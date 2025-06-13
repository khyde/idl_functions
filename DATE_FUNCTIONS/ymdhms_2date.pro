; $ID:	YMDHMS_2DATE.PRO.PRO,	2004 JAN 31 14:39	$
;
  FUNCTION YMDHMS_2DATE, YEAR,MONTH,DAY,HOUR, MINUTE, SECOND
;+
; NAME:
;       YMDHMS_2DATE.PRO
;
; PURPOSE:
;       Formats YEAR,MONTH,DAY,HOUR,MINUTE,SECOND INTO A DATE (YYYYMMDDHHMMSS), Padding with zeros (if needed)
;				to the left of each date component.
;
; CATEGORY:
;       DATE_TIME
;
;
; OUTPUTS:
;       DATE
;	RESTRICTIONS:
;		YEAR,MONTH,DAY are required, HOUR,MINUTE,SECOND are optional

;
; MODIFICATION HISTORY:
;       Written by:  J.E.O'Reilly, Dec 22, 2005
;-

; *******************************************************************************
;	===> Convert to String HHMM

	IF N_ELEMENTS(SECOND) EQ 0 THEN _SECOND = 0 ELSE _SECOND 	= SECOND
	IF N_ELEMENTS(MINUTE) EQ 0 THEN _MINUTE = 0 ELSE _MINUTE 	= MINUTE
	IF N_ELEMENTS(HOUR) 	EQ 0 THEN _HOUR 	= 0 ELSE _HOUR 		= HOUR

	RETURN,	STRING(YEAR,		FORMAT='(I04)')	+ $
					STRING(MONTH,		FORMAT='(I02)')	+ $
					STRING(DAY,			FORMAT='(I02)')	+ $
					STRING(_HOUR,		FORMAT='(I02)')	+ $
					STRING(_MINUTE,	FORMAT='(I02)')	+ $
					STRING(_SECOND,	FORMAT='(I02)')

END
