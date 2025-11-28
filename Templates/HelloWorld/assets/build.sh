#!/usr/bin/env bash

REPO_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"

if [[ "$1" == "clean=yes" ]]; then
    rm -rf build .zig-cache
fi

mkdir -p build/lin

"$REPO_ROOT/tools/cmake/bin/cmake" \
    -S . \
    -B build/lin \
    -DCMAKE_TOOLCHAIN_FILE=../../tools/Toolchain_Zig.cmake -DCMAKE_C_COMPILER_FORCED=1 -DCMAKE_CXX_COMPILER_FORCED=1 -DCMAKE_TOOLCHAIN_FILE="$REPO_ROOT/tools/Toolchain_Zig.cmake" \
    -DCMAKE_C_COMPILER_FORCED=1 
    -DCMAKE_CXX_COMPILER_FORCED=1 

    -DCMAKE_C_COMPILER_FORCED=1 \
    -DCMAKE_CXX_COMPILER_FORCED=1 \
    -DCMAKE_BUILD_TYPE=Debug

"$REPO_ROOT/tools/cmake/bin/cmake" --build build/lin -j$(nproc)

echo "Build complete! Run with: ./build/lin/$(basename "$(pwd)")"
