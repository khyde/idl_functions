; $ID:	COMPARE_SAT_SENSORS.PRO,	2023-09-21-13,	USER-KJWH	$
PRO COMPARE_SAT_SENSORS, SENSORS, PRODS=PRODS, PERIODS=PERIODS, SHPFILES=SHPFILES, SUBAREAS=SUBAREAS, MPS=MPS, INTERP=INTERP, DATERANGE=DATERANGE, $
                         YRANGE=YRANGE, YTITLE=YTITLE, COLORS=COLORS, DIR_OUT=DIR_OUT, BUFFER=BUFFER, NC=NC
;+
; NAME
;   COMPARE_SAT_SENSORS
; 
; DESCRIPTION: 
;   To compare time series from various sensors
;
; KEYWORDS:
;   SENSORS.........The names of the different sensors to be used for data comparisons
;
; OPTIONAL KEYWORDS:
;   PRODS...........Product names
;   PERIOD..........Time period for comparisons
;   MPS.............Map of the input files
;   SHPFILES........ Name of the subarea shape file
;   SUBAREAS........ Name of subareas within the shape file to extract the data from
;   DATERANGE.......Specify the date range of the input files
;   YRANGE..........Y axis plot range
;   YTITLE..........Y axis title
;   COLORS..........Colors for the plots (defaults = ['DARK_BLUE','DARK_ORANGE','DARK_TURQUOISE','RED','SPRING_GREEN','BLUE','MAGENTA'])
;   DIR_OUT.........Output directory for the extracted data and plots
;
; OPTIONAL KEYWORDS
;   INTERP..........Set to use the interpolated data instead of the STATS
;   NC..............Keyword to check for netcf files
;   BUFFER..........Buffer for the plotting steps
;   OVERWRITE.......Overwrite the plot if it already exists
;
; OUTPUTS
;   Time series plots of the data in each subregion
;
; EXAMPLE CALLS:
;   1) COMPARE_SAT_SENSORS,
;   2) COMPARE_SAT_SENSORS, ['SEAWIFS','MODISA']
;   3) COMPARE_SAT_SENSORS, ['SEAWIFS','MODISA'], PRODS=['CHLOR_A-OCI','PAR'], MPS=['L3B2']
;   4) COMPARE_SAT_SENSORS, ['SEAWIFS','MODISA'], PRODS=['CHLOR_A-OCI','PAR'], MPS=['L3B2'], SHPFILES='NES_EPU_NOESTUARIES'
;   5) COMPARE_SAT_SENSORS, ['SEAWIFS','MODISA'], PRODS=['CHLOR_A-OCI','PAR'], MPS=['L3B2'], SHPFILES='NES_EPU_NOESTUARIES', DATERANGE=['2002','2012']
;   6) COMPARE_SAT_SENSORS, ['OCCCI','OCCCI'],PRODS='CHLOR_A-CCI', MPS=['L3B4','L3B2'], PERIODS='M'
;
; NOTES:
; Copyright (C) 2018, Department of Commerce, National Oceanic and Atmospheric Administration, National Marine Fisheries Service,
;   Northeast Fisheries Science Center, Narragansett Laboratory.
;   This software may be used, copied, or redistributed as long as it is not sold and this copyright notice is reproduced on each copy made.
;   This routine is provided AS IS without any express or implied warranties whatsoever.
;
;   This program was written by Kimberly Hyde, DOC/NOAA/NMFS/NEFSC Narragansett, RI, kimberly.hyde@noaa.gov.
;
;
; MODIFICATION HISTORY:
;   Aug 15, 2018 by Kimberly Hyde, NOAA/NEFSC/Narragansett Laboratory, 28 Tarzwell Drive, 02882
;   Oct 19, 2018 - KJWH: Updated how the dimensions were calculated (now based on the number of subareas and not the number of sensors)
;                        Changed program name from COMPARE_SAT_DATA to COMPARE_SAT_SENSORS
;                        Changed plot directory to SENSOR_PLOTS 
;   Oct 22, 2018 - KJWH: Added an optional DIR_OUT keyword
;                        Added a DSUBS directory for the individual files from SUBAREAS_EXTRACT
;                        Now saving the merged data file
;   Nov 05, 2018 - KJWH: Added IF N_ELEMENTS(DATERANGE) EQ 1 THEN AXRANGE = [STRMID(DATERANGE,0,4)+'0101',STRMID(DATERANGE,0,4)+'1231'] to generate the full daterange for a given year                     
;                        Changed DSUBS directory to !S.EXTRACTS        
;   Dec 14, 2018 - KJWH: Added the BUFFER keyword       
;   Mar 01, 2019 - KJWH: Changed output name to be based on just the years and not the complete daterange                                
;   Jan 28, 2020 - KJWH: Updated the STAT used to plot the data - added information to the CASE PROD OF block
;   Jan 29, 2020 - KJWH: Fixed bug for when files were not found for a specific product and sensor    
;                        Defaulting to the "median" STAT if the requeste stat is not available (e.g. GSTATS_MED will not be calculated in SUBAREAS_EXTRACT for daily/non-stat files)   
;                        Added CHL, PAR and RRS "NPRODS" to the CASE PROD OF block 
;   Sep 01, 2020 - KJWH: Updated documentation
;                        Added COMPILE_OPT IDL2
;                        Changed subscript () to []
;                        Updated YRANGE for the MICRO, NANO, PICO and NANOPICO products
;                        Added COLORS, YRANGE and YTITLE keywords
;                        Now works with multiple MAPS
;   Dec 02, 2021 - KJWH: Changed SUBAREAS input parameter to SHPFILES to reflect that the input is actually the shape file name
;                        They input parameter SUBAREAS is now fed to SUBAREAS_EXTRACT to indicate the SUBAREAS within the shape file to extract
      
