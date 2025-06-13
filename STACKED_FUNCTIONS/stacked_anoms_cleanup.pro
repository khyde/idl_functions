; $ID:	STACKED_ANOMS_CLEANUP.PRO,	2023-09-21-13,	USER-KJWH	$
  PRO STACKED_ANOMS_CLEANUP, DIR, DIR_OUT=DIR_OUT, MOVE_FILES=MOVE_FILES

;+
; NAME:
;   STACKED_ANOMS_CLEANUP
;
; PURPOSE:
;   Remove redundant/overlapping anomaly files. 
;
; CATEGORY:
;   STACKED_FUNCTIONS
;
; CALLING SEQUENCE:
;   STACKED_ANOMS_CLEANUP,DIR
;
; REQUIRED INPUTS:
;   DIR.......... The directory for the STACKED_STATS files 
;
; OPTIONAL INPUTS:
;   DIR_OUT...... The output directory to move the redundant files to if the MOVE_FILES keyword is set
;
; KEYWORD PARAMETERS:
;   MOVE_FILES... If set, the redundant files will be moved to a new directory instead of deleted
;
; OUTPUTS:
;   This procedure will delete "older" (i.e. ones that don't use the most recent climatology) files from the input directory if the MOVE_FILES keyword is not set
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
; EXAMPLE:
; 
;
; NOTES:
;   $Citations or any other useful notes$
;   
; COPYRIGHT: 
; Copyright (C) 2022, Department of Commerce, National Oceanic and Atmospheric Administration, National Marine Fisheries Service,
;   Northeast Fisheries Science Center, Narragansett Laboratory.
;   This software may be used, copied, or redistributed as long as it is not sold and this copyright notice is reproduced on each copy made.
;   This routine is provided AS IS without any express or implied warranties whatsoever.
;
; AUTHOR:
;   This program was written on December 08, 2022 by Kimberly J. W. Hyde, Northeast Fisheries Science Center | NOAA Fisheries | U.S. Department of Commerce, 28 Tarzwell Dr, Narragansett, RI 02882
;    
; MODIFICATION HISTORY:
;   Dec 08, 2022 - KJWH: Initial code written
;-
; ****************************************************************************************************
  ROUTINE_NAME = 'STACKED_ANOMS_CLEANUP'
  COMPILE_OPT IDL2
  SL = PATH_SEP()
  
  IF ~N_ELEMENTS(DIR) THEN MESSAGE, 'ERROR: Must provide at least one input directory'
  DIR_ANOMS = DIR
  
  PERIODS = ['AA'];,'DOY','WEEK','MONTH','MONTH3','ANNUAL','MANNUAL','YEAR']                                     ; Periods that will need to be "cleaned" up
  FOR NTH = 0L, N_ELEMENTS(PERIODS)-1 DO BEGIN                                                          ; Loop through the CLIMATOLOGY periods
    FILES = FILE_SEARCH(DIR_ANOMS + '*' + PERIODS[NTH] + '_*.*',COUNT=COUNT)                                  ; Search for files in the input directory
    IF COUNT LE 1 THEN CONTINUE                                                                         ; If only one (or none) files were found, there is no need to look for redundant files
    FA = PARSE_IT(FILES)                                                                                ; Parse the file names
    CLIMPERIODS = VALID_PERIOD_CODES(FA.SECOND_PERIOD)
    OK = WHERE(CLIMPERIODS EQ PERIODS[NTH],COUNTPER)
    IF COUNTPER LE 1 THEN CONTINUE
    FP = FA[OK]
        
    CASE PERIODS[NTH] OF                                                                                ; Get period specific date information
      'DOY'    : DATE_COMPARE = DATE_2DOY(PERIOD_2DATE(FP.SECOND_PERIOD))
      'WEEK'   : DATE_COMPARE = DATE_2WEEK(PERIOD_2DATE(FP.SECOND_PERIOD))
      'MONTH'  : DATE_COMPARE = DATE_2MONTH(PERIOD_2DATE(FP.SECOND_PERIOD))
      'MONTH3' : DATE_COMPARE = DATE_2MONTH(PERIOD_2DATE(FP.SECOND_PERIOD))
      'ANNUAL' : DATE_COMPARE = VALID_PERIOD_CODES(FP.SECOND_PERIOD)
      'MANNUAL': DATE_COMPARE = VALID_PERIOD_CODES(FP.SECOND_PERIOD)
