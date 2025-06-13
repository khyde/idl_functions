; $ID:	PERIOD_2STRUCT.PRO,	2023-09-21-13,	USER-KJWH	$
;###################################################################################
FUNCTION PERIOD_2STRUCT, PER
;+
;	NAME: 
;	  PERIOD_2STRUCT
;	
;	PURPOSE: 
;	  This function returns a structure containing period information (period,period_code,date_start,date_end,year_start,year_end, etc.) from standard coded periods
;	
;	CATEGORY:
;   DATE_FUNCTIONS
;
; CALLING SEQUENCE:
;   R = PERIOD_2STRUCT(PER)
;
; REQUIRED INPUTS:
;   PER.......... An array of periods
;
; OPTIONAL INPUTS:
;   None
;
; KEYWORD PARAMETERS:
;   None
;
; OUTPUTS:
;   A structure with period specific information
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
;   The input must be a period recognized by PERIOD_2STRUCT
;
; EXAMPLE:
;   ST,PERIOD_2STRUCT('Y_2014')
;   ST,PERIOD_2STRUCT('M_200012')
;   ST,PERIOD_2STRUCT('D_20011231')
;   ST,PERIOD_2STRUCT('H_2001010101')
;   ST,PERIOD_2STRUCT('T_200101010159')
;   ST,PERIOD_2STRUCT('S_20010101010101')
;   ST,PERIOD_2STRUCT('SS_20010101010101_20011231235959')
;   ST,PERIOD_2STRUCT('DOY_001_2010_2012')
;   ST,PERIOD_2STRUCT('MONTH_03_1996_2014')
;   ST,PERIOD_2STRUCT('DOY_001_2010_2012')
;   ST,PERIOD_2STRUCT('WEEK_01_1998_2010')
;   ST,PERIOD_2STRUCT('W_199752')
;   ST,PERIOD_2STRUCT('A_2000')
;   S=PERIOD_2STRUCT(['A_2000','A_2001']) & PLIST,S.DATE_START, S.DATE_END
;   ST,PERIOD_2STRUCT('ANNUAL_1996_2014')
;   ST,PERIOD_2STRUCT('YEAR_1996_2014')
;   ST,PERIOD_2STRUCT('M_201201')
;   ST,PERIOD_2STRUCT('STUDY_19781030_19860622')
;   ST,PERIOD_2STRUCT('ALL_19781030000000_19860622235959')
;   ST,PERIOD_2STRUCT(['!Y_2014','Y_2015','ANNUAL_2010_2020','MONTH_01_2010_2013','M_201201','D_20011231','DOY_001_2010_2012','WEEK_01_1998_2010','S2010001'])
;   ST,PERIOD_2STRUCT('MONTH_01_1979_2018-COSTAMV-R2015-SMI-CHL_OCX-MEAN-STATS.SAV');DATE_END SHOULD BE 20180131235959
;
; NOTES:
;
; COPYRIGHT:
; Copyright (C) $YEAR$, Department of Commerce, National Oceanic and Atmospheric Administration, National Marine Fisheries Service,
;   Northeast Fisheries Science Center, Narragansett Laboratory.
;   This software may be used, copied, or redistributed as long as it is not sold and this copyright notice is reproduced on each copy made.
;   This routine is provided AS IS without any express or implied warranties whatsoever.
;
; AUTHOR:
;   This program was written on June 16, 2003 by John E. O'Reilly and Teresa Ducas,Northeast Fisheries Science Center | NOAA Fisheries | U.S. Department of Commerce, 28 Tarzwell Dr, Narragansett, RI 02882
;     Inquires about this program should be directed to kimberly.hyde@noaa.gov
;
; MODIFICATION HISTORY:
;	 JUN 16, 2003 - JEOR & TD: Initial code written
;	 AUG 17, 2005 - JEOR:   ADDED !2MONTH PERIOD (2 MONTH PERIOD)
;	 JUL 21, 2006 - JEOR:   ADDED !W AND !WEEK PERIODS
;	 OCT 12, 2006 - JEOR:   ADDED !3MONTH
;  JAN 08, 2009 - TDUCAS: ADDED !3D
;  NOV 09, 2010 - DWMOONAN: DEBUGGING FOR NEW PERIOD CODES.
;  NOV 17, 2010 - DWMOONAN: BEWARE THIS PROGRAM IS ALSO SET UP TO READ PERIOD CODE FROM FILES THAT DON'T HAVE A LEADING '!' IN THE PERIOD.
;                           SPECIFICALLY, THE NASA FILES.  TEMPORARILY, THIS PROGRAM IS CALLED WHEN READING NASA DOWNLOADED FILES TO GET THE PERIOD INFORMATION,
;                           BECAUSE IT WORKS.  "PERIOD_2STRUCT_NEW" IS CALLED WHEN READING THE NEW PERIODS WITHOUT THE '!'.  IT LOOKS LIKE IF THERE IS NO '!' IN THE PERIOD ARGUMENT,
;                           THIS ROUTINE SIMPLY RETURNS THE CREATED PERIOD STRUCTURE WITHOUT FURTHER ADO.
;                           THIS VERSION CALLS VALID_PERIOD_CODES WITH THE OLD_PARSER KEYWORD.
;  JAN 31, 2011 - KJWH: MADE CHANGES SO THAT PERIOD_2STRUCT ACCEPTS BOTH FILES WITH AND WITHOUT AN '!' AND PERIOD_2STRUCT_NEW IS NO LONGER NECESSARY.
;  FEB 09, 2014 - JEOR: ADDED EXAMPLES FORMATTING, REMOVED OLD_PARSER LOGIC, POS_EX = -1
;  MAR 04, 2014 - JEOR: FUTURE_YEAR = '2100'
;  JUN 26, 2014 - JEOR: NEW MONTH PERIOD IF PERIOD_CODE EQ 'MONTH' THEN BEGIN
;                       ADDED BACK MINUTE: OK = WHERE(PERIOD_TYPE GE 0 AND ((_PERIOD_CODE EQ 'S') OR _PERIOD_CODE EQ 'T'),COUNT)
;                       FIXED WEEK: OK = WHERE(PERIOD_TYPE GE 0 AND (_PERIOD_CODE[0] EQ 'WEEK'),COUNT)
;  JUN 28, 2014 - JOER: FIXED LOGIC FOR MONTH
;  JUL 04, 2014 - JOER: ADDED ON_ERROR, 3
;                       FIXED MINUTE PERIODS, 'T','H'
;  APR 07, 2015 - KJWH: FIXED BUG WITH PERIOD CODE 'WEEK'
;  APR 13, 2015 - KJWH: WORK AROUND FOR THE OLD 'MONTH' PERIOD CODE.  NOW RETURNING A BLANK STRUCTURE IF THE FORMAT IS NOT 'MONHT_mm_yyyy_yyyy'
;  AUG 29, 2016 - KJWH: Added PERIOD_FORMAT (e.g. 'YYYYMMDD') to the structure - NOTE, THERE ARE SEVERAL THAT HAVE "STOPS" AND NEED TO BE DOUBLE CHECKED 
;  MAR 07, 2017 - KJWH: Overhauled the program.  
;                       Removed the ON_ERROR statement because it jumped back to the calling program so it was difficult to diagnose the problem. 
;                       Now using STR_BRK to parse the input data and the PERIOD
;                       Eliminated the need to use FIRST_LEN, WIDTH, START etc to derive the period
;                       Added THIRD_DATE based on updates to VALID_PERIOD_CODES for the DOY, WEEK and MONTH period codes
;                       Now will work when names with invalid period codes are included with valid periods (previously it would stop if there were any invalid period codes)
;                       Now returns blank information in the structure for any periods with invalid period codes (i.e. files with SATNAMES - S2002001)
;                       Looks for files that start with ! and removes the ! prior to determining the period information
;  APR 03, 2017 - KJWH: Was having problems when the input file contained text that matches a VALID period, but no dates are provided (e.g. our D3- inpter files)
;                       Add IF COUNT EQ 1 AND N_ELEMENTS(SPLT_UL) EQ 1 THEN RETURN, S ; RETURN BLANK STRUCTURE IF THE SPLT_UL ONLY HAS ONE VALUE - IT IS AN INDICATION THAT THE INPUT DOES NOT CONTAIN AN ACTUAL PERIOD (E.G. OUR D3_INTERP FILES)
;  AUG 04, 2017 - KJWH: Removed the STOP in the D3 block  
;  MAR 14, 2018 - JEOR: CHANGED:;   S[OK].DATE_END = JD_2DATE(JULDAY(DATE_2MONTH(THIRD_DATE[OK]),DATE_DAYS_MONTH(FIRST_DATE[OK]),DATE_2YEAR(THIRD_DATE[OK]), 23,59,59))
;                       TO:         S[OK].DATE_END = JD_2DATE(JULDAY(FIRST_DATE[OK],DATE_DAYS_MONTH(THIRD_DATE[OK] + FIRST_DATE[OK]),THIRD_DATE[OK], 23,59,59))

