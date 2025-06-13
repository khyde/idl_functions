; $ID:	FTO_MAIN.PRO,	2020-06-30-17,	USER-KJWH	$
;+
;	This Program is a MAIN program for Processing the Flow-Through Logs Collected on NMFS surveys

;	Jan 01,2001	Written by:	J.E. O'Reilly
;-
; *************************************************************************
PRO FTO_MAIN
  ROUTINE_NAME='FTO_MAIN'
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
;  SUBSET = 1 ;
  SUBSET=0

; ================>
; Switches controlling which Processing STEPS to do:
  DO_CHECK_DIRS  =1
  DO_FTO_LOG_2SAVE = 0
  DO_FTO_LOG_EDIT   =0
  DO_FTO_EDIT_PLOT = 0


  DO_SCS_GPS_COMBINE 			= 1
  DO_GPS_FTO_MERGE		    =	1
  DO_GPS_FTO_MERGE_PLOT 	= 0
  DO_GPS_FTO_MERGE_FORMAT	=	1
  ; ====================>
; EXCLUDE LIST
; This is a list of files with known problems in uncompression or where
; there is not a matched set of all products for a given INAME
;  EXCLUDE_INAMES = 'S2000004172640'
  IF N_ELEMENTS(EXCLUDE_INAMES) EQ 0 THEN EXCLUDE_INAMES = ''
; YOU CAN ADD TO EXCLUDE_INAMES THE INAMES OF OTHER PROBLEM FILES.
; STEPS PROCESSED THEREAFTER WILL SKIP OVER INAMES IN THE EXCLUDE_INAMES
; ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||

; ===================>
; Different delimiters for WIN, MAX, AND X DEVICES
  os = STRUPCASE(!VERSION.OS) & computer=GET_COMPUTER() & SLASH=DELIMITER(/PATH)

  COMPUTER=GET_COMPUTER()
  IF COMPUTER EQ 'BURRFISH' THEN BEGIN
  	path = 'g:\'
  	DIR_SCS='G:\FRRF\'
  ENDIF
	IF COMPUTER EQ 'FLOUNDER' THEN BEGIN
		path = 'H:\'
		DIR_SCS='h:\SCS\'
	ENDIF
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
  DIR_LOG  = path+method+SLASH+'LOG'+DIR_SUFFIX+SLASH

  DIR_SAVE = path+method+SLASH+'save'+DIR_SUFFIX+SLASH
  DIR_FREQ = path+method+SLASH+'freq'+DIR_SUFFIX+SLASH

  DIR_STATS = path+method+SLASH+'stats'+DIR_SUFFIX+SLASH
  DIR_PLOTS =path+method+SLASH+'plots'+DIR_SUFFIX+SLASH

  DIR_GPS_COMBINE  = path+method+SLASH+'gps'+DIR_SUFFIX+SLASH

  DIR_ALL = [DIR_LOG,DIR_LOG,DIR_SAVE,DIR_FREQ,DIR_STATS,DIR_PLOTS,DIR_GPS_COMBINE]

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
; ******** F T O  L O G   2 S A V E ************
; *********************************************
  IF DO_FTO_LOG_2SAVE EQ 1 THEN BEGIN
    PRINT, 'S T E P:    DO_FTO_LOG_2SAVE'
 files = [$
;'AL9804_FTO_1',$ ; bad data incomplete
'AL9811_FTO_1','AL9811_FTO_2','AL9811_FTO_3','AL9811_FTO_4',$
'DE9813_FTO_1','DE9813_FTO_2','DE9813_FTO_3','DE9813_FTO_4','DE9813_FTO_5',$
'AL9902_FTO_1',$
'AL9903_FTO_1','AL9903_FTO_2',$
'AJ9901_FTO_1',$
'IS9901_FTO_1','IS9901_FTO_2',$
'AL9910_FTO_1','AL9910_FTO_2',$
'NP9901_FTO_1',$
'AL9911_FTO_1',$
'AL0001_FTO_1','AL0001_FTO_2',$
'AL0002_FTO_1','AL0002_FTO_2','AL0002_FTO_3','AL0002_FTO_4','AL0002_FTO_5',$
'DE0006_FTO_1','DE0006_FTO_2',$
'AL0005_FTO_1',$
'AL0006_FTO_1','AL0006_FTO_2','AL0006_FTO_3','AL0006_FTO_4','AL0006_FTO_5',$
'AL0007_FTO_1','AL0007_FTO_2',$
'AL0102_FT0_1',$
'AL0103_FTO_1','AL0103_FTO_2','AL0103_FTO_3','AL0103_FTO_4',$
'AL0106_FTO_1',$
'DE0105_FTO_1',$

'AL0106_FTO_1',$
'AL0109_FTO_1',$
'AL0110_FTO_1','AL0110_FTO_2','AL0110_FTO_3','AL0110_FTO_4', $
'AL0111_FTO_1','AL0111_FTO_2', $
'AL0202_FTO_1', $
'AL0202_FTO_1_CTD',$
'AL0203_FTO_1','AL0203_FTO_2',$
'AL0204_FTO_1','AL0204_FTO_2','AL0204_FTO_3','AL0204_FTO_4','AL0204_FTO_5',$
'AL0206_FTO_1','AL0206_FTO_1_CTD','AL0206_FTO_2',$
'AL0207_FTO_1','AL0207_FTO_2','AL0207_FTO_3',$
'NS0201_FTO_1','NS0201_FTO_2',$
'AL0210_FTO_1','AL0210_FTO_2','AL0210_FTO_3','AL0210_FTO_4','AL0210_FTO_5',$
'DE0210_FTO_1','DE0210_FTO_2',$
'DE0301_FTO_1',$
'DE0302_FTO_1','DE0302_FTO_2',$
'DE0303_FTO_1','DE0303_FTO_2','DE0303_FTO_3','DE0303_FTO_4',$
'DE0305_FTO_1','DE0305_FTO_2','DE0305_FTO_3',$
'AL0305_FTO_1','AL0305_FTO_2','AL0305_FTO_3','AL0305_FTO_4','AL0305_FTO_5','AL0305_FTO_5',$
'AM0301_FTO_1','AM0301_FTO_1',$
'AL0306_FTO_1',$
'AL0401_FTO_1',$
'AL0402_FTO_1','AL0402_FTO_2',$
'AL0403_FTO_1','AL0403_FTO_2','AL0403_FTO_3','AL0403_FTO_4',$
'AL0405_FTO_1','AL0405_FTO_2','AL0405_FTO_3',$
'AL0408_FTO_1','AL0408_FTO_2',$
'AL0409_FTO_1','AL0409_FTO_2','AL0409_FTO_3','AL0409_FTO_4',$
'AL0410_FTO_1','AL0410_FTO_2']

