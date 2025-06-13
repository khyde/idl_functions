; $ID:	REGRESS3.PRO,	2020-07-08-15,	USER-KJWH	$
FUNCTION REGRESS2, X, Y, W, YFIT=YFIT, A0=A0, SIGMA=SIGMA, FTEST=FTEST, R=R, RMUL=RMUL, CHISQ=CHISQ, SIGMA0=SIGMA0, RELATIVE_WEIGHT=RELATIVE_WEIGHT, VERBOSE=VERBOSE

;+
; NAME:
;        REGRESS2
;
; PURPOSE:
;   Multiple linear regression fit.  Fit the function:
;     Y(i) = A0 + A[0]*X(0,i) + A[1]*X(1,i) + ... + A(Nterms-1)*X(Nterms-1,i)
;
; CATEGORY:
;   G2 - Correlation and regression analysis.
;
; CALLING SEQUENCE:
;   Result = REGRESS(X, Y, W, [YFIT, A0, SIGMA, FTEST, R, RMUL, CHISQ])
;
; INPUTS:
;   X....... Array of independent variable data.  X must be dimensioned (Nterms, Npoints) where there are Nterms coefficients to be found (independent variables) and Npoints of samples.
;   Y....... Vector of dependent variable points, must have Npoints elements.
;   W....... Vector of weights for each equation, must be a Npoints elements vector.  
;              For instrumental weighting w(i) = 1/standard_deviation(Y(i)), 
;              For statistical weighting w(i) = 1./Y(i).   
;              For no weighting set w(i)=1, and also set the RELATIVE_WEIGHT keyword.
;
; OUTPUTS:
;   Function result = coefficients = vector of Nterms elements.  Returned as a column vector.
;
; OPTIONAL OUTPUT PARAMETERS:
;   YFIT.... Array of calculated values of Y, Npoints elements.
;   SIGMA... Vector of standard deviations for coefficients.
;   FTEST... Value of F for test of fit.
;   RMUL.... Multiple linear correlation coefficient.
;   R....... Vector of linear correlation coefficient.
;   Chisq... Reduced chi squared.
;   SIGMA0.. Standard deviation for A0
;
; KEYWORDS:
;   RELATIVE_WEIGHT..... If this keyword is set, the input weights (W vector) are assumed to be relative values, and not based
;                          on known uncertainties in the Y vector.  This is the case for no weighting W(*) = 1.
;   VERBOSE............. Print processing information
;   
; REFERENCE:
;   Adapted from the program REGRESS, Page 172, Bevington, Data Reduction and Error Analysis for the Physical Sciences, 1969.
;
; MODIFICATION HISTORY:
;        Written, DMS, RSI, September, 1982.
;        Added RELATIVE_WEIGHT keyword, W. Landsman, August 1991
;        29-AUG-1994:   H.C. Wen - Used simpler, clearer algorithm to determine fit coefficients. The constant term, A0 is now just one
;                         of the X(iterms,*) vectors, enabling the algorithm to now return the sigma associated with this constant term.
;                         I also made a special provision for the case when Nterm = 1; namely, "inverting" a 1x1 matrix, i.e. scalar.
;        26-MAR-1996:   Added the DOUBLE and CHECK keywords to the call to DETERM.
;        02-APR-1996:   Test matrix singularity using second argument in INVERT instead of call to DETERM.
;        AUG 28, 2018 - KJWH: Updated documentation and formatting to fit in within the NEFSC style
;                             Added IF KEYWORD_SET(VERBOSE) THEN to PRINT statements
;-

  ROUTINE_NAME = 'REGRESS2'
  
  ON_ERROR, 2              ; Return to caller if an error occurs

  NP = N_PARAMS()
  IF NP LT 3 OR NP GT 10 THEN MESSAGE,'ERROR: Must be called with 3-10 parameters: X, Y, W, [YFIT, SIGMA, FTEST, R, RMUL, CHISQ, SIGMAN0]'

