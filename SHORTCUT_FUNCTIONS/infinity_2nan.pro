; $ID:	INFINITY_2NAN.PRO,	2023-09-21-13,	USER-KJWH	$

FUNCTION INFINITY_2NAN, DATA
;+
; NAME:
;   INFINITY_2NAN
;
; PURPOSE:
;   Convert INFINITY (infinity for float and double) to to NAN (not a number)
;
; CALLING SEQUENCE:
;   Result = INFINITY_2NAN(DATA) 
;   
; REQUIRED INPUTS:
;   Data.......... Data or structure
;
; OPTIONAL INPUTS:
;   None
;
; KEYWORD PARAMETERS:
;   None
;   
; OUTPUTS:
;   OUTPUT.......... Data where the infinity values are changed to NaN
;
; OPTIONAL OUTPUTS:
;   None
;
; COMMON BLOCKS:
;   None
;
; SIDE EFFECTS:
;   None
;
; RESTRICTIONS:
;   None
;
; EXAMPLE  
;   PRINT, INFINITY_2NAN([0.0,!values.f_infinity]) 
;   STRUCT= REPLICATE(CREATE_STRUCT('DAT',0.0D),3) & STRUCT(0:1).DAT = !VALUES.F_INFINITY & SPREAD, INFINITY_2NAN(STRUCT)
;
; NOTES:
;   
;
; COPYRIGHT:
; Copyright (C) 2000, Department of Commerce, National Oceanic and Atmospheric Administration, National Marine Fisheries Service,
;   Northeast Fisheries Science Center, Narragansett Laboratory.
;   This software may be used, copied, or redistributed as long as it is not sold and this copyright notice is reproduced on each copy made.
;   This routine is provided AS IS without any express or implied warranties whatsoever.
;
; AUTHOR:
;   This program was written on March 15, 2000 by John E. O'Reilly, Northeast Fisheries Science Center | NOAA Fisheries | U.S. Department of Commerce, 28 Tarzwell Dr, Narragansett, RI 02882
;   Inquires can be directed to kimberly.hyde@noaa.gov
;
; MODIFICATION HISTORY:
;   Mar 15, 2000 - JEOR - Wrote initial code
;   Oct 06, 2020 - KJWH - Updated documentation
;                         Moved to SHORTCUT_FUNCTIONS
;                         Added COMPILE_OPT IDL2
;                         Changed subscript () to []
;                         Removed MISSING keyword because it was not used
;-

	ROUTINE_NAME='INFINITY_2NAN'
	COMPILE_OPT IDL2

  COPY = DATA                       ; Work with a copy of the input data
  TYPE = IDLTYPE(COPY,/CODE)

  IF TYPE EQ 8 THEN BEGIN           ; Look at the data within a structure
    NTAGS = N_TAGS(COPY)
    FOR N = 0L, NTAGS-1L DO BEGIN
    	_DATA = COPY.(N)
      TYPE = IDLTYPE(_DATA,/CODE)
      IF TYPE EQ 4 OR TYPE EQ 5 THEN BEGIN
      	OK = WHERE(FINITE(_DATA) NE 1,COUNT)
      	IF COUNT GE 1 THEN COPY.(N) = INFINITY_2NAN(_DATA)
      ENDIF
    ENDFOR
  ENDIF ELSE BEGIN

	  IF TYPE EQ 4 OR TYPE EQ 5 THEN BEGIN
	     OK = WHERE(FINITE(COPY) NE 1,COUNT)
	     IF COUNT GE 1 THEN BEGIN
	       IF TYPE EQ 4 THEN COPY[OK]  = !VALUES.F_NAN
	       IF TYPE EQ 5 THEN COPY[OK]  = !VALUES.D_NAN
	     ENDIF
	  ENDIF

  ENDELSE

  RETURN, COPY
END; #####################  End of Routine ################################

