; $ID:	OCCCI_1KM_2SAVE.PRO,	2023-09-21-13,	USER-KJWH	$
  PRO OCCCI_1KM_2SAVE, DIR, DIR_OUT=DIR_OUT, MAP_OUT=MAP_OUT, DATERANGE=DATERANGE, REVERSE_FILES=REVERSE_FILES, LOGLUN=LOGLUN

;+
; NAME:
;   OCCCI_1KM_2SAVE
;
; PURPOSE:
;   Convert the 1km OCCCCI netcdf files to save
;
; CATEGORY:
;   FILE_FUNCTIONS
;
; CALLING SEQUENCE:
;   OCCCI_1KM_2SAVE
;
; REQUIRED INPUTS:
;   None
;   
; OPTIONAL INPUTS:
;   DIR............. The directory for the input files
;   DIR_OUT......... The output SAVE directory file
;   MAP_OUT......... The output map for the files
;   LOGLUN.......... The LUN for the open log file
;
; KEYWORD PARAMETERS:
;   REVERSE_FILES.... Keyword to reverse the order of the files
;
; OUTPUTS:
;   OUTPUT.......... Describe the output of this program or function
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
; Copyright (C) 2021, Department of Commerce, National Oceanic and Atmospheric Administration, National Marine Fisheries Service,
;   Northeast Fisheries Science Center, Narragansett Laboratory.
;   This software may be used, copied, or redistributed as long as it is not sold and this copyright notice is reproduced on each copy made.
;   This routine is provided AS IS without any express or implied warranties whatsoever.
;
; AUTHOR:
;   This program was written on November 10, 2021 by Kimberly J. W. Hyde, Northeast Fisheries Science Center | NOAA Fisheries | U.S. Department of Commerce, 28 Tarzwell Dr, Narragansett, RI 02882
;    
; MODIFICATION HISTORY:
;   Nov 10, 2021 - KJWH: Initial code written
;-
; ****************************************************************************************************
  ROUTINE_NAME = 'OCCCI_1KM_2SAVE'
  COMPILE_OPT IDL2
  SL = PATH_SEP()
  DASH = '-'
  
  COMMON OCCCI_1KM_2SAVE_, BINS9, BINS4, BINS2, BINS1 
  
  IF KEYWORD_SET(INIT) OR N_ELEMENTS(BINS9) EQ 0 THEN BINS9 = MAPS_L3B_BINS('L3B9')
  IF KEYWORD_SET(INIT) OR N_ELEMENTS(BINS4) EQ 0 THEN BINS4 = MAPS_L3B_BINS('L3B4')
  IF KEYWORD_SET(INIT) OR N_ELEMENTS(BINS2) EQ 0 THEN BINS2 = MAPS_L3B_BINS('L3B2')
  IF KEYWORD_SET(INIT) OR N_ELEMENTS(BINS1) EQ 0 THEN BINS1 = MAPS_L3B_BINS('L3B1')
  
  
  OC_DATES = SENSOR_DATES('OCCCI')
  DIR_LOG = !S.LOGS + ROUTINE_NAME + SL & DIR_TEST, DIR_LOG
  IF N_ELEMENTS(LOGLUN)    EQ 0 THEN LUN = [] ELSE LUN = LOGLUN
  IF N_ELEMENTS(MAP_OUT)   EQ 0 THEN MAPOUT = ['L3B2'] ELSE MAPOUT = MAP_OUT
  IF N_ELEMENTS(PRODS)     EQ 0 THEN PRODS = ['CHLOR_A-CCI'] ELSE PRODS = STRUPCASE(PRODS)  
  IF N_ELEMENTS(DATA_ONLY) EQ 0 THEN OVERWRITE = 0 
  IF N_ELEMENTS(VERSION)   EQ 0 THEN VERSION = 'VERSION_5.0' ELSE IF STRPOS(VERSION,'VERSION') EQ -1 THEN VERSION = 'VERSION_'+VERSION
  IF N_ELEMENTS(DIR)       EQ 0 THEN DIR = !S.OC + 'OCCCI' + SL + VERSION + SL + '1KM' + SL 
  
  FOR N=0, N_ELEMENTS(PRODS)-1 DO BEGIN
    PROD = PRODS[N]
    MAIN_PROD = []
    CASE PROD OF
      'CHLOR_A-CCI':   BEGIN & PRD='CHLOR_A' & ALG='CCI' & MAIN_PROD='CHLOR_A' & END
    ENDCASE
    DIR_GLOBAL = DIR + 'GLOBAL' + SL + PROD + SL

    FILES = FLS(DIR + 'NC' + SL + PROD + SL + 'M_*.nc',DATERANGE=DATERANGE)  
    FP = PARSE_IT(FILES[0],/ALL)
    IF N_ELEMENTS(DIR_OUT) EQ 0 THEN DIR_OUT = REPLACE(FP.DIR,FP.L2SUB+SL+FP.SUB+SL,'')
    DIR_SAVES = []
    FOR M=0, N_ELEMENTS(MAPOUT)-1 DO DIR_SAVES = [DIR_SAVES,REPLACE(DIR_OUT,'1KM'+SL,MAPOUT[M]+SL+'SAVE'+SL+PROD+SL)]
    DIR_TEST, [DIR_GLOBAL,DIR_SAVES]

    IF KEYWORD_SET(REVERSE_FILES) THEN FILES = REVERSE(FILES)
    FOR F=0, N_ELEMENTS(FILES)-1 DO BEGIN
      OFILE = FILES[F]        
      FN = PARSE_IT(OFILE,/ALL)
      DATES = CREATE_DATE(FN.DATE_START,FN.DATE_END)
      DATES = DATES[WHERE(DATES GE OC_DATES[0] AND DATES LE OC_DATES[1],/NULL)]
      PERIODS = 'D_' + STRMID(DATES,0,8) 
      
      D = [] & STR = []
      FOR R=0, N_ELEMENTS(PERIODS)-1 DO BEGIN
        PERIOD = PERIODS[R]
        OUTPUT_LABEL = FN.SENSOR + DASH + FN.METHOD + DASH + FN.COVERAGE 
        PROD_LABEL = PERIOD + DASH + OUTPUT_LABEL + DASH + MAPOUT + DASH + PROD
  
        SAVEFILES = DIR_SAVES + PROD_LABEL + '.SAV'
        GLOBALFILE = DIR_GLOBAL + OUTPUT_LABEL + DASH + PROD + DASH + 'GLOBAL' + '.SAV'
        IF FILE_MAKE(OFILE,[GLOBALFILE,SAVEFILES],OVERWRITE=OVERWRITE) EQ 0 THEN CONTINUE

        ; ===> Just create the GLOBAL file if missings
        IF FILE_MAKE(OFILE,SAVEFILES,OVERWRITE=OVERWRITE) EQ 0 THEN BEGIN 
          POF, NTH, FILES, OUTTXT=OUTTXT,/QUIET, LOGLUN=LUN
          PFILE, OFILE, /R, _POFTXT=OUTTXT, LOGLUN=LUN
          SD = READ_NC(OFILE,PRODS='GLOBAL')
          IF IDLTYPE(SD) EQ 'STRING' THEN BEGIN
            TXT='ERROR: Can not read '+OFILE+ '; ' + DATE_NOW()
            PLUN, LUN,TXT
            CONTINUE
          ENDIF
          GLOBAL=SD.GLOBAL
          PLUN, LUN, 'WRITING: ' + GLOBALFILE
          SAVE, GLOBAL, FILENAME=GLOBALFILE
          CONTINUE
        ENDIF ; Write out just the GLOBAL file
        
        ; ===> Read the netcdf file if not already open       
        IF D EQ [] THEN BEGIN
          POF, F, FILES, OUTTXT=OUTTXT,/QUIET, LOGLUN=LUN
          PFILE, OFILE, /R, _POFTXT=OUTTXT, LOGLUN=LUN
          D = READ_NC(OFILE)
          IF IDLTYPE(D) EQ 'STRING' THEN BEGIN
            TXT='ERROR: CAN NOT READ '+SFILE+ '; ' + DATE_NOW()
            PLUN, LOG_LUN,TXT
            CONTINUE
          ENDIF
          GLOBAL=D.GLOBAL
          IF FILE_MAKE(OFILE,GLOBALFILE,OVERWRITE=OVERWRITE) EQ 1 THEN SAVE, GLOBAL, FILENAME=GLOBALFILE
          TAGS = TAG_NAMES(D.SD)
          IMGPOS = WHERE(TAGS EQ PRD, COUNT)
          DAT = D.SD.(IMGPOS)
          IF COUNT NE 1 THEN MESSAGE, 'ERROR: ' + PRD + ' not found in ' + STRJOIN(TAGS,'; ')
                    
          LATS = D.SD.LAT.IMAGE & PY = N_ELEMENTS(LATS)
          LONS = D.SD.LON.IMAGE & PX = N_ELEMENTS(LONS)
          TIME = D.SD.TIME.IMAGE
          DATES = []
          FOR T=0, N_ELEMENTS(TIME)-1 DO DATES = [DATES,JD_2DATE(DAYS1970_2JD(TIME[T]))]
        
          ; ===> Extract 
          STR = CREATE_STRUCT('PROD',PRD,'ALG',ALG)
          IF HAS(DAT,'UNITS') THEN STR = CREATE_STRUCT(STR,'DATA_UNITS',DAT.UNITS)
          IF HAS(DAT,'UNITS_NONSTANDARD') THEN STR = CREATE_STRUCT(STR,'UNITS_NONSTANDARD',DAT.UNITS_NONSTANDARD)
          IF HAS(DAT,'LONG_NAME') THEN STR = CREATE_STRUCT(STR,'LONG_NAME',DAT.LONG_NAME)
          IF HAS(DAT,'STANDARD_NAME') THEN STR = CREATE_STRUCT(STR,'STANDARD_NAME', DAT.STANDARD_NAME)
          IF HAS(DAT,'COMMENT') THEN STR = CREATE_STRUCT(STR,'COMMENT', DAT.COMMENT)
          IF HAS(DAT,'REF') THEN STR = CREATE_STRUCT(STR,'REFERCNE', DAT.REF)
        
        ENDIF
        
        OKDATE = WHERE(PERIOD_2DATE(PERIOD) EQ DATES,COUNT)
        IF COUNT EQ 0 THEN BEGIN
          PLUN, LUN, 'ERROR: Period ' + PERIOD + ' not found in ' + OFILE, 0
          CONTINUE
        ENDIF
        
        IMG = DAT.IMAGE[*,*,OKDATE]
        
        FOR M=0, N_ELEMENTS(MAPOUT)-1 DO BEGIN
          AMAP = MAPOUT[M]
          SAVEFILE = SAVEFILES[M]
          IF FILE_MAKE(OFILE, SAVEFILE, OVERWRITE=OVERWRITE) EQ 0 THEN CONTINUE
          CASE STRUPCASE(AMAP) OF
            'L3B9': LBINS = BINS9
            'L3B4': LBINS = BINS4
            'L3B2': LBINS = BINS2
            'L3B1': LBINS = BINS1
            ELSE: MESSAGE, 'ERROR: MAP_OUT MUST BE EITHER L3B1, L3B2, L3B4 OR L3B9'
          ENDCASE
          
          LIMG = MAPS_OCCCI_LONLAT_2BIN(IMG, AMAP, MAP_IN='1KM',LATS=LATS, LONS=LONS)
          OK = WHERE(LIMG NE MISSINGS(LIMG), COUNT)
          IF COUNT GT 0 THEN BIMG = LIMG[OK]  ELSE BIMG = LIMG
          IF COUNT GT 0 THEN BINS = LBINS[OK] ELSE BINS = LBINS
          FSTR = CREATE_STRUCT('DATA',BIMG,'BINS',BINS,STR)
          NOTES   = [GLOBAL.REFERENCES,GLOBAL.INSTITUTION,GLOBAL.SOURCE]
          INFILES = OFILE
          
          STRUCT_WRITE, FSTR, FILE=SAVEFILE, GLOBAL=GLOBAL, NCFILES=INFILES, FILE_NAME=SAVEFILE, LOGLUN=LUN, PROD=PROD,$
            MAP=AMAP, METHOD=METHOD, SATELLITE='MULTI', SENSOR=SENSOR, COVERAGE='1KM', NOTES=NOTES, ROUTINE=ROUTINE_NAME, ORIGINAL_DATE_CREATED=GLOBAL.DATE_CREATED

        ENDFOR ; PERIODS
      ENDFOR ; FILES
    ENDFOR ; PRODS  
  ENDFOR ; MAPS
  


END ; ***************** End of OCCCI_1KM_2SAVE *****************
