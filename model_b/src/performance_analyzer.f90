! !-------------------------------------------------------------------------------
! !  ██████  ███████ ██████  ███████  ██████    ██████  ███    ███  █████  ███    ██  ██████ ███████ 
! !  ██   ██ ██      ██   ██ ██      ██     ██  ██   ██ ████  ████ ██   ██ ████   ██ ██      ██      
! !  ██████  █████   ██████  █████   ██     ██  ██████  ██ ████ ██ ███████ ██ ██  ██ ██      █████   
! !  ██      ██      ██   ██ ██      ██     ██  ██   ██ ██  ██  ██ ██   ██ ██  ██ ██ ██      ██      
! !  ██      ███████ ██   ██ ██       ██████    ██   ██ ██      ██ ██   ██ ██   ████  ██████ ███████ 
! !
! !  Module       : performance_module
! !  Purpose      : Performance monitoring, timing, and metrics collection
! !                 for the Cahn-Hilliard phase-field simulation code.
! !
! !  Author       : Shahid Maqbool
! !  Date         : 16 June 2026
! !  Version      : 1.0.0
! !  License      : MIT
! !
! !  Features     :
! !     CPU_TIME (serial timer - total CPU across all threads)
! !     OMP_GET_WTIME (parallel wall-clock timer - real elapsed time)
! !     SYSTEM_CLOCK (portable backup wall timer)
! !     Performance metrics: update rate, MLUPs, FLOPS, memory usage
! !     Speedup and efficiency calculations
! !     Automatic OpenMP thread detection
! !
! !  Usage        : use performance_module
! !                 call init_performance()
! !                 call print_performance_report()
! !
! !  Dependencies :
! !    precision_module  - Provides r_sp, r_dp, i_sp precision types
! !    phase_field_mod   - Provides PhaseFieldGrid type for grid information
! !    utils_module      - Provides output_unit for formatted output
! !    omp_lib           - OpenMP runtime library (conditional)
! !-------------------------------------------------------------------------------
module performance_module
    use precision_module
    use phase_field_module
    use utils_module
    use timer_module
#ifdef USE_OPENMP
    use omp_lib
#endif
    implicit none
    !-----------------------------------------------------------------------------
    !  Module Constants
    !----------------------------------------------------------------------------- 
    ! FLOPs per grid point update
    real(r_sp), parameter :: FLOPS_PER_UPDATE = 50.0_r_sp
    integer(i_sp), parameter :: NUM_ARRAYS = 6
    integer(i_sp), parameter :: BYTES_PER_ELEMENT = 4

    ! Performance thresholds
    real(r_sp), parameter :: EFFICIENCY_EXCELLENT = 80.0_r_sp
    real(r_sp), parameter :: EFFICIENCY_GOOD = 50.0_r_sp
    integer(i_sp), parameter :: PROBLEM_SIZE_SMALL = 10000
    integer(i_sp), parameter :: PROBLEM_SIZE_MEDIUM = 100000
    !===========================================================================
    !  PUBLIC VARIABLES
    !===========================================================================
    ! Grid and Simulation Control Parameters
    integer(i_sp), public :: nx = 500_i_sp
    integer(i_sp), public :: ny = 500_i_sp
    integer(i_sp), public :: nsteps = 2000_i_sp
    integer(i_sp), public :: print_interval = 100
    integer(i_sp), public :: tstep = 0                    ! Current time step counter

    ! Performance Metrics (calculated from timer module data)
    real(r_dp), public :: update_rate = 0.0_r_dp
    real(r_dp), public :: mlups = 0.0_r_dp
    real(r_dp), public :: flops = 0.0_r_dp
    real(r_dp), public :: gflops = 0.0_r_dp
    real(r_dp), public :: memory_usage = 0.0_r_dp
    real(r_dp), public :: speedup = 0.0_r_dp
    real(r_dp), public :: efficiency = 0.0_r_dp
    
    ! System Information
    integer(i_sp), public :: num_threads = 1
    integer(i_sp), public :: num_procs = 1
    
    ! Status Flags
    logical, public :: is_parallel = .false.
    logical, public :: performance_initialized = .false.
    !===========================================================================
    !  INTERFACE BLOCKS
    !===========================================================================
    interface
        module subroutine init_performance()
        end subroutine init_performance
        
        module subroutine calculate_performance_metrics(grid)
            type(PhaseFieldGrid), intent(in) :: grid
        end subroutine calculate_performance_metrics
        
        module subroutine print_performance_report()
        end subroutine print_performance_report
        
        module subroutine reset_performance()
        end subroutine reset_performance
    end interface
    
end module performance_module