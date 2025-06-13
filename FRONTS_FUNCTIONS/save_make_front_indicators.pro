; $ID:	SAVE_MAKE_FRONT_INDICATORS.PRO,	2023-09-21-13,	USER-KJWH	$
  PRO SAVE_MAKE_FRONT_INDICATORS, GRAD_FILES, $
        ALGORITHM=ALGORITHM, PERIOD_CODE=PERIOD_CODE, MAP_OUT=MAP_OUT, NC_MAP=NC_MAP, $
        SST_THRESHOLD=SST_THRESHOLD, CHL_THRESHOLD=CHL_THRESHOLD, SST_PERSISTENCE=SST_PERSISTENCE, CHL_PERSISTENCE=CHL_PERSISTENCE, $
        BATHY_REF=BATHY_REF, DIR_OUT=DIR_OUT, LOGLUN=LOGLUN, NETCDF=NETCDF, INIT=INIT, OVERWRITE=OVERWRITE, VERBOSE=VERBOSE

;+
; NAME:
;   SAVE_MAKE_FRONT_INDICATORS
;
; PURPOSE:
;   Create .SAV and .NC files of frontal indicators
;
; CATEGORY:
;   FRONTS_FUNCTIONS
;
; CALLING SEQUENCE:
;   SAVE_MAKE_FRONT_INDICATORS, FILES
;
; REQUIRED INPUTS:
;   GRAD_FILES.......... Input D3 GRAD_MAG files 
;
; OPTIONAL INPUTS:
;   ALGORITHM........... To indicate which algorithm functions to run
;   PERIOD_CODE......... The period code for the output products
;   MAP_OUT............. The output map if different from the input data 
;   NC_MAP.............. The netcdf map if different from the input data
;   BATHY_REF........... Used in [Add name of function that compares the frontal data to a bathymetry line]
;   SST_THRESHOLD....... Threshold value for the SST fronts
;   CHL_THRESHOLD....... Threshold value for the CHL fronts
;   DIR_OUT............. The output directory for the .SAV files (the netcdf output will be created if the NETCDF keyword is set)
;   LOGLUN.............. LUN for writing information to the LOG file
;
; KEYWORD PARAMETERS:
;   NETCDF.............. Create NETCDF output files from the .SAV files
;   INIT................ Reinitialize the COMMON MAP structure
;   OVERWRITE........... Overwrite files if they already exist
;   VERBOSE............. Print out processing steps
;
; OUTPUTS:
;   .SAV files with nested structures for the different frontal metrics
;
; OPTIONAL OUTPUTS:
;   .NC files created from the nested structure .SAV files
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
; Copyright (C) 2021, Department of Commerce, National Oceanic and Atmospheric Administration, National Marine Fisheries Service,
;   Northeast Fisheries Science Center, Narragansett Laboratory.
;   This software may be used, copied, or redistributed as long as it is not sold and this copyright notice is reproduced on each copy made.
;   This routine is provided AS IS without any express or implied warranties whatsoever.
;
; AUTHOR:
;   This program was written on March 19, 2021 by Kimberly J. W. Hyde, Northeast Fisheries Science Center | NOAA Fisheries | U.S. Department of Commerce, 28 Tarzwell Dr, Narragansett, RI 02882
;    
; MODIFICATION HISTORY:
;   Mar 19, 2021 - KJWH: Initial code written
;   Jun 29, 2021 - KJWH: Updated to work with the new D3HASH files
;                        Removed ORGDIR (not needed with the D3HASH files)
;-
; ****************************************************************************************************
  ROUTINE_NAME = 'SAVE_MAKE_FRONT_INDICATORS'
  COMPILE_OPT IDL2
  SL = PATH_SEP()
  
  
  COMMON SAVE_MAKE_FRONT_INDICATORS_, STRUCT_MAPS
  IF NONE(STRUCT_MAPS) OR KEY(INIT) THEN STRUCT_MAPS=[]
  
  IF N_ELEMENTS(GRAD_FILES) EQ 0 THEN MESSAGE, 'ERROR: Must provide input gradient magnitude D3 files.'
  
  ; ===> Defaults
  IF N_ELEMENTS(PERIOD_CODE)     EQ 0 THEN PERS = 'W' ELSE PERS = PERIOD_CODE
  IF N_ELEMENTS(ALGORITHMS)      EQ 0 THEN ALGS = 'MILLER' ELSE ALGS = ALGORITHMS
  IF N_ELEMENTS(SST_THRESHOLD)   EQ 0 THEN SST_THRESHOLD = 0.4
  IF N_ELEMENTS(CHL_THRESHOLD)   EQ 0 THEN CHL_THRESHOLD = 0.06
  IF N_ELEMENTS(SST_PERSISTENCE) EQ 0 THEN SST_PERSISTENCE = 0.08
  IF N_ELEMENTS(CHL_PERSISTENCE) EQ 0 THEN CHL_PERSISTENCE = 0.08
  IF N_ELEMENTS(LOGLUN)          NE 1 THEN LOG_LUN = [] ELSE LOG_LUN = LOGLUN
  
  
  FOR F=0, N_ELEMENTS(GRAD_FILES)-1 DO BEGIN
    D3_FILE = GRAD_FILES[F]
