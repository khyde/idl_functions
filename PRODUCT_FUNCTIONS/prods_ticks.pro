; $ID:	PRODS_TICKS.PRO,	2023-09-21-13,	USER-KJWH	$
FUNCTION PRODS_TICKS, PROD, CB_RANGE=CB_RANGE, NUM_TICKS=NUM_TICKS, LOG=LOG, _EXTRA=_EXTRA
;+                    
; NAME: 
;   PRODS_TICKS   
;
; PURPOSE:  
;   This function generates a structure with ticknames for colorbars
;   
; CATEGORY: 
;   Product functions
;
; CALLING SEQUENCE:
;   RESULT = PRODS_TICKS(PROD)
;
; REQUIRED INPUTS:
;   PROD.......... The input "product" name 
;		
; OPTIONAL INPUTS		
;		CB_RANGE...... The byte scale range (0-255) for the colorbar (input to SCALE) 
;		NUM_TICKS..... The number of tick values to return
;
; KEYWORDS:
;	  LOG........... Set the keyword to force the product to be log scaled 
;
; OUTPUTS:  
;   A structure with the product information, range, tick values and ticknames (to make a colorbar)
;	
; OPTIONAL OUTPUTS:
;   None
;
; COMMON BLOCKS:
;   PRODS_MAIN database
;
; SIDE EFFECTS:
;   None
;
; RESTRICTIONS:
;   None
;   
; EXAMPLES:    
;   ST, PRODS_TICKS('SST')
;   ST, PRODS_TICKS('SST_0_10') ; Will parse out the range from the input name
;   ST, PRODS_TICKS('NUM_0_10')
;   ST, PRODS_TICKS('NUM_0_10',/LOG)
;   ST, PRODS_TICKS('NUM_1_10',/LOG) ; Will return an ERROR because the log scale minimum must be greater than 0
;   ST, PRODS_TICKS('CHLOR_A') 
;   ST, PRODS_TICKS('CHLOR_A_0.1_30') 
;   ST, PRODS_TICKS('DEPTH',/LOG) 
;   ST, PRODS_TICKS('RRS_412_0.0002_0.02',/LOG)       ; Not a good range for the colorbar
;   ST, PRODS_TICKS('RRS_412_0.0001_0.02',/LOG)       ; Optimizes legibility of ticknames for RRS_412   
;
; COPYRIGHT:
; Copyright (C) 2014, Department of Commerce, National Oceanic and Atmospheric Administration, National Marine Fisheries Service,
;   Northeast Fisheries Science Center, Narragansett Laboratory.
;   This software may be used, copied, or redistributed as long as it is not sold and this copyright notice is reproduced on each copy made.
;   This routine is provided AS IS without any express or implied warranties whatsoever.
;
; AUTHOR:
;   This program was written on January 06, 2014 by John E. O'Reilly, Northeast Fisheries Science Center | NOAA Fisheries | U.S. Department of Commerce, 28 Tarzwell Dr, Narragansett, RI 02882
;     Inquires regarding this program should be directed to Kimberly.hyde@noaa.gov
;   
; MODIFICATION HISTORY:
;   JAN 06, 2014 - JEOR: Initial code written 
;   JAN 07, 2014 - JEOR: Revised to use INTERVAL                       
;   JAN 10, 2014 - JEOR: Added keyword TICKS9
;                        Added T0:T9 [EXPLICIT TICKNAMES] to structure
;   JAN 15, 2014 - JEOR: Added TICKNAME = STR_ZERO_TRIM(ROUNDS(TICKVS,3,/SIG),TRIM=3)
;                        Added IF NOT KEYWORD_SET(LOG) THEN LOG = 0
;   JAN 17, 2014 - JEOR: Added keyword TEST
;                        Added IF SPAN(MIN_MAX_LOG) EQ 1 THEN BEGIN
;   JAN 23, 2014 - JEOR: Added IF SPAN(_RANGE) MOD 5 EQ 0 THEN INCREMENT = 5 ELSE INCREMENT = 0.5
;   FEB 03, 2014 - JEOR: Added step to parse the product name to the get range PARSE PROD NAME TO GET RANGE 
;                        Addded IF N_ELEMENTS(NUM_TICKS) NE 1 THEN NUM_TICKS  = 10
;   JUL  7, 2014 - JEOR: Added STRUCT_ASSIGN,S,STRUCT,/NOZERO
;   AUG 25, 2015 - KJWH: Changed default log from '0' to 0 in order to avoid errors when checking if KEYWORD_SET(LOG) [IF LOG = '0', THEN KEYWORD_SET(LOG) = 1 INSTEAD OF THE DESIRED 0]
;   APR 06, 2016 - JEOR: Added _RANGE=DOUBLE(RANGE); [FLOAT CORRUPTS SCIENTIFIC NOTATION]
;   SEP 19, 2016 - KJWH: Now looking for range from the last 2 components of the prod name (previously assumed that if the prod had more than one "_" that it had a range)  
;                        Changed the keyword RANGE to PRANGE to avoid conflicts with the function range
;                        Changed the assumption that if the mimimum range was greater than 0.0 that it was logged 
;                          Replaced OK_ZERO = WHERE(_RANGE LE 0,COUNT_ZERO) with if KEY(LOG)
;   SEP 20, 2016 - KJWH: Removed TEST keyword (can use PRODS_VIEW instead)
;                        Added - IF ANY(LOG) THEN IF LOG NE '1' THEN LOG = 0 ; IF LOG='0' CHANGE TO 0  [TO CORRECT AN ERROR WITH LOG TRANSFORMING THE DATA WHEN LOG='0']
;   OCT 18, 2016 - KJWH: Added PROD = VALIDS('PRODS',PROD) and an ERROR message if there is no valid prod to avoid getting stuck in an infinite loop with prods_range   
;   NOV 02, 2016 - KJWH: Updated how the range is parsed from the input prod by looking for numbers as the last two inputs   
;                        Now determining log based on PRODS_READ                
;   NOV 03, 2016 - KJWH: Removed all KEY(LOG) and replace with IF LOG EQ '1'   
;   NOV 12, 2016 - JEOR: Added default IF NONE(LOG) THEN LOG = 0
;                        Added PRODS_2RANGE function and removed code this replaces
;                        Cleaned up examples and keyword documentation
;   FEB 13, 2017 - KJWH: Added IF IDLTYPE(_RANGE) EQ 'STRING' THEN RETURN, [] ; INVALID PROD to jump out of the program if the PROD is invalid  
;   FEB 21, 2017 - KJWH: Added OUTPROD keyword to PRODS_2RANGE and use PRODS_READ of the OUTPROD to determine the LOG if not provided
;   MAR 10, 2017 - JEOR: Fixed bug when outprod is not in PRODS_MAIN
;                        Added IF NONE(LOG)AND COUNT EQ 0 THEN BEGIN
;   AUG 30, 2017 - JEOR: Added PROD = OUTPROD
;                        Added IN_PROD to output structure
;   DEC 21, 2017 - KJWH: Fixed bug when sorting and identifying the UNIQUE ticks
;   JAN 23, 2018 - KJWH: Added STRTRIM to STRTRIM(TICKNAME[NTH],2)
;   MAR 02, 2018 - JEOR: Changed & TICKVS = UNIQUE(ROUNDS(TICKV,6,/SIG)) to TICKVS = UNIQUES(ROUNDS(TICKV,6,/SIG))  [UNIQUES!]
;                        Deleted linE  PROD = OUTPROD
;   MAR 06, 2018 - KJWH: Changed IF IDLTYPE(_RANGE) EQ 'STRING' THEN RETURN, [] ; INVALID PROD 
;                             to IF IDLTYPE(_RANGE) EQ 'STRING' OR _RANGE EQ [] THEN RETURN, [] ; INVALID PROD
;   JUL 11, 2019 - KJWH: Fixed a bug at the end that was overwriting the LOG value so that products such as CHLOR_A_.1_30 are now being returned with LOG=1 
;   DEC 02, 2019 - KJWH: Added step to look at the minimum TICKVS value and adjust the number of decimal places  so that numbers such as 0.0003 are not changed to 0                     
;   MAY 19, 2021 - KJWH: Overhauled the program because there were too many recursive calls to PRODS_READ (and because PRODS_READ calls PRODS_TICKS)
;                        Updated documentation
;                        Added COMPILE_OPT IDL2
;                        Changed subscript () to [] 
;                        Removed PRANGE and TEN keywords as they weren't being used anymore
;                        Moved the PRODS_2RANGE information to PRODS_TICKS to avoid multiple redundant calls to PRODS_READ
;                        Added a COMMON block for the PRODS_MAIN database to avoid multiple redundant calls to PRODS_READ
;   OCT 06, 2021 - KJWH: Changed !S.MASTER to !S.MAINFILES and changes PRODS_MASTER to PRODS_MAIN
;   JAN 12, 2022 - KJWH: Fixed a bug that was incorrectly returning the range of NUM_0.0_0.8 - now change the string values to double before finding the minimum and maximum values
;   NOV 16, 2022 - KJWH: Fixed a bug that was sending a variable increment of 0.0 to INTERVAL. Now if the INCREMENT is 0.0, the TICKV will be 0
;-
; ***************************************************************************************************************************************
  ROUTINE_NAME = 'PRODS_TICKS'
  COMPILE_OPT IDL2
  