;                       BECAUSE THE EXAMPLE ABOVE GAVE 2017: DATE_END ='20171231235959'
;                       ADDED EXAMPLE
;  MAR 18, 2018 - JEOR: FIXED PROBLEM WITH MONTH :
;                         DATE_START = JD_2DATE(DATE_2JD(SECOND_DATE[OK]+FIRST_DATE[OK])) ; FIRST YYYY + MM
;                         DATE_END            = JD_2DATE(JULDAY(FIRST_DATE[OK],DATE_DAYS_MONTH(THIRD_DATE[OK] + FIRST_DATE[OK]),THIRD_DATE[OK], 23,59,59))
;  MAR 19, 2018 - JEOR: IMPROVED SPEED BY USING CASE BLOCK INSTEAD OF NUMEROUS IFS FOR EACH PERIOD TYPE 
;  MAY 09, 2018 - KJWH: Updated formatting   
;  JUL 17, 2018 - KJWH: Added MONTH3 period            
;  FEB 13, 2019 - KJWH: Updated MONTH3 period and added FOURTH_LEN info    
;  FEB 01, 2021 - KJWH: Updated the W period to use    
;                       Added WW (weekly range) period code
;                       Added FIRST_WEEK and SECOND_WEEK parameters 
;                       Added COMPILE_OPT IDL2
;                       Changed subscript () to []
;                       Updated documentation
;                       Moved to DATE_FUNCTIONS  
;  DEC 17, 2021 - KJWH: Added SECOND_PERIOD to the output structure and steps to find a second period if it exists in the name (found in ANOM files) 
;  OCT 06, 2022 - KJWH: Streamlined the code to reduce redundant code for similar periods (e.g. DD, D3, D8, DD3 and DD8)
;                       Removed calls to PERIODS_FORMATS - now getting the format from the PERIODS_MAIN file      
;  OCT 28, 2022 - KJWH: Updated MONTH and WEEK to work with 00 (i.e. stacked file) input periods
;  OCT 31, 2022 - KJWH: Updated DOY to work with 000 (i.e. stacked file) input periods    
;  NOV 08, 2022 - KJWH: Updated code to loop on PERIOD_CODE instead of individual files.  Should increase the speed of the function!    
;  DEC 13, 2022 - KJWH: Added MONTHDAY_START/END and WEEK_START/END to the output structure   
;  MAR 06, 2023 - KJWH: Fixed a bug with the MONTH end date so it now looks for the '00' and changes it to 12                                                             
;-
; *****************************************************************************************
  ROUTINE_NAME='PERIOD_2STRUCT'
  COMPILE_OPT IDL2
  
