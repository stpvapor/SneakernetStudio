cmake_minimum_required(VERSION 3.20)

set(ZIG_ROOT "${CMAKE_CURRENT_SOURCE_DIR}/../../tools/zig")
set(CMAKE_C_COMPILER "${ZIG_ROOT}/zig" cc)
set(CMAKE_CXX_COMPILER "${ZIG_ROOT}/zig" c++)
# Skip CMake's compiler test — this is the only thing that works with Zig 0.14.0
set(CMAKE_C_COMPILER_FORCED TRUE)
set(CMAKE_CXX_COMPILER_FORCED TRUE)
set(CMAKE_TRY_COMPILE_TARGET_TYPE STATIC_LIBRARY)

# Skip compiler test — this is the only thing that works with Zig 0.14.0 + Make
set(CMAKE_C_COMPILER_WORKS 1)
set(CMAKE_CXX_COMPILER_WORKS 1)
