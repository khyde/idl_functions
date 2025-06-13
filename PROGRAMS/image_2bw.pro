; $ID:	IMAGE_2BW.PRO,	2020-06-26-15,	USER-KJWH	$
;+
;	This Program takes a color image (scientific plot figure and makes all non background colors black
; SYNTAX:
;	IMAGE_2BW, Param1, Param2 [,/KEY1] [,/KEY2] [KEY3=KEY3] )
;	Result = IMAGE_2BW(Param1, Param2 [,/KEY1] [,/KEY2] [KEY3=KEY3] )
; OUTPUT:
; ARGUMENTS:
; 	Parm1:
; 	Parm2:
; KEYWORDS:
;	KEY1:
;	KEY2:
;	KEY3:
; EXAMPLE:
; CATEGORY:
;
; NOTES:
;  PROGRAM ASSUMES THAT BACKGROUND IS MOST PREVALENT COLOR

; VERSION:
;	Jan 01,2001
; HISTORY:
;	Jan 1,2001	Written by:	J.E. O'Reilly, NOAA, 28 Tarzwell Drive, Narragansett, RI 02882
;-
; *************************************************************************

PRO IMAGE_2BW,fileS, THICKEN=thicken
  ROUTINE_NAME='IMAGE_2BW'

 IF N_ELEMENTS(FILES) EQ 0 THEN FILES = DIALOG_PICKFILE()

  FOR _FILE = 0, N_ELEMENTS(FILES)-1 DO BEGIN

     AFILE=FILES(_FILE)
    FN=PARSE_IT(AFILE)
    PNG_FILE=FN.DIR+FN.NAME+'_BW.PNG'
    IMAGE=READALL(AFILE)
    H=HISTOGRAM(IMAGE,MIN=0,MAX=255)
    OK = WHERE(H EQ MAX(H))
    BACKGROUND = LAST[OK]
    OK = WHERE(IMAGE EQ BACKGROUND)
    COPY=IMAGE
    COPY[OK] = 255
    OK = WHERE(IMAGE NE BACKGROUND)
    COPY[OK] = 0

    IF KEYWORD_SET(THICKEN) THEN BEGIN
      CLOUDIER,IMAGE=COPY,MASK=MASK
      OK = WHERE(MASK EQ 0)
      COPY=MASK
      COPY[OK] = 255
      OK = WHERE(MASK NE 0)
      COPY[OK] = 0
    ENDIF


    PAL_36,R,G,B
    WRITE_PNG,PNG_FILE,COPY,R,G,B

  ENDFOR
  STOP


END; #####################  End of Routine ################################
