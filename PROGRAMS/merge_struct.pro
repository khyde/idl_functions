; $ID:	MERGE_STRUCT.PRO,	2020-06-30-17,	USER-KJWH	$

function MERGE_STRUCT, ARRAY1, ARRAY2
;+
; NAME:
;       MERGE_STRUCT
;
; PURPOSE:
;       Copy (merges) all tags from two structureS into a new structure
;       (provided the number of elements is the same for the two input structures,
;        and provided that the tag names array1 and array2 are different)
;
; CATEGORY:
;       MISC.
;
; CALLING SEQUENCE:
;       B = MERGE_STRUCT(A,B)

;
; INPUTS:
;       Two structure of equal dimensions.
;       (The number of tags may be different, but tag names in array2 can
;        not match any tag names in array1)
;
; KEYWORD PARAMETERS:

;       None
;
; OUTPUTS:
;       A new Structure comprised of all tags and data from both input structures
;
; SIDE EFFECTS:
;       None.
;
; RESTRICTIONS:
;       None.
;
; PROCEDURE:
;       Straightforward.
;
; MODIFICATION HISTORY:
;       Written by:  J.E.O'Reilly, February 4,1998
;-

; ==================>
; Make sure the array has something in it and that it is a Structure
  n1 = N_ELEMENTS(ARRAY1) & N2 = N_ELEMENTS(ARRAY2)
  IF N1 EQ 0 OR IDLTYPE(ARRAY1)  NE 'STRUCT' THEN MESSAGE,"ERROR: MUST INPUT A STRUCTURE ARRAY'
  IF N2 EQ 0 OR IDLTYPE(ARRAY2)  NE 'STRUCT' THEN MESSAGE,"ERROR: MUST INPUT A STRUCTURE ARRAY'

; ==================>
; Make sure both structure arrays are same size
  IF N1 NE N2 THEN MESSAGE,'ERROR: BOTH STRUCTURES MUST BE SAME SIZE'

; ==================>
; Determine tag names and numbe of tags for both input structures
  NAMES1      = TAG_NAMES(ARRAY1)
  NAMES2      = TAG_NAMES(ARRAY2)

  N_TAGS1      = N_ELEMENTS(names1)
  N_TAGS2      = N_ELEMENTS(names2)


; ==================>
; Make a new structure to hold each of the requested valid tag numbers
  FOR nth = 0, N_TAGS1-1L DO BEGIN
    ANAM = NAMES1(nth)
    AVAL = ARRAY1[0].(nth)
    IF nth EQ 0 THEN BEGIN
      template = CREATE_STRUCT(ANAM,AVAL)
    ENDIF ELSE BEGIN
      template = CREATE_STRUCT(template,ANAM,AVAL)
    ENDELSE
  ENDFOR

  FOR nth = 0, N_TAGS2-1L DO BEGIN
    ANAM = NAMES2(nth)
    AVAL = ARRAY2[0].(nth)
    template = CREATE_STRUCT(template,ANAM,AVAL)
  ENDFOR


; ==================>
; Replicate the template to hold all data from the input array
  DATA = REPLICATE(TEMPLATE,N1)

; ==================>
; Fill the data array structure with the appropriate values from the input arrayS
; ==================>

  start = 0 & finish = N_TAGS1 -1L
  FOR nth = start, finish DO BEGIN
    DATA(*).(nth) = ARRAY1(*).(nth)
  ENDFOR

  start = N_TAGS1 & finish = N_TAGS1+N_TAGS2 -1L
  FOR nth = start, finish DO BEGIN
     DATA(*).(nth) = ARRAY2(*).(nth-start)
  ENDFOR



  RETURN, DATA
  END ; END of PROGRAM
