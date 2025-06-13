; $ID:	UNITS.PRO,	2022-03-21-16,	USER-KJWH	$
;#############################################################################################
	FUNCTION UNITS, PROD, NO_PAREN=NO_PAREN, NO_UNIT=NO_UNIT, NO_NAME=NO_NAME, STACK=STACK, NAMES=NAMES, STRUCT=STRUCT, INIT=INIT, SI=SI
;+
; NAME: 
;   UNITS
;
; PURPOSE: 
;   This function generates a name and units for various scientific data types
;
; CATEGORY:
;		PRODUCT FUNCTIONS
;
; CALLING SEQUENCE:
;		RESULT = UNITS(PROD)
;
; REQUIRED INPUTS:
;		PROD............. The name of the input product 
;
; OPTIONAL INPUTS:
;   None
; 
; KEYWORD PARAMETERS:
;		NO_PAREN..........Do not enclose the units part of the returned text string in parentheses
;		NO_UNIT.......... Do not return the units
;		NO_NAME..........	Do not return the name
;		STACK............	Return a string with a '!C' separating the name from the units so that IDL will plot it on 2 lines
;   NAMES............ Return names of all the units
;   STRUCT........... Returns a structure with prod, name and unit
;   INIT............. Re-reads the units master
;   SCI.............. Return scientific units from the units master
; 
; OUTPUTS:
;		A string with the standardized name and units
;
; OPTIONAL OUTPUTS:
;   None
;
; COMMON BLOCKS:
;   _READ_UNITS...... Stores the information from the UNITS master file
;
; SIDE EFFECTS:
;   None
;
; RESTRICTIONS:
;		Only works for valid product names found in PRODS_MASTER
;
; EXAMPLES:
;    PLIST,UNITS(/NAMES)
;    PRINT,UNITS('SST')
;    PRINT,UNITS('SST',/NO_NAME)
;    PRINT,UNITS('SST',/NO_UNIT)
;    PRINT,UNITS('SST',/NO_PAREN)
;    PRINT,UNITS('SST',/STACK)
;    PLIST,UNITS(['CHLOR_A','SST','PAR'])
;    PLIST,UNITS(['CHLOR_A','SST','PAR'],/NO_UNIT)
;    PLIST,UNITS(['CHLOR_A','SST','PAR'],/NO_NAME)
;    PRINT, UNITS('PPD') 
;    ST, UNITS('PPD',/STRUCT) 
;    PRINT, UNITS('PPD',/SI)
;    PRINT, UNITS('SST',/SI) 
;
; NOTES:
;
;
; COPYRIGHT:
; Copyright (C) 1995, Department of Commerce, National Oceanic and Atmospheric Administration, National Marine Fisheries Service,
;   Northeast Fisheries Science Center, Narragansett Laboratory.
;   This software may be used, copied, or redistributed as long as it is not sold and this copyright notice is reproduced on each copy made.
;   This routine is provided AS IS without any express or implied warranties whatsoever.
;
; AUTHOR:
;   This program was written on Januar 3, 1995 by John E. O'Reilly, Northeast Fisheries Science Center | NOAA Fisheries | U.S. Department of Commerce, 28 Tarzwell Dr, Narragansett, RI 02882
;   Inquiries should be directed to kimberly.hyde@noaa.gov.
;    
; MODIFICATION HISTORY:
;	  JAN 03, 1995 - JEOR: Initial code written
;   AUG 07, 2001 - TD:   Added more CZCS products
;   APR 23, 2002 - TD:   Added SEAWIFS flags
;   NOV 07, 2002 - TD:   PAR > EIN ; Added EINS (EINSTEINS PER SEC).
;   JAN 15, 2003 - TD:   Added keyword STACK
;	  APR 13, 2002 - JEOR: Added OK = WHERE(STRPOS(LABELS,'()') GE 0,COUNT) 
;	                       Added IF COUNT GE 1 THEN LABELS[OK] = ''
;	  JUL 14, 2003 - TD:   Change label for PNEG from % to PROBABILITY
;	  AUG 10, 2004 - TD:   Changed all !E to !U
;	  JUL 10, 2006 - JEOR: Added DOC 
;	  JAN 02, 2014 - JEOR: Added CHEMTAX names 'DAY_LENGTH' and 'AZIMUTH'
;	                       Fiexed 'NLW_750', 'RRS_531','RRS_555','RRS_550','TCHLA','FLH'
;	  JAN 03, 2014 - JEOR: Changed TXT = TO _UNITS = TO MAKE THE UNITS VARIABLE MORE MEANINGFUL
;   JAN 04, 2014 - JEOR: Added all LNP PRODS:['LNP_006CPY','LNP_012CPY','LNP_025CPY','LNP_050CPY','LNP_075CPY','LNP_1CPY','LNP_2CPY','LNP_3CPY','LNP_4CPY','LNP_5CPY','LNP_FAP','LNP_JMAX_CPY','LNP_MAX_PEAK','LNP_DAN_PEAK']
;                        Changed uppercase first letters of each word in aname [unless aname is three letters]
;                        Added IF ANAME NE '' AND STRLEN(ANAME) GT 3 THEN ANAME =STR_CAP(REPLACE(ANAME,'_',' '),/ALL) ; ===> MAKE NAME UPPERCASE: NAME = STRUPCASE(NAME)
;                        Fixed name for 'CELSIUS','LA_670','LOG10'[NO UNITS SINCE IT DEPENDS ON THE DATA TYPE]
;                        Fixed 'CHLL' 'CV', 'DEPTH','EMS','EPS34','ES','E0','GRAD_DIR','GRAD_MAG','JD','LA_670'
;                        Removed LOG7 
;                        Fixed 'PHYSAT_PROCHL'  
;                        Removed POC_STRAMSKI,POC_CLARK changed to STRMID(DATUM,0,3) EQ 'POC'
;                        Fixed  CLOUDRING  
;                        Note SLOPE [S] still needs work
;   JAN 05, 2014 - JEOR: Fixed the sclaling of 'CHLC' 
;   JAN 23, 2013 - JEOR: Added keyword STRUCT 
;                          IF PROD NOT FOUND THEN RETURN ''
;                          IF COUNT EQ 0 THEN RETURN,''
;                          OK = WHERE_MATCH(STRUPCASE(DB.PROD) , STRUPCASE(PROD),COUNT)
;   MAY  2, 2014 - JEOR: Added keyword INIT  
;   MAY 29, 2014 - JEOR: Added MTIME_LAST to COMMON 
;   OCT 20, 2015 - KJWH: Added NAME=VALIDS('PRODS',NAME) in case the input include the alg in the name
;   OCT 21, 2015 - JEOR: Changed VALID_PRODS to VALIDS
;                        Removed OLD keyword and all of the old code
;   AUG 29, 2016 - KJWH: Made is so that you can return units with no names and no parentheses
;   FEB 17, 2016 - KJHW: Removed IF N_ELEMENTS(NAME) GE 1 THEN PROD = VALIDS('PRODS',NAME) so that products such as 'CHLOROPHYLL' will work
;                        Changed "PROD" to "NAME"
;                        Updated formatting
;   AUG 18, 2018 - JEOR: Added tags 'SI' to UNITS_MASTER and new keyword 'SI' to this routine
;   OCT 18, 2018 - KJWH: Added VALIDS('PRODS',STRUPCASE(NAME)), which will remove the ALG if provided with the product name
;   FEB 13, 2020 - KJWH: If no match is found with the VALIDS('PRODS',NAME) then just look for a matching name. 
;   SEP 20, 2021 - KJWH: Changed !S.MASTER to !S.IDL_MAINFILES
;                        Updated documentation & formatting
;                        Added COMPILE_OPT IDL2
;                        Changed subscript () to []
;                        Moved to PRODUCT functions  
;                        Changed MAIN to MASTER
;-
; ***************************************************************************************************************
  ROUTINE = 'UNITS'
  COMMON _READ_UNITS,DB,MTIME_LAST
  
  MAIN = !S.IDL_MAINFILES + 'PRODS_MAIN.csv' 
  IF NONE(MTIME_LAST) THEN MTIME_LAST = GET_MTIME(MAIN)
  IF GET_MTIME(MAIN) GT  MTIME_LAST THEN  INIT = 1 
  IF FILE_TEST(MAIN) EQ 0 THEN MESSAGE,'ERROR: CAN NOT FIND  ' + MAIN 
    
  IF N_ELEMENTS(DB) EQ 0 OR KEY(INIT) THEN BEGIN
    DB = CSV_READ(MAIN)
    MTIME_LAST = GET_MTIME(MAIN)
    OK = WHERE(DB.PLOT_TITLE EQ '',COUNT)
    IF COUNT GT 0 THEN DB[OK].PLOT_TITLE = DB[OK].PROD
  ENDIF ; IF N_ELEMENTS(DB) EQ 0 OR KEY(INIT) THEN BEGIN
    
  IF KEYWORD_SET(NAMES) THEN RETURN,DB.PLOT_TITLE  
  IF N_ELEMENTS(PROD) EQ 0 THEN RETURN,DB.PLOT_TITLE + DB.PLOT_UNITS 
     
  OK = WHERE_MATCH(STRUPCASE(DB.PROD), VALIDS('PRODS',STRUPCASE(PROD)),COUNT)
  IF COUNT EQ 0 THEN OK = WHERE_MATCH(STRUPCASE(DB.PROD),STRUPCASE(PROD),COUNT)
  IF COUNT EQ 0 THEN RETURN, ''
  IF KEYWORD_SET(SI) THEN RETURN,DB[OK].UNITS
  IF KEYWORD_SET(STRUCT) THEN RETURN,DB[OK]
  
  IF KEYWORD_SET(NO_PAREN) THEN UN = REPLACE(DB[OK].PLOT_UNITS,['(',')'],['','']) ELSE UN = DB[OK].PLOT_UNITS
  NAME = DB[OK].PLOT_TITLE
  IF KEYWORD_SET(NO_NAME) THEN RETURN,UN
  IF KEYWORD_SET(NO_UNIT) THEN RETURN,NAME
  IF KEYWORD_SET(STACK)   THEN RETURN,NAME + '!C'+ UN
  RETURN, NAME + ' ' + UN
  
  
END; #####################  END OF ROUTINE ################################

