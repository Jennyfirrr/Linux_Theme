#include <iostream>
#include <fstream>
#include <string>
#include <vector>
#include <cmath>
#include <algorithm>
#include "json.hpp"
#include <curl/curl.h>

using json = nlohmann::json;

// --- Helper: Curl Write Callback ---
size_t WriteCallback(void* contents, size_t size, size_t nmemb, std::string* userp) {
    userp->append((char*)contents, size * nmemb);
    return size * nmemb;
}

// --- Helper: Get Embeddings from Ollama ---
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

double cosine_similarity(const std::vector<float>& v1, const std::vector<float>& v2) {
    double dot = 0.0, norm_a = 0.0, norm_b = 0.0;
    for (size_t i = 0; i < v1.size(); ++i) {
        dot += v1[i] * v2[i];
        norm_a += v1[i] * v1[i];
        norm_b += v2[i] * v2[i];
    }
    return dot / (sqrt(norm_a) * sqrt(norm_b));
}

int main(int argc, char* argv[]) {
    if (argc < 2) {
        std::cerr << "Usage: fask <query>" << std::endl;
        return 1;
    }

    std::string query;
    for (int i = 1; i < argc; ++i) {
        query += std::string(argv[i]) + (i == argc - 1 ? "" : " ");
    }

    std::ifstream f(".foxml_index.json");
    if (!f.is_open()) {
        std::cerr << "Index file not found. Run 'findex' first." << std::endl;
        return 1;
    }
    json index = json::parse(f);

    std::vector<float> query_vec = get_embedding(query);
    if (query_vec.empty()) {
        std::cerr << "Failed to get embedding for query." << std::endl;
        return 1;
    }

    std::vector<std::pair<double, std::string>> results;
    for (auto& entry : index) {
        std::vector<float> vec = entry["vector"].get<std::vector<float>>();
        double sim = cosine_similarity(query_vec, vec);
        results.push_back({sim, entry["path"]});
    }

    std::sort(results.rbegin(), results.rend());

    std::string context = "";
    std::cout << "Researching relevant context..." << std::endl;
    for (size_t i = 0; i < std::min(results.size(), (size_t)5); ++i) {
        std::string path = results[i].second;
        std::ifstream file(path);
        if (file.is_open()) {
            std::string line;
            context += "\n--- FILE: " + path + " ---\n";
            int count = 0;
            while (std::getline(file, line) && count < 100) {
                context += line + "\n";
                count++;
            }
        }
    }

    // Now call the chat model
    CURL* curl = curl_easy_init();
    if(curl) {
        std::string chat_model = "qwen2.5-coder:7b"; // Default
        
        json body = {
            {"model", chat_model},
            {"prompt", "Context:\n" + context + "\n\nUser Question: " + query},
            {"stream", false}
        };
        std::string json_str = body.dump();

        struct curl_slist* headers = NULL;
        headers = curl_slist_append(headers, "Content-Type: application/json");

        curl_easy_setopt(curl, CURLOPT_URL, "http://localhost:11434/api/generate");
        curl_easy_setopt(curl, CURLOPT_POSTFIELDS, json_str.c_str());
        curl_easy_setopt(curl, CURLOPT_HTTPHEADER, headers);
        
        // Output result directly to stdout
        curl_easy_perform(curl);
        
        curl_easy_cleanup(curl);
        curl_slist_free_all(headers);
    }

    return 0;
}
