; $ID:	STACKED_STATS_WRAPPER.PRO,	2023-09-21-13,	USER-KJWH	$
  PRO CLIMTEST_STACKED_STATS_WRAPPER, DATASETS, PRODS=PRODS, PERIODS=PERIODS, MAPP=MAPP, L3BSUBSET=L3BSUBSET, OUTPRODS=OUTPRODS, OUTSTATS=OUTSTATS, DATERANGE=DATERANGE, VERSION=VERSION, OVERWRITE=OVERWRITE

;+
; NAME:
;   STACKED_STATS_WRAPPER
;
; PURPOSE:
;   Wrapper program to find the input files and run STACKED_STATS based on the output period
;
; CATEGORY:
;   STACKED_FUNCTIONS
;
; CALLING SEQUENCE:
;   STACKED_STATS_WRAPPER, DATASETS, PERIODS=PERIODS
;
; REQUIRED INPUTS:
;   DATASET........ The name of the dataset(s) to run the stats
;   PERIODS........ The output period codes for the stats
;   PRODS.......... The name of the input products
;
; OPTIONAL INPUTS:
;   MAPP........... Map of the input data (if not the default for the dataset)
;   L3BSUBSET...... The name of the "map" to subset the L3B binned data
;   OUTSTATS....... The type of "stats" to output
;   DATERANGE...... The daterange for the files/stats
;   VERSION.......... The version for the input data
;   
; KEYWORD PARAMETERS:
;   OVERWRITe...... Keyword to overwrite existing files
;
; OUTPUTS:
;   Runs the STACKED_STATS program
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
;   This program was written on October 11, 2022 by Kimberly J. W. Hyde, Northeast Fisheries Science Center | NOAA Fisheries | U.S. Department of Commerce, 28 Tarzwell Dr, Narragansett, RI 02882
;    
; MODIFICATION HISTORY:
;   Oct 11, 2022 - KJWH: Initial code written
;   Dec 01, 2022 - KJWH: Now running the STATS_CLEANUP steps at the beginning and end in case the program is stopped midway and there are multiple files per period
;   Dec 02, 2022 - KJWH: Added VERSION for the GET_FILES
;   Jan 23, 2023 - KJWH: Added IF ~N_ELEMENTS(L3BSUBSET) THEN L3BSUBSET = 'NWA'
;   Feb 28, 2023 - KJWH: Replaced STACKED_MAKE_WRAPPER with FILES_2STACKED_WRAPPER
;   Oct 19, 2023 - KJWH: Added a MAPS loop
;-
; ****************************************************************************************************
  ROUTINE_NAME = 'STACKED_STATS_WRAPPER'
  COMPILE_OPT IDL2
  SL = PATH_SEP()

  IF ~N_ELEMENTS(DATASETS) THEN MESSAGE, 'ERROR: Must provide at least one input dataset.'
  IF ~N_ELEMENTS(PRODS)    THEN MESSAGE, 'ERROR: Must provide at least on product name.'
  IF ~N_ELEMENTS(PERIODS)  THEN MESSAGE, 'ERROR: Must provide at least one output period code.'
  IF N_ELEMENTS(DATASETS) GT 1 AND TYPENAME(PRODS) NE 'LIST' THEN MESSAGE, 'ERROR: If more than one dataset provided, must input product names as a "LIST"'
  IF ~N_ELEMENTS(VERSION) THEN VERSION = []
  IF ~N_ELEMENTS(L3BSUBSET) THEN L3BSUBSET = 'NWA'
  IF N_ELEMENTS(MAPP) GE 1 THEN MAPS = MAPP ELSE MAPS = '' 

  
  FOR D=0, N_ELEMENTS(DATASETS)-1 DO BEGIN
    DATASET = DATASETS[D]
    
    FOR M=0, N_ELEMENTS(MAPS)-1 DO BEGIN
      MP = MAPS[M]
      IF MP EQ '' THEN MP = []
    
    
