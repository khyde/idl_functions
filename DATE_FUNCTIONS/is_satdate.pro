; $ID:	IS_SATDATE.PRO,	2023-09-21-13,	USER-KJWH	$
	FUNCTION IS_SATDATE, TXT, SATDATE=SATDATE
;+
; NAME:
;   IS _SATDATE
;   
; PURPOSE: 
;   This function tests if txt string contains a "satdate" (which represents the default date for the downloaded satellite files)
; 
; CATEGORY:	
;   DATE function	 
;
; CALLING SEQUENCE: 
;   RESULT = IS_SATDATE(TXT)
;
; REQUIRED INPUTS: 
;   TXT.......... Text string containing the name of the satellite data file
;
; OPTIONAL INPUTS:
;   None
;		
; KEYWORD PARAMETERS:
;   None
;
; OUTPUTS: 
;   Returns a logical value: 1 = true, 0 = false
;		
;	OPTIONAL OUTPUTS:
;	  SATDATES..... Returns the SATDATE from any TRUE results	
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
; EXAMPLES:
;   PRINT,IS_SATDATE('A2014165190500'); = 1
;   PRINT,IS_SATDATE('S1998033123433'); = 1
;   PRINT,IS_SATDATE('2014165190500') ; = 0
;   PRINT,IS_SATDATE('A201416519050') ; = 0
;   PRINT,IS_SATDATE('A201416ABC050') ; = 0
;   
; COPYRIGHT:
; Copyright (C) 2018, Department of Commerce, National Oceanic and Atmospheric Administration, National Marine Fisheries Service,
;   Northeast Fisheries Science Center, Narragansett Laboratory.
;   This software may be used, copied, or redistributed as long as it is not sold and this copyright notice is reproduced on each copy made.
;   This routine is provided AS IS without any express or implied warranties whatsoever.
;
; AUTHOR
;   This program was written July 29, 2015 by John E. O'Reilly, DOC/NOAA/NMFS/NEFSC Narragansett, RI
;     with assistance from Kimberly Hyde, DOC/NOAA/NMFS/NEFSC Narragansett, RI, kimberly.hyde@noaa.gov
;     Inquiries should be directed to kimberly.hyde@noaa.gov.
;
; MODIFICATION HISTORY:
;	  Jul 29, 2015 - JEOR: ADDITIONAL CRITERION :  NUMBER(STRMID(TXT,1,13)) EQ 1 $
;   Aug 10, 2015 - KJWH: ADDED STEPS TO LOOK FOR YYYYDOY SATDATES  
;                        Added optional "SATDATE" output 
;   Mar 08, 2017 - KJWH: Now can evaluate and array of SATDATES instead of just 1
;                        Moved the parsing and extraction of the SATDATE to the beginning
;                        Now looking to see if the first character is not NUMERIC instead of checking if the first character was a string (all text input are strings)
;                        Moved the option to check for AVHRR and MUR satdates to be outside of the IF THEN block because the first character is a number
;                        Replaced STRSPLIT with STR_BREAK
;   Aug 13, 2018 - KJWH: Added steps to look for the OCCCI date  
;   Mar 21, 2019 - KJWH: BUG FIX - Was not working when there was a mix of input files including a ESA OCCCI downloaded file name  
;   Oct 13, 2020 - KJWH: Updated documentation
;                        Added COMPILE_OPT IDL2
;                        Change subscript () to []
;                        Moved to FILE_FUNCTIONS       
;   May 11, 2021 - KJWH: Updated to work with HERMES files    
;   Jan 10, 2022 - KJWH: Changed HERMES to GLOBCOLOUR    
;   Dec 02, 2022 - KJWH: Updated to work with MUR files 
;   Dec 05, 2022 - KJWH: Now subsetting AVHRR dates to just YYYYMMDD                      
;-
;************************************************************************
  ROUTINE_NAME  = 'IS_SATDATE'
  COMPILE_OPT IDL2

  IF NONE(TXT) THEN MESSAGE,'ERROR: input text is required'
  RESULTS = REPLICATE(0,N_ELEMENTS(TXT))
  SDATES  = REPLICATE('',N_ELEMENTS(TXT))
  SATDATE = STRUPCASE(TXT) 
  SATDATE = REPLACE(SATDATE,['_','-'],[' ',' ']) ; ===> LOOK FOR DELIMITERS WITHIN THE NAME AND REPLACE WITH BLANK SPACES
  SATDATE = STR_BREAK(SATDATE,' ')
 ; IF N_ELEMENTS(SZ) EQ 1 THEN RETURN, RESULTS ; Check the dimensions of the "satdate"
 ; IF SZ[1] LT 3 THEN RETURN, RESULTS          ; "satdata" files have at least 3 dimensions in the filename
  
  OK = WHERE(SATDATE[*,0] EQ 'ESACCI' OR SATDATE[*,0] EQ 'L3B' ,COUNT, COMPLEMENT=COMP, NCOMPLEMENT=NCOMP)             ; ===> LOOK FOR OCCCI TYPE FILES WHERE THE DATE IS IN THE MIDDLE OF THE FILE NAME
  IF COUNT GE 1 THEN BEGIN
    SAT1 = ['ESACCI','L3B']
    FOR S=0, N_ELEMENTS(SAT1)-1 DO BEGIN
      CASE SAT1[S] OF
        'ESACCI': BEGIN
          OK = WHERE(SATDATE[*,0] EQ SAT1[S], COUNT)
          IF COUNT GE 1 THEN BEGIN
            RESULTS[OK] = 1      
            SUBS = SATDATE[OK,*]    
            SZ = SIZE(SUBS)
            SUBDATES = REPLICATE('', COUNT) ; Create a blank array to hold the output dates
            TEMP = SUBDATES  ; Create a secondary temp array to check for multiple dates in the file
            FOR T=0, SZ[2]-1 DO BEGIN ; Loop through the different file components
              OKDATE = WHERE(IS_DATE(SUBS[*,T]) EQ 1, COUNTS) ; Look for a date in the component
              IF COUNTS GT 0 THEN BEGIN
                SUBDATES[OKDATE] = SUBS[OKDATE,T] ; If a date is found, add it to the SUBDATES array
                OKTEMP = WHERE(TEMP[OKDATE] NE '' AND SUBDATES[OKDATE] NE '', COUNTTEMP) ; Check to see if a date was already found for a given file.  If both the TEMP and SUBDATES have values, then there may be an error
                IF COUNTTEMP GT 0 THEN MESSAGE, 'ERROR: More than one date found in the file string.  Double check code and file inputs.'
                TEMP[OKDATE] = SUBS[OKDATE,T] ; Fill in the TEMP array with the data
              ENDIF  
            ENDFOR
            SDATES[OK] = SUBDATES
          ENDIF
        END
        'L3B': BEGIN
          OK = WHERE(SATDATE[*,0] EQ SAT1[S] AND SATDATE[*,2] EQ 'GLOB',COUNT)
          IF COUNT GE 1 THEN BEGIN & SDATES[OK] = SATDATE[OK,1] & RESULTS[OK] = 1 & ENDIF
        END            
      ENDCASE
    ENDFOR
  ENDIF
  
  IF NCOMP GE 1 THEN SDATES[COMP] = SATDATE[COMP,0]
  
  OK = WHERE(SATDATE EQ 'MUR',COUNT)
  IF COUNT GE 1 THEN BEGIN
    OK = WHERE(SATDATE[*,2] EQ 'L4',COUNT) ; AND SATDATE[*,5] EQ 'MUR'
    IF COUNT GE 1 THEN BEGIN SDATES[OK] = STRMID(SATDATE[OK,0],0,8) & RESULTS[OK] = 1 & ENDIF
  ENDIF
  
    
