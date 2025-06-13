; $ID:	EDAB_SOE.PRO,	2021-04-15-17,	USER-KJWH	$

FUNCTION EDAB_SOE_GET_FILES, PRODS=PRODS, DATASETS=DATASETS, PERIODS=PERIODS, PPD_PAN=PPD_PAN, YEARS=YEARS, ALLYEARS=ALLYEARS, STATS_ONLY=STATS_ONLY
  SL = PATH_SEP()
  FILES=[]
  FOR D=0, N_ELEMENTS(DATASETS)-1 DO BEGIN
    SPRODS = PRODS
    DAT = DATASETS(D)
    CLIM_ONLY = 0
    CASE DAT OF
      'SEAWIFS': BEGIN & DR = ['1997','2007']     & AMAP = 'L3B2' & ANOM_DAT = ['SA','SAV','SAVJ'] & END
      'MODISA':  BEGIN & DR = ['2008',MAX(YEARS)] & AMAP = 'L3B2' & ANOM_DAT = ['SA','SAV','SAVJ'] & END
      'VIIRS':   BEGIN & DR = ['2012',MAX(YEARS)] & AMAP = 'L3B2' & ANOM_DAT = ['SAV','SAVJ']      & END
      'JPSS1':   BEGIN & DR = ['2017',MAX(YEARS)] & AMAP = 'L3B2' & ANOM_DAT = ['SAVJ']            & END
      'OCCCI':   BEGIN & DR = ['1997',MAX(YEARS)] & AMAP = 'L3B4' & ANOM_DAT = 'OCCCI' & END
      'SA':      BEGIN & DR = ['1997',MAX(YEARS)] & AMAP = 'L3B2' & ANOM_DAT = 'SA'  & CLIM_ONLY = 0      & END
      'SAV':     BEGIN & DR = ['1997',MAX(YEARS)] & AMAP = 'L3B2' & ANOM_DAT = 'SAV'  & CLIM_ONLY = 0      & END
      'SAVJ':    BEGIN & DR = ['1997',MAX(YEARS)] & AMAP = 'L3B2' & ANOM_DAT = 'SAVJ'  & CLIM_ONLY = 0      & END
      'MUR':     BEGIN & DR = ['2002',MAX(YEARS)] & AMAP = 'L3B2' & ANOM_DAT = 'MUR' & SPRODS='SST' & END
      'AVHRR':   BEGIN & DR = ['1997',MAX(YEARS)] & AMAP = 'L3B4' & ANOM_DAT = 'AVHRR' & SPRODS='SST' & END
    ENDCASE
    IF KEY(ALLYEARS) THEN DR = ['1997',MAX(YEARS)]
    IF N_ELEMENTS(YEARS) EQ 1 THEN DR = YEARS
    IF KEY(PPD_PAN) THEN PDAT = REPLACE(DAT,'_PAN','') ELSE PDAT = DAT

    FILES = []
    FOR P=0, N_ELEMENTS(PRODS)-1 DO BEGIN
      APROD = PRODS(P)
      CASE VALIDS('PRODS',APROD) OF
        'PPD': DIR = !S.PP
        'SST': DIR = !S.SST
        ELSE:  DIR = !S.OC
      ENDCASE

      DIR_STAT  = DIR  + DAT      + SL + AMAP + SL + 'STATS' + SL + APROD + SL
      DIR_ANOM  = DIR  + ANOM_DAT + SL + AMAP + SL + 'ANOMS' + SL + APROD + SL ; V2018_2 Changed the anomalies from single sensor to SA for SeaWiFS and MODISA

      FOR R=0, N_ELEMENTS(PERIODS)-1 DO BEGIN
        PER = PERIODS[R]
        CASE PER OF
          'W': BEGIN & APER='W_*WEEK'   & CLIM = 0 & END
          'M': BEGIN & APER='M_*MONTH'  & CLIM = 0 & END
          'A': BEGIN & APER='A_*ANNUAL' & CLIM = 0 & END
          'M3': BEGIN & APER='M3_*MONTH3' & CLIM = 0 & END
          'WEEK': BEGIN & APER = '' & CLIM = 0 & END
          'MONTH': BEGIN & APER = '' & CLIM = 1 & END
          'ANNUAL': BEGIN & APER = '' & CLIM = 1 & END  
          'MONTH3': BEGIN & APER = '' & CLIM = 1 & END
        ENDCASE
        
        IF KEY(CLIM_ONLY) AND ~KEY(CLIM) THEN CONTINUE
        IF ~KEY(CLIM_ONLY) AND KEY(CLIM) AND DAT NE 'OCCCI' THEN CONTINUE

        FLS = FLS(DIR_STAT + PER + '_*STATS*SAV',    DATERANGE=DR)
        IF APER NE '' AND ~KEY(STATS_ONLY) THEN FLS = [FLS,FLS([DIR_ANOM] +APER + '*_*-' +DAT+'*SAV',DATERANGE=DR)]
        FILES = [FILES,FLS]
        GONE, FLS
      ENDFOR ; PERIODS
    ENDFOR ; PRODS
  ENDFOR ; DATASETS
  RETURN, FILES
END    



PRO EDAB_SOE, SOE_YEAR

;+
; NAME:
;		EDAB_SOE
;
; PURPOSE:;
;		MAIN program for creating data and figures for EDAB's State of the Ecosystem (SOE) reports
;
; CATEGORY:
;		MAIN
;
; CALLING SEQUENCE:
;
;	ROUTINE_NAME
;
; INPUTS:
;
; OPTIONAL INPUTS:
;
; KEYWORD PARAMETERS:
;
; OUTPUTS:
;		This function creates data and plots for EDAB SOE reports
;
;	NOTES:
;
;
; MODIFICATION HISTORY:
;			Written November 22, 2017 by K.J.W.Hyde, 28 Tarzwell Drive, NMFS, NOAA 02882 (kimberly.hyde@noaa.gov)
;			Modified: Feb 05, 2019 - KJWH: Added function to find specific files for each step
;			                               Updated the ANNUAL_COMPS step
;-
  ;	****************************************************************************************************
  ROUTINE_NAME = 'EDAB_SOE'


  SL = PATH_SEP()
  DIR_PROJECTS = !S.PROJECTS + 'EDAB' + SL + 'SOE' + SL

  BUFFER = 1
  VERBOSE = 0
  OMAP = 'NES' 
  SUBAREA = 'NES_EPU_NOESTUARIES';'NES_STATISTICAL_AREAS_NAMES'; 'NES_EPU_NOESTUARIES'
  NAMES = ['GOM','GB','MAB']
  SUBTITLES = ['Gulf of Maine','Georges Bank','Mid-Atlantic Bight']
  
  IF NONE(SOE_YEAR) THEN SOE_YEAR = '2021'
  FOR SYR=0, N_ELEMENTS(SOE_YEAR)-1 DO BEGIN ; Loop through the various years
    SOE_YR = SOE_YEAR(SYR)
    CASE SOE_YR OF
      '2021': BEGIN
        VERSION = 'V2021'
        PPD_PAN = 0
        DATE_RANGE = ['19980101','20191231']
  ;      D_PRODS = ['SST','CHLOR_A-OCI','CHLOR_A-PAN','PAR','PPD-VGPM2','MICRO_PERCENTAGE-PAN','NANO_PERCENTAGE-PAN','PICO_PERCENTAGE-PAN','MICRO_PERCENTAGE-HIRATA','NANO_PERCENTAGE-HIRATA','PICO_PERCENTAGE-HIRATA','MICRO_PERCENTAGE-UITZ','NANO_PERCENTAGE-UITZ','PICO_PERCENTAGE-UITZ']
  ;      SOE_PRODS = ['SST','CHLOR_A-PAN','PAR','PPD-VGPM2']
  ;      D_SATS = ['MUR','AVHRR','SAV','SEAWIFS','MODISA']
  ;      D_PERIODS = ['M','M3','MONTH3','MONTH','A','ANNUAL']
        MAKE_NETCDFS        = 'Y'
        DATA_EXTRACTS       = '';Y[MUR;PER=M]';Y';Y_' + STRJOIN(DATE_RANGE,'_')
        PP_REQ_EXTRACTS     = ''
        PP_REQUIRED         = '' ; Extract and calculate the annual PP data for the Primary Production Required (or Fisheries Production Potential) model
        ANNUAL_COMPOSITE    = '';Y[SEAWIFS_MODISA]';Y_' + STRJOIN(DATE_RANGE,'_') ; Create maps and subarea extracted plots for each year
        ANNUAL_COMPARE      = '';Y';Y_' + STRJOIN(DATE_RANGE,'_')                 ; Create maps and subarea extracted plots to compare between sensors
        COMPARE_PRODS       = '' ; Run COMPARE_SAT_PRODS and COMPARE_SAT_SENSORS to compare data
        MONTHLY_TIMESERIES  = ''
        WEEKLY_ANOMS        = '';Y';Y_' + STRJOIN(DATE_RANGE,'_')
        SEASONAL_COMPS      = ''
        PFT_COMPS           = ''
        ANOMALY_MAP         = ''
        PERCENT_PRODUCTION  = ''
        MOVIES              = ''
      END
      '2020': BEGIN
        VERSION = 'V2020_OSM'
        PPD_PAN = 0
        DATE_RANGE = ['19980101','20181231']
        D_PRODS = ['SST','CHLOR_A-OCI','CHLOR_A-PAN','PAR','PPD-VGPM2','MICRO_PERCENTAGE-PAN','NANO_PERCENTAGE-PAN','PICO_PERCENTAGE-PAN','MICRO_PERCENTAGE-HIRATA','NANO_PERCENTAGE-HIRATA','PICO_PERCENTAGE-HIRATA','MICRO_PERCENTAGE-UITZ','NANO_PERCENTAGE-UITZ','PICO_PERCENTAGE-UITZ']
        SOE_PRODS = ['SST','CHLOR_A-PAN','PAR','PPD-VGPM2']
        D_SATS = ['MUR','AVHRR','SAV','SEAWIFS','MODISA']
        D_PERIODS = ['M','M3','MONTH3','MONTH','A','ANNUAL']
        MAKE_NETCDFS        = ''
        DATA_EXTRACTS       = '';Y';Y_' + STRJOIN(DATE_RANGE,'_')
        PP_REQ_EXTRACTS     = ''
        PP_REQUIRED         = '' ; Extract and calculate the annual PP data for the Primary Production Required (or Fisheries Production Potential) model
        ANNUAL_COMPOSITE    = '';Y[SEAWIFS_MODISA]';Y_' + STRJOIN(DATE_RANGE,'_') ; Create maps and subarea extracted plots for each year
        ANNUAL_COMPARE      = '';Y';Y_' + STRJOIN(DATE_RANGE,'_')                 ; Create maps and subarea extracted plots to compare between sensors
        COMPARE_PRODS       = '' ; Run COMPARE_SAT_PRODS and COMPARE_SAT_SENSORS to compare data
        MONTHLY_TIMESERIES  = ''
        WEEKLY_ANOMS        = '';Y';Y_' + STRJOIN(DATE_RANGE,'_')
        SEASONAL_COMPS      = ''
        ANOMALY_MAP         = ''
        PERCENT_PRODUCTION  = ''
        MOVIES              = ''
      END
        
      '2019': BEGIN
        VERSION = 'V2019_2'
        PPD_PAN = 0
        DATE_RANGE = ['19980101','20191231']
        SATS = ['SEAWIFS','MODISA','OCCCI','SA']
        D_PRODS = ['CHLOR_A-PAN','PPD-VGPM2']
        MAKE_NETCDFS        = ''
        DATA_EXTRACTS       = '';Y';Y_' + STRJOIN(DATE_RANGE,'_')
        ANNUAL_COMPOSITE    = '';Y[SEAWIFS_MODISA]';Y_' + STRJOIN(DATE_RANGE,'_') ; Create maps and subarea extracted plots for each year 
        ANNUAL_COMPARE      = '';Y';Y_' + STRJOIN(DATE_RANGE,'_')                 ; Create maps and subarea extracted plots to compare between sensors
        COMPARE_PRODS       = '' ; Run COMPARE_SAT_PRODS and COMPARE_SAT_SENSORS to compare data 
        MONTHLY_TIMESERIES  = ''
        WEEKLY_ANOMS        = '';Y';Y_' + STRJOIN(DATE_RANGE,'_')
        SEASONAL_COMPS      = ''
        ANOMALY_MAP         = ''
      END
            
      '2018': BEGIN
        ANOMALY_MAP         = ''
        TIMESERIES_PLOTS    = ''
        DATA_EXTRACTS       = ''
        PERCENT_PRODUCTION  = ''
        SST_FILES_FOR_VINCE = ''
      END  
      
      '2017': BEGIN
        ANOMALY_MAP         = ''
        TIMESERIES_PLOTS    = ''
        DATA_EXTRACTS       = ''
        PERCENT_PRODUCTION  = ''
        SST_FILES_FOR_VINCE = ''
      END  
    ENDCASE
    
    IF NONE(D_PRODS) THEN PRODS = ['CHLOR_A-PAN','PPD-VGPM2'] ELSE PRODS = D_PRODS
    IF NONE(D_PERIODS) THEN PERIODS = ['M','A','W','WEEK','MONTH','ANNUAL'] ELSE PERIODS = D_PERIODS
    IF NONE(D_SATS) THEN SATS = ['SEAWIFS','MODISA','VIIRS','JPSS1','SAVJ'] ELSE SATS = D_SATS
    
    
        
    YEARS      = YEAR_RANGE(DATE_RANGE[0],DATE_RANGE[1],/STRING)
    SPLABEL    = 'OC_PP-STATS_ANOMS-'+VERSION
    DIR_PRO    = DIR_PROJECTS + VERSION + SL
    DIR_CDF    = DIR_PRO + 'NETCDF'        + SL & DIR_TEST, DIR_CDF
    DIR_DATA   = DIR_PRO + 'DATA_EXTRACTS' + SL & DIR_TEST, DIR_DATA
    DIR_PPREQ  = DIR_PRO + 'PPD_REQUIRED'  + SL & DIR_TEST, DIR_PPREQ
    DIR_COMP   = DIR_PRO + 'COMPOSITES'    + SL & DIR_TEST, DIR_COMP
    DIR_PNGS   = DIR_PRO + 'PNGS'          + SL & DIR_TEST, DIR_PNGS
    DIR_PLOTS  = DIR_PRO + 'PLOTS'         + SL & DIR_TEST, DIR_PLOTS
    DIR_MOVIE  = DIR_PRO + 'MOVIES'        + SL & DIR_TEST, DIR_MOVIE
    DIR_THUMBS = DIR_PRO + 'THUMBNAILS'    + SL & DIR_TEST, DIR_THUMBS
    DATFILE    = DIR_DATA + STRJOIN(DATE_RANGE,'_') + '-' + STRJOIN(SATS,'_') + '-' + SUBAREA + '-' + SPLABEL +  '.SAV'
    
    SHPS = READ_SHPFILE(SUBAREA, MAPP=OMAP, ATT_TAG=ATT_TAG, COLOR=COLOR, VERBOSE=VERBOSE, NORMAL=NORMAL, AROUND=AROUND)
    EPU_OUTLINE = []
    FOR F=0, N_ELEMENTS(NAMES)-1 DO BEGIN
      POS = WHERE(TAG_NAMES(SHPS) EQ STRUPCASE(NAMES(F)),/NULL)
      EPU_OUTLINE = [EPU_OUTLINE,SHPS.(POS).OUTLINE]
    ENDFOR


;||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
;||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
;||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||


; ********************************************************
    IF KEY(MAKE_NETCDFS) THEN BEGIN
; ********************************************************
      SWITCHES,MAKE_NETCDFS,STOPP=STOPP,OVERWRITE=OVERWRITE,VERBOSE=VERBOSE,DATERANGE=DATERANGE

      IF NONE(D_PRODS) THEN PRODS = ['PAR','CHLOR_A-CCI','PPD-VGPM2'] ELSE PRODS = D_PRODS
      FOR R=0, N_ELEMENTS(PRODS)-1 DO BEGIN
        
        IF NONE(D_PERIODS) THEN PERIODS = ['M3'];,'M','A','W','WEEK','MONTH','ANNUAL'] ELSE PERIODS = D_PERIODS
        FOR D=0, N_ELEMENTS(PERIODS)-1 DO BEGIN
        
          IF PRODS[R] EQ 'PAR' THEN DATASETS = ['SAVJ'] ELSE DATASETS = ['OCCCI']
          FOR S=0, N_ELEMENTS(DATASETS)-1 DO BEGIN
            DATASET = DATASETS(S)
            DIR_OUT = DIR_CDF + STRJOIN([PERIODS[D],PRODS[R],DATASET],'_') + SL & DIR_TEST, DIR_OUT
            DIR_PNG = REPLACE(DIR_OUT,'NETCDF','PNGS') & DIR_TEST, DIR_PNG
            FILES = GET_FILES(DATASET, PRODS=PRODS[R], PERIODS=PERIODS[D])
            
            IF FILES NE [] THEN WRITE_NETCDF, FILES, DIR_OUT=DIR_OUT, MAP_OUT='NESGRID4'

          ENDFOR ; SATS
        ENDFOR ; PERIODS
      ENDFOR ; PRODS    
    ENDIF  


; ********************************************************
    IF KEY(DATA_EXTRACTS) THEN BEGIN
; ********************************************************
      SWITCHES,DATA_EXTRACTS,DATASETS=DATASETS,OVERWRITE=OVERWRITE,DPERIODS=DPERS,R_FILES=R_FILES,VERBOSE=VERBOSE,DATERANGE=DATERANGE      
      
      
      EFILES = [] 
      IF NONE(DATASETS) THEN DSETS = SATS ELSE DSETS = DATASETS 
      IF KEY(R_FILES) THEN DSETS = REVERSE(DSETS)
      IF NONE(DPERS) THEN PERIODS=D_PERIODS ELSE PERIODS=DPERS
  OSTATS = ['N','MEAN','VAR','SKEW']    
  STATS_ONLY = 1
  SPLABEL = 'SST-STATS-V2021'
      FOR S=0, N_ELEMENTS(DSETS)-1 DO BEGIN
        DATASET = DSETS(S)
        FILES = EDAB_SOE_GET_FILES(PRODS=PRODS, DATASETS=DATASET, PERIODS=PERIODS, PPD_PAN=PPD_PAN, YEARS=YEARS, /ALLYEARS, STATS_ONLY=STATS_ONLY)
        SAV = DIR_DATA + DATASET + '-' + SUBAREA + '-' + SPLABEL + '-' + ROUTINE_NAME + '_' + VERSION + '.SAV'
        SUBAREAS_EXTRACT, FILES, SHP_NAME=SUBAREA, INIT=INIT, VERBOSE=VERBOSE, DIR_OUT=DIR_DATA, STRUCT=STR, SAVEFILE=SAV, OUTPUT_STATS=OSTATS
        EFILES = [EFILES,SAV]
        IF S EQ 0 THEN STRUCT = STR ELSE STRUCT = STRUCT_CONCAT(STRUCT,STR)
      ENDFOR ; DSETS     
       
      IF FILE_MAKE(EFILES,DATFILE,OVERWRITE=OVERWRITE) EQ 1 THEN BEGIN
        SAVE, STRUCT, FILENAME=DATFILE ; ===> SAVE THE MERGED DATAFILE
        SAVE_2CSV, DATFILE
      ENDIF 
      
      
      IF KEY(PP_REQ_EXTRACTS) THEN BEGIN
        PSATS = ['SEAWIFS','MODISA']
        PPRODS = 'PPD-VGPM2'
        PPERIODS = 'A'
        PSUBAREA = 'NES_EPU_STATISTICAL_AREAS'
        PDATFILE = DIR_DATA + STRJOIN(DATE_RANGE,'_') + '-' + STRJOIN(PSATS,'_') + '-' + PSUBAREA + '-' + PPRODS +  '.SAV'
        FOR S=0, N_ELEMENTS(PSATS)-1 DO BEGIN
          DATASET = PSATS(S)
          CASE DATASET OF
            'SEAWIFS': YRS = YEARS[WHERE(YEARS GE '1998' AND YEARS LE '2007')]
            'MODISA': YRS = YEARS[WHERE(YEARS GE '2008' AND YEARS LE '2020')]
          ENDCASE
          FILES = EDAB_SOE_GET_FILES(PRODS=PPRODS, DATASETS=DATASET, PERIODS=PPERIODS, PPD_PAN=PPD_PAN, YEARS=YRS, /STATS_ONLY)
          SAV = DIR_DATA + DATASET + '-' + PSUBAREA + '-' + SPLABEL + '-' + ROUTINE_NAME + '_' + VERSION + '.SAV'
          SUBAREAS_EXTRACT, FILES, SHP_NAME=PSUBAREA, INIT=INIT, VERBOSE=VERBOSE, DIR_OUT=DIR_DATA, STRUCT=STR, SAVEFILE=SAV
          EFILES = [EFILES,SAV]
          IF S EQ 0 THEN STRUCT = STR ELSE STRUCT = STRUCT_CONCAT(STRUCT,STR)
        ENDFOR ; SATS

        IF FILE_MAKE(EFILES,PDATFILE,OVERWRITE=OVERWRITE) EQ 1 THEN BEGIN
          SAVE, STRUCT, FILENAME=PDATFILE ; ===> SAVE THE MERGED DATAFILE
          SAVE_2CSV, PDATFILE
        ENDIF
      ENDIF
       
      
; ===> CONVERT THE EXTRACTED DATA TO THE SOE FORMAT      
      
      IF NONE(SOE_PRODS) THEN S_PRODS = ['CHLOR_A-PAN','PAR','PPD-VGPM2'] ELSE S_PRODS = SOE_PRODS
      
      SEA_SOURCE = 'https://oceandata.sci.gsfc.nasa.gov/SeaWiFS/'
      MOD_SOURCE = 'https://oceandata.sci.gsfc.nasa.gov/MODIS-Aqua/'
      VIR_SOURCE = 'https://oceandata.sci.gsfc.nasa.gov/MODIS-Aqua/'
      JPS_SOURCE = 'https://oceandata.sci.gsfc.nasa.gov/MODIS-Aqua/'
      SA_SOURCE  =  STRJOIN([SEA_SOURCE,MOD_SOURCE],'; ')
      SAV_SOURCE =  STRJOIN([SEA_SOURCE,MOD_SOURCE,VIR_SOURCE],'; ')
      SAJ_SOURCE =  STRJOIN([SEA_SOURCE,MOD_SOURCE,VIR_SOURCE,JPS_SOURCE],'; ')
      OCC_SOURCE = 'http://www.esa-oceancolour-cci.org/'
      AVH_SOURCE = 'https://www.nodc.noaa.gov/satellitedata/pathfinder4km53/'
      MUR_SOURCE = 'https://podaac.jpl.nasa.gov/dataset/MUR-JPL-L4-GLOB-v4.1'
      SST_SOURCE = STRJOIN([AVH_SOURCE,MUR_SOURCE])
      
      PALG = STRUCT.PROD + '-' + STRUCT.ALG 
      B = WHERE_SETS(PALG)
      FOR PR=0, N_ELEMENTS(B)-1 DO BEGIN
        APROD = B(PR).VALUE
        IF STRPOS(APROD,'-') EQ STRLEN(APROD) THEN APROD = STRMID(APROD,0,STRLEN(APROD)-1)
        IF HAS(S_PRODS,APROD) EQ 0 THEN CONTINUE  
        DATASETS = ['SEAWIFS_MODIS','SAVJ','SEAWIFS_MODIS_VIIRS','OCCCI']
        SEN = STRUCT.SENSOR
        FOR DTH=0, N_ELEMENTS(DATASETS)-1 DO BEGIN
            
          SPLABEL = APROD + '-STATS_ANOMS-' + DATASETS(DTH)
          EXTRACTED_FINAL = DIR_DATA + 'SOE_' + VERSION + '-' + SUBAREA + '-' + SPLABEL + '.CSV'
          DFILE = DIR_DATA + STRJOIN(DATE_RANGE,'_') + '-' + DATASETS(DTH) + '-SUBSET-' + SUBAREA + '-' + SPLABEL +  '.SAV'
          IF FILE_MAKE(DATFILE,DFILE,OVERWRITE=OVERWRITE) EQ 1 THEN BEGIN
            STR = []
            CASE DATASETS(DTH)  OF
              'OCCCI': STR = STRUCT[WHERE(SEN EQ 'OCCCI',/NULL)]
              'SAVJ':  STR = STRUCT[WHERE(SEN EQ 'SAVJ',/NULL)]
              'SEAWIFS_MODIS': BEGIN
                DSTR = STRUCT[WHERE(SEN EQ 'SEAWIFS' OR SEN EQ 'MODISA' OR SEN EQ 'SEAWIFS_SA' OR SEN EQ 'MODISA_SA',/NULL)]
                FP = PARSE_IT(DSTR.NAME)
                OKS = WHERE(STRPOS(DSTR.SENSOR,'SEAWIFS') GE 0 AND FP.YEAR_START LE '2007',/NULL) & DSTR(OKS).SENSOR = 'SEAWIFS'
                OKM = WHERE(STRPOS(DSTR.SENSOR,'MODISA')  GE 0 AND FP.YEAR_START GE '2008',/NULL) & DSTR(OKM).SENSOR = 'MODISA'
                STR = STRUCT_CONCAT(DSTR(OKS),DSTR(OKM))
              END
              'SEAWIFS_MODIS_VIIRS': BEGIN
                DSTR = STRUCT[WHERE(SEN EQ 'SEAWIFS' OR SEN EQ 'MODISA' OR SEN EQ 'VIIRS' OR SEN EQ 'SEAWIFS_SAV' OR SEN EQ 'MODISA_SAV' OR SEN EQ 'VIIRS_SAV',/NULL)]
                FP = PARSE_IT(DSTR.NAME)
                OKS = WHERE(STRPOS(DSTR.SENSOR,'SEAWIFS') GE 0 AND FP.YEAR_START LE '2007',/NULL) & DSTR(OKS).SENSOR = 'SEAWIFS'
                OKM = WHERE(STRPOS(DSTR.SENSOR,'MODISA')  GE 0 AND FP.YEAR_START GE '2008' AND FP.YEAR_START LT '2017',/NULL) & DSTR(OKM).SENSOR = 'MODISA'
                OKV = WHERE(STRPOS(DSTR.SENSOR,'VIIRS')   GE 0 AND FP.YEAR_START GE '2017',/NULL) & DSTR(OKV).SENSOR = 'VIIRS'
                STR = STRUCT_CONCAT(DSTR(OKS),DSTR(OKM))
                STR = STRUCT_CONCAT(STR,DSTR(OKV))
              END
            ENDCASE
            IF STR EQ [] THEN CONTINUE
            SAVE, STR, FILENAME=DFILE ; ===> SAVE THE MERGED DATAFILE
            SAVE_2CSV, DFILE
            GONE, STR
          ENDIF
          
          IF FILE_MAKE(DFILE,EXTRACTED_FINAL,OVERWRITE=OVERWRITE) EQ 1 THEN BEGIN
            DSTR = IDL_RESTORE(DFILE)
            PALG = DSTR.PROD + '-' + DSTR.ALG 
            OK = WHERE(DSTR.ALG EQ '',COUNT)
            IF COUNT GT 0 THEN PALG[OK] = DSTR[OK].ALG
            OKP = WHERE(PALG EQ APROD,COUNTP)
            IF COUNTP EQ 0 THEN CONTINUE
            ASTR = DSTR(OKP)
          
            STR = REPLICATE(STRUCT_2MISSINGS(CREATE_STRUCT('PERIOD','','TIME','','TIME_UNIT','','VARIABLE','','VALUE',0.0,'UNITS','','REGION','','SHAPEFILE','','SENSOR','','ALGORITHM','','SOURCE','','NOTES','','FILENAME','')),N_ELEMENTS(ASTR))
            STR.FILENAME = ASTR.NAME
            STR.PERIOD = ASTR.PERIOD
          
            BP = WHERE_SETS(ASTR.PROD + '-' + ASTR.ALG)
            FOR A=0, N_ELEMENTS(BP)-1 DO BEGIN
              PROD = BP(A).VALUE  
              SUBS = WHERE_SETS_SUBS(BP(A))
              CASE PROD OF
                'CHLOR_A-PAN':              BEGIN & UNIT = 'mg m^-3'      & ALG = 'PAN_ET_AL_2008' & END
                'CHLOR_A-OCI':              BEGIN & UNIT = 'mg m^-3'      & ALG = 'NASA' & END
                'CHLOR_A-OCX':              BEGIN & UNIT = 'mg m^-3'      & ALG = "O'REILLY_ET_AL_1998" & END
                'PAR-':                     BEGIN & UNIT = 'Einstein m-2 d-1' & ALG = 'FRUIN_FRANZ_WANG_2002' & END
                'PPD-VGPM2':                BEGIN & UNIT = 'gC m^-2 d^-1' & ALG = 'BERENFELD_FALKOWSKI_1997;EPPLEY_1972' & END
                'DIATOM_PERCENTAGE-PAN':    BEGIN & UNIT = 'percent(%)'   & ALG = 'PAN_ET_AL_2010; PAN_ET_AL_2011' & END
                'MICRO_PERCENTAGE-PAN':     BEGIN & UNIT = 'percent(%)'   & ALG = 'PAN_ET_AL_2010; PAN_ET_AL_2011' & END
                'NANO_PERCENTAGE-PAN':      BEGIN & UNIT = 'percent(%)'   & ALG = 'PAN_ET_AL_2010; PAN_ET_AL_2011' & END
                'PICO_PERCENTAGE-PAN':      BEGIN & UNIT = 'percent(%)'   & ALG = 'PAN_ET_AL_2010; PAN_ET_AL_2011' & END
                'DIATOM_PERCENTAGE-HIRATA': BEGIN & UNIT = 'percent(%)'   & ALG = 'HIRATA_ET_AL_2008; HIRATA_ET_AL_2011' & END
                'MICRO_PERCENTAGE-HIRATA':  BEGIN & UNIT = 'percent(%)'   & ALG = 'HIRATA_ET_AL_2008; HIRATA_ET_AL_2011' & END
                'NANO_PERCENTAGE-HIRATA':   BEGIN & UNIT = 'percent(%)'   & ALG = 'HIRATA_ET_AL_2008; HIRATA_ET_AL_2011' & END
                'PICO_PERCENTAGE-HIRATA':   BEGIN & UNIT = 'percent(%)'   & ALG = 'HIRATA_ET_AL_2008; HIRATA_ET_AL_2011' & END
                'MICRO_PERCENTAGE-UITZ':    BEGIN & UNIT = 'percent(%)'   & ALG = 'UITZ_ET_AL_2008' & END
                'NANO_PERCENTAGE-UITZ':     BEGIN & UNIT = 'percent(%)'   & ALG = 'UITZ_ET_AL_2008' & END
                'PICO_PERCENTAGE-UITZ':     BEGIN & UNIT = 'percent(%)'   & ALG = 'UITZ_ET_AL_2008' & END
              ENDCASE
              STR(SUBS).UNITS = UNIT
              STR(SUBS).ALGORITHM = ALG
            ENDFOR  
                    
            BP = WHERE_SETS(ASTR.PERIOD_CODE)
            FOR A=0, N_ELEMENTS(BP)-1 DO BEGIN
              APER = BP(A).VALUE
              SUBS = WHERE_SETS_SUBS(BP(A))
              CASE APER OF 
                'A':      BEGIN & OPER = 'ANNUAL'                & TUNIT = 'YYYY'     & SPOS = 2 & LEN = 4 & END
                'M':      BEGIN & OPER = 'MONTHLY'               & TUNIT = 'YYYYMM'   & SPOS = 2 & LEN = 6 & END
                'W':      BEGIN & OPER = 'WEEKLY'                & TUNIT = 'YYYYWW'   & SPOS = 2 & LEN = 6 & END
                'D8':     BEGIN & OPER = '8_DAY'                 & TUNIT = 'YYYYMMDD' & SPOS = 3 & LEN = 8 & END
                'ANNUAL': BEGIN & OPER = 'CLIMATOLOGICAL_ANNUAL' & TUNIT = 'YYYY'     & SPOS = 7 & LEN = 9 & END
                'MONTH':  BEGIN & OPER = 'CLIMATOLOGICAL_MONTH'  & TUNIT = 'MM'       & SPOS = 6 & LEN = 2 & END
                'WEEK':   BEGIN & OPER = 'CLIMATOLOGICAL_WEEK'   & TUNIT = 'WW'       & SPOS = 5 & LEN = 2 & END
                'DOY':    BEGIN & OPER = 'CLIMATOLOGICAL_DOY'    & TUNIT = 'DOY'      & SPOS = 4 & LEN = 3 & END
              ENDCASE
              STR(SUBS).VARIABLE = OPER + '_' + ASTR(SUBS).PROD
              STR(SUBS).TIME = STRMID(ASTR(SUBS).PERIOD,SPOS,LEN)
              STR(SUBS).TIME_UNIT = TUNIT  
            ENDFOR
            
            OK = WHERE(ASTR.N GT 0 AND ASTR.GSTATS_N GT 0, COUNT)
            IF COUNT GT 0 THEN ASTR[OK].MATH = 'GSTATS'
            BP = WHERE_SETS(ASTR.MATH)
            FOR A=0, N_ELEMENTS(BP)-1 DO BEGIN
              UNI = ''
              AMATH = BP(A).VALUE
              SUBS = WHERE_SETS_SUBS(BP(A))
              CASE AMATH OF 
                'STATS':         BEGIN & MTH = 'MEDIAN'             & TAG = 'MED'          & NOTE = 'Median of the spatial mean' & END
                'GSTATS':        BEGIN & MTH = 'MEDIAN'             & TAG = 'GSTATS_MED'   & NOTE = 'Median of the spatial geometrict mean' & END
                'ANOMALY_RATIO': BEGIN & MTH = 'RATIO_ANOMALY'      & TAG = 'AMEAN'        & NOTE = 'Arithmetic mean of the spatial data' & UNI = 'UNITLESS' & END
                'DIF':           BEGIN & MTH = 'DIFFERENCE_ANOMALY' & TAG = 'AMEAN'        & NOTE = 'Arithmetic mean of the spatial data' & END
              ENDCASE
              STR(SUBS).VARIABLE = STR(SUBS).VARIABLE + '_' + MTH
              STR(SUBS).NOTES = NOTE
              IF UNI NE '' THEN STR(SUBS).UNITS = UNI
              TP = WHERE(TAG_NAMES(ASTR) EQ TAG,/NULL)
              STR(SUBS).VALUE = ASTR(SUBS).(TP)
            ENDFOR    
                        
            STR.REGION = ASTR.SUBAREA
            STR.SHAPEFILE = ASTR.REGION
            
            BP = WHERE_SETS(ASTR.SENSOR)
            FOR A=0, N_ELEMENTS(BP)-1 DO BEGIN
              ASEN = BP(A).VALUE
              SUBS = WHERE_SETS_SUBS(BP(A))
              CASE ASEN OF 
                'SEAWIFS': BEGIN & OSEN = 'SeaWiFS'            & SRC = 'KHyde (NEFSC); ' + SEA_SOURCE & END
                'MODISA':  BEGIN & OSEN = 'MODIS-Aqua'         & SRC = 'KHyde (NEFSC); ' + MOD_SOURCE & END
                'VIIRS':   BEGIN & OSEN = 'VIIRS-SNPP'         & SRC = 'KHyde (NEFSC); ' + VIR_SOURCE & END
                'JPSS1':   BEGIN & OSEN = 'VIIRS-NOAA20'       & SRC = 'KHyde (NEFSC); ' + JPS_SOURCE & END
                'SA':      BEGIN & OSEN = 'SeaWiFS/MODIS-Aqua' & SRC = 'KHyde (NEFSC); ' + SA_SOURCE  & END
                'SAV':     BEGIN & OSEN = 'SeaWiFS/MODIS-Aqua/VIIRS-SNPP'  & SRC = 'KHyde (NEFSC); ' + SAV_SOURCE & END
                'SAVJ':    BEGIN & OSEN = 'SeaWiFS/MODIS-Aqua/VIIRS-SNPP/VIIRS-NOAA20'         & SRC = 'KHyde (NEFSC); ' + SAJ_SOURCE & END
                'OCCCI':   BEGIN & OSEN = 'OC-CCI'             & SRC = 'KHyde (NEFSC); ' + OCC_SOURCE & END
              ENDCASE
              STR(SUBS).SENSOR = OSEN
              STR(SUBS).SOURCE = SRC
            ENDFOR  
            
            YR = (DATE_PARSE(PERIOD_2DATE(STR.PERIOD))).YEAR
            
            STR(WHERE(STRUPCASE(STR.SENSOR) EQ 'SEAWIFS/MODIS-AQUA' AND HAS(STR.VARIABLE,'PPD'),/NULL)).SOURCE = STRJOIN(['Khyde (NEFSC)',SA_SOURCE, SST_SOURCE],'; ')
            STR(WHERE(STRUPCASE(STR.SENSOR) EQ 'SEAWIFS' AND HAS(STR.VARIABLE,'PPD') AND ~HAS(STR.VARIABLE,'CLIM') AND YR LE '2001',/NULL)).SOURCE = STRJOIN(['Khyde (NEFSC)',SEA_SOURCE, AVH_SOURCE],'; ')
            STR(WHERE(STRUPCASE(STR.SENSOR) EQ 'SEAWIFS' AND HAS(STR.VARIABLE,'PPD') AND ~HAS(STR.VARIABLE,'CLIM') AND YR EQ '2002',/NULL)).SOURCE = STRJOIN(['Khyde (NEFSC)',SEA_SOURCE, SST_SOURCE],'; ')
            STR(WHERE(STRUPCASE(STR.SENSOR) EQ 'SEAWIFS' AND HAS(STR.VARIABLE,'PPD') AND ~HAS(STR.VARIABLE,'CLIM') AND YR GE '2003',/NULL)).SOURCE = STRJOIN(['Khyde (NEFSC)',SEA_SOURCE, MUR_SOURCE],'; ')
            STR(WHERE(STRUPCASE(STR.SENSOR) EQ 'MODISA'  AND HAS(STR.VARIABLE,'PPD') AND ~HAS(STR.VARIABLE,'CLIM')                 ,/NULL)).SOURCE = STRJOIN(['Khyde (NEFSC)',MOD_SOURCE, MUR_SOURCE],'; ')
            STR(WHERE(STRUPCASE(STR.SENSOR) EQ 'OCCCI'   AND HAS(STR.VARIABLE,'PPD') AND ~HAS(STR.VARIABLE,'CLIM') AND YR LE '2001',/NULL)).SOURCE = STRJOIN(['Khyde (NEFSC)',OCC_SOURCE, AVH_SOURCE],'; ')
            STR(WHERE(STRUPCASE(STR.SENSOR) EQ 'OCCCI'   AND HAS(STR.VARIABLE,'PPD') AND ~HAS(STR.VARIABLE,'CLIM') AND YR EQ '2002',/NULL)).SOURCE = STRJOIN(['Khyde (NEFSC)',OCC_SOURCE, SST_SOURCE],'; ')
            STR(WHERE(STRUPCASE(STR.SENSOR) EQ 'OCCCI'   AND HAS(STR.VARIABLE,'PPD') AND ~HAS(STR.VARIABLE,'CLIM') AND YR GE '2003',/NULL)).SOURCE = STRJOIN(['Khyde (NEFSC)',OCC_SOURCE, MUR_SOURCE],'; ')
            STR(WHERE(STRUPCASE(STR.SENSOR) EQ 'OCCCI'   AND HAS(STR.VARIABLE,'PPD') AND  HAS(STR.VARIABLE,'CLIM'),/NULL)).SOURCE = STRJOIN(['Khyde (NEFSC)',OCC_SOURCE, SST_SOURCE],'; ')

            STR = STRUCT_REMOVE(STR,'PERIOD')
            STR = STRUCT_SORT(STR,TAGNAMES=['MATH','VARIABLE','TIME','REGION'])  
            PFILE, EXTRACTED_FINAL
            STRUCT_2CSV, EXTRACTED_FINAL, STR
          ENDIF ; SOE_FORMAT
        ENDFOR ; DATASETS  
      ENDFOR ; PRODS
    ENDIF ; DATA_EXTRACTS
         

