; $Id: STRUCT_STRTRIM  NOV 28,2000

FUNCTION STRUCT_STRTRIM, STRUCT,FLAG
;+
; NAME:
;       STRUCT_STRTRIM
;
; PURPOSE:
;       Use IDL STRTRIM to trim leading and trailing blanks from all STRING TAGS within a structure
;
; CATEGORY:
;       STRING
;
; CALLING SEQUENCE:
;       Result = STRUCT_STRTRIM(STRUCT)
;
; INPUTS:
;       STRING ARRAY OR A SIMPLE STRUCTURE
;       FLAG (OPTIONAL INPUT OF 0,1,2 (SEE STRTRIM)
;
; KEYWORD PARAMETERS:
;       FLAG:	Same meaning as IDL STRTRIM (SEE IDL HELP)
;
; OUTPUTS:
;       A copy of the input structure with any string tags modified by having their leading and trailing blanks removed (trimmed)
;
; RESTRICTIONS:
;		This routine expects a the input to be a structure
;
;
; MODIFICATION HISTORY:
;       Written by:  J.E.O'Reilly, Nov 28,2000
;-

;	****************************************************************************************************
	ROUTINE_NAME = 'STRUCT_STRTRIM'

  COPY=DATA
  IF N_ELEMENTS(FLAG) NE 1 THEN FLAG =2
  SZ=SIZE(COPY,/STRUCT)
  IF SZ.TYPE EQ 7 THEN RETURN, STRTRIM(COPY,FLAG)

  IF SZ.TYPE EQ 8 AND SZ.N_DIMENSIONS EQ 1 THEN BEGIN  ; VALID STRUCTURE
;   ================>
;   Get tag names
    names=TAG_NAMES(COPY)

;   ===> Trim any leading and trailing spaces
    FOR N=0L,N_ELEMENTS(NAMES)-1L DO BEGIN
      SZ = SIZE(COPY.(N),/STRUCT)
      IF SZ.TYPE EQ 7 THEN BEGIN
        PRINT, 'TRIMMING TAG#'+NUM2STR(N)+' '+names(n)
        COPY.(N) = STRTRIM(COPY.(N),FLAG)
      ENDIF
    ENDFOR
    RETURN, COPY
  ENDIF

	END; #####################  End of Routine ################################
