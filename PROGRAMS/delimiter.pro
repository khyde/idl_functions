; $ID:	DELIMITER.PRO,	MARCH 29,2012 	$
;+
;	THIS FUNCTION RETURNS THE APPROPRIATE STANDARD DELIMITER IN A STRUCTURE OR INDIVIDUAL DELIMITER UPON NAME REQUEST
; HISTORY:
;		JUNE 13, 2003	WRITTEN BY:	J.E. O'REILLY, NOAA, 28 TARZWELL DRIVE, NARRAGANSETT, RI 02882
;		MAR 29,2012,JOR, NOW USING PATH_SEP
;-
;###############################################################################################################################
FUNCTION DELIMITER ,PATH=PATH,SLASH=SLASH,DOT=DOT,DASH=DASH,SPACE=SPACE,ASTER=ASTER,COMMA=COMMA,UL=UL,EXCLAM=EXCLAM,WORD=WORD
;**************************************************  
  ROUTINE_NAME='DELIMITER'
;**************************************************  

; ===> DEFINE DELIMITERS
_PATH = PATH_SEP()
_DOT  	= 	'.'
_DASH		=  	'-'
_SPACE	=		' '
_ASTER	=		'*'
_COMMA	=		','
_UL			=		'_'
_EXCLAM =		'!'
_WORD		=  	'-'

	IF N_ELEMENTS(PATH) 	EQ 1 THEN RETURN, _PATH
	IF N_ELEMENTS(SLASH) 	EQ 1 THEN RETURN, _PATH
	IF N_ELEMENTS(DOT) 		EQ 1 THEN RETURN, _DOT
  IF N_ELEMENTS(DASH) 	EQ 1 THEN RETURN, _DASH
  IF N_ELEMENTS(SPACE) 	EQ 1 THEN RETURN, _SPACE
	IF N_ELEMENTS(ASTER) 	EQ 1 THEN RETURN, _ASTER
	IF N_ELEMENTS(COMMA) 	EQ 1 THEN RETURN, _COMMA
	IF N_ELEMENTS(UL) 		EQ 1 THEN RETURN, _UL
	IF N_ELEMENTS(EXCLAM) EQ 1 THEN RETURN, _EXCLAM
	IF N_ELEMENTS(WORD) 	EQ 1 THEN RETURN, _WORD


  IF N_PARAMS() EQ 0 THEN BEGIN
  	S=CREATE_STRUCT('PATH',	_PATH, $
  								'SLASH',	_PATH, $
  								'DOT',		_DOT,$
  								'DASH',		_DASH,$
  								'SPACE',  _SPACE,$
  								'ASTER',	_ASTER,$
  								'COMMA',	_COMMA,$
  								'UL',			_UL,$
  								'EXCLAM',	_EXCLAM,$
  								'WORD',		_WORD)

  	RETURN, S
  ENDIF

  RETURN,''

END; #####################  END OF ROUTINE ################################
