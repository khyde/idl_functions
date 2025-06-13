; $ID:	WHOI_FALMOUTH_CLIMATE_MAIN.PRO,	2020-07-08-15,	USER-KJWH	$
;+
;
; HISTORY:
;     March 13, 2005 Written by: J.E. O'Reilly
;
;	NOTES:
;;; http://cis.whoi.edu/science/PO/climate/index.cfm
;;;Contact: Richard E. Payne, ext. 2550

;;;Definition of parameters on monthly climatological data reports

;;;Column Units Description
;;;DAY   Day of the month
;;;DAYNO   Year day number
;;;SORADM watt-hours/m2 Daily total of observed vertical solar energy flux
;;;SORADC watt-hours/m2 Daily total of observed vertical solar energy flux with no
;;;atmosphere (calculated)
;;;AT Dimensionless Atmospheric transmittance = SORADM/SORADC
;;;NOONALT Degrees Altitude of sun above horizon at solar noon
;;;TMAX Deg F Maximum air temperature during 24 hour period
;;;TMIN Deg F Minimum air temperature during 24 hour period
;;;DD65 Deg F Heating degree day total for house maintained at 70 deg F
;;;DD65 = (TMAX + TMIN)/2 - 65
;;;DD60 Deg F Heating degree day total for house maintained at 65 deg F
;;;DD60 = (TMAX + TMIN)/2 - 60
;;;PRECIP Inches Precipitation in 24 hour period
;;;
;;;
;;;Comments on measurements
;;;Solar radiation measurements are made with an Eppley PSP pyranometer mounted on the
;;;roof of the Clark Building, Quissett Campus, Woods Hole Oceanographic Institution. The
;;;output signal of the sensor is sampled at 10 second intervals and averaged over an hour
;;;by a Campbell data logger. The hourly totals have been archived since 1991. Daily totals
;;;are computed from the hourly totals and have been archived since 1975.
;;;TMAX, TMIN, and PRECIP are recorded by Falmouth Water Department employees at
;;;the town pumping station located on the shore of Long Pond, the town reservoir. Beacuse
;;;this is an inland site, about 1.5 miles from the shore of Buzzards Bay, air temperatures
;;;may differ considerably from temperatures at shore sites. The thermometers have not
;;;been calibrated since they were purchased in 1960 and their absolute accuracy cannot be
;;;vouched for. TMAX and TMIN have been recorded since 1960, PRECIP since 1966. All
;;;data are archived by Dick Payne (Ext 2550).
;;;
;;;
;;;Atmospheric Transmittance
;;;Solar radiation received at the earth's surface can vary because of clouds, latitude, time of
;;;year, and time of day. If we consider only daily totals we eliminate the time of day.
;;;Because of the dependence on latitude and date, daily totals cannot be compared directly
;;;from one place and time to another but the dependence on latitude and date can be
;;;compensated for mathematically. Knowing a few astronomical parameters we can
;;;compute the amount of solar radiation which would fall on the earth's surface at a given
;;;location and date. If we compute it for Woods Hole and divide our measured daily totals
;;;by these computed daily totals, we get an index for each day which has a value between 0
;;;and about 0.75. This index is called the atmospheric transmittance (AT). A clear day
;;;yields an index of about 0.75; a very cloudy day might have an index of 0.1. This index
;;;changes primarily with the effects of the atmosphere (clouds, water vapor) but has the
;;;effects of latitude and date removed. This index can then be used to compare atmospheric
;;;effects at one location with those at another and one time of year with another.
;-
; *************************************************************************

	PRO WHOI_FALMOUTH_CLIMATE_MAIN

  ROUTINE_NAME='WHOI_FALMOUTH_CLIMATE_MAIN'

	COMPUTER=GET_COMPUTER()
	IF COMPUTER EQ 'LAPSANG' THEN DISK = 'D:'
	IF COMPUTER EQ 'BURRFISH' THEN DISK = 'G:'
	IF COMPUTER EQ 'LOLIGO' THEN DISK = 'D:'
  DELIM=DELIMITER(/PATH)
  DIR_BATHY = 'D:\IDL\BATHY\GEBCO\'
  DIR_IMAGES = 'D:\IDL\IMAGES\'

  PATH = DISK+DELIM + 'PROJECTS\WHOI_FALMOUTH_MONTHLY_CLIMATE'+DELIM

; **************************************
; Directories
; Edit these as needed

	DIR_DATA 		= path+'DATA'+delim
	DIR_DOC 		= path+'DOC'+delim
  DIR_SAVE 		= path+'save'+delim
  DIR_PLOTS 	= path+'plots'+delim
  DIR_REPORT 	= path+'report'+delim


	DIR_ALL = [DIR_DATA,DIR_DOC,DIR_SAVE,DIR_PLOTS,DIR_REPORT]

