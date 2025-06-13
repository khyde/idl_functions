; $ID:	VECTOR_DEMO.PRO,	2020-07-01-12,	USER-KJWH	$
; #########################################################################; 
PRO VECTOR_DEMO
;+
; PURPOSE:  SIMPLE DEMO FOR USING VECTOR FUNCTION
;
; CATEGORY: DEMO
;
;
; INPUTS: NONE
;
;
; KEYWORDS:  NONE
;                 
; OUTPUTS: PLOTS TO THE SCREEN
;
;         
;
; MODIFICATION HISTORY:
;     JUN 25, 2018  WRITTEN BY: J.E. O'REILLY
; #########################################################################
;-
;*************************
ROUTINE = 'VECTOR_DEMO'
;*************************
PLT = PLOT(FINDGEN(11),FINDGEN(11),/NO_TOOLBAR)
XX = [100.0]
YY = XX*1E6
X = [2.0]
Y = X
V = VECTOR(XX,YY,X,Y,COLOR = 'RED',/OVERPLOT,THICK = 5)
XX = [10.0]
YY = XX/1E6
X = [8.0]
Y = X
V = VECTOR(XX,YY,X,Y,COLOR = 'BLUE',/OVERPLOT,THICK = 5)
PLT_GRIDS,PLT
 STOP


END; #####################  END OF ROUTINE ################################