;    IF STRPOS(D3_FILE,'-D3_DAT.FLT') LT 0 THEN MESSAGE, 'ERROR: The input file MUST be a D3_DAT.FLT file'
;    D3_DB_FILE    = REPLACE(D3_FILE, '-D3_DAT.FLT','-D3_DB.SAV')
;    D3_METAFILE   = REPLACE(D3_FILE, '-D3_DAT.FLT','-D3_METADATA.SAV')
;    D3_BINS_FILE  = REPLACE(D3_FILE, '-D3_DAT.FLT','-D3_BINS.SAV')
;    GRADX_D3      = REPLACE(D3_FILE, 'GRAD_',      'GRADX_')
;    GRADY_D3      = REPLACE(D3_FILE, 'GRAD_',      'GRADY_')
;    GRADX_DB_FILE = REPLACE(GRADX_D3,'-D3_DAT.FLT','-D3_DB.SAV')
;    GRADY_DB_FILE = REPLACE(GRADX_D3,'-D3_DAT.FLT','-D3_DB.SAV')
;    INPUT_FILES   = [D3_FILE,D3_DB_FILE,D3_METAFILE,GRADX_D3,GRADY_D3,GRADX_DB_FILE,GRADY_DB_FILE]
;    IF TOTAL(FILE_TEST(INPUT_FILES)) NE N_ELEMENTS(INPUT_FILES) THEN MESSAGE, 'ERROR: One of the D3 file(s) does not exist.'
        
    ; ===> Get dimensions, map and prod from the D3_FILE
    FA=PARSE_IT(D3_FILE,/ALL) & PX=LONG(FA.PX) & PY=LONG(FA.PY) & PZ=LONG(FA.PZ) & MAPP=FA.MAP & PROD=FA.PROD
    IF N_ELEMENTS(MAP_OUT) EQ 0 THEN MP_OUT = FA.MAP ELSE MP_OUT = MAP_OUT
;    IF HAS(D3_FILE,'L3B') THEN BINS = IDL_RESTORE(D3_BINS_FILE) ELSE BINS = []                  ; Get the BIN information if a L3B map
    
    ; ===> Get the D3 file of the "original" input data
