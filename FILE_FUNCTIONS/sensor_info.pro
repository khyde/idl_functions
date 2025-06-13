; $ID:	SENSOR_INFO.PRO,	2021-11-30-16,	USER-KJWH	$

FUNCTION SENSOR_INFO, FILES, PROD=PROD, GET_PRODS=GET_PRODS
;+
; NAME:
;   SENSOR_INFO
;
; PURPOSE:
;   This function returns a structure with information that can be found in NASA OCGB files (L3B, L3-SMI, L2)
;
; CATEGORY:
;   FILES
;
; CALLING SEQUENCE:
;   STRUCT = SENSOR_INFO(FILES)
;
; INPUTS:
;   FILES.......... Original NASA OCGB L1A, L2 or L3 file names
;
; OPTIONAL INPUTS:
;   PROD.......... If prod is provided, then just return then file info for the particular prod
;
; KEYWORD PARAMETERS:
;   GET_PRODS..... If set, get the product names by reading the file
;
; OUTPUTS:
;   This function returns a structure with information (i.e. SENSOR, SAT, possible PRODS) regarding the L2 and L3 files
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
;  ST,SENSOR_INFO(!S.DEMO + 'READ_NC_DEMO' + PATH_SEP() + 'O1997128.L3b_DAY_CHL.nc')
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
;   This program was written on October 7, 2015 by Kimberly Hyde,  Northeast Fisheries Science Center | NOAA Fisheries | U.S. Department of Commerce, 28 Tarzwell Dr, Narragansett, RI 02882
;
; MODIFICATION HISTORY:
;   OCT 07, 2015 - KJWH: Initial code written
;		OCT 16, 2015 - KJWH: Continued updating and testing the program
;	  OCT 19, 2015 - KJWH: Now returning both the NC product name and our (VALID_PRODS) product name in the structure
;		                     Now returning the NAME from PARSE_IT
;		                     Including the DELIM in the structure to indicate what is used to join the PRODS into a single string
;		                     Added PERIOD to the structure
;		OCT 20, 2O15 - KJWH: Changed the sensor TERRA to MODIST and added a case block for MODIST
;		                     NOTE - This program is currently not set up to work with the MODIS SST data yet.
;		                     Added SOURCE to the structure
;		                     Added AVHRR sensor info and made place holders for the MUR and G1SST data
;   OCT 21, 2015 - JEOR: Added EXAMPLE
;                        Added SENSOR_DATES
;   OCT 22, 2015 - KJWH: Fixed bug when inputing multiple files (S[N].NAME = NAME & SI[N].PERIOD = PERIOD)
;                        Changed NAME to SATNAME
;                        Added INAME
;   OCT 27, 2015 - KJWH: Added MODIS SST (4 & 11 um) info
;   OCT 30, 2015 - KWJH: Added MUR SST sensor info
;   NOV 10, 2015 - KJWH: Added info for MODISA and SeaWiFS L2 files
;                        Added EXT to the output structure because default L2 file names do not have the .nc extension
;   NOV 17, 2015 - KJWH: Moved S.DELIM = ';' to be before the file loop
;   DEC 03, 2015 - KJWH: Added GET_PRODS keyword to find the valid products in the L2 files
;   DEC 04, 2015 - KJWH: Updated to work with L2 SST files
;   DEC 30, 2015 - KJWH: Fixed bug to now return the actual file extension of the L2 files if it is .nc or .hdf
;   JAN 26, 2016 - KJWH: Fixed L2 extension bug
;                        Added MODIST and VIIRS L2 Sensor Info
;   FEB 03, 2016 - KJWH: Added L1A option
;   APR 26, 2016 - KJWH: Added SATNAME_SUB option to return the 'L3b_DAY_(prod)' protion of the L3B file
;   JUL 27, 2016 - KJWH: Updated to work with L3B1, L3B2, L3Bx files
;   OCT 07, 2016 - KJWH: Added 'AT' sensor
;   OCT 11, 2016 - KJWH: Added NAME, NAME_EXT, and PERIOD_CODE from to the output SI structure
;                        Fixed bug with M_*AVHRR files
;                        Added 'SAT' sensor (SeaWiFS, Aqua, Terra)
;   OCT 25, 2016 - KJWH: Added POC NC_PROD
;   JAN 20, 2017 - KJWH: Added N_PRODS to the output structure to return the number of products in the file
;   FEB 01, 2017 - KJWH: Changed AVHRR Method to 5_3
;   MAR 08, 2017 - KJWH: Now deriving info from VALIDS instead of PARSE_IT if a traditional file type (to avoid a potential infinite loop because PARSE_IT calls SENSOR_INFO)
;   APR 05, 2017 - KJWH: Fixed a bug when using VALIDS (changed COVERAGES to COVERAGE, MAP to MAPS and METHOD to METHODS)
;   SEP 25, 2017 - KJWH: Added CZCS to the 1KM sensor info
;   OCT 03, 2017 - KJWH: Added PIC NC_PROD
;   MAR 30, 2018 - KWJH: Changed PERIOD = 'D_' + STRMID(FP.DATE_START,0,8) to PERIOD = 'D_' + STRMID(FP[N].DATE_START,0,8) in the MUR block
;   AUG 08, 2018 - KJHW: Added information for the OCCCI dataset
;   AUG 13, 2018 - KJWH: Added OCCCI product information
;   OCT 15, 2018 - KJWH: Added HERMES product information
;   OCT 25, 2018 - KJWH: Changed the phytoplankton output names so that they include _PERCENTAGE
;   NOV 06, 2018 - KJWH: Removed COVERAGE from the FILELABEL output
;   DEC 17, 2018 - KJWH: Updated UITZ PSC names to include _PERCENTAGE
;   MAR 21, 2019 - KJWH: Added COPYRIGHT information
;                        Within the file loop, changed ENAMES to ENAME (the single name being processed within the loop)
;                        In AVHRR block change FP.NAME to SATNAME
;   JUL 22, 2019 - KJWH: Updated the OCCCI method/version to be V4_0
;   JUL 23, 2019 - KJWH: Changed IOP/A_CDOM output products to ADG
;   MAY 13, 2020 - KJWH: Updated the OCCCI version to V4_2
;   OCT 15, 2020 - KJWH: Added ability to work the AQUA_MODIS file names (new naming scheme for NASA R2019)
;                        Added COMPILE_OPT IDL2
;                        Changed subscript () to []
;                        Updated documentation
;   NOV 30, 2021 - KJWH: Removed SATELLITE from the call to INAME_MAKE()                     
;   Jan 10, 2022 - KJWH: Changed HERMES to GLOBCOLOUR
;   Jan 13, 2022 - KJWH: Added GLOBCOLOUR PAR details
;   Feb 17, 2022 - KJWH: Added GEOPOLAR_INTERPOLATED SST details
;   Mar 31, 2022 - KJWH: Added GEOPOLAR SST details (test data)
;   Nov 10, 2022 - KJWH: Added PROD_LABEL to the output structure 
;   Dec 05, 2022 - KJWH: Updated MUR products
;   Dec 21, 2022 - KJHW: Updated NASA sensor info (SEAWIFS, MODIS-AQUA, MODIS-TERRA)
;   Jan 30, 2023 - KJWH: Added CORAL (SST) products
;   Dec 12, 2023 - KJWH: Fixed bug with OCCCI RRS prod/alg information
;                           
; TODO: Update and move specific information to a MAIN csv file
;-
;	****************************************************************************************************
  ROUTINE_NAME = 'SENSOR_INFO'

  SL = PATH_SEP()
  DASH = '-'
  FP = PARSE_IT(FILES)
  NAMES  = FP.NAME
  ENAMES = FP.NAME_EXT
  
  S = REPLICATE(CREATE_STRUCT('NAME','','NAME_EXT','','PERIOD_CODE','','PERIOD','','SATNAME','','SATNAME_SUB','','INAME','', 'SENSOR','','SATELLITE','',$
      'METHOD','','MAP','','LEVEL','', 'COVERAGE','','N_BINS',0L,'DELIM','','N_PRODS',0L,'NC_PROD','','PRODS','','PROD_LABEL','','ALG','','PROD_ALG','','FILELABEL','','SOURCE','','SENSOR_DATES','','EXT',''),N_ELEMENTS(NAMES))
  S.DELIM = ';'
  S.NAME = NAMES
  S.NAME_EXT = ENAMES
  FOR N=0, N_ELEMENTS(FILES)-1 DO BEGIN
    AFILE   = FILES[N]
    ENAME   = ENAMES[N]
    FN      = FP[N]
    SATNAME = NAMES[N]
    STR     = STRSPLIT(SATNAME,'.',/EXTRACT)
    IF N_ELEMENTS(STR) GT 1 THEN SATNAME_SUB = STR[1] ELSE SATNAME_SUB = ''
    PERIOD  = FN.PERIOD
    PERIOD_CODE = FN.PERIOD_CODE

    ; ===> If the necessary info can be parsed from the file name, use this data (needed if a file has been renamed to include the PERIOD, SENSOR, MAP, etc.)
    IF VALIDS('SENSORS',ENAME,/VALID) THEN IF VALIDS('COVERAGE',ENAME) NE '' OR VALIDS('MAPS',ENAME) NE '' THEN BEGIN
      S[N].SENSOR       = VALIDS('SENSORS',   ENAME)
