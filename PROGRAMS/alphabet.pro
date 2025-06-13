; $Id:	alphabet.pro,	January 24 2007	$

 FUNCTION ALPHABET, LOWER=lower, WIDTH=width
;+
; NAME:
; 	ALPHABET
;
; PURPOSE:
;		This Program Makes a string array of the Upper Case letters in the Alphabet
;
; CATEGORY:
;		STRING
;
; CALLING SEQUENCE:
;
;		Result = ALPHABET()
;
; INPUTS:
;		NONE Required
;
;	KEYWORD PARAMETERS:
;		LOWER.. Outputs lower case
;		WIDTH.. Width in characters (normally A B C  if WIDTH = 2 THEN AA BB CC)
;
; OUTPUTS:
;		This function returns a string array of the 26 letters of the alphabet
;
; EXAMPLE:
;		PRINT, ALPHABET()
;		PRINT, ALPHABET(/lower)
;		PRINT, ALPHABET(width=2)
;
; 	MODIFICATION HISTORY:
;			Written Nov 3, 2005 by J.O'Reilly, 28 Tarzwell Drive, NMFS, NOAA 02882 (Jay.O'Reilly@NOAA.GOV)
;-

;	****************************************************************************************************
	ROUTINE_NAME = 'ALPHABET'

	IF N_ELEMENTS(WIDTH) NE 1 THEN _WIDTH = 1 ELSE _WIDTH = WIDTH > 1

	START = 65B
	IF KEYWORD_SET(LOWER) THEN START = START + 32b
	N_LETTERS = 26

	LETTERS= STRTRIM(REFORM(BINDGEN(N_LETTERS)+START,1,N_LETTERS),2)
	TXT = LETTERS

;	LLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLL
 	FOR NTH=1,_WIDTH-1 DO BEGIN & TXT=TXT+LETTERS &  ENDFOR

	RETURN,TXT

END; #####################  End of Routine ################################



