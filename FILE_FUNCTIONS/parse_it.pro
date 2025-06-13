; $ID:	PARSE_IT.PRO,	2023-09-21-13,	USER-KJWH	$

FUNCTION PARSE_IT, FILES, ALL=ALL

;+
;	NAME:
;	  PARSE_IT
;	
;	PURPOSE: 
;	  This function parses the path and file name into its components
;
;	CATEGORY:
;	  FILE functions
;	
;	CALLING SEQUENCE:
;	  RESULT = PARSE_IT(FILES)
;	
; REQUIRED INPUTS:
;   FILES......An array of file names
;   
; OPTIONAL_INPUTS:
;   None
;  
; KEYWORDS:
;   ALL....... If set, then get all available information (MAP, PROD, ALG, etc).  If not set, then just get the basic FILE_PARSE and DATE information (quicker) 
;   
; OUTPUT:
;	  A structure containing the parsed file name components
;	
;	OPTIONAL OUTPUT:
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
;	EXAMPLES:
;	   ST, PARSE_IT(!S.OC+'SEAWIFS/L3B2/STATS/CHLOR_A-OCI/M_200401-SEAWIFS-R2015-L3B2-CHLOR_A-OCI-STATS.SAV',/ALL)
;	 
; NOTES:
; 
; 
; COPYRIGHT:
; Copyright (C) 2018, Department of Commerce, National Oceanic and Atmospheric Administration, National Marine Fisheries Service,
;   Northeast Fisheries Science Center, Narragansett Laboratory.
;   This software may be used, copied, or redistributed as long as it is not sold and this copyright notice is reproduced on each copy made.
;   This routine is provided AS IS without any express or implied warranties whatsoever.
;
; AUTOR:
;   This program was written on November 14, 1994 by John E. O'Reilly, NOAA/NEFSC/Narragansett Laboratory, 28 Tarzwell Drive, 02882
;     with assistance from Kimberly Hyde, DOC/NOAA/NMFS/NEFSC Narragansett, RI, kimberly.hyde@noaa.gov
;     Inquiries should be directed to kimberly.hyde@noaa.gov.
;
; MODIFICATION HISTORY:
;   MAR 12, 1995 - JEOR: INPUT MULTIPLE FILES
;	  JUN 13, 1995 - JEOR: FILES WITH NO EXTENSION
;	  DEC 15, 1995 - JEOR: FIXED PROBLEM WITH MULTIPLE FILES PARSE
;                        MUST INITIALIZE VARIABLES FOR EACH FILE
;	  DEC 19, 1995 - JEOR: INCLUDED KEYWORD:  WITH_PERIOD
;	  MAR 21, 1995 - JEOR: DETERMINES DIFFERENT DIRECTORY DELIMITERS USED BY WIN, MAX, AND X DEVICES
;	  JUL 07, 1997 - JEOR: ADDED DELIMITER FOR PRINTER DEVICE
;	  SEP 25, 2000 - JEOR: NOW THE DELIMITER IS DETERMINED ACCORDING TO THE OPERATING SYSTEM (!VERSION.OS)
;	  SEP 28, 2000 - JEOR: ADDED FIRST_NAME TO STRUCTURE (THIS IS USEFUL WHEN THERE ARE SEVERAL EXTENSIONS TO THE NAME E.G. SAMPLE.DAT.ZIP)
;	  JAN 03, 2001 - JEOR: ADDED TAG 'EXT_DELIM' AND REMOVED 'WITH_PERIOD'
;	  JUL 25, 2002 - JEOR: CHANGED SO FILES PARAMETER IS NOT CORRUPTED
;   JUN 16, 2003 - JEOR/TD: ADDED CAPABILITY TO PARSE WORDS FROM FIRST_NAME, WHERE WORDS ARE SEPARATED WITH DASHES
;	  JUN 23, 2003 - JEOR: ADDED VALID_*.PROS
;	  OCT 18, 2006 - KJWH: ADDED VALID_LEVELS
;	  JAN 03, 2007 - KJWH: ADDED VALID_COVERAGE
;	  MAY 14, 2007 - KJWH: CHANGED THE INPUT INTO THE VALID'S FROM STRUCT.FIRST_NAME TO STRUCT.NAME
;	  JUL 20, 2007 - KJWH: ADDED VALID_ALG
;   MAR 28, 2010 - TD:   CHECK IF ITS L2 FILE SET MAP TO LONLAT
;   NOV 18, 2010 - DWM:  CHANGED TO WORK WITHOUT '!' IN PERIOD CODES.  REQUIRE /OLD_PARSER
;                        KEYWORD TO FILE_ALL FOR SOME FILE LISTS.
;   FEB 18, 2013 - KJWH: REMOVED REFERENCE TO OLD_PARSER
;   MAR 26, 2014 - KJWH: REMOVED FILE_INFO CALL IN THE IF NOT KEYWORD_SET(ALL) THEN BEGIN SUB-SECTION
;   NOV 24, 2014 - KJWH: CHANGED VALID_COVERAGES TO VALID_COVERAGE
;   FEB 26, 2015 - JEOR: REPLACED VALID_PXY WITH VALID_PXPY [TO DEAL WITH OUR NEW D3 FILE NAMES]
;                        STANDARDIZED FORMATTING, ADDED EXAMPLES
;   JUL 24, 2015 - JEOR: IF IS_SATDATE(NAME) THEN BEGIN   
;   JUL 25, 2015 - JEOR: FOR NTH = 0,NOF(NAME) -1 DO BEGIN
;   JUL 29, 2015 - KWJH: REPLACED CREATE_STRUCT WITH STRUCT_MERGE SO THAT IT CAN HANDLE PARSING MULTIPLE FILES AT ONCE. 
;                        MOVED SATDATE CODE TO THE 'IF NOT KEYWORD_SET(ALL) THEN BEGIN' BLOCK
;                        ADDED PERIOD INFO AND END DATES TO THE SATDATE BLOCK
;   AUG 10, 2015 - KJWH: ADDED SATDATE KEYWORD TO IS_SATDATE() AND USING THE OUTPUT IN SATDATE_2DATE   
;   AUG 11, 2015 - KJWH: ADDED STEPS TO DETERMINE IF THE SATDATE PERIOD SHOULD BE 'S' OR 'D' - MAY NEED ADDITIONAL INFO TO DEAL WITH 'M' FILES
;   AUG 14, 2015 - JEOR: NOW USING VALIDS 
;   SEP 07, 2015 - JEOR: SELECT ONLY SOME TAGS [TO AVOID DUPS]
;                        S_DATE= STRUCT_COPY(S_DATE,['EXISTS','MTIME','SIZE'] )
;   OCT 20, 2015 - JEOR: IF IDLTYPE(S_PER) EQ 'STRUCT' THEN BEGIN
;                        IF IDLTYPE(S_PER) EQ 'STRUCT' THEN STRUCT= STRUCT_MERGE(STRUCT,S_PER)
;   OCT 23, 2015 - JEOR: NO LONGER CALLING VALID_PERIODS INSTEAD:S_PER = PERIOD_2STRUCT(STRUPCASE(NAME))
;   JAN 17, 2016 - JEOR: MUST USE VALID_XYZ TO FILL THE SPXY STRUCTURE: S_PXY = VALIDS('PXY',NAME) [BECAUSE TOO MANY POSSIBLE COMBINATIONS OF PX,PY,PZ]
;   FEB 03, 2016 - KJWH: CHANGED THE INPUT FOR IS_SATDATE TO BE JUST THE FIRST NAME FROM THE STRUCTURE.
;   MAY 26, 2016 - KJWH: Commented out the step to change '.' to '-' (line 120) because some METHODS (e.g. V04.1) contain a '.' ; ;  NAME = REPLACE(NAME,'.','-')
;                        *** I DO NOT KNOW IF THIS WILL CAUSE ANY FUTURE PROBLEMS, IF SO, WE WILL NEED TO ADDRESS HOW TO DEAL WITH '.' IN THE NAME   
;   JUL 27, 2016 - KJWH: Added PROD_ALG to output structure        
;                        Added GET_SATTYPE to determine if it is a non traditional satellite file
;   MAR 08, 2017 - KJWH: Overhauled program to know get file information using SENSOR_INFO for non traditional (i.e. raw L1A, L2, L3B, MUR and AVHRR) file     
;                        Streamlined where possible
;                        Removed the FOR loop when there are files where IS_SATDATE EQ 1    
;   OCT 23, 2018 - KJWH: Added a work around for when the MATH (e.g. RATIO) is added to the PROD name (because RATIO is also a valid PROD) 
;   MAR 21, 2019 - KJWH: Changed HAS(NAME[OK],'DAY') EQ 1 to STRPOS(NAME[OK],'DAY') GE 1 because HAS returns incorrect results if the inputs contain different types of files   
;                        Updated documentation     
;                        Changed OKS = WHERE(STRLEN(SATDATE) EQ 8 OR STRPOS(NAME[OK],'DAY') GE 1, COUNT) to  
;                                OKS = WHERE(STRMID(DATE,8,6) EQ '000000' OR STRPOS(NAME[OK],'DAY') GE 1, COUNT) to better identify "Daily" dates          
;  OCT 13, 2020 - KJWH: Updated documentation
;                       Added COMPILE_OPT IDL2
;                       Changed subscript () to []
;                       Added abilitiy to get the period information from the new (2020) NASA file names
;                         *** Still need to update VALIDS and SENSOR_INFO to completely parse the files
;                       Moved to FILE_FUNCTIONS  
;  OCT 14, 2020 - KJWH: Fixed errors with the updated SATDATE/NASADATE to period block - now separated into 2 different steps   
;  APR 19, 2021 - KJWH: Added DAYNIGHT to the output structure     
;  OCT 07, 2021 - KJWH: Updated to work with the updated VALIDS.csv 
;                         Commented out variables that will no longer be included - can remove after more testing
;  NOV 30, 2021 - KJWH: Removed SATELLITE from the INAME_MAKE() call    
;  OCT 19, 2022 - KJWH: Added MAP_SUBSET to the output structure                                
;-                              
; ***********************************************************************************************************************************
  ROUTINE_NAME='PARSE_IT'
  COMPILE_OPT IDL2
  
  STRUCT= FILE_PARSE(FILES)
  
