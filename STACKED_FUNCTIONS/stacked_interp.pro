; $ID:	STACKED_INTERP.PRO,	2023-09-21-13,	USER-KJWH	$
  PRO STACKED_INTERP, FILES, PROD=PROD, DATERANGE=DATERANGE, SPAN=SPAN, N_GOOD=N_GOOD, SMOOTH_WIDTH=SMOOTH_WIDTH, STAT_TRANSFORM=STAT_TRANSFORM, $
                      DAYS_BEFORE=DAYS_BEFORE,VERBOSE=VERBOSE, OVERWRITE=OVERWRITE, LOGLUN=LOGLUN

;+
; NAME:
;   STACKED_INTERP
;
; PURPOSE:
;   To interpolate and smooth "stacked" time series data
;
; CATEGORY:
;   STACKED_FUNCTIONS
;
; CALLING SEQUENCE:
;   STACKED_INTERP, FILES
;
; REQUIRED INPUTS:
;   FILES........ Daily stacked file(s) 
;
; OPTIONAL INPUTS:
;   PROD............. The product name to extract from the files (needed if the file contains more than one product)
;   DIR_OUT.......... Output directory for the output files
;   DATERANGE........ Use a specified daterange to subset the data
;   SPAN............. The sampling gap in the series (number of days) to "blank" (make missing) (default = 7)
;   N_GOOD........... The minimum number is the series to interpolate (default = 11) 
;   SMOOTH_WIDTH..... The width to use in the TRICUBE SMOOTH FILTERING step
;   STAT_TRANSFORM... To transform the data or not (default is based on the input product and the setting in PRODS_MAIN)
;   DAYS_BEFORE...... The number of "previous days" to include in the interpolation
;   LOGLUN........... If provided, the LUN for the log file
;    
; KEYWORD PARAMETERS:
;   VERBOSE.......... Print program progress
;   OVERWRITE........ Overwrite the output stacked interp file if it exists
;  
; OUTPUTS:
;   An annual stacked file of interpolated data
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
; EXAMPLE:
;
;
; NOTES:
;   
;   
; COPYRIGHT: 
; Copyright (C) 2022, Department of Commerce, National Oceanic and Atmospheric Administration, National Marine Fisheries Service,
;   Northeast Fisheries Science Center, Narragansett Laboratory.
;   This software may be used, copied, or redistributed as long as it is not sold and this copyright notice is reproduced on each copy made.
;   This routine is provided AS IS without any express or implied warranties whatsoever.
;
; AUTHOR:
;   This program was written on December 16, 2022 by Kimberly J. W. Hyde, Northeast Fisheries Science Center | NOAA Fisheries | U.S. Department of Commerce, 28 Tarzwell Dr, Narragansett, RI 02882
;    
; MODIFICATION HISTORY:
;   Dec 16, 2022 - KJWH: Initial code written - adapted from D3_MAKE and D3_INTERP
;   Jan 04, 2023 - KJWH: Added the "original" file to the output DB
;                        Added a check for multiple files when determining the "next" file
;   Mar 20, 2023 - KWJH: Removed DAYS_KEEP input (legacy of old D3 interpolation steps)
;                                      Fixed bug that was not saving the correct array of data in the output hash 
;                                      Added ability to look for the PREVIOUS and NEXT files if not provided        
;-
; ****************************************************************************************************
  ROUTINE_NAME = 'STACKED_INTERP'
  COMPILE_OPT IDL2
  SL = PATH_SEP()
  
  ;===> Set up the defaults
  IF ~N_ELEMENTS(SPAN)         THEN SPAN = 7              ; The maximum number of days to interpolate in the series. If it exceeds the span, then the data will be removed
  IF ~N_ELEMENTS(N_GOOD)       THEN N_GOOD = 11           ; Minimum number in the series to interpolate
  IF ~N_ELEMENTS(DAYS_BEFORE)  THEN DAYS_BEFORE = 60      ; Include the previous 60 days in the interpolation when updating the STACKED_INTERP file
  IF ~N_ELEMENTS(SMOOTH_WIDTH) THEN WIDTH = 7             ; Use the default of 7 for the smooth width

  IF ~N_ELEMENTS(LOGLUN)      THEN LOG_LUN = [] ELSE LOG_LUN = LOGLUN
  PLUN, LUN, 'Starting ' + ROUTINE_NAME

  IF ~N_ELEMENTS(FILES) THEN MESSAGE,'ERROR: At least 1 input file is required'
  ALLFILES = FILE_SEARCH((FILE_PARSE(FILES)).DIR + '*.*') 
  
  ; ===> FILE INFORMATION
  IF KEYWORD_SET(DATERANGE) THEN FILES = DATE_SELECT(FILES,DATERANGE,COUNT=COUNT) ELSE COUNT = N_ELEMENTS(FILES)                  ; Subset the files based on the daterange (if provided)
  IF COUNT EQ 0 THEN MESSAGE,'ERROR: There are no files with the date range ' + STRJOIN(NUM2STR(DATERANGE,'-'))                   ; Make sure files are provided
  FP = PARSE_IT(ALLFILES,/ALL)                                                                                                       ; Parse the file names
  ALLFILES = ALLFILES[SORT(DATE_2JD(PERIOD_2DATE(FP.PERIOD)))]                                                                          ; Make sure files & fp in ascending order
  
  MTIMES = FP.MTIME                                                                                                               ; Get the mtimes of the files
  IF SAME(FP.EXT) EQ 0 THEN MESSAGE, 'All input files must have the same EXTENSION'                                               ; Make sure all files have the same extension

  IF ~N_ELEMENTS(DIR_OUT) THEN DIR_OUT = REPLACE(FP[0].DIR,'STACKED_SAVE','STACKED_INTERP') & DIR_TEST, DIR_OUT

  ; ===> Set up the PRODUCT information based on the the input files
  IF SAME(VALIDS('PRODS',FP.NAME)+VALIDS('ALGS',FP.NAME)) EQ 0 THEN  MESSAGE, 'ERROR: PROD-ALG name not consistent in all files'  ; Make sure the prod-alg combo are the same in all files
  IF ~N_ELEMENTS(D3_PROD) THEN APROD = VALIDS('PRODS',FP[0].NAME) ELSE APROD = VALIDS('PRODS',D3_PROD)                            ; Get the product name
  IF ~N_ELEMENTS(D3_PROD) THEN D3_PROD = APROD                                                                                    ; Use the input product name if provided
  IF APROD EQ '' THEN MESSAGE, 'Must provide valid d3 product name'                                                               ; Double check that the product is valid
  PINFO = PRODS_READ(APROD)                                                                                                       ; Get the product specific information
  IF KEYWORD_SET(STAT_TRANSFORM) THEN TRANSFORM = STAT_TRANSFORM ELSE TRANSFORM = KEYWORD_SET(FIX(PINFO.LOG))                     ; If not predetermined, use the log info to determine the transformation status
  IF KEYWORD_SET(SMOOTH_WIDTH) THEN WIDTH = SMOOTH_WIDTH ELSE IF FIX(PINFO.D3_SMOOTH) GT 0 THEN WIDTH = FIX(PINFO.D3_SMOOTH)      ; If not given as a keyword input, then use the d3_smooth info from PRODS MAIN
    
  ; ===> Loop through files
  NFILES = N_ELEMENTS(FILES)
  FOR F=0, NFILES-1 DO BEGIN  
    AFILE = FILES[F]                                                                                                              ; Get the file
    FA = PARSE_IT(AFILE)                                                                                                          ; Parse the file
    APERSTR = PERIOD_2STRUCT(FA.PERIOD)                                                                                           ; Get the period details for the input file
    PREYEAR = APERSTR.YEAR_START-1
    NEXYEAR = APERSTR.YEAR_START+1
    OKP = WHERE(FP.YEAR_START EQ PREYEAR, COUNTP)
    OKN = WHERE(FP.YEAR_START EQ NEXYEAR,COUNTN)
    IF COUNTP EQ 1 THEN PREFILE = FP[OKP].FULLNAME ELSE PREFILE = []
    IF COUNTN EQ 1 THEN NEXFILE = FP[OKN].FULLNAME ELSE NEXFILE = []
