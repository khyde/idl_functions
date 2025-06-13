; $ID:	STATS_CLEANUP.PRO,	2020-07-08-15,	USER-KJWH	$
PRO STATS_CLEANUP,DIR_STATS=DIR_STATS,DIR_OUT=DIR_OUT,MOVE_FILES=MOVE_FILES,DATERANGE=DATERANGE
;+
; NAME:
;   STATS_CLEANUP
;
; PURPOSE:
;   Discover redundant/overlapping statistics files and move them to a (temporary) backup directory. 
;   
; CATEGORY:
;   Utilities
;
; CALLING SEQUENCE:
;   stats_cleanup
;
; SIDE EFFECTS:
;   An output directory will be created for the files to be moved.
;   Files will be moved if they meet certain criteria.
;   Information about operations will be displayed to the console.
;   
; RESTRICTIONS:
;   Only statistics SAVE files and related CSV files should reside in the input directory.
;   REQUIRES NMFS IDL routines to work.
;
; PROCEDURE:
;   We first choose the input directory, and the backup directory name.
;   We then generate the backup path based on the input directory and the backup directory name,
;   and create the backup directory if it does not exist.
;   We generate a list of files from the input directory, and derive the periods from them.
;   We then categorize based on the PERIOD TYPE, and create lists of files based on that.
;   We then group the files from each type list into sets of files that have the same value
;   for the period type for that list.  For example, DOY files are grouped into sets of files that
;   have the same DOY.
;   Finally, we compare the latest YEAR to the year associated with each set, and select all files
;   whos year is less than the highest year.
;   We then move those files to the temporary backup directory.
;   Messages are printed to inform the user whether any files have been moved.
;
; EXAMPLE:
;   STATS_CLEANUP,DIR_STATS='C:\STATS_DIR',DIR_OUT='C:\STATS_DIR_OLD',/MOVE_FILES   
;
; NOTES:    
;     THIS PROGRAM RUNS EXTREMELY SLOWLY on files mounted using WindowsXXX file sharing.
;     For testing it is recommended that dummy input files are used on a local file system.
;     When running the program to actually do the required work, we recommend running it on
;     the machine where the files are located.
;   
; MODIFICATION HISTORY:
;     Written July 15, 2011 by D.W.Moonan, 28 Tarzwell Drive, NMFS, NOAA 02882 (daniel.moonan@noaa.gov)
;     7/19/2011 KJWH mods of looping and period selection simplified
;     7/20/2011 DWM removed original code, added chkdir_create for dir_move, checks for dir_in, dir_out
;     11/14/2013 KJWH replaced CHKDIR_CREATE with DIR_TEST and added CONTINUE when no files are found for a given period
;     4/23/15 KJWH updated DATE_RANGE inputs
;     JUL 21, 2017 - KJWH: Now using DATE_SELECT to subset the files based on the daterange
;                          If DATERANGE is not provided, then use the range derived from SENSOR_DATES
;     FEB 05, 2018 - KJWH: Changed keyword DATE_RANGE to DATERANGE to be consistent with other programs     
;     JUL 17, 2018 - KJWH: Added MONTH3    
;     DEC 23, 2020 - KJWH: Added step to look for multiple files with the same name and remove the older files  
;     DEC 30, 2020 - KJWH: Changed SENSOR = VALIDS('SENSORS',DIR_STATS) to SENSOR = VALIDS('SENSORS',REPLACE(DIR_STATS,PATH_SEP(),'-'))          
;-
; ****************************************************************************************************
; 
  ROUTINE_NAME = 'STATS_CLEANUP'

  IF N_ELEMENTS(DIR_STATS) EQ 0 OR N_ELEMENTS(DIR_OUT) EQ 0 THEN BEGIN
    PRINT, ROUTINE_NAME + ': Error, please provide input and output directories'
    RETURN
  ENDIF
  
  SENSOR = VALIDS('SENSORS',REPLACE(DIR_STATS,PATH_SEP(),'-'))
  IF N_ELEMENTS(SENSOR) NE 1 THEN MESSAGE, 'ERROR: More than one sensor detected'
  SDATES = SENSOR_DATES(SENSOR[0])
  IF N_ELEMENTS(DATERANGE) NE 2 THEN DATE_RANGE = SDATES ELSE DATE_RANGE = DATERANGE
  IF STRLEN(DATE_RANGE[0]) EQ 8 THEN DATE_RANGE[0] = DATE_RANGE[0]+'000000'
  IF STRLEN(DATE_RANGE[1]) EQ 8 THEN DATE_RANGE[1] = DATE_RANGE[1]+'235959'
      
  PERIODS = ['DOY','WEEK','MONTH','MONTH3','ANNUAL','MANNUAL']
  FOR NTH = 0L, N_ELEMENTS(PERIODS)-1 DO BEGIN
    FILES = FILE_SEARCH(DIR_STATS + PERIODS[NTH] + '_*.*',COUNT=COUNT)
    IF COUNT EQ 1 AND FILES[0] EQ '' THEN CONTINUE
    IF COUNT EQ 0 THEN CONTINUE
    FA = PARSE_IT(FILES)       
    CASE PERIODS[NTH] OF
      'DOY'    : DATE_COMPARE = DATE_2DOY(PERIOD_2DATE(FA.PERIOD))
      'WEEK'   : DATE_COMPARE = DATE_2WEEK(PERIOD_2DATE(FA.PERIOD))
      'MONTH'  : DATE_COMPARE = DATE_2MONTH(PERIOD_2DATE(FA.PERIOD))
      'MONTH3' : DATE_COMPARE = DATE_2MONTH(PERIOD_2DATE(FA.PERIOD))
      'ANNUAL' : DATE_COMPARE = FA.PERIOD_CODE ;Previously DATE_2YEAR(PERIOD_2DATE(FA.PERIOD))
      'MANNUAL': DATE_COMPARE = FA.PERIOD_CODE
    ENDCASE  
    SETS = WHERE_SETS(DATE_COMPARE)
    FOR STH = 0L, N_ELEMENTS(SETS)-1 DO BEGIN
      SUBS = WHERE_SETS_SUBS(SETS[STH])
      FSUBS = FA[SUBS]
      OK = WHERE(FSUBS.YEAR_END LT MAX(FSUBS.YEAR_END),COUNT)
      IF COUNT GE 1 THEN BEGIN
        PRINT, 'Renaming ' + FSUBS[OK].FULLNAME
        FILE_RENAME,FSUBS[OK].FULLNAME,NAME_CHANGE=[PERIODS[NTH],'OLD_'+PERIODS[NTH]],/QUIET
      ENDIF  
      OK = WHERE(FSUBS.YEAR_START GT MIN(FSUBS.YEAR_START),COUNT)
      IF COUNT GE 1 THEN BEGIN
        PRINT, 'Renaming ' + FSUBS[OK].FULLNAME
        FILE_RENAME,FSUBS[OK].FULLNAME,NAME_PREFIX='OLD_',/QUIET
      ENDIF       
    ENDFOR    
  ENDFOR  

