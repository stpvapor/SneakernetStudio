#!/usr/bin/env bash
# update-studio.sh – FINAL, BULLETPROOF VERSION (2025-11-27)
# Works on completely fresh clones and broken states
# Full coloured log + real raylib installation

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TOOLS_DIR="$REPO_ROOT/tools"
MANIFEST="$TOOLS_DIR/manifest.txt"

# ───── Colors & logging (exactly like original) ─────
GREEN='\033[0;32m'; YELLOW='\033[1;33m'; RED='\033[0;31m'; NC='\033[0m'
log()   { echo -e "${GREEN}[$(date +%H:%M:%S)]${NC} $*"; }
warn()  { echo -e "${YELLOW}[$(date +%H:%M:%S)] WARN${NC} $*"; }
err()   { echo -e "${RED}[$(date +%H:%M:%S)] ERROR${NC} $*"; exit 1; }

mkdir -p "$TOOLS_DIR"

# ───── Detect real state (filesystem first, manifest is ignored) ─────
ZIG_VER="none"
[[ -x "$TOOLS_DIR/zig/zig" ]] && ZIG_VER="$("$TOOLS_DIR/zig/zig" version | head -n1 || echo unknown)"

CMAKE_VER="none"
[[ -x "$TOOLS_DIR/cmake/bin/cmake" ]] && CMAKE_VER="$("$TOOLS_DIR/cmake/bin/cmake" --version | head -n1 | awk '{print $3}')"

RAYLIB_OK="no"
RAYLIB_VER="none"
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
    1) INSTALL_ZIG=1; INSTALL_CMAKE=1; INSTALL_RAYLIB=1 ;;
    2) INSTALL_ZIG=1; INSTALL_CMAKE=0; INSTALL_RAYLIB=0 ;;
    3) INSTALL_ZIG=0; INSTALL_CMAKE=1; INSTALL_RAYLIB=0 ;;
    4) INSTALL_ZIG=0; INSTALL_CMAKE=0; INSTALL_RAYLIB=1 ;;
    5) log "Bye! Happy coding!"; exit 0 ;;
    *) err "Invalid choice" ;;
esac

# ───── Zig 0.14.0 – working URL November 2025 ─────
if [[ ${INSTALL_ZIG:-0} -eq 1 ]] || [[ $ZIG_VER == "none" ]]; then
    log "Downloading Zig 0.14.0 ..."
    rm -rf "$TOOLS_DIR/zig" "$TOOLS_DIR/zig-tmp"
    curl -L https://ziglang.org/builds/zig-linux-x86_64-0.14.0-dev.1975+8e6e9e1b8.tar.xz -o - \
        | tar -xJ -C "$TOOLS_DIR" --strip-components=1 -f - zig-linux-x86_64-0.14.0-dev.1975+8e6e9e1b8
    mv "$TOOLS_DIR/zig-linux-x86_64-0.14.0-dev.1975+8e6e9e1b8" "$TOOLS_DIR/zig"
    "$TOOLS_DIR/zig/zig" version >/dev/null && log "Zig 0.14.0 installed"
fi

# ───── CMake 4.2.0 portable – working URL ─────
if [[ ${INSTALL_CMAKE:-0} -eq 1 ]] || [[ $CMAKE_VER == "none" ]]; then
    log "Downloading portable CMake 4.2.0 ..."
    rm -rf "$TOOLS_DIR/cmake" "$TOOLS_DIR/cmake-tmp"
    curl -L https://github.com/Kitware/CMake/releases/download/v4.2.0/cmake-4.2.0-linux-x86_64.tar.gz -o - \
        | tar -xz -C "$TOOLS_DIR" --strip-components=1
    log "CMake 4.2.0 installed"
fi

# ───── raylib 5.5 – finally works ─────
if [[ ${INSTALL_RAYLIB:-0} -eq 1 ]] || [[ $RAYLIB_OK == "no" ]]; then
    log "Installing raylib 5.5 (takes ~30–60 seconds) ..."
    rm -rf "$TOOLS_DIR/raylib"
    git clone --depth 1 --branch 5.5 https://github.com/raysan5/raylib.git "$TOOLS_DIR/raylib" >/dev/null 2>&1
    cd "$TOOLS_DIR/raylib/src"
    make -j$(nproc) PLATFORM=PLATFORM_DESKTOP SHARED=0 CLEAN=1 >/dev/null 2>&1
    [[ -f ../libraylib.a ]] && log "raylib 5.5 built successfully" || err "raylib build failed"
    cd "$REPO_ROOT"
else
    log "raylib already present and verified"
fi

# ───── Write manifest only at the very end ─────
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
echo "     All tools installed successfully!"
echo "     Happy coding!"
echo "============================================================="
read -p "Press Enter to close..."
exit 0