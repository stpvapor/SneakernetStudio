#!/usr/bin/env bash
# update-studio.sh – FINAL, FULLY AUTOMATED + FULL LOGGING (2025-11-27)

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TOOLS_DIR="$REPO_ROOT/tools"
LOG_FILE="$TOOLS_DIR/update.log"

# Clear old log and start fresh
> "$LOG_FILE"

GREEN='\033[0;32m'; YELLOW='\033[1;33m'; RED='\033[0;31m'; NC='\033[0m'
log() { 
    echo -e "${GREEN}[$(date +%H:%M:%S)]${NC} $*" | tee -a "$LOG_FILE"
}
warn() { 
    echo -e "${YELLOW}[$(date +%H:%M:%S)] WARN${NC} $*" | tee -a "$LOG_FILE"
}
err() { 
    echo -e "${RED}[$(date +%H:%M:%S)] ERROR${NC} $*" | tee -a "$LOG_FILE"
    exit 1
}

log "============================================================="
log "     SneakernetStudio Updater – STARTING"
log "     Repo root: $REPO_ROOT"
log "     Log file : $LOG_FILE"
log "============================================================="

mkdir -p "$TOOLS_DIR"

# === Zig ===
if [[ ! -f "$TOOLS_DIR/zig/zig" ]]; then
    log "Downloading Zig 0.14.0..."
    rm -rf "$TOOLS_DIR/zig"
    curl -L# https://ziglang.org/download/0.14.0/zig-linux-x86_64-0.14.0.tar.xz | tar -xJ -C "$TOOLS_DIR" >>"$LOG_FILE" 2>&1
    mv "$TOOLS_DIR/zig-linux-x86_64-0.14.0" "$TOOLS_DIR/zig"
    log "Zig 0.14.0 installed"
else
    log "Zig 0.14.0 already present"
fi

# === CMake ===
if [[ ! -f "$TOOLS_DIR/cmake/bin/cmake" ]]; then
    log "Downloading portable CMake 4.2.0..."
    rm -rf "$TOOLS_DIR/cmake"
    curl -L# https://github.com/Kitware/CMake/releases/download/v4.2.0/cmake-4.2.0-linux-x86_64.tar.gz | tar -xz -C "$TOOLS_DIR" >>"$LOG_FILE" 2>&1
    mv "$TOOLS_DIR/cmake-4.2.0-linux-x86_64" "$TOOLS_DIR/cmake"
    log "CMake 4.2.0 installed"
else
    log "CMake 4.2.0 already present"
fi

# === raylib + FULL STATIC BUILD ===
if [[ ! -f "$TOOLS_DIR/raylib/src/libraylib.a" ]]; then
    log "Cloning raylib 5.5..."
    rm -rf "$TOOLS_DIR/raylib"
    git clone --depth 1 --branch 5.5 https://github.com/raysan5/raylib.git "$TOOLS_DIR/raylib" >>"$LOG_FILE" 2>&1

    log "Building static raylib (this takes ~30-60s on Threadripper)..."
    make -C "$TOOLS_DIR/raylib/src" -j$(nproc) PLATFORM=PLATFORM_DESKTOP SHARED=0 CLEAN=1 >>"$LOG_FILE" 2>&1 || err "raylib build failed – see $LOG_FILE"
    log "raylib 5.5 built → libraylib.a ready at tools/raylib/src/libraylib.a"
else
    log "raylib 5.5 already built (libraylib.a exists)"
fi

# === Manifest ===
cat > "$TOOLS_DIR/manifest.txt" <<EOF
# SneakernetStudio Tool Manifest
# Updated: $(date +"%Y-%m-%d %H:%M:%S")
Zig: 0.14.0
CMake: 4.2.0
raylib: 5.5
EOF
log "Manifest updated"

log "============================================================="
log "     ALL TOOLS READY – NO MANUAL STEPS EVER AGAIN"
log "     Full log saved to: $LOG_FILE"
log "============================================================="

clear
echo "============================================================="
echo "     SneakernetStudio is ready"
echo
echo "     Zig     : 0.14.0"
echo "     CMake   : 4.2.0"
echo "     raylib  : 5.5 (static lib built)"
echo
echo "     Full log → tools/update.log"
echo
echo "     Just run ./build.sh in any project"
echo
echo "     Happy coding!"
echo "============================================================="
read -p "Press Enter to close..."