; $ID:	SAVE_MAKE_GLOBCOLOUR.PRO,	2023-09-21-13,	USER-KJWH	$
 
PRO SAVE_MAKE_GLOBCOLOUR, DIR, PRODS=PRODS, DIR_OUT=DIR_OUT, MAPS_OUT=MAPS_OUT, REFRESH=REFRESH, DATERANGE=DATERANGE,  $
                      REVERSE_FILES=REVERSE_FILES,ANALYSIS_ERROR=ANALYSIS_ERROR, DATA_ONLY=DATA_ONLY, STRUCT=STRUCT,  OVERWRITE=OVERWRITE 

;+
; NAME:
;   SAVE_MAKE_GLOBCOLOUR
;   
; PURPOSE: 
;   Read in GLOBCOLOUR files from ESA and create mapped save files
; 
; REQUIRED INPUTS:
;   None 
;   
; OPTIONAL INPUTS: 
;   DIR............. Location of the input directory
;   PRODS........... Product names 
;   DIR_OUT......... Directory to store save files of the final output data/image
;   MAPS_OUT........ Array of maps to produce from the GLOBCOLOUR files
;   REFRESH......... Refresh the MAP_REMAP common memory
;   DATERANGE....... Specify the date range of the input files
;   LOGLUN.......... If provided, the LUN for the log file
;
; KEYWORD PARAMTERS
;   REFRESH......... Refresh the MAPS_REMAP common memory
;   ANALYSIS_ERROR.. Include the analysis error data in the saved structure
;   DATA_ONLY....... Return the data structure without saving the file
;   REVERSE_FILES... Reverse the order of the files for processing
;   OVERWRITE....... Overwrite file if it exists
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
;   
; EXAMPLE CALLS:
;   1) SAVE_MAKE_GLOBCOLOUR
;   2) SAVE_MAKE_GLOBCOLOUR, DIR
;   3) SAVE_MAKE_GLOBCOLOUR, DIR, PRODS=['CHL','RRS']
;   4) SAVE_MAKE_GLOBCOLOUR, DIR, PRODS=['CHL','RRS'], MAPS_OUT=['L3B4','NEC']
;   5) SAVE_MAKE_GLOBCOLOUR, DIR, PRODS=['CHL','RRS'], MAPS_OUT=['L3B4','NEC'], /REFRESH
;   6) SAVE_MAKE_GLOBCOLOUR, DIR, PRODS=['CHL','RRS'], MAPS_OUT=['L3B4','NEC'], /REFRESH, DATE_RANGE=['2010','2013']
;   7) SAVE_MAKE_GLOBCOLOUR, DIR, PRODS=['CHL','RRS'], MAPS_OUT=['L3B4','NEC'], /REFRESH, DATE_RANGE=['2010','2013'], /DATA_ONLY, STRUCT=OUT_STRUCT
;   8) SAVE_MAKE_GLOBCOLOUR, DIR, PRODS=['CHL','RRS'], MAPS_OUT=['L3B4','NEC'], /REFRESH, DATE_RANGE=['2010','2013'], /ANALYSIS_ERROR
;   9) SAVE_MAKE_GLOBCOLOUR, DIR, PRODS=['CHL','RRS'], MAPS_OUT=['L3B4','NEC'], /REFRESH, DATE_RANGE=['2010','2013'], /REVERSE_FILES
;   10) SAVE_MAKE_GLOBCOLOUR, DIR, PRODS=['CHL','RRS'], MAPS_OUT=['L3B4','NEC'], /REFRESH, DATE_RANGE=['2010','2013'], /REVERSE_FILES, /OVERWRITE
;
; NOTES:
; Copyright (C) 2018, Department of Commerce, National Oceanic and Atmospheric Administration, National Marine Fisheries Service,
;   Northeast Fisheries Science Center, Narragansett Laboratory.
;   This software may be used, copied, or redistributed as long as it is not sold and this copyright notice is reproduced on each copy made.
;   This routine is provided AS IS without any express or implied warranties whatsoever.
;
;   This program was written by John E. O'Reilly, DOC/NOAA/NMFS/NEFSC Narragansett, RI
;          with assistance from Kimberly Hyde, DOC/NOAA/NMFS/NEFSC Narragansett, RI, kimberly.hyde@noaa.gov.
;   For questions about the code, contact kimberly.hyde@noaa.gov
;
; AUTHOR:
;   This program was written on October 15, 2018 by Kimberly J. W. HydeNortheast Fisheries Science Center | NOAA Fisheries | U.S. Department of Commerce, 28 Tarzwell Dr, Narragansett, RI 02882
;
; MODIFICATION HISTORY:
;   Oct 15, 2018 - KJWH: Initial code written 
;   Oct 16, 2018 - KJWH: Adapted from SAVE_MAKE_OCCCI
;   Jan 10, 2022 - KJWH: Changed HERMES to GLOBCOLOUR 
;                        Added information to extract the PAR product  
;                  
;-                        
;****************************************
  ROUTINE_NAME = 'SAVE_MAKE_GLOBCOLOUR'
  COMPILE_OPT IDL2

  DASH=DELIMITER(/DASH)
  SL=PATH_SEP()
  
  DIR_LOG = !S.LOGS + ROUTINE_NAME + SL & DIR_TEST, DIR_LOG
  
  IF NONE(DIR)      THEN DIR = !S.OC + 'GLOBCOLOUR' + SL + 'L3' + SL + 'NC' + SL 
  IF NONE(MAPS_OUT) THEN MAPS = 'L3B4' ELSE MAPS = MAPS_OUT    
  IF NONE(PRODS)    THEN PRODS = ['CHLOR_A-GSM','CHLOR_A-AV','PAR'] ELSE PRODS = STRUPCASE(PRODS)  ; 'IOP','KD490'
  IF KEY(DATA_ONLY) THEN OVERWRITE = 1 ; Make OVERWRITE 1 so that the data extraction is not skipped if the file already exists
    
  SZ = MAPS_SIZE('L3B4',PX=PX,PY=PY)  
  L3B4_BINS = MAPS_L3B_BINS('L3B4')
    
  FOR N=0, N_ELEMENTS(PRODS)-1 DO BEGIN
    IF KEY(ANALYSIS_ERROR) THEN AN_ERR = 1 ELSE AN_ERR = 0
    PROD = PRODS[N]
    MAIN_PROD = []
    CASE PROD OF
      'CHLOR_A-GSM':   BEGIN & DPROD='CHL1'     & VPRODS = 'CHLOR_A-GSM' & AN_ERR=1 & MAIN_PROD='CHLOR_A' & END
      'CHLOR_A-AV':    BEGIN & DPROD='CHL1_AV'  & VPRODS = 'CHLOR_A-AV'  & AN_ERR=1 & MAIN_PROD='CHLOR_A' & END
      'PAR':           BEGIN & DPROD='PAR'      & VPRODS = 'PAR'         & AN_ERR=0 & MAIN_PROD='PAR'     & END
      'PIC':           BEGIN & DPROD='PIC'      & VPRODS = 'PIC'         & AN_ERR=0 & MAIN_PROD='PIC'     & END
      'POC':           BEGIN & DPROD='POC'      & VPRODS = 'POC'         & AN_ERR=0 & MAIN_PROD='POC'     & END
     ; 'A_CDOM_443-QAA':BEGIN & DPROD='IOP'   & VPRODS = ['A_CDOM_443-QAA','APH_443-QAA'] & MAIN_PROD='ADG_443' & END
     ; 'KD_490-ZHANG':  BEGIN & DPROD='KD490' & VPRODS = 'KD_490-ZHANG' & AN_ERR=1 & MAIN_PROD='KD_490' & END
    ENDCASE
    
    IF KEY(AN_ERR) THEN BEGIN
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
    FILES = FLS(PDIR + 'L3b*.nc',DATERANGE=DATERANGE,COUNT=COUNTF)
    IF COUNTF EQ 0 THEN CONTINUE
    FP = PARSE_IT(FILES[0],/ALL)
    IF NONE(DIR_OUT) THEN DIR_OUT = REPLACE(FP.DIR,FP.SUB+SL,'')
    DIRS_SAVE = []
    FOR M=0, N_ELEMENTS(MAPS)-1 DO DIRS_SAVE = [DIRS_SAVE,DIR_OUT + MAPS[M] + SL + 'SAVE' + SL + PROD + SL]
    DIR_GLOBAL = DIR_OUT + 'GLOBAL' + SL + PROD + SL
    DIR_TEST, [DIR_GLOBAL,DIRS_SAVE]
    
    IF KEY(REVERSE_FILES) THEN FILES = REVERSE(FILES)
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
        POF, NTH, FILES, OUTTXT=OUTTXT,/QUIET
        PFILE, OFILE, /R, _POFTXT=OUTTXT
        SD = READ_NC(OFILE,PRODS='GLOBAL')
        IF IDLTYPE(SD) EQ 'STRING' THEN BEGIN
          TXT='ERROR: CAN NOT READ '+OFILE+ '; ' + DATE_NOW()
          REPORT,TXT,DIR=DIR_LOG
          PRINT,TXT
          CONTINUE
        ENDIF
        GLOBAL=SD.GLOBAL
        PRINT, 'WRITING: ' + GLOBALFILE
        SAVE, GLOBAL, FILENAME=GLOBALFILE
        CONTINUE
      ENDIF
  
