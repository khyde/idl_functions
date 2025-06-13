; $ID:	NYSE_MAIN.PRO,	2020-06-30-17,	USER-KJWH	$
;+
;	This Program is a MAIN for NYSE
;

;
;-
; *************************************************************************

PRO NYSE_MAIN  , AUTO=AUTO
  ROUTINE_NAME='NYSE_MAIN'
; *******************************************
; DEFAULTS
	DIR_PROGRAMS       = 'D:\IDL\PROGRAMS\'
	DIR_DATA					 = 'D:\IDL\DATA\'
	DIR_IMAGES				 = 'D:\IDL\IMAGES\'
	SP = ' '
	UL='_'
  PX=1024 & PY=1024
  PAL = 'PAL_36'
  ASENSOR = 'NYSE'
	AMETHOD = 'NYSE'
	ASUITE  = ''
	AMAP = ''
  OVERWRITE_BROWSE=0


 	BACKGROUND=252 &


; ====================> Disk depends on computer
  computer = GET_COMPUTER()
  IF computer EQ 'LOLIGO' 	THEN DISK = 'G:'
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
   path = DISK + delim+ 'NYSE'  + delim ;;;



; ================>
; Switches controlling which Processing STEPS to do.
; The steps are in order of execution


  DO_CHECK_DIRS  			        	=1  ; Normally, keep this switch on
  DO_NYSE_EDIT_VOLUME      			=0  ;
  DO_NYSE_EDIT_INDEX      			=0  ;
  DO_NYSE_INDEX_PLOT      			=1  ;


; **************************************
; Directories
; Edit these as needed

  DIR_VOLUME = 			path+'VOLUME'+	delim
  DIR_INDEX  = 			path+'INDEX'+	delim
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
	IF DO_NYSE_EDIT_VOLUME EQ 1 THEN BEGIN
; *********************************************
    PRINT, 'S T E P:    DO_NYSE_EDIT'
    FILES= [$
	'vol-1899.dat',$
	'vol00-19.dat',$
	'vol20-29.dat',$
	'vol30-39.dat',$
	'vol40-49.dat',$
	'vol50-59.dat',$
	'vol60-69.dat',$
	'vol70-79.dat',$
	'vol80-89b.prn.txt',$
	'vol90-98a.prn.txt',$
	'vol99a.prn.txt',$
	'vol1200.prn.txt',$
	'vol1201.prn.txt',$
	'vol0212.prn.txt',$
	'Vol200312.prn.txt',$
	'Vol200401.prn.txt']
	FILES=DIR_VOLUME+ FILES
	LIST, FILES
	STOP

FOR NTH=0,N_ELEMENTS(FILES)-1 DO BEGIN
	PRINT, FILES[NTH]

	TXT=READ_DELIMITED(FILES[NTH],DELIM='SPACE')
	SPREAD,TXT
ENDFOR

  ENDIF
; |||||||||||||||||||||||||||||||||||||||||||||||||

; *********************************************
	IF DO_NYSE_EDIT_INDEX EQ 1 THEN BEGIN
