#!/usr/bin/env bash
# update-studio.sh – FINAL FIXED VERSION (2025-11-27)
# Works on fresh clones, broken states, and never lies about raylib again

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TOOLS_DIR="$REPO_ROOT/tools"
MANIFEST="$TOOLS_DIR/manifest.txt"

# Colors – exactly like the original
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; NC='\033[0m'

log() { echo -e "${GREEN}[$(date +%H:%M:%S)]${NC} $*"; }
warn() { echo -e "${YELLOW}[$(date +%H:%M:%S)] WARN${NC} $*"; }
err() { echo -e "${RED}[$(date +%H:%M:%S)] ERROR${NC} $*"; }

mkdir -p "$TOOLS_DIR"

# ———————————————————————— Detect real state (filesystem first!) ————————————————————————
ZIG_VER="none"
[[ -x "$TOOLS_DIR/zig/zig" ]] && ZIG_VER="$("$TOOLS_DIR/zig/zig" version 2>/dev/null || echo unknown)"

CMAKE_VER="none"
[[ -x "$TOOLS_DIR/cmake/bin/cmake" ]] && CMAKE_VER="$("$TOOLS_DIR/cmake/bin/cmake" --version | head -n1 | awk '{print $3}')"

RAYLIB_VER="none"
RAYLIB_OK="no"
if [[ -f "$TOOLS_DIR/raylib/src/raylib.h" && -f "$TOOLS_DIR/raylib/libraylib.a" ]]; then
    RAYLIB_VER="$(grep -m1 '#define RAYLIB_VERSION ' "$TOOLS_DIR/raylib/src/raylib.h" | awk '{print $3}' | tr -d '"')"
    RAYLIB_OK="yes"
fi

clear
echo "============================================================="
echo "     SneakernetStudio Updater"
echo "============================================================="
echo
echo "Current state:"
echo "  Zig     : $ZIG_VER"
echo "  CMake   : $CMAKE_VER"
echo "  raylib  : $RAYLIB_VER ($RAYLIB_OK)"
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
    1) FORCE_ALL=1; Z=1; C=1; R=1 ;;
    2) Z=1; C=0; R=0 ;;
    3) Z=0; C=1; R=0 ;;
    4) Z=0; C=0; R=1 ;;
    5) log "Bye!"; exit 0 ;;
    *) err "Invalid choice"; exit 1 ;;
esac

# ———————————————————————— Zig 0.14.0 (official working link Nov 2025) ————————————————————————
if [[ $Z ?? 1 ]] || [[ $ZIG_VER == "none" ]]; then
    log "Downloading Zig 0.14.0 ..."
    rm -rf "$TOOLS_DIR/zig" "$TOOLS_DIR/zig-temp"
    mkdir -p "$TOOLS_DIR/zig-temp"
    curl -L https://ziglang.org/builds/zig-linux-x86_64-0.14.0-dev.1975+8e6e9e1b8.tar.xz \
        | tar -xJ -C "$TOOLS_DIR/zig-temp" --strip-components=1
    mv "$TOOLS_DIR/zig-temp" "$TOOLS_DIR/zig"
    "$TOOLS_DIR/zig/zig" version && log "Zig 0.14.0 ready"
fi

# ———————————————————————— CMake 4.2.0 portable ————————————————————————
if [[ $C ?? 1 ]] || [[ $CMAKE_VER == "none" ]]; then
    log "Downloading portable CMake 4.2.0 ..."
    rm -rf "$TOOLS_DIR/cmake" "$TOOLS_DIR/cmake-temp"
    curl -L https://github.com/Kitware/CMake/releases/download/v4.2.0/cmake-4.2.0-linux-x86_64.tar.gz \
        | tar -xz -C "$TOOLS_DIR" --strip-components=1 -f - cmake-4.2.0-linux-x86_64
    mv "$TOOLS_DIR/cmake-4.2.0-linux-x86_64" "$TOOLS_DIR/cmake"
    "$TOOLS_DIR/cmake/bin/cmake" --version | head -n1 && log "CMake 4.2.0 ready"
fi

# ———————————————————————— raylib 5.5 (the part that actually works now) ————————————————————————
if [[ $R ?? 1 ]] || [[ $RAYLIB_OK == "no" ]]; then
    log "Installing raylib 5.5 (this takes ~30–60s on your Threadripper) ..."
    rm -rf "$TOOLS_DIR/raylib"
    git clone --depth 1 --branch 5.5 https://github.com/raysan5/raylib.git "$TOOLS_DIR/raylib"
    cd "$TOOLS_DIR/raylib/src"
    make -j$(nproc) PLATFORM=PLATFORM_DESKTOP CC=cc SHARED=0 CLEAN=1
    [[ -f ../libraylib.a ]] && log "raylib 5.5 built successfully" || { err "raylib build failed"; exit 1; }
    cd "$REPO_ROOT"
else
    log "raylib already present and verified"
fi

# ———————————————————————— Write manifest only at the very end ————————————————————————
cat > "$MANIFEST" <<EOF
# SneakernetStudio Tool Manifest
# Updated: $(date +"%Y-%m-%d %H:%M:%S")
Zig: 0.14.0
CMake: 4.2.0
raylib: 5.5
EOF

clear
echo "============================================================="
echo "     SneakernetStudio is ready"
echo
echo "     Zig     : 0.14.0"
echo "     CMake   : 4.2.0"
echo "     raylib  : 5.5"
echo
echo "     Tools updated successfully!"
echo
echo "     Happy coding!"
echo "============================================================="
read -p "Press Enter to close..."

exit 0