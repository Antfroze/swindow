#include <platform/osx/osx_window.hpp>

#include <AppKit/AppKit.h>
#include <Foundation/Foundation.h>
#include <event.hpp>
#include <internal.hpp>
#include <stdexcept>

using namespace swindow;

@interface OSXApplicationDelegate : NSObject <NSApplicationDelegate>
@end

@implementation OSXApplicationDelegate
- (NSApplicationTerminateReply)applicationShouldTerminate:
    (NSApplication*)sender {
    for (InternalWindow* window : swindow::swindow.windows) {
        window->Close();
    }

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

@interface OSXWindow : NSWindow
@end

@implementation OSXWindow
- (BOOL)canBecomeKeyWindow {
    // Required for NSWindowStyleMaskBorderless windows
    return YES;
}

- (BOOL)canBecomeMainWindow {
    return YES;
}
@end

@interface OSXWindowDelegate : NSObject <NSWindowDelegate> {
    Window* window;
}
- (instancetype)initWithWindow:(Window*)initWindow;
@end

@implementation OSXWindowDelegate
- (instancetype)initWithWindow:(Window*)initWindow {
    self = [super init];
    if (self != nil)
        window = initWindow;

    return self;
}

- (void)windowDidResize:(NSNotification*)notification {
    NSWindow* nsWindow = (NSWindow*)window->GetNSWindow();

    NSRect rect = [nsWindow contentRectForFrameRect:[nsWindow frame]];

    window->eventPipeline->HandleResize(rect.size.width, rect.size.height);
}

- (BOOL)windowShouldClose:(NSWindow*)sender {
    window->Close();
    return NO;
}
@end

@interface OSXView : NSView
- (BOOL)acceptsFirstResponder;
- (BOOL)isOpaque;
@end

@implementation OSXView
- (void)_updateContentScale {
    NSWindow* mainWindow = [NSApp mainWindow];
    NSWindow* layerWindow = [self window];
    if (mainWindow || layerWindow) {
        CGFloat scale = [(layerWindow != nil) ? layerWindow
                                              : mainWindow backingScaleFactor];
        CALayer* layer = self.layer;
        if ([layer respondsToSelector:@selector(contentsScale)]) {
            [self.layer setContentsScale:scale];
        }
    }
}

- (void)scaleDidChange:(NSNotification*)n {
    [self _updateContentScale];
}

- (void)viewDidMoveToWindow {
    // Retina Display support
    [[NSNotificationCenter defaultCenter]
        addObserver:self
           selector:@selector(scaleDidChange:)
               name:@"NSWindowDidChangeBackingPropertiesNotification"
             object:[self window]];

    // immediately update scale after the view has been added to a window
    [self _updateContentScale];
}

- (void)removeFromSuperview {
    [super removeFromSuperview];
    [[NSNotificationCenter defaultCenter]
        removeObserver:self
                  name:@"NSWindowDidChangeBackingPropertiesNotification"
                object:[self window]];
}

- (BOOL)acceptsFirstResponder {
    return YES;
}

- (BOOL)isOpaque {
    return YES;
}
@end

namespace swindow {
Window::Window(WindowOptions& opts) : eventPipeline(new WindowEventPipeline()) {
    @autoreleasepool {
        [NSApplication sharedApplication];

        OSXApplicationDelegate* appDelegate =
            [[OSXApplicationDelegate alloc] init];
        if (!appDelegate) {
            throw std::runtime_error(
                "Cocoa: Failed to create application delegate");
        }
        [NSApp setDelegate:appDelegate];

        NSDictionary* defaults = @{@"ApplePressAndHoldEnabled": @NO};
        [[NSUserDefaults standardUserDefaults] registerDefaults:defaults];

        if (![[NSRunningApplication currentApplication] isFinishedLaunching]) {
            [NSApp run];
        }

        [NSApp setActivationPolicy:NSApplicationActivationPolicyRegular];

        // End of Application initialization

        NSRect contentRect =
            NSMakeRect(opts.x, opts.y, std::min(opts.width, opts.maxWidth),
                       std::min(opts.height, opts.maxHeight));
        NSWindowStyleMask styleMask{};

        if (opts.showTitle) {
            styleMask |= NSWindowStyleMaskTitled;
        }

        if (opts.minimizable) {
            styleMask |= NSWindowStyleMaskMiniaturizable;
        }

        if (opts.canClose) {
            styleMask |= NSWindowStyleMaskClosable;
        }

        if (opts.resizable) {
            styleMask |= NSWindowStyleMaskResizable;
        }

        OSXWindow* window =
            [[OSXWindow alloc] initWithContentRect:contentRect
                                         styleMask:styleMask
                                           backing:NSBackingStoreBuffered
                                             defer:NO];
        OSXWindowDelegate* delegate =
            [[OSXWindowDelegate alloc] initWithWindow:this];
        [window setDelegate:delegate];

        NSString* nsTitle =
            [NSString stringWithCString:opts.title
                               encoding:[NSString defaultCStringEncoding]];

        if (strlen(opts.title)) {
            [window setTitle:nsTitle];
        }

        if (opts.center) {
            [window center];
        } else {
            NSPoint point = NSMakePoint(opts.x, opts.y);
            point = [window convertPointToScreen:point];
            [window setFrameOrigin:point];
        }

        [window setHasShadow:opts.shadow];
        [window setTitlebarAppearsTransparent:opts.transparentTitlebar];

        OSXView* view = [[OSXView alloc] initWithFrame:contentRect];
        [view setHidden:NO];
        [view setNeedsDisplay:YES];
        [view setWantsLayer:YES];

        [window setContentView:view];

        [window setMinSize:NSMakeSize(opts.minWidth, opts.minHeight)];
        [window setMaxSize:NSMakeSize(opts.maxWidth, opts.maxHeight)];

        if (opts.transparent) {
            [window setHasShadow:NO];
            [window setOpaque:NO];
            [window setBackgroundColor:[NSColor clearColor]];
        }

        [NSApp activateIgnoringOtherApps:YES];
        if (opts.visible) {
            [window orderFront:nil];
        }

        this->nsWindow = window;
        this->view = view;

        eventPipeline->Poll();
        swindow.windows.push_back(this);
    }
}

void Window::Center() {
    [(NSWindow*)nsWindow center];
}

void Window::SetPosition(int x, int y) {
    NSWindow* window = (NSWindow*)nsWindow;

    NSPoint point = NSMakePoint(x, y);
    point = [window convertPointToScreen:point];
    [window setFrameOrigin:point];
}

void Window::SetTitle(const char* title) {
    NSWindow* window = (NSWindow*)nsWindow;

    NSString* nsTitle =
        [NSString stringWithCString:title
                           encoding:[NSString defaultCStringEncoding]];
    [window setTitle:nsTitle];
}

void Window::Fullscreen() {
    [(NSWindow*)nsWindow toggleFullScreen:nil];
}

void Window::Minimize() {
    [(NSWindow*)nsWindow miniaturize:nil];
}

void Window::SetFocus(bool b) {
    NSWindow* window = (NSWindow*)nsWindow;

    if (b) {
        [NSApp activateIgnoringOtherApps:YES];
        [window makeKeyAndOrderFront:nil];
    } else {
        [window resignKeyWindow];
    }
}

uint32_t Window::GetWidth() {
    return NSWidth([(NSWindow*)nsWindow frame]);
}

uint32_t Window::GetHeight() {
    NSWindow* window = (NSWindow*)nsWindow;
    return NSHeight([window contentRectForFrameRect:[window frame]]);
}

uint32_t Window::GetMinWidth() {
    return [(NSWindow*)nsWindow minSize].width;
}

uint32_t Window::GetMinHeight() {
    return [(NSWindow*)nsWindow minSize].height;
}

uint32_t Window::GetMaxWidth() {
    return [(NSWindow*)nsWindow maxSize].width;
}

uint32_t Window::GetMaxHeight() {
    return [(NSWindow*)nsWindow maxSize].height;
}

const char* Window::GetTitle() {
    return
        [[(NSWindow*)nsWindow title] cStringUsingEncoding:NSUTF8StringEncoding];
}

bool Window::IsFocused() {
    return [(NSWindow*)nsWindow isKeyWindow];
}

void Window::SetVisible(bool visible) {
    if (visible) {
        [(NSWindow*)nsWindow orderFront:nil];
    } else {
        [(NSWindow*)nsWindow orderBack:nil];
    }
}

void Window::Close() {
    NSWindow* window = (NSWindow*)nsWindow;
    shouldClose = true;
    [window close];

    [window release];
    [(OSXView*)view release];
    [(CALayer*)layer release];

    nsWindow = nullptr;
    view = nullptr;
    layer = nullptr;
}

void Window::SetLayer(void* layer) {
    NSWindow* window = (NSWindow*)nsWindow;
    window.contentView.wantsLayer = true;
    window.contentView.layer = (CALayer*)layer;
}
}  // namespace swindow
