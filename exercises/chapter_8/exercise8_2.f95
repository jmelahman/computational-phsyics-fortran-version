PROGRAM EXERCISE8_2
IMPLICIT NONE
    REAL :: X
    REAL :: FUNC
    REAL :: SUMF,SUMF2
    REAL :: FAVE,F2AVE
    REAL :: SIGMA
    INTEGER :: I
    INTEGER :: N
!
    FUNC(X) = X*X*X
!    FUNC(X) = X*X
!    FUNC(X) = X
    OPEN(20,FILE='/home/jamison/Dropbox/Summer Research/exercises/Chapter 8/exercise8_2.dat')
10  PRINT *,'ENTER NUMBER OF POINTS (0 TO STOP)'
    READ *,N
    SUMF = 0.0
    SUMF2 = 0.0
    IF (N .EQ. 0) STOP
    DO I=1,N
        CALL INIT_RANDOM_SEED()
        CALL RANDOM_NUMBER(X)
        X = -LOG(1.-X)
        SUMF = SUMF+FUNC(X)
        SUMF2 = SUMF2+FUNC(X)*FUNC(X)
    END DO
    FAVE = SUMF/N
    F2AVE = SUMF2/N
    SIGMA = SQRT((F2AVE-FAVE*FAVE)/N)
    PRINT*,'ESTIMATE',FAVE,'+/-',SIGMA
    GOTO 10
END PROGRAM

SUBROUTINE INIT_RANDOM_SEED()
USE ISO_FORTRAN_ENV, ONLY: INT64
IMPLICIT NONE
    INTEGER, ALLOCATABLE :: SEED(:)
    INTEGER :: I, N, UN, ISTAT, DT(8), PID
    INTEGER(INT64) :: T

    CALL RANDOM_SEED(SIZE = N)
    ALLOCATE(SEED(N))
! FALLBACK TO XOR:ING THE CURRENT TIME AND PID. THE PID IS
! USEFUL IN CASE ONE LAUNCHES MULTIPLE INSTANCES OF THE SAME
! PROGRAM IN PARALLEL.
    CALL SYSTEM_CLOCK(T)
    PID = GETPID()
    T = IEOR(T, INT(PID, KIND(T)))
    DO I = 1, N
        SEED(I) = LCG(T)
    END DO
    CALL RANDOM_SEED(PUT=SEED)
CONTAINS
! THIS SIMPLE PRNG MIGHT NOT BE GOOD ENOUGH FOR REAL WORK, BUT IS
! SUFFICIENT FOR SEEDING A BETTER PRNG.
FUNCTION LCG(S)
    INTEGER :: LCG
    INTEGER(INT64) :: S

    IF (S == 0) THEN
        S = 104729
    ELSE
        S = MOD(S, 4294967296_INT64)
    END IF
    S = MOD(S * 279470273_INT64, 4294967291_INT64)
    LCG = INT(MOD(S, INT(HUGE(0), INT64)), KIND(0))
END FUNCTION LCG
END SUBROUTINE INIT_RANDOM_SEED