; ===> Set up a COMMON memory block for the PRODS_MASTER.CSV
  COMMON _PRODS_DB, PDB, MTIME_LAST
  MAIN = !S.IDL_MAINFILES + 'PRODS_MAIN.csv'
  IF FILE_TEST(MAIN) EQ 0 THEN MESSAGE,'ERROR: Can not find ' + MAIN
  
  IF N_ELEMENTS(MTIME_LAST) NE 1 THEN MTIME_LAST = GET_MTIME(MAIN)
  IF GET_MTIME(MAIN) GT MTIME_LAST THEN INIT = 1
  
; ===> Read PRODS_MAIN.csv if not in COMMON
  IF N_ELEMENTS(PDB) EQ 0 OR KEYWORD_SET(INIT) THEN BEGIN
    PDB = CSV_READ(MAIN,/STRING)
    MTIME_LAST = GET_MTIME(MAIN)
  ENDIF
  NAMES = PDB.PROD

; ===> Set up defaults
  IF N_ELEMENTS(PROD) NE 1       THEN MESSAGE,'ERROR: Must provide an input product name'
  IF PROD EQ ''                  THEN MESSAGE,'ERROR: MUST PROVIDE VALID PROD'
  IF N_ELEMENTS(NUM_TICKS) EQ 0  THEN NUM_TICKS = 10
  IF N_ELEMENTS(CB_RANGE) EQ 2   THEN _CB_RANGE = CB_RANGE ELSE _CB_RANGE = [1,250]
  IN_PROD = PROD
  
