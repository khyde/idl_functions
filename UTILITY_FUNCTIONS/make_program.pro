
  PRO MAKE_PROGRAM, FILENAME, TYPE=TYPE, CATEGORY=CATEGORY, PROJECT=PROJECT, TEST=TEST, MAIN=MAIN, OVERWRITE=OVERWRITE

;+
; NAME:
;   MAKE_PROGRAM
;
; DESCRIPTION:
;   This program creates a new procedure or function with a basic template
;
; CATEGORY:
;   UTILITY_FUNCTIONS
;
; INPUT INPUTS:
;   FILENAME...... The name of the new function or procedure
;
; OPTIONAL INPUTS:
;   TYPE.......... Indicate if the new file should be a procedure or function (default)
;   CATEGORY...... Function category (which corresponds to IDL_FUNCTIONS directory)
;
; KEYWORDS:
;   PROJECT....... The project name for the new file, if none provided it can be entered manually
;   MAIN.......... If set, additional information will be added for MAIN programs 
;   TEST.......... The name of the folder in IDL_TEST to put the "test" programs 
;
; OUTPUTS:
;   This procedure creates a new .pro file with the default template information
;
; OPTIONAL OUTPUTS:
;
; PROCEDURE:
;
; EXAMPLE:
;  MAKE_PROGRAM, JUNK_TEST, TYPE='FUNCTION', CA
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
; AUTHOR INFORMATION
;   This program was written June 4, 2020 by Kimberly Hyde, Northeast Fisheries Science Center | NOAA Fisheries | U.S. Department of Commerce, 28 Tarzwell Dr, Narragansett, RI 02882 
;     Inquires about this program should be directed to kimberly.hyde@noaa.gov
;
; MODIFICATION HISTORY:
;   Jun 04, 2020 - KJWH: Initial code written
;   Sep 01, 2020 - KJWH: Added STRLOWCASE(FILENAME) to make sure the file name is saved in lower case
;                        Added COMPILE_OPT IDL2
;   Apr 14, 2021 - KJWH: Added CATEGORY=STRUPCASE(CATEGORY)    
;   Jan 27, 2022 - KJWH: Now when looking for a project in the !S structure, change any '-' to '_'                  
;-
;
;	****************************************************************************************************
	ROUTINE_NAME = 'MAKE_PROGRAM'
	COMPILE_OPT IDL2
	SL = PATH_SEP()
	DT = DATE_PARSE(DATE_NOW())

; ===> Read the template text file  
  TEMP = READ_TXT(!S.UTILITY_FUNCTIONS + 'template.txt')
	
; ===> Add DATE information in the TEMP template with current date information	
  DP = DATE_PARSE(DATE_NOW()) ; Parse today's date information 
  TEMP = REPLACE(TEMP, '$DATE$', DP.STRING_DATE)
  TEMP = REPLACE(TEMP, '$SHORTDATE$', REPLACE(DP.STRING_DATE, MONTH_NAMES(DP.MONTH), DP.MON))
	
; ===> Add USER specific information to the TEMP template
  TEMP = REPLACE(TEMP, ['$INITIALS$','$AUTHOR$','$AFFILIATION$','$EMAIL$'],[!S.INITIALS,!S.AUTHOR,!S.AFFILIATION, !S.ADDRESS])
  
; ===> Add filename specific information
  IF N_ELEMENTS(FILENAME) NE 1 THEN FILENAME = TEXTBOX(TITLE='Enter new program/function name: ') 
  IF N_ELEMENTS(TYPE) NE 1 THEN TYPE = 'FUNCTION' ELSE TYPE = STRUPCASE(TYPE) ; Default
