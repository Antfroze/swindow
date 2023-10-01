#include <swindow/swindow.hpp>

#include <iostream>

using namespace swindow;

int main() {
    WindowOptions options;
    Window window(options);

    window.eventPipeline->SubscribeTo(WindowEventType::Resize, [](unsigned width, unsigned height) {
        std::cout << height << std::endl;
    });

    window.eventPipeline->SubscribeTo(
        WindowEventType::Close, [](unsigned id) { std::cout << "Closing " << id << std::endl; });

    while (!window.ShouldClose()) {
        window.eventPipeline->Poll();
    }

    return 0;
}