; ===> Look for the algorithm in the prod name. If '-' is present and T[1] is a VALID ALG, then remove it from the prod name
  ALG = []
  T = STR_SEP(PROD,'-')                                          ; Parse the input product  name
  IF N_ELEMENTS(T) GT 1 THEN IF NUMBER(T[1]) EQ 0 THEN BEGIN     ; If T[1] is not a number then look for the algorithm name
    IF VALIDS('ALGS',T[1]) THEN ALG = T[1] ELSE BEGIN            ; IF T[1] is not a VALID ALG then parse further to look for the algorithm name
      A = STR_SEP(T[1],'_')                                      ; Parse the name based on underscores
      A = A[WHERE(A NE '')]                                      ; Remove any trailing blanks
      IF N_ELEMENTS(A) GE 3 THEN A = GET(A,NUM=N_ELEMENTS(A)-2)  ; Remove any numbers representing the range (note, it is expected that an alg will have no more than 1 underscore)
      ALG = STRJOIN(A,'_')                                       ; Join the alg back together
      IF VALIDS('ALGS',ALG) EQ '' THEN ALG = []                  ; Validate the alg
    ENDELSE
    IF ALG NE [] THEN PROD = REPLACE(PROD,'-'+ALG,'')            ; Remove the alg from the input product name
  ENDIF;IF NOF(T) EQ 2 THEN BEGIN

