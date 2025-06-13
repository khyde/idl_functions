; $Id: DELIMITER.pro $  Sept 4, 2003
;+
;	This Function returns THE Appropriate Standard DELIMITER in a structure or individual DELIMITER upon NAME request
; HISTORY:
;		June 13, 2003	Written by:	J.E. O'Reilly, NOAA, 28 Tarzwell Drive, Narragansett, RI 02882
;-
; *************************************************************************
FUNCTION DELIMITER ,PATH=path,SLASH=slash,DOT=dot,DASH=dash,SPACE=space,ASTER=aster,COMMA=comma,UL=ul,EXCLAM=exclam,WORD=word
  ROUTINE_NAME='DELIMITER'

; ===================>
; Different DELIMITER for WIN, MAX, AND X DEVICES
  os = STRUPCASE(!VERSION.OS)
  IF OS EQ 'WIN32' THEN _slash = '\'
  IF OS EQ 'LINUX' THEN _slash = '/'
  IF OS EQ 'IRIX'  THEN _slash = '/'
  IF OS EQ 'OSF'   THEN _slash = '/'

  _PATH		=  _slash
	_DOT  	= 	'.'
  _DASH		=  	'-'
  _SPACE	=		' '
	_ASTER	=		'*'
	_COMMA	=		','
	_UL			=		'_'
	_EXCLAM =		'!'
	_WORD		=  	'-'

	IF N_ELEMENTS(PATH) 	EQ 1 THEN RETURN, _slash
	IF N_ELEMENTS(SLASH) 	EQ 1 THEN RETURN, _slash
	IF N_ELEMENTS(DOT) 		EQ 1 THEN RETURN, _DOT
  IF N_ELEMENTS(DASH) 	EQ 1 THEN RETURN, _DASH
  IF N_ELEMENTS(SPACE) 	EQ 1 THEN RETURN, _SPACE
	IF N_ELEMENTS(ASTER) 	EQ 1 THEN RETURN, _ASTER
	IF N_ELEMENTS(COMMA) 	EQ 1 THEN RETURN, _COMMA
	IF N_ELEMENTS(UL) 		EQ 1 THEN RETURN, _UL
	IF N_ELEMENTS(EXCLAM) EQ 1 THEN RETURN, _EXCLAM
	IF N_ELEMENTS(WORD) 	EQ 1 THEN RETURN, _WORD


  IF N_PARAMS() EQ 0 THEN BEGIN
  	s=CREATE_STRUCT('PATH',	_SLASH, $
  								'SLASH',	_SLASH, $
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

END; #####################  End of Routine ################################
