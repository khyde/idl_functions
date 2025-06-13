; $ID:	ALOGS.PRO,	2014-04-29	$
;###################################################################################
FUNCTION ALOGS,ARRAY,BASE
;+
; NAME:
;       ALOGS
;
; PURPOSE:
;       COMPUTE LOGARITHMS USING VARIOUS BASES 
;
; CATEGORY:
;       MATH
;
; CALLING SEQUENCE:
;       RESULT = ALOGS(A,BASE)
;
; INPUTS:
;       ARRAY 
;       BASE TO USE FOR LOGARITHMIC TRANSFORMATION
;
; KEYWORD PARAMETERS:
;       NONE
; OUTPUTS:
;       LOGARITHM  OF INPUT NUMBERS  TO THE SPECIFIED INPUT BASE 

; EXAMPLES:
; PRINT,ALOGS(10)
; PRINT,ALOGS(1E-3)
; PRINT,ALOGS(10,10)
; PRINT,ALOGS(2,2)
; PRINT,ALOGS(8,2)
; PRINT,ALOGS(3,3)
; PRINT,ALOGS(27,3)
; PRINT,ALOGS(3^3,3)
; PRINT,ALOGS(9.D^9,9)
; PRINT,ALOGS(4^(-0.5),0.5)


; MODIFICATION HISTORY:
;       WRITTEN BY:  J.E.O'REILLY, SEPTEMBER 22, 2013
;###################################################################################
;-
;*********************
ROUTINE_NAME = 'ALOGS'
;*********************
IF N_ELEMENTS(BASE) NE 1 THEN _BASE = 10D ELSE _BASE = DOUBLE(BASE)
  RETURN,ALOG10(ARRAY)/ALOG10(_BASE)
END   ; #####################  END OF ROUTINE ################################