; #####   CONSTANTS   #####
  UL='_'
  DASH='-'
  FUTURE_YEAR = '2100'
 
; ===> Get all VALID_PERIOD_CODES, lengths, etc
  PCSTR=VALID_PERIOD_CODES(/STRUCT) ; PERIOD_CODE_LEN=PERIOD_CODE_LEN, FIRST_LEN=FIRST_LEN, SECOND_LEN=SECOND_LEN, THIRD_LEN=THIRD_LEN, FOURTH_LEN=FOURTH_LEN, PERIOD_TYPE=PERIOD_TYPES)
  VALID_PERIOD_CODE = PCSTR.PERIOD_CODE
  
; ===> Create a structure to hold the details of the file label(s)
  S=CREATE_STRUCT('PERIOD','',		'PERIOD_CODE','', 'PERIOD_FORMAT','','PERIOD_TYPE','','SECOND_PERIOD','','DATE_START','','DATE_END','','JD_START',0D,'JD_END',0D,$
  								'YEAR_START','','MONTH_START','', 'MONTHDAY_START','','DAY_START','', 'DOY_START','','WEEK_START','',$
  								'YEAR_END','', 'MONTH_END','','MONTHDAY_END','', 'DAY_END','','DOY_END','','WEEK_END','')
  N = N_ELEMENTS(PER)
  IF N EQ 0 THEN RETURN, S
  S=REPLICATE(S,N)



  OK = WHERE(STRPOS(PER,'!') EQ 0,COUNT)                               ; Find any names that start with an '!' (legacy NEFSC satellite file names started with an !)
  IF COUNT GT 0 THEN PER[OK] = STRMID(PER[OK],1)                       ; Remove the '!' from the beginning of the name
  
  SPLT_DASH = STR_BREAK(PER,DASH)                                      ; Break of the input name based on '-'
  PER  = SPLT_DASH[*,0]                                                ; Only use the first name for the period
  
  SPLT_UL = STR_BREAK(PER,UL)                                          ; Break up the period based on '_'
  PERCODE = SPLT_UL[*,0]                                               ; Extract the period code from the period
  
  IF SIZE(SPLT_DASH,/N_DIMENSIONS) GT 1 THEN BEGIN                     ; If it is a compound name, then look for a second "valid" period (found in ANOM files)
    OK = WHERE(VALIDS('PERIODS',SPLT_DASH[*,1]) NE '',COUNT)           ; Check to see if the second section of the name is also "valid" period
    IF COUNT GT 0 THEN S.SECOND_PERIOD = SPLT_DASH[*,1]                ; If not a "valid" period, make blank
  ENDIF

  PERSETS = WHERE_SETS(PERCODE)

