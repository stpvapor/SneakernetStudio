# Toolchain_Zig.cmake – completely folder-name agnostic
# Works from any depth, any location, any name

# Dynamically compute the absolute path to the repo root using PWD at configure time
execute_process(
    COMMAND bash -c "cd \"${CMAKE_CURRENT_SOURCE_DIR}/../..\" && pwd"
    OUTPUT_VARIABLE REPO_ROOT_ABS
    OUTPUT_STRIP_TRAILING_WHITESPACE
)

set(ZIG_ROOT "${REPO_ROOT_ABS}/tools/zig" CACHE PATH "Path to zig")
set(ZIG_EXE  "${ZIG_ROOT}/zig" CACHE PATH "Zig executable")

# Correct modern Zig 0.14.0+ invocation
set(CMAKE_C_COMPILER   "${ZIG_EXE}" cc)
set(CMAKE_CXX_COMPILER "${ZIG_EXE}" c++)

set(CMAKE_SYSTEM_NAME Linux)
set(CMAKE_SYSTEM_PROCESSOR x86_64)
set(CMAKE_C_COMPILER_TARGET   x86_64-linux-gnu)
set(CMAKE_CXX_COMPILER_TARGET x86_64-linux-gnu)

# Release flags (static, fast, portable)
set(CMAKE_C_FLAGS_RELEASE "-O3 -DNDEBUG")
set(CMAKE_CXX_FLAGS_RELEASE "-O3 -DNDEBUG -static-libstdc++")
set(CMAKE_EXE_LINKER_FLAGS "-static -fuse-ld=lld")

if(NOT EXISTS "${ZIG_EXE}")
    message(FATAL_ERROR "Zig not found at ${ZIG_EXE}. Run ../update-studio.sh from repo root.")
endif()

message(STATUS "Using Zig from: ${ZIG_EXE} cc")
message(STATUS "Repo root resolved to: ${REPO_ROOT_ABS}")