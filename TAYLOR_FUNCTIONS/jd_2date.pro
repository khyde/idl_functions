; $Id:	jd_2date.pro,	February 22 2007	$

FUNCTION JD_2DATE ,JD, ERROR=error
;+
; NAME:
;		JD_2DATE
; INPUTS:
;		Julian Day
; PURPOSE:
;		This function converts Julian Day into Date (YYYYMMDDHHMMSS) format
;
; CATEGORY:
;		DATE_TIME
;
; CALLING SEQUENCE:
;		Result = JD_2DATE(Jd)
;
; INPUTS:
;		JD:	Julian Date (see IDL help)
;
; OUTPUTS:
;		Date String formatted as YYYYMMDDHHMMSS
;
; OPTIONAL OUTPUTS:
;		ERROR:     Any Error messages are placed in ERROR, if no errors then ERROR = ''
;
; EXAMPLE:
;		    PRINT, JD_2DATE(DATE_2JD(DATE_NOW()))
;
; MODIFICATION HISTORY:
;       Written by:  J.E.O'Reilly, Sept 29,2000
;				April 8, 2003 REPLACES STRING_FORMAT WITH STRING, JOR
;				Feb 22,2007 jor checks now for missing JDs
;-
;	****************************************************************************************************
	ROUTINE_NAME = 'JD_2DATE'
	ERROR = ''
; ===>
  IF N_ELEMENTS(JD) EQ 0 THEN BEGIN
  	ERROR = 'Must provide Julian Date'
  	RETURN,''
  ENDIF

;	===> Make a String Array for output
	DATE = REPLICATE('',N_ELEMENTS(JD))

;	===> Find the valid Julian Days
	OK = WHERE(FINITE(JD) AND DATE NE MISSINGS(JD),COUNT)

;	===> Convert Julian Day to Date using IDL Format
	IF COUNT GE 1 THEN DATE(OK) = STRING(JD(OK),FORMAT='(C(CYi4.4,CMoi2.2,CDi2.2,CHi2.2,CMi2.2,CSi2.2))')

	IF N_ELEMENTS(DATE) EQ 1 THEN RETURN, DATE(0) ELSE RETURN, DATE


END; #####################  End of Routine ################################

