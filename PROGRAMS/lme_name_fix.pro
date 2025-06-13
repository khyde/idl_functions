; $ID:	LME_NAME_FIX.PRO,	2014-04-29	$
;+
;;#############################################################################################################
	FUNCTION LME_NAME_FIX,LMES

; PURPOSE: THIS FUNCTION EDITS THE LME NAMES FOR WORD PROCESSING
; 
; 
; CATEGORY:	LMES;		 
;
; CALLING SEQUENCE: RESULT = LME_NAME_FIX(LMES)
;
; INPUTS: LMES  

; OPTIONAL INPUTS:
;		
; KEYWORD PARAMETERS:

; OUTPUTS: 
;		
;; EXAMPLES:
;  PRINT, LME_NAME_FIX(LMES)
;	NOTES:

;
; MODIFICATION HISTORY:
;			WRITTEN OCT 11, 2013 J.O'REILLY
;#################################################################################
;-
;****************************
ROUTINE_NAME  = 'LME_NAME_FIX'
;****************************

IF NONE(LMES) THEN NAMES = GET_LME_NAMES()
NAMES = REPLACE(NAMES,'_',' ')
NAMES = STR_CAP(NAMES,/ALL)
NAMES = REPLACE(NAMES,' OF ',' of ')
NAMES = REPLACE(NAMES,' And ',' and ')
NAMES = REPLACE(NAMES,' Of ',' of ')
NAMES = REPLACE(NAMES,' Us ',' US ')
STOP
;RETURN,
DONE:          
	END; #####################  END OF ROUTINE ################################
