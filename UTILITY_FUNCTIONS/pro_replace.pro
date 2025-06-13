; $ID:	PRO_REPLACE.PRO,	2021-04-15-17,	USER-KJWH	$

	PRO PRO_REPLACE,OLD,NEW,DIR_PRO=DIR_PRO,EXCLUDE_COMMENT=EXCLUDE_COMMENT,TEST=TEST,QUIET=QUIET,VERBOSE=VERBOSE

;+
; NAME:
;		PRO_REPLACE
;
; PURPOSE: 
;   Replaces an old target program name with a new program name
; 
; CATEGORY:	 
;   Edit
;
; CALLING SEQUENCE:
;   PRO_REPLACE, OLD, NEW
; 
; INPUTS:
;		OLD......... Old text string (program name) to be replaced
;		NEW......... New text (program name) replacement string
;		
; OPTIONAL INPUTS:
;		DIR_PRO...... Program directory (default is !S.PROGRAMS)
;
; KEYWORD PARAMETERS:
;   VERBOSE...... Print steps while running the program
;		
; PROCEDURE:
;   1) Loop through files
;   2) Search for old text string
;   3) If found, make a backup of current program
;   4) Replace text string within program
;   5) Save updated program in the current directory
;   6) Add new time step
; 
; OUTPUTS:
;		1) Back up of original program
;		2) A new version of the program with the new text string
;		
;	ISSUES:
;	  No notes are made in the MODIFICATION HISTORY of the edited file to indicate the change in the program
;	  This will only change "active text" and will not change text that has been commented out	
;	  
;	TO DO:
;	  Add step to add a note to the MODIFICATION HISTORY
;	  Create a TEST option to write out the text strings that need to be updated without making permanent changes. 
;
; EXAMPLE:
;  PRO_REPLACE,'LIST', 'PLIST'
;  PRO_REPLACE,' KEY(', ' KEYWORD_SET('
;  PRO_REPLACE,'JUNK!23', '' ; Should not find any programs to modify
;  
;	NOTES:
;
; COPYRIGHT:
;   Copyright (C) 2020, Department of Commerce, National Oceanic and Atmospheric Administration, National Marine Fisheries Service,
;   Northeast Fisheries Science Center, Narragansett Laboratory.
;   This software may be used, copied, or redistributed as long as it is not sold and this copyright notice is reproduced on each copy made.
;   This routine is provided AS IS without any express or implied warranties whatsoever.
;
; AUTHOR: 
;   This program was written September 25, 2011 by John E. O'Reilly and modified by Kimberly Hyde, DOC/NOAA/NMFS/NEFSC Narragansett, RI, kimberly.hyde@noaa.gov.  
;   Any questions should be directed to kimberly.hyde@noaa.gov
;
; MODIFICATION HISTORY:
;			  MAR 4, 2014 - JEOR: Major revisions [PFILE, FORMATTING]
;			                      No longer separating comments from commands but instead using replace on the entire program txt
;			                      If old is found on a commented line then do not replace it with new
;                           Make a txt list of all programs changed in !s.programs: OUTFILE = !S.PROGRAMS + ROUTINE_NAME + '.TXT.
;       MAR 17, 2014 - KJWH: Modified the file_search to include '*.pro' so that it is compatible with linux and mac systems
;       MAR 26, 2014 - KJWH: Added DIR_PRO and QUIET keywords
;                            Changed the location of the output txt file and made the program less verbose
;       DEC 11, 2014 - KJWH: Added logic to determine if the txt being changed was in the commented text (i.e. after the ;) 
;       NOV 30, 2015 - KJWH: Changed log directory to be !s.logs + routine + sl
;       APR 14, 2020 - KJWH: Removed QUIET=1 in the FILE_DOC, call 
;                            Updated the OUTFILE name (changed UNITS='HOUR' to /HOUR and remove /YMD)
;       JUN 03, 2020 - KJWH: Updated the !S system variable tag names to match with the updates in IDL_SYSTEM
;                            Will need to update to work with files in IDL_FUNCTIONS
;       JUN 25, 2020 - KJWH: Added the TEST keyword and functionality to show what changes would be made without permanently saving the changes 
;       APR 15, 2021 - KJWH: Changed the default directory from !S.PROGRAMS to GET_PROGRAM_DIRS() and now looping through dirs during the FILE_SEARCH
;                            Added STRUPCASE      
;       SEP 19, 2023 - KJWH: Added COMPILE_OPT IDL3    
;                            Now using FIND_TEXT with the EXCLUDE_COMMENT keyword set to find the files with the OLD text string
;                            Updated to now only change "active text" and skip any OLD text found after a ';'
          
;-
;****************************
  ROUTINE_NAME = 'PRO_REPLACE'
;****************************	
  COMPILE_OPT IDL2
  SL = PATH_SEP()
  
  DIR_TEST, !S.LOGS + ROUTINE_NAME + SL
  BACK = !S.IDL_BACKUP
  
		
