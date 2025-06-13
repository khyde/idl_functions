; $ID:	PERIODS_READ.PRO,	2023-09-21-13,	USER-KJWH	$
  FUNCTION PERIODS_READ, PERIODS, NAMES=NAMES, INIT=INIT

;+
; NAME:
;   PERIODS_READ
;
; PURPOSE:
;   This function reads PERIODS_MAIN.csv and returns information on the "valid" periods  
;
; CATEGORY:
;   MAINFILE_FUNCTIONS
;
; CALLING SEQUENCE:
;   Result = PERIODS_READ()
;
; REQUIRED INPUTS:
;   None
;
; OPTIONAL INPUTS:
;   PERIODS....... The name(s) of any of the periods found in PERIODS_MAIN.csv
;
; KEYWORD PARAMETERS:
;   NAMES........... Return the names of all of the datasets
;   INIT............ Replaces the main datasets database stored in COMMON
;   
; OUTPUTS:
;   A structure with the dataset information about the specified datasets
;
; OPTIONAL OUTPUTS:
;   Depends on the input keywords and datasets
;
; COMMON BLOCKS: 
;   COMMON _PEriODSS_READ,DB,MTIME_LAST.... Contains the information found in PERIODS_MAIN.csv
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
;   This program was written on February 24, 2022 by Kimberly J. W. Hyde, Northeast Fisheries Science Center | NOAA Fisheries | U.S. Department of Commerce, 28 Tarzwell Dr, Narragansett, RI 02882
;    
; MODIFICATION HISTORY:
;   Feb 24, 2022 - KJWH: Initial code written (adapted from DATASETS_READ)
;-
; ****************************************************************************************************
  ROUTINE_NAME = 'PERIODS_READ'
  COMPILE_OPT IDL2
  SL = PATH_SEP()
  
  ; ===> Set up a COMMON memory block for the PRODS_MASTER.CSV
  COMMON _PERIODS_READ, DB, MTIME_LAST
  MAIN = !S.MAINFILES + 'PERIODS_MAIN.csv'
  IF FILE_TEST(MAIN) EQ 0 THEN MESSAGE,'ERROR: Can not find ' + MAIN

  IF ~N_ELEMENTS(MTIME_LAST) THEN MTIME_LAST = GET_MTIME(MAIN)
  IF GET_MTIME(MAIN) GT MTIME_LAST THEN INIT = 1

  ; ===> Read DATASETS_MAIN.CSV if not in COMMON
  IF N_ELEMENTS(DB) EQ 0 OR KEYWORD_SET(INIT) THEN BEGIN
    DB = CSV_READ(MAIN)
    MTIME_LAST = GET_MTIME(MAIN)
  ENDIF

  BLANK = STRUCT_2MISSINGS(DB[0])                ; Create a blank copy of a single entry from the database

  IF KEYWORD_SET(NAMES) THEN RETURN,DB.PERIOD    ; Return a list of period codes
  IF ~N_ELEMENTS(PERIODS) THEN RETURN,DB         ; Return the entire PERIODS_MAIN structure

  PERIODS = STRUPCASE(STRTRIM(PERIODS,2))       ; Clean up the input datasets so that they will match up with the datasets in the csv file

  ; ===> Find the matching datasets in the database
  OK_PC= WHERE_MATCH(DB.PERIOD_CODE,PERIODS,COUNT_PC)
  IF COUNT_PC EQ 0 THEN BEGIN
    MESSAGE,'ERROR: ' + PERIODS + ' not found', /CONTINUE
    RETURN, BLANK
  ENDIF ELSE RETURN, DB[OK_PC]



END ; ***************** End of PERIODS_READ *****************
