; $ID:	STACKED_STATS_CLEANUP.PRO,	2023-09-21-13,	USER-KJWH	$
  PRO STACKED_STATS_CLEANUP, DATASET, PRODS=PRODS, MAPS=MAPS,  MOVE_FILES=MOVE_FILES

;+
; NAME:
;   STACKED_STATS_CLEANUP
;
; PURPOSE:
;   Remove redundant/overlapping climatological statistics files. 
;
; CATEGORY:
;   STACKED_FUNCTIONS
;
; CALLING SEQUENCE:
;   STACKED_STATS_CLEANUP, DATASET
;
; REQUIRED INPUTS:
;   DATASET.......... The dataset name(s) for the statfiles
;
; OPTIONAL INPUTS:
;   None
;
; KEYWORD PARAMETERS:
;   MOVE_FILES... If set, the redundant files will be moved to a new directory instead of deleted
;
; OUTPUTS:
;   This procedure will delete "older" (i.e. ones that don't span the full climatology) files from the input directory if the MOVE_FILES keyword is not set
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
;   This program was written on October 12, 2022 by Kimberly J. W. Hyde, Northeast Fisheries Science Center | NOAA Fisheries | U.S. Department of Commerce, 28 Tarzwell Dr, Narragansett, RI 02882
;    
; MODIFICATION HISTORY:
;   Oct 12, 2022 - KJWH: Initial code written
;   Dec 08, 2022 - KJWH: Now also looking for MM, WW and DOY periods in STACKED_TEMP 
;   Dec 14, 2022 - KJWH: Added a step to treat the periods with 00 or 000 separately 
;   Jan 11, 2024 - KJWH: Rewored program to be based on dataset name instead of specific directories
;   May 07, 2024 - KJWH: Fixed bug in the GET_FILES call (changed AMAPS to AMAP)
;-
; ****************************************************************************************************
  ROUTINE_NAME = 'STACKED_STATS_CLEANUP'
  COMPILE_OPT IDL2
  SL = PATH_SEP()
  
  IF ~N_ELEMENTS(DATASET) THEN MESSAGE, 'ERROR: Must provide at least one input dataset'
  IF ~N_ELEMENTS(PRODS) THEN MESSAGE, 'ERROR: Must provide at least one input prod'
  IF ~N_ELEMENTS(MAPS) THEN MAPS = '' ; MESSAGE, 'ERROR: Must provide at least one input map'
  TYPES = ['STACKED_STATS','STACKED_TEMP']  
  
  FOR DTH=0L, N_ELEMENTS(DATASET)-1 DO BEGIN                                                              ; Loop through the datasets
    FOR MTH=0L, N_ELEMENTS(MAPS)-1 DO BEGIN
      AMAP = MAPS
      IF AMAP EQ '' THEN AMAP = []
      FOR PTH=0L, N_ELEMENTS(PRODS)-1 DO BEGIN
      
        FOR TTH=0L, N_ELEMENTS(TYPES)-1 DO BEGIN
          CASE TYPES[TTH] OF
            'STACKED_STATS': PERIODS = ['AA'];,'DOY','WEEK','MONTH','MONTH3','ANNUAL','MANNUAL','YEAR']                                       ; Periods that will need to be "cleaned" up
            'STACKED_TEMP':  PERIODS = [PERIODS,'MM','WW','DOY']
          ENDCASE
          DIR_STATS = []
          FOR NTH = 0L, N_ELEMENTS(PERIODS)-1 DO BEGIN                                                          ; Loop through the CLIMATOLOGY periods
            FILES = GET_FILES(DATASET[DTH], PRODS=PRODS[PTH],MAPS=AMAP,PERIODS=PERIODS[NTH],FILE_TYPE=TYPES[TTH], COUNT=COUNT)             ; Search for files in the STACKED_STATS of STACKED_TEMP directory
      
            IF COUNT LE 1 THEN CONTINUE                                                                         ; If only one (or none) files were found, there is no need to look for redundant files
            FA = PARSE_IT(FILES)                                                                                ; Parse the file names
            IF DIR_STATS EQ [] THEN DIR_STATS = FA[0].DIR
            PERBR = STR_BREAK(FA.PERIOD,'_')
            OK = WHERE(PERBR[*,1] EQ '00' OR PERBR[*,1] EQ '000',COMPLEMENT=COMP,COUNT)
            IF COUNT GT 1 THEN BEGIN
              CASE PERIODS[NTH] OF
                'MONTH': DATE_COMPARE = FA.PERIOD_CODE 
                ELSE:
              ENDCASE
              
            ENDIF ELSE BEGIN
              FA = FA[COMP]
              
              CASE PERIODS[NTH] OF                                                                                ; Get period specific date information
                'DOY'    : DATE_COMPARE = DATE_2DOY(PERIOD_2DATE(FA.PERIOD))                                      
                'WEEK'   : DATE_COMPARE = DATE_2WEEK(PERIOD_2DATE(FA.PERIOD))
                'MONTH'  : DATE_COMPARE = DATE_2MONTH(PERIOD_2DATE(FA.PERIOD))
                'MONTH3' : DATE_COMPARE = DATE_2MONTH(PERIOD_2DATE(FA.PERIOD))
                'ANNUAL' : DATE_COMPARE = FA.PERIOD_CODE 
                'MANNUAL': DATE_COMPARE = FA.PERIOD_CODE
                ELSE: DATE_COMPARE = FA.PERIOD_CODE
              ENDCASE
            ENDELSE  
            
            SETS = WHERE_SETS(DATE_COMPARE)
            FOR STH = 0L, N_ELEMENTS(SETS)-1 DO BEGIN
              SUBS = WHERE_SETS_SUBS(SETS[STH])
              FSUBS = FA[SUBS]
              OK = WHERE(FSUBS.DATE_END LT MAX(FSUBS.DATE_END),COUNT)
              IF COUNT GE 1 THEN FILE_RENAME,FSUBS[OK].FULLNAME,NAME_CHANGE=[PERIODS[NTH],'OLD_'+PERIODS[NTH]],/QUIET
              
              OK = WHERE(FSUBS.YEAR_START GT MIN(FSUBS.YEAR_START),COUNT)
              IF COUNT GE 1 THEN FILE_RENAME,FSUBS[OK].FULLNAME,NAME_PREFIX='OLD_',/QUIET         
            ENDFOR ; SETS
          ENDFOR ; PERIODS
        
        
          ; ===> Delete or Move the "OLD" files out of the STATS folder
          IF DIR_STATS NE [] THEN BEGIN
            OFILES = FILE_SEARCH(DIR_STATS + 'OLD_*', COUNT=COUNT)            
            IF KEYWORD_SET(MOVE_FILES) THEN BEGIN
              IF COUNT GT 0 THEN BEGIN
                IF N_ELEMENTS(DIR_OUT) GT 1 THEN MESSAGE, 'ERROR: More than one output directory found'
                IF N_ELEMENTS(DIR_OUT) EQ 0 THEN DIR_OUT = REPLACE(FA[0].DIR,FA[0].L2SUB,'OLD_STACKED_STATS')
                DIR_TEST,DIR_OUT
                FILE_MOVE,OFILES,DIR_OUT,/OVERWRITE,/VERBOSE
              ENDIF
            ENDIF ELSE IF COUNT GT 0 THEN FILE_DELETE, OFILES,/VERBOSE ; AND N_ELEMENTS(OFILES[WHERE(FILE_TEST(OFILES) EQ 1,/NULL)]) THEN FILE_DELETE,OFILES[WHERE(FILE_TEST(OFILES) EQ 1)],/VERBOSE
          
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
                  stop ; Need to decide how to treat redundant files
                  FILE_RENAME, FSET[OK].FULLNAME,NAME_PREFIX='OLD_',/QUIET
                ENDFOR
              ENDIF
              OFILES = FILE_SEARCH(DIR_STATS + 'OLD_*', COUNT=COUNT)
              IF KEYWORD_SET(MOVE_FILES) THEN BEGIN
                IF COUNT GT 0 THEN BEGIN
                  IF N_ELEMENTS(DIR_OUT) GT 1 THEN MESSAGE, 'ERROR: More than one output directory found'
                  IF N_ELEMENTS(DIR_OUT) EQ 0 THEN DIR_OUT = REPLACE(FA[0].DIR,FA[0].L2SUB,'OLD_STACKED_STATS')
                  DIR_TEST,DIR_OUT
                  FILE_MOVE,OFILES,DIR_OUT,/OVERWRITE,/VERBOSE
                ENDIF
              ENDIF ELSE IF COUNT GT 0 THEN FILE_DELETE,OFILES,/VERBOSE
            ENDIF
          ENDIF ; Remove OLD stat files
        ENDFOR ; FILE TYPES  
      ENDFOR; MAPS
    ENDFOR ; PRODS    
  ENDFOR ; DATASETS


END ; ***************** End of STACKED_STATS_CLEANUP *****************
