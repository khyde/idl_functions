; $ID:	IMAGE_HIST_COL_ROW.PRO,	2020-07-08-15,	USER-KJWH	$
;+
;	This Function Returns the Median of a 2-d image using a moving rectangle (does not have to be square)
; SYNTAX:
;
;	Result = IMAGE_HIST_COL_ROW(Image,Width)
; OUTPUT:
;		Median of image
; ARGUMENTS:
; 	Image:	A 2-dimension array
; 	Width:	The size of the neighborhood to be used for the median filter (may be square or non-square)
; KEYWORDS:

; EXAMPLE:
; CATEGORY:
;		IMAGE
; NOTES:

; VERSION:
;		July 11, 2001
; HISTORY:
;		July 11, 2001	Written by:	J.E. O'Reilly, NOAA, 28 Tarzwell Drive, Narragansett, RI 02882
;-
; *************************************************************************

FUNCTION IMAGE_HIST_COL_ROW,Image
  ROUTINE_NAME='IMAGE_HIST_COL_ROW'
  SZ=SIZE(Image,/STRUCT)
  IF SZ.N_DIMENSIONS NE 2 THEN BEGIN
    PRINT,'ERROR: Image must be 2-dimensional array'
    RETURN,-1
  ENDIF
  WIDTH = [1,1]
  IF N_ELEMENTS(Width) EQ 0 THEN BEGIN
    PRINT,'ERROR: Must provide width'
    RETURN, -1
  ENDIF


  NTH_X=SZ.DIMENSIONS[0]-1
  NTH_Y=SZ.DIMENSIONS[1]-1
  MIN_VAL = 0
  MAX_VAL = MAX(IMAGE)

  X_BASE = HISTOGRAM(IMAGE,MIN=MIN_VAL,MAX=MAX_VAL,BINSIZE=1)
  X_BASE(*) = 0
  Y_BASE = X_BASE
  FOR X=0L,NTH_X  DO BEGIN
     X_BASE = X_BASE + HISTOGRAM(IMAGE(X,*),MIN=MIN_VAL,MAX=MAX_VAL,BINSIZE=1)
  ENDFOR

  FOR Y=0L,NTH_Y  DO BEGIN
     Y_BASE = Y_BASE + HISTOGRAM(IMAGE(*,Y),MIN=MIN_VAL,MAX=MAX_VAL,BINSIZE=1)
  ENDFOR
  STOP

END; #####################  End of Routine ################################
