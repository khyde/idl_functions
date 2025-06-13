; $ID:	SUBSAMPLE.PRO,	2023-09-21-13,	USER-KJWH	$
	FUNCTION SUBSAMPLE,ARRAY,NTH
;+
; NAME:
;		SUBSAMPLE
;
; PURPOSE:
;		This function subsamples an array by returning every nth value in the array
;
; CATEGORY:
;		ARRAY
;
; CALLING SEQUENCE:
;		RESULT = SUBSAMPLE(ARRAY,NTH)
;
; INPUTS:
;		ARRAY..... An array
;   NTH....... Select every NTH value for the output
;
; OUTPUTS:
;		This function returns every NTH value in the array
;
; EXAMPLE:
;		A=SUBSAMPLE(INDGEN(100),10) & PRINT, A  ;
;        0      10      20      30      40      50      60      70      80      90
;
; COPYRIGHT:
; Copyright (C) 1998, Department of Commerce, National Oceanic and Atmospheric Administration, National Marine Fisheries Service,
;   Northeast Fisheries Science Center, Narragansett Laboratory.
;   This software may be used, copied, or redistributed as long as it is not sold and this copyright notice is reproduced on each copy made.
;   This routine is provided AS IS without any express or implied warranties whatsoever.
;
; AUTHOR:
;   This program was written on November 29, 1998 by J.E. O'Reilly, DOC/NOAA/NMFS/NEFSC Narragansett, RI
;   Inquiries on this code should be directed to: kimberly.hyde@noaa.gov
;
; MODIFICATION HISTORY:
;			NOV 29, 1998 - JEOR: Wrote the initial code
;			JAN 10, 2014 - JEOR: Updated formatting
;			JUL 01, 2020 - KJWH: Updated documentation
;			                     Added COMPILE_OPT IDL2
;			                     Changed subscript () to []			
;-
; ###################################################################################################

	ROUTINE_NAME = 'SUBSAMPLE'
  COMPILE_OPT IDL2
  
 	IF N_ELEMENTS(ARRAY) LT 1 THEN RETURN, -1
 	IF N_ELEMENTS(NTH) NE 1 THEN NTH = 1
 	SUBSCRIPTS = LINDGEN(N_ELEMENTS(ARRAY))
 	OK = WHERE(SUBSCRIPTS MOD NTH EQ 0)
 	RETURN,ARRAY[OK]
 	
END; #####################  END OF ROUTINE ################################
