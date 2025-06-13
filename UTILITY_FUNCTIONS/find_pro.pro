; $ID:	FIND_PRO.PRO,	2021-09-16-17,	USER-KJWH	$
;##############################################################################################
	PRO FIND_PRO, TXT, DIR_PRO=DIR_PRO, STRUCT=STRUCT

;+
; NAME:
;		FIND_PRO
;
; PURPOSE: 
;   Search for a text string within a program name
;
; CATEGORY: 
;   UTILITY_FUNCTION
;
; CALLING SEQUENCE:
;   FIND_PRO, TXT
;   
; REQUIRED INPUTS:
;		TXT.............. The text string within the program name to find
;		
; OPTIONAL INPUTS:		
;	  DIR.............. The directory to search for the .pro files 
;
; KEYWORD PARAMETERS:
;		STRUCT........... Returns a structure with the programs found
; 
; OUTPUTS:
;   A printed list with the full program names
;   
; EXAMPLE:
;  FIND_PRO,'2DATE'
;  FIND_PRO,'PAL_'
;  FIND_PRO,'PAL_',STRUCT=S
;  FIND_PRO,'PAL_',STRUCT=S,DIR=!S.IDL_TEMP
;
; NOTES:
;     This program assumes that files are in either in the !S.PROGRAMS, !S.FILE_FUNCTIONS or !S.PROJECTS/xxx/IDL_PROGRAMS/ directories.  
;     Use DIR_PRO input to change the default directory location.
;     The user does not need to provide the extension (.pro) in the text search, just a portion of the name 
;   
; COPYRIGHT:
; Copyright (C) 2017, Department of Commerce, National Oceanic and Atmospheric Administration, National Marine Fisheries Service,
;   Northeast Fisheries Science Center, Narragansett Laboratory.
;   This software may be used, copied, or redistributed as long as it is not sold and this copyright notice is reproduced on each copy made.
;   This routine is provided AS IS without any express or implied warranties whatsoever.
;
;   This program was written June 20, 2017 by Kimberly Hyde, DOC | NOAA | NMFS | NEFSC | Narragansett, RI, kimberly.hyde@noaa.gov.
;   All inquires should be directed to kimberly.hyde@noaa.gov
;
; MODIFICATION HISTORY:
;   JUN 20, 2017 - KJWH: Adapted JEOR's original FIND_PRO, which did the same function as FIND_TEXT, to now just look for a text string within a program name
;   OCT 26, 2020 - KJWH: Updated documentation
;                        Added COMPILE_OPT IDL2
;                        Changed subscript () to []
;                        Moved to UTILITY_FUNCTIONS
;                        Now searching for .pro files in !S.PROGRAMS, !S.FILE_FUNCTIONS and !S.IDL_PROJECTS/xxx/IDL_PROGRAMS
;   APR 15, 2021 - KJWH: Streamlined by adding GET_PROGRAMS_DIRS and GET_PROGRAMS           
;   MAY 12, 2021 - KJWH: Removed the final structure (not used) and updated the output text string        
;   SEP 16, 2021 - KJWH: Added step to return the directory above IDL_PROGRAMS for the IDL_PROJECTS block  
;*********************************************************************************************************************************
;-
	ROUTINE_NAME = 'FIND_PRO'
  COMPILE_OPT IDL2
  
  IF NONE(TXT) THEN MESSAGE, 'ERROR:  TXT must be provided'
  
  ; ===> Get the input directories for any IDL programs
  IF NONE(DIR_PRO) THEN DIR_PRO = GET_PROGRAM_DIRS()                                        ; If DIR_PRO not provided, use the default directories to find the files
    
  FILES = GET_PROGRAMS(TXT,DIR_PRO=DIR_PRO,/WILD)
  IF FILES EQ [] THEN BEGIN
    LI, 'No ' + TXT + ' files found...',/NOSEQ
    GOTO, DONE
  ENDIF  
  
  FN = FILE_PARSE(FILES)
	OK = WHERE_STRING(STRUPCASE(FN.NAME),STRUPCASE(REPLACE(TXT,'*','')),FOUND)
	IF FOUND GE 1 THEN BEGIN
	 FP = FN[OK]
	 SUB = FP.SUB
	 OKP = WHERE(FP.SUB EQ 'IDL_PROGRAMS',COUNT)
	 IF COUNT GT 0 THEN SUB[OKP] = (FILE_PARSE(REPLACE(FN[OKP].DIR,'/IDL_PROGRAMS/','/'))).SUB
	 LI, STRUPCASE(FP.NAME) + ': in ' + SUB + ' - Last modified: ' + STRMID(GET_MTIME(FILES[OK],/DATE),0,8)
	ENDIF
  
  DONE:
  
END; #####################  END OF ROUTINE ################################
