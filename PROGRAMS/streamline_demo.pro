; $Id:	STREAMLINE_DEMO.PRO,	2003 Dec 02 15:41	$

 FUNCTION STREAMLINE_DEMO, COLORS
;+
; NAME:
; 	PNT_LINE_DEMO

;		This Program demonstrates IDL'S PNT_LINE PROGRAM

; MODIFICATION HISTORY:
;		Written jAN 31, 2005 by J.O'Reilly, 28 Tarzwell Drive, NMFS, NOAA 02882 (Jay.O'Reilly@NOAA.GOV)
;-

ROUTINE_NAME='STREAMLINE_DEMO'

	POINT = [2,3]
	X = [-3,3]
	Y = [5,12]
	WIN
	PLOT, X,Y
	STOP
 ;PNT_LINE([2,3], [-3,3], [5,12], Pl), Pl
STREAMLINE, Verts, Conn, Normals, Outverts, Outconn [, ANISOTROPY=array] [, SIZE=vector] [, PROFILE=array]



END; #####################  End of Routine ################################



