; $ID:	STR_QUOTE.PRO,	2014-04-29	$
; ===> CHOOSE ONE: PRO OR FUNCTION 
;#############################################################################################################
	FUNCTION STR_QUOTE,TXT 
	
;  PRO STR_QUOTE
;+
; NAME:
;		STR_QUOTE
;
; PURPOSE: THIS FUNCTION RETURNS THE INPUT STRING WITH DOUBLE QUOTES ON BOTH SIDES OF THE TEXT
;
; CATEGORY:
;		STRINGS
;		 
;
; CALLING SEQUENCE:RESULT = STR_QUOTE(TXT)
;
; INPUTS:
;		TXT:	INPUT STRING 
;		
; OPTIONAL INPUTS:
;		NONE:	
;		
; KEYWORD PARAMETERS:
;   NONE

; OUTPUTS:
;		
;; EXAMPLES:
;  PRINT, STR_QUOTE(['SEAWIFS'])
;  PRINT, STR_QUOTE(['1234'])
;	NOTES:

;		
;
;
; MODIFICATION HISTORY:
;			WRITTEN JUN 28,2012  J.O'REILLY
;#################################################################################
;
;
;-
;	*******************************************
ROUTINE_NAME='STR_QUOTE'
; *******************************************
Q = """
RETURN,Q + TXT + Q
DONE:          
	END; #####################  END OF ROUTINE ################################
