; $Id:	month_names.pro,	May 30 2012	$
;#############################################################
FUNCTION MONTH_NAMES,Month, SHORT=short,LETTER=letter,SUN=SUN
;+
; NAME:
;       MONTH_NAMES
;
; PURPOSE:
;       Return Month names
;
; CALLING SEQUENCE:
;       Result = MONTH_NAMES()
;       Result = MONTH_NAMES(2)
;       Result = MONTH_NAMES(2,/SHORT)
;       Result = MONTH_NAMES(1,/SUN)
;
; INPUTS:
;
;
; KEYWORD PARAMETERS:
;		SHORT: 		Returns 3 letter month name(s)
;		LETTER..	Returns first letter of the month name (s)
;		SUN.....	Returns Months in order of sun time beginning with December, Jan, Feb ...
;
; MODIFICATION HISTORY:
;       Written by:  J.E.O'Reilly, August 31,1999
;-


  MONTHS = ['January','February','March','April','May','June','July','August','September',$
               'October','November','December']

  IF KEYWORD_SET(SHORT) THEN MONTHS = STRMID(MONTHS,0,3)
  IF KEYWORD_SET(LETTER) THEN MONTHS = STRMID(MONTHS,0,1)


  IF KEYWORD_SET(SUN) THEN BEGIN
    MN = [MONTHS[11],MONTHS[0:5]]
    MN[1:5] = MN[1:5] + ', '+REVERSE(MONTHS[6:10]    )
    MONTHS = MN
  ENDIF
  
  IF N_ELEMENTS(Month) GE 1 THEN BEGIN
    MONTHS = MONTHS[Month-1]
  ENDIF
  RETURN, MONTHS


END; #####################  END OF ROUTINE ################################
