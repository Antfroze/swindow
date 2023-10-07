#pragma once

#include <swindow/internal/window.hpp>

namespace swindow {
class Window : public InternalWindow {
   public:
    Window(const WindowOptions& opts = WindowOptions());

    void Center() override;
    void SetVisible(bool visible) override;
    void Close() override;
    void Fullscreen() override;
    void Minimize() override;
    void SetFocus(bool b) override;
    void SetPosition(int x, int y) override;
    void SetTitle(const char* title) override;

    void OnResize(unsigned width, unsigned height);
    unsigned GetWidth() const override;
    unsigned GetHeight() const override;
    unsigned GetMinWidth() const override;
    unsigned GetMinHeight() const override;
    unsigned GetMaxWidth() const override;
    unsigned GetMaxHeight() const override;
    const char* GetTitle() const override;
    bool IsFocused() const override;
    unsigned GetId() const override;

    void SetLayer(void* layer);

    inline void* GetNSWindow() const { return nsWindow; }

   private:
    void* nsWindow;
    void* view;
    void* layer;
};
}  // namespace swindow
