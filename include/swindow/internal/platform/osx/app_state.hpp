#pragma once

#include <swindow/internal/events.hpp>

namespace swindow {
class WindowEventQueue;

class AppState {
   public:
    static void Init(WindowEventQueue* eventQueue);
    static void HandleEvent(EventType type, const EventData& data);

   private:
    static WindowEventQueue* eventQueue;
};
}  // namespace swindow
