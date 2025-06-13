; $ID:	FILE_PARSE.PRO,	2023-09-21-13,	USER-KJWH	$

FUNCTION FILE_PARSE,FILES, WITH_PERIOD=WITH_PERIOD

;+
; NAME:
;   FILE_PARSE
;
;	PURPOSE:
;		This function parses the path and file name into its components and returns a structure
;
; CATEGORY:
;   FILE functions
;
;	CALLING SEQUENCE::
;		RESULT = FILE_PARSE(FILES)
;
;	REQUIRED INPUTS:
;		FILES............ An array of file names (typically full names including the path)
;
; OPTIONAL_INPUTS:
;   None
;	
;	KEYWORDS
;		WITH_PERIOD...... Keeps a period '.' in the extension (e.g. .PNG instead of the defailt PNG)
;
; OUTPUT:
;		An IDL structure containing the parsed components of the file name
;
; OPTIONAL OUTPUT:
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
; EXAMPLES:
;    ST, FILE_PARSE(!S.OC+'SEAWIFS/L3B2/STATS/CHLOR_A-OCI/M_200401-SEAWIFS-R2015-L3B2-CHLOR_A-OCI-STATS.SAV',/ALL)
;
; NOTES:
;
;
; COPYRIGHT:
; Copyright (C) 2018, Department of Commerce, National Oceanic and Atmospheric Administration, National Marine Fisheries Service,
;   Northeast Fisheries Science Center, Narragansett Laboratory.
;   This software may be used, copied, or redistributed as long as it is not sold and this copyright notice is reproduced on each copy made.
;   This routine is provided AS IS without any express or implied warranties whatsoever.
;
; AUTOR:
;   This program was written on November 14, 1994 by John E. O'Reilly, NOAA/NEFSC/Narragansett Laboratory, 28 Tarzwell Drive, 02882
;     with assistance from Kimberly Hyde, DOC/NOAA/NMFS/NEFSC Narragansett, RI, kimberly.hyde@noaa.gov
;     Inquiries should be directed to kimberly.hyde@noaa.gov.
;
; MODIFICATION HISTORY:
;		MAR 12, 1995 - JEOR: Can now input multiple files
;		JUN 13, 1995 - JEOR: Fixed problem with files with no extension
;		DEC 15, 1995 - JEOR: Fixed problem with multiple files parse
;                        Must initialize variables for each file
;		DEC 19, 1995 - JEOR: Added keyword:  WITH_PERIOD
;		MAR 21, 1995 - JEOR: Determines different directory delimiters used by WIN, MAX, and X devices
;		JUL 7,  1997 - JEOR: Added delimiter for printer device
;		SEP 25, 2000 - JEOR: Now the delimiter is determined according to the operating system (!VERSION.OS)
;		SEP 28, 2000 - JEOR: Added first_name to structure (this is useful when there are several extensions to the name, e.g. SAMPLE.DAT.Z  or SAMPLE.DAT.ZIP)
;		JAN 03, 2001 - JEOR: Added tag 'EXT_DELIM'
;		JUL 25, 2002 - JEOR: Changed so files parameter is not corrupted
;		SEP 20, 2006 - JEOR: Now using IDL PATH_SEP routine to obtaine the path delimiter
;		DEC 1,  2006 - JEOR: Added drive information to structure
;		DEC 12, 2006 - JEOR: Drive now includes the PATH_SEP()
;   AUG 12, 2013 - JEOR: Formatting
;   JAN 22, 2015 - KJWH: Added FIX_PATH(FILE) to correct the slash
;   FEB 16, 2016 - KJWH: Added a fix for when FILES = []
;   OCT 13, 2020 - KJWH: Updated documentation
;                        Added COMPILE_OPT IDL2
;                        Changed subscript () to []
;                        Moved to FILE_FUNCTIONS
;   OCT 15, 2021 - KJWH: Changed how the directory subscripts are being found - now subset the text based on the last delimiter and then use STR_BREAK to get the different directories
;                        Added L2SUB to get the directory name just about the SUB directory                     
;-
;*************************************************************************************************************************
  ROUTINE_NAME  = 'FILE_PARSE'
  COMPILE_OPT IDL2
  
  IF FILES EQ [] THEN FILES = ''

;===>  Create a structure to hold the details of the file name(s): DIRECTORY, LAST SUB DIRECTORY, NAME, EXTENSION
   FILENAME = {FULLNAME:'',DRIVE:'',DIR:'',SUB:'',L2SUB:'',NAME:'',NAME_EXT:'',FIRST_NAME:'',EXT_DELIM:'',EXT:''}
   STRUCT = REPLICATE(FILENAME,N_ELEMENTS(FILES))

;	===> Eliminate all leading and trailing blanks from file name
	FILE_ARR = FIX_PATH(FILES)
 	FILE_ARR = STRTRIM(FILE_ARR,2)


	FOR F = 0L, (N_ELEMENTS(FILE_ARR) -1L) DO BEGIN
; 	===> Initialize variables
	  I = 0
	  NAME_BEG = -1
	  SUBDIRS = INTARR(50)
	  SUBDIRS[*] = -1
	  AFILE = FILE_ARR[F]
	  FILENAME.FULLNAME = AFILE