;-
;****************************************
  ROUTINE_NAME = 'COMPARE_SAT_SENSORS'
  COMPILE_OPT IDL2
  DASH=DELIMITER(/DASH)
  SL=PATH_SEP()

  IF ~N_ELEMENTS(DIR_OUT) THEN DIR = !S.COMPARE_SAT_DATA  ELSE DIR = DIR_OUT
  ;DSUBS = !S.SUBAREA_EXTRACTS                     ; Directory for the individual extracted data files
  DDATA = DIR + 'DATA' + SL                       ; Directory for the merged data
  DPLOT = DIR + 'SENSOR_PLOTS' + SL               ; Directory for the plots
  DIR_TEST, [DDATA,DPLOT]
  DP = DATE_PARSE(DATE_NOW())

  IF ~N_ELEMENTS(SENSORS)   THEN SENSORS   = ['SEAWIFS','MODISA','VIIRS','OCCCI']
  IF ~N_ELEMENTS(PERIODS)   THEN PERIODS   = 'M'
  IF ~N_ELEMENTS(PRODS)     THEN PRODS     = 'CHLOR_A-OCI'
  IF ~N_ELEMENTS(SHPFILES)  THEN SHPFILES  = 'NES_EPU_NOESTUARIES'
  IF ~N_ELEMENTS(MPS)       THEN MPS       = 'L3B2' & IF N_ELEMENTS(MPS) EQ 1 THEN MPS = REPLICATE(MPS,N_ELEMENTS(SENSORS))
  IF ~N_ELEMENTS(DATERANGE) THEN DATERANGE = ['1997',DP.YEAR] ELSE DATERANGE = GET_DATERANGE(DATERANGE)
  IF KEYWORD_SET(INTERP)    THEN FILE_TYPE = 'INTERP_SAVE' ELSE FILE_TYPE=[]
  IF ~N_ELEMENTS(BUFFER)    THEN BUFFER    = 0
  IF ~N_ELEMENTS(NC)        THEN EXT       = '.SAV' ELSE EXT = '.nc'
  IF ~N_ELEMENTS(COLORS)    THEN COLORS    = ['DARK_BLUE','DARK_ORANGE','DARK_TURQUOISE','RED','SPRING_GREEN','BLUE','MAGENTA']
  
  IF N_ELEMENTS(MPS) NE N_ELEMENTS(SENSORS) THEN MESSAGE, 'ERROR: Number of "MAPS" must equal the number of "SENSORS"'
  
  IF N_ELEMENTS(DATERANGE) EQ 1 THEN AXRANGE = [STRMID(DATERANGE,0,4)+'0101',STRMID(DATERANGE,0,4)+'1231'] ELSE AXRANGE=DATERANGE
  YEARS = YEAR_RANGE(STRMID(DATERANGE[0],0,4),STRMID(DATERANGE[1],0,4))
  DATES = CREATE_DATE(DATERANGE[0],DATERANGE[1]) & IF N_ELEMENTS(DATES) LE 366 THEN YEARS = []
  X  = DATE_2JD(AXRANGE) 
  IF YEARS NE [] THEN BEGIN
    CASE 1 OF
      N_ELEMENTS(YEARS) EQ 1: AX  = DATE_AXIS(X,/MONTH, /YY_YEAR,STEP_SIZE=2)
      N_ELEMENTS(YEARS) EQ 2: AX  = DATE_AXIS(X,/MONTH, /YY_YEAR,STEP_SIZE=3)
      N_ELEMENTS(YEARS) EQ 3: AX  = DATE_AXIS(X,/MONTH, /YY_YEAR,STEP_SIZE=4)
      N_ELEMENTS(YEARS) GT 3 AND N_ELEMENTS(YEARS) LT 6: AX  = DATE_AXIS(X,/MONTH, /YY_YEAR,STEP_SIZE=6)
      N_ELEMENTS(YEARS) GE 6: AX  = DATE_AXIS(X,/MONTH, /YY_YEAR,STEP_SIZE=12) 
    ENDCASE
  ENDIF ELSE BEGIN
    CASE 1 OF
      N_ELEMENTS(DATES) LT 32: AX = DATE_AXIS(X,/DAY, /YY_YEAR,STEP_SIZE=5)
      N_ELEMENTS(DATES) GE 32 AND N_ELEMENTS(DATES) LT 64: AX = DATE_AXIS(X,/DAY, /YY_YEAR,STEP_SIZE=10)
      N_ELEMENTS(DATES) GE 64 AND N_ELEMENTS(DATES) LT 121: AX = DATE_AXIS(X,/DAY, /YY_YEAR,STEP_SIZE=20)
      N_ELEMENTS(DATES) GE 121 AND N_ELEMENTS(DATES) LT 182: AX = DATE_AXIS(X,/WEEK, /YY_YEAR,STEP_SIZE=2)
      N_ELEMENTS(DATES) GE 182 AND N_ELEMENTS(DATES) LT 366: AX = DATE_AXIS(X,/MONTH, /YY_YEAR,STEP_SIZE=1)
    ENDCASE
  ENDELSE
  
  XTICKNAMES = REPLICATE(' ',N_ELEMENTS(AX.TICKNAME))
  YMINOR=1
  FONTSIZE = 8.5
  SYMSIZE = 0.45
  THICK = 2
  FONT = 0
  YMARGIN = [0.3,0.3]
  XMARGIN = [4,1]
  
  FOR N=0, N_ELEMENTS(SHPFILES)-1 DO BEGIN
    SHPFILE = SHPFILES[N]
    SNAME = SHPFILE
