; $ID:	STACKED_STATS.PRO,	2023-09-21-13,	USER-KJWH	$
  PRO STACKED_STATS,FILES, PERIOD_OUT=PERIOD_OUT, $
                    STATPROD=STATPROD, STAT_TYPES=STAT_TYPES, L3BSUBMAP=L3BSUBMAP, DATERANGE=DATERANGE, CLIMATOLOGY_DATERANGE=CLIMATOLOGY_DATERANGE,$
                    DIR_OUT=DIR_OUT, FILE_LABEL=FILE_LABEL, LOGLUN=LOGLUN, $
                    TRANSFORM=TRANSFORM, KEEP_COMMON=KEEP_COMMON, INIT=INIT, OVERWRITE=OVERWRITE

;+
; NAME:
;   STACKED_STATS
;
; PURPOSE:
;   Create stats from a D3HASH file
;
; CATEGORY:
;   STACKED_FUNCTIONS
;
; CALLING SEQUENCE:
;   STACKED_STATS, FILES
;
; REQUIRED INPUTS:
;   FILES.......... Input "stacked" D3HASH files
;   PERIOD_OUT..... The output period codes
;   
; OPTIONAL INPUTS:
;   STATPROD....... The product name to calculate stats (needed when files have multiple products)
;   STAT_TYPES..... A list of stat to calculate - DEFAULT = ['NUM','MIN','MAX','SPAN','NEG','WTS','SUM','SSQ','MEAN','STD','CV']
;   L3BSUBMAP...... The standard map name used to subset a L3B files (e.g. if the input is a global L3B4 file, it can be subset to the NWA map)
;   DATERANGE...... A daterange to subset the files
;   DIR_OUT........ The output directory
;   FILE_LABEL..... A string of key-identifying attributes for the output file name [e.g. map-method-prod]
;   LOGLUN......... If provided, the LUN for the log file
;
; KEYWORD PARAMETERS:
;   TRANSFORM...... Keyword to include the geometric mean and geometric standard deviation in the output stats
;   KEEP_COMMON.... Keyword to use hold the STATHASH in COMMON memory instead of saving the file (used for the DOY stats)
;   INIT........... Keyword to overwrite a STATHASH in COMMON memory
;   OVERWRITE...... Overwrite the current file if it exists
;
; OUTPUTS:
;   OUTPUT......... New D3HASH stacked files with statistics
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
; NOTES:
;   
;   
; COPYRIGHT: 
; Copyright (C) 2021, Department of Commerce, National Oceanic and Atmospheric Administration, National Marine Fisheries Service,
;   Northeast Fisheries Science Center, Narragansett Laboratory.
;   This software may be used, copied, or redistributed as long as it is not sold and this copyright notice is reproduced on each copy made.
;   This routine is provided AS IS without any express or implied warranties whatsoever.
;
; AUTHOR:
;   This program was written on September 21, 2021 by Kimberly J. W. Hyde, Northeast Fisheries Science Center | NOAA Fisheries | U.S. Department of Commerce, 28 Tarzwell Dr, Narragansett, RI 02882
;    
; MODIFICATION HISTORY:
;   Sep 21, 2021 - KJWH: Initial code written
;   Sep 30, 2022 - KJWH: Changed name to STACKED_STATS
;   Nov 14, 2022 - KJWH: Replaced STATHASH_METADAT with D3HASH_METADATA to reduce redundancy (STAHASH_METADATA is no obsolete)
;   Nov 16, 2022 - KJWH: Now using MAPS_L3B_SUBSET to get the bin numbers for the subset map
;   Nov 18, 2022 - KJWH: Changed L3BSUBSET to L3BSUBMAP
;   Dec 14, 2022 - KJWH: Removed the step to remove the current year from the ANNUAL period name in order for it to match the ANNUAL period name generated in STACKED_STATS
;   Jun 01, 2023 - KJWH: Fixed a bug when concatenating data from multiple files (e.g. making the structure to calculate the A period data)
;                        Fixed bug with the file MTIME in the database.  Now using UTC (/GMT) time to match up with the SYSTIME
;   Jan 08, 2024 - KJWH: Fixed bugs assosciated with switching the DB structure from a long structure to a spreadsheet style structure
;                          Changed DB.(variable)[SUBS] to DB[SUBS].(variable)
;                          Removed /STRUCT_ARRAYS keyword from STRUCT_RENAME when changing the names in the DB database
;                          When concatenating multiple files, now simply concatenating the databases DB = [DB,SDB], sorting and then adding the sequence value
;-
; ****************************************************************************************************
  ROUTINE_NAME = 'STACKED_STATS'
  COMPILE_OPT IDL2
  SL = PATH_SEP()
  
  ; ===> Set up the COMMON memory variables
  COMMON _STACKED_STATS, STATHASH, HASH_PERIOD_CODE
  IF KEYWORD_SET(INIT) THEN STATHASH = []
  IF KEYWORD_SET(INIT) OR HASH_PERIOD_CODE EQ [] THEN HASH_PERIOD_CODE = ''
  IF STATHASH EQ [] THEN HASH_PERIOD_CODE = ''
  
  ; ===> Set up defaults for optional inputs and keywords
  IF ~N_ELEMENTS(DATERANGE)  THEN DATERANGE  = []                                                                           ; Make DATERANGE null if not provided
  IF ~N_ELEMENTS(CLIMATOLOGY_DATERANGE) THEN CLIM_DATERANGE = [] ELSE CLIM_DATERANGE = CLIMATOLOGY_DATERANGE
  IF ~N_ELEMENTS(PERIOD_OUT) THEN MESSAGE, 'ERROR: Must provide a least one output period'                                 ; Check for the output period
  IF ~N_ELEMENTS(LOGLUN)     THEN LUN = [] ELSE LUN = LOGLUN                                                                ; Set up the LUN to record in the log file
  IF ~N_ELEMENTS(STAT_TYPES) THEN STATTYPES = ['NUM','MIN','MAX','SPAN','SUM','MED','MEAN','VAR','STD','CV','SKEW','KURT']  ELSE STATTYPES = STAT_TYPES; Set up the default stats to calculate
  STATTYPES = ['NUM',STATTYPES[WHERE(STATTYPES NE 'NUM',/NULL)]]                                                         ; Ensure that NUM is the first "stat"
                                                                    
  ; ===> Check the files and get general information from the file names
  IF ~N_ELEMENTS(FILES)      THEN MESSAGE, 'ERROR: Input files are required'                                                ; Check for input files
  FP = PARSE_IT(FILES,/ALL)                                                                                                 ; Parse the file names
     
  ; ===> Check the PERIOD, MAP, SENSOR and PRODUCT information based on the the input files
  IF ~SAME(FP.PERIOD_CODE) THEN MESSAGE, 'All input files are not from the same PERIOD'                                     ; Check to make sure all of the input PERIOD_CODES are the same
  IF ~SAME(FP.MAP)         THEN MESSAGE, 'ERROR: All input files must have the same "MAP".'                                 ; Check to make sure all of the input MAPS are the same
  IF ~SAME(FP.PROD_ALG)    THEN MESSAGE, 'ERROR: All input files must have the same "PROD" and "ALG".'                      ; Check to make sure all of the input PRODS and ALGS are the same
  IF ~SAME(FP.SENSOR)      THEN MESSAGE, 'ERROR: All input files do not have the same SENSOR'                               ; Check to make sure all of the input SENSORS are the same
  
  ; ===> Subset the files based on the daterange
  COUNT = N_ELEMENTS(FILES) 
  IF DATERANGE NE [] AND FP[0].PERIOD_CODE NE 'AA' THEN FILES = DATE_SELECT(FILES,DATERANGE,COUNT=COUNT)                       ; Subset the files based on the daterange (if provided)
  IF COUNT EQ 0 THEN MESSAGE,'ERROR: There are no files with the date range ' + STRJOIN(NUM2STR(DATERANGE,'-'))             ; Make sure files are provided
  IF DATERANGE EQ [] THEN DATERANGE = [MIN(FP.DATE_START),MAX(FP.DATE_END)]                                                 ; Get a DATERANGE if not provided
  
  ; ===> Set up the PROD info
  IF ~N_ELEMENTS(STATPROD) THEN STAT_PROD = VALIDS('PRODS',FP[0].PROD) ELSE STAT_PROD = VALIDS('PRODS',STATPROD)            ; If the STAT_PROD (the name of the product to extract and calculate stats) is not provided, use the default PROD from the file name
  IF STAT_PROD EQ '' THEN MESSAGE, 'ERROR: The STAT_PROD is not a VALID product name'                                       ; Check that product name is "valid"
  PROD_INFO = PRODS_READ(STAT_PROD)                                                                                         ; Get the PROD information from the PRODS mainfile
  IF KEYWORD_SET(FIX(PROD_INFO.LOG)) OR KEYWORD_SET(TRANSFORM) THEN TRANSFORM = 'ALOG' ELSE TRANSFORM = []                  ; Determine if the data should be LOG transformed when calculating the stats
  
