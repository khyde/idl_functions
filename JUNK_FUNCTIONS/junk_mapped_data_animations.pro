; $ID:	JUNK_MAPPED_DATA_ANIMATIONS.PRO,	2020-06-30-17,	USER-KJWH	$
PRO JUNK_MAPPED_DATA_ANIMATIONS, DATASET, PERIOD=PERIOD, DATERANGE=DATERANGE, PROD=PROD, MAP_OUT=MAP_OUT, INIT=INIT, OVERWRITE=OVERWRITE, BUFFER=BUFFER, VERBOSE=VERBOSE

;+
; NAME:
;   MAPPED_DATA_ANIMATIONS
;
; PURPOSE:
;   Program to generate animations of mapped data
;
; CATEGORY:
;   Visualization
;
; CALLING SEQUENCE:
;   
;
; INPUTS:
;   
;
; OPTIONAL INPUTS:
;   
;
; KEYWORD PARAMETERS:
;   VERBOSE...... Print steps while running the program
;
; PROCEDURE:
;   1) Look for files
;   2) Create images for each season
;   3) Make mp4 files
;
; OUTPUTS:
;   1) Browse images of the input files
;   2) Animations
;
; ISSUES:
;   
;   
; TO DO:
;   
;
; EXAMPLE:
;  
;
; NOTES:
;
; COPYRIGHT:
;   Copyright (C) 2020, Department of Commerce, National Oceanic and Atmospheric Administration, National Marine Fisheries Service,
;   Northeast Fisheries Science Center, Narragansett Laboratory.
;   This software may be used, copied, or redistributed as long as it is not sold and this copyright notice is reproduced on each copy made.
;   This routine is provided AS IS without any express or implied warranties whatsoever.
;
;   This program was written April 23, 2020 by Kimberly Hyde, DOC/NOAA/NMFS/NEFSC Narragansett, RI, kimberly.hyde@noaa.gov.
;
; MODIFICATION HISTORY:
;       
;-      
;|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||

  ROUTINE_NAME = 'MAPPED_DATA_ANIMATIONS'
  SL = PATH_SEP() ; Short cut for the path separated (/ or \) depending on the operating system
  IF NONE(MAP_OUT) THEN MP = 'NES' ELSE MP = MAP_OUT                                  ; Default map for the images
  
  BUFFER = 1
  INIT = 1
  OVERWRITE = 0
  
; ===> Set up output directories
  DIR = !S.spatial_animations + ROUTINE_NAME + SL
  DIR_PNG  = DIR + 'PNG' + SL & DIR_TEST, DIR_PNG
  DIR_MOV  = DIR + 'ANIMATIONS' + SL & DIR_TEST, DIR_MOV
  MFILE = 'D_20190101_20191231-MUR-NES-SST.mp4'
  
  SHP = READ_SHPFILE('NES_EPU_NOESTUARIES',MAPP=MP)
  OUTLINE = SHP.(0).OUTLINE
 
 
