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
#include <fcntl.h>

static int g_curl_ref_count = 0;
static std::mutex g_curl_ref_mu;

FoxIntel::FoxIntel(std::string model) : default_model(model), accent_color("\033[1;32m") {
    const char* home = std::getenv("HOME");
    std::string home_str = home ? home : "";

    // 1. Load active AI model
    if (const char* env = std::getenv("FOXAI_MODEL"); env && *env) {
        default_model = env;
    } else if (!home_str.empty()) {
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

    // 2. Load theme colors
    if (!home_str.empty()) {
        std::ifstream f_colors(home_str + "/.config/foxml/ansi_colors.json");
        if (f_colors.is_open()) {
            try {
                json colors;
                f_colors >> colors;
                if (colors.contains("accent1")) {
                    accent_color = "\033[38;5;" + colors["accent1"].get<std::string>() + "m";
                }
            } catch (...) {}
        }
    }

    std::lock_guard<std::mutex> lk(g_curl_ref_mu);
    if (g_curl_ref_count == 0) curl_global_init(CURL_GLOBAL_DEFAULT);
    g_curl_ref_count++;
}

FoxIntel::~FoxIntel() {
    std::lock_guard<std::mutex> lk(g_curl_ref_mu);
    g_curl_ref_count--;
    if (g_curl_ref_count == 0) curl_global_cleanup();
}

std::string FoxIntel::color_accent() { return accent_color; }
std::string FoxIntel::color_dim() { return "\033[2m"; }
std::string FoxIntel::color_reset() { return "\033[0m"; }

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

std::vector<float> FoxIntel::get_embedding(const std::string& text, const std::string& model) {
    std::string readBuffer;
    std::vector<float> embedding;

    std::string model_name = model.empty() ? "mxbai-embed-large" : model;

    CURL* curl = curl_easy_init();
    if(curl) {
        json body = {{"model", model_name}, {"prompt", text}};
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
        curl_easy_cleanup(curl);
    }
    return embedding;
}

std::string FoxIntel::ask(const std::string& prompt, bool stream) {
    std::string readBuffer;
    CURL* curl = curl_easy_init();
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
                if (j.contains("response")) {
                    readBuffer = j["response"].get<std::string>();
                }
            } catch (...) {}
        }
        curl_slist_free_all(headers);
        curl_easy_cleanup(curl);
    }
    if (stream) return "";
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
    // Silent check (redirect stdout/stderr to /dev/null)
    if (FoxUtils::run_cmd({"ollama", "list"}, true) != 0) {
        std::cout << color_accent() << "[Fox Brain is asleep. Waking up...]" << color_reset() << std::endl;
        FoxUtils::run_cmd({"sudo", "systemctl", "start", "ollama"});
        std::this_thread::sleep_for(std::chrono::seconds(2));
        return FoxUtils::run_cmd({"ollama", "list"}, true) == 0;
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

int FoxUtils::run_cmd(std::initializer_list<const char*> argv, bool silent) {
    pid_t pid = fork();
    if (pid < 0) return -1;
    if (pid == 0) {
        if (silent) {
            int devnull = open("/dev/null", O_WRONLY);
            if (devnull >= 0) {
                dup2(devnull, STDOUT_FILENO);
                dup2(devnull, STDERR_FILENO);
                close(devnull);
            }
        }
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
