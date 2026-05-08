#include <iostream>
#include <fstream>
#include <string>
#include <vector>
#include <filesystem>
#include "json.hpp"
#include <curl/curl.h>

using json = nlohmann::json;
namespace fs = std::filesystem;

size_t WriteCallback(void* contents, size_t size, size_t nmemb, std::string* userp) {
    userp->append((char*)contents, size * nmemb);
    return size * nmemb;
}

std::vector<float> get_embedding(const std::string& text) {
    CURL* curl = curl_easy_init();
    std::string readBuffer;
    std::vector<float> embedding;

    if(curl) {
        json body = {
            {"model", "nomic-embed-text"},
            {"prompt", text}
        };
        std::string json_str = body.dump();

        struct curl_slist* headers = NULL;
        headers = curl_slist_append(headers, "Content-Type: application/json");

        curl_easy_setopt(curl, CURLOPT_URL, "http://localhost:11434/api/embeddings");
        curl_easy_setopt(curl, CURLOPT_POSTFIELDS, json_str.c_str());
        curl_easy_setopt(curl, CURLOPT_HTTPHEADER, headers);
        curl_easy_setopt(curl, CURLOPT_WRITEFUNCTION, WriteCallback);
        curl_easy_setopt(curl, CURLOPT_WRITEDATA, &readBuffer);

        CURLcode res = curl_easy_perform(curl);
        if(res == CURLE_OK) {
            auto j = json::parse(readBuffer);
            if (j.contains("embedding")) {
                embedding = j["embedding"].get<std::vector<float>>();
            }
        }
        curl_easy_cleanup(curl);
        curl_slist_free_all(headers);
    }
    return embedding;
}

int main() {
    std::cout << "Indexing " << fs::current_path() << "..." << std::endl;
    json index = json::array();

    std::vector<std::string> extensions = {".md", ".sh", ".conf", ".lua", ".css", ".json", ".cpp", ".h", ".hpp"};

    for (const auto& entry : fs::recursive_directory_iterator(".")) {
        if (entry.is_regular_file()) {
            std::string path = entry.path().string();
            
            // Skip hidden and rendered/distro
            if (path.find("/.") != std::string::npos || 
                path.find("./rendered") != std::string::npos ||
                path.find("./distro") != std::string::npos ||
                path.find("./src/fox-intel/json.hpp") != std::string::npos) continue;

            bool match = false;
            for (const auto& ext : extensions) {
                if (entry.path().extension() == ext) {
                    match = true;
                    break;
                }
            }

            if (match) {
                std::cout << "  -> Processing " << path << std::endl;
                std::ifstream f(path);
                std::string content((std::istreambuf_iterator<char>(f)), std::istreambuf_iterator<char>());
                
                // Truncate to avoid context window blowup
                if (content.size() > 8000) content = content.substr(0, 8000);

                auto vec = get_embedding(content);
                if (!vec.empty()) {
                    index.push_back({{"path", path}, {"vector", vec}});
                }
            }
        }
    }

    std::ofstream out(".foxml_index.json");
    out << index.dump() << std::endl;
    std::cout << "✨ Indexing complete." << std::endl;

    return 0;
}
