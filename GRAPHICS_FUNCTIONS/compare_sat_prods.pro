; $ID:	COMPARE_SAT_PRODS.PRO,	2023-09-21-13,	USER-KJWH	$
PRO COMPARE_SAT_PRODS, PRODS, SENSORS=SENSORS, COMBO=COMBO, PERIODS=PERIODS, SHPFILES=SHPFILES, SUBAREAS=SUBAREAS, MPS=MPS, FILE_TYPES=FILE_TYPES, YRANGE=YRANGE, YTITLE=YTITLE, $
                       PLTPROD=PLTPROD, COLORS=COLORS, DATERANGE=DATERANGE, DIR_OUT=DIR_OUT, VERSION=VERSION, PROD_VERSION=PROD_VERSION, BUFFER=BUFFER, OVERWRITE=OVERWRITE
;+
; NAME:
;   COMPARE_SAT_PRODS
; 
; PURPOSE: 
;   To compare time series from various products/sensors
;
; CATEGORY:
;   GRAPHICS_FUNCTIONS
;
; CALLING SEQUENCE:
;   COMPARE_SAT_PRODS, PRODS
;   
; REQUIRED_INPUTS:
;   PRODS........... The names of the different products to be used for data comparisons
;
; OPTIONAL INPUTS:
;   SENSORS......... Sensor names
;   COMBO........... To compare a combination of sensors and products
;   PERIOD.......... Time period for comparisons
;   MPS............. Map of the input files 
;   SHPFILES........ Name of the subarea shape file
;   SUBAREAS........ Name of subareas within the shape file to extract the data from
;   DATERANGE....... Specify the date range of the input files
;   YRANGE.......... Y axis plot range
;   YTITLE.......... Y axis title
;   COLORS.......... Colors for the plots (defaults = ['DARK_BLUE','DARK_ORANGE','DARK_TURQUOISE','RED','SPRING_GREEN','BLUE','MAGENTA'])
;   PLTPRD.......... Product to base the plotting - Used if the "COMBO" prods are similar (e.g. MICRO, NANO, PICO), but not exactly the same
;   DIR_OUT......... Output directory for the extracted data and plots
;   VERSION......... The dataset version
;   PROD_VERSION.... The product version
;   FILE_TYPES........... The type of input file (e.g. SAVE, STACKED_FILES)
;
; KEYWORDS
;   INTERP..........Set to use the interpolated data instead of the STATS
;   BUFFER..........Buffer for the plotting steps
;   OVERWRITE.......Overwrite the plot if it already exists
;
; OUTPUTS
;   Time series plots of the data in each subregion
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
; EXAMPLES:
;   0) COMPARE_SAT_PRODS
;   1) COMPARE_SAT_PRODS, ['CHLOR_A-OCI','CHLOR_A-OCX','CHLOR_A-PAN']
;   2) COMPARE_SAT_PRODS, ['CHLOR_A-OCI','CHLOR_A-OCX','CHLOR_A-PAN'], SENSORS=['SEAWIFS','MODISA']
;   3) COMPARE_SAT_PRODS, ['CHLOR_A-OCI','CHLOR_A-OCX','CHLOR_A-PAN'], SENSORS=['SEAWIFS','MODISA'], MPS=['L3B2'],
;   4) COMPARE_SAT_PRODS, ['CHLOR_A-OCI','CHLOR_A-OCX','CHLOR_A-PAN'], SENSORS=['SEAWIFS','MODISA'], MPS=['L3B2'], SHPFILES='NES_ECOREGIONS/EPU_NOESTUARIES'
;   5) COMPARE_SAT_PRODS, ['CHLOR_A-OCI','CHLOR_A-OCX','CHLOR_A-PAN'], SENSORS=['SEAWIFS','MODISA'], MPS=['L3B2'], SHPFILES='NES_ECOREGIONS/EPU_NOESTUARIES', DATERANGE=['2002','2012']
;   6) COMPARE_SAT_PRODS, COMBO=['SEAWIFS,CHLOR_A-OCX;OCCCI,CHLOR_A-OCI'], DATERANGE=['1997','2010']
;   7) COMPARE_SAT_PRODS, COMBO=['OCCCI,MICRO-BREWINSST_NEW;OCCCI,MICRO-BREWINSST_NES,PVER_1'], DATERANGE=['1997','2020']
;
; NOTES:
; 
; COPYRIGHT:
; Copyright (C) 2018, Department of Commerce, National Oceanic and Atmospheric Administration, National Marine Fisheries Service,
;   Northeast Fisheries Science Center, Narragansett Laboratory.
;   This software may be used, copied, or redistributed as long as it is not sold and this copyright notice is reproduced on each copy made.
;   This routine is provided AS IS without any express or implied warranties whatsoever.
;
;   This program was written October 19, 2018 by Kimberly Hyde, Northeast Fisheries Science Center | NOAA Fisheries | U.S. Department of Commerce, kimberly.hyde@noaa.gov.
;
; MODIFICATION HISTORY:
;   Oct 19, 2018 - KJWH: Adapted from COMPARE_SAT_SENSORS (formerly COMPARE_SAT_DATA)
;   Oct 22, 2018 - KJWH: Added an optional DIR_OUT keyword
;                        Added a DSUBS directory for the individual files from SUBAREAS_EXTRACT
;                        Now saving the merged data file
;   Nov 05, 2018 - KJWH: Changed DSUBS directory to !S.EXTRACTS  
;                        Updated how the DATERANGE is calculated if not provided (now uses SENSOR_DATES)        
;   Dec 10, 2018 - KJWH: Changed parameter name DATERANGE to DR after it has been determined if the DATERANGE exists or not.  
;                        Otherwise, the incorrect daterange could be used when looping through sensors.     
;   Dec 14, 2018 - KJWH: Added the BUFFER keyword                                                  
;   May 14, 2019 - KJHW: Updated the SHPFILE name SHPFILE = !S.IDL_SHAPEFILES + 'SHAPES' + SL + SUBAREA + SL + SUBAREA + '.shp'
;                        Changed the default SUBAREA to NES_EPU_NOESTUARIES
;   Jan 28, 2020 - KJWH: Updated the STAT used to plot the data - added information to the CASE PROD OF block    
;   Jan 29, 2020 - KJWH: Fixed bug for when files were not found for a specific product and sensor      
;                        Defaulting to the 'median" STAT if the requeste stat is not available (e.g. GSTATS_MED will not be calculated in SUBAREAS_EXTRACT for daily/non-stat files)           
;   Jul 28, 2020 - KJWH: Updated documentation
;                        Added COMPILE_OPT IDL2
;                        Changed subscript () to []
;                        Updated YRANGE for the MICRO, NANO, PICO and NANOPICO products
;                        Added YRANGE and YTITLE keywords
;                        Now using GET_FILES to find the files for the subarea extract
;   Aug 20, 2020 - KJWH: Added DIATOM and DINOFLAGELLATE products           
;                        Now, if the number of subareas is greater than 6, the plots will be broken up into multiple files          
;   Aug 21, 2020 - KJWH: Added PLTPROD keyword to for when similar products are to be plotted together   
;   Sep 01, 2020 - KJWH: Added M3 period information       
;   Oct 23, 2020 - KJWH: Added VERSION and PROD_VERSION to distinguish between different dataset versions and product version   
;   Nov 03, 2020 - KJWH: Changed SUBAREAS input parameter to SHPFILES to reflect that the input is actually the shape file name
;                        They input parameter SUBAREAS is now fed to SUBAREAS_EXTRACT to indicate the SUBAREAS within the shape file to extract       
;   Nov 04, 2020 - KJWW: Added DIR_TEST, DIR_OUT
;                        Added ability to fix SENSOR,PROD combo inputs - Note, it will not work with a 3 component combo string
;   Jan 28, 2021 - KJWH: Removed DSUBS = !S.SUBAREAS_EXTRACT - this will be set in SUBAREAS_EXTRACT
;   Jan 10, 2022 - KJWH: Changed HERMES to GLOBCOLOUR
;   Nov 22, 2022 - KJWH: Changed NONE() to ~N_ELEMENTS() and KEY() to KEYWORD_SET()
;                        Updated documentation
;-
;****************************************
  ROUTINE_NAME = 'COMPARE_SAT_PRODS'
  COMPILE_OPT IDL2
  SL=PATH_SEP()

  IF ~N_ELEMENTS(DIR_OUT) THEN DIR = !S.COMPARE_SAT_DATA ELSE DIR = DIR_OUT & DIR_TEST, DIR
  DDATA = DIR + 'DATA' + SL                    ; Directory for the merged data
  DPLOT = DIR + 'PROD_PLOTS' + SL              ; Directory for the plots
  DIR_TEST, [DDATA,DPLOT]
  DP = DATE_PARSE(DATE_NOW())
  
  IF ~N_ELEMENTS(COLORS) THEN COLORS = ['DARK_BLUE','DARK_ORANGE','DARK_TURQUOISE','RED','SPRING_GREEN','BLUE','MAGENTA','MAROON','LAVENDER']
  YMINOR=1
  FONTSIZE = 10
  SYMSIZE = 0.45
  THICK = 2
  FONT = 0
  YMARGIN = [0.3,0.3]
  XMARGIN = [4,1]

 ; IF KEYWORD_SET(INTERP)       THEN FILE_TYPE    = 'INTERP_SAVE' ELSE FILE_TYPE=[]
  IF ~N_ELEMENTS(FILE_TYPES) THEN FILE_TYPE = ' '
  IF ~N_ELEMENTS(PRODS)        THEN PRODS        = ['CHLOR_A-OCI','CHLOR_A-OCX','CHLOR_A-PAN']
  IF ~N_ELEMENTS(SENSORS)      THEN SENSORS      = ['SEAWIFS','MODISA','VIIRS','OCCCI']
  IF ~N_ELEMENTS(PERIODS)      THEN PERIODS      = 'M'
  IF ~N_ELEMENTS(SHPFILES)     THEN SHPFILES     = 'NES_EPU_NOESTUARIES'
  IF ~N_ELEMENTS(MPS)          THEN MPS          = 'L3B4'
  IF ~N_ELEMENTS(BUFFER)       THEN BUFFER       = 1
  IF ~N_ELEMENTS(VERSION)      THEN VERSION      = ' '
  IF ~N_ELEMENTS(PROD_VERSION) THEN PROD_VERSION = ' '
  IF ~N_ELEMENTS(COMBO)        THEN BEGIN
    COMBO = []
    FOR R=0, N_ELEMENTS(VERSION) -1 DO BEGIN
      CMB = []
      IF VERSION[R] EQ '' THEN VERSION[R] = ' '
      IF FILE_TYPES[R] EQ '' THEN FILE_TYPES[R] = ' '  
      FOR N=0, N_ELEMENTS(SENSORS)-1 DO BEGIN     
        FOR I=0, N_ELEMENTS(PRODS)-1 DO BEGIN
          FOR V=0, N_ELEMENTS(PROD_VERSION)-1 DO CMB = STRJOIN([CMB,STRJOIN([SENSORS[N], VERSION[R],FILE_TYPES[R],PRODS[I], PROD_VERSION[V]],',')],';')
        ENDFOR ; PRODS
        CMB = REPLACE(CMB,',,',',')
        COMBO = [COMBO,CMB]
      ENDFOR ; SENSOR  
    ENDFOR ; VERSION 
  ENDIF ELSE BEGIN
    _COMBO=COMBO
    FOR C=0, N_ELEMENTS(COMBO)-1 DO BEGIN
      CMB = STR_BREAK(COMBO[C],';')
      CB  = STR_BREAK(CMB,',')
      IF N_ELEMENTS(CB[0,*]) EQ 2 THEN BEGIN
        OKS = WHERE(IS_SENSOR(CB[*,0]) EQ 1, COUNTS)   ; Assumes that the sensors are listed second
        OKP = WHERE(IS_PROD(CB[*,1]) EQ 1, COUNTP)     ; Assumes that the products are listed third
        IF COUNTS NE N_ELEMENTS(CB[*,0]) OR COUNTP NE N_ELEMENTS(CB[*,1]) THEN MESSAGE, 'ERROR: Check the COMBO input for the correct format.'
        CMB = ' ,'+CMB + ', '                          ; Change the COMBO format to the correct VERSION, FILE_TYPE, SENSOR, PRODUCT, PRODUCT VERSION joined string format
        COMBO[C] = STRJOIN(REFORM(CMB),';')
      ENDIF ELSE IF N_ELEMENTS(CB[0,*]) NE 5 THEN MESSAGE, 'ERROR: VERSION, FILE_TYPE, SENSOR, PRODUCT or product VERSION missing from '+ CB[0,*]
    ENDFOR
  ENDELSE    
  
  FOR N=0, N_ELEMENTS(SHPFILES)-1 DO BEGIN
    SHPFILE = SHPFILES[N]

    FOR R=0, N_ELEMENTS(PERIODS)-1 DO BEGIN
      PER = PERIODS[R]

      CASE PER OF
        'D':     PLABEL = 'DAILY'
        'DOY':   PLABEL = 'DOY'
        'D8':    PLABEL = '8-DAY'
        'W':     PLABEL = 'WEEKLY'
        'M':     PLABEL = 'MONTHLY'
        'MONTH': PLABEL = 'MONTHLY_CLIMATOLOGY'
        'M3':    PLABEL = 'SEASONAL'
        'A':     PLABEL = 'YEARLY'
      ENDCASE

      FOR M=0, N_ELEMENTS(MPS)-1 DO BEGIN
        EFILES = []
        CDATA  = []
        MSUBS  = []
        
        FOR C=0, N_ELEMENTS(COMBO)-1 DO BEGIN
          CMB = STR_BREAK(COMBO[C],';')
          CB  = STR_BREAK(CMB,',')
          IF N_ELEMENTS(CB[0,*]) NE 5 THEN MESSAGE, 'ERROR: VERSION, FILE_TYPE, SENSOR, PRODUCT or product VERSION missing from '+ CMB
           SEN  = CB[*,0] ; Sensor
           VER  = CB[*,1] ; Version
           TYP  = CB[*,2] ; File type
           PRD  = CB[*,3] ; Product
           PVER = CB[*,4] ; Product version
           CMB_NOFT = CMB ; REPLACE(CMB,','+TYP,REPLICATE('',N_ELEMENTS(TYP)))
           
          IF ~N_ELEMENTS(DATERANGE) THEN BEGIN
            D1 = [] & D2 = []
            FOR D=0, N_ELEMENTS(SEN)-1 DO BEGIN
              DR = SENSOR_DATES(SEN[D])
              D1 = MIN([D1,DR[0]])
              D2 = MAX([D2,DR[1]])
            ENDFOR
            DR = [D1,D2]
          ENDIF ELSE DR = GET_DATERANGE(DATERANGE)
          CASE PER OF
            'DOY': BEGIN
              AXRANGE = ['21000101','21001231']
              X = DATE_2JD(AXRANGE) & AX = DATE_AXIS(X,/FYEAR,STEP_SIZE=2)
              SDR = []
            END
            'MONTH': BEGIN
              AXRANGE = ['21000101','21001231']
              X = DATE_2JD(AXRANGE) & AX = DATE_AXIS(X,/FYEAR,STEP_SIZE=2)
              SDR = []
            END
            ELSE: BEGIN
              AXRANGE = [STRMID(DR[0],0,4)+'0101',STRMID(DR[1],0,4)+'1231']
              X  = DATE_2JD(AXRANGE) & AX  = DATE_AXIS(X,/MONTH, /YY_YEAR,STEP_SIZE=12) & AYR = DATE_AXIS(X,/YEAR)
              SDR = DR
            END  
          ENDCASE
          XTICKNAMES = REPLICATE(' ',N_ELEMENTS(AX.TICKNAME))

          FOR P=0, N_ELEMENTS(PRD)-1 DO BEGIN
            AVER  = VER[P]  & IF AVER EQ ' ' THEN AVER = ''
            APROD = PRD[P]
            ASEN  = SEN[P]
            APVER = PVER[P] & IF APVER EQ ' ' THEN APVER = ''
            ATYP  = TYP[P]  & IF ATYP  EQ ' ' THEN BEGIN & ATYP  = [] & TYPTXT = '' & ENDIF ELSE TYPTXT = ATYP
            IF MPS[M] EQ 'L3B2' AND ASEN EQ 'OCCCI'  THEN AMAP = 'L3B4' ELSE AMAP = MPS[M]
            IF MPS[M] EQ 'L3B2' AND ASEN EQ 'GLOBCOLOUR' THEN AMAP = 'L3B4' 
            IF HAS(APROD,'RRS') THEN SPROD = RRS_SWAP(RRS=APROD,SENSOR_IN='SEAWIFS',SENSOR_OUT=ASEN) ELSE SPROD = APROD
            
            FILES = GET_FILES(ASEN, PERIODS=PER, PRODS=SPROD, DATERANGE=SDR, MAPS=AMAP, FILE_TYPE=ATYP, VERSION=AVER, PROD_VERSION=APVER, COUNT=COUNTF)
            IF COUNTF EQ 0 THEN BEGIN
              MSUBS = [MSUBS,P]
              CONTINUE
            ENDIF  
            SAVEFILE = PLABEL + '-' + ASEN + '-' + AVER + '-' + AMAP + '-' + APROD + '-' + APVER + '-' + SHPFILE + '-' + TYPTXT + '.SAV'
            SAVEFILE = REPLACE(SAVEFILE,['--','-.'],['-','.'])
            SUBAREAS_EXTRACT, FILES, SV_PROD=VALIDS('PRODS',APROD), SHP_NAME=SHPFILE,SUBAREAS=SUBAREAS,DIR_OUT=DDIR,SAVEFILE=SAVEFILE,INIT=INIT,VERBOSE=VERBOSE
            EFILES = [EFILES,SAVEFILE]
            SDATA = STRUCT_READ(SAVEFILE)
            SUBSET_SDATA = DATE_SELECT(SDATA.NAME,DR,SUBS=SUBS)
            SDATA = SDATA[SUBS]
            SDATA = STRUCT_MERGE(SDATA,REPLICATE(CREATE_STRUCT('DATA_VERSION',AVER,'PROD_VERSION',APVER),N_ELEMENTS(SDATA)))
            IF CDATA EQ [] THEN CDATA = SDATA ELSE CDATA = STRUCT_CONCAT(CDATA,SDATA)
          ENDFOR ; PRODS
          
          IF EFILES EQ [] THEN BEGIN
            PRINT, 'No files found for ' + STRJOIN(SENSORS,' & ') + ' for ' + PER + '*' + APROD + '*'
            CONTINUE
          ENDIF
                    
          IF MSUBS NE [] AND N_ELEMENTS(SEN) GT 1 THEN BEGIN
            SEN = REMOVE(SEN,MSUBS)
            PRD = REMOVE(PRD,MSUBS)
          ENDIF
          
          SPLABEL = SEN[0] + '-' + VER[0] + '-' + PRD[0] + '-' + TYP[0]
          IF ~SAME(PRD) THEN SPLABEL = REPLACE(SPLABEL,PRD[0],STRJOIN(PRD,'_')) 
          IF ~SAME(VER) THEN SPLABEL = REPLACE(SPLABEL,VER[0],STRJOIN(VER,'_'))
          IF ~SAME(SEN) THEN SPLABEL = REPLACE(SPLABEL,SEN[0],STRJOIN(SEN,'_'))
          IF ~SAME(TYP) THEN SPLABEL = REPLACE(SPLABEL,TYP[0],STRJOIN(TYP,'_'))
          IF SAME(PRD) + SAME(SEN) EQ 0 THEN SPLABEL = STRJOIN(SEN + '-' + PRD,'-')
          
          DATFILE = DDATA + PER + '_' + STRJOIN(DR,'_') + '-' + MPS[M] + '-' + SPLABEL + '-' + SHPFILE + '.SAV'
          IF FILE_MAKE(EFILES,DATFILE,OVERWRITE=OVERWRITE) EQ 1 THEN BEGIN
            SAVE, CDATA, FILENAME=DATFILE ; ===> SAVE THE MERGED DATAFILE
            SAVE_2CSV, DATFILE
          ENDIF
          
          SETS = WHERE_SETS(CDATA.SUBAREA)
          IF N_ELEMENTS(SUBAREAS) GT 0 THEN BEGIN
            OK_SETS = WHERE_MATCH(SETS.VALUE, SUBAREAS, COUNT)
            IF COUNT GT 0 THEN SETS = SETS[OK_SETS]
          ENDIF
          IF N_ELEMENTS(SETS) GT 6 THEN BEGIN
            MODS = [8,7,6,5,4,3,2,1]
            I = 0
            WHILE N_ELEMENTS(SETS) MOD MODS[I] NE 0 DO I = I+1
            NPLOTS = N_ELEMENTS(SETS)/MODS[I]
            PNGFILES = DPLOT + PER + '_' + STRJOIN(DR,'_') + '-' + MPS[M] + '-' + SPLABEL + '-' + SHPFILE + '-' + NUM2STR(INDGEN(NPLOTS)+1) + '.PNG'
            PLOTSUBS = LIST()
            FIRSTSUB = 0
            FOR NP=0, NPLOTS-1 DO BEGIN
              SUBS = SETS[FIRSTSUB:FIRSTSUB+MODS[I]-1]
              PLOTSUBS.ADD, SUBS
              FIRSTSUB = FIRSTSUB + MODS[I]
            ENDFOR
          ENDIF ELSE BEGIN
            NPLOTS = 1
            PLOTSUBS = LIST([SETS])
            PNGFILES = DPLOT + PER + '_' + STRJOIN(DR,'_') + '-' + MPS[M] + '-' + SPLABEL + '-' + SHPFILE + '.PNG'
          ENDELSE
          IF FILE_MAKE(EFILES,PNGFILES,OVERWRITE=OVERWRITE) EQ 0 THEN CONTINUE
          
          PRDS = VALIDS('PRODS',PRD)
          IF ~SAME(PRDS) AND N_ELEMENTS(PLTPROD) EQ 0 THEN BEGIN
            IF N_ELEMENTS(PRDS) EQ 1 THEN APROD = PRDS[0] ELSE MESSAGE, 'ERROR: Must input a single PROD for COMBO plots.'
          ENDIF ELSE IF N_ELEMENTS(PLTPROD) EQ 1 THEN APROD = PLTPROD ELSE APROD = PRDS[0]
                
          CASE VALIDS('PRODS',APROD) OF
            'CHLOR_A'               : BEGIN & STAT='MED' & DYRANGE='0,5'   & WYRANGE='0,3'    & MYRANGE='0,3'    & AYRANGE='0,2'    & LOG=1 & TPROD='Chlorophyll'          & ANOM='RATIO' & END
            'MICRO'                 : BEGIN & STAT='GSTATS_MED' & DYRANGE='0,3'    & WYRANGE='0,2'    & MYRANGE='0,2'    & AYRANGE='0,1'    & LOG=1 & TPROD='Micro Chlorophyll'    & ANOM='RATIO' & END
            'PSC_MICRO'         : BEGIN & STAT='MED' & DYRANGE='0,3'    & WYRANGE='0,2'    & MYRANGE='0,1.5'    & AYRANGE='0,1'    & LOG=1 & TPROD='Micro Chlorophyll'    & ANOM='RATIO' & END
            'PSC_NANO'         : BEGIN & STAT='MED' & DYRANGE='0,3'    & WYRANGE='0,2'    & MYRANGE='0,1.5'    & AYRANGE='0,1'    & LOG=1 & TPROD='Nano Chlorophyll'    & ANOM='RATIO' & END
            'PSC_NANOPICO'         : BEGIN & STAT='MED' & DYRANGE='0,3'    & WYRANGE='0,2'    & MYRANGE='0,1.5'    & AYRANGE='0,1'    & LOG=1 & TPROD='Nano-pico Chlorophyll'    & ANOM='RATIO' & END
            'PSC_PICO'         : BEGIN & STAT='MED' & DYRANGE='0,3'    & WYRANGE='0,2'    & MYRANGE='0,1'    & AYRANGE='0,1'    & LOG=1 & TPROD='Pico Chlorophyll'    & ANOM='RATIO' & END
            'PSC_DIATOM'                : BEGIN & STAT='MED' & DYRANGE='0,3'    & WYRANGE='0,2'    & MYRANGE='0,2'    & AYRANGE='0,1'    & LOG=1 & TPROD='Diatom Chlorophyll'    & ANOM='RATIO' & END
            'PSC_FMICRO'      : BEGIN & STAT='MEAN' & DYRANGE='0,.8'   & WYRANGE='0,.8'   & MYRANGE='.2,.8'   & AYRANGE='0,.4'   & LOG=0 & TPROD='Micro CHL (%)'        & ANOM='DIF'   & END
            'PSC_FNANOPICO'   : BEGIN & STAT='MEAN' & DYRANGE='0,.8'   & WYRANGE='0,.8'   & MYRANGE='.2,.8'   & AYRANGE='0,.8'   & LOG=0 & TPROD='NanoPico CHL (%)'     & ANOM='DIF'   & END
            'PSC_FNANO'       : BEGIN & STAT='MEAN' & DYRANGE='0,.8'   & WYRANGE='0,.8'   & MYRANGE='.2,.8'   & AYRANGE='0,.8'   & LOG=0 & TPROD='Nano CHL (%)'         & ANOM='DIF'   & END
            'PSC_FPICO'       : BEGIN & STAT='MEAN' & DYRANGE='0,.4'   & WYRANGE='0,.4'   & MYRANGE='0,.4'   & AYRANGE='0,.4'   & LOG=0 & TPROD='Pico CHL (%)'         & ANOM='DIF'   & END


            'DIATOM'                : BEGIN & STAT='GSTATS_MED' & DYRANGE='0,3'    & WYRANGE='0,2'    & MYRANGE='0,2'    & AYRANGE='0,1'    & LOG=1 & TPROD='Diatom Chlorophyll'    & ANOM='RATIO' & END
            'DINOFLAGELLATE'        : BEGIN & STAT='GSTATS_MED' & DYRANGE='0,3'    & WYRANGE='0,2'    & MYRANGE='0,2'    & AYRANGE='0,1'    & LOG=1 & TPROD='Dinoflagellate Chlorophyll'    & ANOM='RATIO' & END
            'NANOPICO'              : BEGIN & STAT='GSTATS_MED' & DYRANGE='0,3'    & WYRANGE='0,2'    & MYRANGE='0,2'    & AYRANGE='0,1'    & LOG=1 & TPROD='NanoPico Chlorophyll' & ANOM='RATIO' & END
            'NANO'                  : BEGIN & STAT='GSTATS_MED' & DYRANGE='0,3'    & WYRANGE='0,2'    & MYRANGE='0,2'    & AYRANGE='0,1'    & LOG=1 & TPROD='Nano Chlorophyll'     & ANOM='RATIO' & END
            'PICO'                  : BEGIN & STAT='GSTATS_MED' & DYRANGE='0,2'    & WYRANGE='0,1'    & MYRANGE='0,1'    & AYRANGE='0,1'    & LOG=1 & TPROD='Pico Chlorophyll'     & ANOM='RATIO' & END
            'DIATOM_PERCENTAGE'     : BEGIN & STAT='GSTATS_MED' & DYRANGE='0,.8'   & WYRANGE='0,.8'   & MYRANGE='O,.6'   & AYRANGE='0,.4'   & LOG=0 & TPROD='Diatom CHL (%)'       & ANOM='DIF'   & END
            'MICRO_PERCENTAGE'      : BEGIN & STAT='GSTATS_MED' & DYRANGE='0,.8'   & WYRANGE='0,.8'   & MYRANGE='O,.6'   & AYRANGE='0,.4'   & LOG=0 & TPROD='Micro CHL (%)'        & ANOM='DIF'   & END
            'NANOPICO_PERCENTAGE'   : BEGIN & STAT='GSTATS_MED' & DYRANGE='0,.8'   & WYRANGE='0,.8'   & MYRANGE='O,.8'   & AYRANGE='0,.8'   & LOG=0 & TPROD='NanoPico CHL (%)'     & ANOM='DIF'   & END
            'NANO_PERCENTAGE'       : BEGIN & STAT='GSTATS_MED' & DYRANGE='0,.8'   & WYRANGE='0,.8'   & MYRANGE='O,.8'   & AYRANGE='0,.8'   & LOG=0 & TPROD='Nano CHL (%)'         & ANOM='DIF'   & END
            'PICO_PERCENTAGE'       : BEGIN & STAT='GSTATS_MED' & DYRANGE='0,.4'   & WYRANGE='0,.4'   & MYRANGE='O,.4'   & AYRANGE='0,.4'   & LOG=0 & TPROD='Pico CHL (%)'         & ANOM='DIF'   & END
            'PAR'                   : BEGIN & STAT='AMEAN'      & DYRANGE='0,80'   & WYRANGE='0,80'   & MYRANGE='0,80'   & AYRANGE='30,40'  & LOG=0 & TPROD='PAR'                  & ANOM='DIF'   & END
            'PPD'                   : BEGIN & STAT='GSTATS_MED' & DYRANGE='0,4'    & WYRANGE='0,4'    & MYRANGE='0,4'    & AYRANGE='0,2'    & LOG=1 & TPROD='Primary Production'   & ANOM='RATIO' & END
            'MICROPP'               : BEGIN & STAT='GSTATS_MED' & DYRANGE='0,1'    & WYRANGE='0,1'    & MYRANGE='0,1'    & AYRANGE='0,0.5'  & LOG=1 & TPROD='Microplankton PP'     & ANOM='RATIO' & END
            'NANOPICOPP'            : BEGIN & STAT='GSTATS_MED' & DYRANGE='0,3'    & WYRANGE='0,3'    & MYRANGE='0,3'    & AYRANGE='0,1'    & LOG=1 & TPROD='NanoPico PP'          & ANOM='RATIO' & END
            'MICROPP_PERCENTAGE'    : BEGIN & STAT='GSTATS_MED' & DYRANGE='0,40'   & WYRANGE='0,40'   & MYRANGE='O,40'   & AYRANGE='0,40'   & LOG=0 & TPROD='Micro PP (%)'         & ANOM='DIF'   & END
            'NANOPICOPP_PERCENTAGE' : BEGIN & STAT='GSTATS_MED' & DYRANGE='0,80'   & WYRANGE='0,80'   & MYRANGE='O,80'   & AYRANGE='0,80'   & LOG=0 & TPROD='NanoPico PP (%)'      & ANOM='DIF'   & END
            'SST'                   : BEGIN & STAT='AMEAN'      & DYRANGE='-1,30'  & WYRANGE='-1,30'  & MYRANGE='-1,30'  & AYRANGE='-1,30'  & LOG=0 & TPROD='Temperature'          & ANOM='DIF'   & END
            'RRS_412'               : BEGIN & STAT='AMEAN'      & DYRANGE='0,.008' & WYRANGE='0,.006' & MYRANGE='0,.006' & AYRANGE='0,.004' & LOG=0 & TPROD='RRS 412'              & ANOM='DIF'   & END
            'RRS_443'               : BEGIN & STAT='AMEAN'      & DYRANGE='0,.008' & WYRANGE='0,.006' & MYRANGE='0,.006' & AYRANGE='0,.004' & LOG=0 & TPROD='RRS 443'              & ANOM='DIF'   & END
            'RRS_490'               : BEGIN & STAT='AMEAN'      & DYRANGE='0,.008' & WYRANGE='0,.006' & MYRANGE='0,.006' & AYRANGE='0,.004' & LOG=0 & TPROD='RRS 490'              & ANOM='DIF'   & END
            'RRS_510'               : BEGIN & STAT='AMEAN'      & DYRANGE='0,.008' & WYRANGE='0,.006' & MYRANGE='0,.005' & AYRANGE='0,.004' & LOG=0 & TPROD='RRS 510'              & ANOM='DIF'   & END
            'RRS_555'               : BEGIN & STAT='AMEAN'      & DYRANGE='0,.008' & WYRANGE='0,.006' & MYRANGE='0,.005' & AYRANGE='0,.004' & LOG=0 & TPROD='RRS 555'              & ANOM='DIF'   & END
            'RRS_670'               : BEGIN & STAT='AMEAN'      & DYRANGE='0,.002' & WYRANGE='0,.004' & MYRANGE='0,.001' & AYRANGE='0,.001' & LOG=0 & TPROD='RRS 670'              & ANOM='DIF'   & END
          ENDCASE
          
          CASE PER OF
            'D':     _YRANGE = FLOAT(STR_BREAK(DYRANGE,',')) 
            'DOY':   _YRANGE = FLOAT(STR_BREAK(MYRANGE,',')) 
            'D8':    _YRANGE = FLOAT(STR_BREAK(DYRANGE,',')) 
            'W':     _YRANGE = FLOAT(STR_BREAK(WYRANGE,',')) 
            'M':     _YRANGE = FLOAT(STR_BREAK(MYRANGE,',')) 
            'M3':    _YRANGE = FLOAT(STR_BREAK(MYRANGE,',')) 
            'MONTH': _YRANGE = FLOAT(STR_BREAK(MYRANGE,',')) 
            'A':     _YRANGE = FLOAT(STR_BREAK(AYRANGE,',')) 
          ENDCASE
          
          IF N_ELEMENTS(YRANGE) EQ 2 THEN _YRANGE = YRANGE
          IF N_ELEMENTS(YTITLE) EQ 1 THEN _YTITLE = YTITLE ELSE _YTITLE = UNITS(APROD,/NO_NAME)
          
          FOR NP=0, NPLOTS-1 DO BEGIN
            PNGFILE = PNGFILES[NP]
            IF FILE_MAKE(EFILES, PNGFILE, OVERWRITE=OVERWRITE) EQ 0 THEN CONTINUE
            NSET = PLOTSUBS[NP]   
            NPLOTS = N_ELEMENTS(NSET)
            SP = 0.03
            X1 = 0.08
            X2 = 0.96
            YS = (1.0-(SP*(NPLOTS+2)))/NPLOTS
            IF N_ELEMENTS(SETS) EQ 1 THEN Y1 = 0.1 ELSE Y1 = 1.0-SP-YS
            IF N_ELEMENTS(SETS) EQ 1 THEN Y2 = 0.9 ELSE Y2 = 1.0-SP
            IF ~N_ELEMENTS(XDIM)      THEN XDIM = 790
            IF ~N_ELEMENTS(YDIM)      THEN YDIM = 256 * N_ELEMENTS(SETS) < 256*6
                        
            IF N_ELEMENTS(NSET) EQ 1 THEN BEGIN
              W = WINDOW(DIMENSIONS=[XDIM*2,YDIM*2],BUFFER=BUFFER)
              TD = TEXT(.5,.98,TPROD+' - '+NSET.VALUE,FONT_SIZE=FONTSIZE+4,FONT_STYLE='BOLD',ALIGNMENT=0.5,VERTICAL_ALIGNMENT=1)
              X1 = 0.05
              X2 = 0.85
              Y1 = 0.2
              Y2 = 0.85
            ENDIF ELSE BEGIN  
              W = WINDOW(DIMENSIONS=[XDIM,YDIM],BUFFER=BUFFER)
              TD = TEXT(.5,.98,TPROD,FONT_SIZE=FONTSIZE+4,FONT_STYLE='BOLD',ALIGNMENT=0.5,VERTICAL_ALIGNMENT=1)
            ENDELSE
            FOR B=0, N_ELEMENTS(NSET)-1 DO BEGIN
              SET = CDATA[WHERE_SETS_SUBS(NSET[B])]
              SETCMB = SET.SENSOR+','+SET.DATA_VERSION+','+SET.FILE_TYPE+','+SET.PROD+'-'+SET.ALG+','+SET.PROD_VERSION
              OK = WHERE(SET.ALG EQ '',COUNT_NOALG)
              IF COUNT_NOALG GT 0 THEN SETCMB[OK] = REPLACE(SETCMB[OK],SET[OK].PROD+'-',SET[OK].PROD)
              CSETS = WHERE_SETS(SETCMB)
              MAXN = MAX(CSETS.N)
              CASE 1 OF
                (MAXN LE 12):                    BEGIN & THICK=3 & SYMSIZE=1.5 & END
                (MAXN GT 12) AND (MAXN LE 30):   BEGIN & THICK=2 & SYMSIZE=1 & END
                (MAXN GT 30) AND (MAXN LE 99):   BEGIN & THICK=2 & SYMSIZE=0.75 & END
                (MAXN GE 100) AND (MAXN LE 366): BEGIN & THICK=1 & SYMSIZE=0.5 & END
                (MAXN GT 366):                   BEGIN & THICK=0.5 & SYMSIZE=0.35 & END
              ENDCASE
              
              IF B GT 0 THEN Y1 = Y1 - YS - SP
              IF B GT 0 THEN Y2 = Y2 - YS - SP
              POSITION = [X1,Y1,X2,Y2]
  
              IF B EQ N_ELEMENTS(NSET)-1 THEN XTICKNAME=AX.TICKNAME ELSE XTICKNAME=XTICKNAMES
              PD = PLOT(AX.JD,_YRANGE,YTITLE=_YTITLE,FONT_SIZE=FONTSIZE,YMINOR=YMINOR,XMAJOR=AX.TICKS,XMINOR=3,XTICKNAME=XTICKNAME,XTICKVALUES=AX.TICKV,POSITION=POSITION,/NODATA,/CURRENT)
              POS = PD.POSITION
              XTICKV = PD.XTICKVALUES & OK = WHERE(JD_2MONTH(XTICKV) EQ '01',COUNT)
              FOR G=1,COUNT-1 DO GR = PLOT([XTICKV[OK[G]],XTICKV[OK[G]]],_YRANGE,COLOR='GREY',/OVERPLOT,XRANGE=AX.JD,YRANGE=_YRANGE)
              
              FOR S=0, N_ELEMENTS(CMB_NOFT)-1 DO BEGIN
                CMB_NOFT[S] = REPLACE(CMB_NOFT[S],' ,',',')
                CMB_NOFT[S] = REPLACE(CMB_NOFT[S],',INTERP,',',INTERP_SAVE,')
                AA = SET[WHERE(SETCMB EQ STRTRIM(CMB_NOFT[S],2) AND SET.MED NE MISSINGS(0.0),/NULL)]
                IF AA EQ [] THEN CONTINUE
                
                CLABEL = STRTRIM(CMB_NOFT[S],2)
                IF STRMID(CLABEL,0,1) EQ ',' THEN CLABEL = STRMID(CLABEL,1)
                IF STRPOS(CLABEL,',',/REVERSE_SEARCH) EQ STRLEN(CLABEL)-1 THEN CLABEL = STRMID(CLABEL,0,STRLEN(CLABEL)-1)
                CLABEL = REPLACE(CLABEL,',',' - ')
                CLABEL = REPLACE(CLABEL,' - - ',' - ')
                                
                SPOS = WHERE(TAG_NAMES(AA) EQ STAT,/NULL) 
                IF SPOS EQ [] THEN SPOS = WHERE(TAG_NAMES(AA) EQ 'MED',/NULL) ; If desired stat is not available, default to the median
                IF SPOS EQ [] THEN STOP
                CASE PER OF 
                  'DOY': BEGIN
                    DP = DATE_PARSE(PERIOD_2DATE(AA.PERIOD))
                    JD = DATE_2JD(YDOY_2DATE(2100,DP.IDOY))
                  END  
                  ELSE: JD = PERIOD_2JD(AA.PERIOD)
                ENDCASE
                P1 = PLOT(JD,AA.(SPOS),XRANGE=AX.JD,YRANGE=_YRANGE,/OVERPLOT,/CURRENT,LINESTYLE=0,COLOR=COLORS[S],SYMBOL='CIRCLE',SYM_SIZE=SYMSIZE, THICK=THICK,/SYM_FILLED)
                IF N_ELEMENTS(NSET) GT 1 THEN TS = TEXT(0.095,POS[3]-0.03-[0.015*S],CLABEL,FONT_COLOR=COLORS[S],FONT_SIZE=FONTSIZE+1,FONT_STYLE='BOLD') $
                                         ELSE TS = TEXT(0.86, POS[3]-0.05-[0.04*S], CLABEL,FONT_COLOR=COLORS[S],FONT_SIZE=FONTSIZE+1,FONT_STYLE='BOLD')
              ENDFOR
              IF N_ELEMENTS(NSET) GT 1 THEN TD = TEXT(.94,POS[3]-0.03,SET[0].SUBAREA,FONT_SIZE=FONTSIZE+2,FONT_STYLE='BOLD',ALIGNMENT=1) 
            ENDFOR
  
            W.SAVE, PNGFILE;, RESOLUTION=300
            W.CLOSE
            PFILE,PNGFILE
            
          ENDFOR ; NUMBER OF PLOT FILES
        ENDFOR ; COMBO
      ENDFOR ; MAPS
    ENDFOR ; PERIODS 
  ENDFOR ; SHPFILES

  
END
