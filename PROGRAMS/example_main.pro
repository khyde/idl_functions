; $ID:	EXAMPLE_MAIN.PRO,	2020-06-30-17,	USER-KJWH	$
;+
; This Program is a main routine for

;
;	NOTES

; HISTORY:
;     Nov 3, 2005  Written by: J.E. O'Reilly
;-
; *************************************************************************

	PRO EXAMPLE_MAIN

  ROUTINE_NAME='EXAMPLE_MAIN'

; *************************************************************************


; *** Computer & Operating System & Date & Default Graphics Window ***
  os = STRUPCASE(!VERSION.OS) & DATE=DATE_NOW()
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
  DIR_SUFFIX = ''

; *** Main Path ***
  path = !S.PROJECTS + 'SOOP'  + SLASH 

; *** Program Directories ***
	DIR_PROGRAMS       	= !S.PROGRAMS
	DIR_IMAGES				 	= !S.IMAGES
  
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



; ****************************************************************************************
; ********************* U S E R    S W I T C H E S  *************************************
; ****************************************************************************************
; Switches controlling which Processing STEPS to do.  The steps are in order of execution
; Switches: 0 = Off, 1 = On,  2= On and Overwrite any Output Files


; =====>
  DO_CHECK_DIRS  			        	=1  ; Normally, keep this switch on



; ***** DAT TO CSV  ***********
	DO_DAT2SAVE									 = 0
	DO_STRUCT_PLOT							 = 0
	DO_SOOP_MONTHLY_TS					= 0
	DO_SOOP_MONTHLY_TRACK				= 2
	DO_SAVE_2PNG								 = 0



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
 	IF DO_QC_PLOT GE 1 THEN BEGIN
; *********************************************
    PRINT, 'S T E P:    DO_QC_PLOT'
  	FILES=FILE_SEARCH(DIR_SAVE+'*.SAVE')
  	FOR NTH=0,N_ELEMENTS(FILES)-1 DO BEGIN
  		AFILE=FILES[NTH]
  		FN=FILE_PARSE(AFILE)
  		PSFILE=DIR_PLOTS+FN.FIRST_NAME+'QC.PS'
  		IF FILE_TEST(PSFILE) EQ 1 AND DO_STRUCT_PLOT LT 2 THEN CONTINUE ; >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>..
  		DB=READALL(AFILE)
  		PSPRINT,/FULL,/COLOR,FILENAME=PSFILE
  		STRUCT_PLOT,DB,/MULTI
  		PSPRINT
  	ENDFOR
	ENDIF ; DO_STRUCT_PLOT





DONE:
PRINT,'END OF EXAMPLE_MAIN.PRO'


END; #####################  End of Routine ################################