; *******************************************
; Set up color system defaults
	SETCOLOR
	PAL_36

;	===> Ploting options
	SHOW_GRIDS = 1


; ********************************************************************************
; ***** U S E R    S W I T C H E S  Controlling which Processing STEPS to do *****
; ********************************************************************************
;	0 (Do not do the step)
;	1 (Do the step)
; 2 (Do the step and OVERWRITE any output if it alread exists)

; ================>
; Switches controlling which Processing STEPS to do:
	DO_CHECK_DIRS = 1 ; GOOD IDEA TO ALWAYS KEEP THIS SWITCH ON


	DO_CSV_2SAVE  = 1
	DO_PLOT   		= 2


	FILE =FILE_SEARCH(DIR_DATA+'WHOI_FALMOUTH_MONTHLY_CLIMATE_DATA.csv')
	SAVEFILE = DIR_SAVE + 'WHOI_FALMOUTH_MONTHLY_CLIMATE_DATA.SAVE'
	CSV_EDIT = DIR_DATA+ 'WHOI_FALMOUTH_MONTHLY_CLIMATE_DATA-EDIT.CSV'


; *********************************************
  IF DO_CHECK_DIRS GE 1 THEN BEGIN
; *********************************************
    PRINT, 'S T E P:    DO_CHECK_DIRS'
    FOR N=0,N_ELEMENTS(DIR_ALL)-1 DO BEGIN
      AFILE = STRMID(DIR_ALL(N),0,STRLEN(DIR_ALL(N))-1)
      IF FILE_TEST(AFILE,/DIRECTORY) EQ 0L THEN FILE_MKDIR,AFILE
    ENDFOR
  ENDIF ; IF DO_CHECK_DIRS GE 1 THEN BEGIN
; |||||||||||||||||||||||||||||||||||||||||||||||||





; **********************************************************
	IF DO_CSV_2SAVE GE 1 THEN BEGIN
; **********************************************************
		OVERWRITE = DO_CSV_2SAVE GE 2

		IF FILE_TEST(SAVEFILE) AND OVERWRITE EQ 0 THEN GOTO, DONE_DO_DO_CSV_2SAVE ; >>>>>>>>>>>>.


; ===> Data in csv
;	Jan-93	41.52	LAT	70.66	LONG
;	Pyranometer	No.	EPPLEY	27412
;	DAY	DAYNO	SORADM	SORADC	AT	NOONALT	TMAX	TMIN	DD65	DD60	PRECIP
;	watt-hr/m**2	deg	degF	degF	deg	days	inches
;	1	1	2105	3544	0.594	25.5	49	21	30	25	0
;	2	2	2534	3560	0.712	25.6	32	26	36	31	0
;	3	3	1596	3578	0.446	25.7	50	15	32.5	27.5	0

; NOTE THAT IN DEC 2001 THE LINE WITH PYRAN IS MISSING

; ===> Shift all entries left to align them
		TEXT = READ_TXT(FILE)
		NEW = REPLICATE('',N_ELEMENTS(TEXT))
		FOR _LINE = 0, N_ELEMENTS(TEXT)-1L DO BEGIN
			W = WORDS(TEXT(_LINE),DELIM=',')
			NTH = N_ELEMENTS(W)-1
			TXT = W[0]
			COUNTER = 0
			WHILE TXT EQ '' AND COUNTER LE NTH   DO BEGIN
				W=SHIFT(W,-1)
				TXT = W[0]
				COUNTER=COUNTER+1
			ENDWHILE
			NEW(_LINE) = STRJOIN(W,',')
		ENDFOR
		WRITE_TXT,CSV_EDIT,NEW