; *******************************************************
    IF KEY(PP_REQUIRED) THEN BEGIN
; ********************************************************
      SWITCHES,PP_REQUIRED,STOPP=STOPP,OVERWRITE=OVERWRITE,R_FILES=R_FILES,VERBOSE=VERBOSE,DATERANGE=DATERANGE      
      
      MP = 'NEC'
      MPIN = 'L3B2'
      PSATS = ['SEAWIFS_MODISA','SEAWIFS_MODISA_VIIRS']
      PPRODS = ['PPD-VGPM2','CHLOR_A-PAN']
      PPERIODS = 'M'
      
      SUBAREAS = ['NES_EPU_STATISTICAL_AREAS','NES_EPU_STATISTICAL_AREAS_NOEST']
      NAMES    = ['SS','GOM','GB','MAB'] 
      SUBTITLES = ['Scotian Shelf','Gulf of Maine','Georges Bank','Mid-Atlantic Bight'] 
      
      FOR PTH=0, N_ELEMENTS(PSATS)-1 DO BEGIN
        PSAT = PSATS(PTH)
        CASE PSAT OF
          'SEAWIFS_MODISA': SSATS = ['SEAWIFS','MODISA']
          'SEAWIFS_MODISA_VIIRS': SSATS = ['SEAWIFS','MODISA','VIIRS']
        ENDCASE
        
        FOR SA=0, N_ELEMENTS(SUBAREAS)-1 DO BEGIN ; LOOP THROUGH SUBAREA SHAPE FILES
          SUBAREA = SUBAREAS(SA)
          DIR_PPSUB = DIR_PPREQ + SUBAREA + SL
          SHPSTR = READ_SHPFILE(SUBAREA, MAPP=MPIN, ATT_TAG=ATT_TAG, COLOR=COLOR, VERBOSE=VERBOSE, NORMAL=NORMAL, AROUND=AROUND)
          PPSHP=SHPSTR.(0)

; ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
        ; ===> GET THE SUBSCRIPTS FROM THE SHAPEFILES FOR THE ECOREGIONS & EXTRACT THE MONTHLY DATA   
          PFILES = []
          FOR PP=0, N_ELEMENTS(PPRODS)-1 DO BEGIN ; LOOP THROUGH PRODS
            PROD = PPRODS(PP)
            CASE VALIDS('PRODS',PROD) OF
              'PPD': BEGIN & RTAG = 'GMEAN' & RNGE = '0.001_50.0' & SUM_STATS=1 & END
              'CHLOR_A': BEGIN & RTAG = 'GMEAN' & RNGE = '0.001_80.0' & SUM_STATS=0 & END
            ENDCASE
            DIR_MONTH = DIR_PPSUB + 'MONTHLY_EXTRACTS-' + PROD + SL & DIR_TEST, DIR_MONTH
               
            FILES = []
            SAVEFILES = []
            FOR Y=0, N_ELEMENTS(YEARS)-1 DO BEGIN ; LOOP THROUGH YEARS
              YR = YEARS(Y)
              CASE 1 OF
                YR LE '2007': DATASET = 'SEAWIFS
                YR GE '2008': DATASET = 'MODISA'
                YR GT '2017': IF HAS(SSATS,'VIIRS') THEN DATASET = 'VIIRS'
                PSAT EQ 'SA': DATASET = 'SA'
                PSAT EQ 'SAV': DATASET = 'SAV'
                PSAT EQ 'SAVJ': DATASET = 'SAVJ'
              ENDCASE
             
              ; ===> GET FILES
              FILES = EDAB_SOE_GET_FILES(PRODS=PROD, DATASETS=DATASET, PERIODS=PPERIODS, PPD_PAN=PPD_PAN, YEARS=YR, /STATS_ONLY)      
            
              ; ===> CREATE OUTPUT FILE NAMES
              FP = PARSE_IT(FILES,/ALL)
              SAVEFILE = DIR_MONTH + 'M_'+YEARS(Y) + '-' + REPLACE(FP[0].NAME,FP[0].PERIOD,SUBAREA) +'.SAV'
              SAVEFILES = [SAVEFILES,SAVEFILE]
              IF FILE_MAKE(FILES,SAVEFILE,OVERWRITE=OVERWRITE) EQ 0 THEN CONTINUE
  
              ; ===> READ THE FILES AND COMBINE INTO A SINGLE STRUCTURE
              STRUCT = []
              FOR N=0, N_ELEMENTS(FILES)-1 DO BEGIN
                PFILE, FILES(N), /R
                DT = STRUCT_READ(FILES(N),TAG=RTAG,BINS=BINS,/NO_STRUCT)
                IF BINS NE [] THEN DT = MAPS_L3B_2ARR(DT,MP=MPIN,BINS=BINS)
                STRUCT = CREATE_STRUCT(STRUCT,FP[N].PERIOD,REFORM(DT))
              ENDFOR
              TAGS = TAG_NAMES(STRUCT)
          
              ; ===> EXTRACT THE SUBAREA DATA FROM EACH FILE
              SUBAREA_TAGS = TAG_NAMES(PPSHP)
              TEMP = STRUCT_COPY(FP[0],['SENSOR','PROD','ALG'])
              FOR B=0, N_ELEMENTS(NAMES)-1 DO BEGIN ; ===> LOOP THROUGH EACH SUBAREA REGION
                OK = WHERE(SUBAREA_TAGS EQ NAMES(B),/NULL,COUNTSHP)
                IF COUNTSHP EQ 0 THEN CONTINUE
                ATEMP = []
                SUBS  = PPSHP.(OK).SUBS
                FOR T=0, N_ELEMENTS(TAGS)-1 DO ATEMP = CREATE_STRUCT(ATEMP,TAGS(T)+'_'+NAMES(B),STRUCT.(T)(SUBS))  
                TEMP = CREATE_STRUCT(TEMP,NAMES(B),ATEMP)          
              ENDFOR ; AREAS
              
              PRINT, 'Writing: ' + SAVEFILE
              SAVE,FILENAME=SAVEFILE,TEMP,/COMPRESS   
            ENDFOR ; YEARS
            
            ; ===> MERGE THE YEARLY FILES INTO INDIVIDUAL SUBAREA FILES
            DIR_MERGE = DIR_PPSUB + 'MONTHLY_MERGED-' + PROD + SL & DIR_TEST, DIR_MERGE
            MSAVEFILES = []
            FOR A=0, N_ELEMENTS(NAMES)-1 DO BEGIN
              ANAME = NAMES(A)
              FP = FILE_PARSE(SAVEFILES)
              PERIOD = STRSPLIT(FP[0].NAME,'-',/EXTRACT) & PERIOD = PERIOD[0]
              MSAVEFILE = DIR_MERGE + REPLACE(FP[0].NAME_EXT,[PERIOD,SUBAREA,'-'+SSATS],['ALL_YEARS',ANAME,REPLICATE('',N_ELEMENTS(SSATS))])
              MSAVEFILES = [MSAVEFILES,MSAVEFILE]
              
              IF FILE_MAKE(SAVEFILES,MSAVEFILE,OVERWRITE=OVERWRITE) EQ 0 THEN CONTINUE
              OUTSTRUCT = []
              FOR V=0, N_ELEMENTS(SAVEFILES)-1 DO BEGIN
                PERIOD = STRSPLIT(FP[V].NAME,'-',/EXTRACT) 
                YR = STRSPLIT(PERIOD[0],'_',/EXTRACT) 
                IF WHERE(YR[1] EQ YEARS) LT 0 THEN CONTINUE
                PFILE, SAVEFILES(V),/R
                SAV = IDL_RESTORE(SAVEFILES(V))
                OK = WHERE(TAG_NAMES(SAV) EQ ANAME,COUNTSAV)
                IF COUNTSAV EQ 0 THEN STOP
                MSAV = STRUCT_RENAME(SAV.(OK),TAG_NAMES(SAV.(OK)),  TAG_NAMES(SAV.(OK))+'_'+STRJOIN([SAV.SENSOR,REPLACE(SAV.PROD,'_',''),SAV.ALG],'_'),/STRUCT_ARRAYS)          
                IF V EQ 0 THEN OUTSTRUCT = MSAV ELSE OUTSTRUCT = STRUCT_MERGE(OUTSTRUCT,MSAV)
              ENDFOR ; SAVEFILES
              
              PRINT, 'Writing ' + MSAVEFILE
              SAVE,FILENAME=MSAVEFILE,OUTSTRUCT,/COMPRESS
              GONE, OUTSTRUCT
            ENDFOR ; NAMES        
      
; ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
; ===> CALCULATE MONTHLY & ANNUAL SUMS
      
            DIR_SUM = DIR_PPSUB + 'SUMS-' + PROD + SL & DIR_TEST, DIR_SUM
            PIXAREA = MAPS_PIXAREA(MPIN)  ; Average pixel area of the map
            FP = FILE_PARSE(MSAVEFILES)
    
            AFILES = []
            FOR N=0, N_ELEMENTS(NAMES)-1 DO BEGIN
              ANAME = NAMES(N)
              AREA_SUBS = PPSHP.(WHERE(TAG_NAMES(PPSHP) EQ ANAME)).SUBS
              TOTAL_AREA = PIXAREA(AREA_SUBS)
              MSAVE = MSAVEFILES[WHERE(STRPOS(FP.NAME,'-'+ANAME+'-') GT 0, COUNTF, /NULL)]
              IF COUNTF NE 1 THEN STOP
              FOR I=0, N_ELEMENTS(DIRS)-1 DO SAVES = [SAVES,FILE_SEARCH(DIRS(I) + 'ALL-' + CHLIN + '-' + ANAME+'-*' + SENSOR + '*' + PRODS(I) + '*.SAV')]
    
              MSAVEFILE = DIR_SUM + 'MONTHLY_SUM-' + ANAME + '-' + PROD +'-STATS.SAV'
              MCSVFILE  = DIR_SUM + 'MONTHLY_SUM-' + ANAME + '-' + PROD +'-STATS.CSV'
              ASAVEFILE = DIR_SUM + 'ANNUAL_SUM-'  + ANAME + '-' + PROD +'-STATS.SAV'
              ACSVFILE  = DIR_SUM + 'ANNUAL_SUM-'  + ANAME + '-' + PROD +'-STATS.CSV'
              AFILES = [AFILES,ASAVEFILE]
              IF FILE_MAKE(MSAVE,[MSAVEFILE,ASAVEFILE,MCSVFILE,ACSVFILE],OVERWRITE=OVERWRITE) EQ 0 THEN CONTINUE
    
              PRINT, 'Calculating stats for: ' + ANAME + ' - ' + PROD
              MDATA = IDL_RESTORE(MSAVE)
              TAGS  = TAG_NAMES(MDATA)
              ITAGS = STR_BREAK(TAGS,'_')
              OK = WHERE(ITAGS EQ 'CHLORA',COUNT)
              IF COUNT GT 0 THEN ITAGS[OK] = 'CHLOR_A'
               
              STRUCT = CREATE_STRUCT('SENSOR','','PROD','','ALG','','YEAR','','MONTH','','SUBAREA_NAME','','N_SUBAREA_PIXELS',0L,'TOTAL_PIXEL_AREA_KM2',0.0D,'N_PIXELS',0L,'N_PIXELS_AREA',0.0D,'SPATIAL_MEAN',0.0,'SPATIAL_VARIANCE',0.0)
              IF KEY(SUM_STATS) THEN STRUCT = CREATE_STRUCT(STRUCT,'SPATIAL_SUM',0.0D,'MONTHLY_SUM',0.0D)
              MONTHS = ['01','02','03','04','05','06','07','08','09','10','11','12']
              STRUCT = REPLICATE(STRUCT_2MISSINGS(STRUCT),N_ELEMENTS(YEARS)*12)
    
              YSTRUCT = CREATE_STRUCT('SENSOR','','PROD','','ALG','','YEAR','','SUBAREA_NAME','','TOTAL_PIXEL_AREA_KM2','0.0D','N_MONTHS',0L,'ANNUAL_MEAN',0.0)
              IF KEY(SUM_STATS) THEN YSTRUCT = CREATE_STRUCT(YSTRUCT,'ANNUAL_SUM',0.0D,'ANNUAL_MTON',0.0D,'ANNUAL_TTON',0.0D)
              YSTRUCT = REPLICATE(STRUCT_2MISSINGS(YSTRUCT),N_ELEMENTS(YEARS))
              YSTRUCT.N_MONTHS = 0 ; Initialize to zero
               
              I = 0
              FOR Y=0, N_ELEMENTS(YEARS)-1 DO BEGIN
                FOR MTH=0, N_ELEMENTS(MONTHS)-1 DO BEGIN
                  STRUCT(I).YEAR = YEARS(Y)
                  STRUCT(I).MONTH = MONTHS(MTH)
                  STRUCT(I).SUBAREA_NAME = ANAME
                  STRUCT(I).N_SUBAREA_PIXELS = N_ELEMENTS(MDATA.(0))
                  STRUCT(I).TOTAL_PIXEL_AREA_KM2 = TOTAL(PIXAREA(AREA_SUBS))
    
                  ATAG = 'M_' + YEARS(Y) + MONTHS(MTH) + '_' + ANAME
                  CTPOS = WHERE(ITAGS(*,1) EQ YEARS(Y)+MONTHS(MTH) AND ITAGS(*,2) EQ ANAME,COUNTTAG) 
                  IF COUNTTAG NE 1 THEN STOP
                 
                  MTAGS = ITAGS(CTPOS,*)
                  STRUCT(I).SENSOR = MTAGS(3)
                  STRUCT(I).PROD = MTAGS(4)
                  STRUCT(I).ALG = MTAGS(5)
                 
                  MSAV = MDATA.(CTPOS)
                  VDAT = VALID_DATA(MSAV,PROD=PROD,RANGE=RNGE,SUBS=OKVDAT,COUNT=COUNTVDAT,COMPLEMENT=COMPVDAT)
                  STRUCT(I).N_PIXELS = COUNTVDAT
                  STRUCT(I).N_PIXELS_AREA = TOTAL(PIXAREA(OKVDAT))
                  STRUCT(I).SPATIAL_MEAN = GEOMEAN(VDAT(OKVDAT))
                  STRUCT(I).SPATIAL_VARIANCE = VARIANCE(VDAT(OKVDAT))
                  IF KEY(SUM_STATS) THEN BEGIN
                    VDAT(COMPVDAT) = STRUCT(I).SPATIAL_MEAN ; FILL IN MISSING PP DATA WITH THE MEAN PRIOR TO CALCULATING THE TOTAL
                    STRUCT(I).SPATIAL_SUM  = TOTAL(VDAT*1000000*PIXAREA(AREA_SUBS))
                    STRUCT(I).MONTHLY_SUM  = STRUCT(I).SPATIAL_SUM*DAYS_MONTH(MONTHS(MTH),YEAR=YEARS(Y))
                  ENDIF
                  I = I+1
                ENDFOR ; MONTHS
                     
                OKY = WHERE(STRUCT.YEAR EQ YEARS(Y))
                YSTRUCT(Y).YEAR = YEARS(Y)
                YSTRUCT(Y).SUBAREA_NAME = ANAME
                YSTRUCT(Y).SENSOR = STRUCT(OKY[0]).SENSOR
                YSTRUCT(Y).PROD = STRUCT(OKY[0]).PROD
                YSTRUCT(Y).ALG = STRUCT(OKY[0]).ALG
                YSTRUCT(Y).TOTAL_PIXEL_AREA_KM2 = TOTAL(PIXAREA(AREA_SUBS))
                YSTRUCT(Y).ANNUAL_MEAN = MEAN(STRUCT(OKY).SPATIAL_MEAN,/NAN)
                
                IF KEY(SUM_STATS) THEN BEGIN
                  YSTRUCT(Y).N_MONTHS = N_ELEMENTS(WHERE(STRUCT(OKY).MONTHLY_SUM NE MISSINGS(STRUCT.MONTHLY_SUM)))
                  YSTRUCT(Y).ANNUAL_SUM = TOTAL(STRUCT(OKY).MONTHLY_SUM,/NAN)
                  YSTRUCT(Y).ANNUAL_MTON = YSTRUCT(Y).ANNUAL_SUM * 1E-6
                  YSTRUCT(Y).ANNUAL_TTON = YSTRUCT(Y).ANNUAL_MTON/1000
                ENDIF  
              ENDFOR ; YEARS
              PFILE, MSAVEFILE & SAVE, FILENAME=MSAVEFILE,STRUCT,/COMPRESS & STRUCT_2CSV,MCSVFILE,STRUCT
              PFILE, ASAVEFILE & SAVE, FILENAME=ASAVEFILE,YSTRUCT,/COMPRESS & STRUCT_2CSV,ACSVFILE,YSTRUCT
              SKIP_FILE:
            ENDFOR ; CODES

; ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
; ===> MERGE FILES
            
            PSAVEFILE = DIR_SUM + 'ANNUAL_SUM-'+SUBAREA+'-'+PROD+'-STATS.SAV'
            PCSVFILE  = DIR_SUM + 'ANNUAL_SUM-'+SUBAREA+'-'+PROD+'-STATS.CSV'
            PFILES = [PFILES,PSAVEFILE]
            IF FILE_MAKE(AFILES,[PSAVEFILE,PCSVFILE],OVERWRITE=OVERWRITE) EQ 0 THEN CONTINUE
            FOR F=0, N_ELEMENTS(AFILES)-1 DO BEGIN
              IF F EQ 0 THEN SUBSTRUCT = IDL_RESTORE(AFILES(F)) ELSE SUBSTRUCT = STRUCT_CONCAT(IDL_RESTORE(AFILES(F)),SUBSTRUCT)
            ENDFOR
            SUBSTRUCT = SUBSTRUCT[SORT(STRING(SUBSTRUCT.SUBAREA_NAME)+'_'+STRING(SUBSTRUCT.YEAR))]
            PFILE, PSAVEFILE & SAVE, FILENAME=PSAVEFILE,SUBSTRUCT,/COMPRESS & STRUCT_2CSV,PCSVFILE,SUBSTRUCT
       
          ENDFOR ; PRODS
  
          DIR_MERGE = DIR_PPSUB + 'FINAL_MERGED_SUMS'  + SL & DIR_TEST, DIR_MERGE
          CSAVEFILE = DIR_MERGE + 'MERGED_ANNUAL_SUM-'+SUBAREA+'-'+STRJOIN(PPRODS,'_')+'-STATS.SAV'
          CCSVFILE  = DIR_MERGE + 'MERGED_ANNUAL_SUM-'+SUBAREA+'-'+STRJOIN(PPRODS,'_')+'-STATS.CSV'
          IF FILE_MAKE(PFILES,[CSAVEFILE,CCSVFILE],OVERWRITE=OVERWRITE) EQ 0 THEN CONTINUE
          FOR F=0, N_ELEMENTS(PFILES)-1 DO BEGIN
            IF F EQ 0 THEN SUBSTRUCT = IDL_RESTORE(PFILES(F)) ELSE SUBSTRUCT = STRUCT_CONCAT(SUBSTRUCT,IDL_RESTORE(PFILES(F)))
          ENDFOR          
          SUBSTRUCT = SUBSTRUCT[SORT(STRING(SUBSTRUCT.SUBAREA_NAME)+'_'+SUBSTRUCT.PROD+'_'+SUBSTRUCT.PROD+'_'+STRING(SUBSTRUCT.YEAR))]
          PFILE, CSAVEFILE & SAVE, FILENAME=CSAVEFILE,SUBSTRUCT,/COMPRESS & STRUCT_2CSV,CCSVFILE,SUBSTRUCT      
      
        ENDFOR ; SUBAREA SHAPEFILES
      ENDFOR ; PSATS - SATELLITE COMBOS    
    ENDIF ; PP_REQUIRED


        
;  ****************************************
    IF KEY(ANNUAL_COMPOSITE) THEN BEGIN
