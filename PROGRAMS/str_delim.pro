; $ID:	STR_DELIM.PRO,	2014-04-29	$
; ===> CHOOSE ONE: PRO OR FUNCTION 
;#############################################################################################################
	FUNCTION STR_DELIM,TXT,DELIM 
	
;  PRO STR_DELIM
;+
; NAME:
;		STR_DELIM
;
; PURPOSE: THIS FUNCTION RETURNS THE INPUT STRING WITH DELIM ON BOTH SIDES OF THE TEXT
;
; CATEGORY:
;		STRINGS
;		 
;
; CALLING SEQUENCE:RESULT = STR_DELIM(TXT)
;
; INPUTS:
;		TXT:	INPUT STRING 
;		DELIM: DELIMITER 
; OPTIONAL INPUTS:
;		NONE:	
;		
; KEYWORD PARAMETERS:
;   NONE

; OUTPUTS:
;		
;; EXAMPLES:
;  PRINT, STR_DELIM(['SEAWIFS'])
;  PRINT, STR_DELIM(['1234'])
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
ROUTINE_NAME='STR_DELIM'
; *******************************************
Q = """
RETURN,Q + TXT + Q
DONE:          
	END; #####################  END OF ROUTINE ################################
