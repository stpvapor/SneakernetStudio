# Toolchain_Zig.cmake — works with Zig 0.14.0+ (binary is just "zig")
set(CMAKE_SYSTEM_NAME Generic)
set(CMAKE_SYSTEM_PROCESSOR x86_64)

# Relative path — always correct no matter where you unzip
set(ZIG_ROOT "${CMAKE_SOURCE_DIR}/../../tools/zig")
set(CMAKE_C_COMPILER "${ZIG_ROOT}/zig" cc)
set(CMAKE_CXX_COMPILER "${ZIG_ROOT}/zig" c++)

set(CMAKE_C_FLAGS_INIT "-std=c99 -Wall -Wextra")
set(CMAKE_CXX_FLAGS_INIT "-std=c++11 -Wall -Wextra")

set(CMAKE_EXE_LINKER_FLAGS_INIT "-lm -ldl -lpthread -lX11")

# Disable Zig/CMake depfile conflict
set(CMAKE_LINK_DEPENDS_NO_SHARED ON)

set(CMAKE_FIND_LIBRARY_PREFIXES "")
set(CMAKE_FIND_LIBRARY_SUFFIXES ".a")

set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY)
