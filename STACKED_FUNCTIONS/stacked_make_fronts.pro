; $ID:	STACKED_MAKE_FRONTS.PRO,	2023-09-21-13,	USER-KJWH	$
  PRO STACKED_MAKE_FRONTS, FILES, $
    MAP_SUBSET=MAP_SUBSET, FRONTS_ALG=FRONTS_ALG, THRESHOLD_BOX=THRESHOLD_BOX, DIR_OUT=DIR_OUT, OUTPRODS=OUTPRODS, LOGLUN=LOGLUN, $
    OVERWRITE=OVERWRITE

;+
; NAME:
;   STACKED_MAKE_FRONTS
;
; PURPOSE:
;   This procedure runs the fronts_boa program for chlorophyll and sst "stacked" files and creates an output "stacked" .SAV file
;
; CATEGORY:
;   STACKED_FUNCTIONS
;
; CALLING SEQUENCE:
;   STACKED_MAKE_FRONTS, FILES
;
; REQUIRED INPUTS:
;   FILES.......... The full path and file names of the input files
;
; OPTIONAL INPUTS:
;   FRONTS_ALG...... Fronts algorithm (currently only BOA is available, but additional algorithms can easily be added)
;   THRESHOLD_BOX......... The box size for the fronts threshold
;   DIR_OUT......... Directory for writing output files           
;   OUTPRODS........ An array of output products to save in the D3HASH file
;   LOGLUN.......... Lun for writing information to the LOG file
;
; KEYWORD PARAMETERS:
;   OVERWRITE....... Overwrite the output file if it already exists
;
; OUTPUTS:
;   A "stacked" .SAV file of the FRONTS structure containing floating point arrays for:
;     GRAD_MAG (gradient magnitude)
;     GRAD_X (gradient in horizontal direction) 
;     GRAD_Y (gradient in vertical direction) 
;     GRAD_DIR (gradient direction, in degrees)
;     and other specified gradient produts
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
;   The gradient direction (GRAD_DIR) is relative to the image array (the map projection is used to make the image) and is not always true north
;
; EXAMPLE:
; 
;
; NOTES:
;   
;   
; REFERENCE:
;   Belkin IM, O'Reilly JE (2009) An algorithm for oceanic front detection in chlorophyll and SST satellite imagery.
;     Journal of Marine Systems 78: 319-326 doi doi: 10.1016/j.jmarsys.2008.11.018
;   
; COPYRIGHT: 
; Copyright (C) 2023, Department of Commerce, National Oceanic and Atmospheric Administration, National Marine Fisheries Service,
;   Northeast Fisheries Science Center, Narragansett Laboratory.
;   This software may be used, copied, or redistributed as long as it is not sold and this copyright notice is reproduced on each copy made.
;   This routine is provided AS IS without any express or implied warranties whatsoever.
;
; AUTHOR:
;   This program was written on January 06, 2023 by Kimberly J. W. Hyde, Northeast Fisheries Science Center | NOAA Fisheries | U.S. Department of Commerce, 28 Tarzwell Dr, Narragansett, RI 02882
;    
; MODIFICATION HISTORY:
;   Jan 06, 2023 - KJWH: Initial code written - adapted from SAVE_MAKE_FRONTS
;   Jan 12, 2023 - KJWH: Changed STRUCT_HAS() to WHERE(TAG_NAMES()...) to make it faster
;                                     Added AZIMUTH to the output because it is used in the stats
;   Aug 17, 2023 - KJWH: Overhauled program
;                                         Now include the step to calcualte the frontal THRESHOLD 
;                                         Now can subset to a different map than the input subset file 
;                                         Now writing out the output products into multiple files (GRAD_SST, GRAD_SSTKM, GRAD_DIR)  to reduce the overall filesize    
;                                         Fixed bugs with the conversion between GS to L3B arrays before saving them in the output hash
;   Mar 18, 2024 - KJWH: Changed from using the L3BSUBS to L3OCEAN_SUBS when using MAP_SUBSET (now no longer saving "land" pixels)                                                         
;-
; ****************************************************************************************************
  ROUTINE_NAME = 'STACKED_MAKE_FRONTS'
  COMPILE_OPT IDL2
  SL = PATH_SEP()
  
  ; ===> Defaults & constants
  DS = DELIMITER(/DASH)
  SL = PATH_SEP()
  IF ~N_ELEMENTS(FILES) THEN MESSAGE, 'ERROR: Must provide input files'


  IF ~N_ELEMENTS(LOGLUN)        THEN LOG_LUN = [] ELSE LOG_LUN = LOGLUN
  IF ~N_ELEMENTS(FRONTS_ALG)    THEN FALG = 'BOA' ELSE FALG = FRONTS_ALG
  IF ~N_ELEMENTS(FLAG_BITS_CHL) THEN FLAG_BITS_CHL = [0,1,3,4,5,8,9,12,14,25]
  IF ~N_ELEMENTS(FLAG_BITS_SST) THEN FLAG_BITS_SST = [0,1,2,3,4,13,14,15] ; For FRONTS, want to let through the lesser quality data because fronts are often flagged
  IF ~N_ELEMENTS(THRESHOLD_BOX)  THEN THRESHBOX = 9 ELSE THRESHBOX = THRESHOLD_BOX
  

  ; ===> Get the file and map specific information
  FA = PARSE_IT(FILES,/ALL)
  IF SAME(FA.MAP) THEN AMAP = FA[0].MAP ELSE MESSAGE, 'ERROR: All files must have the same input map.'
  IF SAME(FA.MAP_SUBSET) THEN MPSUBSET = REPLACE(FA[0].MAP_SUBSET,'_SUBSET','') ELSE MESSAGE, 'ERROR: All files must have the same SUBSET map.'
  IF N_ELEMENTS(MAP_SUBSET) EQ 1 THEN MPSUBSET =  REPLACE(MAP_SUBSET,'_SUBSET','') 
  IF ~IS_L3B(AMAP) THEN MESSAGE, 'ERROR: Expecting a L3B map input'
  GSMAP = MAPS_L3B_GET_GS(AMAP)
  AREA  = MAPS_PIXAREA(GSMAP, LONS=LONS, LATS=LATS, WIDTHS=WIDTH, HEIGHTS=HEIGHT, AZIMUTH=AZIMUTH)
  LANDMASK = READ_LANDMASK(GSMAP,/LAND) 
  
  TMP = MAPS_L3BGS_SWAP(MAPS_BLANK(AMAP),L3BGS_MAP=L3BGS_MAP,MAP_SUBSET=MPSUBSET,GSSUBS=GSSUBS,L3SUBS=L3SUBS,L3OCEAN_SUBS=L3OCEAN_SUBS,SUBSET_STRUCT=SUBSET_STRUCT)
  OCEBINS = L3OCEAN_SUBS + 1
  SUBS = L3OCEAN_SUBS
  SWIDTH = WIDTH[SUBSET_STRUCT.LONMIN:SUBSET_STRUCT.LONMAX,SUBSET_STRUCT.LATMIN:SUBSET_STRUCT.LATMAX]
  SHEIGHT = HEIGHT[SUBSET_STRUCT.LONMIN:SUBSET_STRUCT.LONMAX,SUBSET_STRUCT.LATMIN:SUBSET_STRUCT.LATMAX]
  SAZIMUTH = AZIMUTH[SUBSET_STRUCT.LONMIN:SUBSET_STRUCT.LONMAX,SUBSET_STRUCT.LATMIN:SUBSET_STRUCT.LATMAX]
  SLANDMASK = LANDMASK[SUBSET_STRUCT.LONMIN:SUBSET_STRUCT.LONMAX,SUBSET_STRUCT.LATMIN:SUBSET_STRUCT.LATMAX]
  SUBSETSZ = SIZEXYZ(TMP,PX=SPX,PY=SPY) & SUBSETPXY = 'PXY_1_' + NUM2STR(N_ELEMENTS(L3OCEAN_SUBS))

  FOR F=0, N_ELEMENTS(FILES)-1 DO BEGIN
    FILE = FILES[F]
    FP = FA[F]
    PERIOD = FP.PERIOD
    PSTR = PERIOD_2STRUCT(PERIOD)
    DRANGE = STRJOIN(STRMID([PSTR.DATE_START,PSTR.DATE_END],0,8),'_')                                                      ; Get the daterange for the period

    ; ===> Get PROD specific information to add to the INFO structure
    PR = PRODS_READ(FP.PROD)
    PROD = PR.PROD
    CASE PROD OF
      'SST': BEGIN
        IALG = ''
        RNGE = [-3.0 ,40.0]
        EPSILON = 1.0
        LOG = 0 & TRANSFORM = ''
        FPROD = 'GRAD_SST'
        GPROD = 'SST'
      END
      'CHLOR_A': BEGIN
        IALG = FP.ALG
        RNGE = [0.0, 189.0] 
        EPSILON = ALOG(2.0)
        LOG = 0 & TRANSFORM = 'ALOG'
        FPROD = 'GRAD_CHL'
        GPROD = 'CHL'
      END  
    ENDCASE
    
    GPRODS = [PROD,FPROD,'GRADX_'+GPROD,'GRADY_'+GPROD,'GRAD'+GPROD+'_FRONT']
    KPRODS = [PROD,FPROD+'KM','GRADX_'+GPROD+'KM','GRADY_'+GPROD+'KM','GRAD'+GPROD+'_FRONT']
    DPRODS = [PROD,FPROD,'GRAD'+GPROD+'_DIR','GRAD'+GPROD+'_FRONT']
    OPRODS = [GPRODS,KPRODS,DPRODS] & OPRODS = OPRODS[UNIQ(OPRODS,SORT(OPRODS))]
    INFO_CONTENT = CREATE_STRUCT('PROD',PR.PROD,'ALG',IALG,'UNITS',PR.UNITS,'LONG_NAME',PR.CF_LONG_NAME, $                      ; Extract product specific information
                                 'STANDARD_NAME',PR.CF_STANDARD_NAME,'VALID_MIN',MIN(RNGE),'VALID_MAX',MAX(RNGE),'THRESHOLD_BOX_SIZE',THRESHBOX)
    
    ; ===> Loop through the frontal algorithms
    DAT = []
    FOR M=0, N_ELEMENTS(FALG)-1 DO BEGIN
      ALG = FALG[M]
      
      ; ===> Create output directory and file name(s)
      IF ~N_ELEMENTS(DIR_OUT) THEN DIR_OUT = REPLACE(FP.DIR,FP.SUB,FPROD+'-'+FALG)                                               ; Create the output directory
      DIR_TEST, [DIR_OUT,REPLACE(DIR_OUT,FPROD,FPROD+'KM'),REPLACE(DIR_OUT,FPROD,'GRAD'+GPROD+'_DIR')]                                                                                                                 ; Make the output directory folder
      IF ~N_ELEMENTS(FILE_LABEL) THEN FLABEL=FILE_LABEL_MAKE(FILE,LST=['SENSOR','VERSION','SATELLITE','SAT_EXTRA','METHOD','MAP','MAP_SUBSET','PXY']) ELSE FLABEL=FILE_LABEL ; Create the output file label
      FLABEL = FLABEL + '-' + FPROD + '-' + FALG 
      IF REPLACE(FA[0].MAP_SUBSET,'_SUBSET','') NE MPSUBSET THEN FLABEL = REPLACE(FLABEL,FA[0].MAP_SUBSET,MPSUBSET+'_SUBSET')
      IF FA[0].PXY NE SUBSETPXY THEN FLABEL = REPLACE(FLABEL,FA[0].PXY,SUBSETPXY)
      
      GOUTFILE = DIR_OUT + FP.PERIOD + '-' + FLABEL + '.SAV'
      KOUTFILE = REPLACE(GOUTFILE,FPROD,FPROD+'KM')
      DOUTFILE = REPLACE(GOUTFILE,FPROD,'GRAD'+GPROD+'_DIR')
      SAVEFILES = [GOUTFILE,KOUTFILE,DOUTFILE]
      IF ~FILE_MAKE(FILE,SAVEFILES,OVERWRITE=OVERWRITE) THEN CONTINUE

      ; ===> Read the data and check that the files were open correctly
      IF DAT EQ [] THEN BEGIN
        STR = STACKED_READ(FILE,DB=DB,BINS=INPUT_FILE_BINS)      
        IF IDLTYPE(STR) EQ 'STRING' THEN BEGIN
          PLUN, LOG_LUN, 'ERROR: Reading the input files for ' + FILE
          CONTINUE
        ENDIF
        DAT = STR.(WHERE(TAG_NAMES(STR) EQ PR.PROD,/NULL))
      ENDIF   

      ; ===> Create or read the HASH obj
      IF GFRTHASH EQ [] THEN BEGIN
        IF ~FILE_TEST(GOUTFILE) OR KEYWORD_SET(OVERWRITE) THEN BEGIN
          GFRTHASH = D3HASH_MAKE(GOUTFILE, INPUT_FILES=FILE, BINS=INPUT_FILE_BINS, PRODS=GPRODS, ADD_INFO='INPUT_PRODUCTS',INFO_CONTENT=INFO_CONTENT) 
          KFRTHASH = D3HASH_MAKE(KOUTFILE, INPUT_FILES=FILE, BINS=INPUT_FILE_BINS, PRODS=KPRODS, ADD_INFO='INPUT_PRODUCTS',INFO_CONTENT=INFO_CONTENT) 
          DFRTHASH = D3HASH_MAKE(DOUTFILE, INPUT_FILES=FILE, BINS=INPUT_FILE_BINS, PRODS=DPRODS, ADD_INFO='INPUT_PRODUCTS',INFO_CONTENT=INFO_CONTENT) 
        ENDIF ELSE BEGIN
          GFRTHASH = IDL_RESTORE(GOUTFILE)    ; Read the D3HASH file if it already exists and extract the D3 database
          KFRTHASH = IDL_RESTORE(KOUTFILE)    ; Read the D3HASH file if it already exists and extract the D3 database
          DFRTHASH = IDL_RESTORE(DOUTFILE)    ; Read the D3HASH file if it already exists and extract the D3 database
        ENDELSE
      ENDIF  
      
      FRTHASH = GFRTHASH ; Make a copy to hold the new content and then copy it over to each hash at the end

      IF IDLTYPE(GFRTHASH) NE 'OBJREF' OR IDLTYPE(KFRTHASH) NE 'OBJREF' OR IDLTYPE(DFRTHASH) NE 'OBJREF' THEN MESSAGE, 'ERROR: Unable to properly create or read the HASH obj'                                                ; Read the existing D3 file
      FTDB = FRTHASH['FILE_DB'].TOSTRUCT()
      
      FOR B=0, N_ELEMENTS(THRESHOLD_BOX)-1 DO BEGIN
        BX = NUM2STR(THRESHOLD_BOX[B])
        IF ~GFRTHASH.HASKEY('THRESHOLD_MEDIAN_'+BX) THEN GFRTHASH['THRESHOLD_MEDIAN_BOX'+BX] = FLTARR(N_ELEMENTS(DB.PERIOD))
        IF ~KFRTHASH.HASKEY('THRESHOLD_MEDIAN_'+BX) THEN KFRTHASH['THRESHOLD_MEDIAN_BOX'+BX] = FLTARR(N_ELEMENTS(DB.PERIOD))
        IF ~DFRTHASH.HASKEY('THRESHOLD_MEDIAN_'+BX) THEN DFRTHASH['THRESHOLD_MEDIAN_BOX'+BX] = FLTARR(N_ELEMENTS(DB.PERIOD))
        
        IF GFRTHASH.HASKEY('GRAD'+GPROD+'_FRONT') THEN GFRTHASH['GRAD'+GPROD+'_FRONT_BOX'+BX] =  GFRTHASH['GRAD'+GPROD+'_FRONT']
        IF KFRTHASH.HASKEY('GRAD'+GPROD+'_FRONT') THEN KFRTHASH['GRAD'+GPROD+'_FRONT_BOX'+BX] =  KFRTHASH['GRAD'+GPROD+'_FRONT']
        IF DFRTHASH.HASKEY('GRAD'+GPROD+'_FRONT') THEN DFRTHASH['GRAD'+GPROD+'_FRONT_BOX'+BX] =  DFRTHASH['GRAD'+GPROD+'_FRONT'] 
        
        OPRODS = [OPRODS,'GRAD'+GPROD+'_FRONT_BOX'+BX]
      ENDFOR 
      IF GFRTHASH.HASKEY('GRAD'+GPROD+'_FRONT') THEN  GFRTHASH.REMOVE, ['GRAD'+GPROD+'_FRONT']
      IF KFRTHASH.HASKEY('GRAD'+GPROD+'_FRONT') THEN  KFRTHASH.REMOVE, ['GRAD'+GPROD+'_FRONT']
      IF DFRTHASH.HASKEY('GRAD'+GPROD+'_FRONT') THEN  DFRTHASH.REMOVE, ['GRAD'+GPROD+'_FRONT']
      
      D3_KEYS = FRTHASH.KEYS() & D3_KEYS = D3_KEYS.TOARRAY()                                                                  ; Get the D3HASH key names and convert the LIST to an array
      D3_PRODS = REMOVE(D3_KEYS,VALUES=['FILE_DB','PRODS','BINS','INFO','METADATA'])                                           ; Keep just the D3 variable names

      WRITEFILE = 0
      FOR D=0, N_ELEMENTS(DB)-1 DO BEGIN
        PER = DB[D].PERIOD
        DP = DATE_PARSE(PERIOD_2DATE(PER))

        ; ===> Find the matching periods in the databases
        ISQ = DB[D].SEQ
        SEQ = WHERE(FRTHASH['FILE_DB','PERIOD'] EQ DB[D].PERIOD,/NULL)
        IF SEQ EQ [] THEN MESSAGE, 'ERROR: Unable to find matching PPD period for ' + PER

        ; ===> Get the data for each variable
        ARRAY = DAT[*,*,ISQ]
        
        OKALL = WHERE(ARRAY NE MISSINGS(ARRAY) AND ARRAY GT RNGE[0] AND ARRAY LT RNGE[1], COUNT_ALL)
        IF COUNT_ALL EQ 0 THEN PLUN, LOG_LUN, 'No valid data found, SKIPPING ' + DB[D].PERIOD,0
        IF COUNT_ALL EQ 0 THEN CONTINUE ; Continue if no valid data

        ; ===> Check the daily MTIMES
        MTIME = DB[ISQ].MTIME
        IF FRTHASH['FILE_DB','MTIME',SEQ] GE MTIME AND ~KEYWORD_SET(OVERWRITE) THEN CONTINUE                     ; Check the MTIMES in the file DB and skip if the data is already in the database and does not need to be updated
        WRITEFILE = 1
        
        ; ===> Add the file information to the D3 database in the D3HASH
        FRTHASH['FILE_DB','MTIME',SEQ] = DATE_NOW(/MTIME)                                                                     ; Add the file MTIME to the D3 database
        FRTHASH['FILE_DB','FULLNAME',SEQ] = GOUTFILE                                                                            ; Add the full file name to the D3 database
        FRTHASH['FILE_DB','NAME',SEQ] = (FILE_PARSE(FILE)).NAME_EXT                                                     ; Add the file "name" to the D3 database
        FRTHASH['FILE_DB','DATE_RANGE',SEQ] = DRANGE                                                                          ; Add the "daterange" to the D3 database
        FRTHASH['FILE_DB','INPUT_FILES',SEQ] = FILE                                                                        ; Add the "input" files to the D3 database
        FRTHASH['FILE_DB','ORIGINAL_FILES',SEQ] = STRJOIN(DB[ISQ].INPUT_FILES,';')

        ; ===> Remap L3B array to a 2-dimensional array
        ARR = MAPS_L3BGS_SWAP(MAPS_L3B_2ARR(ARRAY,MP=AMAP,BINS=INPUT_FILE_BINS),L3BGS_MAP=L3BGS_MAP,MAP_SUBSET=MPSUBSET,GSSUBS=GSSUBS,L3SUBS=L3SUBS,L3OCEAN_SUBS=L3OCEAN_SUBS,SUBSET_STRUCT=SUBSET_STRUCT)
        
        ; ===> Run frontal algorithm
        PLUN, LUN, 'Calculating FRONTS for ' + PER, 0
        CASE ALG OF
          'BOA': GRAD = FRONTS_BOA(ARR, LOG=LOG, GRAD_TAG=FPROD, EPSILON=EPSILON, WIDTH=SWIDTH, HEIGHT=SHEIGHT, AZIMUTH=SAZIMUTH, LANDMASK=SLANDMASK)
          ELSE: MESSAGE, 'ERROR: Invalid frontal algorithm'
        ENDCASE
        
        ; ===> Determine the frontal threshold
        FOR B=0, N_ELEMENTS(THRESHBOX)-1 DO BEGIN
          BX = NUM2STR(THRESHBOX[B])
          PLUN, LUN, 'Calculating FRONTAL THRESHOLD (BOX=' + BX + ') for ' + PER, 0
          TB = BYTARR(SPX,SPY)
          THRESH = FRONTS_THRESHOLD(GRAD.(WHERE(TAG_NAMES(GRAD) EQ FPROD)), PIXELBOX=THRESHBOX[B], SUBS=TSUBS, VALID_PERCENT=VALID_PERCENT,MEDIAN_THRESHOLD=MEDIAN_THRESHOLD)
          TB[TSUBS] = 1
          GFRTHASH['THRESHOLD_MEDIAN_BOX'+BX,SEQ] = MEDIAN_THRESHOLD
          KFRTHASH['THRESHOLD_MEDIAN_BOX'+BX,SEQ] = MEDIAN_THRESHOLD
          DFRTHASH['THRESHOLD_MEDIAN_BOX'+BX,SEQ] = MEDIAN_THRESHOLD
          GRAD = CREATE_STRUCT(GRAD,'GRAD'+GPROD+'_FRONT_BOX'+BX,TB)
        ENDFOR
       
        ; ===> Loop through tags and add to the respective HASH files 
        TAGS = TAG_NAMES(GRAD)
        FOR T=0, N_ELEMENTS(TAGS)-1 DO BEGIN
          OPROD = TAGS[T] 
          IF ~HAS(OPRODS,OPROD) THEN CONTINUE
          GSARR = GRAD.(T)
          
          ; ===> Convert gs2 maps back to l3b
          IF ANY(L3OCEAN_SUBS) THEN BEGIN
            IF N_ELEMENTS(GSARR) NE N_ELEMENTS(ARR) THEN MESSAGE, 'ERROR: Input and output array sizes are not the same'
            BLK = MAPS_BLANK(L3BGS_MAP,FILL=MISSINGS(GSARR))
            BLK[SUBSET_STRUCT.LONMIN:SUBSET_STRUCT.LONMAX,SUBSET_STRUCT.LATMIN:SUBSET_STRUCT.LATMAX] = GSARR
          ENDIF ELSE BLK = GSARR

          L3ARR = MAPS_L3BGS_SWAP(BLK)
          IF GFRTHASH.HASKEY(OPROD) THEN GFRTHASH[OPROD,*,*,SEQ] = L3ARR[SUBS]
          IF KFRTHASH.HASKEY(OPROD) THEN KFRTHASH[OPROD,*,*,SEQ] = L3ARR[SUBS]
          IF DFRTHASH.HASKEY(OPROD) THEN DFRTHASH[OPROD,*,*,SEQ] = L3ARR[SUBS]          
        ENDFOR ; TAGS               
      ENDFOR ; DB.PERIODS
          
      ; ===> Fill in the output HASH
      GFRTHASH['FILE_DB'] = FRTHASH['FILE_DB'] & GFRTHASH['FILE_DB','FULLNAME'] = GOUTFILE
      KFRTHASH['FILE_DB'] = FRTHASH['FILE_DB'] & KFRTHASH['FILE_DB','FULLNAME'] = KOUTFILE
      DFRTHASH['FILE_DB'] = FRTHASH['FILE_DB'] & DFRTHASH['FILE_DB','FULLNAME'] = DOUTFILE

      ; ===> Add the AZIMUTH data to the HASH
      AZI = MAPS_L3BGS_SWAP(AZIMUTH)
      BLK = FLTARR(1,N_ELEMENTS(OCEBINS))
      BLK[0,*] = AZI[OCEBINS-1]
      DFRTHASH['AZIMUTH'] = BLK
            
      ; ===> Update the metadata and save the HASH file
      IF KEYWORD_SET(WRITEFILE) THEN BEGIN
        GFRTHASH['METADATA'] = D3HASH_METADATA(GOUTFILE, DB=GFRTHASH['FILE_DB'])
        PLUN, LUN, 'Writing ' + GOUTFILE
        SAVE, GFRTHASH, FILENAME=GOUTFILE, /COMPRESS
        
        KFRTHASH['METADATA'] = D3HASH_METADATA(KOUTFILE, DB=KFRTHASH['FILE_DB'])
        PLUN, LUN, 'Writing ' + KOUTFILE
        SAVE, KFRTHASH, FILENAME=KOUTFILE, /COMPRESS
        
        DFRTHASH['METADATA'] = D3HASH_METADATA(DOUTFILE, DB=DFRTHASH['FILE_DB'])
        PLUN, LUN, 'Writing ' + DOUTFILE
        SAVE, DFRTHASH, FILENAME=DOUTFILE, /COMPRESS                                                                          ; Save the file
      ENDIF
      FRTHASH = []
      GFRTHASH = []
      KFRTHASH = []
      DFRTHASH = []
      
    ENDFOR ; ALG
  ENDFOR ; FILES

END ; ***************** End of STACKED_MAKE_FRONTS *****************
