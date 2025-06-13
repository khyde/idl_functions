; $ID:	D3HASH_METADATA.PRO,	2023-09-21-13,	USER-KJWH	$
  FUNCTION D3HASH_METADATA, FILE, DB=DB, INPUT_DATA=INPUT_DATA

;+
; NAME:
;   D3HASH_METADATA
;
; PURPOSE:
;   Function to create a metadata structure for the "stacked" files
;
; CATEGORY:
;   STACKED FUCTIONS
;
; CALLING SEQUENCE:
;   Result = D3HASH_METADATA(D3_DB)
;
; REQUIRED INPUTS:
;   FILE........ The name of the output file
;   DB.......... The D3 database created by D3_DB
;
; OPTIONAL INPUTS:
;   INPUT_DATA.. The filenames of the original input data (e.g. SST data used to create GRAD_SST)
;
; KEYWORD PARAMETERS:
;   None
;
; OUTPUTS:
;   A structure with the metadata information 
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
;   
;   
; COPYRIGHT: 
; Copyright (C) 2021, Department of Commerce, National Oceanic and Atmospheric Administration, National Marine Fisheries Service,
;   Northeast Fisheries Science Center, Narragansett Laboratory.
;   This software may be used, copied, or redistributed as long as it is not sold and this copyright notice is reproduced on each copy made.
;   This routine is provided AS IS without any express or implied warranties whatsoever.
;
; AUTHOR:
;   This program was written on February 03, 2021 by Kimberly J. W. Hyde, Northeast Fisheries Science Center | NOAA Fisheries | U.S. Department of Commerce, 28 Tarzwell Dr, Narragansett, RI 02882
;    
; MODIFICATION HISTORY:
;   Jul 07, 2021 - KJWH: Initial code written (adapted from D3_METADATA)
;   Nov 14, 2022 - KJWH: Now using the input file to get the NETCDF_INFO
;                        Changed the search for missing DB.FULLNAME to DB.MTIME because the stacked stats DB uses STATNAME instead of FULLNAME in the DB
;-
; ****************************************************************************************************
  ROUTINE_NAME = 'D3HASH_METADATA'
  COMPILE_OPT IDL2
  
  IF IDLTYPE(DB) EQ 'OBJREF' THEN DB = DB.TOSTRUCT()
  IF IDLTYPE(DB) NE 'STRUCT' THEN MESSAGE, 'ERROR: Must provide the D3 database structure as input.'
    
  OK = WHERE(DB.MTIME NE MISSINGS(DB.MTIME),/NULL,COMPLEMENT=COMPLEMENT,NCOMPLEMENT=NCOMPLEMENT)
  IF OK EQ [] THEN MESSAGE, 'ERROR: No files found in the D3 DB' 
  NCIS = NETCDF_INFO(FILE)
  
  NCI = NCIS[0]
  NCTAGS = TAG_NAMES(NCI) & EXCLUDE_TAGS = ['FILE','NC_FILE','PERIOD_CODE','TIME','TIME_START','TIME_END']
  FOR N=0, N_ELEMENTS(NCTAGS)-1 DO BEGIN
    IF WHERE(EXCLUDE_TAGS EQ NCTAGS[N],/NULL) NE [] THEN CONTINUE
    IF SAME(NCIS.(N)) EQ 0 THEN MESSAGE, 'ERROR: Global netcdf ' + NCTAGS[N] + ' is not the same for all files.'
  ENDFOR
  GLOBAL = STRUCT_COPY(NCI,EXCLUDE_TAGS,/REMOVE)
  FILE_INPUTS = STRUCT_COPY(NCIS,EXCLUDE_TAGS)
  IF NCOMPLEMENT GT 0 THEN BEGIN
    BLANK_STRUCT = REPLICATE(STRUCT_2MISSINGS(FILE_INPUTS[0]),N_ELEMENTS(DB.MTIME))
    BLANK_STRUCT[OK] = FILE_INPUTS
    FILE_INPUTS = BLANK_STRUCT
    GONE, BLANK_STRUCT
  ENDIF
  META = CREATE_STRUCT('GLOBAL',GLOBAL,'FILE_INFORMATION',FILE_INPUTS)
  IF HAS(DB,'INPUT_FILES') THEN META = CREATE_STRUCT(META,'INPUT_FILES',DB.INPUT_FILES)
  IF HAS(DB,'ORIGINAL_FILES') THEN META = CREATE_STRUCT(META,'ORIGINAL_FILES',DB.ORIGINAL_FILES)
  
  RETURN, META
    


END ; ***************** End of D3_METADATA *****************
