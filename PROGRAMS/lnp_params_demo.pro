; $Id:	LNP_PARAMS_DEMO.pro,	March 18 2006, 06:33	$

 PRO LNP_PARAMS_DEMO,DYEAR, MIN_CPY,MAX_CPY
;+
; NAME:
; 	LNP_PARAMS_DEMO

;	This Program Makes Tests the LNP_PARAMS program, ensuring that NOUT is consistent with varying DYEAR and N samples


; MODIFICATION HISTORY:
;		Written March 13, 2005 by J.O'Reilly, 28 Tarzwell Drive, NMFS, NOAA 02882 (Jay.O'Reilly@NOAA.GOV)
;-

	ROUTINE_NAME='LNP_PARAMS_DEMO'


  DYEAR = FINDGEN(1000)+ 1997
  MIN_CPY = 0.02
  MAX_CPY = 100.0


;	LLLLLLLLLLLLLLLLLLLLLL
	FOR N = 1,100 DO BEGIN
    _DYEAR = SUBSAMPLE(DYEAR,N)
		LNP=LNP_PARAMS(_DYEAR, MIN_CPY,MAX_CPY)
		IF LNP.NOUT LT 5000 OR LNP.NOUT GE  5001 THEN STOP
		PRINT,N_ELEMENTS(_DYEAR),LNP.NOUT
	ENDFOR



END; #####################  End of Routine ################################



