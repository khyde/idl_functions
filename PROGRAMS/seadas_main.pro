; $ID:	SEADAS_MAIN.PRO,	2020-06-30-17,	USER-KJWH	$
; Main program to run SeaDAS processing
;
PRO SEADAS_MAIN, year
;
;
;  Program calls SD_SEADAS_L1_2_MAP.PRO
;  This program combines input seawifs l1a files with sd_seawifs_l1_2_map.pro
;  and feeds it to seadas
;
;  WRITTEN:
;  Oct 19, 2006	K.J.W.Hyde:
;
;  MODIFICATIONS:
;  Mar 7,  2007   K.J.W.Hyde: Changed the make inventory step
;                             Made compatible to run either SeaWiFS or MODIS
;  Apr 27, 2007   K.J.W.Hyde: Updated the make inventory and check what needs to be processed steps
;                             Added period plot step
;  May 11, 2007   K.J.W.Hyde: Added subset option
;                             Added L0 processing capabilities
;  Jul 27, 2007   K.J.W.Hyde: Added atmoshpric correction options (DEFAULT, SWIR, TBD_INDEX)
;                             Removed the METHODLIST loop
;  Dec 04, 2010   D.W.Moonan: Begin changing for L1 reprocessing 2010, on Linux x86_64

;
  ROUTINE_NAME = 'SEADAS_MAIN'
;
;  To run,
;  1) At the Linux prompt type 'idl'
;  2) Type '.r seadas_main' to compile the main program
;  3) Type 'seadas_main' to execute the program
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  OS = !VERSION.OS
  SLASH = DELIMITER(/SLASH)

; *****************************************************************************************************
;	USER INPUTS & SWITCHES
; *****************************************************************************************************

;	USER = 'RS'
;	USER = 'JOR'
;	USER = 'JOR_RS'
; USER = 'OC'

  ;IF OS EQ 'Win32' THEN DRIVE_IDL       = 'D:' ELSE DRIVE_IDL       = '/mnt/NTFS-D'   ; IDL drive for inventory and plots
  ;IF OS EQ 'Win32' THEN DRIVE_METOZ     = 'F:' ELSE DRIVE_METOZ     = '/mnt/NTFS-E'   ; METOZ drive
  ;IF OS EQ 'Win32' THEN DRIVE_ATTEPH    = 'E:' ELSE DRIVE_ATTEPH    = '/mnt/NTFS-E'   ; ATTEPH drive
  ;IF OS EQ 'Win32' THEN DRIVE_ATTEPH    = 'E:' ELSE DRIVE_ATTEPH    = '/media/IOMEGA_HDD_14'   ; ATTEPH drive
  ;IF OS EQ 'Win32' THEN DRIVE_IN        = 'D:' ELSE DRIVE_IN        = '/d1/seadas/l1bin'   ; Input drive
  ;IF OS EQ 'Win32' THEN DRIVE_L2_IN     = 'F:' ELSE DRIVE_L2_IN     = '/mnt/NTFS-F'   ; L2 input drive (to run just the BL2MAP step)

  ;DIR_OUT 	    = '/data_lx/'                                                     ; Output directory (only the base directory, additional folders are added later)
  
  ; DIR_INVENTORY = DRIVE_IDL       + '/IDL/INVENTORY/'                                 ; Inventory directory
  ; DIR_PLOTS     = DRIVE_IDL       + '/IDL/PLOTS/'                                     ; Plot directory
  ; DIR_METOZ     = DRIVE_METOZ     + '/METOZ/Z/'                                       ; METOZ directory
  ; DIR_IN        = DRIVE_IN        + '/TEMP-SEAWIFS-MLAC-L1A/'                              ; SeaWiFS input directory

  ;DIR_OUT          = '/d2/output4/'
; testing uncompressed locally extracted
;  DIR_OUT          = '/d1/seawifs/extracted/2010o/'
;  YEAR = 2010
;  DIR_IN          = '/d1/seawifs/extracted/2010i/

; use this after having created links ;
; todo: automate previously uncompressed files and symbolic link tricks.
  DIR_OUT          = '/d3/modistmpo/'
  ;YEAR = 2010
  YEAR = 2009
  ;DIR_IN          = '/d3/output/inputlinks/2010/'
  DIR_IN          = '/d3/modistmp/'

  
  DIR_INVENTORY    = '/d3/tmp/inventory/'
  DIR_PLOTS        = '/d3/tmp/plots/'
  DIR_ATTEPH       = '/d3/tmp/atteph/'
  
;  DIR_METOZ       = '/d2/metoz/'
;  DIR_METOZ       = '/d1/seawifs/l1anc/'

;  DIR_IN          = '/d1/seawifs/l1bin/' + num2str(year) + '/'
;  DIR_IN          = '/d1/seawifs/l1bin/1997/'
;  DIR_IN          = '/home/dmoonan/l1test_modis/'
;  DIR_IN          = '/home/dmoonan/l1test_seawifs/'
;  DIR_IN          = DRIVE_IN        + '/MODISA_L0/Z/'                                      ; MODIS L0 input directory
;  DIR_IN          = DRIVE_IN        + '/MODISA_L1A/Z/'                                 ; MODIS L1A input directory

;  DIR_L2_IN       = DRIVE_L2_IN     + '/SEAWIFS_L2_MLAC/'                               ; L2 input directory (to run just the BL2MAO step)
;  DIR_L2_IN       =  DRIVE_L2_IN     + '/MODISA_LAC-L2/'                               ; L2 input directory (to run just the BL2MAO step)
;  DIR_ATTEPH      = DRIVE_ATTEPH    + '/ATTEPH/Z/'                                      ; ATTEPH directory (for MODIS processing)

 ; DIR_IN = '/media/New_Volume/MODISA_L0/Z/'

  OVERWRITE       = 0                                                                 ; OVERWRITE keyword
  REVERSE_FILES   = 1
  
 ATM_CORRECTION  = ['DEFAULT']                                                       ; Do default atmospheric correction
