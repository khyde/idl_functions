; $ID:	DATE_2IDOY.PRO,	2017-02-24,	USER-KJWH	$

function DATE_2IDOY ,Date, NOLEAP=noleap, IDOY=IDOY
;+
; NAME:
;       DATE_2IDOY
;
; PURPOSE:
;		This function generates an integer Day of Year from the input Date
;
; CATEGORY:
;		DATE_TIME
;
; CALLING SEQUENCE:
;		Result = DATE_2DOY('19770319')
;
; INPUTS:
;   	A Date string formatted as any of the following:
;				YYYY, YYYYMM, YYYYMMDD, YYYYMMDDHH,YYYYMMDDHHMM,YYYYMMDDHHMMSS
;
;	KEYWORD PARAMETERS:
;			NOLEAP ... Constrains maximum DOY to 365 instead of 366 when
;								 the input date is the last day of a leap year
;
; OUTPUTS:
;		A Decimal Day of Year
;	PROCEDURE:
;		This routine converts Date to Julian Day and calls JD_2DOY
;
; EXAMPLE:
;		PRINT, DATE_2DOY(['2000','200001','20000101','2000010112','200001011230'])
;

; MODIFICATION HISTORY:
;       Written by:  J.E.O'Reilly, Dec 17,1997, 1997
;       Modified: FEB 15, 2107 - KJWH: Changed NOLEAP to NO_LEAP to be compatible with JD_2DOY
;-
;	****************************************************************************************************
	ROUTINE_NAME = 'DATE_2IDOY'

; ===> Trim Input Date string and convert to Julian Day
  JULIAN = DATE_2JD(STRTRIM(DATE,2))

;	===> Convert Julian Day to Day of Year
	DOY= JD_2DOY(JULIAN, NO_LEAP=NOLEAP)
	IDOY = STR_PAD(STRTRIM(FIX(JD_2DOY(JULIAN)),2),3)

  RETURN, IDOY

	END; #####################  End of Routine ################################

