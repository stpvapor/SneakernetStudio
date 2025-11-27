cmake_minimum_required(VERSION 3.20)

# Load toolchain FIRST — this sets up the compiler before project() probes it
include(../../tools/Toolchain_Zig.cmake)

# Project name is just the current folder name — works in Projects/MyGame too
get_filename_component(PROJECT_NAME ${CMAKE_CURRENT_SOURCE_DIR} NAME)
project(${PROJECT_NAME} C)

# raylib is always at ../../tools/raylib relative to any project
find_library(RAYLIB_LIB
    NAMES raylib libraylib.a
    PATHS ../../tools/raylib
    NO_DEFAULT_PATH
    REQUIRED
)

# Auto-glob all source files
file(GLOB_RECURSE SOURCES "src/*.c")

# Copy assets folder next to the binary
file(GLOB_RECURSE ASSETS "assets/*")
foreach(ASSET ${ASSETS})
    file(RELATIVE_PATH REL_PATH "${CMAKE_CURRENT_SOURCE_DIR}" "${ASSET}")
    configure_file("${ASSET}" "lin/${REL_PATH}" COPYONLY)
endforeach()

add_executable(${PROJECT_NAME} ${SOURCES})
target_include_directories(${PROJECT_NAME} PRIVATE include ../../tools/raylib/src)
target_link_libraries(${PROJECT_NAME} PRIVATE ${RAYLIB_LIB} m)

set_target_properties(${PROJECT_NAME} PROPERTIES
    RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/lin"
)

if(CMAKE_BUILD_TYPE STREQUAL "Release")
    add_custom_command(TARGET ${PROJECT_NAME} POST_BUILD
        COMMAND ${CMAKE_STRIP} $<TARGET_FILE:${PROJECT_NAME}>
    )
endif()