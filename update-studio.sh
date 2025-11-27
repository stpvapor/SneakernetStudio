#!/bin/bash
# SneakernetStudio Updater - Linux
# Installs/updates Zig, CMake, raylib for game jamming.
STUDIO_ROOT="$(dirname "$(realpath "$0")")"
TOOLS_DIR="$STUDIO_ROOT/tools"
MANIFEST="$TOOLS_DIR/manifest.txt"
LOG_FILE="$STUDIO_ROOT/install.log"
TEMP_FILES=()

# Function to clean up temporary files
cleanup() {
    for file in "${TEMP_FILES[@]}"; do
        [ -f "$file" ] && rm -f "$file" >>"$LOG_FILE" 2>&1
    done
}

# Function to check for required utilities
check_utility() {
    local util="$1"
    local suggestion="$2"
    if ! command -v "$util" >/dev/null 2>&1; then
        echo "[ERROR] Required utility '$util' is missing." | tee -a "$LOG_FILE"
        echo "Install it using your package manager, e.g., '$suggestion'" | tee -a "$LOG_FILE"
        echo "Press Enter to exit..." | tee -a "$LOG_FILE"
        cleanup
        read -p ""
        exit 1
    fi
}

# Check required utilities
check_utility "bash" "sudo apt install bash"
check_utility "wget" "sudo apt install wget"
check_utility "tar" "sudo apt install tar"
check_utility "ping" "sudo apt install iputils-ping"
check_utility "grep" "sudo apt install grep"
check_utility "awk" "sudo apt install gawk"
check_utility "sed" "sudo apt install sed"
check_utility "unzip" "sudo apt install unzip"

# Initialize log
echo "============================================================" > "$LOG_FILE"
echo "     SneakernetStudio Updater" >> "$LOG_FILE"
echo "============================================================" >> "$LOG_FILE"
echo "" >> "$LOG_FILE"
echo "Starting updater in $STUDIO_ROOT..." | tee -a "$LOG_FILE"

# Check internet
is_online() {
    ping -c1 -W2 google.com >/dev/null 2>>"$LOG_FILE"
    return $?
}
ONLINE=0
is_online && ONLINE=1
if [ $ONLINE -eq 0 ]; then
    echo "[WARNING] No internet connection detected. Will use existing tools if available." | tee -a "$LOG_FILE"
fi

# Initialize FINAL_* variables with existing versions
FINAL_ZIG="not installed"
if [ -x "$TOOLS_DIR/zig/zig" ]; then
    FINAL_ZIG=$("$TOOLS_DIR/zig/zig" version 2>>"$LOG_FILE" || echo "not installed")
    echo "[Zig] Found existing version: $FINAL_ZIG" | tee -a "$LOG_FILE"
else
    echo "[Zig] No zig binary found." | tee -a "$LOG_FILE"
fi

FINAL_CMAKE="not installed"
if [ -x "$TOOLS_DIR/cmake/bin/cmake" ]; then
    echo "[CMake] Checking cmake binary..." | tee -a "$LOG_FILE"
    "$TOOLS_DIR/cmake/bin/cmake" --version > cmake_version.txt 2>>"$LOG_FILE"
    TEMP_FILES+=("cmake_version.txt")
    if [ -f cmake_version.txt ]; then
        echo "[CMake] Raw cmake --version output:" >> "$LOG_FILE"
        cat cmake_version.txt >> "$LOG_FILE"
        FINAL_CMAKE=$(grep -oP 'cmake version \K[\d.]+' cmake_version.txt 2>>"$LOG_FILE" || echo "not installed")
        if [ "$FINAL_CMAKE" = "not installed" ]; then
            FINAL_CMAKE=$(head -n1 cmake_version.txt | awk '{print $3}' 2>>"$LOG_FILE" || echo "not installed")
        fi
        rm -f cmake_version.txt
        TEMP_FILES=("${TEMP_FILES[@]/cmake_version.txt}")
        echo "[CMake] Found existing version: $FINAL_CMAKE" | tee -a "$LOG_FILE"
    else
        echo "[CMake] Failed to run cmake --version. Check $TOOLS_DIR/cmake/bin/cmake." | tee -a "$LOG_FILE"
    fi
