; $ID:	MAPS_L3B_2LONLAT.PRO,	2023-09-21-13,	USER-KJWH	$
FUNCTION MAPS_L3B_2LONLAT, MAPP, BINS=BINS, LONS=LONS, LATS=LATS, INIT=INIT, OVERWRITE=OVERWRITE

;+
; NAME:
;   MAPS_L3B_2LONLAT
;
; PURPOSE:
;   This procedure provides the bins, longitudes, latitudes for the L3Bx maps
;
; CATEGORY:
;   MAP FUNCTIONS
;
; CALLING SEQUENCE:
;   Result = MAPS_L3B_2LONLAT('L3B9')
;
; REQUIRED INPUTS:
;   MAPP......... The name of a L3Bx map 
;
; OPTIONAL INPUTS:
;  None
;  
; KEYWORD PARAMETERS:
;   INIT......... Reinitialize the COMMON structure
;   OVERWRITE.... Overwrite the LONLAT save file
;
; OUTPUTS:
;   A saved structure with the lon, lat and bin information
;
; OPTIONAL OUTPUTS
;   BINS......... Number of each bin
;   LONS......... Longitude for each bin
;   LATS......... Latitude for each bin
;
; COMMON BLOCKS:
;   MAPS_L3B_2LONLAT_, STRUCT_BINS  A structure with the information for each map
;
; SIDE EFFECTS:
;   None
;
; RESTRICTIONS:
;   None
;
; EXAMPLE:
;   M = MAPS_L3B_2LONLAT('L3B5', BINS=BINS, LATS=LATS, LONS=LONS)
;
; NOTES:
;
;
; COPYRIGHT:
; Copyright (C) 2016, Department of Commerce, National Oceanic and Atmospheric Administration, National Marine Fisheries Service,
;   Northeast Fisheries Science Center, Narragansett Laboratory.
;   This software may be used, copied, or redistributed as long as it is not sold and this copyright notice is reproduced on each copy made.
;   This routine is provided AS IS without any express or implied warranties whatsoever.
;
; AUTHOR:
;   This program was written on June 22, 2016 by Kimberly J. W. Hyde, Northeast Fisheries Science Center | NOAA Fisheries | U.S. Department of Commerce, 28 Tarzwell Dr, Narragansett, RI 02882
;
; MODIFICATION HISTORY:
;	  JUN 22, 2016 - KJWH: Wrote initial code
;	  JUN 23, 2016 - KJWH: Changed from a PRO to a FUNCTION
;		                     First looks for the MASTER file and if not available, then runs BIN2LL
;		                     Now returns a structure with the BINS, LONS and LATS
;			                   Changed the L3B1 NBINS from L to L64 data type
;			                   Added COMMON structure
;	  AUG 19, 2016 - KJWH: Changed !S.MASTER to !S.MAPINFO           
;		AUG 23, 2016 - KJWH: Updated the SAVEFILE      
;		FEB 08, 2017 - KJWH: Changed ROUNDS() to NUM2STR()    
;		                     Removed  BINS = BINS(1:*) ; THE ZERO BIN IS ALWAYS IGNORED because we were not getting the right number of BINS
;		                     Now saving the structure (SAVEFILE)
;		MAR 01, 2017 - KJWH: Replaced CASE block with MAPS_L3B_NROWS and MAPS_L3B_NBINS     
;		MAR 13, 2017 - KJWH: Replaced BIN2LL with MAPS_BIN2LL (a function derived from BIN2LL)
;		                     Removed calls to MAPS_L3B_NBINS and MAPS_L3B_NROWS because now called in MAPS_2BINLL       
;		AUG 09, 2021 - KJWH: Added COMPILE_OPT IDL2
;		                     Updated documentation
;		                     Moved to MAP_FUNCTIONS	 
;		                     Changed MP to MAPP to be consistent with other mapping programs                    	
;-
;	****************************************************************************************************

  ROUTINE_NAME='MAPS_L3B_2LONLAT'
  COMPILE_OPT IDL2
  
  COMMON MAPS_L3B_2LONLAT_, STRUCT_BINS
  IF NONE(STRUCT_BINS) OR KEY(INIT) OR KEY(OVERWRITE) THEN STRUCT_BINS=CREATE_STRUCT('_','')
  
  MP = STRUPCASE(MAPP)
  
  OK_TAG = WHERE(TAG_NAMES(STRUCT_BINS) EQ MP,COUNT)
  IF COUNT EQ 1 THEN BEGIN
    STR = STRUCT_BINS.(OK_TAG)
    BINS = STR.BINS
    LATS = STR.LATS
    LONS = STR.LONS
    RETURN, STR
  ENDIF
    
  MS = MAPS_SIZE(MP,PX=PX,PY=PY)
  SAVEFILE = !S.MAPINFO + MP + '-PXY_' + NUM2STR(PX) + '_' + NUM2STR(PY) + '-BIN_LONLAT.SAV'
  IF EXISTS(SAVEFILE) AND ~KEY(OVERWRITE) THEN BEGIN
    STR = IDL_RESTORE(SAVEFILE)
    BINS = STR.BINS
    LATS = STR.LATS
    LONS = STR.LONS
    STRUCT_BINS=CREATE_STRUCT(TEMPORARY(STRUCT_BINS),MP,STR)
    RETURN, STR
  ENDIF
      
  STR = MAPS_BIN2LL(MP,LATS=LATS,LONS=LONS)
	SAVE, STR, FILENAME=SAVEFILE
	STRUCT_BINS = CREATE_STRUCT(TEMPORARY(STRUCT_BINS),MP,STR)
  RETURN, STR

END; #####################  End of Routine ################################
