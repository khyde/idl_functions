; $ID:	PRO_CALLS.PRO,	2020-06-26-15,	USER-KJWH	$

	FUNCTION PRO_CALLS, PROGRAM, DIR_PRO=dir_pro, DIR_OUT=dir_out, CSV=csv

;+
; NAME:
;		TEMPLATE
;
; PURPOSE:;
;		This FUNCTION will search through all available programs in a given directory (default='D:\IDL\PROGRAMS\')
;     for a given program call
;
; CATEGORY:
;
;
; CALLING SEQUENCE:
;		RESULT = PRO_CALLS('SD_SCALES', DIR_PRO='D:\IDL\PROGRAMS\')
;		RESULT = PRO_CALLS('SD_SCALES', DIR_PRO='D:\IDL\PROGRAMS\', DIR_OUT='D:\IDL\PRO_CALLS\' ,/CSV)	   To write the result as a csv file

; INPUTS:
;		PROGRAM:		Program name to look for
;		DIR_PRO:		Program directory
;		DIR_OUT:		Output directory for the CSV file
;
; OPTIONAL INPUTS:
;		CSV:        Option to write the results as a CSV file
;
; OUTPUTS:
;		A list of program names and line numbers
;
;
;	NOTES:
;
;
; MODIFICATION HISTORY:
;			Written Jul 20, 2007 by K.J.W.Hyde, 28 Tarzwell Drive, NMFS, NOAA 02882 (kimberly.hyde@noaa.gov)
;-
;	****************************************************************************************************
	ROUTINE_NAME = 'PRO_CALLS'

	IF N_ELEMENTS(PROGRAM) EQ 0 THEN BEGIN
		PRINT, 'ERROR: Must provide input program name'
		STOP
	ENDIF

	IF N_ELEMENTS(DIR_PRO) EQ 0 THEN _DIR_PRO = 'D:\IDL\PROGRAMS\' ELSE _DIR_PRO = DIR_PRO
	IF FILE_TEST(_DIR_PRO,/DIR) EQ 0 THEN _DIR_PRO = 'D:\IDL\PROGRAMS\'
	IF N_ELEMENTS(DIR_OUT) EQ 0 THEN _DIR_OUT = 'D:\IDL\PRO_CALLS\' ELSE _DIR_OUT = DIR_OUT
	IF FILE_TEST(_DIR_OUT,/DIR) EQ 0 THEN FILE_MKDIR,_DIR_OUT

	PRO_FILES = FILE_SEARCH(_DIR_PRO + '*.PRO')

	FOR _PRO = 0L, N_ELEMENTS(PROGRAM)-1 DO BEGIN
		APRO = PROGRAM(_PRO)
		OUTFILE = _DIR_OUT + ROUTINE_NAME + '-' + APRO + '.CSV'
		STRUCT = CREATE_STRUCT('PROGRAM','', 'LINE','')
		STRUCT = STRUCT_2MISSINGS(STRUCT)
		STRUCT = REPLICATE(STRUCT,N_ELEMENTS(PRO_FILES))
		FOR _FILE =0L, N_ELEMENTS(PRO_FILES)-1 DO BEGIN
			AFILE = PRO_FILES(_FILE)
			FP = FILE_PARSE(AFILE)
			TXT = READ_TXT(AFILE)
			OK = WHERE_STRING(STRUPCASE(TXT),STRUPCASE(APRO),COUNT)
			IF COUNT GE 1 THEN BEGIN
				STRUCT(_FILE).PROGRAM = FP.NAME
				STRUCT(_FILE).LINE = STRJOIN(STRTRIM(OK,2),';')
			ENDIF
		ENDFOR
		OK = WHERE(STRUCT.PROGRAM NE '',COUNT)
		IF COUNT GE 1 THEN STRUCT = STRUCT[OK] ELSE BEGIN
			STRUCT = ''
			PRINT, 'No matches found for ' + APRO
			CONTINUE
		ENDELSE
		IF KEYWORD_SET(CSV) THEN STRUCT_2CSV,OUTFILE, STRUCT ELSE LIST, STRUCT.PROGRAM
	ENDFOR
  RETURN, STRUCT



END; #####################  End of Routine ################################
