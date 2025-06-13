; $ID:	SOOP_MAIN.PRO,	2020-06-30-17,	USER-KJWH	$
;+
; This Program is a main routine for the SOOP MAINE AND BERMUDA ROUTE DATA

; DATA SOURCE: JACK JOSSI, NARRAGANSETT, RI
;
;	NOTES
;		HYDRO DATA
;    1.  Record Code:	01R12
;    2.  Record Content:	SHIPS OF OPPORTUNITY (SOOP)Station Operations & XBT Data
;				from Master Files for non-SAS Users and for Sharing with 					Outside Colleagues
;    3.  Record Length:	Variable
;    4.  File Name:	RRTTDDYBYE.012, where:
;				RR=Route Code
;				TT=Data Type Code
;				DD=Data Derivation Code
;				YY=Year Span Code
;                         012=Comma delimited ascii file of surface salinity and
;                              water column temperature data, open-able with any
;                              text editor, e.g., C001__DP.012
;
;
;    5.	VAR#	TYPE	NAME		DEFINITION
;
;	1	C	CRUNAM		CRUISE NAME (VV=VESSEL; YY= LAST TWO DIGITS 							OF YEAR OF CRUISE;##= CONSEC CRUISE OF 								VESSEL IN YEAR)
;	2	N	STA		STATION NUMBER
;	3	N	YER		STATION YEAR (GMT)
;	4	N	MON		STATION MONTH (GMT)
;	5     	N	DAY		STATION DAY (GMT)
;	6	N	YERDAY		CONSECUTIVE DAY OF YEAR
;	7	N	TIM		STATION TIME (GMT)
;	8	N	LATDEC		STATION LATITUDE (DECIMAL DEGREES NORTH)
;	9	N	LNGDEC		STATION LONGITUDE (DECIMAL DEGREES WEST)
;	10	N	OBSDPT		DEPTH OF WTRTMP OBSERVATION (METERS)
;	11	N	WTRTMP		WATER TEMPERATURE (DEGREES CELCIUS)
;	12	C	XBTBTM		XBT MEASURED TO BOTTOM
;	13	N	DST		STANDARDIZED ROUTE REFERENCE DISTANCE (KM)
;	14	N	SFCSAL		SURFACE SALINITY (PSU)
;
;NOTE FROM JACK JOSSI:
;ZERO DEPTH TEMPERATURES
;The first obs kept from the bt file depends on season, etc. but generally represents the upper 3 meters.


; HISTORY:
;     Nov 3, 2005  Written by: J.E. O'Reilly
;-
; *************************************************************************

	PRO SOOP_MAIN

  ROUTINE_NAME='SOOP_MAIN'

; *************************************************************************


; *** Computer & Operating System & Date & Default Graphics Window ***
  computer=GET_COMPUTER()  & os = STRUPCASE(!VERSION.OS) & DATE=DATE_NOW()
  IF os EQ 'WIN32' THEN SET_PLOT,'WIN'
; *** Constants ***
	SLASH=DELIMITER(/path) & SP=DELIMITER(/SPACE) & UL=DELIMITER(/UL) & DASH=DELIMITER(/DASH) & ASTER=DELIMITER(/ASTER)

; *** Data Set & File Parameters ***
  SENSOR 		= 'HYDRO'
	METHOD 		= 'LEVITUS'
	SUITE  		= ''
	MAP 			= 'NEC' &
;	PROD 			= 'SST'
	PAL 			= 'PAL_SW3'

  EXT_data = ['dat']

	Z_EXT     =	['GZ','gz','z','Z']

; *** Data Parameters ***
  min_sst 						= 0.0
  max_sst 						= 35.0

; *** Main Disk ***
  IF computer EQ 'LAPSANG' THEN DISK = 'D:'
  IF computer EQ 'LOLIGO' 	THEN DISK = 'D:'
  DIR_SUFFIX = ''

; *** Main Path ***
  path = DISK + SLASH+ 'PROJECTS\SOOP'  + SLASH ;;;

; *** Program Directories ***
	DIR_PROGRAMS       	= 'D:\IDL\PROGRAMS\'
	DIR_DATA					 	= 'D:\IDL\DATA\'
	DIR_INVENTORY			 	= 'D:\IDL\INVENTORY\'
	DIR_IMAGES				 	= 'D:\IDL\IMAGES\'
  DIR_GZIP 						= 'C:\GZIP\'
  DIR_landmask 				= 'D:\IDL\IMAGES\'
  DISK_CD 						=	'Z:'

  DIR_SRTM30_BROWSE 		= 'D:\PROJECTS\SRTM30\BROWSE\'

  DIR_DI6 = 'D:\IDL\DI6\'

; *** Program Files ***
  land_mask_file  						= DIR_landmask+'MASK_NEC.png'

; *** Data Directories ***

 	DIR_DOC 				= PATH+'DOC'		+	DIR_SUFFIX+SLASH
  DIR_DAT 				= PATH+'DATA'		+	DIR_SUFFIX+SLASH
  DIR_SAVE 				= PATH+'SAVE'		+	DIR_SUFFIX+SLASH
  DIR_PLOTS				= PATH+'PLOTS'	+	DIR_SUFFIX+SLASH

  DIR_ALL = [DIR_DOC,DIR_DAT,DIR_SAVE,DIR_PLOTS]

; *** Colors ***
 	BACKGROUND=252 &
	IF N_ELEMENTS(LAND_COLOR) 	NE 1 THEN LAND_COLOR=252
 	IF N_ELEMENTS(CLOUD_COLOR) 	NE 1 THEN CLOUD_COLOR=254
	IF N_ELEMENTS(MISS_COLOR) 	NE 1 THEN MISS_COLOR=253
	OUR_MISS_COLOR=251
	HI_LO_COLOR=255





; ****************************************************************************************
; ********************* U S E R    S W I T C H E S  *************************************
; ****************************************************************************************
; Switches controlling which Processing STEPS to do.  The steps are in order of execution
; Switches: 0 = Off, 1 = On,  2= On and Overwrite any Output Files

  OVERWRITE_1D  = 0
; =====>
  DO_CHECK_DIRS  			        	=1  ; Normally, keep this switch on



; ***** DAT TO CSV  ***********
	DO_DAT2SAVE									 = 0
	DO_STRUCT_PLOT							 = 2
	DO_SOOP_MONTHLY_TS					 = 0
	DO_SOOP_MONTHLY_TRACK					= 0
	DO_SAVE_2PNG								  = 0



; *********************************************
	IF DO_CHECK_DIRS GE 1 THEN BEGIN
; *********************************************
    PRINT, 'S T E P:    DO_CHECK_DIRS'
    FOR N=0,N_ELEMENTS(DIR_ALL)-1 DO BEGIN & AFILE = STRMID(DIR_ALL(N),0,STRLEN(DIR_ALL(N))-1) &
    	IF FILE_TEST(AFILE,/DIRECTORY) EQ 0L THEN FILE_MKDIR,AFILE &  ENDFOR
  ENDIF
; |||||||||||||||||||||||||||||||||||||||||||||||||


; *********************************************
 	IF DO_DAT2SAVE GE 1 THEN BEGIN
; *********************************************
    PRINT, 'S T E P:    DO_DAT2SAVE'

    FILES= FILE_SEARCH(DIR_DAT+['B001__DP.012','C001__CP.012'])
    TAGNAMES = ['CRUISE','STA','YEAR','MONTH','DAY','DOY','TIME','LAT','LON','DEPTH','TEMP','XBT_BOTTOM','DISTANCE','SALINITY']


;		LLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLL
		FOR _FILE= 0,N_ELEMENTS(FILES)-1 DO BEGIN
			AFILE= FILES(_FILE)
			FN=FILE_PARSE(AFILE)
			NAME=(STRSPLIT(FN.FIRST_NAME,'_',/EXTRACT))[0]
			SAVEFILE = DIR_SAVE+NAME+'.SAVE'
			IF FILE_TEST(SAVEFILE) EQ 1 AND DO_DAT2SAVE LT 2 THEN CONTINUE ; >>>>>>>>>>>>>>>>>>>>

			DB=READ_DELIMITED(AFILE,DELIM=',',/NOHEADING)
			DB=STRUCT_RENAME(DB,TAG_NAMES(DB),TAGNAMES)

;			*******************
;			******* EDITS *****
;			*******************
			OK=WHERE(STRTRIM(DB.SALINITY,2) EQ '.',COUNT)
			IF COUNT GE 1 THEN DB[OK].SALINITY = ''



		 	OK=WHERE(STRTRIM(DB.TEMP) EQ '0',COUNT)
		 	IF COUNT GE 1 THEN BEGIN
				PRINT,'TEMP=0 : '+NUM2STR(COUNT) &
				STRUCT_2CSV,DIR_SAVE+FN.FIRST_NAME+'-ERROR-TEMP_ZERO.CSV',DB[OK]
				DB[OK].TEMP=MISSINGS(DB.TEMP)
			ENDIF

			DB=STRUCT_2NUM(DB,/FLT)
			DB.CRUISE=STRTRIM(DB.CRUISE,2)
			DB.XBT_BOTTOM=STRTRIM(DB.XBT_BOTTOM,2)

			OK=WHERE(STRTRIM(DB.LAT) LT 35,COUNT)
		 	IF COUNT GE 1 THEN BEGIN
				PRINT,'LAT LT 35 : '+NUM2STR(COUNT) &
				STRUCT_2CSV,DIR_SAVE+FN.FIRST_NAME+'-ERROR-LAT_LT_35.CSV',DB[OK]
				D=DB[OK]
				IF D.CRUISE EQ 'OL8214' AND D.STA EQ 31 THEN BEGIN
					D.LAT = 40.0500
					DB[OK].LAT =D.LAT
				ENDIF
			ENDIF

			DB.LON= -1.0 * DB.LON

			SAVE,FILENAME=SAVEFILE,DB,/COMPRESS

		ENDFOR ;FILES

  DONE_DO_DAT2SAVE:
  ENDIF ; IF DO_DAT2SAVE EQ 1 THEN BEGIN
; ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||


; *********************************************
 	IF DO_STRUCT_PLOT GE 1 THEN BEGIN
; *********************************************
    PRINT, 'S T E P:    DO_STRUCT_PLOT'
  	FILES=FILE_SEARCH(DIR_SAVE+'*.SAVE')
  	FOR NTH=0,N_ELEMENTS(FILES)-1 DO BEGIN
  		AFILE=FILES[NTH]
  		FN=FILE_PARSE(AFILE)
  		PSFILE=DIR_PLOTS+FN.FIRST_NAME+'QC.PS'
  		IF FILE_TEST(PSFILE) EQ 1 AND DO_STRUCT_PLOT LT 2 THEN CONTINUE ; >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>..
  		DB=READALL(AFILE)
  		stop
  		PSPRINT,/FULL,/COLOR,FILENAME=PSFILE
  		STRUCT_PLOT,DB,/MULTI
  		PSPRINT
  	ENDFOR
	ENDIF ; DO_STRUCT_PLOT



; *********************************************
 	IF DO_SOOP_MONTHLY_TS GE 1 THEN BEGIN
; *********************************************
    PRINT, 'S T E P:    DO_SAVE_2PNG'
    OVERWRITE = DO_SAVE_2PNG GE 2
    TXT = 'Boyer and Levitus, 1997'

		MAPS = ['NEC','EC','NWA','NENA','SAB']

		PRODS = ['SAL','TEMP']
		MAPS = ['NEC']


		FILES = [DIR_SAVE+'C001.SAVE',DIR_SAVE+'B001.SAVE']

;		LLLLLLLLLLLLLLLLLLL
		FOR _FILE = 0,N_ELEMENTS(FILES)-1 DO BEGIN
			FILE=FILES(_FILE)
			DB=READALL(FILE)
			FN=FILE_PARSE(FILE)



;			===> TS PLOT
			PSFILE=DIR_PLOTS+FN.NAME+'-TS.PS'
			PSPRINT,FILENAME=PSFILE,/FULL,/COLOR
			PAL_SW3
			!P.MULTI=[0,3,4]

		  S=WHERE_SETS(DB.CRUISE,DB.STA,DB.YEAR,DB.MONTH,DB.DAY,/JOIN,/PAD,/order)
		  SUR = DB(S.FIRST)
		  OK=WHERE(SUR.DEPTH LE 10 ,COUNT)
		  SUR=SUR[OK]
		  OK=WHERE(SUR.SALINITY EQ '.',COUNT)
		  IF COUNT GE 1 THEN SUR[OK].SALINITY = MISSINGS(SUR.SALINITY)
		  SUR = STRUCT_2NUM(SUR)

			IF FN.NAME EQ 'B001' THEN BEGIN
				TRANSECT = 'MAB'
				TEMP_RANGE = [-1,30]
				SAL_RANGE  = [20,38]
			ENDIF

			IF FN.NAME EQ 'C001' THEN BEGIN
				TRANSECT = 'MAB'
				TEMP_RANGE = [-1,30]
				SAL_RANGE  = [20,36]
			ENDIF

;			LLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLL
			FOR MONTH=1,12 DO BEGIN
			  PLOT, SUR.TEMP,SUR.SALINITY,PSYM=1,/NODATA,XTITLE=UNITS('TEMP',/UNIT,/NAME),YTITLE=UNITS('SALINITY',/UNIT,/NAME),$
		  			YRANGE = SAL_RANGE,XRANGE=TEMP_RANGE,/XSTYLE,/YSTYLE,$
		  			TITLE=MONTH_NAMES(MONTH,/SHORT)
		  	COLORS=BYTSCL(SUR.DISTANCE,MIN=0,MAX=500)
		  	PLOTS,SUR.TEMP,SUR.SALINITY,PSYM=1,COLOR=253,SYMSIZE=0.5
				OK=WHERE(SUR.MONTH EQ MONTH AND SUR.DEPTH LE 10,COUNT)
				S=SUR[OK]
				PRINT,MONTH,N_ELEMENTS(S)
			  COLORS=BYTSCL(S.DISTANCE,MIN=0,MAX=500)
		    PLOTS,S.TEMP,S.SALINITY,PSYM=1,COLOR=COLORS,SYMSIZE=0.5
			ENDFOR
			PSPRINT
		ENDFOR
  ENDIF
; |||||||||||||||||||||||||||||||||||||||||||||||||||||




; *********************************************
 	IF DO_SOOP_MONTHLY_TRACK GE 1 THEN BEGIN
; *********************************************
    PRINT, 'S T E P:    DO_SAVE_2PNG'
    OVERWRITE = DO_SAVE_2PNG GE 2
    TXT = 'Boyer and Levitus, 1997'

		MAPS = ['NEC','EC','NWA','NENA','SAB']

		PRODS = ['SAL','TEMP']
		MAPS = ['NEC']


		FILES = [DIR_SAVE+'C001.SAVE',DIR_SAVE+'B001.SAVE']

;		LLLLLLLLLLLLLLLLLLL
		FOR _FILE = 0,N_ELEMENTS(FILES)-1 DO BEGIN
			FILE=FILES(_FILE)
			DB=READALL(FILE)
			FN=FILE_PARSE(FILE)

			PROD='SALINITY'

;			===> TS PLOT

			PAL_SW3
			!P.MULTI=0

		  S=WHERE_SETS(DB.CRUISE,DB.STA,DB.YEAR,DB.MONTH,DB.DAY,/JOIN,/PAD,/order)
		  SUR = DB(S.FIRST)
		  OK=WHERE(SUR.DEPTH LE 10 ,COUNT)
		  SUR=SUR[OK]
		  OK=WHERE(SUR.SALINITY EQ '.',COUNT)
		  IF COUNT GE 1 THEN SUR[OK].SALINITY = MISSINGS(SUR.SALINITY)
		  SUR = STRUCT_2NUM(SUR)

			IF FN.NAME EQ 'B001' THEN BEGIN
				TRANSECT = 'MAB'
				TEMP_RANGE = [-1,30]
				SAL_RANGE  = [20,38]
			ENDIF

			IF FN.NAME EQ 'C001' THEN BEGIN
				TRANSECT = 'MAB'
				TEMP_RANGE = [-1,30]
				SAL_RANGE  = [20,36]
			ENDIF

;			===> ALL MONTHS
   		 ZWIN,[1024,1024]
			  MAP_NEC
			  ERASE,254
			  MAP_CONTINENTS,/HIRES,/COAST,COLOR=252

				OK=WHERE( SUR.DEPTH LE 10 AND SUR.SALINITY NE MISSINGS(SUR.SALINITY),COUNT)
				S=SUR[OK]
				SRT = SORT(S.DISTANCE)
				S=S(SRT)

;;			COLORS=SD_SCALES(PROD='SALINITY', S.SALINITY,   /DATA2BIN)
;				COLORS=BYTSCL(S.SALINITY,MIN=30,MAX=34,TOP=250)
				SMO=LOWESS(S.DISTANCE, S.SALINITY,FRACTION = 0.1)
				COLORS=BYTSCL(SMO,MIN=30,MAX=34,TOP=250)

		    PLOTS,S.LON,S.LAT,PSYM=1,COLOR=COLORS,SYMSIZE=0.5
		    IMAGE=TVRD()
		    ZWIN
		    PNGFILE=DIR_PLOTS + FN.NAME+'!STUDY'+'-'+PROD+'.PNG'
		    PAL_SW3,R,G,B
		    WRITE_PNG,PNGFILE,IMAGE,R,G,B



;			LLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLL
			FOR MONTH=1,12 DO BEGIN
			  ZWIN,[1024,1024]
			  MAP_NEC
			  ERASE,254
			  MAP_CONTINENTS,/HIRES,/COAST,COLOR=252

				OK=WHERE(SUR.MONTH EQ MONTH AND SUR.DEPTH LE 10 AND SUR.SALINITY NE MISSINGS(SUR.SALINITY),COUNT)
				S=SUR[OK]
				SRT = SORT(S.DISTANCE)
				S=S(SRT)
;				COLORS=SD_SCALES(PROD='SALINITY', S.SALINITY,   /DATA2BIN)
				COLORS=BYTSCL(S.SALINITY,MIN=30,MAX=34,TOP=250)
				SMO=LOWESS(S.DISTANCE, S.SALINITY,FRACTION = 0.1)
				COLORS=BYTSCL(SMO,MIN=30,MAX=34,TOP=250)
		    PLOTS,S.LON,S.LAT,PSYM=1,COLOR=COLORS,SYMSIZE=0.5
		    IMAGE=TVRD()
		    ZWIN
		    PNGFILE=DIR_PLOTS + FN.NAME+'!MONTH_'+STR_PAD(MONTH,2)+'-'+PROD+'.PNG'
		    PAL_SW3,R,G,B
		    WRITE_PNG,PNGFILE,IMAGE,R,G,B

			ENDFOR

		ENDFOR
  ENDIF
; |||||||||||||||||||||||||||||||||||||||||||||||||||||


DONE:
PRINT,'END OF HYDRO_NEFSC_MAIN.PRO'


END; #####################  End of Routine ################################
