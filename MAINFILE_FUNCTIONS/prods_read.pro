; $ID:	PRODS_READ.PRO,	2023-09-21-13,	USER-KJWH	$

	FUNCTION PRODS_READ, PRODS, NAMES=NAMES, INIT=INIT, LOG=LOG

;+
; NAME:
;		PRODS_READ
;
; PURPOSE: 
;   This function reads PRODS_MAIN.csv and returns information on the "valid" products  
;
; CATEGORY: 
;   PRODUCT functions
;
; CALLING SEQUENCE:
;   RESULT = PRODS_READ()
;
; REQUIRED INPUTS:
;		None
;		
; OPTIONAL INPUTS:
;		PRODS........... The name(s) of any products found in PROD_MAIN.csv   
;		
; KEYWORD PARAMETERS:
;   NAMES........... Return the names of all of the products
;   INIT............ Replaces the main product database stored in COMMON
;
; OUTPUTS: 
;   A structure with the product information about the specified products
;	
; OPTIONAL OUTPUTS
;   Depends on the input keywords and products
; 
; COMMON BLOCKS:
;   COMMON _PRODS_READ,DB,MTIME_LAST.... Contains the information found in PRODS_MAIN.csv
;
; SIDE EFFECTS:
;   Can get hung up in the repeated calls to PRODS_TICKS
;
; RESTRICTIONS:
;   Depends on several related programs
;		
; EXAMPLES:
;   PRINT, PRODS_READ(/NAMES) ; Returns all of the product names 
;   ST, PRODS_READ()          ; Returns a structure with all of the product information 
;   ST, PRODS_READ('PAR')     ; Returns a structure with the information for the specified product (e.g. PAR) 
;   ST, PRODS_READ(['SST','CHLOR_A','PAR']) ; Returns a structure with information for the specified products (e.g. SST, CHLOR_A, PAR)
;   PRINT, PRODS_READ('TEST') ; Returns !NULL because the product is not in PRODS_MAIN.csv
;   ST, PRODS_READ('SST_0_10') ; Returns a structure with updated tick ranges based on the input range (0_10)
;   ST, PRODS_READ('JUNK_1_10') ; Returns a structure with the tick ranges even though 'JUNK' is not a valid product
;   SPREAD, PRODS_READ(['PAR','JUNK','SST','JUNK_1_10','JUNK_1_5','CHLOR_A']) ; Returns a structure with the products, including products not found in PRODS_MAIN.csv
;
;	NOTES:
;
; COPYRIGHT:
; Copyright (C) 2013, Department of Commerce, National Oceanic and Atmospheric Administration, National Marine Fisheries Service,
;   Northeast Fisheries Science Center, Narragansett Laboratory.
;   This software may be used, copied, or redistributed as long as it is not sold and this copyright notice is reproduced on each copy made.
;   This routine is provided AS IS without any express or implied warranties whatsoever.
;
; AUTHOR:
;   This program was written on October 10, 2013 by John E. O'Reilly, Northeast Fisheries Science Center | NOAA Fisheries | U.S. Department of Commerce, 28 Tarzwell Dr, Narragansett, RI 02882
;     Inquires regarding this program should be directed to Kimberly.hyde@noaa.gov
;
; MODIFICATION HISTORY:
;	  OCT 10, 2013 - JEOR: Inital code written
;		OCT 15, 2013 - JEOR: Renamed to PRODS_READ
;		NOV 04, 2013 - JEOR: Added SAVEFILE = GET_PATH() + 'IDL\DB\PROD_DATA_MAIN_DB.SAVE'
;                         Replaced WHERE_IN with WHERE_MATCH to keep output order in sync with input order
;   NOV 05, 2013 - JEOR: Added SAVEFILE = !S.DB + 'PROD_DATA_MAIN_DB.SAVE'
;   NOV 06, 2013 - JEOR: Added keyword names
;   NOV 19, 2013 - JEOR: Added PRODS = STRUPCASE(PRODS)
;   DEC 08, 2013 - JEOR: Renamed to PRODS_READ
;   DEC 28, 2013 - JEOR: Added keyword INIT
;   JAN 11, 2014 - JEOR: Added IF PROD NOT FOUND RETURN ERROR STRING
;   JAN 15, 2014 - JEOR: Added more examples
;   APR 29, 2014 - JEOR: Added RETURN,!NULL when an error is found
;   MAY 26, 2014 - JEOR: Major improvement: 
;                          Added IF PROD NOT IN MAIN THEN 
;                          Added IF COUNT_PROD EQ 0 THEN RETURN,PRODS_TICKS(PRODS)
;   MAY 29, 2014 - JEOR: Added MTIME_LAST to the common block 
;   NOV 12, 2016 - JEOR: Added recursive call to PRODS_READ to handle mixtures of PRODS and PRODS_RANGE text
;                        Modified IF N_ELEMENTS(STR_SEP(PRODS,'_')) GT 4 THEN RETURN, !NULL to handle prods with underscores [e.g. GRAD_SST]                        
;   FEB 16, 2017 - KJWH: Attemped to fix bug of getting stuck in an infinite loop when an invalid prod is used - STILL NEEDS TO BE FIXED!!!
;                        Updated formatting
;   FEB 16, 2017 - KJWH: Tested 2 new examples 
;                          S=PRODS_READ('CHLOR_A-OCI') ; So that it works with the algorithm attached
;                          S=PRODS_READ('CHL')
;   DEC 19, 2017 - KJWH: Added CREATE_STRUCT('INPROD',DB(OK_PROD).PROD,DB(OK_PROD)) so that the output structure is consistent with the structure returned by PRODS_TICKS                     
;   MAR 02, 2018 - JEOR: Added LOG=DB(OK_PROD).LOG to return the LOG keyword when it is not found in the DB and PRODS_TICKS is not called
;   APR 10, 2019 - KJWH: Added steps to return a blank structure if the input prod name is blank ('')  
;                         * Uses PRODS_STRUCT() to create a blank structure
;   SEP 04, 2020 - KJWH: Changed OK_PROD = WHERE_MATCH(DB.PROD,PRODS,COUNT_PROD) to OK_PROD = WHERE_MATCH(DB.PROD,VALIDS('PRODS',PRODS),COUNT_PROD) to account for prods with algorithms (e.g. CHLOR_A-OCI)             
;   MAY 17, 2021 - KJWH: Updated formatting and documentation
;                        Added COMPILE_OPT IDL2
;                        Changed subscript () to []
;                        Working on BUG when calling R = PRODS_READ('GRADX_SST') - it is getting caught in an infinite loop
;   SEP 21, 2021 - KJWH: Changed !S.MAIN to !S.IDL_MAINFILES
;   DEC 07, 2022 - KJWH: Added IF VALIDS('PRODS',PRODS) EQ '' THEN RETURN, PRODS_STRUCT() for when the PROD is not recognized in the DB
;-
;************************************************************************************************************************************
  ROUTINE_NAME  = 'PRODS_READ'
  COMPILE_OPT IDL2
  
