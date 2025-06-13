 ; $Id:	LONGITUDE_2NORMAL.PRO,	2003 Dec 02 15:41	$

 FUNCTION LONGITUDE_2NORMAL, LONGITUDE
;+
; NAME:
; 	PNT_LINE_DEMO

;		This Function Converts Longitude Degrees  from the 0 - 360 convention into Normal Longitudes (-180 to 180)
;	Input		Output
;		0  	= 0
;		180 = -180
;	 -180 = -180
;   270 = -90
;		300 = -60
;		359 = -1

; MODIFICATION HISTORY:
;		Written jAN 31, 2005 by J.O'Reilly, 28 Tarzwell Drive, NMFS, NOAA 02882 (Jay.O'Reilly@NOAA.GOV)
;-

ROUTINE_NAME='LON360_180'
	RETURN, ((LONGITUDE + 360 + 180 ) MOD 360 ) - 180.

END; #####################  End of Routine ################################



