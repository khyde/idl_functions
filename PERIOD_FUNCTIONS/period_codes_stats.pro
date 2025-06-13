; $ID:	PERIOD_CODES_STATS.PRO,	2018-07-17-13,	USER-KJWH	$
;+
;#############################################################################################################
	FUNCTION PERIOD_CODES_STATS, PERIOD_CODE, VERBOSE=VERBOSE
;
; NAME:
;   PERIOD_CODES_STATS
;
; PURPOSE:
;   This function returns the default input period code for a given stat period code
;
; CATEGORY:
;   PERIODS/STATS
;
; CALLING SEQUENCE:
;   Result = PERIOD_CODES_STATS(PERIOD_CODE)
;
; INPUTS:
;   PERIOD_CODE:  The stat period code
;
; OPTIONAL INPUTS:
;   
; KEYWORD PARAMETERS:
;   VERBOSE: Print the output
;
; OUTPUTS:
;   This function returns the default input period code
;
; OPTIONAL OUTPUTS:
;   
; PROCEDURE:
;
; EXAMPLES: 
;     PRINT, PERIOD_CODES_STATS('M',/VERBOSE) 
;     PRINT, PERIOD_CODES_STATS('A',/VERBOSE)   
; 
; NOTES:
;  
;
; MODIFICATION HISTORY:
;     Written:  April 18, 2017 by K.J.W. Hyde, 28 Tarzwell Drive, NMFS, NOAA 02882 (kimberly.hyde@noaa.gov)
;     Modified: 
;       APR 19, 2017 - KJWH: Changed the IPC of MANNUAL from M to MONTH
;       SEP 12, 2017 - KJWH: Changed the IPC of ANNUAL from M to A
;       JUL 17, 2018 - KJWH: Added MONTH3 : IPC = 'M3'
;			
;#################################################################################
;-

; **********************************
  ROUTINE_NAME  = 'PERIOD_CODES_STATS'
; **********************************

  CASE PERIOD_CODE OF
    'S'      : IPC = 'S'
    'SS'     : IPC = 'S'
    'D'      : IPC = 'S'
    'DOY'    : IPC = 'S'
    'D3'     : IPC = 'S'
    'D8'     : IPC = 'S'
    'DD'     : IPC = 'S'
    'W'      : IPC = 'S'
    'WW'     : IPC = 'W'
    'WEEK'   : IPC = 'W'
    'M'      : IPC = 'S'
    'MM'     : IPC = 'M'
    'M3'     : IPC = 'M'
    'MONTH'  : IPC = 'M'
    'MONTH3' : IPC = 'M3'
    'A'      : IPC = 'M'
    'ANNUAL' : IPC = 'A'
    'MANNUAL': IPC = 'MONTH'
    'Y'      : IPC = 'S'
    'YY'     : IPC = 'S'
    'YEAR'   : IPC = 'S'
    'STUDY'  : IPC = 'S'
    'ALL'    : IPC = 'S'
    ELSE     : IPC = 'S'
  ENDCASE

  IF KEY(VERBOSE) THEN PRINT, IPC + ' - is the default input period code for stat period ' + PERIOD_CODE
  RETURN, IPC

END; #####################  END OF ROUTINE ################################
