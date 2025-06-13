; $ID:	SECONDS1970_2JD.PRO,	JANUARY 01,2013 	$
;##############################################################################################
FUNCTION SECONDS1970_2JD,SECONDS_SINCE_1970
;+
;	THIS FUNCTION CONVERTS SECONDS SINCE JAN 1, 1970 TO JULIAN DAY
; NOTE THAT IDL'S SYSTIME RETURNS SECONDS SINCE JAN 1, 1970

; HISTORY:
;		MAY 28, 2003 WRITTEN BY:	J.E. O'REILLY, NOAA, 28 TARZWELL DRIVE, NARRAGANSETT, RI 02882
;		JAN 1,2013,JOR, FORMATTING
; ;##############################################################################################
;-

;******************************************
  ROUTINE_NAME='SECONDS1970_2JD'
;******************************************
;
; ===>  JULDAY(MONTH, DAY, YEAR, HOUR, MINUTE, SECOND)
  JD_1970 = JULDAY(1, 1, 1970, 0, 0, 0)
  DAYS = SECONDS_SINCE_1970/SECONDS_DAY()
  RETURN, JD_1970 + DAYS
END; #####################  END OF ROUTINE ################################
