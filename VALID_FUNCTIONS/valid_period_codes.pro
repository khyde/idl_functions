; $ID:	VALID_PERIOD_CODES.PRO,	2022-03-21-16,	USER-KJWH	$
FUNCTION VALID_PERIOD_CODES, INFO, VALID=VALID, STRUCT=STRUCT
;+
; NAME:
;   VALID_PERIOD_CODES
;   
; PURPOSE:  
;   This function checks that the period code is "valid" returns information about the periods 
;
; CATEGORY:
;   PERIOD_FUNCTIONS
; 
; REQUIRED INPUTS:
;   None
;
; OPTIONAL INPUTS:
;   INFO............. The input period
; 
; KEYWORD PARAMETERS:
;   VALID............ Return just the valid information about the period code
;   STRUCT........... Return a structure with the period code information
;   INIT............. Forces a rereading of the PERIODS_MAIN
;   
; OUTPUTS:
;   The "valid" period codes from the input INFO
; 
; OPTIONAL OUTPUTS:
;   A 1 or 0 if the period code is "valid"
;   A structure with additional period code information
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
;   ST, VALID_PERIOD_CODES('M')
;   PRINT, VALID_PERIOD_CODES('M')
;   PRINT, VALID_PERIOD_CODES('M',/VALID)
;
; NOTES:
;
;
; COPYRIGHT:
; Copyright (C) 2003, Department of Commerce, National Oceanic and Atmospheric Administration, National Marine Fisheries Service,
;   Northeast Fisheries Science Center, Narragansett Laboratory.
;   This software may be used, copied, or redistributed as long as it is not sold and this copyright notice is reproduced on each copy made.
;   This routine is provided AS IS without any express or implied warranties whatsoever.
;
; AUTHOR INFORMATION
;   This program was written June 18, 2003 by John E. O'Reilly, Northeast Fisheries Science Center | NOAA Fisheries | U.S. Department of Commerce, 28 Tarzwell Dr, Narragansett, RI 02882
;     Inquires about this program should be directed to kimberly.hyde@noaa.gov
;
; MODIFICATION HISTORY:
;
; HISTORY:
;   JUN 18, 2003 - JEOR: Initial code written
;   FEB 11, 2014 - JEOR: Removed keyword and code related to old_parser, formatting
;   JUN 25, 2014 - JEOR: Revised month period from 'MONTH_199601_200101' to 'MONTH_01_1996_2001'
;   JUN 26, 2014 - JEOR: Added code for minute ['T'] which was missing:
;                          SINGLE_PERIOD_CODES = ['Y','M','W','D','H','T','S','A']
;   MAR 07, 2017 - KJWH: Added 'THIRD_LEN' output for periods such as DOY (DOY_001_1998_2016), WEEK (WEEK_01_1998_2016) and MONTH (MONTH_01_1998_2016) 
;   FEB 13, 2019 - KJWH: Added 'FOURTH_LEN' output for MONTH3 period
;   APR 09, 2019 - KJWH: Removed MONTH3 from the DOUBLE period codes group
;   JAN 30, 2021 - KJWH: Updated documentation and formatting
;                        Added COMPILE_OPT IDL2
;                        Changed subscript () to []
;                        Added AA and WW periods
;   AUG 09, 2021 - KJWH: Updated documentation
;                        Moved to PERIOD FUNCTIONS
;                        Added DD3 and DD8 period codes
;   SEP 22, 2021 - KJWH: Overhauled the program
;                          Now using PERIODS_MAIN.csv to get the details on the period codes
;                          Removed the period specific information in the code
;                          Updated how the period information is parsed from the input INFO
;                          Added keyword STRUCT to return the period code structure
;                          The default is to return an array with the valid period codes 
;   SEP 28, 2021 - KJWH: Fixed a couple of typo bugs      
;   DEC 20, 2022 - KJWH: Fixed bugs for when non-period code inputs were provided                                      
;     
;-
; ***********************************************************************************************************************
  ROUTINE_NAME='VALID_PERIOD_CODES'
  COMPILE_OPT IDL2

  COMMON _VALID_PERIOD_CODES, PERSTR, MTIME_LAST, REINIT

  IF ~N_ELEMENTS(REINIT) THEN REINIT = 1
  MAIN = !S.IDL_MAINFILES + 'PERIODS_MAIN.csv'
  
  IF ~N_ELEMENTS(MTIME_LAST) THEN MTIME_LAST = GET_MTIME(MAIN)
  IF GET_MTIME(MAIN) GT  MTIME_LAST THEN INIT = 1
  
; ===> Read the MAIN files  
  IF ~N_ELEMENTS(PERSTR) OR KEYWORD_SET(INIT) OR REINIT EQ 1 THEN BEGIN
    PERSTR = CSV_READ(MAIN)
    MTIME_LAST = GET_MTIME(MAIN)
    REINIT = 0
  ENDIF

  MAIN_CODES = PERSTR.PERIOD_CODE                                   ; "VALID" period codes
  IF N_ELEMENTS(INFO) EQ 0 THEN BEGIN
    IF KEYWORD_SET(STRUCT) THEN RETURN, PERSTR                      ; Return the complete main period structure
    RETURN, MAIN_CODES                                              ; Return all period code if INFO not provided
  ENDIF

  CODEOUT = STRARR(N_ELEMENTS(INFO))                                ; Create a blank string array
  BVALID  = BYTARR(N_ELEMENTS(INFO))                                ; Create blank byte array
 
; ===> Parse out the period code from the input INFO  
  INFOSPLT = STR_BREAK(INFO,'_')
  INFOCODE = INFOSPLT[*,0]
    
; ===> Find the matching period codes
  OK = WHERE_MATCH(MAIN_CODES,INFOCODE,VALID=VAL,COMPLEMENT=COMP,COUNT)
  
; ===> Return information based on the keywords
  IF COUNT GT 0 THEN BEGIN
    BVALID[VAL] = 1
    CODEOUT[VAL] = INFOCODE[VAL]
    IF KEYWORD_SET(VALID)  THEN RETURN, BVALID
    IF N_ELEMENTS(WHERE_MATCH(PERSTR[OK].PERIOD_CODE,INFOCODE[VAL])) NE N_ELEMENTS(VAL) THEN MESSAGE, 'ERROR: Input and MAIN period codes do not match.'
    IF KEYWORD_SET(STRUCT) THEN RETURN, CREATE_STRUCT(PERSTR[OK],'PC_LENGTH',FIX(STRLEN(INFOCODE[VAL])))
    RETURN, CODEOUT
  ENDIF
    
; ===> If not matches were found, then return the list of valid period codes  
  IF KEYWORD_SET(VALID)  THEN RETURN, BVALID
  RETURN, CODEOUT


END ; ***************** End of VALID_PERIOD_CODES *****************
