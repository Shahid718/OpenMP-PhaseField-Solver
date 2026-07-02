!-------------------------------------------------------------------------------
!  ██    ██ ████████ ██ ██      ██  ████████  ██    ██     ███    ███  ██████  █████    ███████
!  ██    ██    ██    ██ ██      ██     ██     ██    ██     ████  ████ ██    ██ ██   ██  ██    
!  ██    ██    ██    ██ ██      ██     ██      ██  ██      ██ ████ ██ ██    ██ ██    █  ██████    
!  ██    ██    ██    ██ ██      ██     ██        ██        ██  ██  ██ ██    ██ ██   ██  ██      
!   ██████     ██    ██ ███████ ██     ██        ██        ██      ██  ██████  █████    ███████    
!
!  Module       : utils_module
!  Purpose      : Utility procedures for the Cahn-Hilliard simulation
!                 Provides formatted output, progress tracking, and banners.
!
!  Author       : Shahid Maqbool
!  Date         : 16 June 2026
!  Version      : 1.0.0
!  License      : MIT
!
!  Description  :
!    This module provides a comprehensive set of utility procedures for
!    the Cahn-Hilliard phase-field simulation. It includes formatted output
!    routines, progress tracking, banner display, and runtime configuration
!    reporting with OpenMP support.
!
!  Features     :
!     Professional ASCII banners for application branding
!     Formatted output with box-drawing characters
!     Progress bar with percentage and visual feedback
!     Runtime configuration reporting (compiler, OpenMP, precision)
!     Success, warning, and error message handling
!     OpenMP-aware output (conditional compilation)
!     Separator and section headers for organized output
!
!  Dependencies :
!    iso_fortran_env - Provides compiler_version, compiler_options, output_unit
!    precision_module - Provides r_dp, r_sp precision types
!    phase_field_mod - Provides PhaseFieldGrid type
!    omp_lib         - OpenMP runtime library (conditional)
!
!  Usage        :
!    use utils_module
!    call display_banner()
!    call print_section('INITIALIZATION')
!    call Report_runtime_configuration()
!    call progress_bar(step, total, width=50)
!    call print_simulation_header()
!    call print_simulation_footer(elapsed_time)
!    call display_completion_banner()
!
!-------------------------------------------------------------------------------
module utils_module
    !===========================================================================
    !  MODULE DEPENDENCIES
    !===========================================================================
    !
    !  iso_fortran_env  : Provides standard Fortran environment constants:
    !                     - output_unit      : Standard output unit number
    !                     - compiler_version : Compiler identification string
    !                     - compiler_options : Compiler flags used
    !
    !  precision_module : Provides precision types:
    !                     - r_dp : double precision real (8 bytes)
    !                     - r_sp : single precision real (4 bytes)
    !
    !  phase_field_mod  : Provides the PhaseFieldGrid type for grid operations
    !  omp_lib          : OpenMP runtime library (conditional on USE_OPENMP)
    !
    !===========================================================================
    use, intrinsic :: iso_fortran_env
    use precision_module
    use phase_field_module
#ifdef USE_OPENMP
    use omp_lib
#endif
    implicit none
    !-----------------------------------------------------------------------------
    !  Public Interface
    !-----------------------------------------------------------------------------
    public :: print_simulation_header, print_simulation_footer
    public :: print_section, print_success, print_separator
    public :: print_warning, print_error, progress_bar
    public :: display_banner, display_completion_banner
    public :: Report_runtime_configuration
