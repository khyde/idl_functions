; $ID:	MACO_MAIN.PRO,	2020-07-08-15,	USER-KJWH	$
PRO MACO_MAIN, STRUCT
;+
; NAME:
; 	MACO_MAIN

;		This Program Reads a CSV Database file: MACO_TAGNO.CSV (TAGNO, YYYYMMDD, LON, LAT, TEMPERATURE)
;		and uses the input date and longitude to extract SST data from 1024 pixels at that longitude and within the
;		Standard EC map domain.
;		OUTPUT:
;		 A CSV file with 3 columns (LON,LAT, SST) where SST are Floating Point;
;		 Output file name e.g. !D_20040803-TAGNO.CSV (LON,LAT,SST (Deg C))

; HISTORY:
;     July 4, 2006  Written by: J.E. O'Reilly
;-
; *************************************************************************

	ROUTINE_NAME='MACO_MAIN'

	DISK = 'D:'
  DELIM=DELIMITER(/PATH)
  PATH = DISK+DELIM + 'PROJECTS\MACO'+DELIM

; **************************************
; Directories
; Edit these as needed
  DIR_LOG  = path+ 'LOG'+delim
	DIR_DATA = path+'DATA'+delim
  DIR_SAVE = path+'save'+delim
  DIR_PLOTS = path+'plots'+delim
  DIR_REPORT = path+'report'+delim

	DIR_ALL = [DIR_DATA,DIR_SAVE,DIR_PLOTS,DIR_REPORT]



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

  DO_READ_DATA_AND_SAVE				=	0
  DO_STRUCT_PLOT_DATA 				= 0
  DO_EDIT_DATA  							= 0
  DO_STRUCT_PLOT_EDIT_DATA 		= 0
  DO_MAP_DATA   							= 0
  DO_CHECK_TRACK 							= 0

  DO_PLOT_DATA  							= 0


	EXTRACT_LONGITUDE_SST    =		1


; *********************************************
; ******** C H E C K   D I R S  ***************
; *********************************************
  IF DO_CHECK_DIRS GE 1 THEN BEGIN
    PRINT, 'S T E P:    DO_CHECK_DIRS'
    FOR N=0,N_ELEMENTS(DIR_ALL)-1 DO BEGIN
      AFILE = STRMID(DIR_ALL(N),0,STRLEN(DIR_ALL(N))-1)
      IF FILE_TEST(AFILE,/DIRECTORY) EQ 0L THEN FILE_MKDIR,AFILE
    ENDFOR
  ENDIF ; IF DO_CHECK_DIRS GE 1 THEN BEGIN
; |||||||||||||||||||||||||||||||||||||||||||||||||

; **************************************************************
 	IF DO_READ_DATA_AND_SAVE GE 1 THEN BEGIN
; **************************************************************
		OVERWRITE = DO_READ_DATA_AND_SAVE GE 2

    PRINT, 'S T E P:    DO_READ_DATA_AND_SAVE'
    exist = FILE_TEST(SAVE_FILE)
    IF exist EQ 0 OR OVERWRITE GE 1 THEN BEGIN
 			DATA = READ_CSV(data_file)
;			===> IF file is huge then only want to read it once, then save  the variables of interest
			SAVE,FILENAME=SAVE_FILE,/COMPRESS, DATA ; etc other variables
		ENDIF

  ENDIF ; IF DO_READ_DATA_AND_SAVE GE 1 THEN BEGIN
; |||||||||||||||||||||||||||||||||||||||||||||||||


