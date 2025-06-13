; $ID:	VALIDS.PRO,	2022-03-21-16,	USER-KJWH	$

FUNCTION VALIDS, FAMILY, INFO, VALID=VALID, DELIM=DELIM, OVERWRITE=OVERWRITE, INIT=INIT, PSUITE=PSUITE

;+
; NAME:
;   VALIDS
;   
; PURPOSE: 
;   This function returns valid items based on the family [PRODS, MAPS, ALGS, etc.]
; 
; CATEGORY:	
;   VALID FUNCTIONS		 
;
; CALLING SEQUENCE: 
;   Result = VALIDS(FAMILY,INFO)
;
; REQUIRED INPUTS: 
;   FAMILY...... The name of the "valids" family to check ['PRODS','MAPS','STATS' etc.]
;   INFO........ The value in the family to check [e.g. 'CHLOR_A'] 
;
; OPTIONAL INPUTS:
;   DELIM....... Delimiter to break up the input string 
;		
; KEYWORD PARAMATERS:
;   VALID....... Valid returns 1 for a valid value and 0 if the value is not found [instead of the valid information being returned]
;   OVERWRITE... Remakes the valids master using VALIDS_MAKE
;   INIT........ Initializes [rereads] the master VALIDS.csv
;   PSUITE...... Returns the prods for a suite
;
; OUTPUTS: 
;   The "valid" information for a valids family or a 1 vs. 0 [if the keyword VALID is set]
;		
; OPTIONAL OUTPUTS:
;   None		
;
; COMMON BLOCKS:
;   COMMON _VALIDS, DB
;
; SIDE EFFECTS:
;   None
;
; RESTRICTIONS:
;   None
;		
; EXAMPLES:
;  PRINT,VALIDS() ; = PRINTS ALL THE 'FAMILIES'
;  PRINT,VALIDS('PRODS') ; = PRINTS ALL THE VALUES IN THE PROD FAMILY
;  PRINT,VALIDS('PRODS','CHLOR_A'); = 'CHLOR_A'
;  PRINT,VALIDS('PRODS','S_20130101181000-MODIS-AQUA-R2013-SMI-CHLOR_A-OC4.SAVE'); = 'CHLOR_A'
;  PRINT,VALIDS('MAPS','S_20130101181000-MODIS-AQUA-R2013-SMI-CHLOR_A-OC4.SAVE'); = 'SMI'
;  PRINT,VALIDS('SENSORS','S_20130101181000-MODIS-AQUA-R2013-SMI-CHLOR_A-OC4.SAVE'); = 'AQUA'
;  PRINT,VALIDS('SENSORS','S_20130101181000-MODISA-R2013-SMI-CHLOR_A-OC4.SAVE'); = 'MODIS'
;  PRINT,VALIDS('METHODS','S_20130101181000-MODIS-AQUA-R2013-SMI-CHLOR_A-OC4.SAVE'); = 'R2013'
;  PRINT,VALIDS('SUITES','S_20130101181000-MODIS-AQUA-R2013-SMI-CHLOR_A-OC4.SAVE'); = ''
;  PRINT,VALIDS('PRODS','CHLOR_A',/VALID); = 1
;  PRINT,VALIDS('PRODS','CHLOR_',/VALID); = 0 [NO CHLOR_]
;  PRINT,VALIDS('PROD','CHLOR_A',/VALID); = 0 [NO PROD FAMILY]
;  HELP,VALIDS('PROD','CHLOR_A'); = ''   PROD   NOT FOUND
;  HELP,VALIDS('PRODS','CHLOR_'); = ''   CHLOR_   NOT FOUND
;  PRINT,VALIDS('PRODS',['CHLOR_A','SST','ABC']) ; = CHLOR_A SST
;  PRINT,VALIDS('PRODS',['CHLOR_A','SST','ABC'],/VALID); =   1       1       0
;  PRINT,VALIDS('PRODS',['CAT','DOG','BIRD'],/VALID);    =   0       0       0
;  PRINT,VALIDS('PERIODS',['D_19970508','D_19970508','D_1997050'])
;  PRINT,VALIDS('PERIODS',['D_19970508','D_19970508','D_1997050'],/VALID)
;  PLIST,VALIDS('SUITES','SEAWIFS_FULL',/PSUITE)
;  PLIST,VALIDS('SUITES','MODIS_FULL',/PSUITE)
;  PLIST,VALIDS('SENSORS',['AQUA','TERRA','MODISA','MODIST'])
;  PLIST,VALIDS('PROD_CRITERIA','SST')
;  PLIST,VALIDS('PROD_CRITERIA','PAR')
;  PLIST,VALIDS('PROD_CRITERIA','CHLOR_A')
;  HELP, VALIDS('PRODS','SDF') ; Invalid PROD name
;  HELP, VALIDS('ALGS', 'SDF') ; Invalid ALG name
;  HELP, VALIDS('ALG', 'PAN')  ; Invalid FAMILY name
;  
; NOTES:
;
;
; COPYRIGHT:
; Copyright (C) 2020, Department of Commerce, National Oceanic and Atmospheric Administration, National Marine Fisheries Service,
;   Northeast Fisheries Science Center, Narragansett Laboratory.
;   This software may be used, copied, or redistributed as long as it is not sold and this copyright notice is reproduced on each copy made.
;   This routine is provided AS IS without any express or implied warranties whatsoever.
;
; AUTHOR:
;   This program was written on August 12, 2015 by John E. O'Reilly, Northeast Fisheries Science Center | NOAA Fisheries | U.S. Department of Commerce, 28 Tarzwell Dr, Narragansett, RI 02882
;   Inquiries should be directed to kimberly.hyde@noaa.gov.
;
;
; MODIFICATION HISTORY:
;   AUG 12, 2015 - JEOR: Initial code written
;   AUG 13, 2015 - JEOR: Added and tested examples
;		AUG 14, 2015 - JEOR: Merged code & logic from VALID_SENSORS
;		                     Added IF FILE_MAKE(IN,MAIN,OVERWRITE=OVERWRITE) THEN VALIDS_MAKE
;   OCT 20, 2015 - JEOR: Periods was not working so:
;                          IF FAMILY EQ 'PERIODS' THEN  RETURN, VALID_PERIODS(INFO,VALID=VALID)
;   OCT 23, 2015 - JEOR: Revised VALID_PERIODS to return the period, not a structure
;   NOV 18, 2015 - JEOR: Added AQUA and TERRA to sensors in master
;   DEC 18, 2015 - JEOR  Added keyword PSUITE and associated logic
;                          IF FAMILY EQ 'SENSORS' THEN BEGIN
;                        Added MODISA AQUA & PSUITE examples
;   JAN 17, 2016 - JEOR: Added ;===> IF FAMILY EQ 'PXYZ' OR FAMILY EQ 'PXY' THEN RETURN,VALID_PXYZ(INFO,VALID=VALID)
;   AUG 02, 2016 - JEOR: Added ;===> Added KEY CRITERIA AND CRITERIA EXAMPLES FOR SST,PAR & CHLOR_A
;   AUG 23, 2016 - KJWH: Added STRUPCASE(FAMILY)
;                        Added VALID_PERIOD_CODES()
;                        Streamlined the user specific SENSOR block
;                        Formatting
;   FEB 13, 2017 - KJWH: Added a RETURN, ERROR statement when the family is not in the DB and not a special case
;                        Added examples of "bad" inputs  
;                        Replaced IF ANY(TXT) with IF TOTAL(_VALID) GT 0.0 in the PSUITE and CRITERIA special cases (program would crash if TXT='')    
;   FEB 14, 2017 - KJWH: Added IF DB(OK_VALUES).CRITERIA EQ '' THEN RETURN, [] to return a NULL string if no criteria info is provided in the MASTER DB  
;   MAR 15, 2017 - KJWH: Added step to split up the new PRODS_CRITERIA string using STR_BREAK if FAMILY EQ 'PROD_CRITERIA'
;                        Added step to join the values found in the valid PROD_CRITERIA  
;   MAR 27, 2017 - KJWH: Removed keyword and references to the old CRITERIA keyword and changed examples to PROD_CRITERIA      
;   DEC 12, 2017 - KJWH: Added DELIM keyword so that we can look for 'VALIDS' in directories                
;   APR 19, 2021 - KJWH: Updated documentation
;                        Added COMPILE_OPT IDL2
;                        Changes all subscripts from () to []
;                        Tested the DAYNIGHT valid option
;   APR 20, 2021 - KJWH: Added DATETIME to the COMMON block 
;                        If the VALIDS master is older than the DATETIME then clear the DB and run VALIDS_MAKE                     
;   SEP 21, 2021 - KJWH: Changed !S.MASTER to !S.IDL_MASTER
;   SEP 22, 2021 - KJWH: Changed !S.IDL_MASTER to !S.IDL_MAINFILES
;                        Changed PRODS_MASTER and MAPS_MASTER to PRODS_MAIN and MAPS_MAIN
;   SEP 30, 2021 - KJWH: Changed the details associated with VALIDS_MAKE because we are no longer adding the PRODS and MAPS information into VALIDS.csv                
;   FEB 23, 2022 - KJWH: Added DATASETS_MAIN.csv to the INFILES
;   OCT 19, 2022 - KJWH: Added VALID_MAP_SUBSET to check for any "subset" map names
;   MAY 10, 2023 - KJWH: Added step to remove stat labels (e.g. NUM, MIN, MEAN) from products (e.g. CHLOR_A_MEAN)
;-
; ***********************************************************************************
  ROUTINE_NAME  = 'VALIDS'
  COMPILE_OPT IDL2
  
  VALIDFILE = !S.IDL_MAINFILES + 'VALIDS.csv'
  INFILES = !S.IDL_MAINFILES + ['PRODS_MAIN.csv','MAPS_MAIN.csv','DATASETS_MAIN.csv']
  COMMON _VALIDS, DB, DATETIME
  
  IF ~N_ELEMENTS(DATETIME) THEN DATETIME = SYSTIME(/JULIAN,/UTC)
  IF MAX(GET_MTIME([VALIDFILE,INFILES],/JD)) GT DATETIME THEN INIT=1
  IF DB EQ [] THEN INIT = 1
  
  IF NONE(DELIM) THEN DELIM = '-'

 ; ===> If any of the files have been updated, then recreate the DB
  IF KEYWORD_SET(INIT) THEN BEGIN
    DB = VALIDS_MAKE()
    DATETIME = SYSTIME(/JULIAN,/UTC)
  ENDIF

  IF NONE(FAMILY) THEN RETURN, TAG_NAMES(DB) ELSE FAMILY = STRUPCASE(FAMILY)
  
  VALUES = STRUCT_GET(DB,FAMILY)

