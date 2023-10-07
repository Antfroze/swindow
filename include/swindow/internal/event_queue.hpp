#pragma once

#include <functional>
#include "events.hpp"

namespace swindow {
using Callback = std::function<void(const EventData&)>;

struct InternalEventQueue {
    template <typename T>
    inline void SubscribeTo(EventType type, const std::function<void(const T&)>& callback) {
        callbacks[type].push_back([callback](const EventData& data) { callback(data.As<T>()); });
    }

    inline void SubscribeTo(EventType type, const Callback& callback) {
        callbacks[type].push_back(callback);
    }

    template <typename T>
    inline void SubscribeTo(EventType type, const Callback& callback, const T& t) {
        callbacks[type].push_back(std::bind(callback, t));
    }

    inline void HandleEvent(EventType type, const EventData& data) {
        for (const Callback& cb : callbacks[type]) {
            cb(data);
        }
    }

    virtual void Poll() = 0;
    virtual void Wait() = 0;

   private:
    std::unordered_map<EventType, std::vector<Callback>> callbacks;
};
};  // namespace swindow
