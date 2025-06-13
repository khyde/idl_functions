; $ID:	PRO_PARAMS.PRO,	2020-06-30-17,	USER-KJWH	$

	FUNCTION PRO_PARAMS, File,  NO_COMMENT=NO_COMMENT, ERROR = error

;+
; NAME:
;		PRO_PARAMS
;
; PURPOSE:;
;		This function Returns the Parameters and KEYWORDS from IDL Programs (in the order they occur in the program)
;
; CATEGORY:
;		UTILITY
;
; CALLING SEQUENCE:
;
;		Result = PRO_PARAMS(File)
;
; INPUTS:
;		File:	Idl Program Name (pro)

;	KEYWORD_PARAMETERS:
;		NO_COMMENT: Prevents Formating the Parameter and Keyword Names for inclusion for standard docomentation in the IDL program
;
; OUTPUTS:
;		This function returns a list of the names of the Parameters and Keywords in the program
;
; RESTRICTIONS:
;		This routine assumes that the IDL program name specified in File is already COMPILED by IDL

;	PROCEDURE:
;		COMPILE the IDL Routine  (File)
;		Then:  names = PRO_PARAMS(File)
;
; EXAMPLE:
;		names = PRO_PARAMS(File)
;
; MODIFICATION HISTORY:
;			Written Jan 15, 2006 by J.O'Reilly, 28 Tarzwell Drive, NMFS, NOAA 02882 (Jay.O'Reilly@NOAA.GOV)
;-
;	****************************************************************************************************
	ROUTINE_NAME = 'PRO_PARAMS'
	ERROR = ''
	TAB = STRING(9B)
	SEMI = ';'
	COLON=':'
	DEC = '.'
	SPACE=' '

;	===> Parse the filename components
	fn=FILE_PARSE(FILE)
	AFILE = FN.DIR+FN.NAME
  AFILE=FILELIST(AFILE+'.pro')

 	PRO_NAME = STRUPCASE(FN.NAME)


;	****************************
;	*** Read the IDL Program ***
;	****************************
	TXT= READ_TXT(AFILE)

;	===> UPPERCASE AND COMPRESS
	TXT=STRCOMPRESS(STRUPCASE(TXT))

;	===. Trim Comments from Right Side of each line of TXT
  POS = STRPOS(TXT,SEMI,/REVERSE_SEARCH)
  POS = REFORM(POS,1,N_ELEMENTS(POS))
  OK=WHERE(POS GE 0,COUNT)
  IF COUNT GE 1 THEN BEGIN
  	_POS = POS(*,OK)+1
  	TXT[OK] = STRMID(TXT[OK],_POS)
	ENDIF

;	===> Remove any blank lines
	OK=WHERE(STRLEN(TXT) NE 0,COUNT)
	IF COUNT GE 1 THEN  TXT = TXT[OK]

;	===> TARGETS used to IDENTIFY the start of the Routine name
	TARGETS = ['PRO','FUNCTION']+' ' +STRUPCASE(FN.NAME)

;	===> Find the target
	OK_ROUTINE = WHERE_STRING(TXT,TARGETS,COUNT)
	IF COUNT EQ 0 THEN BEGIN
		ERROR='Can not find start of routine'
		RETURN,''
	ENDIF

;	===> Eliminate lines before the Routine Name
	TXT=TXT(OK_ROUTINE[0]:*)

;	===> Use IDL's HELP to get the Parameters and KEYWORDS the Routine Uses
	HELP,NAME=PRO_NAME, /ROUTINES,OUTPUT=OUTPUT


;	===> Remove 'Compiled Procedures'
	OK=WHERE_STRING(STRUPCASE(OUTPUT),'COMPILED',COUNT,NCOMPLEMENT=NCOMPLEMENT,COMPLEMENT=COMPLEMENT)
	IF COUNT GE 1 THEN OUTPUT[OK] = ''

;	===> Find the Routine name in OUTPUT and remove it, leaving parameters and keywords
	OK=WHERE_STRING(OUTPUT,PRO_NAME,COUNT)
	OUTPUT = OUTPUT(OK[0]:*)

	OUTPUT = STRCOMPRESS(OUTPUT)

;	===> PARSE NAMES IN THE OUTPUT
	NAMES = STR_BREAK(OUTPUT,' ')

;	===> Remove null lines
	OK=WHERE(STRLEN(NAMES) GE 1)
	NAMES=NAMES[OK]
	NAMES=NAMES(1:*)


;	===> Find each parameter/keyword in the TXT
	LINE= -1
	POS = -1

;	LLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLL
	FOR NTH = 0,N_ELEMENTS(NAMES)-1 DO BEGIN
		APARAM = STRUPCASE(NAMES[NTH])
		OK=WHERE_STRING(TXT, APARAM)
		T = TXT(OK[0])
		LINE = [LINE,OK[0]]
		POS = [POS, STRPOS(T,APARAM)]
	ENDFOR

	POS=POS(1:*)
	LINE=LINE(1:*)

;	===> Make up a sorting string
	SRT = STR_JOIN(LINE, POS,/PAD,DELIM='$')
	S=SORT(SRT)
	NAMES=NAMES(S)


;	===> NOTE that IDL keeps PARAMS lower case and KEYWORDS upper case
	OK_PARAM=WHERE(STRUPCASE(NAMES) NE NAMES,COUNT_PARAM,NCOMPLEMENT=NCOMPLEMENT,COMPLEMENT=COMPLEMENT)


;	===> Format the RETURNED NAMES for use in the program documentation ?
	IF KEYWORD_SET(NO_COMMENT) THEN BEGIN
;		===> Only rearrange if there are some non-keywords (parameters)
		IF COUNT_PARAM GE 1 AND NCOMPLEMENT GE 1 THEN NAMES = NAMES([OK_PARAM,COMPLEMENT] )
	ENDIF ELSE BEGIN

;		===> Pad all names to be same length
 		NAMES = NAMES+SPACE

		len=MAX(STRLEN(NAMES))

		NAMES = BYTE(NAMES)
		OK=WHERE(NAMES EQ 0B,COUNT)
		IF COUNT GE 1 THEN NAMES[OK] = BYTE(DEC)
		OK=WHERE(NAMES EQ 32B,COUNT)
		IF COUNT GE 1 THEN NAMES[OK] = BYTE(DEC)
		NAMES = STRING(NAMES)
		ALL = ''
		IF COUNT_PARAM GE 1 THEN ALL = [ALL, SEMI+TAB+'INPUTS:', SEMI+TAB+TAB+ STR_CAP(NAMES(OK_PARAM))]
		IF NCOMPLEMENT GE 1 THEN ALL = [ALL, SEMI+TAB+'KEYWORD PARAMETERS:', SEMI+TAB+TAB+NAMES(COMPLEMENT)]
	  NAMES = ALL(1:*)

	ENDELSE

 	RETURN, NAMES


	END; #####################  End of Routine ################################