; ===> Loop through the periods
  FOR NTH = 0,N_ELEMENTS(PERSETS) -1 DO BEGIN
    PERIOD_CODE = PERSETS[NTH].VALUE
    SUBS = WHERE_SETS_SUBS(PERSETS[NTH])
    PERIOD = PER[SUBS]
    PERIODS = STRTRIM(PERIOD,2)                                        ; Trim any leading and trailing blanks
    PERIODS = STRCOMPRESS(PERIODS,/REMOVE_ALL)                         ; Remove spaces
    
; ===> Create blank arrays for the DATE variables
    FIRST_DATE  = REPLICATE('',PERSETS[NTH].N)                                                         ; Create a blank string array for the FIRST DATE
    SECOND_DATE = REPLICATE('',PERSETS[NTH].N)                                                         ; Create a blank string array for the SECOND DATE
    THIRD_DATE  = REPLICATE('',PERSETS[NTH].N)                                                         ; Create a blank string array for the THIRD DATE
    FOURTH_DATE = REPLICATE('',PERSETS[NTH].N)                                                         ; Create a blank string array for the FOURTH DATE
         
; ===> Find where the input period code matches the valid period codes 
    VSUBS = WHERE_MATCH(VALID_PERIOD_CODE,PERIOD_CODE,COUNT,NCOMPLEMENT=NCOMPLEMENT,VALID=VALID,COMPLEMENT=COMPLEMENT,NINVALID=NINVALID,INVALID=INVALID)
    IF COUNT EQ 0 THEN CONTINUE                                        ; Return blank structure if no matching peirod codes
    IF COUNT EQ 1 AND N_ELEMENTS(SPLT_UL) EQ 1 THEN CONTINUE           ; Return blank structure if the splt_ul only has one value - it is an indication that the input does not contain an actual period (e.g. our D3_INTERP files)
      
    PERIOD_FORMAT = PCSTR[VSUBS].PERIOD_FORMAT                         ; Get the PERIOD_FORMAT from the period structure
    PERIOD_TYPE   = PCSTR[VSUBS].PERIOD_TYPE                           ; Update the period type with the matching valid period types
