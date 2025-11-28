#!/bin/bash
set -e

PROJECT_ROOT="$(pwd)"
TOOLS_DIR="../../tools"
BUILD_DIR="build"
TARGET="${1:-lin}"
CLEAN="${2:-no}"

# Clean if requested
if [ "$CLEAN" = "yes" ]; then
    echo "Cleaning build directory and Zig cache..."
    rm -rf "$BUILD_DIR" .zig-cache zig-out
fi

TARGET_DIR="$BUILD_DIR/$TARGET"
mkdir -p "$TARGET_DIR"
cd "$TARGET_DIR"

# Force Zig cache inside this build folder
export ZIG_GLOBAL_CACHE_DIR="$PWD/.zig-cache"

TOOLCHAIN="-DCMAKE_TOOLCHAIN_FILE=$TOOLS_DIR/Toolchain_Zig.cmake"

case "$TARGET" in
    lin) ZIG_TARGET="" ;;
    win) ZIG_TARGET="-DCMAKE_C_COMPILER=$TOOLS_DIR/zig/zig cc -target x86_64-windows-gnu -DCMAKE_CXX_COMPILER=$TOOLS_DIR/zig/zig c++ -target x86_64-windows-gnu" ;;
    arm) ZIG_TARGET="-DCMAKE_C_COMPILER=$TOOLS_DIR/zig/zig cc -target aarch64-linux-gnu -DCMAKE_CXX_COMPILER=$TOOLS_DIR/zig/zig c++ -target aarch64-linux-gnu" ;;
esac

cmake "$PROJECT_ROOT" $TOOLCHAIN $ZIG_TARGET
make -j$(nproc)

echo "Build complete: $TARGET_DIR/HelloWorld (target: $TARGET)"
