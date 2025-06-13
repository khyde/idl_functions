; $ID:	DYEAR_2JD.PRO,	2014-04-29	$

;#######################################################################
FUNCTION DYEAR_2JD, DYEAR
;+
; NAME:
;       DYEAR_2JD
;
; PURPOSE:
;       COMPUTE THE JULIAN DAY FROM THE DECIMAL YEAR
;
; CATEGORY:
;       DATE TIME
;
; CALLING SEQUENCE:
;       RESULT = DYEAR_2JD(JD)
;
; INPUTS:
;       JD

;	EXAMPLES: JD = DATE_2JD(DATE_NOW()) & DYEAR = JD_2DYEAR(JD) & _JD = DYEAR_2JD(DYEAR) & P,JD,_JD
;
; KEYWORD PARAMETERS:
;       NONE
;
; OUTPUTS:
;       DECIMAL YEARS
;
; MODIFICATION HISTORY:
;       WRITTEN BY:  J.E.O'REILLY, FEB 15,2014
;
;
;##########################################################################
;-
;**************************
	ROUTINE_NAME='DYEAR_2JD'
;**************************

YEAR  = FIX(DYEAR)
PART = DYEAR - YEAR
DPY = DOUBLE(DATE_DAYS_YEAR(YEAR))
DOY = PART*DPY
RETURN, YDOY_2JD(YEAR,DOY)


  END; #####################  END OF ROUTINE ################################
