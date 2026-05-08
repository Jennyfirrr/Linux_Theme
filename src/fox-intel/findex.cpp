#include <iostream>
#include <fstream>
#include <string>
#include <vector>
#include <filesystem>
#include <future>
#include <mutex>
#include <chrono>
#include "json.hpp"
#include <curl/curl.h>

using json = nlohmann::json;
namespace fs = std::filesystem;

// --- Multi-threading Config ---
const int MAX_THREADS = 8; 
std::mutex index_mutex;

size_t WriteCallback(void* contents, size_t size, size_t nmemb, std::string* userp) {
    userp->append((char*)contents, size * nmemb);
    return size * nmemb;
}

std::vector<float> get_embedding(const std::string& text) {
    CURL* curl = curl_easy_init();
    std::string readBuffer;
    std::vector<float> embedding;

    if(curl) {
        json body = {{"model", "nomic-embed-text"}, {"prompt", text}};
        std::string json_str = body.dump();
        struct curl_slist* headers = curl_slist_append(NULL, "Content-Type: application/json");

        curl_easy_setopt(curl, CURLOPT_URL, "http://localhost:11434/api/embeddings");
        curl_easy_setopt(curl, CURLOPT_POSTFIELDS, json_str.c_str());
        curl_easy_setopt(curl, CURLOPT_HTTPHEADER, headers);
        curl_easy_setopt(curl, CURLOPT_WRITEFUNCTION, WriteCallback);
        curl_easy_setopt(curl, CURLOPT_WRITEDATA, &readBuffer);

        if(curl_easy_perform(curl) == CURLE_OK) {
            auto j = json::parse(readBuffer);
            if (j.contains("embedding")) embedding = j["embedding"].get<std::vector<float>>();
        }
        curl_easy_cleanup(curl);
        curl_slist_free_all(headers);
    }
    return embedding;
}

struct FileTask {
    std::string path;
    long long mtime;
};

int main() {
    auto start_time = std::chrono::high_resolution_clock::now();
    
    // Pre-flight check
    if (system("ollama list | grep -q nomic-embed-text") != 0) {
        std::cout << "Model not found. Pulling now..." << std::endl;
        system("ollama pull nomic-embed-text");
    }

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
        // Skip if mtime matches
        if (old_index_map.contains(task.path) && old_index_map[task.path]["mtime"] == task.mtime) {
            std::lock_guard<std::mutex> lock(index_mutex);
            new_index.push_back(old_index_map[task.path]);
            continue;
        }

        if (workers.size() >= MAX_THREADS) {
            workers.front().wait();
            workers.erase(workers.begin());
        }

        workers.push_back(std::async(std::launch::async, [&new_index, task]() {
            std::cout << "  -> Processing " << task.path << std::endl;
            std::ifstream f(task.path);
            std::string content((std::istreambuf_iterator<char>(f)), std::istreambuf_iterator<char>());
            if (content.size() > 8000) content = content.substr(0, 8000);

            auto vec = get_embedding(content);
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
