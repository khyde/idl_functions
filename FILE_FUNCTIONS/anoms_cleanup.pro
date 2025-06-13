; $ID:	ANOMS_CLEANUP.PRO,	2023-09-21-13,	USER-KJWH	$
PRO ANOMS_CLEANUP,DIR_ANOMS=DIR_ANOMS,DIR_OUT=DIR_OUT,MOVE_FILES=MOVE_FILES
;+
; NAME:
;   ANOMS_CLEANUP
;
; PURPOSE:
;   Discover redundant/overlapping anomaly files and move them to a (temporary) backup directory. 
;   
; CATEGORY:
;   FILES
;
; CALLING SEQUENCE:
;   ANOMS_CLEANUP, DIR_ANOMS=DIR_ANOMS,DIR_OUT=DIR_OUT
;   
; REQUIRED INPUTS:
;   DIR_ANOMS....... Input directory
;   DIR_OUT......... Output diretory
;
; OPTIONAL INPUTS:
;   None
;
; KEYWORD PARAMETERS:
;   MOVE_FILES
;
; OUTPUTS:
;   This program moves old files from DIR_ANOMS to DIR_OUT
;
; OPTIONAL OUTPUTS:
;   None
;
; COMMON BLOCKS:
;   None
;
; SIDE EFFECTS:
;   None
;
; RESTRICTIONS:
;   None
;
; CALLING SEQUENCE:
;   ANOMS_CLEANUP
;
; SIDE EFFECTS:
;   An output directory will be created for the files to be moved.
;   Files will be moved if they meet certain criteria.
;   Information about operations will be displayed to the console.
;   
; RESTRICTIONS:
;   Only anomaly SAVE files and related CSV files should reside in the input directory.
;   REQUIRES NMFS IDL routines to work.
;
; PROCEDURE:
;   1) Choose the input directory, and the backup directory name.
;   2) Generate the backup path based on the input directory and the backup directory name, and create the backup directory if it does not exist.
;   3) Generate a list of files from the input directory, and derive the periods from them.
;   4) Categorize based on the PERIOD TYPE, and create lists of files based on that.
;   5) Group the files from each type list into sets of files that have the same value for the period type for that list.  
;       For example, DOY files are grouped into sets of files that have the same DOY.
;   6) Compare the latest YEAR to the year associated with each set, and select all files whos year is less than the highest year.
;   7) Move those files to the temporary backup directory.
;   8) Messages are printed to inform the user whether any files have been moved.
;
; EXAMPLE:
;   ANOMS_CLEANUP,DIR_ANOMS=ANOM_DIR,DIR_OUT=ANOM_BACKUP,/MOVE_FILES   
;
; NOTES:    
; 
; COPYRIGHT:
; Copyright (C) 2018, Department of Commerce, National Oceanic and Atmospheric Administration, National Marine Fisheries Service,
;   Northeast Fisheries Science Center, Narragansett Laboratory.
;   This software may be used, copied, or redistributed as long as it is not sold and this copyright notice is reproduced on each copy made.
;   This routine is provided AS IS without any express or implied warranties whatsoever.
;
; AUTHOR:
;   This program was written on February 05, 2018 by Kimberly J. W. Hyde, Northeast Fisheries Science Center | NOAA Fisheries | U.S. Department of Commerce, 28 Tarzwell Dr, Narragansett, RI 02882
;
; MODIFICATION HISTORY:
;   FEB 05, 2018 - KJWH: Initial code developed from STATS_CLEANUP
;   JUL 17, 2018 - KJWH: Added MONTH3 period
;   JUL 31, 2020 - KJWH: Updated documentation
;                        Added COMPIL_OPT IDL2
;                        Replaced subscript () with []
;                        Removed DATE_RANGE keyword because it is not used in the code
;   DEC 30, 2020 - KJWH: Added step to look for multiple files with the same name and remove the older files
;   DEC 17, 2021 - KJWH: Now considering both the first and second period when looking for "similar" names. 
;                          Previously on the first period (e.g. M_202001) was considered even though the second period was differet (e.g. M_202010-A_2020 & M_202001-MONTH_199801_202001)
;                          This resulted in good files being deleted
;   
;-
; ****************************************************************************************************
; 
  ROUTINE_NAME = 'ANOMS_CLEANUP'
  COMPILE_OPT IDL2

  IF N_ELEMENTS(DIR_ANOMS) EQ 0 OR N_ELEMENTS(DIR_OUT) EQ 0 THEN BEGIN
    PRINT, ROUTINE_NAME + ': ERROR - Missing input and/or output directories'
    RETURN
  ENDIF
      
  PERIODS = ['ANNUAL','MANNUAL','DOY','WEEK','MONTH','MONTH3']
  FOR NTH = 0L, N_ELEMENTS(PERIODS)-1 DO BEGIN
    FILES = FILE_SEARCH(DIR_ANOMS + '*' + PERIODS[NTH] + '_*.*',COUNT=COUNT)
    IF COUNT EQ 0 THEN CONTINUE
    FA = PARSE_IT(FILES)  
    OK = WHERE(FA.PERIOD_CODE NE PERIODS[NTH],COUNT,COMPLEMENT=COMPLEMENT)
    IF COUNT GE 1 THEN BEGIN
      FA = FA[OK]
      SUBFILES = [] ; Rename files so only looking at the long-term mean period information
      FOR I=0, COUNT-1 DO SUBFILES = [SUBFILES,FA[I].DIR + STRMID(FA[I].NAME_EXT,STRLEN(FA[I].PERIOD)+1)]
      FP = PARSE_IT(SUBFILES)
      OK = WHERE(FP.PERIOD EQ '',COUNT,COMPLEMENT=COMPLEMENT,NCOMPLEMENT=NCOMPLEMENT)
      FOR I=0, COUNT-1 DO FILE_RENAME,FA[OK[I]].FULLNAME,NAME_CHANGE=[FA[OK[I]].NAME,'OLD_'+FA[OK[I]].NAME],/QUIET
      IF NCOMPLEMENT EQ 0 THEN GOTO, MOVE_FILES
      FP = PARSE_IT(SUBFILES[COMPLEMENT])
      CASE PERIODS[NTH] OF
        'DOY'    : DATE_COMPARE = DATE_2DOY(PERIOD_2DATE(FP.PERIOD))
        'WEEK'   : DATE_COMPARE = DATE_2WEEK(PERIOD_2DATE(FP.PERIOD))
        'MONTH'  : DATE_COMPARE = DATE_2MONTH(PERIOD_2DATE(FP.PERIOD))
        'MONTH3' : DATE_COMPARE = DATE_2MONTH(PERIOD_2DATE(FP.PERIOD))
        'ANNUAL' : DATE_COMPARE = FP.PERIOD_CODE ;Previously DATE_2YEAR(PERIOD_2DATE(FA.PERIOD))
        'MANNUAL': DATE_COMPARE = FP.PERIOD_CODE
      ENDCASE  
      SETS = WHERE_SETS(DATE_COMPARE)
      FOR STH = 0L, N_ELEMENTS(SETS)-1 DO BEGIN
        SUBS = WHERE_SETS_SUBS(SETS[STH])
        FPSUBS = FP[SUBS] ; Represents the "renamed" files
        FASUBS = FA[SUBS] ; Represents the original files
        OK = WHERE(FPSUBS.YEAR_END LT MAX(FPSUBS.YEAR_END),COUNT)
        IF COUNT GE 1 THEN BEGIN
          PRINT, 'Renaming ' + FASUBS[OK].FULLNAME
          FOR I=0, COUNT-1 DO FILE_RENAME,FASUBS[OK[I]].FULLNAME,NAME_CHANGE=[FASUBS[OK[I]].PERIOD,'OLD_'+FASUBS[OK[I]].PERIOD],/QUIET
        ENDIF  
        OK = WHERE(FPSUBS.YEAR_START GT MIN(FPSUBS.YEAR_START),COUNT)
        IF COUNT GE 1 THEN BEGIN
          PRINT, 'Renaming ' + FASUBS[OK].FULLNAME
          FOR I=0, COUNT-1 DO FILE_RENAME,FASUBS[OK[I]].FULLNAME,NAME_CHANGE=[FASUBS[OK[I]].PERIOD,'OLD_'+FASUBS[OK[I]].PERIOD],/QUIET
        ENDIF       
      ENDFOR      
    ENDIF 
  ENDFOR
  MOVE_FILES:
  IF KEYWORD_SET(MOVE_FILES) THEN BEGIN
    FILES = FILE_SEARCH(DIR_ANOMS + 'OLD_*')    
    IF N_ELEMENTS(FILES) GT 0 AND FILES[0] NE '' THEN BEGIN 
      DIR_TEST,DIR_OUT
      PRINT, 'Moving ' + FILES + ' to ' + DIR_OUT
      FILE_MOVE,FILES,DIR_OUT,/OVERWRITE
    ENDIF  
  ENDIF
  
  ; ===> Look for multiple files with the same period (e.g. two M_200202 files that have slightly differet names) and keep the most recent
  FILES = FILE_SEARCH(DIR_ANOMS + '*.*',COUNT=COUNT)
  IF COUNT GT 0 THEN BEGIN
    FP = PARSE_IT(FILES)
    B = WHERE_SETS(FP.PERIOD + '-' + FP.SECOND_PERIOD)
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
    FILES = FILE_SEARCH(DIR_ANOMS + 'OLD_*')
    IF N_ELEMENTS(FILES) GT 0 AND FILES[0] NE '' THEN BEGIN
      DIR_TEST,DIR_OUT
      PRINT, 'Moving ' + FILES + ' to ' + DIR_OUT
      FILE_MOVE,FILES,DIR_OUT,/OVERWRITE
    ENDIF
  ENDIF  
  
  
END
