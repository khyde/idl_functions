; $ID:	IDL_PARAMS.PRO,	2020-06-30-17,	USER-KJWH	$

	FUNCTION IDL_PARAMS, File,  ERROR = error

;+
; NAME:
;		IDL_PARAMS
;
; PURPOSE:;
;		This function Returns the Parameters and KEYWORDS from IDL Programs
;
;
; CATEGORY:
;		UTILITY
;
; CALLING SEQUENCE:
;
;		Result = IDL_PARAMS(File)
;
; INPUTS:
;		File:	Idl Program Name (pro)
;
; OUTPUTS:
;		This function returns a list of the names of the Parameters and Keywords in the program
;
; RESTRICTIONS:

;	PROCEDURE:
; EXAMPLE:
;

; MODIFICATION HISTORY:
;			Written Jan 15, 2006 by J.O'Reilly, 28 Tarzwell Drive, NMFS, NOAA 02882 (Jay.O'Reilly@NOAA.GOV)
;-
;	****************************************************************************************************
	ROUTINE_NAME = 'IDL_PARAMS'
	ERROR = ''

;	===> Parse the filename components
	fn=FILE_PARSE(FILE)
	AFILE = FN.DIR+FN.NAME
  AFILE=FILELIST(AFILE+'.pro')

;	===> TARGETS
	TARGETS = ['PRO','FUNCTION']+' ' +STRUPCASE(FN.NAME)

	TXT= READ_TXT(AFILE)
	ANAME = STRUPCASE(FN.NAME)

	HELP,NAME=ANAME, /ROUTINES,OUTPUT=OUTPUT
	OK=WHERE_STRING(OUTPUT,ANAME,COUNT)
	OUTPUT = OUTPUT(OK[0]:*)

	OUTPUT = STRCOMPRESS(OUTPUT)

;	===> PARSE NAMES IN THE OUTPUT
	PARAMS = STR_BREAK(OUTPUT,' ')

;	===> Remove null lines
	OK=WHERE(STRLEN(PARAMS) GE 1)
	PARAMS=PARAMS[OK]


;	===> NOTE that IDL keeps PARAMS lower case and KEYWORDS upper case



		LINE= STRTRIM(TXT(LINE_START),2)
		STOP
;		===> If no $ present at the end of the line then need only process one one
	  WHILE STRPOS(LINE,'$',/REVERSE_SEARCH) EQ STRLEN(LINE)-1 DO BEGIN
	    LINE_END=LINE_END+1
	    LINE=TXT(LINE_END)
		ENDWHILE

STOP
END




	IF COUNT_START OR COUNT_END EQ 0 THEN BEGIN
		ERROR='Can not find PRO or FUNCTION'
		RETURN,' '
	ENDIF


	PRINT, TXT(LINE_START)

stop




	END; #####################  End of Routine ################################
