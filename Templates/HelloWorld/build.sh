#!/bin/bash
set -e

# Resolve project root from the script location — works from any folder
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TOOLS_DIR="$PROJECT_ROOT/../../tools"
BUILD_DIR="$PROJECT_ROOT/build"
TARGET="${1:-lin}"

# ALWAYS full clean — no stale CMake cache EVER
echo "=== FULL CLEAN (removing $BUILD_DIR/$TARGET) ==="
rm -rf "$BUILD_DIR/$TARGET"

# Create fresh build directory
TARGET_DIR="$BUILD_DIR/$TARGET"
mkdir -p "$TARGET_DIR"
cd "$TARGET_DIR"

# Zig cache lives inside this build folder
export ZIG_GLOBAL_CACHE_DIR="$PWD/.zig-cache"

# Toolchain is relative to project root
TOOLCHAIN="-DCMAKE_TOOLCHAIN_FILE=$TOOLS_DIR/Toolchain_Zig.cmake"

case "$TARGET" in
    lin) ZIG_TARGET="" ;;
    win) ZIG_TARGET="-DCMAKE_C_COMPILER=$TOOLS_DIR/zig/zig cc -target x86_64-windows-gnu -DCMAKE_CXX_COMPILER=$TOOLS_DIR/zig/zig c++ -target x86_64-windows-gnu" ;;
    arm) ZIG_TARGET="-DCMAKE_C_COMPILER=$TOOLS_DIR/zig/zig cc -target aarch64-linux-gnu -DCMAKE_CXX_COMPILER=$TOOLS_DIR/zig/zig c++ -target aarch64-linux-gnu" ;;
esac

cmake "$PROJECT_ROOT" $TOOLCHAIN $ZIG_TARGET
make -j$(nproc)

echo "Build complete: $TARGET_DIR/HelloWorld"
echo "Run with: ./$TARGET_DIR/HelloWorld"