; TODO: Set up a separate "log" structure to hold the log based stats 
  IF KEYWORD_SET(TRANSFORM) THEN BEGIN
    STATTYPES = [STATTYPES,'GMEAN']
    LOGSTATS = []
    IF HAS(STATTYPES,'MEAN',/EXACT) THEN LOGSTATS = [LOGSTATS,'GMEAN']
    IF HAS(STATTYPES,'NUM',/EXACT)  THEN LOGSTATS = [LOGSTATS,'LNUM']
    IF HAS(STATTYPES,'STD',/EXACT)  THEN LOGSTATS = [LOGSTATS,'GSTD']
    IF HAS(STATTYPES,'SSQ',/EXACT)  THEN LOGSTATS = [LOGSTATS,'GSSQ']
    IF HAS(STATTYPES,'SUM',/EXACT)  THEN LOGSTATS = [LOGSTATS,'LSUM']
  ENDIF
  
  ; ===> Get the input map info and map size
  AMAP = FP[0].MAP                                                                                                             ; Map name
  MS = MAPS_SIZE(AMAP, PX=PX, PY=PY)                                                                                           ; Get the size of the map
  
  ; ===> Get the bin numbers of the subset map
  MOBINS = []   
  IF ~N_ELEMENTS(L3BSUBMAP) AND FP[0].MAP_SUBSET NE '' THEN L3BSUBMAP = VALIDS('MAPS',REPLACE(FP[0].MAP_SUBSET,'_SUBSET',''))
  IF N_ELEMENTS(L3BSUBMAP) EQ 1 THEN M = MAPS_L3B_SUBSET(MAPS_BLANK(AMAP),INPUT_MAP=AMAP,SUBSET_MAP=L3BSUBMAP,OCEAN_BINS=MOBINS)$ ; Get the BIN values for the subset map
                                ELSE IF IS_L3B(AMAP) THEN MOBINS = MAPS_L3B_BINS(AMAP)                                         ; Get the BIN values of the input map if it is an L3B map and no subset map is provided
  IF MOBINS NE [] THEN BEGIN & BX = 1  & BY = N_ELEMENTS(MOBINS) & ENDIF $                                                     ; Get the array sizes of the subset bins
                  ELSE BEGIN & BX = PX & BY = PY & ENDELSE                                                                     ; Use the original map sizes if not an L3B or subset 
                                                                                                                
  ; ===> Update the FILE LABEL based on the map information
  IF MOBINS EQ [] THEN MAP_PXY = AMAP + '-PXY_' + ROUNDS(PX) + '_' + ROUNDS(PY) ELSE BEGIN                                     ; Create a MAP, PX, PY label
    IF N_ELEMENTS(MOBINS) EQ PY THEN MAP_PXY = AMAP + '-PXY_' + ROUNDS(PX) + '_' + ROUNDS(PY) $                                ; Create a L3B MAP label
                                ELSE MAP_PXY = AMAP + '-' + L3BSUBMAP +'_SUBSET' + '-PXY_1_' + ROUNDS(N_ELEMENTS(MOBINS))                                  ; Create a L3BMAP specific MAP label
    PY = N_ELEMENTS(MOBINS)                                                                                                    ; Update the PY variable
  ENDELSE
  
  FOR R=0, N_ELEMENTS(PERIOD_OUT)-1 DO BEGIN                                                                                   ; Loop through output periods
    PEROUT = PERIOD_OUT[R]
    PEROUTCLIM = (PERIODS_READ(PEROUT)).CLIMATOLOGY
    IF PEROUT NE HASH_PERIOD_CODE THEN STATHASH = []                                                                           ; Reinitialize the STATHASH if it is a new period code
    HASH_PERIOD_CODE = PEROUT                                                                                                  ; Set the period code stored in COMMON memory
        
    ; ===> Set up PERIOD info
    PERSTR = PERIODS_READ(PEROUT)                                                                                              ; Get the PERIODS specific information for the output period
    PER_SETS = D3HASH_PERIOD_SETS(FP.FULLNAME, OUTPERIOD=PEROUT,CLIMATOLOGY_DATERANGE=CLIM_DATERANGE)                          ; Determie the ouput PERIODS and output STACKED PERIODS based on the input files
    OUTPERS = WHERE_SETS(PER_SETS.STACKED_PERIOD)                                                                              ; Group the output periods based on the STACKED_PERIODS
      
    ; ===> Create output directory and file name(s)
    IF ~N_ELEMENTS(DIR_OUT) THEN DIROUT = REPLACE(FP[0].DIR,FP[0].L2SUB,'STACKED_STATS') ELSE DIROUT = DIR_OUT                                      ; Create the output directory name
    IF ~N_ELEMENTS(FILE_LABEL) THEN FLABEL=FILE_LABEL_MAKE(FILES[0],LST=['SENSOR','VERSION','SATELLITE','SAT_EXTRA','METHOD','MAP','PROD','ALG','DAYNIGHT']) ELSE FLABEL=FILE_LABEL ; Create the output file label
    IF STAT_PROD NE FP[0].PROD AND STAT_PROD NE FP[0].PROD_ALG THEN BEGIN
      IF VALIDS('ALGS',STAT_PROD) EQ '' AND FP[0].ALG NE '' THEN OUTPROD = STAT_PROD + '-' + FP[0].ALG ELSE OUTPROD = STAT_PROD; Adde the ALG to the output product name if not provided
      FLABEL = REPLACE(FLABEL,FP[0].PROD_ALG,OUTPROD)                                                                          ; Update the file label with the correct product name
      DIROUT = REPLACE(DIROUT,FP[0].PROD_ALG,OUTPROD)                                                                        ; Update the output director
    ENDIF
    FLABEL = REPLACE(FLABEL, FP[0].MAP, MAP_PXY)
    DIR_TEST, DIROUT                                                                                                          ; Make the output directory folder
     
    ; ===> Loop through the stacked output periods 
    FOR N=0, N_ELEMENTS(OUTPERS)-1 DO BEGIN
      PER_SET = PER_SETS[WHERE_SETS_SUBS(OUTPERS[N])]                                                                          ; The output period information for each file
      INFILE = PER_SET[0].FILENAME                                                                                             ; Input file name for the first period
      IF STRPOS(INFILE,';') GT 0 THEN MESSAGE, 'ERROR: Double check filename - the ";" indicates more than one file'           ; Check for a concatenated filename
         
      IF ~SAME(PER_SET.FILENAME) THEN BEGIN                                                                                    ; If the filenames do not match, there could be a second input file
        FILESET = WHERE_SETS(PER_SET.FILENAME)                                                                                 ; Subset the filenames
        FILENAMES = STR_BREAK(FILESET.VALUE,';')                                                                               ; Break up the filenames (looking for a ";" which separates the concatenated file names)
        FILENAMES = FILENAMES[UNIQ(FILENAMES,SORT(FILENAMES))]                                                                 ; Get just the unique file names
        FILENAMES = FILENAMES[WHERE(FILENAMES NE '',/NULL)]                                                                    ; Remove any blank strings
        SECOND = FILENAMES[WHERE(FILENAMES NE INFILE,/NULL)]                                                                   ; Assume the first file is the primary file and indicate here the name of the secondary file
      ENDIF ELSE SECOND = []                                                                                                   ; Make SECOND null if only one filename is found
      INFILES = [INFILE,SECOND]                                                                                                ; Concatenate input files into an array
      INFILES = INFILES[WHERE(INFILES NE MISSINGS(''),/NULL)]                                                                  ; Remove any blank input files
      IF INFILES EQ [] THEN CONTINUE                                                                                           ; If no input files then continue
      
      FA = FILE_PARSE(INFILES[0])                                                                                              ; Parse the first input file
      STAT_FILE = DIROUT + OUTPERS[N].VALUE + '-' + FLABEL + '-STACKED_STATS.SAV'                                             ; Create the output STATS file
      
      ; ===> Check to see if the STAT_FILE needs to be created
      IF ~FILE_MAKE(INFILES,STAT_FILE,OVERWRITE=OVERWRITE) AND ~KEYWORD_SET(KEEP_COMMON) THEN BEGIN                            ; Check the file MTIMES and if the HASH structure exits                             
        IF IDLTYPE(STATHASH) NE 'OBJREF' THEN CONTINUE                                                                         ; If the HASH structure is not in COMMON memory, then continue
        WRITEFILE = 1                                                                                                          ; If the HASH structure is in COMMON memory, then set the WRITEFILE keyword
        GOTO, WRITE_FILE                                                                                                       ; Jump to the WRITEFILE section
      ENDIF
      IF ~FILE_MAKE(INFILES,STAT_FILE,OVERWRITE=OVERWRITE) THEN CONTINUE                                                       ; Check to see if the STAT_FILE needs to be created
      IF FILE_TEST(STAT_FILE) AND KEYWORD_SET(OVERWRITE) THEN FILE_DELETE, STAT_FILE                                           ; Remove the file if OVERWRITE is set
      OUTPERSTR = PERIOD_2STRUCT(OUTPERS[N].VALUE)                                                                             ; Get the date information from the period
      PDATERANGE = [STRMID(OUTPERSTR.DATE_START,0,8),STRMID(OUTPERSTR.DATE_END,0,8)]                                           ; Create a new daterange based on the PERIOD_SET
      
      ; ===> Read the input file and extract the database and extract the basic info
      D = STACKED_READ(INFILES[0],PRODS=INPRODS,DB=DB, BINS=BINS)                             ; Read the first input stacked file
      IF HAS(D.INFO.MATH, 'STATS') THEN STRUCT_PROD = STAT_PROD+'_MEAN' ELSE STRUCT_PROD = STAT_PROD                            ; Get the tagname of the data to use in the stats
      IF HAS(STAT_PROD, 'GRAD_') THEN STRUCT_PROD = STAT_PROD
            
      ; ===> Look for GRAD_MAG data and extract the X and Y components
      XDATA = [] & YDATA = []
      IF HAS(STRUCT_PROD,'GRAD_') THEN BEGIN
        GRAD_STATS = 1
        CASE STRUCT_PROD OF
          'GRAD_SST': BEGIN & GPRD = 'SST' & GRAD_TRANSFORM = 0 & END
          'GRAD_CHL': BEGIN & GPRD = 'CHL' & GRAD_TRANSFORM = 1 & END
          'GRAD_SSTKM': BEGIN & GPRD = 'SSTKM' & GRAD_TRANSFORM = 0 & END
          'GRAD_CHLKM': BEGIN & GPRD = 'CHLKM' & GRAD_TRANSFORM = 1 & END
        ENDCASE
        XGPRD = 'GRADX_'+GPRD
        YGPRD = 'GRADY_'+GPRD
        XDATA = D.(WHERE(TAG_NAMES(D) EQ XGPRD,/NULL)) & IF XDATA EQ [] THEN MESSAGE, 'ERROR: ' + XGRPD + ' not found in ' + INFILE
        YDATA = D.(WHERE(TAG_NAMES(D) EQ YGPRD,/NULL)) & IF YDATA EQ [] THEN MESSAGE, 'ERROR: '  + YGRPD + ' not found in ' + INFILE
        AZTAG = WHERE(TAG_NAMES(D) EQ 'AZIMUTH',/NULL)
        IF AZTAG EQ [] THEN BEGIN
          AREA = MAPS_PIXAREA(AMAP,AZIMUTH=AZIMUTH)
          AZIMUTH = AZIMUTH[0,BINS-1]
        ENDIF ELSE AZIMUTH = D.(AZTAG)  
        INDATA = XDATA
      ENDIF ELSE BEGIN
        GRAD_STATS = 0
        CASE 1 OF 
          STRUCT_PROD EQ 'PSC_NANOPICO' AND FP[0].PERIOD_CODE EQ 'DD': BEGIN
            OKN = WHERE(TAG_NAMES(D) EQ 'PSC_NANO',COUNTN)
            OKP = WHERE(TAG_NAMES(D) EQ 'PSC_PICO',COUNTP)
            IF COUNTN NE 1 AND COUNTP NE 1 THEN MESSAGE, 'ERROR: Unable to find PSC_NANO and PSC_PICO to calculate stats for PSC_NANOPICO'
            IF SIZE(D.(OKN),/N_ELEMENTS) NE SIZE(D.(OKP),/N_ELEMENTS) THEN MESSAGE, 'ERROR: The number of elements in PSC_NANO do not match PSC_PICO'
            INDATA = D.(OKN) + D.(OKP)
          END  
          STRUCT_PROD EQ 'PSC_FNANOPICO' AND FP[0].PERIOD_CODE EQ 'DD': BEGIN
            OKC = WHERE(TAG_NAMES(D) EQ 'CHLOR_A',COUNTC)
            OKN = WHERE(TAG_NAMES(D) EQ 'PSC_NANO',COUNTN)
            OKP = WHERE(TAG_NAMES(D) EQ 'PSC_PICO',COUNTP)
            IF COUNTN NE 1 AND COUNTP NE 1  AND COUNTC NE 1 THEN MESSAGE, 'ERROR: Unable to find CHLOR_A, PSC_NANO and PSC_PICO to calculate stats for PSC_FNANOPICO'
            IF SIZE(D.(OKN),/N_ELEMENTS) NE SIZE(D.(OKP),/N_ELEMENTS) OR SIZE(D.(OKC),/N_ELEMENTS) NE SIZE(D.(OKP),/N_ELEMENTS) THEN MESSAGE, 'ERROR: The number of elements in PSC_NANO do not match PSC_PICO'
            INDATA = (D.(OKN) + D.(OKP))/D.(OKC)
          END
          STRMID(STRUCT_PROD,0,5) EQ 'PSC_F' AND STRUCT_PROD NE 'PSC_FNANOPICO' AND FP[0].PERIOD_CODE EQ 'DD': BEGIN
             OKC = WHERE(TAG_NAMES(D) EQ 'CHLOR_A',COUNTC)
             OKP = WHERE(TAG_NAMES(D) EQ 'PSC_' + STRMID(STRUCT_PROD,5),COUNTP)
             IF COUNTC NE 1 AND COUNTP NE 1 THEN MESSAGE, 'ERROR: Unable to find PSC_FNANO and PSC_FPICO to calculate stats for PSC_FNANOPICO'
             IF SIZE(D.(OKC),/N_ELEMENTS) NE SIZE(D.(OKP),/N_ELEMENTS) THEN MESSAGE, 'ERROR: The number of elements in CHLOR_A do not match PSC_' + STRMID(STRUCT_PROD,5)
             INDATA = D.(OKP)/D.(OKC)
            END
          ELSE: BEGIN
            OK = WHERE(TAG_NAMES(D) EQ STRUCT_PROD, COUNT)                                                                       ; Find the matching input product tag in the data structure
            IF COUNT NE 1 THEN MESSAGE, 'ERROR: ' + STRUCT_PROD + ' not found in ' + INPRODS                                         ; Check to make sure the STAT_PROD matches one of the input file products
            INDATA = D.(OK)                                                                                                                                               ; Extract the data
          END    
        ENDCASE
      ENDELSE
      GONE, D
        
      ; ===> Add data from additional files to the original input file
      FOR S=1, N_ELEMENTS(INFILES)-1 DO BEGIN
        SD = STACKED_READ(INFILES[S],KEYS=SKEYS,BINS=SBINS,DB=SDB,METADATA=SMETA,INFO=SINFO,PRODS=SINPRODS)                    ; Read the "second" input stacked file
        
        CASE 1 OF
          STRUCT_PROD EQ 'PSC_NANOPICO' AND FP[0].PERIOD_CODE EQ 'DD': BEGIN
            OKN = WHERE(TAG_NAMES(SD) EQ 'PSC_NANO',COUNTN)
            OKP = WHERE(TAG_NAMES(SD) EQ 'PSC_PICO',COUNTP)
            SINDATA = SD.(OKN) + SD.(OKP)
          END
          STRUCT_PROD EQ 'PSC_FNANOPICO' AND FP[0].PERIOD_CODE EQ 'DD': BEGIN
            OKC = WHERE(TAG_NAMES(SD) EQ 'CHLOR_A',COUNTC)
            OKN = WHERE(TAG_NAMES(SD) EQ 'PSC_NANO',COUNTN)
            OKP = WHERE(TAG_NAMES(SD) EQ 'PSC_PICO',COUNTP)
            SINDATA = (SD.(OKN) + SD.(OKP))/SD.(OKC)
          END
          STRMID(STRUCT_PROD,0,5) EQ 'PSC_F' AND STRUCT_PROD NE 'PSC_FNANOPICO' AND FP[0].PERIOD_CODE EQ 'DD': BEGIN
            OKC = WHERE(TAG_NAMES(SD) EQ 'CHLOR_A',COUNTC)
            OKP = WHERE(TAG_NAMES(SD) EQ 'PSC_' + STRMID(STRUCT_PROD,5),COUNTP)
            SINDATA = SD.(OKP)/SD.(OKC)
          END
          ELSE: BEGIN
            OK = WHERE(TAG_NAMES(SD) EQ STRUCT_PROD, COUNT)                                                                       ; Find the matching input product tag in the data structure
            IF COUNT NE 1 THEN MESSAGE, 'ERROR: ' + STRUCT_PROD + ' not found in ' + INPRODS                                         ; Check to make sure the STAT_PROD matches one of the input file products
            SINDATA = SD.(OK)                                                                                                                                               ; Extract the data
          END
        ENDCASE
        GONE,SD
            
        SZ = SIZE(INDATA,/DIMENSIONS)                                                                                          ; Get the dimensions of the initial data
        SZS = SIZE(SINDATA,/DIMENSIONS)                                                                                        ; Get the dimenions of the secondary data
        IF N_ELEMENTS(SZ) NE N_ELEMENTS(SZS) OR SZ[0] NE SZS[0] OR SZ[1] NE SZS[1] THEN MESSAGE, 'ERROR: The dimensions of the data do not match' ; Check that the dimensions are the same
        OKDATES = WHERE(PERIOD_2JD(SDB.PERIOD) GE DATE_2JD(PDATERANGE[0]) AND PERIOD_2JD(SDB.PERIOD) LE DATE_2JD(PDATERANGE[1]),COUNT) ; Find the periods within the daterange
        IF COUNT EQ 0 THEN MESSAGE, 'ERROR: Data within the daterange ' + STRJOIN(PDATERANGE,'-') + ' were not found'          ; Check that the periods were found within the daterange
        
        ; ===> Merge the data from the primary and secondary files
        CASE N_ELEMENTS(SZ) OF                                                                                                 ; Get the dimensions for the new array
          2: BEGIN & XX = 0 & YY = SZ[0] & ZZ = SZ[1]+COUNT & END                                                              ; Array sizes based on 2 dimensions 
          3: BEGIN & XX = SZ[0] & YY = SZ[1] & ZZ = SZ[2]+COUNT & END                                                          ; Array sizes based on 3 dimensions
        ENDCASE
        NEWARR = FLTARR(XX,YY,ZZ)                                                                                              ; Make a new blank array
        NEWARR[*,*,0:SZ[-1]-1] = INDATA                                                                                        ; Add the data from the primary file
        NEWARR[*,*,SZ[-1]:*] = SINDATA[*,*,OKDATES]                                                                            ; Add the data from the secondary file
        INDATA = NEWARR & NEWARR = []                                                                                          ; Rename the merged data and remove the temporary array
        
        DB = [DB,SDB]
        DB = DB[SORT(PERIOD_2JD(DB.PERIOD))]
        DB.SEQ = INDGEN(N_ELEMENTS(DB)) 
