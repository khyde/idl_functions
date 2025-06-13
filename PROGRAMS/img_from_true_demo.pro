; $ID:	IMG_FROM_TRUE_DEMO.PRO,	2020-07-01-12,	USER-KJWH	$
; 
PRO IMG_FROM_TRUE_DEMO

; #########################################################################; 
;+
; THIS PROGRAM IS A DEMO FOR IMG_FROM_TRUE


; HISTORY:
;     APR 30,2014 WRITTEN BY: J.E. O'REILLY
;     JUL 4,2014,JOR RENAMED
;     JUL 62014,JOR,
;-
; #########################################################################

;***********************************
ROUTINE_NAME  = 'IMG_FROM_TRUE_DEMO'
;***********************************



;===> GET THE TRUE-COLOR MASK FILE SAVED IN PAINT AS A .BMP     
FILE = !S.IMAGES + 'MASK_NEC_ESTUARY_SHELF.BMP' & PFILE,FILE,/X
IF EXISTS(FILE) EQ 0 THEN MESSAGE,FILE + '  DOES NOT EXIST'
IMG_FROM_TRUE,FILE,DIR_OUT=DIR_OUT


END; #####################  END OF ROUTINE ################################
