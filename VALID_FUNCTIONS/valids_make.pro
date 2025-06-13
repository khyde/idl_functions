; $ID:	VALIDS_MAKE.PRO,	2022-03-21-16,	USER-KJWH	$

FUNCTION VALIDS_MAKE, VERBOSE=VERBOSE
;
;+
; NAME:
;   VALIDS_MAKE
;   
; PURPOSE: 
;   This routine merges the VALIDS, PRODS and MAPS databases and returns all info in a structure
;
; CATEGORY: 
;   VALIDS FUNCTION
;
; REQUIRED INPUTS:
;   None
;   
; OPTIONAL INPUTS
;   None
;
; KEYWORD PARAMETERS:
;   VERBOSE.......... Print program progress
;
; OUTPUTS:
;   This program creates an upated VALIDS.csv master and makes a backup copy of the original
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
; NOTES:
;
; COPYRIGHT:
; Copyright (C) 2020, Department of Commerce, National Oceanic and Atmospheric Administration, National Marine Fisheries Service,
;   Northeast Fisheries Science Center, Narragansett Laboratory.
;   This software may be used, copied, or redistributed as long as it is not sold and this copyright notice is reproduced on each copy made.
;   This routine is provided AS IS without any express or implied warranties whatsoever.
;
; AUTHOR:
;   This program was written on August 11, 2015 by John E. O'Reilly, Northeast Fisheries Science Center | NOAA Fisheries | U.S. Department of Commerce, 28 Tarzwell Dr, Narragansett, RI 02882
;   Inquiries should be directed to kimberly.hyde@noaa.gov.
;
; MODIFICATION HISTORY:
;   AUG 11, 2015 - JEOR: Initial code written
;   AUG 12, 2015 - JEOR  Output a 'regular' type spreadsheet csv
;   AUG 15, 2015 - JEOR  Removed duplicates T = (WHERE_SETS(T)).VALUE
;   AUG 20, 2015 - KJWH: Changed 'VALID*.PRO' to 'valid*.pro' because the file names are case sensitive in linux
;   OCT 23, 2015 - JEOR: Changed to only update prods and maps  
;   FEB 17, 2017 - JEOR: Commented:  ; DB.(NTH) =DM.(OK_TAG)  [UNEQUAL SIZES]    
;   MAR 02, 2017 - JEOR: Overhauled
;                        Added VERBOSE and OVERWRITE keywords
;   MAR 03, 2017 - JEOR: Added 2 new tags: PROD_CRITERIA and PROD_TITLE to VALIDS.csv  
;                        Added IF TAG EQ 'PRODS' OR  TAG EQ 'PROD_CRITERIA' OR  TAG EQ 'PROD_TITLE' THEN BEGIN
;   APR 19, 2021 - KJWH: Updated documentation and formatting
;                        Removed old code
;                        Added COMPILE_OPT IDL2
;                        Changed subscript () to []
;                        Now saving the backup copy file to !S.MASTER/REPLACED      
;                        Changed the IF [tag] THEN statements to a CASE block instead               
;   SEP 21, 2021 - KJWH: Changed !S.MASTER to !S.IDL_MAINFILES   
;   SEP 23, 2021 - KJWH: Removed the step to make a back up of the VALIDS file since the files are not version controlled on GITHUB 
;   SEP 29, 2021 - KJWH: No longer adding PRODS and MAPS info to VALIDS.  Now the primary purpose is to return a merged database
;                        Changed from a PRO to a FUNCTION
;                        Adding the PRODS and MAPS tags to the VALIDS DB
;   FEB 23, 2022 - KJWH: Added DATASET tags to the VALIDS DB
;-
; **************************************************************************************************************************
  ROUTINE_NAME  = 'VALIDS_MAKE'
  COMPILE_OPT IDL2
  SL = PATH_SEP()
  
  IF NONE(VERBOSE) THEN VERBOSE = 1

; ===> MASTER files 
  VMSTR = !S.MAINFILES + 'VALIDS.csv'
  PMSTR = !S.MAINFILES + 'PRODS_MAIN.csv'
  MMSTR = !S.MAINFILES + 'MAPS_MAIN.csv'
  DSSTR = !S.MAINFILES + 'DATASETS_MAIN.csv'

;===> Read the MAIN files
  DV = CSV_READ(VMSTR)
  DP = CSV_READ(PMSTR)
  DM = CSV_READ(MMSTR)
  DS = CSV_READ(DSSTR)

;===> REPLICATE THE VALIDS MASTER DB
  S = STRUCT_2MISSINGS(DV[0])
  S = CREATE_STRUCT(S,'DATASETS','','MAPS','','PRODS','','PROD_CRITERIA','','PROD_TITLE','')  ; Add the DATASETS, MAPS and PRODS tags
  MAX_NUM  = MAX([N_ELEMENTS(DV),N_ELEMENTS(DP),N_ELEMENTS(DM),N_ELEMENTS(DS)] )
  DB = REPLICATE(S,MAX_NUM > 1000)
  TAGS = TAG_NAMES(DB)

  FOR NTH = 0,NOF(TAGS)-1 DO BEGIN
    TAG = TAGS[NTH]
    CASE TAG OF
      'DATASETS': BEGIN
        OK_TAG = WHERE(TAG_NAMES(DS) EQ 'DATASET', COUNT)
        IF COUNT NE 1 THEN MESSAGE, 'ERROR: Can not find DATASET tag.'
        N = N_ELEMENTS(DS)-1
        DB[0:N].(NTH) = DS.(OK_TAG)
      END  
      'MAPS': BEGIN
        OK_TAG = WHERE(TAG_NAMES(DM) EQ 'MAP',COUNT)
        IF COUNT NE 1 THEN MESSAGE,'ERROR: Can not find MAP tag '
        N = NOF(DM)-1
        DB[0:N].(NTH) =  DM.(OK_TAG)
      END
      'PRODS': BEGIN
        OK_TAG = WHERE(TAG_NAMES(DP) EQ 'PROD',COUNT)
        IF COUNT NE 1 THEN MESSAGE,'ERROR: Can not find PROD tag '
        N = NOF(DP)-1
        DB[0:N].(NTH) =  DP.(OK_TAG)
      END
      'PROD_CRITERIA': BEGIN
        OK_TAG = WHERE(TAG_NAMES(DP) EQ 'PROD_CRITERIA',COUNT)
        IF COUNT NE 1 THEN MESSAGE,'ERROR: Can not find PROD tag '
        N = NOF(DP)-1
        DB[0:N].(NTH) =  DP.(OK_TAG)
      END
      'PROD_TITLE': BEGIN
        OK_TAG = WHERE(TAG_NAMES(DP) EQ 'PROD_TITLE',COUNT)
        IF COUNT NE 1 THEN MESSAGE,'ERROR: Can not find PROD tag '
        N = NOF(DP)-1
        DB[0:N].(NTH) =  DP.(OK_TAG)
      END
      ELSE: BEGIN
        N = NOF(DV)-1
        DB[0:N].(NTH) =  DV.(NTH)
      END
    ENDCASE
  ENDFOR;FOR NTH = 0,NOF(ALL_TAGS)-1 DO BEGIN

; ===> DELETE EMPTY RECORDS
  S = STRCOMPRESS(STRUCT_2STRING(DB,DELIM = ' '))
  OK = WHERE(STRLEN(S) GT 1,COUNT) 
  DB = DB[OK]

  RETURN, DB

END; #####################  End of VALIDS_MAKE ################################