;;FILES=['AL0305_FTO_1','AL0305_FTO_2','AL0305_FTO_3','AL0305_FTO_4','AL0305_FTO_5']
;files=['AL0306_FTO_1',$
;'AL0401_FTO_1',$
;'AL0402_FTO_1','AL0402_FTO_2','AL0402_FTO_3',$
;'AL0403_FTO_1','AL0403_FTO_2']

;FILES=['AL0405_FTO_1','AL0405_FTO_2','AL0405_FTO_3']
;FILES=['AL0408_FTO_1','AL0408_FTO_2']
files_log = dir_log + files + '.csv'

    IF N_ELEMENTS(files_log) GE 1 THEN BEGIN
      PRINT, 'Found ' + NUM2STR(N_ELEMENTS(files_log)) + '  *.csv  files'
      PRINT, 'This step will Read each FTO LOG FILE (CSV) '
      PRINT, 'And Make a combined CSV File and a Compressed SAVE file'
      FTO_LOG_2SAVE,files_log, DIR_OUT=DIR_SAVE
    ENDIF ELSE BEGIN
      PRINT,'ERROR: NO TARGET *.CSV FILES FOUND'
    ENDELSE ;  IF N_ELEMENTS(files_log) GE 1 THEN BEGIN
  ENDIF ;  IF DO_FTO_LOG_2SAVE EQ 1 THEN BEGIN
; ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||

