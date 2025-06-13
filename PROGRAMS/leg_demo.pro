; $ID:	LEG_DEMO.PRO,	2014-12-18	$
;+
;	This Program Demonstrates the use of JHUAPL LEG Program for Drawing Legends
;		March 26,2002	Written by:	J.E. O'Reilly, NOAA, 28 Tarzwell Drive, Narragansett, RI 02882
;-
; *************************************************************************

PRO LEG_DEMO
  ROUTINE_NAME='LEG_DEMO'

  x   = [1,2,3,4]
  y   = [1,2,4,6]

  COLORS = [0,21,14,10,6]
  LABELS = ['All','Series 1','Series 2','Series 3','Series 4']
  THICKS = [3,3,3,3,3]
  LSIZE  = 1.1
  PSYMS  = [1,1,1,1,1]
  LSTYLE = [0,1,2,3,4]
  !P.CHARTHICK=3


 	PSPRINT,/FULL,/COLOR,/TIMES
 	PAL_36
 	!P.MULTI=[0,1,2]
 	FONT_TIMES
	PLOT, X,Y,/nodata,XRANGE=[0,5],/XSTYLE,YRANGE=[0,6], $
  XTITLE='xtitle', YTITLE='ytitle',$
  XCHARSIZE=1.25,YCHARSIZE=1.25,XTHICK=4,YTHICK=2,YMINOR=1
	GRIDS,color=35,THICK=4,FRAME=4
	OPLOT, X,Y,THICK=3
	LEG,pos =[0.10 ,0.70,0.14,0.90], color=colors ,label=labels ,THICK=THICKS ,LSIZE=LSIZE

;	*** LEGEND BOX ***
;  given no box is plotted.  May have up to 6 elements:
;  [BIC, BOC, BOT, BMX, BMY, BFLAG]
;  BIC: Box interior color.  Def=no box.
;  BOC: Box outline color.   Def=!p.color.
;  BOT: Outline thickness.   Def=1.
;  BMX: Box margin in x.     Def=1.
;  BMY: Box margin in y.     Def=1.
;  BFLAG: Margin units flag. Def unit (BFLAG=0) is 1 legend


	PLOT, X,Y,/nodata,XRANGE=[0,5],/XSTYLE,YRANGE=[0,6], $
  XTITLE='xtitle', YTITLE='ytitle',$
  XCHARSIZE=1.25,YCHARSIZE=1.25,XTHICK=4,YTHICK=2,YMINOR=1
  BACKGROUND,/PLOT,COLOR=34
	GRIDS,color=35,THICK=4,FRAME=4
	OPLOT, X,Y,THICK=3
	BOX=[34, 0,  1, 0.75, 0.8]
	LEG,pos =[0.10 ,0.70,0.14,0.90], BOX=BOX,color=colors ,label=labels ,THICK=THICKS ,LSIZE=LSIZE
	FRAME,/PLOT,COLOR=0,THICK=4

	PSPRINT

END; #####################  End of Routine ################################
