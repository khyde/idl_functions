; $ID:	LATLON_MAPGEN.PRO,	2014-12-11	$

 FUNCTION LATLON_MAPGEN,  MAP=MAP, PX=PX,PY=PY,NOROUND=NOROUND, ERROR=error
;+
; NAME:
;		LATLON_MAPGEN
;
; PURPOSE:
; 	This function generates a Structure containing 2-d arrays of longitude and latitudes at the CENTER of each pixel within a MAP domain
;
; CATEGORY:
;		MAP
;
; KEYWORD PARAMETERS:
;      MAP:   The name of the NARR Standard MAP projection (e.g. 'NEC', 'EC', 'GEQ')
;      PX:   	The Map Pixel Dimensions in the horizontal direction
;      PY:   	The Map Pixel Dimensions in the vertical direction
;	 NOROUND:	  Prevents rounding to 6 decimal places (rounding is usually desired so that returned lat,lon are in uniform intervals
;
; OUTPUTS:
;		A Structure with a 2-d array of latitudes and a 2-d array of longitudes
;
; OPTIONAL OUTPUTS:
;		ERROR:     Any Error messages are placed in ERROR, if no errors then ERROR = ''

; MODIFICATION HISTORY:
;       Written by:  J.E.O'Reilly, July 24, 2005
;-
; ********************

;	===> Get  dimensions for standard map projections
	M=MAPS_SIZE(MAP)

	IF N_ELEMENTS(PX) NE 1 THEN _PX=M.PX ELSE _PX = PX
	IF N_ELEMENTS(PY) NE 1 THEN _PY=M.PY ELSE _PY = PY

;	===> Get the device coordinates for the center of every pixel in the rectangular map domain
	XY=IMAGE_PXPY(BYTARR(_PX, _PY),/CENTER)


;	===> Open a Zbuffer and dimension to _px,_py
	ZWIN,[_px,_py]

;	===> Initialize Map
	CALL_PROCEDURE,'MAP_'+MAP

;	===> Convert the pixel coordinates to lon,lat coordinates
	XYZ=CONVERT_COORD(XY.X, XY.Y,/DEVICE,/TO_DATA)
	ZWIN


; ===> Make structure to hold lon (2d array) and lat (2d array)
	STRUCT = CREATE_STRUCT('LON', REFORM((XYZ(0,*)),_PX,_PY), 'LAT', REFORM((XYZ(1,*)),_PX,_PY))


	IF NOT KEYWORD_SET(NOROUND) THEN BEGIN
		STRUCT.LON = (ROUND(1E6*STRUCT.LON))*1E-6 ;
		STRUCT.LAT = (ROUND(1E6*STRUCT.LAT))*1E-6 ;
	ENDIF


  RETURN, STRUCT

 END; #####################  End of Routine ################################
