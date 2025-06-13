; $ID:	STRUCT_2FLT.PRO,	2020-07-08-15,	USER-KJWH	$

	FUNCTION STRUCT_2FLT, Struct

;+
; This Function Converts all numeric tags in a simple spreadsheet structure to Floating Point Single-Precision
; SYNTAX:
;   Result = STRUCT_2FLT(Struct)
; ARGUMENTS:
;   Struct: IDL Structure

; EXAMPLE:
;		Make a simple spreadsheet type structure
;		STRUCT = REPLICATE(CREATE_STRUCT('AA',0B,'BB',1L,'CC',0D, 'TXT_ALPHA','CAT', 'TXT_NUMERIC','1.2'),3)
;		STRUCT[1].TXT_ALPHA = '1.2'
;		STRUCT[1].TXT_NUMERIC = '3.333'
;		STRUCT = STRUCT_2FLT(STRUCT)
;
;
;	PROCEDURE:
;		If a tag contains numeric data or string data for which all elements can be converted into numeric data
;		then the Result.tag will be double-precision
;
; NOTES:
;		This routine first calls STRUCT_2NUM to convert any strings into numeric (where possible)
;
;   This routine is usefull for converting string structures made by using READ_CSV.PRO into double precision
;		to facillitate PLOT and other IDL commands where numeric data are preferred.
;
;   The Input structure is not altered.

; HISTORY:
;   Aug 11,2001 Written by: J.E. O'Reilly, NOAA, 28 Tarzwell Drive, Narragansett, RI 02882

;-
; *************************************************************************
  ROUTINE_NAME='STRUCT_2FLT'

  sz=SIZE(Struct,/STRUCT)
  type = sz.type
  IF type NE 8 THEN BEGIN
    PRINT,'ERROR: Struct must be an IDL Structure'
    RETURN, -1
  ENDIF


 	NEW = STRUCT_2NUM(Struct)
  ntags = N_TAGS(NEW)

  TAGNAMES = TAG_NAMES(NEW)
	NUM = N_ELEMENTS(NEW)

; ===> Create a new structure with Tag Names same as original but type=DOUBLE and set to missings code
  FOR N = 0L, ntags-1L DO BEGIN
;		If numeric then convert to DOUBLE otherwise conserve the data type
  	IF NUMERIC(NEW.(N)) THEN TEMPLATE = MISSINGS(0.0) ELSE TEMPLATE = NEW[0].(N)

  	IF N EQ 0 THEN 	_STRUCT	=	CREATE_STRUCT(TAGNAMES(N),TEMPLATE) ELSE $
  									_STRUCT = CREATE_STRUCT(_STRUCT,TAGNAMES(N),TEMPLATE)
  ENDFOR

  _STRUCT=REPLICATE(_STRUCT,NUM)


;	LLLLLLLLLLLLLLLLLLLLLLLLLLLLLL
	FOR N = 0L, ntags-1L DO BEGIN
		TYPE_SOURCE	= IDLTYPE(NEW.(N),/CODE)
		TYPE_DEST		= IDLTYPE(_STRUCT.(N),/CODE)

		IF TYPE_DEST EQ TYPE_SOURCE THEN BEGIN
			_STRUCT.(N) = NEW.(N)
		ENDIF ELSE BEGIN
		  _STRUCT.(N) = STR2NUM(NEW.(N))
;			===> Convert missing codes from those in NEW to the appropriate missing codes for the tags in _STRUCT
		  OK=WHERE(NEW.(N) EQ MISSINGS(NEW.(N)) ,COUNT)
		  IF COUNT GE 1 THEN _STRUCT[OK].(N) = MISSINGS(_STRUCT[OK].(N))
		ENDELSE
  ENDFOR

  RETURN,_STRUCT

END; #####################  End of Routine ################################
