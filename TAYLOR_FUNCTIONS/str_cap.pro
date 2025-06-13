; $Id:	str_cap.pro,	March 01 2007	$

	FUNCTION STR_CAP, Text, ALL=all, DELIM=delim, ERROR=error

;+
; NAME:
;		STR_CAP
;
; PURPOSE:;
;		This function Capitalizes the first letter of the text provided.
;
; CATEGORY:
;		STRING
;
; CALLING SEQUENCE:

;		Result = STR_CAP(Text)
;
; INPUTS:
;		Text:	String Type
;
;	KEYWORD PARAMETERS:
;		ALL: 	Capitalize the first letter of ALL words on each line of input TEXT
;		DELIM: Delimiter for parsing words (default is spaces)
;		ERROR: Error message
;
; OUTPUTS:
;		String with the first letter upper case
;
; EXAMPLE:
;		===> Capitalize the first letter of the first word on each line of text
;   PRINT,STR_CAP(['hELLo gOODBY' , '   hELLO          gOODBY    '],DELIM= ' ')
;		===> Capitalize the first letter of all words on each line of text
;		PRINT,STR_CAP(['hELLo gOODBY' , '   hELLO          gOODBY    '],DELIM= ' ',/ALL)
;
;	NOTES:
;		A Future improvement might be to prevent any case changes to restricted phrases such as '!C' used in
;		plotting strings via XYOUTS
;
;
; MODIFICATION HISTORY:
;			Written Nov 11, 2006 by J.O'Reilly, 28 Tarzwell Drive, NMFS, NOAA 02882 (Jay.O'Reilly@NOAA.GOV)
;-
;	****************************************************************************************************
	ROUTINE_NAME = 'STR_CAP'

;	===> Initialize ERROR to a null string. If errors are encountered ERROR will be set to a message.
;			 The calling routine can check error (e.g.IF ERROR NE 0 then there was a problem and do this or that)
	ERROR = ''

;	===> Default delimiter for parsing words is blank(s)
	IF N_ELEMENTS(DELIM) NE 1 THEN _DELIM = ' ' ELSE _DELIM = DELIM
	IF _DELIM EQ '' THEN _DELIM = ' '


		TXT=TEXT
;	LLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLL
	FOR NTH=0,N_ELEMENTS(TXT)-1L DO BEGIN
		T = STRSPLIT( TXT(NTH),_DELIM,/EXTRACT,/PRESERVE_NULL)

		OK=WHERE(STRLEN(T) GE 1,COUNT)

		IF COUNT GE 1 THEN BEGIN
			IF NOT KEYWORD_SET(ALL) THEN BEGIN
				T(OK(0)) = STRUPCASE(STRMID(T(OK(0)),0,1)) + STRLOWCASE(STRMID(T(OK(0)),1))
			ENDIF ELSE BEGIN
				T(OK) = STRUPCASE(STRMID(T(OK),0,1)) + STRLOWCASE(STRMID(T(OK),1))
			ENDELSE
		ENDIF

		IF N_ELEMENTS(T) EQ 1 THEN TXT(NTH) = T ELSE TXT(NTH) = STRJOIN(T+_DELIM)
	ENDFOR

RETURN, TXT



	END; #####################  End of Routine ################################
