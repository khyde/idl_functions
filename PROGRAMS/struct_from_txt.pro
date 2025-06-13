; $ID:	STRUCT_FROM_TXT.PRO,	2020-06-30-17,	USER-KJWH	$
;+
;	This Function returns a Structure array from Comma-Delimated Text array
;	STRUCT_FROM_TXT

; HISTORY:
;		June 10, 2003 Written by:	J.E. O'Reilly, NOAA, 28 Tarzwell Drive, Narragansett, RI 02882
;-
; *************************************************************************

FUNCTION STRUCT_FROM_TXT, TEXT, DELIM=delim
  ROUTINE_NAME='STRUCT_FROM_TXT'

; ===> Default Text delimiter is a comma
  IF N_ELEMENTS(DELIM) NE 1 THEN _DELIM= "," ELSE _DELIM = DELIM
  BDELIM = BYTE(_DELIM) & BDELIM=BDELIM[0]

; ===> Determine the number of overall columns
  MAX_COL = -1
  FOR NTH=0L,N_ELEMENTS(TEXT)-1L DO BEGIN
    OK = WHERE(BYTE(TEXT[NTH]) EQ BDELIM,COUNT)
    MAX_COL = MAX_COL > COUNT
  ENDFOR
  MAX_COL=MAX_COL + 1

; === Make a temporary structure to hold all columns
  NAMES = '_'+STRTRIM(INDGEN(MAX_COL),2)
  STR   = REPLICATE('',MAX_COL)
  FOR NTH=0L,N_ELEMENTS(NAMES)-1L DO BEGIN
  	IF NTH EQ 0 THEN struct=CREATE_STRUCT(NAMES(nth),STR(nth)) ELSE struct= CREATE_STRUCT(STRUCT,NAMES(nth),STR(nth))
  ENDFOR
  STRUCT=REPLICATE(STRUCT,N_ELEMENTS(TEXT))

; ===> Now fill the struct with all data in the spreadsheet, from left to right
	FOR NTH=0L,N_ELEMENTS(TEXT)-1L DO BEGIN
    TXT = STRTRIM(STRSPLIT(TEXT(nth),_DELIM,/EXTRACT,/PRESERVE_NULL),2)
    NUM=N_ELEMENTS(TXT)
    FOR TAG =0,NUM-1L DO BEGIN
    	STRUCT[NTH].(TAG) = STRTRIM(TXT(TAG),2)
    ENDFOR
  ENDFOR

  RETURN,STRUCT
END; #####################  End of Routine ################################
