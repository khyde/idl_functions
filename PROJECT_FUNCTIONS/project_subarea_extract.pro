; $ID:	PROJECT_SUBAREA_EXTRACT.PRO,	2023-09-21-13,	USER-KJWH	$
  PRO PROJECT_SUBAREA_EXTRACT, VERSTR, PRODS=PRODS, DATASETS=DATASETS, MAP_IN=MAP_IN, SHAPEFILE=SHAPEFILE, SUBAREAS=SUBAREAS, DATERANGE=DATERANGE, $
  PERIOD=PERIOD, FILETYPE=FILETYPE, OUTSTATS=OUTSTATS, DATFILE=DATFILE, DIR_DATA=DIR_DATA, DIR_OUT=DIR_OUT, VERBOSE=VERBOSE

;+
; NAME:
;   PROJECT_SUBAREA_EXTRACT
;
; PURPOSE:
;   Wrapper program to run the SUBAREA_EXTRACT program based on project specific input variables
;
; CATEGORY:
;   PROJECT FUNCTIONS
;
; CALLING SEQUENCE:
;   PROJECT_SUBAREA_EXTRACT [Must provide the input datasets, products, periods, filetype, etc. or a structure with the necessary information] 
;
; REQUIRED INPUTS:
;   Parm1.......... Describe the positional input parameters here. 
;
; OPTIONAL INPUTS:
;   Parm2.......... Describe optional inputs here. If none, delete this section.
;
; KEYWORD PARAMETERS:
;   KEY1........... Document keyword parameters like this. Note that the keyword is shown in ALL CAPS!
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
; Copyright (C) 2022, Department of Commerce, National Oceanic and Atmospheric Administration, National Marine Fisheries Service,
;   Northeast Fisheries Science Center, Narragansett Laboratory.
;   This software may be used, copied, or redistributed as long as it is not sold and this copyright notice is reproduced on each copy made.
;   This routine is provided AS IS without any express or implied warranties whatsoever.
;
; AUTHOR:
;   This program was written on May 10, 2022 by Kimberly J. W. Hyde, Northeast Fisheries Science Center | NOAA Fisheries | U.S. Department of Commerce, 28 Tarzwell Dr, Narragansett, RI 02882
;    
; MODIFICATION HISTORY:
;   May 10, 2022 - KJWH: Initial code written
;-
; ****************************************************************************************************
  ROUTINE_NAME = 'PROJECT_SUBAREA_EXTRACT'
  COMPILE_OPT IDL2
  SL = PATH_SEP()
  
  PHYSIZE_PRODS = 'PSC_'+['MICRO','NANO','NANOPICO','PICO','FMICRO','FNANO','FNANOPICO','FPICO']

  IF ~N_ELEMENTS(VERSTR) THEN IF ~N_ELEMENTS(DATASETS) THEN MESSAGE, 'ERROR: Must provide either the DATASET name or a product specfic structure'
  
  VER = VERSTR.PROJECT
  
  IF ~N_ELEMENTS(DIR_DATA)       THEN DIRDATA   = !S.DATASETS                   ELSE DIRDATA = DIR_DATA
  IF ~N_ELEMENTS(DIR_OUT)        THEN DIROUT    = VERSTR.DIRS.DIR_DATA_EXTRACTS ELSE DIROUT  = DIR_OUT
  IF ~N_ELEMENTS(PRODS)          THEN PRODS     = VERSTR.INFO.EXTRACT_PRODS   
  IF ~N_ELEMENTS(PERIOD)         THEN DPERS     = VERSTR.INFO.EXTRACT_PERIODS   ELSE DPERS   = PERIOD
  IF ~N_ELEMENTS(FILETYPE)       THEN FILETYPES = VERSTR.INFO.EXTRACT_FILETYPE  ELSE FILETYPES=FILETYPE
  IF ~N_ELEMENTS(DATERANGE)      THEN DTR       = VERSTR.INFO.DATERANGE         ELSE DTR     = DATERANGE
  IF ~N_ELEMENTS(SHAPEFILE)      THEN SHPFILES  = TAG_NAMES(VERSTR.SHAPEFILES)  ELSE SHPFILES = SHAPEFILE
