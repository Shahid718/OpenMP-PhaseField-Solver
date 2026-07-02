!---------------------------------------------------------------------------------------
!  ███████ ██████   ███████ ███████ ███████ ███    ██ ██████  ██████    ██████ ██    ██ 
!  ██      ██   ██  ██      ██      ██      ████   ██ ██      ██   ██   ██  ██  ██  ██ 
!  █████   ██████   █████   █████   █████   ██ ██  ██ ████    ██████    ██████   ████
!  ██      ██   ██  ██      ██      ██      ██  ██ ██ ██      ██   ██       ██    ██ 
!  ██      ██   ██  ███████ ███████ ███████ ██   ████ ██████  ██   ██   ██████    ██ 
!
!  Submodule    : free_energy_derivative_sub
!  Purpose      : Compute the derivative of the double-well free energy
!                 functional with respect to concentration (∂f/∂c).
!                 This forms the thermodynamic driving force for phase
!                 separation in the Cahn-Hilliard equation.
!
!  Author       : Shahid Maqbool
!  Date         : 16 June 2026
!  Version      : 1.0.0
!  License      : MIT
!
!  Parent Module : phase_field_module
!
!  Dependencies :
!    phase_field_module - Provides PhaseFieldGrid type and parent procedures
!    precision_module   - Provides r_sp, i_sp precision types
!    omp_lib            - OpenMP runtime library (conditional on USE_OPENMP)
!
!  Mathematical Formulation :
!    Free Energy Functional (Double-Well Potential):
!      f(c) = A · c² · (1-c)²
!
!    Free Energy Derivative (Chemical Potential):
!      df/dc = A · [2c·(1-c)² - 2c²·(1-c)]
!           = 2A · c · (1-c) · (1-2c)
!
!    Physical Interpretation:
!      - df/dc = 0  at c = 0  (stable phase 1)
!      - df/dc = 0  at c = 1  (stable phase 2)
!      - df/dc = A/4 at c = 0.5 (unstable, spinodal decomposition)
!
!    The double-well potential drives the system toward phase separation
!    into two equilibrium phases with minimal free energy.
!
!  Memory Usage : 2 arrays × Nx × Ny × 4 bytes (single precision)
!
!-------------------------------------------------------------------------------

submodule (phase_field_module) free_energy_derivative_sub
    use precision_module
#ifdef USE_OPENMP
    use omp_lib
#endif
    implicit none
    contains
    module procedure free_energy_derivative
    integer(i_sp) :: i, j

    ! Store A parameter
    this%A = A

    ! Compute derivative of free energy: df/dc = A*(2*c*(1-c)^2 - 2*c^2*(1-c))
    !$omp parallel do default(none) schedule(static) private(i, j) shared(this, A)
    do j = 1, this%Ny
        do i = 1, this%Nx
            this%dfdcon(i, j) = A * (2.0*this%con(i,j)*(1.0-this%con(i,j))*(1.0-this%con(i,j)) &
            - 2.0*this%con(i,j)*this%con(i,j)*(1.0-this%con(i,j)))
        end do
    end do
    !$omp end parallel do

    end procedure
end submodule


