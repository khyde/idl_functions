; $ID:	KEY.PRO,	2020-07-08-15,	USER-KJWH	$
;+
;;#############################################################################################################
	FUNCTION KEY,VAR
;
; PURPOSE: THIS FUNCTION RETURNS 1 [TRUE] IF THE KEYWORD IS SET [=1]
; 
; 
; 
; CATEGORY:	LOGIC;		 
;
; CALLING SEQUENCE: RESULT = KEY(VAR)
;
; INPUTS: VAR  

; OPTIONAL INPUTS:
;			
;		
; KEYWORD PARAMETERS:
;   NONE

; OUTPUTS: 1=IF KEYWORD SET  0=IF KEYWORD NOT SET 
;		
;; EXAMPLES:
;  TEST = 0 & PRINT,KEY(TEST)
;  TEST = 1 & PRINT,KEY(TEST)
;  PRINT, KEY[0];  RESULT IS 0
;  PRINT, KEY[1];  RESULT IS 1
;  PRINT, KEY(''); A NULL STRING IS EQUIVALENT TO ZERO SO RESULT IS 0
;  PRINT, KEY(INDGEN(3)); A VARIABLE HAS ELEMENTS SO RESULT IS 1
;	NOTES:;		
;
;
; MODIFICATION HISTORY:
;			APR 19,2014  WRITTEN BY J.O'REILLY
;#################################################################################
;-
;****************************
ROUTINE_NAME  = 'KEY'
;****************************
RETURN,KEYWORD_SET(VAR) EQ 1 
DONE:          
	END; #####################  END OF ROUTINE ################################
