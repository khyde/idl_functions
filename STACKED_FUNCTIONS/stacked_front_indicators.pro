; $ID:	STACKED_FRONT_INDICATORS.PRO,	2023-09-21-13,	USER-KJWH	$
  PRO STACKED_FRONT_INDICATORS, GRAD_FILES, $
         ALGORITHM=ALGORITHM, PERIOD_CODE=PERIOD_CODE, MAP_OUT=MAP_OUT, NC_MAP=NC_MAP, $
         OUT_PRODS=OUT_PRODS, SST_PERSISTENCE=SST_PERSISTENCE, CHL_PERSISTENCE=CHL_PERSISTENCE, $
         BATHY_REF=BATHY_REF, DIR_OUT=DIR_OUT, LOGLUN=LOGLUN, NETCDF=NETCDF, INIT=INIT, OVERWRITE=OVERWRITE, VERBOSE=VERBOSE

;+
; NAME:
;   STACKED_FRONT_INDICATORS
;
; PURPOSE:
;   Create .SAV and .NC files of frontal indicators
;
; CATEGORY:
;   FRONTS_FUNCTIONS
;
; CALLING SEQUENCE:
;   STACKED_MAKE_PRODS_FRONT_INDICATORS, FILES
;
; REQUIRED INPUTS:
;   GRAD_FILES.......... Input D3 GRAD_MAG files 
;
; OPTIONAL INPUTS:
;   ALGORITHM........... To indicate which algorithm functions to run
;   PERIOD_CODE......... The period code for the output products
;   MAP_OUT............. The output map if different from the input data 
;   NC_MAP.............. The netcdf map if different from the input data
;   OUT_PRODS........... An array of output products from the FRONTS_INDICATORS to keep in the file
;   BATHY_REF........... Used in [Add name of function that compares the frontal data to a bathymetry line]
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
;   This program was written on July 09, 2021 by Kimberly J. W. Hyde, Northeast Fisheries Science Center | NOAA Fisheries | U.S. Department of Commerce, 28 Tarzwell Dr, Narragansett, RI 02882
;    
; MODIFICATION HISTORY:
;   Jul 09, 2021 - KJWH: Initial code written - adapted from SAVE_MAKE_FRONT_INDICATORS
;   Jul 19, 2021 - KJWH: Update a bug to fix how the data are added to the D3HASH
;   Oct 21, 2021 - KJWH: Updated to work with the recent updates to D3HASH_MAKE
;                        Changed D3_DB to FILE_DB
;   Oct 26, 2021 - KJWH: Changed default output directory from SAVE to STACKED   
;   Nov 14, 2022 - KJWH: Changed D3HASH_2NETCDF to STACKED_2NETCDF  
;   Jul 31, 2023 - KJWH: Changed name to STACKED_FRONT_INDICATORS to be consistent with other STACKED functions  
;                        Changed SST_THRESHOLD and CHL_THRESHOLD to SST_THRESHOLD_BOX and CHL_THRESHOLD_BOX to reflect the change in how the frontal threshold is calculated
;   Aug 16, 2023 - KJWJ: Reworked program to loop on BOX threshold sizes and can now include data from a second year when the output period extends beyond a single year (e.g. D3, D8, SEA)
;                        Now looping on output periods and not the input files
;                        Still need to figure out how to work with the CUMULATIVE PERSISTANCE product              
;   
;-
; ****************************************************************************************************
  ROUTINE_NAME = 'STACKED_FRONT_INDICATORS'
  COMPILE_OPT IDL2
  SL = PATH_SEP()
  
  
  COMMON STACKED_FRONT_INDICATORS_, STRUCT_MAPS
  IF NONE(STRUCT_MAPS) OR KEY(INIT) THEN STRUCT_MAPS=[]
  
  IF N_ELEMENTS(GRAD_FILES) EQ 0 THEN MESSAGE, 'ERROR: Must provide input gradient magnitude D3 files.'
  
  ; ===> Defaults
  IF ~N_ELEMENTS(PERIOD_CODE)       THEN PERS = 'W'      ELSE PERS = PERIOD_CODE
  IF ~N_ELEMENTS(ALGORITHMS)        THEN ALGS = 'MILLER' ELSE ALGS = ALGORITHMS
  IF ~N_ELEMENTS(SST_PERSISTENCE)   THEN SST_PERSISTENCE = 0.3
  IF ~N_ELEMENTS(CHL_PERSISTENCE)   THEN CHL_PERSISTENCE = 1.08
  IF ~N_ELEMENTS(LOGLUN)            THEN LUN = [] ELSE LUN = LOGLUN
  IF ~N_ELEMENTS(OUT_PRODS)         THEN OUTPRODS = ['FCLEAR','FVALID','FMEAN','FPROB','FINTENSITY','FSTD','FPERSIST','FPERSISTPROB'] ELSE OUTPRODS = OUT_PRODS  ; ,'FPERSISTCUM'

  ; ===> Check the PERIOD, MAP, SENSOR and PRODUCT information based on the the input files
  FP = PARSE_IT(GRAD_FILES,/ALL)  
  IF ~SAME(FP.PERIOD_CODE) THEN MESSAGE, 'All input files are not from the same PERIOD'                                     ; Check to make sure all of the input PERIOD_CODES are the same
  IF ~SAME(FP.MAP)         THEN MESSAGE, 'ERROR: All input files must have the same "MAP".'                                 ; Check to make sure all of the input MAPS are the same
  IF ~SAME(FP.PROD_ALG)    THEN MESSAGE, 'ERROR: All input files must have the same "PROD" and "ALG".'                      ; Check to make sure all of the input PRODS and ALGS are the same
  IF ~SAME(FP.SENSOR)      THEN MESSAGE, 'ERROR: All input files do not have the same SENSOR'                               ; Check to make sure all of the input SENSORS are the same

 GP = PARSE_IT(GRAD_FILES,/ALL)

  ; ===> Loop on output period codes 
  FOR R=0, N_ELEMENTS(PERS)-1 DO BEGIN                                          
    
    ; ===> Set up PERIOD info
    PER = PERS[R]
    PERSTR = PERIODS_READ(PER)                                                                                              ; Get the PERIODS specific information for the output period
    PER_SETS = D3HASH_PERIOD_SETS(GP.FULLNAME, OUTPERIOD=PER)                                                               ; Determie the ouput PERIODS and output STACKED PERIODS based on the input files
    OUTPERS = WHERE_SETS(PER_SETS.STACKED_PERIOD)
          
    ; ===> Loop through the stacked output periods
    FOR N=0, N_ELEMENTS(OUTPERS)-1 DO BEGIN
      PERIOD_OUT = OUTPERS[N].VALUE
      OUTPERSTR = PERIOD_2STRUCT(OUTPERS[N].VALUE)                                                                             ; Get the date information from the period
      PDATERANGE = [STRMID(OUTPERSTR.DATE_START,0,8),STRMID(OUTPERSTR.DATE_END,0,8)]                                           ; Create a new daterange based on the PERIOD_SET
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

      ; ===> Get dimensions, map and prod from the INFILE
      FA = PARSE_IT(INFILES[0],/ALL)
      PX=LONG(FA.PX) & PY=LONG(FA.PY) & PZ=LONG(FA.PZ) & MAPP=FA.MAP & PROD=FA.PROD
      IF ~N_ELEMENTS(MAP_OUT) THEN MP = FA.MAP ELSE MP = MAP_OUT
      IF ~N_ELEMENTS(SUBSET_MAP) THEN SUBSETMAP = REPLACE(FA.MAP_SUBSET,'_SUBSET','') ELSE SUBSETMAP = SUBSET_MAP
      IF ~N_ELEMENTS(NC_MAP)  THEN NCMAP = SUBSETMAP+'GRID' ELSE NCMAP = NC_MAP
      IF VALIDS('MAPS',NCMAP) EQ '' THEN MESSAGE, 'ERROR: Output netcdf map is not valid'

      ; ===> Assign input product specific variables
      GRAD_MAG = []                                                                                                            ; Create a null GRAD_MAG variable that will be filled once the input file is read for the first file that needs to be created
      GPROD = FA.PROD
      CASE GPROD OF
        'GRAD_SST':   BEGIN & PLOG=0 & OUTPROD='GRADSST_INDICATORS' & FTAG = 'GRADSST_' & PTAG='_SST'   & PERSISTENCE=SST_PERSISTENCE & ORGPROD='SST'     & THPROD='GRADSST_FRONT' & END
        'GRAD_SSTKM': BEGIN & PLOG=0 & OUTPROD='GRADSST_INDICATORS' & FTAG = 'GRADSST_' & PTAG='_SSTKM' & PERSISTENCE=SST_PERSISTENCE & ORGPROD='SST'   & THPROD='GRADSST_FRONT'   & END
        'GRAD_CHL':   BEGIN & PLOG=1 & OUTPROD='GRADCHL_INDICATORS' & FTAG = 'GRADCHL_' & PTAG='_CHL'   & PERSISTENCE=CHL_PERSISTENCE & ORGPROD='CHLOR_A' & THPROD='GRADCHL_FRONT' & END
        'GRAD_CHLKM': BEGIN & PLOG=1 & OUTPROD='GRADCHL_INDICATORS' & FTAG = 'GRADCHL_' & PTAG='_CHLKM' & PERSISTENCE=CHL_PERSISTENCE & ORGPROD='CHLOR_A' & THPROD='GRADCHL_FRONT' & END
      ENDCASE

      OPRODS = [ORGPROD,REPLACE(GPROD,'KM',''),FTAG+OUTPRODS]
      IF N_ELEMENTS(UNIQ(SORT(OPRODS))) NE N_ELEMENTS(OPRODS) THEN MESSAGE, 'ERROR: Double check the output product names'

      ; ===> Loop on INDICATOR algorithms
      FOR A=0, N_ELEMENTS(ALGS)-1 DO BEGIN
        ALG = ALGS[A]
        PROD_ALG = OUTPROD + '-'+ALG
  
        ; ===> Create the output directories
        IF ~N_ELEMENTS(DIR_OUT) THEN BEGIN
          FPA = FA
          COUNTER = 0
          WHILE FPA.SUB NE 'STACKED_SAVE' DO BEGIN
            COUNTER = COUNTER + 1
            IF COUNTER GT 5 OR FPA.SUB EQ 'DATASETS' THEN MESSAGE, 'ERROR: Unable to create the output directory'
            FPA = FILE_PARSE(REPLACE(FPA.DIR,FPA.SUB+SL,''))
          ENDWHILE
          DIR_SAVE = REPLACE(FPA.DIR,[FA.MAP],[MP])+ PROD_ALG + SL
        ENDIF ELSE DIR_SAVE = DIR_OUT
        DIR_NC = REPLACE(DIR_SAVE,['STACKED_SAVE',FA.MAP],['NETCDF',NCMAP]) 
        DIR_TEST, [DIR_SAVE, DIR_NC]

        
