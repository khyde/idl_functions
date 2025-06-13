; $ID:	SHIFTIMAGE.PRO,	2020-07-08-15,	USER-KJWH	$

FUNCTION SHIFTIMAGE, image, xshift,yshift, MISSING=missing
;+
; NAME:
;       SHIFTIMAGE
;
; PURPOSE:
;       Navigate (shift) an image by xshift and yshift
;
; CATEGORY:
;       IMAGE
;
; CALLING SEQUENCE:
;       Result = SHIFTIMAGE(IMAGE,2,-2)
;
; INPUTS:
;       A 2 DIMENSIONAL ARRAY
;       XSHIFT (+ IS RIGHT, - IS LEFT)
;       YSHIFT (+ IS UP, - IS DOWN)
;
; KEYWORD PARAMETERS:
;       NONE
; OUTPUTS:
;       A SHIFTED IMAGE; NOTE THAT MISSING VALUES (SEE MISSINGS.PRO)
;
;
; SIDE EFFECTS:
;       THIS PROGRAM DOES NOT WRAP AROUND THE DATA BUT INSTEAD
;       SUBSTITUTES A MISSING CODE FOR PIXELS THAT ARE NOT MAPPABLE
;
; RESTRICTIONS:
;       IMAGES MUST BE 2-DIMENSIONS
;
; PROCEDURE:
;       Straightforward.
;
; MODIFICATION HISTORY:
;       Written by:  J.E.O'Reilly, March 8,1999
;       June 18, 1999  modified to allow user to specify a missing value
;                      Fixed error (1 pixel off)
;-

; ==============>
; MAKE SURE IMAGE ARRAY IS 2-D
  SZ = SIZE(IMAGE)
  IF SZ[0] NE 2 THEN RETURN, -1L

; ==============>
; IF no xshift and yshift then return
  IF N_ELEMENTS(XSHIFT) NE 1 OR N_ELEMENTS(YSHIFT) NE 1 THEN RETURN, IMAGE

; ==============>
; IF XSHIFT AND YSHIFT ARE PROVIDED AND ARE ZERO THEN NO SHIFTING NEEDED
  IF XSHIFT EQ 0 AND YSHIFT EQ 0 THEN RETURN, IMAGE


; ====================>
; SHIFT THE IMAGE AND COPY
  COPY = SHIFT(IMAGE,XSHIFT,YSHIFT)

; ====================>
; SET MISSING AREAS TO APPROPRIATE MISSING CODE
  IF N_ELEMENTS(MISSING) EQ 1 THEN _missing = MISSING ELSE _missing = MISSINGS(copy)

  IF XSHIFT GT 0  THEN COPY(  0:XSHIFT-1,*) = _missing
  IF YSHIFT GT 0  THEN COPY(*,0:YSHIFT-1  ) = _missing

  IF XSHIFT LT 0  THEN COPY(  SZ[1]+XSHIFT-1:*,*) = _missing
  IF YSHIFT LT 0  THEN COPY(*,SZ(2)+YSHIFT-1:*  ) = _missing

  RETURN,COPY

 END ; OF PROGRAM
