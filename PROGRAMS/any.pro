; $ID:	ANY.PRO,	2014-04-13	$
;+
;;#############################################################################################################
	FUNCTION ANY,VAR
;
; PURPOSE: THIS LOGICAL FUNCTION RETURNS 1 [TRUE] IF THERE ARE ANY ELEMENTS IN A VAR
; 
; 
; 
; CATEGORY:	UTILITY;		 
;
; CALLING SEQUENCE: RESULT = ANY(VAR)
;
; INPUTS: VAR  

; OPTIONAL INPUTS:
;		ANY:	
;		
; KEYWORD PARAMETERS:
;   NONE

; OUTPUTS: 1 OR 0
;		
;; EXAMPLES:
;  PRINT, ANY(); NO PARAMETER HAS NO ELEMENTS SO RESULT IS 0
;  PRINT, ANY(XYZABC); UNDEFINED VAR HAS NO ELEMENTS SO RESULT IS 0
;  PRINT, ANY(''); A NULL STRING HAS ELEMENTS SO RESULT IS 1
;  PRINT, ANY(INDGEN(3)); A VAR HAS ELEMENTS SO RESULT IS 1
;	NOTES:;		
;
;
; MODIFICATION HISTORY:
;			APR 09,2014  WRITTEN BY J.O'REILLY
;#################################################################################
;-
;****************************
ROUTINE_NAME  = 'ANY'
;****************************
RETURN,N_ELEMENTS(VAR) NE 0 
DONE:          
	END; #####################  END OF ROUTINE ################################
