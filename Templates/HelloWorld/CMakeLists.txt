cmake_minimum_required(VERSION 3.10)
project(HelloWorld C)

set(CMAKE_TOOLCHAIN_FILE "${CMAKE_SOURCE_DIR}/../../tools/Toolchain_Zig.cmake")
set(CMAKE_LINK_DEPENDS_NO_SHARED ON)

# Crawl src for all .c
file(GLOB SOURCES "src/*.c")

# Add executable (main.c + SOURCES, no duplicates)
add_executable(${PROJECT_NAME} main.c ${SOURCES})

# Local raylib and project include
set(RAYLIB_PATH "${CMAKE_SOURCE_DIR}/../../tools/raylib")
target_include_directories(${PROJECT_NAME} PRIVATE "${RAYLIB_PATH}/include" include)

# Link raylib
target_link_libraries(${PROJECT_NAME} PRIVATE "${RAYLIB_PATH}/lib/libraylib.a" m dl pthread X11)

# Auto-copy assets to build (portable bundle)
file(GLOB_RECURSE ASSETS "assets/*")
foreach(ASSET ${ASSETS})
    configure_file(${ASSET} ${ASSET} COPYONLY)
endforeach()
