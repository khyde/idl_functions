; $ID:	PERIOD_DATE_PLOT.PRO,	2020-06-30-17,	USER-KJWH	$
;    July 3, 2003

PRO PERIOD_DATE_PLOT,FILES=FILES, PS=ps, PERIOD=period,LABEL=label,DIR=dir, BAR_COLOR=bar_color

;
; J.E.O'Reilly, NOAA, NARRAGANSETT, RI.
;
; NAME:
;       PERIOD_DATE_PLOT
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
  ROUTINE_NAME='PERIOD_DATE_PLOT'

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
  FN = PARSE_IT(files,/ALL)

; ===>
	OK = WHERE(FN.PERIOD NE '',COUNT)
	IF COUNT GE 1 THEN FA=FA[OK] ELSE GOTO, DONE

  TITLE = FN[0].SENSOR + '   ' + FN[0].MAP    + '    ' + LABEL

  JULIAN=DT_DATE2JULIAN(FN.DATE_START)

; ===> Get year,day,hour, day of year, and days per year from julian
  year = STRING(JULIAN,FORMAT='(C(CYI4))')
  MONTH= STRING(JULIAN,FORMAT='(C(CMOI2))')
  DAY  = STRING(JULIAN,FORMAT='(C(CDI2))')
  HOUR = STRING(JULIAN,FORMAT='(C(CHI2))')
  DOY  = DT_JULIAN2DOY(JULIAN)

; ===> Get range of years
  min_yr = LONG(MIN(year))
  max_yr = LONG(MAX(year))
  PANELS = (max_yr - min_yr +1 ) > 1 ;
  SETCOLOR,255


; ************************************************
; Generate list of days of year with no data
; ************************************************
  LIST,FILE=DIR+LABEL+'_no_doy.txt',/NOSEQ,/NOHEADING,NOTES='NO DOY'
; ===> Make up a complete year+days string for all years and days
  FOR yr=min_yr,max_yr DO BEGIN
    DPY  = DT_DAYS_YEAR(yr)
    DAYS = INDGEN(DPY)+1
    IF N_ELEMENTS(YRDAYS) EQ 0 THEN BEGIN
      YRDAYS = STRTRIM(YR,2)+STRTRIM(DAYS,2)
    ENDIF ELSE BEGIN
      YRDAYS = [YRDAYS,STRTRIM(YR,2)+STRTRIM(DAYS,2)]
    ENDELSE
  ENDFOR

  OK = WHEREIN(YRDAYS, STRTRIM(YEAR,2)+STRTRIM(FIX(DOY),2),COUNT,COMPLEMENT=COMPLEMENT,NCOMPLEMENT=NCOMPLEMENT)
  IF NCOMPLEMENT GE 1 THEN BEGIN
    _YR = STRMID(YRDAYS(COMPLEMENT),0,4)
    _DOY= STRMID(YRDAYS(COMPLEMENT),5)
    _DATE = DT_ydoy2date(_YR,_DOY)
    TXT= _YR+' ' +_DOY+' '+_DATE
    LIST,FILE=DIR+LABEL+'_no_doy.txt',/NOSEQ,/NOHEADING, TXT
  ENDIF ELSE BEGIN
    LIST,FILE=DIR+LABEL+'_no_doy.txt',/NOSEQ,/NOHEADING,NOTES='NONE MISSING'
  ENDELSE


; ****************************************************************
  IF KEYWORD_SET(PS) THEN PSPRINT,FILENAME=DIR+LABEL+'_1.ps',/full
  !P.multi=[0,1,panels]
  FOR _yr = min_yr, max_yr, 1L DO BEGIN
    xtitle = NUM2STR(_yr)
    xtickv = TOTAL(dt_days_month(YEAR=year_), /CUMULATIVE)
    OK_year = WHERE(year EQ _yr,COUNT_year)
    IF COUNT_YEAR GE 1 THEN BEGIN
;     ===> Make a Julian axis for this year
      first_julian= JULDAY(1, 1, _yr,0,0,0)
      last_julian = JULDAY(12, 31, _yr,23,59,59)
      DA=DT_AXIS(  [first_julian ,last_julian ] ,/month)
        HISTPLOT,JULIAN(OK_year),XRANGE=[first_julian,last_julian],$
                XTICKS=DA.TICKS,XTICKV=DA.TICKV,XTICKNAME=DA.TICKNAME,$
                XTITLE=XTITLE,/XSTYLE,/YSTYLE,TITLE=TITLE, params=[0]
    ENDIF
   ENDFOR
   CAPTION
   IF KEYWORD_SET(PS) THEN PSPRINT ELSE STOP
