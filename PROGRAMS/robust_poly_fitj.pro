; $ID:	ROBUST_POLY_FITJ.PRO,	2020-07-08-15,	USER-KJWH	$
FUNCTION ROBUST_POLY_FITJ,X,Y,NDEG,YFIT,SIG, NUMIT=THIS_MANY
;+
; NAME:
;	ROBUST_POLY_FIT
;
; PURPOSE:
;	An outlier-resistant polynomial fit.
;
; CALLING SEQUENCE:
;	COEFF = ROBUST_POLY_FIT(X,Y,NDEGREE  ,[ YFIT,SIG, NUMIT =] )
;
; INPUTS:
;	X = Independent variable vector, floating-point or double-precision
;	Y = Dependent variable vector
;
; OUTPUTS:
;	Function result = coefficient vector, length NDEGREE+1.
;	IF COEFF=0.0, NO FIT! If N_ELEMENTS(COEFF) > degree+1, the fit is poor
;	(in this case the last element of COEFF=0.)
;	Either floating point or double precision.
;
; OPTIONAL OUTPUT PARAMETERS:
;	YFIT = Vector of calculated y's
;	SIG  = the "standard deviation" of the residuals
;
; RESTRICTIONS:
;	Large values of NDEGREE should be avoided. This routine works best
;	when the number of points >> NDEGREE.
;
; PROCEDURE:
;	For the initial estimate, the data is sorted by X and broken into
;	NDEGREE+2 sets. The X,Y medians of each set are fitted to a polynomial
;	 via POLY_FIT.   Bisquare ("Tukey's Biweight") weights are then
;	calculated, using a limit  of 6 outlier-resistant standard deviations.
;	The fit is repeated iteratively until the robust standard deviation of
;	the residuals changes by less than .03xSQRT(.5/(N-1)).
;
; REVISION HISTORY
;	Written, H. Freudenreich, STX, 8/90. Revised 4/91.
;	2/94 -- changed convergence criterion
;-

ON_ERROR,2

EPS   = 1.0E-20
DEL   = 5.0E-07
DEGMAX= 6

IF N_ELEMENTS(THIS_MANY) GT 0 THEN ITMAX=THIS_MANY ELSE ITMAX=25

BADFIT=0

NPTS = N_ELEMENTS(X)
MINPTS=NDEG+1
IF (NPTS/4*4) EQ NPTS THEN NEED2 = 1 ELSE NEED2 = 0
N3 = 3*NPTS/4  &  N1 = NPTS/4

; If convenient, move X and Y to their centers of gravity:
IF NDEG LT DEGMAX THEN BEGIN
   X0=TOTAL(X)/NPTS  &  Y0=TOTAL(Y)/NPTS
   U=X-X0            &  V=Y-Y0
ENDIF ELSE BEGIN
   U=X               &  V=Y
ENDELSE

; The initial estimate.

; Choose an odd number of segments:
NUM_SEG = NDEG+2
IF (NUM_SEG/2*2) EQ NUM_SEG THEN NUM_SEG =NUM_SEG+1
MIN_PTS = NUM_SEG*3
IF NPTS LT 10000 THEN BEGIN ;MIN_PTS THEN BEGIN
;  Settle for least-squares:
   LSQFIT = 1
   CC = POLY_FIT( U, V, NDEG, YFIT )
ENDIF ELSE BEGIN
;  Break up the data into segments:
   LSQFIT = 0
   Q = SORT(U)
   U = U(Q)  &  V = V(Q)
   N_PER_SEG = INTARR(NUM_SEG)
   N_PER_SEG(*) = NPTS/NUM_SEG

;  Put the leftover points in the middle segment:
   N_LEFT = NPTS - N_PER_SEG[0]*NUM_SEG
   N_PER_SEG(NUM_SEG/2) = N_PER_SEG(NUM_SEG/2) + N_LEFT
   R = FLTARR(NUM_SEG)  &  S = FLTARR(NUM_SEG)
   R[0]=MED( U(0:N_PER_SEG[0]-1) ) & S[0]=MED( V(0:N_PER_SEG[0]-1) )
   I2 = N_PER_SEG[0]-1
   FOR I=1,NUM_SEG-1 DO BEGIN
     I1 = I2 + 1
     I2 = I1 + N_PER_SEG(I) - 1
     R(I) = MED( U(I1:I2) )     &  S(I) = MED( V(I1:I2) )
   ENDFOR
