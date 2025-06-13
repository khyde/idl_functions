; $ID:	SAME.PRO,	2020-06-30-17,	USER-KJWH	$
;#############################################################################################################
	FUNCTION SAME,ARRAY 
	
;+
; NAME:
;		SAME
;
; PURPOSE: THIS FUNCTION DETERMINES IF ALL ELEMENTS IN AN ARRAY ARE IDENTICAL OR NOT
;
; CATEGORY:
;		PROGRAMMING CONTROL
;		 
;
; CALLING SEQUENCE:RESULT = SAME(ARRAY)
;
; INPUTS:
;		ARRAY:	INPUT  ARRAY
;		
; OPTIONAL INPUTS:
;		NONE	
;		
; KEYWORD PARAMETERS:
; NONE

; OUTPUTS: 1=IF SAME'0=NOT SAME 
;		
;; EXAMPLES:
;  PRINT, SAME(['A','B','C'])
;  PRINT, SAME(['A','A','A'])
;  PRINT, SAME(INTARR(9))
;  PRINT, SAME(INDGEN(9))

; 
; MODIFICATION HISTORY:
;			WRITTEN NOV 2,2012 J.O'REILLY
;#################################################################################
;-
;	***********************
ROUTINE_NAME='SAME'
; ***********************
; 
OK = WHERE(ARRAY EQ ARRAY[0],COUNT)
IF COUNT EQ N_ELEMENTS(ARRAY) THEN RETURN, 1 ELSE RETURN, 0

DONE:          
	END; #####################  END OF ROUTINE ################################
