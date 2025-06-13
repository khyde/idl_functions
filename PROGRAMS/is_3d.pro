; $ID:	IS_3D.PRO,	2015-09-13	$
;+
;;#############################################################################################################
	FUNCTION IS_3D,IM

; PURPOSE: RETURNS 1 IF IM IS A 3D ARRAY 0 IF NOT
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
;        P,IS_1D(BYTARR([333,444,10]))
;        P,IS_1D(BYTARR([333,444]))
;        P,IS_1D(BYTARR([333]))
;        P,IS_1D(FLTARR([333,444,10]))
; MODIFICATION HISTORY:
;			WRITTEN MAR 15, 2015 J.O'REILLY
;     SEP 12,2015,JOR RENAMED IS3D TO IS_1D TO CONFORM TO NAMING IN THE IS_ FAMILY
;#################################################################################
;-
;***********************
ROUTINE_NAME  = 'IS_3D'
;**********************
S = SIZEXYZ(IM)
IF  S.PX GE 2 AND S.PY GE 2 AND S.PZ GE 2 AND S.N_DIMENSIONS EQ 3 THEN RETURN, 1 ELSE RETURN,0
          
END; #####################  END OF ROUTINE ################################
