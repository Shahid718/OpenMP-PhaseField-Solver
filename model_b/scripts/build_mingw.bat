@echo off
REM build_MinGW.bat - Build script for Windows (MinGW)

REM Move to project root automatically
cd /d "%~dp0.."

echo ================================================================================
echo   CAHN-HILLIARD PHASE-FIELD SIMULATION - BUILD SCRIPT
echo ================================================================================

REM Clean previous build
if exist build (
    echo Removing previous build directory...
    rmdir /s /q build
)

REM Create build directory
mkdir build
cd /d build

echo.
echo Configuring with CMake...
echo ================================================================================

cmake .. -G "MinGW Makefiles" ^
 -DCMAKE_Fortran_COMPILER=gfortran ^
 -DCMAKE_BUILD_TYPE=Release ^
 -DWITH_OPENMP=ON ^
 -DUSE_OPENMP_MACRO=ON

if errorlevel 1 (
    echo.
    echo ERROR: CMake configuration failed!
    exit /b 1
)

echo.
echo Building the project...
echo ================================================================================

mingw32-make -j%NUMBER_OF_PROCESSORS%

if errorlevel 1 (
    echo.
    echo ERROR: Build failed!
    exit /b 1
)

echo.
echo ================================================================================
echo BUILD SUCCESSFUL
echo ================================================================================