; **********************************************************
; ******** S T R U C T  P L O T  D A T A     ***************
; **********************************************************
  IF DO_STRUCT_PLOT_DATA GE 1 THEN BEGIN
    PRINT, 'S T E P:    DO_STRUCT_PLOT_DATA'
    exist = FILE_TEST(SAVE_file)
    IF exist EQ 0 THEN BEGIN
    	PRINT,'ERROR: Can not find the SAVE file: ' + SAVE_file
    	STOP
    ENDIF
 		STRUCT = READALL(SAVE_FILE)
 		PSPRINT,FILENAME=STRUCT_PLOT_FILE,/FULL,/COLOR
 		STRUCT_PLOT,STRUCT,  /PMULTI, TITLE_PAGE=ROUTINE_NAME, COLOR_SYM=color_sym,PAGE=4,  _EXTRA=_extra
 		PSPRINT
  ENDIF ; IF DO_STRUCT_PLOT_DATA GE 1 THEN BEGIN
; |||||||||||||||||||||||||||||||||||||||||||||||||

; *********************************************
 	IF DO_EDIT_DATA GE 1 THEN BEGIN
; *********************************************

    PRINT, 'S T E P:    DO_EDIT_DATA'
    exist = FILE_TEST(SAVE_file)
    IF exist EQ 0 THEN BEGIN
    	PRINT,'ERROR: Can not find the data file: ' + data_file
    	STOP
    ENDIF
 		DATA = READ_CSV(SAVE_FILE)

;		Do whatever editing is needed, merging etc. then save the edited data

;		===> IF file is huge then only want to read it once, then save  the variables of interest
		SAVE,FILENAME=SAVE_FILE,/COMPRESS, depth, kpar ; etc other variables

  ENDIF ; IF DO_READ_DATA GE 1 THEN BEGIN
; |||||||||||||||||||||||||||||||||||||||||||||||||

; ******************************************************************
	IF DO_STRUCT_PLOT_EDIT_DATA GE 1 THEN BEGIN
; ******************************************************************

    PRINT, 'S T E P:    DO_STRUCT_PLOT_EDIT_DATA'
    PROJECTS = ['ACE','OMP','SEEP1','SEEP2']
		PROJECTS = 'ACE'
		FOR _PROJECT = 0,N_ELEMENTS(PROJECTS)-1 DO BEGIN
			APROJECT = PROJECTS(_PROJECT)
			STRUCT_PLOT_FILE = DIR_PLOTS+APROJECT+'-EDIT.PS'
    	FILES=FILELIST(DIR_DATA+APROJECT+'\*-EDIT.SAVE')
    	PSPRINT,FILENAME=STRUCT_PLOT_FILE,/FULL,/COLOR
    	FOR _FILES=0L,N_ELEMENTS(FILES)-1 DO BEGIN
				AFILE=FILES(_FILES)
				FN=FILE_PARSE(AFILE)
 				STRUCT = READALL(AFILE)
 				TITLE_PAGE = APROJECT+'  '+FN[0].FIRST_NAME
 				PRINT,TITLE_PAGE
 				STRUCT_PLOT,STRUCT,  /PMULTI, TITLE_PAGE=TITLE_PAGE, COLOR_SYM=color_sym,   _EXTRA=_extra
 			ENDFOR
 		PSPRINT
 		ENDFOR
  ENDIF ; IF DO_STRUCT_PLOT_DATA GE 1 THEN BEGIN
; |||||||||||||||||||||||||||||||||||||||||||||||||





; *********************************************
	IF DO_MAP_DATA GE 1 THEN BEGIN