; ===> Fill in the dates based on the PERIOD_TYPE    
    CASE PERIOD_TYPE OF
      1: BEGIN & FIRST_DATE = SPLT_UL[SUBS,1] & END
      2: BEGIN & FIRST_DATE = SPLT_UL[SUBS,1] & SECOND_DATE = SPLT_UL[SUBS,2] & END
      3: BEGIN & FIRST_DATE = SPLT_UL[SUBS,1] & SECOND_DATE = SPLT_UL[SUBS,2] & THIRD_DATE  = SPLT_UL[SUBS,3] & END
      4: BEGIN & FIRST_DATE = SPLT_UL[SUBS,1] & SECOND_DATE = SPLT_UL[SUBS,2] & THIRD_DATE  = SPLT_UL[SUBS,3] & FOURTH_DATE = SPLT_UL[SUBS,4] & END
    ENDCASE

; ===> Double check the date lengths    
    OK = WHERE(STRLEN(FIRST_DATE)  NE PCSTR[VSUBS].FIRST_LENGTH, COUNT) & IF COUNT GE 1 THEN MESSAGE, 'ERROR: Check first date lengths' ; Quick check to make sure the FIRST_DATE lengths match
    OK = WHERE(STRLEN(SECOND_DATE) NE PCSTR[VSUBS].SECOND_LENGTH,COUNT) & IF COUNT GE 1 THEN MESSAGE, 'ERROR: Check first date lengths' ; Quick check to make sure the SECOND_DATE lengths match
    OK = WHERE(STRLEN(THIRD_DATE)  NE PCSTR[VSUBS].THIRD_LENGTH, COUNT) & IF COUNT GE 1 THEN MESSAGE, 'ERROR: Check first date lengths' ; Quick check to make sure the THIRD_DATE lengths match
    OK = WHERE(STRLEN(FOURTH_DATE) NE PCSTR[VSUBS].FOURTH_LENGTH,COUNT) & IF COUNT GE 1 THEN MESSAGE, 'ERROR: Check first date lengths' ; Quick check to make sure the FOURTH_DATE lengths match
               
; ===> Extract year, month, day, hour, minute, second
    FIRST_YEAR 		= STRMID(FIRST_DATE,0,4) 	& SECOND_YEAR 	= STRMID(SECOND_DATE,0,4)
    FIRST_MONTH 	= STRMID(FIRST_DATE,4,2) 	& SECOND_MONTH 	= STRMID(SECOND_DATE,4,2)
    FIRST_WEEK    = STRMID(FIRST_DATE,4,2)  & SECOND_WEEK   = STRMID(SECOND_DATE,4,2)
    FIRST_DAY 		= STRMID(FIRST_DATE,6,2) 	& SECOND_DAY 		= STRMID(SECOND_DATE,6,2)
    FIRST_HOUR 		= STRMID(FIRST_DATE,8,2) 	& SECOND_HOUR 	= STRMID(SECOND_DATE,8,2)
    FIRST_MINUTE 	= STRMID(FIRST_DATE,10,2) & SECOND_MINUTE = STRMID(SECOND_DATE,10,2)
    FIRST_SECOND 	= STRMID(FIRST_DATE,12,2) & SECOND_SECOND = STRMID(SECOND_DATE,12,2)

