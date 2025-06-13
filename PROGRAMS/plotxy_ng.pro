; $ID:	PLOTXY_NG.PRO,	2021-04-15-17,	USER-KJWH	$


FUNCTION PLOTXY_NG ,X ,Y , $
						LOGLOG = loglog,$  	; for a log vs log regression and log10 statistics,
            MODEL=MODEL,$    		; REGRESSION MODEL(s)
            PARAMS=params,$     ; Passed to STATS2.pro
            DECIMALS=DECIMALS,$ ; Passed to STATS2.pro
            XRANGE=XRANGE,$
            YRANGE=YRANGE,$
            CHARSIZE=CHARSIZE,$
            FONT=FONT,$
            MARGIN=MARGIN,$

            FAST = FAST, $			; Passed to STATS2.pro
            MISSINGX=missingx,MISSINGY=missingy,$
            OUTLIERS=outliers,outline=OUTLINE,$
            ONE2ONE=one2one,$ 	; OPLOTS A 1 : 1 LINE
            subset=SUBSET,$
            ROOM = room,$

            TITLE=TITLE,$
            XTITLE=xtitle,$
            YTITLE=ytitle,$
            PAL=PAL,$
            SYM_COLOR=SYM_COLOR,$
            PSYM=PSYM,$
            SYMSIZE=SYMSIZE,$
            SYMFILL=SYMFILL,$
            
            XTICKNAME=XTICKNAME,$
            YTICKNAME=YTICKNAME,$
            XTICKVALUES=XTICKVALUES,$
            YTICKVALUES=YTICKVALUES,$

;           Statistics (Regression)
            FILE = file,$                    ;File for appending stats to
            STATS_NONE=stats_none,$
            STATS_POS=stats_pos,$             ;POSITION FOR STATS (DATA UNITS,X,Y)
            STATS_COLOR=stats_color,$
            STATS_CHARSIZE=stats_charsize,$
            STATS_STRUCT=STATS_STRUCT,$
            DOUBLE_SPACE=double_space,$       ;(double line spaces between stat output)

;           Legend
            LEG_SHOW=leg_show,$
            leg_pos=leg_pos,$
            LEG_COLOR=leg_color,$
            LEG_CHARSIZE=leg_charsize,$

;           Regression lines:
            REG_NONE=reg_none,$
            REG_COLOR=reg_color,$
            REG_THICK=reg_thick,$
            REG_LINESTYLE=reg_linestyle,$
            REG_MID_COLOR=REG_MID_color,$
            REG_MID_THICK=REG_MID_thick,$
            REG_MID_LINESTYLE=REG_MID_linestyle,$

;           ONE2ONE line:
            ONE_COLOR=one_color,$
            ONE_THICK=one_thick,$
            ONE_LINESTYLE=one_linestyle,$

;           Plot Mean x,y:
            MEAN_SHOW=mean_show,$
            MEAN_PSYM=mean_psym,$
            MEAN_SYMSIZE=mean_symsize,$
            MEAN_COLOR=mean_color,$
            MEAN_THICK=mean_thick,$

            SYMBOLS=symbols,$

            GRID_NONE = grid_none,$
            GRID_COLOR=grid_color,$
            GRID_THICK=grid_thick,$
            GRID_LINESTYLE=grid_linestyle,$
            
            POSITION=POSITION,$ ; Position on the plotting window (NG)
            BUFFER=BUFFER,$     ; Create figure in the background (NG)
            CURRENT=CURRENT,$   ; Plot onto current window (NG)
            LAYOUT=LAYOUT,$     ; Figure layout/position (NG)
            DEVICE=DEVICE,$     ; (NG)
            
            SHOW=SHOW,$

            _EXTRA=_extra

;+
; NAME:
;       plotxy
;
; PURPOSE:
; Plot a scatter plot of x and y arrays and the functional (or other) linear regression line
;   and optionally plot the regression statistics