;    CASE F OF                                                                                                                     ; Get the "previous" and "next" files to prepend and extend the time series
;      0:        BEGIN & PREFILE = []         & IF N_ELEMENTS(FILES) GT 1 THEN NEXFILE = FILES[F+1] & END                                                         ; If the first file in the loop, just get the next file
;      NFILES-1: BEGIN & PREFILE = FILES[F-1] & NEXFILE = []         & END                                                         ; If the last file, just get the previous file
;      ELSE:     BEGIN & PREFILE = FILES[F-1] & NEXFILE = FILES[F+1] & END                                                         ; Get both the previous and next files
;    ENDCASE
    
    PF = PARSE_IT(PREFILE) & IF PREFILE NE [] THEN IF PF.YEAR_START NE FA.YEAR_START-1 THEN PREFILE = []                          ; Parse the prevous file and make sure it represents the previous year
    NF = PARSE_IT(NEXFILE) & IF NEXFILE NE [] THEN IF NF.YEAR_START NE FA.YEAR_START+1 THEN NEXFILE = []                          ; Parse the next file and make sure it represents the next year
    
    OUTFILE = DIR_OUT + FA.NAME + '-INTERP.SAV'                                                                                   ; Create the output file name
    IF ~FILE_MAKE([PREFILE,AFILE,NEXFILE],OUTFILE,OVERWRITE=OVERWRITE) THEN CONTINUE                                              ; Check to see if the output file needs to be created
    
    ; ===> Read the input file and extract the database and extract the basic info
    D = STACKED_READ(AFILE,PRODS=INPRODS,DB=ADB,BINS=ABINS)                                                                       ; Read the first input stacked file
    OK = WHERE_MATCH(TAG_NAMES(D), APROD, COUNT)                                                                                  ; Find the matching input product tag in the data structure
    IF COUNT NE 1 THEN MESSAGE, 'ERROR: ' + APROD + ' not found in ' + INPRODS                                                    ; Check to make sure the STAT_PROD matches one of the input file products
    ADATA = D.(OK)                                                                                                                ; Extract the product specific data
    
    ; ===> Get the dimensions of the image
    SZ = SIZE(ADATA)                                                                                                              ; Get the dimensions of the input data
    DIMS = SZ[0]                                                                                                                  ; Determine the number of dimensions
    CASE DIMS OF                                                                                                                  ; Determine the image demsions
      2: BEGIN & AX = 0     & AY = SZ[1] & END
      3: BEGIN & AX = SZ[1] & AY = SZ[2] & END
    ENDCASE ; DIMS
    
    ; ===> Set up the output array and database
    ODATA = ADATA & ODATA[*,*,*] = MISSINGS(ODATA)                                                                                ; Create a blank output array with the same dimensions as the input data (i.e. one year)
    ODB = ADB                                                                                                                     ; Copy the input database (DB) 
    ODATES = CREATE_DATE(APERSTR.YEAR_START)                                                                                      ; Create an array of dates for the year
    OUTDATERANGE = GET_DATERANGE(ODATES[0],ODATES[-1])
    OUTHASH = D3HASH_MAKE(OUTFILE,INPUT_FILES=AFILE,BINS=ABINS, PRODS=APROD,PX=AX,PY=AY)                                          ; Initialize the output HASH
    OK = WHERE(ODB.DATE_RANGE NE MISSINGS(''),/NULL)                                                                              ; Find the dates in the input DB that are not missing
    OBEG = OK[0]                                                                                                                  ; Get the subscript of the first date in the file (note, it may not be Jan 1 if it is the start of a time series)
    OEND = OK[-1]                                                                                                                 ; Get the subscript of the last date in the file

    ; ===> Get the dimensions of the output data
    OSZ = SIZEXYZ(OUTHASH[APROD],PX=OPX,PY=OPY,PZ=OPZ)
    IF OSZ.N_DIMENSIONS NE 3 THEN MESSAGE, 'ERROR: Expecting a 3 dimensional array'
    
    ; ===> Set up the beginning and end dates for the interpolation
    PREDATE = JD_2DATE(JD_ADD(DATE_2JD(APERSTR.DATE_START),-1*DAYS_BEFORE,/DAY))                                                  ; Determine the start date in the previous file
    NEXDATE = JD_2DATE(JD_ADD(DATE_2JD(APERSTR.DATE_END),DAYS_BEFORE,/DAY))                                                       ; Determine the end date in the next file
    
    ; ===> Add data from the previous file to the original input file
    IF PREFILE NE [] THEN BEGIN
      PD = STACKED_READ(PREFILE,KEYS=PKEYS,BINS=PBINS,DB=PDB,PRODS=PINPRODS)                                                      ; Read the "previous" input stacked file
      OK = WHERE_MATCH(TAG_NAMES(PD), APROD, COUNT)                                                                               ; Find the matching input product tag in the data structure
      IF COUNT NE 1 THEN MESSAGE, 'ERROR: ' + APROD + ' not found in ' + PINPRODS                                                 ; Check to make sure the PROD matches one of the input file products
      PDATA = PD.(OK)                                                                                                             ; Extract the data from the "previous" file
      
      ; === Check that the array dimenions match
      ASZ = SIZE(ADATA,/DIMENSIONS)                                                                                               ; Get the dimensions of the initial data
      PSZ = SIZE(PDATA,/DIMENSIONS)                                                                                               ; Get the dimenions of the secondary data
      IF N_ELEMENTS(ASZ) NE N_ELEMENTS(PSZ) OR ASZ[0] NE PSZ[0] OR ASZ[1] NE PSZ[1] THEN MESSAGE, 'ERROR: The dimensions of the data do not match' ; Check that the dimensions are the same
      
      ; ===> Find the days prior to the start of the new year
      OKDATES = WHERE(PERIOD_2JD(PDB.PERIOD) GE DATE_2JD(PREDATE),COUNT)                                                          ; Find the periods within the DAYS_BEFORE range
      IF COUNT EQ 0 THEN MESSAGE, 'ERROR: Data after ' + PREDATE + ' were not found'                                              ; Check that the periods were found within the daterange

      ; ===> Merge the data from the previous file and the main file
      CASE N_ELEMENTS(ASZ) OF                                                                                                     ; Get the dimensions for the new array
        2: BEGIN & XX = 0 & YY = ASZ[0] & ZZ = ASZ[1]+COUNT & END                                                                 ; Array sizes based on 2 dimensions
        3: BEGIN & XX = ASZ[0] & YY = ASZ[1] & ZZ = ASZ[2]+COUNT & END                                                            ; Array sizes based on 3 dimensions
      ENDCASE
      NEWARR = FLTARR(XX,YY,ZZ) & NEWARR[*,*,*] = MISSINGS(NEWARR)                                                                ; Make a blank "new" array                                         
      NEWARR[*,*,0:COUNT-1] = PDATA[*,*,OKDATES]                                                                                  ; Add the "previous" data to the array
      NEWARR[*,*,COUNT:*] = ADATA                                                                                                 ; Add the data from the primary file
      ADATA = NEWARR & NEWARR = []                                                                                                ; Rename the merged data and remove the temporary array

      ADBTAGS = TAG_NAMES(ADB) & PDBTAGS = TAG_NAMES(PDB)                                                                         ; Get the DB tag names
      NEWDB = []                                                                                                                  ; Create a new NULL DB
      FOR DD=0, N_TAGS(ADB)-1 DO BEGIN                                                                                            ; Loop through DB tags
        IF PDBTAGS[DD] NE ADBTAGS[DD] THEN MESSAGE, 'ERROR: Database tag names do not match'                                      ; Check that the DB tags match
        NEWDB = CREATE_STRUCT(NEWDB,ADBTAGS[DD],[PDB[OKDATES].(DD),ADB.(DD)])                                                     ; Create a new structure with the merged DB info
      ENDFOR
      NEWDB.SEQ = INDGEN(N_ELEMENTS(NEWDB.SEQ))                                                                                   ; Update the SEQ values
      ADB = NEWDB & NEWDB = [] & PD = [] & PDB = []                                                                               ; Copy the new DB and remove the temporary arrays
    ENDIF
    
    ; ===> Add data from the previous file to the original input file
    IF NEXFILE NE [] THEN BEGIN
      ND = STACKED_READ(NEXFILE,DB=NDB,PRODS=NPRODS)                                                                              ; Read the "next" input stacked file
      OK = WHERE_MATCH(TAG_NAMES(ND), APROD, COUNT)                                                                               ; Find the matching input product tag in the data structure
      IF COUNT NE 1 THEN MESSAGE, 'ERROR: ' + APROD + ' not found in ' + NPRODS                                                   ; Check to make sure the STAT_PROD matches one of the input file products
      NDATA = ND.(OK)                                                                                                             ; Extract the data from the "next" file

      ; === Check that the array dimenions match
      ASZ = SIZE(ADATA,/DIMENSIONS)                                                                                               ; Get the dimensions of the initial data
      NSZ = SIZE(NDATA,/DIMENSIONS)                                                                                               ; Get the dimenions of the secondary data
      IF N_ELEMENTS(ASZ) NE N_ELEMENTS(NSZ) OR ASZ[0] NE NSZ[0] OR ASZ[1] NE NSZ[1] THEN MESSAGE, 'ERROR: The dimensions of the data do not match' ; Check that the dimensions are the same

      ; ===> Find the days prior to the start of the new year
      OKDATES = WHERE(PERIOD_2JD(NDB.PERIOD) LE DATE_2JD(NEXDATE),COUNT)                                                          ; Find the periods within the DAYS_BEFORE range
      IF COUNT EQ 0 THEN MESSAGE, 'ERROR: Data after ' + NEXDATE + ' were not found'                                              ; Check that the periods were found within the daterange

      ; ===> Merge the data from the previous file and the main file
      CASE N_ELEMENTS(ASZ) OF                                                                                                     ; Get the dimensions for the new array
        2: BEGIN & XX = 0 & YY = ASZ[0] & ZZ = ASZ[1]+COUNT & END                                                                 ; Array sizes based on 2 dimensions
        3: BEGIN & XX = ASZ[0] & YY = ASZ[1] & ZZ = ASZ[2]+COUNT & END                                                            ; Array sizes based on 3 dimensions
      ENDCASE
      NEWARR = FLTARR(XX,YY,ZZ) & NEWARR[*,*,*] = MISSINGS(NEWARR)                                                                ; Make a new blank array
      NEWARR[*,*,0:ASZ[-1]-1] = ADATA                                                                                             ; Add the input data to the new array  
      NEWARR[*,*,ASZ[-1]:*] = NDATA[*,*,OKDATES]                                                                                  ; Add the data from the "next" file to the array
      ADATA = NEWARR & NEWARR = []                                                                                                ; Rename the merged data and remove the temporary array

      ADBTAGS = TAG_NAMES(ADB) & NDBTAGS = TAG_NAMES(NDB)                                                                         ; Get the DB tag names
      NEWDB = []                                                                                                                  ; Create a new NULL DB
      FOR DD=0, N_TAGS(ADB)-1 DO BEGIN                                                                                            ; Loop through DB tags
        IF NDBTAGS[DD] NE ADBTAGS[DD] THEN MESSAGE, 'ERROR: Database tag names do not match'                                      ; Check that the DB tags match
        NEWDB = CREATE_STRUCT(NEWDB,ADBTAGS[DD],[ADB.(DD),NDB[OKDATES].(DD)])                                                     ; Create a new structure with the merged DB info
      ENDFOR
      NEWDB.SEQ = INDGEN(N_ELEMENTS(NEWDB.SEQ))                                                                                   ; Update the SEQ values
      ADB = NEWDB & NEWDB = [] & ND = [] & NDB = []                                                                               ; Copy the new DB and remove the temporary arrays
    ENDIF
    
    PBEG = WHERE(ADB.PERIOD EQ ODB[OBEG].PERIOD)
    PEND = WHERE(ADB.PERIOD EQ ODB[OEND].PERIOD)
    
    ; ===> Get the Julian dates of the input data
    JDS = PERIOD_2JD(ADB.PERIOD)                                                                                                  ; Convert the periods to JD dates
    I_JDS = DATE_2JD(CREATE_DATE(PERIOD_2DATE(ADB[0].PERIOD),PERIOD_2DATE(ADB[-1].PERIOD))) ; Create a range of JD dates
    ;I_JDS = ULONG(INTERVAL([ULONG(MIN(JDS)),ULONG(MAX(JDS))],1))                                                                  ; Create a range of JD dates

    FIRST_DATE = []                                                                                                               ; Create a NULL variable for the first date
    FOR Z=0, OPZ-1 DO BEGIN                                                                                                       ; Loop by day of the output database
      ZDATE = PERIOD_2DATE(ODB[Z].PERIOD,/SHORT)                                                                                                   ; Get the day
      IF ZDATE EQ MISSINGS('') AND FIRST_DATE EQ [] THEN CONTINUE                                                                 ; Check that the day is not missing (if there is no data for that day, DATE_RANGE will be blank)
      IF FIRST_DATE EQ [] AND ODB[Z].DATE_RANGE NE '' THEN FIRST_DATE = ZDATE                                                                                 ; Establish the FIRST_DATE of the time series
      SEQ = WHERE(ADB.DATE_RANGE EQ ZDATE)                                                                                        ; Find the matching date in the input DB
      ODATE = STRMID(ODATES[Z],0,8)
      IF ODATE NE ZDATE AND ZDATE NE ''  THEN MESSAGE, 'ERROR: Double check the dates'
      INFILES = AFILE                                                                                                             ; Copy the primary input file name
      IF DATE_2JD(ODATE) LE JD_ADD(DATE_2JD(PREDATE),DAYS_BEFORE,/DAY) AND PREFILE NE [] THEN INFILES = [PREFILE,INFILES]         ; Determine if the date also includes interpolation from the previous file and add to the list of input files
      IF JD_ADD(DATE_2JD(ODATE),DAYS_BEFORE,/DAY) GE DATE_2JD(APERSTR.DATE_END) AND NEXFILE NE [] THEN INFILES = [INFILES,NEXFILE]; Determine if the date also includes interpolation from the next file and add to the list of input files
  
      ; ===> Add the file information to the D3 database in the D3HASH
      OUTHASH['FILE_DB','MTIME',Z] = DATE_NOW(/MTIME)                                                                             ; Add the file MTIME to the D3 database
 ;     OUTHASH['FILE_DB','FILE',Z] = OUTFILE                                                                                       ; Add the full file name to the D3 database
      OUTHASH['FILE_DB','NAME',Z] = (FILE_PARSE(OUTFILE)).NAME_EXT                                                                ; Add the file "name" to the D3 database
      OUTHASH['FILE_DB','DATE_RANGE',Z] = ODATE                                                                                   ; Add the "daterange" to the D3 database
      OUTHASH['FILE_DB','INPUT_FILES',Z] = INFILES                                                                                ; Add the "input" files to the D3 database
      OUTHASH['FILE_DB','ORIGINAL_FILES',Z] = ADB[SEQ].INPUT_FILES

    ENDFOR ; Day loop
       
    FOR Y=0, OPY-1 DO BEGIN                                                                                                       ; Loop on pixels
      PSERIES = ADATA[*,Y,*]                                                                                                      ; Copy the pixel time series
      OK = WHERE(FINITE(PSERIES),COUNT)                                                                                           ; Find where the pixels are not missing
      IF COUNT EQ 0 THEN CONTINUE                                                                                                 ; Skip if all pixels are missing 
      
      POF,Y,OPY,OUTTXT=POFTXT,/QUIET, /NOPRO                                                                                      ; Get the text to track the pixel loop
      PLUN, LOG_LUN,'Found ' + NUM2STR(COUNT) + ' valid pixels out of ' + NUM2STR(N_ELEMENTS(PSERIES)) + ' in array ' + POFTXT, 0 ; Write out the details about the pixel time series
      
      PSR = PSERIES[OK]                                                                                                       ; Subset the pixel series
      DAYS    = I_JDS-FIRST(I_JDS)                                                                                                ; Get the full list of days
      _DAYS   = DAYS[OK]                                                                                                          ; Subset the days to ones with valid pixels
      _JDS    = JDS[OK]                                                                                                           ; Subset the JDs to ones with valid pixels

      IF N_ELEMENTS(PSERIES) LT N_GOOD THEN CONTINUE                                                                              ; Must have at least N_GOOD points to interpolate
      IF KEYWORD_SET(TRANSFORM) THEN PSR = ALOG(PSR)                                                                      ; Transform the pixel series

      INTP = INTERPX(_DAYS, PSR, DAYS, HELP=HLP, BAD=BAD, GAP=GAP, FIXBAD=FIXBAD)                                             ; Linearly interpolate pixel series to all the days in this time series
      IF WIDTH GT 0 THEN SMO = FILTER(INTP, FILT='TRICUBE', WIDTH=WIDTH) $                                                        ; Smooth the interpolated data using TRICUBE
                    ELSE SMO = INTP                                                                                               ; If the WIDTH is 0, don't smooth
      IF KEYWORD_SET(TRANSFORM) THEN SMO = EXP(SMO)                                                                               ; Untransform the interpolated pixel series
      BLANKED = D3_INTERP_BLANK(JD=_JDS, INTERP_DATA=SMO, INTERP_JD=I_JDS, SPAN=SPAN)                                             ; If the input data gaps are greater than the allowed SPAN, then "blank" them out (i.e. make missings)
      OUTHASH[APROD,*,Y,OBEG:OEND] = BLANKED[PBEG:PEND]                                                                           ; Add the final data to the output HASH
      
    ENDFOR ; Pixel loop

    ; ===> Update the metadata and file information
    OUTHASH['METADATA'] = D3HASH_METADATA(OUTFILE, DB=OUTHASH['FILE_DB'])                                                         ; Add the metadata for the file to the hash                                                                                                 ; Change the DATATYPE to stat
    
    ; ===> Save the OUTHASH file
    PLUN, LUN, 'Writing ' + OUTFILE
    SAVE, OUTHASH, FILENAME=OUTFILE, /COMPRESS                                                                                    ; Save the file
    OUTHASH = []                                                                                                                  ; Remove the OUTHASH to clear up memory
  ENDFOR ; File loop

  
END ; ***************** End of STACKED_INTERP *****************