contains
    !-----------------------------------------------------------------------------
    !  subroutine : print_separator
    !  Description : Print a separator line of specified character and length
    !
    !  Arguments   :
    !    char   - Character to use for the separator (intent: in)
    !    length - Length of the separator line (intent: in)
    !
    !  Output      : Separator line to stdout
    !  Performance : O(length) - constant time
    !-----------------------------------------------------------------------------
    subroutine print_separator(char, length)
        character(len=1), intent(in) :: char
        integer, intent(in) :: length
        integer :: i
        write(output_unit, '(A, $)') '  '
        do i = 1, length
            write(output_unit, '(A, $)') char
        end do
        write(output_unit, '(A)') ''
    end subroutine print_separator
    !-----------------------------------------------------------------------------
    !  subroutine : print_section
    !  Description : Print a section header with title
    !
    !  Arguments   :
    !    title - Section title (intent: in)
    !
    !  Output      : Formatted section header with separators
    !-----------------------------------------------------------------------------
    subroutine print_section(title)
        character(len=*), intent(in) :: title
        write(output_unit, '(A)') ''        
        write(output_unit, '(A)') ''
        write(output_unit, '(A)') ' --------------------------'
        write(output_unit, '(A,A)') '   ', title
        write(output_unit, '(A)') ' --------------------------'
        write(output_unit, '(A)') ''
        write(output_unit, '(A)') ''
    end subroutine print_section
    !-----------------------------------------------------------------------------
    !  subroutine : print_success
    !  Description : Print a success message with visual indicator
    !
    !  Arguments   :
    !    message - Success message (intent: in)
    !
    !  Output      : Success message
    !-----------------------------------------------------------------------------
    subroutine print_success(message)
        character(len=*), intent(in) :: message
        write(output_unit, '(A, A)') ' ', trim(message)
    end subroutine print_success
    !-----------------------------------------------------------------------------
    !  subroutine : print_warning
    !  Description : Print a warning message with visual indicator
    !
    !  Arguments   :
    !    message - Warning message (intent: in)
    !
    !  Output      :  WARNING: message
    !-----------------------------------------------------------------------------
    subroutine print_warning(message)
        character(len=*), intent(in) :: message
        write(output_unit, '(A, A)') '  ## WARNING: ', trim(message)
    end subroutine print_warning
    !-----------------------------------------------------------------------------
    !  subroutine : print_error
    !  Description : Print an error message with visual indicator
    !
    !  Arguments   :
    !    message - Error message (intent: in)
    !
    !  Output      :  ERROR: message
    !-----------------------------------------------------------------------------
    subroutine print_error(message)
        character(len=*), intent(in) :: message
        write(output_unit, '(A, A)') '  ## ERROR: ', trim(message)
    end subroutine print_error
    !-----------------------------------------------------------------------------
    !  subroutine : progress_bar
    !  Description : Display a visual progress bar with percentage
    !
    !  Arguments   :
    !    step   - Current progress step (intent: in)
    !    total  - Total number of steps (intent: in)
    !    width  - Width of the progress bar (intent: in)
    !    prefix - Optional prefix string (intent: in, optional)
    !
    !  Output      : Progress bar with percentage and optional prefix
    !-----------------------------------------------------------------------------
    subroutine progress_bar(step, total, width, prefix)
        integer, intent(in) :: step, total
        integer, intent(in) :: width
        character(len=*), intent(in), optional :: prefix
        
        integer :: i, filled, empty
        real :: fraction
        character(len=50) :: prefix_str
        
        if (present(prefix)) then
            prefix_str = adjustl(prefix)
        else
            prefix_str = '   Progress'
        end if
        
        fraction = real(step) / real(total)
        filled = nint(fraction * width)
        empty = width - filled
        
        write(output_unit, '(A, $)') '  '
        write(output_unit, '(A, $)') trim(prefix_str)
        write(output_unit, '(A, $)') ' |'
        
        do i = 1, filled
            write(output_unit, '(A, $)') '||'
        end do
        
        do i = 1, empty
            write(output_unit, '(A, $)') '||'
        end do
        
        write(output_unit, '(A, I3, A, $)') '| ', nint(fraction * 100), '%'
        
        ! If complete, add newline
        if (step == total) then
            write(output_unit, '(A)') ''
        else
            write(output_unit, '(A, $)') ' '
        end if
        
        ! Flush output
        call flush(output_unit)
        
    end subroutine progress_bar
    !-----------------------------------------------------------------------------
    !  subroutine : Report_runtime_configuration
    !  Description : Report the runtime configuration including compiler,
    !                OpenMP status, precision, and memory model
    !
    !  Output      : Formatted runtime configuration report
    !-----------------------------------------------------------------------------	
    subroutine Report_runtime_configuration ()
        implicit none
		! Display compiler information
        write(output_unit, '(A)')     '  Compiler       : ' // trim(compiler_version())
        write(output_unit, '(A)')     '  Compiler flags : ' // trim(compiler_options())
        call print_separator('=', 50)
		! Display OpenMP configuration
#ifdef USE_OPENMP
        write(output_unit, '(A, I0)') '  OpenMP threads : ', omp_get_max_threads()
        write(output_unit, '(A, I0)') '  CPU cores      : ', omp_get_num_procs()
        write(output_unit, '(A)')     '  Parallel mode  : ENABLED'
#else
        write(output_unit, '(A)')     '  Parallel mode  : DISABLED (serial)'
#endif
        write(output_unit, '(A)')     '  Precision      : Single (r_sp = 4)'
        write(output_unit, '(A)')     '  Memory model   : dynamic allocation'
        write(output_unit, '(A, I0)') '  Output unit    : ', output_unit
    end subroutine Report_runtime_configuration
    !-----------------------------------------------------------------------------
    !  subroutine : print_simulation_header
    !  Description : Print the simulation header with OpenMP status
    !  Output      : Formatted simulation header with OpenMP info
    !-----------------------------------------------------------------------------
    subroutine print_simulation_header()
        implicit none
        write(output_unit, '(A)') ''
        write(output_unit, '(A)') '  |======================================================================|'
        write(output_unit, '(A)') '  |                                                                      |'        