; ATM_CORRECTION  = ['DO_SWIR']                                                       ; Do SWIR correction for HIGH RES MODIS processing
 ; ATM_CORRECTION  = ['DO_TBD']                                                        ; Do SWIR correction based on the turbidity index switch
 ; ATM_CORRECTION  = ['TBD_INDEX','SWIR','DEFAULT']

  RESOLUTION      = '-1'                                                              ; Default resolution for 1km MODIS and SeaWiFS
 ; RESOLUTION      = ['250','500','1000']                                              ; High Res MODIS resolution options

  FILES_IN_TARGET = '*2007*'                                                          ; File search string
  FILES_IN_TARGET = '*'

  INVENTORY_FILE  = DIR_INVENTORY + 'INVENTORY_SEADAS.CSV'                            ; Inventory
  REPROCESS_CSV   = DIR_INVENTORY + 'NEEDS_PROCESSING_L1A.CSV'                        ; Processing list
 ; REPROCESS_CSV   = DIR_INVENTORY + 'NEEDS_PROCESSING_MODIS-L0-PAMLICO.CSV'

  INPUT_MAPS      = ['NEC','EC','MASS_BAY']                                           ; Desired output maps
;  INPUT_MAPS      = ''

  DO_SUBSET = '0'                                                                     ; If subset EQ 1 then SUBSET the L1A and GEO files
  SUBSET_REGIONS = ['']                                                             ; Must include a subset region with coordinates


; *** PROCESSING SWITCHES *****
  DO_UPDATE_ATTEPH_FILES           = 0                                               ; Copy ATTEPH files to the \usr\local\seadas\data\modis\atteph folder
  DO_MAKE_INVENTORY                = 1                                               ; Make/append inventory from files in given directories
  DO_CHECK_WHAT_NEEDS_PROCESSING   = 0                                                ; Based on inventory, determine what files need to be processed
  DO_PERIOD_PLOTS                  = 0                                                ; Make plots to determine where there are gaps in the processed data
  USE_NEEDS_PROCESSING_LIST        = 0                                                ; Keyword to only search for the files that need to be processed
  DO_RUN_SEADAS                    = 1                                               ; Run SEADAS


; *** SWITCHES TO KEEP INTERMEDIATE FILES (1 = KEEP, 0 = DELETE) ***
  KEEP_l0           =0                                                                ; MODIS high res AND SeaWiFS (non MLAC)
  KEEP_l1a          =0
  KEEP_l1a_new      =0                                                                ; SeaWiFS (non MLAC)
  KEEP_l1a_sub      =0                                                                ; MODIS high res
  KEEP_l1b          =0                                                                ; MODIS
  KEEP_l1b_hkm      =0                                                                ; MODIS high res
  KEEP_l1b_qkm      =0                                                                ; MODIS high res
  KEEP_l2           =1
  KEEP_met1         =0
  KEEP_met2         =0
  KEEP_oz           =0
  KEEP_geo          =0                                                                ; MODIS
  KEEP_geo_sub      =0                                                                ; MODIS high res
  KEEP_log          =0
  KEEP_seadas_log   =0
  KEEP_station_info =0


;||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||

; *****************************************************************************************************
  IF KEYWORD_SET(DO_UPDATE_ATTEPH_FILES) GE 1 THEN BEGIN
; *****************************************************************************************************
    PRINT, 'S T E P:    DO_UPDATE_ATTEPH_FILES '
    PRINT, 'UPDATING ATTEPH FOLDERS FOR MODIS-SEADAS PROCESSING: '

    IF OS EQ 'Win32' THEN BEGIN
      PRINT, 'WARNING - DO_UPDATE_ATTEPH_FILES SHOULD NOT BE RUN IN WINDOWS BECAUSE FILES ARE BEING COPIED TO /usr/local'
      STOP
    ENDIF

    DIRS = FILE_SEARCH(DIR_ATTEPH,'*')
    FI=FILE_INFO(DIRS) & FP = FILE_PARSE(DIRS)
    OK=WHERE(FI.DIRECTORY EQ 1 AND STRLEN(FP.NAME) EQ 4,COUNT)
    DIRS = DIRS[OK]
    YEARS = FP[OK].NAME
    YEARS = 2007
    FOR YTH = 0L, N_ELEMENTS(YEARS)-1 DO BEGIN
      DISK_OUT = '/usr/local/seadas/data/modis/atteph/' + YEARS(YTH) + SLASH
      FILE_UPDATE_DIRS,DIRS(YTH),DISK_OUT,/FOLDER
    ENDFOR
  ENDIF


; *****************************************************************************************************
  IF KEYWORD_SET(DO_MAKE_INVENTORY) GE 1 THEN BEGIN
; *****************************************************************************************************

    PRINT, 'S T E P:    DO_MAKE_INVENTORY '
    PRINT, 'MAKING INVENTORY FILE FOR SEADAS PROCESSING: '

;    DIRS = ['F:/SEAWIFS_L2_MLAC/','F:/SEAWIFS_L2_MLAC_EC/','F:/SEAWIFS_L2_MLAC_NEC/','F:/SEAWIFS_L2_MLAC_MASS_BAY/',$
;    				'E:/MODISA_LAC-L2/Z/']
    DIRS = [ $
       DIR_IN]
;      '/d2/SEAWIFS_L2_MLAC/', $
;      '/d2/SEAWIFS_L2_MLAC_EC/', $
;      '/d2/SEAWIFS_L2_MLAC_NEC/', $
;      '/d2/SEAWIFS_L2_MLAC_MASS_BAY/', $
;      '/d2/MODISA_LAC-L2/Z/']

;   IF MODIS THEN $
    FILES_OUT_TARGET = '*.hdf.bz2'
;   IF SEAWIFS THEN $
;    FILES_OUT_TARGET = '*.hdf.gz

;   ***** Make backup of original inventory file *****
    IF FILE_TEST(INVENTORY_FILE) EQ 1 THEN FILE_COPY, INVENTORY_FILE, INVENTORY_FILE + '-' + DATE_NOW()

;   ***** Loop through directories *****
    FOR _DIR = 0L, N_ELEMENTS(DIRS)-1 DO BEGIN
      DIR_LOCAL = DIRS(_DIR)
      FILES_LOCAL = FILE_SEARCH(DIR_LOCAL + FILES_OUT_TARGET)

