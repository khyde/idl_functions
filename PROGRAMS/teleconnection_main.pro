; $ID:	TELECONNECTION_MAIN.PRO,	2020-07-08-15,	USER-KJWH	$
PRO TELECONNECTION_MAIN

; Generate a plot illustrating the North Atlantic Oscillation Index

ROUTINE_NAME='TELECONNECTION_MAIN'

;	******************************************
; ***** Directories for Resource Files *****
;	******************************************
  DIR_PROGRAMS       = 'D:\IDL\PROGRAMS\'
  DIR_DATA           = 'D:\IDL\DATA\'
  DIR_IMAGES         = 'D:\IDL\IMAGES\'

;	******************************
;	***** C O N S T A N T S  *****
;	******************************
  COMPUTER=GET_COMPUTER() & NOW = LONG(STRMID(DATE_NOW(),0,8))
  DELIM		=DELIMITER(/PATH) & SLASH=DELIMITER(/SLASH) & DASH=DELIMITER(/DASH) & UL=DELIMITER(/UL) & CM=DELIMITER(/COMMA) & AS = DELIMITER(/ASTER)
  NOW 		= NUM2STR(LONG(STRMID(DATE_NOW(),0,8)))



;	*************************************************
;	***** O U T P U T   D I R E C T O R I E S   *****
;	*************************************************
	IF COMPUTER EQ 'LOLIGO' THEN DISK_PROJECT = 'D:'
	PROJECT_FOLDER = 'TELECONNECTION'

  PATH = DISK_PROJECT+DELIM + 'PROJECTS\'+PROJECT_FOLDER+DELIM

  DIR_SAVE       = path+'SAVE'    +SLASH
  DIR_DOC        = path+'DOC'     +SLASH
  DIR_PLOTS      = path+'PLOTS'   +SLASH

  DIR_ALL = [DIR_SAVE,DIR_DOC,DIR_PLOTS]


	FTP_SITE = 'ftpprd.ncep.noaa.gov'
	FTP_SITE = 'ftp.cpc.ncep.noaa.gov'

  FTP_ACCOUNT = 'anonymous'
  FTP_PASSWORD = "Jay.O'Reilly@noaa.gov"
  DIR_REMOTE='pub/cpc/wd52dg/data/indices'
  DIR_REMOTE='/cwlinks/'
; ftp://ftpprd.ncep.noaa.gov/pub/cpc/wd52dg/data/indices/tele_index.nh


;	******************************************************************
; *********** J O B  S W I T C H E S  ******************************
;	******************************************************************
	DO_FTP_GET 					= 0
	DO_TEL_INDEX_EDIT   = 1
	DO_TEL_INDEX_PLOT 	= 1



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
    target='tele_index.nh'    ;
    target='norm*.ascii'

STOP
		ftp_batch, ftp_site=ftp_site,ACCOUNT='anonymous',PASSWORD = FTP_PASSWORD, $
					files = target, SKIP_LS=_skip_ls,DIR_REMOTE=DIR_REMOTE,DIR_LOCAL = PATH,$
					MIN_SIZE=min_size,INVENTORY=INVENTORY,N_FILES=FTP_n_files

  ENDIF ;IF DO_FTP_GET GE 1 THEN BEGIN
; |||||||||||||||||||||||||||||||||||||||||||||||||



; ************************************
	IF DO_TEL_INDEX_EDIT GE 1 THEN BEGIN
;	************************************
		FILES = FILE_SEARCH(DIR_DATA+'norm.daily.*.index.*.ascii')
		LIST, FILES
		STOP

		TXT=READ_TXT('D:\IDL\DATA\TELE_INDEX.NH.TXT')
;		SPREAD,TXT
		TXT = TXT(0:20)
		db=READ_DELIMITED('D:\IDL\DATA\TELE_INDEX.NH.TXT',SKIP=21,/NOHEADING,delim=' ')
;		SPREAD,DB

		db=STRUCT_RENAME(DB,['_0','_1','_2'], ['YEAR','MONTH','NAO'])
		TEMP=CREATE_STRUCT('DATE','') & TEMP=REPLICATE(TEMP,N_ELEMENTS(DB))
		DB=STRUCT_MERGE(DB,TEMP)
		DB.DATE = DB.YEAR+ NUM2STR(DB.MONTH,LEADING=2)+'01000000'
		STRUCT_2CSV,'d:\IDL\DATA\TELE_INDEX.CSV' ,DB
	ENDIF
;	\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\



; ************************************
	IF DO_TEL_INDEX_PLOT GE 1 THEN BEGIN
;	************************************
		DB=READ_CSV('d:\IDL\DATA\TELE_INDEX.CSV')
		PSFILE= PATH+'NAO_INDEX.PS'
;		PSPRINT,/COLOR,/HALF,FILENAME='D:\IDL\PROGRAMS\NAO_INDEX.PS'
		PSPRINT,/COLOR,/HALF,FILENAME=PSFILE
 		PAL_36

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
	ENDIF
STOP



END
