; $ID:	STRUCT_CONCAT.PRO,	2020-07-28-09,	USER-KJWH	$
;##############################################################################################
FUNCTION STRUCT_CONCAT, ARRAY1, ARRAY2
;+
; NAME:
;   STRUCT_CONCAT
;
; PURPOSE:
;   Concatenates two structures [ARRAY1,ARRAY2] into a new structure
;     * If the tag names for ARRAY1 and ARRAY2 are not the same then the program makes a new structure 
;       from the tagnames in ARRAY1 and ARRAY2 and returns the concatenated arrays
;
; CALLING SEQUENCE:
;   C = STRUCT_CONCAT(A,B)
;
; INPUTS:
;   Two spreadsheet type structures (can differ in number of elements and tagnames).
;
; OUTPUTS:
;   A new structure comprised of all data from both input structures.
;
; NOTES:
;
; COPYRIGHT:
; Copyright (C) 2019, Department of Commerce, National Oceanic and Atmospheric Administration, National Marine Fisheries Service,
;   Northeast Fisheries Science Center, Narragansett Laboratory.
;   This software may be used, copied, or redistributed as long as it is not sold and this copyright notice is reproduced on each copy made.
;   This routine is provided AS IS without any express or implied warranties whatsoever.
;
;   This program was written by John E. O'Reilly, DOC/NOAA/NMFS/NEFSC Narragansett, RI on March 22, 2000
;          with assistance from Kimberly Hyde, DOC/NOAA/NMFS/NEFSC Narragansett, RI.  Questions should be directed to kimberly.hyde@noaa.gov.
;
; MODIFICATION HISTORY:
;   Mar 22, 2000 - JEOR: Adopted code from MERGE_STRUCT.pro
;	  Dec 15, 2004 - JEOR: Allow tagnames to differ between ARRAY1 and ARRAY2
;	  Jul 28, 2020 - KJWH: Added COMPILE_OPT IDL2
;	                       Changed subscript () to []
;	                       Updated documentation
;	                       Updated formatting
;-
;########################################################################################

  ROUTINE_NAME = 'STRUCT_CONCAT'
  COMPILE_OPT IDL2

; =====> MAKE SURE THE ARRAY HAS SOMETHING IN IT AND THAT IT IS A STRUCTURE
  N1 = N_ELEMENTS(ARRAY1) & N2 = N_ELEMENTS(ARRAY2)
  IF N1 EQ 0 OR IDLTYPE(ARRAY1)  NE 'STRUCT' THEN BEGIN
    MESSAGE, 'ERROR: MUST INPUT A STRUCTURE ARRAY'
    RETURN, []
  ENDIF
  IF N2 EQ 0 OR IDLTYPE(ARRAY2)  NE 'STRUCT' THEN BEGIN
    MESSAGE, 'ERROR: MUST INPUT A STRUCTURE ARRAY'
    RETURN, []
  ENDIF

; =====> DETERMINE TAG NAMES AND NUMBER OF TAGS FOR BOTH INPUT STRUCTURES
  NAMES1 = TAG_NAMES(ARRAY1)
  NAMES2 = TAG_NAMES(ARRAY2)
  NAMES  = [NAMES1,NAMES2]
 	SETS   = WHERE_SETS(NAMES)
 	S      = SORT(SETS.FIRST)
 	NAMES  = SETS[S].VALUE

;	===> FIND THE NAMES IN ARRAY2 NOT ALREADY IN NAMES1 BY COMPARING NAMES1 AGAINST ALL UNIQUE NAMES
 	OK = WHERE_IN(NAMES,NAMES1,COUNT,NCOMPLEMENT=NCOMPLEMENT,COMPLEMENT=COMPLEMENT)

;	===> ENSURE THAT DATA TYPES REMAIN SAME AS IN THE INPUT
	COPY = ARRAY1[0]

;	===> ADDITIONAL TAGNAMES NEEDED TO HOLD BOTH STRUCTURES ?
	IF NCOMPLEMENT GE 1 THEN BEGIN
		FOR NTH=0L, NCOMPLEMENT-1L DO BEGIN
			ANAME = NAMES[COMPLEMENT[NTH]]
			POS 	= WHERE(NAMES2 EQ ANAME,/NULL)
			DATUM = ARRAY2[0].(POS)
			COPY	=	CREATE_STRUCT(COPY, ANAME, DATUM)
		ENDFOR
	ENDIF

; ===> SET THE NEW STRUCTURE TO MISSINGS CODES AND CREATE NEW BLANK STRUCTURES
	COPY  = STRUCT_2MISSINGS(COPY) 
	COPY1 = REPLICATE(COPY,N1)
	COPY2 = REPLICATE(COPY,N2)

  STRUCT_ASSIGN, ARRAY1, COPY1, /NOZERO
  STRUCT_ASSIGN, ARRAY2, COPY2, /NOZERO

  RETURN, [COPY1,COPY2]
END; #####################  END OF ROUTINE ################################