; TODO ===> Set up dataset specific information    
    
      IF TYPENAME(PRODS) EQ 'LIST' THEN DPRODS = PRODS[D] ELSE DPRODS = PRODS 
      
      FOR A=0, N_ELEMENTS(DPRODS)-1 DO BEGIN
        APROD = DPRODS[A]
        ALG = VALIDS('ALGS',DPRODS[A])
        
        ; ===> Get the output products from input files that have multiple products (e.g. PSC) 
        OPRODS = APROD  
        STAT_TYPES = []
        GRAD_TEMP_PRODS = []
        VPROD = VALIDS('PRODS',APROD)
        CASE 1 OF 
          VPROD EQ 'PSC': OPRODS = 'PSC_'+['MICRO','NANO','PICO','NANOPICO','FMICRO','FNANO','FPICO','FNANOPICO'] + '-' + ALG
          VPROD EQ 'ZEU': BEGIN & APROD='PPD-VGPM2' & OPRODS='ZEU-VGPM2' & END
          VPROD EQ 'GRAD_SST':   BEGIN & STAT_TYPES = ['NUM','MIN','MAX'] & GRAD_TEMP_PRODS = ['GRAD_SSTX','GRAD_SSTY'] & END
          VPROD EQ 'GRAD_CHL':   BEGIN & STAT_TYPES = ['NUM','MIN','MAX'] & GRAD_TEMP_PRODS = ['GRAD_CHLX','GRAD_CHLY'] & END
          VPROD EQ 'GRAD_SSTKM': BEGIN & STAT_TYPES = ['NUM','MIN','MAX'] & GRAD_TEMP_PRODS = ['GRAD_SSTX','GRAD_SSTY'] & END
          VPROD EQ 'GRAD_CHLKM': BEGIN & STAT_TYPES = ['NUM','MIN','MAX'] & GRAD_TEMP_PRODS = ['GRAD_CHLX','GRAD_CHLY'] & END
          VPROD EQ 'ADG' OR VPROD EQ 'APH' OR VPROD EQ 'ATOT' OR VPROD EQ 'BBP' OR VPROD EQ 'RRS': BEGIN 
            OPRODS=VPROD+'_'+SENSOR_WAVELENGTHS(DATASET)+'-QAA' 
            APROD='IOP' 
          END
          STRMID(APROD,0,4) EQ 'PSC_': BEGIN
            OPRODS=APROD
            APROD='PSC-'+ALG
          END
          ELSE:   
        ENDCASE
        
        IF N_ELEMENTS(OUTPRODS) GT 0 THEN OPRODS = OUTPRODS
        
        FOR O=0, N_ELEMENTS(OPRODS)-1 DO BEGIN ; Loop through output products
          OPROD = OPRODS[O]
        
          ; ===> Clean up files before starting (in case this step doesn't get to run at the end
          FILES = GET_FILES(DATASET,PRODS=OPROD,FILE_TYPE='STACKED_STATS',VERSION=VERSION,MAPS=MP,COUNT=COUNT) 
          IF COUNT GT 1 THEN BEGIN 
            FP = FILE_PARSE(FILES[0])
            STACKED_STATS_CLEANUP, FP[0].DIR,MOVE_FILES=0
          ENDIF  
          FILES = GET_FILES(DATASET,PRODS=OPROD,FILE_TYPE='STACKED_TEMP',VERSION=VERSION,MAPS=MP,COUNT=COUNT)
          IF COUNT GT 1 THEN BEGIN
            FP = FILE_PARSE(FILES[0])
            STACKED_STATS_CLEANUP, FP[0].DIR,MOVE_FILES=0
          ENDIF
        
          FOR R=0, N_ELEMENTS(PERIODS)-1 DO BEGIN
            APER = PERIODS[R]
            CSTR = PERIODS_READ(APER)                                                                                               ; Get information about the input period code
            INPUT_PER = CSTR.STACKED_STAT_PERIOD_INPUT
            TEMP_PERIOD = CSTR.STACKED_TEMP
            ; ===> Determine the "search" product name based on the input period
            CASE INPUT_PER OF
              'D':  SPROD = APROD
              'DD': SPROD = APROD 
              ELSE: SPROD = OPROD
            ENDCASE
  
            IF CSTR EQ [] THEN MESSAGE, 'ERROR: ' + APER + ' is not a valid period code.'                                           ; Make sure the period code is valid
            IF APER NE 'DOY' THEN FILES = GET_FILES(DATASET,PRODS=SPROD, MAPS=MP,PERIODS=INPUT_PER, FILE_TYPE='STACKED', DATERANGE=DATERANGE,VERSION=VERSION,COUNT=COUNT) ELSE COUNT = 1
            IF COUNT EQ 0 THEN CONTINUE
            KEEP_COMMON = 0
            INIT = 1
            PLUN, LUN, 'Running STATS for ' + DATASET + ' - ' + OPROD + ' for  period ' + APER
            
            IF KEYWORD_SET(TEMP_PERIOD) THEN BEGIN
              FILES_2STACKED_WRAPPER, DATASET, PRODS=SPROD, DATERANGE=DATERANGE, L3BSUBMAP=L3BSUBSET, OVERWRITE=OVERWRITE, MAP_IN=MP, MAP_OUT=MP, TEMP_PERIOD=CSTR.STACKED_STAT_PERIOD_INPUT,/STACKED_TEMP 
              FILES=GET_FILES(DATASET,PRODS=SPROD, PERIODS=APER, MAPS=MP,FILE_TYPE='STACKED_TEMP', DATERANGE=DATERANGE,VERSION=VERSION,COUNT=COUNT) 
              FOR F=0, N_ELEMENTS(FILES)-1 DO BEGIN
                IF F EQ N_ELEMENTS(FILES)-1 THEN KEEP_COMMON=0 ELSE KEEP_COMMON=1
                IF F EQ 0 THEN INIT = 1 ELSE INIT = 0
                STACKED_STATS, FILES[F], PERIOD_OUT=APER, STATPROD=STAT_PROD, STAT_TYPES=STAT_TYPES, L3BSUBMAP=L3BSUBSET, OVERWRITE=OVERWRITE, KEEP_COMMON=KEEP_COMMON, INIT=INIT
              ENDFOR
            ENDIF ELSE BEGIN
             ; 'WEEK':  BEGIN & STATS_2STACKED, FILES, OUTFILE=OUTFILE, OVERWRITE=OVERWRITE & FILES=OUTFILE & STACKED_STATS, OUTFILE, PERIOD_OUT=APER, STATPROD=STAT_PROD, STAT_TYPES=STAT_TYPES, L3BSUBMAP=L3BSUBSET, OVERWRITE=OVERWRITE, INIT=INIT, KEEP_COMMON=KEEP_COMMON & END
             ; 'MONTH': BEGIN & STATS_2STACKED, FILES, OUTFILE=OUTFILE, OVERWRITE=OVERWRITE & FILES=OUTFILE & STACKED_STATS, OUTFILE, PERIOD_OUT=APER, STATPROD=STAT_PROD, STAT_TYPES=STAT_TYPES, L3BSUBMAP=L3BSUBSET, OVERWRITE=OVERWRITE, INIT=INIT, KEEP_COMMON=KEEP_COMMON & END
              STACKED_STATS, FILES, PERIOD_OUT=APER, STATPROD=OPROD, STAT_TYPES=STAT_TYPES, L3BSUBMAP=L3BSUBSET, OVERWRITE=OVERWRITE, INIT=INIT, KEEP_COMMON=KEEP_COMMON 
            ENDELSE       
            FILES = GET_FILES(DATASET,PRODS=OPROD,MAPS=MP,FILE_TYPE='STACKED_STATS',VERSION=VERSION,COUNT=COUNT) & FP = FILE_PARSE(FILES)
            IF COUNT GT 1 THEN STACKED_STATS_CLEANUP, FP[0].DIR,MOVE_FILES=0
            FILES = GET_FILES(DATASET,PRODS=OPROD,MAPS=MP,FILE_TYPE='STACKED_TEMP',VERSION=VERSION, COUNT=COUNT) & FP = FILE_PARSE(FILES)
            IF COUNT GT 1 THEN STACKED_STATS_CLEANUP, FP[0].DIR,MOVE_FILES=0  
          ENDFOR ; PERIODS
        ENDFOR ; OUTPUT PRODUCTS   
      ENDFOR ; PRODS
    ENDFOR ; MAPS
  ENDFOR ; DATASETS
  
  
  
  
  


END ; ***************** End of STACKED_STATS_WRAPPER *****************
