; $ID:	WHERE_ZERO.PRO,	2014-11-13	$
;#############################################################################################################
	FUNCTION WHERE_ZERO,ARRAY,COUNT,TOL = TOL
	
;  PRO WHERE_ZERO
;+
; NAME:
;		WHERE_ZERO
;
; PURPOSE: THIS FUNCTION FINDS THE SUBSCRIPTS OF AN ARRAY WHERE THE VALUES 
;          ARE CLOSE TO ZERO
;
; CATEGORY:
;		UTILITY
;		 
;
; CALLING SEQUENCE:RESULT = WHERE_ZERO(ARRAY)
;
; INPUTS:
;		ARRAY:	INPUT DATA ARRAY 
;		
; OPTIONAL INPUTS:
;		NONE:	
;		
; KEYWORD PARAMETERS:
;   NONE

; OUTPUTS:
;		
;; EXAMPLES:
;  PRINT, WHERE_ZERO([0])
;  PRINT, WHERE_ZERO([0,1E-2])
;  PRINT, WHERE_ZERO([0,1E-6])
;  PRINT, WHERE_ZERO([0,1E-9])
;  PRINT, WHERE_ZERO([0,0,1E-9])
;	NOTES:

;		
;
;
; MODIFICATION HISTORY:
;			WRITTEN JUN 28,2013 J.O'REILLY
;#################################################################################
;
;-
;***************************
ROUTINE_NAME  = 'WHERE_ZERO'
;***************************

IF N_ELEMENTS(TOL) NE 1 THEN TOL = 1E-7 
LOWER = 0-TOL
UPPER = 0+TOL
RETURN,WHERE(ARRAY GE LOWER AND ARRAY LE UPPER,COUNT)



DONE:          
	END; #####################  END OF ROUTINE ################################
