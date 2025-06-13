; $ID:	JD_2DYEAR.PRO,	2004 02 03 17:23	$


FUNCTION JD_2DYEAR, JD
;+
; NAME:
;       JD_2DYEAR
;
; PURPOSE:
;       Compute the Decimal Year from a Julian Day
;
; CATEGORY:
;       Date Time
;
; CALLING SEQUENCE:
;       Result = JD_2DYEAR(JD)
;
; INPUTS:
;       JD

;	EXAMPLE:
;				PRINT, JD_2DYEAR(DATE_2JD('20010101000000'))
;				PRINT, JD_2DYEAR(DATE_2JD('20011231235959')) ; PRINTS AS 2002.000 ... SO SEE NEXT EXAMPLE
;				PRINT, JD_2DYEAR(DATE_2JD('20011231235959')) ,FORMAT='(F20.10)'
;
;
; KEYWORD PARAMETERS:
;       None
;
; OUTPUTS:
;       Decimal years
;
; MODIFICATION HISTORY:
;       Written by:  J.E.O'Reilly, Dec 29, 2003

;-

	ROUTINE_NAME='JD_2DYEAR'

	YEAR  = DOUBLE(STRING(JD,FORMAT='(C(CYi4))'))

  JD_FIRST = (JULDAY( 1.0D, 1.0D,  YEAR,  0.0D,  0.0D,  0D))
	JD_LAST  = (JULDAY(12.0D,31.0D,  YEAR, 23.0D, 59.0D, 60D))

	RETURN,YEAR + ((JD - JD_FIRST)/(JD_LAST - JD_FIRST)) ;


  END; #####################  End of Routine ################################
