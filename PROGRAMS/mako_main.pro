; $ID:	MAKO_MAIN.PRO,	2020-07-08-15,	USER-KJWH	$
PRO MAKO_MAIN, STRUCT
;+
; NAME:
; 	MAKO_MAIN

;		This Program Reads a CSV Database file: MAKO_TAGNO.CSV (TAGNO, YYYYMMDD, LON, LAT, TEMPERATURE)
;		and uses the input date and longitude to extract SST data from 1024 pixels at that longitude and within the
;		Standard EC map domain.
;		OUTPUT:
;		 A CSV file with 3 columns (LON,LAT, SST) where SST are Floating Point;
;		 Output file name e.g. !D_20040803-TAGNO.CSV (LON,LAT,SST (Deg C))

; HISTORY:
;     July 4, 2006  Written by: J.E. O'Reilly
;-
; *************************************************************************

	ROUTINE_NAME='MAKO_MAIN'

	DISK = 'D:'
  DELIM=DELIMITER(/PATH)
  PATH = DISK+DELIM + 'PROJECTS\MAKO'+DELIM

	DIR_IMAGES='D:\IDL\IMAGES\'

; **************************************
; Directories
; Edit these as needed
  DIR_LOG  = path+ 'LOG'+delim
	DIR_DATA = path+'DATA'+delim
  DIR_SAVE = path+'save'+delim
  DIR_STATS = path+'stats'+delim
  DIR_PLOTS = path+'plots'+delim
  DIR_REPORT = path+'report'+delim
  DIR_ANNO   = path+'ANNO'+delim

	DIR_ALL = [DIR_DATA,DIR_SAVE,DIR_STATS,DIR_PLOTS,DIR_REPORT,DIR_ANNO]



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




	EXTRACT_LONGITUDE_SST    		=	0

	DO_PLOT_TRACK 							= 0

	DO_TS_IMAGES_ANNO          	= 0

	DO_TS_IMAGES_2LONLAT_CSV    = 0

	DO_TS_IMAGES_AVERAGE_BY_TAG_PERIOD = 1




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



; *********************************************
 	IF DO_PLOT_TRACK GE 1 THEN BEGIN
; *********************************************
		LONLAT_FILE=DIR_DATA+'MAKO-TempLats-20060817.csv'
		MAP='NEC'
		TAGNAME = 'TAG'

		DB=READ_CSV(LONLAT_FILE)
		TAGNAMES = TAG_NAMES(DB)
		OK_TAG = WHERE(TAGNAMES EQ TAGNAME,COUNT_TAG)
		SETS=WHERE_SETS(DB.(OK_TAG))
		OK = WHERE(SETS.VALUE NE MISSINGS(SETS.VALUE))
		SETS = SETS[OK]

;		LLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLL
		FOR _SETS=0,N_ELEMENTS(SETS)-1 DO BEGIN
			ASET = SETS(_SETS)
			SUBS=WHERE_SETS_SUBS(ASET)
			NAME = STRTRIM(ASET.VALUE,2)
			PSFILE=DIR_PLOTS+ 'TAG-'+NAME+'-TRACK.PS'
			PSPRINT,/COLOR,/FULL,FILENAME=PSFILE
			D=DB(SUBS)


	  	PLOT_TRACK, D.LONG,D.LAT ,DATE=D.DATE,MAP=MAP, TITLE='TAG '+NAME,  pos_title=[0.2,0.7],CHARSIZE_STATIONS=0.75
	  	PSPRINT
	  ENDFOR
	ENDIF






; *********************************************
 	IF DO_TS_IMAGES_ANNO GE 1 THEN BEGIN
; *********************************************
		LONLAT_FILE=DIR_DATA+'MAKO-TAG-20276.csv'
		LONLAT_FILE=DIR_DATA+'MAKO-TempLats-20060817.csv'
		MAP = 'NEC'
		M=MAPS_SIZE(MAP)
		TAGNAME = 'TAG'
		 AUTHORS  = " A. Wood, B. Wetherbee, J.O'Reilly"
			ADDRESS = 'GSO URI  & NOAA,NMFS,RI'
			SENSORS = 'AVHRR,TERRA,AQUA,GOES'

		ADD_NAME= 1
		DAYS = [20,10]
	;	DATE_RANGE = ['20050901','20051030']

		DRIVES = GET_DRIVE_NAMES() & OK=WHERE(DRIVES.NAME EQ 'IOMEGA_HDD_11',COUNT)
		IF COUNT EQ 1 THEN DRIVE=DRIVES[OK].DRIVE ELSE STOP

	  DIR_BROWSE = DRIVE+'SST_GEQ-'+MAP+'\TS_IMAGES\BROWSE\NEC\'
    IMAGE_FILES = FILE_SEARCH(DIR_BROWSE+'!D_*-N4ATG-'+MAP+'-PXY_'+STRTRIM(M.PX,2)+'_'+STRTRIM(M.PY,2)+'-SST-INTERP-TS_IMAGES-LEG.PNG')

    HELP, IMAGE_FILES

