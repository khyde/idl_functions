; $ID:	BATHY_2SHPFILE.PRO,	2023-12-11-16,	USER-KJWH	$
  PRO BATHY_2SHPFILE, MAPP=MAPP, DEPTHS=DEPTHS, OVERWRITE=OVERWRITE

;+
; NAME:
;   BATHY_2SHPFILE
;
; PURPOSE:
;   Create a shapefile of isobaths
;
; CATEGORY:
;   SHPFILE_FUNCTIONS
;
; CALLING SEQUENCE:
;   BATHY_2SHPFILE
;
; REQUIRED INPUTS:
;   None
;
; OPTIONAL INPUTS:
;   MAPP......... The name of the map to base the shapefile on
;   DEPTHS....... An array of bathymetry depth levels
;
; KEYWORD PARAMETERS:
;   OVERWRITE.... Overwrite the shapefile if it currently exists
;
; OUTPUTS:
;   A new shapefile in !S.IDL_SHAPEFILES
;
; OPTIONAL OUTPUTS:
;   None
;
; COMMON BLOCKS: 
;   None
;
; SIDE EFFECTS:  
;   None
;
; RESTRICTIONS:  
;   None
;
; EXAMPLE:
; 
;
; NOTES:
;   $Citations or any other useful notes$
;   
; COPYRIGHT: 
; Copyright (C) 2023, Department of Commerce, National Oceanic and Atmospheric Administration, National Marine Fisheries Service,
;   Northeast Fisheries Science Center, Narragansett Laboratory.
;   This software may be used, copied, or redistributed as long as it is not sold and this copyright notice is reproduced on each copy made.
;   This routine is provided AS IS without any express or implied warranties whatsoever.
;
; AUTHOR:
;   This program was written on December 11, 2023 by Kimberly J. W. Hyde, Northeast Fisheries Science Center | NOAA Fisheries | U.S. Department of Commerce, 28 Tarzwell Dr, Narragansett, RI 02882
;    
; MODIFICATION HISTORY:
;   Dec 11, 2023 - KJWH: Initial code written
;-
; ****************************************************************************************************
  ROUTINE_NAME = 'BATHY_2SHPFILE'
  COMPILE_OPT IDL3
  SL = PATH_SEP()
  
  DIR = !S.IDL_TOPO + 'SUBAREAS' + SL & DIR_TEST, DIR
  
  IF ~N_ELEMENTS(MAPP) THEN MP = 'NWA' ELSE MP = MAPP
  MS = MAPS_SIZE(MP,PX=PX,PY=PY)
  BATHY = READ_BATHY(MP)
  IF ~N_ELEMENTS(DEPTHS) THEN DEPS = [0,10,25,50,75,100,150,200,250,300,400,500,750,1000,2000,3000,4000,5000,6000,7000,8000,9000,10000] ELSE DEPS = ABS(DEPTHS)
  DEPS = DEPS[WHERE(DEPS GE MIN(BATHY,/NAN) AND DEPS LT MAX(BATHY,/NAN),/NULL)] & IF DEPS EQ [] THEN MESSAGE, 'ERROR: Double check the depths'
    
  IF N_ELEMENTS(DEPS) EQ 1 THEN DLABEL = NUM2STR(DEPS) ELSE DLABEL = STRJOIN([NUM2STR(MIN(DEPS)),NUM2STR(MAX(DEPS))],'_')
  
  SUBFILE = DIR + 'MASK_SUBAREA-' + MP +'_BATHY_RANGE_' + DLABEL + '.SAV'

  IF ~FILE_TEST(SUBFILE) OR KEYWORD_SET(OVERWRITE) THEN BEGIN   
    TOPO = PLT_TOPO(MP, -1*DEPS, COLORS=INDGEN(N_ELEMENTS(DEPS))+1);, THICKS=THICKS, COLORS=COLORS, VERBOSE=VERBOSE, VIEW=VIEW, FACT=FACT, SMO=SMO, PNGFILE=PNGFILE, PAL=PAL, LABEL=LABEL
    SUBAREA_NAME = 'BATHY_' + NUM2STR(DEPS)
    SUBAREA_CODE = INDGEN(N_ELEMENTS(DEPS))+1
    STRUCT_WRITE, TOPO, SUBAREA_NAME=SUBAREA_NAME, SUBAREA_CODE=SUBAREA_CODE, MAP=MP, PX=PX, PY=PY, FILE=SUBFILE
  ENDIF 
  
  SUBAREAS_IMAGE_2SHP, SUBFILE, /LINE
  
  
END ; ***************** End of BATHY_2SHPFILE *****************