; ===> Determine the length of the X and Y arrays and the number of sources
  SX    = SIZE(X)          ; Get the X dimensions
  SY    = SIZE(Y)          ; Get the Y dimensions
  NTERM = SX[1]            ; Number of terms
  NPTS  = SY[1]            ; Number of observations
  IF N_ELEMENTS(W) NE SY[1] OR SX[0] NE 2 OR SY[1] NE SX(2) THEN MESSAGE, 'ERROR: Incompatible arrays.'

  WW   = REPLICATE(1.,NTERM) # W
  CURV = (X*WW) # TRANSPOSE(X)
  BETA = X # (Y*W)

  IF NTERM EQ 1 THEN BEGIN
    SIGMA   = 1./SQRT(CURV)
    X_COEFF = BETA/CURV
  ENDIF ELSE BEGIN
    ERR = INVERT(CURV, STATUS)
    IF (STATUS EQ 1) THEN BEGIN
      IF KEYWORD_SET(VERBOSE) THEN PRINT,'DET (CURVATURE MATRIX)=0 ... USING REGRESS'
      X1 = X
      LINECHK = X(0,0) - X(0,FIX( NPTS*RANDOMU(SEED) ))
      IF LINECHK EQ 0 THEN BEGIN
        IF KEYWORD_SET(VERBOSE) THEN PRINT,'Cannot determine SIGMA for constant'
        X1  = X1(1:NTERM-1,*)
      ENDIF
      COEFF = REGRESS(X1,Y,W,YFIT,A0,SIGMA,FTEST,R,RMUL,CHISQ)
      IF LINECHK EQ 0 THEN BEGIN
        COEFF     = [A0,REFORM(COEFF)]
        SIGMA     = [ 0,REFORM(SIGMA)]
        R         = [ 0,R]
      ENDIF
        RETURN, COEFF
    ENDIF ELSE IF STATUS EQ 2 AND KEYWORD_SET(VERBOSE) THEN PRINT,'WARNING -- SMALL PIVOT ELEMENT USED IN MATRIX INVERSION.  SIGNIFICANT ACCURACY PROBABLY LOST...'  
      DIAG    = INDGEN(NTERM)
      SIGMA   = SQRT(ERR(DIAG,DIAG))
      X_COEFF = ERR # BETA
  ENDELSE
  
  YFIT  = TRANSPOSE(X_COEFF # X)                   ; Compute fit
  DOF   = NPTS - NTERM > 1                         ; Degrees of freedom
  CHISQ = TOTAL((Y-YFIT)^2.*W)                     ; Chi square
  CHISQ = CHISQ/DOF                                ; Weighted chi square

; ===> To calculate the "test of fit" parameters, we revert back to the original cryptic routine in REGRESS1. 
;        Because the constant term (if any) is now included in the X variable, NPAR = NTERM_regress2 = NTERM_regress1 + 1.

  IF NTERM EQ 1 THEN GOTO, SKIP

  SW    = TOTAL(W)                                 ; SUM OF WEIGHTS
  YMEAN = TOTAL(Y*W)/SW                            ; Y MEAN
  XMEAN = (X * (REPLICATE(1.,NTERM) # W)) # REPLICATE(1./SW,NPTS)
  WMEAN = SW/NPTS
  WW    = W/WMEAN
         
  NFREE  = NPTS-1                                  ; DEGREES OF FREEDOM
  SIGMAY = SQRT(TOTAL(WW * (Y-YMEAN)^2)/NFREE)     ; W*(Y(I)-YMEAN)
  XX     = X - XMEAN # REPLICATE(1.,NPTS)          ; X(J,I) - XMEAN(I)
  WX     = REPLICATE(1.,NTERM) # WW * XX           ; W(I)*(X(J,I)-XMEAN(I))
  SIGMAX = SQRT(XX*WX # REPLICATE(1./NFREE,NPTS))  ; W(I)*(X(J,I)-XM)*(X(K,I)-XM)
  R      = WX #(Y - YMEAN) / (SIGMAX * SIGMAY * NFREE)

  WW1   = WX # TRANSPOSE(XX)
  ARRAY = INVERT(WW1/(NFREE * SIGMAX #SIGMAX))
  A     = (R # ARRAY)*(SIGMAY/SIGMAX)              ; GET COEFFICIENTS

  FREEN = NPTS-NTERM > 1                           ; DEGS OF FREEDOM, AT LEAST 1.
  CHISQ = TOTAL(WW*(Y-YFIT)^2)*WMEAN/FREEN         ; WEIGHTED CHI SQUARED
  IF KEYWORD_SET(RELATIVE_WEIGHT) THEN VARNCE = CHISQ $
                                  ELSE VARNCE = 1./WMEAN

  RMUL = TOTAL(A*R*SIGMAX/SIGMAY)                  ; MULTIPLE LIN REG COEFF
  IF RMUL LT 1. THEN FTEST = RMUL/(NTERM-1)/ ((1.-RMUL)/FREEN) ELSE FTEST=1.E6
  RMUL = SQRT(RMUL)

  SKIP:    RETURN, X_COEFF

END

