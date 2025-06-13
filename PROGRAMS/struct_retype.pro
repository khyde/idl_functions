; $ID:	STRUCT_RETYPE.PRO,	2020-06-30-17,	USER-KJWH	$
;+
; This Function Converts all tags in a structure to a TYPE (e.g. Long)
;	Tags in a Simple Spreadsheet Structure to Double Precision
; SYNTAX:
;   Result = STRUCT_RETYPE(Struct,TYPE='LONG')
; ARGUMENTS:
;   Struct: IDL Structure
; KEYWORDS:

; EXAMPLE:
;
; NOTES:
;

; HISTORY:
;   Aug 11,2001 Written by: J.E. O'Reilly, NOAA, 28 Tarzwell Drive, Narragansett, RI 02882

;-
; *************************************************************************

FUNCTION STRUCT_RETYPE, Struct, VALUE
  ROUTINE_NAME='STRUCT_RETYPE'

  sz=SIZE(Struct,/STRUCT)
  type = sz.type
  IF type NE 8 THEN BEGIN
    PRINT,'ERROR: Struct must be an IDL Structure'
    RETURN, -1
  ENDIF


 	NEW = STRUCT[0]
  ntags = N_TAGS(NEW)

  TAGNAMES = TAG_NAMES(NEW)
	NUM = N_ELEMENTS(NEW)


  ARR = MAKE_ARRAY(ntags,TYPE= IDLTYPE(VALUE,/CODE))
  ARR(*) = MISSINGS(ARR)

  RETURN, REPLICATE(ARR_2STRUCT(ARR,TAGNAMES=TAGNAMES),NUM)




END; #####################  End of Routine ################################
