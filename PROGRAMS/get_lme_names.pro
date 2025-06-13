; $ID:	GET_LME_NAMES.PRO,	2020-06-26-15,	USER-KJWH	$
;+
;;#############################################################################################################
	FUNCTION GET_LME_NAMES,CODES

; PURPOSE: THIS FUNCTION RETURNS THE LME NAMES 
; 
; 
; CATEGORY:	UTILITY;		 
;
; CALLING SEQUENCE: RESULT = GET_LME_NAMES(CODES)
;
; INPUTS: CODES  

; OPTIONAL INPUTS:
;		
; KEYWORD PARAMETERS:

; OUTPUTS: 
;		
;; EXAMPLES:
;  PRINT, GET_LME_NAMES()
;  PRINT, GET_LME_NAMES([54])
;	NOTES:

;
; MODIFICATION HISTORY:
;			WRITTEN SEP 3,2014 J.O'REILLY
;#################################################################################
;-
;******************************
ROUTINE_NAME  = 'GET_LME_NAMES'
;******************************
DB = READ_LME_DB()
IF NONE(CODES) THEN BEGIN
  RETURN,DB.MAP  
ENDIF ELSE BEGIN
  OK = WHERE_MATCH(DB.CODE,CODES,COUNT)
  IF COUNT GE 1 THEN RETURN,DB[OK].MAP ELSE RETURN, !NULL
ENDELSE;IF NONE(CODES) THEN BEGIN

DONE:          
	END; #####################  END OF ROUTINE ################################
