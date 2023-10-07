#include <swindow/internal/platform/osx/event_queue.hpp>

#include <AppKit/AppKit.h>

namespace swindow {
void WindowEventQueue::Poll() {
    @autoreleasepool {
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
}

// Freezes the thread until a event is available
void WindowEventQueue::Wait() {
    @autoreleasepool {
        NSEvent* event = [NSApp nextEventMatchingMask:NSEventMaskAny
                                            untilDate:[NSDate distantFuture]
                                               inMode:NSDefaultRunLoopMode
                                              dequeue:NO];

        Poll();
    }
}
}  // namespace swindow
