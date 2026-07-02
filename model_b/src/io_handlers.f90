!!-------------------------------------------------------------------------------
!!            ██████  ██    ██ ████████ ██████  ██    ██  ████████
!!           ██    ██ ██    ██    ██    ██  ██  ██    ██     ██        
!!           ██    ██ ██    ██    ██    ██████  ██    ██     ██     
!!           ██    ██ ██    ██    ██    ██      ██    ██     ██       
!!            ██████   ██████     ██    ██      ████████     ██   
!!
!  Submodule    : output_results_sub
!  Purpose      : Output concentration field results to screen and binary file.
!                 Provides formatted output for visualization and analysis.
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
!    omp_lib            - OpenMP runtime library (conditional)
!
!  Output Formats :
!    Screen    : Displays a 5 x 5 sample of the concentration field with statistics
!    File      : Writes the complete concentration field in BINARY format
!
!  Binary File Format :
!    Header   : Magic number (0x12345678), version, grid dimensions, precision, statistics
!    Data     : Concentration field as 32-bit floats (row-major order)
!
!  I/O Strategy : Uses NEWUNIT for safe file unit assignment
!
!-------------------------------------------------------------------------------
submodule (phase_field_module) output_results_sub
    !===========================================================================
    !  SUBMODULE DEPENDENCIES
    !===========================================================================
    !
    !  phase_field_module : Provides the PhaseFieldGrid type containing:
    !                       - con    : concentration field
    !                       - Nx, Ny : grid dimensions
    !
    !  precision_module   : Provides r_sp and i_sp precision types
    !  omp_lib            : OpenMP runtime library (conditional)
    !
    !===========================================================================   
    use precision_module, only : r_sp, i_sp
#ifdef USE_OPENMP
    use omp_lib, only : omp_get_thread_num, omp_get_num_threads
#endif
    implicit none    
    !-----------------------------------------------------------------------------
    !  Local Constants
    !-----------------------------------------------------------------------------   
    ! Output formatting parameters
    integer, parameter :: SAMPLE_SIZE = 5                    ! Sample window size
    
    ! Binary file magic number (0x12345678)
    ! Must fit in 32-bit signed integer
    integer(i_sp), parameter :: MAGIC_NUMBER = 305419896_i_sp  ! 0x12345678
    
    ! Binary file format version
    integer(i_sp), parameter :: BINARY_VERSION = 1_i_sp
    
    ! Precision type identifiers
    integer(i_sp), parameter :: PRECISION_SINGLE = 1_i_sp
    integer(i_sp), parameter :: PRECISION_DOUBLE = 2_i_sp
    
    ! Output messages
    character(len=*), parameter :: HEADER_SAMPLE = '  === Concentration Sample (first 5 x 5) ==='
    character(len=*), parameter :: HEADER_FILE = '  ? Results written to: '

