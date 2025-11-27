# tools/Toolchain_Zig.cmake – FINAL VERSION (2025-11-27)
# 100% portable, no matter where you unzip or rename the folder
# Works even during CMake try-compile phases

cmake_minimum_required(VERSION 3.20)

# ───── Compute absolute repo root ONCE, safely, in the source tree ─────
# CMAKE_CURRENT_SOURCE_DIR is always the project dir (Templates/XXX or Projects/XXX)
get_filename_component(
    REPO_ROOT_ABS
    "${CMAKE_CURRENT_SOURCE_DIR}/../../"   # two levels up from any project
    ABSOLUTE
    BASE_DIR "${CMAKE_BINARY_DIR}"         # anchor to binary dir so it survives try-compile
)

# ───── Zig paths (now always correct) ─────
set(ZIG_ROOT "${REPO_ROOT_ABS}/tools/zig" CACHE PATH "Zig directory")
set(ZIG_EXE  "${ZIG_ROOT}/zig"           CACHE PATH "Zig executable")

# ───── Modern Zig 0.14.0+ invocation (this is REQUIRED) ─────
set(CMAKE_C_COMPILER   "${ZIG_EXE}" cc)
set(CMAKE_CXX_COMPILER "${ZIG_EXE}" c++)

# ───── Target & flags ─────
set(CMAKE_SYSTEM_NAME Linux)
set(CMAKE_SYSTEM_PROCESSOR x86_64)
set(CMAKE_C_COMPILER_TARGET   x86_64-linux-gnu)
set(CMAKE_CXX_COMPILER_TARGET x86_64-linux-gnu)

set(CMAKE_C_FLAGS_RELEASE   "-O3 -DNDEBUG")
set(CMAKE_CXX_FLAGS_RELEASE "-O3 -DNDEBUG -static-libstdc++")
set(CMAKE_EXE_LINKER_FLAGS  "-static -fuse-ld=lld")

# ───── Final sanity check (now runs with the correct absolute path) ─────
if(NOT EXISTS "${ZIG_EXE}")
    message(FATAL_ERROR
        "Zig executable not found at:\n  ${ZIG_EXE}\n"
        "Expected repo root: ${REPO_ROOT_ABS}\n"
        "Run ./update-studio.sh from the repository root first."
    )
endif()

message(STATUS "Zig compiler → ${ZIG_EXE} cc")
message(STATUS "Repo root    → ${REPO_ROOT_ABS}")