; *********************************************
; ******** F T O  L O G   E D I T  ************
; *********************************************
  IF DO_FTO_LOG_EDIT EQ 1 THEN BEGIN
    PRINT, 'S T E P:    DO_FTO_LOG_EDIT'
    FILE_SAVE = FILELIST(DIR_SAVE + 'FTO.SAVE')
    IF N_ELEMENTS(file_save) GE 1 THEN BEGIN
      PRINT, 'Found ' + NUM2STR(N_ELEMENTS(files_save)) + '  *.save  files'
      PRINT, 'This step will Calculate Chlor from the FTO.SAVE FILE '
      PRINT, 'And Make an output compressed SAVE file and CSV'
      FTO_LOG_EDIT,file_save, DIR_OUT=DIR_SAVE ,dir_plots=dir_plots
    ENDIF ELSE BEGIN
      PRINT,'ERROR: NO TARGET *.SAVE FILES FOUND'
    ENDELSE ;  IF N_ELEMENTS(file_save) GE 1 THEN BEGIN
  ENDIF ;   IF DO_FTO_EDIT_2CHL EQ 1 THEN BEGIN
; ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||


; *********************************************
  IF DO_FTO_EDIT_PLOT EQ 1 THEN BEGIN
; *********************************************
    PRINT, 'S T E P:    DO_FTO_EDIT_PLOT'
    FILE_EDIT = FILELIST(DIR_SAVE + 'FTO_EDIT.SAVE')

    IF N_ELEMENTS(FILE_EDIT) GE 1 THEN BEGIN
      PRINT, 'Found ' + NUM2STR(N_ELEMENTS(FILE_EDIT)) + '  *.save  files'
      PRINT, 'This step will PLOT DATA IN the FTO_LOG_2SAVE FILE '
      PRINT, 'And Make an PostScript plot file'
      FTO_EDIT_PLOT,FILE_EDIT, dir_plots=dir_plots
    ENDIF ELSE BEGIN
      PRINT,'ERROR: NO TARGET *.SAVE FILES FOUND'
    ENDELSE ;  IF N_ELEMENTS(FILE_EDIT) GE 1 THEN BEGIN
  ENDIF ;   IF DO_FTO_EDIT_PLOT EQ 1 THEN BEGIN
; ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||


; *********************************************
  IF  DO_SCS_GPS_COMBINE GE 1 THEN BEGIN
; *********************************************
    PRINT, 'S T E P:     DO_SCS_GPS_COMBINE'
    FILE_EDIT = FILELIST(DIR_SAVE + 'FTO_EDIT.SAVE')
    FA        = FILE_ALL(DIR_SCS,'*GPS_EDIT*.SAVE') & HELP, FA
    FA.SUB = STRUPCASE(FA.SUB)
    S=SORT(FA.SUB) & FA=FA(S)
    CRUISES = STRMID(FA.SUB,0,6)
    S=SORT(CRUISES) & CRUISES=CRUISES(S)   & U=UNIQ(CRUISES) & CRUISES = CRUISES(U)
    FOR N=0,N_ELEMENTS(CRUISES)-1 DO BEGIN
      ACR = CRUISES(N)
      OK = WHERE(STRMID(FA.SUB,0,6) EQ ACR,COUNT)
      FA_SET  = FA[OK]
      TARGETS = FA_SET.FULLNAME
      SAVEFILE = DIR_GPS_COMBINE+ACR+'_GPS_EDIT_COMBINE.SAVE

;			===> Skip if savefile is already made and later than mtimes of targets
			FI=FILE_INFO(savefile)

      IF FI.SIZE GT 0 AND FI.MTIME GT MAX(FA_SET.MTIME) AND DO_SCS_GPS_COMBINE EQ 1 THEN BEGIN
				PRINT, 'Skipping ' + ACR
      	CONTINUE
      ENDIF
      PRINT, 'COMBINING GPS DATA FROM: '+ ACR + ' From: '
      LIST, TARGETS

      FOR _TARGET = 0,N_ELEMENTS(TARGETS)-1L DO BEGIN
       ATARGET = TARGETS(_TARGET)
       S=READALL(ATARGET)
       NEW = CREATE_STRUCT('CR',ACR) & NEW = REPLICATE(NEW,N_ELEMENTS(S))
       S=STRUCT_MERGE(new,s)
       IF _TARGET EQ 0 THEN ALL = S ELSE ALL = [TEMPORARY(ALL),TEMPORARY(S)]
      ENDFOR
      SAVE,FILENAME=SAVEFILE,ALL,/COMPRESS
    ENDFOR
  ENDIF ;   IF  DO_SCS_GPS_COMBINE EQ 1 THEN BEGIN
; ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||


; *********************************************
 	IF DO_GPS_FTO_MERGE GE 1 THEN BEGIN
