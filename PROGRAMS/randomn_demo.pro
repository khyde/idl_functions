; $ID:	RANDOMN_DEMO.PRO,	2020-07-01-12,	USER-KJWH	$
;##########################################################################################################
 PRO RANDOMN_DEMO
;+
; NAME:
; 	RANDOMN_DEMO

;		THIS PROGRAM DEMONSTRATES THE USE OF RANDOMN

; 	MODIFICATION HISTORY:
;			WRITTEN JULY 26, 2006 BY J.O'REILLY, 28 TARZWELL DRIVE, NMFS, NOAA 02882 (JAY.O'REILLY@NOAA.GOV)
;			DEC 2,2012,JOR, UPDATED:PFILE,,FORMATTING, ETC.
;##########################################################################################################
;-
;*************************************
	ROUTINE_NAME='RANDOMN_DEMO'
;************************************	
;CUM

	
 NUMS = INTERVAL([1,6],BASE = 10)
!X.OMARGIN=[2,2]
CD,CURRENT = DIR
DIR=DIR+ PATH_SEP()
PSFILE = DIR +ROUTINE_NAME + '.PS'
FONT_CALIBRI
SET_PMULTI,N_ELEMENTS(NUMS)
  PSPRINT,FILENAME = PSFILE,/COLOR,/FULL
  PAL_36
;FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
FOR NTH = 0,N_ELEMENTS(NUMS)-1 DO BEGIN
NUM = NUMS[NTH]
DATA = HISTOGRAM(RANDOMN(SEED, NUM), BINSIZE=0.1)
TITLE ='NUM:   ' +STR_COMMA(ROUNDS(NUM))
PLOT,DATA,TITLE=TITLE,CHARSIZE = 1.7
ENDFOR;FOR NTH = 0,N_ELEMENTS(NUMS)-1 DO BEGIN
;FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
	PSPRINT
	PFILE,PSFILE
	DONE:
	
 

END; #####################  END OF ROUTINE ################################



