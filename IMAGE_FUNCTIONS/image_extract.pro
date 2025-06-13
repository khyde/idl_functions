; $ID:	IMAGE_EXTRACT.PRO,	2020-07-08-15,	USER-KJWH	$
; FUNCTION IMAGE_EXTRACT,Image,Color, BACKGROUND=background, SHOW=show
;+
; NAME:
;	IMAGE_EXTRACT
;
; PURPOSE:
;	This FUNCTION extracts one or more colors from a BINARY IMAGE
;   and Returns a BINARY image with just the target colors
;
; CATEGORY:
;	Image
;
; CALLING SEQUENCE:
;	Result = IMAGE_EXTRACT(Image,Color)
;
; INPUTS:
;	Image:	A binary image
;
;   Color:  A scaler or array of values between 0,255b
;
; OPTIONAL INPUTS:
;	None:
;
; KEYWORD PARAMETERS:
;	NONE:
;
;   BACKGROUND: Background color for output copy of Image
;
; OUTPUTS:
;	This function returns a binary image with just those colors specified in Color
;
; OPTIONAL OUTPUTS:
;	None
;
; COMMON BLOCKS:
;	None
;
; SIDE EFFECTS:
;	None
;
; RESTRICTIONS:
;	Image must be Binary
;
; PROCEDURE:
;	A blank image (255b) is made from the Image and
;   the target color(s) are found using WHERE and copied to the blank image
;;
; EXAMPLE:
;
;   Extract a copy of the image where the new image contains just the color 2b
;		NEW = IMAGE_EXTRACT(Image, 2)
;
; MODIFICATION HISTORY:
; 	Written by:	John E. O'Reilly, December 12,2000
;-

  FUNCTION IMAGE_EXTRACT,Image,Color, BACKGROUND=background

  PROGRAM_NAME='IMAGE_EXTRACT'

  IF N_ELEMENTS(BACKGROUND) NE 1 THEN background=255b
  SZ=SIZE(IMAGE,/STRUCT)
  COPY = Image
  COPY(*,*)=background
  OK = WHERELIST(Image,'EQ',COLOR,COUNT)
  IF COUNT GE 1 THEN COPY[OK] = Image(OK) ELSE COPY=REPLICATE(background,SZ.DIMENSIONS[0],SZ.DIMENSIONS[1])

  RETURN,COPY

END; OF PROGRAM
