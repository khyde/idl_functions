; $ID:	DATE_2SECONDS1970.PRO,	2017-06-22-12,	USER-KJWH	$
;+
;	This Function Converts DATE to Seconds Since Jan 1, 1970
;
; HISTORY:
;		Jun 22, 2017 Written by:	Kimberly J. W. Hyde, NOAA, 28 Tarzwell Drive, Narragansett, RI 02882
;-
; *************************************************************************

FUNCTION DATE_2SECONDS1970, DATE
  ROUTINE_NAME='DATE_2SECONDS1970'
; ===>  JULDAY(Month, Day, Year, Hour, Minute, Second)
  JD = DATE_2JD(DATE)
  JD_1970 = JULDAY(1, 1, 1970, 0, 0, 0)
  SECONDS_SINCE_1970 = (JD - JD_1970)*SECONDS_DAY() ;
  RETURN, SECONDS_SINCE_1970
END; #####################  End of Routine ################################