else
    echo "[CMake] No cmake binary found." | tee -a "$LOG_FILE"
fi

FINAL_RAYLIB="not installed"
if [ -f "$TOOLS_DIR/raylib/include/raylib.h" ]; then
    FINAL_RAYLIB=$(grep '#define RAYLIB_VERSION ' "$TOOLS_DIR/raylib/include/raylib.h" | awk '{print $3}' | tr -d '"' 2>>"$LOG_FILE" || echo "not installed")
    echo "[raylib] Found existing version: $FINAL_RAYLIB" | tee -a "$LOG_FILE"
else
    echo "[raylib] No raylib.h found." | tee -a "$LOG_FILE"
fi

# Debug point
echo "[Debug] Version checks complete: Zig=$FINAL_ZIG, CMake=$FINAL_CMAKE, Raylib=$FINAL_RAYLIB" | tee -a "$LOG_FILE"
read -p "Press Enter to continue..."

# Check for tools and manifest
INSTALL_MODE=0
if [ ! -d "$TOOLS_DIR" ]; then
    echo "No tools folder found. Entering install mode..." | tee -a "$LOG_FILE"
    INSTALL_MODE=1
elif [ ! -f "$MANIFEST" ]; then
    echo "No manifest found. Entering install mode..." | tee -a "$LOG_FILE"
    INSTALL_MODE=1
else
    echo "[Debug] Reading manifest from $MANIFEST..." | tee -a "$LOG_FILE"
    echo "Current tool versions:" | tee -a "$LOG_FILE"
    echo "" | tee -a "$LOG_FILE"
    cat "$MANIFEST" | tee -a "$LOG_FILE"
    echo "" | tee -a "$LOG_FILE"
fi

# Debug point
echo "[Debug] Install mode: $INSTALL_MODE" | tee -a "$LOG_FILE"
read -p "Press Enter to continue..."

# Update manifest with current versions (always)
{
    echo "# SneakernetStudio Tool Manifest"
    echo "# Updated: $(date '+%Y-%m-%d %H:%M:%S')"
    echo "Zig: $FINAL_ZIG"
    echo "CMake: $FINAL_CMAKE"
    echo "raylib: $FINAL_RAYLIB"
} > "$MANIFEST"
echo "Manifest updated."

# Clean install function
clean_install() {
    echo "[Debug] Performing clean install..." | tee -a "$LOG_FILE"
    # Purge tools directories and manifest files, preserving Toolchain_Zig.cmake
    [ -d "$TOOLS_DIR/cmake" ] && rm -rf "$TOOLS_DIR/cmake" >>"$LOG_FILE" 2>&1
    [ -d "$TOOLS_DIR/raylib" ] && rm -rf "$TOOLS_DIR/raylib" >>"$LOG_FILE" 2>&1
    [ -d "$TOOLS_DIR/zig" ] && rm -rf "$TOOLS_DIR/zig" >>"$LOG_FILE" 2>&1
    rm -f "$TOOLS_DIR/manifest"* >>"$LOG_FILE" 2>&1
    echo "[Debug] Tools directories and manifest files purged, preserving Toolchain_Zig.cmake." | tee -a "$LOG_FILE"
    # Force reinstall all tools
    install_zig force
    install_cmake force
    install_raylib force
}

# Install all function
install_all() {
    echo "Installing all tools..." | tee -a "$LOG_FILE"
    install_zig
    install_cmake
    install_raylib
}

