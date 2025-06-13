; $ID:	YY_2YEAR.PRO,	2020-06-26-15,	USER-KJWH	$

FUNCTION YY_2YEAR, YY
;+
; NAME:
;       YY_2YEAR
;
; PURPOSE:
;				Generate a 4 digit YEAR (e.g. 1999) from a 2 digit year (e.g. 99)
;
; CATEGORY:
;		DATE
;
; CALLING SEQUENCE:
;   Result = YY_2YEAR('97')
;
; INPUTS:
;
;	NOTES:
;		***************************  WARNING ******************************
;		This program is only valide for 2 digit years between 1950 and 2049
;   *******************************************************************
;
; MODIFICATION HISTORY:
;       Written by:  Kimberly J.W. Hyde - May 2, 2007
;-

		YY = STRTRIM(STRING(YY),2)
		YEAR = REPLICATE('',N_ELEMENTS(YY))
		OK = WHERE(STRLEN(YY) NE 2,COUNT)
		IF COUNT GE 1 THEN BEGIN
			PRINT, 'ERROR - Input must be a 2 digit year'
			STOP
		ENDIF
		OK = WHERE(YY GE '50' AND YY LE '99',COUNT, COMPLEMENT=COMPLEMENT, NCOMPLEMENT=NCOMPLEMENT)
		IF COUNT GE 1 THEN YEAR[OK] = '19'+ YY[OK]
		IF NCOMPLEMENT GE 1 THEN YEAR(COMPLEMENT) = '20' + YY(COMPLEMENT)
   	RETURN, YEAR

  END ; END OF PROGRAM
