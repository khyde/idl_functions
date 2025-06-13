; $ID:	MAPS_L3B_SUBS.PRO,	2023-09-21-13,	USER-KJWH	$
; 
PRO MAPS_L3B_SUBS, DATASETS, OVERWRITE=OVERWRITE
;+
; NAME:
;   MAPS_L3B_SUBS
; 
; PURPOSE:
;   This program creates L3B9, L3B4, L3B2 and L3B1 subscript master files for specified datasets (e.g. AVHRR or MUR SST) 
;
; CATEGORY: 
;   MAP FUNCTIONS
; 
; CALLING SEQUENCE: 
;   MAPS_L3B_SUBS, 'MUR'
;
; REQUIRED INPUTS: 
;   None
;
; OPTIONAL INPUTS:
;   DATASETS..... The input dataset name (defualt is [MUR,AVHRR])
;   L3BS......... The output L3Bx maps (defaul it [L3B1,L3B2,L3B4,L3B5,L3B9])
;
; KEYWORD PARAMETERS:
;   OVERWRITE.... Overwrite the output files if they already exist
;
; OUTPUTS:
;   Master map files for the specified dataset
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
;   MAPS_L3B_SUBS, MUR
;
; NOTES:
;
; COPYRIGHT:
; Copyright (C) 2015, Department of Commerce, National Oceanic and Atmospheric Administration, National Marine Fisheries Service,
;   Northeast Fisheries Science Center, Narragansett Laboratory.
;   This software may be used, copied, or redistributed as long as it is not sold and this copyright notice is reproduced on each copy made.
;   This routine is provided AS IS without any express or implied warranties whatsoever.
;
; AUTHOR:
;   This program was written on October 29, 2015 by Kimberly J. W. Hyde, Northeast Fisheries Science Center | NOAA Fisheries | U.S. Department of Commerce, 28 Tarzwell Dr, Narragansett, RI 02882
;
; MODIFICATION HISTORY:
;   OCT 29, 2015 - KJWH: Initial code written
;   OCT 30, 2015 - KJWH: Changed !S.DEMO to !S.FILES
;   MAR 17, 2016 - KJWH: Added LON and LAT master SAV files
;                        Added STRUPCASE(DATASETS[N])
;   JUN 22, 2016 - KJWH: Added L3B1 files   
;   JUN 23, 2016 - KJWH: Added steps to create MASTER SAV files with the L3B BINS, LONS and LATS    
;   AUG 23, 2016 - KJWH: Updated the input and output file names      
;   JAN 06, 2017 - KJHW: Added L3B2 files       
;   MAR 01, 2017 - KJWH: Changed ROUNDS() to NUM2STR() because ROUNDS was changing the value 
;   FEB 07, 2020 - KJWH: Added OISST map
;   AUG 04, 2021 - KJWH: Added SEASCAPES map
;                        Added COMPILE_OPT IDL2
;                        Changed subscript () to []
;                        Updated documentation and formatting
;                        Moved to MAP_FUNCTIONS 
;   NOV 19, 2021 - KJWH: Added OCCCI-1KM dataset      
;-
; *****************************************************************************************************************
  ROUTINE_NAME  = 'MAPS_L3B_SUBS'
  COMPILE_OPT IDL2
  SL = PATH_SEP()

  FOR N=0, N_ELEMENTS(L3BS)-1 DO BEGIN
    MS = MAPS_SIZE(L3BS[N])
    SAVEFILE = !S.MAPINFO + L3BS[N] + '-PXY_' + NUM2STR(MS.PX) + '_' + NUM2STR(MS.PY) + '-BIN_LONLAT.SAV'
    IF FILE_TEST(SAVEFILE) EQ 1 AND NOT KEY(OVERWRITE) THEN CONTINUE
    STR = MAPS_L3B_2LONLAT(L3BS[N])
    SAVE, STR, FILENAME=SAVEFILE
  ENDFOR

  IF NONE(DATASETS) THEN DATASETS = ['MUR','AVHRR']    
  FOR N=0, N_ELEMENTS(DATASETS)-1 DO BEGIN
    DATASET = STRUPCASE(DATASETS[N])
    CASE DATASET OF 
      'MUR':       BEGIN & PX=36000 & PY=17999 & END
      'ACSPO':     BEGIN & PX=18000 & PY=9000  & END
      'AVHRR':     BEGIN & PX=8640  & PY=4320  & END
      'OISST':     BEGIN & PX=1440  & PY=720   & END
      'NOAA5KM':   BEGIN & PX=7200  & PY=3600  & END
      'OCCCI-1KM': BEGIN & PX=34560 & PY=17280 & END
      'OCCCI-4KM': BEGIN & PX=8640  & PY=4320  & END
      ELSE: MESSAGE, 'ERROR: ' + MP + ' is not a valid DATASET for MAPS_L3B_SUBS'      
    ENDCASE
    
    L3B1_FILE = !S.MAPINFO + DATASET + '-PXY_' + NUM2STR(PX) + '_' + NUM2STR(PY) + '-2L3B1.SAV'
    L3B2_FILE = !S.MAPINFO + DATASET + '-PXY_' + NUM2STR(PX) + '_' + NUM2STR(PY) + '-2L3B2.SAV'
    L3B4_FILE = !S.MAPINFO + DATASET + '-PXY_' + NUM2STR(PX) + '_' + NUM2STR(PY) + '-2L3B4.SAV'
    L3B5_FILE = !S.MAPINFO + DATASET + '-PXY_' + NUM2STR(PX) + '_' + NUM2STR(PY) + '-2L3B5.SAV'
    L3B9_FILE = !S.MAPINFO + DATASET + '-PXY_' + NUM2STR(PX) + '_' + NUM2STR(PY) + '-2L3B9.SAV'
    LAT_FILE  = !S.MAPINFO + DATASET + '-PXY_' + NUM2STR(PX) + '_' + NUM2STR(PY) + '-LAT.SAV'
    LON_FILE  = !S.MAPINFO + DATASET + '-PXY_' + NUM2STR(PX) + '_' + NUM2STR(PY) + '-LON.SAV'
    LAT_ARRAY = !S.MAPINFO + DATASET + '-PY_'                      + NUM2STR(PY) + '-LAT.SAV'
    LON_ARRAY = !S.MAPINFO + DATASET + '-PX_'  + NUM2STR(PX)                     + '-LON.SAV'
    
    IF WHERE(FILE_TEST([L3B1_FILE,L3B2_FILE,L3B4_FILE,L3B5_FILE,L3B9_FILE,LAT_FILE,LON_FILE,LAT_ARRAY,LON_ARRAY]) EQ 0,/NULL) EQ [] AND ~KEYWORD_SET(OVERWRITE) THEN CONTINUE
    
    F = FILE_SEARCH(!S.IDL_DEMO + 'FILES' + SL + '*' + DATASET + '*.nc',COUNT=COUNT)
    IF COUNT EQ 0 THEN MESSAGE, 'ERROR: NEED SAMPLE FILE TO MAKE THE MASTER L3B FILES'
    SD = READ_NC(F[0],PRODS=['LON','LAT'])
    LON = SD.SD.LON.IMAGE
    LAT = SD.SD.LAT.IMAGE
    
    IF MAX(LON GT 180.1) THEN BEGIN
      OK = WHERE(LON GT 180.0)
      LON[OK] = LON[OK]-360.0  ; Convert data from 0 to 360 degrees to -180 to 180 degrees 
    ENDIF
    
    IF FILE_TEST(LAT_ARRAY) EQ 0 OR KEY(OVERWRITE) THEN SAVE, FILENAME=LAT_ARRAY, LAT  ; SAVE THE LATITUDE ARRAY FILE
    IF FILE_TEST(LON_ARRAY) EQ 0 OR KEY(OVERWRITE) THEN SAVE, FILENAME=LON_ARRAY, LON  ; SAVE THE LONGITUDE ARRAY FILE
    
    LATS = FLTARR(N_ELEMENTS(LON),N_ELEMENTS(LAT)) & LATS[*] = MISSINGS(LATS) & LONS = LATS ; CREATE BLANK ARRAYS FOR THE LON AND LAT DATA
    FOR L=0, N_ELEMENTS(LAT)-1 DO LONS[*,L] = TRANSPOSE(LON) ; FILL IN THE LON GRID FROM A SINGLE ARRAY
    FOR L=0, N_ELEMENTS(LON)-1 DO LATS[L,*] = LAT            ; FILL IN THE LAT GRID FROM A SINGLE ARRAY
    
    IF FILE_TEST(LAT_FILE) EQ 0 OR KEY(OVERWRITE) THEN SAVE, FILENAME=LAT_FILE, LATS  ; SAVE THE GRIDDED LATITUDE FILE
    IF FILE_TEST(LON_FILE) EQ 0 OR KEY(OVERWRITE) THEN SAVE, FILENAME=LON_FILE, LONS  ; SAVE THE GRIDDED LONGITUDE FILE
    
    IF FILE_TEST(L3B9_FILE) EQ 0 OR KEY(OVERWRITE) THEN BEGIN
      PRINT, 'Creating ' + L3B9_FILE
      BINS9 = MAPS_L3B_LONLAT_2BIN('L3B9',LONS,LATS)     ; FIND THE BIN NUMBER FOR EACH LON AND LAT VALUE
      SAVE, FILENAME=L3B9_FILE, BINS9
    ENDIF
    
    IF FILE_TEST(L3B5_FILE) EQ 0 OR KEY(OVERWRITE) THEN BEGIN
      PRINT, 'Creating ' + L3B5_FILE
      BINS5 = MAPS_L3B_LONLAT_2BIN('L3B5',LONS,LATS)     ; FIND THE BIN NUMBER FOR EACH LON AND LAT VALUE
      SAVE, FILENAME=L3B5_FILE, BINS5
    ENDIF
    
    IF FILE_TEST(L3B4_FILE) EQ 0 OR KEY(OVERWRITE) THEN BEGIN
      PRINT, 'Creating ' + L3B4_FILE
      BINS4 = MAPS_L3B_LONLAT_2BIN('L3B4',LONS,LATS)     ; FIND THE BIN NUMBER FOR EACH LON AND LAT VALUE
      SAVE, FILENAME=L3B4_FILE, BINS4
    ENDIF

    IF FILE_TEST(L3B2_FILE) EQ 0 OR KEY(OVERWRITE) THEN BEGIN
      PRINT, 'Creating ' + L3B2_FILE
      BINS2 = MAPS_L3B_LONLAT_2BIN('L3B2',LONS,LATS)     ; FIND THE BIN NUMBER FOR EACH LON AND LAT VALUE
      SAVE, FILENAME=L3B2_FILE, BINS2
    ENDIF
    
    IF FILE_TEST(L3B1_FILE) EQ 0 OR KEY(OVERWRITE) THEN BEGIN
      PRINT, 'Creating ' + L3B1_FILE
      BINS1 = MAPS_L3B_LONLAT_2BIN('L3B1',LONS,LATS)     ; FIND THE BIN NUMBER FOR EACH LON AND LAT VALUE
      SAVE, FILENAME=L3B1_FILE, BINS1
    ENDIF
  ENDFOR ; FOR N=0, N_ELEMENTS(DATASETS)-1 DO BEGIN
  DONE:

END; #####################  END OF ROUTINE ################################