;	===> FILL IN IMPLIED DATE INFORMATION FOR EACH PERIOD 
    S[SUBS].PERIOD        = PERIODS
    S[SUBS].PERIOD_CODE   = PERIOD_CODE
    S[SUBS].PERIOD_TYPE   = PERIOD_TYPE
    S[SUBS].PERIOD_FORMAT = PERIOD_FORMAT
    CASE 1 OF
      PERIOD_CODE EQ 'STUDY' OR PERIOD_CODE EQ 'ANNUAL' OR PERIOD_CODE EQ 'ALL' OR PERIOD_CODE EQ 'MANNUAL' OR PERIOD_CODE EQ 'YEAR': BEGIN
        S[SUBS].DATE_START    = FIRST_YEAR  + '0101000000'
        S[SUBS].DATE_END      = SECOND_YEAR + '1231235959'  ; FUTURE DATE
      END  
      
      PERIOD_CODE EQ 'MONTH' :BEGIN
        DATE_START          = JD_2DATE(DATE_2JD(SECOND_DATE+FIRST_DATE)) ; FIRST YYYY + MM
        S[SUBS].DATE_START    = DATE_START
        OK = WHERE(FIRST_DATE EQ '00', COUNT, COMPLEMENT=CP, NCOMPLEMENT=NCP)
        IF COUNT GT 0 THEN FIRST_DATE[OK] = '12' ; WEEK stacked periods will have 00 as the week number so the end week should be changed to 52 because stacked files contain all weeks within the year
        DATE_END            = JD_2DATE(JULDAY(FIRST_DATE,DATE_DAYS_MONTH(THIRD_DATE + FIRST_DATE),THIRD_DATE, 23,59,59))
        S[SUBS].DATE_END      = DATE_END
      END;'MONTH'
      ;|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
      
      PERIOD_CODE EQ 'MONTH3' :BEGIN
        DATE_START           = JD_2DATE(DATE_2JD(THIRD_DATE+FIRST_DATE)) ; FIRST YYYY + MM
        S[SUBS].DATE_START    = DATE_START
        DATE_END             = JD_2DATE(JULDAY(SECOND_DATE,DATE_DAYS_MONTH(SECOND_DATE),FOURTH_DATE, 23,59,59))
        S[SUBS].DATE_END      = DATE_END
      END;'MONTH'
      ;|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
      
      PERIOD_CODE EQ 'WEEK': BEGIN; WEEK WW_YYYY_YYYY
        JD_START            = YWEEK_2JD(SECOND_DATE+FIRST_DATE) ; FIRST_YEAR HAS THE WEEK NUMBER
        DPW                 = JD_DAYS_WEEK(JD_START)
        S[SUBS].DATE_START    = JD_2DATE(JD_START)
        OK = WHERE(FIRST_DATE EQ '00', COUNT, COMPLEMENT=CP, NCOMPLEMENT=NCP)
        IF COUNT GT 0 THEN FIRST_DATE[OK] = '52' ; WEEK stacked periods will have 00 as the week number so the end week should be changed to 52 because stacked files contain all weeks within the year
        S[SUBS].DATE_END      = JD_2DATE(YWEEK_2JD(THIRD_DATE+FIRST_DATE) + DPW -  1D/SECONDS_DAY())
      END;'WEEK': BEGIN  
      ;|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
      
      PERIOD_CODE EQ 'DOY' : BEGIN    
        OK = WHERE(FIRST_DATE EQ '000', COUNT, COMPLEMENT=CP, NCOMPLEMENT=NCP)
        IF COUNT GT 0  THEN BEGIN ; DOY stacked periods will have 000 as the DOY number so the day should be changed to 000 and 365 because stacked files contain all days within the year
          S[SUBS[OK]].DATE_START = JD_2DATE(YDOY_2JD(SECOND_DATE[OK],'001',0,0,0))
          S[SUBS[OK]].DATE_END   = JD_2DATE(YDOY_2JD(THIRD_DATE[OK], '365',23,59,59))
        ENDIF 
        IF NCP GT 0 THEN BEGIN
          S[SUBS[CP]].DATE_START = JD_2DATE(YDOY_2JD(SECOND_DATE[CP],FIRST_DATE,0,0,0))
          S[SUBS[CP]].DATE_END   = JD_2DATE(YDOY_2JD(THIRD_DATE[CP], FIRST_DATE,23,59,59))
        ENDIF
      END;'DOY' : BEGIN
    ;||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
    
      PERIOD_CODE EQ 'A' OR PERIOD_CODE EQ 'Y': BEGIN
        S[SUBS].DATE_START    = JD_2DATE(JULDAY(1, 1,  FIRST_YEAR,  0, 0,  0))
        S[SUBS].DATE_END      = JD_2DATE(JULDAY(12,31, FIRST_YEAR, 23, 59,59))
      END;'A'      
      ;||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||\
      
      PERIOD_CODE EQ 'M' : BEGIN
        JD                  = JULDAY(FIRST_MONTH,   1,  FIRST_YEAR,  0, 0, 0)
        DPM                 = JD_DAYS_MONTH(JD)
        S[SUBS].DATE_START    = JD_2DATE(JD)
        S[SUBS].DATE_END      = JD_2DATE(JULDAY(FIRST_MONTH,DPM,  FIRST_YEAR, 23,59,59))
      END; 'M'
        ;||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||    
    
      PERIOD_CODE EQ 'W' : BEGIN
        S[SUBS].DATE_START    = YWEEK_2JD(FIRST_YEAR,FIRST_WEEK,/DATE)
        S[SUBS].DATE_END      = YWEEK_2JD(FIRST_YEAR,FIRST_WEEK,/DATE,/ENDDATE) ;JD_2DATE(JD_START + DPW -  1D/SECONDS_DAY() )
      END;
      ;||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
      
      PERIOD_CODE EQ 'D': BEGIN
        S[SUBS].DATE_START    = JD_2DATE(JULDAY(FIRST_MONTH,  FIRST_DAY,  FIRST_YEAR,   0, 0, 0))
        S[SUBS].DATE_END      = JD_2DATE(JULDAY(FIRST_MONTH, FIRST_DAY, FIRST_YEAR,  23,59,59))
      END;'D'
      ;||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
      
      PERIOD_CODE EQ 'DD' OR PERIOD_CODE EQ 'D8' OR PERIOD_CODE EQ 'DD8' OR PERIOD_CODE EQ 'D3' OR PERIOD_CODE EQ 'DD3': BEGIN
        S[SUBS].DATE_START    = JD_2DATE(JULDAY(FIRST_MONTH, FIRST_DAY, FIRST_YEAR,   0, 0, 0))
        S[SUBS].DATE_END      = JD_2DATE(JULDAY(SECOND_MONTH, SECOND_DAY, SECOND_YEAR,  23,59,59))
      END;'D8'
      ;||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
      
      
      PERIOD_CODE EQ 'M3' : BEGIN
        DPM                 = JD_DAYS_MONTH(DATE_2JD(SECOND_DATE))
        S[SUBS].DATE_START    = JD_2DATE(JULDAY(DATE_2MONTH(FIRST_DATE), 1,  FIRST_YEAR,  0, 0, 0))
        S[SUBS].DATE_END      = JD_2DATE(JULDAY(DATE_2MONTH(SECOND_DATE),DPM,SECOND_YEAR, 23,59,59))
      END;'M3'
      ;|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
      
      PERIOD_CODE EQ 'SEA' : BEGIN
        DPM                 = JD_DAYS_MONTH(DATE_2JD(SECOND_DATE))
        S[SUBS].DATE_START    = JD_2DATE(JULDAY(DATE_2MONTH(FIRST_DATE), 1,  FIRST_YEAR,  0, 0, 0))
        S[SUBS].DATE_END      = JD_2DATE(JULDAY(DATE_2MONTH(SECOND_DATE),DPM,SECOND_YEAR, 23,59,59))
      END;'M3'
      ;|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||

      
      PERIOD_CODE EQ 'H' : BEGIN
        S[SUBS].DATE_START    = JD_2DATE(JULDAY(FIRST_MONTH,  FIRST_DAY,  FIRST_YEAR, FIRST_HOUR,   FIRST_MINUTE, 0))
        S[SUBS].DATE_END      = JD_2DATE(JULDAY(FIRST_MONTH, FIRST_DAY, FIRST_YEAR, FIRST_HOUR, 59,59))
      END;'H'
      ;||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
      
      PERIOD_CODE EQ 'T' : BEGIN
        S[SUBS].DATE_START    = JD_2DATE(JULDAY(FIRST_MONTH, FIRST_DAY,  FIRST_YEAR, FIRST_HOUR, FIRST_MINUTE, 0))
        S[SUBS].DATE_END      = JD_2DATE(JULDAY(FIRST_MONTH, FIRST_DAY,  FIRST_YEAR, FIRST_HOUR,FIRST_MINUTE,59))
      END;'T'
      ;||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
      
      PERIOD_CODE EQ 'S' : BEGIN
        S[SUBS].DATE_START    = FIRST_DATE
        S[SUBS].DATE_END      = FIRST_DATE
      END;'S'
      ;|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
      
      PERIOD_CODE EQ 'AA' : BEGIN
        S[SUBS].DATE_START    = JD_2DATE(JULDAY(1,  1,  FIRST_YEAR,   0,  0,  0))
        S[SUBS].DATE_END      = JD_2DATE(JULDAY(12,31,  SECOND_YEAR, 23,  59,59))
      END;'YY'
      ;||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
      
      PERIOD_CODE EQ 'YY' : BEGIN
        S[SUBS].DATE_START    = JD_2DATE(JULDAY(1,  1,  FIRST_YEAR,   0,  0,  0))
        S[SUBS].DATE_END      = JD_2DATE(JULDAY(12,31,  SECOND_YEAR, 23,  59,59))
      END;'YY'
      ;||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
      
      PERIOD_CODE EQ 'MM' : BEGIN
        S[SUBS].DATE_START    = JD_2DATE(JULDAY(FIRST_MONTH,1,FIRST_YEAR,  0, 0, 0))
        JD                   = JULDAY(SECOND_MONTH,        1,SECOND_YEAR, 0, 0, 0)
        DPM                  = JD_DAYS_MONTH(JD)
        S[SUBS].DATE_END      = JD_2DATE(JULDAY(SECOND_MONTH,DPM, SECOND_YEAR, 23,59,59))
      END;'MM'
      ;||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
      
      PERIOD_CODE EQ 'MM3' : BEGIN
        S[SUBS].DATE_START    = JD_2DATE(JULDAY(FIRST_MONTH,1,FIRST_YEAR,  0, 0, 0))
        JD                   = JULDAY(SECOND_MONTH,        1,SECOND_YEAR, 0, 0, 0)
        DPM                  = JD_DAYS_MONTH(JD)
        S[SUBS].DATE_END      = JD_2DATE(JULDAY(SECOND_MONTH,DPM, SECOND_YEAR, 23,59,59))
      END;'MM'
      ;||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
      
      PERIOD_CODE EQ 'WW' : BEGIN
        S[SUBS].DATE_START    = JD_2DATE(YWEEK_2JD(FIRST_YEAR,FIRST_WEEK))
        S[SUBS].DATE_END      = JD_2DATE(YWEEK_2JD(SECOND_YEAR,SECOND_WEEK,/ENDDATE))
      END;'MM'
      ;||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
     
      'SS' : BEGIN
        S[SUBS].DATE_START    = FIRST_DATE
        S[SUBS].DATE_END      = SECOND_DATE
      END;'SS'
      ;||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
        
      ELSE: MESSAGE,'ERROR: Period code ' + PERIOD_CODE + ' not found'
      
    ENDCASE;CASE (1) OF

    S[SUBS].JD_START = DATE_2JD(S[SUBS].DATE_START)
    S[SUBS].JD_END   = DATE_2JD(S[SUBS].DATE_END)

