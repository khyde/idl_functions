; $Id:	LNP_2VARIANCE.PRO.PRO,	2003 Dec 02 15:41	$

 FUNCTION LNP_2VARIANCE, DATA=DATA, FREQUENCY=FREQUENCY, SPECTRUM=spectrum
;+
; NAME:
; 	LNP_2VARIANCE

;		This Program Computes the VARIANCE from the results of LNP_TEST (or FASPER)

; 	MODIFICATION HISTORY:
;			Written Nov 3, 2005 by J.O'Reilly, 28 Tarzwell Drive, NMFS, NOAA 02882 (Jay.O'Reilly@NOAA.GOV)
;-

	ROUTINE_NAME='LNP_2VARIANCE'

	POWER= LNP_2POWER(DATA=DATA, FREQUENCY=FREQUENCY, SPECTRUM=SPECTRUM)
	VARIANCE = INT_TABULATED(FREQUENCY,POWER)
  RETURN, VARIANCE

END; #####################  End of Routine ################################



