cmake_minimum_required(VERSION 3.20)

set(ZIG_ROOT "${CMAKE_CURRENT_SOURCE_DIR}/../../tools/zig")
set(CMAKE_C_COMPILER "${ZIG_ROOT}/zig" cc")
set(CMAKE_CXX_COMPILER "${ZIG_ROOT}/zig c++")
