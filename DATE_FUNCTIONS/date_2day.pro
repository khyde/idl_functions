; $ID:	DATE_2DAY.PRO,	2004 JAN 31 14:39	$
;
  FUNCTION DATE_2DAY, DATE
;+
; NAME:
;       DATE_2DAY
;
; PURPOSE:
;       Convert date_time into an IDL Julian Day
;
; CATEGORY:
;       DATE_TIME
;
;
; INPUTS:
;       a STRING formatted as: YYYY,YYYYMM,YYYYMMDD,YYYYMMDDHH,YYYYMMDDHHMM,YYYYMMDDHHMMSS
;
; KEYWORD PARAMETERS:
;
; OUTPUTS:
;       An IDL JD Date
; SIDE EFFECTS:
;       None.
;
; RESTRICTIONS:
;
;      Input Date is string type then format of date time string must be ordered
;       as in the following examples:
;       yyyy,
;       yyyymm, yyyymmdd, yyyymmddhh, yyyymmddhhmm,yyyymmddhhmmss
;
; MODIFICATION HISTORY:
;       Written by:  J.E.O'Reilly, Oct 7,2000
;-

; *******************************************************************************
;	===> STRTRIM and extract month
	RETURN,STRMID(STRTRIM(DATE,2),6,2)
END
