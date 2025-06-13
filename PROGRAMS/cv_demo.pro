; $ID:	CV_DEMO.PRO,	2020-07-01-12,	USER-KJWH	$
; 
PRO CV_DEMO

; #########################################################################; 
;+
; THIS PROGRAM IS A DEMO FOR COEFFICIENT OF VARIABILITY [CV]


; HISTORY:
;     MAR 1, 2015  WRITTEN BY: J.E. O'REILLY
;-
; #########################################################################

;*****************************
ROUTINE_NAME  = 'CV_DEMO'
;*****************************



X = [1E-4,1E-3,1E-2]
FOR N = 1,5 DO BEGIN
  X = X *10
  S = STATS(X)
  D= STRUCT_COPY(S,TAGNAMES = ['N','MEAN','STD','CV'])
  IF NONE(DB) THEN DB = D ELSE DB = [DB,D]
ENDFOR;FOR N = 1,5,DO BEGIN
 
TXT = 'MEAN=!C' +ROUNDS(DB.MEAN,3,/SIG)
PLT_XY,DB.STD,DB.CV,TXT,TITLE =ROUTINE_NAME,XTITLE = 'STD',YTITLE = 'CV %',$
SYMBOL = 'SQUARE',SYM_SIZE = 13,SYM_THICK = 5,SYM_COLOR = 'CRIMSON',$
OBJ = OBJ,/XLOG,TXT_SIZE = 11,XRANGE =[1E-2,1E3]
PLT_GRIDS,OBJ
, 'DO_CV_X10'
  





END; #####################  END OF ROUTINE ################################
