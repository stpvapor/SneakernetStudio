cmake_minimum_required(VERSION 3.10)
project(HelloWorld C)

set(CMAKE_TOOLCHAIN_FILE "${CMAKE_SOURCE_DIR}/../../tools/Toolchain_Zig.cmake")
set(CMAKE_LINK_DEPENDS_NO_SHARED ON)

# GLOB everything in src/ — user can drop any .c file
file(GLOB SOURCES "src/*.c")

# main.c is separate — never in GLOB
add_executable(${PROJECT_NAME} main.c ${SOURCES})

# raylib headers are in tools/raylib/src
set(RAYLIB_PATH "${CMAKE_SOURCE_DIR}/../../tools/raylib")
target_include_directories(${PROJECT_NAME} PRIVATE "${RAYLIB_PATH}/src" include)

# lib is in src/
target_link_libraries(${PROJECT_NAME} PRIVATE "${RAYLIB_PATH}/src/libraylib.a" m dl pthread X11)

# Copy assets
file(GLOB_RECURSE ASSETS "assets/*")
foreach(ASSET ${ASSETS})
    configure_file(${ASSET} ${ASSET} COPYONLY)
endforeach()

# Critical fix: force main.c to compile first so utils.h is seen before utils.c
set_source_files_properties(main.c PROPERTIES COMPILE_FLAGS "-include utils.h")