; ===> Read the netcdf file
      POF, NTH, FILES, OUTTXT=OUTTXT,/QUIET
      PFILE, OFILE, /R, _POFTXT=OUTTXT
      D = READ_NC(OFILE,PRODS=['GLOBAL',NPRODS,'ROW','COL','CENTER_LAT','CENTER_LON','LON_STEP'])
      IF IDLTYPE(D) EQ 'STRING' THEN BEGIN
        TXT='ERROR: CAN NOT READ '+SFILE+ '; ' + DATE_NOW()
        REPORT,TXT,DIR=DIR_LOG
        PRINT,TXT
        CONTINUE
      ENDIF
      SD = D.SD
      GLOBAL=D.GLOBAL
      IF FILE_MAKE(SFILE,GLOBALFILE,OVERWRITE=OVERWRITE) EQ 1 THEN SAVE, GLOBAL, FILENAME=GLOBALFILE

; ===> Get the LON/LAT data for the valid pixels         
      ROW = SD.ROW.IMAGE
      INDEX = ROW - GLOBAL.FIRST_ROW
      LAT = SD.CENTER_LAT.IMAGE[INDEX]
      LON = SD.CENTER_LON.IMAGE[INDEX]+SD.COL.IMAGE*SD.LON_STEP.IMAGE[INDEX]
      BLK = FINDGEN(N_ELEMENTS(ROW))+1
      BINS = MAPS_L3B_LONLAT_2BIN('L3B4',LON,LAT)
            
      TAGS = TAG_NAMES(SD)
      STR = []
      FOR T=0, N_ELEMENTS(TAGS)-1 DO BEGIN
        DAT = SD.(T)
        TAG = TAGS[T]
        STAG = VPRODS[WHERE(STRUPCASE(NPRODS) EQ TAG,/NULL)]
        IF STAG EQ [] THEN CONTINUE
        BRK = STR_BREAK(STAG,'-')
        PRD = BRK[0]
        IF N_ELEMENTS(BRK) GT 1 THEN ALG = BRK[1] ELSE ALG = ''
        IF MAIN_PROD NE [] AND TAG EQ MAIN_PROD THEN BEGIN
          NBINS = N_ELEMENTS(DAT.IMAGE)
          IF NBINS NE N_ELEMENTS(BINS) THEN MESSAGE, 'ERROR: Number of bins does not match the data count'
          IMG = DAT.IMAGE
          OK_BAD = WHERE(IMG EQ DAT._FILLVALUE[0] OR IMG EQ MISSINGS(IMG),COUNT_BAD)
          IF COUNT_BAD GT 0 THEN MESSAGE, 'ERROR: Check input data'
          STR = CREATE_STRUCT('DATA',IMG,'PROD',PRD,'ALG',ALG,'BINS',BINS)
          IF HAS(DAT,'UNITS') THEN STR = CREATE_STRUCT(STR,'DATA_UNITS',DAT.UNITS)
          IF HAS(DAT,'UNITS_NONSTANDARD') THEN STR = CREATE_STRUCT(STR,'UNITS_NONSTANDARD',DAT.UNITS_NONSTANDARD)
          IF HAS(DAT,'LONG_NAME') THEN STR = CREATE_STRUCT(STR,'LONG_NAME',DAT.LONG_NAME)
          IF HAS(DAT,'STANDARD_NAME') THEN STR = CREATE_STRUCT(STR,'STANDARD_NAME', DAT.STANDARD_NAME) 
          IF HAS(DAT,'COMMENT') THEN STR = CREATE_STRUCT(STR,'COMMENT', DAT.COMMENT)
          IF HAS(DAT,'REF') THEN STR = CREATE_STRUCT(STR,'REFERENCE', DAT.REF) ELSE IF HAS(GLOBAL,'REFERENCE') THEN STR = CREATE_STRUCT(STR,'REFERENCE',GLOBAL.REFERENCE)
        ENDIF ELSE BEGIN
          IMG = DAT.IMAGE
          OK_BAD = WHERE(IMG EQ DAT._FILLVALUE[0] OR IMG EQ MISSINGS(IMG),COUNT_BAD)
          IF COUNT_BAD GT 0 THEN MESSAGE, 'ERROR: Check input data'
          
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
      
      NOTES   = [GLOBAL.REFERENCES,GLOBAL.INSTITUTION]
      INFILES = OFILE
      GONE, SD 
                 
      FOR MTH=0, N_ELEMENTS(MAPS)-1 DO BEGIN
        IF FILE_MAKE(SFILE,SAVEFILES[MTH],OVERWRITE=OVERWRITE) EQ 0 THEN CONTINUE
        AMAP = MAPS[MTH]
        
        IF AMAP NE 'L3B4' THEN STR = STRUCT_REMAP(STR, MAP_OUT=AMAP, INIT=INIT)
        
        IF KEY(DATA_ONLY) THEN RETURN_STRUCT = 1 ELSE RETURN_STRUCT = 0
        STRUCT_WRITE, STR, FILE=SAVEFILES[MTH], RETURN_STRUCT=RETURN_STRUCT, GLOBAL=GLOBAL, NCFILES=INFILES, FILE_NAME=SAVEFILE,  $
          MAP=AMAP, METHOD=METHOD, SATELLITE='MULTI', SENSOR=SENSOR, COVERAGE='4KM', NOTES=NOTES, ROUTINE=ROUTINE_NAME, ORIGINAL_DATE_CREATED=GLOBAL.PROCESSING_TIME
         
        STRUCT = RETURN_STRUCT ; Output structure
  
      ENDFOR ; MAPS
    ENDFOR ; PRODS 
  ENDFOR ; FILES    

  DONE:
END