; ===> Extract the RANGE from the 
  OK = WHERE(PDB.PROD EQ PROD,COUNT)                             ; Look for the PROD in the main database
  OUTPROD = [] & RNGE = []
  CASE COUNT OF
    1: BEGIN
      RNGE = DOUBLE([PDB[OK].LOWER,PDB[OK].UPPER])               ; If a match is found, then set the LOWER and UPPER range
      OUTPROD = PDB[OK].PROD
      PDBOUT = PDB[OK]
    END
    0: BEGIN                                                     ; If no match is found, parse the input product name to find the range
      T = STR_SEP(PROD,'_')                                      ; Parse the input product name by '_'
      RNGE = GET(T,NUM=2,/LAST)                                  ; Get the last two "values" of the name
      IF TOTAL(IS_NUM(RNGE)) NE 2 THEN RNGE = [] $               ; If the last two values are not numbers, then make the range null
        ELSE BEGIN
          RNGE = DOUBLE([MIN(DOUBLE(RNGE)),MAX(DOUBLE(RNGE))])   ; If both values are numbers, then set up the range based on the MIN and MAX values
          OUTPROD = STRJOIN(GET(T,NUM=N_ELEMENTS(T)-2),'_')
          OK = WHERE(PDB.PROD EQ OUTPROD,COUNT)                             ; Look for the PROD in the main database
          IF COUNT EQ 1 THEN PDBOUT = PDB[OK] ELSE PDBOUT = []
        ENDELSE  
    END
  ENDCASE
  
  IF OUTPROD EQ [] OR IDLTYPE(RNGE) EQ 'STRING' OR RNGE EQ [] THEN RETURN, [] ; If the product and/or  could not be parsed from the input information, then return NULL

; ===> Determine if the product is a "LOG" product
  OK = WHERE(NAMES EQ OUTPROD,COUNT)
  IF COUNT EQ 1 THEN LG = FIX(PDB[OK].LOG) ELSE LG = 0 
  IF KEYWORD_SET(LOG) THEN LG = LOG                               ; Overwrite the default LOG status if the keyword is provided
  IF KEYWORD_SET(LG) AND RNGE[0] LE 0.0 THEN MESSAGE, 'ERROR: For logged scales, the mimimum must be greater than 0.0'
  
; ===> "Scale" the range to the color bar range (CB_RANGE)   
  IF KEYWORD_SET(LG) THEN RANGE_SCALED = 10^SCALE(_CB_RANGE,ALOG10(RNGE),INTERCEPT=INTERCEPT,SLOPE=SLOPE) $
                     ELSE RANGE_SCALED = SCALE(_CB_RANGE, RNGE,INTERCEPT=INTERCEPT,SLOPE=SLOPE)
  
; ===> Determine the TICK values  
  IF KEYWORD_SET(LG) THEN BEGIN
    MIN_MAX_LOG =([FLOOR(ALOG10(RNGE[0])),CEIL(ALOG10(RNGE[1]))])
    IF SPAN(MIN_MAX_LOG) EQ 1 THEN BEGIN
      IF MAX(MIN_MAX_LOG) GE 6 THEN  TICKV =INTERVAL(RNGE,1) ELSE TICKV =INTERVAL(RNGE,0.1)
    ENDIF ELSE TICKV = DOUBLE(DECADES(MIN_MAX_LOG,/HALF))  
  ENDIF ELSE BEGIN ; IF LOG EQ 1
    INCREMENT = SPAN(RNGE)/NUM_TICKS 
    IF INCREMENT GT 0 THEN TICKV = INTERVAL(RNGE,INCREMENT) ELSE TICKV = 0.0
    OK = WHERE(ROUNDS(TICKV,3) EQ 0.0,COUNT)
    IF COUNT EQ 1 THEN TICKV[OK] = 0.0
  ENDELSE;IF LOG EQ 1
       
