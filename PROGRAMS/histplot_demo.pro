; $ID:	HISTPLOT_DEMO.PRO,	2014-12-18	$

 PRO HISTPLOT_DEMO, STRUCT
;+
; NAME:
; 	HISTPLOT_DEMO

;		This Program Demonstrates the use of HISTPLOT

; 	MODIFICATION HISTORY:
;			Written July 26, 2006 by J.O'Reilly, 28 Tarzwell Drive, NMFS, NOAA 02882 (Jay.O'Reilly@NOAA.GOV)
;-

	ROUTINE_NAME='HISTPLOT_DEMO'


	DATA = RANDOMN(SEED,100000)

!X.OMARGIN=[0,11]

  PSPRINT,/COLOR,/HALF
  PAL_36
  !P.MULTI = 0

	HISTPLOT,DATA,binsize=0.1,lab_bars=[7,1,7],xticks=10,xrange=[-5,5],bar_thick=2,bar_color=34,bar_outline=34,XHIST,YHIST,_EXTRA=_extra


	HISTPLOT,DATA,binsize=0.1,lab_bars=[7,1,7],xticks=10,xrange=[-5,5],bar_thick=2,bar_color=34,bar_outline=34,XHIST,YHIST,$
		GRIDS_LINESTYLE = 1,GRIDS_COLOR=34

	HISTPLOT,DATA,binsize=0.01,lab_bars=[7,1,7],xticks=10,xrange=[-5,5],bar_thick=2,bar_color=34,bar_outline=34,XHIST,YHIST,$
		GRIDS_LINESTYLE = 1,GRIDS_COLOR=34, YTICKS=10

	PSPRINT
 STOP

END; #####################  End of Routine ################################



