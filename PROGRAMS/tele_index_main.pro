; $ID:	TELE_INDEX_MAIN.PRO,	2020-07-08-15,	USER-KJWH	$
PRO TELE_INDEX_MAIN

; Generate a plot illustrating the North Atlantic Oscillation Index

ROUTINE_NAME='TELE_INDEX_MAIN'


	COMPUTER = GET_COMPUTER()
	SLASH=PATH_SEP()

  IF computer EQ 'LOLIGO' 			THEN DISK = 'D:'
  DIR_SUFFIX = ''

; *** Main Path ***
  path = DISK + SLASH+ 'PROJECTS\TELE_INDEX'  + SLASH ;;;

; *** Program Directories ***
	DIR_PROGRAMS       	= 'D:\IDL\PROGRAMS\'
	DIR_DATA					 	= 'D:\IDL\DATA\'
	DIR_INVENTORY			 	= 'D:\IDL\INVENTORY\'
	DIR_IMAGES				 	= 'D:\IDL\IMAGES\'
  DIR_GZIP 						= 'C:\GZIP\'
  DIR_landmask 				= 'D:\IDL\IMAGES\'
  DIR_NECW_NAV_MASTER = 'D:\IDL\DATA\'
  DISK_CD 						=	'Z:'

; *** Program Files ***
  NAVDBF  										= DIR_NECW_NAV_MASTER+ 'necw_nav_master_cwf.dbf' ; Location for NAVDBF file:
  NAVIMAGE_AVHRR_AUTO  				= 'D:\IDL\DATA\NAVIMAGE_AVHRR_AUTO.CSV'
  NAVIMAGE_AVHRR_AUTO_NAVIGATED='D:\IDL\DATA\NAVIMAGE_AVHRR_AUTO_NAVIGATED.dbf'
  MASTER_CWF_LIST			        = 'D:\IDL\DATA\NECW_MASTER_LIST.CSV'; 'D:\IDL\DATA\NOAA_CoastWatch_Active_Access_System.txt'

  land_mask_file  						= DIR_landmask+'MASK_NEC.png'
  HEADER_DATABASE							= DIR_DATA + 'NECW_AVHRR_ER_HEADER.SAVE'

; *** Data Directories ***


  DIR_DATA				= PATH+'DATA' 			+ DIR_SUFFIX+SLASH

  DIR_PLOTS 			= PATH+'plots'				+ DIR_SUFFIX+SLASH

  DIR_SAVE 				= PATH+'SAVE'					+	DIR_SUFFIX+SLASH



  DIR_ALL = [DIR_DATA,  DIR_PLOTS, DIR_SAVE]



	DO_CHECK_DIRS 			= 1
	DO_FTP_GET 					= 2 ; KEEP THIS ON 2 TO GET THE LATEST FILE
	DO_TEL_INDEX_EDIT   = 1
	DO_TEL_INDEX_PLOT 	= 1


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
    FTP_SITE = 'ftpprd.ncep.noaa.gov'
	  FTP_ACCOUNT = 'anonymous'
	  FTP_PASSWORD = "Jay.O'Reilly@noaa.gov"
	  DIR_REMOTE='pub/cpc/wd52dg/data/indices'
	  DIR_LOCAL = DIR_DATA

		IF FILE_TEST(DIR_DATA+'tele_index.nh') EQ 0 OR DO_FTP_GET GE 2 THEN BEGIN

; 	ftp://ftpprd.ncep.noaa.gov/pub/cpc/wd52dg/data/indices/tele_index.nh
		ftp_batch, ftp_site=ftp_site,ACCOUNT='anonymous',PASSWORD = FTP_PASSWORD, $
					files = target, SKIP_LS=_skip_ls,DIR_REMOTE=DIR_REMOTE,DIR_LOCAL = DIR_DATA,$
					MIN_SIZE=min_size,INVENTORY=INVENTORY,KEEP_FTP=KEEP_FTP,N_FILES=FTP_n_files,$
					OVERWRITE=1
		ENDIF
  ENDIF ;IF DO_FTP_GET GE 1 THEN BEGIN