;      S[N].SATELLITE    = VALIDS('SATS',      ENAME)
      S[N].METHOD       = VALIDS('METHODS',   ENAME)
      S[N].MAP          = VALIDS('MAPS',      ENAME)
      S[N].LEVEL        = VALIDS('LEVELS',    ENAME)
      S[N].COVERAGE     = VALIDS('COVERAGE',  ENAME)
      S[N].INAME        = INAME_MAKE(PERIOD=S[N].PERIOD, SENSOR=S[N].SENSOR, METHOD=S[N].METHOD, COVERAGE=S[N].COVERAGE, MAP=S[N].MAP)
      S[N].PERIOD       = FN.PERIOD
      S[N].PERIOD_CODE  = FN.PERIOD_CODE
      S[N].FILELABEL    = INAME_MAKE(SENSOR=S[N].SENSOR,METHOD=S[N].METHOD,MAP=S[N].MAP)
      S[N].SENSOR_DATES = STRJOIN(SENSOR_DATES(S[N].SENSOR),'_')
      S[N].EXT          = FN.EXT
      IF ~N_ELEMENTS(PROD) THEN PROD = VALIDS('PRODS',FN.NAME)
      S[N].NC_PROD = PROD ; Find products in the NC file that match the requested PROD (needed for STATS_ARRAYS_PERIODS)
      CASE PROD OF
        'CHLOR_A': BEGIN
          CASE S[N].SENSOR OF
            'OCCCI': BEGIN & S[N].PRODS='CHLOR_A-CCI' & & S[N].MAP='GEQ' & S[N].ALG = 'CCI' & END
           ENDCASE 
           S[N].PROD_LABEL = S[N].PRODS[0] 
         END  
         'ATOT': BEGIN
           CASE S[N].SENSOR OF
             'OCCCI': BEGIN & S[N].NC_PROD=STRJOIN('ATOT_'+['443','490','510','560','665'],S[N].DELIM) & S[N].ALG='QAA' & S[N].PRODS=STRJOIN('ATOT_'+['443','490','510','560','665']+'-QAA',S[N].DELIM) & S[N].MAP='GEQ' & END
           ENDCASE
           S[N].PROD_LABEL = S[N].PRODS[0]
         END
         'BBP': BEGIN
           CASE S[N].SENSOR OF
             'OCCCI': BEGIN & S[N].NC_PROD=STRJOIN('BBP_'+['443','490','510','560','665'],S[N].DELIM) & S[N].ALG='QAA' & S[N].PRODS=STRJOIN('BBP_'+['443','490','510','560','665']+'-QAA',S[N].DELIM) & S[N].MAP='GEQ' & END
           ENDCASE
           S[N].PROD_LABEL = S[N].PRODS[0]
         END         
      ENDCASE
      CONTINUE
    ENDIF

    FL = STRMID(SATNAME,0,1)          ; The first letter indicates the sensor
    IF NUMBER(FL) EQ 0 AND NUMBER(STRMID(SATNAME,1,1)) EQ 1 THEN BEGIN     ; If the first character begins with a letter, match the letter up with the OC sensors
      CASE FL OF
        'A': SENSOR = 'MODISA'
        'C': SENSOR = 'CZCS'
        'M': SENSOR = 'MERIS'
        'O': SENSOR = 'OCTS'
        'S': SENSOR = 'SEAWIFS'
        'T': SENSOR = 'MODIST'
        'V': IF HAS(AFILE,'JPSS1') THEN SENSOR = 'JPSS1' ELSE SENSOR = 'VIIRS'
        'Z': SENSOR = 'SA'
        'X': SENSOR = 'AT'
        'Y': SENSOR = 'SAT'
        'E': SENSOR = 'OCCCI'
        'L': SENSOR = 'GLOBCOLOUR'
        ELSE: SENSOR = ''
      ENDCASE
    ENDIF
    IF HAS(SATNAME,'AQUA_MODIS')        THEN SENSOR = 'MODISA'
    IF HAS(SATNAME,'TERRA_MODIS')       THEN SENSOR = 'MODIST'
    IF HAS(SATNAME,'MODISA-AQUA')       THEN SENSOR = 'MODISA'
    IF HAS(SATNAME,'MODIST-TERRA')      THEN SENSOR = 'MODIST'
    IF HAS(SATNAME,'SEAWIFS')           THEN SENSOR = 'SEAWIFS'
    IF HAS(SATNAME,'AVHRR')             THEN SENSOR = 'AVHRR'
    IF HAS(SATNAME,'MUR')               THEN SENSOR = 'MUR'
    IF HAS(SATNAME,'ACSPO')             THEN SENSOR = 'ACSPO'
    IF HAS(SATNAME,'ACSPONRT')          THEN SENSOR = 'ACSPONRT'
    IF HAS(SATNAME,'G1SST')             THEN SENSOR = 'G1SST'
    IF HAS(SATNAME,'ESACCI-OC')         THEN SENSOR = 'OCCCI'
    IF HAS(SATNAME,'OCCCI')             THEN SENSOR = 'OCCCI'
    IF HAS(SATNAME,'CORAL')             THEN SENSOR = 'CORAL'
    IF HAS(SATNAME,'L4_GHRSST-SST-Geo_Polar_Blended') OR HAS(SATNAME,'GEOPOLAR') THEN SENSOR = 'GEOPOLAR'
    IF HAS(SATNAME,'Geo_Polar_Blended_Night-GLOB') OR HAS(SATNAME,'GEOPOLAR_INTERPOLATED') THEN SENSOR = 'GEOPOLAR_INTERPOLATED'
    IF HAS(SATNAME,'nrt_global_allsat_phy') THEN SENSOR = 'CMES'
    

    IF HAS(FP[N].NAME_EXT,'L2') OR HAS(FP[N].NAME_EXT,'L1') AND SENSOR NE 'GLOBCOLOUR' THEN BEGIN
      IF HAS(FP[N].NAME_EXT,'L1A') THEN LEVEL = 'L1A' ELSE LEVEL = 'L2'
      IF STRUPCASE(FP[N].EXT) EQ 'HDF' OR STRUPCASE(FP[N].EXT) EQ 'NC' THEN EXT = STRUPCASE(FP[N].EXT) ELSE EXT = 'NC'
      PERIOD_CODE = 'S'
      NC_PRODS = ''
      V_PRODS  = ''
      NC_ALGS  = ''
      IF KEY(GET_PRODS) THEN BEGIN
        SD = READ_NC(AFILE,/LOOK)
        NC_PRODS = SD.SD
        PRODS = VALID_ALG_CHECK(NC_PRODS,OPRODS=V_PRODS,ALGS=NC_ALGS,DAY_NIGHT=SD.GLOBAL.DAY_NIGHT_FLAG)
      ENDIF

      METHOD = 'R2018'               ; For the 2018 reprocessing - will need to be updated with future reprocessings
      CASE SENSOR OF
        'CZCS': BEGIN
          COVERAGE  = '1KM'
          SATELLITE = 'Nimbus-7'
          MP        = 'LONLAT'
          SOURCE    = 'http://oceandata.sci.gsfc.nasa.gov/'
        END

        'SEAWIFS': BEGIN
          COVERAGE  = '1KM'
          SATELLITE = 'OV2-DAY'
          MP        = 'LONLAT'
          SOURCE    = 'http://oceandata.sci.gsfc.nasa.gov/'
        END

        'MODISA': BEGIN
          COVERAGE  = '1KM'
          MP        = 'LONLAT'
          SATELLITE = 'AQUA'
          SOURCE    = 'http://oceandata.sci.gsfc.nasa.gov/'
          IF HAS(SATNAME,'SST') THEN METHOD = 'R2019'
        END

        'MODIST': BEGIN
          COVERAGE  = '1KM'
          MP        = 'LONLAT'
          SATELLITE = 'TERRA'
          SOURCE    = 'http://oceandata.sci.gsfc.nasa.gov/'
        END

        'VIIRS': BEGIN
          COVERAGE  = '1KM'
          MP        = 'LONLAT'
          SATELLITE = 'NPP'
          SOURCE    = 'http://oceandata.sci.gsfc.nasa.gov/'
        END
        
        'JPSS1': BEGIN
          COVERAGE  = '1KM'
          MP        = 'LONLAT'
          SATELLITE = 'NOAA-20'
          SOURCE    = 'http://oceandata.sci.gsfc.nasa.gov/'
        END

        'MERIS': BEGIN
          COVERAGE = ''
          MP       = 'LONLAT'
          SATELLITE = ''
          SOURCE   =  'http://oceandata.sci.gsfc.nasa.gov/'
        END
      ENDCASE
    ENDIF

    PROD_LABEL = ''
    IF HAS(ENAME,'L3B') OR HAS(ENAME,'L3m') OR HAS(SATNAME, 'GHRSST') OR HAS(SATNAME,'ESACCI') OR HAS(ENAME,'nrt_global_allsat_phy') OR HAS(ENAME,'coral') THEN BEGIN  ; Now works with L3B and GHRSST files
      NC_ALGS = []
      NC_PRODS = []
      V_PRODS = []
      METHOD = 'R2018'
      LEVEL = 'L3'
      EXT = FP[N].EXT
      CASE SENSOR OF
        'SEAWIFS': BEGIN
          SATELLITE ='SEASTAR'
          METHOD    = 'R2022'
          MP        = 'L3B9'
          SOURCE    = 'http://oceandata.sci.gsfc.nasa.gov/'
        END

        'MODISA': BEGIN
          MP        = 'L3B4'
          SATELLITE = 'AQUA'
          SOURCE    = 'http://oceandata.sci.gsfc.nasa.gov/'
        END

        'MODIST': BEGIN
          MP        = 'L3B4'
          SATELLITE = 'TERRA'
          SOURCE    = 'http://oceandata.sci.gsfc.nasa.gov/'
        END

        'VIIRS': BEGIN
          COVERAGE  ='4KM'
          MP        = 'L3B4'
          SATELLITE = 'NPP'
          SOURCE    = 'http://oceandata.sci.gsfc.nasa.gov/'
          ; MAY NEED TO ADD A SEPARATE BLOCK FOR VIIRS DATA DERIVED FROM THE NOAA WEBSITE
        END
        
        'JPSS1': BEGIN
          COVERAGE  ='4KM'
          MP        = 'L3B4'
          SATELLITE = 'NOAA-20'
          SOURCE    = 'http://oceandata.sci.gsfc.nasa.gov/'
          ; MAY NEED TO ADD A SEPARATE BLOCK FOR VIIRS DATA DERIVED FROM THE NOAA WEBSITE
        END

        'MODIS': BEGIN
          MP = 'L3B4'
          SST_QUALITY_CODE=2
          PROD_NAME    = ['SST4',        'SST',        'NSST']
          L3_PROD_NAME = ['sst4',        'sst',        'sst']
          L3_PROD_TXT  = ['L3b_DAY_SST4','L3b_DAY_SST','L3b_DAY_NSST']
          SOURCE       = 'http://oceandata.sci.gsfc.nasa.gov/'
          STOP ; SENSOR_INFO NOT SET UP FOR MODIS SST YET
        END

        'MERIS': BEGIN
          MP        = 'L3B4'
          SATELLITE = 'ENV'
          SOURCE    = 'http://oceandata.sci.gsfc.nasa.gov/'
        END

        'CZCS': BEGIN
          MP        = 'L3B4'
          SATELLITE = 'Nimbus-7'
          SOURCE    = 'http://oceandata.sci.gsfc.nasa.gov/'
        END

        'OCTS': BEGIN
          MP        = 'L3B9'
          SATELLITE = 'ADEOS'
          SOURCE    = 'http://oceandata.sci.gsfc.nasa.gov/'
        END

        'SA': BEGIN
          MP        = 'L3B9'
          SATELLITE = 'OV2-DAY_AQUA'
          SOURCE    = 'http://oceandata.sci.gsfc.nasa.gov/'
        END

        'AT': BEGIN
          MP        = 'L3B9'
          SATELLITE = 'AQUA_TERRA'
          SOURCE    = 'http://oceandata.sci.gsfc.nasa.gov/'
        END

        'AVHRR': BEGIN
          METHOD    = 'V5.3' ; Pathfinder 5.2
          MP        = 'L3';'EDCY'  ; Equidistant Cylindrical
          COVERAGE  = '4KM'
          SATELLITE = 'N00'
          SPOS = STRPOS(STRUPCASE(SATNAME),'_NIGHT')
          YDOY = STRMID(SATNAME,SPOS-7,7)
          DATE = YDOY_2DATE(STRMID(YDOY,0,4),STRMID(YDOY,4,3))
          PERIOD = 'D_' + STRMID(DATE,0,8)  ; Do not use the period derived from PARSE_IT because the beginning date and YDOY in the file name do not always match-up
          PERIOD_CODE = 'D'
          SOURCE    = 'http://www.nodc.noaa.gov/SatelliteData/pathfinder4km/'
          NC_PRODS = ['SEA_SURFACE_TEMPERATURE','PATHFINDER_QUALITY_LEVEL','L2P_FLAGS','LAT','LON']
          V_PRODS  = ['SST',                    'QUALITY',                 'L2P_FLAGS','LAT','LON']
          PROD_LABEL = 'SST'
        END

        'MUR': BEGIN
          LEVEL = 'L4'
          METHOD = 'V04.1'
          MP = 'L4' ; Equidistant Cylindrical ; MUR
          COVERAGE = '1KM'
          SATELLITE = 'GHRSST'
          PERIOD = 'D_' + STRMID(FP[N].DATE_START,0,8)  ; Do not use the period derived from PARSE_IT
          PERIOD_CODE = 'D'
          NC_PRODS = ['ANALYSED_SST','ANALYSIS_ERROR','MASK',    'LAT','LON']
          V_PRODS  = ['SST',         'SST_ERROR',     'SST_MASK','LAT','LON']
          SOURCE = 'https://podaac.jpl.nasa.gov/dataset/JPL-L4UHfnd-GLOB-MUR'
          PROD_LABEL = 'SST'
        END
        
        'ACSPO': BEGIN
          LEVEL = 'L4'
          METHOD = 'V2.81'
          MP = 'L4' 
          COVERAGE = '2KM'
          SATELLITE = 'GHRSST'
          PERIOD = 'D_' + STRMID(FP[N].DATE_START,0,8)  ; Do not use the period derived from PARSE_IT
          PERIOD_CODE = 'D'
          NC_PRODS = ['SEA_SURFACE_TEMPERATURE','SSES_BIAS','SSES_STANDARD_DEVIATION','WIND_SPEED', 'SST_GRADIENT_MAGNITUDE', 'SST_FRONT_POSITION', 'LAT', 'LON']
          V_PRODS  = ['SST',         'SST_BIAS', 'SST_STD',     'WIND_SPEED', 'GRAD_SST','GRADSST_FRONT','LAT','LON']
          SOURCE = 'https://coastwatch.noaa.gov/cwn/products/acspo-global-002o-gridded-super-collated-sst-and-thermal-fronts-low-earth-orbiting.html'
          PROD_LABEL = 'SST'
        END
        
        'ACSPONRT': BEGIN
          LEVEL = 'L4'
          METHOD = 'V2.0'
          MP = 'L4'
          COVERAGE = '2KM'
          SATELLITE = 'GHRSST'
          PERIOD = 'D_' + STRMID(FP[N].DATE_START,0,8)  ; Do not use the period derived from PARSE_IT
          PERIOD_CODE = 'D'
          NC_PRODS = ['SEA_SURFACE_TEMPERATURE','SSES_BIAS','SSES_STANDARD_DEVIATION','WIND_SPEED', 'SST_GRADIENT_MAGNITUDE', 'SST_FRONT_POSITION', 'LAT', 'LON']
          V_PRODS  = ['SST',         'SST_BIAS', 'SST_STD',     'WIND_SPEED', 'GRAD_SST','GRADSST_FRONT','LAT','LON']
          SOURCE = 'https://coastwatch.noaa.gov/cwn/products/acspo-global-002o-gridded-super-collated-sst-and-thermal-fronts-low-earth-orbiting.html'
          PROD_LABEL = 'SST'
        END
        
        'GEOPOLAR_INTERPOLATED': BEGIN
          LEVEL = 'L4'
          METHOD = 'V02.0'
          MP = 'NOAA5KM'; 'Geographic' ; 
          COVERAGE = '5KM'
          SATELLITE = 'Imager_AVHRR_VIIRS'
          PERIOD = 'D_' + STRMID(FP[N].DATE_START,0,8)  ; Do not use the period derived from PARSE_IT
          PERIOD_CODE = 'D'
          NC_PRODS = ['ANALYSED_SST','ANALYSIS_ERROR','MASK','LAT','LON']
          V_PRODS  = ['SST',         'STD',           'MASK','LAT','LON']
          SOURCE = 'https://coastwatch.noaa.gov/cw/satellite-data-products/sea-surface-temperature.html'
        END
        
        'GEOPOLAR': BEGIN
          LEVEL = 'L4'
          METHOD = 'V0.0'
          MP = 'NOAA5KM'
          COVERAGE = '5KM'
          SATELLITE = 'Imager_AVHRR_VIIRS'
          YEARDOY = STR_BREAK(REPLACE(FP[N].NAME,['L4_GHRSST-SST-Geo_Polar_Blended','_'],['','-']),'-')
          PERIOD = 'D_' + STRMID(YDOY_2DATE(YEARDOY[0],YEARDOY[1]),0,8)
          PERIOD_CODE = 'D'
          NC_PRODS = ['AVERAGED_SST','LAT','LON']
          V_PRODS  = ['SST',         'LAT','LON']
          SOURCE = 'coastwatch - test data'
        END  

        'G1SST': BEGIN
          LEVEL = 'L4'
          SATELLITE = 'GHRSST'
        END

        'OCCCI': BEGIN
          LEVEL     = 'L3'
          SATELLITE = 'MULTI'
          METHOD    = 'V6.0'
          SOURCE    = 'http://www.esa-oceancolour-cci.org/'
          MP        = 'SIN'
        END
        
        'GLOBCOLOUR': BEGIN
          LEVEL     = 'L3'
          SATELLITE = 'MULTI'
          METHOD    = 'R2019'
          SOURCE    = 'https://www.globcolour.info/index.html'
          MP        = 'L3'
          COVERAGE  = '4KM'
        END
        
        'CMES': BEGIN
          LEVEL     = 'L4'
          SATELLITE = 'MULTI'
          METHOD    = 'V2019'
          SOURCE    = 'https://resources.marine.copernicus.eu/product-detail/SEALEVEL_GLO_PHY_L4_NRT_OBSERVATIONS_008_046/INFORMATION'
          MP        = 'OISST'
          COVERAGE  = ''
        END
        
        'CORAL': BEGIN
          LEVEL = 'L3'
          SATELLITE = 'MULTI'
          METHOD = 'V3.1'
          SOURCE = 'https://coralreefwatch.noaa.gov/product/5km/index.php#data_access'
          MP = 'L3';'NOAA5KM'
          COVERAGE = '5KM'
        END
          
      ENDCASE

      ; Rewrite the MAP if specific L3Bx info is found in the name
      IF HAS(ENAME,'L3B1') THEN MP = 'L3B1'
      IF HAS(ENAME,'L3B2') THEN MP = 'L3B2'
      IF HAS(ENAME,'L3B4') THEN MP = 'L3B4'
      IF HAS(ENAME,'L3B5') THEN MP = 'L3B5'
      IF HAS(ENAME,'L3B9') THEN MP = 'L3B9'
  ;    IF HAS(ENAME,'4KM_SIN') THEN MP = 'L3B4'

      MS = MAPS_SIZE(MP)
      IF MS.PX EQ 1 THEN N_BINS = MS.PY ; If a MAP is a L3Bx (i.e. when PX is 1), then the number of BINS is PY

      ; Determine the COVERAGE based on the L3Bx MAPs
      CASE MP OF
        'L3B1': COVERAGE = '1KM'
        'L3B2': COVERAGE = '2KM'
        'L3B4': COVERAGE = '4KM'
        'L3B5': COVERAGE = '5KM'
        'L3B9': COVERAGE = '9KM'
        'SIN':  COVERAGE = '4KM'
        ELSE: COVERAGE = COVERAGE
      ENDCASE

      IF HAS(ENAME,'NSST') THEN BEGIN
        NC_PRODS = ['sst']
        V_PRODS  = ['SST']
        NC_ALGS  = ['N_11UM']
        PROD_LABEL = V_PRODS[0]
      ENDIF

      IF HAS(ENAME,'DAY_SST') THEN BEGIN
        NC_PRODS = ['sst']
        V_PRODS  = ['SST']
        NC_ALGS  = ['11UM']
        PROD_LABEL = V_PRODS[0]
      ENDIF

      IF HAS(ENAME,'SST4') THEN BEGIN
        NC_PRODS = ['sst4']
        V_PRODS  = ['SST']
        NC_ALGS  = ['N_4UM']
        PROD_LABEL = V_PRODS[0]
      ENDIF
      
      IF HAS(ENAME,'CHL')   THEN BEGIN
        CASE SENSOR OF  
          'OCCCI': BEGIN
            NC_PRODS = ['chlor_a','chlor_a_log10_bias','chlor_a_log10_rmsd']
            V_PRODS  = ['CHLOR_A-CCI','CHLOR_A_BIAS-CCI','CHLOR_A_RMSD-CCI']
            NC_ALGS  = ['OCI',         'OCI',            'OCI']
          END
          'GLOBCOLOUR': BEGIN
            NC_PRODS = ['chl1_mean','chl1_count','chl1_flags','chl1_error']
            V_PRODS  = ['CHLOR_A','CHLOR_A_COUNT','CHLOR_A_FLAGS','CHLOR_A_ERROR']
            IF HAS(ENAME,'GSM') THEN NCALG = 'GSM'
            IF HAS(ENAME,'_AV') THEN NCALG = 'AV'
            NC_ALGS = REPLICATE(NCALG,N_ELEMENTS(V_PRODS))
            V_PRODS = V_PRODS + '-' + NCALG
          END  
          ELSE: BEGIN
            NC_PRODS = ['chlor_a','chl_ocx']
            V_PRODS  = ['CHLOR_A-OCI','CHLOR_A-OCX']
            NC_ALGS  = ['OCI',    'OCX']
          END
        ENDCASE 
        PROD_LABEL = V_PRODS[0] 
      ENDIF

      IF HAS(ENAME,'IOP')   THEN BEGIN
        IF SENSOR EQ 'OCCCI' THEN BEGIN
          WAVE   = ['412','443','490','510','560','665']
          NPRODS = ['adg_412','adg_412_bias','adg_412_rmsd','aph_412','aph_412_bias','aph_412_rmsd','atot_412','bbp_412']  
          VPRODS = ['ADG_412','ADG_412_BIAS','ADG_412_RMSD','APH_412','APH_412_BIAS','APH_412_RMSD','ATOT_412','BBP_412']
          NC_PRODS = NPRODS & V_PRODS = VPRODS
          FOR I=0, N_ELEMENTS(WAVE)-1 DO NC_PRODS = [NC_PRODS, REPLACE(NPRODS,'412',WAVE[I])]
          FOR I=0, N_ELEMENTS(WAVE)-1 DO V_PRODS  = [V_PRODS,  REPLACE(VPRODS,'412',WAVE[I])]
          V_PRODS  = V_PRODS + '-QAA'
          NC_ALGS  = REPLICATE('QAA',N_ELEMENTS(NC_PRODS))
        ENDIF ELSE BEGIN
          NC_PRODS = ['adg_443_giop','bbp_443_giop','aph_443_giop']  ; NOTE - THERE ARE SEVERAL MORE IOP PRODUCTS NOT LISTED
          V_PRODS  = ['ADG_443',     'BBP_443',     'APH_443'] + '-GIOP'
          NC_ALGS  = REPLICATE('GIOP',N_ELEMENTS(NC_PRODS))
        ENDELSE
        PROD_LABEL = 'IOP'+'-'+NC_ALGS[0]
      ENDIF

      IF HAS(ENAME,'PAR')   THEN BEGIN
        V_PRODS  = 'PAR'
        CASE SENSOR OF
          'GLOBCOLOUR': NC_PRODS = 'par_mean'
           ELSE: NC_PRODS = ['par']
        ENDCASE
        PROD_LABEL = V_PRODS[0]
      ENDIF
 
      IF HAS(ENAME,'coraltemp') THEN BEGIN
        V_PRODS = 'SST'
        NC_PRODS = 'analysed_sst'
        PROD_LABEL = 'SST'
      ENDIF  
 
      IF HAS(ENAME,'KD490') THEN BEGIN
        V_PRODS  = ['KD_490']
        CASE SENSOR OF 
          'OCCCI': BEGIN
            NC_PRODS = ['kd_490','kd_490_bias','kd_490_rmsd']
            V_PRODS  = ['KD_490','KD_490_BIAS','KD_490_RMSD'] + '-ZHANG'
            NC_ALGS  = ['ZHANG','ZHANG','ZHANG']
          END
          ELSE: NC_PRODS = ['Kd_490']
        ENDCASE
        PROD_LABEL = V_PRODS[0]  
      ENDIF
      
      IF HAS(ENAME,'POC') THEN BEGIN
        V_PRODS = 'POC'
        CASE SENSOR OF
          'GLOBCOLOUR': NC_PRODS='poc_mean'
           ELSE: NC_PRODS = ['poc']
        ENDCASE
        PROD_LABEL = V_PRODS[0]
      ENDIF    
            
      IF HAS(ENAME,'PIC') THEN BEGIN
        V_PRODS = 'PIC'
        CASE SENSOR OF
          'GLOBCOLOUR': NC_PRODS='pic_mean'
          ELSE: NC_PRODS = ['pic']
        ENDCASE
        PROD_LABEL = V_PRODS[0]
      ENDIF     
      
      IF HAS(ENAME,'RRS') THEN BEGIN
        CASE SENSOR OF
          'MODISA':  NC_PRODS = ['Rrs_412', 'Rrs_443', 'Rrs_469', 'Rrs_488', 'Rrs_531', 'Rrs_547', 'Rrs_555', 'Rrs_645', 'Rrs_667', 'Rrs_678']
          'SEAWIFS': NC_PRODS = ['Rrs_412', 'Rrs_443', 'Rrs_490', 'Rrs_510', 'Rrs_555', 'Rrs_670']
          'VIIRS':   NC_PRODS = ['Rrs_410', 'Rrs_443', 'Rrs_486', 'Rrs_551', 'Rrs_671' ]
          'JPSS1':   NC_PRODS = ['Rrs_411', 'Rrs_445', 'Rrs_489', 'Rrs_556', 'Rrs_667' ]
          'MERIS':   NC_PRODS = ['Rrs_413', 'Rrs_443', 'Rrs_490', 'Rrs_510', 'Rrs_560', 'Rrs_620', 'Rrs_665', 'Rrs_681', 'Rrs_709']
          'CZCS':    NC_PRODS = ['Rrs_443', 'Rrs_520', 'Rrs_550', 'Rrs_670', 'Rrs_750']
          'OCTS':    NC_PRODS = ['Rrs_412', 'Rrs_443', 'Rrs_490', 'Rrs_516', 'Rrs_565', 'Rrs_667']
          'OCCCI':   NC_PRODS = ['Rrs_412', 'Rrs_443', 'Rrs_490', 'Rrs_510', 'Rrs_560', 'Rrs_665',$
            'Rrs_412_bias','Rrs_443_bias', 'Rrs_490_bias', 'Rrs_510_bias', 'Rrs_560_bias', 'Rrs_665_bias',$
            'Rrs_412_rmsd','Rrs_443_rmsd', 'Rrs_490_rmsd', 'Rrs_510_rmsd', 'Rrs_560_rmsd', 'Rrs_665_rmsd',$
            'water_class1','water_class2','water_class3','water_class4','water_class5','water_class6','water_class7','water_class8',$
            'water_class9','water_class10','water_class11','water_class12','water_class13','water_class14']
        ENDCASE
        PROD_LABEL = 'RRS'
      ENDIF
      
      IF HAS(ENAME,'PFT') THEN BEGIN
        NC_PRODS = ['diatoms_hirata','dinoflagellates_hirata','greenalgae_hirata', 'picoeukaryotes_hirata','prochlorococcus_hirata','prokaryotes_hirata','prymnesiophytes_hirata','microplankton_hirata','nanoplankton_hirata','picoplankton_hirata','microplankton_uitz','nanoplankton_uitz','picoplankton_uitz']
        V_PRODS  = ['DIATOM_PERCENTAGE-HIRATA', 'DINOFLAGELLATE_PERCENTAGE-HIRATA', 'GREEN_ALGAE_PERCENTAGE-HIRATA','PICOEUKARYOTE_PERCENTAGE-HIRATA', 'PROCHLOROCOCCUS_PERCENTAGE-HIRATA','PROKARYOTE_PERCENTAGE-HIRATA','PRYMNESIOPHYTE_PERCENTAGE-HIRATA','MICRO_PERCENTAGE-HIRATA','NANO_PERCENTAGE-HIRATA','PICO_PERCENTAGE-HIRATA','MICRO_PERCENTAGE-UITZ','NANO_PERCENTAGE-UITZ','PICO_PERCENTAGE-UITZ']
        PROD_LABEL = 'PFT'
      ENDIF
         
      IF HAS(ENAME,'nrt_global_allsat_phy') THEN BEGIN
        NC_PRODS = ['sla','err_sla','adt','ugos','vgos']
        V_PRODS  = ['SLA','SLA_ERROR','SSH','VELOCITY_EAST','VELOCITY_NORTH']
        NCALG = 'NRT'
        NC_ALGS = REPLICATE(NCALG,N_ELEMENTS(V_PRODS))
        V_PRODS = V_PRODS + '-' + NCALG
        PROD_LABEL = 'SLA'
      ENDIF
        
      IF ~N_ELEMENTS(V_PRODS) THEN V_PRODS = STRUPCASE(NC_PRODS)
      IF ~N_ELEMENTS(NC_ALGS) THEN NC_ALGS = REPLICATE('',N_ELEMENTS(NC_PRODS))
      IF SENSOR EQ 'OCCCI' THEN BEGIN
        NC_PRODS = [NC_PRODS,'MERIS_nobs','MODISA_nobs','SeaWiFS_nobs','VIIRS_nobs','total_nobs']
        V_PRODS  = [V_PRODS, 'NOBS-MER',  'NOBS-MODA',  'NOBS-SEA',    'NOBS-VIR',  'NOBS-TOT']
        NC_ALGS  = [NC_ALGS, 'MER',       'MODA',       'SEA',         'VIR',       'TOT']
        PROD_ALG = 'CCI'
      ENDIF

      IF ANY(PROD) THEN BEGIN  ;  Find products in the NC file that match the requested PROD (needed for STATS_ARRAYS_PERIODS)
        OK = WHERE_MATCH(V_PRODS,PROD,VALID=VALID,COUNT)
        IF COUNT GE 1 THEN BEGIN
          NC_PRODS = NC_PRODS[OK]
          V_PRODS  = V_PRODS[OK]
          IF ANY(NC_ALGS) THEN NC_ALGS  = NC_ALGS[OK]
        ENDIF ELSE BEGIN
          OK = WHERE_MATCH(NC_PRODS,PROD,VALID=VALID,COUNT)
          IF COUNT GE 1 THEN BEGIN
            NC_PRODS = NC_PRODS[OK]
            V_PRODS  = V_PRODS[OK]
            IF ANY(NC_ALGS) THEN NC_ALGS  = NC_ALGS[OK]
          ENDIF
        ENDELSE
      ENDIF
    ENDIF ; IF HAS(NAMES[N],'L3B') OR HAS(NAMES[N], 'GHRSST') THEN BEGIN

    S[N].SENSOR       = SENSOR
    S[N].SATELLITE    = SATELLITE
    S[N].METHOD       = METHOD
    S[N].MAP          = MP
    S[N].LEVEL        = LEVEL
    S[N].COVERAGE     = COVERAGE
    S[N].SOURCE       = SOURCE
    S[N].SATNAME      = SATNAME
    S[N].SATNAME_SUB  = SATNAME_SUB
    S[N].INAME        = INAME_MAKE(PERIOD=PERIOD, SENSOR=SENSOR, METHOD=METHOD, COVERAGE=COVERAGE, MAP=MP)
    S[N].PERIOD       = PERIOD
    S[N].PERIOD_CODE  = PERIOD_CODE
    S[N].FILELABEL    = INAME_MAKE(SENSOR=SENSOR,METHOD=METHOD,MAP=MP)
    S[N].SENSOR_DATES = STRJOIN(SENSOR_DATES(SENSOR),'_')
    S[N].EXT          = EXT
    IF ANY(N_BINS) THEN S[N].N_BINS    = N_BINS
    IF NONE(NC_ALGS) THEN NC_ALGS = ''
    IF N_ELEMENTS(NC_PRODS) GT 1 THEN S[N].NC_PROD = STRJOIN(NC_PRODS,S[N].DELIM) ELSE S[N].NC_PROD = NC_PRODS
    IF N_ELEMENTS(V_PRODS)  GT 1 THEN S[N].PRODS   = STRJOIN(V_PRODS, S[N].DELIM) ELSE S[N].PRODS   = V_PRODS
    IF N_ELEMENTS(NC_ALGS)  GT 1 THEN S[N].ALG     = STRJOIN(NC_ALGS, S[N].DELIM) ELSE S[N].ALG     = NC_ALGS
    S[N].N_PRODS = N_ELEMENTS(NC_PRODS)
    S[N].PROD_LABEL = PROD_LABEL
  ENDFOR
  RETURN, S



END; #####################  End of Routine ################################
