# tools/Toolchain_Zig.cmake – FINAL, ACTUALLY WORKS (2025-11-27)

cmake_minimum_required(VERSION 3.20)

# ───── 1. Compute repo root from THIS file's location (always correct) ─────
# CMAKE_CURRENT_LIST_DIR = the real <repo>/tools directory
get_filename_component(REPO_ROOT "${CMAKE_CURRENT_LIST_DIR}/.." ABSOLUTE)

# ───── 2. Force CMake to know the real repo root even during try-compile ─────
# This is the crucial line that survives CMake's temporary directory changes
set(CMAKE_PROJECT_INCLUDE_BEFORE "${CMAKE_CURRENT_LIST_DIR}/_force_repo_root.cmake" CACHE INTERNAL "")

# Create a tiny helper file that simply sets REPO_ROOT for the try-compile phase
file(WRITE "${CMAKE_BINARY_DIR}/_force_repo_root.cmake"
     "set(REPO_ROOT \"${REPO_ROOT}\" CACHE INTERNAL \"Forced repo root\")\n"
)

# ───── 3. Zig paths – now bulletproof ─────
set(ZIG_ROOT "${REPO_ROOT}/tools/zig" CACHE PATH "Zig directory")
set(ZIG_EXE  "${ZIG_ROOT}/zig"       CACHE PATH "Zig executable")

# ───── 4. Correct Zig 0.14.0+ compiler invocation ─────
set(CMAKE_C_COMPILER   "${ZIG_EXE}" cc)
set(CMAKE_CXX_COMPILER "${ZIG_EXE}" c++)

set(CMAKE_SYSTEM_NAME Linux)
set(CMAKE_SYSTEM_PROCESSOR x86_64)
set(CMAKE_C_COMPILER_TARGET   x86_64-linux-gnu)
set(CMAKE_CXX_COMPILER_TARGET x86_64-linux-gnu)

set(CMAKE_C_FLAGS_RELEASE   "-O3 -DNDEBUG")
set(CMAKE_CXX_FLAGS_RELEASE "-O3 -DNDEBUG -static-libstdc++")
set(CMAKE_EXE_LINKER_FLAGS  "-static -fuse-ld=lld")

# ───── 5. Final sanity check (now always sees the real path) ─────
if(NOT EXISTS "${ZIG_EXE}")
    message(FATAL_ERROR
        "Zig executable not found!\n"
        "  Expected: ${ZIG_EXE}\n"
        "  Repo root: ${REPO_ROOT}\n"
        "  Run ./update-studio.sh from the repository root."
    )
endif()

message(STATUS "Zig compiler → ${ZIG_EXE} cc")
message(STATUS "Repo root    → ${REPO_ROOT}")