install_zig() {
    local force="$1"
    local zig_ver="$FINAL_ZIG"
    [ "$zig_ver" = "not installed" ] && zig_ver="0.14.0"
    if [ $ONLINE -eq 1 ]; then
        echo "[Zig] Checking for latest version..." | tee -a "$LOG_FILE"
        wget -q -O zig.json https://ziglang.org/download/index.json >>"$LOG_FILE" 2>&1
        TEMP_FILES+=("zig.json")
        if [ -f zig.json ]; then
            latest_zig=$(grep -o '"0\.[0-9]\+\.0"' zig.json | tr -d '"' | sort -Vr | head -n1)
            rm -f zig.json
            TEMP_FILES=("${TEMP_FILES[@]/zig.json}")
        fi
        [ -z "$latest_zig" ] && latest_zig="0.14.0"
        echo "[Zig] Latest version: $latest_zig" | tee -a "$LOG_FILE"
        if [ -z "$force" ] && [ "$zig_ver" = "$latest_zig" ]; then
            echo "[Zig] Version $zig_ver is up-to-date." | tee -a "$LOG_FILE"
            FINAL_ZIG="$zig_ver"
            return
        fi
        zig_ver="$latest_zig"
    elif [ "$zig_ver" = "not installed" ]; then
        echo "[Zig] Offline: Zig not found. Connect to install." | tee -a "$LOG_FILE"
        FINAL_ZIG="failed"
        read -p "Press Enter to continue..."
        return
    elif [ -z "$force" ]; then
        echo "[Zig] Offline: Using existing version: $zig_ver" | tee -a "$LOG_FILE"
        FINAL_ZIG="$zig_ver"
        return
    fi
    echo "[Zig] Installing version $zig_ver..." | tee -a "$LOG_FILE"
    wget -q -O zig.tar.xz "https://ziglang.org/download/$zig_ver/zig-linux-x86_64-$zig_ver.tar.xz" >>"$LOG_FILE" 2>&1
    TEMP_FILES+=("zig.tar.xz")
    if [ -f zig.tar.xz ]; then
        [ -d "$TOOLS_DIR/zig" ] && rm -rf "$TOOLS_DIR/zig"
        mkdir -p "$TOOLS_DIR/zig"
        tar -xJf zig.tar.xz -C "$TOOLS_DIR/zig" --strip-components=1 >>"$LOG_FILE" 2>&1
        if [ -x "$TOOLS_DIR/zig/zig" ]; then
            FINAL_ZIG=$("$TOOLS_DIR/zig/zig" version 2>>"$LOG_FILE" || echo "not installed")
            echo "[Zig] Installation successful: $FINAL_ZIG" | tee -a "$LOG_FILE"
        else
            FINAL_ZIG="failed"
            echo "[Zig] Installation failed: zig binary not found. Check $LOG_FILE for details." | tee -a "$LOG_FILE"
            read -p "Press Enter to continue..."
        fi
        rm -f zig.tar.xz
        TEMP_FILES=("${TEMP_FILES[@]/zig.tar.xz}")
    else
        FINAL_ZIG="failed"
        echo "[Zig] Download failed. Check network and try again." | tee -a "$LOG_FILE"
        read -p "Press Enter to continue..."
    fi
}

