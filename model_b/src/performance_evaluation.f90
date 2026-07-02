
!  ██████  ███████ ██████  ███████  ██████    ██████  ███    ███  █████  ███    ██  ██████ ███████ 
!  ██   ██ ██      ██   ██ ██      ██     ██  ██   ██ ████  ████ ██   ██ ████   ██ ██      ██      
!  ██████  █████   ██████  █████   ██     ██  ██████  ██ ████ ██ ███████ ██ ██  ██ ██      █████   
!  ██      ██      ██   ██ ██      ██     ██  ██   ██ ██  ██  ██ ██   ██ ██  ██ ██ ██      ██      
!  ██      ███████ ██   ██ ██       ██████    ██   ██ ██      ██ ██   ██ ██   ████  ██████ ███████ 
!
!  Submodule    : performance_sub
!  Purpose      : Implementation of performance monitoring procedures
!                 for the Cahn-Hilliard phase-field simulation.
!
!  Author       : Shahid Maqbool
!  Date         : 16 June 2026
!  Version      : 1.0.0
!  License      : MIT
!
!  Parent Module : performance_module
!
!  Dependencies :
!    iso_fortran_env  - Provides output_unit for standardized output
!    precision_module - Provides r_sp, r_dp, i_sp precision types
!    phase_field_mod  - Provides PhaseFieldGrid type
!    omp_lib          - OpenMP runtime library (conditional on USE_OPENMP)
!
!  Procedures Implemented :
!    init_performance()          - Initialize performance variables
!    start_timing()              - Start all timers
!    stop_timing()               - Stop all timers
!    calculate_performance_metrics() - Calculate all metrics
!    print_performance_report()  - Print formatted report
!    reset_performance()         - Reset all variables
!-------------------------------------------------------------------------------
submodule (performance_module) performance_sub
    !===========================================================================
    !  SUBMODULE DEPENDENCIES
    !===========================================================================
    !
    !  iso_fortran_env   : Provides output_unit for consistent formatted output
    !                      across all subroutines.
    !
    !  precision_module  : Provides precision types:
    !                      - r_sp  : single precision real (4 bytes)
    !                      - r_dp  : double precision real (8 bytes)
    !                      - i_sp  : single precision integer (4 bytes)
    !
    !  phase_field_mod   : Provides the PhaseFieldGrid type which contains:
    !                      - grid dimensions (Nx, Ny)
    !                      - concentration field (con)
    !                      - auxiliary arrays (r, dfdcon, lap_con, etc.)
    !
    !  omp_lib           : OpenMP runtime library providing:
    !                      - omp_get_wtime()      : wall-clock timer
    !                      - omp_get_max_threads(): max available threads
    !                      - omp_get_num_procs()  : available CPU cores
    !                      (Note: Only included when USE_OPENMP is defined)
    !
    !===========================================================================
    use precision_module
    use phase_field_module
    use utils_module
    use timer_module
#ifdef USE_OPENMP
    use omp_lib
#endif
    implicit none
contains
    !-----------------------------------------------------------------------------
    !  module procedure : init_performance
    !  Description      : Initialize performance variables and system information.
    !                     Detects OpenMP threads and CPU cores automatically.
    !
    !  Output           : Prints initialization banner with system info
    !-----------------------------------------------------------------------------
    module procedure init_performance
        implicit none
#ifdef USE_OPENMP
        num_threads = omp_get_max_threads()
        num_procs = omp_get_num_procs()
        is_parallel = .true.
#else
        num_threads = 1
        num_procs = 1
        is_parallel = .false.