;    IF N_ELEMENTS(ORGDIR) NE 1 THEN BEGIN
;      CASE NCI.INDATA_PROD OF 
;        'CHLOR_A': ODIR = !S.OC
;        'SST':     ODIR = !S.SST 
;      ENDCASE
;      ODIR = ODIR + FA.SENSOR + SL + FA.MAP + SL + 'STACKED_FILES' + SL + 'DD_D3' + SL + NCI.INDATA_PROD+'-'+NCI.INDATA_ALG + SL
;      IF HAS(NCI.INDATA_ALG,';') THEN ODIR = REPLACE(ODIR,'-'+NCI.INDATA_ALG,'')
;    ENDIF ELSE ODIR = ORGDIR
;    IF FILE_TEST(ODIR,/DIR) EQ 0 THEN  MESSAGE, 'ERROR: ' + ODIR + ' not found.'
;    D3_OFILE = FILE_SEARCH(ODIR + FA.PERIOD + '*-D3_DAT.FLT',COUNT=COUNTO)
;    IF COUNTO GT 1 THEN MESSAGE, 'ERROR: More than one "original" file found.'
;    IF COUNTO EQ 1 THEN BEGIN
;      ORG_DB_FILE    = REPLACE(D3_OFILE, '-D3_DAT.FLT','-D3_DB.SAV')
;      ORG_METAFILE   = REPLACE(D3_OFILE, '-D3_DAT.FLT','-D3_METADATA.SAV')
;      ORG_BINS_FILE  = REPLACE(D3_OFILE, '-D3_DAT.FLT','-D3_BINS.SAV')
;      IF BINS NE [] THEN OBINS = IDL_RESTORE(ORG_BINS_FILE) 
;    ENDIF ELSE MESSAGE, 'ERROR: "Original" data file not found.'


    ; ===> Read the data from the D3 files
    D3 = IDL_RESTORE(D3_FILE)                                                   ; Read the D3 HASH file
    KEYS = D3.KEYS()
    DB = D3['D3_DB'].TOSTRUCT()
    BINS = D3['BINS']

    ; ===> Get the metadata from the D3 file
    META = D3['METADATA']
    MTAGS = TAG_NAMES(META)

    IF HAS(MTAGS,'GRAD_CHL') THEN GPROD='GRAD_CHL' ELSE GPROD = 'GRAD_SST'
    CASE GPROD OF
      'GRAD_SST': BEGIN & PLOG=0 & OPROD='GRADSST_INDICATORS' & THRESHOLD=SST_THRESHOLD & PERSISTENCE=SST_PERSISTENCE & DPRODS='D3_'+['GRAD','GRADX','GRADY']+'_SST' & ORGPROD='SST'     & ORG=D3['D3_SST'] & END
      'GRAD_CHL': BEGIN & PLOG=1 & OPROD='GRADCHL_INDICATORS' & THRESHOLD=CHL_THRESHOLD & PERSISTENCE=CHL_PERSISTENCE & DPRODS='D3_'+['GRAD','GRADX','GRADY']+'_CHL' & ORGPROD='CHLOR_A' & ORG=D3['D3_CHLOR_A'] & END
    ENDCASE
    GRAD_MAG = D3[DPRODS[0]]     & IF SIZE(GRAD_MAG,/N_DIMENSIONS) EQ 2 THEN GRAD_MAG = ADD_DIM(GRAD_MAG,0,1)
    GRAD_X   = D3[DPRODS[1]]     & IF SIZE(GRAD_X,/N_DIMENSIONS)   EQ 2 THEN GRAD_X   = ADD_DIM(GRAD_X,0,1)
    GRAD_Y   = D3[DPRODS[2]]     & IF SIZE(GRAD_Y,/N_DIMENSIONS)   EQ 2 THEN GRAD_Y   = ADD_DIM(GRAD_Y,0,1)
    ODAT     = D3['D3_'+ORGPROD] & IF SIZE(ODAT,/N_DIMENSIONS)     EQ 2 THEN ODAT     = ADD_DIM(ODAT,0,1)
    GONE, D3
    
    ; ===> Read the D3_DB file
    
    
