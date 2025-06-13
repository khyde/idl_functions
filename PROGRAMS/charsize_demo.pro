; $ID:	CHARSIZE_DEMO.PRO,	2020-07-08-15,	USER-KJWH	$

	PRO CHARSIZE_DEMO

;+
; NAME:
;		CHARSIZE_DEMO
;
; PURPOSE:;
;
;		This procedure empirically estimates IDL's formula for varying the character size as a function of !position and !p.multi settings
;
; CATEGORY:
;		PLOT
;
; CALLING SEQUENCE:
;
;		CHARSIZE_DEMO
;
;
; INPUTS:
;		NONE:
;
; OUTPUTS:
;
; EXAMPLE:
;
;	NOTES:
;
;
; MODIFICATION HISTORY:
;			Written Nov 21, 2006 by J.O'Reilly, 28 Tarzwell Drive, NMFS, NOAA 02882 (Jay.O'Reilly@NOAA.GOV)
;-
;	****************************************************************************************************
	ROUTINE_NAME = 'CHARSIZE_DEMO'

;	 ZWIN,[800,800]
  	PSPRINT,/FULL
	CHAR_IN = INTERVAL([-1,1],BASE=10,0.1)
	CHAR_OUT   = FLTARR(N_ELEMENTS(CHAR_IN))

	PLOT,[0,0],[1,1],XMARGIN=[0,0],YMARGIN=[0,0] ,POS=[0,0,.5,.5]

	FOR NTH = 0,N_ELEMENTS(CHAR_IN)-1 DO BEGIN
		_CHARSIZE = CHAR_IN[NTH]
		XYOUTS,0.5,0.5,'W',CHARSIZE= _CHARSIZE,WIDTH=WIDTH

		CHAR_OUT[NTH] = WIDTH
	ENDFOR
	 ST,!D
	 PRINT, (STATS2(CHAR_IN,CHAR_OUT,TYPE='4',/QUIET)).SLOPE
	 PRINT, (FLOAT(!D.X_CH_SIZE)/!D.X_VSIZE)

  PRINT, (!D.X_CH_SIZE*!X.S[1] + !X.S[0]) / ((!X.WINDOW[1]-!X.WINDOW[0])*!D.X_SIZE)

  ZWIN

 	PSPRINT

	WIN,[500,500]
	PLOTXY, CHAR_IN,CHAR_OUT,PSYM=1,THICK=3,DECIMALS=4,PARAMS=[0,2,3,4 ],/QUIET
	ONE2ONE

	STOP




	END; #####################  End of Routine ################################