; TODO: Add widgets to interactively add the purpose, input/output parameters, keywords and their descriptions 
  TEMP = REPLACE(TEMP, ['$ROUTINE_NAME$','$PRO$','$YEAR$'], [STRUPCASE(FILENAME),TYPE,DP.YEAR])
  
  CASE TYPE OF
    'FUNCTION': BEGIN
      TEMP = REPLACE(TEMP, '$CALLING SEQUENCE$', 'Result = '+ STRUPCASE(FILENAME) + '($Parameter1$, $Parameter2$, $Keyword=Keyword$, ...)')
      TEMP = REPLACE(TEMP, '$OUTPUT$', 'This function returns...')
    END  
    'PRO': BEGIN
      TEMP = REPLACE(TEMP, '$CALLING SEQUENCE$', STRUPCASE(FILENAME) + ',$Parameter1$, $Parameter2$, $Keyword=Keyword$, ....')
      TEMP = REPLACE(TEMP, 'OUTPUT$', 'This procedure creates...')
    END  
    ELSE: MESSAGE,'ERROR: Program type ' + TYPE + 'not recognized.'
  ENDCASE
  
  TEMP = [TEMP,'  SL = PATH_SEP()','','','END ; ***************** End of ' + STRUPCASE(FILENAME) + ' *****************']
  
  IF KEYWORD_SET(CATEGORY) AND KEYWORD_SET(PROJECT) THEN MESSAGE, 'ERROR: A program can not be saved in both the IDL_FUNCTIONS and PROJECTS
  IF KEYWORD_SET(CATEGORY) AND KEYWORD_SET(TEST)    THEN MESSAGE, 'ERROR: A program can not be saved in both the IDL_FUNCTIONS and IDL_TEST
  IF KEYWORD_SET(TEST)     AND KEYWORD_SET(PROJECT) THEN MESSAGE, 'ERROR: A program can not be saved in both the IDL_TEST and IDL_PROJECTS

  
  IF KEYWORD_SET(CATEGORY) THEN BEGIN
    CATEGORY=STRUPCASE(CATEGORY)
    IF ~HAS(CATEGORY,'FUNCTIONS') THEN CATEGORY[0] = CATEGORY[0] + '_FUNCTIONS'
    TEMP = REPLACE(TEMP, '$CATEGORY$', CATEGORY)
    OK = WHERE(TAG_NAMES(!S) EQ CATEGORY[0],COUNT)
    IF COUNT NE 1 THEN BEGIN
      DIR_PRO = !S.IDL_FUNCTIONS + CATEGORY + SL
      DIR_TEST, DIR_PRO
      IDL_SYSTEM
    ENDIF ELSE DIR_PRO = !S.(OK)
    FILE = DIR_PRO + STRLOWCASE(FILENAME) + '.pro'
; TODO: Add widget to confirm that a file should be overwritten if it already exists 
    IF FILE_TEST(FILE) EQ 0 OR KEYWORD_SET(OVERWRITE) THEN WRITE_TXT, FILE, TEMP ELSE MESSAGE, 'ERROR: ' + FILE + ' already exists.'
    FILE_DOC, FILENAME
  ENDIF
  
  IF KEYWORD_SET(MAIN) THEN BEGIN
; TODO: Add information on switches and IF keyword set blocks
  ENDIF
  
	IF KEYWORD_SET(PROJECT) THEN BEGIN
	  OK = WHERE(STRUPCASE(TAG_NAMES(!S)) EQ STRUPCASE(REPLACE(PROJECT[0],'-','_')),COUNT)
	  IF COUNT NE 1 THEN STOP
	  DIR_PRO = !S.(OK) + 'IDL_PROGRAMS' + SL
	  DIR_TEST, DIR_PRO
	  FILE = DIR_PRO + STRLOWCASE(FILENAME) + '.pro'
; TODO: Add widget to confirm that a file should be overwritten if it already exists    
    TEMP = REPLACE(TEMP, ['; CATEGORY', '$CATEGORY$'], ['; PROJECT',PROJECT[0]])
    IF FILE_TEST(FILE) EQ 0 OR KEYWORD_SET(OVERWRITE) THEN WRITE_TXT, FILE, TEMP
;    FILE_DOC,FILENAME
	ENDIF
	
	IF KEYWORD_SET(TEST) THEN BEGIN
	  OK = WHERE(TAG_NAMES(!S) EQ TEST[0],COUNT)
	  IF COUNT NE 1 THEN BEGIN
	    DIR_TST = !S.IDL_TEST + TEST[0] + SL + IDL_PROGRAMS + SL
	    DIR_TEST, DIR_TST
	  ENDIF ELSE DIR_TST = !S.(OK)
	  FILE = DIR_TST + STRLOWCASE(FILENAME) + '.pro'
	  ; TODO: Add widget to confirm that a file should be overwritten if it already exists
	  IF FILE_TEST(FILE) EQ 0 OR KEYWORD_SET(OVERWRITE) THEN WRITE_TXT, FILE, TEMP
	  FILE_DOC,FILENAME
	ENDIF
	
	
END; #####################  End of Routine ################################