;	====> Get the period information from the file name
  NAME = STRUCT.NAME
  NAME = REPLACE(NAME,'.','-')
  S_PER = PERIOD_2STRUCT(STRUPCASE(NAME))
  PER = S_PER.PERIOD
 
  ;===> See if the "first name" is a "satdate", if so derive the period and date information from the satdate
  OKS = WHERE(IS_SATDATE(NAME,SATDATE=SATDATE) EQ 1, COUNTS)
  IF COUNTS GE 1 THEN BEGIN  
    DATE = SATDATE_2DATE(SATDATE[OKS])
    PC = REPLICATE('S',N_ELEMENTS(DATE))
    OK = WHERE(STRMID(DATE,6,8) EQ '01000000' AND STRPOS(NAME,'MONTH') GE 1, COUNT)
    IF COUNT GE 1 THEN BEGIN
      DATE[OK] = STRMID(DATE[OK],0,6)
      PC[OK] = 'M'
    ENDIF
    OK = WHERE(STRMID(DATE,8,6) EQ '000000' OR STRPOS(NAME,'DAY') GE 1, COUNT)
    IF COUNT GE 1 THEN BEGIN
      DATE[OK] = STRMID(DATE[OK],0,8)
      PC[OK] = 'D'
    ENDIF
    PER = PC + '_' + DATE
    S_PER[OKS] = PERIOD_2STRUCT(PER) ; Recreate S_PER using the newly created PERIODS
    OK = WHERE(S_PER[OKS].PERIOD EQ '',COUNT) & IF COUNT GE 1 THEN MESSAGE, 'ERROR: Check input files and output period codes'
	ENDIF ; IF COUNT GE 1 THEN BEGIN
	
	;===> See if the "name" is a new (2020) NASA "satdate", if so derive the period and date information from the satdate 
	OKN = WHERE(IS_NASADATE(NAME,SATDATE=NASADATE) EQ 1,COUNTN)
	IF COUNTN GE 1 THEN BEGIN
	  DATE = SATDATE_2DATE(NASADATE[OKN])
	  PC = REPLICATE('S',N_ELEMENTS(DATE))
	  OK = WHERE(STRMID(DATE,8,6) EQ '000000' OR STRPOS(NAME,'DAY') GE 1, COUNT)
	  IF COUNT GE 1 THEN BEGIN
	    DATE[OK] = STRMID(DATE[OK],0,8)
	    PC[OK] = 'D'
	  ENDIF
	  PER = PC + '_' + DATE
	  S_PER[OKN] = PERIOD_2STRUCT(PER) ; Recreate S_PER using the newly created PERIODS
	  OK = WHERE(S_PER[OKN].PERIOD EQ '',COUNT) & IF COUNT GE 1 THEN MESSAGE, 'ERROR: Check input files and output period codes'
	ENDIF ; IF COUNT GE 1 THEN BEGIN
	      
  ;===> See if the "name" is the Coral Reef Watch, if so derive the period and date information from the satdate
  OKC = WHERE(IS_CORALDATE(NAME,SATDATE=CORALDATE) EQ 1,COUNTC)
  IF COUNTC GE 1 THEN BEGIN
    DATE = SATDATE_2DATE(CORALDATE[OKC])
    PC = REPLICATE('D',N_ELEMENTS(DATE))
    OK = WHERE(STRMID(DATE,8,6) EQ '000000' OR STRPOS(NAME,'DAY') GE 1, COUNT)
    IF COUNT GE 1 THEN BEGIN
      DATE[OK] = STRMID(DATE[OK],0,8)
      PC[OK] = 'D'
    ENDIF
    PER = PC + '_' + DATE
    S_PER[OKC] = PERIOD_2STRUCT(PER) ; Recreate S_PER using the newly created PERIODS
    OK = WHERE(S_PER[OKC].PERIOD EQ '',COUNT) & IF COUNT GE 1 THEN MESSAGE, 'ERROR: Check input files and output period codes'
  ENDIF ; IF COUNT GE 1 THEN BEGIN

  IF NOT KEYWORD_SET(ALL) THEN BEGIN
    IF IDLTYPE(S_PER) EQ 'STRUCT' THEN STRUCT= STRUCT_MERGE(STRUCT,S_PER)
    RETURN, STRUCT
  ENDIF;IF NOT KEYWORD_SET(ALL) THEN BEGIN  


	NAME = STRUCT.NAME									                                                          ; Changed from using just the STRUCT.FIRST_NAME to STRUCT.NAME
	N = N_ELEMENTS(NAME)

