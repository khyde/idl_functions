; $ID:	LI.PRO,	2020-06-30-17,	USER-KJWH	$

PRO LI,DAT, SKIP=skip, NOSEQ=NOSEQ, NOHEADING=noheading, FILE=file,NOTES=notes, DELIM=delim,Tags=Tags,TAGNAMES=Tagnames,LIST_OVERWRITE=list_overwrite

;+
;	This Program prints a vertical list of the input data  .
;
; OUTPUT:
;	Prints to screen or to a file if File name is provided

; ARGUMENTS:
; 	DAT:	data array to list:
;
; KEYWORDS:
;		SKIP:		Prints every nth value in array
;		NOSEQ:	List but do not number or sequence the list
;		NOHEADING: Does not Prints names (tagnames of structures)
;		FILE:		Full path and name of file to OPEN and WRITE the printed data
;		NOTES: 	Notes can be a string or string array
;		DELIM:	Delimiter to use after the sequence number, default is ':'
;		TAGS:		The tag numbers of structure arrays to extract from the structure
; EXAMPLE:
;		list, dindgen(10)+randomu(seed,10)
; HISTORY:
;	Sep 22,1998	Written by:	J.E. O'Reilly
;	May 7, 2003 jor, Tags=Tags, Rewrote program
;	Feb 16, 2004 jor, format for complex and dcomplex
;-
; *************************************************************************

  ROUTINE_NAME='LI'
  IF N_ELEMENTS(DAT) EQ 0 THEN GOTO, DONE
  IF N_ELEMENTS(DELIM) NE 1 THEN DELIM = ':'

; ====================>
; Determine data type
  type = IDLTYPE(DAT,/CODE)
  IF N_ELEMENTS(SKIP) NE 1 THEN SKIP = 1

  CASE TYPE OF
  0:  FORMAT = 'UNDEFINED'
  1:  FORMAT = 'I)'
  2:  FORMAT = 'I)'
  3:  FORMAT = 'I)'
  4:  FORMAT = 'F)'
  5:  FORMAT = 'D)'
  6:  FORMAT = ''
  7:  FORMAT = 'A)'
  8:  FORMAT = 'A)' ; Structure tags converted to string
  9:  FORMAT = ''
  10: FORMAT = ''
  11: FORMAT = ''
  12:  FORMAT = 'I)'
  13:  FORMAT = 'I)'
  14:  FORMAT = 'I)'
  15:  FORMAT = 'I)'
  ENDCASE



	IF FORMAT NE '' THEN BEGIN
  	IF KEYWORD_SET(NOSEQ) THEN BEGIN
    	FORMAT = "(A,"+FORMAT
  	ENDIF ELSE BEGIN
    	FORMAT = "(I,'"+DELIM+"'," +FORMAT
  	ENDELSE
	ENDIF

	IF TYPE NE 8 THEN BEGIN ; If not a simple spreadsheet type structure
		TXT = DAT
		IF NOT KEYWORD_SET(NOHEADING) THEN BEGIN
			IF NOT KEYWORD_SET(NOSEQ) THEN BEGIN
				HEADING = 'Seq'+delim+'Data:'
			ENDIF ELSE BEGIN
				HEADING = 'Data:'
			ENDELSE
		ENDIF
	ENDIF ELSE BEGIN
		IF N_ELEMENTS(TAGS) GE 1 OR N_ELEMENTS(TAGNAMES) GE 1 THEN BEGIN
			COPY = STRUCT_COPY(DAT,TAGS=TAGS,TAGNAMES=TAGNAMES)
		ENDIF 	ELSE COPY = DAT

    IF  KEYWORD_SET(NOHEADING) THEN BEGIN
    	TXT=STRUCT_2STRING(COPY)
    ENDIF ELSE BEGIN
    	TXT=STRUCT_2STRING(COPY,/HEADING)
    	HEADING = TXT[0]
    	TXT=TXT[1:*]
    ENDELSE
	ENDELSE

	N = N_ELEMENTS(TXT)

  IF KEYWORD_SET(NOSEQ) THEN BEGIN
    SEQ = REPLICATE('',N)
  ENDIF ELSE BEGIN
    SEQ = [SINDGEN(N)]
  ENDELSE          ;


	IF N_ELEMENTS(FILE) NE 1 THEN BEGIN
;		=====> Printing to Screen Notes First
		FOR NTH = 1L,N_ELEMENTS(NOTES) DO BEGIN
    	PRINT, NOTES(NTH-1)
  	ENDFOR
; 	=====> Print Heading
		FOR NTH = 1L,N_ELEMENTS(HEADING) DO BEGIN
    	PRINT, HEADING(NTH-1)
  	ENDFOR
; 	=====> Print Data
  	FOR NTH = 0L,N-1L, SKIP DO BEGIN
    	PRINT, SEQ[NTH], TXT[NTH],FORMAT=FORMAT
  	ENDFOR

	ENDIF ELSE BEGIN
; =====> Printing to a File
    IF KEYWORD_SET(LIST_OVERWRITE) THEN OPENW,LUN,FILE,/GET_LUN ELSE OPENW,LUN,FILE,/GET_LUN,/APPEND

;		=====> Print Notes First
		FOR NTH = 1L,N_ELEMENTS(NOTES) DO BEGIN
    	PRINTF,LUN, NOTES(NTH-1)
  	ENDFOR
; 	=====> Print Heading
		FOR NTH = 1L,N_ELEMENTS(HEADING) DO BEGIN
    	PRINTF,LUN, HEADING(NTH-1)
  	ENDFOR
; =====> Print Data
  FOR NTH = 0L,N-1L, SKIP DO BEGIN
    PRINTF,LUN, SEQ[NTH], TXT[NTH],FORMAT=FORMAT
  ENDFOR

	CLOSE,LUN
  FREE_LUN,LUN
  ENDELSE ; IF N_ELEMENTS(FILE) EQ 1 THEN BEGIN

; ***************************************


DONE:

END; #####################  End of Routine ################################
