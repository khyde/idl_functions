; $ID:	COMPARE_STACKED_STAT_EXTRACTS.PRO,	2023-09-21-13,	USER-KJWH	$
  PRO COMPARE_STACKED_STAT_EXTRACTS, PRODS, SENSORS=SENSORS, PERIODS=PERIODS, SHPFILES=SHPFILES, SUBAREAS=SUBAREAS, MPS=MPS, YRANGE=YRANGE, YTITLE=YTITLE, $
                                     PLTPROD=PLTPROD, COLORS=COLORS, DATERANGE=DATERANGE, DIR_OUT=DIR_OUT, VERSION=VERSION, INTERP=INTERP, ADD_XYPLOT=ADD_XYPLOT, BUFFER=BUFFER, OVERWRITE=OVERWRITE

;+
; NAME:
;   COMPARE_STACKED_STAT_EXTRACTS
;
; PURPOSE:
;   This program will compare the extracted stats from the old STATS_ARRAYS outputs to the new (2022) STACKED_STATS outputs
;
; CATEGORY:
;   GRAPHICS_FUNCTIONS
;
; CALLING SEQUENCE:
;   COMPARE_STACKED_STAT_EXTRACTS, PRODS
;
; REQUIRED INPUTS:
;   PRODS........... The names of the different products to be used for data comparisons
;
; OPTIONAL INPUTS:
;   SENSORS......... Sensor names
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
;
; KEYWORD PARAMETERS:
;   ADD_XYPLOT..... If set, add an XY plot of the two datasets
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
;   This program was written on November 22, 2022 by Kimberly J. W. Hyde, Northeast Fisheries Science Center | NOAA Fisheries | U.S. Department of Commerce, 28 Tarzwell Dr, Narragansett, RI 02882
;    
; MODIFICATION HISTORY:
;   Nov 22, 2022 - KJWH: Initial code written - based on COMPARE_SAT_PRODS
;-
; ****************************************************************************************************
  ROUTINE_NAME = 'COMPARE_STACKED_STAT_EXTRACTS'
  COMPILE_OPT IDL2
  SL = PATH_SEP()

  IF ~N_ELEMENTS(DIR_OUT) THEN DIR = !S.COMPARE_SAT_DATA +'STACKED_COMPARED' + SL ELSE DIR = DIR_OUT & DIR_TEST, DIR
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

  IF ~N_ELEMENTS(PRODS)        THEN PRODS        = ['CHLOR_A-CCI']
  IF ~N_ELEMENTS(SENSORS)      THEN SENSORS      = ['OCCCI']
  IF ~N_ELEMENTS(PERIODS)      THEN PERIODS      = 'M'
  IF ~N_ELEMENTS(SHPFILES)     THEN SHPFILES     = 'NES_EPU_NOESTUARIES'
  IF ~N_ELEMENTS(MPS)          THEN MPS          = 'L3B4'
  IF ~N_ELEMENTS(BUFFER)       THEN BUFFER       = 0
  IF ~N_ELEMENTS(VERSION)      THEN VERSION      = ' '

  FOR N=0, N_ELEMENTS(SHPFILES)-1 DO BEGIN
    SHPFILE = SHPFILES[N]

    FOR S=0, N_ELEMENTS(SENSORS)-1 DO BEGIN
      ASEN = SENSORS[S]
      
      IF ~N_ELEMENTS(DATERANGE) THEN DR = GET_DATERANGE(SENSOR_DATES(ASEN)) ELSE DR = GET_DATERANGE(DATERANGE)
      
      FOR R=0, N_ELEMENTS(PERIODS)-1 DO BEGIN
        PER = PERIODS[R]
        STYPE = 'STATS'
        ; ===> Get the stacked period (SPER) and the output period label
        CASE PER OF
          'D':     BEGIN & SPER = 'DD'    & PLABEL = 'DAILY'  & STYPE='SAVE'  & IF KEYWORD_SET(INTERP) THEN STYPE='INTERP'  & END
          'DOY':   BEGIN & SPER = 'DOY'   & PLABEL = 'DOY'                 & END
          'D8':    BEGIN & SPER = 'DD8'   & PLABEL = '8-DAY'               & END
          'W':     BEGIN & SPER = 'WW'    & PLABEL = 'WEEKLY'              & END
          'M':     BEGIN & SPER = 'MM'    & PLABEL = 'MONTHLY'             & END
          'MONTH': BEGIN & SPER = 'MONTH' & PLABEL = 'MONTHLY_CLIMATOLOGY' & END
          'M3':    BEGIN & SPER = 'MM3'   & PLABEL = 'SEASONAL'            & END
          'A':     BEGIN & SPER = 'AA'    & PLABEL = 'YEARLY'              & END
        ENDCASE
        
        ; ===> Set the X axis range (adjusted to a "future year" for the climatological periods)
        CASE PER OF
          'DOY': BEGIN
            AXRANGE = ['21000101','21001231']
            X = DATE_2JD(AXRANGE) & AX = DATE_AXIS(X,/FYEAR,STEP_SIZE=2)
          END
          'MONTH': BEGIN
            AXRANGE = ['21000101','21001231']
            X = DATE_2JD(AXRANGE) & AX = DATE_AXIS(X,/FYEAR,STEP_SIZE=2)
          END
          ELSE: BEGIN
            AXRANGE = [STRMID(DR[0],0,4)+'0101',STRMID(DR[1],0,4)+'1231']
            X  = DATE_2JD(AXRANGE) & AX  = DATE_AXIS(X,/MONTH, /YY_YEAR,STEP_SIZE=12) & AYR = DATE_AXIS(X,/YEAR)
          END
        ENDCASE
        XTICKNAMES = REPLICATE(' ',N_ELEMENTS(AX.TICKNAME))
  
        FOR M=0, N_ELEMENTS(MPS)-1 DO BEGIN
          AMAP = MPS[M]
          EFILES = []
          CDATA  = []
                  
          FOR I=0, N_ELEMENTS(PRODS)-1 DO BEGIN
            APROD = PRODS[I]
            
            FILES = GET_FILES(SENSORS, PERIODS=SPER, PRODS=APROD, DATERANGE=DR, MAPS=AMAP, FILE_TYPE='STACKED_'+STYPE, VERSION=AVER, PROD_VERSION=APVER, COUNT=COUNTF)
            IF COUNTF EQ 0 THEN CONTINUE
            
            SAVEFILE = PLABEL + '-' + ASEN + '-' + AVER + '-' + AMAP + '-' + APROD + '-' + APVER + '-' + SHPFILE + '-STACKED_'+ STYPE + '.SAV'
            SAVEFILE = REPLACE(SAVEFILE,'--','-')
            SUBAREAS_EXTRACT, FILES, SHP_NAME=SHPFILE,SUBAREAS=SUBAREAS,SV_PROD=VALIDS('PRODS',APROD),DIR_OUT=DIR,SAVEFILE=SAVEFILE,INIT=INIT,VERBOSE=VERBOSE
            EFILES = [EFILES,SAVEFILE]
            SDATA = STRUCT_READ(SAVEFILE)
            SDATA = STRUCT_MERGE(REPLICATE(CREATE_STRUCT('FILE_TYPE','STACKED'),N_ELEMENTS(SDATA)),SDATA)
            IF CDATA EQ [] THEN CDATA = SDATA ELSE CDATA = STRUCT_CONCAT(CDATA,SDATA)
            
            FILES = GET_FILES(SENSORS, PERIODS=PER, PRODS=APROD, DATERANGE=DR, MAPS=AMAP, FILE_TYPE=STYPE, VERSION=AVER, PROD_VERSION=APVER, COUNT=COUNTF)
            IF COUNTF EQ 0 THEN CONTINUE

            SAVEFILE = PLABEL + '-' + ASEN + '-' + AVER + '-' + AMAP + '-' + APROD + '-' + APVER + '-' + SHPFILE + '-' + STYPE +'.SAV'
            SAVEFILE = REPLACE(SAVEFILE,'--','-')
            SUBAREAS_EXTRACT, FILES, SHP_NAME=SHPFILE,SUBAREAS=SUBAREAS,SV_PROD=VALIDS('PRODS',APROD),DIR_OUT=DIR,SAVEFILE=SAVEFILE,INIT=INIT,VERBOSE=VERBOSE
            EFILES = [EFILES,SAVEFILE]
            SDATA = STRUCT_READ(SAVEFILE)
            SDATA = STRUCT_MERGE(REPLICATE(CREATE_STRUCT('FILE_TYPE','SAVE'),N_ELEMENTS(SDATA)),SDATA)
            CDATA = STRUCT_CONCAT(CDATA,SDATA)
            
          ENDFOR ; PRODS
          
          IF EFILES EQ [] THEN BEGIN
            PRINT, 'No files found for ' + STRJOIN(SENSORS,' & ') + ' for ' + PER + '*' + APROD + '*'
            CONTINUE
          ENDIF

          SPLABEL = ASEN + '-' + APROD
          DATFILE = DDATA + PER + '_' + STRJOIN(DR,'_') + '-' + MPS[M] + '-' + SPLABEL + '-' + SHPFILE + '-STACKED_' + STYPE + '_COMPARE.SAV'
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
            IF N_ELEMENTS(PRODS) EQ 1 THEN APROD = PRODS[0] ELSE MESSAGE, 'ERROR: Must input a single PROD for COMBO plots.'
          ENDIF ELSE IF N_ELEMENTS(PLTPROD) EQ 1 THEN APROD = PLTPROD ELSE APROD = PRDS[0]
          
          XLOG=0 & YLOG=0
          CASE VALIDS('PRODS',APROD) OF
            'CHLOR_A'               : BEGIN & STAT='MED' & DYRANGE='0,5'   & WYRANGE='0,3'    & MYRANGE='0,3'    & AYRANGE='0,2'    & LOG=1 & TPROD='Chlorophyll'          & ANOM='RATIO' & XLOG=1 & YLOG=1 & END
            'PSC_MICRO'                 : BEGIN & STAT='MED' & DYRANGE='0,3'    & WYRANGE='0,2'    & MYRANGE='0,2'    & AYRANGE='0,1'    & LOG=1 & TPROD='Micro Chlorophyll'    & ANOM='RATIO' & END

            'MICRO'                 : BEGIN & STAT='GSTATS_MED' & DYRANGE='0,3'    & WYRANGE='0,2'    & MYRANGE='0,2'    & AYRANGE='0,1'    & LOG=1 & TPROD='Micro Chlorophyll'    & ANOM='RATIO' & END
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
            'DOY':   _YRANGE = FLOAT(STR_BREAK(DYRANGE,','))
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

            IF KEYWORD_SET(ADD_XYPLOT) THEN BEGIN
              XDIM = XDIM*1.3
              X2 = 0.7
              X3 = 0.75
              X4 = X3 + (Y2-Y1)
            ENDIF


            IF N_ELEMENTS(NSET) EQ 1 THEN BEGIN
              W = WINDOW(DIMENSIONS=[XDIM*2,YDIM*2],BUFFER=BUFFER)
              TD = TEXT(.5,.99,TPROD+' - '+NSET.VALUE,FONT_SIZE=FONTSIZE+4,FONT_STYLE='BOLD',ALIGNMENT=0.5,VERTICAL_ALIGNMENT=1)
              X1 = 0.05
              X2 = 0.85
              Y1 = 0.2
              Y2 = 0.85
            ENDIF ELSE BEGIN
              W = WINDOW(DIMENSIONS=[XDIM,YDIM],BUFFER=BUFFER)
              TD = TEXT(.5,.99,TPROD,FONT_SIZE=FONTSIZE+4,FONT_STYLE='BOLD',ALIGNMENT=0.5,VERTICAL_ALIGNMENT=1)
            ENDELSE
            FOR B=0, N_ELEMENTS(NSET)-1 DO BEGIN
              SET = CDATA[WHERE_SETS_SUBS(NSET[B])]
              CSETS = WHERE_SETS(SET.FILE_TYPE)
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
              IF KEYWORD_SET(ADD_XYPLOT) THEN XYPOS = [X3,Y1,X4,Y2]

              IF B EQ N_ELEMENTS(SETS)-1 THEN XTICKNAME=AX.TICKNAME ELSE XTICKNAME=XTICKNAMES
              PD = PLOT(AX.JD,_YRANGE,YTITLE=_YTITLE,FONT_SIZE=FONTSIZE,YMINOR=YMINOR,XMAJOR=AX.TICKS,XMINOR=3,XTICKNAME=XTICKNAME,XTICKVALUES=AX.TICKV,POSITION=POSITION,/NODATA,/CURRENT)
              FPOS = PD.POSITION
              XTICKV = PD.XTICKVALUES & OK = WHERE(JD_2MONTH(XTICKV) EQ '01',COUNT)
              FOR G=1,COUNT-1 DO GR = PLOT([XTICKV[OK[G]],XTICKV[OK[G]]],_YRANGE,COLOR='GREY',/OVERPLOT,XRANGE=AX.JD,YRANGE=_YRANGE)

              FOR S=0, N_ELEMENTS(CSETS)-1 DO BEGIN
                AA = SET[WHERE_SETS_SUBS(CSETS[S])]
                
                CLABEL = CSETS[S].VALUE
                IF STRMID(CLABEL,0,1) EQ ',' THEN CLABEL = STRMID(CLABEL,1)
                IF STRPOS(CLABEL,',',/REVERSE_SEARCH) EQ STRLEN(CLABEL)-1 THEN CLABEL = STRMID(CLABEL,0,STRLEN(CLABEL)-1)
                CLABEL = REPLACE(CLABEL,',',' - ')

                ATAGS = TAG_NAMES(AA)
                SPOS = WHERE(ATAGS EQ STAT,/NULL)
                IF SPOS EQ [] THEN SPOS = WHERE(TAG_NAMES(AA) EQ 'MED',/NULL) ; If desired stat is not available, default to the median
                IF SPOS EQ [] THEN STOP
                AA = AA[WHERE(AA.(SPOS) NE MISSINGS(AA.(SPOS)),/NULL)]
                IF AA EQ [] THEN CONTINUE
                CASE PER OF
                  'DOY': BEGIN
                    DP = DATE_PARSE(PERIOD_2DATE(AA.PERIOD))
                    JD = DATE_2JD(YDOY_2DATE(2100,DP.IDOY))
                  END
                  ELSE: JD = PERIOD_2JD(AA.PERIOD)
                ENDCASE

                ASTR = STRUCT_COPY(AA,[WHERE(ATAGS EQ 'PERIOD'),SPOS])
                ASTR = STRUCT_RENAME(ASTR,ATAGS[SPOS],AA[0].FILE_TYPE)
                IF S EQ 0 THEN AASTR = ASTR ELSE AASTR = STRUCT_JOIN(AASTR,ASTR,TAGNAMES='PERIOD')
                IF S EQ 0 THEN SYM_FILLED=1 ELSE SYM_FILLED=0
                P1 = PLOT(JD,AA.(SPOS),XRANGE=AX.JD,YRANGE=_YRANGE,/OVERPLOT,/CURRENT,LINESTYLE=0,COLOR=COLORS[S],SYMBOL='CIRCLE',SYM_SIZE=SYMSIZE, THICK=THICK,SYM_FILLED=SYM_FILLED)
                IF N_ELEMENTS(NSET) GT 1 THEN TS = TEXT(0.095,FPOS[3]-0.03-[0.015*S],CLABEL,FONT_COLOR=COLORS[S],FONT_SIZE=FONTSIZE+1,FONT_STYLE='BOLD') $
                ELSE TS = TEXT(0.86, FPOS[3]-0.05-[0.04*S], CLABEL,FONT_COLOR=COLORS[S],FONT_SIZE=FONTSIZE+1,FONT_STYLE='BOLD')
              ENDFOR
              IF N_ELEMENTS(NSET) GT 1 THEN TD = TEXT(FPOS[2]-.02,FPOS[3]-0.03,SET[0].SUBAREA,FONT_SIZE=FONTSIZE+2,FONT_STYLE='BOLD',ALIGNMENT=1)
            
              IF KEYWORD_SET(ADD_XYPLOT) THEN BEGIN
                OK = WHERE(AASTR.STACKED_STATS NE MISSINGS(AASTR.STACKED_STATS) AND AASTR.STATS_ARRAYS NE MISSINGS(AASTR.STATS_ARRAYS),/NULL)
                IF OK NE [] THEN PLT_XY, AASTR[OK].STATS_ARRAYS, AASTR[OK].STACKED_STATS, POSITION=XYPOS, AXES_FONT_SIZE=FONTSIZE, XRANGE=_YRANGE, YRANGE=_YRANGE, XLOG=XLOG, YLOG=YLOG, XTITLE='', YTITLE='', XTICKV=[0.1,1,10],YTICKV=[0.1,1,10], /REG_ADD, /ONE_ADD, /STATS_ADD, STATS_SIZE=FONTSIZE, PARAMS=[5,6,7,11], /DEVICE, /CURRENT
              ENDIF
                        
            ENDFOR

            W.SAVE, PNGFILE;, RESOLUTION=300
            W.CLOSE

          ENDFOR ; NUMBER OF PLOT FILES
          
          
          
  
        ENDFOR ; MAPS
      ENDFOR ; PERIODS
    ENDFOR ; SENSORS  
  ENDFOR ; SHPFILES 
   



END ; ***************** End of COMPARE_STACKED_STAT_EXTRACTS *****************