;    DB  = STRUCT_READ(D3_DB_FILE) & N_FILES=NOF(DB) 
;    XDB = STRUCT_READ(GRADX_DB_FILE) & OK = WHERE(DB.PERIOD NE XDB.PERIOD, CTX) & IF CTX GT 0 THEN MESSAGE, 'ERROR: The periods in the GRAD_MAG and GRAD_X DB files do not match.'
;    YDB = STRUCT_READ(GRADX_DB_FILE) & OK = WHERE(DB.PERIOD NE YDB.PERIOD, CTY) & IF CTY GT 0 THEN MESSAGE, 'ERROR: The periods in the GRAD_MAG and GRAD_Y DB files do not match.'
;    ODB = STRUCT_READ(ORG_DB_FILE)   & OK = WHERE(DB.PERIOD NE ODB.PERIOD, CTO) & IF CTO GT 0 THEN MESSAGE, 'ERROR: The periods in the original data DB files do not match.'
;    IF KEY(VERBOSE) THEN PLUN, LOG_LUN,'N_FILES:  ' ,N_FILES

    ; ===> Loop on MAPS
    FOR M=0, N_ELEMENTS(MP_OUT)-1 DO BEGIN
      MP = MP_OUT[M]     
      IF N_ELEMENTS(NC_MAP) EQ 1 THEN NCMAP = NC_MAP ELSE NCMAP = MP
          
      FOR R=0, N_ELEMENTS(PERS)-1 DO BEGIN
        ; ===> Get the number of files from the DB and determine the output periods
        SETS = PERIOD_SETS(PERIOD_2JD(DB.PERIOD),PERIOD_CODE=PERS[R])
        DBSUBS = SETS.SUBS
        PERIODS = SETS.PERIOD
        
        FOR A=0, N_ELEMENTS(ALGS)-1 DO BEGIN
          ALG = ALGS[A]
          ; ===> Establish the product information
          
          
          PROD_ALG = OPROD + '-'+ALG
          ; ===> Create the output directories
          IF NONE(DIR_OUT) THEN BEGIN
            FP = FA
            COUNTER = 0
            WHILE FP.SUB NE 'STACKED_FILES' DO BEGIN
              COUNTER = COUNTER + 1
              IF COUNTER GT 5 OR FP.SUB EQ 'DATASETS' THEN MESSAGE, 'ERROR: Unable to create the output directory'
              FP = FILE_PARSE(REPLACE(FP.DIR,FP.SUB+SL,''))
            ENDWHILE
            DIR_SAVE = REPLACE(FP.DIR,[FA.MAP,'STACKED_FILES'],[MP,'SAVE'])+ PROD_ALG + SL
          ENDIF ELSE DIR_SAVE = DIR_OUT
          DIR_TEST, DIR_SAVE
          
          DIR_NC = REPLACE(DIR_SAVE,['SAVE',FA.MAP],['NETCDF',NCMAP]) & DIR_TEST, DIR_NC
          CASE PERS OF
            'D': PERIOD_OUT = PERS+PERS+'_'+STRMID(FA.DATE_START,0,8)+'_'+STRMID(FA.DATE_END,0,8)
            'W': PERIOD_OUT = PERS+PERS+'_'+FA.YEAR_START+DATE_2WEEK(FA.DATE_START)+'_'+FA.YEAR_END+DATE_2WEEK(FA.DATE_END)
            'M': PERIOD_OUT = PERS+PERS+'_'+FA.YEAR_START+FA.MONTH_START+'_'+FA.YEAR_END+FA.MONTH_END
          ENDCASE
          
          NC_FILE = DIR_NC + STRJOIN([PERIOD_OUT,FA.SENSOR,FA.METHOD,NCMAP,PROD_ALG],'-') + '.nc'
                    
          SAVEFILES = []
          FOR S=0, N_ELEMENTS(PERIODS)-1 DO SAVEFILES = [SAVEFILES,DIR_SAVE + REPLACE(FA.NAME,[FA.PERIOD,FA.MAP,FA.PROD,'-'+FA.ALG,'-D3_DAT'],[PERIODS[S],MP,PROD_ALG,'','']) + '.SAV']
          IF FILE_MAKE(D3_FILE,SAVEFILES,OVERWRITE=OVERWRITE) EQ 0 THEN GOTO, MAKE_NETCDF 

          ; ===> Read the data from the D3 files
