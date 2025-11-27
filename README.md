Sneakernet Studio — 1.0 “It Actually Works”
A completely offline, self-contained, portable C + raylib + Zig game-jam / code-art template.
Zero system dependencies. Zero boilerplate. Zero excuses.
Drop a PNG, drop a .c file, rebuild — it just works.
SneakernetStudio/
├── README.md
├── update-studio.sh          ← RUN THIS FIRST (installs Zig/CMake/raylib)
├── Templates/
│   └── HelloWorld/           ← copy this folder to spawn a new game
│       ├── main.c
│       ├── CMakeLists.txt
│       ├── build.sh / build.bat
│       ├── include/
│       │   ├── utils.h
│       │   ├── entity.h
│       │   └── bullet.h
│       └── src/
│           ├── utils.c       ← all utilities (text, lerp, dual shake)
│           ├── entity.c      ← red ball
│           └── bullet.c      ← VWSBrain.png with pixel-perfect alpha bounce
└── tools/                    ← created by update-studio.sh
First-Time Setup (once per machine or SD card)
./update-studio.sh
This downloads and installs Zig 0.14.0, CMake 4.2.0, and raylib 5.5 into tools/ — everything is now self-contained and offline-ready.
How to Spawn a New Game (30 seconds)
cd Projects
cp -r ../Templates/HelloWorld my_killer_game
cd my_killer_game
drop new .c files in src/
drop new .h files in include/
drop new PNGs in assets/textures/
./build.sh clean=yes        # first time or after big changes
./build/lin/my_killer_game  # run on Linux
or
build.bat                   # run on Windows
Current Features (100% working)

Pixel-perfect alpha collision (transparent parts don’t count)
Dual screen shake (camera) + window shake (OS window) on brain-wall hit
Multi-line perfectly centered text (no ghosting)
GLOB auto-includes every .c you drop in src/
All utils in one place (text centering, lerp, random, easing, dual shake)
No .zig-cache litter (cleaned on clean=yes)
No depfile linker errors
Full asset copy to build/lin/assets/ for perfect SD-card portability
Works on Linux (Hyprland/Arch) and Windows (chainload tested)

Build Script Cheat Sheet
./build.sh clean=yes        # nuclear clean + rebuild (default: lin)
./build.sh                  # normal rebuild (lin)
./build.sh win              # cross-compile Windows .exe
./build.sh arm clean=yes    # clean + ARM build
Want More?

Add new .c → src/
Add new .h → include/
Add new PNG → assets/textures/
Rebuild → it’s included automatically

No more “why isn’t my new file compiling?” ever again.
License
MIT — do whatever you want with it.
Made with blood, sweat, and one very patient Grok.
Now go make something that makes your monitor dance.
— vapor, 27 November 2025
(The day the brain finally bounced right) 🧠💥