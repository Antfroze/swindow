#pragma once

#include <event.hpp>
#include <functional>
#include <vector>

typedef std::function<void(const unsigned width, const unsigned height)>
    ResizeCallback;

namespace swindow {
class InternalEventPipeline {
   public:
    virtual ~InternalEventPipeline() {}

    virtual void Poll() = 0;
    virtual void Wait() = 0;

    inline void SubscribeToResize(ResizeCallback cb) {
        resizeCallbacks.push_back(cb);
    }

    template <typename T>
    inline void BindToResize(void (T::*cb)(const unsigned, const unsigned),
                             T* instance) {
        resizeCallbacks.push_back(std::bind(cb, instance, std::placeholders::_1,
                                            std::placeholders::_2));
    }

    inline void HandleResize(unsigned width, unsigned height) {
        for (ResizeCallback cb : resizeCallbacks) {
            cb(width, height);
        }
    }

   protected:
    std::vector<ResizeCallback> resizeCallbacks;
};
}  // namespace swindow
