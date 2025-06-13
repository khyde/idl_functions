; $Id:	struct_2string.pro,	November 09 2006	$
;+
;	This Function Convert Tags in a Simple (Spreadsheet) Structure into Delimited Strings.
;
; SYNTAX:
;		Result = STRUCT_2STRING(Struct, [DELIM=DELIM], [HEADING=heading]   )
; OUTPUT:
;		String Array
; ARGUMENTS:
; 	Struct:	A simple (database-like or spreadsheet-like IDL Structure)
; KEYWORDS:
;		DELIM; 	The character(s) to append to each tag after it is converted to string
;              	If DELIM = 'TAB' THEN 9B (the byte value of the ASCII TAB character) is the DELIM.:
;		HEADING:  	Adds the tagnames (field names) to the first line of the output string array
;
;		TAGNAMES: 	Returns a delimited string with just the structure tagnames
;		ARR or TRANSP: Transposes the structure so that the output rows are the Tagnames and the columns are the data
;	ERROR:     Any Error messages are placed in ERROR, if no errors then ERROR = ''
; EXAMPLES:
;
;	Struct = CREATE_STRUCT('AA',0B,'BB',1,'CC',2L,'FF',1E16,'GG','Hello')& Struct = REPLICATE(Struct,5)
;	Result = STRUCT_2STRING(Struct)                 	; results in a comma-delimited string array
;
; Result = STRUCT_2STRING(Struct,DELIM=',')   	; results in a comma-delimited string array
;	Result = STRUCT_2STRING(Struct,DELIM=' ')   	; results in a space-delimited string array
; Result = STRUCT_2STRING(Struct,DELIM='TAB') 	; results in a tab-delimited string array
;	Result = STRUCT_2STRING(Struct,DELIM='Cat') 	; results in a 'Cat'-delimited string array
;
;
;	Example of how to easily make a csv file from a simple row vs column structure
;		Struct = CREATE_STRUCT('AA',0B,'BB',1,'CC',2L,'FF',1E16,'GG','Hello')& Struct = REPLICATE(Struct,5)
;		STRUCT_2CSV,'TEST.CSV',Struct
;		Now check out the TEST.CSV file in Excel or word processor
;
; CATEGORY:
;	STRUCTURES
;
; NOTES:
;	Conversion of FLOAT and DOUBLE uses IDL 'G' FORMAT
;	Conversion of BINARY           uses IDL 'I' FORMAT
;   MISSINGS.PRO is called.  Missing Data Codes (see MISSINGS.PRO) are converted to null string ''
;		(except for Byte Type)
;  	Routine only works with simple structures (e.g. database or spreadsheet type structures)
;
; HISTORY:
;	Oct 1,2001	Written by:	J.E. O'Reilly, NOAA, 28 Tarzwell Drive, Narragansett, RI 02882
;	Nov 30,2004 JOR If the data in the structure is 0b then output string will be set to null (missing code for string)
;-
; *************************************************************************


FUNCTION STRUCT_2STRING, Struct, DELIM=delim, HEADING=heading, TAGNAMES=tagnames,ARR=arr,TRANSP=transp,ERROR=error
  ROUTINE_NAME='STRUCT_2STRING'

; ===============>
; Default DELIM is a comma
  IF N_ELEMENTS(DELIM) NE 1 THEN DELIM = ','
  IF STRUPCASE(DELIM) EQ 'TAB' 		THEN DELIM =  STRING(9B)
  IF STRUPCASE(DELIM) EQ 'COMMA' 	THEN DELIM =  STRING(44B)

  S = SIZE(Struct,/STRUCT)

; ******************************************************
; Only works on simple structures (e.g. database or spreadsheet type structures)
  IF S.TYPE EQ 8 AND S.N_DIMENSIONS EQ 1 THEN BEGIN

;   ===================>
;   Make a string array to hold all of the data from each record
    nrecs = N_ELEMENTS(Struct)
    ntags = N_TAGS(Struct)
    types = LONARR(ntags)

    IF KEYWORD_SET(TAGNAMES) THEN RETURN,STRJOIN(TAG_NAMES(Struct),DELIM)



;   LLLLLLLLLLLLLLLLLLLLLLLLLLLLL
    FOR nth=0L, ntags-1L DO BEGIN
      sz=SIZE(Struct(0).(nth),/STRUCT)
      types(nth) = sz.type
    ENDFOR


    fmt = REPLICATE('',ntags)
    ok = WHERE(types EQ 4 OR types EQ 5,count); FLOAT, DOUBLE
    IF count GE 1 THEN fmt(OK) = '(G)'
    ok = WHERE(types EQ 1,count) ; BINARY
    IF count GE 1 THEN fmt(OK) = '(I)'

    txtarr = STRARR(ntags,nrecs)

;   LLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLL
    FOR _tag = 0L, NTAGS-1L DO BEGIN
      txtarr(_tag,*) = STRTRIM(STRING(Struct.(_tag),FORMAT=fmt(_tag)),2)
;     ===> Missing data are set to null string
      ok = WHERE(Struct.(_TAG) EQ MISSINGS(Struct.(_TAG)),count)
       IF count GE 1 THEN txtarr(_tag,ok) = ''
    ENDFOR

		IF KEYWORD_SET(HEADING) THEN txtarr = [[TAG_NAMES(Struct)], [TEMPORARY(txtarr)]]

    IF KEYWORD_SET(ARR) THEN txtarr = TRANSPOSE(txtarr)
    txtarr=STRJOIN(txtarr,DELIM)
    RETURN, txtarr
  ENDIF ELSE RETURN, ''


END; #####################  End of Routine ################################
