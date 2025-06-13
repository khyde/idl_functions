; $ID:	FTO_CTD_MAIN.PRO,	2020-06-26-15,	USER-KJWH	$
;+
;	This Program is a MAIN program for Processing the Flow-Through Logs Collected on NMFS surveys

;	Jan 01,2001	Written by:	J.E. O'Reilly
;-
; *************************************************************************
PRO FTO_CTD_MAIN
  ROUTINE_NAME='FTO_CTD_MAIN'
; *******************************************
; DEFAULTS
  MAP='NEC' & PX=1024 & PY=1024
  SP     =' '
  TOLERANCE= 6.0/(24.*60) ; SIX MINUTES FOR GPS TOLERANCE

; ****************************************************************************************
; ********************* U S E R    S W I T C H E S  *************************************
; ****************************************************************************************
; Switches controlling overwriting if the file already exists (usually do not overwrite : 0)
  METHOD = 'FTO'

; ================>
; Switches controlling which Processing STEPS to do:
  DO_CHECK_DIRS  		=0
  DO_CTD_EDIT 			=0
  DO_CTD_EDIT_PLOT 	=1
  DO_FTO_VS_CTD_PLOT =0

; ===================>
; Different delimiters for WIN, MAX, AND X DEVICES
  os = STRUPCASE(!VERSION.OS) & computer=GET_COMPUTER() & DELIM=DELIMITER(/PATH)

  path = 'g:\'

  DIR_landmask = '/idl/images/'
  IF OS EQ 'WIN32' THEN DIR_landmask = 'D:\IDL\images\'
  DIR_SEATRUTH = '/idl/data/'
  IF OS EQ 'WIN32' THEN DIR_SEATRUTH = 'g:\SEATRUTH\'

; *******************************************************************************
; DIR_SUFFIX allows you to test the entire program with a few *.z files and create
; directory names (e.g. DIR_SUFFIX = 'test')  that differ from the default
  DIR_SUFFIX = ''


; **************************************
; Directories
; Edit these as needed
  DIR_LOG  = path+method+delim+'LOG'+DIR_SUFFIX+delim

  DIR_SAVE = path+method+delim+'save'+DIR_SUFFIX+delim
  DIR_REPORT = path+method+delim+'report'+DIR_SUFFIX+delim
  DIR_FREQ = path+method+delim+'freq'+DIR_SUFFIX+delim

  DIR_STATS = path+method+delim+'stats'+DIR_SUFFIX+delim
  DIR_PLOTS =path+method+delim+'plots'+DIR_SUFFIX+delim
  DIR_CTD_CAL_4FTO=path+method+delim+'CTD_CAL_4FTO'+DIR_SUFFIX+delim

  DIR_GPS_COMBINE  = path+method+delim+'gps'+DIR_SUFFIX+delim

  DIR_ALL = [DIR_LOG,DIR_LOG,DIR_SAVE,DIR_FREQ,DIR_STATS,DIR_PLOTS,dir_report,DIR_CTD_CAL_4FTO,DIR_GPS_COMBINE]

  PRODUCTS=['CHLOR_A']
  N_PRODUCTS=N_ELEMENTS(PRODUCTS)


; *********************************************
; ******** C H E C K   D I R S  ***************
; *********************************************
  IF DO_CHECK_DIRS EQ 1 THEN BEGIN
    PRINT, 'S T E P:    DO_CHECK_DIRS'
    FOR N=0,N_ELEMENTS(DIR_ALL)-1 DO BEGIN
      AFILE = STRMID(DIR_ALL(N),0,STRLEN(DIR_ALL(N))-1)
      IF FILE_TEST(AFILE,/DIRECTORY) EQ 0L THEN FILE_MKDIR,AFILE
    ENDFOR
  ENDIF ; IF DO_Z2SAVE EQ 1 THEN BEGIN
; ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||


