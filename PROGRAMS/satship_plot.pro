; $ID:	SATSHIP_PLOT.PRO,	2020-07-08-15,	USER-KJWH	$
; 
FUNCTION SATSHIP_PLOT, SATPROD, MATCHFILE, TIME_DIF=TIME_DIF, PROD_TITLE=PROD_TITLE, GMEAN=GMEAN, MIN_PIX_PER=MIN_PIX_PER, CURRENT=CURRENT, LAYOUT=LAYOUT, POS=POS, BUFFER=BUFFER, COLORS=COLORS, SENSORS=SENSORS, $
                  USE_GMEAN=USE_GMEAN, USE_FILTER_MEAN=USE_FILTER_MEAN, XLOG=XLOG, YLOG=YLOG, LOGLOG=LOGLOG, $
                  NO_STATS=NO_STATS, NO_LEG=NO_LEG, STATS_POS=STATS_POS, LEG_POS=LEG_POS, PLTSTATS=PLTSTATS, ERROR=ERROR, ERR_MSG=ERR_MSG, _EXTRA=_EXTRA

;+
;NAME:
;   SATSHIP_MATCHUP.PRO
;
; PURPOSE:
;   Routine to plot the SHIP and SAT data using PLT_XL
;    
; CATEGORY:
;   SATSHIP
;
; CALLING SEQUENCE:
;  SATSHIP_XY = SATSHIP_PLOT(SATPROD, MATCHFILE) 
;  
; INPUTS:
;   SATPROD         = Satellite data prod to use in the plot
;   MATCHFILE       = SATSHIP MATCHUP file containing data for the plot
;
; OPTIONAL INPUTS:
;   TIME_DIF        = +/- Time difference between the match-ups
;   TITLE_PROD      = PROD name for the X & Y titles
;   MIN_PIX_PER     = Minimum % of valid pixels per match-up to be included in plot
;   CURRENT         = Use current window for plot
;   LAYOUT          = Layout position for the plot
;   POS             = Position on the window for the plot
;   NO_STATS        = Don't add STATS to the plot
;   NO_LEG          = Don't add sensor legend to the plot
;   STATS_POS       = Position for the stats legend
;   LEG_POS         = Position for the sensor legend
;   COLORS          = COLORS (using IDL colors) for the data points.  If multiple colors and multiple sensors, there will be a color for each sensor
;   SENSORS         = Can choose to plot the data from just one or multiple sensors.  
;   USE_GMEAN       = Use GMEAN instead of MEAN for the satdata input
;   USE_FILTER_MEAN = Use FILTER_(G)MEAN instead of (G)MEAN for satdata input
;   XLOG            = Display X data on a log scale
;   YLOG            = Display Y data on a log scale
;   _EXTRA          = EXTRA optional inputs for PLT_XY
;   
; KEYWORD PARAMETERS:
;
; OUTPUTS:
;   Returns a XY plot 
;   
; OPTIONAL OUTPUTS:
;   STATS       = Output structure containing the XY stats
;   ERROR
;   ERR_MSG    
;
; EXAMPLE:
;   
; NOTES:
;   See Bailey & Werdell, 2006 for published match-up "rules"
;
; MODIFICATION HISTORY:
;   Written May 19, 2015 by K.J.W.Hyde, 28 Tarzwell Drive, NMFS, NOAA 02882 (kimberly.hyde@noaa.gov)
;   Modification History
;           
;                                
;-
; *************************************************************************

  ROUTINE_NAME  = 'SATSHIP_PLOT'
  ERROR = 0
  ERR_MSG = ''
    
  ; ===> Read SATFILE and get the SATPROD tag
  IF NONE(MATCHFILE) THEN MATCHFILE = DIALOG_PICKFILE(TITLE='Pick save files')
  MDATA = IDL_RESTORE(MATCHFILE)
  TAGS  = TAG_NAMES(MDATA)  
  OK = WHERE(TAGS EQ SATPROD,COUNT)
  IF COUNT EQ 0 THEN BEGIN
    ERROR = 1
    ERR_MSG = 'ERROR: SATPROD (' + SATPROD + ') not found in ' + MATCHFILE
    PRINT, ERR_MSG
    RETURN, []
  ENDIF
  PDATA = MDATA.(OK)
  
  ; ===> Find "GOOD" surface data to plot
  IF NONE(TIME_DIF) THEN TIME_DIF = 3
  PDATA = PDATA[WHERE(ABS(PDATA.TIME_DIF_HR) LE TIME_DIF)]
  PDATA = PDATA[WHERE(PDATA.SURFACE_DEPTH NE MISSINGS(0.0))]
  IF NONE(MIN_PIX_PER) THEN MIN_PIX_PER = 0.5                                  ; Need 50% valid pixel Bailey & Werdell, 2006
  DIMS  = STRSPLIT(PDATA[0].PIXEL_DIMS,'X',/EXTRACT)                           ; Get pixel dimensions
  PNUM  = FIX(DIMS[0]) * FIX(DIMS[1])                                          ; Calculate number of pixels
  OK = WHERE(PDATA.N GT MIN_PIX_PER*PNUM,COUNT)                                ; Find data where at least MIN_PIX_PER (e.g. 50%) are valid
  IF COUNT LE 1 THEN BEGIN
    ERROR = 1
    ERR_MSG = 'ERROR: Not enough valid data to create plot'
    PRINT, ERR_MSG
    RETURN, []
  ENDIF
  PDATA = PDATA[OK]  
  IDATA = PDATA.SHIPDATA                                                        ; Ship data
  SDATA = PDATA.MEAN                                                            ; Satellite MEAN
  IF KEY(USE_GMEAN)                           THEN SDATA = PDATA.GMEAN          ; Use the satellite GMEAN instead of the MEAN
  IF KEY(USE_FILTER_MEAN)                     THEN SDATA = PDATA.FILTER_MEAN    ; Use the satellite FILTERED MEAN instead of the MEAN
  IF KEY(USE_GMEAN) AND KEY(USE_FILETER_MEAN) THEN SDATA = PDATA.FILTER_GMEAN   ; Use the satellite FILTERED GMEAN instead of the MEAN
        
  ; ===> Set up defaults
  SENSORS = []
  BSETS = WHERE_SETS(PDATA.SENSOR)                                              ; Look for multiple sensors
  IF NONE(SENSORS) THEN SENSORS = BSETS.VALUE                                   
  IF NONE(MODEL)   THEN MODEL = 'RMA'                                           ; Model input for STATS2
  IF NONE(COLORS)  THEN COLORS = ['DARK_BLUE','CRIMSON','DARK_TURQUOISE','ORANGE','SEA_GREEN','YELLOW'] ; Colors to plot the various sensor data
  IF N_ELEMENTS(COLORS) EQ 1 THEN COLORS = REPLICATE(COLORS,N_ELEMENTS(SENSORS)+1)                      ; If only one color provided, then replicate for the number of sensors +1
  IF NONE(SYMBOL)     THEN SYMBOL = 'CIRCLE'
  IF NONE(SYM_FILLED) THEN SYM_FILLED = 1
  IF NONE(LAYOUT) AND NONE(POS)        THEN POS = [0.15,0.1,0.9,0.85]            ; Position of the plot in the window if layout not provided
  IF NONE(STATS_POS)  THEN STATS_POS = [0.05,0.75]                               ; Position of the stats legend
  IF NONE(LEG_POS)    THEN LEG_POS =[0.77,0.15]                                  ; Position of the sensor legend
  IF NONE(PARAMS)     THEN PARAMS = [2,3,4,8,11,13]                              ; Stat parameters to include in the stats legend
  IF NONE(LOGLOG)     THEN LOGLOG = 0
  IF KEY(LOGLOG)      THEN XLOG = 1 & IF KEY(LOGLOG) THEN YLOG = 1               ; Set XLOG & YLOG
  
  ; ===> Set up X & Y titles 
  IF NONE(PROD_TITLE) THEN BEGIN
    PXTITLE = UNITS(SATPROD)
    PYTITLE = UNITS(SATPROD) 
  ENDIF ELSE BEGIN
    TPROD = VALIDS('PRODS',PROD_TITLE)
    TALG  = VALIDS('ALGS',PROD_TITLE)
    PXTITLE = UNITS(TPROD)
    IF TALG NE '' THEN PYTITLE = UNITS(TPROD,/NO_UNIT) + '-' + TALG + ' ' + UNITS(TPROD,/NO_NAME) ELSE PYTITLE = UNITS(TPROD)
  ENDELSE
  IF NONE(XTITLE)     THEN XTITLE = 'in situ '   + PXTITLE
  IF NONE(YTITLE)     THEN YTITLE = 'Satellite ' + PYTITLE
  
  ; Open graphics window  
  IF NONE(PLT_DIMS)   THEN PLT_DIMS = [600,600]                                  ; Window dimensions
  IF NONE(CURRENT)    THEN W = WINDOW(DIMENSIONS=PLT_DIMS,BUFFER=BUFFER)         ; Open plotting window if one is not already open
   
  ; ===> Calculate regression statistics
  IF NOT LOGLOG THEN PSTATS0 = STATS2(IDATA,SDATA,MODEL=MODEL,PARAMS=PARAMS,DECIMALS=3) $
                ELSE PSTATS0 = STATS2(ALOG10(IDATA),ALOG10(SDATA),MODEL=MODEL,PARAMS=PARAMS,DECIMALS=2)
  PLTSTATS = CREATE_STRUCT('ALLDATA',PSTATS0)                                    ; Structure to hold the STATS info
  
  ; ===> Plot all data & add stats legend
  PLT = PLOT(IDATA,SDATA,XTITLE=XTITLE,YTITLE=YTITLE,COLOR=COLORS,SYMBOL=SYMBOL,/SYM_FILLED,XLOG=XLOG,YLOG=YLOG,/CURRENT,_EXTRA=_EXTRA,BUFFER=BUFFER,POSITION=POS,LINESTYLE=6,LAYOUT=LAYOUT)
  RANGE = [MIN([PLT.XRANGE,PLT.YRANGE]),MAX([PLT.XRANGE,PLT.YRANGE])]           ; Find the min and max range of the data
  PLT.XRANGE = RANGE & PLT.YRANGE = RANGE                                       ; Make the X and Y axes have the same range
  STATS_TXT =  PSTATS0.STATSTRING
 
  IF NOT KEY(NO_STATS) THEN T = TEXT(STATS_POS[0],STATS_POS[1],STATS_TXT,COLOR='BLACK',BUFFER=BUFFER,/RELATIVE,TARGET=PLT,ALIGNMENT=0)

  ; ===> Plot the ONE2ONE line
  ;PLT_ONE2ONE, PLT, COLOR='DARK_GRAY', LINESTYLE=LINESTYLE, THICK=THICK      ; Getting hung up in PLT_ONE2ONE
  PO = PLOT(RANGE,RANGE,XRANGE=RANGE,YRANGE=RANGE,COLOR='DARK_GRAY',THICK=3,LINESTYLE=0,/OVERPLOT,BUFFER=BUFFER)
  
  ; ===> Plot the SLOPE of all data
  ;PLT_SLOPE, PLT, STRUCT=PSTATS0, REG_COLOR='BLACK', REG_THICK=5              ; Not working correctly with LOGLOG data
  XD = MINMAX(IDATA)
  IF NOT LOGLOG THEN YD = PSTATS0.INT + PSTATS0.SLOPE*XD ELSE YD = 10.0^(PSTATS0.INT + PSTATS0.SLOPE*ALOG10(XD))
  PR1 = PLOT(XD,YD,XRANGE=RANGE,YRANGE=RANGE,COLOR='BLACK',THICK=3,LINESTYLE=0,XLOG=XLOG,YLOG=YLOG,/OVERPLOT,BUFFER=BUFFER)

  ; ===> Plot data for each sensor
  FOR S=0, N_ELEMENTS(SENSORS)-1 DO BEGIN
    SUBS = WHERE(PDATA.SENSOR EQ SENSORS(S),COUNT)
    IF COUNT EQ 0 THEN CONTINUE
    IF COUNT GT 2 THEN PLTSTATS = STRUCT_MERGE(PLTSTATS,CREATE_STRUCT(SENSORS(S),STATS2(IDATA(SUBS),SDATA(SUBS),MODEL=MODEL)))      ; Add sensor specific stats to output structure
    PLTS = PLOT(IDATA(SUBS),SDATA(SUBS),COLOR=COLORS,SYMBOL=SYMBOL,SYM_FILLED=SYM_FILLED,LINESTYLE=6,XRANGE=RANGE,YRANGE=RANGE,/OVERPLOT)
    IF NOT KEY(NO_LEG) THEN T = TEXT(LEG_POS[0],LEG_POS[1]-(S*.03),SENSORS(S),COLOR=COLORS,/RELATIVE) ; Add sensor legend
  ENDFOR
  
  RETURN, PLT
    
END; #####################  END OF ROUTINE ################################
