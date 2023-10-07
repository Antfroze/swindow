#pragma once

#include <functional>
#include "events.hpp"

namespace swindow {
using RunCallback = std::function<void(const WindowEvent& event)>;

struct EventLoop {
    EventLoop(ControlFlow ctrlFlow = ControlFlow::Poll) : ctrlFlow(ctrlFlow) {}

    void Run(RunCallback callback);
    void Poll();
    void Wait();

    ControlFlow ctrlFlow;
    RunCallback callback;
};
};  // namespace swindow