install_cmake() {
    local force="$1"
    local cmake_ver="$FINAL_CMAKE"
    [ "$cmake_ver" = "not installed" ] && cmake_ver="4.2.0"
    if [ $ONLINE -eq 1 ]; then
        echo "[CMake] Checking for latest version..." | tee -a "$LOG_FILE"
        wget -q -O cmake.json https://api.github.com/repos/Kitware/CMake/releases/latest >>"$LOG_FILE" 2>&1
        TEMP_FILES+=("cmake.json")
        if [ -f cmake.json ]; then
            latest_cmake=$(grep -oP '"tag_name": "\Kv[\d.]+' cmake.json | tr -d 'v')
            rm -f cmake.json
            TEMP_FILES=("${TEMP_FILES[@]/cmake.json}")
        fi
        [ -z "$latest_cmake" ] && latest_cmake="4.2.0"
        echo "[CMake] Latest version: $latest_cmake" | tee -a "$LOG_FILE"
        if [ -z "$force" ] && [ "$cmake_ver" = "$latest_cmake" ]; then
            echo "[CMake] Version $cmake_ver is up-to-date." | tee -a "$LOG_FILE"
            FINAL_CMAKE="$cmake_ver"
            return
        fi
        cmake_ver="$latest_cmake"
    elif [ "$cmake_ver" = "not installed" ]; then
        echo "[CMake] Offline: CMake not found. Connect to install." | tee -a "$LOG_FILE"
        FINAL_CMAKE="failed"
        read -p "Press Enter to continue..."
        return
    elif [ -z "$force" ]; then
        echo "[CMake] Offline: Using existing version: $cmake_ver" | tee -a "$LOG_FILE"
        FINAL_CMAKE="$cmake_ver"
        return
    fi
    echo "[CMake] Installing version $cmake_ver..." | tee -a "$LOG_FILE"
    wget -q -O cmake.tar.gz "https://github.com/Kitware/CMake/releases/download/v$cmake_ver/cmake-$cmake_ver-linux-x86_64.tar.gz" >>"$LOG_FILE" 2>&1
    TEMP_FILES+=("cmake.tar.gz")
    if [ -f cmake.tar.gz ]; then
        [ -d "$TOOLS_DIR/cmake" ] && rm -rf "$TOOLS_DIR/cmake"
        mkdir -p "$TOOLS_DIR"
        tar -xzf cmake.tar.gz -C "$TOOLS_DIR" >>"$LOG_FILE" 2>&1
        if [ -d "$TOOLS_DIR/cmake-"* ]; then
            mv "$TOOLS_DIR/cmake-"* "$TOOLS_DIR/cmake"
            if [ -x "$TOOLS_DIR/cmake/bin/cmake" ]; then
                "$TOOLS_DIR/cmake/bin/cmake" --version > cmake_version.txt 2>>"$LOG_FILE"
                TEMP_FILES+=("cmake_version.txt")
                if [ -f cmake_version.txt ]; then
                    FINAL_CMAKE=$(grep -oP 'cmake version \K[\d.]+' cmake_version.txt 2>>"$LOG_FILE" || echo "not installed")
                    if [ "$FINAL_CMAKE" = "not installed" ]; then
                        FINAL_CMAKE=$(head -n1 cmake_version.txt | awk '{print $3}' 2>>"$LOG_FILE" || echo "not installed")
                    fi
                    rm -f cmake_version.txt
                    TEMP_FILES=("${TEMP_FILES[@]/cmake_version.txt}")
                    echo "[CMake] Installation successful: $FINAL_CMAKE" | tee -a "$LOG_FILE"
                else
                    FINAL_CMAKE="failed"
                    echo "[CMake] Installation failed: cmake --version failed after install." | tee -a "$LOG_FILE"
                    read -p "Press Enter to continue..."
                fi
            else
                FINAL_CMAKE="failed"
                echo "[CMake] Installation failed: cmake binary not found. Check $LOG_FILE for details." | tee -a "$LOG_FILE"
                read -p "Press Enter to continue..."
            fi
        else
            FINAL_CMAKE="failed"
            echo "[CMake] Installation failed: extraction failed. Check $LOG_FILE for details." | tee -a "$LOG_FILE"
            read -p "Press Enter to continue..."
        fi
        rm -f cmake.tar.gz
        TEMP_FILES=("${TEMP_FILES[@]/cmake.tar.gz}")
    else
        FINAL_CMAKE="failed"
        echo "[CMake] Download failed. Check network and try again." | tee -a "$LOG_FILE"
        read -p "Press Enter to continue..."
    fi
}

