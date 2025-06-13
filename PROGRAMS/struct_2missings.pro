; $Id: STRUCT_2MISSINGS.pro $
;+
;	This Function Converts Tags in a structure to system missing codes (infinity for float and double,etc.)
; SYNTAX:
;	Result = STRUCT_2MISSINGS(Struct, [MISSING=missing] )
; OUTPUT:
; ARGUMENTS:
; 	Struct:	IDL Structure
; KEYWORDS:
;	MISSING:	Code to initialize structure, otherwise codes returned by MISSINGS.PRO are used
; EXAMPLE:
;	STRUCT = CREATE_STRUCT('AA',0B,'BB',1,'CC',0L,'DD',0.0)
;
;	Result = STRUCT_2MISSINGS(Struct)
;	IDL> help,/struct,result
;	** Structure <2c6ae80>, 5 tags, length=24, refs=2:
;	   AA              BYTE         0
;	   BB              INT          32767
;	   CC              LONG         2147483647
;	   DD              FLOAT        Inf
;	   EE              DOUBLE       Infinity
;
;
;	Result = STRUCT_2MISSINGS(Struct,missing= -9)
;	IDL> help,/struct,result
;	** Structure <2c6ae80>, 5 tags, length=24, refs=2:
;	   AA              BYTE         0
;	   BB              INT         -9
;	   CC              LONG        -9
;	   DD              FLOAT       -9.00000
;	   EE              DOUBLE      -9.0000000

; CATEGORY:
;	STRUCTURES
; NOTES:
;	This routine is usefull for initializing structures to operationally-defined missing codes
;	IF a negative missing code is used (e.g. missing= -9) any binary tags will be initialized to 0 instead of -9.
;  	Input structure is not altered.
; VERSION:
;	Jan 22,2001
; HISTORY:
;	March 15, 2000	Written by:	J.E. O'Reilly, NOAA, 28 Tarzwell Drive, Narragansett, RI 02882
;-
; *************************************************************************

FUNCTION STRUCT_2MISSINGS, Struct, MISSING=missing
  ROUTINE_NAME='STRUCT_2MISSINGS'  ;

  COPY = Struct  ; Input structure is not changed
  sz=SIZE(COPY,/STRUCT)
  type = sz.type
  IF type NE 8 THEN BEGIN
    PRINT,'ERROR: Struct must be an IDL Structure'
    RETURN, -1
  ENDIF

  ntags = N_TAGS(COPY)

; >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  FOR nth = 0L, ntags-1L DO BEGIN
    IF N_ELEMENTS(MISSING) NE 1 THEN _missing = MISSINGS(COPY.(nth)) ELSE _missing = MISSING
    sz = SIZE(copy.(nth),/STRUCT)
    IF SZ.TYPE EQ 1 AND _missing LT 0 THEN _MISSING = 0b ; Can not have negative binary missing values
    COPY(*).(nth) = _missing
  ENDFOR

  RETURN, COPY

END; #####################  End of Routine ################################
