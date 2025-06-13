; $ID:	TXT_2STRUCT.PRO,	2020-06-30-17,	USER-KJWH	$
;+
;	This Function returns a Structure array from a delimited Text array
;	TXT_2STRUCT

;	TEXT
;	DELIM
; TAGNAMES
;	ERROR:     Any Error messages are placed in ERROR, if no errors then ERROR = ''

; HISTORY:
;		June 10, 2003 Written by:	J.E. O'Reilly, NOAA, 28 Tarzwell Drive, Narragansett, RI 02882
;-
; *************************************************************************

FUNCTION TXT_2STRUCT, TEXT, DELIM=delim, TAGNAMES=tagnames
  ROUTINE_NAME='TXT_2STRUCT'


;	===> If DELIM not provided then assume comma delimited
  IF N_ELEMENTS(DELIM) NE 1 THEN  DELIM=',' ELSE DELIM = DELIM  ; DEFAULT IS ASSUME COMMA-DELIMED

  IF STRUPCASE(DELIM) EQ 'TAB' 		THEN DELIM=STRING(BYTE(9)) ; ASCII FOR TAB
  IF STRUPCASE(DELIM) EQ 'COMMA' 	THEN DELIM=','
  IF STRUPCASE(DELIM) EQ 'SPACE' 	THEN DELIM=' '


  BDELIM = BYTE(DELIM) & BDELIM=BDELIM[0]

; ===> Determine the number of overall columns
  MAX_COL = MAX(TOTAL(BYTE(TEXT) EQ BDELIM,1)) +1


; === Make a temporary structure to hold all columns
  NAMES = '_'+STRTRIM(INDGEN(MAX_COL),2)
  STR   = REPLICATE('',MAX_COL)
  FOR NTH=0L,N_ELEMENTS(NAMES)-1L DO BEGIN
  	IF NTH EQ 0 THEN struct=CREATE_STRUCT(NAMES(nth),STR(nth)) ELSE struct= CREATE_STRUCT(STRUCT,NAMES(nth),STR(nth))
  ENDFOR
  STRUCT=REPLICATE(STRUCT,N_ELEMENTS(TEXT))


; ===> Now fill the struct with all data in the spreadsheet, from left to right
	FOR NTH=0L,N_ELEMENTS(TEXT)-1L DO BEGIN
    TXT = STRTRIM(STRSPLIT(TEXT(nth),DELIM,/EXTRACT,/PRESERVE_NULL),2)
    NUM=N_ELEMENTS(TXT)
    FOR TAG =0,NUM-1L DO BEGIN
    	STRUCT[NTH].(TAG) = STRTRIM(TXT(TAG),2)
    ENDFOR
  ENDFOR

;	===> Rename Structure if TAGNAMES are provided and the number of TAGNAMES equals the number of tags in the structure
	IF N_ELEMENTS(TAGNAMES) EQ N_TAGS(STRUCT) THEN BEGIN
;		===> ENSURE THAT TAGNAMES ARE NOT NULL
		OK=WHERE(TAGNAMES EQ '',COUNT)
		IF COUNT GE 1 THEN TAGNAMES[OK]='_'+STRTRIM(OK,2)
	STRUCT=STRUCT_RENAME(STRUCT,TAG_NAMES(STRUCT),TAGNAMES)
	ENDIF

  RETURN,STRUCT
END; #####################  End of Routine ################################