;  ****************************************
      
      SWITCHES,ANNUAL_COMPOSITE,DATASETS=DATASETS,OVERWRITE=OVERWRITE,VERBOSE=VERBOSE,INIT=INIT,R_FILES=R_FILES,R_DATASETS=R_DATASETS,R_MAPS=R_MAPS,DATERANGE=DATERANGE
      
      IF NONE(DATASETS) THEN SENS = ['SEAWIFS_MODIS_VIIRS','SEAWIFS_MODISA','SAVJ'] ELSE SENS = DATASETS
      
      DIR_PNG = DIR_COMP + 'ANNUAL' + SL & DIR_TEST, DIR_PNG
      BUFFER = 0
      
      SPRODS = ['CHLOR_A-PAN']
      
      FOR I=0, N_ELEMENTS(SPRODS)-1 DO BEGIN
        SPROD = SPRODS(I)
        PPROD = 'PPD-VGPM2'
        PRODS = [SPROD,PPROD]
        PERIODS = ['A','M']
        PPD_PAN = 0
        TXT_TAGS = [];['PERIOD','MATH']

        EFILES = [] & AFILES = []
        FOR S=0, N_ELEMENTS(SATS)-1 DO BEGIN
          DATASET = SATS(S)
          FILES = EDAB_SOE_GET_FILES(PRODS=PRODS, DATASETS=DATASET, PERIODS=PERIODS, PPD_PAN=PPD_PAN, YEARS=YEARS)
          AFILES = [AFILES,FILES]
        ENDFOR ; SATS  
              
        FA = PARSE_IT(AFILES,/ALL)
        FA[WHERE(STRPOS(FA.NAME,'SEAWIFS') GE 0, /NULL,COUNTS)].SENSOR = 'SEAWIFS'
        FA[WHERE(STRPOS(FA.NAME,'MODISA')  GE 0, /NULL,COUNTM)].SENSOR = 'MODISA'
        FA[WHERE(STRPOS(FA.NAME,'VIIRS')   GE 0, /NULL,COUNTM)].SENSOR = 'VIIRS'
        FA[WHERE(STRPOS(FA.NAME,'JPSS1')   GE 0, /NULL,COUNTM)].SENSOR = 'JPSS1'
        
        STRUCT = IDL_RESTORE(DATFILE)
        STRUCT.SENSOR = REPLACE(STRUCT.SENSOR,'-','_')
        OK = WHERE(STRUCT.PROD+'-'+STRUCT.ALG NE PRODS[0] AND STRUCT.PROD+'-'+STRUCT.ALG NE PRODS[1],COUNT,COMPLEMENT=COMP)
        IF N_ELEMENTS(COMP) GT 0 THEN STRUCT = STRUCT(COMP) ; Remove extra prods
        
        OK_RATIO = WHERE_STRING(STRUCT.MATH,'RATIO',COUNT)
        IF COUNT GT 0 THEN STRUCT(OK_RATIO).PROD = STRUCT(OK_RATIO).PROD + '_RATIO'
        FOR S=0, N_ELEMENTS(SENS)-1 DO BEGIN
          SEN = SENS(S)
          FOR N=0, N_ELEMENTS(YEARS)-1 DO BEGIN
            YR = YEARS(N)
            IF YR EQ '1997' THEN CONTINUE
            CASE SEN OF   
              'SEAWIFS_MODISA': BEGIN
                SET = STRUCT[WHERE(STRUCT.SENSOR EQ 'SEAWIFS' OR STRUCT.SENSOR EQ 'MODISA' OR STRUCT.SENSOR EQ 'SEAWIFS_SA' OR STRUCT.SENSOR EQ 'MODISA_SA',COUNT)]
                FF = PARSE_IT(SET.NAME)
                OKS = WHERE(STRPOS(SET.SENSOR,'SEAWIFS') GE 0 AND FF.DATE_START LT '20080101000000',COUNT) & IF FIX(YR) LT 2008 THEN SENSOR = 'SEAWIFS'
                OKM = WHERE(STRPOS(SET.SENSOR,'MODISA')  GE 0 AND FF.DATE_START GE '20080101000000',COUNT) & IF FIX(YR) GE 2008 THEN SENSOR = 'MODISA'
                SET = [SET(OKS),SET(OKM)]
                RSEN = '_SA-'
              END
              'SEAWIFS_MODIS_VIIRS': BEGIN
                SET = STRUCT[WHERE(STRUCT.SENSOR EQ 'SEAWIFS' OR STRUCT.SENSOR EQ 'MODISA' OR STRUCT.SENSOR EQ 'VIIRS' OR $
                  STRUCT.SENSOR EQ 'SEAWIFS_SAV' OR STRUCT.SENSOR EQ 'MODISA_SAV' OR STRUCT.SENSOR EQ 'VIIRS_SAV',COUNT)]
                FF = PARSE_IT(SET.NAME)
                IF FIX(YR) LT 2008 THEN SENSOR = 'SEAWIFS'
                IF FIX(YR) GE 2008 AND FIX(YR) LT 2015 THEN SENSOR = 'MODISA'
                IF FIX(YR) GE 2015 THEN SENSOR = 'VIIRS'
                OKS = WHERE(STRPOS(SET.SENSOR,'SEAWIFS') GE 0 AND FF.DATE_START LT '20080101000000',COUNT)
                OKM = WHERE(STRPOS(SET.SENSOR,'MODISA')  GE 0 AND FF.DATE_START GE '20080101000000' AND FF.DATE_START LT '20150101000000',COUNT)
                OKV = WHERE(STRPOS(SET.SENSOR,'VIIRS')   GE 0 AND FF.DATE_START GE '20150101000000',COUNT)
                SET = [SET(OKS),SET(OKM),SET(OKV)]
                RSEN = '_SAV-'
              END
              'SAVJ': BEGIN
                SET = STRUCT[WHERE(STRUCT.SENSOR EQ 'SAVJ',COUNT)]
                SENSOR = 'SAVJ'
                RSEN = '-SAVJ-'
              END    
              'OCCCI': BEGIN 
                OK = WHERE(STRUCT.SENSOR EQ 'OCCCI',COUNT)
                XET = STRUCT(OK_OCCCI) 
                SENSOR = 'OCCCI'
                RSEN   = '-OCCCI-'
              END
            ENDCASE
            
            MSTR = SET[WHERE(SET.PERIOD_CODE EQ 'M',/NULL)]
            ASTR = SET[WHERE(SET.PERIOD_CODE EQ 'A',/NULL)]
            
            PERIOD = 'A_'+YR
            CS = AFILES[WHERE(FA.PERIOD EQ PERIOD AND FA.PROD EQ 'CHLOR_A'       AND FA.MATH EQ 'STATS' AND FA.SENSOR EQ SENSOR,/NULL)]
            CA = AFILES[WHERE(FA.PERIOD EQ PERIOD AND FA.PROD EQ 'CHLOR_A_RATIO' AND FA.MATH EQ 'RATIO' AND FA.SENSOR EQ SENSOR AND STRPOS(FA.NAME,RSEN) GT 0,/NULL)]
            PS = AFILES[WHERE(FA.PERIOD EQ PERIOD AND FA.PROD EQ 'PPD'           AND FA.MATH EQ 'STATS' AND FA.SENSOR EQ SENSOR,/NULL)]
            PA = AFILES[WHERE(FA.PERIOD EQ PERIOD AND FA.PROD EQ 'PPD_RATIO'     AND FA.MATH EQ 'RATIO' AND FA.SENSOR EQ SENSOR AND STRPOS(FA.NAME,RSEN) GT 0,/NULL)]
  
            IF ~ANY([CS,CA,PS,PA]) THEN CONTINUE
            PNGFILE = DIR_PNG + 'A_' + YR + '-' + SEN + '-' + SPROD + '-' + PPROD + '-DATA_COMPOSITE.PNG'
            IF FILE_MAKE([CS,CA,PS,PA,DATFILE],PNGFILE) EQ 0 THEN CONTINUE    
            
            WIDTH = 1100
            HEIGHT = 850
            NROW = 3
            NCOL = 4
            EDGE = 0.01
            SP = 0.005
            GAP = 0.05
            DIF = (1-(2*EDGE)-(NROW*SP))/NCOL
            PIXDIF = WIDTH * DIF
            CB = 0.025
            TP = 0.95 
            TPPIX = TP * HEIGHT
            BTPIX = TPPIX-PIXDIF
            BT = BTPIX/HEIGHT
            Y2 = BT-CB-GAP
            Y1 = .32;(BTPIX-PIXDIF/.7)/HEIGHT
            Y4 = Y1-GAP
            Y3 = Y4-(Y2-Y1)
            LF = EDGE + FINDGEN(4)*(DIF+SP)
            RT = LF + DIF
            X1 = LF+SP*5
            X2 = RT-SP*2
  
            ADD_CB = 1
            CB_TYPE = 3
            CB_FONT = 12
            CB_RELATIVE = 0
  
            CSPROD = 'CHLOR_A_0.1_30' & CSTITLE = '$Chlorophyll \ita\rm$' + ' ' + UNITS('CHLOR_A',/NO_NAME)  & CSPAL = 'PAL_DEFAULT'
            CAPROD = 'RATIO'          & CATITLE = 'CHL Ratio Anomaly'                                        & CAPAL = 'PAL_ANOM_GREY'
            PSPROD = 'PPD_0.1_10'     & PSTITLE = 'Primary Production '   + UNITS('PPD',/NO_NAME)            & PSPAL = 'PAL_DEFAULT'
            PAPROD = 'RATIO'          & PATITLE = 'PP Ratio Anomaly'                                         & PAPAL = 'PAL_ANOM_GREY'
            
            W = WINDOW(DIMENSIONS=[WIDTH,HEIGHT],BUFFER=BUFFER)
            
            IF CS NE [] THEN PRODS_2PNG,CS,TAG='GMEAN',MAPP=OMAP,PROD=CSPROD,OUTLINE=EPU_OUTLINE,OUT_COLOR=0,OUT_THICK=4,CB_TITLE=CSTITLE,TXT_TAGS=TXT_TAGS,VERBOSE=VERBOSE,/CURRENT,IMG_POS=[LF[0],BT,RT[0],TP],/ADD_CB,CB_POS=[LF[0]+SP,BT-CB,RT[0]-SP,BT-SP],CB_TYPE=CB_TYPE,CB_RELATIVE=CB_RELATIVE,PAL=CSPAL
            IF CA NE [] THEN PRODS_2PNG,CA,MAPP=OMAP,PROD=CAPROD,OUTLINE=EPU_OUTLINE,OUT_COLOR=0,OUT_THICK=4,CB_TITLE=CATITLE,TXT_TAGS=TXT_TAGS,VERBOSE=VERBOSE,/CURRENT,IMG_POS=[LF[1],BT,RT[1],TP],/ADD_CB,CB_POS=[LF[1]+SP,BT-CB,RT[1]-SP,BT-SP],CB_TYPE=CB_TYPE,CB_RELATIVE=CB_RELATIVE,PAL=CAPAL
            IF PS NE [] THEN PRODS_2PNG,PS,TAG='GMEAN',MAPP=OMAP,PROD=PSPROD,OUTLINE=EPU_OUTLINE,OUT_COLOR=0,OUT_THICK=4,CB_TITLE=PSTITLE,TXT_TAGS=TXT_TAGS,VERBOSE=VERBOSE,/CURRENT,IMG_POS=[LF(2),BT,RT(2),TP],/ADD_CB,CB_POS=[LF(2)+SP,BT-CB,RT(2)-SP,BT-SP],CB_TYPE=CB_TYPE,CB_RELATIVE=CB_RELATIVE,PAL=PSPAL
            IF PA NE [] THEN PRODS_2PNG,PA,MAPP=OMAP,PROD=PAPROD,OUTLINE=EPU_OUTLINE,OUT_COLOR=0,OUT_THICK=4,CB_TITLE=PATITLE,TXT_TAGS=TXT_TAGS,VERBOSE=VERBOSE,/CURRENT,IMG_POS=[LF(3),BT,RT(3),TP],/ADD_CB,CB_POS=[LF(3)+SP,BT-CB,RT(3)-SP,BT-SP],CB_TYPE=CB_TYPE,CB_RELATIVE=CB_RELATIVE,PAL=PAPAL
            T = TEXT(0.5,0.975,YR,ALIGN=0.5,VERTICAL_ALIGN=0.5,FONT_SIZE=20,FONT_STYLE='BOLD')
          
            PRODS = ['CHLOR_A','CHLOR_A_RATIO','PPD','PPD_RATIO']
            MR1   = [0.0,0.5,0.0,0.5]
            MR2   = [2.0,2.25,1.6,2.0]
            MTKS  = LIST('',[0.5,0.75,1,1.5,2.0],'',[0.5,0.75,1.0,1.5,2.0])
            MYMJR = [5,5,4,5]
            YR1   = [0.4,0.65,0.4,0.8]
            YR2   = [1.2,1.58,1.0,1.26]
            YTKS  = LIST('',[0.65,0.8,1,1.2,1.5],'',[0.8,0.9,1.0,1.111,1.25])
            YYMJR = [5,5,4,5]
            LOGS  = [0,1,0,1]
            TAGS  = ['GSTATS_GMEAN','AMEAN','GSTATS_GMEAN','AMEAN']
            CLRS  = ['BLUE','CYAN','RED','SPRING_GREEN']
            EPUS  = ['GOM','GB','MAB']
            THICK = 3
            AX = DATE_AXIS([210001,210012],/MONTH,/FYEAR,STEP=1,ROOM=1)
            AX.TICKNAME[0] = '' & AX.TICKNAME(-1) = ''
            FOR P=0, N_ELEMENTS(PRODS) -1 DO BEGIN
              FOR R=0, N_ELEMENTS(EPUS)-1 DO BEGIN
                POSITION=[X1(P),Y1,X2(P),Y2]
                STR = MSTR[WHERE(MSTR.PROD EQ PRODS(P) AND MSTR.SUBAREA EQ EPUS(R) AND DATE_2YEAR(PERIOD_2DATE(MSTR.PERIOD)) EQ YR,/NULL,COUNTM)] & IF COUNTM GT 12 THEN STOP
                MDATE = DATE_2JD('2100'+DATE_2MONTH(PERIOD_2DATE(STR.PERIOD)))
                RDATA = GET_TAG(STR,TAGS(P))
                LDATA = LOWESS(DATE_2MONTH(PERIOD_2DATE(STR.PERIOD)),RDATA,WIDTH=7)
                IF HAS(PRODS(P),'RATIO') THEN YTICKS = MTKS(P) ELSE YTICKS = []
                P0 = PLOT(MDATE,RDATA,YLOG=LOGS(P),/NODATA,/CURRENT,POSITION=POSITION,OVERPLOT=R,XRANGE=AX.JD,YRANGE=[MR1(P),MR2(P)],XTICKNAME=AX.TICKNAME,XTICKVALUES=AX.TICKV,XMINOR=0,XSTYLE=1,YMAJOR=MYMJR(P),YTICKV=YTICKS)
                XRANGE = P0.XRANGE
                IF HAS(PRODS(P),'RATIO') THEN PL = PLOT(XRANGE,[1,1],/OVERPLOT,COLOR='BLACK',THICK=3,TRANSPARENCY=90)
                P1 = PLOT(MDATE,RDATA,YLOG=LOGS(P),COLOR=CLRS(R),/CURRENT,POSITION=POSITION,/OVERPLOT,THICK=THICK,LINESTYLE=6,SYM_SIZE=0.25,SYMBOL='CIRCLE',SYM_FILLED=1);,XRANGE=AX.JD,YRANGE=[MR1(P),MR2(P)],XTICKNAME=AX.TICKNAME,XTICKVALUES=AX.TICKV,XMINOR=0,XSTYLE=1)
                P2 = PLOT(MDATE,LDATA,YLOG=LOGS(P),COLOR=CLRS(R),/CURRENT,POSITION=POSITION,/OVERPLOT,THICK=THICK);XRANGE=AX.JD,YRANGE=[MR1(P),MR2(P)],XTICKNAME=AX.TICKNAME,XTICKVALUES=AX.TICKV,XMINOR=0,XSTYLE=1)
                IF P EQ 0 THEN T = TEXT(POSITION[0]+0.01,POSITION(3)-0.03-(R*0.015),EPUS(R),COLOR=CLRS(R),TARGET=P0,/NORMAL,FONT_SIZE=10)
              ENDFOR
            ENDFOR
  
            AX = DATE_AXIS([YEARS[0],YEARS(-1)],/YEAR,/YY_YEAR,STEP=2,ROOM=2)
            AX.TICKNAME[0] = '' & AX.TICKNAME(-1) = ''
            FOR P=0, N_ELEMENTS(PRODS) -1 DO BEGIN
              FOR R=0, N_ELEMENTS(EPUS)-1 DO BEGIN
                POSITION=[X1(P),Y3,X2(P),Y4]
                STR = ASTR[WHERE(ASTR.PROD EQ PRODS(P) AND ASTR.SUBAREA EQ EPUS(R),/NULL)]
                YST = STR[WHERE(STR.PERIOD EQ PERIOD,/NULL)]
                RDATA = GET_TAG(STR,TAGS(P))
                LDATA = LOWESS(DATE_2YEAR(PERIOD_2DATE(STR.PERIOD)),RDATA,WIDTH=7)
                IF HAS(PRODS(P),'RATIO') THEN YTICKS = YTKS(P) ELSE YTICKS = []
                P0 = PLOT(MDATE,RDATA,YLOG=LOGS(P),/NODATA,/CURRENT,POSITION=POSITION,OVERPLOT=R,XRANGE=AX.JD,YRANGE=[YR1(P),YR2(P)],XTICKNAME=AX.TICKNAME,XTICKVALUES=AX.TICKV,XMINOR=0,XSTYLE=1,YMAJOR=YYMJR(P),YTICKV=YTICKS,YSTYLE=1)
                XRANGE = P0.XRANGE
                PL = PLOT(PERIOD_2JD([YST.PERIOD,YST.PERIOD]),[YR1(P),YR2(P)],COLOR='YELLOW',THICK=THICK*1.5,/OVERPLOT,TRANSPARENCY=90)
                IF HAS(PRODS(P),'RATIO') THEN PL = PLOT(XRANGE,[1,1],/OVERPLOT,COLOR='BLACK',THICK=3,TRANSPARENCY=90)
                P1 = PLOT(PERIOD_2JD(STR.PERIOD),RDATA,YLOG=LOGS(P),COLOR=CLRS(R),/CURRENT,POSITION=POSITION,/OVERPLOT,THICK=THICK,LINESTYLE=6,SYM_SIZE=0.25,SYMBOL='CIRCLE',SYM_FILLED=1);,XRANGE=AX.JD,YRANGE=[YR1(P),YR2(P)],XTICKNAME=AX.TICKNAME,XTICKVALUES=AX.TICKV,XMINOR=1,XSTYLE=1)
                P2 = PLOT(PERIOD_2JD(STR.PERIOD),LDATA,YLOG=LOGS(P),COLOR=CLRS(R),/CURRENT,POSITION=POSITION,/OVERPLOT,THICK=THICK);,XRANGE=AX.JD,YRANGE=[YR1(P),YR2(P)],XTICKNAME=AX.TICKNAME,XTICKVALUES=AX.TICKV,XMINOR=1,XSTYLE=1)
              ENDFOR
            ENDFOR
              
            W.SAVE, PNGFILE
            W.CLOSE
            PFILE, PNGFILE 
          ENDFOR ; YEARS
        ENDFOR ; SENS  
      ENDFOR ; SPRODS  
    ENDIF ; ANNUAL_COMPS  
    
;  ****************************************
    IF KEY(ANNUAL_COMPARE) THEN BEGIN
;  ****************************************

      SWITCHES,ANNUAL_COMPARE,DATASETS=DATASETS,OVERWRITE=OVERWRITE,VERBOSE=VERBOSE,INIT=INIT,R_FILES=R_FILES,R_DATASETS=R_DATASETS,R_MAPS=R_MAPS,DPRODS=D_PRODS,DATERANGE=DATERANGE

      DIR_PNG = DIR_COMP + 'ANNUAL_COMPARE' + SL & DIR_TEST, DIR_PNG
      IF NONE(DATASETS) THEN SENSORS = ['SEAWIFS','MODISA','VIIRS','JPSS1'] ELSE SENSORS = DATASETS
      IF NONE(D_PRODS) THEN PRODS = ['CHLOR_A-PAN','CHLOR_A-OCI','PPD-VGPM2'] ELSE PRODS = D_PRODS 
      COMPARE_SENSOR = 'SAVJ'
      MATHS = ['STATS','RATIO']
      PERIODS = ['A','M']
      PPD_PAN = 0
      TXT_TAGS = [];['PERIOD','MATH']
      BUFFER = 0

      EFILES = [] & AFILES = []
      FOR S=0, N_ELEMENTS(SATS)-1 DO BEGIN
        DATASET = SATS(S)
        FILES = EDAB_SOE_GET_FILES(PRODS=PRODS, DATASETS=DATASET, PERIODS=PERIODS, PPD_PAN=PPD_PAN, YEARS=YEARS)
        AFILES = [AFILES,FILES]
      ENDFOR ; SATS

      FA = PARSE_IT(AFILES,/ALL)
      
   ;   FA(WHERE(STRPOS(FA.NAME,'SEAWIFS') GE 0, /NULL,COUNTS)).SENSOR = 'SEAWIFS'
   ;   FA(WHERE(STRPOS(FA.NAME,'MODISA')  GE 0, /NULL,COUNTM)).SENSOR = 'MODISA'
   ;   FA(WHERE(STRPOS(FA.NAME,'VIIRS')   GE 0, /NULL,COUNTS)).SENSOR = 'VIIRS'
   ;   FA(WHERE(STRPOS(FA.NAME,'JPSS1')   GE 0, /NULL,COUNTM)).SENSOR = 'JPSS1'

      STRUCT = IDL_RESTORE(DATFILE)
      OK_RATIO = WHERE_STRING(STRUCT.MATH,'RATIO',COUNT)
      IF COUNT GT 0 THEN BEGIN
        STRUCT(OK_RATIO).MATH = 'RATIO'
        STRUCT(OK_RATIO).PROD = STRUCT(OK_RATIO).PROD + '_RATIO'
      ENDIF
      
      
      MSTR = STRUCT[WHERE(STRUCT.PERIOD_CODE EQ 'M',/NULL)]
      ASTR = STRUCT[WHERE(STRUCT.PERIOD_CODE EQ 'A',/NULL)]
      FOR N=0, N_ELEMENTS(YEARS)-1 DO BEGIN
        YR = YEARS(N)
        IF YR EQ '1997' OR YR GT '2019' THEN CONTINUE
      
        FOR P=0, N_ELEMENTS(PRODS)-1 DO BEGIN
          APROD = PRODS(P)
          AALG = VALIDS('ALGS',APROD)
          
          FOR S=0, N_ELEMENTS(SENSORS)-1 DO BEGIN
            SENSOR = SENSORS(S)
          
            FOR M=0, N_ELEMENTS(MATHS)-1 DO BEGIN
              AMATH = MATHS(M)
              
              CASE VALIDS('PRODS',PRODS(P)) OF 
                'CHLOR_A': BEGIN
                  IF AMATH EQ 'RATIO' THEN BEGIN
                    SPROD  = 'CHLOR_A_RATIO' 
                    TITLE = 'CHL Ratio Anomaly' 
                    SSCL  = 'RATIO'  
                    SPAL  = 'PAL_ANOM_GREY'
                    APAL  = 'PAL_ANOM_GREY'
                    MRG   = [0.5,2.0]
                    YRG   = [0.65,1.5]
                    MTKS  = [0.5,0.75,1,1.5,2.0]
                    YTKS  = [0.65,0.8,1,1.2,1.5]
                    MYMJR = 5
                    YYMJR = 5
                    LOGS  = 1
                    TAG   = 'AMEAN'
                    PTAG  = 'ANOMALY'
                    ASENSOR = SENSOR + '_' + COMPARE_SENSOR
                  ENDIF ELSE BEGIN
                    SPROD = 'CHLOR_A'
                    SSCL  = 'CHLOR_A_0.1_30'
                    SPAL  = 'PAL_DEFAULT'
                    APAL  = 'PAL_ANOM_GREY'
                    TITLE = '$Chlorophyll \ita\rm$' + ' ' + UNITS('CHLOR_A',/NO_NAME)  
                    MRG   = [0.0,2.0]
                    YRG   = [0.4,1.2]
                    MTKS  = []
                    YTKS  = []
                    MYMJR = 5
                    YYMJR = 5
                    LOGS  = 0
                    TAG   = 'GSTATS_MED' ; Subareas extraction tag for plot
                    PTAG  = 'GMEAN' ; PRODS_2PNG tag
                    ASENSOR = SENSOR
                  ENDELSE   
                END
                'PPD': BEGIN
                  IF AMATH EQ 'RATIO' THEN BEGIN
                    SSCL  = 'RATIO'
                    SPROD = 'PPD_RATIO'
                    TITLE = 'PP Ratio Anomaly'
                    SPAL  = 'PAL_ANOM_GREY'
                    APAL  = 'PAL_ANOM_GREY'
                    MRG   = [0.5,2.0]
                    YRG   = [0.8,1.25]
                    MTKS  = [0.5,0.75,1.0,1.5,2.0]
                    YTKS  = [0.8,0.9,1.0,1.111,1.25]
                    MYMJR = 5
                    YYMJR = 5
                    LOGS  = 1
                    TAG   = 'AMEAN'
                    PTAG  = 'ANOMALY'
                    ASENSOR = SENSOR + '_' + COMPARE_SENSOR
                  ENDIF ELSE BEGIN
                    SPROD = 'PPD'
                    SSCL  = 'PPD_0.1_10'
                    TITLE = 'Primary Production '    + UNITS('PPD',/NO_NAME)  
                    SPAL  = 'PAL_DEFAULT'
                    APAL  = 'PAL_ANOM_GREY'
                    MRG   = [0.0,1.6]
                    YRG   = [0.4,1.0]
                    MTKS  = []
                    YTKS  = []
                    MYMJR = 4
                    YYMJR = 4
                    LOGS  = 0
                    TAG   = 'GSTATS_MED' ; Subareas extraction tag for plot
                    PTAG  = 'GMEAN' ; PRODS_2PNG tag
                    ASENSOR = SENSOR
                  ENDELSE
                END
              ENDCASE
      
           
        
              PERIOD = 'A_'+YR
              SS = AFILES[WHERE(FA.PERIOD EQ PERIOD AND FA.PROD EQ SPROD AND FA.ALG EQ VALIDS('ALGS',APROD) AND FA.MATH EQ AMATH AND FA.SENSOR EQ ASENSOR,/NULL,COUNT_SS)]
              OS = AFILES[WHERE(FA.PERIOD EQ PERIOD AND FA.PROD EQ SPROD AND FA.ALG EQ VALIDS('ALGS',APROD) AND FA.MATH EQ AMATH AND FA.SENSOR EQ COMPARE_SENSOR,/NULL,COUNT_OS)]
            
              IF COUNT_SS EQ 0 THEN CONTINUE
              PNGFILE = DIR_PNG + 'A_' + YR + '-' + SENSOR + '_vs_' + COMPARE_SENSOR + '-' + SPROD + '-' + AMATH + '_COMPOSITE.PNG'
              IF FILE_MAKE([SS,OS,DATFILE],PNGFILE) EQ 0 THEN CONTINUE
    
              NROW = 3
              NCOL = 3
              IMGPIX = 300.
              HEIGHT = IMGPIX*NROW
              WIDTH  = IMGPIX*NCOL
              
              EDGE = 0.02
              WSP = 0.05 
              HSP = 0.05 
              TEDGE = 0.04
              BEDGE = 0.01
              CB   = 0.005
              CBS  = 0.015
              
              TWSP = WSP*(NCOL-1) + EDGE*2
              THSP = TEDGE + BEDGE + HSP*(NROW-1) + CBS*NROW + CB*NROW
              WDIF = (1-TWSP)/NCOL
              LF = [] & RT = [] & TP = [] & BT = []
              FOR L=0, NCOL-1 DO LF = [LF,EDGE+WSP*L+WDIF*L]
              RT = LF + WDIF
              HDIF = WIDTH*WDIF/HEIGHT
              FOR T=0, NROW-1 DO TP = [TP,1-TEDGE-(HSP*T)-HDIF*T-CBS*T-CB*T]
              BT = TP - HDIF
              
              ADD_CB = 1
              CB_TYPE = 3
              CB_FONT = 12
              CB_RELATIVE = 0
    
              W = WINDOW(DIMENSIONS=[WIDTH,HEIGHT],BUFFER=BUFFER)
              T = TEXT(0.5,0.975,YR,ALIGN=0.5,VERTICAL_ALIGN=0.5,FONT_SIZE=20,FONT_STYLE='BOLD')
              IF SS NE [] THEN PRODS_2PNG,SS,MAPP=OMAP,PROD=SSCL,TAG=PTAG,OUTLINE=EPU_OUTLINE,OUT_COLOR=0,OUT_THICK=4,CB_TITLE=TITLE,TXT_TAGS=SENSOR, TXT_POS=[LF[0]+(WSP/2),TP[0]-(HSP*2)],VERBOSE=VERBOSE,/CURRENT,IMG_POS=[LF[0],BT[0],RT[0],TP[0]],/ADD_CB,CB_POS=[LF[0],BT[0]-CBS,RT[0],BT[0]-CB],CB_TYPE=CB_TYPE,CB_RELATIVE=CB_RELATIVE,PAL=SPAL
              IF OS NE [] THEN PRODS_2PNG,OS,MAPP=OMAP,PROD=SSCL,TAG=PTAG,OUTLINE=EPU_OUTLINE,OUT_COLOR=0,OUT_THICK=4,CB_TITLE=TITLE,TXT_TAGS=COMPARE_SENSOR,TXT_POS=[LF[0]+(WSP/2),TP[0]-(HSP*2)],VERBOSE=VERBOSE,/CURRENT,IMG_POS=[LF[1],BT[0],RT[1],TP[0]],/ADD_CB,CB_POS=[LF[1],BT[0]-CBS,RT[1],BT[0]-CB],CB_TYPE=CB_TYPE,CB_RELATIVE=CB_RELATIVE,PAL=SPAL
              
              SM = STRUCT_READ(SS,TAG=PTAG,MAP_OUT=OMAP)
              OC = STRUCT_READ(OS,TAG=PTAG,MAP_OUT=OMAP) 
              IF AMATH EQ 'STATS' THEN ANOM = SM/OC ELSE ANOM = SM-OC
              IF AMATH EQ 'STATS' THEN ASCL = 'RATIO_.8_1.25' ELSE ASCL = 'DIF_-1_1'
              IF AMATH EQ 'STATS' THEN ATITLE = SENSOR+':'+COMPARE_SENSOR+' Ratio' ELSE ATITLE = SENSOR+'-'+COMPARE_SENSOR+' Difference'
              BYT = PRODS_2BYTE(ANOM,MP=OMAP,PROD=ASCL,/ADD_LAND,/ADD_COAST)
              IMG = IMAGE(BYT, RGB_TABLE=CPAL_READ(APAL),POSITION=[LF(2),BT[0],RT(2),TP[0]], MARGIN=0, /CURRENT, BUFFER=BUFFER)
              CBAR, ASCL, IMG=IMG, FONT_SIZE=10, CB_TYPE=CB_TYPE, CB_POS=[LF(2),BT[0]-CBS,RT(2),BT[0]-CB], CB_TITLE=ATITLE, PAL=APAL, RELATIVE=CB_RELATIVE
              TXT = TEXT(LF(2)+0.01,TP[0]-0.03,SENSOR+':'+COMPARE_SENSOR,/NORMAL,FONT_SIZE=10,FONT_STYLE='BOLD',TARGET=IMG)
              
              
              CLRS  = ['BLUE','CYAN','RED','SPRING_GREEN']
              EPUS  = ['GOM','GB','MAB']
              THICK = 3
              AX = DATE_AXIS([210001,210012],/MONTH,/FYEAR,STEP=1,ROOM=1)
              AX.TICKNAME[0] = '' & AX.TICKNAME(-1) = ''
              
              SENS = [ASENSOR,COMPARE_SENSOR]
              FOR R=0, N_ELEMENTS(EPUS)-1 DO BEGIN
                FOR E=0, N_ELEMENTS(SENS) -1 DO BEGIN
                  POSITION=[LF(R)+.015,BT[1]+.02,RT(R),TP[1]+.02]
                  STR = MSTR[WHERE(MSTR.PROD EQ SPROD AND MSTR.ALG EQ AALG AND MSTR.SUBAREA EQ EPUS(R) AND DATE_2YEAR(PERIOD_2DATE(MSTR.PERIOD)) EQ YR AND MSTR.SENSOR EQ SENS(E) AND MSTR.MATH EQ AMATH,/NULL,COUNTM)] & IF COUNTM GT 12 THEN STOP
                  MDATE = DATE_2JD('2100'+DATE_2MONTH(PERIOD_2DATE(STR.PERIOD)))
                  RDATA = GET_TAG(STR,TAG)
                  LDATA = LOWESS(DATE_2MONTH(PERIOD_2DATE(STR.PERIOD)),RDATA,WIDTH=7)
                  ;IF HAS(PRODS(P),'RATIO') THEN YTICKS = MTKS(P) ELSE YTICKS = []
                  P0 = PLOT(MDATE,RDATA,YLOG=LOGS,/NODATA,/CURRENT,POSITION=POSITION,OVERPLOT=S,XRANGE=AX.JD,YRANGE=MRG,XTICKNAME=AX.TICKNAME,XTICKVALUES=AX.TICKV,XMINOR=0,XSTYLE=1,YMAJOR=MYMJR,YTICKV=MTKS)
                  XRANGE = P0.XRANGE
                  IF AMATH EQ 'RATIO' THEN PL = PLOT(XRANGE,[1,1],/OVERPLOT,COLOR='BLACK',THICK=3,TRANSPARENCY=90)
                  P1 = PLOT(MDATE,RDATA,YLOG=LOGS,COLOR=CLRS(E),/CURRENT,POSITION=POSITION,/OVERPLOT,THICK=THICK,LINESTYLE=6,SYM_SIZE=0.25,SYMBOL='CIRCLE',SYM_FILLED=1);,XRANGE=AX.JD,YRANGE=[MR1(P),MR2(P)],XTICKNAME=AX.TICKNAME,XTICKVALUES=AX.TICKV,XMINOR=0,XSTYLE=1)
                  P2 = PLOT(MDATE,LDATA,YLOG=LOGS,COLOR=CLRS(E),/CURRENT,POSITION=POSITION,/OVERPLOT,THICK=THICK);XRANGE=AX.JD,YRANGE=[MR1(P),MR2(P)],XTICKNAME=AX.TICKNAME,XTICKVALUES=AX.TICKV,XMINOR=0,XSTYLE=1)
                  IF E EQ 0 THEN T = TEXT(POSITION(2)-0.01,POSITION(3)-0.03,EPUS(R),TARGET=P0,/NORMAL,FONT_SIZE=10,ALIGNMENT=1)
                  T = TEXT(POSITION[0]+0.01,POSITION(3)-0.03-(S*0.015),SENS(E),COLOR=CLRS(E),TARGET=P0,/NORMAL,FONT_SIZE=10)
                ENDFOR
              ENDFOR
    
              AX = DATE_AXIS([YEARS[0],YEARS(-1)],/YEAR,/YY_YEAR,STEP=2,ROOM=2)
              AX.TICKNAME[0] = '' & AX.TICKNAME(-1) = ''
              FOR R=0, N_ELEMENTS(EPUS)-1 DO BEGIN
                FOR E=0, N_ELEMENTS(SENS) -1 DO BEGIN
                  POSITION=[LF(R)+.015,BT(2)+.07,RT(R),TP(2)+.07]
                  IF SENS(E) EQ COMPARE_SENSOR THEN STR = ASTR[WHERE(ASTR.PROD EQ SPROD AND ASTR.ALG EQ AALG AND ASTR.SUBAREA EQ EPUS(R) AND ASTR.SENSOR EQ COMPARE_SENSOR AND ASTR.MATH EQ AMATH,/NULL)] ELSE $
                                                    STR = ASTR[WHERE(ASTR.PROD EQ SPROD AND ASTR.ALG EQ AALG AND ASTR.SUBAREA EQ EPUS(R) AND ASTR.SENSOR NE COMPARE_SENSOR AND ASTR.MATH EQ AMATH,/NULL)] 
                  
                  STR = ASTR[WHERE(ASTR.PROD EQ SPROD AND ASTR.ALG EQ AALG AND ASTR.SUBAREA EQ EPUS(R) AND ASTR.SENSOR EQ SENS(E) AND ASTR.MATH EQ AMATH,/NULL)] 
                  
                  YST = STR[WHERE(STR.PERIOD EQ PERIOD,/NULL)]
                  RDATA = GET_TAG(STR,TAG)
                  LDATA = LOWESS(DATE_2YEAR(PERIOD_2DATE(STR.PERIOD)),RDATA,WIDTH=7)
                 ; IF HAS(PRODS(P),'RATIO') THEN YTICKS = YTKS(P) ELSE YTICKS = []
                  P0 = PLOT(MDATE,RDATA,YLOG=LOGS,/NODATA,/CURRENT,POSITION=POSITION,OVERPLOT=S,XRANGE=AX.JD,YRANGE=YRG,XTICKNAME=AX.TICKNAME,XTICKVALUES=AX.TICKV,XMINOR=0,XSTYLE=1,YMAJOR=YYMJR,YTICKV=YTKS,YSTYLE=1)
                  XRANGE = P0.XRANGE
                  PL = PLOT(PERIOD_2JD([YST.PERIOD,YST.PERIOD]),YRG,COLOR='YELLOW',THICK=THICK*1.5,/OVERPLOT,TRANSPARENCY=90)
                  IF AMATH EQ 'RATIO' THEN PL = PLOT(XRANGE,[1,1],/OVERPLOT,COLOR='BLACK',THICK=3,TRANSPARENCY=90)
                  P1 = PLOT(PERIOD_2JD(STR.PERIOD),RDATA,YLOG=LOGS,COLOR=CLRS(E),/CURRENT,POSITION=POSITION,/OVERPLOT,THICK=THICK,LINESTYLE=6,SYM_SIZE=0.25,SYMBOL='CIRCLE',SYM_FILLED=1);,XRANGE=AX.JD,YRANGE=[YR1(P),YR2(P)],XTICKNAME=AX.TICKNAME,XTICKVALUES=AX.TICKV,XMINOR=1,XSTYLE=1)
                  P2 = PLOT(PERIOD_2JD(STR.PERIOD),LDATA,YLOG=LOGS,COLOR=CLRS(E),/CURRENT,POSITION=POSITION,/OVERPLOT,THICK=THICK);,XRANGE=AX.JD,YRANGE=[YR1(P),YR2(P)],XTICKNAME=AX.TICKNAME,XTICKVALUES=AX.TICKV,XMINOR=1,XSTYLE=1)
                  IF E EQ 0 THEN T = TEXT(POSITION(2)-0.01,POSITION(3)-0.03,EPUS(R),TARGET=P0,/NORMAL,FONT_SIZE=10,ALIGNMENT=1)
                  T = TEXT(POSITION[0]+0.01,POSITION(3)-0.03-(S*0.015),SENS(E),COLOR=CLRS(E),TARGET=P0,/NORMAL,FONT_SIZE=10)
                ENDFOR
              ENDFOR
    
              W.SAVE, PNGFILE
              W.CLOSE
              PFILE, PNGFILE
            ENDFOR ; MATHS
          ENDFOR ; SENSORS
        ENDFOR ; PRODS
      ENDFOR ; YEARS  
    ENDIF ; ANNUAL_COMPARE    
    
    
; ********************************************************
    IF KEY(COMPARE_PRODS) THEN BEGIN
; ********************************************************
      SWITCHES,COMPARE_PRODS,STOPP=STOPP,OVERWRITE=OVERWRITE,VERBOSE=VERBOSE,INIT=INIT,R_FILES=R_FILES,R_DATASETS=R_DATASETS,R_MAPS=R_MAPS,DATERANGE=DATERANGE

      OMAP = 'NEC'
      CHL_ALG='PAN'
      PPD_ALG='VGPM2'
      PPD_PAN=0
      TXT_TAGS = [];['PERIOD','MATH']
      BUFFER=0

      SENSORS = (['SEAWIFS','MODISA','VIIRS','JPSS1','SA','SAV','SAVJ'])  ; 'OCCCI', V2019_0 - Added OCCCI
      PRODS = LIST(['CHLOR_A-OCI','CHLOR_A-PAN']);, $
    ;    ['DIATOM_PERCENTAGE-PAN','DIATOM_PERCENTAGE-HIRATA'],$
    ;    ['MICRO_PERCENTAGE-PAN','MICRO_PERCENTAGE-HIRATA','MICRO_PERCENTAGE-UITZ'],$
    ;    ['NANO_PERCENTAGE-PAN','NANO_PERCENTAGE-HIRATA','NANO_PERCENTAGE-UITZ'],$
    ;    ['PICO_PERCENTAGE-PAN','PICO_PERCENTAGE-HIRATA','PICO_PERCENTAGE-UITZ'])
 
 
      COMPARE_SAT_SENSORS, ['MODISA','SAV','SAVJ'],PRODS=['CHLOR_A-PAN'],PERIODS='W',DATERANGE=['20190501','20190731'],BUFFER=BUFFER, DIR_OUT=DIR_PLOTS + 'COMPARE_SAT_DATA' + SL
      COMPARE_SAT_SENSORS, ['MODISA','SAV','SAVJ'],PRODS=['CHLOR_A-PAN'],PERIODS='W',DATERANGE=['20190501','20191231'],BUFFER=BUFFER, DIR_OUT=DIR_PLOTS + 'COMPARE_SAT_DATA' + SL
      
      COMPARE_SAT_SENSORS, ['MODISA','VIIRS','JPSS1'],PRODS=['CHLOR_A-OCI'],PERIODS='D',/NC,DATERANGE=['20190601','20191231'],BUFFER=BUFFER, DIR_OUT=DIR_PLOTS + 'COMPARE_SAT_DATA' + SL
      COMPARE_SAT_SENSORS, ['MODISA','VIIRS','JPSS1'],PRODS=['CHLOR_A-PAN'],PERIODS='D',DATERANGE=['20190601','20191231'],BUFFER=BUFFER, DIR_OUT=DIR_PLOTS + 'COMPARE_SAT_DATA' + SL

      FOR N=0, N_ELEMENTS(PRODS)-1 DO COMPARE_SAT_PRODS, PRODS(N), SENSORS=SENSORS, BUFFER=BUFFER, DIR_OUT=DIR_PLOTS + 'COMPARE_SAT_DATA' + SL

      COMPARE_SAT_SENSORS, ['MODISA','VIIRS','JPSS1'],PRODS=['CHLOR_A-OCI','CHLOR_A-PAN','PPD-VGPM2','PAR'],PERIODS='W',DATERANGE=['2018','2020'],BUFFER=BUFFER, DIR_OUT=DIR_PLOTS + 'COMPARE_SAT_DATA' + SL
      COMPARE_SAT_SENSORS, ['MODISA','VIIRS','JPSS1'],PRODS=['CHLOR_A-OCI','CHLOR_A-PAN','PPD-VGPM2','PAR'],PERIODS='W',DATERANGE=['2012','2020'],BUFFER=BUFFER, DIR_OUT=DIR_PLOTS + 'COMPARE_SAT_DATA' + SL


      IF NONE(D_PRODS) THEN PRODS = ['CHLOR_A-OCI','CHLOR_A-PAN','PPD-VGOM2','PAR'] ELSE PRODS = D_PRODS 
      SENSORS = LIST(['SEAWIFS','MODISA','VIIRS','JPSS1'],['SEAWIFS','MODISA','SA'],['SEAWIFS','MODISA','VIIRS','SAV'],['SA','SAV','SAVJ']) 
      FOR N=0, N_ELEMENTS(SENSORS)-1 DO COMPARE_SAT_SENSORS, SENSORS(N), PRODS=PRODS, BUFFER=BUFFER, DIR_OUT=DIR_PLOTS + 'COMPARE_SAT_DATA' + SL


    ENDIF ; COMAPRE_PRODS         


        
