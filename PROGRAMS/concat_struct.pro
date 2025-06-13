; $ID:	CONCAT_STRUCT.PRO,	2020-06-30-17,	USER-KJWH	$

function CONCAT_STRUCT, ARRAY1, ARRAY2
;+
; NAME:
;       CONCAT_STRUCT
;
; PURPOSE:
;       Concatinates two structures into a new structure
;       (provided the number of tags, tag names and data type is the same
;       for the two input structures array1 and array2)
;
; CATEGORY:
;       MISC.
;
; CALLING SEQUENCE:
;       C = CONCAT_STRUCT(A,B)

;
; INPUTS:
;       Two identical structures ( can differ in number of elements).
;       (The number of tags, tag names and their position, and data types
;        in array1 must match those in array2.)
;
; KEYWORD PARAMETERS:

;       None
;
; OUTPUTS:
;       A new Structure comprised of all data from both input structures
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
;       Adopted from MERGE_STRUCT.PRO :  T.Ducas, Nov 12,1999
;       Modified March 22,2000, JOR: IF IDLTYPE(ARRAY1.(I)) NE IDLTYPE(ARRAY2.(I)) THEN BEGIN
;-

; ==================>
; Make sure the array has something in it and that it is a Structure
  n1 = N_ELEMENTS(ARRAY1) & N2 = N_ELEMENTS(ARRAY2)
  IF N1 EQ 0 OR IDLTYPE(ARRAY1)  NE 'STRUCT' THEN BEGIN
    MESSAGE = DIALOG_MESSAGE("ERROR: MUST INPUT A STRUCTURE ARRAY",/INFORMATION)
    RETURN, -1
  ENDIF
  IF N2 EQ 0 OR IDLTYPE(ARRAY2)  NE 'STRUCT' THEN BEGIN
    MESSAGE = DIALOG_MESSAGE("ERROR: MUST INPUT A STRUCTURE ARRAY",/INFORMATION)
    RETURN, -1
  ENDIF

; ==================>
; Determine tag names and number of tags for both input structures
  NAMES1      = TAG_NAMES(ARRAY1)
  NAMES2      = TAG_NAMES(ARRAY2)

  N_TAGS1      = N_ELEMENTS(names1)
  N_TAGS2      = N_ELEMENTS(names2)


; ==================>
; make sure number of tags, tag order and data type is the same for both structures
  IF N_TAGS1 EQ N_TAGS2 THEN BEGIN
    FOR I = 0, N_TAGS1 -1L DO BEGIN
      IF NAMES1(I) NE NAMES2(I) THEN BEGIN
        MESSAGE = DIALOG_MESSAGE("ERROR: TAG ORDER MUST BE THE SAME"$
        + " IN BOTH STRUCTURES",/INFORMATION)
        RETURN, -1
      ENDIF
      ;; modified IF IDLTYPE(ARRAY1(I)) NE IDLTYPE(ARRAY2(I)) THEN BEGIN
       IF IDLTYPE(ARRAY1.(I)) NE IDLTYPE(ARRAY2.(I)) THEN BEGIN
        MESSAGE, "ERROR: CORRESPONDING DATA TYPES MUST BE THE SAME"
        RETURN, -1
      ENDIF
     ENDFOR
  ENDIF ELSE BEGIN
    MESSAGE = DIALOG_MESSAGE("ERROR: BOTH STRUCTURES MUST HAVE SAME"$
    + " NUMBER OF TAG NAMES",/INFORMATION)
    RETURN, -1
  ENDELSE

; ==================>
; Make a new structure to hold both structures
  FOR nth = 0L, N_TAGS1-1L DO BEGIN
    ANAM = NAMES1(nth)
    AVAL = ARRAY1[0].(nth)
    IF nth EQ 0 THEN BEGIN
      template = CREATE_STRUCT(ANAM,AVAL)
    ENDIF ELSE BEGIN
      template = CREATE_STRUCT(template,ANAM,AVAL)
    ENDELSE
  ENDFOR

; ==================>
; Replicate the template to hold all data from both arrays
  DATA = REPLICATE(TEMPLATE,N1 + N2)

; ==================>
; start filling data array structure with the values from array1
  FOR I = 0L, N1 - 1L DO BEGIN
    FOR J = 0L,N_TAGS1 - 1L DO BEGIN
      DATA(I).(J) = ARRAY1(I).(J)
    ENDFOR
  ENDFOR


; ==================>
; continue filling data array structure with the values from array2
  FOR I = 0L, N2 - 1L DO BEGIN
    FOR J = 0L,N_TAGS1 - 1L DO BEGIN
      DATA(N1 + I).(J) = ARRAY2(I).(J)
    ENDFOR
  ENDFOR
  RETURN, DATA
  END ; END of PROGRAM