install_raylib() {
    local force="$1"
    local raylib_ver="$FINAL_RAYLIB"
    [ "$raylib_ver" = "not installed" ] && raylib_ver="5.5"
    if [ $ONLINE -eq 1 ]; then
        echo "[raylib] Checking for latest version..." | tee -a "$LOG_FILE"
        wget -q -O raylib.json https://api.github.com/repos/raysan5/raylib/releases/latest >>"$LOG_FILE" 2>&1
        TEMP_FILES+=("raylib.json")
        if [ -f raylib.json ]; then
            latest_raylib=$(grep -oP '"tag_name": "\K[\d.]+' raylib.json | tr -d '"')
            rm -f raylib.json
            TEMP_FILES=("${TEMP_FILES[@]/raylib.json}")
        fi
        [ -z "$latest_raylib" ] && latest_raylib="5.5"
        echo "[raylib] Latest version: $latest_raylib" | tee -a "$LOG_FILE"
        if [ -z "$force" ] && [ "$raylib_ver" = "$latest_raylib" ]; then
            echo "[raylib] Version $raylib_ver is up-to-date." | tee -a "$LOG_FILE"
            FINAL_RAYLIB="$raylib_ver"
            return
        fi
        raylib_ver="$latest_raylib"
    elif [ "$raylib_ver" = "not installed" ]; then
        echo "[raylib] Offline: raylib not found. Connect to install." | tee -a "$LOG_FILE"
        FINAL_RAYLIB="failed"
        read -p "Press Enter to continue..."
        return
    elif [ -z "$force" ]; then
        echo "[raylib] Offline: Using existing version: $raylib_ver" | tee -a "$LOG_FILE"
        FINAL_RAYLIB="$raylib_ver"
        return
    fi
    echo "[raylib] Installing version $raylib_ver..." | tee -a "$LOG_FILE"
    wget -q -O raylib.tar.gz "https://github.com/raysan5/raylib/releases/download/$raylib_ver/raylib-$raylib_ver.tar.gz" >>"$LOG_FILE" 2>&1
    TEMP_FILES+=("raylib.tar.gz")
    if [ -f raylib.tar.gz ]; then
        [ -d "$TOOLS_DIR/raylib" ] && rm -rf "$TOOLS_DIR/raylib"
        mkdir -p "$TOOLS_DIR"
        tar -xzf raylib.tar.gz -C "$TOOLS_DIR" >>"$LOG_FILE" 2>&1
        if [ -d "$TOOLS_DIR/raylib-"* ]; then
            mv "$TOOLS_DIR/raylib-"* "$TOOLS_DIR/raylib"
            if [ -f "$TOOLS_DIR/raylib/include/raylib.h" ]; then
                FINAL_RAYLIB=$(grep '#define RAYLIB_VERSION ' "$TOOLS_DIR/raylib/include/raylib.h" | awk '{print $3}' | tr -d '"' 2>>"$LOG_FILE" || echo "not installed")
                echo "[raylib] Installation successful: $FINAL_RAYLIB" | tee -a "$LOG_FILE"
            else
                FINAL_RAYLIB="failed"
                echo "[raylib] Installation failed: raylib.h not found. Check $LOG_FILE for details." | tee -a "$LOG_FILE"
                read -p "Press Enter to continue..."
            fi
        else
            FINAL_RAYLIB="failed"
            echo "[raylib] Installation failed: extraction failed. Check $LOG_FILE for details." | tee -a "$LOG_FILE"
            read -p "Press Enter to continue..."
        fi
        rm -f raylib.tar.gz
        TEMP_FILES=("${TEMP_FILES[@]/raylib.tar.gz}")
    else
        FINAL_RAYLIB="failed"
        echo "[raylib] Download failed. Check network and try again." | tee -a "$LOG_FILE"
        read -p "Press Enter to continue..."
    fi
}

