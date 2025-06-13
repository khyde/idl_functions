; $ID:	COMPARE_SAT_IMAGES.PRO,	2020-07-08-15,	USER-KJWH	$
PRO COMPARE_SAT_IMAGES, PRODS, SENSORS=SENSORS, COMBO=COMBO, PERIODS=PERIODS, SUBAREAS=SUBAREAS, MPS=MPS, MAP_OUT=MAP_OUT, INTERP=INTERP, DATERANGE=DATERANGE, DIR_OUT=DIR_OUT
;+
; PRIMARY PURPOSE: To compare image data from various products/sensors
;
;
; KEYWORDS:
;   PRODS...........The names of the different products to be used for data comparisons
;
; OPTIONAL KEYWORDS:
;   SENSORS.........Sensor names
;   COMBO...........To compare a combination of sensors and products
;   PERIOD..........Time period for comparisons
;   MPS.............Map of the input files 
;   SUBAREAS........Name of shape file to extract the data from
;   DATERANGE.......Specify the date range of the input files
;   INTERP..........Set to use the interpolated data instead of the STATS
;   DIR_OUT.........Output directory for the extracted data and plots
;
; OUTPUTS
;   Time series plots of the data in each subregion
;
; EXAMPLE CALLS:
;   0) COMPARE_SAT_PRODS
;   1) COMPARE_SAT_PRODS, ['CHLOR_A-OCI','CHLOR_A-OCX','CHLOR_A-PAN']
;   2) COMPARE_SAT_PRODS, ['CHLOR_A-OCI','CHLOR_A-OCX','CHLOR_A-PAN'], SENSORS=['SEAWIFS','MODISA']
;   3) COMPARE_SAT_PRODS, ['CHLOR_A-OCI','CHLOR_A-OCX','CHLOR_A-PAN'], SENSORS=['SEAWIFS','MODISA'], MPS=['L3B2'],
;   4) COMPARE_SAT_PRODS, ['CHLOR_A-OCI','CHLOR_A-OCX','CHLOR_A-PAN'], SENSORS=['SEAWIFS','MODISA'], MPS=['L3B2'], SUBAREAS='NES_ECOREGIONS/EPU_NOESTUARIES'
;   5) COMPARE_SAT_PRODS, ['CHLOR_A-OCI','CHLOR_A-OCX','CHLOR_A-PAN'], SENSORS=['SEAWIFS','MODISA'], MPS=['L3B2'], SUBAREAS='NES_ECOREGIONS/EPU_NOESTUARIES', DATERANGE=['2002','2012']
;   6) COMPARE_SAT_PRODS, COMBO=['SEAWIFS,CHLOR_A-OCX;OCCCI,CHLOR_A-OCI'], DATERANGE=['1997','2010']
;
; NOTES:
; Copyright (C) 2018, Department of Commerce, National Oceanic and Atmospheric Administration, National Marine Fisheries Service,
;   Northeast Fisheries Science Center, Narragansett Laboratory.
;   This software may be used, copied, or redistributed as long as it is not sold and this copyright notice is reproduced on each copy made.
;   This routine is provided AS IS without any express or implied warranties whatsoever.
;
;   This program was written by Kimberly Hyde, DOC/NOAA/NMFS/NEFSC Narragansett, RI, kimberly.hyde@noaa.gov.
;   For questions about the code, contact kimberly.hyde@noaa.gov
;
;
; MODIFICATION HISTORY:
;     Written:  Oct 19, 2018 by Kimberly Hyde, NOAA/NEFSC/Narragansett Laboratory, 28 Tarzwell Drive, 02882
;     Modified:
;       Oct 19, 2018 - KJWH: Adapted from COMPARE_SAT_SENSORS (formerly COMPARE_SAT_DATA)
;       Oct 22, 2018 - KJWH: Added an optional DIR_OUT keyword
;                            Added a DSUBS directory for the individual files from SUBAREAS_EXTRACT
;                            Now saving the merged data file
;       Nov 05, 2018 - KJWH: Changed DSUBS directory to !S.EXTRACTS  
;                            Updated how the DATERANGE is calculated if not provided (now uses SENSOR_DATES)                   
;       
;
;-
;****************************************
  ROUTINE_NAME = 'COMPARE_SAT_IMAGES'
  DASH=DELIMITER(/DASH)
  SL=PATH_SEP()

  IF NONE(DIR_OUT) THEN DIR = !S.PROJECTS + 'COMPARE_SAT_DATA' + SL ELSE DIR = DIR_OUT
  DSUBS = !S.EXTRACTS                          ; Directory for the individual extracted data files
  DDATA = DIR + 'DATA' + SL                    ; Directory for the merged data
  DPLOT = DIR + 'IMAGE_PLOTS' + SL             ; Directory for the plots
  DANOM = DIR + 'ANOMALY_DATA' + SL            ; Directory for the anomaly saves 
  DIR_TEST, [DSUBS,DDATA,DPLOT,DANOM]
  DP = DATE_PARSE(DATE_NOW())
  
  COLORS = ['RED','BLUE','CYAN','SPRING_GREEN','ORANGE','DARK_BLUE','MAGENTA']
  YMINOR=1
  FONTSIZE = 8.5
  SYMSIZE = 0.45
  THICK = 2
  FONT = 0
  YMARGIN = [0.3,0.3]
  XMARGIN = [4,1]

  IF NONE(PRODS)     THEN PRODS     = ['CHLOR_A-OCI','CHLOR_A-PAN']
  IF NONE(SENSORS)   THEN SENSORS   = ['SEAWIFS','MODISA','VIIRS','JPSS1','OCCCI']
  IF NONE(PERIODS)   THEN PERIODS   = 'M'
  IF NONE(SUBAREAS)  THEN SUBAREAS  = 'NES_EPU_NOESTUARIES'
  IF NONE(MPS)       THEN MPS       = 'L3B2'
  IF NONE(MAP_OUT)   THEN OMAP      = 'NEC' ELSE OMAP = STRUPCASE(MAP_OUT)
  
  SZ = MAPS_SIZE(OMAP,PX=MPX,PY=MPY)
  DIMS = [MPX,MPY]
  IF MIN(DIMS) LT 500 THEN BEGIN
    FOR I=1, 10 DO BEGIN
      IF MIN(DIMS) LT 500 THEN DIMS = [MPX*I,MPY*I]
    ENDFOR
  ENDIF
  IF MAX(DIMS) GT 1500 THEN BEGIN
    FOR I=1, 10 DO BEGIN
      IF MAX(DIMS) GT 1500 THEN DIMS = [MPX/I,MPY/I]
    ENDFOR
  ENDIF  
  
  IF NONE(BUFFER)    THEN BUFFER    = 0
  IF NONE(COMBO)     THEN BEGIN
    COMBO = []
    FOR N=0, N_ELEMENTS(SENSORS)-1 DO BEGIN
      CMB = []
      FOR I=0, N_ELEMENTS(PRODS)-1 DO CMB = STRJOIN([CMB,STRJOIN([SENSORS(N), PRODS(I)],',')],';')
      COMBO = [COMBO,CMB]
    ENDFOR
  ENDIF ELSE COMBO = COMBO
  
  FOR N=0, N_ELEMENTS(SUBAREAS)-1 DO BEGIN
    SUBAREA = SUBAREAS(N)
    SHP = READ_SHPFILE(SUBAREA, MAPP=OMAP)
    SHP = STRUCT_REMOVE(SHP.(0),'OUTLINE')
    MASK = MAPS_BLANK(OMAP,FILL=1)
    FOR T=0, N_TAGS(SHP)-1 DO MASK(SHP.(T).SUBS) = 0
    MASK = WHERE(MASK EQ 1,/NULL)
      
    FOR M=0, N_ELEMENTS(MPS)-1 DO BEGIN
      AFILES = []
      CDATA  = []
      MSUBS  = []
    
      FOR R=0, N_ELEMENTS(PERIODS)-1 DO BEGIN
        PER = PERIODS(R)
        IF PER EQ 'D'  THEN SDIR = 'SAVE' ELSE SDIR = 'STATS'
        IF KEY(INTERP) THEN SDIR = 'INTERP_SAVE'

        CASE PER OF
          'D': PLABEL = 'DAILY'
          'W': PLABEL = 'WEEKLY'
          'M': PLABEL = 'MONTHLY'
          'A': PLABEL = 'YEARLY'
        ENDCASE       

        FOR C=0, N_ELEMENTS(COMBO)-1 DO BEGIN
          CMB = STR_BREAK(COMBO(C),';')
          CB  = STR_BREAK(CMB,',')
          SEN = CB(*,0)
          PRD = CB(*,1)
          
          IF NONE(DATERANGE) THEN BEGIN
            FOR D=0, N_ELEMENTS(SEN)-1 DO BEGIN
              DR = SENSOR_DATES(SEN(D))
              IF NONE(D1) THEN D1 = DR[0] ELSE D1 = MIN([D1,DR[0]])
              IF NONE(D2) THEN D2 = DR[1] ELSE D2 = MAX([D2,DR[1]])
            ENDFOR
            DATERANGE = [D1,D2]
          ENDIF
          AXRANGE = [STRMID(DATERANGE,0,4)+'0101',STRMID(DATERANGE[1],0,4)+'1231']
          X  = DATE_2JD(AXRANGE) & AX  = DATE_AXIS(X,/MONTH, /YY_YEAR,STEP_SIZE=12) & AYR = DATE_AXIS(X,/YEAR)
          XTICKNAMES = REPLICATE(' ',N_ELEMENTS(AX.TICKNAME))

          FOR P=0, N_ELEMENTS(PRD)-1 DO BEGIN
            APROD = PRD(P)
            ASEN  = SEN(P)
            CASE 1 OF
              HAS(APROD,'SST'):     DIR = !S.SST
              HAS(APROD,'GRAD'):    DIR = !S.FRONTS
              HAS(APROD,'PP'):      DIR = !S.PP
              ELSE:                 DIR = !S.OC
            ENDCASE
        
            IF MPS(M) EQ 'L3B2' AND ASEN EQ 'OCCCI' THEN AMAP = 'L3B4' ELSE AMAP = MPS(M)
            IF HAS(APROD,'RRS') THEN SPROD = RRS_SWAP(RRS=APROD,SENSOR_IN='SEAWIFS',SENSOR_OUT=ASEN) ELSE SPROD = APROD
            FILES = FLS(DIR + ASEN + SL + AMAP + SL + SDIR + SL + SPROD + SL + PER + '_*.SAV',DATERANGE=DATERANGE, COUNT=COUNTF)
            IF COUNTF EQ 0 THEN BEGIN
              MSUBS = P
              CONTINUE
            ENDIF  
            
            AFILES = [AFILES,FILES]
           ; SAVEFILE = DSUBS + PLABEL + '-' + ASEN + '-' + AMAP + '-' + APROD + '-' + SNAME + '.SAV'
           ; SUBAREAS_EXTRACT, FILES, SHP_FILES=SHPFILE,DIR_OUT=DDIR,SAVEFILE=SAVEFILE,INIT=INIT,VERBOSE=VERBOSE
           ; EFILES = [EFILES,SAVEFILE]
           ; IF P EQ 0 THEN CDATA = STRUCT_READ(SAVEFILE) ELSE CDATA = STRUCT_CONCAT(CDATA,STRUCT_READ(SAVEFILE))
          ENDFOR ; PRODS
          
          IF MSUBS NE [] THEN BEGIN
            SEN = REMOVE(SEN,MSUBS)
            PRD = REMOVE(PRD,MSUBS)
          ENDIF
          
          IF SAME(SEN) AND ~SAME(PRD) THEN SPLABEL = SEN[0] + '-' + STRJOIN(PRD,'_') 
          IF SAME(PRD) AND ~SAME(SEN) THEN SPLABEL = STRJOIN(SEN,'_') + '-' + PRD[0]
          IF SAME(PRD) + SAME(SEN) EQ 0 THEN SPLABEL = STRJOIN(SEN + '-' + PRD,'-')
          
       ;   DATFILE = DDATA + PER + '_' + STRJOIN(DATERANGE,'_') + '-' + MPS(M) + '-' + SPLABEL + '-' + SNAME + '.SAV'
       ;   IF FILE_MAKE(EFILES,DATFILE,OVERWRITE=OVERWRITE) EQ 1 THEN BEGIN
       ;     SAVE, CDATA, FILENAME=DATFILE ; ===> SAVE THE MERGED DATAFILE
       ;     SAVE_2CSV, DATFILE
       ;   ENDIF
        
          FP = PARSE_IT(AFILES,/ALL)
          SETS = WHERE_SETS(FP.PROD_ALG)
          COMBOS = COMBIGEN(N_ELEMENTS(SETS),2)
          NCOMBOS = N_ELEMENTS(COMBOS(*,0))
          
          FOR O=0, NCOMBOS-1 DO BEGIN
            SCMB = COMBOS(O,*)
            PRODA = SETS(SCMB[0]).VALUE
            PRODB = SETS(SCMB[1]).VALUE
            
            FILESA = AFILES[WHERE(FP.PROD_ALG EQ PRODA,COUNTA,/NULL)]
            FILESB = AFILES[WHERE(FP.PROD_ALG EQ PRODB,COUNTB,/NULL)]
            
            PFILES = [FILESA,FILESB] & PF = PARSE_IT(PFILES)
            PSETS = WHERE_SETS(PF.PERIOD)
            
            PNGFILE = DPLOT + PER + '_' + STRJOIN(DATERANGE,'_') + '-' + MPS(M) + '-' + SPLABEL + '.PNG'
            IF FILE_MAKE(EFILES,PNGFILE,OVERWRITE=OVERWRITE) EQ 0 THEN CONTINUE
            SETS = WHERE_SETS(CDATA.SUBAREA)

            PRDS = VALIDS('PRODS',[PRODA,PRODB])
            
            PRANGE = []
            IRANGE = []
            CTITLE = []
            FOR D=0, 1 DO BEGIN
              APROD = PRDS(D)
              CASE VALIDS('PRODS',APROD) OF
                'CHLOR_A'             : BEGIN & XYRANGE=[XYRANGE,'0.1,100'] & WRANGE='0,3'    & MRANGE='0,3'    & ARANGE='0,2'    & SCALE='' & TPROD='Chlorophyll'          & END
                'DIATOM_PERCENTAGE'   : BEGIN & XYRANGE=[XYRANGE,'0,.4']    & WRANGE='0,.4'   & MRANGE='O,.3'   & ARANGE='0,.3'   & SCALE='' & TPROD='Diatom CHL (%)'       & END
                'MICRO'               : BEGIN & XYRANGE=[XYRANGE,'0.01,10'] & WRANGE='0,3'    & MRANGE='0,3'    & ARANGE='0,2'    & SCALE='' & TPROD='Micro Chlorophyll'    & END
                'NANOPICO'           : BEGIN & XYRANGE=[XYRANGE,'0.01,30'] & WRANGE='0,3'    & MRANGE='0,3'    & ARANGE='0,2'    & SCALE='' & TPROD='NanoPico Chlorophyll' & END
                'MICRO_PERCENTAGE'    : BEGIN & XYRANGE=[XYRANGE,'0,.4']    & WRANGE='0,40'   & MRANGE='O,40'   & ARANGE='0,40'   & SCALE='' & TPROD='Micro CHL (%)'        & END
                'NANOPICO_PERCENTAGE': BEGIN & XYRANGE=[XYRANGE,'0,.8']    & WRANGE='0,80'   & MRANGE='O,80'   & ARANGE='0,80'   & SCALE='' & TPROD='NanoPico CHL (%)'     & END
                'PAR'                 : BEGIN & XYRANGE=[XYRANGE,'0,80']    & WRANGE='0,80'   & MRANGE='0,80'   & ARANGE='30,40'  & SCALE='' & TPROD='PAR'                  & END
                'PPD'                 : BEGIN & XYRANGE=[XYRANGE,'0.1,40']  & WRANGE='0,4'    & MRANGE='0,4'    & ARANGE='0,2'    & SCALE='' & TPROD='Primary Production'   & END
                'MICROPP'           : BEGIN & XYRANGE=[XYRANGE,'0.1,10']  & WRANGE='0,1'    & MRANGE='0,1'    & ARANGE='0,0.5'  & SCALE='' & TPROD='Microplankton PP'     & END
                'NANOPICOPP'        : BEGIN & XYRANGE=[XYRANGE,'0.1,30']  & WRANGE='0,3'    & MRANGE='0,3'    & ARANGE='0,1'    & SCALE='' & TPROD='NanoPico PP'          & END
                'MICROPP_PERCENTAGE'       : BEGIN & XYRANGE=[XYRANGE,'0,40']    & WRANGE='0,40'   & MRANGE='O,40'   & ARANGE='0,40'   & SCALE='' & TPROD='Micro PP (%)'         & END
                'NANOPICOPP_PERCENTAGE'    : BEGIN & XYRANGE=[XYRANGE,'0,80']    & WRANGE='0,80'   & MRANGE='O,80'   & ARANGE='0,80'   & SCALE='' & TPROD='NanoPico PP (%)'      & END
                'SST'                 : BEGIN & XYRANGE=[XYRANGE,'-1,30']   & WRANGE='-1,30'  & MRANGE='-1,30'  & ARANGE='-1,30'  & SCALE='' & TPROD='Temperature'          & END
                'RRS_412'             : BEGIN & XYRANGE=[XYRANGE,'0,.01']   & WRANGE='0,.006' & MRANGE='0,.006' & ARANGE='0,.004' & SCALE='' & TPROD='RRS 412'              & END
                'RRS_443'             : BEGIN & XYRANGE=[XYRANGE,'0,.01']   & WRANGE='0,.006' & MRANGE='0,.006' & ARANGE='0,.004' & SCALE='' & TPROD='RRS 443'              & END
                'RRS_490'             : BEGIN & XYRANGE=[XYRANGE,'0,.01']   & WRANGE='0,.006' & MRANGE='0,.006' & ARANGE='0,.004' & SCALE='' & TPROD='RRS 490'              & END
                'RRS_510'             : BEGIN & XYRANGE=[XYRANGE,'0,.01']   & WRANGE='0,.006' & MRANGE='0,.005' & ARANGE='0,.004' & SCALE='' & TPROD='RRS 510'              & END
                'RRS_555'             : BEGIN & XYRANGE=[XYRANGE,'0,.01']   & WRANGE='0,.006' & MRANGE='0,.005' & ARANGE='0,.004' & SCALE='' & TPROD='RRS 555'              & END
                'RRS_670'             : BEGIN & XYRANGE=[XYRANGE,'0,.002']  & WRANGE='0,.004' & MRANGE='0,.001' & ARANGE='0,.001' & SCALE='' & TPROD='RRS 670'              & END
              ENDCASE
              CASE PER OF
                'W': BEGIN & IRANGE = [IRANGE,REPLACE(WRANGE,',','_')] & PLABEL = 'WEEKLY'  & END
                'M': BEGIN & IRANGE = [IRANGE,REPLACE(MRANGE,',','_')] & PLABEL = 'MONTHLY' & END
                'A': BEGIN & IRANGE = [IRANGE,REPLACE(ARANGE,',','_')] & PLABEL = 'YEARLY'  & END
              ENDCASE
              CTITLE=[CTITLE,TPROD+' '+UNITS(APROD,/NONAME)]
            ENDFOR ; Loop to set up ranges based on the input product  

            FOR F=0, N_ELEMENTS(PSETS)-1 DO BEGIN
              IF PSETS(F).N EQ 1 THEN BEGIN
                PRINT, 'ERROR: Only 1 image for period ' + PSETS(F).VALUE + ' found.'
                CONTINUE
              ENDIF
              IF PSETS(F).N NE 2 THEN MESSAGE, 'ERROR: More than 2 images for period ' + PSETS(F).VALUE + 'found'
              SUBS = WHERE_SETS_SUBS(PSETS(F))
              SET = PFILES(SUBS) 
              DA = STRUCT_READ(SET[0],STRUCT=SA,MASK=MASK,MAP_OUT=OMAP)
              DB = STRUCT_READ(SET[1],STRUCT=SB,MASK=MASK,MAP_OUT=OMAP)
              OKXY = WHERE(DA NE MISSINGS(DA) AND DB NE MISSINGS(DB),COUNTXY)
              IF COUNTXY EQ 0 THEN MESSAGE, 'ERROR: No matching data found in ' + SET + ' files'
              
              PA = PRODS_READ(SA.PROD)
              IF ~SAME([SA.PROD,SB.PROD]) THEN BEGIN
                PB = PRODS_READ(SB.PROD)
                IF SAME([PA.LOG,PB.LOG]) THEN LOG = PA.LOG ELSE LOG = 0
              ENDIF ELSE LOG = PA.LOG
              
              CB_TITLES = [UNITS(SA.PROD),UNITS(SB.PROD)]
              IF ~SAME([SA.SENSOR,SB.SENSOR]) THEN BEGIN
                CB_TITLES[0] = SA.SENSOR + ' - ' + CB_TITLES[0]
                CB_TITLES[1] = SB.SENSOR + ' - ' + CB_TITLES[1]
              ENDIF
              
              IF LOG EQ 1 THEN ANOM='RATIO' ELSE ANOM='DIF'    
              AN = MAKE_ANOM_SAVES(FILEA=SET[0],FILEB=SET[1],ANOM=ANOM,DIR_OUT=DANOM)
           
              W = WINDOW(DIMENSIONS=DIMS,BUFFER=BUFFER)
              PRODS_2PNG,SET[0],PAL='PAL_BR',IMG_POS=[0,0.5,0.5,1.0],CB_TITLE=CB_TITLES[0],/CURRENT,/ADD_CB, MASK=MASK, MAPP=OMAP, MISS_COLOR=255
         ;     PRODS_2PNG,SET(1),PAL='PAL_BR',IMG_POS=[0.5,0.5,1.0,1.0],CB_TITLE=CB_TITLES(1),/CURRENT,/ADD_CB, MASK=MASK, MAPP=OMAP, MISS_COLOR=255
         ;     PRODS_2PNG,AN,SPROD=ANOM,PAL='PAL_ANOM_BGR',IMG_POS=[0.0,0.0,0.5,0.5],/CURRENT,/ADD_CB, MASK=MASK, MAPP=OMAP, MISS_COLOR=255
  
          
              RANGE = NICE_RANGE(MINMAX([DA(OKXY),DB(OKXY)]))
              P = PLOTXY_NG(DA(OKXY),DB(OKXY),DECIMALS=3,LOGLOG=LOG,/QUIET,/CURRENT,MODEL='RMA',PARAMS=[5,6,7,11],POSITION=[0.55,0.05,0.98,0.5],CHARSIZE=FONTSIZE,PSYM='CIRCLE',$
                XTITLE='',YTITLE='',SYM_COLOR='BLUE',SYMSIZE=SYMSIZE,THICK=THICK,XRANGE=RANGE,YRANGE=RANGE,/GRID_NONE,MARGIN=MARGIN,STATS_CHARSIZE=STATS_CHARSIZE,$
                STATS_POS=[0.56,0.49],/ONE2ONE,ONE_COLOR=253,ONE_THICK=ONE_THICK,ONE_LINESTYLE=ONE_LINESTYLE,BUFFER=BUFFER) ; XTICKNAME=XTICKNAME,YTICKNAME=YTICKNAME,
          ;    TD = TEXT(APOS(2)-0.005,.18,TITLE_PERIODS(LTH),FONT_SIZE=FONTSIZE+2,FONT_STYLE='BOLD',ALIGNMENT=1.0)
         ;   ENDFOR
            TX = TEXT(0.5, 0.16,  LEGA,ALIGNMENT=0.5,FONT_SIZE=FONTSIZE)
           ; TY = TEXT(0.065,0.23, LEGB,ALIGNME
              
      STOP         
       ;     ENDFOR
            
            STOP
      ;    ENDFOR
          
              
              
              W.SAVE, PNGFILE;, RESOLUTION=300
              W.CLOSE
            ENDFOR ; COMBOS
          ENDFOR ; PSETS
        ENDFOR ; MPS
      ENDFOR ; PERIODS
    ENDFOR ; COMBOS 
  ENDFOR ; SUBAREAS

  
END