; *********************************************

    PRINT, 'S T E P:    DO_MAP_DATA'
 		PROJECTS = ['ACE','OMP','SEEP1','SEEP2']
		PROJECTS = 'ACE'
		FOR _PROJECT = 0,N_ELEMENTS(PROJECTS)-1 DO BEGIN
			APROJECT = PROJECTS(_PROJECT)
			PSFILE = DIR_PLOTS+APROJECT+'-MAP.PS'
    	FILES=FILELIST(DIR_DATA+APROJECT+'\*-EDIT.SAVE')
    	PSPRINT,FILENAME=PSFILE,/FULL,/COLOR
    	PAL_36,R,G,B
    	TVLCT,R,G,B
     	PSPRINT,FILENAME=PSFILE,/FULL,/COLOR
    	PAL_36,R,G,B
    	TVLCT,R,G,B
    	FOR _FILES=0L,N_ELEMENTS(FILES)-1 DO BEGIN
				AFILE=FILES(_FILES)
				FN=FILE_PARSE(AFILE)
 				DB = READALL(AFILE)
 				TITLE_PAGE = APROJECT+'  '+FN[0].FIRST_NAME
 				PRINT,TITLE_PAGE
 				!P.MULTI=0
 				MAP_EC
				X= !P.CLIP[0]
				Y= !P.CLIP[1]
				XSIZE= !P.CLIP(2)-!P.CLIP[0]
				YSIZE= !P.CLIP(3)-!P.CLIP[1]
				MAP_CONTINENTS,/HIRES,/COAST,COLOR=34
				PLOTS,DB.LON,DB.LAT,COLOR=0,LINESTYLE=1
				PLOTS,DB.LON,DB.LAT,COLOR=21,PSYM=1,SYMSIZE=0.15
				XYOUTS,DB.LON,DB.LAT,STRTRIM(DB.STATION,2),COLOR=21,CHARSIZE=0.2

				PLOTS,DB[0].LON,DB[0].LAT,COLOR=21,PSYM=4,SYMSIZE=0.6
				XYOUTS,0.14,0.50,TITLE_PAGE,/NORMAL,COLOR=0
				FRAME,/PLOT,COLOR=0,THICK=5
 			ENDFOR
 		PSPRINT
 		ENDFOR
	ENDIF ; IF DO_MAP_DATA GE 1 THEN BEGIN
; |||||||||||||||||||||||||||||||||||||||||||||||||


; *********************************************
	IF DO_PLOT_DATA GE 1 THEN BEGIN
; *********************************************

    PRINT, 'S T E P:    DO_PLOT_DATA'

;		===>
 		RESTORE, SAVE_FILE  ; depth and kpar should now be in memory

		PSPRINT,filename=psfile, /COLOR,/HALF
		PLOT, KPAR,DEPTH  ; ... other plotting keywords, ETC.
		PSPRINT


  ENDIF ; IF DO_PLOT_DATA GE 1 THEN BEGIN
; |||||||||||||||||||||||||||||||||||||||||||||||||


