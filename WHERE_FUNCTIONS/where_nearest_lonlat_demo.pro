; $ID:	WHERE_NEAREST_LOnLAT.PRO,	SEPTEMBER 20 2004, 21:09	$
;+
;	This Function finds the indices in Array which are nearest to Values array AND within a tolerance (NEAR).
; Array and Values must be numeric types
;
;	Result = WHERE_NEAREST_LOnLAT(Array, Values, NEAR=near)
;
; NOTES:
;  Routie uses

; HISTORY:
;	 May 5, 2003	Written by:	J.E. O'Reilly, NOAA, 28 Tarzwell Drive, Narragansett, RI 02882
;-
; *************************************************************************

PRO  WHERE_NEAREST_LOnLAT_DEMO

  ROUTINE_NAME='WHERE_NEAREST_LOnLAT_DEMO'

 LON0 = -70.0
 LAT0 = 40.0

 LON1 = -71
 LAT1 = 41.0
 OK=WHERE_NEAREST_LOnLAT( LON0,LAT0, LON1,LAT1,Count, NEAR=NEAR, VALID=valid,$
												 NCOMPLEMENT=ncomplement,COMPLEMENT=complement,NINVALID=ninvalid,INVALID=invalid)




END; #####################  End of Routine ################################