; ===> Set up a COMMON memory block for the PRODS_MASTER.CSV  
  COMMON _PRODS_READ, DB, MTIME_LAST
  MAIN = !S.IDL_MAINFILES + 'PRODS_MAIN.csv'
  IF FILE_TEST(MAIN) EQ 0 THEN MESSAGE,'ERROR: Can not find ' + MAIN
  
  IF NONE(MTIME_LAST) THEN MTIME_LAST = GET_MTIME(MAIN)
  IF GET_MTIME(MAIN) GT MTIME_LAST THEN INIT = 1 
    
; ===> Read PRODS_MAIN.csv if not in COMMON  
  IF N_ELEMENTS(DB) EQ 0 OR KEYWORD_SET(INIT) THEN BEGIN
    DB = CSV_READ(MAIN,/STRING)
    MTIME_LAST = GET_MTIME(MAIN)
  ENDIF
   
  IF KEYWORD_SET(NAMES) THEN RETURN,DB.PROD   ; Return a list of product names
  IF N_ELEMENTS(PRODS) EQ 0 THEN RETURN,DB    ; Return the entire PRODS_MAIN structure
  
  PRODS = STRUPCASE(STRTRIM(PRODS,2))

; ===> Recursive calls to prods_read for multiple prods and/or multiple prods plus range text
  IF N_ELEMENTS(PRODS) GE 2 AND N_ELEMENTS(PRODS) LT N_ELEMENTS(DB) THEN BEGIN
    FOR I = 0,NOF(PRODS)-1 DO BEGIN  
      D = PRODS_READ(PRODS[I])                                                  ; Call PRODS_READ for the specific product requested (PRODS[I])
      COPY = PRODS_STRUCT()
      IF D EQ [] THEN COPY.PROD = PRODS[I] ELSE STRUCT_ASSIGN,D,COPY,/NOZERO
      IF NONE(DBS) THEN DBS = COPY ELSE DBS = [DBS,COPY]                        ; Join databaset structures
    ENDFOR;FOR I = 0,NOF(PRODS)-1 DO BEGIN
    RETURN,DBS
  ENDIF;IF NOF(PRODS) GE 2 AND NOF(PRODS) LT NOF(DB) THEN BEGIN

; ===> ?
;  OK_PROD = WHERE_MATCH(DB.PROD,VALIDS('PRODS',PRODS),COUNT_PROD)
;  IF COUNT_PROD EQ 0 THEN BEGIN
    IF PRODS EQ '' THEN RETURN, PRODS_STRUCT() ;===> If PROD is blank then return a blank structure
    IF N_ELEMENTS(STR_SEP(PRODS,'_')) GT 4 THEN RETURN, PRODS_STRUCT()  ;===> If RANGE is not found encoded in PRODS then return a blank structure
    RETURN,PRODS_TICKS(PRODS,LOG=LOG)
;  ENDIF
  LOG = DB[OK_PROD].LOG
   
  IF COUNT_PROD GE 1 THEN RETURN, CREATE_STRUCT('IN_PROD',DB[OK_PROD].PROD,DB[OK_PROD])
  DONE:          
END; #####################  END OF ROUTINE ################################