; *******************************************************
; ******** EXTRACT LONGITUDE SST   *********************
; *******************************************************
  IF EXTRACT_LONGITUDE_SST GE 1 THEN BEGIN
    PRINT, 'S T E P:    EXTRACT_LONGITUDE_SST'
    OVERWRITE = EXTRACT_LONGITUDE_SST GE 2
    MAP='EC'
    M=MAPS_SIZE(MAP)
    PX = M.PX
    PY = M.PY
		FILE = DIR_DATA+'MAKO_SATTAG_DATA.csv'
		EXIST=FILE_TEST(FILE )
		IF EXIST EQ 0 THEN GOTO,DONE_EXTRACT_LONGITUDE_SST ; >>>>>>>




		DIRS = ['E:\SST_GEQ-EC\ts_images\save\','E:\SST_GEQ-EC\SAVE_MERGE\']
		FOR _DIR = 0,N_ELEMENTS(DIRS)-1 DO BEGIN
			SST_DIR = DIRS(_DIR)
			METHODS = ['N4AT','N4ATG']
			FOR _METHOD = 0,N_ELEMENTS(METHODS)-1 DO BEGIN
				SST_METHOD = METHODS(_METHOD)

;			!D_20060520-N4AT-EC-SST-INTERP-TS_IMAGES.SAVE

			SST_FILES = SST_DIR+'!D_*-'+'*'+SST_METHOD+'-'+MAP+'*-SST*.SAVE'
			FILES = FILE_SEARCH(SST_FILES)

STOP
		IF FILES[0] EQ '' THEN STOP
		FN=FILE_ALL(FILES)

		NAME=''
   	DB=READ_CSV(FILE)
		DB=STRUCT_2NUM(DB)


    LL=LATLON_MAPGEN(MAP=MAP, PX=PX,PY=PY,NOROUND=NOROUND,  _EXTRA=_extra)
		LAT_RANGE = [MIN(LL.LAT),MAX(LL.LAT)]

		ZWIN,[PX,PY]
		CALL_PROCEDURE,'MAP_'+MAP

;		===> FOR EVERY TAG OBSERVATION EXTRACT LONGITUDES FOR THE IMAGE
		FOR NTH=0L,N_ELEMENTS(DB)-1L DO BEGIN
			ERASE,0
			D=DB[NTH]
			DATE = D.DATE
			PERIOD = '!D_'+STRTRIM(DATE,2)
			OK = WHERE(FN.PERIOD EQ PERIOD,COUNT)
			IF COUNT NE 1 THEN CONTINUE ;                 >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

			FA = FN[OK]
			SST_FILE = FA.FULLNAME
			CSV_FILE =  DIR_SAVE  + FA.PERIOD+'-'+FA.MAP+'-'+FA.METHOD+'-'+FA.PROD+'-'+FA.MATH+'-'+'TAG_'+STRTRIM(D.TAG,2) +'-LON_LAT.CSV'
			IF FILE_TEST(CSV_FILE) AND OVERWRITE EQ 0 THEN CONTINUE ; >>>>>>>>>>>>>>>>>>>>>>>>>>>


			DATA = STRUCT_SD_READ(SST_FILE)

			PLOTS,[D.LON,D.LON],LAT_RANGE,COLOR=1
			IM=TVRD()
			OK=WHERE(IM EQ 1,COUNT)
			IF COUNT NE 1024 THEN STOP
			INDX = ARRAY_INDICES(IM,OK)

			XYZ=CONVERT_COORD(INDX(0,*), INDX(1,*),/DEVICE,/TO_DATA)
			ZWIN
			LONS = REFORM(XYZ(0,*))
			LATS = REFORM(XYZ(1,*))

;			!D_20040803-TAGNO.CSV (LON,LAT,SST (Deg C))

			S=MAP_TRACK_SWATH(LONS=[D.LON,D.LON], LATS=LAT_RANGE, MAP=MAP, WIDTH=7, NAME=name,/WITHIN_MAP)

			STRUCT = REPLICATE(CREATE_STRUCT('LON','','LAT','','N','','SST',''),N_ELEMENTS(S))
		  PX_1 = M.PX -1
			PY_1 = M.PY -1

			FOR I = 0L,N_ELEMENTS(S)-1L DO BEGIN
				PXS=WORDS(S(I).PX_SWATH,DELIM=';',/NO_NULL)
				PYS=WORDS(S(I).PY_SWATH,DELIM=';',/NO_NULL)
				LONS=WORDS(S(I).LON_SWATH,DELIM=';',/NO_NULL)
				LATS=WORDS(S(I).LAT_SWATH,DELIM=';',/NO_NULL)
				_STATS = STATS(DATA([PXS],[PYS]),/QUIET)

	  		STRUCT(I).LON = LONS[1]
	  		STRUCT(I).LAT = LATS[1]
	  		STRUCT(I).N   = _STATS.N
	  		STRUCT(I).SST = _STATS.MEAN
			ENDFOR

;			===> Write Longitude scan to OUTPUT FILE with info: !D_20040803-TAGNO.CSV (LON,LAT,SST (Deg C))
			STRUCT_2CSV,CSV_FILE,STRUCT



		ENDFOR;
	ENDFOR ; METHODS
	ENDFOR; DIRS
		DONE_EXTRACT_LONGITUDE_SST:
	ENDIF  ; EXTRACT_LONGITUDE_SST
; |||||||||||||||||||||||||||||||||||||||||||||||||


PRINT,'END OF MACO_MAIN.PRO'

END; #####################  End of Routine ################################
