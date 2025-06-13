; EQ_KW    June 8,1999

  FUNCTION EQ_CLEAR_WATER, LAMBDA=lambda, METHOD=method
;+
; NAME:
;       EQ_KW
;
; PURPOSE:
;       Compute light absorption coefficients for pure seawater
;       according to several references.
;
; CATEGORY:
;       Light
;
; CALLING SEQUENCE:
;       Result = EQ_KW()
;       Result = EQ_KW([412])
;       Result = EQ_KW([412,443,490,510,555],method='sb81')
;
; INPUTS:
;       None Required
;
; KEYWORD PARAMETERS:
;       METHOD:  May be "SB81" (Smith and Baker, 1981)
;                    or "P93'  (Pope 1993)
;                    or "PF97" (Pope and Fry, 1997)
;
;       LAMBDA:  Wavelength or array of wavelengths (nm)
;
; OUTPUTS:
;       kw for wavelengths between 400 and 700 nm at 1nm resolution or\
;       kw for each of the input wavelengths if LAMBDA array is provided.
;
; SIDE EFFECTS:
;       None.
;
; RESTRICTIONS:
;       Input wavelengths must range beteen 400 and 700nm.
;       Values of LAMBDA outside this range will return floating infiniy values
;
; PROCEDURE:
;       Straightforward.
;
; MODIFICATION HISTORY:
;       June 8,1999 Program Written by J. O'Reilly and S. Maritorena
;
;                   Stephane Mariorena provided Kw values for
;                   Smith & Baker (1981), Pope 93 and Pope & Fry 1997
;                   These were in S. Maritorena's program: AM_hyp2.pro
;
;-
;**************************************************************************************************




; ====================>
; Range of lambdas
  min_lambda = MIN(WL)
  max_lambda = MAX(WL)

; ====================>
; Default Method is Pope & Fry 1997
  IF NOT KEYWORD_SET(METHOD) THEN  METHOD = 'PF97'

  METHOD = STRUPCASE(METHOD)
  IF METHOD NE 'SB81' AND METHOD NE 'P93' AND METHOD NE 'PF97' THEN BEGIN
    PRINT, "ERROR: Method Must Be 'SB81' or 'P93' or 'PF97' "
    STOP
  ENDIF

  IF METHOD EQ 'SB81' THEN BEGIN
    Kw = Kw_SB81
    PRINT, 'Method: Smith & Baker 1981'
  ENDIF
  IF METHOD EQ 'P93'  THEN BEGIN
    Kw = Kw_P93
    PRINT, 'Method: Pope 1993"
  ENDIF
  IF METHOD EQ 'PF97' THEN BEGIN
    Kw = Kw_pf97
    PRINT, 'Method: Pope & Fry 1997"
  ENDIF

; ====================>
; Determine resolution of input lambdas


; ====================>
; Linearly Interpolate Kw to 1 nanometer resolution
  Kw = INTERPOL(Kw, WL, min_lambda+INDGEN(max_lambda-min_lambda+1))

; ====================>
; If array of Lambdas are provided then subset Kw
  IF N_ELEMENTS(LAMBDA) GE 1 THEN BEGIN
;   Round lambdas to nearest nanometer
    _lambda = ROUND(lambda)
;   Create an array of missing values (float infinity)
    arr = REPLICATE(!VALUES.F_INFINITY, N_ELEMENTS(LAMBDA))
;   Find the valid kw's
    OK = WHERE(_lambda GE min_lambda AND _lambda LE max_lambda, count)
    IF count GE 1 THEN BEGIN
;     Replace arr with valid values
      arr(ok) = Kw(_lambda(ok) - min_lambda)
    ENDIF
    kw = arr
  ENDIF



  RETURN, Kw


END ; END OF PROGRAM