#pragma once

namespace swindow {
enum class WindowEventType {
    None = 0,

    // Closing a window
    Close,

    // Resizing a window
    Resize,
};

struct WindowResizeData {
    WindowResizeData(unsigned width, unsigned height)
        : width(width), height(height) {}

    // new width of window viewport
    unsigned width, height;
};

union WindowEventData {
    WindowEventData() {}

    WindowResizeData resize;
};

struct WindowEvent {
    inline WindowEvent(WindowEventType type = WindowEventType::None)
        : type(type) {}
    inline WindowEvent(WindowResizeData data) : type(WindowEventType::Resize) {
        this->data.resize = data;
    }

    WindowEventData data;
    WindowEventType type;
};
}  // namespace swindow
