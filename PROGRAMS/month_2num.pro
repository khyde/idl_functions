; $ID:	MONTH_2NUM.PRO,	2020-06-26-15,	USER-KJWH	$
;+
;;#############################################################################################################
	FUNCTION MONTH_2NUM, MONTH, NO_ZERO=NO_ZERO

; PURPOSE: THIS FUNCTION RETURNS THE NUMBER OF THE MONTH BASED ON EITHER THE FULL OR SHORT MONTH NAME
; 
; 
; CATEGORY:	DATE;		 
;
; CALLING SEQUENCE: RESULT = MONTH_2NUM(MONTH)
;
; INPUTS: MONTH [JAN,FEB,MAR,APR, ETC.]
;
; OPTIONAL INPUTS:  NONE
;		
; KEYWORD PARAMETERS:  NO_ZERO - To remove the 0 at the beginning of single digit months
;
; OUTPUTS: RULL NAME OF MONTH
;		
; EXAMPLES:
;   PRINT, MONTH_2NUM('JAN')
;   PRINT, MONTH_2NUM('JANUARY')
;   PRINT, MONTH_2NUM('JANUARY',/NO_ZERO)
;   
;	NOTES:
;
;
; MODIFICATION HISTORY:
;			Written JAN 25, 2016 by K.J.W. Hyde, 28 Tarzwell Drive, NMFS, NOAA 02882 (kimberly.hyde@noaa.gov)
;			
;#################################################################################
;-
;****************************
  ROUTINE_NAME  = 'MONTH_2NUM'
;****************************
  NUMS = MONTH_NUMBERS(SHORT=NO_ZERO)

  IF N_ELEMENTS(MONTH) EQ 0 THEN RETURN, NUMS
  IF MIN(STRLEN(MONTH)) LT 3 THEN RETURN, 'ERROR: Must input at least the first 3 letters of the month name'

; ===> Get the SHORT name of the MONTH
  MONTHS = STRUPCASE(STRMID(MONTH,0,3))
  
; ===> Get short names of all months
  MONS=STRUPCASE(MONTH_NAMES(/SHORT))

  OK = WHERE_MATCH(MONS,MONTHS,COUNT)
  
  IF COUNT GE 1 THEN RETURN,NUMS[OK]

DONE:          
	END; #####################  END OF ROUTINE ################################
