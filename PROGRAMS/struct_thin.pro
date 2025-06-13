; $ID:	STRUCT_THIN.PRO,	2020-06-30-17,	USER-KJWH	$
;+
;	This Function THINS (REMOVES) TAGS WHICH ARE ENTIRELY EMPTY FROM STRUCTURES (USES STRUCT_COPY.PRO)
;
; SYNTAX:
;		Result = STRUCT_THIN, Struct, [TAGNAMES=Tagnames] )
; OUTPUT:
;		Structure
;   (-1 if input is incorrect)
; ARGUMENTS:
; 	Struct:	Input structure;
; KEYWORDS:
;		TAGNAMES:	The names of the tags to be COPIED from the structure
;		TAGS:		The tag numbers to be COPIED (as an alternative to providing the tagnames)
;		REMOVE:		Removes the specified tagnames or tags from the copied structure
; 	EXAMPLE:
; 	Make a Structure
;		STRUCT = CREATE_STRUCT('AA',0B,'BB',1L,'CC',0D)
;
;	Examples using tagnames:
;   Result = STRUCT_THIN(STRUCT)
;
; NOTES:
;	This routine does not alter the original Structure
;   This routine may be used to rearrange the order of tags in a structure
; 	Tagnames may be upper, lower or mixed case.

; HISTORY:
;		Oct 1, 2003 Written by: J.E. O'Reilly, NOAA, 28 Tarzwell Drive, Narragansett, RI 02882
;-
; *************************************************************************
FUNCTION STRUCT_THIN, Struct
  ROUTINE_NAME='STRUCT_THIN'

; =====> Ensure Input information is correct
  sz_struct   = SIZE(Struct,/STRUCT)
  sz_tagnames = SIZE(Tagnames,/STRUCT)
  sz_tags     = SIZE(Tags,/STRUCT)
  IF sz_struct.type  NE 8 THEN BEGIN
    PRINT,'ERROR: Must provide Struct'
    RETURN, -1
  ENDIF


  ntags        = N_TAGS(Struct)
  nth_tag      = ntags -1L
  struct_names = TAG_NAMES(Struct)
  tag_subs     = LINDGEN(ntags)
  tag_targets  = -1L
  n_records    = N_ELEMENTS(Struct)


; ===> Loop through Tags to find the completely empty tags (where all records for that tag are missing)
	FOR nth=0L, nth_tag DO BEGIN
    ok = WHERE(Struct.(nth) EQ MISSINGS(Struct.(nth)),count)
    IF count EQ n_records THEN tag_targets=[tag_targets,nth]
  ENDFOR


; =====> If all tags have at least one non-missing record then return input structure as is
  IF N_ELEMENTS(tag_targets) GE 2 THEN tag_targets = tag_targets(1:*) ELSE RETURN, Struct


  temp = tag_subs
  FOR nth = 0L,N_ELEMENTS(tag_targets)-1L DO BEGIN
    target = tag_targets(nth)
    OK = WHERE(temp EQ target,count)
    IF count GE 1 THEN temp(ok) = -1
  ENDFOR
  OK = WHERE(temp NE -1,count)
  IF count GE 1 THEN tag_targets = temp(ok) ELSE RETURN, -1


; =====> Make a new structure to hold each of the requested valid tag numbers
  FOR nth = 0L, N_ELEMENTS(TAG_TARGETS)-1L DO BEGIN
    atag = tag_targets(nth)
    anam = Struct_names(atag)
    aval = Struct[0].(ATAG)
    IF nth EQ 0 THEN BEGIN
      template = CREATE_STRUCT(anam,aval)
    ENDIF ELSE BEGIN
      template = CREATE_STRUCT(template,anam,aval)
    ENDELSE
  ENDFOR

; =====> Replicate the template to hold all data from the input Struct
  DATA = REPLICATE(template,N_ELEMENTS(Struct))

; =====> Fill the data structure with the appropriate values from the input Struct
  FOR nth = 0L, N_ELEMENTS(TAG_TARGETS)-1L DO BEGIN
    atag = tag_targets(nth)
    anam = struct_names(ATAG)
    aval = Struct[0].(ATAG)
    data(*).(nth) = Struct(*).(atag)
  ENDFOR

  RETURN, DATA
  END; #####################  End of Routine ################################
