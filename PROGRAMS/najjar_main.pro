; $ID:	NAJJAR_MAIN.PRO,	2020-06-30-17,	USER-KJWH	$
;+
; This Program is a main routine for the OCL HYDRO DATA
; HISTORY:
;     Dec 4 2004  Written by: J.E. O'Reilly
;-
; *************************************************************************

	PRO NAJJAR_MAIN

  ROUTINE_NAME='NAJJAR_MAIN'
 	COMPUTER=GET_COMPUTER()
	IF COMPUTER EQ 'LAPSANG' 	THEN DISK = 'D:'
	IF COMPUTER EQ 'LOLIGO' 	THEN DISK = 'D:'
	IF COMPUTER EQ 'BURRFISH' THEN DISK = 'G:'
  DELIM=DELIMITER(/PATH)
  DIR_BATHY = 'D:\IDL\BATHY\GEBCO\'
  DIR_IMAGES = 'D:\IDL\IMAGES\'
  DIR_SRTM30_BROWSE 		= 'D:\PROJECTS\SRTM30\BROWSE\'

  PATH = DISK+DELIM + 'PROJECTS\NAJJAR'+DELIM

; **************************************
; Directories
; Edit these as needed
	DIR_DATA 		= path+'DATA'+delim
	DIR_DOC 		= path+'DOC'+delim
  DIR_SAVE 		= path+'SAVE'+delim
  DIR_PLOTS 	= path+'PLOTS'+delim
  DIR_BROWSE	= path+'BROWSE'+delim
  DIR_ZIP_IN	= path+'ZIP_IN'+delim
  DIR_ZIP_OUT	= path+'ZIP_OUT'+delim
  DIR_JUNK    = path+'JUNK'+delim


	DIR_ALL = [DIR_DATA,DIR_DOC,DIR_SAVE,DIR_BROWSE,DIR_PLOTS,DIR_SAVE,DIR_ZIP_IN,DIR_ZIP_OUT,DIR_JUNK]

; *******************************************
; Set up color system defaults
	SETCOLOR
	PAL_36


; ********************************************************************************
; ***** U S E R    S W I T C H E S  Controlling which Processing STEPS to do *****
; ********************************************************************************
;	0 (Do not do the step)
;	1 (Do the step)
; 2 (Do the step and OVERWRITE any output if it alread exists)

; ================>
; Switches controlling which Processing STEPS to do:
	DO_CHECK_DIRS = 1 ; GOOD IDEA TO ALWAYS KEEP THIS SWITCH ON


	DO_UNZIP								= 0
	DO_ASSIGN_SUBAREAS 			= 2
	DO_ZIP_SUBAREAS					= 0


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


;	***********************************************
	IF DO_UNZIP GE 1 THEN BEGIN
;	***********************************************
		ZFILES = FILE_SEARCH(DIR_ZIP_IN+'*.ZIP')
		LIST, ZFILES
		FOR _ZFILE = 0,N_ELEMENTS(ZFILES)-1 DO BEGIN
			ZFILE = ZFILES(_ZFILE)
	 		ZIP,FILE=ZFILE,DIR_OUT=DIR_DATA
	;   find files in any expanded subfolders
	  	DIRS_DATA  = FILE_SEARCH(dir_DATA,'*',/MARK_DIR,/FULLY_QUALIFY_PATH,/TEST_DIRECTORY  )
			TXT_FILES=FILE_SEARCH(DIRS_DATA+'*.TXT')
			FILE_MOVE, TXT_FILES, DIR_DATA
		ENDFOR
	ENDIF


;	****************************************
	IF DO_ASSIGN_SUBAREAS GE 1 THEN BEGIN
;	****************************************
		MAP = 'EC'
		PX = 1024
		PY = 1024
		LAND=READ_LANDMASK(MAP='EC',PX=PX,PY=PY)
		DIR_SUBAREA_MASK = 'D:\PROJECTS\SUBAREAS\PLOTS\'
	  MASK_FILE = DIR_SUBAREA_MASK+'MASK_SUBAREA-EC-PXY_1024_1024-ECOS.SAVE'
	  SUBAREA_IMAGE=STRUCT_SD_READ(MASK_FILE,STRUCT=STRUCT)
		PAL_IDL31,R,G,B


		FILES=FILE_SEARCH(dir_data+'*.txt')
		LIST,FILES


		ZWIN,[PX,PY]
		CALL_PROCEDURE,'MAP_'+MAP