#endif
        performance_initialized = .true.
        call reset_performance()
        
        print *, '  Performance Module Initialized'
        print '(A, I0)', '    Threads: ', num_threads
        print '(A, I0)', '    CPU Cores: ', num_procs
    end procedure init_performance
    !-----------------------------------------------------------------------------
    !  module procedure : calculate_performance_metrics
    !  Description      : Calculate all performance metrics from timing data:
    !                     - Update rate (updates/second)
    !                     - MLUPs (million updates/second)
    !                     - FLOPS (FLOPs/second)
    !                     - GFLOPS (giga-FLOPs/second)
    !                     - Memory usage (MB)
    !                     - Speedup (CPU/Wall)
    !                     - Efficiency (Speedup/Threads)
    !
    !  Arguments        :
    !    grid - PhaseFieldGrid object containing grid dimensions
    !
    !-----------------------------------------------------------------------------
    module procedure calculate_performance_metrics
        use omp_lib
        implicit none
        
        !real(r_dp) :: total_updates
        integer(i_dp) :: total_updates
        real(r_dp) :: wall_time
        real(r_sp) :: memory_mb
        
        ! Get elapsed times from timer_module
        cpu_elapsed = get_cpu_time()
        sys_clock_elapsed = get_system_clock_time()
        wall_time = get_wall_time()
!#ifdef USE_OPENMP        
        ! Debug output
        print *, 'DEBUG: calculate_performance_metrics'
        !print '(A, F12.6)', '  CPU Elapsed: ', cpu_elapsed
        !print '(A, F12.6)', '  Wall Time: ', wall_time
        !print '(A, F12.6)', '  System Clock: ', sys_clock_elapsed
!#endif        
        ! Total grid point updates
        total_updates = int(nsteps, i_dp) * int(nx, i_dp) * int(ny, i_dp)
 
        ! Calculate update rate
         if (wall_time > 1.0e-12_r_dp) then    
            update_rate = real(total_updates, r_dp) / wall_time
            mlups = update_rate / 1.0e6_r_dp
        else
            update_rate = 0.0_r_dp
            mlups = 0.0_r_dp
        end if
        
        ! Estimate FLOPS
        if (wall_time > 1.0e-12_r_dp) then    
            flops = update_rate * FLOPS_PER_UPDATE
            gflops = flops / 1.0e9_r_dp
        else
            flops = 0.0_r_dp
            gflops = 0.0_r_dp
        end if
        
        ! Calculate memory usage
        memory_mb = real(NUM_ARRAYS * grid%Nx * grid%Ny * BYTES_PER_ELEMENT, r_sp) / (1024.0_r_sp ** 2)
        memory_usage = memory_mb
        
        ! Calculate speedup
        if (wall_time > 1.0e-12_r_dp .and. cpu_elapsed > 0.0_r_dp) then    
            speedup = real(cpu_elapsed, r_dp) / wall_time
        else
            speedup = 0.0_r_dp
        end if
        
        ! Calculate efficiency
        if (num_threads > 0 .and. speedup > 0.0_r_dp) then
            efficiency = (speedup / real(num_threads, r_sp)) * 100.0_r_dp
        else
            efficiency = 0.0_r_dp
        end if
        
        ! Store grid information
        nx = grid%Nx
        ny = grid%Ny        
    end procedure calculate_performance_metrics
    !-----------------------------------------------------------------------------
    !  module procedure : print_performance_report
    !  Description      : Print a comprehensive, formatted performance report
    !                     including system configuration, timing results,
    !                     performance metrics, and analysis.
    !
    !  Output           : Formatted report to stdout
    !  Format           : Box-drawing characters for professional appearance
    !-----------------------------------------------------------------------------
    module procedure print_performance_report
        implicit none
        write(output_unit, '(A)') ''
#ifdef USE_OPENMP
        write(output_unit, '(A)') '  |=====================================================================|'
        write(output_unit, '(A)') '  |                    OPENMP PERFORMANCE REPORT                        |'
        write(output_unit, '(A)') '  |=====================================================================|'
#else
        write(output_unit, '(A)') '  |=====================================================================|'
        write(output_unit, '(A)') '  |                    SERIAL PERFORMANCE REPORT                        |'
        write(output_unit, '(A)') '  |=====================================================================|'       
        write(output_unit, '(A)') ''
#endif
        ! System Configuration
        write(output_unit, '(A)') '  System Configuration:'
        write(output_unit, '(A)') '  ===================================================================='
#ifdef USE_OPENMP
        write(output_unit, '(A, I0)') '    Available CPU cores : ', omp_get_num_procs()
        write(output_unit, '(A, I0)') '    OpenMP threads      : ', omp_get_max_threads()
