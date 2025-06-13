; $ID:	PERIOD_PLOT.PRO,	2020-06-30-17,	USER-KJWH	$
;    Aug 12, 2003

PRO PERIOD_PLOT,FILES=FILES, PS=ps, PERIOD=period,DATE=DATE,LABEL=label,DIR=dir, $
								BAR_COLOR=bar_color,GRIDS_NONE=grids_none,GRIDS_COLOR=GRIDS_COLOR,$
								YR_CHARSIZE=YR_CHARSIZE,N_CHARSIZE=n_charsize,MONTH_CHARSIZE=month_charsize


;
; J.E.O'Reilly, NOAA, NARRAGANSETT, RI.
;
; NAME:
;       PERIOD_PLOT
;
; PURPOSE:
;       Plot Periods (DATES) of files
;
; OUTPUTS:
;       IF PS SET THEN 4 POSTSCRIPT FILES
 ; RESTRICTIONS:
;        Requires STANDARD PERIOD DATES

; MODIFICATION HISTORY:
;       Written by:  J.E.O'Reilly, October 24,1998
;       FROM SAT_DATE_PLOT.PRO
;-

; ############################################################
  ROUTINE_NAME='PERIOD_PLOT'

  !Y.OMARGIN=[1,7]
  !X.OMARGIN=[1,2]
  PAL_36,R,G,B

; +=====> If output directory not provided, write PS file to idl work directory
  IF N_ELEMENTS(DIR) LT 1 THEN DIR = ''
  IF N_ELEMENTS(LABEL) LT 1 THEN LABEL = ROUTINE_NAME
; =====> IF image names (PERIOD) used then skip this
  IF N_ELEMENTS(PERIOD) GE 1 THEN BEGIN
    FILES = PERIOD
    GOTO, SKIP_FILES
  ENDIF

; =====> Check if file names were provided. If not, then program prompts for file names.
  IF N_ELEMENTS(FILES) LT 1 THEN BEGIN
    files = ''
    READ,FILES,PROMPT='Enter Names Files to Processes'
  ENDIF

; =====> Get the files
  IF STRPOS(FILES[0],'*') GE 0 THEN BEGIN
    files = FILELIST(files,/sort)
  ENDIF

  IF N_ELEMENTS(FILES) EQ 0 THEN BEGIN
    PRINT,'NO FILES FOUND'
    GOTO,DONE
  ENDIF


; **********
  SKIP_FILES:

; =====> Parse file names
	IF N_ELEMENTS(PERIOD) GE 1 THEN BEGIN
	  FN = VALID_PERIODS(PERIOD)
	ENDIF ELSE BEGIN
  	FN = PARSE_IT(files,WITH_PERIOD=1,/ALL)
  ENDELSE


; ===>
	OK = WHERE(FN.PERIOD NE '',COUNT)
	IF COUNT GE 1 THEN FN=FN[OK] ELSE GOTO, DONE  ; >>>>>>>>>>>>>>>>>>>>>

  IF N_ELEMENTS(PERIOD) EQ 0 THEN TITLE = FN[0].SENSOR + '   ' + FN[0].MAP    + '    ' + LABEL ELSE TITLE = LABEL

  JD=DATE_2JD(FN.DATE_START)


	IF N_ELEMENTS(YEAR_CHARSIZE) NE 1 	THEN YEAR_CHARSIZE 	= 0.75
	IF N_ELEMENTS(MONTH_CHARSIZE) NE 1 	THEN MONTH_CHARSIZE = 1.75
	IF N_ELEMENTS(N_CHARSIZE) NE 1 			THEN N_CHARSIZE 		= 0.6

; ===> Get year,day,hour, day of year, and days per year from JD
  year = STRING(JD,FORMAT='(C(CYI4))')
  MONTH= STRING(JD,FORMAT='(C(CMOI2))')
  DAY  = STRING(JD,FORMAT='(C(CDI2))')
  HOUR = STRING(JD,FORMAT='(C(CHI2))')
  DOY  = NUM2STR(FIX(JD_2DOY(JD)),LEADING=3)

; ===> Get range of years
  min_yr = LONG(MIN(year))
  max_yr = LONG(MAX(year))
  PANELS = (max_yr - min_yr +1 ) > 1 ;
  SETCOLOR,255


; ************************************************
; Generate list of days of year with no data
; ************************************************
  LI,FILE=DIR+LABEL+'_no_doy.txt',/NOSEQ,/NOHEADING,NOTES='NO DOY'
