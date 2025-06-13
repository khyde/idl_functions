; $ID:	MEAN_TAIL_TRIM.PRO,	2020-07-08-15,	USER-KJWH	$
;+
;	This Function Returns the Mean of a 2-d image using a moving rectangle (does not have to be square), after trimming the
;  tails
; SYNTAX:
;
;	Result = MEAN_TAIL_TRIM.PRO(Image,Width)
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

FUNCTION MEAN_TAIL_TRIM,Image,Width,_EXTRA=_extra
  ROUTINE_NAME='MEAN_TAIL_TRIM.PRO'
  SZ=SIZE(Image,/STRUCT)
  IF SZ.N_DIMENSIONS NE 2 THEN BEGIN
    PRINT,'ERROR: Image must be 2-dimensional array'
    RETURN,-1
  ENDIF
  IF N_ELEMENTS(Width) EQ 0 THEN BEGIN
    PRINT,'ERROR: Must provide width'
    RETURN, -1
  ENDIF
  TRIM = 1

  NTH=WIDTH[0]*WIDTH[1]-1
  START = TRIM
  FINISH = NTH - TRIM

  COPY=IMAGE
  NTH_X=SZ.DIMENSIONS[0]-Width[0]
  NTH_Y=SZ.DIMENSIONS[1]-Width[1]
  FOR X=0L,NTH_X  DO BEGIN
    FOR Y=0L,NTH_Y DO BEGIN
      Left=x
      right=x+width[0]-1
      bottom=y
      top = y+width[1]-1
      BOX = IMAGE(left:right,bottom:top)
      S=SORT(BOX)
      BOX=BOX(S)

      COPY(X,Y)= ROUND(MEAN(FLOAT(BOX(START:FINISH))))
    ENDFOR
  ENDFOR
  RETURN,COPY
END; #####################  End of Routine ################################
