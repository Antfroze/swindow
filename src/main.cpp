#include <swindow/swindow.hpp>

#include <iostream>

using namespace swindow;

int main() {
    EventLoop loop;
    Window window;

    loop.Run([](const WindowEvent& event) { std::cout << "WHAT" << std::endl; });

    return 0;
}
