#include <swindow/swindow.hpp>

#include <iostream>

using namespace swindow;

int main() {
    WindowOptions options;
    Window window(options);

    window.eventPipeline->SubscribeToResize(
        [](unsigned width, unsigned height) { std::cout << height << std::endl; });

    while (!window.ShouldClose()) {
        window.eventPipeline->Poll();
    }

    return 0;
}