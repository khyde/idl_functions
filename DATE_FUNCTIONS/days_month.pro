; $ID:	DAYS_MONTH.PRO,	2020-07-31-14,	USER-KJWH	$

FUNCTION DAYS_MONTH, MONTH, YEAR=YEAR, STRING=STRING
;+
; NAME:
;       DAYS_MONTH
;
; PURPOSE:
;       Compute the number of days in any month
;
; CATEGORY:
;       Date Time
;
; CALLING SEQUENCE:
;       Result = DAYS_MONTH(month)
;       Result = DAYS_MONTH(month,year=year)
;
; INPUTS:
;  MONTH - Number between 1-12
;
;
; KEYWORD PARAMETERS:
;  YEAR - To account for 29 day in February during leap year (must have century, e.g. 1978)
;  STRING - Return a string value
; 
; OUTPUTS:
;       The number of days in the supplied year
; 
; SIDE EFFECTS:
;       None.
;
; RESTRICTIONS:
;   None.
;
; PROCEDURE:
;   If year not provided then the number of days in the current year are returned.
;
; MODIFICATION HISTORY:
;   Written by:  J.E.O'Reilly, Dec 27,1999
;   DEC 04, 2017 - KJWH: Added STRING keyword to return the value as a string    
;-

; =====> Check if specific year supplied if not use current year for days per month
  IF N_ELEMENTS(YEAR) EQ 1 THEN BEGIN
    AYEAR = YEAR
  ENDIF ELSE BEGIN
    JULIAN = SYSTIME(/UTC,/JULIAN)
    AYEAR  = STRTRIM(string(JULIAN,FORMAT='(C(CYi4.4))'),2)
  ENDELSE

; =====>
  DAYS = [0, 31,28,31,30,31,30,31,31,30,31,30,31]
  IF DATE_DAYS_YEAR(AYEAR) EQ 366 THEN DAYS(2) = 29

  IF KEY(STRING) THEN DAYS = STRTRIM(DAYS,2)

  IF N_ELEMENTS(MONTH) GE 1 THEN RETURN, DAYS(MONTH) ELSE RETURN, DAYS(1:12)


  END ; OF PROGRAM