; EXAMPLES:
;   x =    FINDGEN(50)+25* RANDOMn(seed,50)
;   y =    x  + 25* RANDOMn(s,n_elements(x))
;   PLOTXY,X,Y,psym=1
;
;   plotxy,indgen(10)+1,indgen(10)+2,/stats_plot
;   plotxy,indgen(10)+1,indgen(10)+2,/stats_plot , psym=6
;
;   x = indgen(500)+100*randomn(seed,500)
;   y = indgen(500)+100*randomn(seed,500)
;   PLOTXY,x,y,DECIMALS=3,/SHOW,MODEL=['RMA','LSY'],PARAMS=[1,2,3,4,7],psym=1


;
; INPUTS:
;   An x and y array of integer,long,float,double
;
; KEYWORD PARAMETERS:
;   MODEL: The Regression Model(s) (e.g. MODEL='LSY', or MODEL='RMA');
;			LSY:	LEAST SQUARES Y
;			LSX:	LEAST SQUARES X
;			LSB:	LEAST SQUARES BISECTOR
;			ORMA:	ORTHOGONAL REDUCED MAJOR AXIS
;			RMA:	REDUCED MAJOR AXIS (FUNCTIONAL REGRESSION)
;			MLS:	MEAN LEAST SQUARES
;			RLAD:	ROBUST LEAST ABSOLUTE DEVIATION (IDL'S LADFIT.PRO)
;
;	DECIMALS:  Number of decimal places in legend (passed to STATS2.PRO; affects tag statstring)
;
;	REG_MID_COLOR = REG_MID_COLOR,$
; OUTPUTS:
;       Displays a scatter plot in the graphics window,
;       Functional Regression line, and regression statistics
;       Also Prints regression statistics
;
;
; SIDE EFFECTS:
;       None.
;
; RESTRICTIONS:
;       NOTE: IF THE USER PROVIDES THE PLOT KEYWORD /XLOG OR /YLOG THEN A LOG-LOG PLOT RESULTS
;             THAT IS, THE PROGRAM WILL ONLY DRAW NORMAL VS NORMAL OR LOG VS LOG
;
; PROCEDURE:
;       Straightforward.
;
; NOTES:
;
;
; MODIFICATION HISTORY:
; MODIFICATION HISTORY:
;		Written June ,1996 by J.O'Reilly, 28 Tarzwell Drive, NMFS, NOAA 02882 (Jay.O'Reilly@NOAA.GOV)
;           Sept 14, 1998 JOR Added keyword DOUBLE_SPACE
;           Nov 1, 2011: KJWH Added new graphics code
;
;-

 ;==========>
;  Program plots  y vs x
;  computes and optionally annotates plot with linear regression statistics.

; ===> Ensure that x,y parameters are provided
  IF N_PARAMS() LT 2 THEN MESSAGE, 'ERROR: Please provide x and y variables'
  IF N_ELEMENTS(X) NE N_ELEMENTS(Y) THEN MESSAGE, 'X and Y must be same size'

