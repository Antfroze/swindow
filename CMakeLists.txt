cmake_minimum_required(VERSION 3.15)

project(swindow)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_EXPORT_COMPILE_COMMANDS YES)
enable_language(OBJCXX)

file(GLOB_RECURSE sources ${PROJECT_SOURCE_DIR} "src/*.cpp" "src/*.mm")

add_executable(swindow ${sources} ${objc_sources})

target_include_directories(swindow PRIVATE include)

target_link_libraries(swindow PRIVATE
    "-framework Cocoa"
)

# 'Cocoa', 'IOKit', 'CoreFoundation', 'CoreVideo'
