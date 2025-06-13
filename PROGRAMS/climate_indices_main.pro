; $ID:	CLIMATE_INDICES_MAIN.PRO,	2020-07-08-15,	USER-KJWH	$
PRO CLIMATE_INDICES_MAIN

; Generate a plot illustrating the North Atlantic Oscillation Index

ROUTINE_NAME='CLIMATE_INDICES_MAIN'

;	******************************************
; ***** Directories for Resource Files *****
;	******************************************
  DIR_PROGRAMS       = !S.PROGRAMS
  DIR_DATA           = !S.DATA
  DIR_IMAGES         = !S.IMAGES

;	******************************
;	***** C O N S T A N T S  *****
;	******************************
  NOW = LONG(STRMID(DATE_NOW(),0,8))
  DELIM		=DELIMITER(/PATH) & SLASH=DELIMITER(/SLASH) & DASH=DELIMITER(/DASH) & UL=DELIMITER(/UL) & CM=DELIMITER(/COMMA) & AS = DELIMITER(/ASTER)
  NOW 		= NUM2STR(LONG(STRMID(DATE_NOW(),0,8)))



;	*************************************************
;	***** O U T P U T   D I R E C T O R I E S   *****
;	*************************************************	
	PROJECT_FOLDER = 'CLIMATE_INDICES'

  PATH = DISK_PROJECT+DELIM + 'PROJECTS\'+PROJECT_FOLDER+DELIM

  DIR_DATA       = path+'DATA'    +SLASH
  DIR_SAVE       = path+'SAVE'    +SLASH
  DIR_DOC        = path+'DOC'     +SLASH
  DIR_PLOTS      = path+'PLOTS'   +SLASH

  DIR_ALL = [DIR_DATA,DIR_SAVE,DIR_DOC,DIR_PLOTS]



;	******************************************************************
; *********** J O B  S W I T C H E S  ******************************
;	******************************************************************
	DO_CHECK_DIRS=1
	DO_FTP_GET 					= 0
	DO_TEL_INDEX_EDIT   = 0
	DO_PERIOD_STATS_INDICES 	= 0
	DO_PLOT_INDICES_SEASON  	= 1



;	###############################################
; #####  B E G I N   P R O C E S S I N G    #####
;	###############################################

; *********************************************
  IF DO_CHECK_DIRS GE 1 THEN BEGIN
; *********************************************
    PRINT, 'S T E P:    DO_CHECK_DIRS'
    FOR N=0,N_ELEMENTS(DIR_ALL)-1 DO BEGIN & AFILE = STRMID(DIR_ALL(N),0,STRLEN(DIR_ALL(N))-1) &
      IF FILE_TEST(AFILE,/DIRECTORY) EQ 0L THEN FILE_MKDIR,AFILE &  ENDFOR
  ENDIF
; |||||||||||||||||||||||||||||||||||||||||||||||||


; *********************************************
	IF DO_FTP_GET GE 1 THEN BEGIN
; *********************************************
    PRINT, 'S T E P:    DO_FTP_GET'

		FTP_SITE = 'ftpprd.ncep.noaa.gov'
		FTP_SITE = 'ftp.cpc.ncep.noaa.gov'

	  FTP_ACCOUNT = 'anonymous'
	  FTP_PASSWORD = "Jay.O'Reilly@noaa.gov"
	  DIR_REMOTE='pub/cpc/wd52dg/data/indices'
	  DIR_REMOTE='/cwlinks/'
	  DIR_LOCAL = DIR_DATA
; 	ftp://ftpprd.ncep.noaa.gov/pub/cpc/wd52dg/data/indices/tele_index.nh


    target='tele_index.nh'    ;
    target='norm*.ascii'

STOP
		ftp_batch, ftp_site=ftp_site,ACCOUNT='anonymous',PASSWORD = FTP_PASSWORD, $
					files = target, SKIP_LS=_skip_ls,DIR_REMOTE=DIR_REMOTE,DIR_LOCAL = DIR_LOCAL,$
					MIN_SIZE=min_size,INVENTORY=INVENTORY,N_FILES=FTP_n_files

  ENDIF ;IF DO_FTP_GET GE 1 THEN BEGIN
; |||||||||||||||||||||||||||||||||||||||||||||||||



; ************************************
	IF DO_TEL_INDEX_EDIT GE 1 THEN BEGIN
