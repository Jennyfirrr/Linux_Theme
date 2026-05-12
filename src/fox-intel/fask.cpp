#include <iostream>
#include <fstream>
#include <string>
#include <vector>
#include <cmath>
#include <algorithm>
#include <future>
#include <mutex>
#include <thread>
#include <initializer_list>
#include <sys/wait.h>
#include <unistd.h>
#include "json.hpp"
#include <curl/curl.h>

using json = nlohmann::json;

// run_cmd — safe replacement for system(). Uses fork + execvp so no
// shell is ever invoked. Forces the caller to pass an explicit argv
// vector, so a future "let's interpolate a variable in here" change
// can't smuggle in shell metacharacters. Returns the child exit
// status, or -1 on fork/exec failure.
//
// All callers in this file pass compile-time-constant strings, so
// there's no current injection risk — but the pattern was flagged in
// audit as a future-bug magnet, and execvp costs us essentially
// nothing (no /bin/sh fork).
static int run_cmd(std::initializer_list<const char*> argv) {
    pid_t pid = fork();
    if (pid < 0) return -1;
    if (pid == 0) {
        std::vector<const char*> args(argv.begin(), argv.end());
        args.push_back(nullptr);
        execvp(args[0], const_cast<char* const*>(args.data()));
        _exit(127);
    }
    int status = 0;
    if (waitpid(pid, &status, 0) < 0) return -1;
    return WIFEXITED(status) ? WEXITSTATUS(status) : -1;
}

// --- Helper: Curl Write Callback for Embeddings (Full Response) ---
size_t WriteCallback(void* contents, size_t size, size_t nmemb, std::string* userp) {
    userp->append((char*)contents, size * nmemb);
    return size * nmemb;
}

// --- Helper: Stream Callback for Chat (Streaming Response) ---
size_t StreamCallback(void* contents, size_t size, size_t nmemb, void* userp) {
    std::string chunk((char*)contents, size * nmemb);
    try {
        // Ollama streams JSON objects per line
        auto j = json::parse(chunk);
        if (j.contains("response")) {
            std::cout << j["response"].get<std::string>() << std::flush;
        }
    } catch (...) {
        // Sometimes chunks are partial or combined; simple catch-all
    }
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
            try {
                auto j = json::parse(readBuffer);
                if (j.contains("embedding")) embedding = j["embedding"].get<std::vector<float>>();
            } catch (...) {}
        }
        curl_easy_cleanup(curl);
        curl_slist_free_all(headers);
    }
    return embedding;
}

double cosine_similarity(const std::vector<float>& v1, const std::vector<float>& v2) {
    double dot = 0.0, norm_a = 0.0, norm_b = 0.0;
    size_t n = std::min(v1.size(), v2.size());
    for (size_t i = 0; i < n; ++i) {
        dot += v1[i] * v2[i];
        norm_a += v1[i] * v1[i];
        norm_b += v2[i] * v2[i];
    }
    return (norm_a > 0 && norm_b > 0) ? dot / (sqrt(norm_a) * sqrt(norm_b)) : 0.0;
}

int main(int argc, char* argv[]) {
    if (argc < 2) {
        std::cerr << "Usage: fask <query>" << std::endl;
        return 1;
    }

    std::string query;
    for (int i = 1; i < argc; ++i) query += std::string(argv[i]) + (i == argc - 1 ? "" : " ");

    std::ifstream f_idx(".foxml_index.json");
    if (!f_idx.is_open()) {
        std::cerr << "Index file not found. Run 'findex' first." << std::endl;
        return 1;
    }
    json index;
    try { index = json::parse(f_idx); } catch (...) { std::cerr << "Index corrupted." << std::endl; return 1; }

    std::vector<float> query_vec = get_embedding(query);
    if (query_vec.empty()) {
        std::cout << "\033[1;33m[Fox Brain is asleep. Waking up...]\033[0m" << std::endl;
        run_cmd({"sudo", "systemctl", "start", "ollama"});
        // Give it a moment to boot the port
        int retries = 5;
        while (retries--) {
            query_vec = get_embedding(query);
            if (!query_vec.empty()) break;
            std::this_thread::sleep_for(std::chrono::milliseconds(800));
        }
    }

    if (query_vec.empty()) {
        std::cerr << "🦊 Fox Brain failed to wake up. Try running 'f-on' manually." << std::endl;
        return 1;
    }

    std::vector<std::pair<double, std::string>> results;
    std::mutex res_mutex;
    std::vector<std::future<void>> workers;
    
    // Parallel similarity scoring
    size_t chunk_size = (index.size() + 7) / 8; 
    for (size_t i = 0; i < index.size(); i += chunk_size) {
        workers.push_back(std::async(std::launch::async, [&index, &query_vec, &results, &res_mutex, i, chunk_size]() {
            std::vector<std::pair<double, std::string>> local_res;
            for (size_t j = i; j < i + chunk_size && j < index.size(); ++j) {
                if (!index[j].contains("vector") || !index[j].contains("path")) continue;
                std::vector<float> vec = index[j]["vector"].get<std::vector<float>>();
                double sim = cosine_similarity(query_vec, vec);
                local_res.push_back({sim, index[j]["path"]});
            }
            std::lock_guard<std::mutex> lock(res_mutex);
            results.insert(results.end(), local_res.begin(), local_res.end());
        }));
    }
    for (auto& w : workers) w.wait();
    std::sort(results.rbegin(), results.rend());

    std::string context = "";
    std::cout << "\033[1;30m[Researching context...]\033[0m" << std::endl;
    for (size_t i = 0; i < std::min(results.size(), (size_t)5); ++i) {
        if (results[i].first < 0.3) continue; // Skip irrelevant
        std::ifstream file(results[i].second);
        if (file.is_open()) {
            context += "\n--- FILE: " + results[i].second + " ---\n";
            std::string line;
            int count = 0;
            while (std::getline(file, line) && count < 100) { context += line + "\n"; count++; }
        }
    }

    CURL* curl = curl_easy_init();
    if(curl) {
        std::string chat_model = "qwen2.5-coder:7b";
        json body = {
            {"model", chat_model},
            {"prompt", "Context:\n" + context + "\n\nUser Question: " + query},
            {"stream", true}
        };
        std::string json_str = body.dump();
        struct curl_slist* headers = curl_slist_append(NULL, "Content-Type: application/json");

        curl_easy_setopt(curl, CURLOPT_URL, "http://localhost:11434/api/generate");
        curl_easy_setopt(curl, CURLOPT_POSTFIELDS, json_str.c_str());
        curl_easy_setopt(curl, CURLOPT_HTTPHEADER, headers);
        curl_easy_setopt(curl, CURLOPT_WRITEFUNCTION, StreamCallback);
        
        std::cout << "\033[1;33m🦊 Fox Assistant:\033[0m " << std::endl;
        curl_easy_perform(curl);
        std::cout << std::endl;

        // Notify user when prompt is finished
        run_cmd({"notify-send", "-u", "low", "-i", "dialog-information",
                 "Fox Assistant", "Response complete."});

        curl_easy_cleanup(curl);
        curl_slist_free_all(headers);
    }

    return 0;
}
