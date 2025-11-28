cmake_minimum_required(VERSION 3.10)
project(HelloWorld C)

set(CMAKE_TOOLCHAIN_FILE "${CMAKE_SOURCE_DIR}/../../tools/Toolchain_Zig.cmake")
set(CMAKE_LINK_DEPENDS_NO_SHARED ON)

# GLOB all src/*.c except utils.c (to break circularity)
file(GLOB SOURCES "src/*.c")
list(FILTER SOURCES EXCLUDE REGEX "utils.c")

# Explicitly add utils.c after main.c
add_executable(${PROJECT_NAME} main.c src/utils.c ${SOURCES})

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
