#pragma once

#include <thread>
#include "window.hpp"

namespace swindow {
const std::thread::id MAIN_THREAD_ID = std::this_thread::get_id();

struct WindowGlobal {
    std::vector<InternalWindow*> windows;
};
extern WindowGlobal swindow;
}  // namespace swindow
