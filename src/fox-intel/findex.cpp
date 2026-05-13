// findex — build a chunked semantic index of the current directory.
//
// Schema (per row, written as .foxml_index.json array):
//   {path, chunk_id, line_start, line_end, vector, mtime, model}
//
// Chunks are CHUNK_LINES long with OVERLAP_LINES overlap so a function
// straddling a chunk boundary still appears whole in at least one chunk.
// The model name is stored alongside each vector — re-running findex
// after the embedding model changes (or after the schema changed)
// triggers a full rebuild instead of mixing incompatible vectors.

#include "fox_intel.hpp"

#include <algorithm>
#include <atomic>
#include <chrono>
#include <filesystem>
#include <fstream>
#include <future>
#include <iostream>
#include <map>
#include <mutex>
#include <set>
#include <sstream>
#include <string>
#include <thread>
#include <vector>

namespace fs = std::filesystem;

namespace {

constexpr int  MAX_THREADS    = 8;
constexpr int  CHUNK_LINES    = 100;
constexpr int  OVERLAP_LINES  = 10;
constexpr long MAX_FILE_BYTES = 2L * 1024 * 1024;  // skip > 2 MB
constexpr const char* EMBED_MODEL = "mxbai-embed-large";

// Extensions worth embedding. Add freely; cost is per-file.
const std::set<std::string> EXTENSIONS = {
    ".md", ".sh", ".bash", ".zsh", ".conf", ".cfg", ".ini",
    ".lua", ".css", ".json", ".yaml", ".yml", ".toml",
    ".cpp", ".cc", ".cxx", ".c", ".h", ".hpp", ".hh",
    ".py", ".rs", ".go", ".ts", ".tsx", ".js", ".jsx",
    ".txt", ".sql", ".proto"
};

// Path fragments that always indicate generated / vendored / build output.
bool is_excluded(const std::string& path) {
    static const std::vector<std::string> patterns = {
        "/.git/", "/.hg/", "/.svn/",
        "/build/", "/target/", "/dist/", "/out/",
        "/node_modules/", "/.venv/", "/venv/", "/__pycache__/",
        "/.cache/", "/.cargo/", "/rendered/", "/distro/",
        "json.hpp", ".foxml_index.json"
    };
    for (const auto& p : patterns) {
        if (path.find(p) != std::string::npos) return true;
    }
    // Hidden files at top level (./.something) but allow nested .config etc.
    if (path.size() >= 3 && path[0] == '.' && path[1] == '/' && path[2] == '.') return true;
    return false;
}

struct Chunk {
    std::string path;
    int chunk_id;
    int line_start;
    int line_end;
    long long mtime;
    std::string text;  // populated lazily; not stored in index
};

std::vector<Chunk> chunk_file(const std::string& path, long long mtime) {
    std::vector<Chunk> chunks;
    std::ifstream f(path);
    if (!f) return chunks;

    std::vector<std::string> buffer;
    std::string line;
    int line_no = 0;
    int chunk_start_line = 1;
    int chunk_id = 0;

    auto flush = [&](bool final) {
        if (buffer.empty()) return;
        std::ostringstream joined;
        for (const auto& l : buffer) joined << l << '\n';
        chunks.push_back({path, chunk_id++, chunk_start_line, line_no,
                          mtime, joined.str()});
        if (!final && (int)buffer.size() > OVERLAP_LINES) {
            // Keep last OVERLAP_LINES for the next chunk.
            buffer.erase(buffer.begin(), buffer.end() - OVERLAP_LINES);
            chunk_start_line = line_no - OVERLAP_LINES + 1;
        } else {
            buffer.clear();
        }
    };

    while (std::getline(f, line)) {
        ++line_no;
        buffer.push_back(line);
        if ((int)buffer.size() >= CHUNK_LINES) flush(false);
    }
    flush(true);
    return chunks;
}

struct CacheKey {
    std::string path;
    int chunk_id;
    bool operator<(const CacheKey& o) const {
        if (path != o.path) return path < o.path;
        return chunk_id < o.chunk_id;
    }
};

}  // namespace

