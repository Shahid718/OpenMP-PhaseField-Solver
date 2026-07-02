!-------------------------------------------------------------------------------
!  ██ ███    ██ ██ ████████ ██  █████  ██      ██         
!  ██ ████   ██ ██    ██    ██ ██   ██ ██      ██                
!  ██ ██ ██  ██ ██    ██    ██ ███████ ██      ██            
!  ██ ██  ██ ██ ██    ██    ██ ██   ██ ██      ██                  
!  ██ ██   ████ ██    ██    ██ ██   ██ ███████ ███████    
!
!  Submodule    : init_microstructure_sub
!  Purpose      : Initialize the phase-field microstructure with 
!                 random noise perturbations around a base concentration
!
!  Author       : Shahid Maqbool
!  Date         : 16 June 2026
!  Version      : 1.0.0
!  License      : MIT
!
!  Algorithm    : 
!    1. Generate uniform random field [0,1] using random_number()
!    2. Map to concentration: c = c0 + noise * (0.5 - r)
!
!  Performance  : Parallelize with OpenMP for large grids
!  Precision    : Single-precision (r_sp) for all floating-point operations
!
!-------------------------------------------------------------------------------
submodule (phase_field_module) init_microstructure_sub
    use precision_module
    implicit none
contains
    module procedure init_microstructure
        integer(i_sp) :: i, j
        
        ! Store initial concentration
        this%c0 = c0
        
        ! Initialize random seed
        call random_seed()
        
        ! Generate random field serially, then parallelize the deterministic map.
        call random_number(this%r)

        do j = 1, this%Ny
            do i = 1, this%Nx
                this%con(i, j) = c0 + noise * (0.5 - this%r(i, j))
            end do
        end do
        
      write(*, '(A, F8.4)') '  c0     : ', c0
      write(*, '(A, F8.4)') '  noise  : ', noise
      write(*, '(A)') ''
        
    end procedure
end submodule
