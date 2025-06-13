; $ID:	MAPS_PROJECTIONS.PRO,	2022-03-21-16,	USER-KJWH	$

  FUNCTION MAPS_PROJECTIONS, PROJECTION, INIT=INIT

;+
; NAME:
;   MAPS_PROJECTIONS
;
; PURPOSE:
;   This function will get the map projection information needed for MAPS_MAIN
;
; CATEGORY:
;   MAPS
;
; CALLING SEQUENCE:
;   Result = MAPS_PROJECTIONS(MP)
;
; INPUTS:
;   MP: A valid MAP found in MAPS_MAIN
;
; OPTIONAL INPUTS:
;   
;
; KEYWORD PARAMETERS:
;   
;
; OUTPUTS:
;   This function returns a structure with the map projection information
;   
;
; OPTIONAL OUTPUTS:
;   
;
; PROCEDURE:
;
;
; EXAMPLE:
;   ST, MAPS_PROJECTIONS('NEC') 
;
;
; NOTES:
;   Will only work with standard IDL MAPS found in the NEFSC MAPS_MAIN.csv
;   
; COPYRIGHT: 
; Copyright (C) 2018, Department of Commerce, National Oceanic and Atmospheric Administration, National Marine Fisheries Service,
;   Northeast Fisheries Science Center, Narragansett Laboratory.
;   This software may be used, copied, or redistributed as long as it is not sold and this copyright notice is reproduced on each copy made.
;   This routine is provided AS IS without any express or implied warranties whatsoever.
;
;   This program was written by Kimberly Hyde, DOC/NOAA/NMFS/NEFSC Narragansett, RI, kimberly.hyde@noaa.gov
;         
;
; MODIFICATION HISTORY:
;			Written:  April 02, 2019 by K.J.W. Hyde, NOAA/NEFSC/Narragansett Laboratory, 28 Tarzwell Drive, 02882 (kimberly.hyde@noaa.gov)
;			Modified: Apr 03, 2019 - KJWH: Tested and finalized the initial MAPS_PROJECTIONS code
;			          Apr 04, 2019 - KJWH: Added CRS_GRID_MAPPING and NG_MAP to output structure    
;			         
;-
;	****************************************************************************************************
	ROUTINE_NAME = 'MAPS_PROJECTIONS'
	
	SL = PATH_SEP()
	
	IF NONE(PROJECTION) THEN RETURN, 'ERROR: Must provide input projection(s)...' 
	PR = PROJECTION
	
	MFILE = !S.ILD_MAINFILES + 'MAPS_MAIN.csv'
	M = MAPS_READ()
	PROJTAGS = ['PROJ4','PROJ4_CRS','ELLPS_CRS','CRS_GRID_MAPPING','NG_MAP']
	M = STRUCT_COPY(M,['PROJ',PROJTAGS])
	STR = REPLICATE(STRUCT_2MISSINGS(M[0]),N_ELEMENTS(PR))
	STR.PROJ = PR
	
	COMMON _MAPS_PROJECTIONS, PROJ, MTIME
	IF NONE(MTIME) THEN MTIME = GET_MTIME(MFILE)
	IF NONE(PROJ) THEN INIT = 1
	
  IF GET_MTIME(MFILE) GT MTIME OR KEY(INIT) THEN BEGIN
	  PROJ = STRUCT_SORT(M, TAGNAMES='PROJ')
	  FOR N=0, N_ELEMENTS(PROJTAGS)-1 DO BEGIN
	    OK = WHERE(PROJ.PROJ NE '' AND PROJ.(WHERE_TAGS(PROJ,PROJTAGS(N))) EQ '', COUNT)
	    IF COUNT GE 1 THEN MESSAGE, 'ERROR: Check MAPS_MAIN.csv for missing ' + PROJTAGS(N) + ' information.'
	  ENDFOR
	  PROJ = PROJ[UNIQ(PROJ.PROJ)]
	  PROJ = PROJ[WHERE(PROJ.PROJ NE '')]
	ENDIF
	
	OK = WHERE_MATCH(PROJ.PROJ, STR.PROJ, COUNT, VALID=VALID,NINVALID=NINVALID)
	IF COUNT EQ 0 THEN RETURN, 'ERROR: Projection(s) ' + PR + ' not found in ' + MFILE
	STR(VALID) = PROJ[OK]
	RETURN, STR
	
END; #####################  End of Routine ################################
