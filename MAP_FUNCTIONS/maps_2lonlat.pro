; $ID:	MAPS_2LONLAT.PRO,	2023-09-21-13,	USER-KJWH	$
;##############################################################################
 FUNCTION MAPS_2LONLAT, MAPP, PX=PX, PY=PY, LOWER_LEFT=LOWER_LEFT, LONS=LONS, LATS=LATS, INIT=INIT, OUTFILE=OUTFILE, DIR_OUT=DIR_OUT, OVERWRITE=OVERWRITE
;+
; NAME:
;  MAPS_2LONLAT
;
; PURPOSE:
;  Generate an structure with lon and lat values for the center of each pixel in a standard map
;
; CATEGORY:
;   MAP_FUNCTIONS
;       
; CALLING SEQUENCE:
;   Result = MAPS_2LONLAT(MAP)
;
;	REQUIRED INPUT:
;		MP.......... Standard map (e.g. NEC, EC)
;		
; OPTIONAL INPUTS:
;   PX.......... Set the X pixel dimensions for a specific map
;   PY.......... Set the Y pixel dimensions for a specific map
;   LONS........ Longitude array
;   LATS........ Latitude array
;   DIR_OUT..... Output directory for the SAV file
;   OUTFILE..... Output file name
;   
; KEYWORD PARAMETERS  
;   LOWER_LEFT.. Output the lat,lon for lower left corner of each pixel (the default is the center of each pixel)
;   INIT........ Reinitialize the COMMON 
;   OVERWRITE... Overwrites the outfile if it exists
;   
; OUTPUTS:
;   Creates a file with lon/lat information for a specific map
;
; OPTIONAL OUTPUTS:
;   None
;
; COMMON BLOCKS:
;   Structure to hold the lon/lat information for each map
;
; SIDE EFFECTS:
;   None
;
; RESTRICTIONS:
;   None
;
; EXAMPLES:
;   ST, MAPS_2LONLAT('NEC')
;   ST, MAPS_2LONLAT('NEC',PX= 512,PY=512)
;
; NOTES:
; 
; COPYRIGHT:
; Copyright (C) 2006, Department of Commerce, National Oceanic and Atmospheric Administration, National Marine Fisheries Service,
;   Northeast Fisheries Science Center, Narragansett Laboratory.
;   This software may be used, copied, or redistributed as long as it is not sold and this copyright notice is reproduced on each copy made.
;   This routine is provided AS IS without any express or implied warranties whatsoever.
;
; AUTHOR:
;   This program was written on October 04, 2006 by John E. O'Reilly, Northeast Fisheries Science Center | NOAA Fisheries | U.S. Department of Commerce, 28 Tarzwell Dr, Narragansett, RI 02882
;     Inquires should be directed to kimberly.hyde@noaa.gov
;     
; MODIFICATION HISTORY:
;   OCT 04, 2006 - JEOR: Wrote initial code
;   JAN 20, 2010 - KJWH: Added LME map logicC
;   OCT 04, 2014 - JEOR: Removed LME map logic [obsolete by new maps system]
;   DEC 10, 2014 - JEOR: Renamed to MAPS_2LONLAT
;                        Added MAPS_SET
;   NOV 19, 2015 - KJWH: Changed the distinction between "center" and "lower_left" in the IMG_XPXY() call to be pos and not center (and consistent with updates to IMG_XPYP)
;   NOV 20, 2015 - KJWH: Added /DOUBLE keyword to the IMG_XPYP call
;   JUN 28, 2016 - KJWH: Removed "ELSE BEGIN  ZWIN, [PX,PY]  ENDELSE" because it is redundant 
;                        Added LONS and LATS as optional inputs
;   JUL 19, 2016 - KJWH: Changed MAP to MP to avoid conflicts with IDL's MAP program
;                        Added a check to make sure MP is not LONLAT and return and ERROR string
;                        Now saving the output structures and reading if the exist
;                        Added DIR_OUT, OUTFILE and OVERWRITE keywords    
;                        Added GONE, IXY and GONE, XYZ     
;   JUL 29, 2016 - KJWH: Added IF VALIDS('MAPS',MP) EQ '' THEN RETURN, 'ERROR: ' + MP + ' is not a valid map for MAPS_2LONLAT' (changed from just looking for the 'LONLAT' map)          
;   JAN 06, 2017 - KJWH: Added steps to work with SUBSET maps    
;   SEP 07, 2017 - KJWH: Added option for L3Bx maps - IF IS_L3B(MP) THEN RETURN, MAPS_L3B_2LONLAT(MP)      
;   DEC 11, 2017 - KJWH: Changed LON and LAT to LONS and LATS in the output structure to be consistent with other programs.  
;                        *** May need to recreate most of the LONLAT.SAV files.    
;   APR 05, 2019 - KJWH: Added step to check and see if a "new" map was created and if so, recreate the MAPS_2LONLAT file   
;   MAY 12, 2020 - KJWH: Added a COMMON structure to hold the lon lat information for various maps.  
;                        Added INIT keyword to reinitialize the COMMON structure      
;   AUG 04, 2021 - KJWH: Added COMPILE_OPT IDL2
;                        Changed subscript () to []
;                        Changed input variable MP to MAPP to be consistent with other programs with MAPP inputs
;                        Added SEASCAPES as a special global map              
;                        Updated formatting and documentation
;                        Moved program to MAP_FUNCTIONS   
;   JUn 02, 2023 - KJWH: Added ACSPO PX and PY dimensions
;-
; **************************************************************************************************************
  ROUTINE_NAME = 'MAPS_2LONLAT'
  COMPILE_OPT IDL2
  SL = PATH_SEP()
  
  IF NONE(MAPP)         THEN RETURN,'ERROR: MAP IS REQUIRED'
  IF HAS(MAPP,'SUBSET') THEN MAP_SUBSET = 1 ELSE MAP_SUBSET = 0
  IF KEY(LOWER_LEFT)    THEN POS = 'LL' ELSE POS = 'CEN'
  
  COMMON MAPS_2LONLAT_, STRUCT_LONLAT
  IF NONE(STRUCT_LONLAT) OR KEY(INIT) OR KEY(OVERWRITE) THEN STRUCT_LONLAT=[]

  MP = STRUPCASE(MAPP)
  
  IF VALIDS('MAPS',MP) EQ '' AND MAP_SUBSET EQ 0 THEN BEGIN
    CASE MP OF
      'MUR':       BEGIN & PX=36000 & PY=17999 & END
      'ACSPO':     BEGIN & PX=18000 & PY=9000  & END
      'AVHRR':     BEGIN & PX=8640  & PY=4320  & END
      'OISST':     BEGIN & PX=1440  & PY=720   & END
      'NOAA5KM':   BEGIN & PX=7200  & PY=3600  & END
      ELSE: RETURN, 'ERROR: ' + MP + ' is not a valid map for MAPS_2LONLAT'
    ENDCASE
    
  ENDIF
  
  IF IS_L3B(MP) THEN RETURN, MAPS_L3B_2LONLAT(MP, LONS=LONS, LATS=LATS, OVERWRITE=OVERWRITE)

