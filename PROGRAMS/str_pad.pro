; $ID:	STR_PAD.PRO,	2020-06-30-17,	USER-KJWH	$

 FUNCTION STR_PAD, DATA, WIDTH, CHAR=char
;+
; NAME:
; 	STR_PAD

;		This Function Converts Data into String and PADS any blank characters with CHAR
;   The default CHAR is '0'
;
; SYNTAX:
;		Result = STR_PAD(Data, 4,char='0')
;		Result = STR_PAD(Data, 4)
;
; OUTPUT:
;
;
; ARGUMENTS:
;		DATA: The data to convert to string
;		WIDTH: Width (# characters) for output string
;					 If WIDTH is less than MAX(STRLEN(STRTRIM(Data,2)) then WIDTH IS IGNORED
;
; KEYWORDS:
;
;		CHAR: The single string character to use in the padding
;
;
; EXAMPLEs:
;		PRINT, STR_PAD('AB CD',0)
;		PRINT, STR_PAD('23',4,char='0')
;
;	NOTES:
;
; MODIFICATION HISTORY:
;		Written Jan 17, 2005 by J.O'Reilly, 28 Tarzwell Drive, NMFS, NOAA 02882 (Jay.O'Reilly@NOAA.GOV)
;-

ROUTINE_NAME='STR_PAD'


;	===> Convert data to String Type
	STR	= STRTRIM(DATA,2)

	IF N_ELEMENTS(WIDTH) 	EQ 0 THEN  LEN 	=  MAX(STRLEN(DATA))  ELSE LEN = WIDTH

	IF N_ELEMENTS(CHAR) 	NE 1 THEN _CHAR = BYTE(STRTRIM(0,2)) ELSE _CHAR = BYTE(STRTRIM(CHAR,2))
	_CHAR = _CHAR[0]

;	===> LEN will be the maximum width of any input array or LEN if LEN is greater
	LEN 	= STRTRIM( MAX(STRLEN(STR)) > LEN , 2)

;	===> Determine maximum length of strings so they may padded with leading zeros
 	FMT   = '(A'+LEN+')'
	RETURN, STR_SPACE2CHAR(STRING(STR,FORMAT=FMT), _char)


END; #####################  End of Routine ################################