; *********************************************
    PRINT, 'S T E P:    DO_GPS_FTO_MERGE'
    SAVEFILE 							= DIR_SAVE				+	'FTO_EDIT_MERGE_GPS.SAVE
    FI=FILE_INFO(SAVEFILE)
    FA = FILE_ALL(DIR_GPS_COMBINE + '*GPS_EDIT_COMBINE.SAVE',/SUB) & HELP, FA

    IF FI.SIZE GT 0 AND FI.MTIME GT MAX(FA.MTIME) AND DO_GPS_FTO_MERGE EQ 1 THEN BEGIN
				PRINT, 'Skipping ' +' S T E P:    DO_FTO_MERGE_LOG_GPS'
      	GOTO, DONE_DO_FTO_MERGE_LOG_GPS
    ENDIF

    S_CHL = READALL(DIR_SAVE+ 'FTO_EDIT.SAVE')
    NEW = CREATE_STRUCT('GPS_LAT',0.0,'GPS_LON',0.0)
    NEW = STRUCT_2MISSINGS(NEW)
    NEW = REPLICATE(NEW,N_ELEMENTS(S_CHL))
    S_CHL = STRUCT_MERGE(S_CHL, NEW)

    U=UNIQ(S_CHL.CRUNAME) & CRUISES = STRUPCASE(S_CHL(U).CRUNAME)


;		LLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLL
    FOR N=0,N_ELEMENTS(CRUISES)-1 DO BEGIN
      ACR = CRUISES(N)
      OK_CHL 			= WHERE(S_CHL.CRUNAME EQ ACR,COUNT_CHL)
      OK_GPS_FILE = WHERE(STRMID(FA.NAME,0,6) EQ ACR,COUNT_GPS_FILE)

      IF COUNT_GPS_FILE EQ 1 AND COUNT_CHL GE 1 THEN BEGIN
        TARGET = FA(OK_GPS_FILE).FULLNAME
        PRINT, 'MERGING GPS FROM: '+TARGET+'   WITH CHL DATA FOR CRUISE:   '+ ACR
        S_GPS = READALL(TARGET)

;				===> Find gps for the chl within a tolerance
        OK_GPS=WHERENEAREST(S_GPS.GPS_JULIAN,S_CHL(OK_CHL).FTO_JULIAN, COUNT,NEAR=TOLERANCE,VALID=valid)
        IF COUNT EQ 0 THEN BEGIN
        	PRINT, 'GPS NO MATCH FOR '+NUM2STR(COUNT) + ' Records in ' +TARGET
          LIST, S_CHL(OK_CHL),TAGS=[0,12,13,14,15,16,21,31]
        ENDIF ELSE BEGIN
          PRINT, 'GPS  MATCH FOR '+NUM2STR(COUNT) + ' Records in ' +TARGET
					S_CHL(OK_CHL(VALID)).GPS_LAT = S_GPS(OK_GPS(VALID)).GPS_LAT
          S_CHL(OK_CHL(VALID)).GPS_LON = S_GPS(OK_GPS(VALID)).GPS_LON
				ENDELSE
      ENDIF ELSE BEGIN
        PRINT, 'NO____________________________________________________________________ GPS   FOR CRUISE:   '+ ACR
      ENDELSE ; IF COUNT_GPS_FILE EQ 1 AND COUNT_CHL GE 1 THEN BEGIN

    ENDFOR ; FOR N=0,N_ELEMENTS(CRUISES)-1 DO BEGIN
     S=S_CHL
     SAVE,FILENAME=SAVEFILE,S,/COMPRESS
     SAVE_2CSV,SAVEFILE
	DONE_DO_FTO_MERGE_LOG_GPS:
  ENDIF ;   IF DO_GPS_FTO_MERGE EQ 1 THEN BEGIN
; ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||



; *********************************************
  IF DO_GPS_FTO_MERGE_PLOT EQ 1 THEN BEGIN