;	************************************
		FILES = FILE_SEARCH(DIR_DATA+'norm.daily.*.index.*.ascii')
		LIST, FILES

		FOR _FILE = 0,N_ELEMENTS(FILES)-1 DO BEGIN
			AFILE = FILES(_FILE)
			FN=FILE_PARSE(AFILE)
			FN_ = FILE_PARSE(FN.NAME)
			ANAME = FN.NAME
			IF STRPOS(ANAME,'.nao.') GE 0 THEN INDEX = 'NAO'
			IF STRPOS(ANAME,'.ao.') GE 0 THEN INDEX = 'AO'
			IF STRPOS(ANAME,'.pna.') GE 0 THEN INDEX = 'PNA'
			IF STRPOS(ANAME,'.aao.') GE 0 THEN INDEX = 'AAO'


			D=READ_DELIMITED(AFILE,DELIM='SPACE',/NOHEADING,TAGNAMES=['YEAR','MONTH','DAY','ANOM'])

			TEMP=REPLICATE(CREATE_STRUCT('INDEX','','DATE',''),N_ELEMENTS(D))
			D=STRUCT_MERGE(TEMP,D)

			D.DATE = YMDHMS_2DATE(D.YEAR,D.MONTH,D.DAY)
			D.INDEX=INDEX
			PRINT,INDEX,MM(D.DATE)

		  IF _FILE EQ 0 THEN DB=D ELSE DB=[DB,D]
		ENDFOR

;		===> CONVERT TO NUMERICS
		 DB=STRUCT_2NUM(DB,EXCLUDE='DATE')

		 SAVEFILE = DIR_SAVE + 'CLIMATE_INDICES.SAVE'
		 SAVE,FILENAME=SAVEFILE,DB,/COMPRESS

		 CSVFILE = DIR_SAVE + 'CLIMATE_INDICES.CSV'
     STRUCT_2CSV,CSVFILE,DB
	ENDIF
;	\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\



; ************************************
	IF DO_PERIOD_STATS_INDICES GE 1 THEN BEGIN
;	************************************
 		SAVEFILE = DIR_SAVE + 'CLIMATE_INDICES.SAVE'
		DB=READALL(SAVEFILE)

		INDICES = ['NAO','AO','PNA','AAO']

		DATE_RANGES = ['1950','2020']
		DATE_RANGES = [[DATE_RANGES],['1978','2020']]
		DATE_RANGES = [[DATE_RANGES],['1997','2020']]

    date_ranges = ['1997','2020']
;		LLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLL
		FOR _INDEX = 0,N_ELEMENTS(INDICES)-1 DO BEGIN
;			LLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLL
			FOR _DATE_RANGE = 0,N_ELEMENTS(DATE_RANGES(0,*))-1 DO BEGIN
				DATE_RANGE = DATE_RANGES(*,_DATE_RANGE)
				DATE_TXT   = DATE_RANGE[0]+'_'+DATE_RANGE[1]
				INDEX = INDICES(_INDEX)

				JD=DATE_2JD(DB.DATE)
	 			JD_DATE_RANGE=DATE_2JD(DATE_RANGE)

				OK=WHERE(DB.INDEX EQ INDEX AND JD GE JD_DATE_RANGE[0] AND JD LE JD_DATE_RANGE[1],COUNT)
				IF COUNT EQ 0 THEN STOP

				D=DB[OK]
				JD=JD[OK]
				DATA = D.ANOM

;				===> PERIOD_STATS_PLOT
				PSFILE= DIR_PLOTS+'CLIMATE_INDEX-'+ INDEX+'-'+ DATE_TXT+'.PS'
				PSPRINT,/COLOR,/FULL,FILENAME=PSFILE
	 			PAL_36
	 			INIT=1

	 			PROD = 'DIF_2'

 				STATS_P = PERIOD_STATS_ALL( JD, DATA, PROD=prod, LN=LN, $
 					CRITERIA_RANGE = CRITERIA_RANGE,$
 					CRITERIA_OPER=CRITERIA_OPER, $
 					MPY_MIN=MPY_MIN, $
 					MIN_CPY=MIN_CPY,MAX_CPY=MAX_CPY,$
 					DO_LNP=DO_LNP, DO_DFT=DO_DFT, $
 					ERROR=ERROR)

 				MAX_LABELS = 20
				PERIOD_STATS_PLOT, STATS_P,  MIN_CPY=min_cpy,MAX_CPY=MAX_CPY, SWITCHES=SWITCHES , LABEL=label,$
											 USE_PROD=use_prod,MAX_LABELS=MAX_LABELS,FRAMES=FRAMES
 				PSPRINT

			ENDFOR ; FOR _DATE_RANGE = 0,N_ELEMENTS(DATE_RANGES)-1 DO BEGIN
		ENDFOR ; FOR _INDEX = 0,N_ELEMENTS(INDICES)-1 DO BEGIN

	ENDIF ; DO_PERIOD_STATS_INDICES
