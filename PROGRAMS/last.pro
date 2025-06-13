; $ID:	LAST.PRO,	NOVEMBER 15 2004, 21:01	$

 FUNCTION LAST, ARR
;+
; NAME:
;       LAST
;
; PURPOSE:
;				Return the last element of an array
;
;
; MODIFICATION HISTORY:
;       Written by:  J.E.O'Reilly, MARCH 4,1999
;-

ROUTINE_NAME='LAST'
RETURN, ARR(N_ELEMENTS(ARR)-1)

END; #####################  End of Routine ################################