; *********************************************
    PRINT, 'S T E P:    DO_GPS_FTO_MERGE_PLOT'
    FILE_MERGE = FILELIST(DIR_SAVE + 'FTO_EDIT_MERGE_GPS.SAVE')
    S=READALL(FILE_MERGE)

    LANDMASK = READALL('D:\IDL\IMAGES\MASK_NEC_NO_LAKES.png')
    OK_WATER = WHERE(LANDMASK EQ 255)
    OK_LAND  = WHERE(LANDMASK EQ 1)
    LANDMASK(OK_LAND) = 252
     LANDMASK(OK_WATER) = 254

    IF N_ELEMENTS(FILE_MERGE) GE 1 THEN BEGIN
      PRINT, 'This step will PLOT DATA IN the FTO_EDIT_MERGE_GPS.SAVE  FILE '
      PRINT, 'And Make an PostScript plot file'

      OK = WHERE(S.CHL_A NE MISSINGS(S.CHL_A) AND S.GPS_LAT NE MISSINGS(S.GPS_LAT),COUNT)
      U=UNIQ(S.CRUNAME) & CRUISES = STRUPCASE(S(U).CRUNAME)
      PAL_SW3,R,G,B
      FOR N=0,N_ELEMENTS(CRUISES)-1 DO BEGIN

        ACR = CRUISES(N)
        OK = WHERE(S.CRUNAME EQ ACR AND S.CHL_A NE MISSINGS(S.CHL_A) AND $
                   S.GPS_LAT NE MISSINGS(S.GPS_LAT),COUNT)
        IF COUNT GE 1 THEN BEGIN
        	D=S[OK]
         	TXT = ACR
          DT = [MIN(D.FTO_JULIAN),MAX(D.FTO_JULIAN)]
        	DT  = DT_FMT(MIN(D.FTO_JULIAN),/DAY,/MDY) + '!C'+DT_FMT(MAX(D.FTO_JULIAN),/DAY,/MDY)

;					CHLOR_A MAP
 					ZWIN,[1024,1024]
        	MAP_NEC
 					PROD='CHLOR_A'
 			 		IMAGE = MAP_ADD_TXT(LANDMASK,0.040,0.92,TXT, COLOR=0,charsize=6,CHARTHICK=3)
    			IMAGE = MAP_ADD_TXT(IMAGE,0.040,0.82,PROD, COLOR=0,charsize=6,CHARTHICK=3)
    	 		IMAGE = MAP_ADD_TXT(IMAGE,0.040,0.72,DT, COLOR=0,charsize=5,CHARTHICK=3)
    	 		IMAGE = MAP_ADD_BATHY(IMAGE,BATHS=[200], COLOR=255,THICK=1)
    	 		TV,IMAGE
          FOR NTH=0,N_ELEMENTS(D)-1L DO BEGIN
           	COLOR = SD_SCALES(PROD=PROD,D[NTH].CHL_A,/DATA2BIN)
           	CIRCLE,COLOR=COLOR,/FILL
          	PLOTS, d[NTH].gps_lon,d[NTH].gps_lat,psym=8,THICK=5,SYMSIZE=2.25,COLOR=COLOR
          ENDFOR
        	IMAGE = TVRD()
        	ZWIN
;   			=================> Add Legend
      		FONT_TIMES
      		LEG = COLOR_BAR_SCALE(PROD= PROD,PAL=_PAL,BACKGROUND=252,/TRIM,/NAME)
      		IMAGE = IMAGE_WELD(IMAGE, LEG)
        	PNGFILE = DIR_PLOTS + ACR + '_CHLOR_A.PNG'
        	WRITE_PNG,PNGFILE,IMAGE,R,G,B

;					FLUOR/CHLA MAP
 					ZWIN,[1024,1024]
        	MAP_NEC
        	PROD='PER'
 					BAR_LABEL='Fluor/Chla' & PROD='PER'
 			 		IMAGE = MAP_ADD_TXT(LANDMASK,0.040,0.92,TXT, COLOR=0,charsize=6,CHARTHICK=3)
    			IMAGE = MAP_ADD_TXT(IMAGE,0.040,0.82,BAR_LABEL, COLOR=0,charsize=6,CHARTHICK=3)
    	 		IMAGE = MAP_ADD_TXT(IMAGE,0.040,0.72,DT, COLOR=0,charsize=5,CHARTHICK=3)
    	 		IMAGE = MAP_ADD_BATHY(IMAGE,BATHS=[200], COLOR=255,THICK=1)
    	 		TV,IMAGE
          FOR NTH=0,N_ELEMENTS(D)-1L DO BEGIN

           	COLOR = SD_SCALES(PROD=PROD,FLOAT(D[NTH].FLO_FLR_VALUE)/FLOAT(D[NTH].CHL_A),/DATA2BIN)
           	CIRCLE,COLOR=COLOR,/FILL
          	PLOTS, d[NTH].gps_lon,d[NTH].gps_lat,psym=8,THICK=5,SYMSIZE=2.25,COLOR=COLOR
          ENDFOR
        	IMAGE = TVRD()
        	ZWIN