; ===> Extract from THE structure: YEAR_START,MONTH_START, DAY_START, YEAR_END, MONTH_END, DAY_END  ***
    OK = WHERE(PERIOD_TYPE GT 0,COUNT)
    IF COUNT GE 1 THEN BEGIN
    	S[SUBS].PERIOD_TYPE    = STRTRIM(S[SUBS].PERIOD_TYPE,2)
    	S[SUBS].YEAR_START 	   = STRMID(S[SUBS].DATE_START,0,4)
    	S[SUBS].MONTH_START    = STRMID(S[SUBS].DATE_START,4,2)
    	S[SUBS].MONTHDAY_START = STRMID(S[SUBS].DATE_START,4,4)
    	S[SUBS].DAY_START 	   = STRMID(S[SUBS].DATE_START,6,2) 
    	S[SUBS].DOY_START      = DATE_2DOY(S[SUBS].DATE_START,/PAD) 
    	S[SUBS].WEEK_START     = DATE_2WEEK(S[SUBS].DATE_START) 
    	S[SUBS].YEAR_END 		   = STRMID(S[SUBS].DATE_END,0,4)
    	S[SUBS].MONTH_END 	   = STRMID(S[SUBS].DATE_END,4,2)
    	S[SUBS].MONTHDAY_END   = STRMID(S[SUBS].DATE_END,4,4)
    	S[SUBS].DAY_END 		   = STRMID(S[SUBS].DATE_END,6,2)
    	S[SUBS].DOY_END        = DATE_2DOY(S[SUBS].DATE_END,/PAD)
    	S[SUBS].WEEK_END       = DATE_2WEEK(S[SUBS].DATE_END)
    ENDIF
  ENDFOR;FOR NTH = 0,NOF(PERIOD) -1 DO BEGIN

  RETURN,S

END; #####################  END OF ROUTINE ################################