;	===> Make the save file
		W = WORDS(NEW,LINE=LINE,DELIM=',')

	  OK_LAT 		= WHERE(STRPOS(STRUPCASE(NEW),'LAT') GE 0,COUNT_LAT)
	  OK_PYR 		= WHERE(STRPOS(STRUPCASE(NEW),'PYR') GE 0,COUNT_PYR)
	  OK_DAYNO 	= WHERE(STRPOS(STRUPCASE(NEW),'DAYNO') GE 0,COUNT_DAYNO)
	  OK_WATT 	= WHERE(STRPOS(STRUPCASE(NEW),'WATT') GE 0,COUNT_WATT)

		IF COUNT_LAT NE COUNT_DAYNO OR COUNT_LAT NE COUNT_DAYNO THEN STOP
		MM = MINMAX(OK_DAYNO - OK_LAT)
		IF MM[0] NE 1 OR MM[1] NE 2 THEN STOP

	  PRINT,'OK'

	  OK_PYR 		= WHERE(STRPOS(STRUPCASE(NEW),'PYR') GE 0,COUNT_PYR)
	  NEW=REMOVE(NEW,OK_PYR)
	  OK_DAYNO 	= WHERE(STRPOS(STRUPCASE(NEW),'DAYNO') GE 0,COUNT_DAYNO)
	  NEW=REMOVE(NEW,OK_DAYNO)
	  OK_WATT 	= WHERE(STRPOS(STRUPCASE(NEW),'WATT') GE 0,COUNT_WATT)
	  NEW=REMOVE(NEW,OK_WATT)



		OK_LAT 		= WHERE(STRPOS(STRUPCASE(NEW),'LAT') GE 0,COUNT_LAT,COMPLEMENT=COMPLEMENT)

		DB = ''
		MONTHNAMES =  STRUPCASE(MONTH_NAMES(/SHORT))
		FOR NTH=0,COUNT_LAT-1L DO BEGIN
			SUB_START = OK_LAT[NTH]
			IF NTH NE COUNT_LAT-1 THEN SUB_END   = OK_LAT(NTH+1)-1 ELSE SUB_END = N_ELEMENTS(NEW)-1
			T = STRMID(NEW(SUB_START),0,20)
			W=STRSPLIT(T,'-,',/EXTRACT)

			MONTH =W[0]
			YEAR  =W[1]
			DATA = NEW((SUB_START+1):SUB_END)
			IF FIX(YEAR) GE 1900 THEN BEGIN
				YEAR = YEAR
			ENDIF ELSE BEGIN
				IF FIX(YEAR) LT 70 THEN YEAR = '20'+YEAR ELSE YEAR = '19'+YEAR
			ENDELSE

			MON = STR_PAD(WHERE(MONTHNAMES EQ STRUPCASE(MONTH)),2,CHAR='0')
			DATE = YEAR+MON
			PRINT,DATE
		  DB = [DB, DATE+','+DATA]
		ENDFOR


		STRUCT=TXT_2STRUCT(DB,DELIM=',')

; 	FORMAT:
; 	DATE DAY	DAYNO	SORADM	SORADC	AT	NOONALT	TMAX	TMIN	DD65	DD60	PRECIP
		TAGNAMES=['DATE','DAY', 'DAYNO', 'SORADM',  'SORADC',  'AT',  'NOONALT', 'TMAX',  'TMIN',  'DD65',  'DD60',  'PRECIP']
		TNAMES = '_'+ STRTRIM(SINDGEN(12),2)
		STRUCT=STRUCT_RENAME(STRUCT,TNAMES,TAGNAMES )
		OK = WHERE(STRUCT.DAY NE MISSINGS(STRUCT.DAY))
		STRUCT=STRUCT[OK]
		STRUCT.DATE = STRUCT.DATE + STR_PAD(STRUCT.DAY,2,CHAR='0')
		SAVE,FILENAME=SAVEFILE,STRUCT,/COMPRESS
		SAVE_2CSV,SAVEFILE
    DONE_DO_DO_CSV_2SAVE: ;<<<<<<<<<<<<<<<<<<
  ENDIF ; IF DO_PLOT_RICHARDS_BLOOMDATE GE 1 THEN BEGIN
; |||||||||||||||||||||||||||||||||||||||||||||||||





; **********************************************************
	IF DO_PLOT GE 1 THEN BEGIN
; **********************************************************
		OVERWRITE = DO_PLOT GE 2
		FILE =SAVEFILE
		FN=PARSE_IT(SAVEFILE)

		PSFILE = DIR_PLOTS + FN.FIRST_NAME+'.PS'
		IF FILE_TEST(PSFILE) AND OVERWRITE EQ 0 THEN GOTO, DO_PLOT ; >>>>>>>>>>>>.
		PSPRINT,FILENAME=PSFILE,/COLOR,/FULL
		PAL_36
		!P.MULTI=[0,1,5]
	 	MAP = 'NEC'


		LL=LOCATE('WHOI_PYRANOMETER')
		LOCAL_TIME = 12.0 - (LL.LON/15.0)

		DB  = READALL(SAVEFILE)

		JD = DATE_2JD(DB.DATE)
		JD = JD_ADD(JD,LOCAL_TIME,/HOUR)
		DATE = JD_2DATE(JD)
	;	SUN=DT_SUNPOS(DATE=DATE,LAT=LL.lat,LON=LL.lon)


		TITLE = 'Solar Radiation (' + ll.label+')'


		AX=DATE_AXIS(JD,/YEAR)
		;		===> BY DOY

    !Y.MARGIN = [0,2]
		COLORS = INDGEN(20)*2

