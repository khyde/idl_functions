; $ID:	IS_TRUE_COLOR.PRO,	2015-09-12	$
;+
;;#############################################################################################################
	FUNCTION IS_TRUE_COLOR,IM

; PURPOSE: RETURNS 1 IF IM IS A TRUE COLOR 2D ARRAY 0 IF NOT
; 
; 
; CATEGORY:	LOGICAL;		 
;
; CALLING SEQUENCE: RESULT = IS_TRUE_COLOR(IM)
;
; INPUTS: IM  

; OPTIONAL INPUTS:
;		
; KEYWORD PARAMETERS: NONE

; OUTPUTS: 1 OR 0 
;		
; EXAMPLES:
;        P,IS_TRUE_COLOR(BYTARR([333,444]))
;        P,IS_TRUE_COLOR(BYTARR([333,444,10]))
;        P,IS_TRUE_COLOR(BYTARR([333]))
;        P,IS_TRUE_COLOR(FLTARR([333,444]))
; MODIFICATION HISTORY:
;			WRITTEN MAR 15, 2015 J.O'REILLY
;#################################################################################
;-
;******************************
ROUTINE_NAME  = 'IS_TRUE_COLOR'
;******************************
S = SIZEXYZ(IM)
  PX = S.DIMENSIONS[1]
  PY = S.DIMENSIONS[2]
  PZ = S.DIMENSIONS[0]
IF IDLTYPE(IM) EQ 'BYTE' AND S.PX GT 2 AND S.PY GT 2 AND S.PZ GE 3 AND S.N_DIMENSIONS EQ 3 THEN RETURN, 1 ELSE RETURN,0
          
END; #####################  END OF ROUTINE ################################
