; $ID:	YRFRA_2JD.PRO,	2014-04-29	$
;+
;;#############################################################################################################
	FUNCTION YRFRA_2JD,YRFRA
;
;
; PURPOSE: THIS FUNCTION CONVERTS YRFRA [DECIMAL YEARS] INTO JULIAN DAY
; 
; 
; CATEGORY:	DATE;		 
;
; CALLING SEQUENCE: RESULT = YRFRA_2JD(YRFRA)
;
; INPUTS: YRFRA : DECIMAL YEARS

; OPTIONAL INPUTS:
;		NONE:	
;		
; KEYWORD PARAMETERS:
;   NONE

; OUTPUTS: 
;		
;; EXAMPLES:
;  PRINT, YRFRA_2JD(2003.6)
;  JD_2DATE(YRFRA_2JD(YRFRA(DATE_NOW())))
;	NOTES:
;
; MODIFICATION HISTORY:
;			WRITTEN OCT 11, 2013 J.O'REILLY
;#################################################################################
;-
;****************************
ROUTINE_NAME  = 'YRFRA_2JD'
;****************************
YEAR = FIX(YRFRA) & FRA = YRFRA-YEAR
DPY = DATE_DAYS_YEAR(YEAR)
DOY = FRA*DPY
RETURN,YDOY_2JD(YEAR,DOY)

DONE:          
	END; #####################  END OF ROUTINE ################################
