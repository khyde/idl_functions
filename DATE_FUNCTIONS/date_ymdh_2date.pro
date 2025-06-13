; $ID:	DATE_YMDH_2DATE.PRO.PRO,	2004 JAN 31 14:39	$
;
  FUNCTION DATE_YMDH_2DATE, YEAR,MONTH,DAY,HOUR, MINUTE, SECOND
;+
; NAME:
;       DATE_YMDH_2DATE.PRO
;
; PURPOSE:
;       Convert DECIMAL_HOURS into the format:  HHMM
;
; CATEGORY:
;       DATE_TIME
;
; CALLING SEQUENCE:
;
;       JD = DATE_YMDH_2DATE.PRO(['2000','200001','20001209','2000120912','200012091230','20001209123059'])
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
