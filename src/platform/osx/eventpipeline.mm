#include <swindow/internal/platform/osx/eventpipeline.hpp>

#include <AppKit/AppKit.h>

namespace swindow {
void WindowEventPipeline::Poll() {
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

void WindowEventPipeline::Wait() {
    NSEvent* event = [NSApp nextEventMatchingMask:NSEventMaskAny
                                        untilDate:[NSDate distantPast]
                                           inMode:NSDefaultRunLoopMode
                                          dequeue:YES];

    if (event == nil)
        return;

    [NSApp sendEvent:event];
}
}  // namespace swindow