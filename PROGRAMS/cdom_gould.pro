; $Id:	CDOM_GOULD.PRO,	2003 Dec 02 15:41	$

 FUNCTION CDOM_GOULD
;+
; NAME:
; 	PNT_LINE_DEMO

;		This Program demonstrates IDL'S PNT_LINE PROGRAM

; MODIFICATION HISTORY:
;		Written jAN 31, 2005 by J.O'Reilly, 28 Tarzwell Drive, NMFS, NOAA 02882 (Jay.O'Reilly@NOAA.GOV)
;-

ROUTINE_NAME='CDOM_GOULD'
WL = [443]

	ACDOM = aCDOM_412 * 1.22189 * EXP(-0.0167*(wl-400))

END; #####################  End of Routine ################################



