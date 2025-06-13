; $ID:	D3_METADATA.PRO,	2023-09-21-13,	USER-KJWH	$
  PRO D3_METADATA, D3_DBFILE, INPUT_DATA=INPUT_DATA

;+
; NAME:
;   D3_METADATA
;
; PURPOSE:
;   Make a file to hold the metadata for the D3 files
;
; CATEGORY:
;   D3 FUCTIONS
;
; CALLING SEQUENCE:
;   Result = D3_METADATA(D3_DB)
;
; REQUIRED INPUTS:
;   D3_DB.......... The D3 database created by D3_DB
;
; OPTIONAL INPUTS:
;   INPUT_DATA..... Additional metadata for the original input data (e.g. SST data used to create GRAD_SST)
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
;   Feb 03, 2021 - KJWH: Initial code written
;-
; ****************************************************************************************************
  ROUTINE_NAME = 'D3_METADATA'
  COMPILE_OPT IDL2
  
  IF N_ELEMENTS(D3_DBFILE) NE 1 THEN MESSAGE, 'ERROR: Must provide the name of a D3_DB file as input.'
  IF ~FILE_TEST(D3_DBFILE) THEN MESSAGE, 'ERROR: ' + D3_DBFILE + ' does not exist.'
  
  METAFILE = REPLACE(D3_DBFILE,'-D3_DB.SAV','-D3_METADATA.SAV')    
  IF FILE_MAKE(D3_DBFILE,METAFILE,OVERWRITE=OVERWRITE) EQ 1 THEN BEGIN    
  
    DB = IDL_RESTORE(D3_DBFILE)
    OK = WHERE(DB.FULLNAME NE '',/NULL)
    IF OK EQ [] THEN MESSAGES, 'ERROR: No files found in the D3 DB' 
    NCIS = NETCDF_INFO(DB[OK].FULLNAME)
    
    NCI = NCIS[0]
    NCTAGS = TAG_NAMES(NCI) & EXCLUDE_TAGS = ['FILE','NC_FILE','PERIOD_CODE','TIME','TIME_START','TIME_END']
    FOR N=0, N_ELEMENTS(NCTAGS)-1 DO BEGIN
      IF WHERE(EXCLUDE_TAGS EQ NCTAGS[N],/NULL) NE [] THEN CONTINUE
      IF SAME(NCIS.(N)) EQ 0 THEN MESSAGE, 'ERROR: Global netcdf ' + NCTAGS[N] + ' is not the same for all files.'
    ENDFOR
    GLOBAL = STRUCT_COPY(NCI,EXCLUDE_TAGS,/REMOVE)
    FILE_INPUTS = STRUCT_COPY(NCIS,EXCLUDE_TAGS)
    
    IF INPUT_DATA NE [] THEN BEGIN
      IF N_ELEMENTS(INPUT_DATA) NE 1 THEN MESSAGE, 'ERROR: INPUT_DATA elements should equal 1.'
      GLOBAL = STRUCT_MERGE(GLOBAL,INPUT_DATA)
    ENDIF
    
    D3_META = CREATE_STRUCT('GLOBAL',GLOBAL,'FILE_INFORMATION',FILE_INPUTS)
    STRUCT_WRITE, D3_META, FILE=METAFILE
  ENDIF  


END ; ***************** End of D3_METADATA *****************
