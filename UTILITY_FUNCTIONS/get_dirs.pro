; $ID:	GET_DIRS.PRO,	2022-05-05-11,	USER-KJWH	$
  FUNCTION GET_DIRS, DIR, SEARCH_STRING=SEARCH_STRING

;+
; NAME:
;   GET_DIRS
;
; PURPOSE:
;   Get the directories in specific location
;
; CATEGORY:
;   UTILITY_FUNCTIONS
;
; CALLING SEQUENCE:
;   Result = GET_DIRS()
;
; REQUIRED INPUTS:
;   None
;
; OPTIONAL INPUTS:
;   DIR............ The location of the directory to search in
;   SEARCH_STRING.. Text to include when searching for specific directories
;
; KEYWORD PARAMETERS:
;   None
;
; OUTPUTS:
;   An array of directories
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
;   PRINT, GET_DIRS()  ; Will print all directories in the Current Directory"
;   PRINT, GET_DIRS(SEARCH_STRING='IDL') ; Will print all directories in the Current Directory with IDL in the name
;   PRINT, GET_DIRS(!S.IDL) ; Will print all directories in the !S.IDL directory
;   PRINT, GET_DIRS(!S.IDL, SEARCH_STRING='IDL') ; Will print all directories within !S.IDL that have IDL in the name
; 
;
; NOTES:
;   Linux and Mac OS have slightly different syntax to get the list of directories
;   
; COPYRIGHT: 
; Copyright (C) 2022, Department of Commerce, National Oceanic and Atmospheric Administration, National Marine Fisheries Service,
;   Northeast Fisheries Science Center, Narragansett Laboratory.
;   This software may be used, copied, or redistributed as long as it is not sold and this copyright notice is reproduced on each copy made.
;   This routine is provided AS IS without any express or implied warranties whatsoever.
;
; AUTHOR:
;   This program was written on May 04, 2022 by Kimberly J. W. Hyde, Northeast Fisheries Science Center | NOAA Fisheries | U.S. Department of Commerce, 28 Tarzwell Dr, Narragansett, RI 02882
;    
; MODIFICATION HISTORY:
;   May 04, 2022 - KJWH: Initial code written
;   Sep 21, 2023 - KJWH: Added option for Windows machine
;-
; ****************************************************************************************************
  ROUTINE_NAME = 'GET_DIRS'
  COMPILE_OPT IDL2
  SL = PATH_SEP()
  
  IF N_ELEMENTS(SEARCH_STRING) EQ 0 THEN STR = '' ELSE STR = SEARCH_STRING
  CASE STRUPCASE(!VERSION.OS_NAME) OF
    'MAC OS X': SPAWNDIRS = 'ls -d -- ' + STR + '*/'
    'MICROSOFT WINDOWS': SPAWNDIERS = [] ; 'dir -d ' + STR + '*/'
    ELSE: SPAWNDIRS = 'ls ' + STR + '*/ -d'
  ENDCASE  
  CD, CURRENT=CDIR
  IF N_ELEMENTS(DIR) EQ 1 THEN CD, DIR ELSE DIR = CDIR

  IF SPAWNDIRS NE [] THEN BEGIN
    SPAWN, SPAWNDIRS, DIRS, ERR
    IF ERR NE '' THEN DIRS = []
  ENDIF ELSE BEGIN
    TDIRS = FILE_SEARCH(DIR + SL + '*' + STR + '*', /MARK_DIRECTORY,/TEST_DIRECTORY,COUNT=COUNT) 
    DIRS = []
    FOR T=0, N_ELEMENTS(TDIRS)-1 DO DIRS = [DIRS,REPLACE(TDIRS[T],DIR,'')]  
  ENDELSE
    
  CD, CDIR
  RETURN, DIRS



END ; ***************** End of GET_DIRS *****************