;		LLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLL
		FOR NTH = 0,N_ELEMENTS(FILES)-1 DO BEGIN
			INFILE = FILES[NTH]
			FN=FILE_PARSE(INFILE)
			OUTFILE =  DIR_SAVE+FN.FIRST_NAME+'-EC-SUBAREA_CODES.TXT'
			IF FILE_TEST(OUTFILE) EQ 1 AND  DO_ASSIGN_SUBAREAS LT 2 THEN CONTINUE ; >>>>>>>>>>>>>


			TEXT = ''

			OPENR,LUN_IN,	INFILE,/GET_LUN
			OPENW,LUN_OUT,OUTFILE,/GET_LUN

			WHILE NOT EOF(LUN_IN) DO BEGIN
				READF,LUN_IN,TEXT
				SUBAREAS = MAP_DEG2IMAGE(SUBAREA_IMAGE,FLOAT(STRMID(TEXT,20,10)),FLOAT(STRMID(TEXT,11,9)),  X=x, Y=y,AROUND=0, SUBS=subs)

				IF FINITE(SUBAREAS) EQ 0 THEN SUBAREAS = 0

			  T = '  '+ STRING(SUBAREAS,FORMAT='(I03)')
			  NEW = TEXT  + T;
			  PRINTF,LUN_OUT,NEW
			ENDWHILE
			ZWIN
			CLOSE,LUN_IN 	& FREE_LUN,LUN_IN
			CLOSE,LUN_OUT & FREE_LUN,LUN_OUT

	ENDFOR ; EACH TXT FILE

	ENDIF ; DO_ASSIGN_SUBAREAS


;	****************************************
	IF DO_ZIP_SUBAREAS GE 1 THEN BEGIN
;	****************************************
  NAME = 'SIEWERT-EC-SUBAREAS-'
	FILES=FILE_SEARCH(dir_SAVE+'*.txt')

	LIST, FILES

	FI=FILE_INFO(FILES)
	CUM_SIZE=TOTAL(FI.SIZE,/CUMULATIVE)

;	===> ASSUME 15% COMPRESSION 7:1
	COMPRESSION = 80.0
	ZIP_SIZE = 3E6
	RAW_SIZE = ZIP_SIZE*COMPRESSION
	PRINT,RAW_SIZE
	PRINT, 'MAKING ABOUT: '+ STRTRIM(LAST(CUM_SIZE)/RAW_SIZE,2)+' ZIP FILES'

	STOP

	COUNTER = 1
;	WWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW
	WHILE N_ELEMENTS(FILES) GE 1 DO BEGIN
		FI=FILE_INFO(FILES)
		CUM_SIZE=TOTAL(FI.SIZE,/CUMULATIVE)

		OK=WHERE(CUM_SIZE LE RAW_SIZE,COUNT,NCOMPLEMENT=NCOMPLEMENT,COMPLEMENT=COMPLEMENT)
		IF COUNT GE 1 THEN BEGIN
			TARGETS = FILES[OK]
			IF NCOMPLEMENT GE 1 THEN FILES = FILES(COMPLEMENT) ELSE GONE,FILES
		ENDIF ELSE BEGIN
			TARGETS = FILES[0]
			IF NCOMPLEMENT GE 2 THEN FILES = FILES(COMPLEMENT(1:*)) ELSE GONE,FILES
		ENDELSE
		OUTFILE =  NAME+STRTRIM(COUNTER,2)+'.ZIP'
		ZIP, files=TARGETS, DIR_OUT=DIR_ZIP_OUT,	OUTFILE=outfile
 		COUNTER = COUNTER + 1
	ENDWHILE


	STOP
	ENDIF

PRINT,'END OF SUBAREAS_MAIN.PRO'

END; #####################  End of Routine ###############################
