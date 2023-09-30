#pragma once

#include <memory>
#include <window.hpp>
#include "osx_eventpipeline.hpp"

namespace swindow {
class Window : public InternalWindow {
   public:
    Window(WindowOptions& opts);
    inline ~Window() { delete eventPipeline; }

    void Center() override;
    void SetVisible(bool visible) override;
    void Close() override;
    void Fullscreen() override;
    void Minimize() override;
    void SetFocus(bool b) override;
    void SetPosition(int x, int y) override;
    void SetTitle(const char* title) override;

    unsigned GetWidth() override;
    unsigned GetHeight() override;
    unsigned GetMinWidth() override;
    unsigned GetMinHeight() override;
    unsigned GetMaxWidth() override;
    unsigned GetMaxHeight() override;
    const char* GetTitle() override;
    bool IsFocused() override;

    void SetLayer(void* layer);

    inline void* GetNSWindow() { return nsWindow; }

    WindowEventPipeline* eventPipeline;

   private:
    void* nsWindow;
    void* view;
    void* layer;
};
}  // namespace swindow