contains

    !-----------------------------------------------------------------------------
    !  module procedure : output_results
    !  Description      : Output the concentration field to screen and binary file.
    !                     Provides statistics, sample visualization, and complete
    !                     data export for post-processing.
    !
    !  Arguments        :
    !    this     - PhaseFieldGrid object (intent: in)
    !    filename - Output filename (intent: in)
    !
    !  Output           :
    !    Screen   : 5 x 5 sample of concentration values with statistics
    !    File     : Binary format with header and complete field
    !
    !  Binary File Structure :
    !    Offset | Type    | Description
    !    -------|---------|-------------------------------------------
    !    0      | int32   | Magic number (0x12345678) for validation
    !    4      | int32   | Format version (1)
    !    8      | int32   | Grid dimensions Nx
    !    12     | int32   | Grid dimensions Ny
    !    16     | int32   | Precision type (1=single, 2=double)
    !    20     | float32 | Min concentration value
    !    24     | float32 | Max concentration value
    !    28     | float32 | Mean concentration value
    !    32     | float32 | Data array (Nx x Ny) in row-major order
    !
    !  I/O Safety       : Uses NEWUNIT for automatic file unit assignment
    !-----------------------------------------------------------------------------
    module procedure output_results
        integer :: i, j
        integer :: fileunit
        integer :: sample_nx, sample_ny
        integer(i_sp) :: total_points
        real(r_sp) :: min_val, max_val, mean_val
        integer :: ierr       
        !=========================================================================
        !  Phase 1 : Statistics Calculation
        !=========================================================================
        ! Calculate total number of grid points
        total_points = int(this%Nx, i_sp) * int(this%Ny, i_sp)
        
        ! Compute concentration statistics
        min_val = minval(this%con)                 ! Minimum concentration
        max_val = maxval(this%con)                 ! Maximum concentration
        mean_val = sum(this%con) / real(total_points, r_sp)    ! Mean concentration
        
        !=========================================================================
        !  Phase 2 : Screen Output (Sample and Statistics)
        !=========================================================================       
        print *, ''
        print *, '  +----------------------------------------------------------------------+'
        print *, '  |                         OUTPUT RESULTS                               |'
        print *, '  +----------------------------------------------------------------------+'
        print *, '  |                                                                      |'
        print '(A, I6, A, I6, A)', &
            '   |    Grid size      : ', this%Nx, ' x ', this%Ny, '                                  |'
        print '(A, I12, A)', &
            '   |    Total points   : ', total_points, '                                     |'
        print '(A, F8.4, A, F8.4, A, F8.4, A)', &
            '   |    Statistics     : min = ', min_val, ', mean = ', mean_val, ', max = ', max_val, '  |'
        print *, '  |                                                                      |'
        print *, '  |    Concentration Sample (first ', SAMPLE_SIZE, 'x', SAMPLE_SIZE, '):         |'
        print *, '  |                                                                      |'
        
        ! Print 5x5 sample of the concentration field
        sample_nx = min(SAMPLE_SIZE, this%Nx)
        sample_ny = min(SAMPLE_SIZE, this%Ny)
        
        do i = 1, sample_nx
            write(*, '(A, $)') '   |      '
            do j = 1, sample_ny
                write(*, '(F10.6, $)') this%con(i, j)
            end do
            write(*, '(A)') '              |'
        end do
        
        print *, '  |                                                                      |'
        print '(A, A, A)', &
            '   |    Format         : BINARY (32-bit floats)                           |'
        print *, '  +----------------------------------------------------------------------+'
        print *, ''      
        !=========================================================================
        !  Phase 3 : Binary File Output
        !=========================================================================      
        ! Open file in binary format with automatic unit assignment
        open(newunit=fileunit, file=filename, status='replace', &
             form='unformatted', access='stream', action='write', iostat=ierr)
        
        ! Check for file open errors
        if (ierr /= 0) then
            print *, '  +----------------------------------------------------------------------+'
            print *, '  |                         FILE OPEN ERROR                              |'
            print *, '  +----------------------------------------------------------------------+'
            print '(A, A, A)', &
                '  |    ERROR: Could not open file: ', trim(filename), '                     |'
            print *, '  |    Please check file permissions and path.                           |'
            print *, '  +----------------------------------------------------------------------+'
            print *, ''
            return
        end if        
        !-----------------------------------------------------------------
        !  Write Binary Header
        !-----------------------------------------------------------------
        
		! Magic number for file validation (0x12345678)
        write(fileunit, iostat=ierr) MAGIC_NUMBER
        if (ierr /= 0) go to 100
        
		! Format version
        write(fileunit, iostat=ierr) BINARY_VERSION
        if (ierr /= 0) go to 100
        ! Grid dimensions
        write(fileunit, iostat=ierr) int(this%Nx, i_sp)
        if (ierr /= 0) go to 100
        
        write(fileunit, iostat=ierr) int(this%Ny, i_sp)
        if (ierr /= 0) go to 100
        
        ! Precision type (1 = single precision)
        write(fileunit, iostat=ierr) PRECISION_SINGLE
        if (ierr /= 0) go to 100
        
        ! Statistics
        write(fileunit, iostat=ierr) min_val
        if (ierr /= 0) go to 100
        
        write(fileunit, iostat=ierr) max_val
        if (ierr /= 0) go to 100
        
        write(fileunit, iostat=ierr) mean_val
        if (ierr /= 0) go to 100
        
        !-----------------------------------------------------------------
        !  Write Data Array (Row-major order)
        !-----------------------------------------------------------------   
        ! Write concentration field as binary stream
        write(fileunit, iostat=ierr) this%con
        if (ierr /= 0) go to 100     
        close(fileunit)
        !=========================================================================
        !  Phase 4 : Success Message
        !=========================================================================      
        print *, '  +----------------------------------------------------------------------+'
        print *, '  |                    BINARY OUTPUT SUCCESSFUL                          '
        print *, '  +----------------------------------------------------------------------+'
        print '(A, A, A)', &
            '   |    File           : ', trim(filename), '                                           |'
        print '(A, I12, A)', &
            '   |    Points written : ', total_points, '                                     |'
        print '(A, F12.2, A)', &
            '   |    File size      : ', real(32 + total_points * 4, r_sp) / 1024.0_r_sp, &
            ' KB                                  |'
        print '(A, A, A)', &
            '   |    Format         : BINARY (stream access)                           |'
        print *, '  +----------------------------------------------------------------------+'
        print *, ''
        return
        !=========================================================================
        !  Error Handling
        !=========================================================================
100     continue
        print *, '  +----------------------------------------------------------------------+'
        print *, '  |                         FILE WRITE ERROR                             |'
        print *, '  +----------------------------------------------------------------------+'
        print '(A, A, A)', &
            '  |    ERROR: Could not write to file: ', trim(filename), '                  |'
        print *, '  |    Please check disk space and file permissions.                    |'
        print '(A, I6, A)', &
            '  |    IOSTAT          : ', ierr, '                                                   |'
        print *, '  +----------------------------------------------------------------------+'
        print *, ''      
        close(fileunit)
    end procedure output_results
end submodule output_results_sub