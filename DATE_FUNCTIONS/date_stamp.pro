; $ID:	DATE_STAMP.PRO,	2017-03-02-13,	USER-KJWH	$
;+
;;#############################################################################################################
	FUNCTION DATE_STAMP,TIME=TIME
;
; PURPOSE: THIS FUNCTION RETURNS A DATE STAMP STRING
; 
; CATEGORY:	DATE;		 
;
; CALLING SEQUENCE: RESULT = DATE_STAMP()
;
; INPUTS: NONE 

; OPTIONAL INPUTS:
;		NONE:	
;		
; KEYWORDS:
;          TIME... ADDS HOUR AND MINUTE TO OUTPUT DATE STAMP
;         

; OUTPUTS: 
;		
;; EXAMPLES:
;  PRINT, DATE_STAMP()
;  PRINT, DATE_STAMP(/TIME)
;	NOTES:
;
; MODIFICATION HISTORY:
;			WRITTEN JAN 25, 2014 J.O'REILLY
;			FEB 28,2016,JOR ADDED KEY TIME
;			MAR 02, 2017 - KJWH: Updated the DATE_FORMAT call.  Changed Y_MDH to /HOUR and YMD to /DAY
;#################################################################################
;-
;****************************
ROUTINE_NAME  = 'DATE_STAMP'
;****************************
IF KEY(TIME) THEN BEGIN
  RETURN, STRTRIM(DATE_FORMAT(DATE_NOW(),/HOUR),2)
ENDIF ELSE BEGIN
  RETURN, STRTRIM(DATE_FORMAT(DATE_NOW(),/DAY),2)
ENDELSE
DONE:          
END; #####################  END OF ROUTINE ################################
