; $Id: SECONDS1992_2JD.pro  Sept 19, 2003
;+
;	This Function Converts Seconds Since Jan 1, 1992 to Julian Day

; HISTORY:
;		May 28, 2003 Written by:	J.E. O'Reilly, NOAA, 28 Tarzwell Drive, Narragansett, RI 02882
;-
; *************************************************************************

FUNCTION SECONDS1992_2JD,SECONDS_SINCE_1992
  ROUTINE_NAME='SECONDS1992_2JD'
; ===>  JULDAY(Month, Day, Year, Hour, Minute, Second)
  JD_1992 = JULDAY(1, 1, 1992, 0, 0, 0)
  DAYS = SECONDS_SINCE_1992/SECONDS_DAY()
  RETURN, JD_1992 + DAYS
END; #####################  End of Routine ################################
