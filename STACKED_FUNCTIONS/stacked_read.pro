; $ID:	STACKED_READ.PRO,	2023-09-21-13,	USER-KJWH	$
  FUNCTION STACKED_READ, FILE, PRODS=PRODS, KEYS=KEYS, DB=DB, INFO=INFO, BINS=BINS, METADATA=METADATA, OUTHASH=OUTHASH 

;+
; NAME:
;   STACKED_READ
;
; PURPOSE:
;   Function to read a "stacked" file and return a structure 
;
; CATEGORY:
;   STACKED_FUNCTIONS
;
; CALLING SEQUENCE:
;   Result = STACKED_READ(FILE, KEYS=KEYS, BINS=BINS, DB=DB)
;
; REQUIRED INPUTS:
;   FILE......... The fullname of the input file to read
;
; OPTIONAL INPUTS:
;   PRODS........ The array of products to return in the structure (the default will return all products found)
;
; KEYWORD PARAMETERS:
;   None
;
; OUTPUTS:
;   OUTPUT.......... A structure with all of the HASH data
;
; OPTIONAL OUTPUTS:
;   KEYS......... A list of the "keys" in the has
;   DB........... The database structure in the file
;   INFO......... The info structure in the file
;   BINS......... The "bin" information for the data images
;   METADATA..... The metadata structure in the file
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
;   This program was written on September 30, 2022 by Kimberly J. W. Hyde, Northeast Fisheries Science Center | NOAA Fisheries | U.S. Department of Commerce, 28 Tarzwell Dr, Narragansett, RI 02882
;    
; MODIFICATION HISTORY:
;   Sep 30, 2022 - KJWH: Initial code written
;   Jan 10, 2023 - KJWH: Added OUTHASH as an optional output
;   Dec 20, 2023 - KJWH: Converted the long form DB structure to a side-by-side structure
;-
; ****************************************************************************************************
  ROUTINE_NAME = 'STACKED_READ'
  COMPILE_OPT IDL2
  SL = PATH_SEP()
  
  IF N_ELEMENTS(FILE) NE 1 THEN MESSAGE, 'ERROR: Must input a single file name.'
  IF FILE_TEST(FILE)  NE 1 THEN MESSAGE, 'ERROR: ' + FILE + ' not found.'
  
  SD = IDL_RESTORE(FILE)                                                                                                 ; Read the input file
  OUTHASH = SD
  KEYS = SD.KEYS()                                                                                                       ; Get the KEY information in the file
  KEYS = KEYS.TOARRAY()                                                                                                  ; Convert the KEYS from a list to array
  IF WHERE(KEYS EQ 'BINS',/NULL) NE [] THEN BINS = SD['BINS'] ELSE BINS = []                                             ; Get the input BINS (if available)
  METADATA = SD['METADATA']                                                                                              ; Get the METADATA from the input files
  INFO = SD['INFO']                                                                                                      ; Get the input INFO data
  
  DBTEMP = SD['FILE_DB'].TOSTRUCT()                                                                                      ; Get the database information and convert to a structure
  ; ===> Convert the DB structure from a long structure to a side-by-side structure
  DBTAGS = TAG_NAMES(DBTEMP)                                                                                             ; Get the DB tag names
  DB = [] & FOR D=0, N_ELEMENTS(DBTAGS)-1 DO DB = CREATE_STRUCT(DB, DBTAGS[D],DBTEMP.(D)[0])                             ; Create a new blank structure
  DB = REPLICATE(STRUCT_2MISSINGS(DB), N_ELEMENTS(DBTEMP.(0)))                                                           ; Replicate the blank structure
  IF STRUCT_HAS(DB,'MTIME') THEN DB.MTIME = 0                                                                            ; Convert the missing MTIMES to 0
  FOR D=0, N_ELEMENTS(DBTAGS)-1 DO IF N_ELEMENTS(DBTEMP.(D)) EQ N_ELEMENTS(DBTEMP.(0)) THEN DB.(WHERE(TAG_NAMES(DB) EQ DBTAGS[D])) = DBTEMP.(D)                                   ; Fill in the structure
  
  INPRODS = REMOVE(KEYS,VALUES=['FILE_DB','PRODS','BINS','INFO','METADATA'])                                             ; Keep just the "DATA" variable names                                                                                                  ; Get the list of products in the infile
  IF PRODS NE [] THEN PRODS = INPRODS                                                                                    ; If no PRODS are provided, get all of the PRODS
  IF WHERE_MATCH(PRODS, INPRODS) EQ [] THEN PRODS = INPRODS                                                              ; If specific PRODS are requested, match them to the prods in the file
  
  STRUCT = CREATE_STRUCT('KEYS',KEYS, 'PRODS',PRODS, 'DB',DB, 'BINS',BINS, 'INFO',INFO, 'METADATA',METADATA)             ; Create a structure with the non-data information
  FOR R=0, N_ELEMENTS(PRODS)-1 DO BEGIN
    STRUCT = CREATE_STRUCT(STRUCT,PRODS[R],SD[PRODS[R]])
  ENDFOR

  RETURN, STRUCT

END ; ***************** End of STACKED_READ *****************
