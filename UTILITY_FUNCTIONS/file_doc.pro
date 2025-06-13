; $ID:	FILE_DOC.PRO,	2021-04-15-17,	USER-KJWH	$

PRO FILE_DOC, FILENAMES, DIR_BACKUP=DIR_BACKUP, VERBOSE=VERBOSE

;+
; NAME:
;   FILE_DOC
;
; PURPOSE: 
;   This routines makes a backup and updates the date of IDL .pro files in teh $ID
;
; CATEGORY:
;   UTILITY
;
; CALLING SEQUENCE:
;   FILE_DOC, FILENAME 
;
; INPUTS:
;   FILENAMES... The first name(s) a of .pro file(s). The file name is not case sensitive and does not need to include the .pro extension
;
; OPTIONAL_INPUTS:
;   DIR_BACKUP.. Directory for the BACKUP .pro files
;   
; KEYWORD PARAMETERS:
;   VERBOSE....Turns on program feedback
;
; OUTPUTS:
;   1) Makes a backup directory (if it does not already exist)
;   2) Copies the .pro file to the backup directory
;   3) Places a current date stamp at the top of the .pro file
;   4) Writes the updated .pro file into the program directory
;
; EXAMPLES: 
;   FILE_DOC, 'FILE_DOC' 
; 
; NOTES:
;     This program assumes that files are in either in the !S.PROGRAMS, !S.FILE_FUNCTIONS or !S.PROJECTS/xxx/IDL_PROGRAMS/ directories.  
;     Use DIR_PRO input to change the default directory location.
;     The user does not need to provide the extension (.pro) in the input FILES, just the first name 
;   
; COPYRIGHT:
; Copyright (C) 2020, Department of Commerce, National Oceanic and Atmospheric Administration, National Marine Fisheries Service,
;   Northeast Fisheries Science Center, Narragansett Laboratory.
;   This software may be used, copied, or redistributed as long as it is not sold and this copyright notice is reproduced on each copy made.
;   This routine is provided AS IS without any express or implied warranties whatsoever.
;
;   This program was written December 21, 2011 by John O'Reilly and adapted by Kimberly Hyde, DOC/NOAA/NMFS/NEFSC Narragansett, RI, kimberly.hyde@noaa.gov.
;   All inquires should be directed to kimberly.hyde@noaa.gov
;
; MODIFICATION HISTORY:
;   SEP 30, 2011 - JEOR: Changed DIR_IDL_BACKUP = 'D:\IDL\PROGRAMS\BACKUP\' to DIR_IDL_BACKUP = 'D:\IDL\BACKUP\' to avoid conflicts
;   MAR 11, 2012 - JEOR: Automatically determines working-local programs directory [C or D drive ]
;                        Now always prepends current date
;                        Added documentation, examples, upper case 
;                        If no file names are provided then message results  
;   APR 20, 2012 - JEOR: Changed BACKUP_FILE = DIR_IDL_BACKUP + COMPUTER +'-' + FN.NAME + '-' + DT_NOW() + '.PRO'
;                             to BACKUP_FILE = DIR_IDL_BACKUP + FN.NAME + '-' COMPUTER +'-' + DT_NOW() + '.PRO'
;   JAN 02, 2013 - JEOR: CDPRO; set dir to my working dir
;   MAY 27, 2013 - JEOR: DATE_FORMAT applied to backup file name
;   OCT 02, 2013 - JEOR: Added DIR_IDL_BACKUP = GET_PATH()+'IDL\BACKUP\'
;   OCT 04, 2013 - JEOR: Made date info DATE_FORMAT(DATE_NOW(),UNITS = 'HOUR',/YMD)
;   DEC 09, 2013 - JEOR: Added DOC_PRO = STRLOWCASE(DIR_IDL+ FN.FULLNAME)
;   DEC 10, 2013 - KJWH: Changed DIR_IDL_BACKUP to !S.IDL_BACKUP 
;                        Changed DIR_IDL to !S.PROGRAMS
;                        Changed the FILE_SEARCH to look for lower case names because LINUX file names are case sensitive
;                        Added QUIET keyword
;   DEC 10, 2013 - JEOR: Added IDL_SYSTEM to ensure !S is initialized
;   APR 29, 2014 - JEOR: Fixed bug due to:
;                          FILES=FILE_SEARCH(DIR_IDL+STRLOWCASE(FILES)+'.pro') [THIS WORKS ONLY WHEN THERE IS JUST ONE FILE PROVIDED
;                          AND WHEN THE FILE INPUT WAS JUST THE PROGRAM NAME, THE PATH WAS BEING ADDED TWICE]    
;                          MODIFIED SO THAT FILE_DOC WRITES A LOWER CASE .PRO [BY WRITING TO TEMP THEN MOVING TO PROGRAMS]
;                          USED FILE_DOC TO RENAME ALL UPPERCASE .PRO TO LOWERCASE
;   MAY 27, 2014 - KJWH: Changed COMPUTER = GET_COMPUTER() to COMPUTER = !S.COMPUTER because there are times when my mac has issues with spawning the command in GET_COMPUTER  
;   NOV 24, 2014 - KJWH: Fixed an error when changing the file name to all caps (STRUPCASE)  
;   NOV 24, 2014 - KJWH: Added user name to the id line 
;   FEB 23, 2017 - KJWH: Changed keyword QUIET to VERBOSE
;                        Added COUNT=COUNT_FILES to the file search
;                        If COUNT_FILES is 0 then print an error statement 
;                        Changed parameters of the for loop to COUNT_FILES so if COUNT_FILES = 0, it will skip the loop and not crash
;   MAR 02, 2017 - JEOR: Revised call to DATE_FORMAT: DATE_FORMAT(DATE_NOW(),/HOUR)  
;   MAR 14, 2017 - KJWH: Changed the info saved in the backup file for KJWH to be just the user and to be the USR_COMPUTER for JEOR
;   MAR 12, 2020 - KJWH: Updated documentation and formatting
;                        Added DIR_PRO and DIR_BACKUP optional keywords
;   JUN 03, 2020 - KJWH: Updated the !S system variable tag names to match with the updates in IDL_SYSTEM       
;                            Will need to update to work with files in IDL_FUNCTIONS              
;   JUN 26, 2020 - KJWH: Updated documentation
;                        Added COMPILE_OPT IDL2
;   SEP 08, 2020 - KJWH: Now searching for .pro files in !S.PROGRAMS, !S.FILE_FUNCTIONS and !S.IDL_PROJECTS/xxx/IDL_PROGRAMS
;                        Added a MESSAGE ERROR is the file does not have a .pro extenstion
;                        Added a MESSAGE ERROR if more than one file with the same name is found
;                        Now looping through the file names prior to searching for the files
;                        Changed the input parameter FILES to FILENAMES
;                        Updated documentation
;   APR 15, 2021 - KJWH: Streamlined by adding GET_PROGRAMS and GET_PROGRAM_DIRS   
;   SEP 20, 2023 - KJWH: Removed DIR_PRO and GET_PROGRAM_DIRS because DIR_PRO is no longer used             
;  
; ******************************************************************************************************************                                            
;-
  ROUTINE_NAME  = 'FILE_DOC'
  COMPILE_OPT IDL2
  
  TAB=STRING(BYTE(9))
  USR = !S.INITIALS                                                                  ; Get the user's initials
  IF USR  EQ 'JEOR' THEN BACKUPTAG = USR + '_' + !S.COMPUTER ELSE BACKUPTAG = USR    ; Get the computer name (for JOER) for documentation of the backup file
  DIR_IDL_BACKUP = !S.IDL_BACKUP                                                     ; If DIR_BACKUP not provided, use the default !S.BACKUP directory
  DIR_TEST,DIR_IDL_BACKUP                                                            ; Make a backup directory if it does not already exist                                                          
    
  IF N_ELEMENTS(FILENAMES) EQ 0 THEN MESSAGE, 'ERROR: Must provide at least one input file name'
  NAMES  = (FILE_PARSE(FILENAMES)).NAME                                              ; Get the NAMES from the files then add path and extension during FILE_SEARCH
