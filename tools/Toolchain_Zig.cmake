cmake_minimum_required(VERSION 3.20)

set(ZIG_ROOT "${CMAKE_CURRENT_SOURCE_DIR}/../../tools/zig")
set(CMAKE_C_COMPILER "${ZIG_ROOT}/zig" cc)
set(CMAKE_CXX_COMPILER "${ZIG_ROOT}/zig" c++)

# Disable depfile (fixes --dependency-file linker error)
set(CMAKE_C_LINKER_DEPFILE_SUPPORTED FALSE)
set(CMAKE_CXX_LINKER_DEPFILE_SUPPORTED FALSE)

# Force C99 symbols for __isoc23_* (fixes undefined symbols)
add_compile_definitions(_GNU_SOURCE)

# Skip compiler test (fixes duplicate main)
set(CMAKE_C_COMPILER_FORCED TRUE)
set(CMAKE_CXX_COMPILER_FORCED TRUE)
