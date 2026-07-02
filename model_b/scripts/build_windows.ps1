# build_windows.ps1
# ./build_windows.ps1

Write-Host "================================================================================" -ForegroundColor Cyan
Write-Host "  CAHN-HILLIARD PHASE-FIELD SIMULATION - Windows Build" -ForegroundColor Cyan
Write-Host "================================================================================" -ForegroundColor Cyan


# Get project root (one level above scripts/)
$ProjectRoot = Split-Path $PSScriptRoot -Parent
Set-Location $ProjectRoot

# Check for MinGW
$mingw_make = (Get-Command mingw32-make -ErrorAction SilentlyContinue)
if (-not $mingw_make) {
    Write-Host "WARNING: mingw32-make not found in PATH!" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Options:" -ForegroundColor White
    Write-Host "  1. Install MSYS2 from https://www.msys2.org/" -ForegroundColor White
    Write-Host "  2. Install MinGW from https://sourceforge.net/projects/mingw-w64/" -ForegroundColor White
    Write-Host "  3. Use Visual Studio generator instead" -ForegroundColor White
    Write-Host ""
    Write-Host "Press Enter to continue with Ninja, or Ctrl+C to cancel..." -ForegroundColor Yellow
    Read-Host
}

# Try Ninja if MinGW not found
if (-not $mingw_make) {
    $generator = "Ninja"
    $build_cmd = "ninja -j8"
} else {
    $generator = "MinGW Makefiles"
    $build_cmd = "mingw32-make -j${env:NUMBER_OF_PROCESSORS}"
}

# Clean previous build
if (Test-Path build) {
    Write-Host "Removing previous build directory..."
    Remove-Item -Recurse -Force build
}

# Create build directory
New-Item -ItemType Directory -Path build | Out-Null
Set-Location build

# Configure with CMake
Write-Host ""
Write-Host "Configuring with CMake..." -ForegroundColor Yellow
Write-Host "Generator: $generator" -ForegroundColor Yellow
Write-Host "================================================================================" -ForegroundColor Yellow

cmake .. -G "$generator" -DCMAKE_Fortran_COMPILER=gfortran -DCMAKE_BUILD_TYPE=Release -DWITH_OPENMP=ON

if ($LASTEXITCODE -ne 0) {
    Write-Host ""
    Write-Host "ERROR: CMake configuration failed!" -ForegroundColor Red
    Write-Host ""
    Write-Host "Try specifying the compiler explicitly:" -ForegroundColor Yellow
    Write-Host "  cmake .. -G ""MinGW Makefiles"" -DCMAKE_MAKE_PROGRAM=""C:\msys64\ucrt64\bin\mingw32-make.exe"" -DCMAKE_Fortran_COMPILER=""C:\msys64\ucrt64\bin\gfortran.exe""" -ForegroundColor White
    exit 1
}

# Build
Write-Host ""
Write-Host "Building the project..." -ForegroundColor Yellow
Write-Host "================================================================================" -ForegroundColor Yellow

Invoke-Expression $build_cmd

if ($LASTEXITCODE -ne 0) {
    Write-Host ""
    Write-Host "ERROR: Build failed!" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "================================================================================" -ForegroundColor Green
Write-Host "  BUILD SUCCESSFUL" -ForegroundColor Green
Write-Host "================================================================================" -ForegroundColor Green
Write-Host "  Executable: build\bin\cahn_hilliard_driver.exe" -ForegroundColor White
Write-Host ""
Write-Host "  To run:" -ForegroundColor White
Write-Host "    cd bin" -ForegroundColor White
Write-Host "    ./cahn_hilliard_driver" -ForegroundColor White
Write-Host "================================================================================" -ForegroundColor Green