; $ID:	GONE_DEMO.PRO,	2020-06-30-17,	USER-KJWH	$

PRO GONE_DEMO

;+
; NAME:
; 	GONE_DEMO

;		This Program is a DEMO for GONE

; 	MODIFICATION HISTORY:
;
;			Written April 17, 2006 by J.O'Reilly, 28 Tarzwell Drive, NMFS, NOAA 02882 (Jay.O'Reilly@NOAA.GOV)
;-

	ROUTINE_NAME='GONE_DEMO'

	A=INTARR(100) & HELP, A & GONE,A & HELP,A




;	===> Can not yet delete associated variables
	PRINT,'Can not yet delete associated variables'
	I=INDGEN(100)
	FILE = ROUTINE_NAME+'INT'

	OPENW,LUN,FILE,/GET_LUN
	WRITEU,LUN,I
	CLOSE,LUN
	FREE_LUN,LUN



	OPENR,LUN,FILE,/GET_LUN
	A_FILE=ASSOC(LUN, I) ;Make an associated variable.
	IMAGE=A_FILE[0]

	GONE,A_FILE
	HELP, A_FILE


END; #####################  End of Routine ################################