; ===> Get files
;TODO Create a GET_FILES program (based off of the GET_SOE_FILES function to get dataset/prod/period specific files 
  FILES = FILE_SEARCH(!S.SST + 'MUR/L3B2/SAVE/SST/D_2019*.SAV',COUNT=COUNT)
  
; ===> Set up a COMMON memory structure for the map data
;  COMMON SPATIAL_ANIMATIONS_2MAP_, LONS, LATS, MAP_STRUCT
;  IF KEY(INIT) THEN BEGIN
;    LONS = []
;    LATS = []
;    MAP_STRUCT = []
;  ENDIF  
  
  
; ===> Find input data files and loop through each file
  ;FILES = FILE_SEARCH(DIR_DATA + '*.nc',COUNT=COUNT)
  PNGS = []
  counter = 0
  FOR I=0, COUNT-1 DO BEGIN                 
    FP = FILE_PARSE(FILES(I))                                                         ; Parse the file name
   ; DIR_IMAGE = DIR + STRUPCASE(FP.NAME) + SL & DIR_TEST, DIR_IMAGE                   ; Create an output directory of the mapped images
    PNGFILE = DIR_PNG + STRUPCASE(FP.NAME) + '.png'         ; Create a file name for the output png
    PNGS = [PNGS,PNGFILE]
    IF FILE_MAKE(FILES(I),PNGFILE,OVERWRITE=OVERWRITE) EQ 0 THEN CONTINUE           ; If the png file exists and is "newer" than the input file and keyword "overwrite" is not set, then skip to the next year

    DAT = STRUCT_READ(FILES(I),STRUCT=STR)
    
  ;  NC = READ_NC(FILES(I))                                                            ; Read the netcdf file
    IF DAT EQ [] THEN MESSAGE, 'ERROR: Unable to read ' + FILES(I)                     ; Stop if there was an error reading the file
    
;    YEAR = FIX(NC.SD.TIME.IMAGE)                                                      ; 1D array of the years (converted to integer)
;    YRS = YEAR_RANGE(MIN(YEAR),MAX(YEAR),/STRING)                                     ; Create an array of years to compare to the input year array
;    OK = WHERE_MATCH(STRTRIM(YEAR,2),YRS,COUNT,NINVALID=NINVALID, INVALID=INVALID)    ; Find any missing years in the YEAR array
;    IF NINVALID GT 0 THEN MESSAGE, 'ERROR: ' + STRTRIM(NINVALID) + ' years (' + STRJOIN(YRS(INVALID),', ') + ') missing from ' + FP.NAME
 ;   IF FILE_MAKE(FILES(I),DIR_IMAGE+STRTRIM(YEAR,2)+'_'+STRUPCASE(FP.NAME)+'.png',OVERWRITE=OVERWRITE) EQ 0 THEN CONTINUE ; If all of the png files exist and are "newer" than the input file and keyword "overwrite" is not set, skip to the next file
;
;    IF NONE(LONS) OR NONE(LATS) THEN BEGIN                                            ; Look for LON and LAT data in the COMMON memory                                                                 
;      LL = ARR_XY(NC.SD.LONGITUDE.IMAGE ,NC.SD.LATITUDE.IMAGE)                        ; Make 2D arrays of the 1D lon and lat data
;      LONS = LL.X                                                                     ; 2D array of LONS
;      LATS = LL.Y                                                                     ; 2D array of LATS
;    ENDIF                                     
   
;    COUNT_MAP = 0
;    IF ANY(MAP_STRUCT) THEN BEGIN                                                     ; Look for the MAP information in the COMMON memory structure
;      OK = WHERE(TAG_NAMES(MAP_STRUCT) EQ MP, COUNT_MAP)                              ; Search for the MAP
;      IF COUNT_MAP EQ 1 THEN REMAP_STRUCT = MAP_STRUCT.(OK) ELSE REMAP_STRUCT = []    ; Identify the REMAP_STRUCTURE if MAP was found
;    ENDIF ELSE MAP_STRUCT = []
    
    
;    FOR N=0, N_ELEMENTS(YEAR)-1 DO BEGIN                                              ; Loop through the years in the file
;      YR = YEAR(N)

;         PRODS_2PNG, FILES(I), MAPP='NES', PROD='CHLOR_A_0.1_30', PNGFILE=PNGFILE, BUFFER=BUFFER, OVERWRITE=OVERWRITE, /ADD_CB, CB_TYPE=3, /ADD_DB, DB_POS=DB_POS,OUTLINE_IMG=OUTLINE, OUT_COLOR=0
PRODS_2PNG, FILES(I), MAPP='NES', PROD='SST_0_30',pal='pal_blue_red', PNGFILE=PNGFILE, BUFFER=BUFFER, OVERWRITE=OVERWRITE, /ADD_CB, CB_TYPE=3, /ADD_DB, DB_POS=DB_POS,OUTLINE_IMG=OUTLINE, OUT_COLOR=0

 counter=counter+1
 if counter ge 20 then goto, done     
;      DAT = NC.SD.ABUNDANCE_1.IMAGE(*,*,N)                                            ; Get the 2D data for the specific year
;      SZ = SIZEXYZ(DAT,PX=PX,PY=PY)                                                   ; Get the dimensions of the data array
 ;     IF SZ.PX NE N_ELEMENTS(LON) AND SZ.PY NE N_ELEMENTS(LAT) THEN MESSAGE, 'ERROR: INPUT ARRAY DEMINSIONS MUST BE ' + STRTRIM(N_ELEMENTS(LON),2) + ' x ' + STRTRIM(N_ELEMENTS(LAT),2)
;MDATA = DAT
   ;   MDATA = MAPS_LONLAT_GRID(DAT, MAP_OUT=MP, METHOD='NATURALNEIGHBOR', LON=LONS, LAT=LATS, STRUCT=REMAP_STRUCT, INIT=INIT)

      ; ===> Put the REMAP_STRUCT information into the COMMON memory map structure
  ;    IF MAP_STRUCT NE [] THEN BEGIN
  ;      IF COUNT_MAP EQ 0 THEN MAP_STRUCT = CREATE_STRUCT(MAP_STRUCT,MP,REMAP_STRUCT)
  ;    ENDIF ELSE MAP_STRUCT = CREATE_STRUCT(MP,REMAP_STRUCT)

;      NR = NICE_RANGE(MDATA)                                                           ; Determine the "nice" data range for color scaling
     ; BDATA = PRODS_2BYTE(MDATA, PROD='CHLOR_.1_30'+ROUNDS(NR(1),2))                         ; Convert the data to a byte array
     ; W = WINDOW(DIMENSIONS=[PX,PY],BUFFER=BUFFER)
     ; IM = IMAGE(BDATA, RGB_TABLE=READ_PAL('PAL_DEFAULT'),MARGIN=0.005,/CURRENT)               ; Create the image
     ; TXT = TEXT(.04,.92,STRTRIM(YR,2),FONT_SIZE=16,FONT_STYLE='BOLD',FONT_COLOR='WHITE')
     ; W.SAVE, PNGFILE                                                                       ; Save the image
     ; W.CLOSE                                                                        ; Close the image
 ;   ENDFOR
    
    
    
    
  ENDFOR ; File loop
stop  
  PNGS = PNGS[SORT(PNGS)]
  MFILE = STRUPCASE(FP.NAME) + '.mp4'


  IF FILE_MAKE(PNGS,DIR_MOV+MFILE,OVERWRITE=OVERWRITE) EQ 1 THEN BEGIN
    MOVIE, PNGS, MOVIE_FILE=DIR_MOV+MFILE, FPS=2
  ENDIF
  stop
  done:
END  
  
  


