; $ID:	DAYS_WEEK.PRO,	2004 02 24 09:25	$

FUNCTION DAYS_WEEK, WEEK, year=year
;+
; NAME:
;       DAYS_WEEK
;
; PURPOSE:
;       Compute the number of days in any WEEK (1 TO 52)
;
; CATEGORY:
;       Date Time
;
; CALLING SEQUENCE:
;       Result = DAYS_WEEK(WEEK)
;       Result = DAYS_WEEK(WEEK,year=year)
;
; INPUTS:
;       WEEK (must be between 1-52)
;
;
; KEYWORD PARAMETERS:
;       year (must have century, e.g. 1978)
;
; OUTPUTS:
;       The number of days in the supplied WEEK (usually 7 except 8 DAYS for the last week of the year, and 9 days for leap years)
 ;
; PROCEDURE:
;       If year not provided then the number of days in the current week are returned.
;
; MODIFICATION HISTORY:
;       Written by:  J.E.O'Reilly, Dec 27,,1999

;-

; =====> Check if specific year supplied if not use current year for days per WEEK
  IF N_ELEMENTS(YEAR) EQ 1 THEN BEGIN
    AYEAR = YEAR
  ENDIF ELSE BEGIN
    JULIAN = SYSTIME(/UTC,/JULIAN)
    AYEAR  = STRTRIM(string(JULIAN,FORMAT='(C(CYi4.4))'),2)
  ENDELSE

; =====>
  DAYS = [REPLICATE(7,51),8]

  IF DATE_DAYS_YEAR(AYEAR) EQ 366 THEN DAYS(51) = 9

  IF N_ELEMENTS(WEEK) GE 1 THEN RETURN, DAYS(WEEK) ELSE RETURN, DAYS


  END ; OF PROGRAM
