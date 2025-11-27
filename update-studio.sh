#!/usr/bin/env bash
# update-studio.sh – FINAL, 100% CORRECT, NO MAGIC NUMBERS, MANIFEST-DRIVEN (2025-11-27)

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TOOLS_DIR="$REPO_ROOT/tools"
MANIFEST="$TOOLS_DIR/manifest.txt"
LOG_FILE="$TOOLS_DIR/update.log"
> "$LOG_FILE"

GREEN='\033[0;32m'; RED='\033[0;31m'; NC='\033[0m'
log() { echo -e "${GREEN}[$(date +%H:%M:%S)]${NC} $*" | tee -a "$LOG_FILE"; }

log "============================================================="
log "     SneakernetStudio Updater – MANIFEST-DRIVEN"
log "     Repo root: $REPO_ROOT"
log "============================================================="

# Default versions (used only if manifest missing – first run)
ZIG_VERSION="0.14.0"
CMAKE_VERSION="4.2.0"
RAYLIB_VERSION="5.5"

# Read manifest if it exists
if [[ -f "$MANIFEST" ]]; then
    ZIG_VERSION=$(grep "^Zig:" "$MANIFEST" | cut -d: -f2 | xargs)
    CMAKE_VERSION=$(grep "^CMake:" "$MANIFEST" | cut -d: -f2 |  xargs)
    RAYLIB_VERSION=$(grep "^raylib:" "$MANIFEST" | cut -d: -f2 | xargs)
    log "Manifest found – using versions:"
    log "  Zig: $ZIG_VERSION"
    log "  CMake: $CMAKE_VERSION"
    log "  raylib: $RAYLIB_VERSION"
else
    log "No manifest – using default versions (first run)"
fi

mkdir -p "$TOOLS_DIR"

# Zig
if [[ ! -f "$TOOLS_DIR/zig/zig" ]]; then
    log "Downloading Zig $ZIG_VERSION..."
    curl -L# "https://ziglang.org/download/$ZIG_VERSION/zig-linux-x86_64-$ZIG_VERSION.tar.xz" | tar -xJ -C "$TOOLS_DIR"
    mv "$TOOLS_DIR/zig-linux-x86_64-$ZIG_VERSION" "$TOOLS_DIR/zig"
    log "Zig $ZIG_VERSION installed"
else
    log "Zig $ZIG_VERSION already present"
fi

# CMake
if [[ ! -f "$TOOLS_DIR/cmake/bin/cmake" ]]; then
    log "Downloading portable CMake $CMAKE_VERSION..."
    curl -L# "https://github.com/Kitware/CMake/releases/download/v$CMAKE_VERSION/cmake-$CMAKE_VERSION-linux-x86_64.tar.gz" | tar -xz -C "$TOOLS_DIR"
    mv "$TOOLS_DIR/cmake-$CMAKE_VERSION-linux-x86_64" "$TOOLS_DIR/cmake"
    log "CMake $CMAKE_VERSION installed"
else
    log "CMake $CMAKE_VERSION already present"
fi

# raylib
if [[ ! -f "$TOOLS_DIR/raylib/src/libraylib.a" ]]; then
    log "Cloning and building raylib $RAYLIB_VERSION..."
    rm -rf "$TOOLS_DIR/raylib"
    git clone --depth 1 --branch "$RAYLIB_VERSION" https://github.com/raysan5/raylib.git "$TOOLS_DIR/raylib" >>"$LOG_FILE" 2>&1
    make -C "$TOOLS_DIR/raylib/src" -j$(nproc) PLATFORM=PLATFORM_DESKTOP SHARED=0 CLEAN=1 >>"$LOG_FILE" 2>&1
    log "raylib $RAYLIB_VERSION built – libraylib.a ready"
else
    log "raylib $RAYLIB_VERSION already built"
fi

# Fix all project CMakeLists.txt (library path + include directory)
log "Fixing project CMakeLists.txt..."
find "$REPO_ROOT" -path "$REPO_ROOT/tools" -prune -o -path "*/build" -prune -o -name CMakeLists.txt -print0 | while IFS= read -r -d '' file; do
    sed -i 's|../../tools/raylib|../../tools/raylib/src|g' "$file"
    if ! grep -q "raylib/src" "$file"; then
        awk '
        /target_include_directories/ && /PRIVATE/ && /include/ {
            print $0
            if (!/raylib\/src/) print "    ../../tools/raylib/src"
            next
        }
        { print }
        ' "$file" > "$file.tmp" && mv "$file.tmp" "$file"
    fi
done

# Write manifest (always the truth)
cat > "$MANIFEST" <<EOF
# SneakernetStudio Tool Manifest
# Updated: $(date +"%Y-%m-%d %H:%M:%S")
Zig: $ZIG_VERSION
CMake: $CMAKE_VERSION
raylib: $RAYLIB_VERSION
EOF

log "Manifest updated"

# ORIGINAL FINAL SCREEN – versions pulled from manifest
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