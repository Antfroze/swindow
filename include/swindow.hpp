#if defined(_WIN32) || defined(__CYGWIN__)
#elif defined(__linux__)
#elif defined(__APPLE__) && defined(__MACH__)
#include <platform/osx/osx_window.hpp>
#elif defined(unix) || defined(__unix__) || defined(__unix)
#else
#error Unsupported platform
#endif
