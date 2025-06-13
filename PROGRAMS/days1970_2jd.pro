; $ID:	DAYS1970_2JD.PRO,	2019-03-27-15,	USER-KJWH	$
;+
;	This Function Converts Seconds Since Jan 1, 2001 to Julian Day

; HISTORY:
;		Mar 27, 2019 Written by K.J.W. Hyde, NOAA/NEFSC/Narragansett Laboratory, 28 Tarzwell Drive, 02882 (kimberly.hyde@noaa.gov)
;-
; *************************************************************************

FUNCTION DAYS1970_2JD, DAYS_SINCE_1970
  ROUTINE_NAME='DAYS1970_2JD'
; ===>  JULDAY(Month, Day, Year, Hour, Minute, Second)
  JD_1970 = JULDAY(01, 01, 1970, 0, 0, 0)
  RETURN, JD_ADD(JD_1970,DOUBLE(DAYS_SINCE_1970),/DAY)
END; #####################  End of Routine ################################
