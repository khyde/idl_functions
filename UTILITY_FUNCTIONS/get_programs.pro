; $ID:	GET_PROGRAMS.PRO,	2022-05-05-11,	USER-KJWH	$
  FUNCTION GET_PROGRAMS, TXT, DIR_PRO=DIR_PRO, WILD=WILD

;+
; NAME:
;   GET_PROGRAMS
;
; PURPOSE:
;   Program to find all or a subset of .pro programs based on a search string
;
; CATEGORY:
;   UTILITY_FUNCTIONS
;
; CALLING SEQUENCE:
;   Result = GET_PROGRAMS()
;
; REQUIRED INPUTS:
;   None
;
; OPTIONAL INPUTS:
;   TXT.......... Text string to find .pro files (default is to return all files)
;   DIR_PRO...... Directory to search for the .pro files (default is to look in all program directories)
;
; KEYWORD PARAMETERS:
;   WILD......... Add '*' to the text string to expand the wild card search
;
; OUTPUTS:
;   OUTPUT....... A string array with the list of .pro files
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
;   HELP, GET_PROGRAMS()
;   HELP, GET_PROGRAMS('WHERE*')         
;   HELP, GET_PROGRAMS('WHERE',/WILD)
;   HELP, GET_PROGRAMS('WHERE',DIR_PRO=!S.PROGRAMS)
;   HELP, GET_PROGRAMS(DIR_PRO=!S.PROGRAMS)
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
;   This program was written on April 15, 2021 by Kimberly J. W. Hyde, Northeast Fisheries Science Center | NOAA Fisheries | U.S. Department of Commerce, 28 Tarzwell Dr, Narragansett, RI 02882
;    
; MODIFICATION HISTORY:
;   Apr 15, 2021 - KJWH: Initial code written
;   May 05, 2022 - KJWH: Removed the option to find .PRO files because the file names are not case specific on the Mac and all true programs should be .pro
;-
; ****************************************************************************************************
  ROUTINE_NAME = 'GET_PROGRAMS'
  COMPILE_OPT IDL2
  SL = PATH_SEP()
  
  IF N_ELEMENTS(DIR_PRO) EQ 0 THEN DIR_PRO = GET_PROGRAM_DIRS()
  IF N_ELEMENTS(TXT) NE 1 THEN TXT = '*' ELSE TXT = STRLOWCASE(TXT)
  IF KEYWORD_SET(WILD) THEN TXT = '*'+TXT+'*'
  
  FILES = []
  FOR D=0, N_ELEMENTS(DIR_PRO)-1 DO FILES = [FILES,FILE_SEARCH(DIR_PRO[D]+TXT+'.pro')]
  FILES = FILES[WHERE(FILES NE '',/NULL)]
  
  RETURN, FILES
  


END ; ***************** End of GET_PROGRAMS *****************