; |||||||||||||||||||||||||||||||||||||||||||||||||

; ************************************
	IF DO_TEL_INDEX_EDIT GE 1 THEN BEGIN
;	************************************
		FILE = DIR_DATA+'tele_index.nh'
		SAVE_FILE=DIR_SAVE+'TELE_INDEX.SAVE'
		FI_FILE = FILE_INFO(FILE)
		FI_SAVE_FILE = FILE_INFO(SAVE_FILE)

		IF (FI_SAVE_FILE.MTIME -FI_FILE.MTIME) LE 0 THEN BEGIN

			TXT=READ_TXT(file)
			OK=WHERE(STRPOS(TXT,'yyyy') EQ 0,COUNT)
			IF COUNT EQ 1 THEN BEGIN
				TAGNAMES=TXT[OK]
				TAGNAMES=TXT[OK] & TAGNAMES=REPLACE(TAGNAMES,['/','. ','.'],['_','_',''])
				TAGNAMES=STRCOMPRESS(TAGNAMES)
				TAGNAMES= STRSPLIT(TAGNAMES,' ',/EXTRACT)

				TXT = STRCOMPRESS(TXT(OK+1:*))
				TXT  = REPLACE(TXT,'-99.9',' -99.9')
				OK=WHERE(STRLEN(TXT) NE 0,COUNT)
				IF COUNT GE 1 THEN TXT = TXT[OK] ELSE STOP
				DB=TXT_2STRUCT(TXT, DELIM=' ', TAGNAMES=tagnames)

	 			PRINT,'MINMAX OF EXPLAINED VARIANCE'
				PRINT,MINMAX(FLOAT(DB.EXPL_VAR))
				db=STRUCT_RENAME(DB,['YYYY','MM'], ['YEAR','MONTH' ])
				DB=STRUCT_2NUM(DB)
				DB=REPLACE(DB,'-99.9',MISSINGS(0.0))
				TEMP=CREATE_STRUCT('DATE','') & TEMP=REPLICATE(TEMP,N_ELEMENTS(DB))
				DB=STRUCT_MERGE(DB,TEMP)
				DB.DATE = STRTRIM(DB.YEAR,2)+ NUM2STR(DB.MONTH,LEADING=2)+'01'
				SAVE,FILENAME=SAVE_FILE ,DB,/COMPRESS
			ENDIF
		ENDIF
	ENDIF
;	\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\



; ************************************
	IF DO_TEL_INDEX_PLOT GE 1 THEN BEGIN
;	************************************

		SAVE_FILE=DIR_SAVE+'TELE_INDEX.SAVE'
		PS_FILE= DIR_PLOTS+'TELE_INDEX.PS'

		FI_SAVE_FILE 		= FILE_INFO(SAVE_FILE)
		FI_PS_FILE 	= FILE_INFO(PS_FILE)

		IF (FI_PS_FILE.MTIME -FI_SAVE_FILE.MTIME) LE 0 THEN BEGIN

			DB=READALL(SAVE_FILE)

;			PSPRINT,/COLOR,/HALF,FILENAME='D:\IDL\PROGRAMS\TELE_INDEX.PS'
			PSPRINT,/COLOR,/HALF,FILENAME=PS_FILE
	 		PAL_36
	 		FONT_TIMES

			XRANGE = [1960,2010]
			XTICKS = 10

	;		XRANGE = [1975,2005]
	;		XTICKS = 6
			YRANGE = [-3,3]

;			===> YEAR
			JD=DATE_2JD(DB.DATE)
			DYEAR = JD_2DYEAR(JD)

