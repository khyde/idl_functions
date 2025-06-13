; $ID:	DATE_HR_2HHMM.PRO.PRO,	2004 JAN 31 14:39	$
;
  FUNCTION DATE_HR_2HHMM, DECIMAL_HOURS
;+
; NAME:
;       DATE_HR_2HHMM.PRO
;
; PURPOSE:
;       Convert DECIMAL_HOURS into the format:  HHMM
;
; CATEGORY:
;       DATE_TIME
;
; CALLING SEQUENCE:
;
;       HOUR= [23.00,23.01,23.02,23.03] & PRINT, DATE_HR_2HHMM(HOUR)
;
; INPUTS:
;       DECIMAL HOURS
;
; KEYWORD PARAMETERS:
;				NONE
;
; OUTPUTS:
;       Hours and Minutes formatted as a string: HHMM
;
; SIDE EFFECTS:
;       This routine rounds to nearest minute (MM).
;
; RESTRICTIONS:;
;      Input is DECIMAL_HOURS (e.g. 14.2, 23.54 )
;
; MODIFICATION HISTORY:
;       Written by:  J.E.O'Reilly, Dec 22, 2005
;-

; *******************************************************************************
;	===> Convert to String HHMM

	RETURN, STRING(FIX(DECIMAL_HOURS), FORMAT = '(I02)')  + STRING(ROUND(DECIMAL_HOURS MOD 1 *60.),FORMAT='(-I02)')

END
