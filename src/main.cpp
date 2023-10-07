#include <swindow/swindow.hpp>

#include <iostream>

using namespace swindow;

int main() {
    WindowEventQueue queue;
    Window window;

    queue.SubscribeTo(EventType::Resized, [](const EventData& data) {
        const WindowResizeData& resizeData = data.As<WindowResizeData>();
        std::cout << resizeData.width << std::endl;
    });

    queue.SubscribeTo(EventType::CloseRequested, [](const EventData& data) {
        std::cout << "cLosing " << data.id << std::endl;
    });

    while (true) {
        queue.Wait();
    }

    return 0;
}
