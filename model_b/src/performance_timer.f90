!-------------------------------------------------------------------------------
!  ████████ ██ ███    ███ ███████ ██████  
!     ██    ██ ████  ████ ██      ██   ██ 
!     ██    ██ ██ ████ ██ █████   ██████  
!     ██    ██ ██  ██  ██ ██      ██   ██ 
!     ██    ██ ██      ██ ███████ ██   ██ 
!
!  Module       : timer_module
!  Purpose      : Unified timer interface for CPU_TIME, SYSTEM_CLOCK,
!                 and OMP_GET_WTIME with simple start/stop calls.
!
!  Author       : Shahid Maqbool
!  Date         : 16 June 2026
!  Version      : 1.0.0
!  License      : MIT
!
!-------------------------------------------------------------------------------
module timer_module
    use, intrinsic :: iso_fortran_env, only : output_unit
    use precision_module
#ifdef USE_OPENMP
    use omp_lib
#endif
    implicit none
    !-----------------------------------------------------------------------------
    !  Module Constants
    !-----------------------------------------------------------------------------   
    ! Timer status codes
    integer, parameter, public :: TIMER_NOT_STARTED = 0
    integer, parameter, public :: TIMER_RUNNING     = 1
    integer, parameter, public :: TIMER_STOPPED     = 2
    
    !-----------------------------------------------------------------------------
    !  Timer Variables (PUBLIC for access by other modules)
    !-----------------------------------------------------------------------------
    
    ! CPU_TIME variables
    real(r_dp), public :: cpu_start = 0.0_r_dp
    real(r_dp), public :: cpu_finish = 0.0_r_dp
    real(r_dp), public :: cpu_elapsed = 0.0_r_dp
    
    ! SYSTEM_CLOCK variables
    integer, public :: sys_clock_start = 0
    integer, public :: sys_clock_finish = 0
    integer, public :: sys_clock_rate = 0
    real(r_dp), public :: sys_clock_elapsed = 0.0_r_dp
    
    ! OMP_GET_WTIME variables
    real(r_dp), public :: opm_wall_start = 0.0_r_dp
    real(r_dp), public :: opm_wall_finish = 0.0_r_dp
    real(r_dp), public :: opm_wall_elapsed = 0.0_r_dp
    ! Timer status
    integer, public :: timer_status = TIMER_NOT_STARTED
    !-----------------------------------------------------------------------------
    !  Public Interface
    !-----------------------------------------------------------------------------
    public :: timer_start, timer_stop, timer_report, timer_reset
    public :: get_cpu_time, get_wall_time, get_system_clock_time
contains
    !-----------------------------------------------------------------------------
    !  subroutine : report_timer
    !  Description : Unified timer interface with simple commands
    !
    !  Arguments   :
    !    command - 'start', 'stop', 'report', 'reset' (intent: in)
    !
    !  Usage      :
    !    call report_timer('start')   ! Start timing
    !    call report_timer('stop')    ! Stop timing
    !    call report_timer('report')  ! Print report
    !    call report_timer('reset')   ! Reset timers
    !-----------------------------------------------------------------------------
    subroutine report_timer(command)
        character(len=*), intent(in) :: command
        
        select case(trim(adjustl(command)))
        case('start', 'START', 'Start')
            call timer_start()
            
        case('stop', 'STOP', 'Stop')
            call timer_stop()
            
        case('report', 'REPORT', 'Report')
            call timer_report()
            
        case('reset', 'RESET', 'Reset')
            call timer_reset()
            
        case default
            write(output_unit, '(A)') '   WARNING: Unknown timer command: ' // trim(command)
            write(output_unit, '(A)') '  Available commands: start, stop, report, reset'
            
        end select
        
    end subroutine report_timer
    !-----------------------------------------------------------------------------
    !  subroutine : timer_start
    !  Description : Start all three timers simultaneously
    !-----------------------------------------------------------------------------
    subroutine timer_start()
        implicit none        
        call cpu_time(cpu_start)
        call system_clock(sys_clock_start, sys_clock_rate)
#ifdef USE_OPENMP
        opm_wall_start = omp_get_wtime()
#endif        
        timer_status = TIMER_RUNNING
        write(output_unit, '(A)') '  Timer started...'
    end subroutine timer_start
    !-----------------------------------------------------------------------------
    !  subroutine : timer_stop
    !  Description : Stop all three timers and calculate elapsed times
    !-----------------------------------------------------------------------------
    subroutine timer_stop()
        implicit none
        
        if (timer_status == TIMER_NOT_STARTED) then
            write(output_unit, '(A)') '  ## WARNING: Timer not started. Call timer(''start'') first.'
            return
        end if
        
        call cpu_time(cpu_finish)
        cpu_elapsed = cpu_finish - cpu_start
        
        call system_clock(sys_clock_finish)
        sys_clock_elapsed = real(sys_clock_finish - sys_clock_start, r_dp) / real(sys_clock_rate, r_dp)
        
