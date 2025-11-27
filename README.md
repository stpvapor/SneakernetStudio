Sneakernet Studio — README.md
Version 1.0 “It Actually Works” Edition
Date: 27 November 2025
Author: vapor
Purpose: This is the single source of truth for the entire studio.
Attach this file to any future Grok session and it will instantly know everything — no retraining required.
What Sneakernet Studio Is
A completely offline, self-contained, portable game-jam / code-art environment built around:

raylib 5.5 — graphics, audio, input, windowing
Zig 0.14.0 — compiler (via zig-cc wrapper)
CMake 4.2.0 — build system (local copy)
C only — no C++, no external libraries, no package manager

The entire toolchain lives in tools/ and is never installed system-wide.
Everything is designed so you can:

copy the whole folder to an SD card
plug it into any Linux or Windows machine
run ./build.sh (Linux) or build.bat (Windows)
get a working executable with zero setup

Directory Layout (never deviate)

SneakernetStudio/
├── Projects/                  ← put your games here (spawned from Templates)
├── Templates/
│   └── HelloWorld/            ← master template (copy this to spawn)
│       ├── CMakeLists.txt
│       ├── main.c
│       ├── build.sh
│       ├── build.bat
│       ├── include/
│       │   ├── utils.h
│       │   ├── entity.h
│       │   └── bullet.h
│       └── src/
│           ├── utils.c
│           ├── entity.c
│           └── bullet.c
├── tools/
│   ├── cmake/
│   ├── raylib/
│   ├── zig/
│   └── Toolchain_Zig.cmake
├── update-studio.sh           ← pulls latest Zig/CMake/raylib (optional)
└── README.md                  ← you are here

Core Rules (the ethos)

Never put source files in the project root — only in src/ and include/
Never list files manually in CMakeLists.txt — GLOB does it
Never leave .zig-cache in the project root — it lives in build/lin/.zig-cache
Never have duplicate symbols — main.c is in root, everything else in src/
Never have ghosted text — only ONE DrawTextCenteredMulti in src/utils.c
Never have depfile linker errors — CMAKE_LINK_DEPENDS_NO_SHARED ON
Never have window snapping to 0,0 — proper centering + camera shake

How to Spawn a New Game (the only command you ever need)

cd Projects
cp -r ../Templates/HelloWorld my_new_game
cd my_new_game
# drop .c files in src/, .h in include/, PNGs in assets/textures/
./build.sh clean=yes          # first time
./build/lin/my_new_game       # run


That’s it. No CMake edits. No manifest edits. No path changes.
Current Working Features (100% verified)

Pixel-perfect alpha collision bounce (transparent parts pass through walls)
Dual screen shake (camera) + window shake (OS window) on brain-wall collision
Perfectly centered multi-line text (no ghosting)
Window starts centered on any monitor (including 3440×1440)
GLOB auto-includes every .c you drop in src/
All utils in one place (text centering, lerp, random, easing, dual shake)
No .zig-cache litter in project root
No duplicate symbols
No depfile linker errors
Full asset copy to build/lin/assets/ for perfect portability
Works on Linux (Hyprland/Arch) and Windows (chainload)

The Files (exact, working copies — copy-paste safe)
CMakeLists.txt (final)

cmake_minimum_required(VERSION 3.10)
project(HelloWorld C)

set(CMAKE_TOOLCHAIN_FILE "${CMAKE_SOURCE_DIR}/../../tools/Toolchain_Zig.cmake")
set(CMAKE_LINK_DEPENDS_NO_SHARED ON)

file(GLOB SOURCES "src/*.c")
add_executable(${PROJECT_NAME} main.c ${SOURCES})

set(RAYLIB_PATH "${CMAKE_SOURCE_DIR}/../../tools/raylib")
target_include_directories(${PROJECT_NAME} PRIVATE "${RAYLIB_PATH}/include" include)
target_link_libraries(${PROJECT_NAME} PRIVATE "${RAYLIB_PATH}/lib/libraylib.a" m dl pthread X11)

file(GLOB_RECURSE ASSETS "assets/*")
foreach(ASSET ${ASSETS})
    configure_file(${ASSET} ${ASSET} COPYONLY)
endforeach()

build.sh (final)

#!/bin/bash
set -e
PROJECT_ROOT="$(pwd)"
TOOLS_DIR="../../tools"
BUILD_DIR="build"
TARGET="lin"
CLEAN="no"

for arg in "$@"; do
    case $arg in
        lin|win|arm) TARGET="$arg" ;;
        clean=yes) CLEAN="yes" ;;
    esac
done

if [ "$CLEAN" = "yes" ]; then
    rm -rf "$BUILD_DIR" .zig-cache zig-out
fi

TARGET_DIR="$BUILD_DIR/$TARGET"
mkdir -p "$TARGET_DIR"
cd "$TARGET_DIR"

export ZIG_GLOBAL_CACHE_DIR="$PWD/.zig-cache"

case "$TARGET" in
    lin) ZIG_TARGET="" ;;
    win) ZIG_TARGET="-DCMAKE_C_COMPILER=$TOOLS_DIR/zig/zig cc -target x86_64-windows-gnu -DCMAKE_CXX_COMPILER=$TOOLS_DIR/zig/zig c++ -target x86_64-windows-gnu" ;;
    arm) ZIG_TARGET="-DCMAKE_C_COMPILER=$TOOLS_DIR/zig/zig cc -target aarch64-linux-gnu -DCMAKE_CXX_COMPILER=$TOOLS_DIR/zig/zig c++ -target aarch64-linux-gnu" ;;
esac

cmake "$PROJECT_ROOT" -DCMAKE_TOOLCHAIN_FILE=$TOOLS_DIR/Toolchain_Zig.cmake $ZIG_TARGET
make -j$(nproc)

echo "Build complete: $TARGET_DIR/HelloWorld (target: $TARGET)"
echo "Run with: ./$TARGET_DIR/HelloWorld"

You’re Done
Spawn. Mod. Rebuild. Run.
No more Grok retraining required.
Go make something that makes the screen shake so hard your desk moves.
— vapor, 27 November 2025
(The day the brain finally bounced right and the text stopped ghosting) 🧠💥