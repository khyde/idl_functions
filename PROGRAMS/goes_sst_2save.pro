; $ID:	GOES_SST_2SAVE.PRO,	2020-06-30-17,	USER-KJWH	$

	PRO GOES_SST_2SAVE,SST_FILE, MAP=map, DIR_OUT=dir_out,DIR_REPORT=dir_report, $
													OVERWRITE=overwrite, REFRESH=refresh, ERROR=error
	ROUTINE_NAME='GOES_SST_2SAVE'



;	********************************************************
; Documentation
;	NOTES:

;	*********************************************************
; ===> Constants
	SENSOR='IMAGER'

;	MASK codes
;		 0=space
;    1=not used
;    2=land
;    3=not used
;    4=cloud
;    5=not used
;    6 to 255 = binary coded goes sst data where SST (C) = 0.15 * binary_coded_data -(273.15-271)
;   or 7 to 255 = binary coded goes sst data where SST (C) = 0.15 * binary_coded_data -(273.15-271);
;	===> New Scaling
; Jorge Vazquez program (jpl website) to C.Orphanides >>>  0.15*IMAGE(good_sst)-(3.15) ??? why not -2.15 as above
;	IMAGE_sst_C(good_sst) = 0.15*IMAGE(good_sst)-(3.15)

	ERROR=0
	DATA_UNITS= UNITS('SST')
	SAT_EXTRA	= '' ;
	METHOD = 'CWATCH'

	IF N_ELEMENTS(MAP) NE 1 THEN AMAP = 'GOESWH' ELSE AMAP = MAP

	PROD = 'SST'
	APROD = PROD
	DASH=DELIMITER(/DASH)
	IF N_ELEMENTS(OVERWRITE) NE 1 THEN _OVERWRITE = 0 ELSE _OVERWRITE = OVERWRITE


;	===> Set the MISSING_CODES TO Make 1 through 6 missing
  MISSING_CODES= [0B,1B,2B,3B,4B,5B,6B]

;	===> Must sst file
  IF N_ELEMENTS(SST_FILE) NE 1 THEN BEGIN
		ERROR=1
		GOTO, DONE
  ENDIF

;	===> Get info from SST_FILE to construct a satellite STANDARD file name
	fn=PARSE_IT(SST_FILE) &	NAME=FN.NAME


   IF STRPOS(STRUPCASE(FN.NAME), 'SST1') GE 0 THEN SATELLITE = 'GOES_00'

 	year = STRMID( NAME,5,4) & DOY = STRMID( NAME,10,3) & HOUR = STRMID(NAME,14,2)


 	IF STRUPCASE(STRMID(FN.NAME,0,5)) EQ 'SST1O' THEN BEGIN
 		year = STRMID( NAME,6,4) & DOY = STRMID( NAME,11,3) & HOUR = STRMID(NAME,15,2)
 	ENDIF


 	IF STRUPCASE(STRMID(FN.NAME,9,5)) EQ 'SST1O' AND STRUPCASE(STRMID(FN.NAME,0,1)) EQ 'L' THEN BEGIN
 		year = STRMID( NAME,15,4) & DOY = STRMID( NAME,20,3) & HOUR = STRMID(NAME,24,2)
 	ENDIF


	DATE = JD_2DATE(YDOY_2JD(year,doy,HOUR))
	period = '!H_'+STRMID(DATE,0,10)

	INAME=INAME_MAKE(PERIOD=PERIOD, SENSOR=SENSOR,SATELLITE=SATELLITE,SAT_EXTRA=SAT_EXTRA)
	output_label=iname+dash+METHOD+dash+AMAP+dash+PROD

	IF N_ELEMENTS(DIR_OUT) NE 1 THEN _DIR_OUT = FN.DIR ELSE _DIR_OUT = DIR_OUT
	savefile= _DIR_OUT + output_label +'.save'

	IF FILE_TEST(savefile) EQ 1 AND _OVERWRITE EQ 0 THEN GOTO, DONE ; >>>>>>>>>>>>>>>>>>>
;	===> Read the hdf file and extract the BINARY data


 	FN=FILE_PARSE(SST_FILE)
  REMOVE_FILE = ''


	CD,CURR=DIR_OLD
	CD,FN.DIR

;	===> If it is Z then following is needed but if it is GZ then READ_GOES_SST will handle it
  IF STRUPCASE(FN.EXT) EQ 'Z' THEN BEGIN
		z_file=FN[0].FULLNAME
		dir_gzip  = 'c:\gzip\'
   	cmd = DIR_GZIP + 'GZIP.exe -d -f '  + Z_FILE
    PRINT, CMD
    SPAWN,CMD
    REMOVE_FILE =''
    FILE=FN.DIR+FN.NAME
  ENDIF ELSE BEGIN
  	FILE=FN.NAME+FN.EXT_DELIM+FN.EXT
  ENDELSE

  IMAGE = READ_GOES_SST(FILE,BIN=1,SCALING=scaling,INTERCEPT=intercept,SLOPE=slope,MISSING_CODE=missing_code,MISSING_NAME=missing_name,NOTES=notes, ERROR=error)

	IF ERROR EQ 1 THEN BEGIN
  	TXT='ERROR: CAN NOT READ '+SST_FILE+ '; ' + DATE_NOW()
  	REPORT,TXT,DIR=dir_report
  	PRINT,TXT
  	IF REMOVE_FILE NE '' THEN FILE_DELETE,REMOVE_FILE,/QUIET
  	GOTO, DONE
  ENDIF

  STRUCT_SD_WRITE,SAVEFILE,PROD=APROD, $
       IMAGE=IMAGE,     MISSING_CODE=missing_code, MISSING_NAME=missing_NAME,$
       MASK=MASK,     	CODE_MASK=CODE_MASK,    CODE_NAME_MASK=CODE_NAME_MASK, $
       SCALING=SCALING, INTERCEPT=INTERCEPT,    SLOPE=SLOPE,       DATA_UNITS=DATA_UNITS,$
       PERIOD=PERIOD, $
       INFILE= [SST_FILE],$
       NOTES=NOTES,$
       ERROR=ERROR

 	IF STRUPCASE(FN.EXT) EQ 'Z' THEN ZIP,files=file,DIR_OUT=FN.DIR,/GZIP,/KEEP_EXT,EXT_ZIP='GZ',/HIDE
	IF REMOVE_FILE NE '' THEN FILE_DELETE,REMOVE_FILE,/QUIET

DONE:
END; #####################  End of Routine ################################

