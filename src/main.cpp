#include <swindow/swindow.hpp>

#include <iostream>

using namespace swindow;

int main() {
    WindowEventQueue queue;
    Window window;
    Window window2;

    queue.SubscribeTo<WindowResizeData>(EventType::Resized, [](const WindowResizeData& data) {
        std::cout << data.width << std::endl;
    });

    queue.SubscribeTo(EventType::CloseRequested, [](const EventData& data) {
        std::cout << "Closing " << data.id << std::endl;
    });

    while (true) {
        queue.Wait();
    }

    return 0;
}