; ===> USER SPECIFIC SENSORS
  IF FAMILY EQ 'SENSORS' THEN BEGIN
    CASE !S.USER OF
      'JEOR': OK = WHERE_IN(DB.SENSORS,['MODISA','MODIST'],COUNT)
      'KJWH': OK = WHERE_IN(DB.SENSORS,['AQUA','TERRA'],COUNT)
      'khyde': OK = WHERE_IN(DB.SENSORS,['AQUA','TERRA'],COUNT)
      ELSE:   COUNT = 0
    ENDCASE  
    IF COUNT GE 1 THEN DB[OK].SENSORS = ''
  ENDIF;IF FAMILY EQ 'SENSORS' THEN BEGIN
  
  OK = WHERE(VALUES EQ '',COUNT)
  IF COUNT GE 1 THEN VALUES = REMOVE(VALUES,OK)
  IF KEY(FAMILY) AND NONE(INFO) THEN RETURN,VALUES
  
  TXT = STRARR(N_ELEMENTS(INFO))
  _VALID = INTARR(N_ELEMENTS(INFO))
  _VALID[*] = 0

; ===> SPECIAL CASES
  IF FAMILY EQ 'PERIODS' THEN  RETURN,VALID_PERIODS(INFO,VALID=VALID)             ; Run VALID_PERIODS because there are too many possibilities
  IF FAMILY EQ 'PERIOD_CODES' THEN RETURN, VALID_PERIOD_CODES(INFO,VALID=VALID)   ; Run VALID_PERIOD_CODES because period codes are not parsed by '-' 
  IF FAMILY EQ 'PXYZ' OR FAMILY EQ 'PXY' THEN RETURN,VALID_PXYZ(INFO,VALID=VALID) ; Run VALID_PXPY because there are too many possibilities
  IF FAMILY EQ 'MAP_SUBSET' THEN RETURN, VALID_MAP_SUBSET(INFO,VALID=VALID)       ; Run VALID_MAP_SUBSET to find the "subset" map used when reducing the size of full L3B files