#ifdef USE_OPENMP
        opm_wall_finish = omp_get_wtime()
        opm_wall_elapsed = opm_wall_finish - opm_wall_start
#else
        opm_wall_elapsed = sys_clock_elapsed
#endif
        timer_status = TIMER_STOPPED
        write(output_unit, '(A)') '    Timer stopped...'        
    end subroutine timer_stop
    !-----------------------------------------------------------------------------
    !  subroutine : timer_report
    !  Description : Print a formatted timing report
    !-----------------------------------------------------------------------------
    subroutine timer_report()
        implicit none
        
        if (timer_status == TIMER_NOT_STARTED) then
            write(output_unit, '(A)') '   WARNING: Timer not started. No data to report.'
            return
        end if
        
        write(output_unit, '(A)') ''
        write(output_unit, '(A)') '  |======================================================================|'
        write(output_unit, '(A)') '  |                         TIMING REPORT                                |'
        write(output_unit, '(A)') '  |======================================================================|'
        write(output_unit, '(A)') ''
        
        write(output_unit, '(A)') '  Timing Results:'
        write(output_unit, '(A)') '  ======================================================================='
        write(output_unit, '(A, F12.3, A)') '    SYSTEM_CLOCK  : ', sys_clock_elapsed, ' seconds'
#ifdef USE_OPENMP  
     !   write(output_unit, '(A, F12.3, A)') '    CPU_TIME      : ', cpu_elapsed, ' seconds'      
        write(output_unit, '(A, F12.3, A)') '    OMP_GET_WTIME : ', opm_wall_elapsed, ' seconds'
#endif        
        write(output_unit, '(A)') ''
        
        ! Show which timer is being used
#ifdef USE_OPENMP
        write(output_unit, '(A)') '    Primary timer : OMP_GET_WTIME (parallel)'
#else
        write(output_unit, '(A)') '    Primary timer : SYSTEM_CLOCK  (serial)'
#endif
        
        write(output_unit, '(A)') '  ========================================================================'
        write(output_unit, '(A)') ''
        
    end subroutine timer_report

    !-----------------------------------------------------------------------------
    !  subroutine : timer_reset
    !  Description : Reset all timer variables to zero
    !-----------------------------------------------------------------------------
    subroutine timer_reset()
        implicit none
        
        cpu_start = 0.0_r_dp
        cpu_finish = 0.0_r_dp
        cpu_elapsed = 0.0_r_dp
        
        sys_clock_start = 0
        sys_clock_finish = 0
        sys_clock_rate = 0
        sys_clock_elapsed = 0.0_r_dp
        
        opm_wall_start = 0.0_r_dp
        opm_wall_finish = 0.0_r_dp
        opm_wall_elapsed = 0.0_r_dp
        
        timer_status = TIMER_NOT_STARTED
        write(output_unit, '(A)') '    Timer reset...'
        
    end subroutine timer_reset

    !-----------------------------------------------------------------------------
    !  function : get_cpu_time
    !  Description : Return the elapsed CPU time
    !-----------------------------------------------------------------------------
    function get_cpu_time() result(time)
        real(r_dp) :: time
        
        if (timer_status == TIMER_STOPPED) then
            time = cpu_elapsed
        else if (timer_status == TIMER_RUNNING) then
            call cpu_time(cpu_finish)
            time = cpu_finish - cpu_start
        else
            time = 0.0_r_dp
        end if
        
    end function get_cpu_time

    !-----------------------------------------------------------------------------
    !  function : get_wall_time
    !  Description : Return the elapsed wall time (OMP or SYSTEM_CLOCK)
    !-----------------------------------------------------------------------------
    function get_wall_time() result(time)
        real(r_dp) :: time
        
        if (timer_status == TIMER_STOPPED) then
#ifdef USE_OPENMP
            time = opm_wall_elapsed
#else
            time = sys_clock_elapsed
#endif
        else if (timer_status == TIMER_RUNNING) then
#ifdef USE_OPENMP
            time = omp_get_wtime() - opm_wall_start
#else
            call system_clock(sys_clock_finish)
            time = real(sys_clock_finish - sys_clock_start, r_dp) / real(sys_clock_rate, r_dp)
#endif
        else
            time = 0.0_r_dp
        end if
        
    end function get_wall_time

    !-----------------------------------------------------------------------------
    !  function : get_system_clock_time
    !  Description : Return the elapsed system clock time
    !-----------------------------------------------------------------------------
    function get_system_clock_time() result(time)
        real(r_dp) :: time
        
        if (timer_status == TIMER_STOPPED) then
            time = sys_clock_elapsed
        else if (timer_status == TIMER_RUNNING) then
            call system_clock(sys_clock_finish)
            time = real(sys_clock_finish - sys_clock_start, r_dp) / real(sys_clock_rate, r_dp)
        else
            time = 0.0_r_dp
        end if
        
    end function get_system_clock_time

end module timer_module