; ********************************************
    IF KEY(MONTHLY_TIMESERIES) THEN BEGIN
; ********************************************
      SNAME = 'MONTHLY_TIMESERIES'
      PRINT, 'Running: ' + SNAME + ' for ' + SOE_YR
      SWITCHES,MONTHLY_TIMESERIES,STOPP=STOPP,OVERWRITE=OVERWRITE,VERBOSE=VERBOSE,INIT=INIT,R_FILES=R_FILES,R_DATASETS=R_DATASETS,R_MAPS=R_MAPS,DATERANGE=DATERANGE
      
      DIR_OUT = DIR_PLOTS + 'MONTHLY' + SL & DIR_TEST, DIR_OUT
      
      AMAP    = 'L3B2' & MAP4 = 'L3B4'
      PALG    = 'VGPM2'
      CALG    = 'PAN'
      BUFFER  = 0
      VERBOSE = 0
      PERIOD  = 'M'
      MATHS   = ['STATS']
      YEARS   = YEAR_RANGE('1998','2018',/STRING)
            
      YRS  = YEAR_RANGE(MIN(DATE_2YEAR(DATE_RANGE)),MAX(DATE_2YEAR(DATE_RANGE)))
      AX   = DATE_AXIS(MINMAX(YRS),/YEAR,STEP=6)
      MONS = MONTH_RANGE()
      XDIS = 1/13. & XSP = 1/12.-XDIS
      XPOS1 = 0.02+(FINDGEN(12)*XDIS+(XDIS/2)+XSP*2)
      XPOS2 = XPOS1 + XDIS - XSP
      
      STRUCT = IDL_RESTORE(DATFILE)      
      
      PRODS = ['CHLOR_A-PAN','PPD-VGPM2','SST','PAR'];,'DIATOM-PAN','MICRO-PAN','NANO-PAN','PICO-PAN','NANO_PICO-PAN','DIATOM-HIRATA','MICRO-HIRATA','NANO-HIRATA','PICO-HIRATA','MICRO-UITZ','NANO-UITZ','PICO-UITZ']
      
      SENS = ['SAV','AVHRR','SEAWIFS_MODISA'];,'SEAWIFS_MODISA','SEAWIFS_MODISA_VIIRS','SAVJ'];,'OCCCI']
      FOR S=0, N_ELEMENTS(SENS)-1 DO BEGIN
        SEN = SENS(S)
        CASE SEN OF
          'SEAWIFS_MODISA': BEGIN
            SET = STRUCT[WHERE(STRUCT.SENSOR EQ 'SEAWIFS' OR STRUCT.SENSOR EQ 'MODISA' OR STRUCT.SENSOR EQ 'SEAWIFS_SA' OR STRUCT.SENSOR EQ 'MODISA_SA',COUNT)]
            FF = PARSE_IT(SET.NAME)
            OKS = WHERE(STRPOS(SET.SENSOR,'SEAWIFS') GE 0 AND FF.DATE_START LT '20080101000000',COUNT) 
            OKM = WHERE(STRPOS(SET.SENSOR,'MODISA')  GE 0 AND FF.DATE_START GE '20080101000000',COUNT) 
            SET = [SET(OKS),SET(OKM)]
            RSEN = 'SA'
          END
          'SEAWIFS_MODISA_VIIRS': BEGIN
            SET = STRUCT[WHERE(STRPOS(STRUCT.SENSOR,'SEAWIFS') GT 0 OR STRPOS(STRUCT.SENSOR,'MODISA') GT 0 OR STRPOS(STRUCT.SENSOR,'VIIRS') GT 0,COUNT)]
            FF = PARSE_IT(SET.NAME)
            OKS = WHERE(STRPOS(SET.SENSOR,'SEAWIFS') GE 0 AND FF.DATE_START LT '20080101000000',COUNT)
            OKM = WHERE(STRPOS(SET.SENSOR,'MODISA')  GE 0 AND FF.DATE_START GE '20080101000000' AND FF.DATE_START LT '20150101000000',COUNT)
            OKV = WHERE(STRPOS(SET.SENSOR,'MODISA')  GE 0 AND FF.DATE_START LT '20150101000000',COUNT)
            SET = [SET(OKS),SET(OKM),SET(OKV)]
          END
          'SAVJ': BEGIN
            SET = STRUCT[WHERE(STRUCT.SENSOR EQ 'SAVJ',COUNT)]
            SENSOR = 'SAVJ'
            RSEN = 'SAVJ'
          END
          'SAV': BEGIN
            SET = STRUCT[WHERE(STRUCT.SENSOR EQ 'SAV',COUNT)]
            SENSOR = 'SAV'
            RSEN = 'SAV'
          END
          'AVHRR': BEGIN
            OK = WHERE(STRUCT.SENSOR EQ 'AVHRR',COUNT)
            SET = STRUCT[OK]
            SENSOR = 'AVHRR'
            RSEN   = 'AVHRR'
          END;AVHRR
          'OCCCI': BEGIN
            OK = WHERE(STRUCT.SENSOR EQ 'OCCCI',COUNT)
            XET = STRUCT(OK_OCCCI)
            SENSOR = 'OCCCI'
            RSEN   = 'OCCCI'
          END
        ENDCASE
      
        FOR RTH=0, N_ELEMENTS(MATHS)-1 DO BEGIN
          MATH = MATHS(RTH)
          
          FOR R=0, N_ELEMENTS(PRODS)-1 DO BEGIN
            APROD = PRODS(R)
            YMAJOR = 5
            CASE VALIDS('PRODS',APROD) OF
              'SST':     BEGIN & YRANGE = [0,30] & TITLE='Sea Surface Temperature ' + UNITS('SST',/NO_NAME) & ATAG = 'MEAN' & ANOM_MATH = 'ANOMALY_DIF' & YMAJOR=6 & END
              'CHLOR_A': BEGIN & YRANGE = [0,3]  & TITLE='Chlorophyll ' + UNITS('CHLOR_A',/NO_NAME) & ATAG = 'GSTATS_MED' & ANOM_MATH = 'ANOMALY_RATIO' & END
              'PPD':     BEGIN & YRANGE = [0,2]  & TITLE='Primary Production ' + UNITS('PPD',/NO_NAME) & ATAG = 'GSTATS_MED' & ANOM_MATH = 'ANOMALY_RATIO' & END
              'PAR':     BEGIN & YRANGE = [0,60] & TITLE='Photosynthetic Available Radiation ' + UNITS('PAR',/NO_NAME) & ATAG = 'AMEAN' & ANOM_MATH = 'ANOMALY_DIF' & END
            ENDCASE
            
            CASE ANOM_MATH OF
              'ANOMALY_RATIO': BEGIN & ATAG = 'MED'  & ARANGE = [0,2]  & END
              'ANOMALY_DIF':   BEGIN & ATAG = 'AMEAN' & ARANGE = [-2,2] & END
            ENDCASE
            
            
              
            SUBS = WHERE_STRING(SET.NAME,APROD,COUNT)
            IF COUNT GE 1 THEN STR = SET(SUBS) ELSE CONTINUE
            
            FOR N=0, N_ELEMENTS(NAMES)-1 DO BEGIN ; Subareas
              ANAME = NAMES(N)
              STITLE = SUBTITLES(N)
              
              PNGFILE = DIR_OUT + ANAME + '-' + SEN + '-' + APROD + '-' + MATH + '-MONTHLY_TIMESERIES.PNG'
              IF FILE_MAKE(DATFILE,PNGFILE,OVERWRITE=OVERWRITE) EQ 0 THEN CONTINUE
             
              MSET = STR[WHERE(STR.PERIOD_CODE EQ 'M' AND STR.SUBAREA EQ ANAME AND STR.MATH EQ 'STATS' AND STR.N GT 0,/NULL)]
              IF MSET EQ [] THEN CONTINUE
              MONTH = DATE_2MONTH(PERIOD_2DATE(MSET.PERIOD))
             
              BKG = [195,237,255]
              PCLR = [0,53,95]
              SCLR = [0,112,192]
              W = WINDOW(DIMENSIONS=[1300,850], BUFFER=BUFFER)
              PLY = POLYGON([0,1,1,0,0],[0,0,1,1,0],FILL_COLOR=BKG,TRANSPARENCY=80,/CURRENT)
              TTXT = TEXT(0.5,0.96,STITLE,ALIGNMENT=0.5,FONT_SIZE=16,FONT_STYLE='BOLD',COLOR=PCLR)
              FOR M=0, N_ELEMENTS(MONS)-1 DO BEGIN
                AMON = MONS(M)
                MNAME = STRUPCASE(MONTH_NAMES(AMON,/SHORT))
                MON = MSET[WHERE(MONTH EQ AMON AND MSET.PERIOD_CODE EQ 'M',/NULL)]
                IF MON EQ [] THEN CONTINUE
                MON = SORTED(MON,TAG='PERIOD')
                YR  = DATE_2JD(DATE_2YEAR(PERIOD_2DATE(MON.PERIOD)))
                YRS = DATE_2YEAR(PERIOD_2DATE(MON.PERIOD))
                MDATA = GET_TAG(MON,ATAG)
                
                IF M NE 0 THEN YTICKNAMES = REPLICATE('',YMAJOR) ELSE YTICKNAMES=[]
                IF M EQ 0 THEN YTITLE = TITLE ELSE YTITLE = ''
                  
                PL = PLOT(AX.JD, [1,1],XTEXT_COLOR=PCLR,COLOR=PCLR,XCOLOR=PCLR,/NODATA,BACKGROUND_COLOR=BKG,FONT_SIZE=14,XSTYLE=3,POSITION=[XPOS1(M),0.1,XPOS2(M),0.9],/CURRENT,XTICKVALUE=AX.TICKV,XTICKNAME=AX.TICKNAME,XTEXT_ORIENTATION=60,XMINOR=2,YRANGE=YRANGE,YMAJOR=YMAJOR,YTICKNAME=YTICKNAMES,YTITLE=YTITLE)
                PL = PLOT(YR,MDATA,COLOR=SCLR,BACKGROUND_COLOR='WHITE',SYMBOL='CIRCLE',/SYM_FILLED,SYM_SIZE=0.2,SYM_COLOR=SCLR,/OVERPLOT,LINESTYLE=0,THICK=2) ; BACKGROUND_COLOR='GAINSBORO'
                PL = PLOT([YR[0],YR(-1)],[MEDIAN(MDATA),MEDIAN(MDATA)],/OVERPLOT,/CURRENT,XRANGE=MM(YR),THICK=3,COLOR='LIGHT_GREY',YRANGE=YRANGE)
                MK = MANN_KENDALL(MDATA)
                SLP = MK.SLOPE
                INT = MEDIAN(MDATA-SLP*YRS)
                IF MK.SIGNIFICANT EQ 1 THEN PL = PLOT([YR[0],YR(-1)],[SLP*YRS[0]+INT,SLP*YRS(-1)+INT],/OVERPLOT,/CURRENT,XRANGE=MM(YR),THICK=4,COLOR=PCLR,YRANGE=YRANGE)
                
              ;  PX = PLOT(YR,YY,COLOR='BLACK',THICK=2,/OVERPLOT)
                TX = TEXT(XPOS1(M)+(XPOS2-XPOS1)/2,0.91,MNAME,ALIGNMENT=0.5,COLOR=PCLR,FONT_SIZE=12,FONT_STYLE='BOLD')
                  
              ENDFOR ; MONS
              W.SAVE, PNGFILE
              W.CLOSE
              PFILE, PNGFILE
            ENDFOR
              
              ; ===> New version of the monthly time series
            
            CASE VALIDS('PRODS',APROD) OF
              'SST':     BEGIN & YRANGE = [0,25] & Y2TITLE='Sea Surface Temperature ' + UNITS('SST',/NO_NAME) & END
              'CHLOR_A': BEGIN & YRANGE = [0,3]  & Y2TITLE='Chlorophyll ' + UNITS('CHLOR_A',/NO_NAME) & END
              'PPD':     BEGIN & YRANGE = [0,3]  & Y2TITLE='Primary Production ' + UNITS('PPD',/NO_NAME) & END
              'PAR':     BEGIN & YRANGE = [0,60] & Y2TITLE='Photosynthetic Available Radiation ' + UNITS('PAR',/NO_NAME) & END
            ENDCASE
            
            
            
            FOR N=0, N_ELEMENTS(NAMES)-1 DO BEGIN ; Subareas
              ANAME = NAMES(N)
              STITLE = SUBTITLES(N)
              
              PNGFILE = DIR_OUT + ANAME + '-' + SEN + '-' + APROD + '-' + MATH + '-MONTHLY_TIMESERIES_V2.PNG'
              IF FILE_MAKE(DATFILE,PNGFILE,OVERWRITE=OVERWRITE) EQ 0 THEN CONTINUE

              MSET = STR[WHERE(STR.PERIOD_CODE EQ 'M' AND STR.SUBAREA EQ ANAME AND STR.MATH EQ 'STATS' AND STR.N GT 0,/NULL)]
              IF MSET EQ [] THEN CONTINUE
              MONTH = DATE_2MONTH(PERIOD_2DATE(MSET.PERIOD))


              ;   MSET.PERIOD = STRMID(MSET.PERIOD,6,2)+STRMID(MSET.PERIOD,2,4)
              ;   MSET = STRUCT_SORT(MSET,TAGNAMES='PERIOD')
              PER = MSET.PERIOD
              BSET = WHERE_SETS(DATE_2YEAR(PERIOD_2DATE(PER)))
              MONTHS = MONTH_RANGE(/STRING)
              YEARS = YEAR_RANGE(MIN(DATE_2YEAR(PERIOD_2DATE(PER))),MAX(DATE_2YEAR(PERIOD_2DATE(PER)))) & NYEARS = N_ELEMENTS(YEARS) & MID=NYEARS/2 & MIDYEAR=YEARS(MID)
              PER = []
              FOR B=0, N_ELEMENTS(BSET)-1 DO PER = [PER,MONTHS+BSET(B).VALUE]
              PER = PER[SORT(PER)]
              PERNUM = FINDGEN(N_ELEMENTS(PER))
              MID = WHERE(STRMID(PER,2,4) EQ MIDYEAR)

              XTICKNAME = MONTH_NAMES(/SHORT)
              XTICKVALUE = PERNUM(MID)              
              W = WINDOW(DIMENSIONS=[1200,800], BUFFER=BUFFER)
              PL = PLOT(MM(PERNUM), YRANGE,/NODATA,XSTYLE=3,/CURRENT,POSITION=[0.08,0.07,0.97,0.94],FONT_SIZE=14,$
                XTICKVALUE=XTICKVALUE,XTICKNAME=XTICKNAME,XMINOR=1,XTICKLEN=0.03,XTITLE='Annual Time Series by Month',YTICKLEN=0.03,YRANGE=YRANGE,YMAJOR=4,YMINOR=3,YTICKNAME=YTICKNAME,YTITLE=Y2TITLE)
    
              
              TTXT = TEXT(0.5,0.96,STITLE,ALIGNMENT=0.5,FONT_SIZE=16,FONT_STYLE='BOLD')
              

              ;    PLOT, XDATES,REPLICATE(0.0,N_ELEMENTS(XDATES)),/NO_DATA, XTICKVALUE=XTICKV, XTICKNAME=XTICKNAME, YRANGE=YRANGE, YTITLE=UNITS('CHLOROPHYLL')
              FOR M=0, N_ELEMENTS(MONS)-1 DO BEGIN
                AMON = MONS(M)
                MNAME = STRUPCASE(MONTH_NAMES(AMON,/SHORT))
                MON = MSET[WHERE(MONTH EQ AMON AND MSET.PERIOD_CODE EQ 'M',/NULL)]
                IF MON EQ [] THEN CONTINUE
                MON = SORTED(MON,TAG='PERIOD')
                DT = STRMID(MON.PERIOD,6,2)+STRMID(MON.PERIOD,2,4)
                OK = WHERE_MATCH(PER,DT)
                PNUM = PERNUM[OK]
                YR   = DATE_2JD(DATE_2YEAR(PERIOD_2DATE(MON.PERIOD)))
                MDATA = GET_TAG(MON,ATAG)
                PL = PLOT(PNUM,MDATA,THICK=2,/OVERPLOT,/CURRENT,XRANGE=MM(PERNUM),YRANGE=YRANGE) ; SYMBOL='CIRCLE',/SYM_FILLED,SYM_SIZE=0.2,SYM_COLOR='RED',
                PL = PLOT(MM(PNUM),[MEDIAN(MDATA),MEDIAN(MDATA)],/OVERPLOT,/CURRENT,XRANGE=MM(PERNUM),THICK=3,COLOR='LIGHT_GREY',YRANGE=YRANGE)
                MK = MANN_KENDALL(ALOG(MDATA))
                SLP = MK.SLOPE
                INT = MEDIAN(MDATA-SLP*PNUM)
                IF MK.SIGNIFICANT EQ 1 THEN PL = PLOT(MM(PNUM),[SLP*PNUM[0]+INT,SLP*PNUM(-1)+INT],/OVERPLOT,/CURRENT,XRANGE=MM(PERNUM),THICK=4,COLOR='RED',YRANGE=YRANGE)
              ENDFOR
              W.SAVE, PNGFILE
              W.CLOSE
              PFILE, PNGFILE


                ; Monthly data plot
                ; Convert YYYYMM to MMYYYY
                ; XTICKRANGE = 011998 to 122018
                ; May want to add a spacer between the months, e.g. 0102019 point in the X range
                ; First nodata plot Xvalues with xticks etc and y range
                ;
                ; XDATA = WHERE(D.PROD EQ 'CHLOR_A-PAN' AND PERIOD_CODE = 'A')
                ; DP = DATE_PARSE(PERIOD_2DATE(XDATA.PERIOD))
                ; B = WHERE_SETS(DP.MONTH)
                ;
                ;
                ; YRS = YEAR_RANGE('1998','2020',/STRING)
                ; MTH = MONTH_RANGE(/STRING)
                ; XDATES = []
                ; FOR M=0, N_ELEMENTS(MTH)-1 DO XDATES = [XDATES,MTH(M)+YRS]
                ; XTICKV = WHERE(STRMID(XDATE,2,4) EQ '2009')
                ; XTICKNAME = ['J','F','M','A','M','J','J','A','S','O','N','D']
                ; YRANGE = [0.0,15.0]
                ; PLOT, XDATES,REPLICATE(0.0,N_ELEMENTS(XDATES)),/NO_DATA, XTICKVALUE=XTICKV, XTICKNAME=XTICKNAME, YRANGE=YRANGE, YTITLE=UNITS('CHLOROPHYLL')
                ; FOR M=0, N_ELEMENTS(B)-1 DO BEGIN
                ;   XDAT = XDATA[WHERE_SETS_SUBS(B(M))]
                ;   X = STRMID(XDAT.PERIOD,6,2)+STRMID(XDAT.PERIOD,2,4)
                ;   PLOT, X, XDAT.MEDIAN, /OVERPLOT,
                ;   PLOT, [X[0],X(-1)],REPLICATE(MEDIAN(XDAT.MEDIAN),2),/OVERPLOT
                ; ENDFOR



                
              
                
              
              ENDFOR ; PRODS
            ENDFOR ; NAMES
          ENDFOR ; MATHS
        ENDFOR ; SENSORS  
              
                          

;              SPRODS = ['DIATOM','MICRO','NANO','PICO']
;              SUBS = WHERE(STR.PROD EQ 'MICRO' OR STR.PROD EQ 'NANO' OR STR.PROD EQ 'PICO' OR STR.PROD EQ 'DIATOM' AND STR.SUBAREA EQ ANAME,COUNT)
;              SR = STR(SUBS)
;              SR(WHERE_STRING(SR.NAME,'PAN')).ALG = 'PAN'
;              SR(WHERE_STRING(SR.NAME,'UITZ')).ALG = 'UITZ'
;              SR(WHERE_STRING(SR.NAME,'HIRATA')).ALG = 'HIRATA'
;              SETS = WHERE_SETS(SR.PROD)
;              XDIM      = 790
;              YDIM      = 256 * N_ELEMENTS(SPRODS)
;              NPLOTS = N_ELEMENTS(SETS)
;              
;              AXM  = DATE_AXIS(['1998','2018'],/MONTH, /YY_YEAR,STEP_SIZE=12) & AYR = DATE_AXIS(X,/YEAR)
;              XTICKNAMES = REPLICATE(' ',N_ELEMENTS(AXM.TICKNAME))
;              COLORS = ['RED','CYAN','BLUE','SPRING_GREEN','ORANGE','DARK_BLUE','MAGENTA']
;              YMINOR=1
;              FONTSIZE = 8.5
;              SYMSIZE = 0.45
;              THICK = 2
;              FONT = 0
;              YMARGIN = [0.3,0.3]
;              XMARGIN = [4,1]
;              
;              SC = 0.03
;              X1 = 0.08
;              X2 = 0.96
;              YS = (1.0-(SC*(NPLOTS+2)))/NPLOTS
;              Y1 = 1.0-SC-YS
;              Y2 = 1.0-SC
;              ALGS = ['PAN','UITZ','HIRATA']
;              YRANGE = [0,1]
;
;              PNGFILE = DIR_PLOTS + 'COMPARE-' + SP + '-' + ANAME + '-' + 'PHYTO_COMPARE' + '-' + MATH + '-MONTHLY_TIMESERIES.PNG'
;              W = WINDOW(DIMENSIONS=[XDIM,YDIM],BUFFER=0)
;              FOR B=0, N_ELEMENTS(SETS)-1 DO BEGIN
;                SET = SR(WHERE_SETS_SUBS(SETS(B)))
;                TPROD = SET[0].PROD
;                IF B GT 0 THEN Y1 = Y1 - YS - SC
;                IF B GT 0 THEN Y2 = Y2 - YS - SC
;                POSITION = [X1,Y1,X2,Y2]
;
;                IF B EQ N_ELEMENTS(SETS)-1 THEN XTICKNAME=AXM.TICKNAME ELSE XTICKNAME=XTICKNAMES
;                PD = PLOT(AXM.JD,YRANGE,YTITLE=UNITS(TPROD),FONT_SIZE=FONTSIZE,YMINOR=YMINOR,XMAJOR=AXM.TICKS,XMINOR=3,XTICKNAME=XTICKNAME,XTICKVALUES=AXM.TICKV,POSITION=POSITION,/NODATA,/CURRENT)
;                POS = PD.POSITION
;                XTICKV = PD.XTICKVALUES & OK = WHERE(JD_2MONTH(XTICKV) EQ '01',COUNT)
;                FOR G=1,COUNT-1 DO GR = PLOT([XTICKV(OK(G)),XTICKV(OK(G))],YRANGE,COLOR='GREY',/OVERPLOT,XRANGE=AXM.JD,YRANGE=YRANGE)
;
;                FOR S=0, N_ELEMENTS(ALGS)-1 DO BEGIN
;                  AA = SET[WHERE(SET.ALG EQ ALGS(S) AND SET.MED NE MISSINGS(0.0),/NULL)]
;                  IF AA EQ [] THEN CONTINUE
;                  AA = SORTED(AA,TAG='PERIOD')
;                  P1 = PLOT(PERIOD_2JD(AA.PERIOD),AA.MED,XRANGE=AXM.JD,YRANGE=YRANGE,/OVERPLOT,/CURRENT,LINESTYLE=0,COLOR=COLORS(S),SYMBOL='CIRCLE',SYM_SIZE=0.25,/SYM_FILLED)
;                  TS = TEXT(0.095,POS(3)-0.03-(0.015*S),ALGS(S),FONT_COLOR=COLORS(S),FONT_SIZE=FONTSIZE+2,FONT_STYLE='BOLD')
;                ENDFOR
;                TD = TEXT(.94,POS(3)-0.03,SET[0].SUBAREA,FONT_SIZE=FONTSIZE+2,FONT_STYLE='BOLD',ALIGNMENT=1)
;              ENDFOR
;              
;              W.SAVE, PNGFILE;, RESOLUTION=300
;              W.CLOSE
;              PFILE, PNGFILE
         
    ENDIF ; MONTHLY TIMESERIES      
    

; ********************************************
    IF KEY(SEASONAL_TIMESERIES) THEN BEGIN
; ********************************************
      SNAME = 'SEASONAL_TIMESERIES'
      PRINT, 'Running: ' + SNAME + ' for ' + SOE_YR
      SWITCHES,SEASONAL_TIMESERIES,STOPP=STOPP,OVERWRITE=OVERWRITE,VERBOSE=VERBOSE,INIT=INIT,R_FILES=R_FILES,R_DATASETS=R_DATASETS,R_MAPS=R_MAPS,DATERANGE=DATERANGE

      DIR_OUT = DIR_PLOTS + 'SEASONAL' + SL & DIR_TEST, DIR_OUT

      AMAP    = 'L3B2' & MAP4 = 'L3B4'
      PALG    = 'VGPM2'
      CALG    = 'PAN'
      BUFFER  = 0
      VERBOSE = 0
      PERIOD  = 'M'
      MATHS   = ['STATS']
      YEARS   = YEAR_RANGE('1998','2019',/STRING)

      YRS  = YEAR_RANGE(MIN(DATE_2YEAR(DATE_RANGE)),MAX(DATE_2YEAR(DATE_RANGE)))
      AX   = DATE_AXIS(MINMAX(YRS),/YEAR,STEP=5)
      MONS = MONTH_RANGE()
      XDIS = 1/13. & XSP = 1/12.-XDIS
      XPOS1 = FINDGEN(12)*XDIS+(XDIS/2)+XSP*2
      XPOS2 = XPOS1 + XDIS - XSP

      STRUCT = IDL_RESTORE(DATFILE)

      PRODS = ['CHLOR_A-PAN','PPD-VGPM2','SST','PAR'];,'DIATOM-PAN','MICRO-PAN','NANO-PAN','PICO-PAN','NANO_PICO-PAN','DIATOM-HIRATA','MICRO-HIRATA','NANO-HIRATA','PICO-HIRATA','MICRO-UITZ','NANO-UITZ','PICO-UITZ']

      SENS = ['SAV','SEAWIFS_MODISA','SEAWIFS_MODISA_VIIRS','SAVJ'];,'OCCCI']
      
      FOR S=0, N_ELEMENTS(SENS)-1 DO BEGIN
        SEN = SENS(S)
        CASE SEN OF
          'SEAWIFS_MODISA': BEGIN
            SET = STRUCT[WHERE(STRUCT.SENSOR EQ 'SEAWIFS' OR STRUCT.SENSOR EQ 'MODISA' OR STRUCT.SENSOR EQ 'SEAWIFS_SA' OR STRUCT.SENSOR EQ 'MODISA_SA',COUNT)]
            FF = PARSE_IT(SET.NAME)
            OKS = WHERE(STRPOS(SET.SENSOR,'SEAWIFS') GE 0 AND FF.DATE_START LT '20080101000000',COUNT)
            OKM = WHERE(STRPOS(SET.SENSOR,'MODISA')  GE 0 AND FF.DATE_START GE '20080101000000',COUNT)
            SET = [SET(OKS),SET(OKM)]
            RSEN = 'SA'
          END
          'SEAWIFS_MODISA_VIIRS': BEGIN
            SET = STRUCT[WHERE(STRPOS(STRUCT.SENSOR,'SEAWIFS') GT 0 OR STRPOS(STRUCT.SENSOR,'MODISA') GT 0 OR STRPOS(STRUCT.SENSOR,'VIIRS') GT 0,COUNT)]
            FF = PARSE_IT(SET.NAME)
            OKS = WHERE(STRPOS(SET.SENSOR,'SEAWIFS') GE 0 AND FF.DATE_START LT '20080101000000',COUNT)
            OKM = WHERE(STRPOS(SET.SENSOR,'MODISA')  GE 0 AND FF.DATE_START GE '20080101000000' AND FF.DATE_START LT '20150101000000',COUNT)
            OKV = WHERE(STRPOS(SET.SENSOR,'MODISA')  GE 0 AND FF.DATE_START LT '20150101000000',COUNT)
            SET = [SET(OKS),SET(OKM),SET(OKV)]
          END
          'SAVJ': BEGIN
            SET = STRUCT[WHERE(STRUCT.SENSOR EQ 'SAVJ',COUNT)]
            SENSOR = 'SAVJ'
            RSEN = 'SAVJ'
          END
          'SAV': BEGIN
            SET = STRUCT[WHERE(STRUCT.SENSOR EQ 'SAV',COUNT)]
            SENSOR = 'SAV'
            RSEN = 'SAV'
          END
          'OCCCI': BEGIN
            OK = WHERE(STRUCT.SENSOR EQ 'OCCCI',COUNT)
            XET = STRUCT(OK_OCCCI)
            SENSOR = 'OCCCI'
            RSEN   = 'OCCCI'
          END
        ENDCASE

        FOR RTH=0, N_ELEMENTS(MATHS)-1 DO BEGIN
          MATH = MATHS(RTH)

          FOR R=0, N_ELEMENTS(PRODS)-1 DO BEGIN
            APROD = PRODS(R)
            CASE VALIDS('PRODS',APROD) OF
              'SST':     BEGIN & YRANGE = [0,25] & ATAG = 'MEAN' & ANOM_MATH = 'ANOMALY_DIF' & END
              'CHLOR_A': BEGIN & YRANGE = [0,3]  & ATAG = 'GSTATS_MED' & ANOM_MATH = 'ANOMALY_RATIO' & END
              'PPD':     BEGIN & YRANGE = [0,3]  & ATAG = 'GSTATS_MED' & ANOM_MATH = 'ANOMALY_RATIO' & END
              'PAR':     BEGIN & YRANGE = [0,60]  & ATAG = 'MEAN' & ANOM_MATH = 'ANOMALY_DIF' & END
            ENDCASE

            CASE ANOM_MATH OF
              'ANOMALY_RATIO': BEGIN & ATAG = 'MED'  & YRANGE = [0,2]  & END
              'ANOMALY_DIF':   BEGIN & ATAG = 'MEAN' & YRANGE = [-2,2] & END
            ENDCASE

            TITLE = APROD + ' ' + UNITS(VALIDS('PRODS',APROD),/NO_NAME)

            SUBS = WHERE_STRING(SET.NAME,APROD,COUNT)
            IF COUNT GE 1 THEN STR = SET(SUBS) ELSE CONTINUE
            
            ; ===> New version of the monthly time series

            CASE VALIDS('PRODS',APROD) OF
              'SST':     BEGIN & YRANGE = [0,25] & Y2TITLE='Sea Surface Temperature ' + UNITS('SST',/NO_NAME) & END
              'CHLOR_A': BEGIN & YRANGE = [0,3]  & Y2TITLE='Chlorophyll ' + UNITS('CHLOR_A',/NO_NAME) & & END
              'PPD':     BEGIN & YRANGE = [0,3]  & Y2TITLE='Primary Production ' + UNITS('PPD',/NO_NAME) & END
            ENDCASE



            FOR N=0, N_ELEMENTS(NAMES)-1 DO BEGIN ; Subareas
              ANAME = NAMES(N)
              STITLE = SUBTITLES(N)

              PNGFILE = DIR_OUT + ANAME + '-' + SEN + '-' + APROD + '-' + MATH + '-SEASONAL_TIMESERIES_V2.PNG'
              IF FILE_MAKE(DATFILE,PNGFILE,OVERWRITE=OVERWRITE) EQ 0 THEN CONTINUE

              MSET = STR[WHERE(STR.PERIOD_CODE EQ 'M3' AND STR.SUBAREA EQ ANAME AND STR.MATH EQ 'STATS' AND STR.N GT 0,/NULL)]
              IF MSET EQ [] THEN CONTINUE
              MONTH = DATE_2MONTH(PERIOD_2DATE(MSET.PERIOD))
              VALID_MONTHS = ['01','04','07','10']
              stop


              ;   MSET.PERIOD = STRMID(MSET.PERIOD,6,2)+STRMID(MSET.PERIOD,2,4)
              ;   MSET = STRUCT_SORT(MSET,TAGNAMES='PERIOD')
              PER = MSET.PERIOD
              BSET = WHERE_SETS(DATE_2YEAR(PERIOD_2DATE(PER)))
              MONTHS = MONTH_RANGE(/STRING)
              YEARS = YEAR_RANGE(MIN(DATE_2YEAR(PERIOD_2DATE(PER))),MAX(DATE_2YEAR(PERIOD_2DATE(PER)))) & NYEARS = N_ELEMENTS(YEARS) & MID=NYEARS/2 & MIDYEAR=YEARS(MID)
              PER = []
              FOR B=0, N_ELEMENTS(BSET)-1 DO PER = [PER,MONTHS+BSET(B).VALUE]
              PER = PER[SORT(PER)]
              PERNUM = FINDGEN(N_ELEMENTS(PER))
              MID = WHERE(STRMID(PER,2,4) EQ MIDYEAR)

              XTICKNAME = MONTH_NAMES(/SHORT)
              XTICKVALUE = PERNUM(MID)
              W = WINDOW(DIMENSIONS=[1200,800], BUFFER=BUFFER)
              PL = PLOT(MM(PERNUM), YRANGE,/NODATA,XSTYLE=3,/CURRENT,POSITION=[0.08,0.07,0.97,0.94],FONT_SIZE=14,$
                XTICKVALUE=XTICKVALUE,XTICKNAME=XTICKNAME,XMINOR=1,XTICKLEN=0.03,XTITLE='Annual Time Series by Month',YTICKLEN=0.03,YRANGE=YRANGE,YMAJOR=4,YMINOR=3,YTICKNAME=YTICKNAME,YTITLE=Y2TITLE)
              TTXT = TEXT(0.5,0.96,STITLE,ALIGNMENT=0.5,FONT_SIZE=16,FONT_STYLE='BOLD')

              FOR M=0, N_ELEMENTS(MONS)-1 DO BEGIN
                AMON = MONS(M)
                MNAME = STRUPCASE(MONTH_NAMES(AMON,/SHORT))
                MON = MSET[WHERE(MONTH EQ AMON AND MSET.PERIOD_CODE EQ 'M',/NULL)]
                IF MON EQ [] THEN CONTINUE
                MON = SORTED(MON,TAG='PERIOD')
                DT = STRMID(MON.PERIOD,6,2)+STRMID(MON.PERIOD,2,4)
                OK = WHERE_MATCH(PER,DT)
                PNUM = PERNUM[OK]
                YR   = DATE_2JD(DATE_2YEAR(PERIOD_2DATE(MON.PERIOD)))
                MDATA = GET_TAG(MON,ATAG)
                PL = PLOT(PNUM,MDATA,THICK=2,/OVERPLOT,/CURRENT,XRANGE=MM(PERNUM),YRANGE=YRANGE) ; SYMBOL='CIRCLE',/SYM_FILLED,SYM_SIZE=0.2,SYM_COLOR='RED',
                PL = PLOT(MM(PNUM),[MEDIAN(MDATA),MEDIAN(MDATA)],/OVERPLOT,/CURRENT,XRANGE=MM(PERNUM),THICK=3,COLOR='LIGHT_GREY',YRANGE=YRANGE)
                MK = MANN_KENDALL(ALOG(MDATA))
                SLP = MK.SLOPE
                INT = MEDIAN(MDATA-SLP*PNUM)
                IF MK.SIGNIFICANT EQ 1 THEN PL = PLOT(MM(PNUM),[SLP*PNUM[0]+INT,SLP*PNUM(-1)+INT],/OVERPLOT,/CURRENT,XRANGE=MM(PERNUM),THICK=4,COLOR='RED',YRANGE=YRANGE)
              ENDFOR
              W.SAVE, PNGFILE
              W.CLOSE
              PFILE, PNGFILE
            ENDFOR
          ENDFOR
        ENDFOR
      ENDFOR
    ENDIF          

    
