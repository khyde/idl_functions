; $Id:	yy_2year.pro,	May 02 2007	$

FUNCTION YEAR_2YY, YEAR
;+
; NAME:
;       YEAR_2YY
;
; PURPOSE:
;				Generate a 2 digit YEAR (e.g. 99) from a 4 digit year (e.g. 1999)
;
; CATEGORY:
;		DATE
;
; CALLING SEQUENCE:
;   Result = YEAR_2YY('97')
;
; INPUTS:
;
;	NOTES:
;		
;
; MODIFICATION HISTORY:
;       Written by:  Kimberly J.W. Hyde - June 2, 2014
;-

		YR = NUM2STR(YEAR)
		OK = WHERE(STRLEN(YR) NE 4,COUNT)
		IF COUNT GE 1 THEN BEGIN
			PRINT, 'ERROR - Input must be a 4 digit year'
			STOP
		ENDIF
		
   	RETURN, STRMID(YR,2,2)

  END ; END OF PROGRAM
