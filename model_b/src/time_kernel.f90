!-------------------------------------------------------------------------------
!  ███████ ██    ██  ██████  ██       ██    ██ ████████ ██  ██████  ███    ██ 
!  ██      ██    ██ ██    ██ ██       ██    ██    ██    ██ ██    ██ ████   ██ 
!  █████   ██    ██ ██    ██ ██       ██    ██    ██    ██ ██    ██ ██ ██  ██ 
!  ██      ██    ██ ██    ██ ██       ██    ██    ██    ██ ██    ██ ██  ██ ██ 
!  ███████  ██████   ██████  ███████   ██████     ██    ██  ██████  ██   ████ 
!
!  Submodule    : time_integration_sub
!  Purpose      : Perform explicit time integration for the Cahn-Hilliard equation.
!                 Updates concentration field using forward Euler method.
!
!  Author       : Shahid Maqbool
!  Date         : 16 June 2026
!  Version      : 1.0.0
!  License      : MIT
!
!  Parent Module : phase_field_mod
!
!  Dependencies :
!    phase_field_mod  - Provides PhaseFieldGrid type and parent procedures
!    precision_module - Provides r_sp precision types
!    omp_lib          - OpenMP runtime library (conditional)
!
!  Algorithm    :
!    Cahn-Hilliard Equation:
!      ∂c/∂t = M · ∇²(μ)
!      where μ = df/dc - κ·∇²c  (chemical potential)
!
!    Forward Euler Time Integration:
!      c^{n+1} = c^n + Δt · M · ∇²(μ^n)
!
!    Bounds Enforcement:
!      [0.0001, 0.9999] prevents numerical instability)
!
!-------------------------------------------------------------------------------
submodule (phase_field_module) time_integration_sub
    !===========================================================================
    !  SUBMODULE DEPENDENCIES
    !===========================================================================
    !
    !  phase_field_mod  : Provides the PhaseFieldGrid type containing:
    !                     - con        : concentration field (updated)
    !                     - lap_dummy  : Laplacian of chemical potential (∇²μ)
    !                     - Nx, Ny     : grid dimensions
    !
    !  precision_module : Provides precision types
    !  omp_lib          : OpenMP runtime library (conditional)
    !
    !===========================================================================
    use precision_module
#ifdef USE_OPENMP
    use omp_lib
#endif
    implicit none
contains
    !-----------------------------------------------------------------------------
    !  module procedure : time_integration
    !  Description      : Update concentration using explicit forward Euler
    !                     time integration for the Cahn-Hilliard equation.
    !
    !  Arguments        :
    !    this       - PhaseFieldGrid object (intent: inout)
    !    dt         - Time step (intent: in)
    !    mobility   - Mobility coefficient (intent: in)
    !    grad_coef  - Gradient energy coefficient (intent: in)
    !
    !  Algorithm        :
    !    Step 1: Store parameters in grid object
    !    Step 2: Compute c^{n+1} = c^n + dt·M·∇²(μ^n)
    !    Step 3: Enforce physical bounds [0, 1]
	
    module procedure time_integration
        integer(i_sp) :: i, j
        real(i_sp) :: c_max, c_min
        !=========================================================================
        !  Phase 1 : Store Parameters
        !=========================================================================
        ! Store simulation parameters in grid object for future reference
        this%dt = dt
        this%mobility = mobility
        this%grad_coef = grad_coef
        c_max = 0.99999
        c_min = 0.00001
        !=========================================================================
        !  Phase 2 : Forward Euler Time Integration
        !=========================================================================
        !
        !  Cahn-Hilliard Equation:
        !    ∂c/∂t = M · ∇²(μ)
        !
        !  Forward Euler Update:
        !    c^{n+1}(i,j) = c^n(i,j) + Δt · M · ∇²(μ^n)(i,j)
        !
        !  Where:
        !    μ = df/dc - κ·∇²c  (chemical potential)
        !    ∇²(μ) is stored in lap_dummy
        !
        !=========================================================================		
        !$omp parallel do default(none) schedule(static) private(i, j) &         
		!$omp shared(this, dt, mobility, c_max, c_min)
        do j = 1, this%Ny
            do i = 1, this%Nx
                !-----------------------------------------------------------------
                !  Step 1 : Forward Euler Update
                !-----------------------------------------------------------------
                ! c_new = c_old + dt * mobility * ∇²(μ)
                this%con_next(i, j) = this%con(i, j) + dt * mobility * this%lap_dummy(i, j)
                
                !-----------------------------------------------------------------
                !  Step 2 : Enforce Physical Bounds
                !-----------------------------------------------------------------
                ! Concentration must stay within [0, 1] for numerical stability
                ! This prevents values from going negative or above 1
                this%con_next(i, j) = min(c_max, max(c_min, this%con_next(i, j)))
            end do
        end do
        !$omp end parallel do
        call swap_fields(this%con, this%con_next)
        
    end procedure
    
    ! swap fields for update
    module subroutine swap_fields(this, that)
        real(r_sp), allocatable, intent(inout) :: this(:, :), that(:, :)
        real(r_sp), allocatable :: buffer(:, :)
        
        call move_alloc(this, buffer)
        call move_alloc(that, this)
        call move_alloc(buffer, that)
    end subroutine swap_fields
    
end submodule
