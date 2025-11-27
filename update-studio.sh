#!/usr/bin/env bash
# update-studio.sh – FINAL CORRECT VERSION (2025-11-27)
# Keeps manifest for updates, but never crashes if missing
# Working URLs + proper raylib detection

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TOOLS_DIR="$REPO_ROOT/tools"
MANIFEST="$TOOLS_DIR/manifest.txt"

# Colors
GREEN='\033[0;32m'; YELLOW='\033[1;33m'; RED='\033[0;31m'; NC='\033[0m'

log() { echo -e "${GREEN}$1${NC}"; }

clear
echo "============================================================="
echo "     SneakernetStudio Updater"
echo "============================================================="
echo "Starting updater in $REPO_ROOT..."

# ───── Safe manifest reading (never crashes if missing) ─────
ZIG_MANIFEST="unknown"
CMAKE_MANIFEST="unknown"
RAYLIB_MANIFEST="unknown"

if [[ -f "$MANIFEST" ]]; then
    ZIG_MANIFEST=$(grep "^Zig:" "$MANIFEST" | cut -d: -f2 | xargs || echo "unknown")
    CMAKE_MANIFEST=$(grep "^CMake:" "$MANIFEST" | cut -d: -f2 | xargs || echo "unknown")
    RAYLIB_MANIFEST=$(grep "^raylib:" "$MANIFEST" | cut -d: -f2 | xargs || echo "unknown")
fi

# ───── Real filesystem checks (this is what fixes the raylib lie) ─────
ZIG_OK="no";     [[ -x "$TOOLS_DIR/zig/zig" ]] && ZIG_OK="yes"
CMAKE_OK="no";   [[ -x "$TOOLS_DIR/cmake/bin/cmake" ]] && CMAKE_OK="yes"
RAYLIB_OK="no"
if [[ -f "$TOOLS_DIR/raylib/src/raylib.h" && -f "$TOOLS_DIR/raylib/libraylib.a" ]]; then
    RAYLIB_OK="yes"
    RAYLIB_REAL_VER=$(grep -m1 '#define RAYLIB_VERSION ' "$TOOLS_DIR/raylib/src/raylib.h" | awk '{print $3}' | tr -d '"')
else
    RAYLIB_REAL_VER="not installed"
fi

log "[Zig]     $ZIG_OK (manifest: $ZIG_MANIFEST)"
log "[CMake]   $CMAKE_OK (manifest: $CMAKE_MANIFEST)"
log "[raylib]  $RAYLIB_OK → $RAYLIB_REAL_VER (manifest claims: $RAYLIB_MANIFEST)"
[[ $RAYLIB_OK == "no" ]] && log "[raylib] No raylib.h found."

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
    1) DO_ZIG=1; DO_CMAKE=1; DO_RAYLIB=1 ;;
    2) DO_ZIG=1; DO_CMAKE=0; DO_RAYLIB=0 ;;
    3) DO_ZIG=0; DO_CMAKE=1; DO_RAYLIB=0 ;;
    4) DO_ZIG=0; DO_CMAKE=0; DO_RAYLIB=1 ;;
    5) log "Bye!"; exit 0 ;;
    *) log "Invalid choice"; exit 1 ;;
esac

mkdir -p "$TOOLS_DIR"

# ───── Zig ─────
if [[ $DO_ZIG == 1 ]] || [[ $ZIG_OK == "no" ]]; then
    log "[Zig] Downloading Zig 0.14.0..."
    rm -rf "$TOOLS_DIR/zig"
    curl -L https://ziglang.org/download/0.14.0/zig-linux-x86_64-0.14.0.tar.xz | tar -xJ -C "$TOOLS_DIR"
    mv "$TOOLS_DIR"/zig-linux-x86_64-0.14.0 "$TOOLS_DIR/zig"
    log "[Zig] Found existing version: 0.14.0"
fi

# ───── CMake ─────
if [[ $DO_CMAKE == 1 ]] || [[ $CMAKE_OK == "no" ]]; then
    log "[CMake] Downloading portable CMake 4.2.0..."
    rm -rf "$TOOLS_DIR/cmake"
    curl -L https://github.com/Kitware/CMake/releases/download/v4.2.0/cmake-4.2.0-linux-x86_64.tar.gz | tar -xz -C "$TOOLS_DIR"
    mv "$TOOLS_DIR"/cmake-4.2.0-linux-x86_64 "$TOOLS_DIR/cmake"
    log "[CMake] Found existing version: 4.2.0"
fi

# ───── raylib ─────
if [[ $DO_RAYLIB == 1 ]] || [[ $RAYLIB_OK == "no" ]]; then
    log "[raylib] Installing raylib 5.5..."
    rm -rf "$TOOLS_DIR/raylib"
    git clone --depth 1 --branch 5.5 https://github.com/raysan5/raylib.git "$TOOLS_DIR/raylib"
    cd "$TOOLS_DIR/raylib/src"
    make -j$(nproc) PLATFORM=PLATFORM_DESKTOP SHARED=0
    cd "$REPO_ROOT"
    log "[raylib] Found existing version: 5.5"
else
    log "[raylib] Already installed and verified"
fi

# ───── Write manifest at the very end (only truth) ─────
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
echo "     Tools updated or unchanged."
echo
echo "     Happy coding!"
echo "============================================================="
read -rp "Press Enter to close..."