; ===> Loop through input file names  
  FOR F=0, N_ELEMENTS(NAMES)-1 DO BEGIN
    ANAME = NAMES[F]
    FILES = GET_PROGRAMS(ANAME)                                                      ; Search for the file name 
    FILES = FILES[WHERE(FILES NE '',COUNT_FILES)]                                    ; Remove an blank files
    IF COUNT_FILES EQ 0 THEN MESSAGE, 'ERROR: ' + NAMES + '.pro not found.'
    IF COUNT_FILES GT 1 THEN MESSAGE, 'ERROR: ' + NAMES + '.pro found in more than one directory (' + FILES + ').'
  
    FN=FILE_PARSE(FILES)                                                                 ; Parse the file name
    IF STRUPCASE(FN.EXT) NE 'PRO' THEN MESSAGE, 'ERROR: ' + FILES + ' must have a .pro extension'      
    IF KEY(VERBOSE) THEN PRINT, 'Adding documentation date to: '+AFILE
    IF KEY(VERBOSE) THEN PFILE, AFILE, /R
      
    TXT= READ_TXT(FILES)                                                                 ; Read the program as a text file                                                       ; Read the file
    ID = '; $ID:'+TAB+STRUPCASE(FN.NAME+'.'+FN.EXT) +','+TAB+ DATE_FORMAT(DATE_NOW(),/HOUR)+','+TAB+'USER-'+USR+TAB+'$'   ; Create an ID tag for the file
    D = STRUPCASE(ID)                                                       
    OK=WHERE(STRPOS(STRUPCASE(TXT),'$ID:') GE 0 AND STRPOS(STRUPCASE(TXT),'$ID:') LE 3,COUNT)  ; Look for the ID tag at the beginning of the file
    IF COUNT GE 1 THEN BEGIN                                                        
      TXT = REMOVE(TXT, OK[0])                                                            ; Remove the old ID tag 
      TXT=[ID,TXT]                                                                        ; Add the new ID tag at the top of the program
    ENDIF ELSE TXT=[ID,TXT]		
  
    BACKUP_FILE = DIR_IDL_BACKUP + STRUPCASE(FN.NAME + '-'+ BACKUPTAG +'-' + DATE_FORMAT(DATE_NOW(),/HOUR) + '.PRO')         ; Create a new name for the back up file
    IF KEY(VERBOSE) THEN PFILE,BACKUP_FILE,/W
    WRITE_TXT,BACKUP_FILE,TXT                                                             ; Write the back-up file
  		
  	DOC_PRO = FN.DIR + STRLOWCASE(FN.NAME_EXT)                                            ; File name in the PROGRAMS directory
    DOC_TEMP = !S.IDL_TEMP+STRLOWCASE(FN.NAME_EXT)                                        ; File name in the TEMP directory                   
  	IF FILE_TEST(DOC_TEMP) EQ 1 THEN FILE_DELETE,DOC_TEMP                                 ; Look for the file in the TEMP directory and remove if it exists
  		
    WRITE_TXT,DOC_TEMP,TXT                                                                ; Write the file in the TEMP directory
  	FILE_MOVE,DOC_TEMP,DOC_PRO,/OVERWRITE		                                              ; Move the file to the PROGRAMS directory and overwrite any existing files
    PFILE,DOC_PRO,/W
	ENDFOR ; NAMES loop
	
  IF KEY(VERBOSE) THEN PDONE
END; #####################  END OF ROUTINE ################################
