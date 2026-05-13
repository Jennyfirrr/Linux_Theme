#include "fox_intel.hpp"
#include <iostream>
#include <fstream>
#include <cmath>
#include <algorithm>
#include <sys/wait.h>
#include <unistd.h>
#include <cstdlib>
#include <cstring>
#include <thread>
#include <chrono>

FoxIntel::FoxIntel(std::string model) : default_model(model) {
    // Allow user/env override of the default model.
    // Precedence: FOXAI_MODEL env > ~/.config/opencode/opencode.json > ~/.config/foxml/ai-model.conf > ctor arg.
    if (const char* env = std::getenv("FOXAI_MODEL"); env && *env) {
        default_model = env;
    } else if (const char* home = std::getenv("HOME"); home && *home) {
        std::string home_str = home;
        // 1. Try OpenCode config (modern standard)
        std::ifstream f_opencode(home_str + "/.config/opencode/opencode.json");
        bool found = false;
        if (f_opencode.is_open()) {
            try {
                json data;
                f_opencode >> data;
                if (data.contains("model")) {
                    std::string m = data["model"].get<std::string>();
                    if (m.find("ollama/") == 0) m = m.substr(7);
                    if (!m.empty()) { default_model = m; found = true; }
                }
            } catch (...) {}
        }

        // 2. Fallback to legacy FoxML config
        if (!found) {
            std::ifstream f_legacy(home_str + "/.config/foxml/ai-model.conf");
            std::string line;
            while (std::getline(f_legacy, line)) {
                if (line.empty() || line[0] == '#') continue;
                auto eq = line.find('=');
                if (eq == std::string::npos) continue;
                if (line.substr(0, eq) != "MODEL") continue;
                std::string v = line.substr(eq + 1);
                while (!v.empty() && (v.front() == ' '  || v.front() == '\t' ||
                                      v.front() == '"'  || v.front() == '\'')) v.erase(0, 1);
                while (!v.empty() && (v.back()  == ' '  || v.back()  == '\t' ||
                                      v.back()  == '\r' || v.back()  == '\n' ||
                                      v.back()  == '"'  || v.back()  == '\'')) v.pop_back();
                if (!v.empty()) { default_model = v; break; }
            }
        }
    }

    curl_global_init(CURL_GLOBAL_DEFAULT);
    curl = curl_easy_init();
}

FoxIntel::~FoxIntel() {
    if (curl) curl_easy_cleanup(curl);
    curl_global_cleanup();
}

size_t FoxIntel::WriteCallback(void* contents, size_t size, size_t nmemb, std::string* userp) {
    userp->append((char*)contents, size * nmemb);
    return size * nmemb;
}

size_t FoxIntel::StreamCallback(void* contents, size_t size, size_t nmemb, void* userp) {
    std::string chunk((char*)contents, size * nmemb);
    try {
        auto j = json::parse(chunk);
        if (j.contains("response")) {
            std::cout << j["response"].get<std::string>() << std::flush;
        }
    } catch (...) {}
    return size * nmemb;
}

std::vector<float> FoxIntel::get_embedding(const std::string& text) {
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
        curl_slist_free_all(headers);
    }
    return embedding;
}

std::string FoxIntel::ask(const std::string& prompt, bool stream) {
    std::string readBuffer;
    if(curl) {
        json body = {{"model", default_model}, {"prompt", prompt}, {"stream", stream}};
        std::string json_str = body.dump();
        struct curl_slist* headers = curl_slist_append(NULL, "Content-Type: application/json");

        curl_easy_setopt(curl, CURLOPT_URL, "http://localhost:11434/api/generate");
        curl_easy_setopt(curl, CURLOPT_POSTFIELDS, json_str.c_str());
        curl_easy_setopt(curl, CURLOPT_HTTPHEADER, headers);
        
        if (stream) {
            curl_easy_setopt(curl, CURLOPT_WRITEFUNCTION, StreamCallback);
        } else {
            curl_easy_setopt(curl, CURLOPT_WRITEFUNCTION, WriteCallback);
            curl_easy_setopt(curl, CURLOPT_WRITEDATA, &readBuffer);
        }

        if(curl_easy_perform(curl) == CURLE_OK && !stream) {
            try {
                auto j = json::parse(readBuffer);
                if (j.contains("response")) return j["response"].get<std::string>();
            } catch (...) {}
        }
        curl_slist_free_all(headers);
    }
    return readBuffer;
}

double FoxIntel::cosine_similarity(const std::vector<float>& v1, const std::vector<float>& v2) {
    double dot = 0.0, norm_a = 0.0, norm_b = 0.0;
    size_t n = std::min(v1.size(), v2.size());
    for (size_t i = 0; i < n; ++i) {
        dot += v1[i] * v2[i];
        norm_a += v1[i] * v1[i];
        norm_b += v2[i] * v2[i];
    }
    return (norm_a > 0 && norm_b > 0) ? dot / (sqrt(norm_a) * sqrt(norm_b)) : 0.0;
}

bool FoxIntel::ensure_ollama_running() {
    if (FoxUtils::run_cmd({"ollama", "list"}) != 0) {
        std::cout << "\033[1;33m[Fox Brain is asleep. Waking up...]\033[0m" << std::endl;
        FoxUtils::run_cmd({"sudo", "systemctl", "start", "ollama"});
        std::this_thread::sleep_for(std::chrono::seconds(2));
        return FoxUtils::run_cmd({"ollama", "list"}) == 0;
    }
    return true;
}

bool FoxIntel::ensure_model_present(const std::string& model_name) {
    if (!FoxUtils::has_model(model_name.c_str())) {
        std::cout << "Model " << model_name << " not found. Pulling now..." << std::endl;
        return FoxUtils::run_cmd({"ollama", "pull", model_name.c_str()}) == 0;
    }
    return true;
}

int FoxUtils::run_cmd(std::initializer_list<const char*> argv) {
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

bool FoxUtils::has_model(const char* pattern) {
    int pipefd[2];
    if (pipe(pipefd) < 0) return false;
    pid_t pid = fork();
    if (pid < 0) {
        close(pipefd[0]); close(pipefd[1]);
        return false;
    }
    if (pid == 0) {
        close(pipefd[0]);
        dup2(pipefd[1], STDOUT_FILENO);
        close(pipefd[1]);
        execlp("ollama", "ollama", "list", (char*)nullptr);
        _exit(127);
    }
    close(pipefd[1]);
    FILE* f = fdopen(pipefd[0], "r");
    bool found = false;
    if (f) {
        char buf[4096];
        while (fgets(buf, sizeof(buf), f)) {
            if (strstr(buf, pattern)) { found = true; break; }
        }
        fclose(f);
    } else {
        close(pipefd[0]);
    }
    int status = 0;
    waitpid(pid, &status, 0);
    return found;
}
