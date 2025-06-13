; $Id:	CONTOUR_TIME_DEPTH_DEMO.PRO,	2003 Dec 02 15:41	$

 	PRO CONTOUR_TIME_DEPTH_DEMO
;+
; NAME:
; 	CONTOUR_TIME_DEPTH_DEMO

;		This Program demonstrates Gridding and Contouring of Time vers Depth data using as input a series of profiles from
;		Mass Bay Station N04

; MODIFICATION HISTORY:
;		Written June 15,2005 Kim Whitman-Hyde & J.O'Reilly, 28 Tarzwell Drive, NMFS, NOAA 02882 (Jay.O'Reilly@NOAA.GOV)
;-

	ROUTINE_NAME='CONTOUR_TIME_DEPTH_DEMO'

	PSFILE = ROUTINE_NAME+'.PS'
	;PSPRINT,FILENAME=PSFILE,/COLOR,/FULL,/TIMES,/LANDSCAPE
	!P.MULTI = [0,1,4]
 	PAL_SW3,R,G,B

	D = IDL_RESTORE('D:/IDL/DATA/MASS_BAY-TEMP-N04.SAVE')

	DATE_RANGE = ['19980101','20040101']
	DEPTH_RANGE = [0,50]
	DATE = D.GMT_DATE
	DEPTH = D.DEPTH
	DATA  = D.TEMP
	DELTA= [0.25,0.25]
	GRID = CONTOUR_TIME_DEPTH(DATE, DEPTH, DATA, DELTA=delta, DATE_RANGE=DATE_RANGE,DEPTH_RANGE = depth_range, ERROR=error)


STOP

STOP



END; #####################  End of Routine ################################