;	===> If PX and PY not provided get default sizes for this map
  IF NONE(PX) OR NONE(PY) THEN BEGIN
  	MS = MAPS_SIZE(MP)
  	PX = MS.PX
  	PY = MS.PY 
  ENDIF 
    
  MAP_TAG = MP + '_PXY_' + NUM2STR(PX) + '_' + NUM2STR(PY)
  IF STRUCT_LONLAT NE [] THEN OK_TAG = WHERE(TAG_NAMES(STRUCT_LONLAT) EQ MAP_TAG,COUNT) ELSE COUNT = 0
  IF COUNT EQ 1 THEN BEGIN
    STR = STRUCT_LONLAT.(OK_TAG)
    LATS = STR.LATS
    LONS = STR.LONS
    RETURN, STR
  ENDIF  
    
; ===> Make the name for the savefile
  IF NONE(DIR_OUT) THEN DIR_OUT = !S.MAPINFO
  IF NONE(OUTFILE) THEN OUTFILE = DIR_OUT + STRUPCASE(MP) + '-PXY_' + ROUNDS(PX) + '_' + ROUNDS(PY) + '-LONLAT.SAV'

; ===> Read maps_master to determine if a "new" map was created and the outfile needs to be replaced
  MR = MAPS_READ(MP)
  MTIME = JD_ADD(PERIOD_2JD(MR.PERIOD),(SYSTIME(/JULIAN,/UTC)-SYSTIME(/JULIAN))*24.,/HOUR) ; Convert the period to a UTC Julian date

