; $ID:	BIWEIGHT_MEAN.PRO,	2020-06-30-17,	USER-KJWH	$
;+NAME/ONE LINE DESCRIPTION OF ROUTINE:
;    BIWEIGHT_MEAN calculates the center and dispersion of a distribution
;    using bisquare weighting.
;
;NAME:
; Biweight_Mean
;
;PURPOSE:
; Calculate the center and dispersion (like mean and sigma) of a distribution
; using bisquare weighting.
;
;CALLING SEQUENCE:
; MEAN = BIWEIGHT_MEAN( VECTOR, SIGMA, WEIGHTS )
;
;INPUT ARGUMENT:
; Y = Distribution in vector form
;
;RETURNS:
; The location of the center.
;
;OPTIONAL OUTPUT ARGUMENTS:
; SIGMA = An outlier-resistant measure of the dispersion about the
;         center, analogous to the standard deviation OF THE MEAN.
;
; WEIGHTS = The weights applied to the data in the last iteration.
;
;SUBROUTINE CALLS:
; MED, which calculates a median
;
;AUTHOR: H. Freudenreich, STX, 12/89
;-
FUNCTION                    BIWEIGHT_MEAN,Y,SIGMA, WEIGHTs

  EPS = 1.0E-24
  CLOSE_ENOUGH = .000001 ; When center changes < .00001*sigma, we are through.
  MAXIT = 20 ; Allow 20 iterations

; As an initial estimate of the center, use the median:
  Y0=MED(Y)

; Calculate the weights:
  DEV = ABS( Y-Y0 )
  MAD = MED(DEV)/.675
  IF MAD LT eps THEN MAD = AVG(DEV)/.8
  IF MAD LT eps THEN BEGIN
     SIGMA = 0.
     RETURN,Y0
  ENDIF

; Repeat:
  PREV_Y0 = 10.*Y0
  DIFF = 1.0E30
  ITNUM = 0
  WHILE( (DIFF GT CLOSE_ENOUGH) AND (ITNUM LT MAXIT) ) DO BEGIN
    ITNUM = ITNUM + 1
;   Re-calculate the spread if this is the second iteration:
    IF ITNUM EQ 2 THEN BEGIN
       DEV = ABS( Y-Y0 )
       MAD = MED(DEV)/.675
       IF MAD LT eps THEN MAD = AVG(DEV)/.8
       IF MAD LT eps THEN BEGIN
          PRINT,' BIWEIGHT_MEAN: median absolute deviation = 0!'
          SIGMA=0.
          RETURN,Y0
       ENDIF
    ENDIF
    UU = ( (Y-Y0)/(6.*MAD) )^2
    Q=WHERE(UU GT 1.) & IF Q[0] GE 0 THEN UU(Q)=1.
    W=(1.-UU)^2
    Y0 = TOTAL( W*Y )/TOTAL( W )
    DIFF = ABS(PREV_Y0-Y0)/MAD
    PREV_Y0 = Y0
  ENDWHILE

  IF( N_PARAMS[0] GT 1 )THEN BEGIN
;    Now a measure of the dispersion:
     Q = WHERE(UU LE 1.0)
     IF (Q[0] LT 0) THEN BEGIN
        PRINT,'  BIWEIGHT_MEAN admits defeat. Returning the median. S=-1.'
        SIGMA = -1.
        RETURN,Y0
     ENDIF
     NUMERATOR = TOTAL( (Y(Q)-Y0)^2 * (1-UU(Q))^4 )
     DEN1 = TOTAL( (1.-UU(Q))*(1.-5.*UU(Q)) )
     N = N_ELEMENTS(Y)
     IF ABS(DEN1-1.) LT 1.0E-6 THEN SIGMA = NUMERATOR/DEN1^2 $
                               ELSE SIGMA = NUMERATOR/(DEN1*(DEN1-1.))
     SIGMA = SQRT(SIGMA)
  ENDIF

  IF( N_PARAMS[0] GT 2 )THEN WEIGHTS = W/TOTAL(W)

RETURN,Y0
END
