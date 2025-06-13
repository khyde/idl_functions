; $ID:	IMAGE_PASTE.PRO,	2014-09-16-14	$

 FUNCTION IMAGE_PASTE, PAGE,IMAGE_ARRAY, X=X,Y=Y, BACKGROUND=BACKGROUND,TRANSPARENT=TRANSPARENT,DEVICE=DEVICE,NORMAL=NORMAL,PAL=PAL
 ;#########################################################################################################################################
;+
; NAME:
;       IMAGE_PASTE
;
; PURPOSE:
;				IMAGE_PASTE ONE IMAGE ON TOP OF ANOTHER
;
; INPUTS:
;       PAGE  : THE PAGE UPON WHICH TO PASTE THE IMAGE
;       IMAGE: THE IMAGE TO PASTE UPON THE PAGE
;
; KEYWORD PARAMETERS:
;       TRANSPARENT:	TRANSPARENTLY ADDS IMAGE TO THE PAGE
;       BACKGROUND : THE PAGE BACKGROUND COLOR

;
; MODIFICATION HISTORY:
;       WRITTEN BY:  J.E.O'REILLY, FEB 28, 2004
;       OCT 15,2011, JOR, OVERHAULED, GREATLY MODIFIED
;       NOV 13,2011, JOR, FIXED WHEN BOTH IMAGE AND PAGE ARE ONE PLANE 256 COLOR IMAGES
;       FEB 26,2012,JOR REVERSED PARAMETERS TO  PAGE,IMAGE,[BIG,SMALL]
;       APR 17,2012,JOR, CHANGED 'IMAGE' TO 'IMAGE_ARRAY' TO AVOID CONFLICT WITH IDLS 'IMAGE FUNCTION
;       NOV 25,2012,JOR ADDED *** 256 COLOR ONE COLOR PLANE  ****
;    
;            
;-
;************************************************************************
ROUTINE_NAME='IMAGE_PASTE'
;************************************************************************

	IF N_ELEMENTS(X) NE 1 THEN X = 0
	IF N_ELEMENTS(Y) NE 1 THEN Y = 0
	IF N_ELEMENTS(BACKGROUND) NE 1 THEN _BACKGROUND = 0 ELSE _BACKGROUND = BACKGROUND
	SZ_IMAGE=SIZEXYZ(IMAGE_ARRAY)
	SZ_PAGE=SIZEXYZ(PAGE)

  TRUE_IMAGE = SZ_IMAGE.N_DIMENSIONS EQ 3
  TRUE_PAGE = SZ_PAGE.N_DIMENSIONS EQ 3
  
; ===> GET PIXEL SIZE OF IMAGE_ARRAY
  PX_IMAGE = SZ_IMAGE.PX
  PY_IMAGE = SZ_IMAGE.PY

; ===> GET PIXEL SIZE OF PAGE
  PX_PAGE = SZ_PAGE.PX
  PY_PAGE = SZ_PAGE.PY
  
  BOXL = 0+X
  BOXR = (PX_IMAGE-1) + X
  BOXB   = 0+Y
  BOXT   = (PY_IMAGE-1) + Y
; ****************************************************  
; *** 256 COLOR ONE COLOR PLANE  ****
  IF TRUE_IMAGE EQ 0 AND TRUE_PAGE EQ 0 THEN BEGIN
  ;STOP
    PAGE(BOXL:BOXR,BOXB:BOXT) = IMAGE_ARRAY
  ENDIF; IF TRUE_IMAGE EQ 0 AND TRUE_PAGE EQ 0 THEN BEGIN
; **************************************************** 

;  ********************************************************************
  IF TRUE_PAGE EQ 0 AND TRUE_IMAGE EQ 1 THEN BEGIN
; ===> MAKE PAGE TRUE COLOR
    PAGE = REPLICATE(_BACKGROUND,3,PX_PAGE,PY_PAGE)
    TRUE_PAGE = 1
  ENDIF; IF TRUE_PAGE EQ 0 AND TRUE_IMAGE EQ 1 THEN BEGIN
;  ********************************************************************
;  
;  ********************************************************************
; ===> BOTH TRUE COLOR
  IF TRUE_IMAGE EQ 1 AND TRUE_PAGE EQ 1 THEN BEGIN
    
  FOR N = 0,2 DO BEGIN
    IM = REFORM(IMAGE_ARRAY(N,*,*))
    PG =  REFORM(PAGE(N,*,*))
 ;   PAGE(N,BOXL:BOXR,BOXB:BOXT) = IMAGE_ARRAY(N,BOXL:BOXR,BOXB:BOXT) 
    PAGE(N,BOXL:BOXR,BOXB:BOXT) = IMAGE_ARRAY(N,*,*)  
  ENDFOR;FOR P = 0,2 DO BEGIN
  ENDIF; IF TRUE_IMAGE EQ 1 AND TRUE_PAGE EQ 1 THEN BEGIN
;  ********************************************************************

		
RETURN, PAGE


END; #####################  END OF ROUTINE ################################