; ===> Default REGRESSION MODEL;
  IF N_ELEMENTS(MODEL) EQ 0 THEN MODEL = 'RMA' ELSE MODEL=STRUPCASE(MODEL); DEFAULT IS FUNCTIONAL REGRESSION (REDUCED MAJOR AXIS)
  N_MODEL = N_ELEMENTS(MODEL)

  IF N_ELEMENTS(CHARSIZE)       EQ 0 THEN CHARSIZE  = 10
  IF N_ELEMENTS(FONT)           EQ 0 THEN FONT = 'Helvetica'
  IF N_ELEMENTS(STATS_COLOR)   	EQ 0 THEN STATS_COLOR     = 0
  IF N_ELEMENTS(STATS_CHARSIZE)	EQ 0 THEN STATS_CHARSIZE  = 8
  IF N_ELEMENTS(REG_COLOR)     	EQ 0 THEN REG_COLOR = REPLICATE(0,N_MODEL)
  IF N_ELEMENTS(REG_THICK)     	NE N_MODEL THEN REG_THICK = REPLICATE(3,N_MODEL)
  IF N_ELEMENTS(REG_LINESTYLE)  NE N_MODEL THEN REG_LINESTYLE = INDGEN(N_MODEL)

	IF N_ELEMENTS(REG_MID_COLOR) 	EQ 0 THEN REG_MID_COLOR = REPLICATE(0,N_MODEL)
	IF N_ELEMENTS(REG_MID_THICK)     	NE N_MODEL THEN REG_MID_THICK = REPLICATE(3,N_MODEL)
  IF N_ELEMENTS(REG_MID_LINESTYLE) NE N_MODEL THEN REG_MID_LINESTYLE = REPLICATE(0,N_MODEL)

  IF N_ELEMENTS(PAL)          EQ 0 THEN PAL = 'PAL_36'
  IF N_ELEMENTS(PSYM)     		EQ 0 THEN PSYM = 'CIRCLE'
  IF N_ELEMENTS(SYMSIZE)     	EQ 0 THEN SYMSIZE     = 1
  IF N_ELEMENTS(SYMFILL)      EQ 0 THEN SYMFILL = 1
  IF N_ELEMENTS(SYM_COLOR)     EQ 0 THEN SYM_COLOR     = 0

  IF N_ELEMENTS(one_COLOR)     EQ 0 THEN one_COLOR     = 251
  IF N_ELEMENTS(one_THICK)     EQ 0 THEN one_THICK     = 2
  IF N_ELEMENTS(one_LINESTYLE) EQ 0 THEN one_LINESTYLE = 0

  IF N_ELEMENTS(MEAN_PSYM) EQ 0 THEN mean_psym = 1
  IF N_ELEMENTS(MEAN_SYMSIZE) EQ 0 THEN mean_symsize=2
  IF N_ELEMENTS(MEAN_COLOR) EQ 0 THEN mean_color = 0
  IF N_ELEMENTS(MEAN_THICK) EQ 0 THEN mean_thick = 1


  IF N_ELEMENTS(GRID_COLOR)  EQ 0 THEN GRID_COLOR     = 254
  IF N_ELEMENTS(GRID_linestyle)  EQ 0 THEN GRID_linestyle = 0
  IF N_ELEMENTS(GRID_THICK)  EQ 0 THEN GRID_THICK     = 1

; ====================>
; If no descriptive text is provided for keyword subset then subset = ''
  IF N_ELEMENTS(SUBSET)   EQ 0 THEN subset = ''

; ====================>
; If no descriptive name for x and y variables then default names: xvar,yvar
  IF N_ELEMENTS(XTITLE) EQ 0 THEN XTITLE = 'X'
  IF N_ELEMENTS(YTITLE) EQ 0 THEN YTITLE = 'Y'

; ===================>
; Copy x and y into new variables, and convert to DOUBLE PRECISION
  XD = DOUBLE(X)
  YD = DOUBLE(Y)

; ===================>
; Eliminate infinite data or data equal to missing code
  IF N_ELEMENTS(MISSINGX) EQ 0 THEN MISSINGX = MISSINGS(XD)
  IF N_ELEMENTS(MISSINGY) EQ 0 THEN MISSINGY = MISSINGS(YD)

  OK = WHERE(XD NE MISSINGX AND YD NE MISSINGY,count)
  IF count LT 2 THEN BEGIN
    PRINT, 'NOT ENOUGH OBSERVATIONS'
    GOTO, SKIP
  ENDIF
  XD = XD[OK] & YD = YD[OK]


;	===> Generate a nice xrange and yrange
 	IF N_ELEMENTS(XRANGE) NE 2 THEN XRANGE=NICE_RANGE(XD)
	IF N_ELEMENTS(YRANGE) NE 2 THEN YRANGE=NICE_RANGE(YD)


; ====================>
; Check if outliers is set (eliminate outlier ratios of 10:1, 1:10 etc.)
  IF KEYWORD_SET(OUTLIERS) THEN BEGIN
    outliers = DOUBLE(outliers)
    ok = WHERE( (YD/XD) LT  outliers AND (YD/XD) GT (1.0d/outliers), count  )
    XD = XD(ok)      & YD = YD(ok)
    IF count LT 2 THEN BEGIN
      PRINT, 'NOT ENOUGH OBSERVATIONS'
      GOTO, SKIP
    ENDIF
  ENDIF

