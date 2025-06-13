; $ID:	PARTITION.PRO,	2020-07-08-15,	USER-KJWH	$

	FUNCTION PARTITION, POSITION=position, COL=col, Row=Row, TOP=top, XMARGIN=xmargin, YMARGIN=ymargin, ERROR = error

;+
; NAME:
;		PARTITION
;
; PURPOSE:
;		This function Partitions normal space into a series of rectangle based on the provided col and row inputs.
;
; CATEGORY:
;		PLOT
;
; CALLING SEQUENCE:
;
;		Result = PARTITION(POSITION=position, COL=col, ROW=row)
;
; KEYWORD PARAMETERS:
;		POSITION ... The Position Coordinates for the initial space to partition into cols x rows
;									Defined same way as IDL: 'POSITION is a 4-element vector giving, in order,
;									the coordinates [(X0, Y0), (X1, Y1)], of the lower left and upper right corners of the window.'
;		COL......... The number of columns to use in partitioning the space
;		ROW......... The number of rows to use in partitioning the space
;		XMARGIN..... The margin (room) [left,right] in normal units
;		YMARGIN..... The margin (room) [bottom,top] in normal units
;		TOP......... Begin the first partition in the upper left
;
;
; OUTPUTS:
;		A structure with the normal coordinates for each of the rectangles within the input POSITION normal space
;		(The rectangle coordinates start in the Lower Left (Unless KEYWORD TOP is used).
;
; OPTIONAL OUTPUTS:
;		ERROR:     Any Error messages are placed in ERROR, if no errors then ERROR = ''
;
; EXAMPLE:
;
;	NOTES:
;		Useful for subdividing a portion of the graphics device page
;
; MODIFICATION HISTORY:
;			Written Feb 8, 2007 by J.O'Reilly, 28 Tarzwell Drive, NMFS, NOAA 02882 (Jay.O'Reilly@NOAA.GOV)
;-
;	****************************************************************************************************
	ROUTINE_NAME = 'PARTITION'
	ERROR = ''

	IF N_ELEMENTS(POSITION) NE 4 THEN _POSITION = [0,0,1.0,1.0] ELSE _POSITION = POSITION
	IF N_ELEMENTS(COL) NE 1 THEN _COL = 1 ELSE _COL = COL
	IF N_ELEMENTS(ROW) NE 1 THEN _ROW = 1 ELSE _ROW = ROW
	IF N_ELEMENTS(XMARGIN) NE 2 THEN _XMARGIN = [0.,0.] ELSE _XMARGIN = XMARGIN
	IF N_ELEMENTS(YMARGIN) NE 2 THEN _YMARGIN = [0.,0.] ELSE _YMARGIN = YMARGIN


	X = INTERPOL([_POSITION[0],_POSITION(2)],_COL+1)
	Y = INTERPOL([_POSITION[1],_POSITION(3)],_ROW+1)

	IF KEYWORD_SET(TOP) THEN BEGIN
 		Y = REVERSE(Y)
		RR = [_ROW-1,0,-1]
	ENDIF ELSE BEGIN
	  RR =[0,_ROW-1,1]
	ENDELSE


;	===> Create a structure to hold Column, Row and Position for each of the rectangles
	XY = REPLICATE(CREATE_STRUCT('COL',0,'ROW',0,'POSITION',[0.,0.,0.,0.]),_COL*_ROW)
	NTH = 0

	FOR R = 0, _ROW-1 DO BEGIN
		FOR C = 0,_COL-1 DO BEGIN
			XY[NTH].COL = C
			XY[NTH].ROW =   R ;
			IF NOT KEYWORD_SET(TOP) THEN BEGIN
				XY[NTH].POSITION = [X(C)+_Xmargin[0],	Y(R)+_Ymargin[0],	X(C+1)-_Xmargin[1],	Y(R+1)-_Ymargin[1]]
			ENDIF ELSE BEGIN
				XY[NTH].POSITION = [X(C)+_Xmargin[0],	Y(R+1)+_Ymargin[0],	X(C+1)-_Xmargin[1],	Y(R)-_Ymargin[1]]
			ENDELSE
			NTH=NTH+1
		ENDFOR
	ENDFOR


  RETURN,XY


	END; #####################  End of Routine ################################