; ********************************************
    IF KEY(WEEKLY_ANOMS) THEN BEGIN
; ********************************************
      SNAME = 'WEEKLY_ANOMS'
      PRINT, 'Running: ' + SNAME + ' for ' + SOE_YR
      SWITCHES,WEEKLY_ANOMS,STOPP=STOPP,OVERWRITE=OVERWRITE,VERBOSE=VERBOSE,INIT=INIT,R_FILES=R_FILES,R_DATASETS=R_DATASETS,R_MAPS=R_MAPS,DATERANGE=DATERANGE

      BUFFER = 1
      STRUCT = IDL_RESTORE(DATFILE)
      
      DIR_OUT = DIR_PLOTS + 'WEEKLY' + SL & DIR_TEST, [DIR_OUT,DIR_OUT+'GIFS'+SL]
      
      OK_OCCCI = WHERE(STRUCT.SENSOR EQ 'OCCCI',COMPLEMENT=OK_SEAMOD)

      SENS = ['SEAWIFS_MODISA','SAVJ']
      FOR SN=0, N_ELEMENTS(SENS)-1 DO BEGIN
        SEN = SENS(SN)
        CASE SEN OF
          'SEAWIFS_MODISA': BEGIN
            SET = STRUCT[WHERE(STRUCT.SENSOR EQ 'SEAWIFS' OR STRUCT.SENSOR EQ 'MODISA' OR STRUCT.SENSOR EQ 'SEAWIFS_SA' OR STRUCT.SENSOR EQ 'MODISA_SA',COUNT)]
            FF = PARSE_IT(SET.NAME)
            OKS = WHERE(STRPOS(SET.SENSOR,'SEAWIFS') GE 0 AND FF.DATE_START LT '20080101000000',COUNT) 
            OKM = WHERE(STRPOS(SET.SENSOR,'MODISA')  GE 0 AND FF.DATE_START GE '20080101000000',COUNT) 
            SET = [SET(OKS),SET(OKM)]
            RSEN = 'SA'
          END
          'SEAWIFS_MODIS_VIIRS': BEGIN
            SET = STRUCT[WHERE(STRPOS(STRUCT.SENSOR,'SEAWIFS') GT 0 OR STRPOS(STRUCT.SENSOR,'MODISA') GT 0 OR STRPOS(STRUCT.SENSOR,'VIIRS') GT 0,COUNT)]
            FF = PARSE_IT(SET.NAME)
            IF FIX(YR) LT 2008 THEN SENSOR = 'SEAWIFS'
            IF FIX(YR) GE 2008 AND FIX(YR) LT 2015 THEN SENSOR = 'MODISA'
            IF FIX(YR) GE 2015 THEN SENSOR = 'VIIRS'
            OKS = WHERE(STRPOS(SET.SENSOR,'SEAWIFS') GE 0 AND FF.DATE_START LT '20080101000000',COUNT)
            OKM = WHERE(STRPOS(SET.SENSOR,'MODISA')  GE 0 AND FF.DATE_START GE '20080101000000' AND FF.DATE_START LT '20150101000000',COUNT)
            OKV = WHERE(STRPOS(SET.SENSOR,'MODISA')  GE 0 AND FF.DATE_START LT '20150101000000',COUNT)
            SET = [SET(OKS),SET(OKM),SET(OKV)]
            RSEN = 'SAV'
          END
          'SAVJ': BEGIN
            SET = STRUCT[WHERE(STRUCT.SENSOR EQ 'SAVJ',COUNT)]
            SENSOR = 'SAVJ'
            RSEN = 'SAVJ'
          END
          'OCCCI': BEGIN
            OK = WHERE(STRUCT.SENSOR EQ 'OCCCI',COUNT)
            XET = STRUCT(OK_OCCCI)
            SENSOR = 'OCCCI'
            RSEN   = 'OCCCI'
          END
        ENDCASE
        
        
;        CASE SEN OF
;          'SAVJ': SET = STRUCT(
;          'SEAWIFS_MODISA': SET = STRUCT(OK_SEAMOD)
;          'OCCCI': SET = STRUCT(OK_OCCCI)
;        ENDCASE

        WSTR = SET[WHERE(SET.PERIOD_CODE EQ 'W'    AND SET.MATH EQ 'STATS',/NULL)]
        KSTR = SET[WHERE(SET.PERIOD_CODE EQ 'WEEK' AND SET.MATH EQ 'STATS',/NULL)]
      
        PRODS = ['CHLOR_A-PAN','PPD-VGPM2']
        TITLES = UNITS(['CHLOROPHYLL','PRIMARY_PRODUCTION'])
        YRNG  = LIST([0.0,1.6],[0.0,2.2])
        AX = DATE_AXIS([210001,210012],/MONTH,/FYEAR,STEP=1,/MID)
        MTHICK = 3
        PSTATS = 'GSTATS_MED'
        YEARS = YEAR_RANGE(DATE_RANGE[0],DATE_RANGE[1],/STRING)
        FOR STH=0, N_ELEMENTS(PSTATS)-1 DO BEGIN
          GIFS = []
          FOR S=0, N_ELEMENTS(YEARS)-1 DO BEGIN
            YEAR = YEARS(S)
            GFILE = DIR_OUT + 'GIFS' + SL + 'W_' + YEAR +'-' + SEN + '-' + STRJOIN(PRODS,'_')+'-'+PSTATS(STH)+ '-SEASONAL_CLIMATOLOGY.gif'
            PNGFILE = DIR_OUT             + 'W_' + YEAR +'-' + SEN + '-' + STRJOIN(PRODS,'_')+'-'+PSTATS(STH)+ '-SEASONAL_CLIMATOLOGY.png'
            GIFS = [GIFS,GFILE]
            IF FILE_MAKE(DATFILE,[PNGFILE,GFILE],OVERWRITE=OVERWRITE) EQ 0 THEN CONTINUE
            W = WINDOW(DIMENSIONS=[800,1200],BUFFER=BUFFER)
            T = TEXT(0.5,0.98,YEAR,ALIGNMENT=0.5,FONT_SIZE=14,FONT_STYLE='BOLD',/NORMAL)
            LO = 0
            FOR FTH=0L, N_ELEMENTS(NAMES)-1 DO BEGIN
              FOR PTH=0, N_ELEMENTS(PRODS)-1 DO BEGIN
                LO = LO+1
                PROD = PRODS(PTH)
                YRANGE = YRNG(PTH)
                YSTR = WSTR[WHERE(DATE_2YEAR(PERIOD_2DATE(WSTR.PERIOD)) EQ YEAR AND WSTR.SUBAREA EQ NAMES(FTH) AND WSTR.PROD EQ VALIDS('PRODS',PROD) AND WSTR.ALG EQ VALIDS('ALGS',PROD),/NULL)]
                RSTR = KSTR[WHERE(KSTR.SUBAREA EQ NAMES(FTH) AND KSTR.PROD EQ VALIDS('PRODS',PROD) AND KSTR.ALG EQ VALIDS('ALGS',PROD),/NULL)]
  
                WDATE = DATE_2JD(YDOY_2DATE('2100',DATE_2DOY(PERIOD_2DATE(YSTR.PERIOD))))
                WDATA = GET_TAG(YSTR,PSTATS(STH))
  
                KDATE = DATE_2JD(YDOY_2DATE('2100',DATE_2DOY(PERIOD_2DATE(RSTR.PERIOD))))
                KDATA = GET_TAG(RSTR,PSTATS(STH)) & ADATA = KDATA & BDATA = KDATA
                KSTD  = GET_TAG(RSTR,'GSTATS_STD')
  
                OKA = WHERE(WDATA GE KDATA,COUNTA) & OKB = WHERE(WDATA LE KDATA,COUNTB)
                ADATA(OKA) = WDATA(OKA) & BDATA(OKB) = WDATA(OKB)
  
                P0 = PLOT(WDATE,WDATA,/NODATA,/CURRENT,LAYOUT=[2,3,LO],XRANGE=AX.JD,YRANGE=YRANGE,XTICKNAME=AX.TICKNAME,XTICKVALUES=AX.TICKV,XMINOR=0,XSTYLE=1,YMAJOR=YMAJOR,YTICKV=YTICKS,YTITLE=TITLES(PTH),MARGIN=[0.13,0.05,0.05,0.07])
               ; P1 = POLYGON([KDATE,REVERSE(KDATE)],[KDATA+KSTD,  REVERSE(KDATA-KSTD)],  FILL_COLOR='LIGHT_GREY',FILL_TRANSPARENCY=65,LINESTYLE=6,/OVERPLOT,/DATA,TARGET=P0)
               ; P2 = POLYGON([KDATE,REVERSE(KDATE)],[KDATA+KSTD*2,REVERSE(KDATA-KSTD*2)],FILL_COLOR='LIGHT_GREY',FILL_TRANSPARENCY=75,LINESTYLE=6,/OVERPLOT,/DATA,TARGET=P0)
                PA = POLYGON([KDATE,REVERSE(KDATE)],[KDATA,REVERSE(ADATA)],FILL_COLOR='SPRING_GREEN',FILL_TRANSPARENCY=50,LINESTYLE=6,/OVERPLOT,/DATA,TARGET=P0)
                PB = POLYGON([KDATE,REVERSE(KDATE)],[KDATA,REVERSE(BDATA)],FILL_COLOR='MEDIUM_BLUE', FILL_TRANSPARENCY=50,LINESTYLE=6,/OVERPLOT,/DATA,TARGET=P0)
                PM = PLOT(KDATE,KDATA,COLOR='BLACK',/CURRENT,/OVERPLOT,THICK=MTHICK);,XRANGE=AX.JD,YRANGE=[MR1(P),MR2(P)],XTICKNAME=AX.TICKNAME,XTICKVALUES=AX.TICKV,XMINOR=0,XSTYLE=1)
                TN = TEXT(KDATE(2),MAX(YRANGE)*.9,NAMES(FTH),TARGET=PM,FONT_SIZE=12,/DATA)
              ENDFOR ; PRODS
            ENDFOR ; NAMES
            W.SAVE, PNGFILE
            W.SAVE, GFILE
            W.CLOSE
            PFILE, GFILE
          ENDFOR  ; YEARS
        ENDFOR ; PSTATS 
      ENDFOR ; SENSORS   
              
      IF FILE_MAKE(GIFS,DIR_OUT+'WEEKLY_ANOMS.gif',OVERWRITE=OVERWRITE) EQ 1 AND GIFS NE [] THEN BEGIN
        CD, DIR_OUT
        PFILE, 'WEEKLY_ANOMS.gif'
        IF EXISTS('WEEKLY_ANOMS.gif') THEN FILE_DELETE,'WEEKLY_ANOMS.gif'
        DELAY = '4'
        CMD = 'gifsicle --delay=' + delay + ' --loop '+'W_*.gif>'+'WEEKLY_ANOMS.gif'
        SPAWN, CMD, LOG, ERR
        CD, !S.PROGRAMS
      ENDIF
      
    ENDIF ; WEEKLY_ANOMS  


; ********************************************
    IF KEY(SEASONAL_COMPS) THEN BEGIN
; ********************************************

      SNAME = SEASONAL_COMPS
      PRINT, 'Running: ' + 'STATS_GIF'
      SWITCHES,SEASONAL_COMPS,STOPP=STOPP,OVERWRITE=OVERWRITE,VERBOSE=VERBOSE,INIT=INIT,R_FILES=R_FILES,R_DATASETS=R_DATASETS,R_MAPS=R_MAPS,DATASETS=DATASETS,DATERANGE=DATERANGE

      DIR = DIR_PLOTS 
      
      CLRS = LIST([217,241,253],[193,232,251],[0,173,238],[0,83,159],[37,64,143],[255,255,255])
      LOGO = !S.PROJECTS + 'EDAB' + SL + 'IEA_WEBSITE' + SL + 'NOAA2.png'
      LG = READ_PNG(LOGO) & LG = LG(*,*,380:999)
      
      SUBAREA = 'NES_EPU_EXTENDED'
      SHPS = READ_SHPFILE(SUBAREA, MAPP='NEC', COLOR=COLORS, VERBOSE=VERBOSE)
      OUTLINE = [SHPS.GB.OUTLINE,SHPS.MAB.OUTLINE,SHPS.GOM.OUTLINE]
      
      MAPOUT = 'NEC'
      PRODS   = ['CHL','PPD','SST']
      PERIODS = ['SEASONAL','ANNUAL','MONTHLY']
      TYPES   = ['ANOMS','STATS','ANOMS-LTM']
      OTHER   = ['UPWELLING']
      SUBS    = [];(['AVHRR-NEC','MUR-NEC','OCCCI-NEC'])
      FOR P=0, N_ELEMENTS(PRODS)-1 DO FOR R=0, N_ELEMENTS(PERIODS)-1 DO FOR T=0, N_ELEMENTS(TYPES)-1 DO SUBS = [SUBS,STRJOIN([PRODS(P),PERIODS(R),TYPES(T)],'_')]
      
      FOR S=0, N_ELEMENTS(SUBS)-1 DO BEGIN
        BUFFER = 1
        OVERWRITE = 0
        PNGS = []
        OCOLOR = 0
        NCOLOR = CLRS(5)
        DELAY = '100'
        SUB = STR_SEP(SUBS(S),'_')
        
   ;     IF HAS(SUBS(S),'OCCCI')   THEN GOTO, OCCCI
   ;     IF HAS(SUBS(S),'MUR-')    THEN GOTO, MUR
        
        IF SUB[1] EQ 'MONTHLY' AND SUB(2) EQ 'ANOMS' THEN CONTINUE
        
      
        CASE SUB[1] OF
          'ANNUAL':   PER = 'A'
          'MONTHLY':  BEGIN & PER='MONTH' & DELAY = '75' & END
          'SEASONAL': PER='M3'
        ENDCASE
      
        CASE SUB[0] OF
          'PPD': BEGIN
            DATASET = 'SEAWIFS_MODISA'
            F = FLS(!S.PP + 'MODISA' + '/L3B2/'+SUB[2]+'/PPD-VGPM2/' + PER + '*',DATERANGE=[2002,2019],COUNT=COUNTF)
            IF COUNTF EQ 0 THEN GOTO, SKIP_PNGS
            IF PER EQ 'A_' OR PER EQ 'M3_' THEN BEGIN
              F = DATE_SELECT(F,[2008,2019])
              F = [FLS(!S.PP + 'SEAWIFS/L3B2/'+SUB[2]+'/PPD-VGPM2/' + PER + '*',DATERANGE=[1998,2007]),F]
            ENDIF
            CASE SUB[2] OF
              'STATS': BEGIN & APROD='PPD_0.1_10' & CB_TITLE='Primary Production!C' + UNITS('PRIMARY_PRODUCTION',/no_name) & PAL='PAL_DEFAULT'   & DCOLOR='WHITE' & END
              'ANOMS': BEGIN & APROD='RATIO'      & CB_TITLE='Primary Production!CAnomaly (ratio)' & PAL='PAL_ANOM_BGR' & DCOLOR=CLRS(4) & NCOLOR=CLRS(4) & END
            ENDCASE
          END ; CHL
      
          'CHL': BEGIN
            CASE SUB[2] OF
              'STATS': BEGIN & APROD='CHLOR_A_0.1_30' & CB_TITLE=UNITS('CHLOROPHYLL')          & PAL='PAL_DEFAULT'       & DCOLOR='WHITE' & END
              'ANOMS': BEGIN & APROD='RATIO'          & CB_TITLE='Chlorophyll Anomaly (ratio)' & PAL='PAL_BLUE_ORANGE' & DCOLOR=CLRS(4) & NCOLOR=CLRS(4) & END
            ENDCASE
            DATASET = ['OCCCI'];'SEAWIFS_MODISA'
            CASE DATASET OF 
              'OCCCI': BEGIN 
                F = GET_FILES('OCCCI',PROD='CHLOR_A-CCI',PERIODS=PER,FILE_TYPE=SUB[2],DATERANGE=DATERANGE,COUNT=COUNTF)
                IF COUNTF EQ 0 THEN GOTO, SKIP_PNGS
              END  
              'SEAWIFS_MODISA': BEGIN
                F = FLS(!S.OC + 'MODISA' + '/L3B2/'+SUB(2)+'/CHLOR_A-PAN/' + PER + '*',DATERANGE=[2002,2019],COUNT=COUNTF)
                IF COUNTF EQ 0 THEN GOTO, SKIP_PNGS
                IF PER EQ 'A_' OR PER EQ 'M3_' THEN BEGIN
                  F = DATE_SELECT(F,[2008,2019])
                  F = [FLS(!S.OC + 'SEAWIFS/L3B2/'+SUB(2)+'/CHLOR_A-PAN/' + PER + '*',DATERANGE=[1998,2007]),F]
                ENDIF
                
              END
            ENDCASE  
          END ; CHL
      
          'SST': BEGIN
            DATASET = 'AVHRR'
            F = FLS(!S.SST + DATASET + '/L3B4/'+REPLACE(SUB(2),'-','_')+'/SST/' + PER + '*',DATERANGE=[1981,2019],COUNT=COUNTF)
            IF COUNTF EQ 0 THEN GOTO, SKIP_PNGS
            CASE SUB(2) OF
              'STATS': BEGIN & APROD='SST_0_30' & CB_TITLE=UNITS('TEMP')                                & PAL='PAL_BLUE_RED' & DCOLOR='WHITE' & END
              'ANOMS': BEGIN & APROD='DIF_-5_5' & CB_TITLE='Temperature Anomaly '+UNITS('SST',/NO_NAME) & PAL='PAL_ANOM_BWR' & DCOLOR=CLRS(4) & NCOLOR=CLRS(4) & DELAY='75' & END
              'ANOMS-LTM': BEGIN & APROD='DIF_-5_5' & CB_TITLE='Temperature Anomaly '+UNITS('SST',/NO_NAME) & PAL='PAL_ANOM_BWR' & DCOLOR=CLRS(4) & NCOLOR=CLRS(4) & DELAY='75' & END
            ENDCASE
          END ; SST
        ENDCASE
        
        SKIP_PNGS:
        
        IF SUB[1] EQ 'SEASONAL' AND N_ELEMENTS(F) GT 0 THEN BEGIN
          D = DIR + SUB[1] + '_COMPOSITES' + SL +SUB[0] + '_' + DATASET + '_' + REPLACE(SUB(2),'-','_') + SL & DIR_TEST, D
          FP = PARSE_IT(F)
          WIN = F[WHERE(FP.MONTH_START EQ '01',/NULL,CWN)]
          YEARS = []
          FOR N=0, N_ELEMENTS(WIN)-1 DO BEGIN
            WN = WIN(N)
            WFP = PARSE_IT(WN)
            T = WFP[0].YEAR_START
            YEARS = [YEARS,T]
            SP = F[WHERE(FP.MONTH_START EQ '04' AND FP.YEAR_START EQ T,/NULL,CSP)]
            SU = F[WHERE(FP.MONTH_START EQ '07' AND FP.YEAR_START EQ T,/NULL,CSU)]
            FA = F[WHERE(FP.MONTH_START EQ '10' AND FP.YEAR_START EQ T,/NULL,CFA)]
      
            FF = [WN,SP,SU,FA]
            IF N_ELEMENTS(FF) NE 4 THEN CONTINUE
            PF = PARSE_IT(FF)
            IF SAME(PF.YEAR_START) EQ 0 THEN STOP
            PNG = D + SUBS(S) + '_'+ T + '.png'
            PNGS = [PNGS,PNG]
            IF FILE_MAKE(FF,PNG,OVERWRITE=OVERWRITE) EQ 0 THEN CONTINUE
      
            W = WINDOW(DIMENSIONS=[512,512],BUFFER=BUFFER)
            OPROD = APROD
            PRODS_2PNG,FF[0],SPROD=OPROD,MAPP=MAPOUT,OUTLINE=OUTLINE,OUT_COLOR=OCOLOR,/CURRENT,IMG_POS=[0,0.5,0.5,1.0],  PAL=PAL, CB_SIZE=6, CB_POS=[0.05,0.9,0.48,0.92], /ADD_CB, CB_TYPE=3, CB_TITLE=CB_TITLE
            PRODS_2PNG,FF[1],SPROD=OPROD,MAPP=MAPOUT,OUTLINE=OUTLINE,OUT_COLOR=OCOLOR,/CURRENT,IMG_POS=[0.5,0.5,1.0,1.0],PAL=PAL
            PRODS_2PNG,FF(2),SPROD=OPROD,MAPP=MAPOUT,OUTLINE=OUTLINE,OUT_COLOR=OCOLOR,/CURRENT,IMG_POS=[0,0,0.5,0.5],    PAL=PAL
            PRODS_2PNG,FF(3),SPROD=OPROD,MAPP=MAPOUT,OUTLINE=OUTLINE,OUT_COLOR=OCOLOR,/CURRENT,IMG_POS=[0.5,0,1.0,0.5],  PAL=PAL
      
            T  = TEXT(0.98,0.02, T,        FONT_SIZE=10, FONT_STYLE='BOLD', FONT_COLOR=DCOLOR, ALIGNMENT=1.0)
            S1 = TEXT(0.01,0.97, 'WINTER', FONT_SIZE=10, FONT_STYLE='BOLD', FONT_COLOR=DCOLOR, ALIGNMENT=0)
            S2 = TEXT(0.51,0.97, 'SPRING', FONT_SIZE=10, FONT_STYLE='BOLD', FONT_COLOR=DCOLOR, ALIGNMENT=0)
            S3 = TEXT(0.01,0.47, 'SUMMER', FONT_SIZE=10, FONT_STYLE='BOLD', FONT_COLOR=DCOLOR, ALIGNMENT=0)
            S4 = TEXT(0.51,0.47, 'FALL',   FONT_SIZE=10, FONT_STYLE='BOLD', FONT_COLOR=DCOLOR, ALIGNMENT=0)
      
          ;  TM = IMAGE(LG, RGB_TABLE=ARR,DIMENSIONS=[25,5025], POSITION=[5,30,30,55],/CURRENT,/DEVICE)
          ;  T1 = TEXT(6,  20, 'NOAA FISHERIES',                      FONT_COLOR=NCOLOR, FONT_SIZE=7,/DEVICE,FONT_STYLE='BOLD')
          ;  T3 = TEXT(6,  5, 'Northeast Fisheries !CScience Center', FONT_COLOR=NCOLOR, FONT_SIZE=5, /DEVICE,FONT_STYLE='BOLD')
            W.SAVE, PNG
            W.CLOSE
            PFILE, PNG
            GONE, FF
          ENDFOR ; WIN
          
          DIR_MOV = DIR_MOVIE + SUB[1] + SL & DIR_TEST, DIR_MOV
          MOVIE_FILE = SUB[1] + '_' + MIN(YEARS) + '_' + MAX(YEARS) + '-' + DATASET + '-' + SUB[0] + '-' + SUB(2) + '-COMPOSITES.mp4'
          IF FILE_MAKE(PNGS,DIR_MOV+MOVIE_FILE,OVERWRITE=OVERWRITE) EQ 0 THEN CONTINUE
          MAKE_FF_MOVIE,FILES=PNGS,DIR_OUT=DIR_MOV,PAL=PAL,KBPS=KBPS,FPS=1,MAP=MAPOUT,YOFFSET=YOFFSET,TITLE_SLIDE=0,END_SLIDE=0,MOVIE_FILE=MOVIE_FILE
          
        ENDIF ; SEASONAL
      ENDFOR ; SUBS
    ENDIF ; STATS_GIF    


; ********************************************
    IF KEY(PFT_COMPS) THEN BEGIN
; ********************************************

      SNAME = PFT_COMPS
      PRINT, 'Running: ' + 'STATS_GIF'
      SWITCHES,PFT_COMPS,STOPP=STOPP,OVERWRITE=OVERWRITE,VERBOSE=VERBOSE,INIT=INIT,R_FILES=R_FILES,R_DATASETS=R_DATASETS,R_MAPS=R_MAPS,DATASETS=DATASETS,DATERANGE=DATERANGE

      DIR = DIR_PLOTS

      CLRS = LIST([217,241,253],[193,232,251],[0,173,238],[0,83,159],[37,64,143],[255,255,255])
     ; LOGO = !S.PROJECTS + 'EDAB' + SL + 'IEA_WEBSITE' + SL + 'NOAA2.png'
      ;LG = READ_PNG(LOGO) & LG = LG(*,*,380:999)

     ; SUBAREA = 'NES_EPU_EXTENDED'
     ; SHPS = READ_SHPFILE(SUBAREA, MAPP='NEC', COLOR=COLORS, VERBOSE=VERBOSE)
      OUTLINE = [];SHPS.GB.OUTLINE,SHPS.MAB.OUTLINE,SHPS.GOM.OUTLINE]

      MAPOUT = 'NEC'
      PRODS   = ['PSC']
      PERIODS = ['MONTHLY','ANNUAL']
      TYPES   = ['STATS'];,'ANOMS']
      SUBS = []
      
      FOR P=0, N_ELEMENTS(PRODS)-1 DO FOR R=0, N_ELEMENTS(PERIODS)-1 DO FOR T=0, N_ELEMENTS(TYPES)-1 DO SUBS = [SUBS,STRJOIN([PRODS[P],PERIODS[R],TYPES[T]],'_')]

      FOR S=0, N_ELEMENTS(SUBS)-1 DO BEGIN
        BUFFER = 1
        OVERWRITE = 0
        PNGS = []
        OCOLOR = 0
        NCOLOR = CLRS(5)
        DELAY = '100'
        SUB = STR_SEP(SUBS(S),'_')

        ;     IF HAS(SUBS(S),'OCCCI')   THEN GOTO, OCCCI
        ;     IF HAS(SUBS(S),'MUR-')    THEN GOTO, MUR

        IF SUB[1] EQ 'MONTHLY' AND SUB(2) EQ 'ANOMS' THEN CONTINUE


        CASE SUB[1] OF
          'ANNUAL':   PER = 'A'
          'MONTHLY':  BEGIN & PER='MONTH' & DELAY = '75' & END
          'SEASONAL': PER='M3'
        ENDCASE

        CASE SUB[0] OF
          'PSC': BEGIN
            DATASET = 'OCCCI'
            GET_PRODS = ['MICRO','NANO','PICO']+'-BREWINSST_NES'
            F = GET_FILES(DATASET,PROD=GET_PRODS,PERIODS=PER,DATERANGE=[1997,2019],COUNT=COUNTF)
            IF COUNTF EQ 0 THEN GOTO, SKIP_PSC_PNGS
            CASE SUB[2] OF
              'STATS': BEGIN & APROD='CHLOR_A_0.01_10' & CB_TITLE= UNITS('CHLOROPHYLL') & PAL='PAL_DEFAULT'   & DCOLOR='WHITE' & END
              'ANOMS': BEGIN & APROD='RATIO'      & CB_TITLE='Chlorophyll !CAnomaly (ratio)' & PAL='PAL_ANOM_BLUE_ORANGE' & DCOLOR=CLRS(4) & NCOLOR=CLRS(4) & END
            ENDCASE
          END ; CHL
        ENDCASE

        SKIP_PSC_PNGS:

        IF SUB[1] EQ 'ANNUAL' THEN BEGIN
          D = DIR + SUB[1] + '_COMPOSITES' + SL +SUB[0] + '_' + DATASET + '_' + REPLACE(SUB(2),'-','_') + SL & DIR_TEST, D
          FP = PARSE_IT(F)
          YRS = YEAR_RANGE(MIN(FP.YEAR_START),MAX(FP.YEAR_START),/STRING)
          FOR YR=0, N_ELEMENTS(YRS)-1 DO BEGIN
            YFILES = F[WHERE(FP.YEAR_START EQ YRS[YR])]
            YFP = PARSE_IT(YFILES,/ALL)
            MF = YFILES[WHERE(YFP.PROD_ALG EQ GET_PRODS[0],/NULL)]
            NF = YFILES[WHERE(YFP.PROD_ALG EQ GET_PRODS[1],/NULL)]
            PF = YFILES[WHERE(YFP.PROD_ALG EQ GET_PRODS[2],/NULL)]
            PSC = [MF,NF,PF]
            IF N_ELEMENTS(PSC) NE 3 THEN CONTINUE
            
            PNG = D + SUBS[S] + '_' + YRS[YR] + '.png'
            PNGS = [PNGS,PNG]
            IF FILE_MAKE(PSC,PNG,OVERWRITE=OVERWRITE) EQ 0 THEN CONTINUE
           
            W = WINDOW(DIMENSIONS=[768,341],BUFFER=BUFFER)    
            OPROD = APROD
            CBAR, OPROD, OBJ=W, FONT_SIZE=12, CB_TYPE=3, CB_POS=[0.15,0.15,0.85,0.22], CB_TITLE=CB_TITLE, PAL=PAL
          
            PRODS_2PNG,PSC[0],SPROD=OPROD,MAPP=MAPOUT,OUTLINE=OUTLINE,OUT_COLOR=OCOLOR,/CURRENT,IMG_POS=[0,  85,256,341],/DEVICE,PAL=PAL
            PRODS_2PNG,PSC[1],SPROD=OPROD,MAPP=MAPOUT,OUTLINE=OUTLINE,OUT_COLOR=OCOLOR,/CURRENT,IMG_POS=[256,85,512,341],/DEVICE,PAL=PAL
            PRODS_2PNG,PSC(2),SPROD=OPROD,MAPP=MAPOUT,OUTLINE=OUTLINE,OUT_COLOR=OCOLOR,/CURRENT,IMG_POS=[512,85,768,341],/DEVICE,PAL=PAL
            
            TM = TEXT(0.01,0.95,'Microplankton',FONT_SIZE=12,FONT_STYLE='BOLD')
            TN = TEXT(0.34,0.95,'Nanoplankton',FONT_SIZE=12,FONT_STYLE='BOLD')
            TP = TEXT(0.68,0.95,'Picoplankton',FONT_SIZE=12,FONT_STYLE='BOLD')
            TY = TEXT(0.99,0.01,YRS[YR],FONT_SIZE=16,FONT_STYLE='BOLD',ALIGNMENT=1.0)
        
            W.SAVE, PNG
            W.CLOSE
            PFILE, PNG
            
          ENDFOR ; WIN

          DIR_MOV = DIR_MOVIE + SUB[1] + SL & DIR_TEST, DIR_MOV
          MOVIE_FILE = SUB[1] + '_' + MIN(YRS) + '_' + MAX(YEARS) + '-' + DATASET + '-' + SUB[0] + '-' + SUB(2) + '-COMPOSITES.mp4'
          IF FILE_MAKE(PNGS,DIR_MOV+MOVIE_FILE,OVERWRITE=YRS) EQ 0 THEN CONTINUE
          MAKE_FF_MOVIE,FILES=PNGS,DIR_OUT=DIR_MOV,PAL=PAL,KBPS=KBPS,FPS=1,MAP=MAPOUT,YOFFSET=YOFFSET,TITLE_SLIDE=0,END_SLIDE=0,MOVIE_FILE=MOVIE_FILE

        ENDIF ; ANNUAL  
        
        IF SUB[1] EQ 'MONTHLY' THEN BEGIN
          D = DIR + SUB[1] + '_COMPOSITES' + SL +SUB[0] + '_' + DATASET + '_' + REPLACE(SUB(2),'-','_') + SL & DIR_TEST, D
          FP = PARSE_IT(F)
          MONTHS = MONTH_NUMBERS()
          FOR MN=0, N_ELEMENTS(MONTHS)-1 DO BEGIN
            MFILES = F[WHERE(FP.MONTH_START EQ MONTHS[MN])]
            MFP = PARSE_IT(MFILES,/ALL)
            MF = MFILES[WHERE(MFP.PROD_ALG EQ GET_PRODS[0],/NULL)]
            NF = MFILES[WHERE(MFP.PROD_ALG EQ GET_PRODS[1],/NULL)]
            PF = MFILES[WHERE(MFP.PROD_ALG EQ GET_PRODS[2],/NULL)]
            PSC = [MF,NF,PF]
            IF N_ELEMENTS(PSC) NE 3 THEN CONTINUE

            PNG = D + SUBS[S] + '_' + MONTHS[MN] + '.png'
            PNGS = [PNGS,PNG]
            IF FILE_MAKE(PSC,PNG,OVERWRITE=OVERWRITE) EQ 0 THEN CONTINUE

            W = WINDOW(DIMENSIONS=[768,384],BUFFER=BUFFER)
            OPROD = APROD
            CBAR, OPROD, OBJ=W, FONT_SIZE=12, CB_TYPE=3, CB_POS=[0.15,0.15,0.85,0.22], CB_TITLE=CB_TITLE, PAL=PAL
            PRODS_2PNG,PSC[0],SPROD=OPROD,MAPP=MAPOUT,OUTLINE=OUTLINE,OUT_COLOR=OCOLOR,/CURRENT,IMG_POS=[0.00,0.33,0.33,1.0],PAL=PAL
            PRODS_2PNG,PSC[1],SPROD=OPROD,MAPP=MAPOUT,OUTLINE=OUTLINE,OUT_COLOR=OCOLOR,/CURRENT,IMG_POS=[0.33,0.33,0.67,1.0],PAL=PAL
            PRODS_2PNG,PSC(2),SPROD=OPROD,MAPP=MAPOUT,OUTLINE=OUTLINE,OUT_COLOR=OCOLOR,/CURRENT,IMG_POS=[0.67,0.33,1.00,1.0],PAL=PAL

            TM = TEXT(0.01,0.95,'Microplankton',FONT_SIZE=12,FONT_STYLE='BOLD')
            TN = TEXT(0.34,0.95,'Nanoplankton',FONT_SIZE=12,FONT_STYLE='BOLD')
            TP = TEXT(0.68,0.95,'Picoplankton',FONT_SIZE=12,FONT_STYLE='BOLD')
            TY = TEXT(0.99,0.01,MONTH_NAMES(MONTHS[MN]),FONT_SIZE=16,FONT_STYLE='BOLD',ALIGNMENT=1.0)

            W.SAVE, PNG
            W.CLOSE
            PFILE, PNG
            
          ENDFOR ; WIN

          DIR_MOV = DIR_MOVIE + SUB[1] + SL & DIR_TEST, DIR_MOV
          MOVIE_FILE = SUB[1] + '_' + 'MONTHLY' + '-' + DATASET + '-' + SUB[0] + '-' + SUB(2) + '-COMPOSITES.mp4'
          IF FILE_MAKE(PNGS,DIR_MOV+MOVIE_FILE,OVERWRITE=YRS) EQ 0 THEN CONTINUE
          MAKE_FF_MOVIE,FILES=PNGS,DIR_OUT=DIR_MOV,PAL=PAL,KBPS=KBPS,FPS=1,MAP=MAPOUT,YOFFSET=YOFFSET,TITLE_SLIDE=0,END_SLIDE=0,MOVIE_FILE=MOVIE_FILE

