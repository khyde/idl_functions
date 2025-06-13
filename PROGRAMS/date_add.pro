; $ID:	DATE_ADD.PRO,	2019-04-30-20,	USER-KJWH	$

FUNCTION DATE_ADD, DATE, ADD, YEAR=year, MONTH=month, DAY=day, HOUR=hour, MINUTE=minute, SECOND=second

;+
; NAME:
;       DATE_ADD
; INPUTS:
;       DATE
;       ADD.....The value in years, months, days, hours, minutes or seconds to be added to the DATE
;       
;       
;       
;	NOTES:
;
; MODIFICATION HISTORY:
;     Written:  April 30, 2019 by K.J.W.Hyde, 28 Tarzwell Drive, NMFS, NOAA 02882 (kimberly.hyde@noaa.gov)
;     Modified: 
;                                    

;-
; ===================>
  IF N_ELEMENTS(DATE) EQ 0 THEN RETURN,-1
  IF N_ELEMENTS(ADD)  NE 1 THEN ADD = 0 
  
  JD = DATE_2JD(DATE)
  JULIAN = JD_ADD(JD, ADD, YEAR=year,MONTH=month,DAY=day,HOUR=hour,MINUTE=minute,SECOND=second)
  RETURN, JD_2DATE(JULIAN)
 

END; #####################  End of Routine ################################

