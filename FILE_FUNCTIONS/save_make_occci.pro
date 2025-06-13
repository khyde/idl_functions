; $ID:	SAVE_MAKE_OCCCI.PRO,	2023-09-21-13,	USER-KJWH	$
 
PRO SAVE_MAKE_OCCCI, DIR, PRODS=PRODS, DIR_OUT=DIR_OUT, MAPS_OUT=MAPS_OUT, REFRESH=REFRESH, DATERANGE=DATERANGE, LOGLUN=LOGLUN, $
                     REVERSE_FILES=REVERSE_FILES, ANALYSIS_ERROR=ANALYSIS_ERROR, DATA_ONLY=DATA_ONLY, STRUCT=STRUCT,  OVERWRITE=OVERWRITE 
 
;+
; NAME:
;   SAVE_MAKE_OCCCI
; 
; PURPOSE: 
;   Program that will read in the OCCCI netcdf files from ESA and create mapped save files
; 
; CATEGORY: 
;   FILES
; 
; CALLING SEQUENCE:
;   SAVE_MAKE_OCCCI
; 
; REQUIRED INPUTS:
;   None
;   
; OPTIONAL INPUTS: 
;   DIR............. Location of the input directory  
;   PRODS........... Product names 
;   DIR_OUT......... Directory to store save files of the final output data/image
;   MAPS_OUT........ Array of maps to produce from the OCCCI files
;   DATERANGE....... Specify the date range of the input files
;   LOGLUN.......... If provided, the LUN for the log file
;   
; KEYWORD PARAMETERS:  
;   REFRESH......... Refresh the MAPS_REMAP common memory
;   ANALYSIS_ERROR.. Include the analysis error data in the saved structure
;   DATA_ONLY....... Return the data structure without saving the file
;   REVERSE_FILES... Reverse the order of the files for processing
;   OVERWRITE....... Overwrite file if it exists
;   
; OUTPUTS:
;   .SAV files for each of the requested products (and maps)  
;   
; OPTIONAL OUTPUTS
;   STRUCT.......... Name of the output structure  
; 
; COMMON BLOCKS:
;   None
;
; SIDE EFFECTS:
;   None
;
; RESTRICTIONS:
;   This program may need to be updated with default information if changes are made to the algorithm functions  
;   
; EXAMPLE CALLS:
;   SAVE_MAKE_OCCCI
;   SAVE_MAKE_OCCCI, DIR
;   SAVE_MAKE_OCCCI, DIR, PRODS=['CHL','RRS']
;   SAVE_MAKE_OCCCI, DIR, PRODS=['CHL','RRS'], MAPS_OUT=['L3B4','NEC']
;   SAVE_MAKE_OCCCI, DIR, PRODS=['CHL','RRS'], MAPS_OUT=['L3B4','NEC'], /REFRESH
;   SAVE_MAKE_OCCCI, DIR, PRODS=['CHL','RRS'], MAPS_OUT=['L3B4','NEC'], /REFRESH, DATE_RANGE=['2010','2013']
;   SAVE_MAKE_OCCCI, DIR, PRODS=['CHL','RRS'], MAPS_OUT=['L3B4','NEC'], /REFRESH, DATE_RANGE=['2010','2013'], /DATA_ONLY, STRUCT=OUT_STRUCT
;   SAVE_MAKE_OCCCI, DIR, PRODS=['CHL','RRS'], MAPS_OUT=['L3B4','NEC'], /REFRESH, DATE_RANGE=['2010','2013'], /ANALYSIS_ERROR
;   SAVE_MAKE_OCCCI, DIR, PRODS=['CHL','RRS'], MAPS_OUT=['L3B4','NEC'], /REFRESH, DATE_RANGE=['2010','2013'], /REVERSE_FILES
;   SAVE_MAKE_OCCCI, DIR, PRODS=['CHL','RRS'], MAPS_OUT=['L3B4','NEC'], /REFRESH, DATE_RANGE=['2010','2013'], /REVERSE_FILES, /OVERWRITE
;
; NOTES:
; 
; COPYRIGHT:
; Copyright (C) 2018, Department of Commerce, National Oceanic and Atmospheric Administration, National Marine Fisheries Service,
;   Northeast Fisheries Science Center, Narragansett Laboratory.
;   This software may be used, copied, or redistributed as long as it is not sold and this copyright notice is reproduced on each copy made.
;   This routine is provided AS IS without any express or implied warranties whatsoever.
;
; AUTHOR:
;   This program was written on August 14, 2018 by Kimberly J. W. HydeNortheast Fisheries Science Center | NOAA Fisheries | U.S. Department of Commerce, 28 Tarzwell Dr, Narragansett, RI 02882
;   
; MODIFICATION HISTORY:
;   Aug 14, 2018 - KJWH: Wrote initial code (adapted from SAVE_MAKE_GHRSS)
;   Jul 22, 2019 - KJWH: Added LOGLUN keyword, changed PRINT to PLUN, LOG_LUN, and added LOGLUN to POF, PFILE commands
;                        Added DATERANGE to the file search and now exiting if no files are found
;   Aug 14, 2020 - KJWH: Added COMPILE_OPT IDL
;                        Changed subscript () to []
;                        Changed the chlorophyll algorithm from OCI to CCI   
;   Sep 04, 2020 - KJWH: Changed the IOP algorithm to QAA    
;   Nov 09, 2022 - KJWH: Changed the base directory from !S.OC to !S.OCCCI
;                        Replaced some shortcut functions with the IDL version (e.g. KEY() is not KEYWORD_SET())                 
;-                        
;**********************************************************
  ROUTINE_NAME = 'SAVE_MAKE_OCCCI'
  COMPILE_OPT IDL2
  
  DASH=DELIMITER(/DASH)
  SL=PATH_SEP()
  
  DIR_LOG = !S.LOGS + ROUTINE_NAME + SL & DIR_TEST, DIR_LOG
  IF ~N_ELEMENTS(LOGLUN)    THEN LOG_LUN = [] ELSE LOG_LUN = LOGLUN
  IF ~N_ELEMENTS(DIR)       THEN DIR = !S.OCCCI + 'SIN' + SL + 'NC' + SL 
  IF ~N_ELEMENTS(MAPS_OUT)  THEN MAPS = 'L3B4' ELSE MAPS = MAPS_OUT    
  IF ~N_ELEMENTS(PRODS)     THEN PRODS = ['CHLOR_A-CCI','RRS'] ELSE PRODS = STRUPCASE(PRODS)  ; 'IOP','KD490'
  IF KEYWORD_SET(DATA_ONLY) THEN OVERWRITE = 1 ; Make OVERWRITE 1 so that the data extraction is not skipped if the file already exists
    
  SZ = MAPS_SIZE('L3B4',PX=PX,PY=PY)  
  L3B4_BINS = MAPS_L3B_BINS('L3B4')
    
  FOR N=0, N_ELEMENTS(PRODS)-1 DO BEGIN
    IF KEYWORD_SET(ANALYSIS_ERROR) THEN AN_ERR = 1 ELSE AN_ERR = 0
    PROD = PRODS[N]
    MAIN_PROD = []
    CASE PROD OF
      'CHLOR_A-CCI':   BEGIN & DPROD='CHL'   & VPRODS = 'CHLOR_A-CCI' & AN_ERR=1 & MAIN_PROD='CHLOR_A' & END
      'RRS':           BEGIN & DPROD='RRS'   & VPRODS = ['RRS_412','RRS_443','RRS_490','RRS_510','RRS_560','RRS_665'] & END
      'KD_490-ZHANG':  BEGIN & DPROD='KD490' & VPRODS = 'KD_490-ZHANG' & AN_ERR=1 & MAIN_PROD='KD_490' & END
      'ADG-QAA':       BEGIN & DPROD='IOP'   & VPRODS = ['ADG_412', 'ADG_443', 'ADG_490', 'ADG_510', 'ADG_560', 'ADG_665'] +'-QAA' & AN_ERR=1 & END
      'APH-QAA':       BEGIN & DPROD='IOP'   & VPRODS = ['APH_412', 'APH_443', 'APH_490', 'APH_510', 'APH_560', 'APH_665'] +'-QAA' & AN_ERR=1 & END
      'ATOT-QAA':      BEGIN & DPROD='IOP'   & VPRODS = ['ATOT_412','ATOT_443','ATOT_490','ATOT_510','ATOT_560','ATOT_665']+'-QAA' & END
      'BBP-QAA':       BEGIN & DPROD='IOP'   & VPRODS = ['BBP_412', 'BBP_443', 'BBP_490', 'BBP_510', 'BBP_560', 'BBP_665'] +'-QAA' & END
    ENDCASE
    
    IF KEYWORD_SET(AN_ERR) THEN BEGIN
      V = [] 
      FOR I=0, N_ELEMENTS(VPRODS)-1 DO BEGIN
        STR = STR_BREAK(VPRODS[I],'-')
        VP = STR[0]+'_'+['BIAS','RMSD']
        IF N_ELEMENTS(STR) GT 1 THEN VP = VP + '-' + STR[1] ; Add ALG back to the name
        V = [V, VP]
      ENDFOR
      VPRODS = SORTED([VPRODS,V])
    ENDIF
    
    PDIR = DIR + DPROD + SL
    FILES = FLS(PDIR + 'E*.*',DATERANGE=DATERANGE)
    IF FILES EQ [] THEN BEGIN
      PLUN, LUN, 'ERROR: No files found for DATERANGE = ' + STRJOIN(DATERANGE, ' - ')
      GOTO, DONE
    ENDIF
    FP = PARSE_IT(FILES[0],/ALL)
    IF NONE(DIR_OUT) THEN DIR_OUT = REPLACE(FP.DIR,FP.SUB+SL,'')
    DIRS_SAVE = []
    FOR M=0, N_ELEMENTS(MAPS)-1 DO DIRS_SAVE = [DIRS_SAVE,DIR_OUT + MAPS[M] + SL + 'SAVE' + SL + PROD + SL]
    DIR_GLOBAL = DIR_OUT + 'GLOBAL' + SL + PROD + SL
    DIR_TEST, [DIR_GLOBAL,DIRS_SAVE]
    
    IF KEYWORD_SET(REVERSE_FILES) THEN FILES = REVERSE(FILES)

    FOR NTH = 0L, N_ELEMENTS(FILES)-1 DO BEGIN
      OFILE = FILES[NTH]
      FP = FILE_PARSE(OFILE)
      SI = SENSOR_INFO(OFILE)
      NPRODS = STRSPLIT(SI.NC_PROD,SI.DELIM,/EXTRACT)
      OPRODS = STRSPLIT(SI.PRODS,SI.DELIM,/EXTRACT)
      OK = WHERE_MATCH(OPRODS, VPRODS, VALID=VALID,COUNT)
      IF COUNT EQ 0 THEN MESSAGE, 'ERROR: ' + VPROD + ' not found in file.'
      NPRODS = NPRODS[OK]
      VPRODS = VPRODS[VALID]
      OUTPUT_LABEL = SI.PERIOD + DASH + SI.SENSOR + DASH + SI.METHOD + DASH + SI.COVERAGE + DASH + MAPS + DASH + PROD
      SAVEFILES = DIRS_SAVE + OUTPUT_LABEL + '.SAV'
      GLOBALFILE = DIR_GLOBAL + SI.PERIOD + DASH + SI.SENSOR + DASH + SI.METHOD + DASH + SI.COVERAGE + DASH + 'GLOBAL' + '.SAV'
  
      IF FILE_MAKE(OFILE,[GLOBALFILE,SAVEFILES],OVERWRITE=OVERWRITE) EQ 0 THEN CONTINUE
      
      IF FILE_MAKE(OFILE,SAVEFILES,OVERWRITE=OVERWRITE) EQ 0 THEN BEGIN ; Just missing the GLOBAL file
        POF, NTH, FILES, OUTTXT=OUTTXT,/QUIET, LOGLUN=LOG_LUN
        PFILE, OFILE, /R, _POFTXT=OUTTXT, LOGLUN=LOG_LUN
        SD = READ_NC(OFILE,PRODS='GLOBAL')
        IF IDLTYPE(SD) EQ 'STRING' THEN BEGIN
          TXT='ERROR: CAN NOT READ '+OFILE+ '; ' + DATE_NOW()         
          PLUN, LOG_LUN,TXT
          CONTINUE
        ENDIF
        GLOBAL=SD.GLOBAL
        PLUN, LOG_LUN, 'WRITING: ' + GLOBALFILE
        SAVE, GLOBAL, FILENAME=GLOBALFILE
        CONTINUE
      ENDIF
  
