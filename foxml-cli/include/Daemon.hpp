#pragma once

#include <iostream>
#include <string>
#include <thread>
#include <chrono>
#include <sys/socket.h>
#include <sys/un.h>
#include <unistd.h>
#include "SystemController.hpp"

namespace foxml {

class Daemon {
public:
    static void start() {
        std::cout << "FoxML Daemon starting..." << std::endl;
        
        // Thread for time-based checks
        std::thread time_thread([]() {
            int last_hour = -1;
            while (true) {
                auto now = std::chrono::system_clock::to_time_t(std::chrono::system_clock::now());
                struct tm* ltm = localtime(&now);
                if (ltm->tm_hour != last_hour) {
                    std::cout << "[Daemon] Hour changed: " << ltm->tm_hour << ":00" << std::endl;
                    // Logic for day/night switch could go here
                    last_hour = ltm->tm_hour;
                }
                std::this_thread::sleep_for(std::chrono::minutes(1));
            }
        });

        // Main loop for Hyprland socket
        const char* signature = std::getenv("HYPRLAND_INSTANCE_SIGNATURE");
        if (signature) {
            std::string socket_path = "/tmp/hypr/" + std::string(signature) + "/.socket2.sock";
            int sock = socket(AF_UNIX, SOCK_STREAM, 0);
            struct sockaddr_un addr;
            memset(&addr, 0, sizeof(addr));
            addr.sun_family = AF_UNIX;
            strncpy(addr.sun_path, socket_path.c_str(), sizeof(addr.sun_path)-1);

            if (connect(sock, (struct sockaddr*)&addr, sizeof(addr)) == 0) {
                std::cout << "[Daemon] Connected to Hyprland socket." << std::endl;
                char buffer[1024];
                while (true) {
                    ssize_t bytes = read(sock, buffer, sizeof(buffer)-1);
                    if (bytes <= 0) break;
                    buffer[bytes] = '\0';
                    std::string event(buffer);
                    if (event.find("activewindow>>") != std::string::npos) {
                        // std::cout << "[Daemon] Window change detected: " << event << std::endl;
                    }
                }
            }
            close(sock);
        }

        time_thread.join();
    }
};

} // namespace foxml
