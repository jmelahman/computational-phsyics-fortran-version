PROGRAM FINDBETA
IMPLICIT NONE
    REAL, DIMENSION(15) :: E
    REAL, PARAMETER :: PI=4.*ATAN(1.)
    REAL, PARAMETER :: V0=4.747
    REAL :: ENERGY
    REAL :: BETA
    REAL :: DBETA
    REAL :: AREA
    REAL :: SOURCE
    REAL :: GSOURCE
    REAL :: XIN,XOUT
    INTEGER :: I
!
    CALL FILLE(E)
    I = 0
10  CONTINUE
        BETA = 1.0
        DBETA = 0.1
        I = I+1
        IF (I > 15) STOP
        ENERGY = E(I)/V0
        AREA = (I-.5)*PI
20      BETA = BETA+DBETA
        CALL FINDTP(ENERGY,BETA,XIN,XOUT)
        CALL GAUSS_S(ENERGY,BETA,XIN,XOUT,GSOURCE)
        CALL CALC_S(ENERGY,BETA,XIN,XOUT,SOURCE)
!
        IF (AREA < SOURCE) GOTO 20
        IF (AREA > SOURCE-.00001) THEN
            BETA = BETA-DBETA
            DBETA = DBETA/2.0
            IF (DBETA < .000001) THEN
                PRINT *,'ENERGY',ENERGY*V0,'BETA',BETA
                PRINT *,'XIN',XIN,'XOUT',XOUT
                PRINT *,
                GOTO 10
            END IF
            GOTO 20
        END IF
END PROGRAM

SUBROUTINE FINDTP(ENERGY,BETA,XIN,XOUT)
IMPLICIT NONE
    REAL :: DX                  !STEP FOR INTITAL SEARCH
    REAL :: XMIN                !X VALUE FOR POTENTAL MINIMUM
    REAL :: ENERGY              !ENERGY (INPUT)
    REAL :: BETA                !BETA (INPUT)
    REAL :: XIN,XOUT            !TURNING POINTS (OUTPUT)
    REAL :: X                   !LOCAL VARIABLE
    REAL :: POT                 !POTENTIAL FUNCTION
    XMIN = .74166
    DX = 0.1
    X=XMIN
    DO WHILE (DX > .00001)
        X = X+DX
        IF (POT(BETA,X) > ENERGY) THEN
            X = X-DX
            DX = DX/2.0
        END IF
    END DO
    XOUT = X
!
    DX = 0.1
    X=XMIN
    DO WHILE (DX > .00001)
        X = X-DX
        IF (POT(BETA,X) > ENERGY) THEN
            X = X+DX
            DX = DX/2.0
        END IF
    END DO
    XIN = X
    RETURN
END SUBROUTINE FINDTP

SUBROUTINE GAUSS_S(ENERGY,BETA,XIN,XOUT,S)
IMPLICIT NONE
    REAL, DIMENSION(64)  :: XI,WI  !ABSCISSAS AND WEIGHTS
    REAL :: GAMMA = 21.7          !GAMMA (CONSTANT)
    REAL :: XIN,XOUT              !INTEGRAL LIMITS
    REAL :: VAL                   !INTEGRAL VARIABLES
    REAL :: S                     !AREA OF PHASE SPACE TRAJECTORY
    REAL :: ENERGY                !ENERY OF THE BOUND STATE (INPUT)
    REAL :: POT                   !POTENTIAL FUNCTION
    REAL :: BETA                  !INPUT
    REAL :: X                     !LOCAL VARIABLE
    INTEGER :: I                  !COUNTER
!
    GAMMA = 21.7
    S = 0.0
	CALL FILL64(XI,WI)
    DO I=1,64
        X = (XI(I)+1.)*(XOUT-XIN)/2.+XIN
!DX=(XOUT-XIN)/2*DXI
        VAL = SQRT(ENERGY-POT(BETA,X))*(XOUT-XIN)/2.
        S = S+VAL*WI(I)
    END DO
    S = GAMMA*S
    RETURN
END SUBROUTINE GAUSS_S


