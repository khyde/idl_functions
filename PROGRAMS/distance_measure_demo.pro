; $Id:	DISTANCE_MEASURE_DEMO,	2003 Dec 02 15:41	$

 PRO DISTANCE_MEASURE_DEMO, STRUCT
;+
; NAME:
; 	DISTANCE_MEASURE_DEMO

;		This Program is a DEMO for IDl'S DISTANCE_MEASURE_DEMO function

; 	MODIFICATION HISTORY:
;			Written Aug 3, 2006 by J.O'Reilly, 28 Tarzwell Drive, NMFS, NOAA 02882 (Jay.O'Reilly@NOAA.GOV)
;-

	ROUTINE_NAME='DISTANCE_MEASURE_DEMO'

  ARR = DIST(10)
  ARR = [[0,0],[1,1],[2,2],[3,3],[4,4]]
  PRINT, ARR
  ARR=DIST(255)
;  D = DISTANCE_MEASURE(ARR,/MATRIX)
  D = DISTANCE_MEASURE(ARR)
  HELP,D
 ; PRINT,D
  WIN
  PLOT,D
STOP


END; #####################  End of Routine ################################