; ===> Make up a complete year+days string for all years and days
  FOR yr=min_yr,max_yr DO BEGIN
    DPY  = DATE_DAYS_YEAR(yr)
    DAYS = NUM2STR(INDGEN(DPY)+1,LEADING=3)
    IF N_ELEMENTS(YRDAYS) EQ 0 THEN YRDAYS = STRTRIM(YR,2) + DAYS ELSE YRDAYS = [YRDAYS, STRTRIM(YR,2)+DAYS]
  ENDFOR
  OK = WHERE_IN(YRDAYS,  YEAR+DOY,COUNT,COMPLEMENT=COMPLEMENT,NCOMPLEMENT=NCOMPLEMENT)
  IF NCOMPLEMENT GE 1 THEN BEGIN
    _YR = STRMID(YRDAYS(COMPLEMENT),0,4)
    _DOY= STRMID(YRDAYS(COMPLEMENT),4,3)
    _DATE = JD_2DATE(YDOY_2JD(_YR,_DOY))
    TXT= _YR+' ' +_DOY+' '+_DATE
    LIST,FILE=DIR+LABEL+'_no_doy.txt',/NOSEQ,/NOHEADING, TXT
  ENDIF ELSE BEGIN
    LIST,FILE=DIR+LABEL+'_no_doy.txt',/NOSEQ,/NOHEADING,NOTES='NONE MISSING'
  ENDELSE



; ****************************************************************
  IF KEYWORD_SET(PS) THEN BEGIN
  	PS_FILE = DIR+LABEL+'.ps'
  	PS_FILE = REPLACE(PS_FILE,' ','_')
  	PSPRINT,FILENAME=PS_FILE,/full,/COLOR
  ENDIF
  PAL_36,R,G,B
  !P.multi=[0,1,panels]
  OLD_X_OMARGIN = !X.OMARGIN
  !X.OMARGIN = [4,10]

  OLD_Y_MARGIN = !Y.MARGIN
  !Y.MARGIN = [0,0]

	MAX_FREQUENCY = -1L
	FREQ_YEAR = LONARR(MAX_YR-MIN_YR+1)
;	===> Cycle through the years to find the maximum frequency
;	LLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLL
	FOR _yr = min_yr, max_yr, 1L DO BEGIN
	 	OK_year = WHERE(year EQ _yr,COUNT_year)
	  IF COUNT_YEAR GE 1 THEN H=HISTOGRAM(JD(OK_year),MIN=FIRST_JD,MAX=LAST_JD,BINSIZE=1.0D) ELSE H = 0
	  FREQ_YEAR(_YR-min_yr) = TOTAL(H)
    MAX_FREQUENCY = MAX_FREQUENCY > MAX(H)
	ENDFOR

	YRANGE = [0,MAX_FREQUENCY]
	Y_MID_RANGE = MEAN(YRANGE)
 	YTICKS = 1

;	LLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLL
	FOR _yr = min_yr, max_yr, 1L DO BEGIN
    xtickv = TOTAL(DAYS_MONTH(YEAR=year_), /CUMULATIVE)

;   ===> Make a JD axis for this year
    first_JD= JULDAY(1, 1, _yr,0,0,0)
    last_JD = JULDAY(12, 31, _yr,23,59,59)
    DA=DATE_AXIS(  [first_JD ,last_JD ] ,/month)
    IF _yr NE max_yr THEN BEGIN
     	XTICKNAME=REPLICATE(' ',N_ELEMENTS(DA.TICKNAME))
     	XSTYLE=5
    ENDIF ELSE BEGIN
     	XTICKNAME=DA.TICKNAME
    	XSTYLE=1
    ENDELSE

		YTICKS = 1
		TICKV = [0,MAX_FREQUENCY]
		TITLE = ' '
    YTICKNAME=[' ',' ']
    XTITLE = ' '
    YTICKLEN= 0.0001
    YSTYLE=5

    IF _yr EQ max_yr THEN XTITLE='Month'

		OK_year = WHERE(year EQ _yr,COUNT_year)
		IF COUNT_YEAR GE 1 THEN $
      HISTPLOT,JD(OK_year),XRANGE=[first_JD,last_JD],YRANGE=YRANGE,$
      					YTICKS=YTICKS,YTICKV=YTICKV,YTICKNAME=YTICKNAME,$
                XTICKS=DA.TICKS,XTICKV=DA.TICKV,XTICKNAME=XTICKNAME,$
                XTITLE=XTITLE,XSTYLE=XSTYLE,YTITLE=ytitle,YSTYLE=5,TITLE= '',/STATS_NONE, BAR_COLOR=BAR_COLOR,BINSIZE=1.0D,/CUM_NONE,XCHARSIZE=MONTH_CHARSIZE,$
                bar_outline=0,GRIDS_NONE=GRIDS_NONE,grids_color=grids_color,$
                YTICKLEN=0.0001 $
    ELSE $
      HISTPLOT,[0,0],XRANGE=[first_JD,last_JD],YRANGE=YRANGE,$
      					YTICKS=YTICKS,YTICKV=YTICKV,YTICKNAME=YTICKNAME,$
                XTICKS=DA.TICKS,XTICKV=DA.TICKV,XTICKNAME=XTICKNAME,$
                XTITLE=XTITLE,XSTYLE=XSTYLE,YTITLE=ytitle,YSTYLE=5,TITLE= '',/STATS_NONE, BAR_COLOR=BAR_COLOR,BINSIZE=1.0D,/CUM_NONE,XCHARSIZE=MONTH_CHARSIZE,$
                bar_outline=0,GRIDS_NONE=GRIDS_NONE,grids_color=grids_color,$
                YTICKLEN=0.0001

 		XYOUTS2, first_JD,Y_MID_RANGE,STRTRIM(_YR,2),  ALIGN=[1.1,0.5],/DATA,CHARSIZE=YEAR_CHARSIZE
		XYOUTS2, last_JD,Y_MID_RANGE,STRTRIM(FREQ_YEAR(_YR-min_yr),2),  ALIGN=[1.1,0.125],/DATA,CHARSIZE=N_CHARSIZE

		IF _yr eq MAX_YR THEN AXIS,YAXIS=1,YTICKLEN= -0.01,yticks=1,YTITLE='Frequency'
    XYOUTS,0.5,0.96,/NORMAL,TITLE,align=0.5
  ENDFOR

  !X.OMARGIN = OLD_X_OMARGIN
  !Y.MARGIN = OLD_Y_MARGIN


