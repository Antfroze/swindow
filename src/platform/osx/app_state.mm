#include <swindow/internal/platform/osx/app_state.hpp>

#include <AppKit/AppKit.h>
#include <iostream>

@interface ApplicationDelegate : NSObject <NSApplicationDelegate>
@end

@implementation ApplicationDelegate
- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication*)sender {
    return NSTerminateCancel;
}

- (void)applicationWillFinishLaunching:(NSNotification*)notification {
    id menubar = [[NSMenu new] autorelease];
    id appMenuItem = [[NSMenuItem new] autorelease];
    [menubar addItem:appMenuItem];
    [NSApp setMainMenu:menubar];
    id appMenu = [[NSMenu new] autorelease];
    id appName = [[NSProcessInfo processInfo] processName];
    id quitMenuItem = [[[NSMenuItem alloc] initWithTitle:@"Quit"
                                                  action:@selector(terminate:)
                                           keyEquivalent:@"q"] autorelease];
    [appMenu addItem:quitMenuItem];
    [appMenuItem setSubmenu:appMenu];
}

- (void)applicationDidFinishLaunching:(NSNotification*)notification {
    NSEvent* event = [NSEvent otherEventWithType:NSEventTypeApplicationDefined
                                        location:NSMakePoint(0, 0)
                                   modifierFlags:0
                                       timestamp:0
                                    windowNumber:0
                                         context:nil
                                         subtype:0
                                           data1:0
                                           data2:0];
    [NSApp postEvent:event atStart:YES];

    [NSApp stop:nil];
}
@end

namespace swindow {
RunCallback* AppState::callback = nullptr;

void AppState::Init() {
    NSApplication* app = [NSApplication sharedApplication];
    ApplicationDelegate* appDelegate = [[ApplicationDelegate alloc] init];

    if (!appDelegate) {
        throw std::runtime_error("Cocoa: Failed to create application delegate!");
    }

    [app setDelegate:appDelegate];

    if (![[NSRunningApplication currentApplication] isFinishedLaunching]) {
        [app run];
    }

    [app setActivationPolicy:NSApplicationActivationPolicyRegular];
}

void AppState::SetCallback(RunCallback* callback) {
    AppState::callback = callback;
}

void AppState::HandleEvent(const WindowEvent& event) {
    (*AppState::callback)(event);
}
}  // namespace swindow
