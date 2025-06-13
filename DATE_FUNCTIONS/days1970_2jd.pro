; $ID:	DAYS1970_2JD.PRO,	2019-03-27-15,	USER-KJWH	$
;+
;	This Function Converts Seconds Since Jan 1, 2001 to Julian Day

; HISTORY:
;		Mar 27, 2019 Written by K.J.W. Hyde, NOAA/NEFSC/Narragansett Laboratory, 28 Tarzwell Drive, 02882 (kimberly.hyde@noaa.gov)
;		Jun 05, 2023 - KJWH: Removed the JD_ADD() option and am now simply adding the input days to the JULDAY
;-
; *************************************************************************

FUNCTION DAYS1970_2JD, DAYS_SINCE_1970
  ROUTINE_NAME='DAYS1970_2JD'
; ===>  JULDAY(Month, Day, Year, Hour, Minute, Second)
  JD_1970 = JULDAY(01, 01, 1970, 0, 0, 0)
  RETURN, JD_1970 + DOUBLE(DAYS_SINCE_1970)
END; #####################  End of Routine ################################
