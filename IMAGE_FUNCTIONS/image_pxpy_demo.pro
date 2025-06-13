; $ID:	IMAGE_PXPY_DEMO.PRO,	2020-07-01-12,	USER-KJWH	$

PRO IMAGE_PXPY_DEMO
;+
; NAME:
;       IMAGE_PXPY_DEMO
;
; PURPOSE: DEMO FOR IMAGE_PXPY WHICH GENERATES A 2-D ARRAY OF PIXEL POSITIONS FOR AN IMAGE
;
;	KEYWORDS:
;			CENTER: GENERATES VALUES FOR THE CENTER OF EACH PIXEL (0.5)
;
; CALLING SEQUENCE:
;				
;       WRITTEN BY:  J.E.O'REILLY, FEB 4,2012
;       
;       
; NOTES:
; !ERROR = -153 IF NOT ENOUGH MEMORY


;-
; *************************************************************************************************************
ROUTINE_NAME = 'IMAGE_PXPY_DEMO'
; *************************************************************************************************************
DIR_PLOTS='D:\IDL\PLOTS\'

;SSSSSSSSSSSSSSS SWITCHES SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS
DO_SMALL    = 0
DO_IMAGES   = 2
;SSSSSSSSSSSSSSS SWITCHES SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS

; **********************************
IF DO_SMALL GE 1 THEN BEGIN
  IXY= IMAGE_PXPY([5,5])
  X=IXY.X
  Y=IXY.Y
  PRINT,X
  PRINT,Y
  ,'DO_SMALL'
ENDIF;IF DO_SMALL GE 1 THEN BEGIN
; ||||||||||||||||||||||||||||||||||||||||||

IF DO_IMAGES GE 1 THEN BEGIN
  IXY= IMAGE_PXPY([256,128])
  X=IXY.X
  Y=IXY.Y
  IM = BYTARR(256,256)
  BX= BYTE(X)
  BY = BYTE(Y)
  PAL_SW2,R,G,B
  WRITE_PNG,DIR_PLOTS +'X.PNG',BX,R,G,B
  WRITE_PNG,DIR_PLOTS +'Y.PNG',BY,R,G,B
  ,'DO_IMAGES'
ENDIF;IF DO_IMAGES GE 1 THEN BEGIN
; ||||||||||||||||||||||||||||||||||||||||||


END; #####################  END OF ROUTINE ################################
