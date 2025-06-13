; $ID:	DETREND.PRO,	2020-06-30-17,	USER-KJWH	$

  FUNCTION DETREND, Xarray ,Yarray, MISSING=missing,REG_TYPE=REG_type,STRUCT=struct

;+
; NAME:
;       DETREND
;
; PURPOSE:
;       Remove a time trend (linear variation in y as a function of x (time)
;
;
; CATEGORY:
;       Math
;
; CALLING SEQUENCE:
;       RESULT = DETREND(xarray,yarray)
;
; INPUTS:
;       xARRAY
;				yARRAY

;
; KEYWORD PARAMETERS:   ROW:  works on the rows instead of the columns
;   MISSING:  Your code for missing data
;             1)The program sets values equal to your missing code to NAN;
;             2)The NAN's are not used to compute the Linear Regression,
;             3)The array returned has NAN's substituted for values
;               you specify as missing.
;		TYPE:			See STATS2  type='0' is default for this program because we assume that
;             the x variable (xarray) is Time and is measured without error
;
;
; OUTPUTS:
;       An DETRENDED Yarray
;
; SIDE EFFECTS:
;       The returned array will be float or double
;
;       IF missing code provided then
;       the returned array will have NAN's substuted for any missing values.
;
; RESTRICTIONS:
;       1 DIMENSIONAL ARRAYS
;
; PROCEDURE:
;       Straightforward.
;
; MODIFICATION HISTORY:
;       Written by:  J.E.O'Reilly ,April 9, 2002
;-

; ==================>
; Check the size of the input array
  Sx=SIZE(xARRAY,/struct)
  Sy=SIZE(yARRAY,/struct)
  IF Sx.N_dimensions EQ 0 OR Sx.N_dimensions GT 1 OR SY.N_dimensions EQ 0 OR SY.N_dimensions GT 1THEN RETURN,-1 ; Can not handle 0 OR 3 dimensions
  IF Sx.N_ELEMENTS NE Sy.N_ELEMENTS THEN RETURN,-1


  IF N_ELEMENTS(REG_TYPE) NE 1 THEN _REG_TYPE = 'RMA' ELSE _REG_TYPE = REG_TYPE[0]

; ====================>
; Make a copy of the input array
; The copy will be ALWAYS double
;
	XCOPY = DOUBLE(XARRAY)
  YCOPY = DOUBLE(YARRAY)

; ====================>
; If Missing code provided then substitute NAN for these values
  IF N_ELEMENTS(MISSING) EQ 1 THEN _MISSING = MISSING ELSE _MISSING = MISSINGS(XCOPY)
  bad = WHERE(XCOPY EQ _MISSING OR YCOPY EQ _MISSING,COUNT_MISSING)
  IF COUNT_MISSING GE 1 THEN BEGIN
  	XCOPY(bad) = MISSINGS(XCOPY)
  	YCOPY(bad) = MISSINGS(YCOPY)
  ENDIF

; **********************> STATS2 LINEAR REGRESSION
  struct=STATS2(XARRAY,YARRAY,/QUIET,MODEL=_REG_TYPE)

	Y_MODEL= struct.INT + struct.SLOPE*XARRAY




  RETURN, YARRAY-Y_MODEL

  END ; END OF PROGRAM
