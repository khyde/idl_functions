; $ID:	SEASCAPES_NC2SAVE.PRO,	2023-09-21-13,	USER-KJWH	$
  PRO SEASCAPES_NC2SAVE, FILES, MAPOUT=MAPOUT, SUBSETMAP=SUBSETMAP, DIR_OUT=DIR_OUT, FILE_LABEL=FILE_LABEL, LOGLUN=LOGLUN, OVEWRITE=OVERWRITE

;+
; NAME:
;   SEASCAPES_NC2SAVE
;
; PURPOSE:
;   Create individual .SAV files from the downloaded bulk .nc files
;
; CATEGORY:
;   SEASCAPES_FUNCTIONS
;
; CALLING SEQUENCE:
;   SEASCAPES_NC2SAVE,$Parameter1$, $Parameter2$, $Keyword=Keyword$, ....
;
; REQUIRED INPUTS:
;   FILES........ An array of .nc files
;
; OPTIONAL INPUTS:
;   MAPOUT....... The name of the output map (default='L3B5')
;   SUBSETMAP.... The name of the map to subset the data (e.g. 'NWA')
;   DIR_OUT........ The location of the output directory
;   FILE_LABEL..... The label in the output file
;   LOGLUN......... The lun for the log file
;
; KEYWORD PARAMETERS:
;   OVERWRITE.... Keyword to overwrite existing output files 
;
; OUTPUTS:
;   Individual .SAV files of the SEACAPES data
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
;   
; COPYRIGHT: 
; Copyright (C) 2022, Department of Commerce, National Oceanic and Atmospheric Administration, National Marine Fisheries Service,
;   Northeast Fisheries Science Center, Narragansett Laboratory.
;   This software may be used, copied, or redistributed as long as it is not sold and this copyright notice is reproduced on each copy made.
;   This routine is provided AS IS without any express or implied warranties whatsoever.
;
; AUTHOR:
;   This program was written on April 08, 2022 by Kimberly J. W. Hyde, Northeast Fisheries Science Center | NOAA Fisheries | U.S. Department of Commerce, 28 Tarzwell Dr, Narragansett, RI 02882
;    
; MODIFICATION HISTORY:
;   Apr 08, 2022 - KJWH: Initial code written
;   Nov 16, 2022 - KJWH: Removed the MOBINS step because the outputs do not appear to be used
;-
; ****************************************************************************************************
  ROUTINE_NAME = 'SEASCAPES_NC2SAVE'
  COMPILE_OPT IDL2
  SL = PATH_SEP()

  ; ===> Set up defaults for optional inputs and keywords
  IF N_ELEMENTS(L3BMAP)     NE 1 THEN L3BMAP = 'L3B5'
  IF N_ELEMENTS(LOGLUN)     NE 1 THEN LUN = [] ELSE LUN = LOGLUN                                                                ; Set up the LUN to record in the log file
  IF N_ELEMENTS(NCPRODS)    EQ 0 THEN NCPRODS = ['CLASS','P']
  
  ; ===> Get general information from the file names
  IF N_ELEMENTS(FILES) EQ 0 THEN MESSAGE, 'ERROR: Input files are required.'
  
  FOR F=0, N_ELEMENTS(FILES)-1 DO BEGIN
    AFILE = FILES[F]
    FP = PARSE_IT(AFILE,/ALL)                                                                                                     ; Parse the file names
    IF SAME(FP.EXT) EQ 0 THEN MESSAGE, 'All input files must have the same EXTENSION'                                             ; Make sure all files have the same extension
    NAME = FP[0].NAME
    IF N_ELEMENTS(FILE_LABEL) NE 1 THEN _FILE_LABEL=FILE_LABEL_MAKE(FILES[0]) ELSE _FILE_LABEL=FILE_LABEL                         ; Create the file label

    ; ===> Get additional file information
    INFOTAGS = ['SENSOR','SATELLITE','METHOD']
    OK = WHERE_MATCH(TAG_NAMES(FP),INFOTAGS,COUNT)
    IF COUNT GT 0 THEN INFO = STRUCT_COPY(FP,OK) ELSE MESSAGE, 'ERROR: Information not found in the file name'   ; Copy the "metadata" to a separate structure
    INFO = CREATE_STRUCT(INFO,'MAP','L3B5','ROUTINE',ROUTINE_NAME)
    
    ; ===> Get D3_PROD specific information
    D3PROD = []
    FOR D=0, N_ELEMENTS(NCPRODS)-1 DO BEGIN
      NPROD = NCPRODS[D]
      CASE NPROD OF
        'CLASS': PROD_NAME = 'WATER_CLASS'
        'P':     PROD_NAME = 'WATER_PROB'
      ENDCASE
      D3PROD = [D3PROD,PROD_NAME]
      CR = STRSPLIT(VALIDS('PROD_CRITERIA',PROD_NAME),'_',/EXTRACT)
      DSTR = CREATE_STRUCT('PROD',PROD_NAME,'ALG',FP[0].ALG,'UNITS',UNITS(NPROD,/SI),'VALID_MIN',CR[0],'VALID_MAX',CR[1])
      INFO = CREATE_STRUCT(INFO,PROD_NAME,DSTR)
    ENDFOR
    
    ; ===> Get PERIOD and DATERANGE information
    IF ~SAME(FP.PERIOD_CODE) THEN MESSAGE, 'All input files are not from the same PERIOD'                                         ; Make sure all files have the same period_code
    S = SORT(DATE_2JD(PERIOD_2DATE(FP.PERIOD))) & FP = FP[S] & FILES = FILES[S]                                                   ; Make sure files & fp in ascending order
    MTIMES = GET_MTIME(FILES)
    PERIOD_CODE = FP[0].PERIOD_CODE                                                                                               ; Period code for the files
    PERSTR = PERIOD_2STRUCT(FP.PERIOD)
    DATE_RANGE = [STRMID(MIN(PERSTR.DATE_START),0,8), STRMID(MAX(PERSTR.DATE_END),0,8)]

    ; ===> Get the input map info and map size
    AMAP = FP[0].MAP                                                                                                             ; Map name
    MS = MAPS_SIZE(AMAP, PX=PX, PY=PY)                                                                                           ; Get the size of the map
    
    ; ===> Set up the output directory
    IF N_ELEMENTS(DIR_OUT) NE 1 THEN DIR_OUT = REPLACE(FP.DIR,'NC','SAVE'+SL+'WATER_CLASSIFICATION-MBON')
    IF ~HAS(DIR_OUT,AMAP) THEN MESSAGE, 'ERROR: Check the output directory MAP information'                                         ; Check the output directory is correct
    DIR_TEST, DIR_OUT

    D = READ_NC(AFILE)
    LL = ARR_XY(D.SD.LON.IMAGE,D.SD.LAT.IMAGE,XOUT=LONS,YOUT=LATS)
    
    PERIODS = 'D8_' + STRMID(JD_2DATE(SECONDS1970_2JD(D.SD.TIME.IMAGE)),0,8) + '_' + STRMID(JD_2DATE(JD_ADD(SECONDS1970_2JD(D.SD.TIME.IMAGE),7,/DAY)),0,8)
    FOR R=0, N_ELEMENTS(PERIODS)-1 DO BEGIN
      APER = PERIODS[R]
      OFILE = DIR_OUT + APER + '-' + _FILE_LABEL + '.SAV'
      IF ~FILE_MAKE(AFILE,OFILE,OVERWRITE=OVERWRITE) THEN CONTINUE
      
      CLASS = REFORM(D.SD.CLASS.IMAGE[*,*,R])
      
      MCLASS = MAPS_NOAA5KM_2BIN(CLASS,'L3B5',LONS=LONS,LATS=LATS)
  STOP    
      MLL = MAPS_LONLAT_GRID(CLASS, LON=LONS, LAT=LATS, MAP_OUT='NWA', STRUCT=LONLAT_STRUCT, INIT=INIT, DO_MASK=DO_MASK)
      BINS = MAPS_L3B_LONLAT_2BIN(AMAP, LONS, LATS)
STOP
      
      
      CLASS = MAPS_REMAP(REFORM(D.SD.CLASS.IMAGE[R,*,*]),MAP_IN='LONLAT',MAP_OUT=AMAP, CONTROL_LONS=LONS,CONTROL_LATS=LATS)
      PROB  = REFORM(D.SD.P.IMAGE[R,*,*])
      
      
  STOP    
      STRUCT_WRITE, CLASS, PROBABILITY=PROB, FILE=OFILE, UNITS='None', NCFILES=AFILE, GLOBAL=D.GLOBAL, MAP=AMAP, SATELLITE='MULTI', SENSOR='SEASCAPES', COVERAGE='5KM', PROD='WATER_CLASSIFICATION',$
        FILE_NAME=OFILE, LOCLUN=LUN, NOTES=D.SD.CLASS.COMMENT, FLAG_MEANINGS=D.SD.CLASS.FLAG_MEANINGS, FLAG_VALUES=D.SD.CLASS.FLAG_VALUES, ROUTINE=ROUTINE_NAME, ORIGINAL_DATE_CREATED=GLOBAL.DATE_CREATED
      
    ENDFOR

STOP
  ENDFOR ; FILES

END ; ***************** End of SEASCAPES_NC2SAVE *****************
