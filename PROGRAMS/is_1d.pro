; $ID:	IS_1D.PRO,	2015-09-13	$
;+
;;#############################################################################################################
	FUNCTION IS_1D,IM

; PURPOSE: RETURNS 1 IF IM IS A 1D ARRAY 0 IF NOT
; 
; 
; CATEGORY:	LOGICAL;		 
;
; CALLING SEQUENCE: RESULT = IS_1D(IM)
;
; INPUTS: IM  

; OPTIONAL INPUTS:
;		
; KEYWORD PARAMETERS: NONE

; OUTPUTS: 1 OR 0 
;		
; EXAMPLES:
;        P,IS_1D(BYTARR([333]))
;        P,IS_1D(BYTARR([333,444]))
;        P,IS_1D(BYTARR([333,444,10]))
;        P,IS_1D(BYTARR([1]))
;        P,IS_1D(BYTARR([2]))
;        P,IS_1D(STRARR([2]))
;        P,IS_1D(STRARR([1]))
;        P,IS_1D(4)
;        
; MODIFICATION HISTORY:
;			WRITTEN SEP 13,2015, J.O'REILLY
;#################################################################################
;-
;***********************
ROUTINE_NAME  = 'IS_1D'
;**********************
S = SIZEXYZ(IM)
IF  S.PX GT 1 AND S.PY EQ 0  AND S.PZ EQ 0 AND S.N_DIMENSIONS EQ 1 THEN RETURN, 1 ELSE RETURN,0
          
END; #####################  END OF ROUTINE ################################
