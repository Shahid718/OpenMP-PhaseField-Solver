!|==================================================================|'
!|                                                                  |'
!|                    ---    ---    ---                             |'
!|                   |   |  |   |  |   |                            |'
!|                   |   |  |   |  |   |                            |'
!|                    ---    ---    ---                             |'
!|                    ---    ---    ---                             |'
!|                   |   |  |   |  |   |                            |'
!|                   |   |  |   |  |   |                            |'
!|                    ---    ---    ---                             |'
!|                                                                  |'
!|             Cahn-Hilliard Phase-Field Simulation Suite           |'
!|                     High-Performance Computing                   |'
!|                                                                  |'
!|            Version 1.0.0   |   Author: Shahid Maqbool            |'
!|       Date: 16 June 2026   |   License: MIT                      |'
!|                                                                  |'
!|                                                                  |'
!|==================================================================|'
!
!
!   Module      : Main Driver
!   Purpose     : Time integration of Cahn-Hilliard equation using
!                 finite difference method with OpenMP parallelism
!
!   Author      : Shahid Maqbool
!   Date        : 16 June 2026
!   Version     : 1.0.0
!   License     : MIT
!
!   Performance : Optimized for shared-memory architectures
!   Memory      : Dynamic allocation with status checking
!   Precision   : Single-precision (r_sp) for all floating-point operations
!   i/O         : parallel output format for performance
!
!   COMPILATION:
!                 Check ReadMe
!-------------------------------------------------------------------------------

program cahn_hilliard_driver
    !===========================================================================
    ! Module usage 
    !===========================================================================
    use, intrinsic :: iso_fortran_env
    use precision_module
    use timer_module
    use utils_module 
    use phase_field_module
    use performance_module
#if USE_OPENMP
    use omp_lib
#endif
    implicit none
    !===========================================================================
    ! Variable declarations with descriptive names
    !===========================================================================
    
    type(PhaseFieldGrid) :: grid            ! Grid object (core simulation data structure)
#if USE_OPENMP    
    num_threads = omp_get_max_threads()     ! Max threads available 
#endif    
    
    !===========================================================================
    ! Code entry point - Display application banner
    !===========================================================================
    
    call display_banner()
    call print_section('INITIALIZATION')
    
    !===========================================================================
    ! Phase 1: Runtime configuration
    !===========================================================================
    
    call print_section('RUNTIME CONFIGURATION')
    call report_runtime_configuration ()
	
    !===========================================================================
    !  Phase 2: Grid Setup
    !===========================================================================

    call print_section('GRID SETUP')
    call grid%create_grid_interactive()
    
    ! Initialize microstructure
    call print_section('MICROSTRUCTURE INITIALIZATION')
    call grid%init_microstructure(c0=0.4_r_sp, noise=0.02_r_sp)
    call print_success('Initial microstructure generated')
    
    !===========================================================================
    ! Phase 3: Simulation execution
    !===========================================================================
    
    call print_simulation_header()
    
    !===========================================================================
    ! Phase 4: Time integration (main computational kernel)
    !===========================================================================
    
    call report_timer('start')
    
    ! Display progress header
    write(output_unit, '(A)') ''
    write(output_unit, '(A)') '  Progress:'
    write(output_unit, '(A)') ''
    
    time_loop: do tstep = 1, nsteps
        ! =====================================================================
        ! Phase-field kernel - computational intensive part
        ! =====================================================================
        call grid%free_energy_derivative(A=1.0_r_sp)
        call grid%laplace_evaluation()
        call grid%time_integration(dt=0.01_r_sp, mobility=1.0_r_sp, grad_coef=0.5_r_sp)
        !=========================================================================
        !  Progress Reporting
        !=========================================================================
        if (mod(tstep, print_interval) == 0) then
            ! Update progress bar
            call progress_bar(tstep, nsteps, width=50, prefix='   Progress')
            
            ! Print timing info every 10% progress
            if (mod(tstep, nsteps/100) == 0 .or. tstep == nsteps) then
                ! Get current elapsed time
                sys_clock_elapsed = get_system_clock_time()
                write(output_unit, '(A, F8.2, A)') '  [', sys_clock_elapsed, 's elapsed]'
            end if
        end if
    end do time_loop
    
    ! Finalize progress bar
    call progress_bar(nsteps, nsteps, width=10, prefix='   Progress')
    write(output_unit, '(A)') ''
    
    !=========================================================================
    !  Phase 5: Stop Timers and Report
    !=========================================================================
    
    call report_timer('stop')
    call report_timer('report')
    
    !=========================================================================
    !  Phase 6: Write Output
    !=========================================================================
		
    call print_section('WRITING OUTPUT')
    call grid%output_results(filename='ch.dat')
    
    !=========================================================================
    !  Phase 7: Performance Metrics
    !=========================================================================
    
    call print_section('PERFORMANCE ANALYSIS')
    
    ! Calculate performance metrics using timer data
    call calculate_performance_metrics(grid)
    call print_performance_report()
    
    !=========================================================================
    !  Phase 8: Simulation Completion
    !=========================================================================
    
    call print_simulation_footer(sys_clock_elapsed)
    !call display_completion_banner ()
    
end program cahn_hilliard_driver