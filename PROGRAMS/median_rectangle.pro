; $ID:	MEDIAN_RECTANGLE.PRO,	2020-07-08-15,	USER-KJWH	$
;+
;	This Function Returns the Median of a 2-d image using a moving rectangle (does not have to be square)
; SYNTAX:
;
;	Result = MEDIAN_RECTANGLE(Image,Width)
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

FUNCTION MEDIAN_RECTANGLE,Image,Width,_EXTRA=_extra
  ROUTINE_NAME='MEDIAN_RECTANGLE'
  SZ=SIZE(Image,/STRUCT)
  IF SZ.N_DIMENSIONS NE 2 THEN BEGIN
    PRINT,'ERROR: Image must be 2-dimensional array'
    RETURN,-1
  ENDIF
  IF N_ELEMENTS(Width) EQ 0 THEN BEGIN
    PRINT,'ERROR: Must provide width'
    RETURN, -1
  ENDIF

  COPY=IMAGE
  NTH_X=SZ.DIMENSIONS[0]-1
  NTH_Y=SZ.DIMENSIONS[1]-1

  HALF_X = WIDTH[0]/2
  HALF_Y = WIDTH[1]/2
  FOR X=0L,NTH_X  DO BEGIN
    FOR Y=0L,NTH_Y DO BEGIN

      Left= 0 > (x-HALF_X) < NTH_X
      right=0 > (x+HALF_X) < NTH_X
      bottom= 0 > (y-HALF_Y) < NTH_Y
      top   = 0 > (y+HALF_Y) < NTH_Y
      BOX = IMAGE(left:right,bottom:top)
      COPY(X,Y)=MEDIAN(BOX,_EXTRA=_extra)
    ENDFOR
  ENDFOR
  RETURN,COPY
END; #####################  End of Routine ################################
