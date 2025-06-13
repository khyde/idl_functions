; $ID:	DJIA_MAIN.PRO,	2020-06-30-17,	USER-KJWH	$
;+
;	This Program is a MAIN for DJIA
;
; http://www.djindexes.com/mdsidx/index.cfm?event=showtotalMarketIndexData&perf=Historical%20Values
;http://www.ibiblio.org/pub/archives/misc.invest/historical-data/index/stocks/dow/
; http://www.ibiblio.org/pub/archives/misc.invest/historical-data/index/stocks/dow/dow.79-90/
;-
; *************************************************************************

PRO DJIA_MAIN  , AUTO=AUTO
  ROUTINE_NAME='DJIA_MAIN'
; *******************************************
; DEFAULTS
	DIR_PROGRAMS       = 'D:\IDL\PROGRAMS\'
	DIR_DATA					 = 'D:\IDL\DATA\'
	DIR_IMAGES				 = 'D:\IDL\IMAGES\'
	SP = ' '
	UL='_'
  PX=1024 & PY=1024
  PAL = 'PAL_36'
  ASENSOR = 'DJIA'
	AMETHOD = 'DJIA'
	ASUITE  = ''
	AMAP = ''
  OVERWRITE_BROWSE=0


 	BACKGROUND=252 &


; ====================> Disk depends on computer
  computer = GET_COMPUTER()
  IF computer EQ 'LOLIGO' 	THEN DISK = 'D:'
  IF computer EQ 'BURRFISH' THEN DISK = 'F:'
  IF computer EQ 'LAPSANG'  THEN DISK = 'F:'

  DISK_CD ='Z:'

; **************************
  DIR_GZIP 			= 'C:\GZIP\'
  DIR_landmask 	= 'D:\IDL\IMAGES\'

; ===================>
; Different delimiters for WIN, MAX, AND X DEVICES
  os = STRUPCASE(!VERSION.OS)
  computer=GET_COMPUTER()
  DELIM=DELIMITER(/path)


  SET_PLOT,'WIN'
  DATE=DATE_NOW()

; ****************************************************************************************
; ********************* U S E R    S W I T C H E S  *************************************
; ****************************************************************************************
; Switches controlling overwriting if the file already exists (usually do not overwrite : 0)

;  ************************************************
   path = DISK + delim+ 'DJIA'  + delim ;;;

; ================>
; Switches controlling which Processing STEPS to do.
; The steps are in order of execution


  DO_CHECK_DIRS  			        	=1  ; Normally, keep this switch on

  DO_DJIA_EDIT_INDEX      			=1  ;
  DO_DJIA_INDEX_PLOT      			=1  ;


; **************************************
; Directories
; Edit these as needed
  DIR_DATA  = 			path+'DATA'+	delim
  DIR_SAVE   = 			path+'SAVE'+	delim
  DIR_STATS  = 			path+'STATS'+	delim

  DIR_STATS_PLOT = 	path+'STATS_PLOT'+	delim


  DIR_LOG		= 			path+'log' 			+ 	delim
  DIR_REPORT = 			path+'report'		+ 	delim
  DIR_PLOTS = 			path+'plots'		+ 	delim


  DIR_ALL = [DIR_DATA,DIR_SAVE,DIR_STATS,DIR_STATS_PLOT,$
             DIR_LOG,DIR_REPORT,DIR_PLOTS]

  STATUS = ''


; *********************************************
	IF DO_CHECK_DIRS EQ 1 THEN BEGIN
; *********************************************
    PRINT, 'S T E P:    DO_CHECK_DIRS'
    FOR N=0,N_ELEMENTS(DIR_ALL)-1 DO BEGIN & AFILE = STRMID(DIR_ALL(N),0,STRLEN(DIR_ALL(N))-1) &
    	IF FILE_TEST(AFILE,/DIRECTORY) EQ 0L THEN FILE_MKDIR,AFILE &  ENDFOR
  ENDIF
; |||||||||||||||||||||||||||||||||||||||||||||||||




; *********************************************
	IF DO_DJIA_EDIT_INDEX EQ 1 THEN BEGIN
; *********************************************
    PRINT, 'S T E P:    DO_DJIA_EDIT'
    FILE= 'DowJones.xls' ; ACTUALLY A CSV


		FILE=DIR_DATA+ FILE
		LIST, FILE
		N_FILE=N_ELEMENTS(FILE)