update_menu() {
    echo "Options:" | tee -a "$LOG_FILE"
    echo "1. Force reinstall all tools" | tee -a "$LOG_FILE"
    echo "2. Update/install Zig only" | tee -a "$LOG_FILE"
    echo "3. Update/install CMake only" | tee -a "$LOG_FILE"
    echo "4. Update/install raylib only" | tee -a "$LOG_FILE"
    echo "5. Exit (use existing tools)" | tee -a "$LOG_FILE"
    echo -n "Enter choice(s) (e.g., 1,2 or 12 or 1 2): "
    read choice
    echo "" | tee -a "$LOG_FILE"
    echo "User selected: $choice" | tee -a "$LOG_FILE"
    echo

    # Parse multiple selections
    choice=$(echo "$choice" | tr -d ' ,')
    installed=0
    for ((i=0; i<${#choice}; i++)); do
        char="${choice:$i:1}"
        case "$char" in
            1) clean_install; installed=1 ;;
            2) install_zig; installed=1 ;;
            3) install_cmake; installed=1 ;;
            4) install_raylib; installed=1 ;;
            5) echo "Keeping existing tools." | tee -a "$LOG_FILE"; return ;;
            *) echo "Invalid choice: $char" | tee -a "$LOG_FILE" ;;
        esac
    done
    if [ $installed -eq 0 ]; then
        echo "Invalid choice selected." | tee -a "$LOG_FILE"
    fi
}

# Main
mkdir -p "$TOOLS_DIR"
if [ $INSTALL_MODE -eq 1 ]; then
    clean_install
else
    update_menu
fi

# Determine installation status
install_status="All tools successfully installed."
if [ "${FINAL_ZIG:-failed}" = "failed" ] || [ "${FINAL_CMAKE:-failed}" = "failed" ] || [ "${FINAL_RAYLIB:-failed}" = "failed" ] || \
   [ "${FINAL_CMAKE:-not installed}" = "not installed" ] || [ "${FINAL_RAYLIB:-not installed}" = "not installed" ]; then
    install_status="Some tools failed to install."
fi

# Final screen
clear
echo "[Debug] Preparing final screen..." | tee -a "$LOG_FILE"
echo "" | tee -a "$LOG_FILE"
echo "============================================================" | tee -a "$LOG_FILE"
echo "     SneakernetStudio is ready" | tee -a "$LOG_FILE"
echo "" | tee -a "$LOG_FILE"
echo "     Zig     : ${FINAL_ZIG:-failed}" | tee -a "$LOG_FILE"
echo "     CMake   : ${FINAL_CMAKE:-failed}" | tee -a "$LOG_FILE"
echo "     raylib  : ${FINAL_RAYLIB:-failed}" | tee -a "$LOG_FILE"
echo "" | tee -a "$LOG_FILE"
if [ $INSTALL_MODE -eq 1 ]; then
    echo "     $install_status" | tee -a "$LOG_FILE"
else
    echo "     Tools updated or unchanged." | tee -a "$LOG_FILE"
fi
echo "" | tee -a "$LOG_FILE"
echo "     Happy coding!" | tee -a "$LOG_FILE"
echo "============================================================" | tee -a "$LOG_FILE"
echo "" | tee -a "$LOG_FILE"
echo "Press Enter to close..." | tee -a "$LOG_FILE"

# Write manifest
echo "[Debug] Writing manifest to $MANIFEST..." | tee -a "$LOG_FILE"
{
    echo "# SneakernetStudio Tool Manifest"
    echo "# Updated: $(date '+%Y-%m-%d %H:%M:%S')"
    echo "Zig: ${FINAL_ZIG:-failed}"
    echo "CMake: ${FINAL_CMAKE:-failed}"
    echo "raylib: ${FINAL_RAYLIB:-failed}"
} > "$MANIFEST" 2>>"$LOG_FILE"
echo "[Debug] Manifest write complete." | tee -a "$LOG_FILE"

read -p ""
cleanup
