#include <swindow/internal/platform/osx/window.hpp>

#include <AppKit/AppKit.h>
#include <Foundation/Foundation.h>
#include <iostream>
#include <swindow/internal/events.hpp>
#include <swindow/internal/platform/osx/app_state.hpp>

using namespace swindow;

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

    AppState::HandleEvent(EventType::Resized,
                          WindowResizeData(window->GetId(), rect.size.width, rect.size.height));
}

- (BOOL)windowShouldClose:(NSWindow*)sender {
    AppState::HandleEvent(EventType::CloseRequested, EventData(window->GetId()));
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
        CGFloat scale = [(layerWindow != nil) ? layerWindow : mainWindow backingScaleFactor];
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
Window::Window(const WindowOptions& opts) {
    @autoreleasepool {
        NSRect contentRect = NSMakeRect(opts.x, opts.y, std::min(opts.width, opts.maxWidth),
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

        OSXWindow* window = [[OSXWindow alloc] initWithContentRect:contentRect
                                                         styleMask:styleMask
                                                           backing:NSBackingStoreBuffered
                                                             defer:NO];
        OSXWindowDelegate* delegate = [[OSXWindowDelegate alloc] initWithWindow:this];
        [window setDelegate:delegate];

        NSString* nsTitle = [NSString stringWithCString:opts.title
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

        if (opts.visible) {
            [window orderFront:nil];
        }

        this->nsWindow = window;
        this->view = view;
    }
}

void Window::OnResize(unsigned width, unsigned height) {
    std::cout << width << std::endl;
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

    NSString* nsTitle = [NSString stringWithCString:title
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

uint32_t Window::GetWidth() const {
    return NSWidth([(NSWindow*)nsWindow frame]);
}

uint32_t Window::GetHeight() const {
    NSWindow* window = (NSWindow*)nsWindow;
    return NSHeight([window contentRectForFrameRect:[window frame]]);
}

uint32_t Window::GetMinWidth() const {
    return [(NSWindow*)nsWindow minSize].width;
}

uint32_t Window::GetMinHeight() const {
    return [(NSWindow*)nsWindow minSize].height;
}

uint32_t Window::GetMaxWidth() const {
    return [(NSWindow*)nsWindow maxSize].width;
}

uint32_t Window::GetMaxHeight() const {
    return [(NSWindow*)nsWindow maxSize].height;
}

const char* Window::GetTitle() const {
    return [[(NSWindow*)nsWindow title] cStringUsingEncoding:NSUTF8StringEncoding];
}

bool Window::IsFocused() const {
    return [(NSWindow*)nsWindow isKeyWindow];
}

unsigned Window::GetId() const {
    return [(NSWindow*)nsWindow windowNumber];
}

void Window::SetVisible(bool visible) {
    visible ? [(NSWindow*)nsWindow orderFront:nil] : [(NSWindow*)nsWindow orderBack:nil];
}

void Window::Close() {
    NSWindow* window = (NSWindow*)nsWindow;
    shouldClose = true;
    [window.delegate release];
    [window close];

    [(OSXView*)view release];
    [(CALayer*)layer release];

    nsWindow = nil;
    view = nil;
    layer = nil;
}

void Window::SetLayer(void* layer) {
    NSWindow* window = (NSWindow*)nsWindow;
    window.contentView.wantsLayer = true;
    window.contentView.layer = (CALayer*)layer;
}
}  // namespace swindow
