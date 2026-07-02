!------------------------------------------------------------------------
!  ██████  ██   ██  █████  ███████ ███████     ███████ ██ ███████ ██      ██████   
!  ██  ██  ██   ██ ██   ██ ██      ██          ██      ██ ██      ██      ██   ██      
!  ██████  ███████ ███████ ███████ █████       █████   ██ █████   ██      ██   ██    
!  ██      ██   ██ ██   ██      ██ ██          ██      ██ ██      ██      ██   ██       
!  ██      ██   ██ ██   ██ ███████ ███████     ██      ██ ███████ ███████ ██████  
!
!  Module       : phase_field_mod
!  Purpose      : Core type definition and procedure interfaces for the
!                 Cahn-Hilliard phase-field simulation code.
!
!  Author       : Shahid Maqbool
!  Date         : 16 June 2026
!  Version      : 1.0.0
!  License      : MIT
!
!  Description  :
!    This module defines the PhaseFieldGrid type which encapsulates all
!    data and procedures for the Cahn-Hilliard simulation. It provides
!    a clean interface for grid creation, microstructure initialization,
!    time integration, and output.
!
!  Features     :
!     Object-oriented design with type-bound procedures
!     Dynamic memory allocation for scalability
!     Interactive and batch grid creation modes
!     Complete Cahn-Hilliard solver implementation
!     OpenMP parallelization support
!     Precision control via precision_module
!
!  Dependencies :
!    precision_module - Provides r_sp and i_sp precision types
!
!  Usage        :
!    type(PhaseFieldGrid) :: grid
!    call grid%create_grid(Nx=500, Ny=500, dx=1.0, dy=1.0)
!    call grid%init_microstructure(c0=0.4, noise=0.02)
!    call grid%free_energy_derivative(A=1.0)
!    call grid%laplace_evaluation()
!    call grid%time_integration(dt=0.01, mobility=1.0, grad_coef=0.5)
!    call grid%output_results('ch.dat')
!-------------------------------------------------------------------------------
module phase_field_module
    !===========================================================================
    !  MODULE DEPENDENCIES
    !===========================================================================
    !
    !  precision_module  : Provides precision types:
    !                      - r_sp  : single precision real (4 bytes)
    !                      - r_dp  : double precision real (8 bytes)
    !                      - i_sp  : single precision integer (4 bytes)
    !
    !  Note: This module is the core dependency for all submodules.
    !        All phase-field submodules USE this module.
    !
    !===========================================================================
    use precision_module
    implicit none
    !-----------------------------------------------------------------------------
    !  Type Definition : PhaseFieldGrid
    !-----------------------------------------------------------------------------
    !  Description    : Core data structure for the Cahn-Hilliard simulation.
    !                   Encapsulates all grid data, parameters, and procedures.
    !
    !  Components     :
    !    Nx, Ny       - Grid dimensions (integer)
    !    dx, dy       - Grid spacing (real)
    !    A            - Free energy coefficient (real)
    !    dt           - Time step (real)
    !    mobility     - Mobility coefficient (real)
    !    grad_coef    - Gradient energy coefficient (real)
    !    c0           - Initial concentration (real)
    !
    !  Arrays         :
    !    con          - Concentration field (Nx × Ny)
    !    r            - Random field for initialization (Nx × Ny)
    !    dfdcon       - Free energy derivative (Nx × Ny)
    !    lap_con      - Laplacian of concentration (Nx × Ny)
    !    dummy_con    - Intermediate variable (Nx × Ny)
    !    lap_dummy    - Laplacian of dummy_con (Nx × Ny)
    !
    !  Type-Bound Procedures :
    !    Grid Creation      : create_grid, create_grid_interactive
    !    Grid Input         : get_grid_dimensions_from_user
    !    Simulation         : init_microstructure, free_energy_derivative
    !                         laplace_evaluation, time_integration
    !    Output             : output_results
    !
    !  Memory Usage   : 6 arrays x Nx x Ny x 24 bytes
    !  Performance    : Optimized for contiguous memory access
    !-----------------------------------------------------------------------------
    type, public :: PhaseFieldGrid
        integer :: Nx, Ny
        real(r_sp) :: dx, dy, A, dt, mobility, grad_coef, c0
        real(r_sp), dimension(:,:), allocatable :: con
        real(r_sp), dimension(:,:), allocatable :: r
        real(r_sp), dimension(:,:), allocatable :: dfdcon
        real(r_sp), dimension(:,:), allocatable :: lap_con
        real(r_sp), dimension(:,:), allocatable :: dummy_con
        real(r_sp), dimension(:,:), allocatable :: lap_dummy
        real(r_sp), dimension(:,:), allocatable :: con_next
    contains
        ! Grid creation procedures
        procedure :: create_grid
        procedure :: create_grid_interactive      ! Interactive grid creation
        procedure :: get_grid_dimensions_from_user ! Get user input for dimensions		
		! simulation procedures
        procedure :: init_microstructure
        procedure :: free_energy_derivative
        procedure :: laplace_evaluation
        procedure :: time_integration       
        procedure :: output_results
     end type PhaseFieldGrid
    !-----------------------------------------------------------------------------
    !  Interface Blocks for Submodule Procedures
    !-----------------------------------------------------------------------------
    !  Description : These interfaces declare the module procedures that will
    !                be implemented in separate submodule files.
    !
    !  Note        : Each interface must EXACTLY match the corresponding
    !                submodule implementation.
    !-----------------------------------------------------------------------------
    interface
        !=======================================================================
        !  Grid Creation Subroutines
        !=======================================================================
        
        ! create_grid : Allocate and initialize grid
        !-----------------------------------------------------------------------
        !  Arguments :
        !    this  - PhaseFieldGrid object (intent: inout)
        !    Nx    - Number of grid points in X direction (intent: in)
        !    Ny    - Number of grid points in Y direction (intent: in)
        !    dx    - Grid spacing in X direction (intent: in)
        !    dy    - Grid spacing in Y direction (intent: in)
        !-----------------------------------------------------------------------
        module subroutine create_grid(this, Nx, Ny, dx, dy)
            class(PhaseFieldGrid), intent(inout) :: this
            integer, intent(in) :: Nx, Ny
            real(r_sp)          :: dx, dy
        end subroutine
        ! create_grid_interactive : Create grid with interactive user input
        !-----------------------------------------------------------------------
        !  Arguments :
        !    this  - PhaseFieldGrid object (intent: inout)
        !-----------------------------------------------------------------------	
        module subroutine create_grid_interactive(this)
            class(PhaseFieldGrid), intent(inout) :: this
        end subroutine create_grid_interactive
        ! get_grid_dimensions_from_user : Get grid dimensions from user
        !-----------------------------------------------------------------------
        !  Arguments :
        !    this         - PhaseFieldGrid object (intent: inout)
        !    Nx           - Output: Grid points in X (intent: out)
        !    Ny           - Output: Grid points in Y (intent: out)
        !    default_Nx   - Default value for Nx (optional)
        !    default_Ny   - Default value for Ny (optional)
        !-----------------------------------------------------------------------    
        module subroutine get_grid_dimensions_from_user(this, Nx, Ny, default_Nx, default_Ny)
            class(PhaseFieldGrid), intent(inout) :: this
            integer, intent(out) :: Nx, Ny
            integer, intent(in), optional :: default_Nx, default_Ny
        end subroutine get_grid_dimensions_from_user
        !=======================================================================
        !  Simulation Subroutines
        !=======================================================================
        
        ! init_microstructure : Initialize concentration field
        !-----------------------------------------------------------------------
        !  Arguments :
        !    this  - PhaseFieldGrid object (intent: inout)
        !    c0    - Base concentration (intent: in)
        !    noise - Noise amplitude for perturbations (intent: in)
        !-----------------------------------------------------------------------			
        module subroutine init_microstructure(this, c0, noise)
            class(PhaseFieldGrid), intent(inout) :: this
            real(r_sp), intent(in) :: c0, noise
        end subroutine
        ! free_energy_derivative : Compute dF/dc
        !-----------------------------------------------------------------------
        !  Arguments :
        !    this  - PhaseFieldGrid object (intent: inout)
        !    A     - Free energy coefficient (intent: in)
        !-----------------------------------------------------------------------        
        module subroutine free_energy_derivative(this, A)
            class(PhaseFieldGrid), intent(inout) :: this
            real(r_sp), intent(in) :: A
        end subroutine
        ! output_results : Write concentration field to binary file
        !-----------------------------------------------------------------------
        !  Arguments :
        !    this     - PhaseFieldGrid object (intent: in)
        !    filename - Output filename (intent: in)
        !-----------------------------------------------------------------------
        module subroutine output_results(this, filename)
            class(PhaseFieldGrid), intent(in) :: this
            character(len=*), intent(in) :: filename
        end subroutine
        ! laplace_evaluation : Compute Laplacians
        !-----------------------------------------------------------------------
        !  Arguments :
        !    this  - PhaseFieldGrid object (intent: inout)
        !-----------------------------------------------------------------------		
        module subroutine laplace_evaluation(this)
            class(PhaseFieldGrid), intent(inout) :: this
        end subroutine
        
! Alternative: Put this in your parent module interface instead


        ! time_integration : Advance the solution in time
        !-----------------------------------------------------------------------
        !  Arguments :
        !    this       - PhaseFieldGrid object (intent: inout)
        !    dt         - Time step (intent: in)
        !    mobility   - Mobility coefficient (intent: in)
        !    grad_coef  - Gradient energy coefficient (intent: in)
        !-----------------------------------------------------------------------
        module subroutine time_integration(this, dt, mobility, grad_coef)
            class(PhaseFieldGrid), intent(inout) :: this
            real(r_sp), intent(in) :: dt, mobility, grad_coef
        end subroutine

    end interface

interface
    module subroutine swap_fields(this, that)
        real(r_sp), allocatable, intent(inout) :: this(:, :), that(:, :)
    end subroutine swap_fields
end interface

end module phase_field_module