stop

		TS_IMAGES_ANNO,  LONLAT_FILE=LONLAT_FILE, MAP=MAP, TAGNAME=TAGNAME,PRODS=prods,$
 										 IMAGE_FILES=IMAGE_FILES, DATE_RANGE=date_range,$
  									 DIR_OUT=DIR_ANNO,ADD_NAME=ADD_NAME, DAYS=DAYS


	ENDIF
; |||||||||||||||||||||||||||||||||||||||||||||||||||||




; *********************************************
 	IF DO_TS_IMAGES_2LONLAT_CSV GE 1 THEN BEGIN
; *********************************************
	DRIVES = GET_DRIVE_NAMES() & OK=WHERE(DRIVES.NAME EQ 'IOMEGA_HDD_13',COUNT)
	IF COUNT EQ 1 THEN DRIVE=DRIVES[OK].DRIVE ELSE STOP

	DIR_FILES = DRIVE+ 'ts_images_save_n4atg_sst_nec\'
  FILES = FILE_SEARCH(DIR_FILES+'!D_*-N4ATG-NEC-SST-INTERP-TS_IMAGES.SAVE')



  DATE_RANGE = ['20040819','20040828']
  DATE_RANGE = ['20040827','20040909']
   DATE_RANGE = ['20050801','20050811']
   DATE_RANGE = ['20050926','20051022']


  JD_RANGE = DATE_2JD(DATE_RANGE)
	FN = FILE_PARSE(FILES)
	JD = PERIOD_2JD(FN.FIRST_NAME)
	OK=WHERE(JD GE JD_RANGE[0] AND JD LE JD_RANGE[1])
	FILES = FILES[OK]

;	LLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLL
  FOR _files=0L,N_ELEMENTS(files)-1l DO BEGIN
    afile=files(_files)
    FN=PARSE_IT(AFILE,/ALL)
			DATA = STRUCT_SD_READ(AFILE,PROD=APROD,STRUCT=STRUCT,SUBS=SUBS)
	    STRUCT=MAP_IMAGE_2LONLAT(DATA,MAP='NEC')
	    OK=WHERE(STRUCT.DATA NE MISSINGS(STRUCT.DATA),COUNT)
	    IF COUNT GE 1 THEN BEGIN
	     	txtfile = DIR_SAVE+FN.NAME+'.CSV'
	    	STRUCT_2CSV,txtfile,STRUCT[OK]
	    ENDIF ELSE BEGIN
	    	PRINT,'ERROR: NO GOOD DATA'
	    ENDELSE

  ENDFOR

STOP
  files= FILE_SEARCH(DIR_SAVE+'!D_*-N4ATG-NEC-SST-INTERP-TS_IMAGES.CSV')
  ZIP,FILES=FILES,/ZIP
	ENDIF
; |||||||||||||||||||||||||||||||||||||||||||||||||||||






; *********************************************
 	IF DO_TS_IMAGES_AVERAGE_BY_TAG_PERIOD GE 1 THEN BEGIN
; *********************************************
		DO_MAKE_MEAN_SST = 0
		DO_ADD_BATHY_ADD_TRACK = 1

		LONLAT_FILE=DIR_DATA+'MAKO-TAG-20276.csv'
		LONLAT_FILE=DIR_DATA+'MAKO-TempLats-20060817.csv'
		MAP = 'NEC'
		M=MAPS_SIZE(MAP)
		TAGNAME = 'TAG'


  	DIR_SAVE = 'F:\SST_GEQ-NEC\ts_images\save\'
	;	DATE_RANGE = ['20050901','20051030']

	IF DO_MAKE_MEAN_SST GE 1 THEN BEGIN
		DRIVES = GET_DRIVE_NAMES() & OK=WHERE(DRIVES.NAME EQ 'IOMEGA_HDD_11',COUNT)
		IF COUNT EQ 1 THEN DRIVE=DRIVES[OK].DRIVE ELSE STOP


		METHOD='N4ATG'
		PROD = 'SST'
		map='NEC'
		MATH='INTERP'
		DIR_SAVE = 'F:\SST_GEQ-NEC\ts_images\save\'

		FILES=FILELIST(DIR_SAVE+'*'+METHOD+'*'+MAP+'*'+MATH+'*.SAVE')
		FN=FILE_ALL(FILES)

		DATE_RANGES = STRARR(2,4)
		DATE_RANGES(*,0) = ['20040818','20040912']
		DATE_RANGES(*,1) = ['20040818','20040831']
		DATE_RANGES(*,2) = ['20050731','20050813']
		DATE_RANGES(*,3) = ['20050926','20051024']

STOP




