; $ID:	DWLD_NASA_REMOVE_DUPLICATES.PRO,	2023-09-21-13,	USER-KJWH	$
  PRO DWLD_NASA_REMOVE_DUPLICATES, DIRECTORY, LOGFILE=LOGFILE, LOGLUN=LOGLUN

;+
; NAME:
;   DWLD_NASA_REMOVE_DUPLICATES
;
; PURPOSE:
;   This program will find and remove duplicate NASA files prior to downloading
;
; CATEGORY:
;   DOWNLOAD_FUNCTIONS
;
; CALLING SEQUENCE:
;   DWLD_NASA_REMOVE_DUPLICATES, DIRECTORY
;
; REQUIRED INPUTS:
;   DIRECTORY.......... The directory location for the files
;
; OPTIONAL INPUTS:
;   LOGLUN........... The LUN for the log file
;   LOGFILE.......... The name of the log file
;
; KEYWORD PARAMETERS:
;   None
;
; OUTPUTS:
;   A directory where the duplicate files have been removed
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
; Copyright (C) 2021, Department of Commerce, National Oceanic and Atmospheric Administration, National Marine Fisheries Service,
;   Northeast Fisheries Science Center, Narragansett Laboratory.
;   This software may be used, copied, or redistributed as long as it is not sold and this copyright notice is reproduced on each copy made.
;   This routine is provided AS IS without any express or implied warranties whatsoever.
;
; AUTHOR:
;   This program was written on November 01, 2021 by Kimberly J. W. Hyde, Northeast Fisheries Science Center | NOAA Fisheries | U.S. Department of Commerce, 28 Tarzwell Dr, Narragansett, RI 02882
;    
; MODIFICATION HISTORY:
;   Nov 01, 2021 - KJWH: Initial code written
;   Dec 13, 2021 - KJWH: Updated code to work when more than 2 "duplicate" files are found
;                          Once the first duplicate file is removed, update the list of "duplicate" files and continue
;                          If all duplicates are not removed the first time the program is run, they "should" be removed in subsequent calls.
;   Dec 14, 2022 - KJWH: Added COUNT to the FILE_SEARCH
;-
; ****************************************************************************************************
  ROUTINE_NAME = 'DWLD_NASA_REMOVE_DUPLICATES'
  COMPILE_OPT IDL2
  SL = PATH_SEP()
  
  IF N_ELEMENTS(LOGLUN) EQ 1 THEN LUN=LOGLUN ELSE LUN = []
  
  IF N_ELEMENTS(DIRECTORY) NE 1 THEN MESSAGE ,'ERROR: Must provide a single file directory'
  IF ~FILE_TEST(DIRECTORY,/DIR) THEN MESSAGE, 'ERROR: ' + DIRECTORY + ' does not exist.'
  
  NFILES = FILE_SEARCH(DIRECTORY + '*.*',COUNT=COUNT)
  IF COUNT EQ 0 THEN GOTO, SKIP_DUPS
  FNP = FILE_PARSE(NFILES)
  FSP = STR_BREAK(REPLACE(FNP.NAME_EXT,'.',','),',')
  DUPS = WHERE_DUPS(FSP[*,0]+'-'+FSP[*,1],COUNT)
  IF COUNT EQ 0 THEN GOTO, SKIP_DUPS
  IF MAX(DUPS.N) GT 10 THEN MESSAGE, 'ERROR: More than 10 "duplicate" files found in ' + DATASET
  PLUN, LUN, 'Found ' + NUM2STR(COUNT) + ' sets of duplicate files.'
  FOR D=0, COUNT-1 DO BEGIN
    DUPFILES = NFILES[WHERE_SETS_SUBS(DUPS[D])]
    DFP = FILE_PARSE(DUPFILES)
    IF HAS(DFP.EXT,'NRT') THEN BEGIN  ; Near real-time files have the extension NRT.nc
      NFP = FILE_PARSE(DFP.NAME)       ; Compare the file names without the .nc extension
      IF SAME(NFP.EXT) AND ~SAME(NFP.NAME) THEN CONTINUE  ; If the extension is the same (i.e. NRT), but the name is different (e.g. SST and SST4) then continue because the files are not duplicate

      DUP_MTIMES = GET_MTIME(DUPFILES)
      NRT = DUPFILES[WHERE(STRUPCASE(NFP.EXT) EQ 'NRT',/NULL)]
      IF NRT EQ [] THEN MESSAGE, 'ERROR: NRT extension not found.'
      IF GET_MTIME(NRT) NE MIN(DUP_MTIMES) THEN MESSAGE, 'ERROR: NRT file is newer than the other duplicate file.' $
                                           ELSE FILE_DELETE, NRT, /VERBOSE
      DUPFILES = DUPFILES[WHERE(FILE_TEST(DUPFILES) EQ 1, /NULL)]   ; Removed the deleted file from the list of duplicate files
      DFP = FILE_PARSE(DUPFILES)                                    ; Parse the duplicate files again
    ENDIF

    IF SAME(DFP.EXT) AND ~SAME(DFP.NAME) THEN CONTINUE
    MTIMES = GET_MTIME(DUPFILES)
    OK = WHERE(MTIMES EQ MAX(MTIMES),CT,COMPLEMENT=COMP)
    IF CT EQ N_ELEMENTS(DUPFILES) THEN BEGIN
      OK = WHERE(IS_NUM(DFP.EXT) EQ 0, COUNT, COMPLEMENT=COMP)
      IF COUNT NE 1 THEN MESSAGE, 'ERROR: Unable to identify which duplicate file to keep in ' + DATASET
      KEEP_FILE = DUPFILES[OK]
      DEL_FILE  = DUPFILES[COMP]
    ENDIF ELSE BEGIN
      IF CT NE 1 THEN PLUN, LUN, DUPFILES
      IF CT NE 1 THEN MESSAGE, 'ERROR: Unable to identify which duplicate file to keep in ' + DATASET
      KEEP_FILE = DUPFILES[OK]
      DEL_FILE  = DUPFILES[COMP] 
    ENDELSE
    PLUN, LUN, 'Removing duplicate file(s) - ' + DEL_FILE,0
    FILE_DELETE, DEL_FILE
    KFP = PARSE_IT(KEEP_FILE)
    IF KFP.EXT NE 'nc' THEN FILE_COPY, KEEP_FILE, REPLACE(KEEP_FILE,'.'+KFP.EXT,''), /VERBOSE
  ENDFOR
  
  SKIP_DUPS:


END ; ***************** End of DWLD_NASA_REMOVE_DUPLICATES *****************
