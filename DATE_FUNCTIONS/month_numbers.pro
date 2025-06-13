; $Id:	month_names.pro,	June 10 2007	$

FUNCTION MONTH_NUMBERS,Month, SHORT=short
;+
; NAME:
;       MONTH_NUMBERS
;
; PURPOSE:
;       Return Month numbers
;
; CALLING SEQUENCE:
;       Result = MONTH_NAMES()
;       Result = MONTH_NAMES(/SHORT)
; INPUTS:
;
;
; KEYWORD PARAMETERS:
;		SHORT: 		Returns month number without a 0 for single digit months
;
; MODIFICATION HISTORY:
;       Written by:  K.J.W. Hyde, November 4, 2009
;-


  MONTHS = ['1','2','3','4','5','6','7','8','9','10','11','12']

  IF NOT KEYWORD_SET(SHORT) THEN MONTHS = ADD_STR_ZERO(MONTHS)
    
  RETURN, MONTHS


  END ; END OF PROGRAM
