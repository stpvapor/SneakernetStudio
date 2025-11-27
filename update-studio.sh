#!/usr/bin/env bash
# update-studio.sh – FINAL, 100% WORKING WITH ZIG 0.14.0 (2025-11-27)

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TOOLS_DIR="$REPO_ROOT/tools"
MANIFEST="$TOOLS_DIR/manifest.txt"
LOG_FILE="$TOOLS_DIR/update.log"
> "$LOG_FILE"

GREEN='\033[0;32m'; RED='\033[0;31m'; NC='\033[0m'
log() { echo -e "${GREEN}[$(date +%H:%M:%S)]${NC} $*" | tee -a "$LOG_FILE"; }

log "============================================================="
log "     SneakernetStudio Updater – FINAL"
log "============================================================="

ZIG_VERSION="0.14.0"
CMAKE_VERSION="4.2.0"
RAYLIB_VERSION="5.5"

mkdir -p "$TOOLS_DIR"

# Zig
if [[ ! -f "$TOOLS_DIR/zig/zig" ]]; then
    log "Downloading Zig $ZIG_VERSION..."
    curl -L# "https://ziglang.org/download/$ZIG_VERSION/zig-linux-x86_64-$ZIG_VERSION.tar.xz" | tar -xJ -C "$TOOLS_DIR"
    mv "$TOOLS_DIR/zig-linux-x86_64-$ZIG_VERSION" "$TOOLS_DIR/zig"
else
    log "Zig $ZIG_VERSION present"
fi

# CMake
if [[ ! -f "$TOOLS_DIR/cmake/bin/cmake" ]]; then
    log "Downloading CMake $CMAKE_VERSION..."
    curl -L# "https://github.com/Kitware/CMake/releases/download/v$CMAKE_VERSION/cmake-$CMAKE_VERSION-linux-x86_64.tar.gz" | tar -xz -C "$TOOLS_DIR"
    mv "$TOOLS_DIR/cmake-$CMAKE_VERSION-linux-x86_64" "$TOOLS_DIR/cmake"
else
    log "CMake $CMAKE_VERSION present"
fi

# raylib
if [[ ! -f "$TOOLS_DIR/raylib/src/libraylib.a" ]]; then
    log "Building raylib $RAYLIB_VERSION..."
    rm -rf "$TOOLS_DIR/raylib"
    git clone --depth 1 --branch "$RAYLIB_VERSION" https://github.com/raysan5/raylib.git "$TOOLS_DIR/raylib" >>"$LOG_FILE" 2>&1
    make -C "$TOOLS_DIR/raylib/src" -j$(nproc) PLATFORM=PLATFORM_DESKTOP SHARED=0 CLEAN=1 >>"$LOG_FILE" 2>&1
    log "raylib $RAYLIB_VERSION built"
else
    log "raylib $RAYLIB_VERSION built"
fi

# Toolchain – OVERRIDE LINK COMMAND (ONLY FIX THAT WORKS)
log "Installing Toolchain_Zig.cmake..."
cat > "$TOOLS_DIR/Toolchain_Zig.cmake" <<'EOF'
cmake_minimum_required(VERSION 3.20)

get_filename_component(REPO_ROOT "${CMAKE_CURRENT_LIST_DIR}/.." ABSOLUTE)
set(ZIG_ROOT "${REPO_ROOT}/tools/zig")
set(ZIG_EXE  "${ZIG_ROOT}/zig")

set(CMAKE_C_COMPILER   "${ZIG_EXE}" cc)
set(CMAKE_CXX_COMPILER "${ZIG_EXE}" c++)

# THIS OVERRIDES THE LINK COMMAND — NO --dependency-file EVER
set(CMAKE_C_LINK_EXECUTABLE "${ZIG_EXE} cc <FLAGS> <CMAKE_C_LINK_FLAGS> <LINK_FLAGS> <OBJECTS> -o <TARGET> <LINK_LIBRARIES>")

set(CMAKE_SYSTEM_NAME Linux)
set(CMAKE_SYSTEM_PROCESSOR x86_64)
set(CMAKE_C_COMPILER_TARGET x86_64-linux-gnu)
set(CMAKE_CXX_COMPILER_TARGET x86_64-linux-gnu)

set(CMAKE_C_FLAGS_RELEASE "-O3 -DNDEBUG")
set(CMAKE_CXX_FLAGS_RELEASE "-O3 -DNDEBUG")

if(NOT EXISTS "${ZIG_EXE}")
    message(FATAL_ERROR "Zig not found at ${ZIG_EXE}")
endif()

message(STATUS "Zig compiler → ${ZIG_EXE} cc")
EOF

# Original template CMakeLists.txt
log "Installing original CMakeLists.txt..."
for template in "$REPO_ROOT"/Templates/*; do
    if [[ -d "$template" ]]; then
        cat > "$template/CMakeLists.txt" <<'EOF'
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
EOF
    fi
done

# Manifest
cat > "$MANIFEST" <<EOF
# SneakernetStudio Tool Manifest
# Updated: $(date +"%Y-%m-%d %H:%M:%S")
Zig: $ZIG_VERSION
CMake: $CMAKE_VERSION
raylib: $RAYLIB_VERSION
EOF

clear
echo "============================================================="
echo "     SneakernetStudio is ready"
echo
echo "     Zig     : $ZIG_VERSION"
echo "     CMake   : $CMAKE_VERSION"
echo "     raylib  : $RAYLIB_VERSION"
echo
echo "     Tools updated or unchanged."
echo
echo "     Happy coding!"
echo "============================================================="
read -p "Press Enter to close..."