;		LLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLL
		FOR _DATE_RANGE = 0,N_ELEMENTS(DATE_RANGES(0,*))-1 DO BEGIN
			DATE_RANGE=DATE_RANGES(*,_DATE_RANGE)

			JD_RANGE  = DATE_2JD(DATE_RANGE)
			JD = PERIOD_2JD(FN.PERIOD)
			OK = WHERE(JD GE JD_RANGE[0] AND JD LE JD_RANGE[1],COUNT)
			FILES = FILES[OK]

;			LLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLL
	  	FOR NTH=0,N_ELEMENTS(FILES)-1 DO BEGIN
		  	IF NTH EQ 0 THEN START=1 ELSE START = 0
		  	IF NTH EQ N_ELEMENTS(FILES)-1 THEN BEGIN
		  		CALC = 1
		  		STRUCT = 1
		  	ENDIF ELSE BEGIN
		  		CALC = 0
		  		STRUCT = 0
		  	ENDELSE

				DATA=STRUCT_SD_READ(FILES[NTH])
				DATA=VALID_DATA(DATA,PROD=PROD)

				A = STATS_ARRAYS(DATA, RANGE=range,MISSING=MISSING,START=START,CALC=CALC,STRUCT=STRUCT,NAME='TEST'  )
	 		ENDFOR

; 		|||||||||||||||||||||||||||||||||||||||||||||||||||||
			PERIOD='!DD_'+DATE_RANGE[0]+'_'+DATE_RANGE[1]
			FULLNAME = DIR_STATS+PERIOD+'-'+METHOD+'-'+MAP+'-'+PROD+'-INTERP-MEAN.SAVE'


 			STRUCT_SD_WRITE,    FULLNAME,           IMAGE=A.MEAN, 		$
												PROD=PROD, 				  ASTAT='MEAN', 	AMATH=AMATH,$
                        PERIOD=PERIOD,      SENSOR=SENSOR,        SATELLITE=SATELLITE,  SAT_EXTRA=SAT_EXTRA,$
                        METHOD=METHOD,      SUITE=SUITE,          MAP=MAP, $
                        INFILE=FILES,$
                        NOTES=NOTES,        ERROR=ERROR,$
                        HELP=HELP,$
                        _EXTRA=_extra

			STRUCT_SD_2PNG,FULLNAME,/ADDDATE,/ADD_LAND,/ADD_COAST,/ADD_COLORBAR,/OVERWRITE
			STRUCT_SD_2HDF,FULLNAME,/LONLAT

		ENDFOR;

		ENDIF


		IF DO_ADD_BATHY_ADD_TRACK GE 1 THEN BEGIN
			LONLAT_FILE=DIR_DATA+'MAKO-TempLats-20060817.csv'
		  DB=READ_CSV(LONLAT_FILE)
;		Tag 20329  8/18/04 to 9/12/04
;		Tag 20330  8/18/04 to 8/31/04
;		Tag 20287  7/31/05 to 8/13/05
;		Tag 20276  9/26/05 to 10/24/05
			FILES=FILELIST('D:\PROJECTS\MAKO\SAVE\'+'!DD_*-N4ATG-NEC-PXY_1024_1024-SST-INTERP-MEAN-LEG.PNG')
			FOR NTH=0,N_ELEMENTS(FILES)-1 DO BEGIN
				AFILE=FILES[NTH]
				IMAGE=READ_PNG(AFILE,R,G,B)
				FN=FILE_ALL(AFILE)
				IF FN.PERIOD EQ '!DD_20040818_20040831' THEN Tag = '20330'
				IF FN.PERIOD EQ '!DD_20040818_20040912' THEN Tag = '20329'
				IF FN.PERIOD EQ '!DD_20050731_20050813' THEN Tag = '20287'
				IF FN.PERIOD EQ '!DD_20050926_20051024' THEN Tag = '20276'
		  	OK=WHERE(DB.TAG EQ TAG)
		  	D=DB[OK]

				IMAGE = MAP_ADD_BATHY(IMAGE, MAP='NEC', BATHS=[100,2000],COLOR=253,THICK=2, SRTM30=srtm30)
		  	ZWIN,IMAGE
		  	MAP_NEC
		  	FONTS,'TIMES'
		  	TV,IMAGE
			  PLOTS,D.LONG,D.LAT,COLOR=0,THICK=3
			  XYOUTS,0.1,0.8,/NORMAL,'Tag: '+TAG,CHARSIZE=2.5,COLOR=0

			;	PLOT_TRACK, D.LONG,D.LAT ,DATE=D.DATE,MAP=MAP, TITLE='TAG '+TAG,  pos_title=[0.2,0.7],CHARSIZE_STATIONS=0.75
				IMAGE=TVRD()
				ZWIN
				TVLCT,R,G,B
				pngfile=REPLACE(AFILE,'-LEG.PNG','-LEG-BATHY-TRACK.PNG')
				WRITE_PNG,PNGFILE,IMAGE,R,G,B

			ENDFOR
			STOP
		ENDIF
	ENDIF













PRINT,'END OF MAKO_MAIN.PRO'

END; #####################  End of Routine ################################
