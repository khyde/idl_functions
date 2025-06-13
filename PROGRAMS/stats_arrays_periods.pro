; $ID:	STATS_ARRAYS_PERIODS.PRO,	2020-08-04-15,	USER-KJWH	$
;+
PRO  STATS_ARRAYS_PERIODS, FILES, PERIOD_CODE_OUT=PERIOD_CODE_OUT, $
  DATERANGE=DATERANGE, STAT_PROD=STAT_PROD, DIR_OUT=DIR_OUT, FILE_LABEL=FILE_LABEL, $
  DO_STATS=DO_STATS, KEY_STAT=KEY_STAT,  TRANSFORM_KEY_STAT=TRANSFORM_KEY_STAT, STAT_TRANSFORM=STAT_TRANSFORM,$
  REVERSE_FILES=REVERSE_FILES, ERROR_STOP=ERROR_STOP, ADD_GLOBAL_PROD=ADD_GLOBAL_PROD, OVERWRITE=OVERWRITE, VERBOSE=VERBOSE, INIT=INIT,$
  OUTSTRUCT=OUTSTRUCT,SKIP_SAVE=SKIP_SAVE,BAD_FILES=BAD_FILES, LOGLUN=LOGLUN



  ; NAME:	STATS_ARRAYS_PERIODS
  ;
  ; PURPOSE: THIS PROGRAM USES STATS_ARRAYS TO COMPUTE STATISTICS FOR VARIOUS PERIODS: [M,MONTH,Y,YEAR,ANNUAL]
  ;
  ; CATEGORY:
  ;		STATISTICS
  ;
  ;
  ; CALLING SEQUENCE:STATS_ARRAYS_PERIODS( # MUST USE MOST OF THE KEYWORDS # )
  ;
  ; REQUIRED INPUTS:
  ;		FILES.............. Input data files (can be daily or stat files)
  ;   PERIOD_CODES_OUT... The period codes for the output statistics
  ;
  ;	OPTINOAL INPUTS
  ;   DATERANGE.......... The daterange to subset the files
  ;   STAT_PROD.......... Standard product name for the input files [E.G. 'CHLOR_A' OR 'SST' OR 'PAR']
  ;   DIR_OUT............ Directory for statistical output files
  ;   FILE_LABEL......... A string of key-identifying attributes for the output file name [e.g. map-method-prod]
  ;   DO_STATS........... A List of stat types to calculate [default = mean]  DO_STATS = ['NUM','MIN','MAX','SPAN','NEG','WTS','SUM','SSQ','MEAN','STD','CV']
  ;   KEY_STAT........... The stat type used to calculate the stat when the input files are STAT files [default = mean]
  ;   TRANSFORM_KEY_STAT. The stat type used to process for the next period [default = gmean] for the log transformed stats
  ;   STAT_TRANSFORM..... To determine if the data should be transformed prior to calculating stats [default derived from PRODS_READ]
  ;
  ; KEYWORD PARAMETERS:
  ;   REVERSE_FILES...... Keyword to process the files in reverse order
  ;	  ERROR_STOP......... Keyword to stop the processing if a "bad" file is encountered
  ;	  ADD_GLOBAL_PROD.... Add the global product information to the output structure
  ;   OVERWRITE.......... Overwrite output sav files
  ;   VERBOSE............ Print program progress
  ;   INIT............... Forces the program to check all of the stat files for the correct input files
  ;
  ; OUTPUTS:
  ;   A SAV FILE WITH THE STATISTICS IN A NESTED STRUCTURE
  ;
  ; OPTIONAL OUTPUTS
  ;   BAD_FILES.......... An array of "BAD" files to return to the calling program
  ;		LOGLUN............. If provided, the LUN for the log file
  ;
  ; EXAMPLES:
  ;   STATS_ARRAYS_PERIODS, FILES, PERIOD_CODES_OUT='M',DO_STATS=['NUM','MIN','MAX','SUM','MEAN','SPAN']
  ;
  ; RESTRICTIONS:
  ;   For processing fronts you must use STATS_ARRAYS_FRONTS
  ;
  ; COPYRIGHT:
  ; Copyright (C) 2012, Department of Commerce, National Oceanic and Atmospheric Administration, National Marine Fisheries Service,
  ;   Northeast Fisheries Science Center, Narragansett Laboratory.
  ;   This software may be used, copied, or redistributed as long as it is not sold and this copyright notice is reproduced on each copy made.
  ;   This routine is provided AS IS without any express or implied warranties whatsoever.
  ;
  ; AUTHOR:
  ;   This program was written on May 07, 2012 by John E. O'Reilly, Northeast Fisheries Science Center | NOAA Fisheries | U.S. Department of Commerce, 28 Tarzwell Dr, Narragansett, RI 02882
  ;   Inquiries can be directed to kimberly.hyde@noaa.gov
  ;
  ;
  ;
  ; MODIFICATION HISTORY:
  ;   MAY 07, 2012 - JEOR: Wrote the initial code
  ;	  OCT 23, 2012 - JEOR: PRODS = VALIDS('PRODS',NAMES) ;===> NARROW DOWN FILES PROD MAY BE 2 WORDS  [COMPOUND PROD SUCH AS 'CHLOR_A-GRAD_X']
  ;                        IF N_ELEMENTS(STAT_TRANSFORM) NE 1 THEN _STAT_TRANSFORM = '' ELSE _STAT_TRANSFORM = STAT_TRANSFORM
  ;   OCT 25, 2012 - JEOR: STAT_TYPES = ['NUM','MIN','MAX','NEG','WTS','SUM','SSQ','MEAN','STD','CV']
  ;   NOV 01, 2012 - JEOR: FOR _STAT = 0,N_ELEMENTS(DO_STATS)-1 DO BEGIN
  ;   AUG 14, 2013 - JEOR: Added keyword KEY_STAT: IF N_ELEMENTS(KEY_STAT) NE 1 THEN KEY_STAT = 'MEAN'
  ;                        Added '_' TO TARGET;
  ;                        GOTO,DONE_PERIOD IF ALL  OUTPUT STATS EXISTS FOR A PERIOD
  ;   SEP 01, 2013 - JEOR: Added logic to skip over output stat files if they already exist
  ;                        IF PERIOD_IN EQ 'D' THEN _KEY_STAT = '' ELSE _KEY_STAT = KEY_STAT
  ;                        TARGET_IN  = PERIOD_IN+'_*'+FILE_LABEL +'*' + _KEY_STAT+ '.SAV'
  ;                        TARGET_OUT = PERIOD_OUT+'_*'+FILE_LABEL +'*' + _KEY_STAT+ '.SAV'
  ;   SEP 02, 2013 - JEOR: Documented keywords
  ;                        STAT_FILES =  DIR_OUT + TAGNAME + '-' + FILE_LABEL+ '-'+DO_STATS + '.SAV'
  ;                        Added keyword PACK
  ;   NOV 07, 2013 - JEOR:  Moved PERIOD LOOPS to calling program
  ;                        Added DATE_RANGE
  ;   NOV 08, 2013 - JEOR: Added FILE_CHECK logic
  ;   NOV 10, 2013 - JEOR: Now using STATS_READ
  ;   NOV 12, 2013 - JEOR: Fixed updating logic based on MTIMES
  ;   FEB 02, 2014 - JEOR: Added DATE_RANGE and DIR_IN
  ;   FEB 13, 2014 - JEOR: Removed keyword PACK
  ;   MAR 02, 2014 - JEOR: FULLNAME = REPLACE( FULLNAME,'--','-')
  ;   SEP 13, 2014 - JEOR: STATS_READ replaced with STRUCT_READ and changed .SAVE with .SAV
  ;   FEB 11, 2015 - KJWH: Added VERBOSE and DATERANGE keywords
  ;                        Removed keyword PROD - Should be derived from the files
  ;                        Removed error associated with DIR_OUT - This can be determined if not provided
  ;   FEB 19, 2015 - KJWH: Added PRODS_READ Tto determine the STAT_TRANSFORM keyword based on the prod
  ;                        Changed FILE_LABEL to _FILE_LABEL
  ;   OCT 07, 2015 - KJWH: Added the capability to use .nc nfilesS
  ;                        Added NC_PROD keyword (NECESSARY FOR THE .nc FILES)
  ;                        Added STAT_PROD keyword (NECESSARY FOR THE .nc FILES)
  ;   OCT 16, 2015 - KJWH: Removed NC_PROD - NOW CAN GET THE NC PROD NAME FROM SENSOR_INFO
  ;                        Added BLOCK TO READ THE L3B NC FILES
  ;   OCT 19, 2015 - KJWH: Fixed bug with STAT_NAME
  ;                        Now using STRUCT_WRITE to write out the files
  ;   OCT 22, 2015 - KJWH: Updated with new output from SENSOR_INFO()
  ;                        Changed VALID_xxx functions to VALIDS
  ;   NOV 09, 2015 - KJWH: Added IF HAS(FILE,'-STATS.SAV') EQ 0 THEN _TAG = [] ELSE _TAG = _KEY_STAT  ; Look for a STATS_ARRAYS_PERIODS generated STATS file, else use null for TAG
  ;   JAN 11, 2015 - KJWH: Updated bug associated with retreiving the LOG information from PRODS_READ.  Now look for LOG info in the structure: IF KEY(PROD_INFO.LOG) THEN _STAT_TRANSFORM = 'ALOG'
  ;   JAN 26, 2016 - KJWH: Added IF NONE(DATERANGE) THEN DATERANGE = ['19810101','21001231']
  ;                        Added MESSAGE if unmapped L2.nc files are used an inputs
  ;   AUG 22, 2016 - KJWH: Changed STRMID(EXT,0,3) to HAS(EXT,'SAV')
  ;                        Updated documentation
  ;   AUG 24, 2016 - KJWH: Corrected HAS() error - IF HAS(STRUCT,'INFILE') THEN IFILE = [IFILE, STRUCT.INFILE]
  ;   AUG 29, 2016 - KJWH: Added a search for the GLOBAL_PROD to add to the output structure
  ;   AUG 30, 2016 - KJWH: Use /HDF5 when looking for the prod names in READ_NC
  ;   SEP 14, 2016 - KJWH: Added a step to check that the INPUT files match those in the STAT file before skipping
  ;                        Now accumulating the list of original input files (i.e. the .nc files) and adding them to the structre as NCFILES
  ;   SEP 23, 2016 - KJWH: Added L2FILES as an option to accumulate the list of L2 files used to generate the L3B1 and L3B2 files
  ;   SEP 26, 2016 - KJWH: Added a IDLTYPE() check for when reading the STAT_FILE to check the list of L2FILES.  If the file can't be read, delete and remake.
  ;   OCT 06, 2016 - KJWH: Added keyword FORCE_STATS
  ;                        Now doing a quick check of the input and output files to see if the stat files are present and more recent than the latest input file
  ;   OCT 17, 2016 - KJWH: Added steps to read BIN information from a SAV file and to subset the output structure based on the pixels with valid data (i.e. NUM > 0)
  ;                        Added MAPS check and LEVEL info when reading SAV files
  ;   OCT 18, 2016 - KJWH: BUG fix - changed STRUCT.N_BINS to STRUCT.TOTAL_BINS when extracting the total bin information from the .SAV file
  ;   DEC 09, 2016 - KJWH: Changed DAT = FLTARR(STRUCT.TOTAL_BINS) to DAT = FLTARR(N_BINS) and DATA = FLTARR(1,STRUCT.TOTAL_BINS) to DATA=FLTARR(1,N_BINS) in order to avoid errors if TOTAL_BINS is not in the .SAV structure (i.e. daily L3B .SAV files)
  ;   FEB 22, 2016 - KJWH: Added STAT_PROD option for .SAV files to work with COMPOUND/NESTED save files with multiple products (i.e. PIGMENTS and PHYTO)
  ;                        Now when reading the .SAV files, the program will look for COMPOUND/NESTED structures and extract the appropriate product
  ;   FEB 23, 2017 - KJWH: Added DATA = MAPS_L3B_2ARR(DATA,MAPP=MP,BINS=BINS) to convert the subset L3B array into a full array
  ;                        Added steps to get the MAP needed for MAPS_L3B_2ARR
  ;   APR 18, 2017 - KJWH: Changed KEY(PROD_INFO.LOG) to KEY(FIX(PROD_INFO.LOG)) - the former was always TRUE because PROD_INFO.LOG was a string and not a number
  ;   DEC 15, 2017 - KJWH: Added REVERSE_FILES to reverse the order of the period sets output
  ;   DEC 19, 2017 - KJWH: Changed FORCE_STATS keyword to INIT to be consistent with other programs
  ;                        No longer doing a bulk FILE_TEST of all of the output files prior to the period sets loop
  ;                        Now checking the MTIMES within the loop with FILE_MAKE and skipping out if the file exists and INIT not set
  ;                        INIT will trigger the program to read the STAT_FILE if it exists and verify the INFILES within the STAT_FILE
  ;   FEB 16, 2018 - KJWH: Added IF FILE_MAKE(INFILES,STAT_FILE,OVERWRITE=_OVERWRITE) EQ 1 AND EXISTS(STAT_FILE) THEN FILE_DELETE, STAT_FILE,/VERBOSE to delete the STAT_FILE if newer files exist
  ;   MAY 15, 2018 - KJWH: Updated formatting.
  ;   MAY 21, 2018 - KJWH: Removed NCFILES and L2FILES from the output structure (not needed)
  ;                        Added a STOP in the L3B BIN check step - this step may be obsolete and can eventually be deleted
  ;   SEP 17, 2018 - KJWH: Changed UNITS(APROD) to UNITS(APROD,/SI) to return SI units instead of the plotting "units"
  ;   NOV 14, 2018 - KJWH: Changed the PRINT commands to PLUN so that they can be captured in a log file if provided
  ;                        Added LOGLUN keyword
  ;   NOV 19, 2018 - KJWH: Updated the PLUN/PFILE print commands
  ;   AUG 09, 2019 - KJWH: Changed DATATYPE() to IDLTYPE() & Changed the parameter DATA to DAT
  ;   SEP 05, 2019 - KJWH: Added options to calculate the log based stats using the GMEAN as input while also calculating the AMEAN using MEAN iputs
  ;                        Added TRANSFORM_KEY_STAT keyword (default is GMEAN)
  ;                        Created a DATY parameter to hold the GMEAN data
  ;                        Added STATS_ARRAYS_XYZ when there are two data inputs (DATX and DATY) - Note STATS_ARRAYS is faster and is used when there is not DATY data
  ;                        Replacing the log-based stats in the original structure with those calculated with the GMEAN/DATY data
  ;                        Added a note in the structure to indicate which data were used as input for the log-based stats
  ;   SEP 10, 2019 - KJWH: Added BAD_FILES to accumulate a list of files that have errors when being read and the keyword ERROR_STOP (default = 1) to continue the stats processing, skipping the "BAD" file
  ;   AUG 04, 2020 - KJWH: Added COMPILE_OPT IDL2
  ;                        Changed subscript () to []
  ;                        Added the ability to work with products that are not the primary product in a file (e.g. ZEU in PPD files)
  ;                        Updated documentation
  ;                        Removed MISSING keyword because it is no longer used
  ;-
  ;#################################################################################

  ROUTINE_NAME  = 'STATS_ARRAYS_PERIODS'
  COMPILE_OPT IDL2
  SL = PATH_SEP()

  IF KEY(OVERWRITE)   THEN _OVERWRITE = 1 ELSE _OVERWRITE = 0
  IF NONE(FILES)      THEN  MESSAGE,'INPUT FILES MUST BE PROVIDED'
  IF NONE(DATERANGE)  THEN DATERANGE = ['19810101','21001231']
  IF NONE(LOGLUN)     THEN LOG_LUN = [] ELSE LOG_LUN = LOGLUN
  IF NONE(ERROR_STOP) THEN ERROR_STOP = 1 ; The default is to stop the program if there is an error reading the file.

  FN = PARSE_IT(FILES)
  DIR_IN = FIRST(FN.DIR)
  IF SAME(FN.EXT) EQ 0 THEN MESSAGE, 'ALL FILES MUST HAVE THE SAME EXTENSION'

  IF HAS(FN[0].EXT,'SAV') THEN BEGIN
    NAMES = FN.NAME
    IF NONE(DIR_OUT) THEN DIR_OUT = REPLACE(FN[0].DIR,'SAVE','STATS')  ; DEFAULT LOCATION FOR OUTPUT STATS
    IF SAME(FN.PERIOD_CODE) EQ 0 THEN MESSAGE,'INPUT FILES ARE NOT FROM THE SAME PERIOD'

    MAPS = VALIDS('MAPS',NAMES)
    IF SAME(MAPS) THEN MP = MAPS[0] ELSE MESSAGE, 'ALL FILES MUST BE HAVE THE SAME MAP'
    IF HAS(MP,'L3B') THEN LEVEL = 'L3' ELSE LEVEL = '' ; DETERMINE IF THE FILES ARE L3B TO LOOK FOR BINS
    MS = MAPS_SIZE(MP, PX=MPX, PY=MPY)
    IF LEVEL EQ 'L3' THEN N_BINS = MPY

    IF NONE(STAT_PROD) THEN APROD = VALIDS('PRODS',NAMES[0]) ELSE APROD = VALIDS('PRODS',STAT_PROD)
    IF SAME(VALIDS('PRODS',NAMES)+VALIDS('ALGS',NAMES)) EQ 0 THEN  MESSAGE, 'PROD-ALG NAME NOT CONSISTENT IN ALL FILES'
    IF NONE(FILE_LABEL) THEN _FILE_LABEL=FILE_LABEL_MAKE(FILES[0]) ELSE _FILE_LABEL=FILE_LABEL
    IF ~NONE(STAT_PROD) THEN _FILE_LABEL=REPLACE(_FILE_LABEL,(PARSE_IT(FILES[0],/ALL)).PROD_ALG,STAT_PROD)
  ENDIF ELSE BEGIN
    IF NONE(STAT_PROD) THEN APROD = VALIDS('PRODS',FN[0].NAME) ELSE APROD = VALIDS('PRODS',STAT_PROD)
    IF APROD EQ '' THEN MESSAGE, 'MUST PROVIDE VALID STAT PRODUCT NAME'
    SI = SENSOR_INFO(FILES,PROD=STAT_PROD)
    IF SAME(SI.MAP) THEN MP = SI[0].MAP ELSE MESSAGE, 'ALL FILES MUST BE THE SAME MAP TO USE THE .nc FILES'
    IF SI[0].LEVEL EQ 'L3' THEN BEGIN
      IF SAME(SI.N_BINS) NE 1 THEN MESSAGE, 'THE BIN NUMBERS FOR ALL FILES MUST BE THE SAME'
      N_BINS = SI[0].N_BINS
      LEVEL = 'L3'
    ENDIF ELSE LEVEL = ''
    NC_PROD = SI[0].NC_PROD
    TEST_PROD = READ_NC(FILES[0],/NAMES,/HDF5)
    IF HAS(TEST_PROD,NC_PROD) EQ 0 THEN BEGIN
      PLUN, LOG_LUN, 'The first file does not contain the requested product.  Exiting ' + ROUTINE_NAME
      GOTO, DONE
    ENDIF
    IF NONE(FILE_LABEL) THEN _FILE_LABEL = SI[0].FILELABEL + '-' + STAT_PROD ELSE _FILE_LABEL=FILE_LABEL
    IF NONE(DIR_OUT) THEN DIR_OUT = REPLACE(FN[0].DIR,'L3','STATS')+STAT_PROD+SL
  ENDELSE
  IF ~KEYWORD_SET(SKIP_SAVE) THEN DIR_TEST, DIR_OUT

  PROD_INFO = PRODS_READ(APROD)
  IF KEY(FIX(PROD_INFO.LOG)) THEN _STAT_TRANSFORM = 'ALOG'
  IF KEY(STAT_TRANSFORM) THEN _STAT_TRANSFORM=STAT_TRANSFORM
  IF NONE(DO_STATS)  THEN DO_STATS  = ['MEAN','NUM']
  IF NONE(KEY_STAT)  THEN KEY_STAT_X = 'MEAN' ELSE KEY_STAT_X = KEY_STAT
  IF NONE(TRANSFORM_KEY_STAT) THEN TRANSFORM_KEY_STAT = []
  IF NONE(TRANSFORM_KEY_STAT) AND HAS(_STAT_TRANSFORM,'LOG') THEN KEY_STAT_Y = 'GMEAN' ELSE KEY_STAT_Y = TRANSFORM_KEY_STAT
  IF APROD EQ 'PPD'  THEN DO_STATS  = [DO_STATS,'MEAN','NUM','SUM']
  DO_STATS = DO_STATS[UNIQ(DO_STATS,SORT(DO_STATS))] ; REMOVE REDUNDANT STATS

  IF KEY(VERBOSE) THEN PLUN, LOG_LUN, NUM2STR(N_ELEMENTS(FILES)) + '  STATS SAVE FILES IN: '+ FIRST(FN.DIR)
  JULIAN = PERIOD_2JD(FN.PERIOD)
  SETS=PERIOD_SETS(JULIAN,DATA=FILES,PERIOD_CODE=PERIOD_CODE_OUT,JD_START=DATE_2JD(DATERANGE[0]),JD_END=DATE_2JD(DATERANGE[1]),/NESTED) ; GET THE SETS FOR THIS PERIOD_CODE_OUT
  IF SETS EQ [] THEN BEGIN
    PLUN, LOG_LUN,' FOUND NO FILES TO PROCESS FOR PERIOD: ' + PERIOD_CODE_OUT
    GOTO,DONE
  ENDIF

  TAGNAMES =  TAG_NAMES(SETS)
  IF KEY(REVERSE_FILES) THEN TAGNAMES = REVERSE(TAGNAMES) ; Process the stat files in reverse order
  PLUN, LOG_LUN,TAGNAMES,0

  BAD_FILES = [] ; Set up a NULL array for any "BAD" files

  ;FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
  FOR TAG=0, N_ELEMENTS(TAGNAMES)-1 DO BEGIN
    TAGNAME=TAGNAMES[TAG] & IF KEY(VERBOSE) THEN PLUN, LOG_LUN, 'Checking for: ' + TAGNAME + ' stat file.', 0
    TPOS = WHERE(TAG_NAMES(SETS) EQ TAGNAME,/NULL,COUNT_TAG) & IF COUNT_TAG NE 1 THEN STOP

    STAT_FILE = DIR_OUT + TAGNAME + '-' + _FILE_LABEL+ '-'+'STATS' + '.SAV'
    STAT_FILE = REPLACE(STAT_FILE,'--','-') ;====> REPLACE '--'
    INFILES   = STRING(SETS.(TPOS))
    NFILES    = N_ELEMENTS(INFILES)
    FP = PARSE_IT(INFILES,/ALL)
    IF ~SAME(FP.METHOD+'-'+FP.MAP) THEN MESSAGE, 'ERROR: Check input files.'

    IF NFILES EQ 0 THEN CONTINUE
    IF FILE_MAKE(INFILES,STAT_FILE,OVERWRITE=_OVERWRITE) EQ 0 AND ~KEY(INIT) THEN CONTINUE         ; Skip if STAT_FILE is newer than the input files and INIT keyword is not set
    IF FILE_MAKE(INFILES,STAT_FILE,OVERWRITE=_OVERWRITE) EQ 1 AND EXISTS(STAT_FILE) THEN FILE_DELETE, STAT_FILE,/VERBOSE ; Delete STAT_FILE if newer files exist

    IF EXISTS(STAT_FILE) THEN BEGIN ; ===> If the STAT file exists, make sure the INPUT files match
      TMP = STRUCT_READ(STAT_FILE,STRUCT=TSTR)
      IF IDLTYPE(TMP) NE 'STRING' THEN BEGIN
        IF HAS(TSTR,'INFILES') THEN OK = WHERE_MATCH(INFILES,TSTR.INFILES,COUNT) $
        ELSE OK = WHERE_MATCH(INFILES,TSTR.NCFILES,COUNT)
      ENDIF ELSE COUNT = 0
      IF COUNT NE NFILES THEN FILE_DELETE, STAT_FILE, /VERBOSE
      GONE, TSTR & GONE, TMP
    ENDIF
    IF FILE_MAKE(INFILES,STAT_FILE,OVERWRITE=_OVERWRITE) EQ 0 THEN CONTINUE
    PLUN, LOG_LUN, '     Calculating stats for product:  ' +  APROD  + '  for period: ' + TAGNAME, 1

    FOR NTH=0,N_ELEMENTS(INFILES) -1L DO BEGIN
      ; ===>SET KEYWORDS FOR STATS_ARRAYS
      START=0
      CALC=0
      IF NTH EQ 0         THEN START=1
      IF NTH EQ NFILES-1L THEN CALC=1
      POF,NTH,N_ELEMENTS(INFILES),OUTTXT=OUTTXT,/QUIET
      IF KEY(VERBOSE) THEN PLUN, LOG_LUN, OUTTXT

      FILE=INFILES[NTH]
      PFILE, FILE, LOGLUN=LOG_LUN, /R; , 'Reading: ' + FILE, 0
      ;    IF HAS(FILE,'-STATS.SAV') EQ 0 THEN _TAG = [] ELSE _TAG = _KEY_STAT  ; Look for a STATS_ARRAYS_PERIODS generated STATS file, else use null for TAG
      IF HAS(FN[0].EXT,'SAV') THEN BEGIN
        DATX = STRUCT_READ(FILE, STRUCT=STRUCT, BINS=BINS)
        IF IDLTYPE(DATX) EQ 'STRING' THEN BEGIN
          BAD_FILES=[BAD_FILES,FILE]
          IF KEY(ERROR_STOP) THEN INFORMATIONAL = 0 ELSE INFORMATIONAL = 1  ; ERROR_STOP will stop the processing, otherwise the file is skipped and the stats processing continues
          MESSAGE, 'ERROR READING: ' + FILE, INFORMATIONAL=INFORMATIONAL    ; Print error message
          GOTO, SKIP_STATFILE                                               ; Skip this statfile
          CONTINUE
        ENDIF
        DATY = []
        IF IDLTYPE(DATX) EQ 'STRUCT' THEN BEGIN
          IF HAS(DATX,APROD) EQ 0 THEN MESSAGE, 'ERROR: ' + APROD + ' not found within the structure'
          DATX = GET(DATX,APROD)
          IF IDLTYPE(DATX) EQ 'STRUCT' THEN BEGIN
            BINS = GET(DATX,'BINS')
            DATX = GET(DATX,'IMAGE')
          ENDIF
          IF IDLTYPE(DATX,/NUMERIC) EQ 0 THEN MESSAGE, 'ERROR: ' + APROD + ' is not a data array'
        ENDIF ELSE BEGIN
          IF HAS(STRUCT,KEY_STAT_X) THEN BEGIN
            DATX = GET(STRUCT,KEY_STAT_X) ;& IF DATX EQ [] THEN MESSAGE, 'ERROR: ' + KEY_STAT_X + ' not found in the STRUCTURE'
            IF KEY_STAT_Y NE [] THEN IF HAS(STRUCT,KEY_STAT_Y) THEN BEGIN
              DATY = GET(STRUCT,KEY_STAT_Y)
              IF DATY EQ [] THEN MESSAGE, 'ERROR: ' + KEY_STAT_X + ' not found in the STRUCTURE'
              IF HAS(MP,'L3B') AND ANY(BINS) THEN DATY = MAPS_L3B_2ARR(DATY,MP=MP,BINS=BINS) ; Create a full L3B array
            ENDIF
          ENDIF ELSE BEGIN
            IF HAS(STRUCT,'PROD') THEN IF APROD NE VALIDS('PRODS',STRUCT.PROD) THEN DATX = GET(STRUCT,APROD)
          ENDELSE
        ENDELSE
      ENDIF ELSE BEGIN
        DATX = READ_NC(FILE,PROD=NC_PROD,BINS=BINS,GLOBAL=GLOBAL,/DATA)
        IF IDLTYPE(DATX) EQ 'STRING' THEN MESSAGE, DATX
      ENDELSE
      IF IDLTYPE(DATX) EQ 'STRING' THEN BEGIN
        BAD_FILES = [BAD_FILES,FILE]                                      ; Make a list of unreadable files
        IF KEY(ERROR_STOP) THEN INFORMATIONAL = 0 ELSE INFORMATIONAL = 1  ; ERROR_STOP will stop the processing, otherwise the file is skipped and the stats processing continues
        MESSAGE, 'ERROR READING: ' + FILE, INFORMATIONAL=INFORMATIONAL    ; Print error message
        GOTO, SKIP_STATFILE
        CONTINUE                                                          ; Continue with the STATS process then return the list of "BAD" files
      ENDIF
      IF HAS(MP,'L3B') AND ANY(BINS) THEN DATX = MAPS_L3B_2ARR(DATX,MP=MP,BINS=BINS) ; Create a full L3B array

      ; ===> Use STATS_ARRAYS if only DATX data is provided because it is faster than STATS_ARRAYS_XYZ
      IF DATY NE [] THEN STATXYZ = STATS_ARRAYS_XYZ(XDATA=DATX,YDATA=DATY,XTRANSFORM=_STAT_TRANSFORM,YTRANSFORM=_STAT_TRANSFORM,XSTART=START,YSTART=START,XCALC=CALC,YCALC=CALC,XSTATS=DO_STATS,YSTATS=DO_STATS) $
                    ELSE STAT    = STATS_ARRAYS(DATX, TRANSFORM=_STAT_TRANSFORM, MISSING=MISSING, DO_STATS=DO_STATS, START=START, CALC=CALC)

    ENDFOR;FOR _SUB=0,N_SUBS -1L DO BEGIN

    IF KEY(ADD_GLOBAL_PROD) THEN BEGIN
      GFILE = FILE_SEARCH(!S.GLOBAL_PRODS + SI[0].SENSOR + '-' + [APROD,NC_PROD] + '-GLOBAL.SAV')
      GLOBAL = IDL_RESTORE(GFILE[0])
    ENDIF ELSE GLOBAL = []

    ; ===> LOOK FOR X AND Y TAGS IN THE STRUCTURE
    IF IDLTYPE(STATXYZ) EQ 'STRUCT' THEN BEGIN
      IF WHERE(TAG_NAMES(STATXYZ) EQ 'X',/NULL) NE [] THEN BEGIN
        STAT = STATXYZ.X
        IF WHERE(TAG_NAMES(STATXYZ) EQ'Y',/NULL) NE [] THEN BEGIN ; Replace the GEOMETRIC/LOG TRANSFORMED stats in the STAT struct with those in the STAT.Y struct
          YY = STATXYZ.Y
          LOG_STATS  = ['LNUM','LSUM','LSSQ','GMEAN','GSTD']
          LSTATS = []
          FOR L=0, N_ELEMENTS(LOG_STATS)-1 DO BEGIN
            POSX = WHERE(TAG_NAMES(STAT) EQ LOG_STATS[L],COUNTX)
            POSY = WHERE(TAG_NAMES(YY)   EQ LOG_STATS[L],COUNTY)
            IF COUNTX EQ 0 OR COUNTY EQ 0 THEN CONTINUE
            STAT.(POSX) = YY.(POSY)
            LSTATS = [LSTATS,LOG_STATS[L]]
          ENDFOR
          IF LSTATS NE [] THEN NOTES = 'Log based stats (' + STRJOIN(LSTATS,',') + ') used the geometric mean (GMEAN) instead of the arithmetic mean (MEAN) as input data.'
        ENDIF
      ENDIF
    ENDIF

    ; ===> SAVE JUST THE PIXELS OF THE L3Bx MAPS WITH VALID DATA AND GET THE BIN NUMBERS
    IF LEVEL EQ 'L3' THEN BEGIN
      OK_NUM = WHERE(STAT.NUM GT 0 AND STAT.NUM NE MISSINGS(STAT.NUM),COUNT_BINS)    ; Find pixels where NUM is greater than 0 and not MISSINGS
      IF COUNT_BINS GE 1 THEN BEGIN
        TAGS = TAG_NAMES(STAT)                                                       ; Get the tag names of the STAT structure
        STRUCT= CREATE_STRUCT('N_SETS',STAT.N_SETS, 'RANGE',STAT.RANGE,'MISSING',$   ; Create a new stat structure with BIN info
          STAT.MISSING,'TRANSFORM',STAT.TRANSFORM,'BINS',OK_NUM,'NBINS',COUNT_BINS,'TOTAL_BINS',N_BINS)
        SKIP_TAGS = ['N_SETS','RANGE','MISSING','TRANSFORM']                         ; Tags to ignore in the LOOP
        FOR T=0, N_ELEMENTS(TAGS)-1 DO BEGIN                                         ; Loop through the STAT tags
          OKT = WHERE_MATCH(TAGS[T],SKIP_TAGS,COUNT_TAGS)                            ; Look for the tags to ignore
          IF COUNT_TAGS GT 0 THEN CONTINUE
          SUBSET = STAT.(T)                                                          ; Get the data from the tag
          SUBSET = SUBSET[OK_NUM]                                                    ; Subset the data to be only those pixels where NUM great than 0 (and not MISSINGS)
          STRUCT = CREATE_STRUCT(STRUCT,TAGS[T],SUBSET)                              ; Add subset to the new stat structure
        ENDFOR
        STAT = STRUCT & GONE, STRUCT                                                 ; Rename the stat structure
      ENDIF
    ENDIF

    OUTSTRUCT = STAT
    IF KEYWORD_SET(SKIP_SAVE) THEN GOTO, SKIP_STATFILE
    STRUCT_WRITE, STAT, FILE=STAT_FILE, DATA_UNITS=UNITS(APROD,/SI), STATS=STRJOIN(DO_STATS,'_'), INFILES=INFILES, NOTES=NOTES, GLOBAL=GLOBAL, LOGLUN=LOG_LUN ; NCFILES=NCFILES, L2FILES=L2FILES,
    SKIP_STATFILE:
  ENDFOR; FOR _TAGNAME = 0,N_ELEMENTS(TAGNAMES)-1 DO BEGIN
  ;FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF

  DONE:
END; #####################  END OF ROUTINE ################################
