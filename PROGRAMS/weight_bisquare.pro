; $ID:	WEIGHT_BISQUARE.PRO,	2020-06-26-15,	USER-KJWH	$
;+
;	This Function returns weights using the WEIGHT_BISQUARE function
; SYNTAX:
;
;	Result  = WEIGHT_BISQUARE(Arr)
; OUTPUT:	Weights assigned to each y-residual based on WEIGHT_BISQUARE function
; ARGUMENTS:
;		Arr: 	An array of usually Y-axis RESIDUALS from a model prediction
;
; NOTES:

; HISTORY:
;		March 26,2002	Written by:	J.E. O'Reilly, NOAA, 28 Tarzwell Drive, Narragansett, RI 02882
;-
; *************************************************************************

FUNCTION WEIGHT_BISQUARE,arr
  ROUTINE_NAME='WEIGHT_BISQUARE'

  IF N_ELEMENTS(arr) LT 2 THEN RETURN, -1

  ABS_ARR = ABS(ARR)
  MAD = MEDIAN(ABS_ARR,/EVEN)

  w = DBLARR(N_ELEMENTS(arr))

  ok = WHERE(ABS_ARR LT 6*MAD,count)
  IF COUNT GE 1 THEN W[OK] = (1 - (Arr(ok)/(6*MAD))^2)^2

 	ok = WHERE(ABS_ARR GE 6*MAD,count)
 	IF COUNT GE 1 THEN W[OK] = 0

; ==================> Return the weights to be assigned to each residual
  RETURN, w

END; #####################  End of Routine ################################