stop
        ENDIF ; MONTHLY
          
        
        IF SUB[1] EQ 'SEASONAL' AND N_ELEMENTS(F) GT 0 THEN BEGIN
          D = DIR + SUB[1] + '_COMPOSITES' + SL +SUB[0] + '_' + DATASET + '_' + REPLACE(SUB(2),'-','_') + SL & DIR_TEST, D
          FP = PARSE_IT(F)
          WIN = F[WHERE(FP.MONTH_START EQ '01',/NULL,CWN)]
          YEARS = []
          FOR N=0, N_ELEMENTS(WIN)-1 DO BEGIN
            WN = WIN(N)
            WFP = PARSE_IT(WN)
            T = WFP[0].YEAR_START
            YEARS = [YEARS,T]
            SP = F[WHERE(FP.MONTH_START EQ '04' AND FP.YEAR_START EQ T,/NULL,CSP)]
            SU = F[WHERE(FP.MONTH_START EQ '07' AND FP.YEAR_START EQ T,/NULL,CSU)]
            FA = F[WHERE(FP.MONTH_START EQ '10' AND FP.YEAR_START EQ T,/NULL,CFA)]

            FF = [WN,SP,SU,FA]
            IF N_ELEMENTS(FF) NE 4 THEN CONTINUE
            PF = PARSE_IT(FF)
            IF SAME(PF.YEAR_START) EQ 0 THEN STOP
            PNG = D + SUBS(S) + '_'+ T + '.png'
            PNGS = [PNGS,PNG]
            IF FILE_MAKE(FF,PNG,OVERWRITE=OVERWRITE) EQ 0 THEN CONTINUE

            W = WINDOW(DIMENSIONS=[512,512],BUFFER=BUFFER)
            OPROD = APROD
            PRODS_2PNG,FF[0],SPROD=OPROD,MAPP=MAPOUT,OUTLINE=OUTLINE,OUT_COLOR=OCOLOR,/CURRENT,IMG_POS=[0,0.5,0.5,1.0],  PAL=PAL, CB_SIZE=6, CB_POS=[0.05,0.9,0.48,0.92], /ADD_CB, CB_TYPE=3, CB_TITLE=CB_TITLE
            PRODS_2PNG,FF[1],SPROD=OPROD,MAPP=MAPOUT,OUTLINE=OUTLINE,OUT_COLOR=OCOLOR,/CURRENT,IMG_POS=[0.5,0.5,1.0,1.0],PAL=PAL
            PRODS_2PNG,FF(2),SPROD=OPROD,MAPP=MAPOUT,OUTLINE=OUTLINE,OUT_COLOR=OCOLOR,/CURRENT,IMG_POS=[0,0,0.5,0.5],    PAL=PAL
            PRODS_2PNG,FF(3),SPROD=OPROD,MAPP=MAPOUT,OUTLINE=OUTLINE,OUT_COLOR=OCOLOR,/CURRENT,IMG_POS=[0.5,0,1.0,0.5],  PAL=PAL

            T  = TEXT(0.98,0.02, T,        FONT_SIZE=10, FONT_STYLE='BOLD', FONT_COLOR=DCOLOR, ALIGNMENT=1.0)
            S1 = TEXT(0.01,0.97, 'WINTER', FONT_SIZE=10, FONT_STYLE='BOLD', FONT_COLOR=DCOLOR, ALIGNMENT=0)
            S2 = TEXT(0.51,0.97, 'SPRING', FONT_SIZE=10, FONT_STYLE='BOLD', FONT_COLOR=DCOLOR, ALIGNMENT=0)
            S3 = TEXT(0.01,0.47, 'SUMMER', FONT_SIZE=10, FONT_STYLE='BOLD', FONT_COLOR=DCOLOR, ALIGNMENT=0)
            S4 = TEXT(0.51,0.47, 'FALL',   FONT_SIZE=10, FONT_STYLE='BOLD', FONT_COLOR=DCOLOR, ALIGNMENT=0)

            ;  TM = IMAGE(LG, RGB_TABLE=ARR,DIMENSIONS=[25,5025], POSITION=[5,30,30,55],/CURRENT,/DEVICE)
            ;  T1 = TEXT(6,  20, 'NOAA FISHERIES',                      FONT_COLOR=NCOLOR, FONT_SIZE=7,/DEVICE,FONT_STYLE='BOLD')
            ;  T3 = TEXT(6,  5, 'Northeast Fisheries !CScience Center', FONT_COLOR=NCOLOR, FONT_SIZE=5, /DEVICE,FONT_STYLE='BOLD')
            W.SAVE, PNG
            W.CLOSE
            PFILE, PNG
            GONE, FF
          ENDFOR ; WIN

          DIR_MOV = DIR_MOVIE + SUB[1] + SL & DIR_TEST, DIR_MOV
          MOVIE_FILE = SUB[1] + '_' + MIN(YEARS) + '_' + MAX(YEARS) + '-' + DATASET + '-' + SUB[0] + '-' + SUB(2) + '-COMPOSITES.mp4'
          IF FILE_MAKE(PNGS,DIR_MOV+MOVIE_FILE,OVERWRITE=OVERWRITE) EQ 0 THEN CONTINUE
          MAKE_FF_MOVIE,FILES=PNGS,DIR_OUT=DIR_MOV,PAL=PAL,KBPS=KBPS,FPS=1,MAP=MAPOUT,YOFFSET=YOFFSET,TITLE_SLIDE=0,END_SLIDE=0,MOVIE_FILE=MOVIE_FILE

        ENDIF ; SEASONAL
      ENDFOR ; SUBS
    ENDIF ; PFT_COMP


; ********************************************
    IF KEY(ANOMALY_MAP) THEN BEGIN
; ********************************************
      
      SWITCHES,ANOMALY_MAP,STOPP=STOPP,OVERWRITE=OVERWRITE,VERBOSE=VERBOSE,INIT=INIT,R_FILES=R_FILES,R_DATASETS=R_DATASETS,R_MAPS=R_MAPS,DATERANGE=DATERANGE
      
      BUFFER = 0      
      YR = MAX(DATE_2YEAR(DATE_RANGE))
      
      APA = FLS(!S.PP + 'SA/L3B2/ANOMS/PPD-VGPM2/A_' + YR + '*SA_MODISA*')   & GPA = !S.GLOBAL_PRODS + 'MODISA-PPD-VGPM2-GLOBAL.SAV'
      ACA = FLS(!S.OC  + 'SA/L3B2/ANOMS/CHLOR_A-PAN/A_' + YR + '*SA_MODISA*') & GCA = !S.GLOBAL_PRODS + 'MODISA-CHLOR_A-PAN-GLOBAL.SAV'
      APS = FLS(!S.PP + 'MODISA/L3B2/STATS/PPD-VGPM2/A_' + YR + '*')         & GPS = !S.GLOBAL_PRODS + 'MODISA-PPD-VGPM2-GLOBAL.SAV'
      ACS = FLS(!S.OC  + 'MODISA/L3B2/STATS/CHLOR_A-PAN/A_' + YR + '*')       & GCS = !S.GLOBAL_PRODS + 'MODISA-CHLOR_A-PAN-GLOBAL.SAV'

      DIR_CDF = DIR_PRO + 'DATA' + SL + 'NETCDF' + SL + 'CHL_PP' + SL & DIR_TEST,DIR_CDF
      WRITE_NC, ACS, OUTPROD='CHLOR_A', DIR_OUT=DIR_CDF, LONLAT=1, MAP_OUT='NES', GLOBAL_FILE=GCS, TAGS_STAT=['MEAN'], OVERWRITE=OVERWRITE, /VERBOSE
      WRITE_NC, APS, OUTPROD='PPD',     DIR_OUT=DIR_CDF, LONLAT=1, MAP_OUT='NES', GLOBAL_FILE=GPS, TAGS_STAT=['MEAN'], OVERWRITE=OVERWRITE, /VERBOSE
      WRITE_NC, ACA, OUTPROD='CHLOR_A', DIR_OUT=DIR_CDF, LONLAT=1, MAP_OUT='NES', GLOBAL_FILE=GCA, TAGS_STAT=['ANOMALY'], OVERWRITE=OVERWRITE, /VERBOSE
      WRITE_NC, APA, OUTPROD='PPD',     DIR_OUT=DIR_CDF, LONLAT=1, MAP_OUT='NES', GLOBAL_FILE=GPA, TAGS_STAT=['ANOMALY'],OVERWRITE=OVERWRITE, /VERBOSE
      
      LF = [0,.5,0,.5]
      RT = [.5,1,.5,1]
      TP = [1,1,.5,.5]
      BT = [.5,.5,0,0]
      CL = LF[0] + 0.035
      CR = LF[0] + 0.49
      CT = TP[0] - 0.05
      CB = TP[0] - 0.02
      CB_TYPE = 3

      CSPROD = 'CHLOR_A_0.1_30' & CSTITLE = UNITS('CHLOROPHYLL')        & CSPAL = 'PAL_BR'
      CAPROD = 'RATIO'          & CATITLE = 'CHL Anomaly (ratio)'       & CAPAL = 'PAL_ANOM_GREY'
      PSPROD = 'PPD_0.1_10'     & PSTITLE = UNITS('PRIMARY_PRODUCTION') & PSPAL = 'PAL_BR'
      PAPROD = 'RATIO'          & PATITLE = 'PP Anomaly (ratio)'        & PAPAL = 'PAL_ANOM_GREY'

      MAPS = ['NEC','MAB','GOMN']
      FOR M=0, N_ELEMENTS(MAPS)-1 DO BEGIN
        OMAP = MAPS(M)
        
        STRUCT = READ_SHPFILE(SUBAREA, MAPP=OMAP, COLOR=COLOR, VERBOSE=VERBOSE, NORMAL=NORMAL, AROUND=AROUND)
        SHPS=STRUCT.(0)
        EOUTLINE = []
        CASE OMAP OF
          'NEC':  NAMES = ['GOM','GB','MAB']
          'MAB':  NAMES = ['MAB']
          'GOMN': NAMES = ['GOM','GB']
        ENDCASE
        FOR F=0, N_ELEMENTS(NAMES)-1 DO BEGIN
          POS = WHERE(TAG_NAMES(SHPS) EQ STRUPCASE(NAMES(F)),/NULL)
          EOUTLINE = [EOUTLINE,SHPS.(POS).OUTLINE]
        ENDFOR
       
        PNGFILE = DIR_PNGS + YR + '_CHL_PP_COMPOSITE-' + OMAP + '.PNG'
        IF FILE_MAKE([ACS,ACA,APS,APA],PNGFILE,OVERWRITE=OVERWRITE) EQ 1 THEN BEGIN
          W = WINDOW(DIMENSIONS=[1024,1024],BUFFER=BUFFER)
          IF ACS NE [] THEN PRODS_2PNG,ACS,MAPP=OMAP,PROD=CSPROD,OUTLINE=EOUTLINE,OUT_COLOR=0,OUT_THICK=4,CB_TITLE=CSTITLE,TXT_TAGS=TXT_TAGS,VERBOSE=VERBOSE,/CURRENT,IMG_POS=[LF[0],BT[0],RT[0],TP[0]],CB_POS=[CL,CT,CR,CB],CB_TYPE=CB_TYPE,CB_RELATIVE=CB_RELATIVE,PAL=CSPAL,/ADD_CB
          IF ACA NE [] THEN PRODS_2PNG,ACA,MAPP=OMAP,PROD=CAPROD,OUTLINE=EOUTLINE,OUT_COLOR=0,OUT_THICK=4,CB_TITLE=CATITLE,TXT_TAGS=TXT_TAGS,VERBOSE=VERBOSE,/CURRENT,IMG_POS=[LF[1],BT[1],RT[1],TP[1]],CB_POS=[CL,CT,CR,CB],CB_TYPE=CB_TYPE,CB_RELATIVE=CB_RELATIVE,PAL=CAPAL,/ADD_CB
          IF APS NE [] THEN PRODS_2PNG,APS,MAPP=OMAP,PROD=PSPROD,OUTLINE=EOUTLINE,OUT_COLOR=0,OUT_THICK=4,CB_TITLE=PSTITLE,TXT_TAGS=TXT_TAGS,VERBOSE=VERBOSE,/CURRENT,IMG_POS=[LF(2),BT(2),RT(2),TP(2)],CB_POS=[CL,CT,CR,CB],CB_TYPE=CB_TYPE,CB_RELATIVE=CB_RELATIVE,PAL=PSPAL,/ADD_CB
          IF APA NE [] THEN PRODS_2PNG,APA,MAPP=OMAP,PROD=PAPROD,OUTLINE=EOUTLINE,OUT_COLOR=0,OUT_THICK=4,CB_TITLE=PATITLE,TXT_TAGS=TXT_TAGS,VERBOSE=VERBOSE,/CURRENT,IMG_POS=[LF(3),BT(3),RT(3),TP(3)],CB_POS=[CL,CT,CR,CB],CB_TYPE=CB_TYPE,CB_RELATIVE=CB_RELATIVE,PAL=PAPAL,/ADD_CB
          W.SAVE, PNGFILE
          W.CLOSE
        ENDIF
        
        PRODS_2PNG,ACS,MAPP=OMAP,PROD=CSPROD,DIR_OUT=DIR_PNGS,OUTLINE=EOUTLINE,OUT_COLOR=0,OUT_THICK=4,CB_TITLE=CSTITLE,TXT_TAGS=TXT_TAGS,VERBOSE=VERBOSE,CB_TYPE=CB_TYPE,CB_RELATIVE=CB_RELATIVE,PAL=CSPAL,CB_POS=[CL,CT,CR,CB],/ADD_CB
        PRODS_2PNG,ACA,MAPP=OMAP,PROD=CAPROD,DIR_OUT=DIR_PNGS,OUTLINE=EOUTLINE,OUT_COLOR=0,OUT_THICK=4,CB_TITLE=CATITLE,TXT_TAGS=TXT_TAGS,VERBOSE=VERBOSE,CB_TYPE=CB_TYPE,CB_RELATIVE=CB_RELATIVE,PAL=CAPAL,CB_POS=[CL,CT,CR,CB],/ADD_CB
        PRODS_2PNG,APS,MAPP=OMAP,PROD=PSPROD,DIR_OUT=DIR_PNGS,OUTLINE=EOUTLINE,OUT_COLOR=0,OUT_THICK=4,CB_TITLE=PSTITLE,TXT_TAGS=TXT_TAGS,VERBOSE=VERBOSE,CB_TYPE=CB_TYPE,CB_RELATIVE=CB_RELATIVE,PAL=PSPAL,CB_POS=[CL,CT,CR,CB],/ADD_CB
        PRODS_2PNG,APA,MAPP=OMAP,PROD=PAPROD,DIR_OUT=DIR_PNGS,OUTLINE=EOUTLINE,OUT_COLOR=0,OUT_THICK=4,CB_TITLE=PATITLE,TXT_TAGS=TXT_TAGS,VERBOSE=VERBOSE,CB_TYPE=CB_TYPE,CB_RELATIVE=CB_RELATIVE,PAL=PAPAL,CB_POS=[CL,CT,CR,CB],/ADD_CB
      
      
        ; *** SEASONS ***
        SEAS = ['WIN','SPR','SUM','FAL']
        NAME = ['Winter','Spring','Summer','Fall']
        SEASONS = [YR+'01_',YR+'04_',YR+'07_',YR+'10_']
        FOR S=0, N_ELEMENTS(SEASONS)-1 DO BEGIN
          SEASON = SEASONS(S)
          CS = FLS(!S.OC  + 'MODISA/L3B2/STATS/CHLOR_A-PAN/M3_' + SEASON + '*')       & IF CS EQ [] THEN CS = '' & GCS = !S.GLOBAL_PRODS + 'MODISA-CHLOR_A-PAN-GLOBAL.SAV'
          CA = FLS(!S.OC  + 'SA/L3B2/ANOMS/CHLOR_A-PAN/M3_' + SEASON + '*SA_MODISA*') & IF CA EQ [] THEN CA = '' & GCA = !S.GLOBAL_PRODS + 'MODISA-CHLOR_A-PAN-GLOBAL.SAV'
          PS = FLS(!S.PP + 'MODISA/L3B2/STATS/PPD-VGPM2/M3_' + SEASON + '*')         & IF PS EQ [] THEN PS = '' & GPS = !S.GLOBAL_PRODS + 'MODISA-PPD-VGPM2-GLOBAL.SAV'
          PA = FLS(!S.PP + 'SA/L3B2/ANOMS/PPD-VGPM2/M3_' + SEASON + '*SA_MODISA*')   & IF PA EQ [] THEN PA = '' & GPA = !S.GLOBAL_PRODS + 'MODISA-PPD-VGPM2-GLOBAL.SAV'
          
          IF CS NE '' THEN WRITE_NC, CS, OUTPROD='CHLOR_A', DIR_OUT=DIR_CDF, LONLAT=1, MAP_OUT='NES', GLOBAL_FILE=GCS, TAGS_STAT=['MEAN'],   OVERWRITE=OVERWRITE, /VERBOSE
          IF CA NE '' THEN WRITE_NC, CA, OUTPROD='CHLOR_A', DIR_OUT=DIR_CDF, LONLAT=1, MAP_OUT='NES', GLOBAL_FILE=GCA, TAGS_STAT=['ANOMALY'],OVERWRITE=OVERWRITE, /VERBOSE
          IF PS NE '' THEN WRITE_NC, PS, OUTPROD='PPD',     DIR_OUT=DIR_CDF, LONLAT=1, MAP_OUT='NES', GLOBAL_FILE=GPS, TAGS_STAT=['MEAN'],   OVERWRITE=OVERWRITE, /VERBOSE
          IF PA NE '' THEN WRITE_NC, PA, OUTPROD='PPD',     DIR_OUT=DIR_CDF, LONLAT=1, MAP_OUT='NES', GLOBAL_FILE=GPA, TAGS_STAT=['ANOMALY'],OVERWRITE=OVERWRITE, /VERBOSE

          CASE SEAS(S) OF
            'WIN': WIN = [CS,CA,PS,PA]
            'SPR': SPR = [CS,CA,PS,PA]
            'SUM': SUM = [CS,CA,PS,PA]
            'FAL': FAL = [CS,CA,PS,PA]
          ENDCASE

          PNGFILE = DIR_PNGS + YR + '_' + SEAS(S) + '-CHL_PP_COMPOSITE-' + OMAP + '.PNG'
          IF FILE_MAKE([CS,CA,PS,PA],PNGFILE,OVERWRITE=OVERWRITE) EQ 1 THEN BEGIN
            W = WINDOW(DIMENSIONS=[1024,1024],BUFFER=BUFFER)
            IF CS NE '' THEN PRODS_2PNG,CS,MAPP=OMAP,PROD=CSPROD,OUTLINE=EOUTLINE,OUT_COLOR=0,OUT_THICK=4,CB_TITLE=CSTITLE,TXT_TAGS=TXT_TAGS,VERBOSE=VERBOSE,/CURRENT,IMG_POS=[LF[0],BT[0],RT[0],TP[0]],CB_POS=[CL,CT,CR,CB],CB_TYPE=CB_TYPE,CB_RELATIVE=CB_RELATIVE,PAL=CSPAL,/ADD_CB
            IF CA NE '' THEN PRODS_2PNG,CA,MAPP=OMAP,PROD=CAPROD,OUTLINE=EOUTLINE,OUT_COLOR=0,OUT_THICK=4,CB_TITLE=CATITLE,TXT_TAGS=TXT_TAGS,VERBOSE=VERBOSE,/CURRENT,IMG_POS=[LF[1],BT[1],RT[1],TP[1]],CB_POS=[CL,CT,CR,CB],CB_TYPE=CB_TYPE,CB_RELATIVE=CB_RELATIVE,PAL=CAPAL,/ADD_CB
            IF PS NE '' THEN PRODS_2PNG,PS,MAPP=OMAP,PROD=PSPROD,OUTLINE=EOUTLINE,OUT_COLOR=0,OUT_THICK=4,CB_TITLE=PSTITLE,TXT_TAGS=TXT_TAGS,VERBOSE=VERBOSE,/CURRENT,IMG_POS=[LF(2),BT(2),RT(2),TP(2)],CB_POS=[CL,CT,CR,CB],CB_TYPE=CB_TYPE,CB_RELATIVE=CB_RELATIVE,PAL=PSPAL,/ADD_CB
            IF PA NE '' THEN PRODS_2PNG,PA,MAPP=OMAP,PROD=PAPROD,OUTLINE=EOUTLINE,OUT_COLOR=0,OUT_THICK=4,CB_TITLE=PATITLE,TXT_TAGS=TXT_TAGS,VERBOSE=VERBOSE,/CURRENT,IMG_POS=[LF(3),BT(3),RT(3),TP(3)],CB_POS=[CL,CT,CR,CB],CB_TYPE=CB_TYPE,CB_RELATIVE=CB_RELATIVE,PAL=PAPAL,/ADD_CB
            TXT = TEXT(0.5,0.97,NAME(S),ALIGNMENT=0.5,FONT_STYLE='BOLD',FONT_SIZE=18)
            W.SAVE, PNGFILE
            W.CLOSE
          ENDIF
        ENDFOR ; SEASONS
        
        
        PRODS = ['CHL_STATS','CHL_ANOM','PP_STATS','PP_ANOM']
        FOR P=0, N_ELEMENTS(PRODS)-1 DO BEGIN
          CASE PRODS(P) OF 
            'CHL_STATS': BEGIN & PROD=CSPROD & TITLE=CSTITLE & PAL=CSPAL & END
            'CHL_ANOM' : BEGIN & PROD=CAPROD & TITLE=CATITLE & PAL=CAPAL & END
            'PP_STATS' : BEGIN & PROD=PSPROD & TITLE=PSTITLE & PAL=PSPAL & END
            'PP_ANOM'  : BEGIN & PROD=PAPROD & TITLE=PATITLE & PAL=PAPAL & END
          ENDCASE
          
          PNGFILE = DIR_PNGS + YR + '_SEASONAL-'+ PRODS(P) + '-' + OMAP + '.PNG'
          FILES = [WIN(P),SPR(P),SUM(P),FAL(P)]
          IF FILE_MAKE(FILES,PNGFILE,OVERWRITE=OVERWRITE) EQ 1 THEN BEGIN
            W = WINDOW(DIMENSIONS=[1024,1024],BUFFER=BUFFER)
            LI, FILES
            IF FILES[0] NE '' THEN PRODS_2PNG,FILES[0],MAPP=OMAP,PROD=PROD,OUTLINE=EOUTLINE,OUT_COLOR=0,OUT_THICK=4,CB_TITLE=NAME[0]+' ' +TITLE,TXT_TAGS=TXT_TAGS,VERBOSE=VERBOSE,/CURRENT,IMG_POS=[LF[0],BT[0],RT[0],TP[0]],CB_POS=[CL,CT,CR,CB],CB_TYPE=CB_TYPE,CB_RELATIVE=CB_RELATIVE,PAL=PAL,/ADD_CB
            IF FILES[1] NE '' THEN PRODS_2PNG,FILES[1],MAPP=OMAP,PROD=PROD,OUTLINE=EOUTLINE,OUT_COLOR=0,OUT_THICK=4,CB_TITLE=NAME[1]+' ' +TITLE,TXT_TAGS=TXT_TAGS,VERBOSE=VERBOSE,/CURRENT,IMG_POS=[LF[1],BT[1],RT[1],TP[1]],CB_POS=[CL,CT,CR,CB],CB_TYPE=CB_TYPE,CB_RELATIVE=CB_RELATIVE,PAL=PAL,/ADD_CB
            IF FILES(2) NE '' THEN PRODS_2PNG,FILES(2),MAPP=OMAP,PROD=PROD,OUTLINE=EOUTLINE,OUT_COLOR=0,OUT_THICK=4,CB_TITLE=NAME(2)+' ' +TITLE,TXT_TAGS=TXT_TAGS,VERBOSE=VERBOSE,/CURRENT,IMG_POS=[LF(2),BT(2),RT(2),TP(2)],CB_POS=[CL,CT,CR,CB],CB_TYPE=CB_TYPE,CB_RELATIVE=CB_RELATIVE,PAL=PAL,/ADD_CB
            IF FILES(3) NE '' THEN PRODS_2PNG,FILES(3),MAPP=OMAP,PROD=PROD,OUTLINE=EOUTLINE,OUT_COLOR=0,OUT_THICK=4,CB_TITLE=NAME(3)+' ' +TITLE,TXT_TAGS=TXT_TAGS,VERBOSE=VERBOSE,/CURRENT,IMG_POS=[LF(3),BT(3),RT(3),TP(3)],CB_POS=[CL,CT,CR,CB],CB_TYPE=CB_TYPE,CB_RELATIVE=CB_RELATIVE,PAL=PAL,/ADD_CB
            IF ANY(FILES) THEN W.SAVE, PNGFILE
            W.CLOSE
          ENDIF
        ENDFOR ; SEASONAL PRODS  
      ENDFOR ; MAPS
    ENDIF ; ANOMALY_MAP
    
    
    
; ********************************************
    IF KEY(MOVIES) THEN BEGIN
; ********************************************

      SWITCHES,MOVIES,STOPP=STOPP,OVERWRITE=OVERWRITE,VERBOSE=VERBOSE,INIT=INIT,R_FILES=R_FILES,R_DATASETS=R_DATASETS,R_MAPS=R_MAPS,DATERANGE=DATERANGE,DPRODS=D_PRODS
  
      BUFFER = 1
      REV = 1
      IF NONE(DATASETS) THEN DATASETS = ['SEAWIFS','VIIRS','JPSS1','MODISA']
      IF NONE(D_PRODS) THEN PRODS = ['PPD-VGPM2','CHLOR_A-OCI','CHLOR_A-PAN','PAR','PPD-VGPM2'] ELSE PRODS = D_PRODS
      DIRS = ['NC','INTERP_SAVE','SAVE']
      
      IF KEY(REV) THEN BEGIN
        DATASETS = REVERSE(DATASETS)
        PRODS = REVERSE(PRODS)
        DIRS = REVERSE(DIRS)
      ENDIF
      
      MAPIN = 'L3B2'
      MAPOUT = 'NEC'
      DIM = 200
      BLK = MAPS_BLANK(MAPOUT)
      LAND = READ_LANDMASK(MAPOUT,/STRUCT)
      BLK(LAND.OCEAN) = 252
      BLK(LAND.LAND) = 251
      BLK(LAND.COAST) = 0
      
      PAL = 'PAL_DEFAULT'
      RGB_TABLE = RGBS([0,255],PAL=PAL)  
      
      FOR N=0, N_ELEMENTS(DATASETS)-1 DO BEGIN
        DATASET = DATASETS(N)
        PREFIX = ''
        CASE DATASET OF
          'SEAWIFS': BEGIN & DR=['1998','2009'] & PREFIX='S' & STITLE='SeaWiFS'                 & END
          'MODISA':  BEGIN & DR=['2002','2019'] & PREFIX='A' & STITLE='MODIS-Aqua'              & END
          'VIIRS':   BEGIN & DR=['2012','2019'] & PREFIX='V' & STITLE='VIIRS'                   & END
          'JPSS1':   BEGIN & DR=['2018','2019'] & PREFIX='V' & STITLE='JPSS1'                   & END
          'SA':      BEGIN & DR=['1998','2019'] & STITLE='SeaWiFS + MODIS-Aqua'                 & END
          'SAV':     BEGIN & DR=['1998','2019'] & STITLE='SeaWiFS + MODIS-Aqua + VIIRS'         & END
          'SAVJ':    BEGIN & DR=['1998','2019'] & STITLE='SeaWiFS + MODIS-Aqua + VIIRS + JPSS1' & END
        ENDCASE
        
        YRS = YEAR_RANGE(DR[0],DR[1],/STRING) & NYRS = N_ELEMENTS(YRS)
        CASE NYRS OF
          2:  BEGIN & NROW = 1 & NCOL = 2 & END
          8:  BEGIN & NROW = 2 & NCOL = 4 & END
          12: BEGIN & NROW = 2 & NCOL = 6 & END  
          18: BEGIN & NROW = 3 & NCOL = 6 & END
          22: BEGIN & NROW = 4 & NCOL = 6 & END
        ENDCASE
        
        DIM  = 200
        SP   = 5
        CSP  = 15
        TOP  = 15
        BOT  = 80
        XDIM = DIM*NCOL + SP*(NCOL+2)
        YDIM = DIM*NROW + SP*(NROW+3) + TOP + BOT
        XPOS = [] & FOR A=0, NROW-1 DO XPOS = [XPOS,SP+INDGEN(NCOL)*(DIM+SP)]
        YP = BOT+REVERSE(SP+INDGEN(NROW)*(DIM+SP)) & YPOS=[] & FOR A=0, NROW-1 DO YPOS = [YPOS,REPLICATE(YP(A),NCOL)]    
        CPOS = [XDIM/2+CSP, BOT/2+CSP, XDIM-CSP, MIN(YPOS)-CSP]
        CPOS = FLOAT(CPOS)/FLOAT([XDIM,YDIM,XDIM,YDIM]) ; Convert the DEVICE units into NORMAL units
        DPOS = [CSP,CSP,XDIM/2-CSP,MIN(YPOS)-CSP]
        
        FOR I=0, N_ELEMENTS(PRODS)-1 DO BEGIN
          PROD = PRODS(I)
          APROD = VALIDS('PRODS',PROD)
          AALG  = VALIDS('ALGS',PROD)
          CASE APROD OF
            'CHLOR_A': BEGIN & DIN = !S.OC & SCL = 'CHLOR_A_0.1_30' & NDIR = 'CHL' & TITLE=UNITS('CHLOROPHYLL') & END
            'PPD': BEGIN & DIN = !S.PP & SCL = 'PPD_0.1_10' & NDIR = '' & TITLE='Primary Productivity ' + UNITS('PPD',/NO_NAME) & END
            'PAR': BEGIN & DIN = !S.OC & SCL = 'PAR' & NDIR = 'PAR' & TITLE='Photosynthetic Available Radiation ' + UNITS('PAR',/NO_NAME) & END
          ENDCASE
          
          FOR R=0, N_ELEMENTS(DIRS)-1 DO BEGIN
            DIR = DIRS(R)
            CASE DIR OF
              'NC':          BEGIN & PER = PREFIX & EXT = 'nc'  & DPROD=NDIR & TTITLE=' (Daily)' & END
              'SAVE':        BEGIN & PER = 'D'    & EXT = 'SAV' & DPROD=PROD & TTITLE=' (Daily)' & END
              'INTERP_SAVE': BEGIN & PER = 'D'    & EXT = 'SAV' & DPROD=PROD & TTITLE=' (Interpolated)' & END
            ENDCASE
                   
            FLS = FLS(DIN + DATASET + SL + MAPIN + SL + DIR + SL + DPROD + SL + PER + '*' + EXT, DATERANGE=DR, COUNT=CT)
            IF CT EQ 0 THEN CONTINUE
            DIRDAT = DIR_MOVIE + DATASET + SL
            DIROUT = DIRDAT + DATASET + '-' + MAPOUT + '-' + PROD + '-' + DIR + SL & DIR_TEST, DIROUT + 'BROWSE' + SL
            
            FP = PARSE_IT(FLS)
            DP = DATE_PARSE(PERIOD_2DATE(FP.PERIOD))
            DOYS = (DATE_PARSE(CREATE_DATE('19990101','19991231'))).IDOY         
            PNGS = []
            FOR S=0, N_ELEMENTS(DOYS)-1 DO BEGIN
              DOY = DOYS(S)
              FF = FLS[WHERE(DP.IDOY EQ DOY,CNT,/NULL)]
              IF CNT EQ 0 THEN CONTINUE
              PNG = DIROUT + 'BROWSE' + SL + 'DOY_' + DOY + '-' + DATASET + '-' + MAPOUT + '-' + PROD + '-' + DIR + '.PNG'
              PNGS = [PNGS,PNG]
              IF FILE_MAKE(FF,PNG,OVERWRITE=OVERWRITE) EQ 0 THEN CONTINUE
              
              W = IMAGE(REPLICATE(255B,DIM,DIM),DIMENSIONS=[XDIM,YDIM],BUFFER=BUFFER)
              STXT = TEXT(XDIM-SP,YDIM-TOP+SP, STITLE + TTITLE, FONT_STYLE='BOLD',FONT_SIZE=16,ALIGNMENT=1.0,VERTICAL_ALIGNMENT=1,/DEVICE)
              TTXT = TEXT(SP,YDIM-TOP+SP,'Day of Year ' + DOY,FONT_STYLE='BOLD',FONT_SIZE=16,ALIGNMENT=0.0,VERTICAL_ALIGNMENT=1,/DEVICE)
              CBAR, SCL, IMG=W, CB_POS=CPOS, CB_TITLE=TITLE, CB_TYPE=3, PAL=PAL
              DB = DATE_BAR(YDOY_2DATE('1999',DOY),BKG='WHITE',DB_FONT_SIZE=14,DB_COLOR='RED',DB_THICK=4,FRAME_COLOR='BLACK',NO_YEAR=1,/DEVICE,DB_POS=DPOS)

              FOR Y=0, N_ELEMENTS(YRS)-1 DO BEGIN
                F = FLS[WHERE(DP.IDOY EQ DOY AND DP.YEAR EQ YRS(Y),COUNT,/NULL)]
                POS = [XPOS(Y),YPOS(Y),XPOS(Y)+DIM,YPOS(Y)+DIM]
               
                IF COUNT EQ 0 THEN IM = IMAGE(BLK, RGB_TABLE=RGB_TABLE, POSITION=POS,MARGIN=0,/DEVICE, /CURRENT) ELSE $
                  PRODS_2PNG, F, MAPP=MAPOUT, PROD=SCL, IMG_POS=POS,/DEVICE, /CURRENT
                TXT = TEXT(POS[0]+SP, POS(3)-(SP*4), YRS(Y), FONT_STYLE='BOLD', FONT_SIZE=12, /DEVICE)
              ENDFOR ; YRS               
              PFILE, PNG
              W.SAVE, PNG
              W.CLOSE         
            ENDFOR ; DOYS
            
            MOVIE_FILE = 'A_' + YRS[0] + '_' + YRS(-1) + '-' + DATASET + '-' + MAPOUT + '-' + PROD + '-' + DIR + '.MP4'
            IF FILE_MAKE(PNGS,DIRDAT+MOVIE_FILE,OVERWRITE=OVERWRITE) EQ 0 THEN CONTINUE
            MAKE_FF_MOVIE,FILES=PNGS,DIR_OUT=DIROUT,PAL=PAL,KBPS=KBPS,FPS=10,MAP=MAPOUT,YOFFSET=YOFFSET,TITLE_SLIDE=0,END_SLIDE=0,MOVIE_FILE=MOVIE_FILE
            
          ENDFOR ; DIRS  
        ENDFOR ; PRODS
      ENDFOR ; DATASETS  
      
  
  STOP
      ENDIF

