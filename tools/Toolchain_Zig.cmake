# tools/Toolchain_Zig.cmake – FINAL, REALLY WORKS (2025-11-27)
# Uses only CMAKE_CURRENT_LIST_DIR → survives try-compile 100%

cmake_minimum_required(VERSION 3.20)

# CMAKE_CURRENT_LIST_DIR is the directory containing THIS file → always tools/
# One level up = real repo root, no matter where CMake runs from
get_filename_component(REPO_ROOT "${CMAKE_CURRENT_LIST_DIR}/.." ABSOLUTE)

# Zig paths – now mathematically impossible to get wrong
set(ZIG_ROOT "${REPO_ROOT}/tools/zig")
set(ZIG_EXE  "${ZIG_ROOT}/zig")

# This is the ONLY correct way to invoke Zig as a C compiler in 0.14.0+
set(CMAKE_C_COMPILER   "${ZIG_EXE}" cc)
set(CMAKE_CXX_COMPILER "${ZIG_EXE}" c++)

# Target triple and flags
set(CMAKE_SYSTEM_NAME Linux)
set(CMAKE_SYSTEM_PROCESSOR x86_64)
set(CMAKE_C_COMPILER_TARGET   x86_64-linux-gnu)
set(CMAKE_CXX_COMPILER_TARGET x86_64-linux-gnu)

set(CMAKE_C_FLAGS_RELEASE   "-O3 -DNDEBUG")
set(CMAKE_CXX_FLAGS_RELEASE "-O3 -DNDEBUG -static-libstdc++")
set(CMAKE_EXE_LINKER_FLAGS  "-static -fuse-ld=lld")

# Sanity check – this now always sees the real path
if(NOT EXISTS "${ZIG_EXE}")
    message(FATAL_ERROR
        "Zig executable not found at:\n  ${ZIG_EXE}\n"
        "Repo root resolved to: ${REPO_ROOT}\n"
        "Run ./update-studio.sh from the repo root first."
    )
endif()

message(STATUS "Zig compiler → ${ZIG_EXE} cc")
message(STATUS "Repo root    → ${REPO_ROOT}")