; *********************************************
; ******** C T D          E D I T  ************
; *********************************************
  IF DO_CTD_EDIT EQ 1 THEN BEGIN
    PRINT, 'S T E P:    DO_CTD_EDIT'
    ;;DATA_FILE = FILELIST(DIR_CTD_CAL_4FTO + 'ORACLE_Ctd_CAL_4fto.csv')
    DATA_FILE = FILELIST(DIR_CTD_CAL_4FTO + 'newCalib.CSV')
    SAVE_FILE = DIR_SAVE+'CTD_CAL_4FTO.SAVE'
    CSV_FILE  = DIR_SAVE+'CTD_CAL_4FTO.CSV'

    IF N_ELEMENTS(CSV_FILE) GE 1 THEN BEGIN
      PRINT, 'Found ' + NUM2STR(N_ELEMENTS(CSV_FILE)) + '  *.CSV  files'
      PRINT, 'This step will Edit CTD data file '
      PRINT, 'And Make an output compressed SAVE file and CSV'
      Struct=READALL(DATA_FILE)
      STRUCT=STRUCT_RENAME(STRUCT,['CRUISE_ID','GMT_DATE','SALT','TEMP','PRES','LAT_DD','LON_DD'],['CR','DATE','SALINITY','TEMPERATURE','DEPTH','LATD','LOND'])
      TEMPLATE=REPLICATE(CREATE_STRUCT('JULIAN',0D),N_ELEMENTS(STRUCT))
      STRUCT=STRUCT_MERGE(STRUCT,TEMPLATE)
;			===> ALB > AL
			OK = WHERE(STRMID(STRUPCASE(STRUCT.CR),0,3) EQ 'ALB',COUNT) & IF COUNT GE 1 THEN STRUCT[OK].CR = 'AL'+ STRMID(STRUCT[OK].CR,3)
;			===> DEL > DE
			OK = WHERE(STRMID(STRUPCASE(STRUCT.CR),0,3) EQ 'DEL',COUNT) & IF COUNT GE 1 THEN STRUCT[OK].CR = 'DE'+ STRMID(STRUCT[OK].CR,3)
;			===> DATE
			DATE=DT_MDY2DATE(struct.date)
			STRUCT.JULIAN = JULDAY(STRMID(DATE,4,2), STRMID(DATE,6,2),STRMID(DATE,0,4),STRUCT.GMT_TIME)
			STRUCT.DATE 	= DT_JULIAN2DATE(STRUCT.JULIAN)

			OK=WHERE(STRUCT.SALINITY EQ '{null}',COUNT) & IF COUNT GE 1 THEN STRUCT[OK].SALINITY=MISSINGS(STRUCT[OK].SALINITY)
      OK=WHERE(STRUCT.TEMPERATURE EQ '{null}',COUNT) & IF COUNT GE 1 THEN STRUCT[OK].TEMPERATURE=MISSINGS(STRUCT[OK].TEMPERATURE)
      OK=WHERE(STRUCT.DEPTH EQ '{null}',COUNT) & IF COUNT GE 1 THEN STRUCT[OK].DEPTH=MISSINGS(STRUCT[OK].DEPTH)

      STRUCT.LOND = STRUCT.LOND* (-1.0)

;			===> Narrow to 3m depths
			ok=WHERE(STRUCT.DEPTH EQ '3')
			_STRUCT=STRUCT[OK]
			SAVE,FILENAME=SAVE_FILE,_STRUCT,/COMPRESS
			STRUCT_2CSV,CSV_FILE,_STRUCT
    ENDIF ELSE BEGIN
      PRINT,'ERROR: NO TARGET *.SAVE FILES FOUND'
    ENDELSE ;  IF N_ELEMENTS(file_save) GE 1 THEN BEGIN
  ENDIF ;   IF DO_CTD_EDIT_2CHL EQ 1 THEN BEGIN
; ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||

; *********************************************
; ******** C T D  E D I T   P L O T    ********
; *********************************************
  IF DO_CTD_EDIT_PLOT EQ 1 THEN BEGIN
    PRINT, 'S T E P:    DO_CTD_EDIT_PLOT'
    SAVE_FILE = DIR_SAVE+'CTD_CAL_4FTO.SAVE'
    PSFILE = DIR_REPORT + 'FTO_CTD_EDIT.PS'
    STRUCT=READALL(SAVE_FILE)

		PSPRINT,/FULL,/COLOR
		STRUCT_PLOT,STRUCT,/PMULTI
		PSPRINT
  ENDIF ;   IF DO_FTO_EDIT_PLOT EQ 1 THEN BEGIN
; |||||||||||||||||||||||||||||||||||||||||||||



END; #####################  End of Routine ################################