;        PREV_START = NUM2STR(FA.YEAR_START-1) & PREV_END = NUM2STR(FA.YEAR_END-1)
;        IF FA.YEAR_START EQ FA.YEAR_END THEN PREVIOUS_PERIOD = REPLACE(PERIOD_OUT,FA.YEAR_START,PREV_START) $
;                                        ELSE PREVIOUS_PERIOD = REPLACE(PERIOD_OUT,[FA.YEAR_START,FA.YEAR_END],[PREV_START,PREV_END])
;        PREVIOUS = DIR_SAVE + REPLACE(FA.NAME,[FA.PERIOD,FA.MAP,FA.PROD,'-'+FA.ALG,'-STACKED'],[PREVIOUS_PERIOD,MP,PROD_ALG,'','']) + '.SAV'                    
;        IF FILE_TEST(PREVIOUS) THEN BEGIN
;          RECHECK_PREVIOUS:
;          IF FILE_MAKE([GFILE,PREVIOUS],SAVEFILE,OVERWRITE=OVERWRITE) EQ 0 THEN GOTO, MAKE_NETCDF 
;          PREV = IDL_RESTORE(PREVIOUS)
;          CPERS_ORG = PREV[FTAG+'FPERSISTCUM',*,*,-1]
;          GONE, PREV
;        ENDIF ELSE BEGIN
;          PRESTR = PERIOD_2STRUCT(PREVIOUS_PERIOD)
;          DATES = CREATE_DATE(PRESTR.DATE_START,PRESTR.DATE_END)
;          PSETS = PERIOD_SETS(DATE_2JD(DATES),PERIOD_CODE=PER) & PSET_STR = PERIOD_2STRUCT(PSETS.PERIOD)
;          PREVIOUS_PER = PREVIOUS_PERIOD
;          FOR PS=1, N_ELEMENTS(PSETS)-1 DO BEGIN
;            PREVIOUS_PER = REPLACE(PREVIOUS_PER,PSETS[PS-1].PERIOD,PSETS[PS].PERIOD)
;            PREVIOUS = DIR_SAVE + REPLACE(FA.NAME,[FA.PERIOD,FA.MAP,FA.PROD,'-'+FA.ALG,'-D3_DAT'],[PREVIOUS_PER,MP,PROD_ALG,'','']) + '.SAV'
;            IF FILE_TEST(PREVIOUS) THEN GOTO, RECHECK_PREVIOUS
;          ENDFOR          
;          CPERS_ORG = []
;        ENDELSE
        
                
        ; ===> Read the input data from the stacked grad_mag file
 ;       IF GRAD_MAG EQ [] THEN BEGIN                                                                ; Only need to read the file the first time through the period loop
        PLUN, LUN, 'Reading ' + INFILES[0], 1
        GMD = IDL_RESTORE(INFILES[0])                                                                  ; Read the D3 HASH file (IDL_RESTORE is faster than STACKED_READ)
        KEYS = GMD.KEYS()                                                                         ; Get the KEY information in the file
        KEYS = KEYS.TOARRAY()                                                                     ; Convert the KEYS from a list to array
        IF WHERE(KEYS EQ 'BINS',/NULL) NE [] THEN GBINS = GMD['BINS'] ELSE GBINS = []             ; Get the input BINS (if available)
        GINFO = GMD['INFO']                                                                       ; Get the input INFO data
                  
        ; ===> Get the threshold BOX information
        OK = WHERE(STRPOS(KEYS,'BOX') GE 0,COUNT)
        IF COUNT EQ 0 THEN MESSAGE, 'ERROR: Unable to find any threshold information'
        TKEYS = KEYS[OK]
        STRBK = STR_BREAK(TKEYS,'_')
        BOXES = STRBK[*,-1]
        OK = WHERE(STRPOS(BOXES,'BOX') LT 0, COUNT)
        IF COUNT GE 1 THEN MESSAGE, 'ERROR: Tag names should have a BOX threshold label'
        BXSETS = WHERE_SETS(BOXES)
                  
        ; ===> Loop on BOX thresholds
        FOR X=0, N_ELEMENTS(BXSETS)-1 DO BEGIN
          TPROD = THPROD + '_'+BXSETS[X].VALUE
          MPROD = 'THRESHOLD_MEDIAN_'+BXSETS[X].VALUE
          THRESH = GMD[TPROD]
          TMED    = GMD[MPROD]

          SAVEFILE = DIR_SAVE + REPLACE(FA.NAME,[FA.PERIOD,FA.MAP,FA.PROD,'-'+FA.ALG,'-STACKED'],[PERIOD_OUT,MP,PROD_ALG,'','']) + '-' + BXSETS[X].VALUE+ '.SAV'
          IF FILE_MAKE(INFILES,SAVEFILE,OVERWRITE=OVERWRITE) EQ 0 THEN CONTINUE
          
          ; ===> Extract the GRAD_MAG data from the primary input file
          GRAD_MAG = GMD[GPROD]
          GRAD_X = GMD['GRADX'+PTAG]
          GRAD_Y = GMD['GRADY'+PTAG]
          ODAT   = GMD[ORGPROD] 
          GDB   = GMD['FILE_DB'].TOSTRUCT()                                                         ; Get the database information and convert to a structure  
          ; ===> Add the data from additional input files if needed
          FOR F=1, N_ELEMENTS(INFILES)-1 DO BEGIN
            PLUN, LUN, 'Reading ' + INFILES[F], 0
            SGMD = IDL_RESTORE(INFILES[F])
            SGRAD_MAG = SGMD[GPROD]
            SGRAD_X   = SGMD['GRADX'+PTAG]
            SGRAD_Y   = SGMD['GRADY'+PTAG]
            SODAT     = SGMD[ORGPROD]
            STHRESH   = SGMD[TPROD]
            STMED = SGMD[MPROD]
            SDB       = SGMD['FILE_DB'].TOSTRUCT()  
            SZ = SIZE(GRAD_MAG,/DIMENSIONS)                                                                                          ; Get the dimensions of the initial data
            SZS = SIZE(SGRAD_MAG,/DIMENSIONS)                                                                                        ; Get the dimenions of the secondary data
            IF N_ELEMENTS(SZ) NE N_ELEMENTS(SZS) OR SZ[0] NE SZS[0] OR SZ[1] NE SZS[1] THEN MESSAGE, 'ERROR: The dimensions of the data do not match' ; Check that the dimensions are the same
            OKDATES = WHERE(PERIOD_2JD(SDB.PERIOD) GE DATE_2JD(PDATERANGE[0]) AND PERIOD_2JD(SDB.PERIOD) LE DATE_2JD(PDATERANGE[1]),COUNT) ; Find the periods within the daterange
            IF COUNT EQ 0 THEN MESSAGE, 'ERROR: Data within the daterange ' + STRJOIN(PDATERANGE,'-') + ' were not found'          ; Check that the periods were found within the daterange

            CASE N_ELEMENTS(SZ) OF                                                                                                 ; Get the dimensions for the new array
              2: BEGIN & XX = 0 & YY = SZ[0] & ZZ = SZ[1]+COUNT & END                                                              ; Array sizes based on 2 dimensions
              3: BEGIN & XX = SZ[0] & YY = SZ[1] & ZZ = SZ[2]+COUNT & END                                                          ; Array sizes based on 3 dimensions
            ENDCASE
            NEWARR = FLTARR(XX,YY,ZZ)                                                                                              ; Make a new blank array
            PRDS = [GPROD,'GRADX'+PTAG,'GRADY'+PTAG,ORGPROD,TPROD]
            FOR PR=0, N_ELEMENTS(PRDS)-1 DO BEGIN
              TEMPARR = NEWARR
              CASE PRDS[PR] OF
                GPROD:        BEGIN & TEMPARR[*,*,0:SZ[-1]-1] = GRAD_MAG & TEMPARR[*,*,SZ[-1]:*] = SGRAD_MAG[*,*,OKDATES] & GRAD_MAG = TEMPARR & TEMPARR = [] & END
                'GRADX'+PTAG: BEGIN & TEMPARR[*,*,0:SZ[-1]-1] = GRAD_X   & TEMPARR[*,*,SZ[-1]:*] = SGRAD_X[*,*,OKDATES]   & GRAD_X   = TEMPARR & TEMPARR = [] & END
                'GRADY'+PTAG: BEGIN & TEMPARR[*,*,0:SZ[-1]-1] = GRAD_Y   & TEMPARR[*,*,SZ[-1]:*] = SGRAD_Y[*,*,OKDATES]   & GRAD_Y   = TEMPARR & TEMPARR = [] & END
                ORGPROD:      BEGIN & TEMPARR[*,*,0:SZ[-1]-1] = ODAT     & TEMPARR[*,*,SZ[-1]:*] = SODAT[*,*,OKDATES]     & ODAT     = TEMPARR & TEMPARR = [] & END
                TPROD:        BEGIN & TEMPARR[*,*,0:SZ[-1]-1] = THRESH   & TEMPARR[*,*,SZ[-1]:*] = STHRESH[*,*,OKDATES]   & THRESH   = TEMPARR & TEMPARR = [] & END
                MPROD:       BEGIN & TMED = [TMED,STMED] & END 
              ENDCASE
          ENDFOR ; PRDS loop  
            
          DBTAGS = TAG_NAMES(GDB) & SDBTAGS = TAG_NAMES(SDB)                                                                      ; Get the DB tag names
          NEWDB = []                                                                                                             ; Create a new NULL DB
          FOR DD=0, N_TAGS(GDB)-1 DO BEGIN                                                                                        ; Loop through DB tags
            IF SDBTAGS[DD] NE DBTAGS[DD] THEN MESSAGE, 'ERROR: Database tag names do not match'                                  ; Check that the DB tags match
            NEWDB = CREATE_STRUCT(NEWDB,DBTAGS[DD],[GDB.(DD),SDB.(DD)[OKDATES]])                                                  ; Create a new structure with the merged DB info
          ENDFOR
          NEWDB.SEQ = INDGEN(N_ELEMENTS(NEWDB.SEQ))                                                                              ; Update the SEQ values
          GDB = NEWDB & NEWDB = []            
        ENDFOR ; Extra INPUT files
                  
        ; ===> Get the number of files from the DB and determine the output periods
        SETS = PERIOD_SETS(PERIOD_2JD(GDB.PERIOD),PERIOD_CODE=PERS[R])
        DBSUBS = SETS.SUBS
        PERIODS = SETS.PERIOD
               
        ; ===> Create or read the HASH obj
        IF FRTHASH EQ [] THEN BEGIN
          IF ~FILE_TEST(SAVEFILE) THEN FRTHASH = D3HASH_MAKE(SAVEFILE, INPUT_FILES=INFILES, BINS=GBINS, PRODS=OPRODS, PX=PX, PY=PY, ADD_INFO='GRADMAG_INFO',INFO_CONTENT=GINFO) $
                                  ELSE SAVEFILE = IDL_RESTORE(SAVEFILE)    ; Read the D3HASH file if it already exists and extract the D3 dabase
        ENDIF
        IF IDLTYPE(FRTHASH) NE 'OBJREF' THEN MESSAGE, 'ERROR: Unable to properly create or read the HASH obj'                                                ; Read the existing D3 file
        FDB = FRTHASH['FILE_DB'].TOSTRUCT()
        FRTKEYS = FRTHASH.KEYS() & FRTKEYS = FRTKEYS.TOARRAY()                                                                  ; Get the D3HASH key names and convert the LIST to an array
        FRTPRODS = REMOVE(FRTKEYS,VALUES=['FILE_DB','PRODS','BINS','INFO','METADATA'])                                           ; Keep just the D3 variable names
               
        ; ===> Loop through the PERIODS_SETS periods
        WRITEFILE = 0
        FOR S=0, N_ELEMENTS(SETS)-1 DO BEGIN
          OPER = PER_SET[S]
          APER = OPER.PERIOD
          ASTR = PERIOD_2STRUCT(APER)
          SUBS = STRSPLIT(DBSUBS[S],';',/EXTRACT)          
          
          IF STRMID(ASTR.DATE_START,0,8) NE STRMID(ASTR.DATE_END,0,8) THEN $
            DTRNG = STRJOIN(STRMID([ASTR.DATE_START,ASTR.DATE_END],0,8),'_') ELSE DTRNG = STRMID(ASTR.DATE_START,0,8)                                                                   ; Create the PERIOD_RANGE variable

          GPER = GDB.PERIOD[S]
          DP = DATE_PARSE(PERIOD_2DATE(GPER))
          SEQ = WHERE(FRTHASH['FILE_DB','PERIOD'] EQ APER[0],/NULL,COUNT)
          IF COUNT EQ 0 THEN MESSAGE, 'ERROR: ' + APER + ' not found in the output DB database'
          
          ; ===> Check the daily MTIMES
          GMT = GDB.MTIME[SUBS]
          IF FRTHASH['FILE_DB','MTIME',SEQ] GE MAX(GMT) AND ~KEYWORD_SET(OVERWRITE) THEN CONTINUE  ; Skip if data already exists in the hash file
          WRITEFILE = 1
          
          ; ===> Add the file information to the D3 database in the D3HASH
          FRTHASH['FILE_DB','MTIME',SEQ] = DATE_NOW(/MTIME,/GMT)                                                                     ; Add the file MTIME to the D3 database
          FRTHASH['FILE_DB','FULLNAME',SEQ] = SAVEFILE                                                                            ; Add the full file name to the D3 database
          FRTHASH['FILE_DB','NAME',SEQ] = (FILE_PARSE(SAVEFILE)).NAME_EXT                                                     ; Add the file "name" to the D3 database
          FRTHASH['FILE_DB','DATE_RANGE',SEQ] = DTRNG                                                                          ; Add the "daterange" to the D3 database
          FRTHASH['FILE_DB','INPUT_FILES',SEQ] = OPER.FILENAME                                                                        ; Add the "input" files to the D3 database
          FRTHASH['FILE_DB','ORIGINAL_FILES',SEQ] = STRJOIN(GDB.ORIGINAL_FILES[SUBS],'; ') 
                    
          ; ===> Get the subscripts for the period and list of original input files
          OK = WHERE(GDB.MTIME[SUBS] EQ 0, COUNT) & IF COUNT EQ N_ELEMENTS(SUBS) THEN CONTINUE ; Continue because there is no data in the file for the subscripts
                      
          ; ===> Extract the data for the period and convert the L3B data to a 2D array 
          GM = FLTARR(PX,PY,N_ELEMENTS(SUBS)) & GM[*] = MISSINGS(GM) & GX = GM & GY = GM & OD = GM & TR = GM; Create blank data arrays
          FOR B=0,N_ELEMENTS(SUBS)-1L DO BEGIN ; ===> Loop through the subscripts and get the data for each day
            SUB = FIX(SUBS[B])
            GM[*,*,B] = GRAD_MAG[*,*,SUB] ;  IF SUBSETMAP NE FA.MAP THEN GM[*,*,SUB] = MAPS_L3BGS_SWAP(MAPS_L3B_2ARR(GRAD_MAG[*,*,SUB],MP=FA.MAP,BINS=GBINS),MAP_SUBSET=SUBSETMAP,L3BGS_MAP=FA.MAP) ELSE GM[*,*,B] = GRAD_MAG[*,*,SUB]
            GX[*,*,B] = GRAD_X[*,*,SUB]   ;  IF SUBSETMAP NE FA.MAP THEN GX[*,*,SUB] = MAPS_L3BGS_SWAP(MAPS_L3B_2ARR(GRAD_X[*,*,SUB],MP=FA.MAP,BINS=GBINS),MAP_SUBSET=SUBSETMAP,L3BGS_MAP=FA.MAP) ELSE GX[*,*,B] = GRAD_X[*,*,SUB]
            GY[*,*,B] = GRAD_Y[*,*,SUB]   ;  IF SUBSETMAP NE FA.MAP THEN GY[*,*,SUB] = MAPS_L3BGS_SWAP(MAPS_L3B_2ARR(GRAD_Y[*,*,SUB],MP=FA.MAP,BINS=GBINS),MAP_SUBSET=SUBSETMAP,L3BGS_MAP=FA.MAP) ELSE GY[*,*,B] = GRAD_Y[*,*,SUB]
            OD[*,*,B] = ODAT[*,*,SUB] ; Don't need to remap because not being fed into the indicator function
            TR[*,*,B] = THRESH[*,*,SUB]
          ENDFOR
          
          ; ===> Calculate the original data (CHL/SST) mean
          CASE ORGPROD OF
            'SST':     OMEAN = MEAN(OD,/NAN,DIMENSION=3)
            'CHLOR_A': OMEAN = EXP(MEAN(ALOG(OD),/NAN,/DOUBLE,DIMENSION=3))
          ENDCASE
          OMEAN[WHERE(FINITE(OMEAN) EQ 0)] = MISSINGS(OMEAN)
          
          ; ===> Run the metric code 
          PLUN, LUN, 'Calculating frontal metrics on ' + APER + ' for ' + FA.NAME_EXT, 0
          CASE ALG OF 
            'MILLER': GSTR = FRONT_INDICATORS_MILLER(GRAD_MAG=GM, GRAD_X=GX, GRAD_Y=GY, TRANSFORM=PLOG, THRESHOLD=TR, PERSISTENCE=PERSISTENCE, CPERS_ORG=CPERS_ORG)
          ENDCASE
          
          ; ===> Loop through the OUTPROD and add to the HASH
          FOR O=0, N_ELEMENTS(OPRODS)-1 DO BEGIN
            OPROD = OPRODS[O]
            FPROD = REPLACE(OPROD,FTAG,'')
            CASE OPROD OF
              'SST':      FRTHASH[OPROD,*,*,SEQ] = OMEAN
              'CHLOR_A':  FRTHASH[OPROD,*,*,SEQ] = OMEAN
              'GRAD_SST': FRTHASH[OPROD,*,*,SEQ] = GSTR.GRADMEAN
              'GRAD_CHL': FRTHASH[OPROD,*,*,SEQ] = GSTR.GRADMEAN
              'GRADSST_FMASK': FRTHASH[OPROD,*,*,SEQ] = GSTR.FMASK.MASK
              'GRADCHL_FMASK': FRTHASH[OPROD,*,*,SEQ] = GSTR.FMASK.MASK
              ELSE: BEGIN
                IF ~STRUCT_HAS(GSTR,FPROD) THEN MESSAGE, 'ERROR: Check that the output product matches the FRTHASH prods key'                       ; Make sure the stat names align
                FRTHASH[OPROD,*,*,SEQ] = GSTR.(WHERE(TAG_NAMES(GSTR) EQ FPROD,/NULL))
              END                                                                                         ; Get the name of the "stat"
            ENDCASE
          ENDFOR ; OUTPRODS
                   