; 	===> from Eppley Lab:	86.05 Langleys    = 1000.0 Watts-Hour m-2
	  LANGLEYS = FLOAT(DB.SORADM )  ; CAL CM-2
	  PLOT,AX.JD,LANGLEYS, XTICKS=AX.TICKS,XTICKNAME=AX.TICKNAME,XTICKV=AX.TICKV,/XSTYLE, XTITLE=AX.TITLE,PSYM=1,SYMSIZE=0.25,YTITLE= 'watt-hours/m2',TITLE=TITLE

; 	===> from Eppley Lab:	86.05 Langleys    = 1000.0 Watts-Hour m-2
	  LANGLEYS = FLOAT(DB.SORADM ) *( 86.05/1000.) ; CAL CM-2
	  PLOT,AX.JD,LANGLEYS, XTICKS=AX.TICKS,XTICKNAME=AX.TICKNAME,XTICKV=AX.TICKV,/XSTYLE, XTITLE=AX.TITLE,PSYM=1,SYMSIZE=0.25,YTITLE=UNITS('LANGLEY_DAY',/NAME,/UNIT)


		WL = 550.
;		===> PAR (E M-2)  = (0.43 PAR/ 1 TOTAL ENERGY) *WATT_HR *(86.05 CAL CM-2 /100 WATT-HR) * (4.184 Joule/ 1 Cal) * ( (8.362e-9)*WL / 1 Joule) * (1E4 CM2/ M2)
;		E.G. 8470*(86.05/1000) * 4.184*8.362e-9 * 550 * 1e4
;		WATTS M-2 * 5.036 x 1015 = QUANTA M-2 SEC -1
    PAR_E_M2 = 0.43*DB.SORADM*(86.05/1000) * 4.184*8.362e-9 * WL * 1e4


; 	===> from Eppley Lab:	86.05 Langleys    = 1000.0 Watts-Hour m-2
	  PLOT,AX.JD,PAR_E_M2, XTICKS=AX.TICKS,XTICKNAME=AX.TICKNAME,XTICKV=AX.TICKV,/XSTYLE, XTITLE=AX.TITLE,PSYM=1,SYMSIZE=0.25,YTITLE=UNITS('PAR',/NAME,/UNIT)


		AX=DATE_AXIS(JD,/YEAR)
		;		===> BY DOY
		DOY = DATE_2DOY(DB.DATE)
    !Y.MARGIN = [0,2]
		COLORS = INDGEN(15)*2
	  PLOT,FLOAT(DOY), LANGLEYS,  /XSTYLE, XTITLE='DOY',/NODATA,YTITLE=UNITS('LANGLEY_DAY',/NAME,/UNIT)
	  GRIDS,COLOR=33,/ALL
	  SETS=WHERE_SETS(STRMID(DB.DATE,0,4))
	  FOR _SET = 0,N_ELEMENTS(SETS)-1 DO BEGIN
	  	SUBS=WHERE_SETS_SUBS(SETS(_SET))
	  	PLOTS,FLOAT(DOY(SUBS)),FLOAT(LANGLEYS(SUBS)) ,PSYM=1,SYMSIZE=0.25,COLOR=COLORS(SUBS)
	 	ENDFOR


 		PLOT,FLOAT(DOY), PAR_E_M2,  /XSTYLE, XTITLE='DOY',/NODATA,YTITLE=UNITS('PAR',/NAME,/UNIT)
 		GRIDS,COLOR=33,/ALL
	  SETS=WHERE_SETS(STRMID(DB.DATE,0,4))
	  FOR _SET = 0,N_ELEMENTS(SETS)-1 DO BEGIN
	  	SUBS=WHERE_SETS_SUBS(SETS(_SET))
	  PLOTS,FLOAT(DOY(SUBS)),FLOAT(PAR_E_M2(SUBS)) ,PSYM=1,SYMSIZE=0.25,COLOR=COLORS(SUBS)
	 	ENDFOR
		PSPRINT

STOP


stop

	  PSPRINT

    DO_PLOT: ;<<<<<<<<<<<<<<<<<<
  ENDIF ; IF DO_PLOT_RICHARDS_BLOOMDATE GE 1 THEN BEGIN
; |||||||||||||||||||||||||||||||||||||||||||||||||





PRINT,'END OF WHOI_FALMOUTH_CLIMATE_MAIN.PRO'

END; #####################  End of Routine ###############################
