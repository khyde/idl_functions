; $ID:	DATE_SELECT.PRO,	2023-09-21-13,	USER-KJWH	$

  FUNCTION DATE_SELECT, FILES, DATERANGE, YEAR=YEAR, SUBS=SUBS, COUNT=COUNT, COMPLEMENT=COMPLEMENT

;+
; NAME:
;   DATE_SELECT
;
; PURPOSE:
;   This procedure will select the files that fall between within the given date range.  If YEAR is listed, only return the files from the given year.
;
; CATEGORY:
;   FILES
;
; CALLING SEQUENCE:
;   Result = DATE_SELECT(FILES, DATERNAGE)
;
; REQUIRED INPUTS:
;   FILES.......... Array of all input files
;
; OPTIONAL INPUTS:
;   DATE_RANGE..... The range of dates to subset the files
;   YEAR........... Year for the beginning and end dates
;
; KEYWORD PARAMETERS:
;
; OUTPUTS:
;   This function returns only the files within the given date range 
;
; OPTIONAL OUTPUTS:
;   SUBS........... Returns the subscripts for the selected files
;   COUNT.......... Returns the number of files 
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
;   FILES = GET_FILES('AVHRR', PRODS='SST')
;   DATE_RANGE = ['20020101','20041231']
;   NEW_FILES = DATE_SELECT(FILES,DATE_RANGE)
;   NEW_FILES = DATE_SELECT(FILES,YEAR=2003)
;
; NOTES:
;
; COPYRIGHT:
; Copyright (C) 2013, Department of Commerce, National Oceanic and Atmospheric Administration, National Marine Fisheries Service,
;   Northeast Fisheries Science Center, Narragansett Laboratory.
;   This software may be used, copied, or redistributed as long as it is not sold and this copyright notice is reproduced on each copy made.
;   This routine is provided AS IS without any express or implied warranties whatsoever.
;
; AUTHOR:
;   This program was written on December 16, 2013 by Kimberly J. W. Hyde, Northeast Fisheries Science Center | NOAA Fisheries | U.S. Department of Commerce, 28 Tarzwell Dr, Narragansett, RI 02882
;
; MODIFICATION HISTORY:
;		Dec 16, 2013 - KJWH: Initial code written
;		Feb 06, 2014 - KJWH: Added code to deal with year (i.e. '2004') inputs
;		May 14, 2015 - KJWH: Added SATDATE keyword to work with original satellite file names
;   Aug 10, 2015 - KJWH: Removed SATDATE keyword now that PARSE_IT can return the dates from the original satellite file names and changed FILE_PARSE to PARSE_IT to get DATE_START
;   Oct 05, 2015 - KJWH: Changed DATE_START and DATE_END keywords to be just DATERANGE and cleaned up some of the logical statements
;   Oct 16, 2015 - KJWH: Added COUNT keyword to return the number of files selected
;   Feb 27, 2017 - KJWH: Added STRCOMPRESS(/REMOVE_ALL) statements for DATE_START and DATE_END
;   May 09, 2017 - KJWH: Added COMPLEMENT keyword
;   Aug 18, 2021 - KJWH: Added IF N_ELEMENTS(DATERANGE) EQ 0 AND N_ELEMENTS(YEAR) EQ 1 THEN DATERANGE = YEAR
;                        Updated documentation and formatting
;                        Added COMPILE_OPT IDL2
;                        Changed subscropt () to []  
;                        Removed the ERROR optional output          
;-
;	****************************************************************************************************
	ROUTINE_NAME = 'DATE_SELECT'
	COMPILE_OPT IDL2
	
	SUBS = [] ; Initialize SUBS to NULL
	COUNT = 0 ; Initialize COUNT to 0
	
  IF N_ELEMENTS(FILES) EQ 0 THEN RETURN, []                                  ; No input files
  OK = WHERE(FILES NE '',COUNT) & IF COUNT EQ 0 THEN RETURN, []              ; No valid input files
  
  IF N_ELEMENTS(DATERANGE) EQ 0 AND N_ELEMENTS(YEAR) EQ 0 THEN RETURN, FILES ; No dates/years given
  IF N_ELEMENTS(DATERANGE) GT 2 OR  N_ELEMENTS(YEAR) GT 1 THEN RETURN, FILES ; To many dates/years given
  IF N_ELEMENTS(DATERANGE) EQ 0 AND N_ELEMENTS(YEAR) EQ 1 THEN DATERANGE = YEAR
    
  IF ANY(DATERANGE)             THEN DATE_START = DATERANGE[0] ELSE DATE_START = '1980'
  IF N_ELEMENTS(DATERANGE) EQ 2 THEN DATE_END   = DATERANGE[1] ELSE DATE_END   = '2100'
  IF N_ELEMENTS(DATERANGE) EQ 1 AND STRLEN(DATERANGE[0]) EQ 4 THEN DATE_END = DATERANGE[0]
  
  DATE_START = STRCOMPRESS(DATE_START,/REMOVE_ALL)
  DATE_END   = STRCOMPRESS(DATE_END,/REMOVE_ALL)
     
  IF STRLEN(DATE_START) EQ 4 THEN DATE_START = DATE_START + '0101000000'
  IF STRLEN(DATE_END)   EQ 4 THEN DATE_END   = DATE_END   + '1231235959'
    
  JDS = DATE_2JD(DATE_START)
  DP = DATE_PARSE(DATE_END)
  DE = DP.YEAR + DP.MONTH + DP.DAY + '235959'  ; Make sure DATE_END includes the entire day  
  JDE = DATE_2JD(DE)  
    
  IF N_ELEMENTS(YEAR) EQ 1 THEN BEGIN
    JDS = DATE_2JD(NUM2STR(YEAR) + '0101000000')
    JDE = DATE_2JD(NUM2STR(YEAR) + '1231235959')
  ENDIF
  
  IF ~IS_NUM(FILES[0]) THEN BEGIN
    FP = PARSE_IT(FILES)
    SUBS = WHERE(DATE_2JD(FP.DATE_START) GE JDS AND DATE_2JD(FP.DATE_END) LE JDE, COUNT, COMPLEMENT=COMPLEMENT)
    IF SAME(FP.PERIOD_CODE) AND FP[0].PERIOD_CODE EQ 'AA' THEN BEGIN
      SUBS = WHERE(FP.PERIOD_CODE NE '',COUNT) ; GET ALL OF THE 'AA' DATA
    ENDIF
  ENDIF ELSE SUBS = WHERE(DATE_2JD(FILES) GE JDS AND DATE_2JD(FILES) LE JDE, COUNT, COMPLEMENT=COMPLEMENT)
  
  IF COUNT GE 1 THEN RETURN, FILES[SUBS] ELSE RETURN, []
  

END; #####################  End of Routine ################################
