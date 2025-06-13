; $ID:	ARR_XY.PRO,	2015-11-30,	USER-JOR	$
; 
FUNCTION ARR_XY, X, Y, XOUT=XOUT, YOUT=YOUT
;#########################################################################; 
;+
; RETURNS A STRUCTURE WITH X AND Y ARRAYS REPLICATED TO HAVE THE SAME DIMENSIONS

;
; CATEGORY: MATH;
;
; CALLING SEQUENCE: 
;
; INPUTS: 

; OPTIONAL INPUTS:
;
; KEYWORDS:

; OUTPUTS:
;
;; EXAMPLES:
;
; MODIFICATION HISTORY:
;     OCT 15, 2004  WRITTEN BY: J.E. O'REILLY
;-
; #########################################################################

;*********************************
ROUTINE_NAME  = 'ARR_XY'
;*********************************
IF NONE(X) OR NONE(Y) THEN MESSAGE,'ERROR: X AND Y ARE REQUIRED'
D=CREATE_STRUCT('X', X # REPLICATE(1,N_ELEMENTS(Y)),  'Y',  REPLICATE(1,N_ELEMENTS(X)) # Y  )
XOUT=D.X
YOUT=D.Y
RETURN,D



END; #####################  END OF ROUTINE ################################