;  IF ~N_ELEMENTS(MAP_IN)         THEN MAPIN     = VERSTR.INFO.MAP_IN          ELSE MAPIN   = MAP_IN

  PERSTR = PERIODS_READ(DPERS)
  TPERS = DPERS[WHERE(PERSTR.CLIMATOLOGY EQ 0,/NULL)]

  FOR S=0, N_ELEMENTS(SHPFILES)-1 DO BEGIN
    SHPFILE = SHPFILES[S]
    
    IF ~N_ELEMENTS(SUBAREAS) THEN BEGIN
      OK = WHERE(TAG_NAMES(VERSTR.SHAPEFILES) EQ SHPFILE,COUNT_SHP)
      IF COUNT_SHP EQ 1 THEN NAMES = VERSTR.SHAPEFILES.(OK).SUBAREA_NAMES ELSE NAMES = []
    ENDIF ELSE NAMES = SUBAREAS
    
    IF STRUCT_HAS(VERSTR.INFO,'TEMP_PRODS') THEN TEMP_PRODS = VERSTR.INFO.TEMP_PRODS  ELSE TEMP_PRODS = ''    
    
    DFILES = []
    FOR A=0, N_ELEMENTS(PRODS)-1 DO BEGIN
      APROD = PRODS[A]  
      
      OK = WHERE(TEMP_PRODS EQ APROD,COUNT)
      IF COUNT GE 1 THEN TPROD = TEMP_PRODS[OK] ELSE TPROD = []
      
      CASE APROD OF
        'PHYSIZE': BEGIN & DPRODS=PHYSIZE_PRODS & END
        ELSE:      BEGIN & DPRODS=''            & END
      ENDCASE
      
      EFILES = []
      FOR D=0, N_ELEMENTS(DPRODS)-1 DO BEGIN
        DPROD = DPRODS[D]
        IF DPROD EQ '' THEN POK = WHERE(TAG_NAMES(VERSTR.PROD_INFO) EQ APROD,/NULL) ELSE POK = WHERE(TAG_NAMES(VERSTR.PROD_INFO) EQ DPROD,/NULL)
        PSTR = VERSTR.PROD_INFO.(POK)
        DPRD = PSTR.PROD
        DSET = PSTR.DATASET
        DVER = PSTR.VERSION & IF DVER NE '' AND ~HAS(DVER,'V') THEN DVER='V'+DVER 
        DATASETS = DSET
        
        DIR_EXTRACT = DIROUT + DSET + SL & DIR_TEST, DIR_EXTRACT
        DTR = GET_DATERANGE(DTR)
                
        FOR F=0, N_ELEMENTS(FILETYPES)-1 DO BEGIN
          ATYPE = FILETYPES[F]
          IF DIRDATA EQ !S.DATASETS THEN FILES = GET_FILES(DSET, PRODS=DPRD, PERIODS=DPERS, FILE_TYPE='STACKED_'+ATYPE, MAPS=MAPIN, VERSION=DVER, DATERANGE=DTR, COUNT=COUNT) $
                                                           ELSE FILES = FILE_SEARCH(DIRDATA + DSET + SL + MAPIN + SL + 'STATS' + SL + DPRD + SL + [DPERS] + '*',COUNT=COUNT)
          IF FILES EQ [] THEN CONTINUE
          FP = PARSE_IT(FILES,/ALL)
          IF ~SAME(FP.MAP) THEN MESSAGE, 'ERROR: All input files must have the same map.'
          SAV = DIR_EXTRACT + ROUTINE_NAME + '-' +VER + '-' + STRJOIN(DPERS,'_') + '-' + DSET  + '-' + DVER + '-' + SHPFILE + '-' + FP[0].MAP + '-' + DPRD + '-' + ATYPE + '.SAV'
          SAV = REPLACE(SAV,['--','-.'],['-',''])
          SUBAREAS_EXTRACT, FILES, SHP_NAME=SHPFILE, SUBAREAS=NAMES, VERBOSE=VERBOSE, DIR_OUT=DIR_EXTRACT, STRUCT=STR, SAVEFILE=SAV, OUTPUT_STATS=OUTSTATS, /ADD_DIR
          EFILES = [EFILES,SAV]
          
          ; ===> Extract the data from the "temporary" prod
          IF TPROD NE [] THEN BEGIN
            PERSTR = PERIOD_2STRUCT(STR.PERIOD)
            PERSTR.JD_END = DATE_2JD(STRMID(JD_2DATE(PERSTR.JD_END),0,8))
            PCS = WHERE_SETS(PERSTR.PERIOD_CODE)
            DTRSTR = DATE_PARSE(DTR)
            FOR C=0, N_ELEMENTS(PCS)-1 DO BEGIN
              TPER = PCS[C].VALUE
              IF KEYWORD_SET((PERIODS_READ(TPER)).CLIMATOLOGY) THEN CONTINUE
              PSUBS = PERSTR[WHERE_SETS_SUBS(PCS[C])]
              
              IF MAX(PSUBS.JD_END) GE MAX(DTRSTR.JD) THEN CONTINUE ; If the max period matches the max daterange, then continue because you don't need the temp file
              
              TDTR = GET_DATERANGE(STRMID(JD_2DATE(JD_ADD(MAX(PSUBS.JD_END),1,/DAY)),0,8),MAX(DTR))
              STDTR = TDTR
             ; IF TPER EQ 'A' THEN STDTR = [] ELSE STDTR = TDTR ; Set up the "search" daterange 
              TSET = PSTR.TEMP_DATASET
              TPRD = PSTR.TEMP_PROD
              TVER = PSTR.TEMP_VERSION
              DIR_EXTRACT = DIROUT + TSET + SL & DIR_TEST, DIR_EXTRACT
          
              IF DIRDATA EQ !S.DATASETS THEN TFILES = GET_FILES(TSET, PRODS=TPRD, PERIODS=TPER, FILE_TYPE='STACKED_'+ATYPE, VERSION=TVER, DATERANGE=STDTR, COUNT=COUNT) $
                                        ELSE TFILES = FILE_SEARCH(DIRDATA + DSET + SL + MAPIN + SL + 'STATS' + SL + DPRD + SL + [TPER] + '*',COUNT=COUNT)
              IF TFILES EQ [] THEN CONTINUE
              FP = PARSE_IT(TFILES,/ALL)
              IF ~SAME(FP.MAP) THEN MESSAGE, 'ERROR: All input files must have the same map.'
              SAV = DIR_EXTRACT + ROUTINE_NAME + '-' +VER + '-' + TPER + '-' + TSET + '-' +TVER + '-' + SHPFILE + '-' + FP[0].MAP  + '-' + TPRD + '-' + ATYPE + '.SAV'
              SAV = REPLACE(SAV,['--','-.'],['-',''])
              SUBAREAS_EXTRACT, TFILES, SHP_NAME=SHPFILE, SUBAREAS=NAMES, DATERANGE=TDTR, DIR_OUT=DIR_EXTRACT, STRUCT=TSTR, SAVEFILE=SAV, EXTRACT_STAT=ESTAT, /ADD_DIR
              EFILES = [EFILES,SAV]
              DATASETS = [DSET,TSET]
            ENDFOR ; PERIOD CODES  
          ENDIF ; TPROD
        ENDFOR ; FILETYPE
      ENDFOR ; DPRODS
      
      IF DATASETS EQ [] THEN CONTINUE
      DATASETS = DATASETS[UNIQ(DATASETS), SORT(DATASETS)]
          
      DATFILE = DIROUT + STRJOIN(DTR,'_') + '-' + STRJOIN(DATASETS,'_') + '-' + APROD + '-' + STRJOIN(FILETYPES,'_') + '-' + SHPFILE + '-' + VER +  '.SAV'
      DFILES = [DFILES,DATFILE]
      IF EFILES NE [] AND FILE_MAKE(EFILES,DATFILE,OVERWRITE=OVERWRITE) EQ 1 THEN BEGIN
        STRUCT = IDL_RESTORE(EFILES[0])
        FOR E=1, N_ELEMENTS(EFILES)-1 DO IF FILE_TEST(EFILES[E]) THEN STRUCT = STRUCT_CONCAT(STRUCT,IDL_RESTORE(EFILES[E]))
        STRUCT = STRUCT_DUPS(STRUCT, TAGNAMES=['PERIOD','SUBAREA','PROD','ALG','MATH','MIN','MAX','MED'],DUPS_REMOVED=DUPS_REMOVED) ; Remove any duplicates
        DSTRUCT = STRUCT_DUPS(STRUCT, TAGNAMES=['PERIOD','SUBAREA','PROD','MATH'],DUPS_REMOVED=DUPS_REMOVED) ; Remove any duplicates

        SAVE, STRUCT, FILENAME=DATFILE ; ===> SAVE THE MERGED DATAFILE
        SAVE_2CSV, DATFILE
      ENDIF
  
    ENDFOR ; PRODS
    
    ; ===> Merge the product based DATFILE into a single combined DATAFILE
    DATAFILES = VERSTR.INFO.DATAFILE
    DFP = FILE_PARSE(DATAFILES)
    BRK = STR_BREAK(DFP.NAME,'-')
    OK = WHERE(BRK[*,1] EQ SHPFILE, COUNTDAT)
    IF COUNTDAT NE 1 THEN MESSAGE, 'ERROR: Unable to find the correct datafile name for ' + SHPFILE
    DATAFILE = DATAFILES[OK]
    IF ANY(DIR_DATA) THEN DATAFILE = REPLACE(DATAFILE,VERSTR.DIRS.DIR_EXTRACTS,DIROUT)
    IF DFILES NE [] AND FILE_MAKE(DFILES,DATAFILE,OVERWRITE=OVERWRITE) EQ 1 THEN BEGIN
      STRUCT = IDL_RESTORE(DFILES[0])
      FOR T=1, N_ELEMENTS(DFILES)-1 DO IF FILE_TEST(DFILES[T]) THEN STRUCT = STRUCT_CONCAT(STRUCT,IDL_RESTORE(DFILES[T]))
      STRUCT = STRUCT_DUPS(STRUCT, TAGNAMES=['PERIOD','SUBAREA','PROD','ALG','MATH','MIN','MAX','MED'],SUBS=SUBS,DUPS_REMOVED=DUPS_REMOVED) ; Remove any duplicates
      SAVE, STRUCT, FILENAME=DATAFILE ; ===> SAVE THE MERGED DATAFILE
      SAVE_2CSV, DATAFILE
    ENDIF
    
    
  ENDFOR ; SHAPEFILES  

 




END ; ***************** End of PROJECT_SUBAREA_EXTRACT *****************
