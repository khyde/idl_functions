; $ID:	CSV_READ.PRO,	2020-06-30-17,	USER-KJWH	$
;############################################################################################
	FUNCTION CSV_READ, FILE, TAGNAMES=TAGNAMES, N_TABLE_HEADER=N_TABLE_HEADER, NUM_RECORDS=NUM_RECORDS, START_ROW=START_ROW, COL_TYPES=COL_TYPES, STRING=STRING, MISSING_VALUE=MISSING_VALUE, NEW=NEW
;+
; 
; NAME:
;   CSV_READ
;
; PURPOSE
;   This function reads a .csv file (comma-delimited) and returns a string structure array
; 
; CATEGORY
;   READ
;   
; CALLING SEQUENCE:
;		RESULT = CSV_READ(FILE)
; 
; INPUTS:
;   FILE..... Name of the input .csv file
;   
; OPTIONAL_INPUTS:
;   N_TABLE_HEADER.. Number of header lines in the csv file to skip before beginning to read the record
;   NUM_RECORDS..... Integer specifying the number of records to read (default is all records)
;   START_ROW....... The row number of the first record to read (default is 0)
;   COL_TYPES....... String array containing the IDL data type for each column of data.  If not provided, IDL automatically determines the data TYPE  
;   MISSING_VALUE... The value to use for all non-string missing values (default = -99999)
;   
; KEYWORDS:  
;   TAGNAMES... Returns just the tagnames from the csv file
;   STRING....  Return the entire structure in STRING format
;
; OUTPUT:
;		This function returns a structure of the csv file.  Note, if COL_TYPES are not provided, the column type will be automatically determined by IDL
;	
; PROCEDURE:
;   RESULT = CSV_READ(FILE)
;   
; EXAMPLE:
;   DAT = CSV_READ(file.csv)
;		PR = PRODS_READ(/INIT) ; Reads the PRODS_MASTER.csv
;		MR = MAPS_READ(/INIT)  ; Reads the MAPS_MASTER.csv
;		
; NOTES:
;		Works with EXCEL .csv files
;		
; COPYRIGHT:
; Copyright (C) 2018, Department of Commerce, National Oceanic and Atmospheric Administration, National Marine Fisheries Service,
;   Northeast Fisheries Science Center, Narragansett Laboratory.
;   This software may be used, copied, or redistributed as long as it is not sold and this copyright notice is reproduced on each copy made.
;   This routine is provided AS IS without any express or implied warranties whatsoever.
;
;   This program was written by John E. O'Reilly, DOC/NOAA/NMFS/NEFSC Narragansett, RI 
;          with assistance from Kimberly Hyde, DOC/NOAA/NMFS/NEFSC Narragansett, RI, kimberly.hyde@noaa.gov
;          Inquiries should be directed to kimberly.hyde@noaa.gov.
;
; MODIFICATION HISTORY:
;     Written:  January 10, 2001 by John E. O'Reilly, NOAA/NEFSC/Narragansett Laboratory, 28 Tarzwell Drive, 02882
;     Modified: Nov 08, 2004 - JEOR: Add a '_' before any tagnames that begin with a number
;		            Apr 02, 2013 - JEOR: Formatting
;		            Feb 10, 2014 - JEOR: Renamed from READ_CSV
;		            Feb 18, 2016 - JEOR: New functions
;		            Mar 05, 2019 - KJWH: Formatting & documentation
;		            Mar 18, 2019 - KJWH: Updated and now using IDL's READ_CSV and converting that output to a structure
;		                                 Removed COMP and SKIP keywords
;		            Mar 19, 2019 - KJWH: Added MISSING_VALUE, TAG_ROW, NUM_RECORDS, START_ROW keywords                        
;		            Mar 20, 2019 - KJWH: Tested reading some of the MASTER csv's. 
;		                                 Added examples      
;		            Apr 04, 2019 - KJWH: Added an optional keyword, STRING, to return the entire structure in "STRING" format (similar to the old CSV_READ method)      
;		                                   First read just the first line of the CSV
;		                                   Create an "STRING" array based on the number of tags in the CSV
;		                                   Then read the entire CSV and input the string array in the TYPE variable   
;		            Jun 24, 2019 - KJWH: Added step to make sure the file exists and return an error message if it does not.                                                     
;############################################################################################
;-
;*************************
  ROUTINE_NAME  = 'CSV_READ'
