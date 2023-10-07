#pragma once

#include <swindow/internal/event_loop.hpp>

namespace swindow {
class AppState {
   public:
    static void Init();
    static void SetCallback(RunCallback* callback);
    static void HandleEvent(const WindowEvent& event);

   private:
    static RunCallback* callback;
};
}  // namespace swindow
