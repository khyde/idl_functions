; $ID:	SECONDS2001_2JD.PRO,	OCTOBER 14 2004, 10:38	$
;+
;	This Function Converts Seconds Since Jan 1, 2001 to Julian Day

; HISTORY:
;		May 28, 2003 Written by:	J.E. O'Reilly, NOAA, 28 Tarzwell Drive, Narragansett, RI 02882
;-
; *************************************************************************

FUNCTION DAYS1800_2JD, DAYS_SINCE_1800
  ROUTINE_NAME='DAYS1800_2JD'
; ===>  JULDAY(Month, Day, Year, Hour, Minute, Second)
  JD_1800 = JULDAY(01, 01, 1800, 0, 0, 0)
  RETURN, JD_ADD(JD_1800,DOUBLE(DAYS_SINCE_1800),/DAY)
END; #####################  End of Routine ################################