; ===> READ THE NETCDF FILE
      POF, NTH, FILES, OUTTXT=OUTTXT,/QUIET, LOGLUN=LOG_LUN
      PFILE, OFILE, /R, _POFTXT=OUTTXT, LOGLUN=LOG_LUN
      SD = READ_NC(OFILE,PRODS=['GLOBAL',NPRODS])
      IF IDLTYPE(SD) EQ 'STRING' THEN BEGIN
        TXT='ERROR: CAN NOT READ '+SFILE+ '; ' + DATE_NOW()
        PLUN, LOG_LUN,TXT
        CONTINUE
      ENDIF
      GLOBAL=SD.GLOBAL
      IF FILE_MAKE(SFILE,GLOBALFILE,OVERWRITE=OVERWRITE) EQ 1 THEN SAVE, GLOBAL, FILENAME=GLOBALFILE
      
      TAGS = TAG_NAMES(SD.SD)
      STR = []
      FOR T=0, N_ELEMENTS(TAGS)-1 DO BEGIN
        DAT = SD.SD.(T)
        TAG = TAGS[T]
        STAG = VPRODS[WHERE(STRUPCASE(NPRODS) EQ TAG,/NULL)]
        IF STAG EQ [] THEN CONTINUE
        BRK = STR_BREAK(STAG,'-')
        PRD = BRK[0]
        IF N_ELEMENTS(BRK) GT 1 THEN ALG = BRK[1] ELSE ALG = ''
        IF MAIN_PROD NE [] AND TAG EQ MAIN_PROD THEN BEGIN
          NBINS = N_ELEMENTS(DAT.IMAGE)
          IF NBINS NE PY THEN MESSAGE, 'ERROR: NUMBER OF BINS DOES NOT MATCH THE L3B4 DIMENSIONS'
          IMG = DAT.IMAGE
          OK_GOOD = WHERE(IMG NE DAT._FILLVALUE[0] AND IMG NE MISSINGS(IMG),COUNT_GOOD)
          IF COUNT_GOOD GT 0 THEN BEGIN
            IMG = IMG[OK_GOOD]
            BINS = L3B4_BINS[OK_GOOD]
          ENDIF ELSE BEGIN
            IMG = REFORM(IMG,1,NBINS)
            BINS = L3B4_BINS
          ENDELSE  
          STR = CREATE_STRUCT('DATA',IMG,'PROD',PRD,'ALG',ALG,'BINS',BINS)
          IF HAS(DAT,'UNITS') THEN STR = CREATE_STRUCT(STR,'DATA_UNITS',DAT.UNITS)
          IF HAS(DAT,'UNITS_NONSTANDARD') THEN STR = CREATE_STRUCT(STR,'UNITS_NONSTANDARD',DAT.UNITS_NONSTANDARD)
          IF HAS(DAT,'LONG_NAME') THEN STR = CREATE_STRUCT(STR,'LONG_NAME',DAT.LONG_NAME)
          IF HAS(DAT,'STANDARD_NAME') THEN STR = CREATE_STRUCT(STR,'STANDARD_NAME', DAT.STANDARD_NAME) 
          IF HAS(DAT,'COMMENT') THEN STR = CREATE_STRUCT(STR,'COMMENT', DAT.COMMENT)
          IF HAS(DAT,'REF') THEN STR = CREATE_STRUCT(STR,'REFERCNE', DAT.REF)
        ENDIF ELSE BEGIN
          IMG = DAT.IMAGE
          OK_GOOD = WHERE(IMG NE DAT._FILLVALUE[0] AND IMG NE MISSINGS(IMG),COUNT_GOOD)
          IF COUNT_GOOD GT 0 THEN BEGIN
            IMG = IMG[OK_GOOD]
            BINS = L3B4_BINS[OK_GOOD]
          ENDIF ELSE BINS = L3B4_BINS
          
          BRK = STR_BREAK(STAG,'-')
          PRD = BRK[0]
          IF N_ELEMENTS(BRK) GT 1 THEN ALG = BRK[1] ELSE ALG = ''
          DTAGS = ['REL','COMMENT','REF','LONG_NAME','STANDARD_NAME','UNITS','UNITS_NONSTANDARD']
          OKTAGS = WHERE_MATCH(DTAGS,TAG_NAMES(DAT),COUNTTAGS)
          DTAGS = DTAGS[OKTAGS]
          DAT = CREATE_STRUCT('IMAGE',IMG,'PROD',PRD,'ALG',ALG,'BINS',BINS,STRUCT_COPY(DAT,DTAGS))
          STR = CREATE_STRUCT(STR,BRK[0],DAT)
        ENDELSE
      ENDFOR ; tags
      
      NOTES   = [GLOBAL.REFERENCES,GLOBAL.INSTITUTION] & IF HAS(GLOBAL,'SOURCE') THEN NOTES = [NOTES,GLOBAL.SOURCE]
      INFILES = OFILE
      GONE, SD 
          
       
      FOR MTH=0, N_ELEMENTS(MAPS)-1 DO BEGIN
        IF FILE_MAKE(SFILE,SAVEFILES[MTH],OVERWRITE=OVERWRITE) EQ 0 THEN CONTINUE
        AMAP = MAPS[MTH]
        
        IF AMAP NE 'L3B4' THEN STR = STRUCT_REMAP(STR, MAP_OUT=AMAP, INIT=INIT)
        
        IF KEYWORD_SET(DATA_ONLY) THEN RETURN_STRUCT = 1 ELSE RETURN_STRUCT = 0
        STRUCT_WRITE, STR, FILE=SAVEFILES[MTH], RETURN_STRUCT=RETURN_STRUCT, GLOBAL=GLOBAL, NCFILES=INFILES, FILE_NAME=SAVEFILE, LOGLUN=LOG_LUN, PROD=PROD,$
          MAP=AMAP, METHOD=METHOD, SATELLITE='MULTI', SENSOR=SENSOR, COVERAGE='4KM', NOTES=NOTES, ROUTINE=ROUTINE_NAME, ORIGINAL_DATE_CREATED=GLOBAL.DATE_CREATED
         
        STRUCT = RETURN_STRUCT ; Output structure
  
      ENDFOR ; MAPS
    ENDFOR ; PRODS 
  ENDFOR ; FILES    

  DONE:
END



