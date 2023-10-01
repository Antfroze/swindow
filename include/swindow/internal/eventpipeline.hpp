#pragma once

#include <any>
#include <functional>
#include <unordered_map>
#include "event.hpp"

using ResizeCallback = std::function<void(const unsigned width, const unsigned height)>;
using CloseCallback = std::function<void(const unsigned id)>;
using Callback = std::variant<ResizeCallback, CloseCallback>;

namespace swindow {
class InternalEventPipeline {
   public:
    virtual ~InternalEventPipeline() {}

    virtual void Poll() = 0;
    virtual void Wait() = 0;

    inline void SubscribeTo(WindowEventType type, const Callback& cb) {
        eventCallbacks[type].push_back(cb);
    }

    template <typename R, typename T, typename U, typename... Args>
    inline void SubscribeTo(WindowEventType type, R (T::*f)(Args...), U p) {
        eventCallbacks[type].push_back([p, f](Args... args) -> R { return (p->*f)(args...); });
    };

    template <typename... Args>
    inline void HandleEvent(WindowEventType type, Args... args) {
        for (Callback& cb : eventCallbacks[type]) {
            std::visit(
                [&args...](const auto& func) {
                    if constexpr (std::is_invocable_v<decltype(func), Args...>) {
                        func(args...);
                    }
                },
                cb);
        }
    }

   protected:
    std::unordered_map<WindowEventType, std::vector<Callback>> eventCallbacks;
};
}  // namespace swindow
