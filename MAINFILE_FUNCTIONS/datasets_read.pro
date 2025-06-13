; $ID:	DATASETS_READ.PRO,	2023-09-21-13,	USER-KJWH	$
  FUNCTION DATASETS_READ, DATASETS, NAMES=NAMES, INIT=INIT

;+
; NAME:
;   DATASETS_READ
;
; PURPOSE:
;   This function reads DATASETS_MAIN.csv and returns information on the "valid" datasets  
;
; CATEGORY:
;   DATASETS_FUNCTIONS
;
; CALLING SEQUENCE:
;   Result = DATASETS_READ()
;
; REQUIRED INPUTS:
;   None
;
; OPTIONAL INPUTS:
;   DATASETS....... The name(s) of any of the datasets found in DATASETS_MAIN.csv
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
;   COMMON _DATASETS_READ,DB,MTIME_LAST.... Contains the information found in DATASETS_MAIN.csv
;
; SIDE EFFECTS:  
;   None
;
; RESTRICTIONS:  
;   None
;
; EXAMPLE:
;   HELP, DATASETS_READ()
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
;   This program was written on February 23, 2022 by Kimberly J. W. Hyde, Northeast Fisheries Science Center | NOAA Fisheries | U.S. Department of Commerce, 28 Tarzwell Dr, Narragansett, RI 02882
;    
; MODIFICATION HISTORY:
;   Feb 23, 2022 - KJWH: Initial code written (adapted from MAPS_READ)
;-
; ****************************************************************************************************
  ROUTINE_NAME = 'DATASETS_READ'
  COMPILE_OPT IDL2
  SL = PATH_SEP()
  
  ; ===> Set up a COMMON memory block for the PRODS_MASTER.CSV
  COMMON _DATASETS_READ, DB, MTIME_LAST
  MAIN = !S.IDL_MAINFILES + 'DATASETS_MAIN.csv'
  IF FILE_TEST(MAIN) EQ 0 THEN MESSAGE,'ERROR: Can not find ' + MAIN
  
  IF ~N_ELEMENTS(MTIME_LAST) THEN MTIME_LAST = GET_MTIME(MAIN)
  IF GET_MTIME(MAIN) GT MTIME_LAST THEN INIT = 1
  
  ; ===> Read DATASETS_MAIN.CSV if not in COMMON
  IF N_ELEMENTS(DB) EQ 0 OR KEYWORD_SET(INIT) THEN BEGIN
    DB = CSV_READ(MAIN,/STRING)
    MTIME_LAST = GET_MTIME(MAIN)
  ENDIF
  
  BLANK = STRUCT_2MISSINGS(DB[0])                ; Create a blank copy of a single entry from the database
  
  IF KEYWORD_SET(NAMES) THEN RETURN,DB.DATASET   ; Return a list of dataset names
  IF ~N_ELEMENTS(DATASETS) THEN RETURN,DB        ; Return the entire DATASETS_MAIN structure

  DATASETS = STRUPCASE(STRTRIM(DATASETS,2))      ; Clean up the input datasets so that they will match up with the datasets in the csv file
  
  ; ===> Find the matching datasets in the database  
  OK_DS= WHERE_MATCH(DB.DATASET,VALIDS('DATASETS',DATASETS),COUNT_DS)
  IF COUNT_DS EQ 0 THEN BEGIN
    MESSAGE,'ERROR: ' + DATASETS + ' not found', /CONTINUE
    RETURN, BLANK
  ENDIF ELSE RETURN, DB[OK_DS]


END ; ***************** End of DATASETS_READ *****************