; ===> Compute correlation,rmsd and regression coefficients (NASA GSFC SIXLIN.PRO)
; Must look to see if _extra contains 'XLOG' OR 'YLOG' KEYWORDS TO PASS TO PLOT COMMAND
  _loglog = 0
  IF KEYWORD_SET(_EXTRA) THEN BEGIN
    txt = TAG_NAMES(_EXTRA)
    ok = WHERE(STRUPCASE(txt) EQ 'XLOG' OR STRUPCASE(txt) EQ 'YLOG' , COUNT )
    IF count GE 1 THEN _loglog = 1
  ENDIF

  IF KEYWORD_SET(LOGLOG) THEN _loglog = 1


  IF NOT _loglog THEN BEGIN
    _STATS2 = STATS2(XD,YD,MODEL=MODEL,PARAMS=PARAMS,DECIMALS=DECIMALS,SHOW=SHOW,FAST=fast,FILE=file,DOUBLE_SPACE=double_space)
  ENDIF ELSE BEGIN
;    LOG10 TRANSFORM X AND Y DATA
    _STATS2 = STATS2(ALOG10(XD),ALOG10(YD),MODEL=MODEL,PARAMS=PARAMS, DECIMALS=DECIMALS,SHOW=SHOW,FAST=fast,FILE=file,DOUBLE_SPACE=double_space)
  ENDELSE

		STATS_STRUCT = _STATS2
;

; ====================>
  IF N_ELEMENTS(ROOM) GE 1 THEN BEGIN
    GRACE = (100.0- ROOM)*.01
    XRANGE = [XRANGE[0]*GRACE,XRANGE[1]/GRACE]
    YRANGE = [YRANGE[0]*GRACE,YRANGE[1]/GRACE]
  ENDIF
  
  RGB_TABLE = CPAL_READ(PAL,PALLIST=PALLIST)
  IF IDLTYPE(SYM_COLOR) EQ 'STRING' THEN SYM_COLOR = GET_IDL_COLOR(SYM_COLOR)
  IF N_ELEMENTS(SYM_COLOR) NE 3 THEN RGB_COLOR = PALLIST(SYM_COLOR) ELSE RGB_COLOR = SYM_COLOR
  
; ===> Plot scatter plot  
  IF N_ELEMENTS(SYMBOLS) EQ N_ELEMENTS(XD) THEN BEGIN
    SYMBOLS = LONG(SYMBOLS)

    P = PLOT(XD,YD,XRANGE=XRANGE,YRANGE=YRANGE,XSTYLE=1,YSTYLE=1,TITLE=TITLE,XTITLE=XTITLE,YTITLE=YTITLE,FONT_SIZE=CHARSIZE,MARGIN=MARGIN,$
       XTICK_GET=XTICK_GET, YTICK_GET=YTICK_GET,XTICKNAME=XTICKNAME,YTICKNAME=YTICKNAME,XTICKVALUES=XTICKVALUES,YTICKVALUES=YTICKVALUES,$
       /NODATA,XLOG=_LOGLOG,YLOG=_LOGLOG, _extra=_extra,BUFFER=BUFFER,FONT_NAME=FONT,POSITION=POSITION)

      IF NOT KEYWORD_SET(GRID_NONE) THEN GRIDS,X=XTICK_GET,Y=YTICK_GET,COLOR=GRID_COLOR,LINESTYLE=GRID_LINESTYLE,THICK=GRID_THICK

      FOR i = 0,N_ELEMENTS(SYMBOLS)-1L DO BEGIN
       PLOTS,XD(I),YD(I),PSYM=SYMBOLS(I),SYMSIZE=SYMSIZE, COLOR=RGB_COLOR
      ENDFOR

  ENDIF ELSE BEGIN

    P = PLOT(XD,YD,XRANGE=XRANGE,YRANGE=YRANGE,TITLE=TITLE,XTITLE=XTITLE,YTITLE=YTITLE,LINESTYLE=6,SYMBOL=PSYM,SYM_COLOR=RGB_COLOR,SYM_FILLED=SYMFILL,SYM_SIZE=SYMSIZE,$
        MARGIN=MARGIN,FONT_SIZE=CHARSIZE,XLOG=_LOGLOG,YLOG=_LOGLOG,BUFFER=BUFFER,CURRENT=CURRENT,LAYOUT=LAYOUT,FONT_NAME=FONT,$
        XTICKNAME=XTICKNAME,YTICKNAME=YTICKNAME,XTICKVALUES=XTICKVALUES,YTICKVALUES=YTICKVALUES,POSITION=POSITION,DEVICE=DEVICE)
    
    IF NOT KEYWORD_SET(GRID_NONE) THEN STOP ; NEEDS TO BE FIX FOR NG PLOTS - GRIDS,X=XTICK_GET,Y=YTICK_GET,COLOR=GRID_COLOR,LINESTYLE=GRID_LINESTYLE,THICK=GRID_THICK
  ENDELSE

