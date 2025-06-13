; $ID:	ADD_STR_ZERO.PRO,	2023-09-21-13,	USER-KJWH	$

FUNCTION ADD_STR_ZERO, NUM, DIGITS=DIGITS
;+
; NAME:
;   ADD_STR_ZERO
;
; PURPOSE:
;		This function will add a 0 in front of a single digit number (9 to 09)
;
; CATEGORY:
;		FORMAT_FUNCTIONS
;
; CALLING SEQUENCE:
;   RESULT = ADD_STR_ZERO('9')
;
; REQUIRED INPUTS:
;   NUM......... The number to add the '0' to
;   
; OPTIONAL INPUS  
;   DIGITS....... The total number of digits in the string (default is 2)
;	
;	KEYWORD PARAMETERS:
;	  None
;	
;	OUTPUTS:
;	  Returns string array of numbers with a '0'(s) added to the beginning of the number
;	  
;	OPTIONAL OUTPUTS
;	  None
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
; EXAMPLE:
;   R = ADD_STR_ZERO(9)
;   R = ADD_STR_ZERO(99)
;   R = ADD_STR_ZERO([9,10])
;   R = ADD_STR_ZERO([9,99,100])
;   R = ADD_STR_ZERO([9,99,100], DIGITS=4)
;   R = MONTH_RANGE(INDGEN(365))
;
; NOTES:
;
;
; COPYRIGHT:
; Copyright (C) 2014, Department of Commerce, National Oceanic and Atmospheric Administration, National Marine Fisheries Service,
;   Northeast Fisheries Science Center, Narragansett Laboratory.
;   This software may be used, copied, or redistributed as long as it is not sold and this copyright notice is reproduced on each copy made.
;   This routine is provided AS IS without any express or implied warranties whatsoever.
;
; AUTHOR:
;   This program was written on September 05, 2007 by Kimberly J. W. Hyde, Northeast Fisheries Science Center | NOAA Fisheries | U.S. Department of Commerce, 28 Tarzwell Dr, Narragansett, RI 02882
;
; MODIFICATION HISTORY:
;   Sep 05, 2007 - KJWH: Initial code written
;   Aug 06, 2015 - KJWH: Added DIGITS keyword so you can add multiple zeros at the beginning of the string
;   Nov 01, 2022 - KJWH: Updated documentation
;                        Added COMPILE_OPT IDL2
;                        Changed subscript () to []
;                        Now using the maximum string length to determine the defaul value for DIGITS if not provided
;                        Now using WHERE_SETS(STRLEN(NUM)) to subset the input numbers into groups rather than looping through each input variable 
;-
; ****************************************************************************************************
  ROUTINE_NAME = 'MONTH_RANGE'
  COMPILE_OPT IDL2
	
	NUM = STRTRIM(STRING(NUM),2)
  IF ~N_ELEMENTS(DIGITS) THEN DIGITS = MAX(STRLEN(NUM)) > 2
  
  ZEROS = NUM
  SETS = WHERE_SETS(STRLEN(NUM))
  
  FOR N=0, N_ELEMENTS(SETS)-1 DO BEGIN
    DIF = DIGITS - SETS[N].VALUE
    IF DIF LE 0 THEN CONTINUE
    SUBS = WHERE_SETS_SUBS(SETS[N])
    ZEROS[SUBS] = REPLICATE(STRJOIN(REPLICATE('0',DIF)),SETS[N].N) + ZEROS[SUBS]
  ENDFOR
  
  RETURN, ZEROS

END ; END OF PROGRAM
