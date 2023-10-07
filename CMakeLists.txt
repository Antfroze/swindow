cmake_minimum_required(VERSION 3.15)

project(SWindow)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED YES)
enable_language(OBJCXX)

file(GLOB_RECURSE sources src "*.cpp")
file(GLOB_RECURSE objc_sources src "*.mm")

add_executable(SWindow ${sources} ${objc_sources})

target_include_directories(SWindow PRIVATE include)

target_link_libraries(SWindow PRIVATE
    "-framework Cocoa"
)

# 'Cocoa', 'IOKit', 'CoreFoundation', 'CoreVideo'