;          IF IS_SHM(D3_FILE) THEN SHMUNMAP,'D3'                                       ; Make sure there are no D3 files with mapped shared memory
;          OPENR, D3_LUN, D3_FILE, /GET_LUN                                            ; Read the D3 GRAD_MAG file
;          SHMMAP, 'D3', /FLOAT, DIMENSION=[PX,PY,N_FILES], FILENAME=D3_FILE           ; Map the D3 array to the D3_FILE
;          GRAD_MAG = SHMVAR('D3')                                                     ; Get the D3 array 
;          SHMUNMAP,'D3'                                                               ; Unmap the shared memory
;          FLUSH, D3_LUN & CLOSE, D3_LUN & FREE_LUN, D3_LUN                            ; Free up the logical units
;          
;          IF IS_SHM(GRADX_D3) THEN SHMUNMAP,'X3'                                      ; Make sure there are no X3 files with mapped shared memory
;          OPENR, X3_LUN, GRADX_D3, /GET_LUN                                           ; Read the D3 GRAD_X file
;          SHMMAP, 'X3', /FLOAT, DIMENSION=[PX,PY,N_FILES], FILENAME=GRADX_D3          ; Map the D3 array to the GRADX_D3
;          GRAD_X = SHMVAR('X3')                                                       ; Get the D3 GRAD_X array 
;          SHMUNMAP,'X3'                                                               ; Unmap the shared memory
;          FLUSH, X3_LUN & CLOSE, X3_LUN & FREE_LUN, X3_LUN                            ; Free up the logical units
;          
;          IF IS_SHM(GRADY_D3) THEN SHMUNMAP,'Y3'                                      ; Make sure there are no Y3 files with mapped shared memory
;          OPENR, Y3_LUN, GRADY_D3, /GET_LUN                                           ; Read the D3 GRAD_Y file
;          SHMMAP, 'Y3', /FLOAT, DIMENSION=[PX,PY,N_FILES], FILENAME=GRADY_D3          ; Map the D3 array to the GRADY_D3
;          GRAD_Y = SHMVAR('Y3')                                                       ; Get the D3 GRAD_Y array
;          SHMUNMAP,'Y3'                                                               ; Unmap the shared memory
;          FLUSH, Y3_LUN & CLOSE, Y3_LUN & FREE_LUN, Y3_LUN                            ; Free up the logical units
;          
;          IF IS_SHM(D3_OFILE) THEN SHMUNMAP,'O3'                                      ; Make sure there are no O3 files with mapped shared memory
;          OPENR, O3_LUN, D3_OFILE, /GET_LUN                                           ; Read the D3 original file
;          SHMMAP, 'O3', /FLOAT, DIMENSION=[PX,PY,N_FILES], FILENAME=D3_OFILE          ; Map the D3 array to the D3_OFILE
;          ODAT = SHMVAR('O3')                                                         ; Get the D3 original array
;          SHMUNMAP,'O3'                                                               ; Unmap the shared memory
;          FLUSH, O3_LUN & CLOSE, O3_LUN & FREE_LUN, O3_LUN                            ; Free up the logical units
          
          ; ===> Loop through the PERIODS_SETS periods
          FOR S=0, N_ELEMENTS(PERIODS)-1 DO BEGIN
            APER = PERIODS[S]
            
            ; ===> Create the output NC file name
            SAVFILE = SAVEFILES[S]
            IF FILE_MAKE(D3FILE, SAVFILE,OVERWRITE=OVERWRITE) EQ 0 THEN CONTINUE
            
            ; ===> Get the subscripts for the period and list of original input files
            SUBS = STRSPLIT(DBSUBS[S],';',/EXTRACT)
            INFILES = DB.FULLNAME[SUBS]
            ORGFILES = DB.ORIGINAL_FILES[SUBS]
          
            ; ===> Loop through files
            GM = FLTARR(PX,PY,N_ELEMENTS(SUBS)) & GM[*] = MISSINGS(GM) & GX = GM & GY = GM & OD = GM; Create blank data arrays
            FOR F=0,N_ELEMENTS(SUBS)-1L DO BEGIN
              SUB = FIX(SUBS[F])
              GM[*,*,F] = GRAD_MAG[*,*,SUB]
              GX[*,*,F] = GRAD_X[*,*,SUB]
              GY[*,*,F] = GRAD_Y[*,*,SUB]
              OD[*,*,F] = ODAT[*,*,SUB]
            ENDFOR
            
 ; IF MIN(GX) LT 0.0 OR MIN(GY) LT 0.0 THEN MESSAGE, 'ERROR: Need to look at the negative values.'
  
            CASE ORGPROD OF
              'SST': OMEAN = MEAN(OD,/NAN,DIMENSION=3)
              'CHLOR_A': OMEAN = EXP(MEAN(ALOG(OD),/NAN,/DOUBLE,DIMENSION=3))
            ENDCASE
            OMEAN[WHERE(FINITE(OMEAN) EQ 0)] = MISSINGS(OMEAN)
            
            CASE ALG OF 
              'MILLER': GSTR = FRONT_INDICATORS_MILLER(GRAD_MAG=GM, GRAD_X=GX, GRAD_Y=GY, TRANSFORM=PLOG, THRESHOLD=THRESHOLD, PERSISTENCE=PERSISTENCE)
            ENDCASE
            
            ; ===> Remove the values where FCLEAR is 0 to save space
            CLEAR = WHERE(GSTR.FLEAR EQ 0)
            