;************************* 

  
  IF NONE(FILE) THEN FILE = DIALOG_PICKFILE(FILTER='*.csv')
  
  IF FILE_TEST(FILE) EQ 0 THEN MESSAGE, 'ERROR: ' + FILE + ' does not exist.'
    
  IF NONE(TAG_ROW) THEN TAG_ROW = 0 ; Assumes the header row is the first row
  IF KEY(TAGNAMES) THEN NUM_RECORDS = 0 ; If only want the tag names, then only need to read the first row
  IF NONE(START_ROW) THEN START_ROW = 0

; ***** Start of NEW CSV_READ code (KJWH: 3/18/2019) *****
  
  IF NONE(MISSING_VALUE) THEN MISSING_VALUE = -99999 ; Missings value for all missing data except strings (missing strings are blank).  The IDL defualt is to replace blank number records with 0, but that could easily be misread as a read value
  
  IF KEY(STRING) THEN BEGIN
    MISSING_VALUE = ''
    CDATA = READ_CSV(FILE, HEADER=TAGS, COUNT=COUNT, RECORD_START=START_ROW, NUM_RECORDS=0) ; READ THE FIRST ROW OF THE FILE TO GET THE NUMBER OF ROWS
    TYPES = REPLICATE('String',N_TAGS(CDATA)) ; Create a string array of 'STRING' for the column types
    CDATA = READ_CSV(FILE, HEADER=TAGS, COUNT=COUNT, RECORD_START=START_ROW, NUM_RECORDS=NUM_RECORDS, TYPES=TYPES, MISSING_VALUE=MISSING_VALUE)  
  ENDIF ELSE CDATA = READ_CSV(FILE, HEADER=TAGS, COUNT=COUNT, RECORD_START=START_ROW, NUM_RECORDS=NUM_RECORDS, TYPES=COL_TYPES, MISSING_VALUE=MISSING_VALUE) ; Read the file
  
  IF N_ELEMENTS(TAGS) EQ 1 AND TAGS[0] EQ '' THEN BEGIN
    TAGS = []
    FOR N=0, N_TAGS(CDATA)-1 DO BEGIN
      TAGS = [TAGS,CDATA.(N)[0]]
      CDATA.(N)[0] = MISSINGS(CDATA.(N))
    ENDFOR
    COUNT = COUNT - 1
    STRING_STRUCT = 1
  ENDIF ELSE STRING_STRUCT = 0
  
  TAGS = IDL_VALIDNAME(STRCOMPRESS(TAGS),/CONVERT_ALL)  
  IF KEY(TAGNAMES) THEN RETURN, TAGS ; ===> Just return the header information

; ===> Create a new structure
  STRUCT=CREATE_STRUCT(TAGS[0],CDATA.(0)[0]) 
  FOR N=1L,N_ELEMENTS(TAGS)-1 DO STRUCT = CREATE_STRUCT(STRUCT,TAGS[N],CDATA.(N)[0])
  STRUCT = STRUCT_2MISSINGS(REPLICATE(STRUCT,COUNT))
  FOR N=0, N_ELEMENTS(TAGS)-1 DO BEGIN
    IF IDLTYPE(CDATA.(N)) NE 'STRING' THEN BEGIN
      OK = WHERE(CDATA.(N) EQ MISSING_VALUE,COUNT)
      IF COUNT GT 0 THEN CDATA.(N)(OK) = MISSINGS(CDATA.(N))
    ENDIF
    IF KEY(STRING_STRUCT) THEN STRUCT.(N) = CDATA.(N)(1:*) ELSE STRUCT.(N) = CDATA.(N)
  ENDFOR

  RETURN,STRUCT  