; ===> FAMILY NOT FOUND IN THE DB
  IF VALUES EQ [] THEN RETURN, 'ERROR: Input family (' + FAMILY + ') not found in VALIDS database'

  IF FAMILY EQ 'PROD_CRITERIA' THEN CVALUES = STR_BREAK(VALUES,';') 

; ===> LOOP THROUGH THE INPUT INFORMATION
  FOR _INFO=0L,N_ELEMENTS(INFO)-1L DO BEGIN
    AINFO = INFO[_INFO]
    FN  = FILE_PARSE(AINFO)
    T = WORDS(WORDS(STRUPCASE(FN.FULLNAME)),DELIM = DELIM) ; Split up the information based on dashes
    CASE FAMILY OF
       'PRODS': BEGIN
          STAT_LABELS = '_'+['RATIO','DIF','ANOM','NUM','MIN' ,'SUB_MIN' ,'MAX' ,'SUB_MAX' ,'SUM' ,'SPAN' ,'MED' ,'MEAN' ,'AMEAN' ,'VAR' ,'STD' ,'CV' ,'MDEV' ,'SKEW' ,'KURT' ,'GMEAN' ,'GMED' ,'GVAR' ,'GSTD' ,'GCV','GMDEV','GSKEW','GKURT']
          T = REPLACE(T,STAT_LABELS,REPLICATE('',N_ELEMENTS(STAT_LABELS)))
          OK_VALUES  = WHERE_IN(VALUES, T, COUNT)
          _VALID[_INFO] = COUNT
          IF COUNT EQ 1 THEN TXT[_INFO] = VALUES[OK_VALUES[0]]
          IF COUNT GT 1 THEN TXT[_INFO] = STRJOIN(VALUES[OK_VALUES],'_')
        END
          
       'PROD_CRITERIA':  BEGIN
        OK_VALUES  = WHERE_IN(CVALUES[*,0], T, COUNT)
        IF COUNT EQ 1 THEN TXT[_INFO] = CVALUES[OK_VALUES,1] + '_' + CVALUES[OK_VALUES,2]
        IF COUNT GT 1 THEN MESSAGE, 'ERROR: More than one valid family found'
      END 
      
      ELSE: BEGIN
        OK_VALUES  = WHERE_IN(VALUES, T, COUNT)
        _VALID[_INFO] = COUNT
        IF COUNT EQ 1 THEN TXT[_INFO] = VALUES[OK_VALUES[0]]
        IF COUNT GT 1 THEN TXT[_INFO] = STRJOIN(VALUES[OK_VALUES],'_')
      END 
    ENDCASE
  ENDFOR ; INFO loop

  IF KEY(VALID) THEN BEGIN
    IF N_ELEMENTS(_VALID) EQ 1 THEN RETURN, _VALID[0] ELSE RETURN, _VALID
  ENDIF ; IF KEY(VALID) THEN BEGIN

; ===> RETURN PRODS FOR SUITES IF KEY PSUITE
  IF TOTAL(_VALID) GT 0.0 AND KEY(PSUITE)   THEN  RETURN, STR_SEP(DB[OK_VALUES].PSUITE,';')

  IF N_ELEMENTS(TXT) EQ 1 THEN RETURN,TXT[0] ELSE RETURN, TXT

END; #####################  END OF ROUTINE ################################