; ********************************************
    IF KEY(SOE_2018) THEN BEGIN
; ********************************************
      SNAME = 'SOE_2018'
      PRINT, 'Running: ' + SNAME
      SWITCHES,SOE_2018,STOPP=STOPP,OVERWRITE=OVERWRITE,VERBOSE=VERBOSE,INIT=INIT,R_FILES=R_FILES,R_DATASETS=R_DATASETS,R_MAPS=R_MAPS,DATERANGE=DATERANGE
  
  
      VERSION = 'V2018_2'
      DIR_PRO = DIR_PROJECTS + VERSION + SL
      DIR_DATA   = DIR_PRO + 'DATA_EXTRACTS' + SL & DIR_TEST, DIR_DATA
      DIR_COMP   = DIR_PRO + 'COMPOSITES'    + SL & DIR_TEST, DIR_COMP
      DIR_PNGS   = DIR_PRO + 'PNGS'          + SL & DIR_TEST, DIR_PNGS
  
      ANOMALY_MAP         = '';Y_2017'
      TIMESERIES_PLOTS    = ''
      DATA_EXTRACTS       = ''
      PERCENT_PRODUCTION  = ''
      SST_FILES_FOR_VINCE = ''
  
  
      OMAP = 'NEC'
      SUBAREA = 'NES_EPU_NOESTUARIES'
      NAMES = ['MAB','GOM','SS','GB']
      SUBTITLES = ['Northeast Shelf LME','Scotian Shelf','Gulf of Maine','Georges Bank','Mid-Atlantic Bight']
      STRUCT = READ_SHPFILE(SUBAREA, MAPP=OMAP, COLOR=COLOR, VERBOSE=VERBOSE, NORMAL=NORMAL, AROUND=AROUND)
      SHPS=STRUCT.(0)
      EPU_OUTLINE = []
      FOR F=0, N_ELEMENTS(NAMES)-1 DO BEGIN
        POS = WHERE(TAG_NAMES(SHPS) EQ STRUPCASE(NAMES(F)),/NULL)
        EPU_OUTLINE = [EPU_OUTLINE,SHPS.(POS).OUTLINE]
      ENDFOR
     
  
      
  
      
  
      
  
      IF KEY(PERCENT_PRODUCTION) THEN BEGIN
        AMAP = 'L3B2'
        OMAP = 'NEC'
        APROD = 'PPD-VGPM2'
  
        SATS = (['MODISA','SEAWIFS'])
        BUFFER = 1
        VERBOSE = 1
        DS = '-'
        SKIP_PAR = 1
  
        IF KEY(SKIP_PAR) THEN GOTO, SKIP
        FOR S=0, N_ELEMENTS(SATS)-1 DO BEGIN
          CPROD = 'PAR'
          DR = [20030101,20030131]
          NFILES = FLS(!S.OC + SATS(S) + SL + AMAP + SL + 'NC' + SL + CPROD + SL + '*' + CPROD + '*nc',DATERANGE=DR)           & NP = PARSE_IT(NFILES)
          DFILES = FLS(!S.OC + SATS(S) + SL + AMAP + SL + 'INTERP_SAVE' + SL + CPROD + SL + '*' + CPROD + '*SAV',DATERANGE=DR) & DP = PARSE_IT(DFILES)
          FFILES = FLS(!S.OC + SATS(S) + SL + AMAP + SL + 'FILLED_SAVE' + SL + CPROD + SL + '*' + CPROD + '*SAV',DATERANGE=DR) & FP = PARSE_IT(FFILES)
  
          PDIR = !S.OC + SATS(S) + SL + OMAP + SL + 'PNGS' + SL + CPROD + SL & DIR_TEST, PDIR
          FOR N=0, N_ELEMENTS(NFILES)-1 DO BEGIN
            DR = DFILES[WHERE(DP.PERIOD EQ NP(N).PERIOD,/NULL,COUNTD)] & D3 = PARSE_IT(DR,/ALL)
            FR = FFILES[WHERE(FP.PERIOD EQ NP(N).PERIOD,/NULL,COUNTF)] & FF = PARSE_IT(DR,/ALL)
            PR = NFILES(N)
  
            PNGFILE = PDIR + REPLACE(D3.NAME,D3.MAP,OMAP) + '-COMPARE.PNG'
            IF FILE_MAKE([DR,PR,FR],PNGFILE) EQ 0 THEN CONTINUE
  
            W = WINDOW(DIMENSIONS=[768,256],BUFFER=BUFFER)
            IF PR NE [] THEN PRODS_2PNG,PR,MAPP='NEC',PROD=CPROD,TXT_TAGS=['PERIOD','MATH'],VERBOSE=VERBOSE,/CURRENT,/ADD_NAME,IMG_POS=[0,0,0.333,1]
            IF DR NE [] THEN PRODS_2PNG,DR,MAPP='NEC',PROD=CPROD,TXT_TAGS=['PERIOD','MATH'],VERBOSE=VERBOSE,/CURRENT,/ADD_NAME,IMG_POS=[.333,0,0.666,1]
            IF FR NE [] THEN PRODS_2PNG,FR,MAPP='NEC',PROD=CPROD,TXT_TAGS=['PERIOD','MATH'],VERBOSE=VERBOSE,/CURRENT,/ADD_NAME,IMG_POS=[.666,0,1,1]
            W.SAVE, PNGFILE
            W.CLOSE
            PFILE, PNGFILE
          ENDFOR
        ENDFOR
        SKIP:
  
  
  
        FOR S=0, N_ELEMENTS(SATS)-1 DO BEGIN
          INTERP_CHL = 1
          INTERP_PAR = 0
          PERIOD = 'D'
          TXT_TAGS = 'DATE_CREATED'
          CHL_ALG='OCI'
          PPD_ALG='VGPM2'
          SAT = SATS(S)
          CASE SAT OF
            'MODISA':  PREFIX='A'
            'SEAWIFS': PREFIX='S'
          ENDCASE
          FOR P=0, N_ELEMENTS(CHL_ALG)-1 DO BEGIN
            PSAT = REPLACE(SAT,'_PAN','')
            CHL_PROD = []
            CASE CHL_ALG(P) OF
              'OCI': BEGIN & SPROD = 'CHLOR_A-OCI' & NPROD = 'CHL' & CHL_PROD = 'chlor_a' & END
              'OCX': BEGIN & SPROD = 'CHLOR_A-OCX' & NPROD = 'CHL' & CHL_PROD = 'chl_ocx' & END
              'PAN': BEGIN & SPROD = 'CHLOR_A-PAN' & NPROD = 'CHL_PAN' & END
            ENDCASE
  
            DIR_NC     = !S.OC  + SAT + SL + AMAP + SL + 'NC' + SL
            DIR_SAV    = !S.OC  + SAT + SL + AMAP + SL + 'SAVE' + SL
            DIR_INTERP = !S.OC  + SAT + SL + AMAP + SL + 'INTERP_SAVE' + SL
            DIR_PP     = !S.PP + SAT + SL + AMAP + SL + 'SAVE' + SL + APROD + SL
            DIR_OUT    = !S.PP + SAT + SL + OMAP + SL + 'INPUT_DATA_COMPOSITES' + SL + APROD + SL & DIR_TEST, DIR_OUT
            DIR        = DIR_NC ; DEFAULTS
  
            VFILES = FLS(DIR_PP + 'D_*.SAV',DATERANGE=DATERANGE,COUNT=VNUM)
  
            IF VNUM EQ 0 THEN STOP
  
            FOR FTH=0L, N_ELEMENTS(VFILES)-1 DO BEGIN
              VFILE  = VFILES(FTH)
              FP_PPD = PARSE_IT(VFILE,/ALL)
              INFILES = STRUCT_READ(VFILE,TAG='INFILE')
  
              FP_IN = PARSE_IT(INFILES,/ALL)
              CFILE = INFILES[WHERE(FP_IN.PROD EQ 'CHLOR_A')]
              RFILE = INFILES[WHERE(FP_IN.PROD EQ 'PAR')]
              SFILE = INFILES[WHERE(FP_IN.PROD EQ 'SST')]
  
              IF MIN(FILE_TEST(INFILES)) EQ 0 THEN STOP
  
              PNGFILE = DIR_OUT+REPLACE(FP_PPD.NAME,FP_PPD.MAP,OMAP)+'-INFILES.PNG'
              IF FILE_MAKE([VFILE,CFILE,RFILE,SFILE],PNGFILE,OVERWRITE=OVERWRITE) EQ 0 THEN CONTINUE
  
              W = WINDOW(DIMENSIONS=[800,800],BUFFER=BUFFER)
              PRODS_2PNG,VFILE,MAPP='NEC',PROD='PPD',    TXT_TAGS=TXT_TAGS,/ADD_NAME,VERBOSE=VERBOSE,/CURRENT,IMG_POS=[0,0.5,0.5,1]
              PRODS_2PNG,CFILE,MAPP='NEC',PROD='CHLOR_A',TXT_TAGS=TXT_TAGS,/ADD_NAME,VERBOSE=VERBOSE,/CURRENT,IMG_POS=[0.5,0.5,1,1]
              PRODS_2PNG,SFILE,MAPP='NEC',PROD='SST',    TXT_TAGS=TXT_TAGS,/ADD_NAME,VERBOSE=VERBOSE,/CURRENT,IMG_POS=[0,0,0.5,0.5]
              PRODS_2PNG,RFILE,MAPP='NEC',PROD='PAR',    TXT_TAGS=TXT_TAGS,/ADD_NAME,VERBOSE=VERBOSE,/CURRENT,IMG_POS=[0.5,0,1,0.5]
              W.SAVE, PNGFILE
              W.CLOSE
              PFILE, PNGFILE
            ENDFOR
          ENDFOR
  
          continue
          CPROD = 'PPD-VGPM2'
          CH = FLS(!S.PP + SATS(S) + SL + AMAP + SL + 'SAVE' + SL + CPROD + SL + 'D*SAV',DATERANGE=['20020101','20020714'])
          PDIR = !S.PP + SATS(S) + SL + 'NEC' + SL + 'PNGS' + SL + CPROD + SL & DIR_TEST, PDIR
          ;  FOR N=0, N_ELEMENTS(CH)-1 DO PRODS_2PNG,CH(N),MAPP='NEC',PROD='PPD',DATA_TAG=DATA_TAG,LOG=LOG,DIR_OUT=PDIR,/OVERWRITE,BUFFER=BUFFER,TXT_TAGS='PERIOD',VERBOSE=VERBOSE;
  
          CPROD = 'CHLOR_A-OCI'
          CH = FLS(!S.OC + SATS(S) + SL + AMAP + SL + 'INTERP_SAVE' + SL + CPROD + SL + 'D_2009010*SAV')
          PDIR = !S.OC + SATS(S) + SL + 'NEC' + SL + 'INTERP_PNGS' + SL + CPROD + SL & DIR_TEST, PDIR
          FOR N=0, N_ELEMENTS(CH)-1 DO PRODS_2PNG,CH(N),MAPP='NEC',PROD='CHLOR_A',DATA_TAG=DATA_TAG,LOG=LOG,DIR_OUT=PDIR,/OVERWRITE,BUFFER=BUFFER,TXT_TAGS='PERIOD',VERBOSE=VERBOSE;
  
  
          CPROD = 'CHLOR_A'
          CH = FLS(!S.OC + SATS(S) + SL + AMAP + SL + 'NC' + SL + 'CHL' + SL + 'A*CHL*nc',DATERANGE=[20090101,20091231])
          PDIR = !S.OC + SATS(S) + SL + 'NEC' + SL + 'PNGS' + SL + CPROD + SL & DIR_TEST, PDIR
  
          FOR N=0, N_ELEMENTS(CH)-1 DO BEGIN
            PR = REPLACE(CH(N),'CHL','PAR')
            IF EXISTS(PR) EQ 0 THEN CONTINUE
            W = WINDOW(DIMENSIONS=[1024,512],BUFFER=BUFFER)
            PRODS_2PNG,CH(N),MAPP='NEC',PROD=CPROD,DATA_TAG=DATA_TAG,LOG=LOG,TXT_TAGS='PERIOD',VERBOSE=VERBOSE,/CURRENT,IMG_POS=[0,0,0.5,1]
            PRODS_2PNG,PR   ,MAPP='NEC',PROD='PAR',DATA_TAG=DATA_TAG,LOG=LOG,TXT_TAGS='PERIOD',VERBOSE=VERBOSE,/CURRENT,IMG_POS=[.5,0,1,1]
            W.SAVE, PDIR + (FILE_PARSE(PR)).NAME + '.PNG'
            W.CLOSE
          ENDFOR
  
          CH = FLS(!S.OC + SATS(S) + SL + AMAP + SL + 'STATS' + SL + CPROD + SL + ['M_','A_'] + '*SAV')
          PDIR = !S.OC + SATS(S) + SL + 'NEC' + SL + 'STATS_PNGS' + SL + CPROD + SL & DIR_TEST, PDIR
          FOR N=0, N_ELEMENTS(CH)-1 DO PRODS_2PNG,CH(N),MAPP='NEC',PROD=CPROD,DATA_TAG=DATA_TAG,LOG=LOG,DIR_OUT=PDIR,/OVERWRITE,BUFFER=BUFFER,TXT_TAGS='PERIOD',VERBOSE=VERBOSE;
  
          CH = FLS(!S.OC + SATS(S) + SL + AMAP + SL + 'INTERP_SAVES' + SL + CPROD + SL + 'D_*SAV')
          PDIR = !S.OC + SATS(S) + SL + 'NEC' + SL + 'INTERP_PNGS' + SL + CPROD + SL & DIR_TEST, PDIR
          FOR N=0, N_ELEMENTS(CH)-1 DO PRODS_2PNG,CH(N),MAPP='NEC',PROD=CPROD,DATA_TAG=DATA_TAG,LOG=LOG,DIR_OUT=PDIR,/OVERWRITE,BUFFER=BUFFER,TXT_TAGS='PERIOD',VERBOSE=VERBOSE;
  
  
          CPROD = 'PAR'
          CH = FLS(!S.OC + SATS(S) + SL + AMAP + SL + 'NC' + SL + 'A*PAR*nc',DATERANGE=[20160101,20171231])
          PDIR = !S.OC + SATS(S) + SL + 'NEC' + SL + 'PNGS' + SL + CPROD + SL & DIR_TEST, PDIR
          FOR N=0, N_ELEMENTS(CH)-1 DO PRODS_2PNG,CH(N),MAPP='NEC',PROD='PAR',DATA_TAG=DATA_TAG,LOG=LOG,DIR_OUT=PDIR,/OVERWRITE,BUFFER=BUFFER,TXT_TAGS='PERIOD',VERBOSE=VERBOSE;
  
          CPROD = 'PAR'
          CH = FLS(!S.OC + SATS(S) + SL + AMAP + SL + 'STATS' + SL + CPROD + SL + ['M_','A_'] + '*SAV')
          PDIR = !S.OC + SATS(S) + SL + 'NEC' + SL + 'STATS_PNGS' + SL + CPROD + SL & DIR_TEST, PDIR
          FOR N=0, N_ELEMENTS(CH)-1 DO PRODS_2PNG,CH(N),MAPP='NEC',PROD='PAR',DATA_TAG=DATA_TAG,LOG=LOG,DIR_OUT=PDIR,/OVERWRITE,BUFFER=BUFFER,TXT_TAGS='PERIOD',VERBOSE=VERBOSE;
  
  
          stop
          PP = FLS(!S.PP + SATS(S) + SL + AMAP + SL + 'STATS' + SL + APROD + SL + ['M_','A_'] + '*SAV')
          PDIR = !S.PP + SATS(S) + SL + 'NEC' + SL + 'STATS_PNGS' + SL + APROD + SL & DIR_TEST, PDIR
  
          FOR N=0, N_ELEMENTS(PP)-1 DO PRODS_2PNG,PP(N),MAPP='NEC',PROD='PPD',DATA_TAG=DATA_TAG,LOG=LOG,DIR_OUT=PDIR,MARGIN=0,BUFFER=BUFFER,/ADD_NAME,TXT_TAGS=['PERIOD','SENSOR'],VERBOSE=VERBOSE;
  
          SPP = FLS(!S.PP + SATS(S) + SL + AMAP + SL + 'ANOMS' + SL + APROD + SL + 'M*A_*')
          PDIR = !S.PP + SATS(S) + SL + 'NEC' + SL + 'ANOM_PNGS' + SL + APROD + SL & DIR_TEST, PDIR
          FOR N=0, N_ELEMENTS(SPP)-1 DO PRODS_2PNG,SPP(N),MAPP='NEC',PROD='RATIO',DATA_TAG=DATA_TAG,LOG=LOG,DIR_OUT=PDIR,MARGIN=0,CB_TITLE='Anomaly Ratio',TXT_TAGS='PERIOD',BUFFER=BUFFER,VERBOSE=VERBOSE;===> MAIN INPUTS
  
  
          OUTLINE = []
          FOR F=0, N_ELEMENTS(NAMES)-1 DO BEGIN
            POS = WHERE(TAG_NAMES(SHPS) EQ STRUPCASE(NAMES(F)),/NULL)
            POS2 = WHERE(TAG_NAMES(SHPS.(POS)) EQ STRUPCASE(NAMES(F))+'_OUTLINE',/NULL)
            OUTLINE = [OUTLINE,SHPS.(POS).(POS2)]
          ENDFOR
          stop
          SUBAREAS_EXTRACT, SPP, SHP_FILES=SUBAREAFILES,INIT=INIT,VERBOSE=VERBOSE ; SAVEFILE=ECOS_SAV,
          stop
          ;  IF FILE_MAKE(ECOS_SAV,ECOS_CSV) EQ 1 THEN SAVE_2CSV,ECOS_SAV
  
  
          ; W = WINDOW(DIMENSIONS=[1024,1024])
          ;     PRODS_2PNG,PP[1],MAPP='NEC',PROD='PPD',BUFFER=0,/CURRENT,IMG_POS=[0,0,.5,.5],/VERBOSE,DIR_OUT=PDIR,DATA_TAG=DATA_TAG,LOG=LOG,/ADD_AUTH,/ADD_NAME,TXT_TAGS=['PERIOD','SENSOR'];,/RETURN_IMAGE,OBJ=OBJ,VERBOSE=VERBOSE
  
  
  
        ENDFOR
      ENDIF ; PERCENT PRODUCTION
  
  
      stop
  
      IF KEY(SST_FILES_FOR_VINCE) THEN BEGIN
        BUFFER = 1
        PERIOD = 'M'
        STAT = 'MEAN'
        MP = 'NES'
        L = READ_LANDMASK(MP,/STRUCT)
  
        ASST = FLS(!S.DATASETS + 'SST-AVHRR-4KM' + SL + MP + SL + 'STATS' + SL + 'SST' + SL + PERIOD + '_*.SAV',DATERANGE=['1982','2002'])
        MSST = FLS(!S.DATASETS + 'SST-MUR-1KM'   + SL + MP + SL + 'STATS' + SL + 'SST' + SL + PERIOD + '_*.SAV',DATERANGE=['2002','2017'])
  
        DIR_OUT = DIR_PRO + 'DATA' + SL
        DIR_CDF = DIR_OUT + 'NETCDF' + SL
        DIR_PNG = DIR_OUT + 'PNG' + SL
        DIR_TEST, [DIR_CDF,DIR_PNG]
  
        WRITE_NC, ASST,  OUTPROD='SST', DIR_OUT=DIR_CDF+'AVHRR'+SL, LONLAT=1, MAP_OUT='NES', OVERWRITE=OVERWRITE, /VERBOSE
        WRITE_NC, MSST,  OUTPROD='SST', DIR_OUT=DIR_CDF+'MUR'+SL,   LONLAT=1, MAP_OUT='NES', OVERWRITE=OVERWRITE, /VERBOSE
  
        NFILES = FILE_SEARCH(DIR_CDF + ['AVHRR','MUR'] + SL + '*.NC',COUNT=COUNT)
        nfiles = reverse(nfiles)
        FOR I=0, COUNT-1 DO BEGIN
          FPROD = VALIDS('PRODS','SST')
          PNGFILE = REPLACE(NFILES(I),[DIR_CDF,'.NC'],[DIR_PNG,'.PNG'])
          FP = FILE_PARSE(PNGFILE) & DIR_TEST, FP.DIR
          IF FILE_MAKE(NFILES(I),PNGFILE,OVERWRITE=OVERWRITE) EQ 0 THEN CONTINUE
          D = READ_NC(NFILES(I))
          T = D.SD.TIME
          TAG = WHERE_STRING(TAG_NAMES(D.SD),FPROD+'_'+STAT[0])
          B = PRODS_2BYTE(D.SD.(TAG).IMAGE,PROD='SST')
          IF IDLTYPE(L) NE 'STRING' THEN BEGIN
            B(L.LAND) = 253
            B(L.COAST) = 0
          ENDIF
          W = WINDOW(DIMENSIONS=[684,784],BUFFER=BUFFER)
          IM = IMAGE(B,RGB_TABLE=CPAL_READ('PAL_BR'),MARGIN=0,POSITION=[0,100,684,784],BUFFER=BUFFER,/CURRENT,/DEVICE)
          PRODS_COLORBAR, FPROD, IMG=IM, LOG=1, ORIENTATION=0, TITLE=TITLE, FONT_SIZE=12, POSITION=[50,55,634,95], TEXTPOS=0, /DEVICE, PAL='PAL_BR'
          TXT = TEXT(10,720,'Monthly Mean!C'+DATE_FORMAT(T.YEAR_START+T.MONTH_START+T.DAY_START,/DAY) + ' to ' + DATE_FORMAT(T.YEAR_END+T.MONTH_END+T.DAY_END,/DAY),FONT_SIZE=16,FONT_STYLE='BOLD',/DEVICE)
          W.SAVE, PNGFILE
          W.CLOSE
          PFILE, PNGFILE,/W
        ENDFOR
      ENDIF
      STOP
    ENDIF ; SOE_2018

; ********************************************
    IF KEY(SOE_2017) THEN BEGIN
