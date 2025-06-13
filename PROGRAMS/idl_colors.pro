; $ID:	IDL_COLORS.PRO,	2014-06-30-13	$
;+
;;#############################################################################################################
	FUNCTION IDL_COLORS,VAR

; PURPOSE: THIS FUNCTION RETURNS A SORTED LIST OF THE NAMES OF IDL COLORS IN !COLOR
; 
; 
; CATEGORY:	UTILITY;		 
;
; CALLING SEQUENCE: RESULT = IDL_COLORS(VAR)
;
; INPUTS: VAR  

; OPTIONAL INPUTS:
;		
; KEYWORD PARAMETERS:

; OUTPUTS: 
;		
;; EXAMPLES:
;  PRINT, IDL_COLORS(VAR)
;	NOTES:

;
; MODIFICATION HISTORY:
;			WRITTEN OCT 11, 2013 J.O'REILLY
;#################################################################################
;-
;****************************
ROUTINE_NAME  = 'IDL_COLORS'
;****************************
NAMES = TAG_NAMES(!COLOR)
NAMES = NAMES(SORT(NAMES))
RETURN,NAMES
DONE:          
	END; #####################  END OF ROUTINE ################################
