; $ID:	STRUCT_SMERGE.PRO,	2020-06-30-17,	USER-KJWH	$
;+
;	This Function Merges Two Structures to form a New Structure
;
; SYNTAX:
;	Result = STRUCT_SMERGE(Struct1, Struct2)
; OUTPUT:
;	A new Structure with all tags and data from both input structures
; ARGUMENTS:
; 	Struct1:	First Structure
; 	Struct2:	Second Structure
; KEYWORDS:
;
; EXAMPLE:
; 	Struct1 = CREATE_STRUCT('AA',0B,'BB',1,'CC',2L) & Struct1=REPLICATE(Struct1,5)
; 	Struct2 = CREATE_STRUCT('E',3.,'F',4D,'G','5')  & Struct2=REPLICATE(Struct2,5)
; 	Result  = STRUCT_SMERGE(Struct1,Struct2)
;
; NOTES:
;		This routine expects simple (spreadsheet or database type) structures.
;		Both Structures Must have the same number of elements(records).
;		The two structures can have no Tagnames in common
;   (if so rename tags using STRUCT_RENAME.PRO before using STRUCT_SMERGE)
;
; VERSION:
;		Jan 15,2001
; HISTORY:
;		Feb 4,1998	Written by:	J.E. O'Reilly, NOAA, 28 Tarzwell Drive, Narragansett, RI 02882
;-
; *************************************************************************

FUNCTION STRUCT_SMERGE, Struct1, Struct2
  ROUTINE_NAME='STRUCT_SMERGE'

; =====> Make sure Struct1 and Struct2 are structures
  size_struct1=SIZE(Struct1,/STRUCT)
  size_struct2=SIZE(Struct2,/STRUCT)

  IF size_struct1.type  NE 8 OR $
     size_struct2.type  NE 8 OR $
     size_struct1.n_elements NE size_struct2.n_elements THEN BEGIN
     PRINT,'ERROR: Struct1,Struct2 must be structures with same number of elements'
     RETURN, -1L
  ENDIF

; =====> Get information on Struct1, Struct2
  names1   = TAG_NAMES(Struct1)
  names2   = TAG_NAMES(Struct2)
  n_tags1  = N_TAGS(Struct1)
  n_tags2  = N_TAGS(Struct2)
  n1 = size_struct1.n_elements
  n2 = size_struct2.n_elements

; =====> Make a new structure to hold each of the requested valid tag numbers
  FOR nth = 0L, n_tags1-1L DO BEGIN
    anam = names1(nth)
    aval = struct1[0].(nth)
    IF nth EQ 0 THEN BEGIN
      template = CREATE_STRUCT(anam,aval)
    ENDIF ELSE BEGIN
      template = CREATE_STRUCT(template,anam,aval)
    ENDELSE
  ENDFOR

  FOR nth = 0, N_TAGS2-1L DO BEGIN
    anam = names2(nth)
    aval = struct2[0].(nth)
    template = CREATE_STRUCT(template,anam,aval)
  ENDFOR

; =====> Replicate the template to hold all data from the input struct
  data = REPLICATE(template,N1)

; =====> Fill the data struct structure with the appropriate values from the input structS
  start = 0 & finish = n_tags1 -1L
  FOR nth = start, finish DO BEGIN
    data(*).(nth) = struct1(*).(nth)
  ENDFOR

  start = n_tags1 & finish = n_tags1+n_tags2 -1L
  FOR nth = start, finish DO BEGIN
     data(*).(nth) = struct2(*).(nth-start)
  ENDFOR

  RETURN, data
  END; #####################  End of Routine ################################