;			AX=DATE_AXIS(JD,/YEAR)
;			PLOT,AX.JD,Y, XTICKS=AX.TICKS,XTICKNAME=AX.TICKNAME,XTICKV=AX.TICKV,/XSTYLE, XTITLE=AX.TITLE

			OK=WHERE(DYEAR GE XRANGE[0] AND DYEAR LE XRANGE[1])
			DYEAR=DYEAR[OK]
			D = DB[OK]


			VARS=TAG_NAMES(D)
			OK=WHERE_IN(VARS,['YEAR','MONTH','DATE'],COMPLEMENT=COMPLEMENT)
			VARS=VARS(COMPLEMENT)
			COLOR_DATA = 32
			COLOR_SMO  = 6
			COLOR_ZERO = 0
			COLOR_GRIDS = 34

			THICK_DATA = 1
			THICK_SMO  = 4
			THICK_ZERO = 3
			THICK_GRIDS = 1

			LINESTYLE_DATA = 0
			LINESTYLE_SMO  = 0
			LINESTYLE_ZERO = 0
			LINESTYLE_GRIDS = 0



			FOR _VAR = 0,N_ELEMENTS(VARS)-1 DO BEGIN
				VAR = VARS(_VAR)
				POS = WHERE(TAG_NAMES(D) EQ VAR)
				DATA = FLOAT(D.(POS))

				PLOT, DYEAR,DATA,/NODATA,TITLE = VAR+' Index (NOAA Climate Prediction Center)',ytitle='Index',$
					xrange=XRANGE,/xstyle,xticks=xticks,YRANGE=YRANGE,/YSTYLE,xtick_get=XTICK_GET,YTICK_GET=YTICK_GET
				GRIDS,color=COLOR_GRIDS,XX=XTICK_GET,/all,thick=4,LINESTYLE=LINESTYLE_GRIDS
				PLOT_EVENT,/YAXIS,0.0,LINESTYLE=LINESTYLE_ZERO,THICK=THICK_ZERO,COLOR=COLOR_ZERO
		 		OPLOT, DYEAR,DATA,COLOR=COLOR_DATA,THICK=THICK_DATA,LINESTYLE=LINESTYLE_DATA

	; 		===> Running 6-month mean
				smo=SMOOTH(DATA,6,/EDGE_TRUNCATE)

	; 		===>INTERPOLATE
				xx		=	INTERVAL(XRANGE,0.1)
				NUM=N_ELEMENTS(SMO)
	 			ISMO 	= INTERPOL(SMO,DYEAR,xx)

				ok=where(Ismo GT 0, NCOMPLEMENT=NCOMPLEMENT,COMPLEMENT=COMPLEMENT)
;				above=replicate(0.0,n_elements(Ismo))
;				above(ok)=Ismo(ok)

	 ;		polyfill, XX,above,color=21,/data


;				below=replicate(0.0,n_elements(Ismo))
;				ok=where(Ismo LT 0, NCOMPLEMENT=NCOMPLEMENT,COMPLEMENT=COMPLEMENT)

;				below(OK)=ISMO[OK]

;				XXX= [XX[0],XX,LAST(XX),XX[0]]
;				BELOW=[0,BELOW,LAST(BELOW),0]

	;			polyfill, XXX,below,color=8,/data


				OPLOT, DYEAR,smo,COLOR=COLOR_SMO,THICK=THICK_SMO

		  ;OPLOT, DYEAR,SMOOTH(DATA,24,/EDGE_TRUNCATE),COLOR=27,THICK=3

	;			POLYFILL, X, Y, COLOR = 175, /DEVICE

			BOX=[255, 255,  3, 0.5, 1.1, 0]
			COLORS=[COLOR_DATA,COLOR_SMO]
			LABELS=['Index','6 month!Cmean']
			LABELS=['Index','6 month mean']
			THICKS=[THICK_DATA,THICK_SMO]
			LSIZE=1.0
			!P.CHARTHICK=3
			LEG,pos =[0.57 ,0.04,0.58,0.07], BOX=BOX,color=colors,label=labels,THICK=THICKS,LSIZE=LSIZE
			!P.CHARTHICK=1
			CAPTION,"Plotted by J.O'Reilly, NOAA, NMFS",/PLOT
			FRAME,COLOR=0,THICK=5,/PLOT
		ENDFOR

	PSPRINT


;	===> Delete any trim files
		files=FILELIST(DIR_PLOTS+'TELE_INDEX-*trim*.PNG')
		IF FILES[0] NE '' THEN FILE_DELETE,FILES
		IMAGE_TRIM,PSFILE,DPI=600
		ENDIF

	ENDIF

END
