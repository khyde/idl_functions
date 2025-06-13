; $ID:	NUMERIC.PRO,	NOVEMBER 05 2004, 08:17	$
;+
;	This Function returns 1 if input data type is numeric and 0 if not

;	Result = NUMERIC(Data)

; HISTORY:
;		June 9, 2003	Written by:	J.E. O'Reilly, NOAA, 28 Tarzwell Drive, Narragansett, RI 02882
;-
; *************************************************************************

FUNCTION NUMERIC, Data
  ROUTINE_NAME='NUMERIC'
  sz=SIZE(Data,/STRUCT)
  TYPE_NUMERIC = [1,2,3,4,5,6,9, 12,13,14,15,16]
  OK = WHERE(TYPE_NUMERIC EQ sz.type,Count)
  RETURN,Count

END; #####################  End of Routine ################################
