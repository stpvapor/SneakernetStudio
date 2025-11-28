#!/bin/bash
# SneakernetStudio Updater - Linux
# Installs/updates Zig, CMake, raylib for game jamming.
STUDIO_ROOT="$(dirname "$(realpath "$0")")"
TOOLS_DIR="$STUDIO_ROOT/tools"
MANIFEST="$TOOLS_DIR/manifest.txt"
LOG_FILE="$STUDIO_ROOT/install.log"
TEMP_FILES=()

# Cleanup function
cleanup() {
    for file in "${TEMP_FILES[@]}"; do
        [ -f "$file" ] && rm -f "$file" >>"$LOG_FILE" 2>&1
    done
}

# Check utilities
check_utility() {
    local util="$1"
    local suggestion="$2"
    if ! command -v "$util" >/dev/null 2>&1; then
        echo "[ERROR] Required utility '$util' is missing." | tee -a "$LOG_FILE"
        echo "Install it using your package manager, e.g., '$suggestion'" | tee -a "$LOG_FILE"
        cleanup
        read -p "Press Enter to exit..."
        exit 1
    fi
}

check_utility "bash" "sudo pacman -S bash"
check_utility "wget" "sudo pacman -S wget"
check_utility "tar" "sudo pacman -S tar"
check_utility "git" "sudo pacman -S git"
check_utility "make" "sudo pacman -S make"
check_utility "gcc" "sudo pacman -S gcc"

# Log
echo "================================================================" > "$LOG_FILE"
echo "SneakernetStudio Updater" >> "$LOG_FILE"
echo "================================================================" >> "$LOG_FILE"
echo "Starting in $STUDIO_ROOT..." | tee -a "$LOG_FILE"

# Check internet
ping -c1 google.com >/dev/null 2>&1 && ONLINE=1 || ONLINE=0
if [ $ONLINE -eq 0 ]; then
    echo "[WARNING] No internet — using existing tools." | tee -a "$LOG_FILE"
fi

# Version checks
FINAL_ZIG="not installed"
if [ -x "$TOOLS_DIR/zig/zig" ]; then
    FINAL_ZIG=$("$TOOLS_DIR/zig/zig" version 2>>"$LOG_FILE" || echo "not installed")
fi

FINAL_CMAKE="not installed"
if [ -x "$TOOLS_DIR/cmake/bin/cmake" ]; then
    "$TOOLS_DIR/cmake/bin/cmake" --version > cmake_version.txt 2>>"$LOG_FILE"
    TEMP_FILES+=("cmake_version.txt")
    FINAL_CMAKE=$(grep -oP 'cmake version \K[\d.]+' cmake_version.txt 2>>"$LOG_FILE" || echo "not installed")
    rm -f cmake_version.txt
    TEMP_FILES=("${TEMP_FILES[@]/cmake_version.txt}")
fi

FINAL_RAYLIB="not installed"
if [ -f "$TOOLS_DIR/raylib/src/libraylib.a" ]; then
    FINAL_RAYLIB="5.5"  # Hard-coded for now
fi

echo "[Debug] Versions: Zig=$FINAL_ZIG, CMake=$FINAL_CMAKE, Raylib=$FINAL_RAYLIB" | tee -a "$LOG_FILE"
read -p "Press Enter to continue..."

# Install mode
if [ ! -d "$TOOLS_DIR" ] || [ ! -f "$MANIFEST" ]; then
    INSTALL_MODE=1
else
    INSTALL_MODE=0
fi