; ===> Find all files with the OLD text string
	FIND_TEXT, OLD, DIR_PRO=DIR_PRO, FILELIST=FILES, /EXCLUDE_COMMENT
	IF KEYWORD_SET(VERBOSE) THEN PRINT, STRTRIM(N_ELEMENTS(FILES),2), + ' program files found in ' + DIR_PRO
	
; ===> Loop through files
	FOR NTH = 0, N_ELEMENTS(FILES)-1L DO BEGIN
	 IF KEYWORD_SET(VERBOSE) THEN POF,NTH,FILES,OUTTXT=POFTXT,/QUIET,/NOPRO
	 AFILE = FILES[NTH]
	 FN = FILE_PARSE(AFILE)  
	 TXT = READ_TXT(AFILE)	   	 
	 OK = WHERE_STRING(STRUPCASE(TXT),STRUPCASE(OLD),FOUND)
	 
	 IF FOUND EQ 0 THEN CONTINUE ; >>>>  TEXT NOT FOUND IN PROGRAM
	 IF KEYWORD_SET(VERBOSE) THEN PFILE,FN.NAME_EXT,/R, _POFTXT=POFTXT
	 IF WHERE(STRPOS(TXT[OK],';') GE 0,/NULL) NE [] THEN LOOP_TXT = 1 ELSE LOOP_TXT = 0 ; Must loop through the text if ';' are found to isolate the active text
	 
	 NEW_FILE = FN.DIR + FN.NAME_EXT   
	 IF ~KEYWORD_SET(TEST) THEN FILE_COPY, AFILE, BACK, /ALLOW_SAME, /OVERWRITE, VERBOSE=VERBOSE
   IF N_ELEMENTS(EDITED_FILES) EQ 0 THEN EDITED_FILES = AFILE $
                                    ELSE EDITED_FILES =[EDITED_FILES, AFILE]
                                    
   PRINT, 'Changing ' + NUM2STR(FOUND) + ' occurence(s) of ' + OLD + ' to ' + NEW + ' in ' + AFILE
   IF LOOP_TXT EQ 1 THEN BEGIN
     COUNTER = 0
     FOR N=0, N_ELEMENTS(OK)-1 DO BEGIN
       NTXT = STRTRIM(TXT[OK[N]],2)
       IF STRMID(NTXT,0,1) EQ ';' THEN CONTINUE
       IF STRPOS(NTXT,';') THEN GOTO, CHANGE_TXT
       IF STRPOS(NTXT,';') LT STRPOS(NTXT,OLD) THEN COUNTER = COUNTER+1 ELSE BEGIN
        CHANGE_TXT:
        IF KEYWORD_SET(TEST) THEN PRINT, 'Changing: ' + TXT[OK[N]], '      to: ' + REPLACE(TXT[OK[N]],OLD,NEW) $
                             ELSE TXT[OK[N]] = REPLACE(TXT[OK[N]],OLD,NEW)
       ENDELSE   
     ENDFOR
     IF COUNTER EQ N_ELEMENTS(OK) THEN CONTINUE ; >>>>  NO ACTIVE TEXT NOT FOUND IN PROGRAM
   ENDIF ELSE BEGIN
     IF KEYWORD_SET(TEST) THEN PRINT, 'Changing: ' + TXT[OK], '      to: ' + REPLACE(TXT[OK],OLD,NEW) ELSE $
       TXT[OK] = REPLACE(TXT[OK],OLD,NEW)  ; IF LOOP_TXT EQ 1 THEN BEGIN
   ENDELSE
    
   IF ~KEYWORD_SET(TEST) THEN  BEGIN
     WRITE_TXT,NEW_FILE,TXT & IF NONE(QUIET) THEN PFILE,NEW_FILE,/W
     FILE_DOC,FN.NAME ;###> USE FILE_DOC TO TIME STAMP THE EDITED PROGRAM  [PASS JUST THE PROGRAM NAME]
   ENDIF 
	 
	ENDFOR; FOR NTH = 0, N_ELEMENTS(FILES)-1L DO BEGIN
; FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF	
  IF N_ELEMENTS(EDITED_FILES) EQ 0 THEN PRINT,'Did not find "' + OLD + '" in any program files' $ 
                                   ELSE PRINT,'Found ' + NUM2STR(N_ELEMENTS(EDITED_FILES))+ ' files with the "' + OLD + '" text.'
  OUTFILE = !S.LOGS + ROUTINE_NAME + SL + OLD + '-' + NEW + '-' + DATE_FORMAT(DATE_NOW(),/HOUR) + '.TXT'
  DIR_TEST, !S.LOGS + ROUTINE_NAME + SL
  OUTFILE = REPLACE(OUTFILE,['[',']'],['(',')'])
  IF N_ELEMENTS(EDITED_FILES) GE 1 AND ~KEYWORD_SET(TEST) THEN BEGIN
      WRITE_TXT,OUTFILE,EDITED_FILES 
      IF NONE(QUIET) THEN PFILE,OUTFILE,/W
  ENDIF ELSE PRINT, 'No files were permanentaly changed.'
  	
END; #####################  END OF ROUTINE ################################