;  Now fit:
   CC = POLY_FIT( R,S, NDEG )
   YFIT = POLY(U,CC)
ENDELSE

ISTAT=ROB_CHECKFIT(V,YFIT,EPS,DEL,  SIG,FRACDEV,NGOOD,W,S)
IF ISTAT EQ 0 THEN GOTO,AFTERFIT

IF NGOOD LT MINPTS THEN BEGIN
   IF LSQFIT EQ 0 THEN BEGIN
      ;  Try a least-squares:
      CC = POLY_FIT( U, V, NDEG, YFIT )
      ISTAT=ROB_CHECKFIT(V,YFIT,EPS,DEL,  SIG,FRACDEV,NGOOD,W,S)
      IF ISTAT EQ 0 THEN GOTO,AFTERFIT
      NGOOD = NPTS-COUNT
   ENDIF
   IF NGOOD LT MINPTS THEN BEGIN
      PRINT,'ROBUST_POLY_FIT: No Fit Possible!'
      RETURN,0.
   ENDIF
ENDIF

; Now iterate until the solution converges:
CLOSE_ENOUGH = .03*SQRT(.5/(NPTS-1)) > DEL
DIFF= 1.0E10
SIG_1= (100.*SIG) < 1.0E20
NIT = 0
WHILE( (DIFF GT CLOSE_ENOUGH) AND (NIT LT ITMAX) ) DO BEGIN
  NIT=NIT+1
  SIG_2=SIG_1
  SIG_1=SIG
  CC= POLYFITW( U, V, W, NDEG, YFIT )
  ISTAT=ROB_CHECKFIT(V,YFIT,EPS,DEL,  SIG,FRACDEV,NGOOD,W,S)
  IF ISTAT EQ 0 THEN GOTO,AFTERFIT
  IF NGOOD LT MINPTS THEN BEGIN
     PRINT,'ROBUST_POLY_FIT: Questionable Fit!'
     BADFIT=1
     GOTO,AFTERFIT
  ENDIF
  DIFF = (ABS(SIG_1-SIG)/SIG) < (ABS(SIG_2-SIG)/SIG)
ENDWHILE

;IF NIT GE ITMAX THEN PRINT,'ROBUST_POLY_FIT: Did not converge in',ITMAX,$
;' iterations!'

AFTERFIT:
CC=REFORM(CC)

IF NDEG LT DEGMAX THEN BEGIN
CASE NDEG OF
 1: CC[0] = CC[0]-CC[1]*X0 + Y0
 2: BEGIN
   CC[0] = CC[0]-CC[1]*X0+CC(2)*X0^2 + Y0
   CC[1] = CC[1]-2.*CC(2)*X0
    END
 3: BEGIN
   CC[0] = CC[0]-CC[1]*X0+CC(2)*X0^2-CC(3)*X0^3 + Y0
   CC[1] = CC[1]-2.*CC(2)*X0+3.*CC(3)*X0^2
   CC(2) = CC(2)-3.*CC(3)*X0
    END
 4: BEGIN
   CC[0] = CC[0]-   CC[1]*X0+CC(2)*X0^2-CC(3)*X0^3+CC(4)*X0^4+ Y0
   CC[1] = CC[1]-2.*CC(2)*X0+3.*CC(3)*X0^2-4.*CC(4)*X0^3
   CC(2) = CC(2)-3.*CC(3)*X0+6.*CC(4)*X0^2
   CC(3) = CC(3)-4.*CC(4)*X0
    END
 5: BEGIN
   CC[0] = CC[0]-  CC[1]*X0+CC(2)*X0^2-CC(3)*X0^3+CC(4)*X0^4-CC(5)*X0^5+ Y0
   CC[1] = CC[1]-2.*CC(2)*X0+ 3.*CC(3)*X0^2- 4.*CC(4)*X0^3+5.*CC(5)*X0^4
   CC(2) = CC(2)-3.*CC(3)*X0+ 6.*CC(4)*X0^2-10.*CC(5)*X0^3
   CC(3) = CC(3)-4.*CC(4)*X0+10.*CC(5)*X0^2
   CC(4) = CC(4)-5.*CC(5)*X0
    END
 ENDCASE
ENDIF

; Calculate the fit at points X:
IF( N_PARAMS[0] GT 3 )THEN YFIT=POLY(X,CC)

IF BADFIT EQ 1 THEN CC=[CC,0.]

RETURN,CC
END
