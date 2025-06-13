; $ID:	GET_EXPON.PRO,	2020-07-01-12,	USER-KJWH	$
; ===> CHOOSE ONE: PRO OR FUNCTION 
;#############################################################################################################
	FUNCTION GET_EXPON,VALUES
	
;  PRO GET_EXPON
;+
; NAME:
;		GET_EXPON
;
; PURPOSE: THIS FUNCTION  EXTRACTS THE VALUE OF THE EXPONENT FROM NUMBERS 
;
; CATEGORY:
;		MATH
;		 
;
; CALLING SEQUENCE:RESULT =GET_EXPON(VALUES)
;
; INPUTS:
;		VALUES:	INPUT DATA/VALUES
;		
; OPTIONAL INPUTS:
;		NONE:	
;		
; KEYWORD PARAMETERS:
;		NONE:

; OUTPUTS:
;		
;; EXAMPLES:
;   PRINT,GET_EXPON([1.0D,12345.6789E33,1e9,6E-12])
;	NOTES:

;		
;
;
; MODIFICATION HISTORY:
;			WRITTEN MAR 31,2012  J.O'REILLY
;#################################################################################
;
;
;-
;	*******************************************
ROUTINE_NAME='GET_EXPON'
; *******************************************

; ===> USEFUL WORDS FOR SEARCHING:
; STOP PRINT N_ELEMENTS  ENDFOR SWITCHES  RETURN    ,
; 
S=STRTRIM(VALUES,2)
EXS = REPLICATE(0,N_ELEMENTS(VALUES))
POS = STRPOS(S,'e')
EX= STRMID(S,POS)

OK=WHERE(POS GE 0,COUNT)
IF COUNT GE 1 THEN BEGIN
EXS[OK] = EX(0,OK)
STOP

ENDIF;IF COUNT GE 1 THEN BEGIN
STOP
RETURN,EX
DONE:          
	END; #####################  END OF ROUTINE ################################
