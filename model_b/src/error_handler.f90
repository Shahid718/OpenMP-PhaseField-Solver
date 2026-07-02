!-------------------------------------------------------------------------------
!             ███████  ██████   ██████    ██████    ██████  
!             ██      ██    ██ ██    ██  ██    ██  ██    ██ 
!             █████   ██████   ██████    ██    ██  ██████  
!             ██      ██   ██  ██   ██   ██    ██  ██   ██
!             ███████ ██    ██ ██    ██   ██████   ██    ██
!
!  Module       : error_status_module
!  Purpose      : Error handling and status checking for array allocations
!                 and memory management operations.
!
!  Author       : Shahid Maqbool
!  Date         : 20 January 2025
!  Version      : 1.0.0
!  License      : MIT
!
!  Description  :
!    This module provides error handling utilities for the phase-field
!    simulation code. It centralizes allocation status checking and
!    provides consistent error reporting across all submodules.
!
!  Features     :
!    ✓ Allocation status checking
!    ✓ Standardized error reporting
!    ✓ Consistent output formatting
!    ✓ Integration with ISO_FORTRAN_ENV
!    ✓ Precision-aware integer handling
!
!  Dependencies :
!    iso_fortran_env - Provides error_unit for standard error output
!    precision_module - Provides i_sp precision type
!
!  Usage        :
!    use error_status_module, only : check_allocation_status, ALLOCATION_ERR
!    integer(i_sp) :: istat
!    allocate(array(N), stat=istat)
!    call check_allocation_status(istat)
!
!-------------------------------------------------------------------------------
module error_status_module
    !===========================================================================
    !  MODULE DEPENDENCIES
    !===========================================================================
    !
    !  iso_fortran_env  : Provides error_unit for standardized error output
    !                     (unit number for error messages)
    !
    !  precision_module : Provides i_sp precision type for status codes
    !
    !===========================================================================
    use, intrinsic :: iso_fortran_env, only : error_unit
    use precision_module, only : i_sp
    implicit none
    !===========================================================================
    !  PUBLIC CONSTANTS
    !===========================================================================
    !-----------------------------------------------------------------------------
    !  ALLOCATION_ERR : Allocation error status code
    !  Description    : Returned when array allocation fails
    !  Value          : 1
    !  Usage          : if (istat == ALLOCATION_ERR) then ...
    !-----------------------------------------------------------------------------
    integer(i_sp), parameter, public :: ALLOCATION_ERR = 1_i_sp
    !-----------------------------------------------------------------------------
    !  SUCCESS : Success status code
    !  Description    : Returned when operation completes successfully
    !  Value          : 0
    !  Usage          : if (istat == SUCCESS) then ...
    !-----------------------------------------------------------------------------
    integer(i_sp), parameter, public :: SUCCESS = 0_i_sp
    !-----------------------------------------------------------------------------
    !  Error Message Templates
    !-----------------------------------------------------------------------------
    character(len=*), parameter :: ERROR_MSG_ALLOC = &
    '   ERROR: Memory allocation failed for arrays.'
    character(len=*), parameter :: SUCCESS_MSG_ALLOC = &
    '   Arrays allocated successfully.'
    character(len=*), parameter :: WARNING_MSG_INVALID = &
    '   WARNING: Invalid status code provided.'
    Contains
    !-----------------------------------------------------------------------------
    !  subroutine : check_allocation_status
    !  Description : Check the allocation status of arrays and print appropriate
    !                messages. If allocation fails, the program stops with an
    !                error message.
    !
    !  Arguments   :
    !    istat - Allocation status code (intent: in)
    !            - 0  : Success
    !            - >0 : Error code
    !
    !  Error Handling :
    !    If istat /= 0, prints error message to error_unit and stops program.
    !    If istat == 0, prints success message to standard output.
	!
    !---------------------------------------------------------------------------	
    subroutine check_allocation_status(istat)
        integer(i_sp), intent(in) :: istat
        !=========================================================================
        !  Phase 1 : Print Status Banner
        !=========================================================================
        print *, ''
        print *, '|======================================================|'
        print *, '|            ALLOCATION STATUS CHECK                   |'
        print *, '|======================================================|'
        !=========================================================================
        !  Phase 2 : Evaluate Allocation Status
        !=========================================================================
        if (istat /= 0_i_sp) then
            !---------------------------------------------------------------------
            !  Error Case : Allocation Failed
            !---------------------------------------------------------------------
            ! Write error message to standard error unit
            write(error_unit, '(A)') '  |                                                     |'
            write(error_unit, '(A)') '  |    X ERROR: Memory allocation failed!               |'
            write(error_unit, '(A, I12, A)')'  |  Status code  : ', istat,'                        |'
            write(error_unit, '(A)') '  |                                                     |'                              
            write(error_unit, '(A)') '  |                                                     |'
            write(error_unit, '(A)') '  |    Possible causes:                                 |'
            write(error_unit, '(A)') '  |      - Insufficient system memory                   |'
            write(error_unit, '(A)') '  |      - Requested array too large                    |'
            write(error_unit, '(A)') '  |      - Memory fragmentation                         |'
            write(error_unit, '(A)') '  |                                                     |'
            write(error_unit, '(A)') '  |    Solutions:                                       |'
            write(error_unit, '(A)') '  |      - Reduce grid size (Nx, Ny)                    |'
            write(error_unit, '(A)') '  |      - Use smaller precision (r_sp instead of r_dp) |'
            write(error_unit, '(A)') '  |      - Increase system memory                       |'
            write(error_unit, '(A)') '  -------------------------------------------------------'
            print *, ''            
            ! Terminate program with error code 1
            stop 1
        else
            !---------------------------------------------------------------------
            !  Success Case : Allocation Successful
            !---------------------------------------------------------------------
            print *, '|                                                      |'
            print *, '|     SUCCESS: Memory allocation successful!           |'
            print '(A, I12, A)',  ' |    Status code    : ', istat, '                     |'
            print *, '|                                                      |'
            print *, '|    All arrays have been allocated and initialized.   |'
            print *, '|    Ready for simulation.                             |'
            print *, '|                                                      |'
            print *, '|======================================================|'
        end if
    end subroutine check_allocation_status

end module error_status_module