; ===> Get min and max X values to plot the regression line
  XD = MINMAX(XD)    
  GONE, YD  

; ===> Get x and y axis limits for subsequent placement of statistics legend
; and for proper plotting of one2one line and regression line

  XCRANGE= !X.CRANGE
  YCRANGE= !Y.CRANGE
  IF _loglog THEN BEGIN
    XCRANGE= (10.0d*DOUBLE(_loglog))^!X.CRANGE
    YCRANGE= (10.0d*DOUBLE(_loglog))^!Y.CRANGE
  ENDIF

; ===> Over plot ONE2ONE line.
  IF KEYWORD_SET(ONE2ONE) THEN PO = PLOT(XRANGE,YRANGE,XRANGE=XRANGE,YRANGE=YRANGE,COLOR=PALLIST(ONE_COLOR),THICK=ONE_THICK,LINESTYLE=ONE_LINESTYLE,/OVERPLOT,BUFFER=BUFFER);ONE2ONE_NG,XRANGE,YRANGE,COLOR=PALLIST(ONE_color),THICK=ONE_thick,LINESTYLE=ONE_linestyle,BUFFER=BUFFER

; ===> Over plot REGRESSION line.
  IF NOT KEYWORD_SET(REG_NONE) THEN BEGIN

;		LLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLL
    FOR NTH = 0, N_ELEMENTS(MODEL)-1 DO BEGIN
    	AMODEL = MODEL[NTH]
    	OK_MODEL=WHERE(_STATS2.MODEL EQ AMODEL,COUNT_MODEL)

    	IF COUNT_MODEL EQ 0 THEN CONTINUE  ;        >>>>>>>>>>>>>>>>>>>>>

      IF NOT _LOGLOG THEN YD =       _STATS2(OK_MODEL).INT + _STATS2(OK_MODEL).slope*XD $
                     ELSE YD = 10.0^(_STATS2(OK_MODEL).INT + _STATS2(OK_MODEL).slope*ALOG10(XD))
      IF N_ELEMENTS(REG_COLOR)     NE 3 THEN RGB_COLOR = PALLIST(REG_COLOR[NTH]) ELSE RGB_COLOR = REG_COLOR                     
      IF N_ELEMENTS(REG_MID_COLOR) NE 3 THEN RGB_MID_COLOR = PALLIST(REG_MID_COLOR[NTH]) ELSE RGB_MID_COLOR = REG_MID_COLOR
      PR1 = PLOT(XD,YD,COLOR=RGB_COLOR,    THICK=REG_THICK[NTH],    LINESTYLE=0,                     /OVERPLOT,BUFFER=BUFFER)
      PR2 = PLOT(XD,YD,COLOR=RGB_MID_COLOR,THICK=REG_MID_THICK[NTH],LINESTYLE=REG_MID_LINESTYLE[NTH],/OVERPLOT,BUFFER=BUFFER)      
    ENDFOR ; FOR NTH = 0, N_ELEMENTS(MODEL)-1 DO BEGIN
  ENDIF

