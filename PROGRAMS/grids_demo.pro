; $ID:	GRIDS_DEMO.PRO,	2014-12-18	$

	PRO GRIDS_DEMO

;+
; NAME:
;		GRIDS_DEMO
;
; PURPOSE:;
;
;		This procedure is  DEMO for GRIDS.PRO
;
; CATEGORY:
;		GRAPHICS
;
; CALLING SEQUENCE:
;		GRIDS_DEMO
;
; INPUTS:
;		NONE
;
; OUTPUTS:
;		Graphs are drawn with grids
;

; MODIFICATION HISTORY:
;			Written Jan 4, 2006 by J.O'Reilly, 28 Tarzwell Drive, NMFS, NOAA 02882 (Jay.O'Reilly@NOAA.GOV)
;-
;	****************************************************************************************************
	ROUTINE_NAME = 'GRIDS_DEMO'

	PSPRINT,/COLOR
	PAL_36

	D=DECADES([-2,2])





	PLOT, [1,2,3],[2,5,10]
	GRIDS,COLOR=21,THICK=5,LINESTYLE=2

	PLOT, [.93,2,3.1],[1.93,5,10.1],/XSTYLE ,/YSTYLE
	GRIDS,COLOR=21,THICK=5,LINESTYLE=2


	PLOT, D,D,/XLOG
	GRIDS,COLOR=21

	PLOT, D,D,/XLOG,/YLOG
	GRIDS,COLOR=34


	PLOT, D,D,/XLOG,/YLOG
	GRIDS,COLOR=34,LINESTYLE=1,/NO_X


	PLOT, D,D,/XLOG,/YLOG
	GRIDS,COLOR=30,LINESTYLE=1,/NO_Y,THICK=4


	PLOT, D,D,/XLOG,/YLOG
	GRIDS,COLOR=0,LINESTYLE=1, THICK=4,X=[0.1,1] ,Y=[0.1,1]

	PLOT, D,D,/XLOG,/YLOG
	GRIDS,COLOR=0,LINESTYLE=1, THICK=4,X=[0.1,1] ,Y=[0.1,1],/NO_X

	PLOT, D,D,/XLOG,/YLOG
	GRIDS,COLOR=0,LINESTYLE=1, THICK=4,X=[0.1,1] ,Y=[0.1,1],/NO_Y

	PLOT, D,D,/XLOG,/YLOG,TITLE='ALL'
	GRIDS,COLOR=21,LINESTYLE=1, THICK=4,X=[0.001,0.01,0.1,1,10,100] ,Y=[0.1,1],/NO_Y,/ALL

	PSPRINT





	END; #####################  End of Routine ################################
