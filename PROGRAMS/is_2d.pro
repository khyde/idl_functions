; $ID:	IS_2D.PRO,	2015-09-13	$
;+
;;#############################################################################################################
	FUNCTION IS_2D,IM

; PURPOSE: RETURNS 1 IF IM IS A 2D ARRAY 0 IF NOT
; 
; 
; CATEGORY:	LOGICAL;		 
;
; CALLING SEQUENCE: RESULT = IS_2D(IM)
;
; INPUTS: IM  

; OPTIONAL INPUTS:
;		
; KEYWORD PARAMETERS: NONE

; OUTPUTS: 1 OR 0 
;		
; EXAMPLES:
;        P,IS_2D(BYTARR([333,444]))
;        P,IS_2D(BYTARR([333,444,10]))
;        P,IS_2D(BYTARR([333]))
;        P,IS_2D(FLTARR([333,444]))
; MODIFICATION HISTORY:
;			WRITTEN MAR 15, 2015 J.O'REILLY
;			SEP 12,2015,JOR RENAMED IS2D TO IS_2D TO CONFORM TO NAMING IN THE IS_ FAMILY
;#################################################################################
;-
;**********************
ROUTINE_NAME  = 'IS_2D'
;**********************
S = SIZEXYZ(IM)
IF  S.PX GE 2 AND S.PY GE 2 AND S.PZ EQ 0 AND S.N_DIMENSIONS EQ 2 THEN RETURN, 1 ELSE RETURN,0
          
END; #####################  END OF ROUTINE ################################
