; $ID:	STACKED_STATS_WRAPPER.PRO,	2023-09-21-13,	USER-KJWH	$
  PRO STACKED_STATS_WRAPPER, DATASETS, PRODS=PRODS, PERIODS=PERIODS, CLIMATOLOGY_DATERANGE=CLIMATOLOGY_DATERANGE, MAPP=MAPP, L3BSUBSET=L3BSUBSET, OUTPRODS=OUTPRODS, OUTSTATS=OUTSTATS, DATERANGE=DATERANGE, VERSION=VERSION, DIR_IN=DIR_IN, DIR_OUT=DIR_OUT, OVERWRITE=OVERWRITE

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
;   CLIMATOLOGY_YEARS... The year range for the climatology files
;   MAPP................ Map of the input data (if not the default for the dataset)
;   L3BSUBSET........... The name of the "map" to subset the L3B binned data
;   OUTSTATS............ The type of "stats" to output
;   DATERANGE........... The daterange for the files/stats
;   VERSION............. The version for the input data
;   DIR_IN.............. Directory to search for the input files (if not the default)
;   DIR_OUT............. Directory to store the stacked files (if not the default)
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
;   Mar 05, 2024 - KJWH: Now excluding the current year file from climatological (WEEK and MONTH) calculations
;   Mar 06, 2024 - KJWH: Added DIR_OUT to the input options
;-
; ****************************************************************************************************
  ROUTINE_NAME = 'STACKED_STATS_WRAPPER'
  COMPILE_OPT IDL2
  SL = PATH_SEP()

  IF ~N_ELEMENTS(DATASETS) THEN MESSAGE, 'ERROR: Must provide at least one input dataset.'
  IF ~N_ELEMENTS(PRODS)    THEN MESSAGE, 'ERROR: Must provide at least on product name.'
  IF ~N_ELEMENTS(PERIODS)  THEN MESSAGE, 'ERROR: Must provide at least one output period code.'
  IF  N_ELEMENTS(DATASETS) GT 1 AND TYPENAME(PRODS) NE 'LIST' THEN MESSAGE, 'ERROR: If more than one dataset provided, must input product names as a "LIST"'
  IF ~N_ELEMENTS(VERSION) THEN VERSION = []
  IF ~N_ELEMENTS(L3BSUBSET) THEN L3BSUBSET = 'NWA'
  IF  N_ELEMENTS(MAPP) GE 1 THEN MAPS = MAPP ELSE MAPS = '' 
  IF ~N_ELEMENTS(DIR_OUT) THEN DIROUT = []

  FOR D=0, N_ELEMENTS(DATASETS)-1 DO BEGIN
    DATASET = DATASETS[D]

    ; ===> Set up the climatology daterange
    IF ~N_ELEMENTS(CLIMATOLOGY_DATERANGE) THEN CLIMATOLOGY_DATERANGE = 'DEFAULT'
    IF N_ELEMENTS(CLIMATOLOGY_DATERANGE) EQ 2 THEN CLIMDTR = GET_DATERANGE(CLIMATOLOGY_DATERANGE) ELSE BEGIN
      CASE CLIMATOLOGY_DATERANGE OF
        'FULL': CLIMDTR = GET_DATERANGE(SENSOR_DATES(DATASET))
        'DEFAULT': CLIMDTR = GET_DATERANGE(['1991','2020'])
        ELSE: MESSAGE,'ERROR: Must provide a start and end year for the climatology range'
      ENDCASE
    ENDELSE  
    CLIM_YEAR_START = DATE_2YEAR(CLIMDTR[0])
    CLIM_YEAR_END   = DATE_2YEAR(CLIMDTR[1])
    IF CLIM_YEAR_START EQ CLIM_YEAR_END THEN MESSAGE, 'ERROR: Climatology start year and end year are the same'
    
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
          VPROD EQ 'PSC': BEGIN 
            OPRODS = 'PSC_'+['MICRO','NANO','PICO','NANOPICO','FMICRO','FNANO','FPICO','FNANOPICO'] + '-' + ALG
            IF ALG EQ 'HIRATA' THEN OPRODS = [OPRODS,'PSC_DIATOM-HIRATA']
          END  
          VPROD EQ 'ZEU': BEGIN & APROD='PPD-VGPM2' & OPRODS='ZEU-VGPM2' & END
          VPROD EQ 'GRAD_SST': BEGIN & STAT_TYPES = ['NUM','MIN','MAX']  & GRAD_TEMP_PRODS = ['GRAD_SSTX','GRAD_SSTY'] & END
          VPROD EQ 'GRAD_CHL': BEGIN & STAT_TYPES = ['NUM','MIN','MAX']  & GRAD_TEMP_PRODS = ['GRAD_CHLX','GRAD_CHLY'] & END
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
          STACKED_STATS_CLEANUP, DATASET, PRODS=OPROD, MAPS=MP, MOVE_FILES=0 ; Clean up the files and look for "OLD" climatologies before starting (in case this step doesn't get to run at the end)
          FOR R=0, N_ELEMENTS(PERIODS)-1 DO BEGIN
            APER = PERIODS[R]
            CSTR = PERIODS_READ(APER)                                                                                               ; Get information about the input period code
            INPUT_PER = CSTR.STACKED_STAT_PERIOD_INPUT
            
            ; ===> Determine the "search" product name based on the input period
            CASE INPUT_PER OF
              'D':  SPROD = APROD
              'DD': SPROD = APROD 
              ELSE: SPROD = OPROD
            ENDCASE
  
            IF CSTR EQ [] THEN MESSAGE, 'ERROR: ' + APER + ' is not a valid period code.'                                           ; Make sure the period code is valid
            IF APER NE 'DOY' THEN BEGIN
              FILES = GET_FILES(DATASET,PRODS=SPROD,DIR_DATA=DIR_IN, MAPS=MP,PERIODS=INPUT_PER, FILE_TYPE='STACKED', DATERANGE=DATERANGE,VERSION=VERSION,COUNT=COUNT) 
              FP = PARSE_IT(FILES)
              DP = PERIOD_2STRUCT(FP.PERIOD)
              IF APER EQ 'A' THEN FILES = FILES[WHERE(DP.YEAR_END LT DATE_NOW(/YEAR))]  ; Remove current year from the climatological calculations
              IF APER EQ 'ANNUAL' THEN IF N_ELEMENTS(FILES) GT 1 THEN MESSAGE,'ERROR: There should only be 1 in AA file for the ANNUAL period'
            ;  IF KEYWORD_SET(CSTR.CLIMATOLOGY) AND APER NE 'ANNUAL' THEN FILES = FILES[WHERE(DP.YEAR_START GE CLIM_YEAR_START AND DP.YEAR_END LE CLIM_YEAR_END,/NULL)]
              IF FILES EQ [] THEN MESSAGE, 'ERROR: Unable to find files...' 
            ENDIF ELSE COUNT = 1
            IF COUNT EQ 0 THEN CONTINUE
            KEEP_COMMON = 0
            INIT = 1
            PLUN, LUN, 'Running STATS for ' + DATASET + ' - ' + OPROD + ' for  period ' + APER
            CASE APER OF
              'DOY':   BEGIN 
                STOP ; NEED TO ADJUST THE CLIMATOLOGY DATE RANGE TO 1991-2020
                FILES_2STACKED_WRAPPER, DATASET, PRODS=SPROD, DATERANGE=DATERANGE, L3BSUBMAP=L3BSUBSET, OVERWRITE=OVERWRITE, MAP_IN=MP, MAP_OUT=MP, /DOY 
                FILES=GET_FILES(DATASET,PRODS=SPROD, PERIODS='DOY', MAPS=MP,FILE_TYPE='STACKED_TEMP', DATERANGE=DATERANGE,VERSION=VERSION,COUNT=COUNT) 
                FOR F=0, N_ELEMENTS(FILES)-1 DO BEGIN
                  IF F EQ N_ELEMENTS(FILES)-1 THEN KEEP_COMMON=0 ELSE KEEP_COMMON=1
                  IF F EQ 0 THEN INIT = 1 ELSE INIT = 0
                  STACKED_STATS, FILES[F], PERIOD_OUT=APER, STATPROD=STAT_PROD, CLIMATOLOGY_DATERANGE=CLIMDTR, STAT_TYPES=STAT_TYPES, L3BSUBMAP=L3BSUBSET, OVERWRITE=OVERWRITE, DIR_OUT=DIROUT, KEEP_COMMON=KEEP_COMMON, INIT=INIT
                ENDFOR
              END
              'WEEK':  BEGIN & STATS_2STACKED, FILES, OUTFILE=OUTFILE, OVERWRITE=OVERWRITE & FILES=OUTFILE & STACKED_STATS, OUTFILE, PERIOD_OUT=APER, STATPROD=STAT_PROD, DATERANGE=DATERANGE,CLIMATOLOGY_DATERANGE=CLIMDTR,STAT_TYPES=STAT_TYPES, L3BSUBMAP=L3BSUBSET, OVERWRITE=OVERWRITE, INIT=INIT, DIR_OUT=DIROUT, KEEP_COMMON=KEEP_COMMON & END
              'MONTH': BEGIN & STATS_2STACKED, FILES, OUTFILE=OUTFILE, OVERWRITE=OVERWRITE & FILES=OUTFILE & STACKED_STATS, OUTFILE, PERIOD_OUT=APER, STATPROD=STAT_PROD, DATERANGE=DATERANGE,CLIMATOLOGY_DATERANGE=CLIMDTR,STAT_TYPES=STAT_TYPES, L3BSUBMAP=L3BSUBSET, OVERWRITE=OVERWRITE, INIT=INIT, DIR_OUT=DIROUT, KEEP_COMMON=KEEP_COMMON & END
              'MONTH3': BEGIN & STATS_2STACKED, FILES, OUTFILE=OUTFILE, OVERWRITE=OVERWRITE & FILES=OUTFILE & STACKED_STATS, OUTFILE, PERIOD_OUT=APER, STATPROD=STAT_PROD, DATERANGE=DATERANGE,CLIMATOLOGY_DATERANGE=CLIMDTR,STAT_TYPES=STAT_TYPES, L3BSUBMAP=L3BSUBSET, OVERWRITE=OVERWRITE, INIT=INIT, DIR_OUT=DIROUT, KEEP_COMMON=KEEP_COMMON & END
              ELSE: STACKED_STATS, FILES, PERIOD_OUT=APER, STATPROD=OPROD, DATERANGE=DATERANGE, CLIMATOLOGY_DATERANGE=CLIMDTR,STAT_TYPES=STAT_TYPES, L3BSUBMAP=L3BSUBSET, OVERWRITE=OVERWRITE, INIT=INIT, DIR_OUT=DIROUT, KEEP_COMMON=KEEP_COMMON 
            ENDCASE       
            IF KEYWORD_SET(CSTR.CLIMATOLOGY) OR APER EQ 'A' THEN STACKED_STATS_CLEANUP, DATASET, PRODS=OPROD, MAPS=MP,MOVE_FILES=0 ; Clean up the STAT directories and remove any "OLD" climatology files
          ENDFOR ; PERIODS
          STACKED_STATS_CLEANUP, DATASET, PRODS=OPROD, MAPS=MP,MOVE_FILES=0 ; Clean up the STAT directories and remove any "OLD" climatology files
        ENDFOR ; OUTPUT PRODUCTS   
      ENDFOR ; PRODS
    ENDFOR ; MAPS
  ENDFOR ; DATASETS
  
END ; ***************** End of STACKED_STATS_WRAPPER *****************
