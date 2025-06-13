; $ID:	DATE_2YEAR.PRO,	2020-06-30-17,	USER-KJWH	$

function DATE_2YEAR ,DATE
;+
; NAME:
;       DATE_2YEAR
;
; PURPOSE:
;				Generate a YEAR (Usually e.g. 1999 )
;
; CATEGORY:
;		DATE
;
; CALLING SEQUENCE:
;       Result = DATE_2YEAR('19770319')
;
; INPUTS:
;

;
; MODIFICATION HISTORY:
;       Written by:  J.E.O'Reilly, July 17,2006
;-



; ===> Program assumes date is a string 8 characters long
; Example 19770317

; ===> Trim date string, determine julian, then YEAR
   YEAR= JD_2YEAR(DATE_2JD(STRTRIM(DATE,2)))  ;
   IF N_ELEMENTS(YEAR) EQ 1 THEN RETURN, YEAR[0] ELSE RETURN, YEAR

  END ; END OF PROGRAM
