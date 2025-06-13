; $ID:	BLEND_DEMO.PRO,	2020-06-26-15,	USER-KJWH	$

	PRO BLEND_DEMO

;+
; NAME:
;		BLEND_DEMO
;
; PURPOSE:
;		This Program is a DEMO for BLEND
;
; CATEGORY:
;		FUNCTIONS
;
; CALLING SEQUENCE:
;
;		BLEND_DEMO

;
; INPUTS:
;		NONE
;
; KEYWORD PARAMETERS:
;		NONE
;
; OUTPUTS:
;		Plot

;	NOTES:
;		This routine will display better if you set your tab to 2 spaces:
;	  (Preferences, Editor, The TAB Number of spaces to indent for each Tab: 2)
;

; MODIFICATION HISTORY:
;			Written May 12, 2007 by J.O'Reilly, 28 Tarzwell Drive, NMFS, NOAA 02882 (Jay.O'Reilly@NOAA.GOV)
;-
;	****************************************************************************************************
	ROUTINE_NAME = 'BLEND_DEMO'

;	===> EXAMPLE OF BLENDING BETWEEN 0.75 AND 2.0 E.G. CHL KIM
	X=FINDGEN(126)/100+0.75
;	WIN
	W1=BLEND(X)
	W2=1.0-W1
	PLOT, X,W1
	OPLOT, X,W2


	RANGE = [0.01,60.0]
	INCREMENT = 0.001
	LOWER = 0.75
	UPPER = 2.00
  MID_CHL = (LOWER+UPPER)/2.0
	CHLOR_A = [0.1, 0.7, 0.75, 1.0,MID_CHL,1.75, 2.0, 3.0,10]
	CHL=INTERVAL(RANGE,INCREMENT)

	W1 = REPLICATE(1.0,N_ELEMENTS(CHL))
	W2 = REPLICATE(1.0,N_ELEMENTS(CHL))
	OK=WHERE(CHL GE LOWER AND CHL LE UPPER,COUNT)
	SUB_FIRST=FIRST[OK]
  SUB_LAST=LAST[OK]
  W1(0:SUB_FIRST-1) = 1.0
  W1(SUB_LAST+1:*) 	= 0.0
  W2(0:SUB_FIRST-1) = 0.0
  W2(SUB_LAST+1:*) 	= 1.0
	W2[OK]=BLEND(CHL[OK])
	W1[OK]=1.0-W2[OK]

 	PLOT, CHL,W1,/XLOG, /NODATA,YTITLE='Relative Weights',XTITLE='Chlorophyll'
 	OPLOT,CHL,W1,COLOR=TC(11)
 	OPLOT,CHL,W2,COLOR=TC(22)

	ok=WHERE_NEAREST(CHL,CHLOR_A,NEAR=1.0)
	PRINT, CHL[OK]
	PRINT, W1[OK]
	PRINT, W2[OK]
	STOP


	END; #####################  End of Routine ################################
