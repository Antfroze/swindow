#pragma once

namespace swindow {
enum class EventType {
    Resized,
    CloseRequested,
};

struct EventData {
    inline EventData(unsigned id) : id(id) {}

    template <typename T>
    inline T As() const {
        return reinterpret_cast<const T&>(*this);
    }

    unsigned id;
};

struct WindowResizeData : EventData {
    WindowResizeData(unsigned id, unsigned width, unsigned height)
        : EventData(id), width(width), height(height) {}

    // new width of window viewport
    unsigned width, height;
};
}  // namespace swindow
