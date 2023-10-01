#pragma once

#include "event.hpp"

namespace swindow {
struct WindowOptions {
    const char* title = "SWindow";
    const char* iconPath;
    int x = 0;
    int y = 0;
    unsigned width = 800;
    unsigned height = 600;
    unsigned minWidth = 0;
    unsigned minHeight = 0;
    unsigned maxWidth = 0xFFFF;
    unsigned maxHeight = 0xFFFF;
    bool visible = true;
    bool resizable = true;
    bool minimizable = true;
    bool center = true;
    bool shadow = true;
    bool showTitle = true;
    bool canClose = true;
    bool rememberPosition = false;
    bool transparent = false;
    bool transparentTitlebar = false;
};

class InternalWindow {
   public:
    virtual void Center() = 0;
    virtual void SetVisible(bool visible) = 0;
    virtual void Close() = 0;
    virtual void Fullscreen() = 0;
    virtual void Minimize() = 0;
    virtual void SetFocus(bool b) = 0;
    virtual void SetPosition(int x, int y) = 0;
    virtual void SetTitle(const char* title) = 0;

    virtual unsigned GetWidth() const = 0;
    virtual unsigned GetHeight() const = 0;
    virtual unsigned GetMinWidth() const = 0;
    virtual unsigned GetMinHeight() const = 0;
    virtual unsigned GetMaxWidth() const = 0;
    virtual unsigned GetMaxHeight() const = 0;
    virtual const char* GetTitle() const = 0;
    virtual bool IsFocused() const = 0;
    inline bool ShouldClose() const { return shouldClose; }
    virtual unsigned GetId() const = 0;

   protected:
    bool shouldClose = false;
};
}  // namespace swindow