;    SHPFILE = !S.IDL_SHAPEFILES + 'SHAPES' + SL + SUBAREA + SL + SUBAREA + '.shp'
;    IF ~FILE_TEST(SHPFILE) THEN CONTINUE

    FOR P=0, N_ELEMENTS(PRODS)-1 DO BEGIN
      APROD = PRODS[P]
      NPROD = []
      CASE VALIDS('PRODS',APROD) OF
        'CHLOR_A'               : BEGIN & STAT='GSTATS_MED' & DYRANGE='0,10'   & WYRANGE='0,3'    & MYRANGE='0,3'    & AYRANGE='0,2'    & LOG=1 & TPROD='Chlorophyll'          & ANOM='RATIO' & NPROD='CHLOR_A-OCI' & END
        'MICRO'                 : BEGIN & STAT='GSTATS_MED' & DYRANGE='0,.5'   & WYRANGE='0,.3'   & MYRANGE='0,.3'   & AYRANGE='0,.2'   & LOG=1 & TPROD='Micro Chlorophyll'    & ANOM='RATIO' & END
        'NANOPICO'              : BEGIN & STAT='GSTATS_MED' & DYRANGE='0,8'    & WYRANGE='0,3'    & MYRANGE='0,3'    & AYRANGE='0,2'    & LOG=1 & TPROD='NanoPico Chlorophyll' & ANOM='RATIO' & END
        'NANO'                  : BEGIN & STAT='GSTATS_MED' & DYRANGE='0,8'    & WYRANGE='0,3'    & MYRANGE='0,3'    & AYRANGE='0,2'    & LOG=1 & TPROD='Nano Chlorophyll'     & ANOM='RATIO' & END
        'PICO'                  : BEGIN & STAT='GSTATS_MED' & DYRANGE='0,2'    & WYRANGE='0,1'    & MYRANGE='0,3'    & AYRANGE='0,2'    & LOG=1 & TPROD='Pico Chlorophyll'     & ANOM='RATIO' & END
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
        'RRS_412'               : BEGIN & STAT='AMEAN'      & DYRANGE='0,.008' & WYRANGE='0,.006' & MYRANGE='0,.006' & AYRANGE='0,.004' & LOG=0 & TPROD='RRS 412'              & ANOM='DIF'   & NPROD='RRS_412' & END
        'RRS_443'               : BEGIN & STAT='AMEAN'      & DYRANGE='0,.008' & WYRANGE='0,.006' & MYRANGE='0,.006' & AYRANGE='0,.004' & LOG=0 & TPROD='RRS 443'              & ANOM='DIF'   & NPROD='RRS_443' & END
        'RRS_490'               : BEGIN & STAT='AMEAN'      & DYRANGE='0,.008' & WYRANGE='0,.006' & MYRANGE='0,.006' & AYRANGE='0,.004' & LOG=0 & TPROD='RRS 490'              & ANOM='DIF'   & NPROD='RRS_490' & END
        'RRS_510'               : BEGIN & STAT='AMEAN'      & DYRANGE='0,.008' & WYRANGE='0,.006' & MYRANGE='0,.005' & AYRANGE='0,.004' & LOG=0 & TPROD='RRS 510'              & ANOM='DIF'   & NPROD='RRS_510' & END
        'RRS_555'               : BEGIN & STAT='AMEAN'      & DYRANGE='0,.008' & WYRANGE='0,.006' & MYRANGE='0,.005' & AYRANGE='0,.004' & LOG=0 & TPROD='RRS 555'              & ANOM='DIF'   & NPROD='RRS_555' & END
        'RRS_670'               : BEGIN & STAT='AMEAN'      & DYRANGE='0,.002' & WYRANGE='0,.004' & MYRANGE='0,.001' & AYRANGE='0,.001' & LOG=0 & TPROD='RRS 670'              & ANOM='DIF'   & NPROD='RRS_670' & END
      ENDCASE
      
      FOR R=0, N_ELEMENTS(PERIODS)-1 DO BEGIN
        PER = PERIODS[R]
        
        CASE PER OF
          'D':   BEGIN & _YRANGE = FLOAT(STR_BREAK(DYRANGE,',')) & PLABEL = 'DAILY'    & END
          'DOY': BEGIN & _YRANGE = FLOAT(STR_BREAK(DYRANGE,',')) & PLABEL = 'DOY'      & END
          'D8':  BEGIN & _YRANGE = FLOAT(STR_BREAK(DYRANGE,',')) & PLABEL = '8-DAY'    & END
          'W':   BEGIN & _YRANGE = FLOAT(STR_BREAK(WYRANGE,',')) & PLABEL = 'WEEKLY'   & END
          'M':   BEGIN & _YRANGE = FLOAT(STR_BREAK(MYRANGE,',')) & PLABEL = 'MONTHLY'  & END
          'M3':  BEGIN & _YRANGE = FLOAT(STR_BREAK(MYRANGE,',')) & PLABEL = 'SEASONAL' & END
          'A':   BEGIN & _YRANGE = FLOAT(STR_BREAK(AYRANGE,',')) & PLABEL = 'YEARLY'   & END
        ENDCASE

        EFILES = []
        CDATA  = []
        MSUBS  = []
        FOR S=0, N_ELEMENTS(SENSORS)-1 DO BEGIN
          ASEN = SENSORS[S]
          AMAP=MPS[S]
          IF HAS(APROD,'RRS') THEN SPROD = RRS_SWAP(RRS=APROD,SENSOR_IN='SEAWIFS',SENSOR_OUT=SENSORS[S]) ELSE SPROD = APROD

          FILES = GET_FILES(ASEN,PERIODS=PER,PRODS=SPROD,DATERANGE=DATERANGE,MAPS=AMAP,FILE_TYPE=FILE_TYPE,COUNT=COUNTF)
          IF COUNTF EQ 0 THEN BEGIN
            MSUBS = [MSUBS,S]
            CONTINUE
          ENDIF  
          SAVEFILE = PLABEL + '-' + ASEN + '-' + AMAP + '-' + APROD + '-' + SNAME + '.SAV'
          SUBAREAS_EXTRACT, FILES, SHP_NAME=SHPFILE,SUBAREAS=SUBAREAS,NC_PROD=NPROD,DIR_OUT=DDIR,SAVEFILE=SAVEFILE,INIT=INIT,VERBOSE=VERBOSE
          EFILES = [EFILES,SAVEFILE]
          IF S EQ 0 THEN CDATA = STRUCT_READ(SAVEFILE) ELSE CDATA = STRUCT_CONCAT(CDATA,STRUCT_READ(SAVEFILE))
        ENDFOR ; SENSORS
            
        IF EFILES EQ [] THEN BEGIN
          PRINT, 'No files found for ' + STRJOIN(SENSORS,' & ') + ' for ' + PER + '*' + APROD + '*'
          CONTINUE
        ENDIF
        IF MSUBS NE [] THEN SENSORS = REMOVE(SENSORS,MSUBS)
         
        IF N_ELEMENTS(SENSORS) GT 1 THEN SPLABEL = STRJOIN(SENSORS,'_') + '-' + APROD ELSE SPLABEL = SENSORS + '-' + APROD
        
        DATFILE = DDATA + PER + '_' + STRJOIN(DATE_2YEAR(DATERANGE),'_') + '-' + AMAP + '-' + SPLABEL + '-' + SNAME + '.SAV'
        IF FILE_MAKE(EFILES,DATFILE,OVERWRITE=OVERWRITE) EQ 1 THEN BEGIN
          SAVE, CDATA, FILENAME=DATFILE ; ===> SAVE THE MERGED DATAFILE
          SAVE_2CSV, DATFILE
        ENDIF
        
        IF N_ELEMENTS(YEARS) EQ 1 OR YEARS EQ [] THEN BEGIN
          IF YEARS EQ [] THEN PNGFILE = DPLOT + PER + '_' + STRJOIN(DATERANGE,'_') + '-' + AMAP + '-' + SPLABEL + '-' + SNAME + '.PNG' $
                         ELSE PNGFILE = DPLOT + PER + '_' + DATE_2YEAR(DATERANGE) + '-' + AMAP + '-' + SPLABEL + '-' + SNAME + '.PNG'
        ENDIF ELSE PNGFILE = DPLOT + PER + '_' + STRJOIN(DATE_2YEAR(DATERANGE),'_') + '-' + AMAP + '-' + SPLABEL + '-' + SNAME + '.PNG'
        IF FILE_MAKE(EFILES,PNGFILE,OVERWRITE=OVERWRITE) EQ 0 THEN CONTINUE
        SETS = WHERE_SETS(CDATA.SUBAREA)
                 
        NPLOTS = N_ELEMENTS(SETS)
        SP = 0.03
        X1 = 0.08
        X2 = 0.96
        YS = (1.0-(SP*(NPLOTS+2)))/NPLOTS
        Y1 = 1.0-SP-YS
        Y2 = 1.0-SP
        IF NONE(XDIM)      THEN XDIM      = 790
        IF NONE(YDIM)      THEN YDIM      = 256 * N_ELEMENTS(SETS) < 256*6
        
        IF N_ELEMENTS(YRANGE) EQ 2 THEN _YRANGE = YRANGE
        IF N_ELEMENTS(YTITLE) EQ 1 THEN _YTITLE = YTITLE ELSE _YTITLE = UNITS(APROD,/NO_NAME)

        
        W = WINDOW(DIMENSIONS=[XDIM,YDIM],BUFFER=BUFFER)
        TD = TEXT(.5,.98,TPROD,FONT_SIZE=FONTSIZE+4,FONT_STYLE='BOLD',ALIGNMENT=0.5)
        FOR B=0, N_ELEMENTS(SETS)-1 DO BEGIN
          SET = CDATA[WHERE_SETS_SUBS(SETS[B])]
          IF B GT 0 THEN Y1 = Y1 - YS - SP
          IF B GT 0 THEN Y2 = Y2 - YS - SP
          POSITION = [X1,Y1,X2,Y2]

          IF B EQ N_ELEMENTS(SETS)-1 THEN XTICKNAME=AX.TICKNAME ELSE XTICKNAME=XTICKNAMES
          PD = PLOT(AX.JD,_YRANGE,YTITLE=UNITS(APROD,/NO_NAME),FONT_SIZE=FONTSIZE,YMINOR=YMINOR,XMAJOR=AX.TICKS,XMINOR=3,XTICKNAME=XTICKNAME,XTICKVALUES=AX.TICKV,POSITION=POSITION,/NODATA,/CURRENT)
          POS = PD.POSITION
          XTICKV = PD.XTICKVALUES & OK = WHERE(JD_2MONTH(XTICKV) EQ '01',COUNT)
          FOR G=1,COUNT-1 DO GR = PLOT([XTICKV[OK[G]],XTICKV[OK[G]]],_YRANGE,COLOR='GREY',/OVERPLOT,XRANGE=AX.JD,YRANGE=YRANGE)
          
          FOR S=0, N_ELEMENTS(SENSORS)-1 DO BEGIN
            AA = SET[WHERE(SET.SENSOR EQ SENSORS[S] AND SET.MAP EQ MPS[S] AND SET.MED NE MISSINGS(0.0),/NULL)]
            IF AA EQ [] THEN CONTINUE 
            SPOS = WHERE(TAG_NAMES(AA) EQ STAT,/NULL)
            IF SPOS EQ [] THEN SPOS = WHERE(TAG_NAMES(AA) EQ 'MED',/NULL) ; If desired stat is not available, default to the median 
            IF SPOS EQ [] THEN STOP
            P1 = PLOT(PERIOD_2JD(AA.PERIOD),AA.(SPOS),XRANGE=AX.JD,YRANGE=_YRANGE,/OVERPLOT,/CURRENT,LINESTYLE=0,COLOR=COLORS[S],SYMBOL='CIRCLE',SYM_SIZE=0.25,/SYM_FILLED)
            TS = TEXT(0.095,POS[3]-0.03-(0.015*S),SENSORS[S],FONT_COLOR=COLORS[S],FONT_SIZE=FONTSIZE+2,FONT_STYLE='BOLD')
          ENDFOR ; SENSORS
          TD = TEXT(.94,POS[3]-0.03,SET[0].SUBAREA,FONT_SIZE=FONTSIZE+2,FONT_STYLE='BOLD',ALIGNMENT=1)
        ENDFOR

        W.SAVE, PNGFILE;, RESOLUTION=300
        W.CLOSE
        PFILE, PNGFILE, /W

      ENDFOR ; PERIODS (SETS)
    ENDFOR ; SENSORS
  ENDFOR ; SHPFILES
  
END