;		===> Tab-delimited, Read as text, edit
;		Historical Index for Dow Jones Averages Friday, April 2, 2004 Time : 7:04:03 AM
;		Trade Date	Country 	Currency 	Group 	Mkt.Cap Range	PClose	TRClose
;		18960526	US	USD	 DJ Ind.  [DJI]	Broad	40.94	0
		txt=READ_TXT(FILE)

		ok=WHERE(STRPOS(TXT,'Trade Date') ge 0,count)
		IF COUNT GE 1 THEN TXT=TXT(FIRST[OK]:*) ELSE STOP
		ok=WHERE(STRPOS(TXT,'Note') eq -1,count)
		IF COUNT GE 1 THEN TXT=TXT(ok) ELSE STOP
		ok=WHERE(STRPOS(TXT,'--') eq -1,count)
		IF COUNT GE 1 THEN TXT=TXT(ok) ELSE STOP
		ok=WHERE(STRLEN(TXT) GE 10,count)
		IF COUNT GE 1 THEN TXT=TXT(ok) ELSE STOP

		LINE=TXT[0]
		LINE=REPLACE(LINE,'Trade Date','DATE')
		LINE=REPLACE(LINE,'.','_')
		LINE=REPLACE(LINE,'PClose','INDEX')

	  TXT[0]=LINE
	  STRUCT=TXT_2STRUCT(TXT,DELIM='TAB')
	  STRUCT=STRUCT_RENAME(STRUCT,['_0','_5'],['DATE','INDEX'])
	  STRUCT=STRUCT(1:*)
	  STRUCT=STRUCT_COPY(STRUCT,TAGNAMES=['DATE','INDEX'])
	  SAVEFILE=DIR_SAVE+'DJIA_INDEX.SAVE'
  	SAVE,FILENAME=SAVEFILE,STRUCT,/COMPRESS
		SAVE_2CSV,SAVEFILE

  ENDIF
; |||||||||||||||||||||||||||||||||||||||||||||||||


; *********************************************
	IF DO_DJIA_INDEX_PLOT EQ 1 THEN BEGIN
; *********************************************
    PRINT, 'S T E P:    DO_DJIA_TILE_AVG'
    TARGETS = DIR_SAVE+ 'DJIA_INDEX.SAVE'
    FILE = FILELIST(TARGETS)
  	LIST, FILE
  	D=READALL(FILE)
  	JD=DATE_2JD(D.DATE)
  	DA=DT_AXIS(JD,/YEAR,ROOM=[1,1])
  	FN=PARSE_IT(FILE)
  	PSFILE=DIR_PLOTS+FN.NAME+'.PS'
 		PSPRINT,FILENAME=PSFILE,/COLOR,/FULL,/TIMES
 		!P.MULTI=[0,1,6]
 		PAL_36

 		PLOT,DA.DT, D.INDEX,  TITLE='DJIA', XTITLE='Date', YTITLE='Index',/NODATA,$
 				 XTICKS=DA.TICKS, XTICKV=DA.TICKV,XTICKNAME=DA.TICKNAME,XTICK_GET=XTICK_GET,YTICK_GET=YTICK_GET,XCHARSIZE=0.75
 		GRIDS,COLOR=34,XTICK_GET,YTICK_GET
 		OPLOT,JD,D.INDEX,COLOR=10

		PLOT,DA.DT, D.INDEX,  TITLE='DJIA', XTITLE='Date', YTITLE='Index',/NODATA,/YLOG,YRANGE=[40,20000],/YSTYLE,$
 				 XTICKS=DA.TICKS, XTICKV=DA.TICKV,XTICKNAME=DA.TICKNAME,XTICK_GET=XTICK_GET,YTICK_GET=YTICK_GET,XCHARSIZE=0.75
 		GRIDS,COLOR=34,XTICK_GET,YTICK_GET
 		OPLOT,JD,D.INDEX,COLOR=7


		LDATA=ALOG10(FLOAT(D.INDEX))
		PLOT,DA.DT, D.INDEX,  TITLE='DJIA', XTITLE='Date', YTITLE='Index',/NODATA,/YLOG,YRANGE=[40,20000],/YSTYLE,$
 				 XTICKS=DA.TICKS, XTICKV=DA.TICKV,XTICKNAME=DA.TICKNAME,XTICK_GET=XTICK_GET,YTICK_GET=YTICK_GET,XCHARSIZE=0.75
 		GRIDS,COLOR=34,XTICK_GET,YTICK_GET
 		OPLOT, JD, 10.^LDATA, COLOR=7
 		OPLOT, JD, 10.^SMOOTH(LDATA,366,/EDGE_TRUNCATE),COLOR=0,LINESTYLE=1