;   			=================> Add Legend
      		FONT_TIMES
      		LEG = COLOR_BAR_SCALE(PROD= PROD,XTITLE=BAR_LABEL,PAL=_PAL,BACKGROUND=252,/TRIM )
      		IMAGE = IMAGE_WELD(IMAGE, LEG)
        	PNGFILE = DIR_PLOTS + ACR + '_FLUOR_CHLA.PNG'
        	WRITE_PNG,PNGFILE,IMAGE,R,G,B
				ENDIF
      ENDFOR
    ENDIF ELSE BEGIN
      PRINT,'ERROR: NO TARGET *.SAVE FILES FOUND'
    ENDELSE ;  IF N_ELEMENTS(FILE_MERGE) GE 1 THEN BEGIN
  ENDIF ;    IF DO_GPS_FTO_MERGE_PLOT EQ 1 THEN BEGIN
; ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||


; *********************************************
  IF DO_GPS_FTO_MERGE_FORMAT EQ 1 THEN BEGIN
; *********************************************
    PRINT, 'S T E P:    DO_GPS_FTO_MERGE_FORMAT'
    FILE_MERGE = FILELIST(DIR_SAVE + 'FTO_EDIT_MERGE_GPS.SAVE')
    S=READALL(FILE_MERGE)

    IF N_ELEMENTS(FILE_MERGE) GE 1 THEN BEGIN
      PRINT, 'This step will REFORMAT DATA IN the FTO_EDIT_MERGE_GPS.SAVE TO STANDARD SEATRUTH FORMAT'
      PRINT
      OK = WHERE(S.CHL_A NE MISSINGS(S.CHL_A) AND S.GPS_LAT NE MISSINGS(S.GPS_LAT),COUNT)
      S=S[OK]
      HELP,S

;     REFORMAT: YEAR	MONTH	DAY	HOUR	MINUTE	SECOND	LAT	LON	DEPTH	CHL	PHA	CRUISE	STA	SOURCE
      S=STRUCT_RENAME(S,['GPS_LAT','GPS_LON','CHL_A','CRUNAME'],['LAT','LON','CHL','CRUISE'])

      C=STRUCT_COPY(S,TAGNAMES=['YEAR','MONTH','DAY','HOUR','MINUTE'])
      SEC = CREATE_STRUCT('SECOND',0) & SEC = REPLICATE(SEC,N_ELEMENTS(S))

      D=STRUCT_COPY(S,TAGNAMES=['LAT','LON'])

      DEP=CREATE_STRUCT('DEPTH',0.0) & DEP = REPLICATE(DEP,N_ELEMENTS(S))
      DEP(*).DEPTH=FLOAT(S.DEPTH)

      E=STRUCT_COPY(S,TAGNAMES=['CHL'])

      F=STRUCT_COPY(S,TAGNAMES=['CRUISE'])

      P=CREATE_STRUCT('PHA',0.0) & P=STRUCT_2MISSINGS(P) & P = REPLICATE(P,N_ELEMENTS(D))
      G=CREATE_STRUCT('STA','-1','SOURCE','NMFS') & G=REPLICATE(G,N_ELEMENTS(D))

      NEW = STRUCT_MERGE(C,SEC) & NEW = STRUCT_MERGE(NEW,D)&
      NEW = STRUCT_MERGE(NEW,DEP) &
      NEW = STRUCT_MERGE(NEW,E)&
      NEW = STRUCT_MERGE(NEW,P) & NEW = STRUCT_MERGE(NEW,F) & NEW = STRUCT_MERGE(NEW,G)

      SAVEFILE = DIR_SAVE+'FTO_SEATRUTH.SAVE'
      SAVE,FILENAME=SAVEFILE,NEW
      SAVE_2CSV,SAVEFILE
    ENDIF ELSE BEGIN
      PRINT,'ERROR: NO TARGET *.SAVE FILES FOUND'
    ENDELSE ;  IF N_ELEMENTS(FILE_MERGE) GE 1 THEN BEGIN
  ENDIF ;    DO_GPS_FTO_MERGE_FORMAT EQ 1 THEN BEGIN
; ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||



END; #####################  End of Routine ################################
