; $ID:	IS_IMG.PRO,	2015-09-12	$
;+
;;#############################################################################################################
	FUNCTION IS_IMG,IM

; PURPOSE: RETURNS 1 IF IM IS A 2D BYTE IMAGE ARRAY 0 IF NOT
; 
; 
; CATEGORY:	LOGICAL;		 
;
; CALLING SEQUENCE: RESULT = IS_IMG(IM)
;
; INPUTS: IM  

; OPTIONAL INPUTS:
;		
; KEYWORD PARAMETERS: NONE

; OUTPUTS: 1 OR 0 
;		
; EXAMPLES:
;        P,IS_IMG(BYTARR([333,444]))
;        P,IS_IMG(BYTARR([333]))
;        P,IS_IMG(FLTARR([333,444]))
; MODIFICATION HISTORY:
;			WRITTEN MAR 15, 2015 J.O'REILLY
;     SEP 12,2015,JOR RENAMED ISIMG TO IS_IMG TO CONFORM TO NAMING IN THE IS_ FAMILY
;#################################################################################
;-
;***********************
ROUTINE_NAME  = 'IS_IMG'
;**********************
S = SIZEXYZ(IM)
IF  S.PX GT 2 AND S.PY GT 2 AND $
    S.PZ EQ 0 AND S.N_DIMENSIONS EQ 2 AND $
    IDLTYPE(IM) EQ 'BYTE' THEN RETURN, 1 ELSE RETURN,0
          
END; #####################  END OF ROUTINE ################################
