; $Id:	jd_2doy.pro,	June 27 2007	$

FUNCTION JD_2DOY ,JD, NOLEAP=noleap
;+
; NAME:
;       JD_2DOY
;
; PURPOSE:
;				Convert Julian Day into DAY OF YEAR (1-366)
;
; CATEGORY:
;		Date
;
; CALLING SEQUENCE:
;       Result = JD_2DOY(2451908.5)
;
; INPUTS:
; 	JD:  IDL Julian Day
;
; KEYWORD PARAMETERS:
;		NOLEAP:  If the year is a leap year and NOLEAP keyword is set then the maximum DOY will be 365.9999 (none for 366.0 to 366.999)
;
; OUTPUTS:
;		DOY  DAY OF YEAR 1-366 IN DECIMAL DAYS)
;
; MODIFICATION HISTORY:
;       Written by:  J.E.O'Reilly, Oct 23, 2000
;       JOR Feb 15, 2002 ; added year keyword
;-

;	****************************************************************************************************
	ROUTINE_NAME = 'JD_2DOY'

;	===> Make output Array missing
	DOY = JD
	DOY(*) = MISSINGS(DOY)

;	===> Find valid Input JD
	OK=WHERE(FINITE(JD) AND JD NE MISSINGS(JD),COUNT)

	IF COUNT EQ 0 THEN RETURN, DOY

;	===> Compute Year from JD
  YEAR  = DOUBLE(STRING(JD(OK),FORMAT='(C(CYi4.4))'))

;	===> Calculate First of Year
  FOY = JULDAY(             1.0D,               1.0D,     YEAR,          0.0D,            0.0D,      0.0D  )


;	===> Calculate Day Of Year (doy)
;	===> IF NOLEAP IS SET THEN CHANGE DOY 366 TO DOY 365 (but keep the decimal day precision in the doy)
	IF NOT KEYWORD_SET(NOLEAP) THEN BEGIN
		DOY(OK) = JD(OK) - FOY + 1.0D ;
 	ENDIF ELSE BEGIN
 		DOY(OK) = (JD(OK)-FOY) +   ((JD(OK) - FOY) LT 365) * 1.0D
 	ENDELSE

	IF N_ELEMENTS(DOY) EQ 1 THEN RETURN, DOY(0) ELSE RETURN, DOY

  END; #####################  End of Routine ################################