#ifdef USE_OPENMP
        write(output_unit, '(A, I0, A)') &
            '  |   OpenMP: ENABLED  |  Threads: ', omp_get_max_threads(), &
            '  |  Parallel execution              |'
#else
        write(output_unit, '(A)') '  |   OpenMP: DISABLED  |  Serial execution                              |'
#endif
        write(output_unit, '(A)') '  |                                                                      |'
        write(output_unit, '(A)') '  |   Starting Cahn-Hilliard Microstructure Evolution                    |'
        write(output_unit, '(A)') '  |                                                                      |'
        write(output_unit, '(A)') '  |======================================================================|' 
        write(output_unit, '(A)') ''
    end subroutine print_simulation_header
    !-----------------------------------------------------------------------------
    !  subroutine : print_simulation_footer
    !  Description : Print the simulation completion footer
    !
    !  Arguments   :
    !    elapsed_time - Total execution time in seconds (intent: in)
    !
    !  Output      : Formatted simulation completion footer
    !-----------------------------------------------------------------------------
    subroutine print_simulation_footer(elapsed_time)
        real(r_dp), intent(in) :: elapsed_time
        write(output_unit, '(A)') ''
        write(output_unit, '(A)') '  |======================================================================|'
        write(output_unit, '(A)') '  |                                                                      |'
        write(output_unit, '(A)') '  |                         SIMULATION COMPLETE                          |'
        write(output_unit, '(A)') '  |                                                                      |'
        write(output_unit, '(A, F12.4, A)') '  |   Total execution time : ', elapsed_time, ' seconds                        |'
        write(output_unit, '(A)') '  |                                                                      |'
        write(output_unit, '(A)') '  |            All results written successfully                          |'
        write(output_unit, '(A)') '  |                                                                      |'
        write(output_unit, '(A)') '  |======================================================================|'
        write(output_unit, '(A)') ''        
    end subroutine print_simulation_footer
    !-----------------------------------------------------------------------------
    !  subroutine : display_banner
    !  Description : Display the application banner with ASCII art
    !
    !  Output      : Professional ASCII banner with version info
    !-----------------------------------------------------------------------------
    subroutine display_banner()
        implicit none        
        write(output_unit, '(A)') ''
        write(output_unit, '(A)') '  |==================================================================|'
        write(output_unit, '(A)') '  |                                                                  |'
        write(output_unit, '(A)') '  |                    ---    ---    ---                             |'
        write(output_unit, '(A)') '  |                   |   |  |   |  |   |                            |'
        write(output_unit, '(A)') '  |                   |   |  |   |  |   |                            |'
        write(output_unit, '(A)') '  |                    ---    ---    ---                             |'
        write(output_unit, '(A)') '  |                    ---    ---    ---                             |'
        write(output_unit, '(A)') '  |                   |   |  |   |  |   |                            |'
        write(output_unit, '(A)') '  |                   |   |  |   |  |   |                            |'
        write(output_unit, '(A)') '  |                    ---    ---    ---                             |'
        write(output_unit, '(A)') '  |                                                                  |'
        write(output_unit, '(A)') '  |             Cahn-Hilliard Phase-Field Simulation Suite           |'
        write(output_unit, '(A)') '  |                     High-Performance Computing                   |'
        write(output_unit, '(A)') '  |                                                                  |'
        write(output_unit, '(A)') '  |            Version 1.0.0   |   Author: Shahid Maqbool            |'
        write(output_unit, '(A)') '  |       Date: 16 June 2026   |   License: MIT                      |'
        write(output_unit, '(A)') '  |                                                                  |'
        write(output_unit, '(A)') '  |                                                                  |'
        write(output_unit, '(A)') '  |==================================================================|'
        write(output_unit, '(A)') ''
    end subroutine display_banner
    !-----------------------------------------------------------------------------
    !  subroutine : display_completion_banner
    !  Description : Display the completion banner with success message
    !
    !  Output      : Formatted completion banner
    !-----------------------------------------------------------------------------
    subroutine display_completion_banner ()
    implicit none
        write(output_unit, '(A)') ''
        write(output_unit, '(A)') '  |=======================================================|'
        write(output_unit, '(A)') '  |                                                       |'
        write(output_unit, '(A)') '  |          Simulation completed successfully!           |'
        write(output_unit, '(A)') '  |                                                       |'
        write(output_unit, '(A)') '  |                  Happy computing!                     |'
        write(output_unit, '(A)') '  |                                                       |'
        write(output_unit, '(A)') '  |=======================================================|'
        write(output_unit, '(A)') ''
    end subroutine
end module utils_module