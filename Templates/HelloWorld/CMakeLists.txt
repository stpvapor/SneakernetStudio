cmake_minimum_required(VERSION 3.20)
include(../../tools/Toolchain_Zig.cmake)

project(HelloWorld C)

find_library(RAYLIB_LIB
    NAMES raylib libraylib.a
    PATHS ../../tools/raylib/src
    NO_DEFAULT_PATH
    REQUIRED
)

file(GLOB_RECURSE SOURCES "*.c" "src/*.c")

add_executable(HelloWorld ${SOURCES})

target_include_directories(HelloWorld PRIVATE include ../../tools/raylib/src)
target_link_libraries(HelloWorld PRIVATE ${RAYLIB_LIB} m)

set_target_properties(HelloWorld PROPERTIES RUNTIME_OUTPUT_DIRECTORY lin)
