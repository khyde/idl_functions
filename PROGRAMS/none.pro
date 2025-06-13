; $ID:	NONE.PRO,	2014-04-24	$
;+
;;#############################################################################################################
	FUNCTION NONE,VAR
;
; PURPOSE: THIS FUNCTION RETURNS 1 [TRUE] IF THERE ARE NO ELEMENTS IN A VAR
; 
; 
; 
; CATEGORY:	LOGIC		 
;
; CALLING SEQUENCE: RESULT = NONE(VALS)
;
; INPUTS: VAR  

; OPTIONAL INPUTS:
;		NONE:	
;		
; KEYWORD PARAMETERS:
;   NONE

; OUTPUTS: 1=IF NONE  0=IF NOT NONE 
;		
;; EXAMPLES:
;  PRINT, NONE(); NO PARAMETER HAS NO ELEMENTS SO RESULT IS 1
;  PRINT, NONE(XYZABC); UNDEFINED VAR HAS NO ELEMENTS SO RESULT IS 1
;  PRINT, NONE(''); A NULL STRING HAS ELEMENTS SO RESULT IS 0
;  PRINT, NONE(INDGEN(3)); A VAR HAS ELEMENTS SO RESULT IS 0
;	NOTES:;		
;
;
; MODIFICATION HISTORY:
;			APR 09,2014  WRITTEN BY J.O'REILLY
;#################################################################################
;-
;****************************
ROUTINE_NAME  = 'NONE'
;****************************
RETURN,N_ELEMENTS(VAR) EQ 0 
DONE:          
	END; #####################  END OF ROUTINE ################################