;      ELSE: DATE_COMPARE = FP.PERIOD_CODE
    ENDCASE

    SETS = WHERE_SETS(DATE_COMPARE)
    FOR STH = 0L, N_ELEMENTS(SETS)-1 DO BEGIN
      SUBS = WHERE_SETS_SUBS(SETS[STH])
      FSUBS = PERIOD_2STRUCT(FP[SUBS].SECOND_PERIOD)
      OK = WHERE(FSUBS.DATE_END LT MAX(FSUBS.DATE_END),COUNT)
      IF COUNT GE 1 THEN FILE_RENAME,FP[SUBS[OK]].FULLNAME,NAME_CHANGE=[PERIODS[NTH],'OLD_'+PERIODS[NTH]],/QUIET

      OK = WHERE(FSUBS.YEAR_START GT MIN(FSUBS.YEAR_START),COUNT)
      IF COUNT GE 1 THEN FILE_RENAME,FSUBS[OK].FULLNAME,NAME_PREFIX='OLD_',/QUIET

    ENDFOR
  ENDFOR
  
  ; ===> Move the "OLD" files out of the STATS folder
  OFILES = FILE_SEARCH(DIR_ANOMS + 'OLD_*', COUNT=COUNT)
  IF KEYWORD_SET(MOVE_FILES) THEN BEGIN
    IF COUNT GT 0 THEN BEGIN
      IF N_ELEMENTS(DIR_OUT) GT 1 THEN MESSAGE, 'ERROR: More than one output directory found'
      IF N_ELEMENTS(DIR_OUT) EQ 0 THEN DIR_OUT = REPLACE(FA[0].DIR,FA[0].L2SUB,'OLD_STACKED_STATS')
      DIR_TEST,DIR_OUT
      FILE_MOVE,OFILES,DIR_OUT,/OVERWRITE,/VERBOSE
    ENDIF
  ENDIF ELSE IF COUNT GT 0 THEN FILE_DELETE,OFILES,/VERBOSE

  ; ===> Look for multiple files with the same period (e.g. two M_200202 files that have slightly differet names) and keep the most recent
  FILES = FILE_SEARCH(DIR_ANOMS + '*.*',COUNT=COUNT)
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
        stop ; Need to decide how to treat redundant files
        FILE_RENAME, FSET[OK].FULLNAME,NAME_PREFIX='OLD_',/QUIET
      ENDFOR
    ENDIF
    OFILES = FILE_SEARCH(DIR_ANOMS + 'OLD_*', COUNT=COUNT)
    IF KEYWORD_SET(MOVE_FILES) THEN BEGIN
      IF COUNT GT 0 THEN BEGIN
        IF N_ELEMENTS(DIR_OUT) GT 1 THEN MESSAGE, 'ERROR: More than one output directory found'
        IF N_ELEMENTS(DIR_OUT) EQ 0 THEN DIR_OUT = REPLACE(FA[0].DIR,FA[0].L2SUB,'OLD_STACKED_STATS')
        DIR_TEST,DIR_OUT
        FILE_MOVE,OFILES,DIR_OUT,/OVERWRITE,/VERBOSE
      ENDIF
    ENDIF ELSE IF COUNT GT 0 THEN FILE_DELETE,OFILES,/VERBOSE
  ENDIF




END ; ***************** End of STACKED_ANOMS_CLEANUP *****************
