; $ID:	STATS_PERIODS.PRO,	2020-06-26-15,	USER-KJWH	$
;+
;;#############################################################################################################
	FUNCTION STATS_PERIODS,JD,DATA,PROD=PROD,PERIOD_CODE=PERIOD_CODE,DATE=DATE, $
                          JD_START=JD_START, JD_END=JD_END,$
                          WIDTH=WIDTH,$
                          NOLEAP=NOLEAP, $
                          STD=STD, SAME_JD=SAME_JD, QUIET=QUIET, INIT=INIT

; PURPOSE: THIS FUNCTION RETURNS STATS FROM STATS_PERIOD FOR SEVERAL PERIODS
; 
; 
; CATEGORY:	STATS;		 
;
; CALLING SEQUENCE: RESULT = STATS_PERIODS(VAR)
;
; INPUTS: SAME AS STATS_PERIOD  

; OPTIONAL INPUTS:
;		
; KEYWORD PARAMETERS:

; OUTPUTS: 
;		
;; EXAMPLES:


;	NOTES:

;
; MODIFICATION HISTORY:
;			WRITTEN OCT 11, 2013 J.O'REILLY
;#################################################################################
;-
;*******************************
ROUTINE_NAME  = 'STATS_PERIODS'
;*******************************


;*************************************************************************
; ************   P E R I O D     M  E  A  N  S   **************************
; *************************************************************************
PRINT,'WORKS  ONLY FOR M TO MONTH ANDM TO YEAR'
; TESTING DATASET CHL BALTIC SEA
S = IDL_RESTORE('JUNK.SAV') 
PROD = 'CHLOR_A'
JD = S.JD
DATA = S.DATA
HELP,JD,DATA
; ===> M IN  > MONTH OUT
PRINT,'NOT WORKING'
STOP
PER_MONTH     =STATS_PERIOD(JD,DATA,PERIOD_CODE='MONTH')
OK = WHERE(PER_MONTH.N GT 0,N_MONTH)
PER_MONTH = CREATE_STRUCT(PER_MONTH,'N_MONTH',N_MONTH)


D = CREATE_STRUCT(D,'N_MONTH_CHL',N_MONTH_CHL,'CHL_MONTH_MEAN',CHL_MONTH_MEAN)
; ===> MONTH > Y
PER_M     =STATS_PERIOD(PER_D.JD,PER_D.MEAN,  PERIOD_CODE='M',   /QUIET)

; ===> D > DOY
PER_DOY =STATS_PERIOD(PER_D.JD,PER_D.MEAN,    PERIOD_CODE='DOY',/QUIET)

; ===> M > Y
PER_Y     =STATS_PERIOD(PER_M.JD,PER_M.MEAN,  PERIOD_CODE='Y',   /QUIET)

; ===> Y > YEAR  (Must usually have all 12 months, but at least MPY_MIN)
OK=WHERE(PER_Y.N GE MPY_MIN,COUNT)
IF COUNT GE 1 THEN PER_YEAR =STATS_PERIOD(PER_Y[OK].JD,PER_Y[OK].MEAN,  PERIOD_CODE='YEAR',/QUIET) $
ELSE PER_YEAR =STATS_PERIOD(PER_Y.JD,MISSINGS(PER_Y.MEAN),  PERIOD_CODE='YEAR',/QUIET)

; ===> M > MONTH
PER_MONTH =STATS_PERIOD(PER_M.JD,PER_M.MEAN,        PERIOD_CODE='MONTH',/QUIET)


; ===> MONTH > ANNUAL
PER_ANNUAL =STATS_PERIOD(PER_MONTH.JD,PER_MONTH.MEAN,PERIOD_CODE='ANNUAL',/QUIET)


;
;RETURN,
DONE:          
	END; #####################  END OF ROUTINE ################################
