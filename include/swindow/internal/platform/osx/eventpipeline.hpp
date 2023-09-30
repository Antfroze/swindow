#pragma once

#include <stdexcept>
#include <swindow/internal/eventpipeline.hpp>
#include <swindow/internal/global.hpp>
#include <thread>

namespace swindow {
struct WindowEventPipeline : public InternalEventPipeline {
    inline WindowEventPipeline() {
        if (std::this_thread::get_id() != MAIN_THREAD_ID) {
            throw std::runtime_error(
                "On MacOS the EventQueue must be on the main thread.");
        }
    }

    void Poll() override;
    void Wait() override;
};
}  // namespace swindow