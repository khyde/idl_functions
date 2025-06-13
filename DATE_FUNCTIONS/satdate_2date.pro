; $ID:	SATDATE_2DATE.PRO,	2020-10-13-18,	USER-KJWH	$
  FUNCTION SATDATE_2DATE, SATDATE, NOCENTURY=NOCENTURY, NOMINUTE=NOMINUTE,NOSECOND=NOSECOND

;+
; NAME:
;   SATDATE_2DATE
;   
; PURPOSE: 
;   Converts a "satdate" to a standard date
;
; CATEGORY
;   Date function
;   
; CALLING SEQUENCE
;   Result = SATDATE_2DATE(SATDATE)
;   
; REQUIRED INPUTS:
;   SATDATE........ Text string containing the "date" information from the default satellite file name
;
; OPTIONAL INPUTS:
;   None
;
; KEYWORD PARAMETERS:
;   NOMINUTE....... Remove the "minute" and "second" digits from the date
;   NOSECOND....... Remove the "second" digits from the date
;
; OUTPUTS:
;   The standard date for the NEFSC file names
;
; OPTIONAL OUTPUTS:
;   SATDATES..... Returns the SATDATE from any TRUE results
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
;     
; EXAMPLES:
;   PRINT, SATDATE_2DATE('S1998033123433')
;   
; COPYRIGHT:
; Copyright (C) 2018, Department of Commerce, National Oceanic and Atmospheric Administration, National Marine Fisheries Service,
;   Northeast Fisheries Science Center, Narragansett Laboratory.
;   This software may be used, copied, or redistributed as long as it is not sold and this copyright notice is reproduced on each copy made.
;   This routine is provided AS IS without any express or implied warranties whatsoever.
;
; AUTHOR
;   This program was written September 01, 1998 by John E. O'Reilly, DOC/NOAA/NMFS/NEFSC Narragansett, RI
;     with assistance from Kimberly Hyde, DOC/NOAA/NMFS/NEFSC Narragansett, RI, kimberly.hyde@noaa.gov
;     Inquiries should be directed to kimberly.hyde@noaa.gov.
;
; MODIFICATION HISTORY:
;   AUG 27, 2014 - JEOR: Added IF KEYWORD_SET(NOMINUTE) THEN MMIN(*) = ''
;   AUG 04, 2015 - JEOR: Updated formatting - FIXED YDOY_2DATE TO GET EXAMPLES TO WORK
;   OCT 20, 2015 - KJWH: Removed the NOCENTURY keyword and related code since it is obsolete
;                        Added capability to identify and return a 14 digit date that does not start with a letter (useful for GHRSST files)
;   OCT 22, 2015 - KJWH: Fixed bug when trying to identify a 14 digit date
;   OCT 30, 2015 - KJWH: Added IF NCOMPLEMENT GE 1 THEN BEGIN 
;   AUG 23, 2018 - KJWH: Added a step to work with 8 digit dates and no letters (e.g. the ESA_OCCCI dates extracted from IS_SATDATE)
;   OCT 13, 2020 - KJWH: Updated documentation
;                        Added COMPILE_OPT IDL2
;                        Changed subscript () to []
;                        Added ability to work with new (2020) NASA file names (YYYYMMDDTHHMMSS)
;                        Moved to DATE_FUNCTIONS
;    MAR 13, 2023 - KJWH: Added option for six digit monthly date (e.g. 199901)                    
;-
;****************************************************************
ROUTINE_NAME = 'SATDATE_2DATE'

; ===> ENSURE SATDATE IS A STRING
  IF IDLTYPE(SATDATE) NE 'STRING' THEN RETURN, ''
  SATDATE = STRTRIM(SATDATE,2)

  OK = WHERE(NUMBER(STRMID(SATDATE,0)) EQ 1 AND STRLEN(SATDATE) EQ 8, COUNT) ; If it is an 8 digit date without a letter at the beginning (e.g. ESA_OCCCI), then add zero's for the HH, MM and SS 
  IF COUNT GE 1 THEN SATDATE[OK] = SATDATE[OK] + '000000'
  
  OK = WHERE(NUMBER(STRMID(SATDATE,0)) EQ 1 AND STRLEN(SATDATE) EQ 6, COUNT) ; If it is an 6 digit date without a letter at the beginning (e.g. ESA_OCCCI-Montly), then add one for the first date and zero's for the HH, MM and SS
  IF COUNT GE 1 THEN SATDATE[OK] = SATDATE[OK] + '01000000'

  OK = WHERE(NUMBER(STRMID(SATDATE,0)) EQ 0 AND STRLEN(SATDATE) EQ 15, COUNT)
  IF COUNT GE 1 THEN BEGIN
    CK = WHERE(NUMBER(STRMID(SATDATE[OK],0,8)) EQ 1 AND STRMID(SATDATE[OK],8,1) EQ 'T' AND NUMBER(STRMID(SATDATE[OK],9,6)) EQ 1, COUNT, COMPLEMENT=COMP, NCOMPLEMENT=NCOMP)
    IF COUNT GE 1 THEN SATDATE[OK[CK]] = STRMID(SATDATE[OK[CK]],0,8) + STRMID(SATDATE[OK[CK]],9,6)
    IF NCOMP GE 1 THEN SATDATE[OK[COMP]] = '' ; There are no "sat dates" that are 15 digits long, but don't fit the YYYYMMDD"T"HHMMSS format
  ENDIF

  OK = WHERE(NUMBER(STRMID(SATDATE,0,1)) EQ 0 AND STRLEN(SATDATE) EQ 14, COUNT);  Look for a date that starts with a letter and has 13 digits (YYYYDOYHHMMSS)
  IF COUNT GE 1 THEN BEGIN
    YR  = STRMID(SATDATE[OK],1,4)
    DOY = STRMID(SATDATE[OK],5,3)
    HH  = STRMID(SATDATE[OK],8,2)
    MN  = STRMID(SATDATE[OK],10,2)
    SS  = STRMID(SATDATE[OK],12,2)
  
    IF KEYWORD_SET(NOMINUTE) THEN BEGIN & MN[*] = '' & SS[*] = '' & ENDIF
    IF KEYWORD_SET(NOSECOND) THEN SS[*] =''
  
    SATDATE[OK] = YDOY_2DATE(YR,DOY,HH,MN,SS)
  ENDIF  
  
  OK = WHERE(NUMBER(STRMID(SATDATE,0,1)) EQ 0 AND STRLEN(SATDATE) EQ 8, COUNT);  Look for a date that starts with a letter and has 7 digits (YYYYDOY)
  IF COUNT GE 1 THEN BEGIN
    YR  = STRMID(SATDATE[OK],1,4)
    DOY = STRMID(SATDATE[OK],5,3)
    SATDATE[OK] = YDOY_2DATE(YR,DOY)
  ENDIF
  
  OK = WHERE(NUMBER(SATDATE) EQ 0 OR STRLEN(SATDATE) NE 14,COUNT)
  IF COUNT GE 1 THEN SATDATE[OK] = ''
  
  RETURN, SATDATE

END; #####################  END OF ROUTINE ################################


