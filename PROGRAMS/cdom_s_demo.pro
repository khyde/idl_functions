; $ID:	CDOM_S_DEMO.PRO,	2014-12-18	$

 PRO CDOM_S_DEMO
;+
; NAME:
; 	PNT_LINE_DEMO

;		This Program demonstrates IDL'S PNT_LINE PROGRAM

; MODIFICATION HISTORY:
;		Written jAN 31, 2005 by J.O'Reilly, 28 Tarzwell Drive, NMFS, NOAA 02882 (Jay.O'Reilly@NOAA.GOV)
;-

ROUTINE_NAME='CDOM_S_DEMO'
WL = FINDGEN(321) + 380
ACDOM_412 = 0.05
;	GOULD
	ACDOM = aCDOM_412 * 1.22189 * EXP(-0.0167*(wl-400.))

  s = [0.010, 0.014, 0.023]

  COLORS = [10,14,21]
  LABELS = 'S = '+ NUM2STR(S,FORMAT='(F10.3)')
  THICKS = [3,5,3]
  LSIZE  = 1.1
  PSYMS  = [1,1,1]
  LSTYLE = [0,1,2]
  !P.CHARTHICK=3

 	PSPRINT,/HALF,/COLOR,/TIMES
 	PAL_36
 	FONT_TIMES

;	*** LEGEND BOX ***
;  given no box is plotted.  May have up to 6 elements:
;  [BIC, BOC, BOT, BMX, BMY, BFLAG]
;  BIC: Box interior color.  Def=no box.
;  BOC: Box outline color.   Def=!p.color.
;  BOT: Outline thickness.   Def=1.
;  BMX: Box margin in x.     Def=1.
;  BMY: Box margin in y.     Def=1.
;  BFLAG: Margin units flag. Def unit (BFLAG=0) is 1 legend


PLOT, WL, [0.0,0.1], XTITLE= 'Wavelength '+UNITS('LAM'),/xstyle,YTITLE= 'CDOM '+UNITS('ABS',/UNIT,/NAME),/NODATA,$
  XCHARSIZE=1.25,YCHARSIZE=1.25,XTHICK=4, YTHICK=2,YMINOR=1
  BACKGROUND,/PLOT,COLOR=34
  GRIDS,color=35,THICK=4,FRAME=4

;	LLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLL
	FOR _S = 0,N_ELEMENTS(S)-1 DO BEGIN
		ACDOM = ACDOM_412*EXP(-S(_S)*(WL-412))
		OPLOT, WL, ACDOM,COLOR=COLORS(_S),THICK=THICKS(_S)
	ENDFOR

	BOX=[34, 0,  1, 0.5, 0.8]
	LEG,pos =[0.60 ,0.70,0.64,0.90], BOX=BOX,color=colors,label=labels,THICK=THICKS,LSIZE=LSIZE
	FRAME,/PLOT,COLOR=0,THICK=4
PSPRINT
STOP

;IMAGE_TRIM,'IDL.PS',DPI=600
END; #####################  End of Routine ################################



