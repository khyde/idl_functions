; $ID:	YWEEK_2JD.PRO,	2023-09-21-13,	USER-KJWH	$

FUNCTION YWEEK_2JD, YEAR, WEEK, ENDDATE=ENDDATE,DATE=DATE
;+
; NAME:
;   YWEEK_2JD
;
; DESCRIPTION:
;	  Compute the Julian Day from Year and Week Number (1-52).  Week number may be decimal week
;
; REQUIRED INPUTS:
;   YEAR........ The year (YYYY)
;   WEEK........ The number (1-52) week of the year
; 
; OPTIONAL INPUTS:
; 
; KEYWORD PARAMETERS:
;   ENDDATE..... Return the julian day of the last day of the week  
;   DATE........ Return the value as a date (YYYYMMDDHHMMSS) instead of a julian date
; 
; OUTPUTS:
;   The julian date of the input YEAR+WEEK
; 
; OPTIONAL OUTPUTS:
;
; EXAMPLES:
;   PRINT, YWEEK_2JD('2000',1)
;   PRINT, YWEEK_2JD('2002','20')
;   PRINT, YWEEK_2JD('2000',1.5) ;NOTE CAN USE DECIMAL weeks
;   PRINT, YWEEK_2JD('2000',52) ;
;		PRINT, YWEEK_2JD('2000',52.9999)
;	  WEEK= DATE_2WEEK(['20011231235959','20001231235959'],/DEC)  & PRINT, JD_2DATE(YWEEK_2JD([2001,2000],WEEK))
;
; NOTES:
;
;
; COPYRIGHT:
; Copyright (C) 2006, Department of Commerce, National Oceanic and Atmospheric Administration, National Marine Fisheries Service,
;   Northeast Fisheries Science Center, Narragansett Laboratory.
;   This software may be used, copied, or redistributed as long as it is not sold and this copyright notice is reproduced on each copy made.
;   This routine is provided AS IS without any express or implied warranties whatsoever.
;
; AUTHOR INFORMATION
;   This program was written July 20, 2006 by John E. O'Reilly, Northeast Fisheries Science Center | NOAA Fisheries | U.S. Department of Commerce, 28 Tarzwell Dr, Narragansett, RI 02882
;     Inquires about this program should be directed to kimberly.hyde@noaa.gov
;
; MODIFICATION HISTORY:
;    JUL 20, 2006 - JEOR: Initial code written
;    MAR 11, 2011 - KJwH: Modified WEEK info
;    JAN 30, 2021 - KJWH: Updated documentation
;                         Added COMPILE_OPT IDL2
;                         Changed subscript () to []
;                         Now returning [] instead of -1 if there is an error
;    FEB 01, 2021 - KJWH: Added DATE keyword to return the JD in a date format (JD_2DATE(JD))
;                         Added ENDDATE keyword to return the last date in the week    
;    OCT 18, 2021 - KJWH: Added YEAR = NUM2STR(YEAR) to make sure the program is working with a string input                 
;-
; ***************************************************************************************
  ROUTINE_NAME = 'YWEEK_2JD'
  COMPILE_OPT IDL2


  IF N_ELEMENTS(YEAR) EQ 0 THEN RETURN, [] ELSE YEAR = NUM2STR(YEAR)
  IF N_ELEMENTS(WEEK) EQ 0 AND MIN(STRLEN(YEAR)) EQ 4 THEN RETURN, []

  OK = WHERE(STRLEN(YEAR) EQ 6,COUNT)
  IF COUNT GE 1 THEN BEGIN
    WEEK = INTARR(N_ELEMENTS(YEAR))
    WEEK[OK] = STRMID(YEAR[OK],4,2)
    YEAR[OK] = STRMID(YEAR[OK],0,4)    
  ENDIF  

;	===> Week 1 to 52
  FIX_WEEK 	= 1 > FIX(WEEK) < 52 ;
  JD_START_WEEK = YDOY_2JD(YEAR, (FIX_WEEK * 7-6))
  JD_END_WEEK   = YDOY_2JD(YEAR,  FIX_WEEK * 7 + JD_DAYS_WEEK(JD_START_WEEK)-7,23,59,59)
  JD_START      = JD_START_WEEK + (JD_DAYS_WEEK(JD_START_WEEK)) * (WEEK MOD FIX_WEEK) 
  JD_END        = JD_ADD(JD_END_WEEK, -(JD_DAYS_WEEK(JD_START_WEEK))*(WEEK MOD FIX_WEEK),/DAY)

	IF N_ELEMENTS(JD) EQ 1 THEN JD=JD[0]
	IF KEYWORD_SET(DATE) AND KEYWORD_SET(ENDDATE) THEN RETURN, JD_2DATE(JD_END)
	IF KEYWORD_SET(ENDDATE) THEN RETURN, JD_END
  IF KEYWORD_SET(DATE) THEN RETURN, JD_2DATE(JD_START) 
  RETURN, JD_START


END ; END OF PROGRAM
