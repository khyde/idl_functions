; $ID:	READ_BATHY.PRO,	2021-03-15-16,	USER-KJWH	$
	FUNCTION READ_BATHY, MP, PX=PX, PY=PY, DIR=DIR, FILENAME=FILENAME, STRUCT=STRUCT, NAME_ONLY=NAME_ONLY
;+
; This Program Reads a standard Bathy Image and returns either:
;
;	INPUT
;		MP: The name of a standard map (e.g. 'NEC','EC','GEQ')
;
;	OUTPUT
;		The BATHY IMAGE (in positive values) is returned
;
;	KEYWORDS:
;			PX:		The x size in pixels of the map
;			PY:		The y size in pixels of the map
;			DIR:	The directory of the map to be read - DEFAULT is !S.IDL_TOPO/SAV/
;			
; OPTIONAL OUTPUTS:
;     FILENAME:  The name of the bathy file read
;     STRUCT:    The structure found in the bathy file with the original TOPO data
;
; 	HISTORY:
;   Jan 28, 2006	Written by J.O'Reilly, NOAA
;		Dec 19, 2006 JOR added keyword NAME to return the actual name of the bathy file read
;		SEP 07, 2017 - KJWH: Overhauled READ_BATHY to be consistent with other READ_x programs (e.g. READ_LANDMASK)
;		                     Now using the SAV files found in !S.IDL_TOPO/SAV/ 
;		                     Makes all "LAND" pixels missings
;		                     Changes the negative "OCEAN" pixels to positive, creating a "BATHY" product
;		                     Options to return the original STRUCTURE (with the original TOPO data) of the SAV file and FILENAME  
;		APR 10, 2018 - KJWH: Add keyword NAME_ONLY to return the bathy filename instead of the data
;                        Added IF KEY(NAME_ONLY) THEN RETURN, FILENAME  
;-
; *************************************************************************
	ROUTINE_NAME='READ_BATHY'
	SL = PATH_SEP()
	
;	===> Default directory for bathy png
	IF NONE(DIR) THEN _DIR = !S.IDL_TOPO+'SAV'+SL ELSE _DIR= DIR
  IF NONE(MP)  THEN RETURN, 'ERROR: Map name must be provided' ELSE MP = STRUPCASE(MP)

  MS=MAPS_SIZE(MP)
  IF NONE(PX) THEN PX=MS.PX
  IF NONE(PY) THEN PY=MS.PY

  BATHY_FILE= _DIR+'TOPO-'+MP+'-PXY_'+ROUNDS(PX)+'_'+ROUNDS(PY)+'-TOPO.SAV'
  IF ~EXISTS(BATHY_FILE) THEN MAPS_TOPO, MP, PX=PX, PY=PY
  IF ~EXISTS(BATHY_FILE) THEN MESSAGE, 'ERROR: Unable to find or create the BATHY_FILE: ' + BATHY_FILE 
  
  FILENAME=BATHY_FILE
  IF KEY(NAME_ONLY) THEN RETURN, FILENAME
	BATHY = FLOAT(STRUCT_READ(BATHY_FILE,STRUCT=STRUCT))
	
	OK = WHERE(BATHY LT 0.0, COUNT, COMPLEMENT=COMPLEMENT)
	BATHY(COMPLEMENT) = MISSINGS(BATHY)  ; Make all of the "LAND" pixels (pixels with values GT 0) missings
	BATHY[OK] = -1.0 * BATHY[OK]         ; Convert the negative "WATER" pixels to positive values
	
	RETURN, BATHY

END; #####################  End of Routine ################################



