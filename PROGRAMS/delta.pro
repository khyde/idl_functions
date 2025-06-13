; $ID:	DELTA.PRO,	2020-07-08-15,	USER-KJWH	$
;+
;;#############################################################################################################
	FUNCTION DELTA,VEC

; PURPOSE:  RETURNS THE DIFFERENCES BETWEEN ADJACENT ELEMENTS IN A VECTOR 

; 
; 
; CATEGORY:	UTILITY;		 
;
; CALLING SEQUENCE: RESULT = DELTA(VEC)
;
; INPUTS: VECTOR  

; OPTIONAL INPUTS:
;		
; KEYWORD PARAMETERS:

; OUTPUTS: 
;		
;; EXAMPLES:

;     P,DELTA(INDGEN(5))

;
; MODIFICATION HISTORY:
;			WRITTEN SEP 16, 2015 J.O'REILLY
;			JUL 09,2016,JEOR: IF IDLTYPE(VEC) EQ 'STRING' THEN VEC = FLOAT(VEC)

;#################################################################################
;-
;**********************
ROUTINE_NAME  = 'DELTA'
;**********************
IF IDLTYPE(VEC) EQ 'STRING' THEN VEC = FLOAT(VEC)
S = VEC-SHIFT(VEC,1)
S[0] = VEC[1] - VEC[0]
RETURN, S
          
	END; #####################  END OF ROUTINE ################################