; *******************************



;	**********************************************
		IF DO_PLOT_INDICES_SEASON GE 1 THEN BEGIN
;	**********************************************

		SAVEFILE = DIR_SAVE + 'CLIMATE_INDICES.SAVE'
		DB=READALL(SAVEFILE)


		DATE_RANGES = ['1950','2020']
 ;
 		INDICES = ['NAO','AO']

;		LLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLL
		FOR _INDEX = 0,N_ELEMENTS(INDICES)-1 DO BEGIN
;			LLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLL
			FOR _DATE_RANGE = 0,N_ELEMENTS(DATE_RANGES(0,*))-1 DO BEGIN
				DATE_RANGE = DATE_RANGES(*,_DATE_RANGE)
				DATE_TXT   = DATE_RANGE[0]+'_'+DATE_RANGE[1]
				INDEX = INDICES(_INDEX)

				JD=DATE_2JD(DB.DATE)
	 			JD_DATE_RANGE=DATE_2JD(DATE_RANGE)

				OK=WHERE(DB.INDEX EQ INDEX AND JD GE JD_DATE_RANGE[0] AND JD LE JD_DATE_RANGE[1],COUNT)
				IF COUNT EQ 0 THEN STOP

				D=DB[OK]
				JD=JD[OK]


;				===> GROUP BY JFM
				OK = WHERE(D.MONTH GE 1 AND D.MONTH LE 3)
				D=DB[OK]
				JD=JD[OK]
				DATA = D.ANOM
				AX = DATE_AXIS(JD,/YEAR,ROOM=[2,1],MAX_LABELS=10)
				AX = DATE_AXIS(JD,/YEAR, MAX_LABELS=10)
				STATS_P = PERIOD_STATS(JD,DATA,PERIOD_CODE='!Y')


STOP

;				===> PERIOD_STATS_PLOT
				PSFILE= DIR_PLOTS+'CLIMATE_INDEX-'+ INDEX+'-'+ DATE_TXT+'.PS'
				PSPRINT,/COLOR,/FULL,FILENAME=PSFILE
	 			PAL_36
	 			INIT=1

	 			PROD = 'DIF_2'

 				STATS_P = PERIOD_STATS_ALL( JD, DATA, PROD=prod, LN=LN, $
 					CRITERIA_RANGE = CRITERIA_RANGE,$
 					CRITERIA_OPER=CRITERIA_OPER, $
 					MPY_MIN=MPY_MIN, $
 					MIN_CPY=MIN_CPY,MAX_CPY=MAX_CPY,$
 					DO_LNP=DO_LNP, DO_DFT=DO_DFT, $
 					ERROR=ERROR)

 				MAX_LABELS = 20
				PERIOD_STATS_PLOT, STATS_P,  MIN_CPY=min_cpy,MAX_CPY=MAX_CPY, SWITCHES=SWITCHES , LABEL=label,$
											 USE_PROD=use_prod,MAX_LABELS=MAX_LABELS,FRAMES=FRAMES
 				PSPRINT

			ENDFOR ; FOR _DATE_RANGE = 0,N_ELEMENTS(DATE_RANGES)-1 DO BEGIN
		ENDFOR ; FOR _INDEX = 0,N_ELEMENTS(INDICES)-1 DO BEGIN

	ENDIF