; ********************************************
      SNAME = 'SOE_2017'
      PRINT, 'Running: ' + SNAME
      SWITCHES,SOE_2017,STOPP=STOPP,OVERWRITE=OVERWRITE,VERBOSE=VERBOSE,INIT=INIT,DATASETS=DATASETS,R_FILES=R_FILES,R_DATASETS=R_DATASETS,R_MAPS=R_MAPS,DATERANGE=DATERANGE
  
      VERSION = 'V2017_1'
      FINAL_DATA    = 'Y'
      COMPARE_PLOTS = ''
  
      IF KEY(FINAL_DATA) THEN BEGIN
        BUFFER = 1
  
        DATERANGE = ['1998','2016']
        MAP_IN  = 'L3B2'
        MAP_OUT = 'NEC'
        CPROD = 'CHLOR_A'
        PPROD = 'PPD-VGPM2'
        CALGS = ['PAN','OCI']
        FILES = []
        SERVERS  = [!S.SEADAS,!S.MODIS,!S.DATASETS]
        DATASETS = ['SEAWIFS','MODISA','SA_MERGE']
  
        FOR A=0, N_ELEMENTS(CALGS)-1 DO BEGIN
          FOR D=0, N_ELEMENTS(DATASETS)-1 DO BEGIN
            IF CALGS(A) EQ 'PAN' THEN ALGADD = '_PAN' ELSE ALGADD = ''
            IF DATASETS(D) EQ 'SA_MERGE' THEN CONTINUE
            FILES = [FILES,FLS(SERVERS(D) +'OC-'+DATASETS(D)+'-1KM'+SL+MAP_IN+SL+'STATS'+SL+CPROD+'-'+CALGS(A)+SL+['A_*','M_*']+CPROD+'-'+CALGS(A)+'-STATS.SAV',DATERANGE=DATERANGE),FLS(SERVERS(D) +'OC-'+DATASETS(D)+'-1KM'+SL+MAP_IN+SL+'STATS'+SL+CPROD+SL+['ANNUAL*','MONTH*']+CPROD+'-STATS.SAV')]
            FILES = [FILES,FLS(SERVERS(D) +'OC-'+DATASETS(D)+'-1KM'+SL+MAP_IN+SL+'ANOMS'+SL+CPROD+'-'+CALGS(A)+SL+['A*ANNUAL*']+CPROD+'-'+CALGS(A)+'-RATIO.SAV',DATERANGE=DATERANGE)]
            FILES = [FILES,FLS(!S.PP  +'PP-'+DATASETS(D)+ALGADD+'-1KM'+SL+MAP_IN+SL+'STATS'+SL+PPROD+SL+['A_*','M_*']+PPROD+'-STATS.SAV',DATERANGE=DATERANGE),FLS(SERVERS(D) +'OC-'+DATASETS(D)+'-1KM'+SL+MAP_IN+SL+'STATS'+SL+PPROD+SL+['ANNUAL*','MONTH*']+PPROD+'-STATS.SAV')]
            FILES = [FILES,FLS(!S.PP  +'PP-'+DATASETS(D)+ALGADD+'-1KM'+SL+MAP_IN+SL+'ANOMS'+SL+PPROD+SL+['A*ANNUAL*']+PPROD+'-RATIO.SAV',DATERANGE=DATERANGE)]
          ENDFOR
          FILES = FILES[WHERE(FILES NE '')]
          ECOS_SAV = DIR_ESR_DATA + 'CHL_PP_DATA_NES_ECOREGIONS.SAV'
          ECOS = []
  
          SUBAREA = 'NES_ECOREGIONS'
          NAMES    = ['NES','SS','GOM','GB','MAB'] + '_full'
          SUBAREAFILES = FLS(!S.IDL_SHAPEFILES + 'NES_ECOREGIONS' + SL + [NAMES] + '.shp')
          SUBTITLES = ['Northeast Shelf LME','Scotian Shelf','Gulf of Maine','Georges Bank','Mid-Atlantic Bight']
          READ_SHPFILE, SUBAREAFILES, MAPP=MAP_OUT, COLOR=COLOR, FILL=1, THICK=THICK, VERBOSE=VERBOSE, GET_RANGE=GET_RANGE, TAGNAME=TAGNAME, VALUE=VALUE, RANGE_LON=RANGE_LON, RANGE_LAT=RANGE_LAT, $
            STRUCT=STRUCT, NORMAL=NORMAL, DO_ALL=DO_ALL, AUTO=AUTO, LONS=LONS, LATS=LATS, AROUND=AROUND, PSYM=PSYM, SYMSIZE=SYMSIZE, _EXTRA=_EXTRA, OVERWRITE=OVERWRITE
          SHPS=STRUCT
          OUTLINE = []
          FOR F=0, N_ELEMENTS(NAMES)-1 DO BEGIN
            POS = WHERE(TAG_NAMES(SHPS) EQ STRUPCASE(NAMES(F)),/NULL)
            POS2 = WHERE(TAG_NAMES(SHPS.(POS)) EQ STRUPCASE(NAMES(F))+'_OUTLINE',/NULL)
            OUTLINE = [OUTLINE,SHPS.(POS).(POS2)]
          ENDFOR
  
          SUBAREAS_EXTRACT, FILES, SHP_FILES=SUBAREAFILES,SAVEFILE=ECOS_SAV,INIT=INIT,VERBOSE=VERBOSE
          IF FILE_MAKE(ECOS_SAV,ECOS_CSV) EQ 1 THEN SAVE_2CSV,ECOS_SAV
  
          ECODATA = IDL_RESTORE(ECOS_SAV)
          RESOLUTION=300
          L = READ_LANDMASK(MAP_OUT,/STRUCT)
          MS = MAPS_SIZE(MAP_OUT,PX=MPX,PY=MPY)
          LCOLOR = 252
          CCOLOR = 0
  
          COLORS = ['DARK_GRAY','BLUE','CYAN','RED','SPRING_GREEN']
          YEARS = ['1998','2016']
          SAX = DATE_AXIS([19970101,20170101],/YEAR,/YY_YEAR)
          SAS = DATE_AXIS([19980101,20160101],/YEAR,/YY_YEAR,STEP=2)
          AAX = DATE_AXIS([20200101,20201231],/MONTH,/FYEAR,/MID)
          PAL = 'PAL_BR'
  
          CPRODA = 'CHLOR_A-'+CALGS(A) & CPROD = 'CHLOR_A_0.1_10.0' & CRANGE = [0.4,1.4]
          PPRODA = 'PPD-VGPM2'         & PPROD = 'PPD_0.2_4.0'      & PRANGE = [0.2,1.0]
          CTITLE = UNITS('CHLOROPHYLL',       /NO_UNIT)+', '+UNITS('CHLOR_A',/NO_NAME,/NO_PAREN) & CTITLE = REPLACE(CTITLE,['(',')'],['','']) ; CTITLE = UNITS('CHLOROPHYLL')
          PTITLE = UNITS('PRIMARY_PRODUCTION',/NO_UNIT)+', '+UNITS('PPD',    /NO_NAME,/NO_PAREN) & PTITLE = REPLACE(PTITLE,['(',')'],['','']) ; PTITLE = UNITS('PRIMARY_PRODUCTION')
  
          FOR N=0, N_ELEMENTS(DATASETS)-1 DO BEGIN
            DATASET = DATASETS(N)
            IF DATASET EQ 'SA_MERGE' THEN BEGIN
              CHLD = !S.DATASETS + 'OC-SA-1KM' + SL + MAP_IN + SL
              PPDD = !S.PP      + 'PP-SA-1KM' + SL + MAP_IN + SL
              SDATA = ECODATA[WHERE(ECODATA.SENSOR EQ 'SEAWIFS' OR ECODATA.SENSOR EQ 'SEAWIFS'+ALGADD,/NULL)] & STMP = DATE_SELECT(SDATA.PERIOD,['1998','2007'],SUBS=SUBS1)
              MDATA = ECODATA[WHERE(ECODATA.SENSOR EQ 'MODISA'  OR ECODATA.SENSOR EQ 'MODISA' +ALGADD,/NULL)] & MTMP = DATE_SELECT(MDATA.PERIOD,['2008','2016'],SUBS=SUBS2)
              ECOS = [SDATA(SUBS1),MDATA(SUBS2)]
            ENDIF ELSE BEGIN
              CHLD = SERVERS(N) + 'OC-'+DATASET+'-1KM' + SL + MAP_IN + SL
              PPDD = !S.PP     + 'PP-'+DATASET+ALGADD+'-1KM' + SL + MAP_IN + SL
              ECOS = ECODATA[WHERE(ECODATA.SENSOR EQ DATASET OR ECODATA.SENSOR EQ DATASET+ALGADD,/NULL)]
              IF DATASET EQ 'SA' THEN ECOS = ECODATA[WHERE(ECODATA.SENSOR EQ 'SA' OR ECODATA.SENSOR EQ 'SA_PAN',/NULL)]
            ENDELSE
  
            CSTAT =  FLS(CHLD[0] + 'STATS' + SL + CPRODA + SL + 'ANNUAL_*-STATS.SAV') & APERIOD = (PARSE_IT(CSTAT)).PERIOD
            PSTAT =  FLS(PPDD[0] + 'STATS' + SL + PPRODA + SL + 'ANNUAL_*-STATS.SAV')
            PNGFILE = DIR_ESR_PLOTS + APERIOD + '-' + DATASET + '-' + MAP_OUT+ '-CHL_PPD-STATS-COMPOSITE_WITH_LINE_PLOT-DPI_'+NUM2STR(RESOLUTION)+'.PNG'
            IF FILE_MAKE([CSTAT,PSTAT,ECOS_SAV],PNGFILE,OVERWRITE=OVERWRITE) EQ 0 THEN CONTINUE
  
            IF FILE_MAKE(CSTAT,REPLACE(CSTAT,MAP_IN,MAP_OUT)) EQ 1 THEN CHL = STRUCT_READ(CSTAT,MAP_OUT=MAP_OUT) $
            ELSE CHL = STRUCT_READ(REPLACE(CSTAT,MAP_IN,MAP_OUT))
            IF FILE_MAKE(PSTAT,REPLACE(PSTAT,MAP_IN,MAP_OUT)) EQ 1 THEN PPD = STRUCT_READ(PSTAT,MAP_OUT=MAP_OUT) $
            ELSE PPD = STRUCT_READ(REPLACE(PSTAT,MAP_IN,MAP_OUT))
  
            BCHL = PRODS_2BYTE(CHL,PROD=CPROD) & BCHL(L.LAND) = LCOLOR & BCHL(L.COAST) = CCOLOR & BCHL(OUTLINE) = CCOLOR
            BPPD = PRODS_2BYTE(PPD,PROD=PPROD) & BPPD(L.LAND) = LCOLOR & BPPD(L.COAST) = CCOLOR & BPPD(OUTLINE) = CCOLOR
  
            DIMS = [1024,1034]
            W = WINDOW(DIMENSIONS=DIMS,BUFFER=BUFFER)
            TXC = TEXT(512,995,STRJOIN(YEARS,'-'),/DEVICE,FONT_SIZE=20,ALIGNMENT=0.5)
  
            MAR  = 25
            CPOS = [    MAR,512+MAR,512 -MAR,1012-MAR] & CBPOS = [    MAR*2,512,512 -MAR*2,512+MAR]
            PPOS = [512+MAR,512+MAR,1024-MAR,1012-MAR] & PBPOS = [512+MAR*2,512,1024-MAR*2,512+MAR]
            IMC = IMAGE(BCHL,RGB_TABLE=CPAL_READ(PAL),MARGIN=0,POSITION=CPOS,/DEVICE,BUFFER=BUFFER,/CURRENT)
            IMP = IMAGE(BPPD,RGB_TABLE=CPAL_READ(PAL),MARGIN=0,POSITION=PPOS,/DEVICE,BUFFER=BUFFER,/CURRENT)
            PRODS_COLORBAR, CPROD, IMG=IMC, LOG=1, ORIENTATION=0, TITLE=CTITLE, FONT_SIZE=14, POSITION=CBPOS, TEXTPOS=0, /DEVICE, PAL=PAL
            PRODS_COLORBAR, PPROD, IMG=IMP, LOG=1, ORIENTATION=0, TITLE=PTITLE, FONT_SIZE=14, POSITION=PBPOS, TEXTPOS=0, /DEVICE, PAL=PAL
  
            LMAR = 50
            LDIF = 18
            LCPOS = [    LMAR*1.5,LMAR,512 -LMAR*0.5,512-LMAR*1.5]
            LPPOS = [512+LMAR*1.5,LMAR,1024-LMAR*0.5,512-LMAR*1.5]
            TXTC = LMAR*2
            TXTP = 512+LMAR*2
            TXTY = 512-LMAR*2
  
            CTITLE = UNITS('CHLA',/NO_UNIT) + ' ' + UNITS('CHLOR_A',/NO_NAME)
            PTITLE = 'Primary productivity ' + UNITS('PPD',/NO_NAME)
  
            CP = PLOT(SAX.JD,CRANGE,XRANGE=SAX.JD,XTICKNAME=SAS.TICKNAME,XTICKVALUES=SAS.TICKV,YRANGE=CRANGE,XMINOR=0,XTICKLEN=0.03,YTICKLEN=0.03,YMINOR=0,AXIS_STYLE=1,/CURRENT,/DEVICE,POSITION=LCPOS,/NODATA,YTITLE=CTITLE)
            IF DATASET EQ 'SA_MERGE' THEN BEGIN
              SALINE = PLOT(DATE_2JD([2007,2007]),CRANGE,XRANGE=SAX.JD,YRANGE=CRANGE,AXIS_STYLE=1,XMINOR=0,YMINOR=0,LINESTYLE=5,THICK=2,COLOR='GREY',/CURRENT,/DEVICE,POSITION=LCPOS,/OVERPLOT)
              SEATXT = TEXT(DATE_2JD(200606),CRANGE[0]*1.1,'SeaWiFS',   /DATA,ALIGNMENT=1,COLOR='GREY',FONT_SIZE=11,FONT_NAME='HELVITICA',TARGET=CP)
              MODTXT = TEXT(DATE_2JD(200706),CRANGE[0]*1.1,'MODIS-Aqua',/DATA,ALIGNMENT=0,COLOR='GREY',FONT_SIZE=11,FONT_NAME='HELVITICA',TARGET=CP)
            ENDIF
            PLOTPERIOD = 'A_'
            FOR C=0, N_ELEMENTS(NAMES)-1 DO BEGIN
              OK = WHERE(ECOS.SUBAREA EQ STRUPCASE(NAMES(C)) AND ECOS.PROD+'-'+ECOS.ALG EQ CPRODA AND ECOS.AMEAN NE MISSINGS(0.0) AND STRMID(ECOS.PERIOD,0,STRLEN(PLOTPERIOD)) EQ PLOTPERIOD AND ECOS.MATH EQ 'STATS',COUNT)
              IF COUNT LE 1 THEN STOP
              CDATA = ECOS[OK] & CDATA = CDATA[SORT(PERIOD_2JD(CDATA.PERIOD))]
              CMEAN = MEAN(FLOAT(CDATA.AMEAN),/NAN)
              LDATA = LOWESS(DATE_2YEAR(PERIOD_2DATE(CDATA.PERIOD)),FLOAT(CDATA.AMEAN),WIDTH=7)
              CP0 = PLOT(PERIOD_2JD(CDATA.PERIOD),FLOAT(CDATA.AMEAN),XRANGE=SAX.JD,YRANGE=CRANGE,AXIS_STYLE=1,XMINOR=0,YMINOR=0,LINESTYLE=6,COLOR=COLORS(C),SYMBOL='CIRCLE',SYM_SIZE=0.8,/SYM_FILLED,/CURRENT,/DEVICE,POSITION=LCPOS,/OVERPLOT)
              CPL = PLOT(PERIOD_2JD(CDATA.PERIOD),LDATA,             XRANGE=SAX.JD,YRANGE=CRANGE,AXIS_STYLE=1,XMINOR=0,YMINOR=0,LINESTYLE=0,COLOR=COLORS(C),                THICK=2,                 /CURRENT,/DEVICE,POSITION=LCPOS,/OVERPLOT)
              TXT = TEXT(TXTC, TXTY-(LDIF*C),REPLACE(NAMES(C),'_full','')+' = ' + NUM2STR(CMEAN,DECIMALS=2),COLOR=COLORS(C),FONT_SIZE=12,FONT_NAME='HELVITICA',FONT_STYLE='BOLD',/DEVICE)
            ENDFOR
            XAXIS = AXIS('X',LOCATION=MAX(CP.YRANGE),MAJOR=0,TARGET=CP,MINOR=0)
            YAXIS = AXIS('Y',LOCATION=MAX(SAX.JD),   MAJOR=0,TARGET=CP,MINOR=0)
  
            PP = PLOT(SAX.JD,PRANGE,XRANGE=SAX.JD,XTICKNAME=SAS.TICKNAME,XTICKVALUES=SAS.TICKV,YRANGE=PRANGE,XMINOR=0,XTICKLEN=0.03,YTICKLEN=0.03,YMINOR=0,AXIS_STYLE=1,/CURRENT,/DEVICE,POSITION=LPPOS,/NODATA,YTITLE=PTITLE)
            IF DATASET EQ 'SA_MERGE' THEN BEGIN
              SALINE = PLOT(DATE_2JD([2007,2007]),PRANGE,XRANGE=SAX.JD,YRANGE=CRANGE,AXIS_STYLE=1,XMINOR=0,YMINOR=0,LINESTYLE=5,THICK=2,COLOR='GREY',/CURRENT,/DEVICE,POSITION=LCPOS,/OVERPLOT)
              SEATXT = TEXT(DATE_2JD(200606),PRANGE[0]*1.1,'SeaWiFS',   /DATA,ALIGNMENT=1,COLOR='GREY',FONT_SIZE=11,FONT_NAME='HELVITICA',TARGET=PP)
              MODTXT = TEXT(DATE_2JD(200706),PRANGE[0]*1.1,'MODIS-Aqua',/DATA,ALIGNMENT=0,COLOR='GREY',FONT_SIZE=11,FONT_NAME='HELVITICA',TARGET=PP)
            ENDIF
            FOR C=0, N_ELEMENTS(NAMES)-1 DO BEGIN
              OK = WHERE(ECOS.SUBAREA EQ STRUPCASE(NAMES(C)) AND ECOS.PROD+'-'+ECOS.ALG EQ PPRODA AND ECOS.AMEAN NE MISSINGS(0.0) AND STRMID(ECOS.PERIOD,0,STRLEN(PLOTPERIOD)) EQ PLOTPERIOD AND ECOS.MATH EQ 'STATS',COUNT)
              IF COUNT LE 1 THEN STOP
              PDATA = ECOS[OK] & PDATA = PDATA[SORT(PERIOD_2JD(PDATA.PERIOD))]
              PMEAN = MEAN(FLOAT(PDATA.AMEAN),/NAN)
              LDATA = LOWESS(DATE_2YEAR(PERIOD_2DATE(PDATA.PERIOD)),FLOAT(PDATA.AMEAN),WIDTH=7)
              PP0 = PLOT(PERIOD_2JD(PDATA.PERIOD),FLOAT(PDATA.AMEAN),XRANGE=SAX.JD,YRANGE=PRANGE,AXIS_STYLE=1,XMINOR=0,YMINOR=0,LINESTYLE=6,COLOR=COLORS(C),SYMBOL='CIRCLE',SYM_SIZE=0.8,/SYM_FILLED,/CURRENT,/DEVICE,POSITION=LPPOS,/OVERPLOT)
              PPL = PLOT(PERIOD_2JD(PDATA.PERIOD),LDATA,             XRANGE=SAX.JD,YRANGE=PRANGE,AXIS_STYLE=1,XMINOR=0,YMINOR=0,LINESTYLE=0,COLOR=COLORS(C),                THICK=2,                 /CURRENT,/DEVICE,POSITION=LPPOS,/OVERPLOT)
              TXT = TEXT(TXTP, TXTY-(LDIF*C),REPLACE(NAMES(C),'_full','')+' = ' + NUM2STR(PMEAN,DECIMALS=2),COLOR=COLORS(C),FONT_SIZE=12,FONT_NAME='HELVITICA',FONT_STYLE='BOLD',/DEVICE)
            ENDFOR
            IF DATASET EQ 'SA_MERGE' THEN SALINE = PLOT(DATE_2JD([2007,2007]),CRANGE,/OVERPLOT,LINESTYLE=1,COLOR='LIGHT_GREY')
            XAXIS = AXIS('X',LOCATION=MAX(PP.YRANGE),MAJOR=0,TARGET=PP,MINOR=0)
            YAXIS = AXIS('Y',LOCATION=MAX(SAX.JD),   MAJOR=0,TARGET=PP,MINOR=0)
  
            PFILE, PNGFILE, /W
            W.SAVE,PNGFILE,RESOLUTION=RESOLUTION
            W.CLOSE
          ENDFOR
        ENDFOR ; ALGS LOOP
        stop
  
        CSCALE = '.1_10'
        PSCALE = '.2_4'
        CPROD = 'CHLOR_A'
        PPROD = 'PPD'
        CSTAT = 'MEAN'
        PSTAT = 'MEAN'
        AX = SAX
        AS = SAS
        CRANGE = [0.4,1.4]
        PRANGE = [0.2,1.2]
        PLOTPERIOD = 'A_'
  
        CANOMS =  FLS(CHLD[0] + 'ANOMS' + SL + CHLPROD + SL + 'A_*ANNUAL*-RATIO.SAV',DATERANGE=[YEARS[0],YEARS[1]]) & FC = PARSE_IT(CANOMS)
        PANOMS =  FLS(PPDD[0] + 'ANOMS' + SL + PPDPROD + SL + 'A_*ANNUAL*-RATIO.SAV',DATERANGE=[YEARS[0],YEARS[1]]) & FA = PARSE_IT(PANOMS)
  
        FOR N=0, N_ELEMENTS(CANOMS)-1 DO BEGIN
          CANOM = CANOMS(N)
          APERIOD = FC(N).PERIOD
          YEAR = DATE_2YEAR(PERIOD_2DATE(APERIOD))
          PAL    = 'PAL_ANOM_GREY'
          CTITLE = 'Chlorophyll ratio anomaly'
          PTITLE = 'Primary production ratio anomaly'
          TXT = STRMID(APERIOD,2,4)
          CPROD = 'RATIO'
          PPROD = 'RATIO'
          CSTAT = 'MEAN-RATIO'
          PSTAT = 'RATIO'
          AX = AAX
          AS = AAX
          CRANGE = [0.0,3.0]
          PRANGE = [0.0,1.5]
          PLOTPERIOD = 'M_' + STRMID(APERIOD,2,4)
  
          OK = WHERE(FA.PERIOD EQ APERIOD,COUNT)
          IF COUNT EQ 1 THEN PANOM = PANOMS[OK] ELSE PANOM = []
          PNGFILE = DIR_ESR_PLOTS + APERIOD + '-' + MAP_OUT+ '-CHL_PPD_COMPOSITE_WITH_LINE_PLOT'+FILEEXTRA+'-DPI_'+NUM2STR(RESOLUTION)+'.PNG'
          IF FILE_MAKE([CANOMS(N),PANOM],PNGFILE,OVERWRITE=OVERWRITE) EQ 0 THEN CONTINUE
  
          CHL = STRUCT_READ(CANOM,STRUCT=CSTRUCT,MAP_OUT=MAP_OUT)
          PPD = STRUCT_READ(PANOM,STRUCT=PSTRUCT,MAP_OUT=MAP_OUT)
  
          BCHL = PRODS_2BYTE(CHL,PROD=CPROD) & BCHL(L.LAND) = LCOLOR & BCHL(L.COAST) = CCOLOR
          BPPD = PRODS_2BYTE(PPD,PROD=PPROD) & BPPD(L.LAND) = LCOLOR & BPPD(L.COAST) = CCOLOR
  
          DIMS = [1024,1034]
          W = WINDOW(DIMENSIONS=DIMS,BUFFER=BUFFER)
          TXC = TEXT(512,995,TXT,/DEVICE,FONT_SIZE=20,ALIGNMENT=0.5)
  
          MAR  = 25
          CPOS = [    MAR,512+MAR,512 -MAR,1012-MAR] & CBPOS = [    MAR*2,512,512-MAR*4,1012-MAR*2]
          PPOS = [512+MAR,512+MAR,1024-MAR,1012-MAR] & PBPOS = [512+MAR*2,512,512-MAR*4,1012-MAR*2]
          IMC = IMAGE(BCHL,RGB_TABLE=CPAL_READ(PAL),MARGIN=0,IMG_POSITION=CPOS,BUFFER=BUFFER,/CURRENT)
          PRODS_COLORBAR, CCOLOR, IMG=IM, LOG=1, ORIENTATION=0, TITLE=CTITLE, FONT_SIZE=12, POSITION=CPOS, TEXTPOS=0, /DEVICE, PAL=PAL
          IMP = IMAGE(BPPD,RGB_TABLE=CPAL_READ(PAL),MARGIN=0,IMG_POSITION=PPOS,BUFFER=BUFFER,/CURRENT)
          PRODS_COLORBAR, PCOLOR, IMG=IM, LOG=1, ORIENTATION=0, TITLE=PTITLE, FONT_SIZE=12, POSITION=PPOS, TEXTPOS=0, /DEVICE, PAL=PAL
  
  
          MAR = 50
          DIF = 18
          CPOS = [    MAR*1.5,MAR,512 -MAR*0.5,512-MAR*1.5]
          PPOS = [512+MAR*1.5,MAR,1024-MAR*0.5,512-MAR*1.5]
          TXTC = MAR*2
          TXTP = 512+MAR*2
          TXTY = 512-MAR*2
  
          CTITLE = UNITS('CHLA',/NO_UNIT) + ' ' + UNITS('CHLOR_A',/NO_NAME)
          PTITLE = 'Primary productivity ' + UNITS('PPD',/NO_NAME)
  
          CP = PLOT(AX.JD,CRANGE,XRANGE=AX.JD,XTICKNAME=AS.TICKNAME,XTICKVALUES=AS.TICKV,YRANGE=CRANGE,XMINOR=0,XTICKLEN=0.03,YTICKLEN=0.03,YMINOR=0,AXIS_STYLE=1,/CURRENT,/DEVICE,POSITION=CPOS,/NODATA,YTITLE=CTITLE)
          FOR C=0, N_ELEMENTS(CODES)-1 DO BEGIN
            CPOSM = WHERE(TAG_NAMES(ECOS) EQ REPLACE(CHLPROD,'-','_')+'_MEAN')
            CPOSL = WHERE(TAG_NAMES(ECOS) EQ REPLACE(CHLPROD,'-','_')+'_LOWESS')
            OK = WHERE(ECOS.SUBAREA_CODE EQ CODES(C) AND ECOS.(CPOSM) NE MISSINGS(0.0) AND STRMID(ECOS.PERIOD,0,STRLEN(PLOTPERIOD)) EQ PLOTPERIOD)
            CDATA = ECOS[OK]
            CMEAN = MEAN(CDATA.(CPOSM),/NAN)
            CDATA = CDATA[SORT(PERIOD_2JD(CDATA.PERIOD))]
            IF APERIOD EQ 'MONTH' THEN CDATA = CDATA[SORT(DATE_2MONTH(PERIOD_2DATE(CDATA.PERIOD)))]
            IF APERIOD EQ 'ANNUAL' THEN BEGIN
              LDATA = LOWESS(DATE_2YEAR(PERIOD_2DATE(CDATA.PERIOD)),CDATA.(CPOSM),WIDTH=7)
              CP0 = PLOT(PERIOD_2JD(CDATA.PERIOD),CDATA.(CPOSM),XRANGE=AX.JD,YRANGE=CRANGE,AXIS_STYLE=1,XMINOR=0,YMINOR=0,LINESTYLE=6,COLOR=COLORS(C),SYMBOL='CIRCLE',SYM_SIZE=0.8,/SYM_FILLED,/CURRENT,/DEVICE,POSITION=CPOS,/OVERPLOT)
              ; CPL = PLOT(PERIOD_2JD(CDATA.PERIOD),LDATA,       XRANGE=AX.JD,YRANGE=CRANGE,AXIS_STYLE=1,XMINOR=0,YMINOR=0,LINESTYLE=0,COLOR=COLORS(C),                THICK=2,                 /CURRENT,/DEVICE,POSITION=CPOS,/OVERPLOT)
              CPL = PLOT(PERIOD_2JD(CDATA.PERIOD),CDATA.(CPOSL),XRANGE=AX.JD,YRANGE=CRANGE,AXIS_STYLE=1,XMINOR=0,YMINOR=0,LINESTYLE=0,COLOR=COLORS(C),                THICK=2,                 /CURRENT,/DEVICE,POSITION=CPOS,/OVERPLOT)
            ENDIF ELSE BEGIN
              LDATA = LOWESS(DATE_2MONTH(PERIOD_2DATE(CDATA.PERIOD)),CDATA.(CPOSM),WIDTH=7)
              CP0 = PLOT(JD_ADD(YDOY_2JD('2020',JD_2DOY(PERIOD_2JD(CDATA.PERIOD))),15,/DAY),CDATA.(CPOSM),XRANGE=AX.JD,YRANGE=CRANGE,AXIS_STYLE=1,XMINOR=0,YMINOR=0,LINESTYLE=6,COLOR=COLORS(C),SYMBOL='CIRCLE',SYM_SIZE=0.8,/SYM_FILLED,/CURRENT,/DEVICE,POSITION=CPOS,/OVERPLOT)
              ; CPL = PLOT(JD_ADD(YDOY_2JD('2020',JD_2DOY(PERIOD_2JD(CDATA.PERIOD))),15,/DAY),LDATA,       XRANGE=AX.JD,YRANGE=CRANGE,AXIS_STYLE=1,XMINOR=0,YMINOR=0,LINESTYLE=0,COLOR=COLORS(C),                THICK=2,                 /CURRENT,/DEVICE,POSITION=CPOS,/OVERPLOT)
              CPL = PLOT(JD_ADD(YDOY_2JD('2020',JD_2DOY(PERIOD_2JD(CDATA.PERIOD))),15,/DAY),CDATA.(CPOSL),XRANGE=AX.JD,YRANGE=CRANGE,AXIS_STYLE=1,XMINOR=0,YMINOR=0,LINESTYLE=0,COLOR=COLORS(C),                THICK=2,                 /CURRENT,/DEVICE,POSITION=CPOS,/OVERPLOT)
            ENDELSE
            TXT = TEXT(TXTC, TXTY-(DIF*C),NAMES(C)+' = ' + NUM2STR(CMEAN,DECIMALS=2),COLOR=COLORS(C),FONT_SIZE=12,FONT_NAME='HELVITICA',FONT_STYLE='BOLD',/DEVICE)
          ENDFOR
          XAXIS = AXIS('X',LOCATION=MAX(CP.YRANGE),MAJOR=0,TARGET=CP,MINOR=0)
          YAXIS = AXIS('Y',LOCATION=MAX(AX.JD), MAJOR=0,TARGET=CP,MINOR=0)
  
          PP = PLOT(AX.JD,PRANGE,XRANGE=AX.JD,XTICKNAME=AS.TICKNAME,XTICKVALUES=AS.TICKV,YRANGE=PRANGE,XMINOR=0,XTICKLEN=0.03,YTICKLEN=0.03,YMINOR=0,AXIS_STYLE=1,/CURRENT,/DEVICE,POSITION=PPOS,/NODATA,YTITLE=PTITLE)
          FOR C=0, N_ELEMENTS(CODES)-1 DO BEGIN
            PPOSM = WHERE(TAG_NAMES(ECOS) EQ REPLACE(PPDPROD,'-','_')+'_MEAN')
            PPOSL = WHERE(TAG_NAMES(ECOS) EQ REPLACE(PPDPROD,'-','_')+'_LOWESS')
            OK = WHERE(ECOS.SUBAREA_CODE EQ CODES(C) AND ECOS.(PPOSM) NE MISSINGS(0.0) AND STRMID(ECOS.PERIOD,0,STRLEN(PLOTPERIOD)) EQ PLOTPERIOD)
            PDATA = ECOS[OK]
            PMEAN = MEAN(PDATA.(PPOSM),/NAN)
            PDATA = PDATA[SORT(PERIOD_2JD(PDATA.PERIOD))]
            IF APERIOD EQ 'MONTH' THEN PDATA = PDATA[SORT(DATE_2MONTH(PERIOD_2DATE(PDATA.PERIOD)))]
            IF APERIOD EQ 'ANNUAL' THEN BEGIN
              ; LDATA = LOWESS(DATE_2YEAR(PERIOD_2DATE(PDATA.PERIOD)),PDATA.(PPOSM),WIDTH=7)
              PP0 = PLOT(PERIOD_2JD(PDATA.PERIOD),PDATA.(PPOSM),XRANGE=AX.JD,YRANGE=PRANGE,AXIS_STYLE=1,XMINOR=0,YMINOR=0,LINESTYLE=6,COLOR=COLORS(C),SYMBOL='CIRCLE',SYM_SIZE=0.8,/SYM_FILLED,/CURRENT,/DEVICE,POSITION=PPOS,/OVERPLOT)
              ;PPL = PLOT(PERIOD_2JD(PDATA.PERIOD),LDATA,       XRANGE=AX.JD,YRANGE=PRANGE,AXIS_STYLE=1,XMINOR=0,YMINOR=0,LINESTYLE=0,COLOR=COLORS(C),                THICK=2,                 /CURRENT,/DEVICE,POSITION=PPOS,/OVERPLOT)
              PPL = PLOT(PERIOD_2JD(PDATA.PERIOD),PDATA.(PPOSL),XRANGE=AX.JD,YRANGE=PRANGE,AXIS_STYLE=1,XMINOR=0,YMINOR=0,LINESTYLE=0,COLOR=COLORS(C),                THICK=2,                 /CURRENT,/DEVICE,POSITION=PPOS,/OVERPLOT)
            ENDIF ELSE BEGIN
              ;  LDATA = LOWESS(DATE_2MONTH(PERIOD_2DATE(PDATA.PERIOD)),PDATA.(PPOSM),WIDTH=7)
              PP0 = PLOT(JD_ADD(YDOY_2JD('2020',JD_2DOY(PERIOD_2JD(PDATA.PERIOD))),15,/DAY),PDATA.(PPOSM),XRANGE=AX.JD,YRANGE=PRANGE,AXIS_STYLE=1,XMINOR=0,YMINOR=0,LINESTYLE=6,COLOR=COLORS(C),SYMBOL='CIRCLE',SYM_SIZE=0.8,/SYM_FILLED,/CURRENT,/DEVICE,POSITION=PPOS,/OVERPLOT)
              ;  PPL = PLOT(JD_ADD(YDOY_2JD('2020',JD_2DOY(PERIOD_2JD(PDATA.PERIOD))),15,/DAY),LDATA,       XRANGE=AX.JD,YRANGE=PRANGE,AXIS_STYLE=1,XMINOR=0,YMINOR=0,LINESTYLE=0,COLOR=COLORS(C),                THICK=2,                 /CURRENT,/DEVICE,POSITION=PPOS,/OVERPLOT)
              PPL = PLOT(JD_ADD(YDOY_2JD('2020',JD_2DOY(PERIOD_2JD(PDATA.PERIOD))),15,/DAY),PDATA.(PPOSL),XRANGE=AX.JD,YRANGE=PRANGE,AXIS_STYLE=1,XMINOR=0,YMINOR=0,LINESTYLE=0,COLOR=COLORS(C),                THICK=2,                 /CURRENT,/DEVICE,POSITION=PPOS,/OVERPLOT)
            ENDELSE
            TXT = TEXT(TXTP, TXTY-(DIF*C),NAMES(C)+' = ' + NUM2STR(PMEAN,DECIMALS=2),COLOR=COLORS(C),FONT_SIZE=12,FONT_NAME='HELVITICA',FONT_STYLE='BOLD',/DEVICE)
          ENDFOR
          XAXIS = AXIS('X',LOCATION=MAX(PP.YRANGE),MAJOR=0,TARGET=PP,MINOR=0)
          YAXIS = AXIS('Y',LOCATION=MAX(AX.JD), MAJOR=0,TARGET=PP,MINOR=0)
  
          W.SAVE,PNGFILE,RESOLUTION=RESOLUTION
          W.CLOSE
        ENDFOR
      ENDIF ; FINAL_DATA
  
      IF KEY(COMPARE_PLOTS) THEN BEGIN
        MAP = 'NEC'
        L = READ_LANDMASK(MAP,/STRUCT)
  
        PERIOD_IN = 'D'
        PERIOD_OUT = 'M'
      ;  DATERANGE = ['1998','2016']
  
        IF DATASETS EQ [] THEN BEGIN
          DO_MODISA_NEW     = 0 & IF KEY(DO_MODISA_NEW)     THEN DATASETS = [DATASETS,'OC-MODISA-1KM']
          DO_MODISA_OLD     = 1 & IF KEY(DO_MODISA_OLD)     THEN DATASETS = [DATASETS,'OC-MODIS-LAC']
          DO_SEAWIFS_NEW    = 1 & IF KEY(DO_SEAWIFS_NEW)    THEN DATASETS = [DATASETS,'OC-SEAWIFS-1KM']
          DO_SEAWIFS_OLD    = 1 & IF KEY(DO_SEAWIFS_OLD)    THEN DATASETS = [DATASETS,'OC-SEAWIFS-MLAC']
  
          DO_PP_MODISA_NEW  = 1 & IF KEY(DO_PP_MODISA_NEW)  THEN DATASETS = [DATASETS,'PP-MODISA_PAN-1KM']
          DO_PP_MODISA_OLD  = 1 & IF KEY(DO_PP_MODISA_OLD)  THEN DATASETS = [DATASETS,'PP-MODIS_PAN-PAT-LAC']
          DO_PP_SEAWIFS_NEW = 1 & IF KEY(DO_PP_SEAWIFS_NEW) THEN DATASETS = [DATASETS,'PP-SEAWIFS_PAN-1KM']
          DO_PP_SEAWIFS_OLD = 1 & IF KEY(DO_PP_SEAWIFS_OLD) THEN DATASETS = [DATASETS,'PP-SEAWIFS_PAN-PAT-MLAC']
        ENDIF
  
        BUFFER = 0
  
        FOR NTH = 0L, N_ELEMENTS(DATASETS)-1 DO BEGIN
          DATASET = DATASETS[NTH]
          CASE DATASET OF
            'OC-MODISA-1KM':   BEGIN & SENSOR='MODISA'  & SERVER=!S.MODIS   & PRODS='CHLOR_A-PAN' & SUBDIR='L3B2' & END
            'OC-MODIS-LAC':    BEGIN & SENSOR='MODISA'  & SERVER=!S.ARCHIVE & PRODS='CHLOR_A-PAN' & SUBDIR='NEC'  & END
            'OC-SEAWIFS-1KM':  BEGIN & SENSOR='SEAWIFS' & SERVER=!S.SEADAS  & PRODS='CHLOR_A-PAN' & SUBDIR='L3B2' & END
            'OC-SEAWIFS-MLAC': BEGIN & SENSOR='SEAWIFS' & SERVER=!S.ARCHIVE & PRODS='CHLOR_A-PAN' & SUBDIR='NEC'  & END
  
            'PP-MODISA_PAN-1KM':       BEGIN & SENSOR='MODISA'  & SERVER=!S.PP     & PRODS='PPD-VGPM2' & SUBDIR='L3B2' & END
            'PP-MODIS_PAN-PAT-LAC':    BEGIN & SENSOR='MODISA'  & SERVER=!S.ARCHIVE & PRODS='PPD-VGPM2' & SUBDIR='NEC'  & END
            'PP-SEAWIFS_PAN-1KM':      BEGIN & SENSOR='SEAWIFS' & SERVER=!S.PP     & PRODS='PPD-VGPM2' & SUBDIR='L3B2' & END
            'PP-SEAWIFS_PAN-PAT-MLAC': BEGIN & SENSOR='SEAWIFS' & SERVER=!S.ARCHIVE & PRODS='PPD-VGPM2' & SUBDIR='NEC'  & END
          ENDCASE
  
          FOR PTH=0, N_ELEMENTS(PRODS)-1 DO BEGIN
            APROD = PRODS(PTH)
            DIR_AREAS  = !S.PROJECTS + 'ECOAP' + SL + 'SOE'  + SL + 'SUBAREAS' + SL       & DIR_TEST,DIR_AREAS
            DIR_STATS  = SERVER + DATASET + SL + SUBDIR + SL + 'STATS' + SL + APROD + SL
            DIR_ANOMS  = SERVER + DATASET + SL + SUBDIR + SL + 'ANOMS' + SL + APROD + SL
  
            FILES = FILE_SEARCH(DIR_ANOMS + 'A_*' + APROD + '*RATIO.SAV')
            FILES = [FILES,FILE_SEARCH(DIR_STATS + 'A_*' + APROD + ['*STATS.SAV','*MEAN.SAVE'])]
            FILES = FILES[WHERE(FILES NE '')]
            FILES = DATE_SELECT(FILES,DATERANGE,COUNT=COUNT)
            IF COUNT EQ 0 THEN STOP
  
            FA = PARSE_IT(FILES[0],/ALL)
            SAVEFILE = DIR_AREAS + INAME_MAKE(SENSOR=FA[0].SENSOR, SATELLITE=FA[0].SATELLITE, METHOD=FA[0].METHOD, COVERAGE=FA[0].COVERAGE, MAP=FA[0].MAP) + '-' + APROD + '-SUBAREAS.SAV'
            SFILES = FILE_SEARCH(!S.IDL_SHAPEFILES +'NES_ECOREGIONS_EXTENDED' + SL,'EPU_extended.shp',COUNT=COUNT_FILES)
            SUBAREAS_EXTRACT,FILES,SUBREGIONS=SUBREGIONS,SHP_FILES=SFILES,DIR_OUT=DIR_OUT,DIR_SHP=DIR_SHP,SAVEFILE=SAVEFILE,INIT=INIT,VERBOSE=VERBOSE
  
            DAT = IDL_RESTORE(SAVEFILE)
            FP = FILE_PARSE(SAVEFILE)
            DSETS = WHERE_SETS(DAT.MATH)
            FOR DTH=0, N_ELEMENTS(DSETS)-1 DO BEGIN
              NEW = DAT[WHERE_SETS_SUBS(DSETS(DTH))]
              SETS = WHERE_SETS(NEW.SENSOR,NEW.SUBAREA,NEW.PROD,NEW.MATH,/JOIN)
              PLTFILE = DIR_AREAS + FP.NAME + '-' + 'TIMESERIES.PNG'
              IF FILE_MAKE(SAVEFILE,PLTFILE,OVERWRITE=OVERWRITE) EQ 0 THEN CONTINUE
              W = WINDOW(DIMENSIONS=[1500,1100],BUFFER=BUFFER)
              TITLE = ''
              MARGIN=[0.1,0.15,0.05,0.1]
              FOR S = 0,N_ELEMENTS(SETS) -1 DO BEGIN
                D = NEW(WHERE_SETS_SUBS(SETS(S)))
                TXT = REPLACE(D[0].SUBAREA + '-' + D[0].SENSOR,'_','')
                LAYOUT = [1, N_ELEMENTS(SETS), S+1]
  
                DATES=DATE_2YEAR(PERIOD_2DATE(D.PERIOD))
                AX = DATE_AXIS([MIN(DATES),MAX(DATES)+1],/YEAR)
                Y = FLOAT(D.AMEAN)
                X = PERIOD_2JD(D.PERIOD)
  
                SUBAREA = FIRST(D.SUBAREA)
                IF DSETS(DTH).VALUE EQ 'RATIO_ANOMALY' THEN YRANGE = [0.75,1.25] ELSE YRANGE = []
                IF DSETS(DTH).VALUE EQ 'RATIO_ANOMALY' THEN YTITLE = UNITS(FIRST(D.PROD),/NO_UNIT) + ' Ratio Anomaly' ELSE YTITLE = UNITS(FIRST(D.PROD))
                PLT = PLOT(X,Y,BUFFER=BUFFER, CURRENT=1, LAYOUT=LAYOUT, MARGIN=MARGIN, TITLE=TITLE, $
                  XTITLE=XTITLE, XRANGE=AX.JD,  XSTYLE=XSTYLE, XTICKNAME=AX.TICKNAME,  XTICKV=AX.TICKV,  XMINOR=XMINOR, XCOLOR=AXES_COLOR, XTHICK=AXES_THICK,$
                  YTITLE=YTITLE, YRANGE=YRANGE, YSTYLE=YSTYLE, YTICKNAME=YTICKNAME,    YTICKV=YTICKV,    YMINOR=YMINOR, YCOLOR=AXES_COLOR, YTHICK= AXES_THICK, $
                  FONT_SIZE=16, LINESTYLE=LINESTYLE, COLOR='BLUE', THICK=2, SYMBOL='CIRCLE', SYM_FILLED=1, SYM_COLOR='BLUE', SYM_FILL_COLOR=SYM_FILL_COLOR, SYM_SIZE=0.4, SYM_THICK=SYM_THICK, CLIP=CLIP)
                IF DSETS(DTH).VALUE EQ 'RATIO_ANOMALY' THEN OPLT = PLOT(AX.JD,[1.0,1.0],COLOR='BLACK',/OVERPLOT,/CURRENT)
                POS = PLT.POSITION
              ENDFOR ; SETS
              W.SAVE, PLTFILE
              W.CLOSE
              PFILE, PLTFILE, /W
            ENDFOR ; DSETS
          ENDFOR ; PRODS
        ENDFOR ; DATASETS
      ENDIF ; COMPARE_PLOTS
    ENDIF ; SOE_2017
  ENDFOR ; SOE_YEAR




END; #####################  End of Routine ################################