;		===> 4-5 DEGREE GIVES OVERALL RISE TREND FOR LOG10(INDEX)
	  COEFFS=POLY_FIT_ORTHO( JD, LDATA, 2, YFIT)
		OPLOT, JD, 10.^YFIT, COLOR= 21
 			delta = (LDATA-YFIT)

;		===> Plot difference between data and smooth trend
		PLOT,DA.DT, 10.^DELTA,  TITLE='DJIA', XTITLE='Date', YTITLE='Detrended Index',/NODATA,/YLOG,YRANGE=[0.3,2.4],/YSTYLE,$
 				 XTICKS=DA.TICKS, XTICKV=DA.TICKV,XTICKNAME=DA.TICKNAME,XTICK_GET=XTICK_GET,YTICK_GET=YTICK_GET,XCHARSIZE=0.75
 		GRIDS,COLOR=34,XTICK_GET,YTICK_GET

 		PLOT_EVENT,/YAXIS,1.0,COLOR=0,THICK=2
 		OPLOT, JD, 10.^DELTA, COLOR=21




;		*** LNP_TEST Using Original Data ***
		DYEAR=JD_2DYEAR(JD)

    DETRENDED = DELTA

		LABEL='DATA'+'!CN: '+NUM2STR(N_ELEMENTS(DETRENDED))
		HIGHEST_FREQUENCY = 100
		TIMES_=DYEAR

		N_SAMPLES=N_ELEMENTS(JD)
		TP=MAX(DYEAR)-MIN(DYEAR)
    T_AVG=TP/N_SAMPLES
		hifac=HIGHEST_FREQUENCY*(2*t_avg)
		P_DATA				=LNP_TEST(TIMES_-FIRST(TIMES_),DETRENDED,	WK1=WK1,	WK2=WK2,	OFAC=8,HIFAC=hifac,JMAX=JMAX)
		LABEL = LABEL+'!C'+ 'Peak: '+ NUM2STR(P_DATA[0],FORMAT='(F10.1)') + '!C'+ 'Period: '+ NUM2STR(WK1(JMAX),FORMAT='(F10.3)')
;		===> ACF Using Original Data
		LAG=FINDGEN(N_SAMPLES) & TP_ACF=TP
 		ACT=A_CORRELATE(DETRENDED, Lag  , /DOUBLE)
 		WIDTH=11
		TIME_FIRST_CROSS_ACT = ACF_FIRST_ZERO(ACT,Tp_ACF=Tp_ACF,WIDTH=WIDTH,SUBS=SUBS,SMO=SMO,  ERROR=error)
		LABEL = LABEL+'!C'+ 'ACT0: '+ NUM2STR(TIME_FIRST_CROSS_ACT,FORMAT='(F10.3)')
		PLOT,  WK1,WK2,/XLOG,/NODATA,XRANGE=[0.01,200],/XSTYLE,XTICK_GET=XTICK_GET,XTITLE='Frequency (1/year)'
		GRIDS,COLOR=34
		AXIS,XAXIS=1, XTICKV= XTICK_GET,XTICKNAME= NUM2STR(1./XTICK_GET,trim=2),XTITLE='YEARS',/xstyle
		OPLOT, WK1,WK2,COLOR=24
		s=COORD_2PLOT(.67,.8,/normal) 	& XYOUTS,S.X,S.Y,/DATA,LABEL,CHARSIZE=0.8,COLOR=COLOR_DATA


	  PLOT,  WK1,WK2,/XLOG,/YLOG,/NODATA,XRANGE=[0.01,200],/XSTYLE,XTICK_GET=XTICK_GET,XTITLE='Frequency (1/year)'
		GRIDS,COLOR=34
		AXIS,XAXIS=1, XTICKV= XTICK_GET,XTICKNAME= NUM2STR(1./XTICK_GET,trim=2),XTITLE='YEARS',/xstyle
		OPLOT, WK1,WK2,COLOR=24
		s=COORD_2PLOT(.67,.8,/normal) 	& XYOUTS,S.X,S.Y,/DATA,LABEL,CHARSIZE=0.8,COLOR=COLOR_DATA
		PSPRINT
		STOP


  ENDIF
; |||||||||||||||||||||||||||||||||||||||||||||||||



DONE:
PRINT,'END OF DJIA_MAIN.PRO'


END; #####################  End of Routine ################################
