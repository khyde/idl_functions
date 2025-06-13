; $ID:	IMG_TRUE_2EIGHT_DEMO.PRO,	2020-07-01-12,	USER-KJWH	$
; 
PRO IMG_TRUE_2EIGHT_DEMO

; #########################################################################; 
;+
; THIS PROGRAM IS A  DEMO FOR  IMG_TRUE_2EIGHT


; HISTORY:
;     APR 30,2014 WRITTEN BY: J.E. O'REILLY
;-
; #########################################################################

;*************************************
ROUTINE_NAME  = 'IMG_TRUE_2EIGHT_DEMO'
;*************************************



;===> GET THE TRUE-COLOR MASK FILE SAVED IN PAINT AS A .BMP     
FILE = !S.IMAGES + 'MASK_NEC_ESTUARY_SHELF.BMP' & PFILE,FILE,/X
IF EXISTS(FILE) EQ 0 THEN MESSAGE,FILE + '  DOES NOT EXIST'
IMG_TRUE_2EIGHT,FILE,DIR_OUT=DIR_OUT


END; #####################  END OF ROUTINE ################################