;     ***** Read inventory file *****
      INV_EXIST=FILE_TEST(INVENTORY_FILE)
      IF INV_EXIST EQ 1 THEN INV = READALL(INVENTORY_FILE)

      IF N_ELEMENTS(FILES_LOCAL) GE 1 AND FILES_LOCAL[0] NE '' THEN BEGIN
        PRINT, 'This step will write HDF file inames  to a .csv file '
        FA = FILE_ALL(FILES_LOCAL)

        STRUCT = CREATE_STRUCT('INAME','','MTIME','','DATE','','SATELLITE','','SENSOR','','LEVEL','','METHOD','','MAP','')
        STRUCT = REPLICATE(STRUCT,N_ELEMENTS(FILES_LOCAL))
        STRUCT.INAME      = FA.NAME
        STRUCT.MTIME      = STRTRIM(STRING(FA.MTIME),2)
        STRUCT.DATE       = FA.DATE_START
        STRUCT.SATELLITE  = FA.SATELLITE
        STRUCT.SENSOR     = FA.SENSOR
        STRUCT.LEVEL      = FA.LEVEL
        STRUCT.METHOD     = FA.METHOD
        STRUCT.MAP        = FA.MAP

        IF INV_EXIST EQ 1 THEN CONCAT = STRUCT_CONCAT(INV, STRUCT) ELSE CONCAT = STRUCT

        CONCAT = CONCAT[SORT(CONCAT.INAME)]
        SETS = WHERE_SETS(CONCAT.INAME)

        IF N_ELEMENTS(CONCAT) EQ N_ELEMENTS(SETS) THEN NEW = CONCAT ELSE BEGIN
          PRINT, 'ADDING FILES TO INVENTORY'
          NEW = CREATE_STRUCT('INAME','','MTIME','','DATE','','SATELLITE','','SENSOR','','LEVEL','','METHOD','','MAP','')
          NEW = REPLICATE(NEW,N_ELEMENTS(SETS))
  	      FOR NTH=0L, N_ELEMENTS(SETS)-1 DO BEGIN
            SUBS = WHERE_SETS_SUBS(SETS[NTH])
        	  SET = CONCAT(SUBS)
	          IF SETS[NTH].N GT 1 THEN BEGIN
    	      	OK = WHERE(SET.MTIME EQ MAX(SET.MTIME),COUNT)
      	    	IF COUNT GT 1 THEN SET = SET[0] ELSE SET = SET[OK]
        	  ENDIF
          	NEW[NTH] = SET
          ENDFOR
        ENDELSE
        IF FILE_TEST(DIR_INVENTORY,/DIRECTORY) EQ 0 THEN FILE_MKDIR, DIR_INVENTORY 
        STRUCT_2CSV,INVENTORY_FILE,NEW
      ENDIF ELSE PRINT, 'NO FILES ADDED TO INVENTORY, NO FILES FOUND for target:   ',FILES_OUT_TARGET,'    IN FOLDER: ',DIR_LOCAL
    ENDFOR
  ENDIF;	IF KEYWORD_SET(DO_MAKE_INVENTORY) GE 1 THEN BEGIN
;|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||


; *****************************************************************************************************
  IF KEYWORD_SET(DO_CHECK_WHAT_NEEDS_PROCESSING) GE 1 THEN BEGIN
; *****************************************************************************************************
    PRINT, 'S T E P:    DO_CHECK_WHAT_NEEDS_PROCESSING '
    PRINT, 'SEE WHICH FILES NEED PROCESSING'

    INV = READALL(INVENTORY_FILE)

    L1A = FILE_SEARCH(DIR_IN + '*')
    FN_L1A = FILE_PARSE(L1A)
    SATDATE = FN_L1A.FIRST_NAME
    DATE = SATDATE_2DATE(SATDATE)
    SENSOR = STRMID(FN_L1A.FIRST_NAME,0,1)
    SATELLITE = REPLICATE('',N_ELEMENTS(FN_L1A))

    OK = WHERE(SENSOR EQ 'S', COUNT) & IF COUNT GE 1 THEN BEGIN & SENSOR[OK] = 'SEAWIFS'     & SATELLITE[OK] = 'OV2' & ENDIF
    OK = WHERE(SENSOR EQ 'A', COUNT) & IF COUNT GE 1 THEN BEGIN & SENSOR[OK] = 'MODIS'       & SATELLITE[OK] = 'AQU' & ENDIF
    OK = WHERE(SENSOR EQ 'H', COUNT) & IF COUNT GE 1 THEN BEGIN & SENSOR[OK] = 'MODIS_HIRES' & SATELLITE[OK] = 'AQU' & ENDIF

    INV_ID = INV.DATE + INV.SENSOR + INV.SATELLITE + INV.LEVEL + INV.MAP

    OK = WHERE(SENSOR EQ 'SEAWIFS',COUNT)
    IF COUNT GE 1 THEN _INPUT_MAPS = INPUT_MAPS ELSE _INPUT_MAPS = ''
    TYPES = ['L2',_INPUT_MAPS]

    REPROCESS=''
    FOR t = 0L, N_ELEMENTS(TYPES)-1 DO BEGIN
      ATYPE = TYPES(t) & IF ATYPE EQ '' THEN CONTINUE
      PRINT, 'Checking ', ATYPE, ' files'
      IF ATYPE EQ 'L2' THEN LEVEL = ATYPE ELSE LEVEL = ''
      IF ATYPE NE 'L2' THEN MAP   = ATYPE ELSE MAP   = ''
      FILE_ID = DATE + SENSOR + SATELLITE + LEVEL + MAP
      OK = WHERE_MATCH(FILE_ID,INV_ID, VALID=VALID, COMPLEMENT=COMPLEMENT, NCOMPLEMENT=NCOMPLEMENT, COUNT)
      IF NCOMPLEMENT EQ 0 THEN CONTINUE
      REPROCESS = [REPROCESS,FN_L1A(COMPLEMENT).FULLNAME]
      ;OC_LIST, 'Need to process ' + FN_L1A(COMPLEMENT).FULLNAME
    ENDFOR
    IF N_ELEMENTS(REPROCESS) GT 1 THEN REPROCESS= REPROCESS(1:*)

    IF REPROCESS[0] NE '' THEN BEGIN
      FP = FILE_PARSE(REPROCESS)
      TEMP   = CREATE_STRUCT('FULL_NAME', '','FILE_NAME','') & TEMP = REPLICATE(TEMP,N_ELEMENTS(FP))
      TEMP.FULL_NAME = FP.FULLNAME
      TEMP.FILE_NAME = FP.NAME_EXT
      STRUCT_2CSV,REPROCESS_CSV,TEMP
      PRINT, 'NEED TO PROCESS ' + STRTRIM(STRING(N_ELEMENTS(TEMP)),2) + ' FILES'
    ENDIF
  ENDIF


