!------------------------------------------------------------------------------
!  Submodule    : create_grid_sub
!  Purpose      : Allocate and initialize the phase-field grid structure
!                 with dynamic memory allocation and error handling
!
!  Arguments        :
!    this   - PhaseFieldGrid object (intent: inout)
!    Nx     - Number of grid points in X direction (intent: in)
!    Ny     - Number of grid points in Y direction (intent: in)
!    dx     - Grid spacing in X direction (intent: in)
!    dy     - Grid spacing in Y direction (intent: in)
!
!  Memory Usage    : 7 arrays × Nx × Ny × 4 bytes
!	
!  Author       : Shahid Maqbool
!  Date         : 16 June 2026
!  Version      : 1.0.0
!  License      : MIT
!
!  Performance  : Optimized memory allocation with contiguous arrays
!  Dependencies : error_status_module for allocation validation
!  Precision    : Single-precision (r_sp) for all floating-point operations
!
!-------------------------------------------------------------------------------

submodule (phase_field_module) create_grid_sub
    use error_status_module
    implicit none
contains
    module procedure create_grid
    integer :: istat
    ! Store grid parameters
    this%Nx = Nx
    this%Ny = Ny
    this%dx = dx
    this%dy = dy

    allocate(this%con(Nx, Ny),  & 
        this%r(Nx, Ny),         &
        this%dfdcon(Nx, Ny),    &
        this%lap_con(Nx, Ny),   &
        this%dummy_con(Nx, Ny), &
        this%lap_dummy(Nx, Ny), &
        this%con_next(Nx,Ny),    &
    stat=istat)

    call Check_allocation_status (istat)

    end procedure
end submodule