; ===> Move the "OLD" files out of the STATS folder  
  IF KEYWORD_SET(MOVE_FILES) THEN BEGIN
    FILES = FILE_SEARCH(DIR_STATS + 'OLD_*')    
    IF N_ELEMENTS(FILES) GT 0 AND FILES[0] NE '' THEN BEGIN 
      DIR_TEST,DIR_OUT
      PRINT, 'Moving ' + FILES + ' to ' + DIR_OUT
      FILE_MOVE,FILES,DIR_OUT,/OVERWRITE
    ENDIF  
  ENDIF
  
; ===> Look for multiple files with the same period (e.g. two M_200202 files that have slightly differet names) and keep the most recent  
  FILES = FILE_SEARCH(DIR_STATS + '*.*',COUNT=COUNT)
  IF COUNT GT 0 THEN BEGIN 
    FP = PARSE_IT(FILES)
    B = WHERE_SETS(FP.PERIOD)
    OK = WHERE(B.N GT 1, COUNT)
    IF COUNT GT 0 THEN BEGIN
      B = B[OK]
      FOR NTH=0, N_ELEMENTS(B)-1 DO BEGIN
        SUBS = WHERE_SETS_SUBS(B[NTH])
        FSET = FP[SUBS]
        MTIMES = GET_MTIME(FSET.FULLNAME)
        OK = WHERE(MTIMES NE MAX(MTIMES),COUNT)
        IF COUNT EQ N_ELEMENTS(FSET) THEN MESSAGE, 'ERROR: All files have the same MTIME.'
        FILE_RENAME, FSET[OK].FULLNAME,NAME_PREFIX='OLD_',/QUIET
      ENDFOR
    ENDIF
  ENDIF    

; ===> Move the "OLD" files out of the STATS folder  
  IF KEYWORD_SET(MOVE_FILES) THEN BEGIN
    FILES = FILE_SEARCH(DIR_STATS + 'OLD_*')
    IF N_ELEMENTS(FILES) GT 0 AND FILES[0] NE '' THEN BEGIN
      DIR_TEST,DIR_OUT
      PRINT, 'Moving ' + FILES + ' to ' + DIR_OUT
      FILE_MOVE,FILES,DIR_OUT,/OVERWRITE
    ENDIF
  ENDIF


  DONE:
END