; *****************************************************************************************************
  IF KEYWORD_SET(DO_PERIOD_PLOTS) GE 1 THEN BEGIN
; *****************************************************************************************************
    PRINT, 'S T E P:    DO_PERIOD_PLOTS '
    PRINT, 'DETERMINE WHERE THERE ARE GAPS IN THE FILES THAT HAVE BEEN PROCESSED'

    INV = READALL(INVENTORY_FILE)
    B = WHERE_SETS(INV.SENSOR+'_'+INV.LEVEL+INV.MAP)
    FOR NTH=0L, N_ELEMENTS(B)-1 DO BEGIN
    	LABEL = 'PERIOD_PLOT-PROCESSED_FILES-' + B[NTH].VALUE
    	SUBS = WHERE_SETS_SUBS(B[NTH])
    	_INV = INV(SUBS)
    	PERIOD_PLOT,FILES=_INV.INAME, /PS, LABEL=LABEL,DIR=DIR_PLOTS
		ENDFOR

		REPRO = READALL(REPROCESS_CSV)
		FN = FILE_PARSE(REPRO.FILE_NAME)
		SATDATE = FN.FIRST_NAME
		DATE = SATDATE_2DATE(SATDATE)
		PERIOD = 'S_' + DATE
		LABEL = 'PERIOD_PLOT-NEEDS_PROCESSING_L1A'
		PERIOD_PLOT, PERIOD=PERIOD, LABEL=LABEL, /PS, DIR=DIR_PLOTS

  ENDIF


;|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||



; ****************************************************************************************
  IF KEYWORD_SET(DO_RUN_SEADAS) GE 1 THEN BEGIN
