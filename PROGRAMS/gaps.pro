; $ID:	GAPS.PRO,	2020-06-26-15,	USER-KJWH	$
;+
;;#############################################################################################################
	PRO GAPS,DATA

; PURPOSE: THIS FUNCTION COMPUTES GAPS IN A SERIES
; 
; 
; CATEGORY:	UTILITY;		 
;
; CALLING SEQUENCE: RESULT = GAPS(VAR)
;
; INPUTS: DATA  

; OPTIONAL INPUTS:
;		
; KEYWORD PARAMETERS:

; OUTPUTS: 
;		
;; EXAMPLES:
;  PRINT, GAPS(VAR)
;	NOTES:

;
; MODIFICATION HISTORY:
;			WRITTEN OCT 11, 2013 J.O'REILLY
;#################################################################################
;-
;**********************
ROUTINE_NAME  = 'GAPS'
;**********************
JD = DINDGEN(30) & JD(5:10) = MISSINGS(JD) & JD(1:3) = MISSINGS(JD) 
OK = WHERE(JD EQ MISSINGS(JD),COUNT) & P,SPAN[OK]
H = HISTOGRAM(JD,/NAN)

;RETURN,
DONE:          
	END; #####################  END OF ROUTINE ################################
