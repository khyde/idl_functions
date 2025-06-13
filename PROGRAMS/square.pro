; $ID:	SQUARE.PRO,	2014-06-10-12	$
;+
;#############################################################################################################
	PRO SQUARE

;
; PURPOSE: CALLS USERSYM AND MAKES A SQUARE PLOTTING SYMBOL [PSYM = 8]
;
; CATEGORY:	PLOT
;
; CALLING SEQUENCE: SQUARE
;

; MODIFICATION HISTORY:
;			JUN 10,2014,  WRITTEN BY J.O'REILLY 
;			
;			
;			
;#################################################################################
;-
;********************************
ROUTINE_NAME  = 'SQUARE'
;********************************
X = [-1, 1,  1, -1, -1]
Y = [-1,-1,  1,  1, -1]

X = [0, 1,  1, 0,  0]
Y = [0, 0,  1,  1, 0]
USERSYM, X, Y,COLOR = TC(26),FILL = 1


END; #####################  END OF ROUTINE ################################