; ===> Clean up the TICKVs
  OK = WHERE(TICKV GE RNGE[0] AND TICKV LE RNGE[1],COUNT_TICKS)
  IF COUNT_TICKS GE 1 THEN TICKV = DOUBLE(TICKV[OK])
  WHILE COUNT_TICKS GT NUM_TICKS DO BEGIN                                     ; Narrow down TICKV if there are too many 
    TICKV = SUBSAMPLE(TICKV,2) 
    COUNT_TICKS = N_ELEMENTS(TICKV)
  ENDWHILE

  OK = WHERE(DOUBLE(TICKV) LT RNGE[0] OR DOUBLE(TICKV) GT RNGE[1],COUNT)      ; Find TICKVs outside of the range
  IF COUNT GE 1 THEN TICKV = REMOVE(TICKV,OK)                                 ; Remove TICKVs below and above the range 
  TICKV = [RNGE[0],TICKV,RNGE[1]]                                             ; Ensure that lower and upper range are represented
  IF COUNT_TICKS LE N_ELEMENTS(TICKV) THEN TICKV= [TICKV,TICKV[-1]]           ; If number of TICKVS LT TICKV then add back highest TICKV to TICKVS
  TICKV = TICKV[SORT(TICKV)] & TICKVS = UNIQUES(ROUNDS(TICKV,6,/SIG))         ; Sort and remove and duplicate TICKVs

; ===> Determine the number of digits to trim the ticknames to
  DIGITS = 3
  IF MIN(TICKVS) LT 0.001 THEN DIGITS = 4
  IF MIN(TICKVS) LT 0.0001 THEN DIGITS = 5
  IF MIN(TICKVS) LT 0.00001 THEN DIGITS = 6
  TICKNAME =STR_ZERO_TRIM(ROUNDS(TICKVS,DIGITS,/SIG),TRIM=3)                  ; Round to 3 places and trim tickvs to make legible ticknames for the color bar
  TICKS = FIX(N_ELEMENTS(TICKVS) -1)                                          ; Number of ticks
  
; ===> Create the output structure  
  S = CREATE_STRUCT('IN_PROD',IN_PROD,'PROD',OUTPROD,$
                    'LOWER',RNGE[0],$
                    'UPPER',RNGE[1],$
                    'C_LO',_CB_RANGE[0],$
                    'C_HI',_CB_RANGE[1],$                      
                    'TICKS',TICKS,$
                    'TICKV',TICKVS,$
                    'TICKNAME',TICKNAME)
  
  IF PDBOUT NE [] THEN S = STRUCT_MERGE(STRUCT_COPY(PDBOUT,['LOWER','UPPER','LOG'],/REMOVE),STRUCT_COPY(S,'PROD',/REMOVE))

; ===> Add each element of tickname to struct 
  FOR NTH=0, NUM_TICKS-1 DO BEGIN
    IF NTH LE TICKS THEN VAL = STRTRIM(TICKNAME[NTH],2) ELSE VAL = ''
    NAME = 'T' + STRTRIM(NTH,2)
    S  = CREATE_STRUCT(S,NAME,VAL)
  ENDFOR

;===> Add LOG, INTERCEPT, SLOPE to the structure so they are in the right sequence
  S = CREATE_STRUCT(S,'LOG',NUM2STR(LG),'INTERCEPT',STRTRIM(INTERCEPT,2),'SLOPE',STRTRIM(SLOPE,2))
  RETURN, S

END; #####################  END OF ROUTINE ################################