int main() {
    auto t0 = std::chrono::steady_clock::now();
    FoxIntel intel;
    if (!intel.ensure_ollama_running()) return 1;
    if (!intel.ensure_model_present(EMBED_MODEL)) {
        std::cerr << "Embed model '" << EMBED_MODEL
                  << "' missing and could not be pulled.\n";
        return 1;
    }

    // Load existing index — but only entries that match the current model.
    // Any mismatch (old schema, old model) is treated as cache-miss.
    std::map<CacheKey, json> cache;
    std::ifstream f_in(".foxml_index.json");
    if (f_in.is_open()) {
        try {
            json old = json::parse(f_in);
            for (auto& e : old) {
                if (!e.contains("model") || e["model"] != EMBED_MODEL) continue;
                if (!e.contains("chunk_id")) continue;
                cache[{e["path"], e["chunk_id"]}] = e;
            }
        } catch (...) {}
        std::cout << "Reusing " << cache.size() << " cached embeddings\n";
    }

    std::cout << "Indexing " << fs::current_path() << " ("
              << EMBED_MODEL << ", " << CHUNK_LINES << "-line chunks, "
              << OVERLAP_LINES << "-line overlap)\n";

    std::vector<Chunk> tasks;
    int files_seen = 0, files_skipped_size = 0, files_indexed = 0;

    for (const auto& entry : fs::recursive_directory_iterator(
             ".", fs::directory_options::skip_permission_denied)) {
        if (!entry.is_regular_file()) continue;
        std::string path = entry.path().string();
        if (is_excluded(path)) continue;
        if (!EXTENSIONS.count(entry.path().extension().string())) continue;

        ++files_seen;
        std::error_code ec;
        auto sz = fs::file_size(entry.path(), ec);
        if (!ec && (long)sz > MAX_FILE_BYTES) { ++files_skipped_size; continue; }
        if (!ec && sz == 0) continue;

        long long mtime = std::chrono::duration_cast<std::chrono::seconds>(
            entry.last_write_time().time_since_epoch()).count();

        auto chunks = chunk_file(path, mtime);
        for (auto& c : chunks) tasks.push_back(std::move(c));
        if (!chunks.empty()) ++files_indexed;
    }

    std::cout << "Files: " << files_seen << " seen, " << files_indexed
              << " indexable, " << files_skipped_size << " skipped (>2MB), "
              << tasks.size() << " chunks total\n";

    // Worker pool: bounded async fan-out.
    std::mutex out_mu;
    json new_index = json::array();
    std::vector<std::future<void>> workers;
    std::atomic<int> done{0}, hit{0}, miss{0};

    auto submit = [&](const Chunk& c) {
        workers.push_back(std::async(std::launch::async, [&, c]() {
            // Cache hit: mtime + chunk_id match → reuse vector.
            auto it = cache.find({c.path, c.chunk_id});
            if (it != cache.end() && it->second["mtime"] == c.mtime &&
                it->second["line_start"] == c.line_start &&
                it->second["line_end"]   == c.line_end) {
                std::lock_guard<std::mutex> lk(out_mu);
                new_index.push_back(it->second);
                ++hit; ++done;
                return;
            }
            auto vec = intel.get_embedding(c.text);
            if (!vec.empty()) {
                std::lock_guard<std::mutex> lk(out_mu);
                new_index.push_back({
                    {"path",       c.path},
                    {"chunk_id",   c.chunk_id},
                    {"line_start", c.line_start},
                    {"line_end",   c.line_end},
                    {"mtime",      c.mtime},
                    {"model",      EMBED_MODEL},
                    {"vector",     vec},
                });
            }
            ++miss; ++done;
        }));
    };

    auto drain_one = [&]() {
        workers.front().wait();
        workers.erase(workers.begin());
    };

    int progress_total = tasks.size();
    int last_pct = -1;
    for (size_t i = 0; i < tasks.size(); ++i) {
        if (workers.size() >= MAX_THREADS) drain_one();
        submit(tasks[i]);
        int pct = (int)((i + 1) * 100 / std::max(1, progress_total));
        if (pct != last_pct && pct % 5 == 0) {
            std::cout << "\r  " << pct << "% (" << done.load() << "/"
                      << progress_total << "  hit=" << hit.load()
                      << " miss=" << miss.load() << ")" << std::flush;
            last_pct = pct;
        }
    }
    while (!workers.empty()) drain_one();
    std::cout << "\r  100% (" << done.load() << "/" << progress_total
              << "  hit=" << hit.load() << " miss=" << miss.load() << ")\n";

    std::ofstream out(".foxml_index.json");
    out << new_index.dump() << '\n';

    auto t1 = std::chrono::steady_clock::now();
    auto secs = std::chrono::duration_cast<std::chrono::seconds>(t1 - t0).count();
    std::cout << "Done in " << secs << "s\n";
    return 0;
}