# Install functions
install_zig() {
    local force="$1"
    local zig_ver="$FINAL_ZIG"
    [ "$zig_ver" = "not installed" ] && zig_ver="0.14.0"

    if [ $ONLINE -eq 1 ]; then
        wget -q -O zig.tar.xz "https://ziglang.org/download/$zig_ver/zig-linux-x86_64-$zig_ver.tar.xz" >>"$LOG_FILE" 2>&1
        TEMP_FILES+=("zig.tar.xz")
        if [ -f zig.tar.xz ]; then
            rm -rf "$TOOLS_DIR/zig"
            mkdir -p "$TOOLS_DIR/zig"
            tar -xJf zig.tar.xz -C "$TOOLS_DIR/zig" --strip-components=1 >>"$LOG_FILE" 2>&1
            if [ -x "$TOOLS_DIR/zig/zig" ]; then
                FINAL_ZIG="$zig_ver"
                echo "[Zig] Installed $FINAL_ZIG" | tee -a "$LOG_FILE"
            else
                FINAL_ZIG="failed"
                echo "[Zig] Install failed" | tee -a "$LOG_FILE"
            fi
            rm -f zig.tar.xz
            TEMP_FILES=("${TEMP_FILES[@]/zig.tar.xz}")
        fi
    fi
}

install_cmake() {
    local force="$1"
    local cmake_ver="$FINAL_CMAKE"
    [ "$cmake_ver" = "not installed" ] && cmake_ver="4.2.0"

    if [ $ONLINE -eq 1 ]; then
        wget -q -O cmake.tar.gz "https://github.com/Kitware/CMake/releases/download/v$cmake_ver/cmake-$cmake_ver-linux-x86_64.tar.gz" >>"$LOG_FILE" 2>&1
        TEMP_FILES+=("cmake.tar.gz")
        if [ -f cmake.tar.gz ]; then
            rm -rf "$TOOLS_DIR/cmake"
            mkdir -p "$TOOLS_DIR"
            tar -xzf cmake.tar.gz -C "$TOOLS_DIR" >>"$LOG_FILE" 2>&1
            if [ -d "$TOOLS_DIR/cmake-"* ]; then
                mv "$TOOLS_DIR/cmake-"* "$TOOLS_DIR/cmake"
                if [ -x "$TOOLS_DIR/cmake/bin/cmake" ]; then
                    FINAL_CMAKE="$cmake_ver"
                    echo "[CMake] Installed $FINAL_CMAKE" | tee -a "$LOG_FILE"
                else
                    FINAL_CMAKE="failed"
                    echo "[CMake] Install failed" | tee -a "$LOG_FILE"
                fi
            fi
            rm -f cmake.tar.gz
            TEMP_FILES=("${TEMP_FILES[@]/cmake.tar.gz}")
        fi
    fi
}

install_raylib() {
    local force="$1"
    local raylib_ver="$FINAL_RAYLIB"
    [ "$raylib_ver" = "not installed" ] && raylib_ver="5.5"

    if [ $ONLINE -eq 1 ]; then
        rm -rf "$TOOLS_DIR/raylib"
        git clone --depth 1 --branch $raylib_ver https://github.com/raysan5/raylib.git "$TOOLS_DIR/raylib" >>"$LOG_FILE" 2>&1

        cd "$TOOLS_DIR/raylib/src"
        make PLATFORM=PLATFORM_DESKTOP RAYLIB_LIBTYPE=STATIC -j$(nproc) >>"$LOG_FILE" 2>&1

        if [ -f libraylib.a ]; then
            FINAL_RAYLIB="$raylib_ver"
            echo "[raylib] Installed $FINAL_RAYLIB" | tee -a "$LOG_FILE"
        else
            FINAL_RAYLIB="failed"
            echo "[raylib] Build failed" | tee -a "$LOG_FILE"
        fi
    fi
}

# Main
mkdir -p "$TOOLS_DIR"
if [ $INSTALL_MODE -eq 1 ]; then
    install_zig
    install_cmake
    install_raylib
else
    update_menu
fi

# Update manifest
{
    echo "# SneakernetStudio Tool Manifest"
    echo "# Updated: $(date '+%Y-%m-%d %H:%M:%S')"
    echo "Zig: $FINAL_ZIG"
    echo "CMake: $FINAL_CMAKE"
    echo "raylib: $FINAL_RAYLIB"
} > "$MANIFEST"

echo "============================================================"
echo "     SneakernetStudio is ready"
echo "     Zig : $FINAL_ZIG"
echo "     CMake : $FINAL_CMAKE"
echo "     raylib : $FINAL_RAYLIB"
echo "============================================================"
echo "Press Enter to close..."
read -p ""
