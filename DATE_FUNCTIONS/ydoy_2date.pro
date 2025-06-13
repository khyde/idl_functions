; $ID:	YDOY_2DATE.PRO,	2023-09-21-13,	USER-KJWH	$
FUNCTION YDOY_2DATE, YEAR, DOY, HOUR, MINUTE, SECOND, YEARDOY=YEARDOY, SHORT=SHORT
;+
; NAME:
;   YDOY_2DATE
;
; PURPOSE:
;		Convert the year and day-of-year to DATE
;
; CATEGORY:
;   DATE function
;
; REQUIRED INPUTS:
;   YEAR...... Year of the day
;   DOY....... Day of the year
;   YEARDOY... Year plus day of year (if YEAR or DOY) are not provided 
;   
; OPTIONAL INPUTS:  
;   HOUR...... Hour of the day
;   MINUTE.... Minute of the hour
;   SECOND.... Second of the minute
;
; KEYWORD PARAMETERS:
;   SHORT..... Will just return an 8 digit date (YYYYMMDD)
;
; OUTPUTS:
;   Returns a date string (YYYYMMDDHHMMSS or YYYYMMDD)
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
; RESTRICTIONS:
;    If HOUR, MINUTE, SECONDS provided, then the DOY should be a whole number
;    IF DOY is a decimal DOY then the HOUR, MINUTE, SECONDS are ignored
;
;  EXAMPLES:
;      PRINT, YDOY_2DATE('2000',1)
;      PRINT, YDOY_2DATE('2000',[1,2,3,4,5])
;      PRINT, YDOY_2DATE('2000',1, 12, 0, 0)
;      PRINT, YDOY_2DATE('2000',1.5)                      ; Note - decimal day used as an input
;      PRINT, YDOY_2DATE('2000',[1,2,3,4,5],/SHORT)
;      PRINT, YDOY_2DATE('2000005')
;      PRINT, YDOY_2DATE(YEARDOY=['2000005','2000006','2000007','2000008'])
;      PRINT, YDOY_2DATE(YEARDOY=['2000005','2000006','2000007','2000008.5'])
; 
; COPYRIGHT:
; Copyright (C) 2000, Department of Commerce, National Oceanic and Atmospheric Administration, National Marine Fisheries Service,
;   Northeast Fisheries Science Center, Narragansett Laboratory.
;   This software may be used, copied, or redistributed as long as it is not sold and this copyright notice is reproduced on each copy made.
;   This routine is provided AS IS without any express or implied warranties whatsoever.
;
; AUTHOR
;   This program was written September 25, 2000 by John E. O'Reilly, DOC/NOAA/NMFS/NEFSC Narragansett, RI
;     with assistance from Kimberly Hyde, DOC/NOAA/NMFS/NEFSC Narragansett, RI, kimberly.hyde@noaa.gov
;     Inquiries should be directed to kimberly.hyde@noaa.gov.
;
; MODIFICATION HISTORY:
;   Sep 25, 2000 - JEOR: Initial code written
;		May 27, 2003 - JEOR: Eliminated loop because JULDAY supports array input
;		Jul 28, 2015 - JEOR: Added IF NUMERIC(YEAR) EQ 0 OR NUMERIC(DOY) EQ 0 OR NUMERIC(HOUR) EQ 0 OR NUMERIC(MINUTE) EQ 0 OR NUMERIC(SECOND) EQ 0 THEN  JD = MISSINGS(0.D)
;   Aug 04, 2015 - JEOR: AddedIF NUMBER(YEAR) EQ 0 OR NUMBER(DOY) EQ 0 OR NUMBER(HOUR) EQ 0 OR NUMBER(MINUTE) EQ 0 OR NUMBER(SECOND) EQ 0 THEN BEGIN
;                         ===> SINCE '' IS NOT A NUMBER THEN SET ANY '' HOUR,MINUTE,SECONDS  TO ZEROS
;   Oct 05, 2015 - KJWH: Fixed bug - Changed IF NUMBER(YEAR).... to IF ANY(NUMBER([YEAR,DOY,HOUR,MINUTE,SECOND])) TO ACCOMODATE ARRAYS.
;   Dec 07, 2022 - KJWH: Overhauled program
;                        Now the primary input can be either YYYYDOY or DOY (or iDOY)
;                        Updated documentation
;                        Added COMPILE_OPT IDL2
;                        Changed subscript () to []
;-
; ************************************************************************************************
  ROUTINE_NAME = 'YDOY_2DATE
  COMPILE_OPT IDL2
  
  IF N_ELEMENTS(YEARDOY) GT 0 THEN BEGIN
    IF IDLTYPE(YEARDOY) NE 'STRING' THEN SYD = NUM2STR(ROUND(YEARDOY)) ELSE SYD = YEARDOY
    YEAR = FIX(STRMID(YEARDOY,0,4)) 
    IF MIN(YEAR) LT '1900' OR MAX(YEAR) GT '2200' THEN BEGIN
      PRINT, 'ERROR: Year range (' + MIN(YEAR) + '_' + MAX(YEAR) + ') is out of range.'
      RETURN, []
    ENDIF
    DOY  = FLOAT(STRMID(YEARDOY,4))
    IF MIN(DOY) LT '000' OR MAX(DOY) GT '366' THEN BEGIN
      PRINT, 'ERROR: DOY range (' + MIN(DOY) + '_' + MAX(DOY) + ') is out of range.'
      RETURN, []
    ENDIF
  ENDIF

  IF ~N_ELEMENTS(DOY)  THEN RETURN,[]
  IF ~N_ELEMENTS(YEAR) THEN RETURN,[] 
  
  IF N_ELEMENTS(HOUR) 	EQ 1 THEN HOUR   	= REPLICATE(HOUR,N_ELEMENTS(DOY))
  IF N_ELEMENTS(MINUTE) EQ 1 THEN MINUTE  = REPLICATE(MINUTE,N_ELEMENTS(DOY))
  IF N_ELEMENTS(SECOND) EQ 1 THEN SECOND  = REPLICATE(SECOND,N_ELEMENTS(DOY))

  IF N_ELEMENTS(HOUR)   NE N_ELEMENTS(DOY) THEN HOUR   = REPLICATE(0,N_ELEMENTS(DOY))
  IF N_ELEMENTS(MINUTE) NE N_ELEMENTS(DOY) THEN MINUTE = REPLICATE(0,N_ELEMENTS(DOY))
  IF N_ELEMENTS(SECOND) NE N_ELEMENTS(DOY) THEN SECOND = REPLICATE(0,N_ELEMENTS(DOY))

;===> Since '' is not a number then set any missing hour, minute, seconds to zeros
  OK = WHERE(HOUR   EQ '',COUNT) & IF COUNT GE 1 THEN HOUR[OK]   = 0
  OK = WHERE(MINUTE EQ '',COUNT) & IF COUNT GE 1 THEN MINUTE[OK] = 0
  OK = WHERE(SECOND EQ '',COUNT) & IF COUNT GE 1 THEN SECOND[OK] = 0

   		
; ===>  WHEN DOY,YEAR,OR DOY OR HOUR OR MINUTE ARE NON-NUMERIC THEN SET JD TO MISSINGS CODE FOR DOUBLE 
  IF ANY(NUMBER([YEAR,DOY,HOUR,MINUTE,SECOND])) EQ 0 THEN RETURN, []

  JD = DOY -1.0D + JULDAY( 1, 1, YEAR, HOUR,MINUTE,(SECOND + 0.0001))  ;;;; 0.0001 ; NEEDED FOR ROUNDING ERRORS ?
  IF KEYWORD_SET(SHORT) THEN RETURN, STRMID(JD_2DATE(JD),0,8) ELSE RETURN,JD_2DATE(JD)


END; #####################  END OF ROUTINE ################################
