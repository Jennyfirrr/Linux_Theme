#include "fox_intel.hpp"
#include <iostream>
#include <fstream>
#include <string>
#include <vector>
#include <algorithm>

int main(int argc, char* argv[]) {
    if (argc < 2) {
        std::cout << "usage: fask \"question\"" << std::endl;
        return 1;
    }

    std::string query = argv[1];
    FoxIntel intel;

    if (!intel.ensure_ollama_running()) return 1;

    // Load index
    std::ifstream f_in(".foxml_index.json");
    if (!f_in.is_open()) {
        std::cout << "Index not found. Run 'findex' first." << std::endl;
        return 1;
    }
    json index_data = json::parse(f_in);

    // Get query embedding
    auto query_vec = intel.get_embedding(query);
    if (query_vec.empty()) return 1;

    // Semantic Search (RAG)
    struct Match { std::string path; double score; };
    std::vector<Match> matches;
    for (auto& el : index_data) {
        double score = FoxIntel::cosine_similarity(query_vec, el["vector"].get<std::vector<float>>());
        matches.push_back({el["path"], score});
    }
    std::sort(matches.begin(), matches.end(), [](const Match& a, const Match& b) { return a.score > b.score; });

    // Build context
    std::string context = "Context from the project:\n";
    for (int i = 0; i < std::min((int)matches.size(), 5); ++i) {
        std::ifstream f(matches[i].path);
        std::string content((std::istreambuf_iterator<char>(f)), std::istreambuf_iterator<char>());
        if (content.size() > 2000) content = content.substr(0, 2000);
        context += "--- File: " + matches[i].path + " ---\n" + content + "\n\n";
    }

    std::string prompt = context + "\nQuestion: " + query + "\nAnswer:";
    std::cout << "\033[1;32m[Thinking...]\033[0m" << std::endl;
    intel.ask(prompt, true); // Streaming answer
    std::cout << std::endl;

    return 0;
}
