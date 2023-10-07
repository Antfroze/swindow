cmake_minimum_required(VERSION 3.15)

project(swindow)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_EXPORT_COMPILE_COMMANDS YES)
enable_language(OBJCXX)

file(GLOB_RECURSE sources ${PROJECT_SOURCE_DIR} "src/*.cpp" "src/*.mm")

add_executable(swindow_app ${sources})
add_library(swindow STATIC ${sources})
set_target_properties(swindow_app PROPERTIES
  MACOSX_BUNDLE_INFO_PLIST ${CMAKE_CURRENT_SOURCE_DIR}/Info.plist
)
target_include_directories(swindow PRIVATE include)
target_include_directories(swindow_app PRIVATE include)

target_link_libraries(swindow PRIVATE
    "-framework Cocoa"
)
target_link_libraries(swindow_app PRIVATE
    "-framework Cocoa"
)