;===> FIRST CHAR A LETTER AND SATDATE MUST BE 14 OR 6 NUMBERS WIDE AND NUMERIC
  OK_SAT = WHERE(NUMBER(STRMID(SDATES,0,1)) EQ 0 AND STRLEN(SDATES) GE 8,COUNT)
  IF COUNT GE 1 THEN BEGIN
    SAT = SDATES[OK_SAT]
    RES = RESULTS[OK_SAT]
        
    OK = WHERE(STRLEN(SAT) EQ 14 AND NUMBER(STRMID(SAT,1,13)) EQ 1, COUNT)
    IF COUNT GE 1 THEN RES[OK] = 1 
  
    OK = WHERE(STRLEN(SAT) EQ 8 AND NUMBER(STRMID(SAT,1,7)) EQ 1,COUNT)
    IF COUNT GE 1 THEN RES[OK] = 1
        
    RESULTS[OK_SAT] = RES
  ENDIF

; ===> Get ACSPO specific dates
  OK = WHERE(SATDATE EQ 'ACSPO' OR SATDATE EQ 'ACSPONRT', COUNT)
  IF COUNT GE 1 THEN BEGIN
    ADATES = STRMID(SATDATE[*,0],0,8)
    AOK = WHERE(NUMBER(ADATES) EQ 1 AND STRLEN(ADATES) EQ 8,COUNT)
    IF COUNT GE 1 THEN BEGIN & SDATES[AOK] = ADATES & RESULTS[AOK] = 1 & END 
  ENDIF
  
; ===> Get AVHRR specific dates
  OK = WHERE(SATDATE EQ 'AVHRR' ,COUNT)
  IF COUNT GE 1 AND (SIZEXYZ(SATDATE)).PY GT 11 THEN BEGIN
    ADATES = SATDATE[*,11]
    OK = WHERE(NUMBER(ADATES) EQ 1 AND STRLEN(ADATES) EQ 7,COUNT)
    IF COUNT GE 1 THEN BEGIN & SDATES[OK] = YDOY_2DATE(YEARDOY=ADATES,/SHORT) & RESULTS[OK] = 1 & END ; Shorten the AVHRR full dates to YYYYMMDD
  ENDIF
  
  SATDATE = SDATES
   
  RETURN, RESULTS
END; #####################  END OF ROUTINE ################################
