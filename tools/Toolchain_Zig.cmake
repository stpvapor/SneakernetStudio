# Toolchain_Zig.cmake
# CMake toolchain file for Zig-based C/C++ builds
# Self-contained, relative paths – works anywhere

# Compute ZIG_ROOT relative to the repo root (from project dir)
set(ZIG_ROOT "${CMAKE_CURRENT_SOURCE_DIR}/../../tools/zig" CACHE PATH "Path to zig installation")

# Zig executable path
set(ZIG_EXE "${ZIG_ROOT}/zig")

# This is the correct invocation for Zig 0.14.0+ (no deprecated wrappers)
set(CMAKE_C_COMPILER "${ZIG_EXE} cc")
set(CMAKE_CXX_COMPILER "${ZIG_EXE} c++")

# Target triple for x86_64 Linux (optimizes for your Threadripper + 4090)
set(CMAKE_SYSTEM_NAME Linux)
set(CMAKE_SYSTEM_PROCESSOR x86_64)
set(CMAKE_C_COMPILER_TARGET x86_64-linux-gnu)
set(CMAKE_CXX_COMPILER_TARGET x86_64-linux-gnu)

# Flags for release builds (static, optimized – leverages your 16-core beast)
set(CMAKE_C_FLAGS_RELEASE "-O3 -DNDEBUG -static-libgcc")
set(CMAKE_CXX_FLAGS_RELEASE "-O3 -DNDEBUG -static-libgcc -static-libstdc++")

# Linker flags (static linking for portability, no system libs needed)
set(CMAKE_EXE_LINKER_FLAGS "-static -fuse-ld=lld")

# Ensure Zig is found and valid
if(NOT EXISTS "${ZIG_EXE}")
    message(FATAL_ERROR "Zig not found at ${ZIG_EXE}. Run ./update-studio.sh first.")
endif()

message(STATUS "Zig toolchain loaded: ${ZIG_EXE} cc (target: x86_64-linux-gnu)")
message(STATUS "Repo root assumed at: ${CMAKE_CURRENT_SOURCE_DIR}/../..")