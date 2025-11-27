@echo off
setlocal enabledelayedexpansion
set PROJECT_ROOT=%CD%
set TOOLS_DIR=..\..\tools
set BUILD_DIR=build
set CLEAN=%1
if "%CLEAN%"=="yes" rmdir /s /q %BUILD_DIR%
if not exist %BUILD_DIR% mkdir %BUILD_DIR%
cd %BUILD_DIR%
set TOOLCHAIN=-DCMAKE_TOOLCHAIN_FILE=%TOOLS_DIR%\Toolchain_Zig.cmake
%TOOLS_DIR%\cmake\bin\cmake.exe %PROJECT_ROOT% %TOOLCHAIN%
%TOOLS_DIR%\cmake\bin\cmake.exe --build . --parallel %NUMBER_OF_PROCESSORS%
echo Build complete: %BUILD_DIR%\HelloWorld.exe