; ===> Plot Mean X,Y position
  IF  KEYWORD_SET(MEAN_SHOW) THEN BEGIN
    IF NOT _LOGLOG THEN PM=PLOT(_stats2[0].MEAN_X,_stats2[0].MEAN_Y,PSYM=mean_psym,SYMSIZE=mean_symsize,COLOR=PALLIST(mean_color),THICK=mean_thick,/OVERPLOT,BUFFER=BUFFER) $
                   ELSE PM=PLOT(10.0^_stats2[0].MEAN_X, 10.0^_stats2[0].MEAN_Y,PSYM=mean_psym,SYMSIZE=mean_symsize,COLOR=PALLIST(mean_color),THICK=mean_thick,/OVERPLOT,BUFFER=BUFFER)
  ENDIF

; ===> Plot Regression Statistics  - NEEDS TO BE FIXED FOR NG PLOTS
  IF NOT KEYWORD_SET(stats_none) THEN BEGIN
    _pos = [!X.S[1]*!X.CRANGE + !X.S[0],$
            !Y.S[1]*!Y.CRANGE + !Y.S[0]]
    IF NOT KEYWORD_SET(stats_pos) OR N_ELEMENTS(stats_pos) NE 2 THEN $
      STATS_POS = [0.25,.75]
    X_POS= (_POS[1]-_POS[0])*STATS_POS[0]+ _POS[0]
    Y_POS= (_POS(3)-_POS(2))*STATS_POS[1]+ _POS(2)

   ; IF N_ELEMENTS(STATS_POS) NE 2 THEN STATS_POS = [0.15,0.77]
    
    stats_txt = ''
;		LLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLL
    FOR NTH = 0, N_ELEMENTS(MODEL)-1 DO BEGIN
    	AMODEL = MODEL[NTH]
    	OK_MODEL=WHERE(_STATS2.MODEL EQ AMODEL,COUNT_MODEL)
    	IF COUNT_MODEL EQ 0 THEN CONTINUE  ;        >>>>>>>>>>>>>>>>>>>>>
      stats_txt = stats_txt + _STATS2(OK_MODEL).statstring  +'!C'
    ENDFOR
    T = TEXT(STATS_POS[0],STATS_POS[1],stats_txt,/NORMAL,COLOR=PALLIST(STATS_COLOR),FONT_NAME=FONT,FONT_SIZE=stats_charsize,BUFFER=BUFFER)
  ENDIF


; ===> Plot a Legend using JHUAPL program LEG.PRO
  IF  KEYWORD_SET(LEG_SHOW) THEN BEGIN
  STOP ; WILL NEED TO BE FIXED FOR NG PLOTS
    IF NOT KEYWORD_SET(leg_pos) OR N_ELEMENTS(leg_pos) NE 4 THEN BEGIN
     xyz=CONVERT_COORD(!X.CRANGE[1],!Y.CRANGE[0],/DATA,/TO_NORMAL)
     leg_pos = [xyz[0]-.2, .1,.85, xyz[1]+.2]
    ENDIF
    TXT = ''
    START = 1

;		LLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLL
    FOR NTH = 0,N_ELEMENTS(MODEL)-1 DO BEGIN
    	AMODEL = MODEL[NTH]
    	OK_MODEL=WHERE(_STATS2.MODEL EQ AMODEL,COUNT_MODEL)
    	IF COUNT_MODEL EQ 0 THEN CONTINUE  ;        >>>>>>>>>>>>>>>>>>>>>
      IF START EQ 1 THEN BEGIN
        TXT =   STRTRIM(_STATS2(OK_MODEL).(1),2)
        START = 0
      ENDIF ELSE BEGIN
        TXT = [TXT,STRTRIM(_STATS2(OK_MODEL).(1),2)]
      ENDELSE
    ENDFOR
		BOX=[255, 0,  1, 0.75, 0.8]
   	LEG,POS=leg_pos,LINESTYLE=reg_linestyle,label=TXT,BOX=BOX   ; JHUAPL PROGRAM, IF YOU HAVE IT
  ENDIF
 RETURN, P
 SKIP:   ; SKIP HERE IF INSUFFICIENT N OF OBS
END
