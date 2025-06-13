; $ID:	PERIODS_DEMO.PRO,	2014-02-11 14	$
;+
;#############################################################################################################
	PRO PERIODS_DEMO

;
; PURPOSE: DEMO TO ILLUSTRATE THE STANDARD PERIODS
;
; CATEGORY:	PERIODS
;
; CALLING SEQUENCE: PERIODS_DEMO
;
; INPUTS: NONE
;		
;		
; OPTIONAL INPUTS:
;		NONE:	
;		
; KEYWORD PARAMETERS:
;		NONE:

; OUTPUTS: 
;		
; EXAMPLES: PERIODS_DEMO
;
;
; MODIFICATION HISTORY:
;			WRITTEN FEB 11,2014 J.O'REILLY
;			
;			
;			
;#################################################################################
;-
;****************************
ROUTINE_NAME  = 'PERIODS_DEMO'
;****************************
;###> SINGLE YEAR - Uses daily data as inputs Y_yyyy
P = VALID_PERIODS('Y_2014')      & ST,P
;###> SINGLE MONTH - Uses daily data as inputs M_yyyymm
P = VALID_PERIODS('M_201401')     & ST,P 
;###> SINGLE WEEK - Uses daily data as inputs W_yyyyww (note, weeks are given as a 2 digit number from 01 to 52)
P = VALID_PERIODS('W_201401')     & ST,P
;###> SINGLE DAY - D_yyyymmdd
P = VALID_PERIODS('D_20140203')   & ST,P
;###> SINGLE HOUR - H_yyyymmddhh
P = VALID_PERIODS('H_2014020312')   & ST,P ; Note, I never use this period (KHyde)
;###> SINGLE MINUTE - T_yyyymmddhhmm
P = VALID_PERIODS('T_201402031258')   & ST,P ; Note, I never use this period (KHyde)
;###> SINGLE SECOND - S_yyyymmddhhmmss
P = VALID_PERIODS('S_20140203125859')   & ST,P
;###> CLIMATOLOGICAL MONTH - Uses M data as inputs MONTH_yyyymm_yyyymm
P = VALID_PERIODS('MONTH_199601_201401')   & ST,P
;###> CLIMATOLOGICAL DAY OF YEAR - Uses daily data as inputs DOY_yyyydoy_yyyydoy (note, DOY is given as a 3 digit number from 001 to 366)
P = VALID_PERIODS('DOY_1998001_2002001')   & ST,P



; & P,SPAN(FLOAT([P.DATE_START,P.DATE_END]))/(60.0*60*24)


END; #####################  END OF ROUTINE ################################
