; $ID:	READ_DELIMITED.PRO,	2020-06-30-17,	USER-KJWH	$
;+
;	This Function Reads a TEXT file that is DELIMITED with Space or Tabs (or commas) and returns a string structure array

;	NOTE:   PROGRAM ASSUMES THAT THERE ARE NAMES FOR EACH OF THE COLUMNS IN THE FIRST LINE OF THE FILE

;	If DELIM is not provided then a comma is assumed.
; SYNTAX:;
;		Result = READ_DELIMITED(File,delim='SPACE') 	; space
;		Result = READ_DELIMITED(File,delim='TAB')	; tab
;		Result = READ_DELIMITED(File,delim='COMMA')		; comma
; OUTPUT:
;		Structure, All tags will be STRING Type
; ARGUMENTS:
; 	File:	Full name of ASCII text file
; NOTES:
;
; HISTORY:
;		Jan 10,2001	Written by:	J.E. O'Reilly
; 	June 21,2001 JOR added :NTH_DATA = (N_TAGS(ALL) < N_ELEMENTS(DATA)) -1L ;
;   July 6,2001 jor made sure tag names do not have any leading or trailing spaces
;		Jan 7,2002   NTH_DATA = (N_ELEMENTS(DATA) ) -1L ;
;		Oct
;-
; *************************************************************************

FUNCTION READ_DELIMITED,FILE , DELIM=DELIM, SKIP=skip , TAGNAMES=tagnames,NOHEADING= NOHEADING
  ROUTINE_NAME='READ_DELIMITED'

;	===> If DELIM not provided then assume comma delimited
  IF N_ELEMENTS(DELIM) NE 1 THEN  DELIMIT=',' ELSE DELIMIT = DELIM  ; DEFAULT IS ASSUME COMMA-DELIMITED

  IF STRUPCASE(DELIMIT) EQ 'TAB' 		THEN DELIMIT=STRING(BYTE(9)) ; ASCII FOR TAB
  IF STRUPCASE(DELIMIT) EQ 'COMMA' 	THEN DELIMIT=','
  IF STRUPCASE(DELIMIT) EQ 'SPACE' 	THEN DELIMIT=' '

  IF N_ELEMENTS(FILE) EQ 0 THEN FILE = DIALOG_PICKFILE(filter='*.*')

;	===> Read the entire text file into an array
	TXT = READ_TXT(FILE)

; =====> Determine number of lines in the ASCII file to read
  N_LINES= N_ELEMENTS(TXT)
  
  IF N_LINES EQ 0 OR TXT EQ [] THEN BEGIN
    PRINT, 'ERROR: ' + FILE + ' is empty.'
    RETURN, []
  ENDIF

	FIRST_LINE = 0L
	LAST_LINE  = N_LINES - 1L

;	===> Skip Lines of text before the tags (data fields)
	IF N_ELEMENTS(SKIP) EQ 1 THEN BEGIN
		IF SKIP GE 1 THEN BEGIN
			_TXT = TXT(0:(SKIP-1L))
			PRINT,'Skipping '+STRTRIM(SKIP) +' Lines'
			FOR NTH = 0,N_ELEMENTS(_TXT)-1L DO PRINT, _TXT[NTH]
			FIRST_LINE = SKIP
			N_LINES = N_LINES - SKIP
		ENDIF
	ENDIF

  _TXT = TXT(FIRST_LINE)

;	===> If there are both tabs and spaces in a space-delimited, then replace tabs with a single space
  IF DELIMIT EQ 'SPACE' THEN _TXT= STR_TAB2SPACE(_TXT)

;	===> Split the TXT into its components based on the provided delimiter and get the names for the structure
	NAMES = STRSPLIT(_TXT,DELIMIT,/EXTRACT)
	
; ===> Check to see if any rows in the file have more elements than the first line
  MAXCOLS = N_ELEMENTS(NAMES)
  FOR NTH=1, N_LINES-1 DO BEGIN
    ROW = STRSPLIT(TXT[NTH],DELIMIT,/EXTRACT)
    IF N_ELEMENTS(ROW) GT N_ELEMENTS(NAMES) THEN MAXCOLS = N_ELEMENTS(ROW)
  ENDFOR

;	===> If there are no column headings (tagnames) /NOHEADING then make them up
;			 Unless TAGNAMES are provided
	IF KEYWORD_SET(NOHEADING) THEN BEGIN
		IF N_ELEMENTS(TAGNAMES) EQ N_ELEMENTS(NAMES) THEN BEGIN
			NAMES = TAGNAMES
		ENDIF ELSE BEGIN
			NAMES = '_'+STRTRIM(SINDGEN(MAXCOLS),2)
		ENDELSE
	ENDIF ELSE BEGIN
		FIRST_LINE = FIRST_LINE +1L ;
		N_LINES = N_LINES - 1L ;
	ENDELSE

;	===> Check tagnames
	NAMES = STRUCT_TAGNAMES_FIX(NAMES)

;	LLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLL
  FOR N=0L,N_ELEMENTS(NAMES)-1L DO BEGIN
    ANAME = NAMES[N]
    ANAME = STRTRIM(ANAME,2)
    IF N EQ 0 THEN STRUCT=CREATE_STRUCT(ANAME,'') ELSE STRUCT = CREATE_STRUCT(STRUCT,ANAME,'')
  ENDFOR

  NTAGS = N_TAGS(STRUCT)
;	===> Replicate the structure to hold all remaining text
  STRUCT=REPLICATE(STRUCT, (N_LINES) > 1)

	COUNTER = 0L
; LLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLL
  FOR LINE = FIRST_LINE,LAST_LINE DO BEGIN
    _TXT = TXT(LINE)
    IF DELIMIT EQ 'SPACE' THEN _TXT= STR_TAB2SPACE(_TXT)

 ;	===> IF DELIMIT IS 'SPACE' THEN REMOVE ALL BUT ONE SPACE BETWEEN COLUMNS
		IF DELIMIT EQ " " THEN _TXT = STRTRIM(STRCOMPRESS(_TXT),2)

    DATA = STRSPLIT(_TXT,DELIMIT,/EXTRACT,/PRESERVE_NULL)
    NTH_DATA = (N_ELEMENTS(DATA) ) -1L ;
;   ===> Frequently files have blank columns at right so only fill structure with
;   ===> data from N=0 to NTH_DATA
    FOR N=0L,NTH_DATA DO BEGIN
    	IF DATA[N] EQ '' THEN CONTINUE
       STRUCT[COUNTER].(N)= DATA[N]
    ENDFOR
    COUNTER = COUNTER + 1L
  ENDFOR
;	||||||

  RETURN,STRUCT
END; #####################  End of Routine ################################
