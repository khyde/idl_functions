; $Id:	INTERPX_DEMO.PRO,	2003 Dec 02 15:41	$

 PRO INTERPX_DEMO
;+
; NAME:
; 	INTERPX_DEMO

;		This Program demonstrates JHUAPL INTERPX_DEMO  PROGRAM

; MODIFICATION HISTORY:
;		Written March 19, 2005 by J.O'Reilly, 28 Tarzwell Drive, NMFS, NOAA 02882 (Jay.O'Reilly@NOAA.GOV)
;-

ROUTINE_NAME='INTERPX_DEMO'


depths = [2.,   3,  4,   7,  11,  15,  25,  34,  49,  70,  88]
data   = [0.3, 0.6, 1.0, 1.4,2.0, 3.1, 1.6, 1.1, 0.4, 0.2, 0.11]
STANDARD = FINDGEN(100)
INT = INTERPX(DEPTHS,DATA,STANDARD)

STOP



END; #####################  End of Routine ################################



