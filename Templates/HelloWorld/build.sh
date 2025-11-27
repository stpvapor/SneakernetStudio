#!/usr/bin/env bash

REPO_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"

if [[ "$1" == "clean=yes" ]]; then
    rm -rf build .zig-cache
fi

mkdir -p build/lin

cmake -S . -B build/lin -DCMAKE_TOOLCHAIN_FILE="$REPO_ROOT/tools/Toolchain_Zig.cmake" -DCMAKE_BUILD_TYPE=Debug

cmake --build build/lin -j$(nproc)

echo "Build complete! Run with: ./build/lin/HelloWorld"