;        DBTAGS = TAG_NAMES(DB) & SDBTAGS = TAG_NAMES(SDB)                                                                      ; Get the DB tag names
;        NEWDB = []                                                                                                             ; Create a new NULL DB 
;        FOR DD=0, N_TAGS(DB)-1 DO BEGIN                                                                                        ; Loop through DB tags
;          IF SDBTAGS[DD] NE DBTAGS[DD] THEN MESSAGE, 'ERROR: Database tag names do not match'                                  ; Check that the DB tags match
;          NEWDB = CREATE_STRUCT(NEWDB,DBTAGS[DD],[DB.(DD),SDB.(DD)[OKDATES]])                                                  ; Create a new structure with the merged DB info
;        ENDFOR
;        NEWDB.SEQ = INDGEN(N_ELEMENTS(NEWDB.SEQ))                                                                              ; Update the SEQ values
;        DB = NEWDB & NEWDB = []                                                                                                ; Rename the merged DB and remove the temporary structure
      ENDFOR     
      IF STRUCT_HAS(DB,'STATFILE') THEN DB = STRUCT_RENAME(DB,['STATFILE','STATNAME'],['FULLNAME','NAME']);,/STRUCT_ARRAYS)                                        ; If the input files are "stats" rename the tags in the DB (to avoid errors looking for specific tags)
      IF CLIM_DATERANGE NE [] AND KEYWORD_SET(PEROUTCLIM) THEN JD_START = DATE_2JD(CLIM_DATERANGE[0]) ELSE JD_START = []
      IF CLIM_DATERANGE NE [] AND KEYWORD_SET(PEROUTCLIM) THEN JD_END = DATE_2JD(CLIM_DATERANGE[1]) ELSE JD_END = []
      DPSET = PERIOD_SETS(PERIOD_2JD(DB.PERIOD),PERIOD_CODE=PEROUT,/NESTED, JD_START=JD_START, JD_END=JD_END)                   ; Group the input data into appropriate periods

      ; ===> Get the dimensions of the image 
      SZ = SIZE(INDATA) 
      DIMS = SZ[0]
      CASE DIMS OF                                                                                                             ; Determine the image demsions
        2: BEGIN & BX = 0 & BY = SZ[1] & END 
        3: BEGIN & BX = SZ[1] & BY = SZ[2] & END
      ENDCASE ; DIMS
      IF BX NE PX OR BY NE PY THEN MESSAGE, 'ERROR: The map dimensions do not match the image dimensions'                      ; Check that the dimensions match
      
      ; ===> Create or read the HASH obj
      IF STATHASH EQ [] THEN BEGIN
        IF ~FILE_TEST(STAT_FILE) THEN BEGIN
          STATHASH = D3HASH_MAKE(STAT_FILE, INPUT_FILES=FILES, BINS=MOBINS, PRODS=STAT_PROD, PX=BX, PY=BY, STAT_TYPES=STATTYPES, ANOM_TYPES=ANOM_TYPES, DO_STATS=DO_STATS, DO_ANOMS=DO_ANOMS) 
          
          ; ===> Add GRAD_MAG specific stats to the output STATHASH
          IF KEYWORD_SET(GRAD_STATS) THEN BEGIN
            D3 = STATHASH[STAT_PROD+'_'+STATTYPES[0]]
            STATHASH[STAT_PROD] = D3
            STATHASH[XGPRD] = D3 
            STATHASH[YGPRD] = D3
            STATHASH['GRAD'+GPRD+'_DIR'] = D3  
            STATHASH[STAT_PROD +'_VAR'] = D3
            STATHASH['AZIMUTH'] = AZIMUTH
          ENDIF        
        ENDIF ELSE STATHASH = IDL_RESTORE(STAT_FILE)    ; Read the D3HASH file if it already exists and extract the D3 dabase
      ENDIF
            
      IF IDLTYPE(STATHASH) NE 'OBJREF' THEN MESSAGE, 'ERROR: Unable to properly create or read the HASH obj'                                                ; Read the existing D3 file
      DBSTAT = STATHASH['FILE_DB'].TOSTRUCT()
      D3_KEYS = STATHASH.KEYS() & D3_KEYS = D3_KEYS.TOARRAY()                                                                  ; Get the D3HASH key names and convert the LIST to an array
      D3_STATS = REMOVE(D3_KEYS,VALUES=['FILE_DB','PRODS','BINS','INFO','METADATA'])                                           ; Keep just the D3 variable names
      DBCHECK = D3HASH_DB(STAT_FILE,/ADD_INFILES,/ADD_ORIGINAL)                                                                ; Recreate the stat database to update the current DBSTAT if needed
      DBCHECK = STRUCT_RENAME(DBCHECK, ['FULLNAME','NAME'],['STATFILE','STATNAME'])
    
      ; ===> Run stats on the input files and add them to the STATHASH file
      WRITEFILE = 0
      FOR NTH=0, N_ELEMENTS(PER_SET)-1 DO BEGIN                                                                                ; Loop through the output periods
        OPER = PER_SET[NTH]
        APER = OPER.PERIOD                                                                                                     ; Get the period
        ASTR = PERIOD_2STRUCT(OPER.PERIOD)                                                                                     ; Get information about the period
        DRANGE = STRJOIN(STRMID([ASTR.DATE_START,ASTR.DATE_END],0,8),'_')                                                      ; Get the daterange for the period
        SEQ = WHERE(STATHASH['FILE_DB','PERIOD'] EQ APER,COUNT)                                                                ; Find the period in the DB database
        IF COUNT NE 1 THEN BEGIN                                                                                               ; Check that the period is in the DB database
          CASE 1 OF
            PEROUT EQ 'DOY' OR PEROUT EQ 'WEEK' OR PEROUT EQ 'MONTH': BEGIN
              SEQ = WHERE(DBCHECK.PERIOD EQ APER,COUNT)                                                                        ; Find the period in the DB database
              IF COUNT EQ 0 THEN MESSAGE, 'ERROR: ' + APER + ' not found in the database.'
            END 
            ELSE:  MESSAGE, 'ERROR: ' + APER + ' not found in the DB database.'
          ENDCASE
        ENDIF  
               
        ; ===> Get the subscripts for the period and list of original input files
        OKPER = WHERE(TAG_NAMES(DPSET) EQ APER[0],/NULL)                                                                          ; Find the period in DPSET
        IF OKPER EQ [] THEN CONTINUE                                                                                           ; Skip if the period is not found
        SUBS = DPSET.(OKPER)                                                                                                   ; Get the subscripts for the period
        SUBS = SUBS[WHERE(DB[SUBS].MTIME GT 0,/NULL)]                                                                          ; Remove subscripts if the MTIME is 0 (i.e. there is no data in the file)
        IF SUBS EQ [] THEN CONTINUE                                                                                            ; Skip if no valid data found

        ; ===> Set up some period specific subscripts to make sure the  
        SKIP_STAT = 0 & SKIP_FILE = 0
        CASE PEROUT OF 
          'A': IF N_ELEMENTS(SUBS) NE 12 THEN SKIP_STAT = 1  
          ELSE: SKIP_STAT = 0
        ENDCASE
        IF KEYWORD_SET(SKIP_STAT) THEN CONTINUE                                                                                ; Skip adding the STAT for this period if incomplete
        IF KEYWORD_SET(SKIP_FILE) THEN GOTO, DONE                                                                              ; If the file does not need to be recreated, goto the end
        
        IF SZ[0] EQ 2 THEN DSET = TEMPORARY(INDATA[*,SUBS]) ELSE DSET = TEMPORARY(INDATA[*,*,SUBS])                                                  ; Get the data based on the subscripts
        IF XDATA NE [] THEN IF SZ[0] EQ 2 THEN XSET = XDATA[*,SUBS] ELSE XSET = XDATA[*,*,SUBS] ELSE XSET = []
        IF YDATA NE [] THEN IF SZ[0] EQ 2 THEN YSET = YDATA[*,SUBS] ELSE YSET = YDATA[*,*,SUBS] ELSE YSET = []
                
        DSZ = SIZE(DSET,/DIMENSIONS)                                                                                         ; Get the dimensions of the input data
        IF N_ELEMENTS(DSZ) NE DIMS THEN DMS = 1 ELSE DMS = DIMS                                                              ; If only a 2D array (e.g. 1 x 34123 and not 1 x 34123 x 8) then change the DIMS input into the stats
        
        ORGFILES = DB[SUBS].NAME & ORGFILES = ORGFILES[WHERE(ORGFILES NE '',/NULL)]                                            ; Get the names of the original input files
        IF ORGFILES EQ [] THEN CONTINUE                                                                                        ; If no files were found, continue
        ORGFILES = ORGFILES[UNIQ(ORGFILES,SORT(ORGFILES))]                                                                     ; Remove redundant files
        IF FILE_TEST(STAT_FILE) AND STATHASH['FILE_DB','MTIME',SEQ] GE MAX(GET_MTIME(DB[SUBS].FULLNAME)) THEN BEGIN                                     ; Check the MTIMES in the file DB
          IF NTH NE N_ELEMENTS(PER_SET)-1 THEN CONTINUE                                                                        ; Skip if the data is already in the database and does not need to be updated
          IF FILE_MAKE(INFILES,STAT_FILE,OVERWRITE=OVERWRITE) THEN WRITEFILE = 1                                               ; The input file MTIME could be more recent than the output file (common when the input files span multiple years) so the output file should be resaved to update the MTIME
          GOTO, WRITE_FILE                                                                                                     ; Jump to the WRITE_FILE section
        ENDIF  
        WRITEFILE = 1                                                                                                          ; If data are updated, then set so that the file will be written
        PLUN, LUN, 'Calculating stats for ' + APER, 0
        
        ; ===> Add the file information to the D3 database in the D3HASH
        STATHASH['FILE_DB','MTIME',SEQ] = DATE_NOW(/MTIME,/GMT)                                                                     ; Add the file MTIME to the D3 database
        STATHASH['FILE_DB','STATFILE',SEQ] = STAT_FILE                                                                         ; Add the full file name to the D3 database
        STATHASH['FILE_DB','STATNAME',SEQ] = (FILE_PARSE(STAT_FILE)).NAME_EXT                                                  ; Add the file "name" to the D3 database
        STATHASH['FILE_DB','DATE_RANGE',SEQ] = DRANGE                                                                          ; Add the "daterange" to the D3 database
        STATHASH['FILE_DB','INPUT_FILES',SEQ] = OPER.FILENAME                                                                  ; Add the "input" files to the D3 database 
        STATHASH['FILE_DB','ORIGINAL_FILES',SEQ] = STRJOIN(ORGFILES,';')                                                       ; Concatenate the "original" input files and add to the DB structure
    
        ; ===> If input is GRAD_MAG then calculate the GRAD_MAG MEAN and DIR
        IF KEYWORD_SET(GRAD_STATS) THEN BEGIN
          PZ = N_ELEMENTS(SUBS)
          
          ; ===> Look for the number of "valid" GRAD_MAG pixels that exceed the threshold
          NVALID = INTARR(PX,PY) & NVALID[*] = 0.0
          FOR Z=0, PZ-1 DO NVALID = NVALID + FINITE(DSET[*,*,Z])

          IF KEYWORD_SET(GRAD_TRANSFORM) THEN GRAD_X = MEAN(ALOG(XSET),DIMENSION=DMS,/NAN) ELSE GRAD_X = MEAN(XSET,DIMENSION=DMS,/NAN)
          IF KEYWORD_SET(GRAD_TRANSFORM) THEN GRAD_Y = MEAN(ALOG(YSET),DIMENSION=DMS,/NAN) ELSE GRAD_Y = MEAN(YSET,DIMENSION=DMS,/NAN)

          GRAD_MAG = SQRT(GRAD_X^2 + GRAD_Y^2) ; Calculate GRAD_MAG mean
          GRAD_DIR = ATAN(INFINITY_2NAN(GRAD_Y), INFINITY_2NAN(GRAD_X)) ; Calculate mean GRAD_DIR
          GRAD_DIR = (GRAD_DIR)*!RADEG ; Change radians to degrees
          OK = WHERE(GRAD_DIR LT 0,COUNT) ; Find where GRAD_DIR is negative
          IF COUNT GE 1 THEN GRAD_DIR[OK] = 360 - ABS(GRAD_DIR[OK]) ; Adjust to 0-360 degrees scheme (i.e. make negative degrees positive)
          GRAD_DIR = GRAD_DIR - AZIMUTH ; Correct GRAD_DIR for the azimuth angle         
         
          ; ===> Calculate the Variance
          XSSQ = XSET & YSSQ = XSET & GRAD_VAR = FLTARR(PX,PY) & GRAD_VAR[*] = MISSINGS(GRAD_VAR)
          FOR Z=0, PZ-1 DO BEGIN
            XSSQ[*,*,Z] = (XSET[*,*,Z]-GRAD_X)^2 
            YSSQ[*,*,Z] = (YSET[*,*,Z]-GRAD_Y)^2
          ENDFOR
          XSSQ = TOTAL(XSSQ,DMS,/NAN)
          YSSQ = TOTAL(YSSQ,DMS,/NAN)  
            
          OK_GOOD = WHERE(NVALID GT 0, COUNTGOOD, COMPLEMENT=GRADMISS, NCOMPLEMENT=COUNTMISS) & IF COUNTGOOD EQ 0 THEN STOP ; NEED TO FIGURE OUT WHAT TO DO IF ALL INPUT DATA ARE MISSING
          GRAD_VAR[OK_GOOD] = (XSSQ[OK_GOOD] + YSSQ[OK_GOOD])/NVALID[OK_GOOD]

          ; ===> Untransform the gradient data if the input is GRAD_CHL
          IF KEYWORD_SET(GRAD_TRANSFORM) THEN BEGIN
            GRAD_X = EXP(GRAD_X)
            GRAD_Y = EXP(GRAD_Y)
            GRAD_MAG = EXP(GRAD_MAG)
            GRAD_VAR = EXP(GRAD_VAR)
          ENDIF

          ; ===> Make any input missing subscripts missing in the output data
          IF COUNTMISS GT 0 THEN BEGIN
            GRAD_MAG[GRADMISS] = MISSINGS(GRAD_MAG)
            GRAD_X[GRADMISS]   = MISSINGS(GRAD_X)
            GRAD_Y[GRADMISS]   = MISSINGS(GRAD_Y)
            GRAD_DIR[GRADMISS] = MISSINGS(GRAD_DIR)
            GRAD_VAR[GRADMISS] = MISSINGS(GRAD_VAR)
          ENDIF  

          ; ===> Add the GRAD stats to the STATHASH
          STATHASH[STAT_PROD,*,*,SEQ] = GRAD_MAG
          STATHASH[XGPRD,*,*,SEQ] = GRAD_X
          STATHASH[YGPRD,*,*,SEQ] = GRAD_Y
          STATHASH['GRAD'+GPRD+'_DIR',*,*,SEQ] = GRAD_DIR
          STATHASH[STAT_PROD + '_VAR',*,*,SEQ] = GRAD_VAR
          STATTYPES = REMOVE(STATTYPES,VALUES=['SPAN','SUM','MED','MEAN','VAR','STD','CV','SKEW','KURT','GMEAN'])           ; Remove other stat types in case they were mistakenly included in the stats list
        ENDIF ; GRAD_STATS
        
        
        ; ===> Loop through the STATTYPES and add to the STATHASH
        MINDATA = [] & MAXDATA = [] & NUMDATA = [] & SUMDATA = [] & MEANDATA = [] & STDATA = []                                ; Set up null arrays for the min, max, num and sum data
        FOR DS=0, N_ELEMENTS(STATTYPES)-1 DO BEGIN
          ASTAT = STATTYPES[DS]                                                                                               ; Get the name of the "stat"
          D3STAT = D3_STATS[DS]                                                                                                ; Get the name of the product stat
          IF ~HAS(D3STAT,ASTAT) THEN MESSAGE, 'ERROR: Check that the stat type matches the HASHSTAT key'                       ; Make sure the stat names align
          
          IF N_ELEMENTS(DSZ) EQ 2 THEN SDATA = FLTARR(DSZ[1]) ELSE SDATA = FLTARR(DSZ[0],DSZ[1])                               ; Create the output data array
          SDATA[*] = MISSINGS(SDATA)                                                                                           ; Make the output data array "missings"
          
          ; ===> Calculate specific stats
          CASE ASTAT OF ;'NUM','MIN','MAX','SPAN','SUM','MED','MEAN','VAR','STD','CV','SKEW','KURT','GMEAN'
            'NUM': BEGIN
              IF N_ELEMENTS(DSZ) EQ 2 THEN SDATA = INTARR(DSZ[1]) ELSE SDATA = INTARR(DSZ[0],DSZ[1])                           ; Create a output integer array for the NUM variable 
              IF N_ELEMENTS(DSZ) EQ 2 THEN SDATA=SDATA+ FINITE(DSET) ELSE FOR Z=0, DSZ[-1]-1 DO SDATA=SDATA+FINITE(DSET[*,*,Z]); Loop through each input period and count the "number" of valid pixels
              NUMDATA = SDATA             
            END
            'MIN':   BEGIN & SDATA = MIN(DSET,DIMENSION=DMS,/NAN) & MINDATA = SDATA & END                                      ; Determine the "minimum" value in the array
            'MAX':   BEGIN & SDATA = MAX(DSET,DIMENSION=DMS,/NAN) & MAXDATA = SDATA & END                                      ; Determine the "maximum" value in the array
            'SPAN':  BEGIN
              OKSPAN = WHERE(MINDATA NE MISSINGS(MINDATA) AND MAXDATA NE MISSINGS(MAXDATA),COUNT)                              ; Find the "valid" data in the array
              IF COUNT GT 0 THEN SDATA[OKSPAN] = ABS(MAXDATA[OKSPAN]-MINDATA[OKSPAN])                                          ; Determine the "span" of data values in the array
            END
            'SUM':   BEGIN & SDATA = TOTAL(DSET,DMS,/NAN) & SUMDATA = SDATA & END                                              ; Calculate the "total" sum of the data values in the array
            'MED':   SDATA = MEDIAN(MISSING_2NAN(DSET),DIMENSION=DMS)                                                          ; Calculate the "median" of the data values in the array
            'MEAN':  SDATA = MEAN(DSET,DIMENSION=DMS,/NAN)                                                                     ; Calculate the "mean" of the data values in the array
            'VAR':   SDATA = VARIANCE(DSET,DIMENSION=DMS,/NAN)                                                                 ; Calculate the "variance" of the data values in the array
            'STD':   SDATA = STDDEV(DSET,DIMENSION=DMS,/NAN)                                                                   ; Calculate the "standard deviation" of the data values in the array
            'CV':    SDATA = 100.0*STDDEV(DSET,DIMENSION=DMS,/NAN)/MEAN(DSET,DIMENSION=DMS,/NAN)                               ; Calculate the "coefficient of variation" of the data values in the array
            'SKEW':  SDATA = SKEWNESS(DSET,DIMENSION=DMS,/NAN)                                                                 ; Calculate the "skewness" of the data values in the array
            'KURT':  SDATA = KURTOSIS(DSET,DIMENSION=DMS,/NAN)                                                                 ; Calculate the "kurtosis" of the data values in the array
            'GMEAN': SDATA = GMEAN(DSET,DIMENSION=DMS)                                                                         ; Calculate the "geometric mean" of the data values in the array
          ENDCASE ; ASTAT
          
          SDSZ = SIZE(SDATA,/DIMENSIONS)                                                                                         ; Get the dimensions of the output array
          IF N_ELEMENTS(SDSZ) EQ 2 THEN IF SDSZ[0] NE BX OR SDSZ[1] NE BY THEN MESSAGE, 'ERROR: Output data dimensions do not match expected dimensions (' + NUM2STR(BX) + ' x ' + NUM2STR(BY) + ')'
          IF N_ELEMENTS(SDSZ) EQ 1 THEN IF SDSZ[0] NE BY THEN MESSAGE, 'ERROR: Output data dimensions do not match expected dimensions (' + NUM2STR(BX) + ' x ' + NUM2STR(BY) + ')'
            
          SDATA[WHERE(FINITE(SDATA) EQ 0)] = MISSINGS(SDATA)                                                                     ; Make sure any NaN are turned into "missings"
          STATHASH[D3STAT,*,*,SEQ] = SDATA                                                                                       ; Add the output stat array to the hash
        ENDFOR ; STATTYPES
      ENDFOR ; PER_SET
      
      ; ===> Update the metadata and file information
      STATHASH['METADATA'] = D3HASH_METADATA(STAT_FILE, DB=STATHASH['FILE_DB']);, STAT_TYPES=STAT_TYPES)                       ; Add the metadata for the file to the hash                                                                                                 ; Change the DATATYPE to stat
      ; ===> Save the STATHASH file
      WRITE_FILE:
      IF KEYWORD_SET(WRITEFILE) AND ~KEYWORD_SET(KEEP_COMMON) THEN BEGIN                                                       ; Only need to save the file if new data were added
        PLUN, LUN, 'Writing ' + STAT_FILE
        SAVE, STATHASH, FILENAME=STAT_FILE, /COMPRESS                                                                          ; Save the file
        STATHASH = []                                                                                                          ; Remove the STATHASH to clear up memory
      ENDIF
      DONE:
            
    ENDFOR ; OUTPERS
    IF ~KEYWORD_SET(KEEP_COMMON) THEN STATHASH = []
  ENDFOR ; PERIOD_OUT
  STATTYPES = []

END ; ***************** End of D3HASH_2STATS *****************
