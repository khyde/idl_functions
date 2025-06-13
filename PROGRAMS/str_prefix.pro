; $Id:	STR_PREFIX.PRO,	2003 Dec 02 15:41	$

 FUNCTION STR_PREFIX, DATA, WIDTH, PREFIX=prefix
;+
; NAME:
; 	STR_PREFIX

;		This Function Converts Data into String and adds a String Prefix (Default are '000' ) to the data
;		so that the number of characters in the string are identical
;
; SYNTAX:
;		Result = STRUCT_JOIN(Struct1, Struct2)
;
; OUTPUT:
;
;
; ARGUMENTS:
;
;
; KEYWORDS:
;
;		TAGNAMES: The tagname(s) to use to join the Structures (REQUIRED INPUT)
;
;
; EXAMPLE:
;
;
;	NOTES:
;
; MODIFICATION HISTORY:
;		Written Dec 17, 2005 by J.O'Reilly, 28 Tarzwell Drive, NMFS, NOAA 02882 (Jay.O'Reilly@NOAA.GOV)
;-

ROUTINE_NAME='STR_PREFIX'

	N_DATA = N_ELEMENTS(DATA)


;	===> Convert data to String Type
	STR	= STRTRIM(DATA,2)

	IF N_ELEMENTS(WIDTH) EQ 0 THEN  LEN 	=  MAX(STRLEN(DATA))  ELSE LEN = WIDTH


	LEN = STRTRIM(LEN,2)

;	===> Determine maximum length of strings so they may padded with leading zeros
 	FMT   = '(A'+LEN+')'
	STR= STRING(STR,FORMAT=FMT)

	IF N_ELEMENTS(PREFIX) NE 1 THEN STR  = STR_SPACE2ZERO(STR) ELSE STR = REPLACE_ALPHA(STR,PREFIX)

	RETURN, STR


END; #####################  End of Routine ################################



