; $ID:	JD_GEN.PRO,	2020-06-30-17,	USER-KJWH	$
;+
;;#############################################################################################################
	FUNCTION JD_GEN,DATES
;
;
; PURPOSE: RETURNS A COMPLETE JD ARRAY FROM DATE_RANGE

; CATEGORY:	JD		 
;
; CALLING SEQUENCE:  RESULT = JD_GEN(DATES)
;
; INPUTS: DATES ... DATES OR DATE_RANGE

; OPTIONAL INPUTS:
;		NONE:	
;		
; KEYWORD PARAMETERS:  NONE
; 

; OUTPUTS: A COMPLETE ARRAY OF JDS SPANNNG THE RAGE OF DATES          
;		
;; EXAMPLES:  
;             P,JD_GEN(['20150101','20150131'])
;             HELP,JD_GEN(['20000101','20001231'])
;             HELP,JD_GEN(['20150101','20151231'])
;           
;	NOTES:
; 
;  MODIFICATION HISTORY:
;			WRITTEN FEB 20, 2015 J.O'REILLY

;			
;#################################################################################
;-
;************************
ROUTINE_NAME  = 'JD_GEN'
;************************

IF NONE(DATES) THEN MESSAGE,'ERROR: DATES ARE REQUIRED'
IF IDLTYPE(DATES) NE 'STRING' THEN MESSAGE,'ERROR DATES MUST BE STRING'
DATE_RANGE = MINMAX(DATES)
JD_RANGE = DATE_2JD(DATE_RANGE)
 N = SPAN(JD_RANGE)+ 1
RETURN,DINDGEN(N) + JD_RANGE[0]





DONE:          
	END; #####################  END OF ROUTINE ################################