; ===> CREATE A STRUCTURE TO HOLD THE MAIN DETAILS OF THE FILE LABEL(S):
  S_MAIN = REPLICATE(CREATE_STRUCT('INAME','',	'SENSOR','','SATELLITE','','METHOD','','SUITE','','MAP','','MAP_SUBSET','','PROD','','LEVEL','', $
    'COVERAGE','','ALG','','PROD_ALG','','STATS','','MATH','','DAYNIGHT',''),N)
  S_DATE = FILE_INFO(FILES)
  S_DATE = STRUCT_COPY(S_DATE,['EXISTS','MTIME','SIZE'] )
  
; ===> USE VALIDS TO GET INFORMATION FROM THE FILE NAME
  S_PXY             = VALIDS('PXY',       NAME)                                                  ; Get the PXYZ from the file NAME
  S_MAIN.SENSOR 		= VALIDS('SENSORS',   NAME)                                                  ; Get the SENSOR(s) from the file NAME
  S_MAIN.METHOD 		= VALIDS('METHODS',   NAME)                                                  ; Get the METHOD(s) from the file NAME
  S_MAIN.MAP		 		= VALIDS('MAPS',      NAME)                                                  ; Get the MAP(s) from the file NAME
	S_MAIN.MAP_SUBSET = VALIDS('MAP_SUBSET',NAME)                                                  ; Get the SUBSET MAP(s) from the file NAME
	S_MAIN.LEVEL			= VALIDS('LEVELS',    NAME)                                                  ; Get the LEVEL(s) from the file NAME
	S_MAIN.STATS      = VALIDS('STATS',     NAME)                                                  ; Get the STAT(s) from the file NAME
	S_MAIN.MATH       = VALIDS('MATHS',     NAME)                                                  ; Get the MATH(s) from the file NAME
	S_MAIN.PROD       = VALIDS('PRODS',     NAME)                                                  ; Get the PROD(s) from the file NAME
	S_MAIN.ALG		    = VALIDS('ALGS',      NAME)                                                  ; Get the ALGORITHMS from the file NAME
	S_MAIN.DAYNIGHT   = VALIDS('DAYNIGHT',  NAME)                                                  ; Get the DAYNIGHT from the file NAME
	S_MAIN.COVERAGE   = VALIDS('COVERAGE',STRUCT.FULLNAME)                                         ; Get the COVERAGE from the file FULLNAME
  
