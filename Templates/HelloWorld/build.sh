#!/bin/bash
set -e

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TOOLS_DIR="$PROJECT_ROOT/../../tools"
BUILD_ROOT="$PROJECT_ROOT/build"

TARGET="lin"
CLEAN="no"

# Parse arguments properly
for arg in "$@"; do
    case "$arg" in
        lin|win|arm)
            TARGET="$arg"
            ;;
        clean=yes)
            CLEAN="yes"
            ;;
    esac
done

# FULL CLEAN — wipes everything
if [ "$CLEAN" = "yes" ]; then
    echo "Cleaning build tree and Zig cache..."
    rm -rf "$BUILD_ROOT" "$PROJECT_ROOT/.zig-cache" "$PROJECT_ROOT/zig-out"
fi

TARGET_DIR="$BUILD_ROOT/$TARGET"
mkdir -p "$TARGET_DIR"
cd "$TARGET_DIR"

export ZIG_GLOBAL_CACHE_DIR="$PWD/.zig-cache"

case "$TARGET" in
    lin) ZIG_TARGET="" ;;
    win) ZIG_TARGET="-DCMAKE_C_COMPILER=$TOOLS_DIR/zig/zig cc -target x86_64-windows-gnu -DCMAKE_CXX_COMPILER=$TOOLS_DIR/zig/zig c++ -target x86_64-windows-gnu" ;;
    arm) ZIG_TARGET="-DCMAKE_C_COMPILER=$TOOLS_DIR/zig/zig cc -target aarch64-linux-gnu -DCMAKE_CXX_COMPILER=$TOOLS_DIR/zig/zig c++ -target aarch64-linux-gnu" ;;
esac

cmake "$PROJECT_ROOT" -DCMAKE_TOOLCHAIN_FILE="$TOOLS_DIR/Toolchain_Zig.cmake" $ZIG_TARGET
make -j$(nproc)

echo "Build complete: $TARGET_DIR/HelloWorld (target: $TARGET)"
echo "Run with: cd \"$TARGET_DIR\" && ./HelloWorld"