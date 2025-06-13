; $ID:	SAVE_MAKE_FRONTS.PRO,	2023-09-21-13,	USER-KJWH	$
;############################################################################
  PRO SAVE_MAKE_FRONTS, FILES, FRONTS_ALG=FRONTS_ALG, DIR_OUT=DIR_OUT, DIR_AREAS=DIR_AREAS, PROD=PROD, FLAG_BITS_CHL=FLAG_BITS_CHL, FLAG_BITS_SST=FLAG_BITS_SST, FULL_STRUCT=FULL_STRUCT, $
                        MAP_OUT=MAP_OUT, MAP_SUBSET=MAP_SUBSET, SUBSET_LONS=SUBSET_LONS, SUBSET_LATS=SUBSET_LATS, THUMBNAILS=THUMBNAILS, OVERWRITE=OVERWRITE, VERBOSE=VERBOSE, LOGLUN=LOGLUN
;
; NAME:
;   SAVE_MAKE_FRONTS 
;
; PURPOSE:
;   This procedure runs the fronts_boa program for chlorophyll and sst files and creates an output .SAV file
;
; CATEGORY:
;    FILE_FUNCTIONS
;
; CALLING SEQUENCE:
;   SAVE_MAKE_FRONTS, FILES
;
; REQUIRED INPUTS:
;   FILES........... The full path and file names of the input data
;
; OPTIONAL INPUTS:
;   FRONTS_ALG...... Fronts algorithm (currently only BOA is available, but additional algorithms can easily be added)
;   DIR_OUT......... Directory for writing output files           
;   DIR_AREAS....... Directory for the Level 2 'LONLAT' area files
;   PROD............ The product name from the input files that is used to set up the processing defauls of BOA
;   FLAG_BITS_CHL... CHL flag bits when working with the Level 2 CHL files
;   FLAG_BITS_SST... SST flag bits when working with the Level 2 SST files
;   MAP_OUT......... Map for the output files
;   MAP_SUBSET...... Name of a map to use to SUBSET the input data (for MUR, AVHRR, and L3B files)
;   SUBSET_LONS.....
;   SUBSET_LATS.....
;   LOGLUN.......... Lun for writing information to the LOG file
;
; KEYWORDS:
;   FULL_STRUCT..... Option to save the full structure from FRONTS_BOA. If not set, only the GRAD_CHL/SST, GRAD_X, GRAD_Y and GRAD_DIR products will be saved 
;   THUMBNAILS......
;   OVERWRITE....... Overwrite the output file if it already exists
;   VERBOSE......... Print out commands
;
; OUTPUTS:
;   A compressed .SAV file of the FRONTS_BOA structure containing floating point arrays for:
;     GRAD_MAG (gradient magnitude)
;     GRAD_X (gradient in horizontal direction) 
;     GRAD_Y (gradient in vertical direction) 
;     GRAD_DIR (gradient direction, in degrees)
;     FILTERED_PIXELS (pixels removed by mf3_1d_5pt)
;                                                            
; OPTIONAL OUTPUS:
;  The full FRONTS_BOA structure  
;       
; COMMON BLOCKS:
;   None
;
; SIDE EFFECTS:
;   None
;       
; RESTRICTIONS:
;   The gradient direction (GRAD_DIR) is relative to the image array (the map projection is used to make the image) and is not always true north
;    
; REFERENCE:
;   Belkin IM, O'Reilly JE (2009) An algorithm for oceanic front detection in chlorophyll and SST satellite imagery. 
;     Journal of Marine Systems 78: 319-326 doi doi: 10.1016/j.jmarsys.2008.11.018
;   
; PROCEDURE:
;   Files must be provided
;   If the output directory (DIR_OUT) does not exist, the program will create it. 
;           FOR CHLOROPHYLL (CHLOR_A) AND OTHER LOG-NORMALLY DISTRIBUTED DATA THE ARRAYS IN THE INPUT FILES MUST BE LOG-TRANSFORMED USING THE NATURAL LOG FUNCTION(ALOG), BEFORE RUNNING BOA!
;           THIS ROUTINE USES IDL'S CONVOL CONVOLUTION ROUTINE FOR ALL EDGE DETECTORS.
;           THE KERNAL IS CENTERED OVER EACH ARRAY ELEMENT.
;           ARRAY ELEMENTS THAT ARE NOT FINITE OR ARE NAN ARE TREATED AS MISSING DATA (NAN BY CONVOL).
;           THE SPECIAL MEDIAN FILTERING PROGRAM ( MF3_1D_5PT ) IS USED TO ELIMINATE NOISY DATA.
;           
;   
;
; EXAMPLES:
; 
; COPYRIGHT:
; Copyright (C) 2007, Department of Commerce, National Oceanic and Atmospheric Administration, National Marine Fisheries Service,
;   Northeast Fisheries Science Center, Narragansett Laboratory.
;   This software may be used, copied, or redistributed as long as it is not sold and this copyright notice is reproduced on each copy made.
;   This routine is provided AS IS without any express or implied warranties whatsoever.
;
; AUTHOR:
;   This program was written on January 17, 2007 by John E. O'Reilly, Northeast Fisheries Science Center | NOAA Fisheries | U.S. Department of Commerce, 28 Tarzwell Dr, Narragansett, RI 02882
;   Inquires can be directed to kimberly.hyde@noaa.gov
;
; MODIFICATION HISTORY: 
;   AUG 25, 2007 - TD:   FIXED GRAD_DIR, IT WAS OFF BY 180 DEGREES GRAD_DIR=(GRAD_DIR + 180) MOD 360
;   JUN 10, 2008 - KJWH: SIMPLIFIED PROGRAM FOR OPERATIONAL USE
;   APR 29, 2008 - TD:   CONSTRUCT OUTPUT FILE NAME FROM INPUT FILE NAME,CHECK IF OUTPUT ALREADY EXISTS
;   NOV 04, 2010 - JEOR: REVIEWED,ADDED MORE DOCUMENTATION, MINOR MODIFICATIONS( DELETED SUPERFLUOUS LINES ),
;                        ADDED EXAMPLES AND REFERENCE AND TESTED THE PROGRAM.
;   JAN 20, 2011 - IGOR M BELKIN, JIANYU HU AND FAN ZHANG: ADDED CODE TO ADJUST GRADIENT MAGNITUDE FOR DISTANCE (AVERAGE PIXEL SIZE)
;   JAN 22, 2011 - JEOR and IMB: ADDED KEYWORD KM TO ACCEPT AVERAGE SIZE OF PIXEL IN INPUT IMAGE ARRAY
;                         KM IS USED TO CORRECT GRADIENT MAGNITUDE FOR THE DISTANCE BETWEEN PIXELS
;                         REMOVED CODE WHICH SMOOTHS (GAUSSIAN) IMAGE ARRAY BEFORE EDGE DETECTION BECAUSE THE SMOOTHING WAS CREATING ARTIFACTS ALONG COASTLINES.
;                         ALSO REMOVED CREATION OF SMOOTHED PNG AND FLT OUTPUT
;   JUL 18, 2011 - JEOR and IMB: NOW WE REINITIALIZE THE DEFINITION OF THE PRIMARY RAINBOW COLOR PALETTE (PAL_SW3,R,G,B) FOR EACH FILE IN THE LOOP TO BE PROCESSED.
;   MAR 14, 2012 - JEOR: ADDED PFILE AND POF; UPPERCASE
;   MAR 29, 2012 - JEOR and IMB: MAJOR OVERHAUL OF PROGRAM
;                         MODIFIED TO INPUT HDF IMAGE ARRAYS OR 
;                         ARRAYS MADE USING IDL SAVE PROCEDURE AS INPUT[ NO LONGER FLOAT .FLT AS INPUT ]
;                         ASSUMES THAT IDL ARRAY SAVE FILES HAVE AN '.SAVE' EXTENSION AND ARE A STRUCTURE WHERE THE TAG 'IMAGE' IS THE IMAGE DATA ARRAY
;                         IF STRPOS(FN.EXT,'HDF') NE -1 THEN S = READHDF(FILE)[USES READHDF.PRO TO READ HDF FILES]
;                         IF FN.EXT EQ 'SAVE' THEN S = IDL_RESTORE(FILE)[ USES IDL'S RESTORE TO READ SAVE FILES]
;                         ! NO LONGER ASSUMES THAT INPUT FILES CONTAIN CHLOR_A OR SST DATA
;                         ADDED KEYWORD PROD TO CONTROL PROGRAM PARAMETERS
;                         NOW USES FILE_PARSE TO PARSE FILE NAME ELEMENTS 
;                         OUTPUT FILES ARE NOW IDL COMPRESSED SAVE FILES
;                         PROD IS ADDED TO THE OUTPUT NAMES OF THE SAVE FILES
;                         ELIMINATED KEYWORD DIR_IN
;   APR 01, 2012 - JEOR and IMB: FIXED NAMES OF OUTPUT FILES
;                        ADJUSTED  BACKGROUND COLOR FOR PNG IMAGES
;   APR 02, 2012 - IMB:  ADDED MEDIAN FILTER (ESTIMATOR_FILTER)                                                  
;   NOV 10, 2015 - KJWH: UPDATED WITH NEW CODE AND TO BE CONSISTENT WITH OTHER 'SAVE_MAKE_' PROGRAMS      
;                        ADDED DATE_RANGE KEYWORD 
;   DEC 30, 2015 - KJWH: ADDED CODE TO READ THE SST FILES
;                        UPDATED HDF CODE   
;   DEC 31, 2015 - KJWH: RENAMED TO SAVE_MAKE_FRONTS AND NOW CALLING FRONTS_BOA     
;   MAR 18, 2016 - KJWH: CHANGED DATATYPE TO IDLTYPE   
;   APR 04, 2016 - KJWH: Added DIR_AREAS keyword 
;                        Removed MAPS_REMAP step - This should be done externally
;                        Updated documentation
;                        Added DIR_LOG and REPORTING  
;                        Removed DATE_RANGE - This should be done before calling SAVE_MAKE_FRONTS       
;                        Removed KM keyword - Now using the actual pixel widths and heights from MAPS_PIXAREA  
;                        Removed ERROR keyword      
;   MAY 13, 2016 - KJWH: Added SST4 as a valid product    
;                        Added SST_FLAG_BITS (SST now uses L2_FLAGS)
;   JUN 29, 2016 - KJWH: Fixed bug with SST's flags - Changed L2_FLAGS to FLAGS_SST(4) and streamlined the flags code   
;   JUL 18, 2016 - KJWH: Updated FLAG_BITS_CHL    
;                        Added AZIMUTH to the return from MAPS_PIXAREA and to the FRONTS_BOA call                                                                                                                                                                                         
;   AUG 09, 2016 - KJWH: Now can read L3B files and will remap them prior to calling FRONTS_BOA.
;   AUG 10, 2016 - KJWH: Changed output map name from LONLAT to MAP_OUT and added a NONE(MAP_OUT) check
;   AUG 12, 2016 - KWJH: Changed POF/PFILE output
;                        Removed /SKIP_AREAS from the MAPS_PIXAREA call for mapped images 
;                        Changed output alg from BOASNR to just BOA
;   AUG 16, 2016 - KJWH: Added options to have multiple maps in MAP_OUT
;                        Cleaned up the code to work with .SAV, .nc and .hdf - some of which needs to be validated    
;   AUG 18, 2016 - KJWH: Added a VALID_CRITERIA step after reading the L3B file to eliminate data that are out of range for a specific product    
;                        Added additional ancillary information (i.e. UNITS, VALID_MIN/MAX) to the output save file      
;                        If file has no VALID data, then write an EXCLUDE file     
;   AUG 22, 2016 - KJWH: Updated savefile name - now the output prod is CHLOR_A_BOA and SST_BOA   
;   SEP 14, 2016 - KJWH: Changed the output struct tag "INFILE" to "NCFILES" to be consistent with other files   
;   SEP 23, 2016 - KJWH: Now reading and inputing the LANDMASK to FRONTS_BOA     
;   OCT 03, 2016 - KJWH: Made compatible with AVHRR and MUR files       
;   OCT 12, 2016 - KJWH: After running FRONTS_BOA, rename the GRAD_MAG tag to be either GRAD_CHL or GRAD_SST
;                        Updated the UNITS to be Gradient Chlorophyll and Gradient Temperature    
;   OCT 20, 2016 - KJWH: Changed EXISTS(AEXCLUDE) to FILE_MAKE(AFILE,AEXCLUDE) so that if the file is new, it will try to run BOA again
;   DEC 06, 2016 - KJWH: Now looping through the MAPS prior to reading the file 
;                        EXLUDE_FILES are now map specific
;   MAR 27, 2017 - KJWH: Changed CRIT = VALIDS('PROD',APROD,/CRITERIA) to CRIT = STRSPLIT(VALIDS('PROD_CRITERIA',APROD),'_',/EXTRACT) - which is now consistent with the updates to VALIDS.pro    
;                        Added optional keyword FULL_STRUCT to alternatively save the full structure returned from FRONTS_BOA       
;                        Added INDATA = ARR prior to calling FRONTS_BOA to preserve the input data     
;   MAR 29, 2017 - KJWH: Changed 'LAT' to 'LATS' when checking the SIZEXYZ of the input LATITUDES          
;   MAR 30, 2017 - KJWH: Adding the SI.MAP to the SI.FILELABEL if not provided       
;   MAY 14, 2018 - KJWH: Added FRONTS_ALG keyword (default is BOA)
;                        Updated output file names and output structure
;                        Changing output name from CHL_BOA-OCI and SST_BOA-4UM to GRAD_CHL-BOA and GRAD_SST-BOA  
;                        Adding IPROD and IALG (input prod and input algorithm) to the output structure   
;                        Added THUMBNAILS keyword and code to produce a THUMBNAIL image of the GRAD_CHL or GRAD_SST image     
;                        Added keyword FRONTS_ALG and a CASE FALG OF so that other frontal algorithms could easily be added to the program          
;   JUL 19, 2019 - KJWH: Added LOGLUN keyword(s)
;   OCT 08, 2020 - KJWH: Updated documentation
;                        Added COMPILE_OPT IDL
;                        Changed subscript () to []
;   MAR 15, 2021 - KJWH: Added steps to change the GRAD_X and GRAD_Y variables to GRAD_SSTX (GRAD_CHLX) and GRAD_SSTY (GRAD_CHLY) respectively  
;   JUN 28, 2021 - KJWH: Now returning the Median Filter (MDFILTER) array as the "input" data because it is the actual (manipulated) data used to generate the GRAD_MAG etc arrays
;                        The INDATA array tag names are now the input data prod (i.e. SST or CHL)                  
;                                         
;-
; *****************************************************************************************************
  ROUTINE_NAME = 'SAVE_MAKE_FRONTS'
  COMPILE_OPT IDL2
    
; ===> Defaults & constants
  DS = DELIMITER(/DASH)
  SL = PATH_SEP()
  IF NONE(LOGLUN)    THEN LOG_LUN = [] ELSE LOG_LUN = LOGLUN
  IF NONE(FRONTS_ALG) THEN FALG = 'BOA' ELSE FALG = FRONTS_ALG
  IF NONE(FLAG_BITS_CHL) THEN FLAG_BITS_CHL = [0,1,3,4,5,8,9,12,14,25]
  IF NONE(FLAG_BITS_SST) THEN FLAG_BITS_SST = [0,1,2,3,4,13,14,15] ; For FRONTS, want to let through the lesser quality data because fronts are often flagged 
    
  COUNT = N_ELEMENTS(FILES)
  IF NONE(FILES)     THEN FILES = DIALOG_PICKFILE(TITLE='Pick files') 
  IF COUNT EQ 0 THEN GOTO, DONE

; ===> Set up the product and algorithm information for the input files
  FA = PARSE_IT(FILES,/ALL)
  IF N_ELEMENTS(PROD) NE 1 THEN BEGIN                                             ; Get prod info from the file name if not provided
    IF SAME(FA.PROD) EQ 0 THEN MESSAGE, 'ERROR: More than one PROD type found.'
    IPROD = FA[0].PROD
    IALG  = FA[0].ALG
    IF IPROD EQ '' THEN MESSAGE, 'ERROR: Must provide PROD if not found in the file name.' 
  ENDIF ELSE BEGIN
    IPROD = VALIDS('PRODS',PROD)
    IALG  = VALIDS('ALGS',PROD) 
  ENDELSE
  IF SAME(FA.MAP) AND ~N_ELEMENTS(MAP_OUT) THEN MPOUT = FA[0].MAP
  IF N_ELEMENTS(MAP_OUT) GT 0 THEN MPOUT = MAP_OUT
  IF ~N_ELEMENTS(MPOUT) THEN MESSAGE, 'ERROR: Unable to determine the output map'

; ===> SET UP PRODUCT SPECIFIC (CHL VS SST) INFORMATION  
  IF IPROD EQ 'SST' OR IPROD EQ 'SST4' THEN BEGIN
    EPSILON = 1.0  ; USED IN MF3_1D_5PT
    LOG = 0
    TRANSFORM = ''
    UNITS_GMAG = 'Gradient Temperature (oC km^-1)'
    VMIN_GMAG = 0.0
    VMAX_GMAG = 10.0
    IF IPROD EQ 'SST' THEN FLAG = 'FLAGS_SST' ELSE FLAG = 'FLAGS_SST4'
    FLAG_BITS = FLAG_BITS_SST
    LANDMASK_FLAG = 1
    FPROD = 'GRAD_SST'
  ENDIF

  IF IPROD EQ 'CHLOR_A' THEN BEGIN
    EPSILON = ALOG(2.0) ; USED IN MF3_1D_5PT
    LOG = 1
    TRANSFORM = 'ALOG'
    UNITS_GMAG = 'Gradient Chlorophyll (km^-1)'
    VMIN_GMAG = 0.0
    VMAX_GMAG = 5.0
    FLAG = 'L2_FLAGS'
    FLAG_BITS = FLAG_BITS_CHL
    LANDMASK_FLAG = 1
    FPROD = 'GRAD_CHL'
  ENDIF
  
; ===> Create output directories  
  IF NONE(DIR_OUT)   THEN DIR_OUT   = !S.FRONTS 
  DIR_LOG     = DIR_OUT + 'LOGS' + SL
  DIR_EXCLUDE = DIR_OUT + 'EXCLUDE' + SL
  DIR_SAVES   = [] 
  DIR_THUMBS  = []
  FOR I=0, N_ELEMENTS(FALG)-1 DO DIR_SAVES = [DIR_SAVES, DIR_OUT + [MPOUT] + SL + 'SAVE' + SL + FPROD + '-' + FALG[I] + SL]
  IF KEY(THUMBNAILS) THEN FOR I=0, N_ELEMENTS(FALG)-1 DO DIR_THUMBS  = [DIR_THUMBS, DIR_OUT + [MPOUT] + SL + 'THUMBNAILS' + SL + FPROD + '-' + FALG[I] + SL] 
  DIR_TEST, [DIR_LOG,DIR_EXCLUDE,DIR_SAVES,DIR_THUMBS]
  
; ===> Loop through the files
  FOR F=0, N_ELEMENTS(FILES)-1L DO BEGIN
    AFILE=FILES[F]
    FP = FA[F]
    SI = SENSOR_INFO(AFILE)
    NAME = SI.NAME
    IF VALIDS('MAPS',SI.FILELABEL) EQ '' THEN SI.FILELABEL = SI.FILELABEL + DS + SI.MAP
    IF ANY(SI.EXT) THEN EXT = STRUPCASE(SI.EXT) ELSE EXT = STRUPCASE(FP.EXT) 
    IF EXT EQ 'SAV' THEN APROD = FP.PROD_ALG ELSE APROD = SI.PRODS   
      
    CASE APROD OF
      'SST': BEGIN
        CASE SI.ALG OF
          '11UM': DAYNIGHT = 'DAY'
          'N_4UM': DAYNIGHT = 'NIGHT'
          'N_11UM': DAYNIGHT = 'NIGHT'
          ELSE: DAYNIGHT='NIGHT'
         ENDCASE
       END  
      ELSE: DAYNIGHT = 'DAY'
    ENDCASE
        
    ; ===> Loop through maps & fronts algs
    ARRAY = [] ; Start with a null data array
    FOR M=0, N_ELEMENTS(MPOUT)-1 DO BEGIN
      AMAP = MPOUT[M]  
      OMAP = MPOUT[M]
      FOR A=0, N_ELEMENTS(FALG)-1 DO BEGIN
        AALG = FALG[A]
        FPROD_ALG = FPROD + '-' + FALG[A]
        
        ; ===> Create file names
        DIR_SAVE  = DIR_OUT + AMAP + SL + 'SAVE' + SL + FPROD_ALG + SL 
        DIR_THUMB = DIR_OUT + AMAP + SL + 'THUMBNAILS' + SL + FPROD_ALG + SL 
        OUTPUT_LABEL = SI.PERIOD + DS + SI.FILELABEL + DS + FPROD_ALG + DS + DAYNIGHT
        ASAVEFILE = DIR_SAVE   +REPLACE(OUTPUT_LABEL, SI.MAP, SI.COVERAGE+DS+AMAP)+ '.SAV'
        APNGFILE  = DIR_THUMB  +REPLACE(OUTPUT_LABEL, SI.MAP, SI.COVERAGE+DS+AMAP)+ '.PNG'
        AEXCLUDE  = DIR_EXCLUDE+REPLACE(OUTPUT_LABEL, SI.MAP, SI.COVERAGE+DS+AMAP)+'-EXCLUDE.TXT'
        
        ; ===> Check if files exist and the fronts code need to be run
        IF FILE_MAKE(AFILE,AEXCLUDE, OVERWRITE=OVERWRITE) EQ 0 THEN CONTINUE ; ===> Skip if EXCLUDE file(s) exists and is more recent than the input file     
        IF KEY(THUMBNAILS) THEN BEGIN
          IF FILE_MAKE(AFILE,[ASAVEFILE,APNGFILE],OVERWRITE=OVERWRITE) EQ 0 THEN CONTINUE  ; ===> Skip if SAVE and PNG file(s) exists and is more recent than the input file
          IF FILE_MAKE(AFILE,ASAVEFILE,OVERWRITE=OVERWRITE) EQ 0 THEN GOTO, MAKE_THUMBNAIL ; ===> If SAVE exists, but PNG is missing, just make new PNG file
        ENDIF ELSE IF FILE_MAKE(AFILE,ASAVEFILE,OVERWRITE=OVERWRITE) EQ 0 THEN CONTINUE    ; ===> Skip if SAVE and PNG file(s) exists and is more recent than the input file
    
        ; ===> READ THE FILE IF ARR IS []
        IF ARRAY EQ [] THEN BEGIN 
          POF, F, FILES, OUTTXT=OUTTXT,/QUIET
          PFILE, AFILE, /R, _POFTXT=OUTTXT, LOGLUN=LOG_LUN
          LONS=[] & L2_LONS=[]
          LATS=[] & L2_LATS=[]
          IF HAS(EXT, 'SAV') THEN BEGIN 
            ARRAY = STRUCT_READ(AFILE,STRUCT=STRUCT) 
            IF STRUCT_HAS(STRUCT,'BINS') THEN BINS=STRUCT.BINS ELSE BINS = []  
          ENDIF ELSE BEGIN
            IF ~IS_L3B(SI.MAP) THEN BEGIN ; If not a L3B, then assume an unmapped LONLAT file
              PRODS=[IPROD,'LONGITUDE','LATITUDE','L2_FLAGS','FLAGS_SST','FLAGS_SST4']
              CASE EXT OF
                'HDF': SD = READ_HDF(AFILE,PRODS=PRODS)
                'NC':  SD = READ_NC(AFILE,PRODS=PRODS)
              ENDCASE  
              IF IDLTYPE(SD) EQ 'STRING' THEN BEGIN
                TXT = 'ERROR: Can not read ' + IPROD + ' from ' + AFILE
                STOP
                REPORT, TXT, DIR=DIR_LOG,/QUIET
                WRITE_TXT, AEXCLUDE, TXT
              ENDIF
          
              L2_LATS = SD.SD.LATITUDE.IMAGE
              L2_LONS = SD.SD.LONGITUDE.IMAGE
            
              OK_PROD = WHERE(TAG_NAMES(SD.SD) EQ IPROD,COUNT_PROD)
              IF COUNT_PROD EQ 0 THEN MESSAGE, 'ERROR: ' + IPROD + ' not found in ' + AFILE
              DT = SD.SD.(OK_PROD)
              IMG  = DT.IMAGE
              DTAGS = STRUPCASE(TAG_NAMES(DT))
      
            ; ===>  Find FILLED/BAD data
              IF HAS(DTAGS,'_FILLVALUE')       THEN FV = DT._FILLVALUE._DATA[0] ELSE FV = MISSINGS(IMG)
              IF HAS(DTAGS,'BAD_VALUE_SCALED') THEN BV = DT.BAD_VALUE_SCALED    ELSE BV = MISSINGS(IMG)
        
            ; ===> Get VALID_MIN/MAX data
              IF HAS(DTAGS,'VALID_MIN') THEN VMIN = DT.VALID_MIN._DATA[0] ELSE VMIN = -1*MISSINGS(IMG)
              IF HAS(DTAGS,'VALID_MAX') THEN VMAX = DT.VALID_MAX._DATA[0] ELSE VMAX = MISSINGS(IMG)
      
            ; ===> Create MASK based on L2 FLAGS
              FLAG_POS = WHERE(TAG_NAMES(SD.SD) EQ FLAG,COUNT) & IF COUNT EQ 0 THEN STOP
              MASK_FLAG = SD_FLAGS_COMBO(SD.SD.(FLAG_POS).IMAGE,FLAG_BITS)
              OK_MASK = WHERE(MASK_FLAG GT 0, COUNT_MASK)
              LANDMASK = SD_FLAGS_COMBO(SD.SD.(FLAG_POS).IMAGE,LANDMASK_FLAG)
     
              IF HAS(SD.SD, 'QUAL_SST') OR HAS(SD.SD, 'QUAL_SST4') THEN BEGIN
                POS = WHERE(TAG_NAMES(SD.SD) EQ 'FLAGS_SST')
                IF POS EQ -1 THEN POS = WHERE(TAG_NAMES(SD.SD) EQ 'FLAGS_SST4')
                IF POS EQ -1 THEN STOP
                QIMG = SD.SD.(POS).IMAGE
                OK_MASK = WHERE(QIMG GT SST_QUAL,COUNT_MASK)
              ENDIF
    
              ; ===>  Find the "GOOD" data
              OK_GOOD=WHERE(IMG NE MISSINGS(IMG) AND IMG NE BV AND IMG NE FV AND IMG NE MISSINGS(0) AND IMG NE -MISSINGS(0) AND IMG GE VMIN AND IMG LE VMAX, COUNT_GOOD, COMPLEMENT=OK_BAD, NCOMPLEMENT=COUNT_BAD)
      
              ; ===> Scale with slope and intercept if available
              SLOPE = 1.0 & INTERCEPT = 0.0
              IF HAS(DTAGS,'SLOPE')        THEN SLOPE     = FLOAT(DT.SLOPE[0])
              IF HAS(DTAGS,'SCALE_FACTOR') THEN SLOPE     = FLOAT(DT.SCALE_FACTOR._DATA[0])
              IF HAS(DTAGS,'INTERCEPT')    THEN INTERCEPT = FLOAT(DT.INTERCEPT[0])
              IF HAS(DTAGS,'ADD_OFFSET')   THEN INTERCEPT = FLOAT(DT.ADD_OFFSET._DATA[0])
        
              ARRAY = IMG * SLOPE + INTERCEPT
            
              ; ===>  Make "BAD" data MISSINGS
              IF COUNT_BAD  GE 1 THEN ARRAY[OK_BAD]  = MISSINGS(ARRAY) ; Mask out MISSING and BAD_VALUE data
              IF COUNT_MASK GE 1 THEN ARRAY[OK_MASK] = MISSINGS(ARRAY) ; Mask out data based on L2 FLAGS          
    
            ENDIF ELSE BEGIN ; IF HAS(SI.MAP,'L3B') EQ 0 THEN BEGIN
              NPROD = VALIDS('PRODS',IPROD)
              IF PROD EQ 'SST-N_4UM' THEN NPROD = 'SST4' ; Special case for the SST4 products
              CRIT = STRSPLIT(VALIDS('PROD_CRITERIA',IPROD),'_',/EXTRACT) & VMIN = FLOAT(CRIT[0]) & VMAX = FLOAT(CRIT[1])
              SD = READ_NC(AFILE,PRODS=NPROD)
              OKP = WHERE_TAGS(SD.SD,NPROD)
              ARRAY = SD.SD.(OKP).DATA
              BINS = SD.SD.(OKP).BINS
              ARRAY = VALID_DATA(ARRAY, PROD=IPROD)
              IF ANY(SUBSET_LONS) THEN BEGIN
                LONS = SUBSET_LONS
                LATS = SUBSET_LATS
              ENDIF
            ENDELSE
          ENDELSE ; IF EXT EQ 'SAV' OR EXT EQ 'SAVE' THEN BEGIN  
  
          ; ===> Check data array    
          IF NONE(ARRAY) OR WHERE(ARRAY NE MISSINGS(ARRAY),/NULL) EQ [] THEN BEGIN
            TXT = 'ERROR: No data to input to FRONTS_BOA: '  + AFILE
            REPORT, TXT, DIR=DIR_LOG,/QUIET
            PLUN, LOG_LUN, TXT
            WRITE_TXT, AEXCLUDE, TXT
            GONE, ARRAY
            CONTINUE
          ENDIF
          IF STRUCT_HAS(STRUCT,'NCFILES') THEN NCFILES=STRUCT.NCFILES ELSE NCFILES=AFILE  ; ===> GET NCFILES FOR THE OUTPUT STRUCTURE
        ENDIF ; IF ARRARY EQ [] 
      
        ; ===> Remap array  
        SUBSET_BINS = []
        L3BGS_MAP = []
        SUBSET_STRUCT = []
        CASE 1 OF
          (AMAP EQ 'LONLAT'):                  ARR = ARRAY
          (IS_L3B(SI.MAP) AND IS_L3B(AMAP)):   ARR = MAPS_L3BGS_SWAP(MAPS_L3B_2ARR(ARRAY,MP=SI.MAP,BINS=BINS),L3BGS_MAP=L3BGS_MAP,MAP_SUBSET=MAP_SUBSET,SUBSET_BINS=SUBSET_BINS,SUBSET_STRUCT=SUBSET_STRUCT)  
          (IS_L3B(SI.MAP) AND IS_GSMAP(AMAP)): ARR = MAPS_L3BGS_SWAP(MAPS_L3B_2ARR(ARRAY,MP=SI.MAP,BINS=BINS),L3BGS_MAP=L3BGS_MAP,MAP_SUBSET=MAP_SUBSET,SUBSET_BINS=SUBSET_BINS,SUBSET_STRUCT=SUBSET_STRUCT)  
          ELSE:                                ARR = MAPS_REMAP(ARRAY, MAP_IN=SI.MAP,MAP_OUT=AMAP,BINS=BINS,MAP_SUBSET=MAP_SUBSET,CONTROL_LONS=LONS,CONTROL_LATS=LATS)    
        ENDCASE
        IF L3BGS_MAP NE [] THEN AMAP = L3BGS_MAP
      
      IF NONE(ARR) OR WHERE(ARR NE MISSINGS(ARR),/NULL) EQ [] THEN BEGIN
        TXT = 'ERROR: No data to input to FRONTS_BOA for map ' + AMAP + ': '  + AFILE
        REPORT, TXT, DIR=DIR_LOG,/QUIET
        PLUN, LOG_LUN, TXT
        WRITE_TXT, AEXCLUDE, TXT
        GONE, ARR
        CONTINUE
      ENDIF
      INDATA = ARRAY 

 ; ===> GET THE PIXEL WIDTHS AND HEIGHTS
      IF AMAP EQ 'LONLAT' THEN BEGIN
        IF NONE(DIR_AREAS) THEN DIR_AREAS = REPLACE(FP.DIR,'NC','AREAS') 
      ;  DIR_TEST, DIR_AREAS
        MAP_AREA_FILE = DIR_AREAS + SI.NAME_EXT + DS + 'AREA.SAV'
        IF FILE_MAKE(AFILE, MAP_AREA_FILE) EQ 1 THEN BEGIN ; If area file does not exist, make the file        
          SZ = SIZEXYZ(L2_LATS, PX=PX, PY=PY)
          IF PX LE 5 OR PY LE 5 THEN BEGIN
            TXT = 'ERROR: Image is too narrow (PX<5) or too short (PY<5) to process: ' + AFILE
            REPORT, TXT, DIR=DIR_LOG,/QUIET
            PLUN, LOG_LUN, TXT
            CONTINUE
          ENDIF
          PLUN, LOG_LUN, 'Getting pixel sizes...'
          MAREA = MAPS_PIXAREA(LONS=L2_LONS, LATS=L2_LATS, WIDTHS=WIDTH, HEIGHTS=HEIGHT, AZIMUTH=AZIMUTH, /SKIP_AREAS)
        ENDIF ELSE BEGIN
          MAREA = IDL_RESTORE(MAP_AREA_FILE)
          WIDTH = MAREA.WIDTHS
          HEIGHT = MAREA.HEIGHTS
          AZIMUTH = MAREA.AZIMUTH
        ENDELSE ; FILE_MAKE MAP_AREA_FILE
      ENDIF ELSE BEGIN
        AREA  = MAPS_PIXAREA(AMAP, LONS=LONS, LATS=LATS, WIDTHS=WIDTH, HEIGHTS=HEIGHT, AZIMUTH=AZIMUTH)
        LANDMASK = READ_LANDMASK(AMAP,/LAND)
      ENDELSE  
      
      IF ANY(SUBSET_BINS) THEN BEGIN
        WIDTH = WIDTH[SUBSET_STRUCT.LONMIN:SUBSET_STRUCT.LONMAX,SUBSET_STRUCT.LATMIN:SUBSET_STRUCT.LATMAX]
        HEIGHT = HEIGHT[SUBSET_STRUCT.LONMIN:SUBSET_STRUCT.LONMAX,SUBSET_STRUCT.LATMIN:SUBSET_STRUCT.LATMAX]  
        AZIMUTH = AZIMUTH[SUBSET_STRUCT.LONMIN:SUBSET_STRUCT.LONMAX,SUBSET_STRUCT.LATMIN:SUBSET_STRUCT.LATMAX]  
        LANDMASK = LANDMASK[SUBSET_STRUCT.LONMIN:SUBSET_STRUCT.LONMAX,SUBSET_STRUCT.LATMIN:SUBSET_STRUCT.LATMAX]  
      ENDIF  
      
      ; ===> RUN FRONTS    
      CASE FALG[A] OF
        'BOA': STR = FRONTS_BOA(ARR, LOG=LOG, GRAD_TAG=FPROD, EPSILON=EPSILON, WIDTH=WIDTH, HEIGHT=HEIGHT, AZIMUTH=AZIMUTH, LANDMASK=LANDMASK)   
        ELSE: MESSAGE, 'ERROR: Invalid FRONTS ALGORITHM'
      ENDCASE
        
      IF IDLTYPE(STR) EQ 'STRING' THEN BEGIN
        TXT = STR + ' for map ' + AMAP + ' in file: '  + AFILE 
        REPORT, TXT, DIR=DIR_LOG,/QUIET
        PLUN, LOG_LUN, TXT
        WRITE_TXT, AEXCLUDE, TXT
        GONE, ARR
        CONTINUE
      ENDIF  

      ; ===> Subset the fronts_structure
      IF KEY(FULL_STRUCT) THEN STR = CREATE_STRUCT(STR,'PIXEL_WIDTH',WIDTH,'PIXEL_HEIGHT',HEIGHT,'PIXEL_AZIMUTH',AZIMUTH) $
                          ELSE STR = STRUCT_COPY(STR,['GRAD_CHL','GRAD_SST','GRAD_X','GRADX_CHL','GRADX_SST','GRAD_Y','GRADY_CHL','GRADY_SST','GRAD_DIR','MDFILTER']) 
      
      ; ===> Rename the GRAD_X and GRAD_Y variables
      CASE FPROD OF 
        'GRAD_SST': BEGIN & STR = STRUCT_RENAME(STR, ['GRAD_X','GRAD_Y','MDFILTER'], ['GRADX_SST','GRADY_SST','SST'],/STRUCT_ARRAYS) & GMARR = STR.GRAD_SST & END
        'GRAD_CHL': BEGIN & STR = STRUCT_RENAME(STR, ['GRAD_X','GRAD_Y','MDFILTER'], ['GRADX_CHL','GRADY_CHL','CHLOR_A'],/STRUCT_ARRAYS) & GMARR = STR.GRAD_CHL & END
      ENDCASE  
             
      ; ===> Convert gs2 maps back to l3b             
      IF IS_GSMAP(AMAP) AND IS_L3B(SI.MAP) THEN BEGIN  
        OK_SUBSET = []
        IF ANY(SUBSET_BINS) THEN BEGIN
          IF N_ELEMENTS(GMARR) NE N_ELEMENTS(ARR) THEN MESSAGE, 'ERROR: Input and output array sizes are not the same'
          BLK = MAPS_BLANK(L3BGS_MAP,FILL=-9999.0D)
          BLK[SUBSET_STRUCT.LONMIN:SUBSET_STRUCT.LONMAX,SUBSET_STRUCT.LATMIN:SUBSET_STRUCT.LATMAX] = GMARR
          OK_SUBSET = WHERE(BLK NE -9999.0D)
        ENDIF ELSE BLK = GMARR 
        
        TAGS = TAG_NAMES(STR)                                                        ; Get the tag names of the FRONTS structure
        IF IS_L3B(OMAP) THEN BEGIN  
          BL3 = MAPS_L3BGS_SWAP(BLK)
          OK_NUM = WHERE(BL3 NE MISSINGS(BL3) AND BL3 NE -9999.0D,COUNT_BINS)           
          STRUCT= CREATE_STRUCT('BINS',OK_NUM,'NBINS',COUNT_BINS)                    ; Create a new FRONTS structure with BIN info
        ENDIF ELSE STRUCT = []
        SKIP_TAGS = ['']                                                             ; Tags to ignore in the LOOP
        FOR T=0, N_ELEMENTS(TAGS)-1 DO BEGIN                                         ; Loop through the STAT tags
          OKT = WHERE_MATCH(TAGS[T],SKIP_TAGS,COUNT_TAGS)                            ; Look for the tags to ignore
          IF COUNT_TAGS GT 0 THEN CONTINUE                                           ; Continue if a "SKIP TAG"
                                                        
          IF OK_SUBSET NE [] THEN BEGIN
            SUBSET = MAPS_BLANK(AMAP, FILL=MISSINGS(0.0D))
            SUBSET[OK_SUBSET] = STR.(T) 
            IF IS_L3B(OMAP) THEN BEGIN
              SUBSET = MAPS_L3BGS_SWAP(SUBSET)
              SUBSET = SUBSET[OK_NUM]
            ENDIF
          ENDIF ELSE SUBSET = STR.(T) 
          STRUCT = CREATE_STRUCT(STRUCT,TAGS[T],SUBSET)                              ; Add subset to the new stat structure
        ENDFOR
        STR = STRUCT & GONE, STRUCT                                                  ; Rename the stat structure
      ENDIF
                                   
      ; ===> Save the structure
      STRUCT_WRITE, STR, FILE=ASAVEFILE, PROD=FPROD, MAP=OMAP, UNITS=UNITS_GMAG, VALID_MIN=VMIN_GMAG, VALID_MAX=VMAX_GMAG, DAYNIGHT=DAYNIGHT, LOGLUN=LOG_LUN,$
        MED_FILTER_EPSILON=EPSILON, TRANSFORM=TRANSFORM, GRADDIR_UNITS='Degrees',GRADDDIR_VALID_MIN=0.0, GRADDIR_VALID_MAX=360.0,LONS=L2_LONS,LATS=L2_LATS,$
        INFILE=AFILE, INDATA_PROD=IPROD, INDATA_ALG=IALG, INDATA_UNITS=UNITS(IPROD,/SI),INDATA_VALID_MIN=VMIN, INDATA_VALID_MAX=VMAX, NOTES='FRONTS_'+FALG[A]+'-'+DATE_NOW(/DATE_ONLY)

      ; ===> Make thumbnail image
      MAKE_THUMBNAIL:
      IF KEY(THUMBNAILS) THEN BEGIN
        IF VALIDS('MAPS',MAP_SUBSET) THEN MAPP = MAP_SUBSET ELSE MAPP = AMAP
        PRODS_2PNG, ASAVEFILE, DIR_OUT=DIR_THUMB, PNGFILE=APNGFILE, BUFFER=1, /ADD_CB, MAPP=MAPP, /ADD_TXT, TXT_TAGS='MAP', TXT_POS=[0.01,0.78]
      ENDIF
      
      GONE, ARR
      ENDFOR ; FALG
    ENDFOR ; MPOUT
    GONE, SD
  ENDFOR ; FOR _FILE = 0L, N_FILES-1 DO BEGIN

  DONE:

END; #####################  END OF ROUTINE ################################
