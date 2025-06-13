; $ID:	CONVERT_RRS_555.PRO,	2023-09-19-17,	USER-KJWH	$

  FUNCTION CONVERT_RRS_555, RRS, WAVELENGTH

;+
; NAME:
;   CONVERT_RRS_555
;
; PURPOSE:
;   This procedure converts the RRS at a given wavelength to RRS at 555 nm.  
;
; CATEGORY:
;   ALGORITHM_FUNCTIONS
;   
; CALLING SEQUENCE:
;   Result = CONVERT_RRS_555(VALUE, WAVELENGTH, ERROR=ERROR, ERR_MSG=ERR_MSG)
;
; REQUIRED INPUTS:
;   RRS............ The value of the input RRS data
;   WAVELENGTH..... The input wavelength
;
; OPTIONAL INPUTS:
;   None
;
; KEYWORD PARAMETERS:
;   None
;   
; OUTPUTS:
;   This function returns the converted RRS value.
;   If the wavelength difference is less than 2 nm, then the original RRS value is returned
;
; OPTIONAL OUTPUTS:
;   None
;   
; EXAMPLE:
;
; 
; NOTES:
;   Converted from SeaDAS 6.2 'C' routine in l2gen/convert_band.c
;   http://oceancolor.gsfc.nasa.gov/DOCS/OCSSW/convert__band_8c_source.html
;
; COPYRIGHT:
; Copyright (C) 2011, Department of Commerce, National Oceanic and Atmospheric Administration, National Marine Fisheries Service,
;   Northeast Fisheries Science Center, Narragansett Laboratory.
;   This software may be used, copied, or redistributed as long as it is not sold and this copyright notice is reproduced on each copy made.
;   This routine is provided AS IS without any express or implied warranties whatsoever.
;
; AUTHOR:
;   This program was written on April 26, 2011 by Kimberly J. W. Hyde, Northeast Fisheries Science Center | NOAA Fisheries | U.S. Department of Commerce, 28 Tarzwell Dr, Narragansett, RI 02882
;
; MODIFICATION HISTORY:
;	  Apr 25, 2011 - KJWH: Initial code written 
;		Oct 21, 2021 - KJWH: Updated documentation and formatting
;		                     Removed ERROR and ERR_MSG output variables
;		                     Added COMPILE_OPT IDL2 
;		                     Changed subscript () to []
;-
;	****************************************************************************************************
	ROUTINE_NAME = 'CONVERT_RRS_555'
	COMPILE_OPT IDL2
		 
  IF (ABS(WAVELENGTH-555.0) GT 2.0) THEN BEGIN
    IF (ABS(WAVELENGTH-547.0) LE 2.0) THEN BEGIN
       SW = 0.001723;
       A1 = 0.986;
       B1 = 0.081495;
       A2 = 1.031;
       B2 = 0.000216;
    ENDIF ELSE BEGIN
      IF (ABS(WAVELENGTH-550.0) LE 2.0) THEN BEGIN
       SW = 0.001597;
       A1 = 0.988;
       B1 = 0.062195;
       A2 = 1.014;
       B2 = 0.000128;
      ENDIF ELSE BEGIN
        IF (ABS(WAVELENGTH-560.0) LE 2.0) THEN BEGIN
          SW = 0.001148;
          A1 = 1.023;
          B1 = 0.103624;
          A2 = 0.979;
          B2 = 0.000121;
        ENDIF ELSE BEGIN
          ERROR = 1
          ERR_MSG='Unable to convert Rrs at ' + NUM2STR(WAVELENGTH) + ' to 555 nm.'
          PRINT, ERR_MSG
          RETURN, []
        ENDELSE
      ENDELSE
    ENDELSE
  ENDIF ELSE RETURN, RRS  
  OK = WHERE(RRS LT SW,COUNT,COMPLEMENT=COMPLEMENT,NCOMPLEMENT=NCOMPLEMENT)
  IF COUNT GE 1 THEN RRS[OK] = (10.0 ^(A1 * ALOG10(RRS[OK]) - B1 )) 
  IF NCOMPLEMENT GE 1 THEN RRS[COMPLEMENT] = (A2 * RRS[COMPLEMENT] - B2 )  
  RETURN, RRS


END; #####################  End of Routine ################################
