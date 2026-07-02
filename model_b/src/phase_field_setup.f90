!  Submodule    : phase_field_interactive_sub
!  Purpose      : Interactive grid creation and user input procedures
!                 for the Cahn-Hilliard phase-field simulation.
!
!  Author       : Shahid Maqbool
!  Date         : 16 June 2026
!  Version      : 1.0.0
!  License      : MIT
!
!  Parent Module : phase_field_mod
!
!  Dependencies :
!    phase_field_mod - Provides PhaseFieldGrid type and parent procedures
!    precision_module - Provides r_sp, i_sp precision types
!
!  Procedures Implemented :
!    create_grid_interactive()          - Interactive grid creation
!    get_grid_dimensions_from_user()    - Get user input for dimensions
!    get_user_dimensions()              - Internal helper (private)
!
!  Features     :
!    Input validation with error handling
!    Default values with Enter key
!    Interactive user prompts
!    Professional formatted output
!
!-------------------------------------------------------------------------------
!  COMPILATION:
!  gfortran -O3 -fopenmp -cpp -DUSE_OPENMP -c phase_field_interactive_sub.f90
!-------------------------------------------------------------------------------
submodule (phase_field_module) phase_field_interactive_sub
    !===========================================================================
    !  SUBMODULE DEPENDENCIES
    !===========================================================================
    !
    !  phase_field_mod  : Provides the PhaseFieldGrid type and parent procedures.
    !                     This submodule extends the functionality of the parent
    !                     module with interactive input capabilities.
    !
    !  precision_module : Provides precision types:
    !                     - r_sp  : single precision real (4 bytes)
    !                     - i_sp  : single precision integer (4 bytes)
    !
    !===========================================================================
    use precision_module, only : i_sp, r_sp
    implicit none
contains
    !-----------------------------------------------------------------------------
    !  module procedure : create_grid_interactive
    !  Description      : Create a grid with interactive user input.
    !                     Prompts the user for Nx and Ny dimensions,
    !                     then creates the grid with default dx=1.0, dy=1.0.
    !
    !  Arguments        :
    !    this - PhaseFieldGrid object (intent: inout)
    !
    !  Algorithm        :
    !    1. Call get_user_dimensions() to get Nx and Ny from user
    !    2. Call create_grid() with the specified dimensions
    !    3. Print success message with grid information
    !
    !  Performance      : O(Nx × Ny) for grid allocation
    !-----------------------------------------------------------------------------
    module procedure create_grid_interactive
        integer(i_sp) :: Nx, Ny              
        ! Get dimensions from user
        call get_user_dimensions(Nx, Ny)
        ! Create grid with default dx,dy
        call this%create_grid(Nx=Nx, Ny=Ny, dx=1.0, dy=1.0)
        print *, '========================================='
        print *, 'Grid created successfully!'
        print *, '  Nx = ', this%Nx
        print *, '  Ny = ', this%Ny
        print *, '========================================='        
    end procedure create_grid_interactive
    !-----------------------------------------------------------------------------
    !  module procedure : get_grid_dimensions_from_user
    !  Description      : Get Nx and Ny dimensions from the user with validation.
    !                     This is a wrapper around the internal helper subroutine.
    !
    !  Arguments        :
    !    this        - PhaseFieldGrid object (intent: inout)
    !    Nx          - Output: Grid points in X (intent: out)
    !    Ny          - Output: Grid points in Y (intent: out)
    !    default_Nx  - Default value for Nx (optional)
    !    default_Ny  - Default value for Ny (optional)
    !
    !  Performance      : O(1) - constant time
    !-----------------------------------------------------------------------------
    module procedure get_grid_dimensions_from_user
        call get_user_dimensions(Nx, Ny, default_Nx, default_Ny)
    end procedure get_grid_dimensions_from_user
 !-----------------------------------------------------------------------------
    !  internal subroutine : get_user_dimensions
    !  Description         : Internal helper subroutine for user input.
    !                        Prompts the user for Nx and Ny with validation.
    !                        Handles default values and error cases.
    !
    !  Arguments           :
    !    Nx          - Output: Grid points in X (intent: out)
    !    Ny          - Output: Grid points in Y (intent: out)
    !    default_Nx  - Default value for Nx (optional)
    !    default_Ny  - Default value for Ny (optional)
    !
    !  Algorithm           :
    !    1. Set defaults if provided
    !    2. Loop until valid input is received for Nx
    !    3. Loop until valid input is received for Ny
    !    4. Validate that inputs are positive integers
    !
    !  Error Handling      : 
    !    - Invalid input: Re-prompt user
    !    - Enter key: Use default value
    !    - Non-positive: Re-prompt with error message
    !
    !  Performance         : O(1) - constant time
    !-----------------------------------------------------------------------------	
    subroutine get_user_dimensions(Nx, Ny, default_Nx, default_Ny)
        integer(i_sp), intent(out) :: Nx, Ny
        integer(i_sp), intent(in), optional :: default_Nx, default_Ny
        integer(i_sp) :: ios
        character(len=100) :: input_str
        logical :: input_valid
        
        ! Set defaults if provided
        if (present(default_Nx)) then
            Nx = default_Nx
        else
            Nx = 500
        end if
        
        if (present(default_Ny)) then
            Ny = default_Ny
        else
            Ny = 500
        end if
        
        print *, '-----------------------------------------'
        print *, 'Enter grid dimensions'
        print *, 'Press Enter to use default values'
        print *, '-----------------------------------------'
        
        ! Get Nx from user
        input_valid = .false.
        do while (.not. input_valid)
            print '(" Enter Nx (positive integer, default ", I0, "):")', Nx
            read(*, '(A)', iostat=ios) input_str
            
            ! Check for read error
            if (ios /= 0) then
                print *, 'ERROR: Could not read input. Please try again.'
                cycle
            end if
            
            ! If user pressed Enter, use default
            if (len_trim(input_str) == 0) then
                print *, 'Using default Nx = ', Nx
                input_valid = .true.
                exit
            end if
            
            ! Try to parse input
            read(input_str, *, iostat=ios) Nx
            if (ios == 0 .and. Nx > 0) then
                input_valid = .true.
            else
                print *, 'ERROR: Nx must be a positive integer. Please try again.'
            end if
        end do
        
        ! Get Ny from user
        input_valid = .false.
        do while (.not. input_valid)
            print '(" Enter Ny (positive integer, default ", I0, "):")', Ny
            read(*, '(A)', iostat=ios) input_str
            
            ! Check for read error
            if (ios /= 0) then
                print *, 'ERROR: Could not read input. Please try again.'
                cycle
            end if
            
            ! If user pressed Enter, use default
            if (len_trim(input_str) == 0) then
                print *, 'Using default Ny = ', Ny
                input_valid = .true.
                exit
            end if
            
            ! Try to parse input
            read(input_str, *, iostat=ios) Ny
            if (ios == 0 .and. Ny > 0) then
                input_valid = .true.
            else
                print *, 'ERROR: Ny must be a positive integer. Please try again.'
            end if
        end do
    end subroutine get_user_dimensions
end submodule phase_field_interactive_sub