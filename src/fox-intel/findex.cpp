#include "fox_intel.hpp"
#include <iostream>
#include <fstream>
#include <string>
#include <vector>
#include <filesystem>
#include <future>
#include <mutex>
#include <chrono>
#include <thread>

namespace fs = std::filesystem;

const int MAX_THREADS = 8; 
std::mutex index_mutex;

struct FileTask {
    std::string path;
    long long mtime;
};

int main() {
    auto start_time = std::chrono::high_resolution_clock::now();
    FoxIntel intel;

    if (!intel.ensure_ollama_running()) return 1;
    if (!intel.ensure_model_present("nomic-embed-text")) return 1;

    // Load existing index for mtime check
    json old_index_map = json::object();
    std::ifstream f_in(".foxml_index.json");
    if (f_in.is_open()) {
        try {
            json old_data = json::parse(f_in);
            for (auto& el : old_data) old_index_map[el["path"]] = el;
        } catch (...) {}
    }

    std::cout << "Indexing " << fs::current_path() << " (Parallel)..." << std::endl;
    std::vector<FileTask> tasks;
    std::vector<std::string> extensions = {".md", ".sh", ".conf", ".lua", ".css", ".json", ".cpp", ".h", ".hpp"};

    for (const auto& entry : fs::recursive_directory_iterator(".")) {
        if (!entry.is_regular_file()) continue;
        std::string path = entry.path().string();
        if (path.find("/.") != std::string::npos || path.find("./rendered") != std::string::npos ||
            path.find("./distro") != std::string::npos || path.find("json.hpp") != std::string::npos ||
            path.find(".foxml_index.json") != std::string::npos) continue;

        bool match = false;
        for (const auto& ext : extensions) { if (entry.path().extension() == ext) { match = true; break; } }
        if (match) {
            long long mtime = std::chrono::duration_cast<std::chrono::seconds>(
                entry.last_write_time().time_since_epoch()).count();
            tasks.push_back({path, mtime});
        }
    }

    json new_index = json::array();
    std::vector<std::future<void>> workers;
    
    for (const auto& task : tasks) {
        if (old_index_map.contains(task.path) && old_index_map[task.path]["mtime"] == task.mtime) {
            std::lock_guard<std::mutex> lock(index_mutex);
            new_index.push_back(old_index_map[task.path]);
            continue;
        }

        if (workers.size() >= MAX_THREADS) {
            workers.front().wait();
            workers.erase(workers.begin());
        }

        workers.push_back(std::async(std::launch::async, [&new_index, task, &intel]() {
            std::cout << "  -> Processing " << task.path << std::endl;
            std::ifstream f(task.path);
            std::string content((std::istreambuf_iterator<char>(f)), std::istreambuf_iterator<char>());
            if (content.size() > 8000) content = content.substr(0, 8000);

            auto vec = intel.get_embedding(content);
            if (!vec.empty()) {
                std::lock_guard<std::mutex> lock(index_mutex);
                new_index.push_back({{"path", task.path}, {"vector", vec}, {"mtime", task.mtime}});
            }
        }));
    }

    for (auto& w : workers) w.wait();

    std::ofstream out(".foxml_index.json");
    out << new_index.dump() << std::endl;
    
    auto end_time = std::chrono::high_resolution_clock::now();
    auto duration = std::chrono::duration_cast<std::chrono::milliseconds>(end_time - start_time);
    std::cout << "✨ Indexing complete in " << duration.count() << "ms." << std::endl;

    return 0;
}