SUBROUTINE CALC_S(ENERGY,BETA,XIN,XOUT,S)
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!   USES BODE'S EQUATION TO ESTIMATE THE STANDARDIZED ACTION GIVEN
!   BY EQUATION 1.22 IN THE TEXT
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
IMPLICIT NONE
    REAL :: XIN,XOUT              !INTEGRAL LIMITS
    REAL :: H,X,VAL,SUM           !INTEGRAL VARIABLES
    REAL :: S                     !AREA OF PHASE SPACE TRAJECTORY
    REAL :: ENERGY                !ENERY OF THE BOUND STATE (INPUT)
    REAL :: POT                   !POTENTIAL FUNCTION
    REAL :: GAMMA                 !GAMMA CONSTANT
    REAL :: BETA
    INTEGER :: I                  !COUNTER
!
    H = (XOUT-XIN)/2000.0
    SUM = 0.0
    GAMMA = 21.7
    DO I=0,2000
        X = XIN+I*H
        S = SQRT(ENERGY-POT(BETA,X))
        VAL = 0.0
        IF (I == 0 .OR. I == 2000) THEN
            VAL = 14.0*H*S/45.0
        ELSE IF (MOD(I,2) == 1) THEN
            VAL = 64.0*H*S/45.0
        ELSE IF (MOD(I,4) == 2) THEN
            VAL = 24.0*H*S/45.0
        ELSE
            VAL = 28.0*H*S/45.0
        END IF
        SUM = SUM + VAL
    END DO
    S = GAMMA * SUM
    RETURN
END SUBROUTINE CALC_S

SUBROUTINE FILLE(E)
IMPLICIT NONE
    REAL, DIMENSION(15) :: E
!
    E(1) = -4.477
    E(2) = -3.962
    E(3) = -3.475
    E(4) = -3.017
    E(5) = -2.587
    E(6) = -2.185
    E(7) = -1.811
    E(8) = -1.466
    E(9) = -1.151
    E(10) = -0.867
    E(11) = -0.615
    E(12) = -0.400
    E(13) = -0.225
    E(14) = -0.094
    E(15) = -0.017
    RETURN
END SUBROUTINE

REAL FUNCTION POT(BETA,R)
IMPLICIT NONE
    REAL :: R
    REAL :: BETA
    REAL :: RMIN =.74166
    POT = (1.-EXP(-BETA*(R-RMIN)))**2-1.
    RETURN
END FUNCTION POT

SUBROUTINE FILL64(XI,WI)
IMPLICIT NONE
    REAL, DIMENSION(64)  :: XI,WI    !ABSCISSAS AND WEIGHTS
    XI(1) = -0.0243502926634244
    XI(2) = 0.0243502926634244
    XI(3) = -0.0729931217877990
    XI(4) = 0.0729931217877990
    XI(5) = -0.1214628192961206
    XI(6) = 0.1214628192961206
    XI(7) = -0.1696444204239928
    XI(8) = 0.1696444204239928
    XI(9) = -0.2174236437400071
    XI(10) = 0.2174236437400071
    XI(11) = -0.2646871622087674
    XI(12) = 0.2646871622087674
    XI(13) = -0.3113228719902110
    XI(14) = 0.3113228719902110
    XI(15) = -0.3572201583376681
    XI(16) = 0.3572201583376681
    XI(17) = -0.4022701579639916
    XI(18) = 0.4022701579639916
    XI(19) = -0.4463660172534641
    XI(20) = 0.4463660172534641
    XI(21) = -0.4894031457070530
    XI(22) = 0.4894031457070530
    XI(23) = -0.5312794640198946
    XI(24) = 0.5312794640198946
    XI(25) = -0.5718956462026340
    XI(26) = 0.5718956462026340
    XI(27) = -0.6111553551723933
    XI(28) = 0.6111553551723933
    XI(29) = -0.6489654712546573
    XI(30) = 0.6489654712546573
    XI(31) = -0.6852363130542333
    XI(32) = 0.6852363130542333
    XI(33) = -0.7198818501716109
    XI(34) = 0.7198818501716109
    XI(35) = -0.7528199072605319
    XI(36) = 0.7528199072605319
    XI(37) = -0.7839723589433414
    XI(38) = 0.7839723589433414
    XI(39) = -0.8132653151227975
    XI(40) = 0.8132653151227975
    XI(41) = -0.8406292962525803
    XI(42) = 0.8406292962525803
    XI(43) = -0.8659993981540928
    XI(44) = 0.8659993981540928
    XI(45) = -0.8893154459951141
    XI(46) = 0.8893154459951141
    XI(47) = -0.9105221370785028
    XI(48) = 0.9105221370785028
    XI(49) = -0.9295691721319396
    XI(50) = 0.9295691721319396
    XI(51) = -0.9464113748584028
    XI(52) = 0.9464113748584028
    XI(53) = -0.9610087996520538
    XI(54) = 0.9610087996520538
    XI(55) = -0.9733268277899110
    XI(56) = 0.9733268277899110
    XI(57) = -0.9833362538846260
    XI(58) = 0.9833362538846260
    XI(59) = -0.9910133714767443
    XI(60) = 0.9910133714767443
    XI(61) = -0.9963401167719553
    XI(62) = 0.9963401167719553
    XI(63) = -0.9993050417357722
    XI(64) = 0.9993050417357722
