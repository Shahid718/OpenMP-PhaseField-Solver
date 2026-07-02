#!/bin/bash
#-------------------------------------------------------------------------------
# build_linux.sh - Build script for Linux/Mac
#-------------------------------------------------------------------------------

# Move to project root automatically
PROJECT_ROOT="$( cd "$( dirname "$0" )/.." && pwd )"
cd "$PROJECT_ROOT"

echo "================================================================================"
echo "  CAHN-HILLIARD PHASE-FIELD SIMULATION - BUILD SCRIPT"
echo "================================================================================"


# Clean previous build
if [ -d "build" ]; then
    echo "Removing previous build directory..."
    rm -rf build
fi

# Create build directory
mkdir build
cd build

# Configure with CMake
echo ""
echo "Configuring with CMake..."
echo "================================================================================"

cmake .. \
    -DCMAKE_Fortran_COMPILER=gfortran \
    -DCMAKE_BUILD_TYPE=Release \
    -DWITH_OPENMP=ON \
    -DUSE_OPENMP_MACRO=ON

# Check if CMake succeeded
if [ $? -ne 0 ]; then
    echo ""
    echo "ERROR: CMake configuration failed!"
    exit 1
fi

# Build
echo ""
echo "Building the project..."
echo "================================================================================"

make -j$(nproc)

# Check if build succeeded
if [ $? -ne 0 ]; then
    echo ""
    echo "ERROR: Build failed!"
    exit 1
fi

echo ""
echo "================================================================================"
echo "  BUILD SUCCESSFUL"
echo "================================================================================"
echo "  Executable: ./build/bin/cahn_hilliard_driver"
echo ""
echo "  To run:"
echo "    cd .. "
echo "    cd build/bin"
echo "    ./cahn_hilliard_driver"
echo ""
echo "  To set number of OpenMP threads:"
echo "    export OMP_NUM_THREADS=8"
echo "    ./cahn_hilliard_driver"
echo "================================================================================"