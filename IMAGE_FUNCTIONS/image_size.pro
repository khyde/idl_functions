; $ID:	IMAGE_SIZE.PRO,	2020-07-08-15,	USER-KJWH	$

FUNCTION IMAGE_SIZE,IMAGE
;+
; NAME:
;       IMAGE_SIZE
;
; PURPOSE: Return a structure with size and other aspects of an image
;
;	KEYWORDS:
;			NONE
;
; CALLING SEQUENCE:
;				image = BYTARR(1024,1024)
;       Result = IMAGE_SIZE(IMAGE)       ; Provide an image array
;				OR
;				RESULT = IMAGE_SIZE([1024,1024]) ; You may just provide dimensions of image
;
;       Written by:  J.E.O'Reilly, October 4, 2006
;-

	ROUTINE_NAME = 'IMAGE_SIZE'

; ===> Determine size of image
  s=SIZE(IMAGE,/STRUCT)
   IF s.N_DIMENSIONS EQ 3 THEN BEGIN ; Image is 3-dimensions
    px = s.DIMENSIONS[1] & py=s.DIMENSIONS(2)
  ENDIF
  IF s.N_DIMENSIONS EQ 2 THEN BEGIN ; Image is 2-dimensions
    px = s.DIMENSIONS[0] & py=s.DIMENSIONS[1]
  ENDIF
  IF s.N_DIMENSIONS EQ 1 THEN BEGIN ; Image is array with 2 elements specifying dimensions
    IF s.N_ELEMENTS  EQ 2 THEN BEGIN
      px = IMAGE[0] & py = image[1]
    ENDIF
  ENDIF


  STOP
	RETURN, STRUCT

END; #####################  End of Routine ################################
