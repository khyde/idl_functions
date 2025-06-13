; $ID:	CHARSCALE.PRO,	2020-07-08-15,	USER-KJWH	$

 FUNCTION CHARSCALE, Charsize
;+
; NAME:
;       CHARSCALE
;
; PURPOSE:
;       Scales the size of Characters in proportion to the available plot window (useful when !P.MULTI is set to make many plots on one page)
;
; CATEGORY:
;       Graphics
;
; CALLING SEQUENCE:
;       CHARSIZE=CHARSCALE()
;
; KEYWORD PARAMETERS:
;		NONE
;
; MODIFICATION HISTORY:
;       Written by:  J.E.O'Reilly, March 18, 2004
;-

	ROUTINE_NAME='CHARSCALE'

 IF N_ELEMENTS(Charsize) NE 1 THEN CHARSIZE = 1.0
; ===>
  XYZ=CONVERT_COORD(0,1.0*!d.y_ch_size,/DEVICE,/TO_DATA)
  CHARSIZE =!Y.REGION[1]-!Y.REGION[0]

  PRINT, CHARSIZE
  IF !P.CHARSIZE NE 0 THEN CHARSIZE=!P.CHARSIZE*CHARSIZE

	RETURN,CHARSIZE

  END; #####################  End of Routine ################################