; *********************************************
    PRINT, 'S T E P:    DO_NYSE_EDIT'
    FILES= [$
	'nya66-69.prn.txt',$
	'nya70-79.prn.txt',$
	'nya80-89.prn.txt',$
	'nya90-98.prn.txt',$
	'Nya99.prn.txt',$
	'nya1200.prn.txt',$
	'nya1201.prn.txt',$
	'nya1202.prn.txt',$
	'Nya1203_revised.prn.txt',$
	'Nya0204.prn.txt'] ;   NEWEST HAS MORE TAGS]

	FILES=DIR_INDEX+ FILES
	LIST, FILES
	N_FILES=N_ELEMENTS(FILES)

	FOR NTH=0,N_ELEMENTS(FILES)-1 DO BEGIN
		PRINT, FILES[NTH]
		S=READ_DELIMITED(FILES[NTH],DELIM='SPACE')
		S=STRUCT_COPY(S,TAGNAMES=['DATE','COMPOSITE'])
	  IF NTH EQ 0 THEN STRUCT = S ELSE STRUCT=STRUCT_CONCAT(STRUCT,S)
	ENDFOR

  OK=WHERE(STRUCT.COMPOSITE NE MISSINGS(STRUCT.COMPOSITE) AND STRUCT.COMPOSITE NE 'C' AND FLOAT(STRUCT.COMPOSITE NE 0.0))
  STRUCT=STRUCT[OK]
  NTAGS = N_TAGS(STRUCT)
  FOR NTH=0,NTAGS-1 DO BEGIN & STRUCT.(NTH) = REPLACE(STRUCT.(NTH),',','') & ENDFOR

  OK=WHERE(FLOAT(STRUCT.COMPOSITE) LT 1000.0,COUNT)
  IF COUNT GE 1 THEN STRUCT[OK].COMPOSITE =   STRTRIM( (FLOAT(STRUCT[OK].COMPOSITE) * 10),2)

  CSVFILE=DIR_SAVE+'NYSE_INDEX.CSV'
	STRUCT_2CSV,CSVFILE,STRUCT

  ENDIF
; |||||||||||||||||||||||||||||||||||||||||||||||||


; *********************************************
	IF DO_NYSE_INDEX_PLOT EQ 1 THEN BEGIN
; *********************************************
    PRINT, 'S T E P:    DO_NYSE_TILE_AVG'
    TARGETS = DIR_SAVE+ 'NYSE_INDEX.CSV'
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

 		PLOT,DA.DT, D.COMPOSITE,  TITLE='NYSE', XTITLE='Date', YTITLE='Index',/NODATA,$
 				 XTICKS=DA.TICKS, XTICKV=DA.TICKV,XTICKNAME=DA.TICKNAME,XTICK_GET=XTICK_GET,YTICK_GET=YTICK_GET,XCHARSIZE=0.75
 		GRIDS,COLOR=34,XTICK_GET,YTICK_GET
 		OPLOT,JD,D.COMPOSITE,COLOR=10

		PLOT,DA.DT, D.COMPOSITE,  TITLE='NYSE', XTITLE='Date', YTITLE='Index',/NODATA,/YLOG,YRANGE=[300,10000],/YSTYLE,$
 				 XTICKS=DA.TICKS, XTICKV=DA.TICKV,XTICKNAME=DA.TICKNAME,XTICK_GET=XTICK_GET,YTICK_GET=YTICK_GET,XCHARSIZE=0.75
 		GRIDS,COLOR=34,XTICK_GET,YTICK_GET
 		OPLOT,JD,D.COMPOSITE,COLOR=7


		LDATA=ALOG10(FLOAT(D.COMPOSITE))
		PLOT,DA.DT, D.COMPOSITE,  TITLE='NYSE', XTITLE='Date', YTITLE='Index',/NODATA,/YLOG,YRANGE=[300,10000],/YSTYLE,$
 				 XTICKS=DA.TICKS, XTICKV=DA.TICKV,XTICKNAME=DA.TICKNAME,XTICK_GET=XTICK_GET,YTICK_GET=YTICK_GET,XCHARSIZE=0.75
 		GRIDS,COLOR=34,XTICK_GET,YTICK_GET
 		OPLOT, JD, 10.^LDATA, COLOR=7
 		OPLOT, JD, 10.^SMOOTH(LDATA,366,/EDGE_TRUNCATE),COLOR=0,LINESTYLE=1

;		===> 4-5 DEGREE GIVES OVERALL RISE TREND FOR LOG10(INDEX)
	  COEFFS=POLY_FIT_ORTHO( JD, LDATA, 2, YFIT)
		OPLOT, JD, 10.^YFIT, COLOR= 21
 			delta = (LDATA-YFIT)

;		===> Plot difference between data and smooth trend
		PLOT,DA.DT, 10.^DELTA,  TITLE='NYSE', XTITLE='Date', YTITLE='Detrended Index',/NODATA,/YLOG,YRANGE=[0.499,2.01],/YSTYLE,$
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
PRINT,'END OF NYSE_MAIN.PRO'


END; #####################  End of Routine ################################
