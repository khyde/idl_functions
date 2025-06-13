; $ID:	STRUCT_FILL.PRO,	2020-06-30-17,	USER-KJWH	$
;+
;	This Function Fills missing data in tags with non-missing data from the same tags in the previous record
;
; SYNTAX:
;		Result = STRUCT_FILL, Struct, [TAGNAMES=Tagnames], [TAGS=Tags])
; OUTPUT:
;		Structure
;   (-1 if input is incorrect)
; ARGUMENTS:
; 	Struct:	Input structure;
; KEYWORDS:
;		TAGNAMES:	The names of the tags to be COPIED from the structure
;		TAGS:		The tag numbers to be COPIED (as an alternative to providing the tagnames)

;	EXAMPLE:
; 	SEE STRUCT_FILL_DEMO.PRO
;
; NOTES:
;	This routine does not alter the original Structure
; 	Tagnames may be upper, lower or mixed case.
;
;
; HISTORY:
;		NOV 30, 2004 Written by: J.E. O'Reilly, NOAA, 28 Tarzwell Drive, Narragansett, RI 02882
;-
; *************************************************************************
FUNCTION STRUCT_FILL, Struct, TAGNAMES=Tagnames, TAGS=Tags
  ROUTINE_NAME='STRUCT_FILL'

; =====> Ensure Input information is correct
  sz_struct   = SIZE(Struct,/STRUCT)
  sz_tagnames = SIZE(Tagnames,/STRUCT)
  sz_tags     = SIZE(Tags,/STRUCT)
  IF sz_struct.type  NE 8 THEN BEGIN
    PRINT,'ERROR: Must provide Struct'
    RETURN, -1
  ENDIF
  IF sz_tagnames.n_elements EQ 0 AND sz_tags.n_elements EQ 0 THEN BEGIN
    PRINT,'ERROR: Must provide Tagnames OR Tags'
    RETURN, -1
  ENDIF
  IF sz_tagnames.n_elements GE 1 AND sz_tagnames.type   NE 7 THEN BEGIN
    PRINT,'ERROR: Tagnames must be String Type'
    RETURN, -1
  ENDIF

	DATA=STRUCT
	COPY=STRUCT_COPY(DATA, TAGNAMES=Tagnames, TAGS=Tags)
	NUM = N_ELEMENTS(COPY)

;	===> When the structure (COPY) has all missing data there will be just commas in these records in TXT
;			(these records will then be filled in with the preceding information from just the target tags)
	TXT =STRUCT_2STRING(COPY)
	OK=WHERE(STRLEN(TXT) EQ (N_TAGS(COPY)-1),COUNT,COMPLEMENT=SOURCE,NCOMPLEMENT=NSOURCE)


	IF COUNT EQ 0 THEN BEGIN
		PRINT,'The combination of tags selected have some non-missing data'
		PRINT,'So No fills could be made to original Structure'
		RETURN,DATA
	ENDIF

	IF COUNT EQ NUM THEN BEGIN
		PRINT,'The combination of tags selected are all missing data'
		PRINT,'So No fills could be made to original Structure'
		RETURN,DATA
	ENDIF

  LSUBS=LINDGEN(N_ELEMENTS(TXT))

;	LLLLLLLLLLLLLLLLLLLLLLLLLLLLLL
	FOR nth=0L,NSOURCE-1L DO BEGIN
		START = SOURCE[NTH] & FINISH = SOURCE( (NTH+1) < (NSOURCE-1L)) -1 ;;
		;PRINT, START,FINISH
		IF FINISH - START GE 1 THEN BEGIN
  		SUBS = LSUBS(START:FINISH)
  		COPY(SUBS) = COPY(START)
		ENDIF
	IF FINISH - START EQ -1 THEN BEGIN
	  IF START LT NUM-1L THEN BEGIN
  		SUBS = LSUBS(START:NUM-1L)
  		COPY(SUBS) = COPY(START)
  		ENDIF
		ENDIF
	END

	STRUCT_ASSIGN,COPY,DATA,/NOZERO

  RETURN, DATA
  END; #####################  End of Routine ################################
