; $ID:	GET_PROGRAM_DIRS.PRO,	2022-05-05-11,	USER-KJWH	$
  FUNCTION GET_PROGRAM_DIRS, FUNCTIONS=FUNCTIONS, PROJECTS=PROJECTS, TEST=TEST, PROGRAMS=PROGRAMS, INIT=INTI

;+
; NAME:
;   GET_PROGRAM_DIRS
;
; PURPOSE:
;   Get a list of directories containing IDL programs
;
; CATEGORY:
;   UTILITY_FUNCTIONS
;
; CALLING SEQUENCE:
;   Result = GET_PROGRAM_DIRS()
;
; REQUIRED INPUTS:
;   None
;
; OPTIONAL INPUTS:
;   Parm2.......... Describe optional inputs here. If none, delete this section.
;
; KEYWORD PARAMETERS:
;   FUNCTIONS...... Set to include or exclude the directories in !S.IDL_FUNCTIONS (default=1) 
;   PROJECTS....... Set to include or exclude the directories in !S.IDL_PROJECTS/*/IDL_PROGRAMS (default=1)
;   TEST........... Set to include or exclude the directories in !S.IDL_TEST (default=1)
;   PROGRAMS....... Set to include or exclude the directories in !S.PROGRAMS (default=1)
;   INIT........... Used to reset the DIR_IDL variable set in COMMON
;
; OUTPUTS:
;   OUTPUT.......... A list of all directories containing IDL programs and functions (.pro files)
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
;   DIRS = GET_PROGRAM_DIRS()
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
;   This program was written on April 14, 2021 by Kimberly J. W. Hyde, Northeast Fisheries Science Center | NOAA Fisheries | U.S. Department of Commerce, 28 Tarzwell Dr, Narragansett, RI 02882
;    
; MODIFICATION HISTORY:
;   Apr 14, 2021 - KJWH: Initial code written
;   Aug 17, 2021 - KJWH: Fixed bug to get program directories from IDL_PROJECTS
;   Oct 07, 2021 - KJWH: Added a step to print out the project directory if IDL_PROGRAMS not found 
;   Oct 12, 2021 - KJWH: Now working with IDL_PROJECTS and GIT_PROJECTS
;   May 04, 2022 - KJWH: Added SPAWNDIRS to work with MAC command line
;   May 05, 2022 - KJWH: Replaced SPAWNDIRS command with GET_DIRS function
;   Jun 06, 2022 - KJWH: Removed IF KEYWORD_SET(GET_PROGRAMS) THEN PROGRAM_DIRS=!S.PROGRAMS ELSE PROGRAM_DIRS=[] now that PROGRAMS has been moved into IDL_FUNCTIONS
;   Sep 20, 2023 - KJWH: Added COMMON to hold the DIR_IDL output and avoid repeated GIT_DIRS (and SPAWN calls)
;-
; ****************************************************************************************************
  ROUTINE_NAME = 'GET_PROGRAM_DIRS'
  COMPILE_OPT IDL2
  SL = PATH_SEP()
  
  COMMON _GET_PROGRAM_DIRS, DIR_IDL
  IF KEYWORD_SET(INIT) THEN DIR_IDL = [] 
  IF DIR_IDL NE [] THEN RETURN, DIR_IDL
  
  IF N_ELEMENTS(FUNCTIONS) NE 1 THEN GET_FUNCTIONS = 1 ELSE GET_FUNCTIONS = FUNCTIONS
  IF N_ELEMENTS(PROJECTS)  NE 1 THEN GET_PROJECTS  = 1 ELSE GET_PROGRAMS  = PROJECTS
  IF N_ELEMENTS(TEST)      NE 1 THEN GET_TEST      = 0 ELSE GET_TEST      = TEST
  IF N_ELEMENTS(PROGRAMS)  NE 1 THEN GET_PROGRAMS  = 1 ELSE GET_PROGRAMS  = PROGRAMS
  
  ; ===> Find any directories in the IDL_FUNCTIONS
  IF KEYWORD_SET(GET_FUNCTIONS) THEN BEGIN
    DIRS = GET_DIRS(!S.IDL_FUNCTIONS)
    FUNCTION_DIRS = !S.IDL_FUNCTIONS + DIRS
  ENDIF ELSE FUNCTION_DIRS = []
  
  ; ===> Find any directories in the IDL_TEST
  TEST_DIRS = []
  IF KEYWORD_SET(GET_TEST) THEN BEGIN
    DIRS = GET_DIRS(!S.IDL_TEST)
    FOR F=0, N_ELEMENTS(DIRS)-1 DO BEGIN
      TDIRS = GET_DIRS(!S.IDL_TEST + DIRS[F])
      OK = WHERE(TDIRS EQ 'IDL_PROGRAMS/',COUNT)
      IF COUNT EQ 1 THEN TEST_DIRS = [TEST_DIRS,!S.IDL_TEST + DIRS[F] + TDIRS[OK]]
    ENDFOR
  ENDIF

  ; ===> Look for IDL_PROGRAMS directories in IDL_PROJECTS
  PROJECT_DIRS = []
  IF KEYWORD_SET(GET_PROJECTS) THEN BEGIN
    PROJ_DIRS = [!S.PROJECTS]
    FOR PR=0,N_ELEMENTS(PROJ_DIRS)-1 DO BEGIN
      DIRS = GET_DIRS(PROJ_DIRS[PR])
      FOR F=0, N_ELEMENTS(DIRS)-1 DO BEGIN
        PDIRS = GET_DIRS(PROJ_DIRS[PR] + DIRS[F])
        OK = WHERE(PDIRS EQ 'IDL_PROGRAMS/',COUNT)
        IF COUNT EQ 1 THEN PROJECT_DIRS = [PROJECT_DIRS, PROJ_DIRS[PR]+DIRS[F]+PDIRS[OK]] 
      ENDFOR ; DIRS
    ENDFOR ; PROJ_DIRS  
  ENDIF
  
  DIR_IDL = [FUNCTION_DIRS,TEST_DIRS,PROJECT_DIRS]
  RETURN, DIR_IDL


END ; ***************** End of GET_PROGRAM_DIRS *****************