; Place holder for the code to remap the data and run the spatial metrics            
                        
            
            ; ===> Rename the structure tags
            CASE OPROD OF 
              'GRADSST_INDICATORS': FTAG = 'GRADSST_'
              'GRADCHL_INDICATORS': FTAG = 'GRADCHL_'
            ENDCASE
            
            GSTR = STRUCT_RENAME(GSTR,TAG_NAMES(GSTR),FTAG+TAG_NAMES(GSTR),/STRUCT_ARRAYS)
            GSTR = CREATE_STRUCT((ORGPROD),OMEAN,GSTR)
                       
            ; ===> Save the structure
            STRUCT_WRITE, GSTR, FILE=SAVFILE, PROD=OPROD, MAP=MP, THRESHOLD=THRESHOLD, LOGLUN=LOG_LUN, BINS=BINS, $
              INFILE=D3_FILE,INPUT_PROD=FA.PROD, INDATA_ALG=FA.ALG, INDATA_UNITS=UNITS(FA.PROD,/SI), $
              INPUTF_FILES=INFILES, ORIGINAL_FILEINFO=ORG, ORIGINAL_FILES=ORGFILES,$
              NOTES='FRONTAL_INDICATORS'+ALG+'-'+DATE_NOW(/DATE_ONLY)
  
          ENDFOR ; PERIODS (FROM PERIOD_SETS)
        
          MAKE_NETCDF:
          OK = WHERE(FILE_TEST(SAVEFILES) EQ 1, COUNT)
          IF COUNT EQ 0 THEN CONTINUE
          INFILES = SAVEFILES[OK]
          IF FILE_MAKE(INFILES, NC_FILE, OVERWRITE=OVERWRITE) EQ 0 THEN CONTINUE
          NCI = NETCDF_INFO(INFILES, DIR_SUITE='FRONTS')

          LAND = READ_LANDMASK(NCMAP,/STRUCT)                                                           ; Read the landmask for the output map
          MSZ = MAPS_SIZE(NCMAP,PX=MPX,PY=MPY)                                                          ; Get the dimensions of the output map
          MAP_TAG = MP + 'PXY_' + STRJOIN(NUM2STR([MPX,MPY]),'_')                                       ; Create a tag name for the COMMON map structure
          IF STRUCT_MAPS NE [] THEN OK_TAG = WHERE(TAG_NAMES(STRUCT_MAPS) EQ MAP_TAG,COUNT) ELSE COUNT = 0 
        
          IF COUNT NE 1 THEN BEGIN                                                                      ; Only get map information if it is different from the previous file
            MI = MAPS_INFO(NCMAP)                                                                       ; Get standard information about the "MAP"
            MR = MAPS_READ(NCMAP)                                                                       ; Read the "MAP" information
            LL = MAPS_2LONLAT(NCMAP,LONS=LONS,LATS=LATS)                                                ; Get the LONS and LATS of the "MAP"
            SZLAT = SIZEXYZ(LATS,PX=PXLAT,PY=PYLAT)                                                     ; Get the size dimensions of the LAT array
            SZLON = SIZEXYZ(LONS,PX=PXLON,PY=PYLON)                                                     ; Get the size dimensions of the LON array
            IF SAME(LATS[*,0]) AND SAME(LATS[*,-1]) AND SAME(LONS[0,*]) AND SAME(LONS[-1,*]) THEN BEGIN ; Look for "gridded" map coordinates
              LATS = REFORM(LATS[0,*])                                                                  ; Create 1D latitude array
              LONS = REFORM(LONS[*,0])                                                                  ; Create 1D longitude array
              LONLAT_1D=1
            ENDIF ELSE LONLAT_1D=0
            IF KEY(LONLAT_1D) AND (N_ELEMENTS(LATS) NE PYLAT OR N_ELEMENTS(LONS) NE PXLON) THEN MESSAGE, 'ERROR: Check the lon/lat dimensions.'
            LONRES = ROUNDS(MEAN([MI.V_SCALE_LEFT,MI.V_SCALE_MID,MI.V_SCALE_RIGHT])/111.0,3)            ; Get the LON resolution
            LATRES = ROUNDS(MEAN([MI.H_SCALE_LOWER,MI.H_SCALE_MID,MI.H_SCALE_UPPER])/111.0,3)           ; Get the LAT resolution
            SPARES = ROUNDS(MEAN([MI.V_SCALE_LEFT,MI.V_SCALE_MID,MI.V_SCALE_RIGHT,MI.H_SCALE_LOWER,MI.H_SCALE_MID,MI.H_SCALE_UPPER])/111.0,3) ; Get the spatial resolution
            MPSTRUCT = CREATE_STRUCT('MAP',NCMAP,'MAP_INFO',MI,'MAP_READ',MR,'LONLAT_1D',LONLAT_1D,'PXLON',PXLON,'PYLAT',PYLAT,'LATS',LATS,'LONS',LONS,'LATRES',LATRES,'LONRES',LONRES,'SPARES',SPARES)
            STRUCT_MAPS = [STRUCT_MAPS,MPSTRUCT]
          ENDIF ELSE MPSTRUCT = STRUCT_MAPS[OK_TAG]
        
          
          ; ===> Set up arrays for each product in the structure
          D = STRUCT_READ(INFILES[0],STRUCT=STR)
          
          ; ===> Determine the prod type (SST or CHL)
          CASE STR.PROD OF
            'GRADSST_INDICATORS': FTAG = 'GRADSST_'
            'GRADCHL_INDICATORS': FTAG = 'GRADCHL_'
          ENDCASE
          
          TAGS = TAG_NAMES(STR)
          ATAGS = []
          FOR T=0, N_TAGS(STR)-1 DO BEGIN
            SZS = SIZEXYZ(STR.(T),N_DIMENSIONS=NDIMS)
            IF NDIMS EQ 2 THEN ATAGS = [ATAGS,TAGS[T]]
          ENDFOR  
          DAT = FLTARR(PXLAT,PYLAT,N_ELEMENTS(INFILES),N_ELEMENTS(ATAGS))
          MASK = INTARR(PXLAT,PYLAT,N_ELEMENTS(INFILES))
          FOR N=0, N_ELEMENTS(INFILES)-1 DO BEGIN
            D = STRUCT_READ(INFILES[N],STRUCT=STR)
            
            ; Create a structure with all of the data products for the input files
            C = 0
            FOR T=0, N_TAGS(STR)-1 DO BEGIN
              IF ~HAS(ATAGS,TAGS[T]) THEN CONTINUE
              IF TAGS[T] EQ ORGPROD THEN BINS=STR.ORIGINAL_BINS ELSE BINS=STR.BINS
              IF NCMAP NE STR.MAP THEN DAT[*,*,N,C] = MAPS_REMAP(STR.(T),MAP_IN=STR.MAP,MAP_OUT=NCMAP,BINS=OBINS) $
                                  ELSE DAT[*,*,N,C] = STR.(T)
              C = C+1                    
            ENDFOR
  
            ; ===> Make a mask for the output data
            MSK = MASK[*,*,N]                                                                   ; Make a subset mask for each INFILE
            CTAG = WHERE(ATAGS EQ FTAG+'FCLEAR', COUNTC)                                        ; Find the FCLEAR tag
            VTAG = WHERE(ATAGS EQ FTAG+'FVALID', COUNTV)                                        ; Find the FVALID tag 
            IF COUNTC + COUNTV NE 2 THEN MESSAGE, 'ERROR: FCLEAR and FVALID tags not found.'    ; Check that both tags were found
            COK = WHERE(DAT[*,*,N,CTAG] EQ 0.0, COUNTC)                                         ; Find the cloudy pixels (CLEAR=0)
            VOK = WHERE(DAT[*,*,N,VTAG] EQ 0.0, COUNTV)                                         ; Find the pixels without fronts (VALID=0)
            FOK = WHERE(DAT[*,*,N,VTAG] GT 0.0, COUNTF)                                         ; Find the pixels with fronts (VALID=1)
            IF COUNTC GT 0 THEN MSK[COK] = 3                                                    ; Add the cloudy pixels to the mask
            IF COUNTV GT 0 THEN MSK[VOK] = 4                                                    ; Add the non-front pixels to the mask
            IF COUNTF GT 0 THEN MSK[FOK] = 5                                                    ; Add the front pixels to the mask
            MSK[LAND.LAND] = 1                                                                  ; Add the land pixels to the mask
            MSK[LAND.COAST] = 2                                                                 ; Add the coast pixels to the mask
            MASK[*,*,N] = MSK                                                                   ; Put the subset mask back into the full mask array
            
          ENDFOR ; INFILES 
          
          ; ===> Make a MAST structure
          MASK_CODES = [1,2,3,4,5]                                                                
          MASK_NAMES = ['Land', 'Coast', 'Missing data', 'Non-front', 'Front']
          MASK_NOTES = 'Mask codes for the frontal indicators are: '
          FOR K=0, N_ELEMENTS(MASK_CODES)-1 DO MASK_NOTES = MASK_NOTES + STRTRIM(MASK_CODES[K],2)+'='+MASK_NAMES[K]+'; '
          MASK_NOTES = STRMID(MASK_NOTES,0,STRLEN(MASK_NOTES)-2)                                ; Remove the last '; '
          MSTR = CREATE_STRUCT('MASK',MASK, 'MASK_CODES', MASK_CODES, 'MASK_NAMES', MASK_NAMES, 'MASK_NOTES', MASK_NOTES)
          
          IFP = FILE_PARSE(INFILES)
          SAVFILES = STRJOIN(IFP.NAME_EXT,';')
          FRONT_INDICATORS_2NETCDF, DAT, TAGS=ATAGS, MAPSTRUCT=MPSTRUCT, METASTRUCT=NCI, MASKSTRUCT=MSTR, NCFILE=NC_FILE, SAVFILES=SAVFILES
        ENDFOR ; ALGS
      ENDFOR ; MAPS
    ENDFOR ; PERS (PERIOD_CODES)
  ENDFOR ; GRAD_FILES



END ; ***************** End of SAVE_MAKE_FRONT_INDICATORS *****************
