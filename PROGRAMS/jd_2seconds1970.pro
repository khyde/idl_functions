; $ID:	JD_2SECONDS1970.PRO,	2004 02 03 17:34	$
;+
;	This Function Converts Julian Day to Seconds Since Jan 1, 1970
;
; HISTORY:
;		May 28, 2003 Written by:	J.E. O'Reilly, NOAA, 28 Tarzwell Drive, Narragansett, RI 02882
;-
; *************************************************************************

FUNCTION JD_2SECONDS1970, JD
  ROUTINE_NAME='JD_2SECONDS1970'
; ===>  JULDAY(Month, Day, Year, Hour, Minute, Second)
  JD_1970 = JULDAY(1, 1, 1970, 0, 0, 0)
  SECONDS_SINCE_1970 = (JD - JD_1970)*SECONDS_DAY() ;
  RETURN, SECONDS_SINCE_1970
END; #####################  End of Routine ################################
