; $ID:	FIND_TEXT.PRO,	2021-10-15-16,	USER-KJWH	$

	PRO FIND_TEXT, FTEXT, DIR_PRO=DIR_PRO, DATERANGE=DATERANGE,EXT=EXT, FILELIST=FILELIST, EXCLUDE_COMMENT=EXCLUDE_COMMENT

;+
; NAME:
;		FIND_TEXT
;
; PURPOSE:;
;		This PROGRAM will search through all available programs in a given directory (default='D:\IDL\PROGRAMS\')
;     for a given program call
;
; CATEGORY:
;  UTILITY
;
; CALLING SEQUENCE:
;		FIND_TEXT, 'SD_SCALES'
;		FIND_TEXT, 'SD_SCALES, DIR_PRO = !S.IDL_BACKUP
;
; REQUIRED INPUTS:
;		PROGRAM.........	Program name to look for
;
; OPTIONAL INPUTS:
;   DIR_PRO.......... To change the default directory to search for the programs
;   DATERANGE..... Look at specified "last modified" date range
;   EXT.............. To change the default file extension
;
; KEYWORDS
;   EXCLUDE_COMMENT.. Exclude lines/programs where the desired text is in a comment (i.e. ";" preceeds the text string)
;   
; OUTPUTS:
;		A list of program names and line numbers
;
; OPTIONAL OUTPUTS
;   FILELIST........ A list of file names with the input text
;
;	NOTES:
;
; COPYRIGHT:
; Copyright (C) 2020, Department of Commerce, National Oceanic and Atmospheric Administration, National Marine Fisheries Service,
;   Northeast Fisheries Science Center, Narragansett Laboratory.
;   This software may be used, copied, or redistributed as long as it is not sold and this copyright notice is reproduced on each copy made.
;   This routine is provided AS IS without any express or implied warranties whatsoever.
;
; AUTHOR INFORMATION
;   This program was written May 16, 2008 by Kimberly Hyde, DOC/NOAA/NMFS/NEFSC Narragansett, RI, kimberly.hyde@noaa.gov
;
; MODIFICATION HISTORY:
;     Jun 04, 2020 - KJWH:
;-
;
; MODIFICATION HISTORY:
;			May 16, 2008 - KJWH: Adapted code from PRO_CALLS
;			Dec 29, 2015 - KJWH: Added EXCLUDE_COMMENT keyword to prevent the program from returning programs where the text string has been commented out      
;			Feb 04, 2016 - KJWH: Added EXT keyword and changed DIR_PRO to DIR - Now can look for text in files other than just .pro     
;			Jun 26, 2020 - KJWH: Added FILELIST keyword option and functionality
;			                     Updated documentation  
;			                     Added COMPILE_OPT IDL2
;			Oct 26, 2020 - KWJH: Now searching for .pro files in !S.PROGRAMS, !S.FILE_FUNCTIONS and !S.IDL_PROJECTS/xxx/IDL_PROGRAMS   
;			Jun 07, 2021 - KJWH: Now using GET_PROGRAM_DIRS to locate the multiple program directories
;			                     Now printing out the DIRECTORY and LAST MODIFIED dates
;			                     Removed the VERBOSE keyword   
;			                     Added OUTSTRUCT to hold the structure   
;			                     Added SL = PATH_SEP()         
;   Sep 01, 2023 - KJWH: Added DATERANGE input  
;-
;	****************************************************************************************************
	ROUTINE_NAME = 'FIND_TEXT'
  COMPILE_OPT IDL2
  SL = PATH_SEP()
  
	IF N_ELEMENTS(FTEXT) EQ 0 THEN MESSAGE, 'ERROR: Must provide input text string'	
	FTEXT = STRUPCASE(FTEXT)

	IF ~N_ELEMENTS(DATERANGE) THEN DTR = [] ELSE DTR = GET_DATERANGE(DATERANGE)
	IF ~N_ELEMENTS(EXT) THEN _EXT = 'pro' ELSE _EXT = EXT
	
	; ===> Get the input directories for any IDL programs
	IF ~N_ELEMENTS(DIR_PRO) THEN DIR_PRO = GET_PROGRAM_DIRS()                                            ; If DIR_PRO not provided, use the default directories to find the files
	  
	FILES  = FILE_SEARCH(DIR_PRO + '*.' + _EXT)
	IF FILES EQ [] THEN MESSAGE, 'ERROR: No files with the extension ' + _EXT + ' found in ' + DIR_PRO
	FILES  = FILES[WHERE(FILES NE '')] 
	STRUCT = CREATE_STRUCT('FULLNAME','','FILE','', 'LINE','','DIR','','MTIME','')
	STRUCT = STRUCT_2MISSINGS(STRUCT)
	STRUCT = REPLICATE(STRUCT,N_ELEMENTS(FILES))
	FOR _FILE =0L, N_ELEMENTS(FILES)-1 DO BEGIN
		AFILE = FILES[_FILE]
		FP = FILE_PARSE(AFILE)
		TXT = STRUPCASE(READ_TXT(AFILE))
		OK = WHERE_STRING(TXT,FTEXT,COUNT)
		IF COUNT GE 1 THEN BEGIN
		  IF KEY(EXCLUDE_COMMENT) THEN BEGIN
		    TX  = TXT[OK]
		    SUBS = []
		    FOR N=0, COUNT-1 DO BEGIN
		      T = TX[N]
		      IF STRPOS(T,';') EQ -1 OR STRPOS(T,FTEXT) LT STRPOS(T,';') THEN SUBS = [SUBS,N]
		    ENDFOR
		    IF SUBS NE [] THEN OK = OK[SUBS]
		    COUNT = N_ELEMENTS(SUBS)
		  ENDIF
			IF COUNT GE 1 THEN BEGIN
			  IF DTR NE [] THEN BEGIN ; Check if the file mtime is within the specified daterange
          JDM = GET_MTIME(FP.FULLNAME,/JD)
			    IF JDM LT DATE_2JD(DTR[0]) OR JDM GT DATE_2JD(DTR[1]) THEN CONTINUE
			  ENDIF
			  STRUCT[_FILE].FULLNAME = AFILE
			  STRUCT[_FILE].FILE  = FP.NAME
			  STRUCT[_FILE].LINE  = STRJOIN(STRTRIM(OK,2),'; ')
			  STRUCT[_FILE].MTIME = STRMID(GET_MTIME(FP.FULLNAME,/DATE),0,8)
			  IF FP.SUB EQ 'IDL_PROGRAMS' THEN STRUCT[_FILE].DIR = FP.L2SUB+SL+FP.SUB  ELSE STRUCT[_FILE].DIR = FP.SUB
		  ENDIF  	 
		ENDIF
	ENDFOR
	OK = WHERE(STRUCT.FILE NE '',COUNT)
	IF COUNT GE 1 THEN BEGIN
		STRUCT = STRUCT[OK]
		FILELIST=STRUCT.FULLNAME
		LI, STRUCT.FILE + ': in ' + STRUCT.DIR + ' -  on LINES: ' + STRUCT.LINE + ' (last modified: ' + STRUCT.MTIME + ')'
	ENDIF	ELSE PRINT, 'No matches found for ' + FTEXT
	

END; #####################  End of Routine ################################



