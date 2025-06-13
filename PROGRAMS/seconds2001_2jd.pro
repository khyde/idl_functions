; $ID:	SECONDS2001_2JD.PRO,	OCTOBER 14 2004, 10:38	$
;+
;	This Function Converts Seconds Since Jan 1, 2001 to Julian Day

; HISTORY:
;		May 28, 2003 Written by:	J.E. O'Reilly, NOAA, 28 Tarzwell Drive, Narragansett, RI 02882
;-
; *************************************************************************

FUNCTION SECONDS2001_2JD,SECONDS_SINCE_2001
  ROUTINE_NAME='SECONDS2001_2JD'
; ===>  JULDAY(Month, Day, Year, Hour, Minute, Second)
  JD_2001 = JULDAY(1, 1, 2001, 0, 0, 0)
  DAYS = SECONDS_SINCE_2001/SECONDS_DAY()
  RETURN, JD_2001 + DAYS
END; #####################  End of Routine ################################
