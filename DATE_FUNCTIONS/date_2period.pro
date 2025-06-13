; $ID:	DATE_2PERIOD.PRO,	2020-06-26-15,	USER-KJWH	$
 
;#############################################################################
 FUNCTION DATE_2PERIOD, DATE
;+
; NAME:
;       DATE_2PERIOD
;
; PURPOSE:
;       CONVERT A STANDARD DATE INTO A STANDARD PERIOD (SEE VALID_PERIOD_CODES.PRO) JULIAN DAY
;
; CATEGORY:
;       DATE_TIME;

; INPUTS:
;       DATE: THE FORMAT MUST BE ANY OF THE FOLLOWING (NO SPACES)
;							YYYYMMDDHHMMSS
;							YYYYMMDDHHMM
;							YYYYMMDDHH
;							YYYYMMDD
;							YYYYMM
;							YYYY

; RESTRICTIONS:
;    INPUT PERIOD MUST BE A VALID DATE OR DATE RANGE

;
; MODIFICATION HISTORY:
;      FEB 8, 2004 WRITTEN BY:  J.E.O'REILLY
;      APR 2,2014,JOR REMOVED ! FROM ALL 
;      JUL 1,2014,JOR FORMATTING
;#############################################################################
;-
;****************************
ROUTINE_NAME = 'DATE_2PERIOD'
;****************************
N = N_ELEMENTS(DATE)
PERIODS = ['Y','M','D','H','T','S']+'_'

_DATE=STRTRIM(DATE,2)
LEN=STRLEN(_DATE)
PER = REPLICATE('',N)

OK=WHERE(LEN MOD 2 EQ 0,COUNT)
IF COUNT GE 1 THEN PER[OK] = PERIODS(LEN[OK]/2-2)+_DATE[OK] ;
RETURN, PER
END; #####################  END OF ROUTINE ################################
