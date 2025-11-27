# Toolchain_Zig.cmake
# CMake toolchain file for Zig as C/C++ compiler
# Usage: cmake -DCMAKE_TOOLCHAIN_FILE=tools/Toolchain_Zig.cmake ..

set(CMAKE_SYSTEM_NAME Generic)
set(CMAKE_SYSTEM_PROCESSOR x86_64)  # Adjust for target (e.g., i686 for 32-bit)

# Zig as compiler (wrapper path)
set(ZIG_ROOT "$ENV{HOME}/_/SneakernetStudio/tools/zig")
set(CMAKE_C_COMPILER "${ZIG_ROOT}/zig cc")
set(CMAKE_CXX_COMPILER "${ZIG_ROOT}/zig c++")

# Flags
set(CMAKE_C_FLAGS_INIT "-std=c99 -Wall -Wextra")
set(CMAKE_CXX_FLAGS_INIT "-std=c++11 -Wall -Wextra")

# Linker flags for Linux
set(CMAKE_EXE_LINKER_FLAGS_INIT "-static-libgcc -static-libstdc++ -lm -ldl -lpthread -lX11")

# Hide library paths (portable)
set(CMAKE_FIND_LIBRARY_PREFIXES "")
set(CMAKE_FIND_LIBRARY_SUFFIXES ".a")

# Enable Zig's libc for portability
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY)