; KJWH WORK AROUND
  OK = WHERE(WHERE_STRING(S_MAIN.PROD,'_'+S_MAIN.MATH) NE [] AND S_MAIN.MATH NE '', COUNT_ERR)
  IF COUNT_ERR GT 0 THEN BEGIN
    S_MAIN.PROD = REPLACE(S_MAIN.PROD,'_'+S_MAIN[OK[0]].MATH,'')
  ENDIF
     
; ===> Merge the structures
  STRUCT = STRUCT_MERGE(STRUCT,S_MAIN) & GONE, S_MAIN
  STRUCT = STRUCT_MERGE(STRUCT,S_PER)  & GONE, S_PER
  STRUCT = STRUCT_MERGE(STRUCT,S_DATE) & GONE, S_DATE
  STRUCT = STRUCT_MERGE(STRUCT,S_PXY)  & GONE, S_PXY

; ===> If the name contains a "satdate" (an indicator it is a downloaded file and not a processed file) then run SENSOR_INFO for specific files
  OK = WHERE(IS_SATDATE(NAME) EQ 1 OR IS_NASADATE(NAME) EQ 1, COUNT) ; ===> IF L1A, L2, L3B, MUR OR AVHRR FILES, THEN USE SENSOR_INFO TO GET THE INFORMATION
  IF COUNT GE 1 THEN BEGIN
    SI = SENSOR_INFO(NAME[OK])
    STRUCT[OK].MAP       = SI.MAP
    STRUCT[OK].LEVEL     = SI.LEVEL
    STRUCT[OK].SENSOR    = SI.SENSOR
    STRUCT[OK].SATELLITE = SI.SATELLITE
    STRUCT[OK].METHOD    = SI.METHOD
    STRUCT[OK].COVERAGE  = SI.COVERAGE
    STRUCT[OK].PROD      = SI.PRODS
    STRUCT[OK].ALG       = SI.ALG
    GONE, SI
  ENDIF
  
; ===> Update PROD_ALG  
  STRUCT.PROD_ALG = STRUCT.PROD                                                              ; ===> POPULATE PROD_ALG WITH THE PROD
  OK_ALG = WHERE(STRUCT.ALG NE '', COUNT, COMPLEMENT=COMPLEMENT)                             ; ===> FIND WHERE THERE IS A VALID ALG
  IF COUNT GE 1 THEN STRUCT[OK_ALG].PROD_ALG = STRUCT[OK_ALG].PROD + '-' + STRUCT[OK_ALG].ALG   ; ===> COMBINE THE PRODUCT AND ALGORITHM
  
; ===> Make the standard iname
	STRUCT.INAME = INAME_MAKE(PERIOD=STRUCT.PERIOD,SENSOR=STRUCT.SENSOR)
  RETURN,STRUCT
END; #####################  END OF ROUTINE ################################

