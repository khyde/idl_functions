; $ID:	SUN_SRLOCAT.PRO,	2020-06-30-17,	USER-KJWH	$
;+
;NAME:
;   SUN_SRLOCAT
;
;PURPOSE:
;
;CATEGORY:
;
;CALLING SEQUENCE:
;		ROUTINE_NAME, Parameter1, Parameter2, Foobar
;		Result = FUNCTION_NAME(Parameter1, Parameter2, Foobar)
;
;INPUTS:
;		Parm1:	Describe the positional input parameters here. Note again
;		that positional parameters are shown with Initial Caps.
;
;KEYWORDS:
;
;OUTPUTS:
;
;EXAMPLE:
;
;NOTES:
; http://aom.giss.nasa.gov/srlocat.html
;	FORTRAN PROGRAM EDITED: SRLOCAT
;
;HISTORY:
; 	Oct 6, 2003,	Written by:	J.E. O'Reilly, NOAA, 28 Tarzwell Drive, Narragansett, RI 02882
;-
; *************************************************************************

FUNCTION SUN_SRLOCAT, LON,LAT,YEAR
  ROUTINE_NAME='SUN_SRLOCAT'
  CMD_FORTRAN = 'D:\FORT\SRLOCAT.EXE '
;  CMD_FORTRAN = 'D:\FORT\SRLOCAT\DEBUG\SRLOCAT.EXE '

	IF N_ELEMENTS(YEAR) NE 1 THEN _YEAR=2000 ELSE _YEAR = YEAR


	IF N_ELEMENTS(LON) NE 1  THEN _LON = 0.0 ELSE _LON = LON
	IF N_ELEMENTS(LAT) NE 1  THEN _LAT = 0.0 ELSE _LAT = LAT

	CMD = CMD_FORTRAN + STRTRIM(_LAT,2)  + ' ' + STRTRIM(_LON,2) + ' ' + STRTRIM(_YEAR,2)
  SPAWN,CMD,TXT
  NAMES= STRTRIM(WORDS(TXT[0],DELIM=','),2)
	STRUCT = TXT_2STRUCT(TXT(1:*),DELIM=',')
	SNAMES = '_'+ STRTRIM(SINDGEN(N_ELEMENTS(NAMES)),2)
	STRUCT = STRUCT_RENAME(STRUCT, SNAMES  , NAMES)
	STRUCT.DATE 		= STR_SPACE2ZERO(STRUCT.DATE)
	STRUCT.SUNRISE 	= STR_SPACE2ZERO(STRUCT.SUNRISE)
	STRUCT.SUNSET 	= STR_SPACE2ZERO(STRUCT.SUNSET)

 	RETURN,STRUCT

END; #####################  End of Routine ################################
