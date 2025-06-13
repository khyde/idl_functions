; $ID:	I_LIGHT_MEAN.PRO,	2020-06-26-15,	USER-KJWH	$

 FUNCTION I_LIGHT_MEAN, K=k, Z=Z
;+
; NAME:
;       I_LIGHT_MEAN
;
; PURPOSE:
;				Compute the mean light intensity (Fraction of 1.0) based on light extinction coefficient (k m-1) and Depth (Z meters)
;
; MODIFICATION HISTORY:
;       Written by:  J.E.O'Reilly, MARCH 23,2004
;-

ROUTINE_NAME='I_LIGHT_MEAN'

_K = DOUBLE(K)
_Z = DOUBLE(Z)
IF N_ELEMENTS(K) EQ 1 AND N_ELEMENTS(Z) GT 1 THEN _K=REPLICATE(K,N_ELEMENTS(Z)) ELSE _K = K
IF N_ELEMENTS(Z) EQ 1 AND N_ELEMENTS(K) GT 1 THEN _Z=REPLICATE(Z,N_ELEMENTS(K)) ELSE _Z = Z

_K = DOUBLE(_K)
_Z = DOUBLE(_Z)
OK=WHERE(_K GT 0,COUNT)
IF COUNT GE 1 THEN _K[OK] = -1*_K[OK]

a = _K*_Z
fraction= -1*((1.0D - EXP(a))/a) ;
RETURN, Fraction


END; #####################  End of Routine ################################



