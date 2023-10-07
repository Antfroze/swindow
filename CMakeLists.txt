cmake_minimum_required(VERSION 3.15)

project(swindow)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_EXPORT_COMPILE_COMMANDS YES)
enable_language(OBJCXX)

file(GLOB_RECURSE sources ${PROJECT_SOURCE_DIR} "src/*.cpp" "src/*.mm")

add_executable(swindow_app ${sources})
add_library(swindow STATIC ${sources})

target_include_directories(swindow PRIVATE include)
target_include_directories(swindow_app PRIVATE include)

target_link_libraries(swindow PRIVATE
    "-framework Cocoa"
)
target_link_libraries(swindow_app PRIVATE
    "-framework Cocoa"
)

set (CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fsanitize=address")