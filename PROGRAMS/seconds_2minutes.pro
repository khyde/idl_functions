; $ID:	SECONDS_2MINUTES.PRO,	2020-07-01-12,	USER-KJWH	$
; ===> CHOOSE ONE: PRO OR FUNCTION 
;#############################################################################################################
	FUNCTION SECONDS_2MINUTES,VALUES ,WHOLE=WHOLE 
	
;  PRO SECONDS_2MINUTES
;+
; NAME:
;		SECONDS_2MINUTES
;
; PURPOSE: THIS FUNCTION CONVERTS SECONDS TO MINUTES
;
; CATEGORY:
;   DATE_TIME		 
;
; CALLING SEQUENCE:RESULT = SECONDS_2MINUTES(VALUE)
;
; INPUTS:
;		VALUE:	SECONDS
;		
; OPTIONAL INPUTS:
;		WHOLE: RETURN WHOLE MINUTES NOT DECIMAL FRACTIONS	
;		
; KEYWORD PARAMETERS:
;   NONE

; OUTPUTS:
;   MINUTES [DECIMAL]
;		
;; EXAMPLES:
;  PRINT, SECONDS_2MINUTES(62)
;	NOTES:

;		
;
;
; MODIFICATION HISTORY:
;			WRITTEN DEC 28,2012  J.O'REILLY
;			DEC 30,2012,JOR, : MINUTES = ULONG64(_SEC/60.)

;#################################################################################
;
;
;-
;	*******************************************
ROUTINE_NAME='SECONDS_2MINUTES'
; *******************************************

; ===> USEFUL WORDS FOR SEARCHING:
; STOP PRINT N_ELEMENTS  ENDFOR SWITCHES  RETURN    ,
; 

MINUTES = VALUES/60.0
IF KEYWORD_SET(WHOLE) THEN MINUTES = ULONG64(MINUTES)
RETURN, MINUTES

DONE:          
	END; #####################  END OF ROUTINE ################################
