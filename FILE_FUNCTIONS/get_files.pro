; $ID:	GET_FILES.PRO,	2023-09-21-13,	USER-KJWH	$
FUNCTION GET_FILES, DATASETS, DIR_DATA=DIR_DATA, ANOMALY_DATASET=ANOMALY_DATASET, LEVELS=LEVELS, PRODS=PRODS, PERIODS=PERIODS, FILE_TYPE=FILE_TYPE, $
  MAPS=MAPS, EXT=EXT, DATERANGE=DATERANGE, CLIMATOLOGY=CLIMATOLOGY, VERSION=VERSION, PROD_VERSION=PROD_VERSION, SST=SST, DAYNIGHT=DAYNIGHT, COUNT=COUNT

;+
; NAME:
;   GET_FILES
;
; PURPOSE:
;   This procedure is a shortcut to find files based on PRODS, MATH, PERIODS, LEVELS, MAP
;
; CATEGORY:
;   FILES
;
; CALLING SEQUENCE:
;   Result = GET_FILES(DATASETS)
;   Result = GET_FILES(DATASETS, LEVELS=LEVELS, PRODS=PRODS, PERIODS=PERIODS, MATH=MATH, MAPS=MAPS, DATERANGE=DATERANGE)
;
; REQUIRED INPUTS:
;   DATASETS......... The name of the dataset to search for files: Default = all OC and SST datasets
;   PRODS............ The product name to search for: Default = all available products depending on the dataset
;
; OPTIONAL INPUTS:
;   SUITE............ The name of the dataset "suite" (OC, SST, FRONTS, etc.)
;   ANOMALY_DATASET.. The name of the anomaly dataset if the denominator dataset is different from the numerator dataset (e.g. SEAWIFS/SA, VIIRS/SAV)
;   LEVELS........... The level directory (e.g. L1A, L2, L3, L4): Default = 'L3'
;   PERIODS.......... The period code for the files: Default = 'D'
;   FILE_TYPE........ The type of the files (NETCDFS, STATS, INTERP_SAVE or ANOMS): Default = STATS is the period is not 'D'
;   MAPS............. The name of the map: Default = 'L3B2' unless otherwise specified
;   EXT.............. The extension of the file: Default = 'SAV'
;   DATERANGE........ The minimum and maximum date of the files: Default = maximum daterange based on the dataset
;   CLIMATOLOGY...... The climatology daterange for climatology and anomaly files
;   VERSION.......... To indicate the dataset version (e.g. VERSION_4.2 vs VERSION_5.0): Default = 'CURRENT'
;   PROD_VERSION..... To indicate the product version: Default = 'CURRENT'
;   DAYNIGHT......... To indicate if the product has a DAY or NIGHT tag
;
; KEYWORD PARAMETERS:
;   SST.............. Use this keyword to for the main dir to be !S.SST (needed when looking for L2/NC SST files)
;
; OUTPUTS:
;   This function returns a list of files based on the optional inputs
;
; OPTIONAL OUTPUTS:
;   COUNT........... The number of files found
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
;   FILES = GET_FILES('OCCCI') & HELP, FILES
;   FILES = GET_FILES('OCCCI',PRODS=['CHLOR_A-OCI','CHLOR_A-PAN'], MATH='STATS', PERIODS='M') & HELP, FILES
;   FILES = GET_FILES('MODISA',LEVEL='L1A') & HELP, FILES
;   FILES = GET_FILES('MODISA',LEVEL='L2') & HELP, FILES
;   FILES = GET_FILES('MODISA',PROD='CHL',FILE_TYPE='NC') & HELP, FILES
;   FILES = GET_FILES('MUR',LEVEL='L4') & HELP, FILES
;   FILES = GET_FILES('AVHRR',LEVEL='L3') & HELP, FILES
;
; NOTES:
;
;
; COPYRIGHT:
; Copyright (C) 2020, Department of Commerce, National Oceanic and Atmospheric Administration, National Marine Fisheries Service,
;   Northeast Fisheries Science Center, Narragansett Laboratory.
;   This software may be used, copied, or redistributed as long as it is not sold and this copyright notice is reproduced on each copy made.
;   This routine is provided AS IS without any express or implied warranties whatsoever.
;
; AUTHOR:
;   This program was written on July 10, 2020 by Kimberly J. W. Hyde, Northeast Fisheries Science Center | NOAA Fisheries | U.S. Department of Commerce, 28 Tarzwell Dr, Narragansett, RI 02882
;
; MODIFICATION HISTORY:
;   Jul 10, 2020 - KJWH: Initial code developed from GET_SOE_FILES in EDAB_SOE
;   Jul 28, 2020 - KJWH: Added COUNT keyword (default COUNT=0)
;   Jul 31, 2020 - KJWH: Added steps to update the DATERANGE based on the PERIOD for M and M3
;   Aug 06, 2020 - KJWH: Added ZEU to the PRODS case statement
;   Aug 12, 2020 - KJWH: Changed MATH_TYPE to FILE_TYPE
;                        Added NETCDF and NC as file types
;                        Added DIR_NC and DIR_NETCDF options
;                        Now looping through LEVELS to find level specific files (e.g. L1A, L2, L4)
;                        PROD is now not required if the LEVEL is specified because most "LEVEL" files do not have products in their directory or file name
;                        Added (and tested) more examples
;   Oct 15, 2020 - KJWH: Added keyword SST to force the DIR to be !S.SST
;   Oct 23, 2020 - KJWH: Added VERSION keyword to distinguish between different dataset versions or reprocessings
;   Dec 31, 2020 - KJWH: Now if FILETYPE is ANOM and no period is input, all periods will be found
;   Oct 07, 2021 - KJWH: Changed D3 to STACKED
;   Dec 20, 2021 - KJWH: Now if using the default SENSOR_DATES for the daterange and the dataset is active (i.e. the max date is the current date), change the max daterange to be the end of the year
;   Jan 10, 2022 - KJWH: Changed HERMES to GLOBCOLOUR
;   Feb 23, 2022 - KJWH: Now reading DATASETS_MAIN to get some of the default information (such as MAPS and DIRS)
;   May 05, 2022 - KJWH: Updated to work with the new DATASETS organization
;                          Removed SUITES
;                          Now all DATASETS should have a VERSION
;                            The default is to look for the only "version" in the datasets folder; followed by the DATASETS_MAIN information
;   Sep 30, 2022 - KJWH: Added IF FILE_TYPE EQ 'STACKED' AND PER NE 'DD' THEN FILE_TYPE = 'STACKED_STATS'                      
;   Oct 12, 2022 - KJWH: Added IF PER EQ 'D_' THEN PER = '*_' for the STACKED_STATS directories to find the "stat" periods
;                        Change PER for STACKED_FILES to DD_
;   Dec 02, 2022 - KJWH: Changed the default "STACKED" folder to "STACKED_SAVE"
;                        Now using getting the full year when getting the DATERANGE from SENSOR_DATES so that it works with STACKED periods
;   Dec 12, 2022 - KJWH: Updated the OCCCI defaults
;   Dec 14, 2022 - KJWH: Updated D - STACKED parameters
;   Jan 06, 2022 - KJWH: Changed the default directories to STACKED directories
;   Mar 15, 2023 - KJWH: Added option to search for the GROUP prod for files that have multiple products (e.g. RRS)
;                                      Added default NC_MAPS ('SIN' for OCCCI and 'L4' for other products') - may need to update for other datasets
;                                      Changed the default DATERANGE to [] to speed up the file search/date select
;   Apr 20, 2023 - KJWH: Updated GROUP prod output for unrecognized input prods (e.g. CHL1)           
;   Sep 27, 2023 - KJWH: Added a work around to correct the DATERANGE when searching for STACKED files so that they encompass the full year (e.g. change [20230304,20230506] to [20230101,20231231])     
;   Feb 22, 2024 - KJWH: If MAPS EQ '' then convert '' to [] (null) and use the default map
; TODO:
;   Need to overhaul the program
;-
; ****************************************************************************************************
  ROUTINE_NAME = 'GET_FILES'

  COMPILE_OPT IDL2

  SL = PATH_SEP()
  COUNT = 0
  STAGS = TAG_NAMES(!S)
  DTAGS = []
  FOR S=0, N_TAGS(!S)-1 DO IF STRPOS(!S.(S),'DATASETS'+SL) GE 0 THEN DTAGS = [DTAGS,STAGS[S]]
  DTAGS = DTAGS[WHERE(DTAGS NE 'DATASETS')]
  
  IF N_ELEMENTS(ANOMALY_DATASET) EQ 0 THEN ANOM_DAT = DATASETS ELSE ANOM_DAT = ANOMALY_DATASETS
  IF N_ELEMENTS(ANOM_DAT) NE N_ELEMENTS(DATASETS) THEN MESSAGE, 'ERROR: The number of ANOMALY_DATASETS should be ' + NUM2STR(N_ELEMENTS(DATASETS))
  IF N_ELEMENTS(PRODS) EQ 0 THEN PRODS = '' ; AND N_ELEMENTS(LEVELS) EQ 0 THEN MESSAGE, 'ERROR: Must provide at least 1 product name of specify a processing level for the files.'
  IF N_ELEMENTS(PERIODS) EQ 0 THEN PERIOD = 'D' ELSE PERIOD = PERIODS
  IF N_ELEMENTS(LEVELS) EQ 0 THEN LEVELS = ''
  IF N_ELEMENTS(EXT) EQ 0 THEN EXT = 'SAV'
  IF N_ELEMENTS(VERSION) EQ 0 THEN VERSION = '' & IF VERSION NE '' THEN IF IS_NUM(VERSION) THEN VERSION = 'V'+VERSION
  IF N_ELEMENTS(PROD_VERSION) EQ 0 THEN PROD_VERSION = ''
  IF N_ELEMENTS(FILE_TYPE) EQ 0 THEN FILETYPE = [] ELSE FILETYPE = FILE_TYPE
  
  FILES=[]
  FOR D=0, N_ELEMENTS(DATASETS)-1 DO BEGIN
    DAT = STRUPCASE(DATASETS[D])
    OK = WHERE(DTAGS EQ DAT, COUNT)
    IF COUNT EQ 0 THEN BEGIN
      MESSAGE, 'ERROR: ' + DAT + ' dataset directory not found in !S', /CONTINUE
      RETURN, []
    ENDIF
    IF COUNT GT 1 THEN MESSAGE, 'ERROR: More than one dataset directory found'
  
    ; ===> Set up the climatology daterange
    IF ~N_ELEMENTS(CLIMATOLOGY) THEN CLIMATOLOGY = 'DEFAULT'
    CASE CLIMATOLOGY OF
      'FULL': CLIMDTR = GET_DATERANGE(SENSOR_DATES(DAT))
      'DEFAULT': CLIMDTR = GET_DATERANGE(['1991','2020'])
      'ALL': CLIMDTR = []
      ELSE: IF N_ELEMENTS(CLIMATOLOGY) EQ 2 THEN CLIMDTR = GET_DATERANGE(CLIMATOLOGY) ELSE MESSAGE,'ERROR: Must provide a start and end year for the climatology range'
    ENDCASE
    
    ;DS = DATASETS_READ(DAT)
    
; TODO  Need to fix the version (after creating a GET_DIRS function)
    IF VERSION EQ [] THEN VERSION = DS.VERSION


    FOR L=0, N_ELEMENTS(LEVELS)-1 DO BEGIN
      LEVEL = LEVELS[L]
      ; ===> Establish LEVEL specific defaults
      CASE LEVEL OF
        'L1':  BEGIN & EXT='*'  & MAPS='' & PERIOD='' & PRODS='' & FILETYPE='NC' & END
        'L1A': BEGIN & EXT='*'  & MAPS='' & PERIOD='' & PRODS='' & FILETYPE='NC' & END
        'L2':  BEGIN & EXT='*'  & MAPS='' & PERIOD='' & PRODS='' & FILETYPE='NC' & END
        'L3':  BEGIN & EXT='nc' & MAPS='' & PERIOD='' & PRODS='' & FILETYPE='NC' & END
        'L4':  BEGIN & EXT='nc' & MAPS='' & PERIOD='' & FILETYPE='NC' & IF DAT EQ 'OCCCI' THEN MAPS='SIN' & END
        ELSE:
      ENDCASE
      IF N_ELEMENTS(MAPS) EQ 1 THEN IF MAPS[0] EQ '' THEN MAPS = []

      ; ===> Establish the default MAP for each DATASET
      CASE DAT OF
        'OCCCI':      DMAP = 'L3B4'
        'GLOBCOLOUR': DMAP = 'L3B4'
        'AVHRR':      DMAP = 'L3B4'
        'SEASCAPES':  DMAP = 'L3B5'
        'GEOPOLAR':   DMAP = 'L3B5'
        'CORAL': DMAP='L3B5'
        ELSE:         DMAP = 'L3B2'
      ENDCASE
      IF N_ELEMENTS(MAPS) GT 0 THEN DMAP = MAPS
      
      ; ===> Establish the default VERSIONS for each DATASET
      IF VERSION EQ '' THEN BEGIN
        CASE DAT OF
          'OCCCI': VER = 'V6.0';'VERSION_5.0'
          'ACSPO': VER = 'V2.81'
          'ACSPONRT': VER = 'V2.81'
          'GLOBCOLOUR': VER = 'V4.2.1'
          'AVHRR': VER = 'V5.3'
          ELSE: VER = ''
        ENDCASE
      ENDIF ELSE VER = VERSION

      CASE DAT OF
        'OCCCI': BEGIN
          CASE VER OF
            'V6.0': DIR = !S.(WHERE(STAGS EQ DAT,/NULL))
            'V5.0': DIR = !S.ARCHIVE + DAT + SL + 'V5.0' + SL ; (WHERE(STAGS EQ DAT,/NULL))
            'V4.2': DIR = !S.(WHERE(STAGS EQ DAT,/NULL)) ; ARCHIVE + DAT + SL + 'V4.2' + SL
            'V4.0': DIR = !S.ARCHIVE + DAT + SL + 'V4.0' + SL
            'V3.1': DIR = !S.ARCHIVE + DAT + SL + 'V3.0' + SL
          ENDCASE
          IF ~N_ELEMENTS(MAPS) THEN NCMAP = 'SIN' ELSE NCMAP = MAPS
        END
        ELSE: BEGIN & IF ~N_ELEMENTS(MAPS) THEN NCMAP = 'SOURCE_DATA' ELSE NCMAP = MAPS & DIR = !S.(WHERE(STAGS EQ DAT,/NULL))  & END
      ENDCASE

      ; ===> Establish the default NC dirs
      CASE DAT OF 
        'OCCCI': NCSRC = 'BINNED_4KM_DAILY'
        'GLOBCOLOUR': NCSRC = 'BINNED_4KM_DAILY'
        'ACSPO': NCSRC = 'MAPPED_2KM_DAILY'
        'ACSPONRT': NCSRC = 'MAPPED_2KM_DAILY'
        'CORALSST': NCSRC = 'MAPP3D_3KM_DAILY'
        'MUR': NCSRC = 'MAPPED_1KM_DAILY'
        'AVHRR': NCSRC = 'MAPPED_4KM_DAILY'
      ENDCASE

      IF DIR EQ [] THEN MESSAGE, 'ERROR: Unable to find the dataset directory.'


      ; ===> Establish the DATERANGE
      IF N_ELEMENTS(DATERANGE) NE 0 THEN BEGIN
        IF IDLTYPE(DATERANGE) NE 'STRING' THEN DATERANGE = NUM2STR(DATERANGE)
        IF N_ELEMENTS(DATERANGE) EQ 1 THEN IF STRPOS(DATERANGE,'_') GT 0 THEN DATERANGE = STRSPLIT(DATERANGE,'_',/EXTRACT)
        IF N_ELEMENTS(DATERANGE) GT 2 THEN MESSAGE, 'ERROR: ' + DATERANGE + ' is invalid.'
        IF N_ELEMENTS(DATERANGE) EQ 1 THEN BEGIN
          CASE STRLEN(DATERANGE) OF
            4:  DR = [DATERANGE+'0101',DATERANGE+'1231']
            6:  DR = [DATERANGE+'01',DATERANGE+DAYS_MONTH(STRMID(DATERANGE,4,2),YEAR=STRMID(DATERANGE,0,4),/STRING)]
            8:  DR = [DATERANGE,DATERANGE]
            14: DR = STRMID([DATERANGE,DATERANGE],0,8)
            ELSE: MESSAGE, 'ERROR: ' + DATERANGE + ' is invalid.'
          END
        ENDIF ELSE BEGIN
          CASE STRLEN(DATERANGE[0]) OF
            4:  DR = [STRMID(DATERANGE[0],0,4)+'0101',STRMID(DATERANGE[1],0,4)+'1231']
            6:  DR = [STRMID(DATERANGE[0],0,6)+'01',  STRMID(DATERANGE[1],0,6)+DAYS_MONTH(STRMID(DATERANGE[1],4,2),YEAR=STRMID(DATERANGE[1],0,4),/STRING)]
            8:  DR = DATERANGE
            14: DR = STRMID(DATERANGE,0,8)
            ELSE: MESSAGE, 'ERROR: ' + DATERANGE + ' is invalid.'
          ENDCASE
        ENDELSE
      ENDIF ELSE BEGIN
        DR = SENSOR_DATES(DAT,/YEAR)
        IF DR[1] EQ DATE_NOW(/DATE_ONLY) THEN DR[1] = STRMID(DR[1],0,4)+'1231'
DR = []        
      ENDELSE

      FOR M=0, N_ELEMENTS(DMAP)-1 DO BEGIN
        AMAP = DMAP[M]

        FOR P=0, N_ELEMENTS(PRODS)-1 DO BEGIN
          APROD = PRODS[P]
          AALG = VALIDS('ALGS',APROD)
          PRDSTR = PRODS_READ(PRODS[P])
          GPROD='' & IF PRDSTR NE [] THEN GPROD = PRDSTR.GROUP_PROD & IF AALG NE '' THEN GPROD = GPROD + '-' + AALG  ; Get the "group" product name if needed to find files
          IF ~N_ELEMENTS(DIR_DATA) THEN DIR_DAT = DIR ELSE DIR_DAT = DIR_DATA
    
          IF VER NE '' THEN BEGIN
            VDIR = FILE_SEARCH(DIR_DAT + VER + SL,/MARK_DIRECTORY,COUNT=CVD)
            IF CVD EQ 1 THEN DIR_DAT = DIR_DAT +VER + SL
            IF FILE_TEST(DIR_DAT,/DIR) EQ 0 THEN MESSAGE, 'ERROR: VERSION directory does not exists.'
            IF CVD GT 1 THEN MESSAGE, 'ERROR: More than one VERSION directory exists'
          ENDIF 
          NDIR_DAT = REPLACE(DIR_DAT,!S.DATASETS,!S.DATASETS_SOURCE)
          
          IF PROD_VERSION NE '' THEN PVER = PROD_VERSION + SL ELSE PVER = ''

          DIR_SAVE           = DIR_DAT + AMAP + SL + 'SAVE'            + SL + PVER + APROD + SL
          DIR_GSAVE          = DIR_DAT + AMAP + SL + 'SAVE'            + SL + PVER + GPROD + SL
          DIR_STATS          = DIR_DAT + AMAP + SL + 'STATS'           + SL + PVER + APROD + SL
          DIR_STATS_LTM      = DIR_DAT + AMAP + SL + 'STATS_LTM'       + SL + PVER + APROD + SL
          DIR_ANOMS          = DIR_DAT + AMAP + SL + 'ANOMS'           + SL + PVER + APROD + SL
          DIR_ANOMS_LTM      = DIR_DAT + AMAP + SL + 'ANOMS_LTM'       + SL + PVER + APROD + SL
          DIR_INTERP         = DIR_DAT + AMAP + SL + 'INTERP_SAVE'     + SL + PVER + APROD + SL
          DIR_NETCDF         = DIR_DAT + AMAP + SL + 'NETCDF'          + SL + PVER + APROD + SL
          DIR_STACKED        = DIR_DAT + AMAP + SL + 'STACKED_SAVE'    + SL + PVER + APROD + SL
          DIR_GSTACKED       = DIR_DAT + AMAP + SL + 'STACKED_SAVE'    + SL + PVER + GPROD + SL
          DIR_STACKED_INTERP = DIR_DAT + AMAP + SL + 'STACKED_INTERP'  + SL + PVER + APROD + SL
          DIR_STACKED_TEMP   = DIR_DAT + AMAP + SL + 'STACKED_TEMP'    + SL + PVER + APROD + SL
          DIR_STACKED_STATS  = DIR_DAT + AMAP + SL + 'STACKED_STATS'   + SL + PVER + APROD + SL
          DIR_STACKED_ANOMS  = DIR_DAT + AMAP + SL + 'STACKED_ANOMS'   + SL + PVER + APROD + SL
          DIR_NC             = REPLACE(NDIR_DAT,'DATASETS','DATASETS_SOURCE') + NCMAP + SL + NCSRC + SL + LEVEL + SL + PVER + APROD + SL & WHILE STRPOS(DIR_NC,SL+SL) GE 0 DO DIR_NC = REPLACE(DIR_NC,SL+SL,SL)

          FOR R=0, N_ELEMENTS(PERIOD)-1 DO BEGIN
            PER = PERIOD[R]
            PSTR = PERIODS_READ(PER)
            IF KEYWORD_SET(PSTR.CLIMATOLOGY) THEN DTR = GET_DATERANGE(STRMID(SENSOR_DATES(DAT),0,4)) ELSE DTR = DR
            CASE PER OF
              'W':  BEGIN & APER='W_*WEEK'    & END
              'M':  BEGIN & APER='M_*MONTH'   & IF DR NE [] THEN DTR = GET_DATERANGE(STRMID(DR,0,6)) & END
              'A':  BEGIN & APER='A_*ANNUAL'  & END
              'D':  BEGIN & APER='D_DOY'      & END
              'M3': BEGIN & APER='M3_*MONTH3' & IF DR NE [] THEN DTR = GET_DATERANGE(STRMID(DR,0,6)) & END
              'MONTH': BEGIN & APER=PER       & DTR = [] & END
              'WEEK':  BEGIN & APER=PER       & DTR = [] & END
              ELSE:    BEGIN & APER=PER       & END
            ENDCASE

            IF N_ELEMENTS(FILETYPE) EQ 0 THEN BEGIN
              CASE 1 OF
                PER EQ 'D':           FILETYPE = 'STACKED_SAVE'
                PER EQ 'DD':          FILETYPE = 'STACKED_SAVE'
                STRPOS(PER,'_') GT 0: FILETYPE = 'STACKED_ANOM'
                PER EQ '':            FILETYPE = 'NC'
                ELSE:                 FILETYPE = 'STACKED_STATS'
              ENDCASE
            ENDIF
            
            IF FILETYPE EQ 'STACKED_SAVE' AND PER EQ 'D' THEN PER = 'DD'
            IF FILETYPE EQ 'STACKED' AND PER EQ 'D' THEN PER = 'DD'
            IF FILETYPE EQ 'STACKED' AND PER NE 'DD' THEN FILETYPE = 'STACKED_STATS'
            
            IF PER NE '' THEN BEGIN
              IF HAS(FILETYPE,'STACKED') AND PER NE 'D' THEN PER = PSTR.STACKED_PERIOD_OUTPUT 
              PER = PER + '_' ; Add an underscore after then period to avoid conflicts such as M and MONTH
            ENDIF
            
            IF N_ELEMENTS(DAYNIGHT) EQ 1 THEN DN = DAYNIGHT ELSE DN = ''
            
            FOR T=0, N_ELEMENTS(FILETYPE)-1 DO BEGIN
              CASE STRUPCASE(FILETYPE[T]) OF
                'SAVE':          BEGIN & DIR_SEARCH = DIR_SAVE & END
                'SAV':           BEGIN & DIR_SEARCH = DIR_SAVE & END
                'ANOM':          BEGIN & DIR_SEARCH = DIR_ANOMS & PER = APER & IF N_ELEMENTS(PERIODS) EQ 0 THEN PER = '' & END
                'ANOMS':         BEGIN & DIR_SEARCH = DIR_ANOMS & PER = APER & IF N_ELEMENTS(PERIODS) EQ 0 THEN PER = '' & END
                'ANOMS_LTM':     BEGIN & DIR_SEARCH = DIR_ANOMS_LTM & END
                'STAT':          BEGIN & DIR_SEARCH = DIR_STATS & IF PER EQ 'D_' THEN PER = '*_' & END
                'STATS':         BEGIN & DIR_SEARCH = DIR_STATS & IF PER EQ 'D_' THEN PER = '*_' & END
                'STATS_LTM':     BEGIN & DIR_SEARCH = DIR_STATS_LTM & END
                'INTERP':        BEGIN & DIR_SEARCH = DIR_INTERP & END
                'INTERP_SAVE':        BEGIN & DIR_SEARCH = DIR_INTERP & END
                'STACKED':       BEGIN & DIR_SEARCH = DIR_STACKED & IF PER EQ 'D_' THEN PER = 'DD_' & END
                'STACKED_SAVE':  BEGIN & DIR_SEARCH = DIR_STACKED & IF PER EQ 'D_' THEN PER = 'DD_' & END
                'STACKED_INTERP':BEGIN & DIR_SEARCH = DIR_STACKED_INTERP & IF PER EQ 'D_' THEN PER = 'DD_' & END
                'STACKED_TEMP':  BEGIN & DIR_SEARCH = DIR_STACKED_TEMP & IF PER EQ 'D_' THEN PER = '*_' & END
                'STACKED_STATS': BEGIN & DIR_SEARCH = DIR_STACKED_STATS & IF PER EQ 'D_' THEN PER = '*_' & END
                'STACKED_ANOMS': BEGIN & DIR_SEARCH = DIR_STACKED_ANOMS & IF PER EQ 'D_' THEN PER = '*_' & END
                'NETCDF':        BEGIN & DIR_SEARCH = DIR_NETCDF & EXT = 'nc' & END
                'NC':            BEGIN & DIR_SEARCH = DIR_NC & IF EXT EQ 'SAV' THEN EXT = '*' & PER = '' & END
                ELSE: MESSAGE,'ERROR: Unrecognized FILETYPE'
              ENDCASE

              IF ~FILE_TEST(DIR_SEARCH,/DIR) THEN BEGIN
                IF DIR_SEARCH EQ DIR_SAVE THEN FT = FILE_TEST(DIR_GSAVE,/DIR) ELSE FT = 0
                IF DIR_SEARCH EQ DIR_STACKED THEN FTG = FILE_TEST(DIR_GSTACKED,/DIR) ELSE FTG = 0
                IF FT EQ 0 AND FTG EQ 0 THEN MESSAGE, 'ERROR: ' + DIR_SEARCH + ' does not exist',/CONTINUE 
                IF FT EQ 1 THEN DIR_SEARCH = DIR_GSAVE
                IF FTG EQ 1 THEN DIR_SEARCH = DIR_GSTACKED
              ENDIF  
              
              IF HAS(DIR_SEARCH,'STACKED') AND DTR NE [] THEN DTR = GET_DATERANGE(DATE_2YEAR(DTR[0]),DATE_2YEAR(DTR[1]))  ; Make sure the DATERANGE is the full year when searching for STACKED files
              IF KEYWORD_SET(PSTR.CLIMATOLOGY) OR HAS(DIR_SEARCH,'STACKED_ANOMS') THEN BEGIN
                IF KEYWORD_SET(PSTR.CLIMATOLOGY) THEN BEGIN
                  FILE = FLS(DIR_SEARCH + PER + '*' + DN + '.' + EXT,COUNT=CTCFILES)
                  IF CTCFILES GT 0 AND CLIMATOLOGY NE 'ALL' THEN BEGIN
                    CFP = PARSE_IT(FILE)
                    OK = WHERE(CFP.YEAR_START GE DATE_2YEAR(CLIMDTR[0]) AND CFP.YEAR_END EQ DATE_2YEAR(CLIMDTR[1]),COUNTCLIM)
                    IF COUNTCLIM EQ 0 AND APER EQ 'ANNUAL' THEN OK = WHERE(CFP.YEAR_START GE DATE_2YEAR(CLIMDTR[0]) AND CFP.YEAR_END EQ DATE_2YEAR(CLIMDTR[1])-1,COUNTCLIM)
                    IF COUNTCLIM EQ 1 THEN FILE = FILE[OK] ELSE MESSAGE, 'ERROR: Correct climatology file not found'
                  ENDIF
                ENDIF
                IF HAS(DIR_SEARCH,'STACKED_ANOMS') THEN BEGIN
                  AFILES = FLS(DIR_SEARCH + PER + '*' + DN + '.' + EXT, DATERANGE=DTR)
                  AFP = PARSE_IT(AFILES)
                  ADP = PERIOD_2STRUCT(AFP.SECOND_PERIOD)
                  CASE CLIMATOLOGY OF
                    'ALL': FILE = AFILES
                    ELSE: BEGIN
                       OK = WHERE(ADP.YEAR_START GE DATE_2YEAR(CLIMDTR[0]) AND ADP.YEAR_END EQ DATE_2YEAR(CLIMDTR[1]),COUNTCLIM)
                       IF COUNTCLIM EQ 0 AND ADP[0].PERIOD_CODE EQ 'ANNUAL' THEN OK = WHERE(ADP.YEAR_START GE DATE_2YEAR(CLIMDTR[0]) AND ADP.YEAR_END EQ DATE_2YEAR(CLIMDTR[1])-1,COUNTCLIM)
                       IF COUNTCLIM GT 0 THEN FILE = AFILES[OK] ELSE FILE = [] 
                    END
                  ENDCASE
                ENDIF
              ENDIF ELSE FILE = FLS(DIR_SEARCH + PER + '*' + DN + '.' + EXT, DATERANGE=DTR)
              FILES = [FILES,FILE]
              GONE, FILE
            ENDFOR ; FILETYPE
          ENDFOR ; PERIOD
        ENDFOR ; PRODS
      ENDFOR ; MAPS
    ENDFOR ; LEVELS
  ENDFOR ; DATASETS
  COUNT = N_ELEMENTS(FILES)
  IF N_ELEMENTS(PERIODS) GT 0 THEN PERSTR = 'for PERIODS  -  ' + STRJOIN(PERIODS,'; ') ELSE PERSTR = ''
  IF DTR NE [] THEN SDTR = STRJOIN(DTR,'-') ELSE SDTR = ''
  IF COUNT EQ 0  THEN PRINT, 'No files found in ' + DIR_SEARCH + PERSTR + ' (' + SDTR + ')'
  RETURN, FILES

END ; ************************************* END OF PROGRAM *******************************************