;===> If MAPS_2LONLAT-MAP file already exists then read and return
  IF FILE_TEST(OUTFILE) EQ 1 AND ~KEY(OVERWRITE) AND GET_MTIME(OUTFILE,/JD) GT MTIME THEN BEGIN
    D = IDL_RESTORE(OUTFILE)
    LONS=D.LONS
    LATS=D.LATS
    IF STRUCT_LONLAT EQ [] THEN STRUCT_LONLAT = CREATE_STRUCT(MAP_TAG,D) ELSE STRUCT_LONLAT=CREATE_STRUCT(TEMPORARY(STRUCT_LONLAT),MAP_TAG,D)
    RETURN, D
  ENDIF  
  
  IF MAP_SUBSET EQ 1 THEN BEGIN
    MASTER_LATS = IDL_RESTORE(!S.MAPINFO + 'MUR-PXY_36000_17999-LAT.SAV')
    MASTER_LONS = IDL_RESTORE(!S.MAPINFO + 'MUR-PXY_36000_17999-LON.SAV')

    LATS = MAPS_REMAP(MASTER_LATS, MAP_IN='MUR', MAP_OUT=MP, MAP_SUBSET=1, LONMIN=MS.LONMIN, LONMAX=MS.LONMAX, LATMIN=MS.LATMIN, LATMAX=MS.LATMAX)
    LONS = MAPS_REMAP(MASTER_LONS, MAP_IN='MUR', MAP_OUT=MP, MAP_SUBSET=1, LONMIN=MS.LONMIN, LONMAX=MS.LONMAX, LATMIN=MS.LATMIN, LATMAX=MS.LATMAX)
    SZ = SIZEXYZ(SUBSET_LATS)
    IF SZ.PX NE PX OR SZ.PY NE PY THEN MESSAGE, 'ERROR: LAT/LON array sizes (PX and/or PY) do not map sizes from MAPS_MAIN.csv.  Note, SUBSET LONLAT file can also be created in MAPS_MAIN.'
    GOTO, SKIP_MAPSET  
  ENDIF
    
  IXY=IMG_XPYP([PX,PY],POS=POS,/DOUBLE)

; ===> Open Z device and size it to [PX,PY]
	IF MP NE 'NENA' AND MP NE 'FENNEL' THEN BEGIN
  	MAPS_SET, MP
  ;	===> GET THE LON,LAT
  	XYZ=CONVERT_COORD(IXY.X,IXY.Y,/DEVICE,/TO_DATA)
  	GONE, IXY
  	LONS = REFORM(XYZ[0,*],PX,PY)
  	LATS = REFORM(XYZ[1,*],PX,PY)
  	GONE,XYZ
  	ZWIN
  ENDIF ELSE BEGIN
    IF MP EQ 'NENA' THEN BEGIN
      M=READ_MATFILE(!S.DATA + 'ROMS-NENA-LON-SURFACE.MAT') & LONS=M.(1).DATA
      M=READ_MATFILE(!S.DATA + 'ROMS-NENA-LAT-SURFACE.MAT') & LATS=M.(1).DATA
    ENDIF
    IF MP EQ 'FENNEL' THEN BEGIN
      LATS = IDL_RESTORE(!S.DATA+'KFENNEL_LAT.SAVE')
      LONS = IDL_RESTORE(!S.DATA+'KFENNEL_LON.SAVE')      
    ENDIF  
  ENDELSE;IF MAP NE 'NENA' AND MAP NE 'FENNEL' THEN BEGIN

  SKIP_MAPSET:

	D = CREATE_STRUCT('MAP',MP,'LONS',LONS,'LATS',LATS)
	STRUCT_LONLAT=CREATE_STRUCT(TEMPORARY(STRUCT_LONLAT),MAP_TAG,D)
	
	SAVE, FILENAME=OUTFILE, D
	RETURN, D
	
END; #####################  END OF ROUTINE ################################