#endif
        write(output_unit, '(A, I0, A, I0)') '    Grid size           : ', nx, ' x ', ny
        write(output_unit, '(A, I0)') '    Time steps          : ', nsteps
        write(output_unit, '(A, I15)') '    Total updates       : ', int(nsteps, i_dp) * int(nx, i_dp) * int(ny, i_dp)
!        write(output_unit, '(A, F0.2, A)') '    Memory usage        : ', memory_usage, ' MB'
        write(output_unit, '(A)') ''
        
        ! Timing Results
        write(output_unit, '(A)') '  Timing Results:'
        write(output_unit, '(A)') '  ====================================================================='
        write(output_unit, '(A, F12.3, A)') '    System Clock       : ', sys_clock_elapsed, ' seconds'        
#ifdef USE_OPENMP
        write(output_unit, '(A, F12.3, A)') '    Wall Time (elapsed): ', opm_wall_elapsed, ' seconds'        
!        write(output_unit, '(A, F12.3, A)') '    CPU Time (total)   : ', cpu_elapsed, ' seconds'
#endif        
        write(output_unit, '(A)') ''

! #ifdef USE_OPENMP        
        ! ! Performance Metrics
        ! write(output_unit, '(A)') '  Performance Metrics:'
        ! write(output_unit, '(A)') '  ====================================================================='
        ! write(output_unit, '(A, F8.2, A)') '    Speedup            : ', speedup, ' x'
        ! write(output_unit, '(A, F6.1, A)') '    Efficiency         : ', efficiency, ' %'
        ! write(output_unit, '(A, F12.2, A)') '    Updates/sec        : ', update_rate, ' updates/s'
        ! write(output_unit, '(A, F8.3, A)') '    MLUPs/sec          : ', mlups, ' million updates/s'
        ! write(output_unit, '(A, F8.3, A)') '    Estimated GFLOPS   : ', gflops, ' GFLOPS/s'
        ! write(output_unit, '(A)') ''        
        ! write(output_unit, '(A)') '  ====================================================================='
        ! write(output_unit, '(A)') ''
! #endif         
        !=========================================================================
        !  Phase 1 : Parallel Efficiency Assessment
        !  Description : Evaluate how effectively the available computational 
        !                resources are utilized. Efficiency measures the fraction
        !                of theoretical peak performance achieved.
        !
        !  Metrics :
        !    > 80%  : Excellent - Near-ideal scaling with minimal overhead
        !    50-80% : Good - Acceptable performance with some parallel overhead
        !    < 50%  : Poor - Significant performance bottlenecks detected
        !
        !  Common Causes of Inefficiency :
        !    - Load imbalance across threads
        !    - Excessive synchronization (critical/atomic sections)
        !    - False sharing in cache lines
        !    - Too many threads for problem size
        !    - Memory bandwidth saturation
        !=========================================================================
! #ifdef USE_OPENMP
        ! write(output_unit, '(A)') '  Performance Analysis:'
        ! write(output_unit, '(A)') '  --------------------------------------------------------------------'
! #else
        ! write(output_unit, '(A)') '  It is a Serial Code, For performance use OpenMP:'
        ! write(output_unit, '(A)') '  --------------------------------------------------------------------' 
! #endif        
        ! ! Efficiency Analysis
