#pragma once

namespace swindow {
enum ControlFlow {
    // Continiously iterage, reguardless of whether or not new events are avaiable to process.
    Poll,
    // Pauses the thread when waiting for new events.
    Wait
};

enum class WindowEventType {
    // Closing a window
    Close,

    // Resizing a window
    Resize,
};

struct WindowResizeData {
    WindowResizeData(unsigned width, unsigned height) : width(width), height(height) {}

    // new width of window viewport
    unsigned width, height;
};

union WindowEventData {
    WindowEventData() {}

    WindowResizeData resize;
};

struct WindowEvent {
    inline WindowEvent(WindowResizeData data) : type(WindowEventType::Resize) {
        this->data.resize = data;
    }

    WindowEventData data;
    WindowEventType type;
};
}  // namespace swindow
