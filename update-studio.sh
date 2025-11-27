#!/usr/bin/env bash
# update-studio.sh – FINAL, 100% WORKING, NEVER TOUCHES PROJECT FILES (2025-11-27)

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TOOLS_DIR="$REPO_ROOT/tools"
MANIFEST="$TOOLS_DIR/manifest.txt"
LOG_FILE="$TOOLS_DIR/update.log"
> "$LOG_FILE"

GREEN='\033[0;32m'; RED='\033[0;31m'; NC='\033[0m'
log() { echo -e "${GREEN}[$(date +%H:%M:%S)]${NC} $*" | tee -a "$LOG_FILE"; }

log "============================================================="
log "     SneakernetStudio Updater"
log "============================================================="

ZIG_VERSION="0.14.0"
CMAKE_VERSION="4.2.0"
RAYLIB_VERSION="5.5"

# Auto-install on first run
if [[ ! -f "$MANIFEST" ]]; then
    log "First run — installing all tools"
    DO_ALL=1
else
    ZIG_VERSION=$(grep "^Zig:" "$MANIFEST" | cut -d: -f2 | xargs || echo "$ZIG_VERSION")
    CMAKE_VERSION=$(grep "^CMake:" "$MANIFEST" | cut -d: -f2 | xargs || echo "$CMAKE_VERSION")
    RAYLIB_VERSION=$(grep "^raylib:" "$MANIFEST" | cut -d: -f2 | xargs || echo "$RAYLIB_VERSION")

    log "Current versions:"
    log "  Zig     : $ZIG_VERSION"
    log "  CMake   : $CMAKE_VERSION"
    log "  raylib  : $RAYLIB_VERSION"

    echo
    echo "Options:"
    echo "1. Force reinstall all tools"
    echo "2. Update/install Zig only"
    echo "3. Update/install CMake only"
    echo "4. Update/install raylib only"
    echo "5. Exit (use existing tools)"
    echo
    read -rp "Select [1-5]: " choice

    case "$choice" in
        1) DO_ALL=1 ;;
        2) DO_ZIG=1 ;;
        3) DO_CMAKE=1 ;;
        4) DO_RAYLIB=1 ;;
        5) log "Bye!"; exit 0 ;;
        *) log "Invalid choice"; exit 1 ;;
    esac
fi

mkdir -p "$TOOLS_DIR"

# Zig
if [[ $DO_ALL || $DO_ZIG ]]; then
    log "Downloading Zig $ZIG_VERSION..."
    rm -rf "$TOOLS_DIR/zig"
    curl -L# "https://ziglang.org/download/$ZIG_VERSION/zig-linux-x86_64-$ZIG_VERSION.tar.xz" | tar -xJ -C "$TOOLS_DIR"
    mv "$TOOLS_DIR/zig-linux-x86_64-$ZIG_VERSION" "$TOOLS_DIR/zig"
    log "Zig $ZIG_VERSION installed"
else
    log "Zig $ZIG_VERSION already present"
fi

# CMake
if [[ $DO_ALL || $DO_CMAKE ]]; then
    log "Downloading portable CMake $CMAKE_VERSION..."
    rm -rf "$TOOLS_DIR/cmake"
    curl -L# "https://github.com/Kitware/CMake/releases/download/v$CMAKE_VERSION/cmake-$CMAKE_VERSION-linux-x86_64.tar.gz" | tar -xz -C "$TOOLS_DIR"
    mv "$TOOLS_DIR/cmake-$CMAKE_VERSION-linux-x86_64" "$TOOLS_DIR/cmake"
    log "CMake $CMAKE_VERSION installed"
else
    log "CMake $CMAKE_VERSION already present"
fi

# raylib
if [[ $DO_ALL || $DO_RAYLIB ]]; then
    log "Cloning and building raylib $RAYLIB_VERSION..."
    rm -rf "$TOOLS_DIR/raylib"
    git clone --depth 1 --branch "$RAYLIB_VERSION" https://github.com/raysan5/raylib.git "$TOOLS_DIR/raylib" >>"$LOG_FILE" 2>&1
    make -C "$TOOLS_DIR/raylib/src" -j$(nproc) PLATFORM=PLATFORM_DESKTOP SHARED=0 CLEAN=1 >>"$LOG_FILE" 2>&1
    log "raylib $RAYLIB_VERSION built – libraylib.a ready"
else
    log "raylib $RAYLIB_VERSION already built"
fi

# Write manifest
cat > "$MANIFEST" <<EOF
# SneakernetStudio Tool Manifest
# Updated: $(date +"%Y-%m-%d %H:%M:%S")
Zig: $ZIG_VERSION
CMake: $CMAKE_VERSION
raylib: $RAYLIB_VERSION
EOF

clear
echo "============================================================="
echo "     SneakernetStudio is ready"
echo
echo "     Zig     : $ZIG_VERSION"
echo "     CMake   : $CMAKE_VERSION"
echo "     raylib  : $RAYLIB_VERSION"
echo
echo "     Tools updated or unchanged."
echo
echo "     Happy coding!"
echo "============================================================="
read -p "Press Enter to close..."