; ===> Assume the drive delimiter is ':' for Windows
		DELIM = ':'
		TXT = STRSPLIT(AFILE,DELIM,/EXTRACT) 
		IF N_ELEMENTS(TXT) EQ 2 THEN BEGIN
			FILENAME.DRIVE = TXT[0]+DELIM+PATH_SEP()
		ENDIF

; ===> Determine starting point of file name and fill subdirs array with character locations of the delimiter
    DELIM = PATH_SEP()  ; Get the directory delimiter 
    LAST_SLASH = STRPOS(AFILE,DELIM,/REVERSE_SEARCH)
    IF LAST_SLASH GT 0 THEN BEGIN
      FULLDIR = STRMID(AFILE,0,LAST_SLASH)
      ALLDIRS = STR_BREAK(FULLDIR,DELIM)
      FILENAME.SUB = ALLDIRS[-1]  ; Get the last sub
      IF N_ELEMENTS(ALLDIRS) GT 1 THEN FILENAME.L2SUB = ALLDIRS[-2]
    ENDIF
    
    
    N = -1
  	WHILE (I NE -1) DO BEGIN
    	I =  STRPOS(AFILE,DELIM,I)
      IF I NE -1 THEN BEGIN
        N = N + 1
        SUBDIRS[N] = I+1
        I = I + 1
        NAME_BEG = I
    	ENDIF
  	ENDWHILE

; ===> If no delimiters for path present then assume name begins at first non-blank character
    IF NAME_BEG EQ -1 THEN NAME_BEG = STRPOS(AFILE,' ',0 ) +1

; ===> Determine if there is more than one delimiter (if so then there is at least one subdirectory)
    OK_LAST_SUB = WHERE(SUBDIRS NE -1,COUNT)

;   	IF COUNT GE 2 THEN BEGIN ; If none, FILENAME.SUB remains empty
;     	SUBDIRS = SUBDIRS[OK_LAST_SUB]
;     	WIDTH = SUBDIRS[COUNT-1] - SUBDIRS[COUNT-2]-1
;     	FILENAME.SUB = STRMID(AFILE,SUBDIRS[COUNT-2],WIDTH)
;   	ENDIF

; ===> Determine beginning and ending positions of directory path
   	DIR_END = NAME_BEG -1
   	DIR_BEG = 0
   	IF DIR_END LT DIR_BEG THEN DIR_END = 0
   	WIDTH = DIR_END - DIR_BEG + 1

    IF WIDTH EQ 1 THEN BEGIN
  		FILENAME.DIR = ''
    ENDIF ELSE BEGIN
    	FILENAME.DIR = STRMID(AFILE,DIR_BEG,WIDTH)
   	ENDELSE

;   ===> DETERMINE ENDING POSITION OF FILE NAME(S)
   	I = 0
   	DELIM = '.'
   	PERIOD = -1

;		WWWWWWWWWWWWWWWWWWWWWWWWW
    WHILE (I NE -1) DO BEGIN
    	I = STRPOS(AFILE,DELIM,I)
    	IF I NE -1 THEN BEGIN
      	I = I + 1
        NAME_END = I -2
        PERIOD   = I -1
        EXT_BEG  = I
        IF KEYWORD_SET(WITH_PERIOD) THEN _EXT_BEG  = I-1 ELSE _EXT_BEG = I
     	ENDIF
   	ENDWHILE

   	IF PERIOD EQ -1 THEN BEGIN
	   	NAME_END = STRLEN(AFILE)-1
	   	EXT_BEG  = NAME_END +1
	   	_EXT_BEG = EXT_BEG
    ENDIF


    IF EXT_BEG-NAME_END EQ 2 THEN FILENAME.EXT_DELIM='.' ELSE FILENAME.EXT_DELIM = ''

; ===> Now determine ending position of file extension(s)
    EXT_END = STRLEN(STRCOMPRESS(AFILE))-1
   	FILENAME.NAME =STRMID(AFILE,NAME_BEG,NAME_END - NAME_BEG + 1)
   	FILENAME.EXT  =STRMID(AFILE, _EXT_BEG, EXT_END - _EXT_BEG + 1)


; ===> Determine first name in name
    I = 0
    DELIM = '.'
    PERIOD = -1
    I = STRPOS(FILENAME.NAME,DELIM,I)
    IF I NE -1 THEN BEGIN
      I = I + 1
      NAME_END = I -2
      PERIOD   = I -1
      EXT_BEG  = I
      I= -1
   	ENDIF
    IF PERIOD EQ -1 THEN BEGIN
      NAME_END = STRLEN(FILENAME.NAME)-1
      EXT_BEG  = NAME_END +1
    ENDIF
    FILENAME.FIRST_NAME =STRMID(FILENAME.NAME,0,NAME_END + 1)
    FILENAME.NAME_EXT = FILENAME.NAME+FILENAME.EXT_DELIM+FILENAME.EXT

;   ===>
    STRUCT[F] = FILENAME

	ENDFOR ; (FOR _FILE_ARR = 0, (N_ELEMENTS(FILE_ARR) -1) DO BEGIN)

	RETURN, STRUCT


END; #####################  END OF ROUTINE ################################