;          CPERS_ORG = GSTR.FPERSISTCUM
;          GRADMEAN = GSTR.GRADMEAN
;          GSTR = STRUCT_COPY(GSTR,'GRADMEAN',/REMOVE)
;          GTAGS = [ORGPROD,GPROD,FTAG+TAG_NAMES(GSTR)]      
;          GSTR = CREATE_STRUCT((ORGPROD),OMEAN,GPROD,GRADMEAN,GSTR)
;          
;          IF SCOUNT EQ 0 THEN BEGIN   ; ===> Create the blank data arrays after the first file has been created 
;            GRADTAGS = [ORGPROD,GPROD,FTAG+['FCLEAR','FVALID','FMEAN','FPROB','FINTENSITY','FSTD','FPERSIST','FPERSISTPROB']] ; ,'FPERSISTCUM'
;            FOR T=0, N_ELEMENTS(GRADTAGS)-1 DO BEGIN
;              GRADTAG = GRADTAGS[T]
;              OK = WHERE(GTAGS EQ GRADTAG,COUNT)
;              GPRD = GSTR.(OK)
;              IF COUNT EQ 0 THEN MESSAGE, 'ERROR: ' + GRADTAG + ' not found in the GRAD indicators structure.'
;              
;              CR = STRSPLIT(VALIDS('PROD_CRITERIA',GRADTAG),'_',/EXTRACT)
;              DSTR = CREATE_STRUCT('PROD',GRADTAG,'ALG',ALG,'UNITS',UNITS(GRADTAG,/SI),'VALID_MIN',CR[0],'VALID_MAX',CR[1])
;              IF ~HAS(TAG_NAMES(INFO),GRADTAG) THEN INFO = CREATE_STRUCT(INFO,GRADTAG,DSTR)
;              
;              ; ===> Create a blank array based on the data type of the variable
;              CASE IDLTYPE(GPRD) OF 
;                'BYTE':   D3BLANK = BYTARR([PX,PY,N_ELEMENTS(PERIODS)])
;                'FLOAT':  D3BLANK = FLTARR([PX,PY,N_ELEMENTS(PERIODS)])
;                'INT':    D3BLANK = INTARR([PX,PY,N_ELEMENTS(PERIODS)])   
;                'LONG':   D3BLANK = LONARR([PX,PY,N_ELEMENTS(PERIODS)])
;                'DOUBLE': D3BLANK = DBLARR([PX,PY,N_ELEMENTS(PERIODS)])                                                                                              
;              ENDCASE
;              IF IDLTYPE(GPRD) NE 'INT' THEN D3BLANK[*] = MISSINGS(D3BLANK)
;              D3HASH[GRADTAG] = D3BLANK
;            ENDFOR
;            
;            D3HASH['MASK'] = INTARR([PX,PY,N_ELEMENTS(PERIODS)]) ; Add the mask to the D3HASH, but replace the MASK array with a full "D3" blank array
;            INFO = CREATE_STRUCT(INFO,'MASK',STRUCT_COPY(GSTR.MASK,'MASK',/REMOVE))
;            D3HASH['INFO'] = INFO     ; Add the file information structure
;          ENDIF
;            
;          ; ===> Add the front data to the hash
;          FOR T=0, N_ELEMENTS(GRADTAGS)-1 DO D3HASH[GRADTAGS[T],*,*,S] = GSTR.(WHERE(GTAGS EQ GRADTAGS[T] ))
;          D3HASH['MASK',*,*,S] = GSTR.MASK.MASK
;          SCOUNT = SCOUNT + 1
        ENDFOR ; PERIODS (FROM PERIOD_SETS)
        
        ; ===> Update the metadata and save the HASH file
        IF KEYWORD_SET(WRITEFILE) THEN BEGIN
          MASK = STRUCT_COPY(GSTR.FMASK,'MASK',/REMOVE)                                 ; Remove the "mask" from the mask structure
          FRTHASH['FMASK_INFO'] = MASK                                                  ; Add the mask information to the output hash
          FRTHASH['METADATA'] = D3HASH_METADATA(SAVEFILE, DB=FRTHASH['FILE_DB'])
          PLUN, LUN, 'Writing ' + SAVEFILE
          SAVE, FRTHASH, FILENAME=SAVEFILE, /COMPRESS                                                                          ; Save the file
        ENDIF
        FRTHASH = []     
        
        MAKE_NETCDF:
        STACKED_2NETCDF, SAVEFILE, MAP_OUT=NCMAP, DIR_OUT=DIR_NC, OUTFILE=NC_FILE
          
        ENDFOR ; ALGS
      ENDFOR ; PERIOD_SETS
    ENDFOR ; PERS (PERIOD_CODES) 
  ENDFOR ; THRESHOLD BOX SIZE



END ; ***************** End of SAVE_MAKE_FRONT_INDICATORS *****************