; ****************************************************************************************
    
    FILES = FILE_SEARCH(DIR_IN + FILES_IN_TARGET) ; Find files

    IF FILES[0] EQ ''  THEN BEGIN
      PRINT, 'ERROR: NO FILES FOUND'
      GOTO, DONE
    ENDIF

    IF N_ELEMENTS(INVENTORY_FILE) EQ 1 THEN INV = READALL(INVENTORY_FILE)

    IF KEYWORD_SET(USE_NEEDS_PROCESSING_LIST) THEN BEGIN
      PROCESS_LIST = READALL(REPROCESS_CSV)
      IF N_ELEMENTS(PROCESS_LIST.FULL_NAME) GE 1 THEN _FILES = PROCESS_LIST.FULL_NAME
      FP = FILE_PARSE(FILES)
     _FILES = REPLACE(_FILES, '\','/')
     _FILES = REPLACE(_FILES, 'D:','/mnt/NTFS-D')
     _FILES = REPLACE(_FILES, 'E:','/mnt/NTFS-E')
     _FILES = REPLACE(_FILES, 'F:','/mnt/NTFS-F')
     FILES = _FILES
     OC_LIST, FILES
    ENDIF
    IF REVERSE_FILES EQ 1 THEN FILES = REVERSE(FILES)
    PRINT, NUM2STR(N_ELEMENTS(FILES)) + ' Files found'

    FOR _FILE=0,N_ELEMENTS(FILES)-1L DO BEGIN
      AFILE=FILES(_FILE)
      FN = PARSE_IT(AFILE,/ALL)
      INAME = STRMID(FN.FIRST_NAME, 0,14) & PRINT, INAME
      _NAME = STRSPLIT(FN.NAME,'._-',/EXTRACT,/PRESERVE_NULL)

;    ===> GET VALID COVERAGES'S AND VALID LEVELS
      COVERAGE	= VALID_COVERAGES(_NAME) & OK = WHERE(COVERAGE NE MISSINGS(COVERAGE),COUNT) & COVERAGE = COVERAGE(OK[0])
      IF COUNT NE 1 THEN BEGIN
        PRINT, 'ERROR: EITHER NO COVERAGE PROVIDED OR MORE THAN ONE VALID COVERAGE (HRPT) IN FILENAME'
        CONTINUE
      ENDIF
      LEVEL = VALID_LEVELS(_NAME) & OK = WHERE(LEVEL NE MISSINGS(LEVEL),COUNT) & LEVEL = LEVEL(OK[0])
      IF COUNT NE 1 THEN BEGIN
        PRINT, 'ERROR: EITHER NO LEVEL PROVIDED OR MORE THAN ONE VALID LEVEL IN FILENAME'
        CONTINUE
      ENDIF

;     ===> GET PERIOD FROM SATDATE
      IF FN.PERIOD EQ MISSINGS(FN.PERIOD) THEN PERIOD = 'S_' + SATDATE_2DATE(_NAME[0]) ELSE PERIOD = FN.PERIOD

;     ===> LOOP THROUGH EACH SUBSET REGION
      FOR _SUBSET =0L, N_ELEMENTS(SUBSET_REGIONS)-1 DO BEGIN
        SUBSET_REGION = SUBSET_REGIONS(_SUBSET)
        SUBSET_AREA = ''
        IF SUBSET_REGION EQ 'PS'      THEN BEGIN SWLAT = '34' & SWLON = '-78' & NELAT = '39' & NELON = '-74' & ENDIF
        IF SUBSET_REGION EQ 'NAR_BAY' THEN BEGIN SWLAT = '41' & SWLON = '-72' & NELAT = '42' & NELON = '-71' & ENDIF
        IF SUBSET_REGION EQ 'GL'      THEN BEGIN SWLAT = '41' & SWLON = '-93' & NELAT = '50' & NELON = '-74' & ENDIF
        IF SUBSET_REGION EQ 'GM'      THEN BEGIN SWLAT = '22' & SWLON = '-82' & NELAT = '38' & NELON = '-73' & ENDIF
        IF N_ELEMENTS(SWLAT) GE 1 AND DO_SUBSET EQ '1' THEN SUBSET_AREA = STRJOIN([SWLAT, SWLON, NELAT, NELON],',')
        IF SUBSET_AREA   EQ ''        THEN DO_SUBSET = '0'

;       *** SWITCHES TO KEEP INTERMEDIATE FILES (1 = KEEP, 0 = DELETE) - KEEP INTERMEDIATE STEPS IF THE SAME FILE WILL BE PROCESSED AGAIN ***
        IF _SUBSET EQ N_ELEMENTS(SUBSET_REGIONS)-1 THEN _1KEEP_l0           = KEEP_l0           ELSE _1KEEP_l0           = 1  ; MODIS high res AND SeaWiFS (non MLAC)
        IF _SUBSET EQ N_ELEMENTS(SUBSET_REGIONS)-1 THEN _1KEEP_l1a          = KEEP_l1a          ELSE _1KEEP_l1a          = 1
        IF _SUBSET EQ N_ELEMENTS(SUBSET_REGIONS)-1 THEN _1KEEP_l1a_new      = KEEP_l1a_new      ELSE _1KEEP_l1a_new      = 0  ; SeaWiFS (non MLAC)
        IF _SUBSET EQ N_ELEMENTS(SUBSET_REGIONS)-1 THEN _1KEEP_l1a_sub      = KEEP_l1a_sub      ELSE _1KEEP_l1a_sub      = 0  ; MODIS high res
        IF _SUBSET EQ N_ELEMENTS(SUBSET_REGIONS)-1 THEN _1KEEP_l1b          = KEEP_l1b          ELSE _1KEEP_l1b          = 0  ; MODIS
        IF _SUBSET EQ N_ELEMENTS(SUBSET_REGIONS)-1 THEN _1KEEP_l1b_hkm      = KEEP_l1b_hkm      ELSE _1KEEP_l1b_hkm      = 0  ; MODIS high res
        IF _SUBSET EQ N_ELEMENTS(SUBSET_REGIONS)-1 THEN _1KEEP_l1b_qkm      = KEEP_l1b_qkm      ELSE _1KEEP_l1b_qkm      = 0  ; MODIS high res
        IF _SUBSET EQ N_ELEMENTS(SUBSET_REGIONS)-1 THEN _1KEEP_l2           = KEEP_l2           ELSE _1KEEP_l2           = 1
        IF _SUBSET EQ N_ELEMENTS(SUBSET_REGIONS)-1 THEN _1KEEP_met1         = KEEP_met1         ELSE _1KEEP_met1         = 1
        IF _SUBSET EQ N_ELEMENTS(SUBSET_REGIONS)-1 THEN _1KEEP_met2         = KEEP_met2         ELSE _1KEEP_met2         = 1
        IF _SUBSET EQ N_ELEMENTS(SUBSET_REGIONS)-1 THEN _1KEEP_oz           = KEEP_oz           ELSE _1KEEP_oz           = 1
        IF _SUBSET EQ N_ELEMENTS(SUBSET_REGIONS)-1 THEN _1KEEP_geo          = KEEP_geo          ELSE _1KEEP_geo          = 1  ; MODIS
        IF _SUBSET EQ N_ELEMENTS(SUBSET_REGIONS)-1 THEN _1KEEP_geo_sub      = KEEP_geo_sub      ELSE _1KEEP_geo_sub      = 0  ; MODIS high res
        IF _SUBSET EQ N_ELEMENTS(SUBSET_REGIONS)-1 THEN _1KEEP_log          = KEEP_log          ELSE _1KEEP_log          = 0
        IF _SUBSET EQ N_ELEMENTS(SUBSET_REGIONS)-1 THEN _1KEEP_seadas_log   = KEEP_seadas_log   ELSE _1KEEP_seadas_log   = 0
        IF _SUBSET EQ N_ELEMENTS(SUBSET_REGIONS)-1 THEN _1KEEP_station_info = KEEP_station_info ELSE _1KEEP_station_info = 0

;       ===> LOOP THROUGH EACH RESOLUTION
        FOR _RES =0L, N_ELEMENTS(RESOLUTION)-1 DO BEGIN
          RES = RESOLUTION(_RES)

;         *** SWITCHES TO KEEP INTERMEDIATE FILES (1 = KEEP, 0 = DELETE) - KEEP INTERMEDIATE STEPS IF THE SAME FILE WILL BE PROCESSED AGAIN ***
          IF _RES EQ N_ELEMENTS(RESOLUTION)-1 THEN _2KEEP_l0           = _1KEEP_l0           ELSE _2KEEP_l0           = 1  ; MODIS high res AND SeaWiFS (non MLAC)
          IF _RES EQ N_ELEMENTS(RESOLUTION)-1 THEN _2KEEP_l1a          = _1KEEP_l1a          ELSE _2KEEP_l1a          = 1
          IF _RES EQ N_ELEMENTS(RESOLUTION)-1 THEN _2KEEP_l1a_new      = _1KEEP_l1a_new      ELSE _2KEEP_l1a_new      = 0  ; SeaWiFS (non MLAC)
          IF _RES EQ N_ELEMENTS(RESOLUTION)-1 THEN _2KEEP_l1a_sub      = _1KEEP_l1a_sub      ELSE _2KEEP_l1a_sub      = 1  ; MODIS high res
          IF _RES EQ N_ELEMENTS(RESOLUTION)-1 THEN _2KEEP_l1b          = _1KEEP_l1b          ELSE _2KEEP_l1b          = 1  ; MODIS
          IF _RES EQ N_ELEMENTS(RESOLUTION)-1 THEN _2KEEP_l1b_hkm      = _1KEEP_l1b_hkm      ELSE _2KEEP_l1b_hkm      = 1  ; MODIS high res
          IF _RES EQ N_ELEMENTS(RESOLUTION)-1 THEN _2KEEP_l1b_qkm      = _1KEEP_l1b_qkm      ELSE _2KEEP_l1b_qkm      = 1  ; MODIS high res
          IF _RES EQ N_ELEMENTS(RESOLUTION)-1 THEN _2KEEP_l2           = _1KEEP_l2           ELSE _2KEEP_l2           = 1
          IF _RES EQ N_ELEMENTS(RESOLUTION)-1 THEN _2KEEP_met1         = _1KEEP_met1         ELSE _2KEEP_met1         = 1
          IF _RES EQ N_ELEMENTS(RESOLUTION)-1 THEN _2KEEP_met2         = _1KEEP_met2         ELSE _2KEEP_met2         = 1
          IF _RES EQ N_ELEMENTS(RESOLUTION)-1 THEN _2KEEP_oz           = _1KEEP_oz           ELSE _2KEEP_oz           = 1
          IF _RES EQ N_ELEMENTS(RESOLUTION)-1 THEN _2KEEP_geo          = _1KEEP_geo          ELSE _2KEEP_geo          = 1  ; MODIS
          IF _RES EQ N_ELEMENTS(RESOLUTION)-1 THEN _2KEEP_geo_sub      = _1KEEP_geo_sub      ELSE _2KEEP_geo_sub      = 1  ; MODIS high res
          IF _RES EQ N_ELEMENTS(RESOLUTION)-1 THEN _2KEEP_log          = _1KEEP_log          ELSE _2KEEP_log          = 0
          IF _RES EQ N_ELEMENTS(RESOLUTION)-1 THEN _2KEEP_seadas_log   = _1KEEP_seadas_log   ELSE _2KEEP_seadas_log   = 0
          IF _RES EQ N_ELEMENTS(RESOLUTION)-1 THEN _2KEEP_station_info = _1KEEP_station_info ELSE _2KEEP_station_info = 0


;         ===> LOOP THROUGH EACH ATMOSPHERIC CORRECTION OPTION
          FOR _ATM = 0L, N_ELEMENTS(ATM_CORRECTION)-1 DO BEGIN
            ATM_COR = ATM_CORRECTION(_ATM)

;           *** SWITCHES TO KEEP INTERMEDIATE FILES (1 = KEEP, 0 = DELETE) - KEEP INTERMEDIATE STEPS IF THE SAME FILE WILL BE PROCESSED AGAIN ***
            IF _ATM EQ N_ELEMENTS(ATM_CORRECTION)-1 THEN _3KEEP_l0           = _2KEEP_l0           ELSE _3KEEP_l0           = 1  ; MODIS high res AND SeaWiFS (non MLAC)
            IF _ATM EQ N_ELEMENTS(ATM_CORRECTION)-1 THEN _3KEEP_l1a          = _2KEEP_l1a          ELSE _3KEEP_l1a          = 1
            IF _ATM EQ N_ELEMENTS(ATM_CORRECTION)-1 THEN _3KEEP_l1a_new      = _2KEEP_l1a_new      ELSE _3KEEP_l1a_new      = 0  ; SeaWiFS (non MLAC)
            IF _ATM EQ N_ELEMENTS(ATM_CORRECTION)-1 THEN _3KEEP_l1a_sub      = _2KEEP_l1a_sub      ELSE _3KEEP_l1a_sub      = 1  ; MODIS high res
            IF _ATM EQ N_ELEMENTS(ATM_CORRECTION)-1 THEN _3KEEP_l1b          = _2KEEP_l1b          ELSE _3KEEP_l1b          = 1  ; MODIS
            IF _ATM EQ N_ELEMENTS(ATM_CORRECTION)-1 THEN _3KEEP_l1b_hkm      = _2KEEP_l1b_hkm      ELSE _3KEEP_l1b_hkm      = 1  ; MODIS high res
            IF _ATM EQ N_ELEMENTS(ATM_CORRECTION)-1 THEN _3KEEP_l1b_qkm      = _2KEEP_l1b_qkm      ELSE _3KEEP_l1b_qkm      = 1  ; MODIS high res
            IF _ATM EQ N_ELEMENTS(ATM_CORRECTION)-1 THEN _3KEEP_l2           = _2KEEP_l2           ELSE _3KEEP_l2           = 1
            IF _ATM EQ N_ELEMENTS(ATM_CORRECTION)-1 THEN _3KEEP_met1         = _2KEEP_met1         ELSE _3KEEP_met1         = 1
            IF _ATM EQ N_ELEMENTS(ATM_CORRECTION)-1 THEN _3KEEP_met2         = _2KEEP_met2         ELSE _3KEEP_met2         = 1
            IF _ATM EQ N_ELEMENTS(ATM_CORRECTION)-1 THEN _3KEEP_oz           = _2KEEP_oz           ELSE _3KEEP_oz           = 1
            IF _ATM EQ N_ELEMENTS(ATM_CORRECTION)-1 THEN _3KEEP_geo          = _2KEEP_geo          ELSE _3KEEP_geo          = 1  ; MODIS
            IF _ATM EQ N_ELEMENTS(ATM_CORRECTION)-1 THEN _3KEEP_geo_sub      = _2KEEP_geo_sub      ELSE _3KEEP_geo_sub      = 1  ; MODIS high res
            IF _ATM EQ N_ELEMENTS(ATM_CORRECTION)-1 THEN _3KEEP_log          = _2KEEP_log          ELSE _3KEEP_log          = 0
            IF _ATM EQ N_ELEMENTS(ATM_CORRECTION)-1 THEN _3KEEP_seadas_log   = _2KEEP_seadas_log   ELSE _3KEEP_seadas_log   = 0
            IF _ATM EQ N_ELEMENTS(ATM_CORRECTION)-1 THEN _3KEEP_station_info = _2KEEP_station_info ELSE _3KEEP_station_info = 0

            IF STRMID(FN.NAME,0,1) EQ 'S' OR FN.SENSOR EQ 'SEAWIFS' THEN BEGIN
              IF ATM_COR NE 'DEFAULT' THEN PRINT, 'ERROR: Incorrect ATM_COR for SeaWiFS, ATM_COR changed to "DEFAULT"'
              SENSOR        = 'SEAWIFS'
              ;METHOD        = 'REPRO5'
              METHOD        = 'R2010'
              ;SUITE         = 'SEAWIFS_MINIMUM'
              SUITE         = 'SEAWIFS_FULL'
;              IF USER EQ 'JOR'    THEN SUITE = 'NARR'
;              IF USER EQ 'RS'     THEN SUITE = 'RS_SEA'
;              IF USER EQ 'JOR_RS' THEN SUITE = 'NARRA_RS_SEA'
              SATELLITE     = 'OV2'
              RES           = '-1'
              ATM_COR       = 'DEFAULT'
            ENDIF;	IF SENSOR EQ 'SEAWIFS' THEN BEGIN

            IF STRMID(FN.NAME,0,1) EQ 'A' OR FN.SENSOR EQ 'MODIS' OR STRMID(FN.NAME,0,1) EQ 'H' OR FN.SENSOR EQ 'HR_MODIS' THEN BEGIN
              SENSOR        = 'MODIS'
              SATELLITE     = 'AQUA'
              INPUT_MAPS    = ''
              METHOD        = 'R2010'
              ;SUITE         = 'MODIS_MINIMUM'
              SUITE         = 'MODIS_FULL'
;              IF LEVEL EQ 'L0' OR STRMID(FN.NAME,0,1) EQ 'H' OR FN.SENSOR EQ 'HR_MODIS' THEN BEGIN
;                IF USER EQ 'JOR'    AND RES EQ '250'  THEN SUITE = 'NARRA_M_2M'
;                IF USER EQ 'JOR'    AND RES EQ '500'  THEN SUITE = 'NARRA_M_5M'
;                IF USER EQ 'JOR'    AND RES EQ '1000' THEN SUITE = 'NARRA_M_1K'
;                IF USER EQ 'RS'     AND RES EQ '250'  THEN SUITE = 'RS_M_2M'
;                IF USER EQ 'RS'     AND RES EQ '500'  THEN SUITE = 'RS_M_5M'
;                IF USER EQ 'RS'     AND RES EQ '1000' THEN SUITE = 'RS_M_1K'
;                IF USER EQ 'JOR_RS' AND RES EQ '250'  THEN SUITE = 'NARRA_RS_M_2M'
;                IF USER EQ 'JOR_RS' AND RES EQ '500'  THEN SUITE = 'NARRA_RS_M_5M'
;                IF USER EQ 'JOR_RS' AND RES EQ '1000' THEN SUITE = 'NARRA_RS_M_1K'
;                SENSOR    = 'MODIS_HR'
;                IF ATM_COR EQ 'SWIR'      THEN METHOD = 'COLL5_SWIR'
;                IF ATM_COR EQ 'TBD_INDEX' THEN METHOD = 'COLL5_TBD'
;              ENDIF ELSE BEGIN
;                ATM_COR     = 'DEFAULT'
;                IF USER EQ 'JOR'    THEN SUITE = 'NARR_M_A'
;                IF USER EQ 'RS'     THEN SUITE = 'RS_M_A'
;                IF USER EQ 'JOR_RS' THEN SUITE = 'NARRA_RS_M_A'
;                RES         = '-1'
;              ENDELSE
            ENDIF
  
            IF RES EQ '250'  THEN COVERAGE = 'LAC_250'
            IF RES EQ '500'  THEN COVERAGE = 'LAC_500'
            IF RES EQ '1000' THEN COVERAGE = 'LAC_1KM'

            FILE_LABEL = PERIOD + '-' + SENSOR + '-' + SATELLITE + '-' + COVERAGE + '-' + METHOD
            MAPS = 'NONE'
            _OVERWRITE = OVERWRITE

            _DIR_OUT = DIR_OUT + SENSOR + SLASH + num2str(year) + SLASH
            IF FILE_TEST(_DIR_OUT,/DIRECTORY) EQ 0 THEN FILE_MKDIR, _DIR_OUT

;           ***** DETERMINE L2_PRODUCTS *****
            SUITE_PRODS = VALID_SUITES(SUITE  ,/PRODUCTS)
            SUITE_PRODUCTS = SUITE_PRODS.SUITE_PRODS
            S_MISSINGS = SUITE_PRODS.SEADAS_MISSINGS
            PRODS = STRJOIN(SUITE_PRODUCTS,',')
            SEADAS_MISSINGS = STRJOIN(S_MISSINGS,',')

;           ***** CHECK INVENTORY FOR L2 AND MAPPED FILES *****
            L2_FILE   = FILE_LABEL + '-L2.hdf'
            L2_GZ     = _DIR_OUT + FILE_LABEL + '-L2.hdf.gz'
            L2_HDF    = _DIR_OUT + FILE_LABEL + '-L2.hdf'
            L3_FILES  = FILE_LABEL + '-' + INPUT_MAPS + '.hdf'
            L3_GZ     = _DIR_OUT + FILE_LABEL + '-' + INPUT_MAPS + '.hdf.gz'
            L3_HDF    = _DIR_OUT + FILE_LABEL + '-' + INPUT_MAPS + '.hdf'

            IF NOT KEYWORD_SET(_OVERWRITE) THEN BEGIN
;             ***** GATHER LIST OF MAPS TO BE PROCESSED *****
              FOR NTH = 0L, N_ELEMENTS(INPUT_MAPS)-1 DO BEGIN
                IF INPUT_MAPS[NTH] EQ '' THEN CONTINUE
                EXIST_L3_GZ = FILE_TEST(L3_GZ[NTH])                    ; Does the zipped L3 file exist in the DIR_OUT?
                EXIST_L3    = FILE_TEST(L3_HDF[NTH])                   ; Does the L3 file exist in the DIR_OUT?
                IF EXIST_L3 EQ 0 AND EXIST_L3_GZ EQ 0 THEN BEGIN       ; If the L3 file does not exist, is it
                  OK = WHERE(INV.INAME EQ L3_FILES[NTH],COUNT_L3)      ;   present in the inventory?
                  IF COUNT_L3 EQ 0 THEN MAPS = [MAPS,INPUT_MAPS[NTH]]  ; Compile a list of MAPS to be processed
                ENDIF
              ENDFOR
              OK_MAPS = WHERE(MAPS NE 'NONE',COUNT_MAPS)

;             ***** SEE IF L2 FILE EXISTS *****
              EXIST_L2_GZ = FILE_TEST(L2_GZ)                           ; Does the zipeed L2 file exist in the DIR_OUT?
              EXIST_L2    = FILE_TEST(L2_HDF)                          ; Does the L2 file exist in the DIR_OUT?
              ; FIXME: Fail, if inventory was not read, inv is <null>
              OK = WHERE(INV.INAME EQ L2_FILE,COUNT_L2)                ; Does the L2 file exist in the INVENTORY?
              IF EXIST_L2 EQ 0 AND EXIST_L2_GZ EQ 0 AND COUNT_L2 EQ 0 THEN BEGIN            ; L2 file not found
                IF KEEP_L2 EQ 1 AND COUNT_MAPS GT 0 THEN BEGIN         ; If Keep_l2 set and there are maps to be processed
                  MAPS = INPUT_MAPS                                    ;   then reprocess all MAPS
                  _OVERWRITE = 1                                       ;   and overwrite
                ENDIF
                IF KEEP_L2 EQ 0 AND COUNT_MAPS EQ 0 THEN CONTINUE      ; If all maps are present then skip file because Keep_l2 is not set
              ENDIF ELSE BEGIN
                IF COUNT_MAPS EQ 0 THEN CONTINUE                       ; If L2 and all MAPS exist then skip file
                MAPS = MAPS(OK_MAPS)                                   ; Only process the missing MAPS
                IF EXIST_L2_GZ EQ 1 THEN AFILE = L2_GZ
                IF EXIST_L2 EQ 1 THEN AFILE = L2_HDF
                IF EXIST_L2_GZ EQ 0 AND EXIST_L2 EQ 0 THEN BEGIN $    ; If L2 is present in DIR_OUT then use L2 as AFILE
;                 ***** Look for L2 file in DIR_L2_IN *****
                  IF FILE_TEST(DIR_L2_IN + FILE_LABEL + '-L2.hdf')    EQ 1 THEN AFILE = DIR_L2_IN + FILE_LABEL + '.L2'
                  IF FILE_TEST(DIR_L2_IN + FILE_LABEL + '-L2.hdf.gz') EQ 1 THEN AFILE = DIR_L2_IN + FILE_LABEL + '.L2.gz'
                ENDIF
              ENDELSE
            ENDIF ELSE MAPS = INPUT_MAPS ;  IF NOT KEYWORD_SET(_OVERWRITE) THEN BEGIN

            IF MAPS[0] EQ 'NONE' THEN MAPS = ''

            IF STRPOS(AFILE,'L2') GT 0 THEN LEVEL = 'L2'              ; Change LEVEL if AFILE is now a L2 file
            IF N_ELEMENTS(MAPS) EQ 0 THEN CONTINUE
            _OVERWRITE = STRING(OVERWRITE)
            MAPS = STRJOIN(MAPS,',')

            KEEP_FILES = STRJOIN(STRTRIM([_3KEEP_l0, _3KEEP_l1a, _3KEEP_l1a_new, _3KEEP_l1a_sub, $
                                           _3KEEP_l1b, _3KEEP_l1b_hkm, _3KEEP_l1b_qkm, _3KEEP_L2, $
                                          _3KEEP_geo, _3KEEP_geo_sub, _3KEEP_met1, _3KEEP_met2, _3KEEP_oz, $
                                          _3KEEP_LOG, _3KEEP_seadas_log, _3KEEP_station_info],2),',')

            TOTAL_LOOPS = N_ELEMENTS(FILES) * N_ELEMENTS(ATM_CORRECTION) * N_ELEMENTS(SUBSET_REGIONS) * N_ELEMENTS(RESOLUTION)
            CURRENT_LOOP = _FILE + _ATM + _SUBSET + _RES
            PRINT, ''
            PRINT, 'Working on ' + AFILE + ' (' + STRTRIM(STRING(CURRENT_LOOP),2) + ' of ' + STRTRIM(STRING(TOTAL_LOOPS),2) + ' total files to be processed) '
            PRINT, ''

            cmd = 'seadas_l1_l2, files=' +"'"+ afile +"'"                        ; List of input files
            cmd = cmd + ', dir_out='         + "'" + _dir_out        + "'"             ; Output working directory
            ;cmd = cmd + ', dir_metoz='       + "'" + dir_metoz       + "'"             ; METOZ directory
            cmd = cmd + ', file_label='      + "'" + file_label      + "'"             ; Output file names
            cmd = cmd + ', sensor='          + "'" + sensor          + "'"             ; SeaWiFS or MODIS
            cmd = cmd + ', method='          + "'" + method          + "'"             ; Valid method (REPRO5)
            cmd = cmd + ', coverage='        + "'" + coverage        + "'"             ; Valid coverage (MLAC, LAC) or HRPT site
            cmd = cmd + ', prods='           + "'" + prods           + "'"             ; Output L2 products
            cmd = cmd + ', seadas_missings=' + "'" + seadas_missings + "'"             ; Missing codes for BL2MAP
;            cmd = cmd + ', maps='            + "'" + maps            + "'"             ; Output MAPS
;            cmd = cmd + ', resolution='      + "'" + res             + "'"             ; For High Res MODIS processing
;           cmd = cmd + ', gain='            + "'" + gain            + "'"             ; Optional GAINS input
;           cmd = cmd + ', brdf='            + "'" + brdf            + "'"             ; BRDF_OPT (0,1,3,7)
            cmd = cmd + ', level='           + "'" + level           + "'"             ; Input file LEVEL (L1A, L2, etc.)
;            cmd = cmd + ', do_subset='       + "'" + do_subset       + "'"             ; For subsetting High Res MODIS
;            cmd = cmd + ', subset_area='     + "'" + subset_area     + "'"             ; Subset area for High Res MODIS
            cmd = cmd + ', overwrite='       + "'" + _overwrite      + "'"             ; Overwrite previous files
            cmd = cmd + ', keep_files='      + "'" + keep_files      + "'"             ; List of files to delete
;            cmd = cmd + ', atm_cor='         + "'" + atm_cor         + "'"             ; Do SWIR correction for HIGH RES MODIS processing

            CMD_FILE='/usr/local/idl/seadas_main_batch'
            CMD_FILE='/tmp/seadas_main_batch'
            LOG_FILE=_DIR_OUT+'seadas.log'
            OPENW,LUN,CMD_FILE,/GET_LUN
            PRINTF,LUN,CMD
            PRINTF,LUN,'exit'
            CLOSE, LUN, /ALL
            FREE_LUN,LUN, /FORCE

            ; spawn or run from command line only if program has been debugged properly first. 
            ; SPAWN, 'seadas -b ' + CMD_FILE +' >>'+LOG_FILE
            ; set a breakpoint in sd_seadas_l1_l2 (or whichever cmd is) to see what's happening here.
            result = execute(cmd)
          ENDFOR; FOR _ATM
        ENDFOR; FOR _RES
      ENDFOR; FOR _SUBSET
    ENDFOR; FOR _FILE
  ENDIF; IF KEYWORD_SET(DO_RUN_SEADAS) GE 1 THEN BEGIN

;|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||


  DONE:
  PRINT,'FINISHED PROCESSING AT ', DATE_NOW()
  PRINT,'DONE WITH  seadas_main.pro'
END
