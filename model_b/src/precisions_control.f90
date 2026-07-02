!-------------------------------------------------------------------------------
!  ██████  ██████  ███████  ██████ ██ ███████ ██  ██████  ███    ██ 
!  ██   ██ ██   ██ ██      ██      ██ ██      ██ ██    ██ ████   ██ 
!  ██████  ██████  █████   ██      ██ ███████ ██ ██    ██ ██ ██  ██ 
!  ██      ██   ██ ██      ██      ██      ██ ██ ██    ██ ██  ██ ██ 
!  ██      ██   ██ ███████  ██████ ██ ███████ ██  ██████  ██   ████ 
!
!  Module       : precision_module
!  Purpose      : Define precision and range parameters for the entire program.
!                 Provides consistent precision types across all modules.
!
!  Author       : Shahid Maqbool
!  Date         : 20 Jan 2025
!  Version      : 1.0.0
!  License      : MIT
!
!  Description  :
!    This module defines standard precision types for integers and reals
!    using the ISO_FORTRAN_ENV intrinsic module. All other modules in the
!    project USE this module to ensure consistent precision throughout.
!
!  Features     :
!    Single precision real   : r_sp (32-bit, ~7 decimal digits)
!    Double precision real   : r_dp (64-bit, ~15 decimal digits)
!    Single precision integer: i_sp (32-bit, range: -2e9 to 2e9)
!    Double precision integer: i_dp (64-bit, range: -9e18 to 9e18)
!    ISO_FORTRAN_ENV standard compliance
!
!  Dependencies :
!    iso_fortran_env - Provides int32, int64, real32, real64 constants
!
!  Usage        :
!    use precision_module, only : r_sp, r_dp, i_sp, i_dp
!    real(r_sp) :: single_precision_var
!    real(r_dp) :: double_precision_var
!    integer(i_sp) :: single_precision_int
!    integer(i_dp) :: double_precision_int
!
!  Performance  :
!    - Use r_sp for memory-constrained applications (4 bytes/element)
!    - Use r_dp for high-precision calculations (8 bytes/element)
!    - Use i_sp for standard integer operations (4 bytes)
!    - Use i_dp for large integer ranges (8 bytes)
!-------------------------------------------------------------------------------

module precision_module
    use, intrinsic :: iso_fortran_env, only : int32, int64, real32, real64
    implicit none
    
    ! Integer precision
    integer, parameter :: i_sp = int32   ! 32-bit integer  (-2.1e9 to 2.1e9)
    integer, parameter :: i_dp = int64   ! 64-bit integer  (-9.2e18 to 9.2e18)
    
    ! Real precision
    integer, parameter :: r_sp = real32  ! 32-bit real (~7 digits)
    integer, parameter :: r_dp = real64  ! 64-bit real (~15 digits)
    
end module precision_module