; |||||||||||||||||||||||||||||||||||||||||||


; ***********************************************************************
  IF KEYWORD_SET(PS) THEN PSPRINT,FILENAME=DIR+LABEL+'_2.ps',/full,/COLOR
  !P.multi=[0,1,panels]
  FOR _yr = min_yr, max_yr, 1L DO BEGIN
    xtickv = TOTAL(dt_days_month(YEAR=year_), /CUMULATIVE)
    OK = WHERE(year EQ _yr,COUNT)
    IF COUNT GE 1 THEN BEGIN
;     Make a Julian axis for this year
      first_julian= JULDAY(1, 1, _yr,0,0,0)
      last_julian = JULDAY(12, 31, _yr,23,59,59)
      DA=DT_AXIS(  [first_julian ,last_julian ] ,/month)

      PLOT,JULIAN[OK],DAY[OK],XRANGE=[first_julian,last_julian],$
                XTICKS=DA.TICKS,XTICKV=DA.TICKV,XTICKNAME=DA.TICKNAME,$
                XTITLE=XTITLE,/XSTYLE,TITLE=TITLE,$
                ytitle='Day',yrange=[0,32], ystyle=1,yticks=16,PSYM=1,$
                XTICK_GET=XTICK_GET,YTICK_GET=YTICK_GET,/NODATA

      GRIDS,XTICK_GET,YTICK_GET,COLOR=221
      ; OPLOT,JULIAN(OK),day(OK),PSYM=2,SYMSIZE=1

      _JULIAN=JULIAN[OK] & _DAY=DAY[OK] &
      YMD=YEAR[OK]+MONTH[OK]+DAY[OK]+'000000' & YMD=REPLACE(YMD,' ','0')
      S=SORT(YMD) & YMD=YMD(S) & _JULIAN=_JULIAN(S) & _DAY=_DAY(S)
      U=UNIQ(YMD)

      FOR _U = 0,N_ELEMENTS(U)-1 DO BEGIN
        AYMD = YMD(U(_U))
        _OK = WHERE(YMD EQ AYMD)
        JULIAN_DATE = DT_DATE2JULIAN(YMD(_OK))

        CIRCLE,2,COLOR=N_ELEMENTS(_OK),FILL=0,THICK= N_ELEMENTS(_OK)
        PLOTS, JULIAN_DATE,_DAY(_OK),PSYM=8,SYMSIZE=1
      ENDFOR

    ENDIF
   ENDFOR
   CAPTION
   IF KEYWORD_SET(PS) THEN PSPRINT ELSE STOP
; |||||||||||||||||||||||||||||||||||||||||||



; ****************************************************************
  IF KEYWORD_SET(PS) THEN PSPRINT,FILENAME=DIR+LABEL+'_3.ps',/full
  !P.multi=[0,1,panels]
  circle,2,fill=0,/ROTATE,COLOR=0

  FOR _yr = min_yr, max_yr, 1L DO BEGIN
    xtitle = NUM2STR(_yr)
    xtickv = TOTAL(dt_days_month(YEAR=year_), /CUMULATIVE)
    OK = WHERE(year EQ _yr,COUNT)
    IF COUNT GE 1 THEN BEGIN
;     Make a Julian axis for this year
      first_julian= JULDAY(1, 1, _yr,0,0,0)
      last_julian = JULDAY(12, 31, _yr,23,59,59)
      DA=DT_AXIS(  [first_julian ,last_julian ] ,/month)
      PLOT,JULIAN[OK],HOUR[OK],XRANGE=[first_julian,last_julian],$
                XTICKS=DA.TICKS,XTICKV=DA.TICKV,XTICKNAME=DA.TICKNAME,$
                XTITLE=XTITLE,/XSTYLE,TITLE=TITLE,$
                ytitle='Hours',yrange=[0,24], ystyle=1,yticks=12,PSYM=8,SYMSIZE=0.9,$
                XTICK_GET=XTICK_GET,YTICK_GET=YTICK_GET,/NODATA


      GRIDS,XTICK_GET,YTICK_GET,COLOR=221
      OPLOT,JULIAN[OK],HOUR[OK],PSYM=8,SYMSIZE=0.8
    ENDIF
   ENDFOR
   CAPTION
   IF KEYWORD_SET(PS) THEN PSPRINT ELSE STOP
 ; |||||||||||||||||||||||||||||||||||||||||



  DONE:
  files=''
  julian=''
  !Y.OMARGIN=[0,0]
  !X.OMARGIN=[0,0]
END; OF PROGRAM
