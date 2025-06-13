; $Id: image_2true.pro,  J.E.O'Reilly Aug 20,2000

function IMAGE_2TRUE,IMAGE,R,G,B, PAL=pal
;+
; NAME:
;       image_2true
;
; PURPOSE:
;       Convert an 8bit 256 color image into a 24bit TRUE color image
;       using the r,g,b x256 palette provided.
;
; CATEGORY:
;       IMAGES
;
; CALLING SEQUENCE:
;       Result = image_2true(image) ; no r,g,b so will get a true color grey
;       Result = image_2true(image,r,g,b)
;
; INPUTS:
;       IMAGE: a 2-dimensional byte array
;       R:     An array of 256 binary values representing RED
;       G:     An array of 256 binary values representing GREEN
;       B:     An array of 256 binary values representing BLUE
;
; KEYWORD PARAMETERS:
;
; OUTPUTS:
;      A true-color 3 diminsional image array (3 by xsize by ysize)
; SIDE EFFECTS:
;       None.
;
; RESTRICTIONS:
;       None.
;
; PROCEDURE:
;       Straightforward.
;
; MODIFICATION HISTORY:
;       Written by:  J.E.O'Reilly, August 20,2000
;-
  ROUTINE_NAME ='IMAGE_2TRUE'

; ===> Get the size of the 2 dimensional input image array
  S=SIZE(IMAGE,/STRUCT)

; ===> Ensure that input image array is 2 dimensions
  IF S.N_DIMENSIONS NE 2 THEN BEGIN
    PRINT, 'ERROR: Input Image Array is not 2 dimensions'
    RETURN, -1L
  ENDIF

; ===> Make a 3,px,py byte array
  image_true=BYTARR(3,S.DIMENSIONS(0),S.DIMENSIONS(1))

; ===> If the name of a palette idl program is provided then
; execute program to get the r,g,b values
  IF N_ELEMENTS(PAL) EQ 1 THEN  CALL_PROCEDURE,PAL,R,G,B

; ===> IF r,g,b not know yet then use IDL greyscale palette
  IF N_ELEMENTS(R) NE 256 OR N_ELEMENTS(G) NE 256 OR N_ELEMENTS(B) NE 256 THEN BEGIN
    LOADCT,0
    TVLCT,R,G,B,/GET
  ENDIF

; ===> Fill image_true Red,green,blue planes with appropriate values
; based on data in input image
  image_true(0,*,*) = R(IMAGE)
  image_true(1,*,*) = G(IMAGE)
  image_true(2,*,*) = B(IMAGE)


; ===> Return true color image
  RETURN, image_true

  END; #####################  End of Routine ################################
