#pragma once

#include <stdexcept>
#include <swindow/internal/event_queue.hpp>
#include <thread>
#include "app_state.hpp"

const std::thread::id MAIN_THREAD_ID = std::this_thread::get_id();

namespace swindow {
struct WindowEventQueue : public InternalEventQueue {
    inline WindowEventQueue() {
        if (std::this_thread::get_id() != MAIN_THREAD_ID) {
            throw std::runtime_error("On MacOS the EventQueue must be on the main thread.");
        }

        AppState::SetQueue(this);
    }

    void Poll() override;
    void Wait() override;
};
}  // namespace swindow