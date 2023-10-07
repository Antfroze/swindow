#include <swindow/internal/event_loop.hpp>

#include <AppKit/AppKit.h>
#include <iostream>
#include <swindow/internal/global.hpp>
#include <swindow/internal/platform/osx/app_state.hpp>
#include <thread>

namespace swindow {
void EventLoop::Run(RunCallback callback) {
    if (std::this_thread::get_id() != MAIN_THREAD_ID) {
        throw std::runtime_error("On MacOS the EventQueue must be on the main thread.");
    }

    this->callback = callback;
    AppState::Init();
    AppState::SetCallback(&callback);

    while (true) {
        switch (ctrlFlow) {
            case ControlFlow::Poll: {
                Poll();
                break;
            }
            case ControlFlow::Wait: {
                Wait();
                break;
            }
        }
    }
}

void EventLoop::Poll() {
    while (true) {
        NSEvent* event = [NSApp nextEventMatchingMask:NSEventMaskAny
                                            untilDate:[NSDate distantPast]
                                               inMode:NSDefaultRunLoopMode
                                              dequeue:YES];

        if (event == nil)
            break;

        [NSApp sendEvent:event];
    }
}

void EventLoop::Wait() {
    NSEvent* event = [NSApp nextEventMatchingMask:NSEventMaskAny
                                        untilDate:[NSDate distantPast]
                                           inMode:NSDefaultRunLoopMode
                                          dequeue:YES];

    [NSApp sendEvent:event];
    Poll();
}
}  // namespace swindow
