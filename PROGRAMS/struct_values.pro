; $ID:	STRUCT_VALUES.PRO,	2020-06-30-17,	USER-KJWH	$
;+
;	This Function returns the unique values in a structure

;
; SYNTAX:
;		Result = STRUCT_VALUES(Struct)
; OUTPUT:
;		Structure
;   (-1 if input is incorrect)
; ARGUMENTS:
; 	Struct:	Input structure;
;		Names : Can be any part or all of the desired tagnames (helps when have various tagnames with similar prefix or suffix)
; KEYWORDS:
;		TAGNAMES:	The names of the tags to be COPIED from the structure
;		TAGS:		The tag numbers to be COPIED (as an alternative to providing the tagnames)

; 	EXAMPLE:
; 	Make a Structure
;		STRUCT = CREATE_STRUCT('AA',0B,'BB',1L,'CC',0D)
;
;	Examples using tagnames:
;   Result = STRUCT_VALUES(STRUCT,TAGNAMES='AA')   			; Extract Tag AA
;
;
; NOTES:
;	This routine does not alter the original Structure
;   This routine may be used to rearrange the order of tags in a structure
; 	Tagnames may be upper, lower or mixed case.

; VERSION:
;		Jan 14,2001
; HISTORY:
;		Mar 10,1999 Written by: J.E. O'Reilly, NOAA, 28 Tarzwell Drive, Narragansett, RI 02882
;-
; *************************************************************************
FUNCTION STRUCT_VALUES, Struct,Names, TAGNAMES=Tagnames, TAGS=Tags, FIN=fin, LABEL=label, ERROR=error
  ROUTINE_NAME='STRUCT_VALUES'

	ERROR = 0

; =====> Ensure Input information is correct
  sz_struct   = SIZE(Struct,/STRUCT)
  sz_names 		= SIZE(Names,/STRUCT)
  sz_tagnames = SIZE(Tagnames,/STRUCT)
  sz_tags     = SIZE(Tags,/STRUCT)
  IF sz_struct.type  NE 8 THEN BEGIN
    PRINT,'ERROR: Must provide Struct'
    ERROR = 1
    RETURN, -1
  ENDIF

  IF sz_names.n_elements GE 1 AND sz_names.type   NE 7 THEN BEGIN
    PRINT,'ERROR: Names must be String Type'
    ERROR = 1
    RETURN, -1
  ENDIF
	IF sz_tagnames.n_elements GE 1 AND sz_tagnames.type   NE 7 THEN BEGIN
    PRINT,'ERROR: Tagnames must be String Type'
    ERROR = 1
    RETURN, -1
  ENDIF
  ntags        = N_TAGS(Struct)
  nth_tag      = ntags -1L
  struct_names = TAG_NAMES(Struct)
  tag_subs     = LINDGEN(ntags)
  tag_targets  = -1L

	IF N_ELEMENTS(LABEL) NE 1 THEN _LABEL = ''	ELSE _LABEL = STRTRIM(LABEL,2)

	IF sz_names.n_elements EQ 0 AND sz_tagnames.n_elements EQ 0 AND sz_tags.n_elements EQ 0 THEN BEGIN
   tag_targets=[-1L,LINDGEN(N_TAGS(STRUCT))]
  ENDIF

; =====>If Tagnames provided then find tag numbers from Tagnames, conserving the input order
  IF sz_tagnames.n_elements EQ 0 AND sz_names.n_elements GE 1 AND sz_tags.n_elements EQ 0 THEN BEGIN;   >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
    FOR nth=0L, N_ELEMENTS(names)-1L DO BEGIN
      target = STRUPCASE(names(nth))
      OK = WHERE(STRPOS(struct_names,TARGET) GE 0,COUNT)
      IF count GE 1 THEN tag_targets=[tag_targets,(ok)]
    ENDFOR
  ENDIF

; =====>If Tagnames provided then find tag numbers from Tagnames, conserving the input order
  IF sz_tagnames.n_elements GE 1 AND sz_names.n_elements EQ 0 AND sz_tags.n_elements EQ 0 THEN BEGIN
;   >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
    FOR nth=0L, N_ELEMENTS(tagnames)-1L DO BEGIN
      target = STRUPCASE(Tagnames(nth))
      ok = WHERE(struct_names EQ target,count)
      IF count EQ 1 THEN tag_targets=[tag_targets,(ok)]
    ENDFOR
  ENDIF

; =====> If TAGS Provided, extract just the valid TAGS numbers for Struct, conserving the input order
   IF sz_tagnames.n_elements EQ 0 AND sz_names.n_elements EQ 0 AND sz_tags.n_elements GE 1 THEN BEGIN
;   >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
     FOR nth=0L, N_ELEMENTS(tags)-1L DO BEGIN
      target = Tags(nth)
      ok = WHERE(tag_subs EQ target,count)
      IF count EQ 1 THEN tag_targets=[tag_targets,(ok)]
    ENDFOR
  ENDIF

; =====> If no targets were found return -1L
  IF N_ELEMENTS(tag_targets) GE 2 THEN BEGIN
  	tag_targets = tag_targets(1:*)
  ENDIF ELSE BEGIN
  	ERROR = 1
  	PRINT,'ERROR: The tags or Tagnames provided are not found in the Structure'
  	RETURN, -1
  ENDELSE

;	===> Eliminate redundant tag_targets
	sets=WHERE_SETS(TAG_TARGETS)
	S=SORT(SETS.FIRST)
	TAG_TARGETS = SETS(S).VALUE

	VAL = REPLICATE(CREATE_STRUCT('LABEL',_LABEL,'NAME','','TYPE','','MIN','','MAX','','VALUE','','N',''),N_ELEMENTS(TAG_TARGETS))

; =====> Make a new structure of values for the TAG_TARGETS
  FOR nth = 0L, N_ELEMENTS(TAG_TARGETS)-1L DO BEGIN
    atag = tag_targets(nth)
    anam = Struct_names(atag)

    aval = Struct[0].(ATAG)
    atype = IDLTYPE(AVAL)

		VAR = STRUCT.(ATAG)

		IF KEYWORD_SET(FIN) THEN BEGIN
			OK=WHERE(VAR NE MISSINGS(VAR),COUNT)
			IF COUNT GE 1 THEN VAR = VAR[OK] ELSE VAR(*) = MISSINGS(VAR)
		ENDIF


	 	SETS=WHERE_SETS(VAR)

;		===> SORT Sets Padded with ZEROs so first and last works below
		TXT=STR_PAD(SETS.VALUE)
		SRT=SORT(TXT)
		SETS = SETS(SRT)

		VAL[NTH].NAME=ANAM
		VAL[NTH].TYPE=atype
		VAL[NTH].MIN =FIRST(SETS.VALUE)
		VAL[NTH].MAX =LAST(SETS.VALUE)
		VAL[NTH].VALUE = STRJOIN(STRTRIM(SETS.VALUE,2)+';')
		VAL[NTH].N = STRJOIN(STRTRIM(SETS.N,2)+';')

  ENDFOR

  RETURN,VAL


  END; #####################  End of Routine ################################
