; $Id:	pmulti_demo.pro,	February 13 2007	$

 PRO PMULTI_DEMO, STRUCT
;+
; NAME:
; 	PMULTI_DEMO

;		This Program Demonstrates using pmulti

; 	MODIFICATION HISTORY:
;			Written Nov 3, 2005 by J.O'Reilly, 28 Tarzwell Drive, NMFS, NOAA 02882 (Jay.O'Reilly@NOAA.GOV)
;-

	ROUTINE_NAME='PMULTI_DEMO'

	x = FINDGEN(100)
  	Y = RANDOMU(SEED,100)

	!P.MULTI = [0,2,4]

	PLOT,X,Y,TITLE='PLOT1'
	PRINT,!P.MULTI
	Y = RANDOMU(SEED,100)
	PLOT,X,Y,TITLE='PLOT2'
	PRINT,!P.MULTI
	Y = RANDOMU(SEED,100)
	STOP
	PLOT,X,Y,TITLE='PLOT3'
	PRINT,!P.MULTI
	Y = RANDOMU(SEED,100)
	PLOT,X,Y,TITLE='PLOT4'
	PRINT,!P.MULTI

	!P.MULTI = [0,1,16]
 	SKIPPLOT,8
	Y = RANDOMU(SEED,100)
	PLOT,X,Y,TITLE='PLOT5',/NOERASE
	PRINT,!P.MULTI
	STOP

	Y = RANDOMU(SEED,100)
	PLOT,X,Y,TITLE='PLOT6';,/NOERASE
	PRINT,!P.MULTI


END; #####################  End of Routine ################################