; ***********************************************************************

  PAL_36,R,G,B
  !P.multi=[0,1,panels]
  FOR _yr = min_yr, max_yr, 1L DO BEGIN
    xtickv = TOTAL(DAYS_MONTH(YEAR=year_), /CUMULATIVE)
    OK = WHERE(year EQ _yr,COUNT)
    IF COUNT GE 1 THEN BEGIN
;     Make a JD axis for this year
      first_JD= JULDAY(1, 1, _yr,0,0,0)
      last_JD = JULDAY(12, 31, _yr,23,59,59)
      DA=DATE_AXIS(  [first_JD ,last_JD ] ,/month)

      PLOT,JD[OK],DAY[OK],XRANGE=[first_JD,last_JD],$
                XTICKS=DA.TICKS,XTICKV=DA.TICKV,XTICKNAME=DA.TICKNAME,$
                XTITLE=XTITLE,/XSTYLE,TITLE=TITLE,$
                ytitle='Day',yrange=[0,32], ystyle=1,yticks=16,PSYM=1,$
                XTICK_GET=XTICK_GET,YTICK_GET=YTICK_GET,/NODATA


;PRO GRIDS,X=XX,Y=YY, NO_X=no_x,NO_Y=no_y, ALL=all,AUTO=auto, _EXTRA=_extra

      GRIDS,X=XTICK_GET,YY=YTICK_GET,COLOR=221
      ; OPLOT,JD(OK),day(OK),PSYM=2,SYMSIZE=1

      _JD=JD[OK] & _DAY=DAY[OK] &
      YMD=YEAR[OK]+MONTH[OK]+DAY[OK]+'000000' & YMD=REPLACE(YMD,' ','0')
      S=SORT(YMD) & YMD=YMD(S) & _JD=_JD(S) & _DAY=_DAY(S)
      U=UNIQ(YMD)

      FOR _U = 0,N_ELEMENTS(U)-1 DO BEGIN
        AYMD = YMD(U(_U))
        _OK = WHERE(YMD EQ AYMD)
        JD_DATE = DATE_2JD(YMD(_OK))

        CIRCLE,2,COLOR=N_ELEMENTS(_OK),FILL=0,THICK= N_ELEMENTS(_OK)
        PLOTS, JD_DATE,_DAY(_OK),PSYM=8,SYMSIZE=1
      ENDFOR

    ENDIF
   ENDFOR
   CAPTION

; |||||||||||||||||||||||||||||||||||||||||||


; ****************************************************************

  PAL_36,R,G,B
  !P.multi=[0,1,panels]
  circle,2,fill=0,/ROTATE,COLOR=0

  FOR _yr = min_yr, max_yr, 1L DO BEGIN
    xtitle = NUM2STR(_yr)
    xtickv = TOTAL(DAYS_MONTH(YEAR=year_), /CUMULATIVE)
    OK = WHERE(year EQ _yr,COUNT)
    IF COUNT GE 1 THEN BEGIN
;     Make a JD axis for this year
      first_JD= JULDAY(1, 1, _yr,0,0,0)
      last_JD = JULDAY(12, 31, _yr,23,59,59)
      DA=DATE_AXIS(  [first_JD ,last_JD ] ,/month)
      PLOT,JD[OK],HOUR[OK],XRANGE=[first_JD,last_JD],$
                XTICKS=DA.TICKS,XTICKV=DA.TICKV,XTICKNAME=DA.TICKNAME,$
                XTITLE=XTITLE,/XSTYLE,TITLE=TITLE,$
                ytitle='Hours',yrange=[0,24], ystyle=1,yticks=12,PSYM=8,SYMSIZE=0.9,$
                XTICK_GET=XTICK_GET,YTICK_GET=YTICK_GET,/NODATA


      GRIDS,X=XTICK_GET,Y=YTICK_GET,COLOR=221
      OPLOT,JD[OK],HOUR[OK],PSYM=8,SYMSIZE=0.8
    ENDIF
   ENDFOR
   CAPTION


   IF KEYWORD_SET(PS) THEN PSPRINT
 ; |||||||||||||||||||||||||||||||||||||||||



  DONE:
  files=''
  JD=''
  !Y.OMARGIN=[0,0]
  !X.OMARGIN=[0,0]
END; OF PROGRAM
