; $ID:	GET_EXTRA.PRO,	2014-04-29	$
;+
;;#############################################################################################################
	FUNCTION GET_EXTRA,_EXTRA,TAG

; PURPOSE: THIS FUNCTION EXTRACTS INFO FROM _EXTRA
; 
; 
; CATEGORY:	UTILITY;		 
;
; CALLING SEQUENCE: RESULT = GET_EXTRA(_EXTRA)
;
; INPUTS: _EXTRA  

; OPTIONAL INPUTS:
;		
; KEYWORD PARAMETERS:

; OUTPUTS: 
;		
;; EXAMPLES:
;  PRINT, GET_EXTRA(_EXTRA)
;	NOTES:

;
; MODIFICATION HISTORY:
;			WRITTEN SEP 17, 2014 J.O'REILLY
;#################################################################################
;-
;****************************
ROUTINE_NAME  = 'GET_EXTRA'
;****************************
IF IDLTYPE(_EXTRA) NE 'STRUCT' THEN RETURN,0
OK = WHERE_MATCH(TAG_NAMES(_EXTRA),TAG,COUNT)
IF COUNT EQ 1 THEN RETURN,_EXTRA.(OK)          
	END; #####################  END OF ROUTINE ################################