;	******************



    JD=DATE_2JD(DB.DATE)
	 	JD_DATE_RANGE=DATE_2JD(DATE_RANGE)

		OK=WHERE(DB.INDEX EQ INDEX AND JD GE JD_DATE_RANGE[0] AND JD LE JD_DATE_RANGE[1],COUNT)
		IF COUNT EQ 0 THEN STOP


		D=DB[OK]
		JD=JD[OK]
		DATA = D.ANOM

		STOP

		XRANGE = [1960,2005]
		XTICKS = 9

	;	XRANGE = [1975,2005]
	 	XRANGE = [1985,2006]
	 	XTICKS = 11
		YRANGE = [-3,3]
		NAO = DB.NAO

;		===> YEAR
		JD=DATE_2JD(DB.DATE)
		DYEAR = JD_2DYEAR(JD)

;		AX=DATE_AXIS(JD,/YEAR)
;		PLOT,AX.JD,Y, XTICKS=AX.TICKS,XTICKNAME=AX.TICKNAME,XTICKV=AX.TICKV,/XSTYLE, XTITLE=AX.TITLE

		OK=WHERE(DYEAR GE XRANGE[0] AND DYEAR LE XRANGE[1])
		DYEAR=DYEAR[OK]
		NAO  = FLOAT(NAO[OK])

		!P.MULTI=[0,1,2]
		PLOT, DYEAR,NAO,/NODATA,TITLE='NAO Index (NOAA Climate Prediction Center)',ytitle='Index',$
			xrange=XRANGE,/xstyle,xticks=xticks,YRANGE=YRANGE,/YSTYLE,xtick_get=XTICK_GET,YTICK_GET=YTICK_GET,$
			YMINOR=1
		GRIDS,color=34,XX=XTICK_GET,/all,thick=2
		PLOT_EVENT,/YAXIS,0.0,LINESTYLE=0,THICK=5,COLOR=18
 		OPLOT, DYEAR,NAO,COLOR=6,THICK=1

; 	===> Running 6-month mean
		smo=SMOOTH(NAO,6,/EDGE_TRUNCATE)
;		smo=SMOOTH(NAO,12,/EDGE_TRUNCATE)

; 	===>INTERPOLATE
		xx		=	INTERVAL(XRANGE,0.1)
		NUM=N_ELEMENTS(SMO)
 		ISMO 	= INTERPOL(SMO,DYEAR,xx)


		ok=where(Ismo GT 0, NCOMPLEMENT=NCOMPLEMENT,COMPLEMENT=COMPLEMENT)
		above=replicate(0.0,n_elements(Ismo))
		above(ok)=Ismo(ok)

;		polyfill, XX,above,color=21,/data


		below=replicate(0.0,n_elements(Ismo))
		ok=where(Ismo LT 0, NCOMPLEMENT=NCOMPLEMENT,COMPLEMENT=COMPLEMENT)

		below(OK)=ISMO[OK]

		XXX= [XX[0],XX,LAST(XX),XX[0]]
		BELOW=[0,BELOW,LAST(BELOW),0]

;		polyfill, XXX,below,color=8,/data


		OPLOT, DYEAR,smo,COLOR=21,THICK=7

	  ;OPLOT, DYEAR,SMOOTH(NAO,24,/EDGE_TRUNCATE),COLOR=27,THICK=3

;	POLYFILL, X, Y, COLOR = 175, /DEVICE

;	*** LEGEND BOX ***
;  given no box is plotted.  May have up to 6 elements:
;  [BIC, BOC, BOT, BMX, BMY, BFLAG]
;  BIC: Box interior color.  Def=no box.
;  BOC: Box outline color.   Def=!p.color.
;  BOT: Outline thickness.   Def=1.
;  BMX: Box margin in x.     Def=1.
;  BMY: Box margin in y.     Def=1.
;  BFLAG: Margin units flag. Def unit (BFLAG=0) is 1 legend

	BOX=[255, 255,  3, 0.5, 1.1, 0]
	COLORS=[6,21]
	LABELS=['Index','6 month!Cmean']
	LABELS=['Index','6 month mean']

;	LABELS=['Index','12 month!Cmean']
;	LABELS=['Index','12 month mean']
	THICKS=[1,3]
	LSIZE=1.0
	!P.CHARTHICK=3
	LEG,pos =[0.77 ,0.05,0.78,0.12], BOX=BOX,color=colors,label=labels,THICK=THICKS,LSIZE=LSIZE
	!P.CHARTHICK=1
	FRAME,COLOR=0,THICK=3,/PLOT
	PSPRINT

	IMAGE_TRIM,PSFILE,DPI=600

STOP



END



