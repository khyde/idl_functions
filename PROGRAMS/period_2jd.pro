; $ID:	PERIOD_2JD.PRO,	2020-06-30-17,	USER-KJWH	$
;##################################################################
 ;+
 FUNCTION PERIOD_2JD, PERIOD, JD_END=JD_END

; NAME:
;       PERIOD_2JD
;
; PURPOSE:
;       CONVERT A STANDARD PERIOD (SEE VALID_PERIOD_CODES.PRO) JULIAN DAY
;
; CATEGORY:
;       DATE_TIME;

; INPUTS:
;       PERIOD ;
;

; RESTRICTIONS:
;    INPUT PERIOD MUST BE A VALID PERIOD

;
; MODIFICATION HISTORY:
;      JUNE 21, 2003  WRITTEN BY:  J.E.O'REILLY
;      FEB 14,2014,JOR FORMATTING
;##################################################################
;-
;***************************
ROUTINE_NAME = 'PERIOD_2JD'
;***************************

; ===============>
  N = N_ELEMENTS(PERIOD)

; *******************************************************************************
  S_PER		=	PERIOD_2STRUCT(PERIOD)
;  IF S_PER[0].PERIOD EQ '' THEN STOP
  JD 			= DATE_2JD(S_PER.DATE_START)
  JD_END  = DATE_2JD(S_PER.DATE_END)

  IF N_ELEMENTS(JD) EQ 1 THEN BEGIN
  	JD=JD[0]
  	JD_END=JD_END[0]
  ENDIF
  RETURN, JD
END; #####################  END OF ROUTINE ################################
