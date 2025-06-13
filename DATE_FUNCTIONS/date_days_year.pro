; $ID:	DATE_DAYS_YEAR.PRO,	2020-06-30-17,	USER-KJWH	$

FUNCTION DATE_DAYS_YEAR,Date
;+
; NAME:
;       DATE_DAYS_YEAR
;
; PURPOSE:
;       Compute the number of days in any year
;
; CATEGORY:
;       Date Time
;
; CALLING SEQUENCE:
;       Result = DATE_DAYS_YEAR(year)
;
; INPUTS:
;       year (must have century, e.g. 1978)
;
; KEYWORD PARAMETERS:
;       None
;
; OUTPUTS:
;       The number of days in the supplied year
; SIDE EFFECTS:
;       None.
;
; RESTRICTIONS:
;       None.
;
; PROCEDURE:
;       If year not provided then the number of days in the current year are returned.
;
; MODIFICATION HISTORY:
;       Written by:  J.E.O'Reilly, July 1,1999

;-

	ROUTINE_NAME= 'DATE_DAYS_YEAR'
	DPY=JD_DAYS_YEAR(DATE_2JD(DATE))

  IF N_ELEMENTS(DPY) EQ 1 THEN DPY = DPY[0]
  RETURN,DPY

  END; #####################  End of Routine ################################
