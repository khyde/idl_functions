; $ID:	YEAR_RANGE.PRO,	2023-09-21-13,	USER-KJWH	$

	FUNCTION YEAR_RANGE, START_YEAR, END_YEAR, STRING=STRING, PERIOD=PERIOD

;+
; NAME:
;		YEAR_RANGE
;
; PURPOSE:
;		This function will create a list of years ranging from the input start and end years
;
; CATEGORY:
;		Dates
;
; CALLING SEQUENCE:
;
; INPUTS:
;		START_YEAR....... Beginning Year (e.g. 2002)
;		END_YEAR......... End Year (e.g. 2008)
;
; OPTIONAL INPUTS:
;
; KEYWORD PARAMETERS:
;   STRING........... Set to return the number list in STRING format
;   PERIOD........... Set to return the array as periods (A_yyyy)
;
; OUTPUTS:
;		This function returns an array of sequential years (2002,2003,2004,2005,2006,2007,2008)
;
; OPTIONAL OUTPUTS:
;
;	PROCEDURE:
;
; EXAMPLE:
;   YEARS = YEAR_RANGE(2002, 2008)
;   YEARS = YEAR_RANGE(2002, 2008,/STRING)
;
;	NOTES:
;
; COPYRIGHT:
;   Copyright (C) 2020, Department of Commerce, National Oceanic and Atmospheric Administration, National Marine Fisheries Service,
;   Northeast Fisheries Science Center, Narragansett Laboratory.
;   This software may be used, copied, or redistributed as long as it is not sold and this copyright notice is reproduced on each copy made.
;   This routine is provided AS IS without any express or implied warranties whatsoever.
;
;   This program was written March 25, 2011 by Kimberly J. W. Hyde, Northeast Fisheries Science Center | NOAA Fisheries | U.S. Department of Commerce, 28 Tarzwell Dr, Narragansett, RI 02882
;
; MODIFICATION HISTORY:
;	  Oct 23, 2018 - KJWH: Added IF STRLEN(START_YEAR) GT 4 THEN START_YEAR = STRMID(START_YEAR,0,4) and 
;                              IF STRLEN(END_YEAR)   GT 4 THEN END_YEAR   = STRMID(END_YEAR,0,4)
;                          so that full dates could be used as inputs.   
;   Apr 23, 2020 - KJWH: Added START_YEAR = STRTRIM(START_YEAR,2) and END_YEAR = STRTRIM(END_YEAR,2) so that dates entered as numbers will work  
;                        Updated documentation  
;   Jan 07, 2020 - KJWH: Added an option to determine the start and end years from a date range  
;   Nov 07, 2022 - KJWH: Added IF ~N_ELEMENTS(END_YEAR) THEN RETURN, START_YEAR in case only a single year is passed to the function                                   
;-
;	****************************************************************************************************
	ROUTINE_NAME = 'YEAR_RANGE'
	COMPILE_OPT IDL2

  IF N_ELEMENTS(START_YEAR) EQ 2 AND N_ELEMENTS(END_YEAR) EQ 0 THEN BEGIN
    END_YEAR = START_YEAR[1]
    START_YEAR = START_YEAR[0]
  ENDIF
  
  IF ~N_ELEMENTS(END_YEAR) THEN RETURN, START_YEAR
  
  START_YEAR = STRTRIM(START_YEAR,2)
  END_YEAR = STRTRIM(END_YEAR,2)

  IF STRLEN(START_YEAR) GT 4 THEN START_YEAR = STRMID(START_YEAR,0,4)
  IF STRLEN(END_YEAR)   GT 4 THEN END_YEAR   = STRMID(END_YEAR,0,4)
  
  YEARS = FIX(START_YEAR)
  
  WHILE (MAX(YEARS) LT FIX(END_YEAR)) DO YEARS = [YEARS,MAX(YEARS)+1]
  
  IF KEYWORD_SET(STRING) THEN YEARS=NUM2STR(YEARS)
  IF KEYWORD_SET(PERIOD) THEN BEGIN
    CASE PERIOD OF 
      'A': PERS = 'A_' + NUM2STR(YEARS)                                                             ; Create the 'A' period 
      'Y': PERS = 'Y_' + NUM2STR(YEARS)                                                             ; Create the 'Y' period
      ELSE: PERS = 'A_' + NUM2STR(YEARS)                                                            ; By default, create the 'A' period because it is the most commonly used annual period
    ENDCASE
    RETURN, PERS 
  ENDIF
  RETURN, YEARS 



END; #####################  End of Routine ################################
