; $Id: PARSE_WORD.pro $  VERSION: March 26,2002
;+
;
;		June 15, 2003	Written by:	J.E. O'Reilly, NOAA, 28 Tarzwell Drive, Narragansett, RI 02882
;-
; *************************************************************************

 FUNCTION PARSE_WORD,TEXT, COUNT, DELIM=delim
  ROUTINE_NAME='WORD_PARSE'
  IF N_ELEMENTS(DELIM) NE 1 THEN _DELIM = DELIMITER(/UL) ELSE _DELIM = DELIM
  	TXT = STRSPLIT(TEXT,_DELIM,/EXTRACT,/PRESERVE_NULL)
  	COUNT = N_ELEMENTS(TXT)
  RETURN, TXT

END; #####################  End of Routine ################################