;**********************************************************************************************************
;**********************************************************************************************************
;**********************************************************************************************************
;**********************************************************************************************************
;**********************************************************************************************************

; OLD CSV_READ code

  TXT = ''

;===> DELIMITER IS A COMMA
  DELIM=','
  IF KEY(COMP) THEN _COMP = '-COMP' ELSE _COMP = ''


;===> DETERMINE NUMBER OF LINES IN THE FILE
  N_LINES= FILE_LINES(FILE, COMPRESS=_COMP)
  
;===> OPEN THE CSV FILE FOR READING
  OPENR,LUN,FILE,/GET_LUN, COMPRESS=_COMP

;===> SKIP LINES OF TEXT BEFORE THE TAGS (DATA FIELDS)
  IF N_ELEMENTS(SKIP) EQ 1 THEN BEGIN
  	PRINT,'SKIPPING '+STRTRIM(SKIP) +' LINES'
  	FOR N=1L,SKIP DO BEGIN & READF,LUN,TXT & PRINT,TXT & ENDFOR
  ENDIF;IF N_ELEMENTS(SKIP) EQ 1 THEN BEGIN

;	===> READ THE TAGNAMES
  READF, LUN, TXT
  DATA = STRSPLIT(TXT,DELIM,/EXTRACT)

;	===> CHECK VALIDITY OF TAGNAMES
  DATA = STRUCT_TAGNAMES_FIX(STRTRIM(DATA,2))
  
;	===> IF TAGNAMES THEN RETURN JUST THE TAGNAMES AND NO DATA
  IF KEYWORD_SET(TAGNAMES) THEN BEGIN
  	CLOSE,LUN & FREE_LUN,LUN
  	RETURN, STRUPCASE(DATA)
  ENDIF;IF KEYWORD_SET(TAGNAMES) THEN BEGIN

;	===> CREATE THE STRUCTURE
;FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
  FOR N=0L,N_ELEMENTS(DATA)-1L DO BEGIN
    ANAME = DATA(N)
    ANAME = STRTRIM(ANAME,2)
    IF N EQ 0 THEN STRUCT=CREATE_STRUCT(ANAME,'') ELSE STRUCT = CREATE_STRUCT(STRUCT,ANAME,'')
  ENDFOR;FOR N=0L,N_ELEMENTS(DATA)-1L DO BEGIN
;FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF   

;===> REPLICATE STRUCTURE N_LINES
  STRUCT=REPLICATE(STRUCT, (N_LINES-1L) > 1)

;===> LINE COUNTER
  LINE = -1L

;WWWWWWWWWWWWWWWWWWWWWWWWWW
  WHILE NOT EOF(LUN) DO BEGIN
    READF,LUN,TXT
    LINE = LINE + 1L
    DATA = STRSPLIT(TXT,DELIM,/EXTRACT,/PRESERVE_NULL)
    NTH_DATA = (N_ELEMENTS(DATA) ) -1L ;
;     FREQUENTLY SPREADSHEET CSV FILES HAVE BLANK COLUMNS AT RIGHT 
;     SO ONLY FILL STRUCTURE WITH NON BLANK COLUMNS [NTH_DATA]

 ;FFFFFFFFFFFFFFFFFFFFFFFFFF 
    FOR N=0L,NTH_DATA DO BEGIN
       STRUCT(LINE).(N)= DATA(N)
    ENDFOR;FOR N=0L,NTH_DATA DO BEGIN
 ;FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
 
ENDWHILE;WHILE NOT EOF(LUN) DO BEGIN
;WWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW
  CLOSE,LUN & FREE_LUN,LUN
  RETURN,STRUCT

END; #####################  END OF ROUTINE ################################
