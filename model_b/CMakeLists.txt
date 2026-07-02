#-------------------------------------------------------------------------------
# CMake Configuration for HPC Fortran Project
# Multi-Compiler Support (GNU + Intel oneAPI ifx)
#-------------------------------------------------------------------------------

cmake_minimum_required(VERSION 3.18)

project(CahnHilliard
    VERSION 1.0.0
    LANGUAGES Fortran
    DESCRIPTION "Parallel Phase Field Simulation Framework"
)

#-------------------------------------------------------------------------------
# Build Options
#-------------------------------------------------------------------------------

option(WITH_OPENMP "Enable OpenMP parallelization" ON)

set(CMAKE_BUILD_TYPE Release CACHE STRING
    "Build type: Debug, Release, RelWithDebInfo"
)

#-------------------------------------------------------------------------------
# Compiler Detection
#-------------------------------------------------------------------------------

message(STATUS "Detected compiler: ${CMAKE_Fortran_COMPILER_ID}")

if(CMAKE_Fortran_COMPILER_ID MATCHES "GNU")

    message(STATUS "Using GNU Fortran")

    set(BASE_FLAGS
        "-cpp -ffree-line-length-none -Wall -Wextra -Wimplicit-interface"
    )

    set(RELEASE_FLAGS
        "-O3 -march=native -funroll-loops -ftree-vectorize -fstack-arrays"
    )

    set(DEBUG_FLAGS
        "-O0 -g -fbacktrace -fbounds-check -fcheck=all"
    )

elseif(CMAKE_Fortran_COMPILER_ID MATCHES "IntelLLVM")

    message(STATUS "Using Intel oneAPI ifx")

    # Windows + Linux compatible Intel flags
    if(WIN32)

        set(BASE_FLAGS
            "/fpp"
        )

        set(RELEASE_FLAGS
            "/O3 /QxHost"
        )

        set(DEBUG_FLAGS
            "/Od /debug:full /traceback"
        )

    else()

        set(BASE_FLAGS
            "-fpp"
        )

        set(RELEASE_FLAGS
            "-O3 -xHost"
        )

        set(DEBUG_FLAGS
            "-O0 -g -traceback"
        )

    endif()

else()

    message(FATAL_ERROR
        "Unsupported compiler: ${CMAKE_Fortran_COMPILER_ID}"
    )

endif()

#-------------------------------------------------------------------------------
# Build Type Flags
#-------------------------------------------------------------------------------

if(CMAKE_BUILD_TYPE STREQUAL "Debug")

    set(CMAKE_Fortran_FLAGS
        "${BASE_FLAGS} ${DEBUG_FLAGS}"
    )

    message(STATUS "Build Type: DEBUG")

else()

    set(CMAKE_Fortran_FLAGS
        "${BASE_FLAGS} ${RELEASE_FLAGS}"
    )

    message(STATUS "Build Type: RELEASE")

endif()

#-------------------------------------------------------------------------------
# OpenMP Support
#-------------------------------------------------------------------------------

if(WITH_OPENMP)

    find_package(OpenMP REQUIRED)

endif()

#-------------------------------------------------------------------------------
# Source Directories
#-------------------------------------------------------------------------------

set(SRC_DIR "${CMAKE_SOURCE_DIR}/src")
set(APP_DIR "${CMAKE_SOURCE_DIR}/app")

#-------------------------------------------------------------------------------
# Source Files
#-------------------------------------------------------------------------------

set(MODULE_SOURCES
    ${SRC_DIR}/precisions_control.f90
    ${SRC_DIR}/error_handler.f90
    ${SRC_DIR}/performance_timer.f90
    ${SRC_DIR}/core_utilities.f90
    ${SRC_DIR}/phase_field_solver.f90
    ${SRC_DIR}/phase_field_setup.f90
    ${SRC_DIR}/grid_generator.f90
    ${SRC_DIR}/microstructure_initializer.f90
    ${SRC_DIR}/free_energy_kernel.f90
    ${SRC_DIR}/laplacian_kernel.f90
    ${SRC_DIR}/time_kernel.f90
    ${SRC_DIR}/io_handlers.f90
    ${SRC_DIR}/performance_analyzer.f90
    ${SRC_DIR}/performance_evaluation.f90
)

set(MAIN_SOURCES
    ${APP_DIR}/main_driver.f90
)

#-------------------------------------------------------------------------------
# Executable
#-------------------------------------------------------------------------------

add_executable(
    cahn_hilliard_driver
    ${MAIN_SOURCES}
    ${MODULE_SOURCES}
)

#-------------------------------------------------------------------------------
# Module Directory
#-------------------------------------------------------------------------------

set_target_properties(cahn_hilliard_driver PROPERTIES

    Fortran_MODULE_DIRECTORY
        ${CMAKE_BINARY_DIR}/modules

    RUNTIME_OUTPUT_DIRECTORY
        ${CMAKE_BINARY_DIR}/bin
)

#-------------------------------------------------------------------------------
# OpenMP Linking
#-------------------------------------------------------------------------------

if(WITH_OPENMP)

    target_link_libraries(
        cahn_hilliard_driver
        OpenMP::OpenMP_Fortran
    )

    target_compile_definitions(
        cahn_hilliard_driver
        PRIVATE USE_OPENMP
    )

endif()

#-------------------------------------------------------------------------------
# Summary
#-------------------------------------------------------------------------------

message(STATUS "")
message(STATUS "======================================================")
message(STATUS " Project      : ${PROJECT_NAME}")
message(STATUS " Compiler     : ${CMAKE_Fortran_COMPILER_ID}")
message(STATUS " Build Type   : ${CMAKE_BUILD_TYPE}")
message(STATUS " OpenMP       : ${WITH_OPENMP}")
message(STATUS "======================================================")
message(STATUS "")