!
    WI(1) = 0.0486909570091397
    WI(2) = 0.0486909570091397
    WI(3) = 0.0485754674415034
    WI(4) = 0.0485754674415034
    WI(5) = 0.0483447622348030
    WI(6) = 0.0483447622348030
    WI(7) = 0.0479993885964583
    WI(8) = 0.0479993885964583
    WI(9) = 0.0475401657148303
    WI(10) = 0.0475401657148303
    WI(11) = 0.0469681828162100
    WI(12) = 0.0469681828162100
    WI(13) = 0.0462847965813144
    WI(14) = 0.0462847965813144
    WI(15) = 0.0454916279274181
    WI(16) = 0.0454916279274181
    WI(17) = 0.0445905581637566
    WI(18) = 0.0445905581637566
    WI(19) = 0.0435837245293235
    WI(20) = 0.0435837245293235
    WI(21) = 0.0424735151236536
    WI(22) = 0.0424735151236536
    WI(23) = 0.0412625632426235
    WI(24) = 0.0412625632426235
    WI(25) = 0.0399537411327203
    WI(26) = 0.0399537411327203
    WI(27) = 0.0385501531786156
    WI(28) = 0.0385501531786156
    WI(29) = 0.0370551285402400
    WI(30) = 0.0370551285402400
    WI(31) = 0.0354722132568824
    WI(32) = 0.0354722132568824
    WI(33) = 0.0338051618371416
    WI(34) = 0.0338051618371416
    WI(35) = 0.0320579283548516
    WI(36) = 0.0320579283548516
    WI(37) = 0.0302346570724025
    WI(38) = 0.0302346570724025
    WI(39) = 0.0283396726142595
    WI(40) = 0.0283396726142595
    WI(41) = 0.0263774697150547
    WI(42) = 0.0263774697150547
    WI(43) = 0.0243527025687109
    WI(44) = 0.0243527025687109
    WI(45) = 0.0222701738083833
    WI(46) = 0.0222701738083833
    WI(47) = 0.0201348231535302
    WI(48) = 0.0201348231535302
    WI(49) = 0.0179517157756973
    WI(50) = 0.0179517157756973
    WI(51) = 0.0157260304760247
    WI(52) = 0.0157260304760247
    WI(53) = 0.0134630478967186
    WI(54) = 0.0134630478967186
    WI(55) = 0.0111681394601311
    WI(56) = 0.0111681394601311
    WI(57) = 0.0088467598263639
    WI(58) = 0.0088467598263639
    WI(59) = 0.0065044579689784
    WI(60) = 0.0065044579689784
    WI(61) = 0.0041470332605625
    WI(62) = 0.0041470332605625
    WI(63) = 0.0017832807216964
    WI(64) = 0.0017832807216964
    RETURN
END SUBROUTINE