! #ifdef USE_OPENMP        
        ! if (efficiency > EFFICIENCY_EXCELLENT) then
            ! write(output_unit, '(A)') '     EXCELLENT efficiency! The code scales very well.'
            ! write(output_unit, '(A)') '      - Speedup is close to ideal'
            ! write(output_unit, '(A)') '      - Minimal parallel overhead'
            ! write(output_unit, '(A)') '      - Good load balancing'
        ! else if (efficiency > EFFICIENCY_GOOD) then
            ! write(output_unit, '(A)') '     GOOD efficiency. Consider optimizing for better scaling.'
            ! write(output_unit, '(A)') '      - Some parallel overhead detected'        
           ! write(output_unit, '(A)') '      - Check for load imbalance'
            ! write(output_unit, '(A)') '      - Consider larger problem size'
        ! else
            ! write(output_unit, '(A)') '     LOW efficiency. Optimization needed:'
            ! if (nx * ny < PROBLEM_SIZE_MEDIUM) then
                ! write(output_unit, '(A)') '      - Increase grid size (problem is too small)'
            ! end if
            ! write(output_unit, '(A)') '      - Reduce number of threads'
            ! write(output_unit, '(A)') '      - Check for load imbalance'
            ! write(output_unit, '(A)') '      - Reduce synchronization overhead'
        ! end if
        ! write(output_unit, '(A)') ''       
        !=========================================================================
        !  Phase 2 : Problem Size Analysis
        !  Description : Assess whether the computational domain is appropriately
        !                sized for the available parallel resources. The ratio of
        !                computation to communication (parallel overhead) is
        !                critical for strong scaling.
        !
        !  Guidelines :
        !    > 100,000 points : Large - Ideal for parallel scaling
        !    10,000-100,000   : Medium - Suitable for testing
        !    < 10,000 points  : Small - Communication overhead dominates
        !
        !  Recommendations :
        !    - For small problems: Use fewer threads or increase grid size
        !    - For large problems: Optimize memory access patterns
        !    - Consider weak scaling for production runs
        !=========================================================================
        ! if (nx * ny < PROBLEM_SIZE_SMALL) then
            ! write(output_unit, '(A)') '     Problem size is very small.'
            ! write(output_unit, '(A)') '      OpenMP overhead may dominate.'
            ! write(output_unit, '(A)') '      Consider increasing grid size for better parallel performance.'
        ! else if (nx * ny < PROBLEM_SIZE_MEDIUM) then
            ! write(output_unit, '(A)') '     Problem size is moderate.'
            ! write(output_unit, '(A)') '      Good for testing, but larger grids will scale better.'
        ! else
            ! write(output_unit, '(A)') '     Problem size is large.'
            ! write(output_unit, '(A)') '      Excellent for parallel scaling.'
        ! end if
        ! write(output_unit, '(A)') ''        
        !=========================================================================
        !  Phase 3 : Speedup Analysis
        !  Description : Evaluate the parallel speedup relative to the serial
        !                execution. Speedup = CPU_Time / Wall_Time.
        !                Ideal speedup equals the number of threads.
        !
        !  Assessment Criteria :
        !    > 0.8 x Threads  : Excellent - Near-linear scaling
        !    0.5-0.8 x Threads: Good - Acceptable scaling
        !    < 0.5 x Threads  : Poor - Scaling bottlenecks exist
        !
        !=========================================================================
        ! if (speedup < 1.0_r_dp .and. speedup > 0.0_r_dp) then
            ! write(output_unit, '(A)') '     Speedup < 1.0. Parallel version is slower than serial!'
            ! write(output_unit, '(A)') '      This usually means:'
            ! write(output_unit, '(A)') '        - Problem size is too small'
            ! write(output_unit, '(A)') '        - Too many threads for the problem'
            ! write(output_unit, '(A)') '        - Excessive synchronization'
        ! else if (speedup < real(num_threads, r_sp) * 0.5_r_dp .and. num_threads > 1) then
            ! write(output_unit, '(A)') '     Speedup is less than 50% of ideal.'
            ! write(output_unit, '(A)') '      Consider increasing problem size or optimizing.'
        ! else if (speedup > real(num_threads, r_sp) * 0.8_r_dp) then
            ! write(output_unit, '(A)') '     Excellent speedup! Near ideal scaling achieved.'
        ! end if        
        ! write(output_unit, '(A)') '  --------------------------------------------------------------------'
        ! write(output_unit, '(A)') ''
! #endif        
    end procedure print_performance_report
    !-----------------------------------------------------------------------------
    !  module procedure : reset_performance
    !  Description      : Reset all performance variables to their initial values.
    !                     Useful for re-running simulations or clearing state.
    !
    !  Postcondition   : All timing and metric variables are set to zero
    !-----------------------------------------------------------------------------
    module procedure reset_performance
        implicit none
        update_rate = 0.0_r_dp
        mlups = 0.0_r_dp
        flops = 0.0_r_dp
        gflops = 0.0_r_dp
        memory_usage = 0.0_r_dp
        speedup = 0.0_r_dp
        efficiency = 0.0_r_dp
    end procedure reset_performance

end submodule performance_sub