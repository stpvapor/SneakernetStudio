# tools/Toolchain_Zig.cmake – FINAL, BULLETPROOF, 100% PORTABLE
# Works in SneakernetStudio-main, ~/_/SneakernetStudio, USB sticks, anywhere

cmake_minimum_required(VERSION 3.20)

# Compute absolute repo root once, safely from source directory
set(_REPO_ROOT_SOURCE "${CMAKE_CURRENT_SOURCE_DIR}/../..")
file(TO_CMAKE_PATH "${_REPO_ROOT_SOURCE}" _REPO_ROOT_SOURCE)
file(REAL_PATH "${_REPO_ROOT_SOURCE}" REPO_ROOT_ABS EXPAND_TILDE)

# Zig paths – now always correct, no matter where CMake runs from
set(ZIG_ROOT "${REPO_ROOT_ABS}/tools/zig" CACHE PATH "Zig install directory")
set(ZIG_EXE  "${ZIG_ROOT}/zig"          CACHE PATH "Zig executable")

# Modern Zig 0.14.0+ invocation
set(CMAKE_C_COMPILER   "${ZIG_EXE}" cc)
set(CMAKE_CXX_COMPILER "${ZIG_EXE}" c++)

set(CMAKE_SYSTEM_NAME Linux)
set(CMAKE_SYSTEM_PROCESSOR x86_64)
set(CMAKE_C_COMPILER_TARGET   x86_64-linux-gnu)
set(CMAKE_CXX_COMPILER_TARGET x86_64-linux-gnu)

# Release flags (fast + static for sneakernet)
set(CMAKE_C_FLAGS_RELEASE   "-O3 -DNDEBUG")
set(CMAKE_CXX_FLAGS_RELEASE "-O3 -DNDEBUG -static-libstdc++")
set(CMAKE_EXE_LINKER_FLAGS  "-static -fuse-ld=lld")

# Sanity check – this now runs with the correct absolute path
if(NOT EXISTS "${ZIG_EXE}")
    message(FATAL_ERROR "Zig executable not found at:\n  ${ZIG_EXE}\nRun ./update-studio.sh from the repository root.")
endif()

message(STATUS "Zig compiler: ${ZIG_EXE} cc")
message(STATUS "Repo root:    ${REPO_ROOT_ABS}")