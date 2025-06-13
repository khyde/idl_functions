; $ID:	STRUCT_TOTAL.PRO,	2004 07 18 11:16	$
;+
;	This Function Totals accros rows in a spreadsheet type structure and returns the input structure plus the row totals
; SYNTAX:
;		Result = STRUCT_TOTAL(Struct)
; OUTPUT:
; ARGUMENTS:
; 	Struct:	IDL Structure (simple row x column 'spreadsheet' type structure)
; KEYWORDS:
;		TAGNAMES... The names of the tags (columns) to be totaled.
;
;	Result = STRUCT_TOTAL(Struct)

; CATEGORY:
;		STRUCTURES
; NOTES:
;		Input structure is not altered.

; HISTORY:
;		May 31,2007	Written by:	J.E. O'Reilly, NOAA, 28 Tarzwell Drive, Narragansett, RI 02882
;-
; *************************************************************************

FUNCTION STRUCT_TOTAL, Struct, TAGNAMES=TAGNAMES
  ROUTINE_NAME='STRUCT_TOTAL'  ;
  COPY = Struct  ; Input structure is not changed
  sz=SIZE(COPY,/STRUCT)
  type = sz.type
  IF type NE 8 THEN BEGIN
    PRINT,'ERROR: Struct must be an IDL Structure'
    RETURN, -1
  ENDIF
  ntags = N_TAGS(COPY)

  IF SZ.N_DIMENSIONS NE 1 THEN BEGIN
    PRINT,'ERROR: ONLY SPREADSHEET TYPE STRUCTURE ALLOWED'
    RETURN, -1
  ENDIF

	IF N_ELEMENTS(TAGNAMES) EQ 0 THEN _TAGNAMES = TAG_NAMES(COPY) ELSE _TAGNAMES = TAGNAMES

	TOT = REPLICATE(CREATE_STRUCT('TOTAL',MISSINGS(0.0),'N',0,'TAGS_VALID',''),N_ELEMENTS(STRUCT))

	COPY = STRUCT_COPY(COPY,TAGNAMES= _TAGNAMES)
	ARR = STRUCT_2ARR(COPY)
	TOT_ROW = TOTAL(ARR,1,/NAN)
	OK = WHERE(FINITE(ARR) AND ARR NE MISSINGS(ARR),COUNT)


	A=ARRAY_INDICES(Arr, OK)
	N=TOTAL(FINITE(ARR),1)
	TOT.N = N

	OK_ROWS = WHERE(TOT.N EQ N_TAGS(COPY),COUNT_ROWS)

;	===> MERGE INPUT STRUCTURE WITH TOT AND FILL IN VALID TOTALS PER ROW

	TOT(OK_ROWS).TOTAL = TOT_ROW(OK_ROWS)


  RETURN,TOT


END; #####################  End of Routine ################################
