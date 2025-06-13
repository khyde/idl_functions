; $ID:	STACKED_MAKE_PRODS_PPD.PRO,	2023-09-21-13,	USER-KJWH	$
  PRO STACKED_MAKE_PRODS_PPD, CHLFILES=CHLFILES, PARFILES=PARFILES, SSTFILES=SSTFILES,$
    PP_MODELS=PP_MODELS, OUTPRODS=OUTPRODS, DIR_OUT=DIR_OUT, FILE_LABEL=FILE_LABEL, CHL_RANGE=CHL_RANGE, PAR_RANGE=PAR_RANGE, SST_RANGE=SST_RANGE, LOGLUN=LOGLUN, OVERWRITE=OVERWRITE

;+
; NAME:
;   STACKED_MAKE_PRODS_PPD
;
; PURPOSE:
;   Calculate daily integrated primary productivity and ancillary products
;
; CATEGORY:
;   STACKED_FUNCTIONS
;
; CALLING SEQUENCE:
;   STACKED_MAKE_PRODS_PPD, CHLFILES=CHLFILES, PARFILES,PARFILES, SSTFILES=SSTFILES
;
; REQUIRED INPUTS:
;   CHLFILES....... Stacked chlorophyll files (daily or interpolated)
;   PARFILES....... Stacked PAR files (daily or interpolated)
;   SSTFILES....... Stacked SST files (daily or interpolated)
;
; OPTIONAL INPUTS:
;   PP_MODELS...... The specific PP model to run (default = VGPM2)
;   OUTPRODS....... The output products from the PP model to save in the stacked file
;   DIR_OUT........ The output directory
;   FILE_LABEL..... Specific information to include in the output file
;   CHL_RANGE...... The range of valid CHL data to include in the model
;   PAR_RANGE...... The range of valid PAR data to include in the model
;   SST_RANGE...... The range of valid SST data to include in the model
;   LOGLUN......... The LUN for the log file
;
; KEYWORD PARAMETERS:
;   OVERWRITE...... Keyword to overwrite the output file if it already exists
;
; OUTPUTS:
;   STACKED file with daily primary production data
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
;   $Citations or any other useful notes$
;   
; COPYRIGHT: 
; Copyright (C) 2022, Department of Commerce, National Oceanic and Atmospheric Administration, National Marine Fisheries Service,
;   Northeast Fisheries Science Center, Narragansett Laboratory.
;   This software may be used, copied, or redistributed as long as it is not sold and this copyright notice is reproduced on each copy made.
;   This routine is provided AS IS without any express or implied warranties whatsoever.
;
; AUTHOR:
;   This program was written on December 20, 2022 by Kimberly J. W. Hyde, Northeast Fisheries Science Center | NOAA Fisheries | U.S. Department of Commerce, 28 Tarzwell Dr, Narragansett, RI 02882
;    
; MODIFICATION HISTORY:
;   Dec 20, 2022 - KJWH: Initial code written
;-
; ****************************************************************************************************
  ROUTINE_NAME = 'STACKED_MAKE_PRODS_PPD'
  COMPILE_OPT IDL2
  SL = PATH_SEP()
  IF ~N_ELEMENTS(LOGLUN) THEN LUN = [] ELSE LUN = LOGLUN
  
  ; ===> Check input files and ranges
  IF ~N_ELEMENTS(CHLFILES) OR ~N_ELEMENTS(PARFILES) OR ~N_ELEMENTS(SSTFILES) THEN MESSAGE, 'ERROR: Must include CHL, PAR and SST input files'
  IF N_ELEMENTS(CHL_RANGE) NE 2 THEN CRANGE = [0.0  , 189.0] ELSE CRANGE = CHL_RANGE  
  IF N_ELEMENTS(PAR_RANGE) NE 2 THEN PRANGE = [0.0  ,  75.0] ELSE PRANGE = PAR_RANGE
  IF N_ELEMENTS(SST_RANGE) NE 2 THEN SRANGE = [-3.0 ,  37.0] ELSE SRANGE = SST_RANGE
  INPUT_PRODS = ['CHLOR_A','PAR','SST']
  
  ; ===> Check other input variables
  IF ~N_ELEMENTS(PP_MODELS) THEN MODELS = 'VGPM2' ELSE MODELS = PP_MODELS
  IF ~N_ELEMENTS(OUTPRODS) THEN OUTPRODS = ['PPD','KD_PAR','ZEU','CHLOR_EUPHOTIC']
  VALID = VALIDS('ALGS',MODELS,/VALID)
  OK = WHERE(VALID EQ 0,COUNT,COMPLEMENT=COMP,NCOMPLEMENT=NCOMP)
  IF COUNT GE 1 THEN PLUN, LOG_LUN, 'ERROR: Invalid PP_MODELS - ',MODELS[OK]
  IF NCOMP GE 1 THEN MODELS = MODELS[OK] ELSE MESSAGE, 'ERROR: No valid PP models provided'
  
  ; ===> Get file info
  FCS = PARSE_IT(CHLFILES,/ALL)
  FPS = PARSE_IT(PARFILES)
  FSS = PARSE_IT(SSTFILES)                                                                                                          ; Parse the file
  
  ; ===> Create output directory and file name(s)
  IF ~N_ELEMENTS(DIR_OUT) THEN DIR_OUT = REPLACE(FCS[0].DIR,FCS[0].SUB,'PPD-'+MODELS)                                               ; Create the output directory
  DIR_OUT = REPLACE(DIR_OUT,'STACKED_INTERP','STACKED_SAVE')                                                                        ; Update the output directory
  DIR_TEST, DIR_OUT                                                                                                                 ; Make the output directory folder
  IF ~N_ELEMENTS(FILE_LABEL) THEN FLABEL=FILE_LABEL_MAKE(CHLFILES[0],LST=['SENSOR','VERSION','SATELLITE','SAT_EXTRA','METHOD','MAP']) ELSE FLABEL=FILE_LABEL ; Create the output file label
  FLABEL = FLABEL + '-PPD-' + MODELS
  
  ; ===> Loop through files
  NFILES = N_ELEMENTS(CHLFILES)
  FOR F=0, NFILES-1 DO BEGIN
    CFLE = CHLFILES[F]                                                                                                              ; Get the file
    FC = FCS[F]
    PERIOD = FC.PERIOD
    PSTR = PERIOD_2STRUCT(PERIOD)
    DRANGE = STRJOIN(STRMID([PSTR.DATE_START,PSTR.DATE_END],0,8),'_')                                                      ; Get the daterange for the period
    
    ;   =====> Find the files for each subset
    PFLE = PARFILES[WHERE(FPS.PERIOD EQ FC.PERIOD,/NULL,COUNTP)] & IF COUNTP EQ 0 THEN CONTINUE & IF COUNTP NE 1 THEN MESSAGE, 'ERROR: More than 1 PAR file found for period ' + PERIOD
    SFLE = SSTFILES[WHERE(FSS.PERIOD EQ FC.PERIOD,/NULL,COUNTS)] & IF COUNTS EQ 0 THEN CONTINUE & IF COUNTS NE 1 THEN MESSAGE, 'ERROR: More than 1 SST file found for period ' + PERIOD

    FP = PARSE_IT(PFLE)
    FS = PARSE_IT(SFLE) 
    
    INFILES = [CFLE,PFLE,SFLE]
    PPFILES = DIR_OUT + FC.PERIOD + '-' + FLABEL + '.SAV'
    IF ~FILE_MAKE(INFILES,PPFILES,OVERWRITE=OVERWRITE) THEN CONTINUE
    
    ; ===> Read the data
    CSAT = STACKED_READ(CFLE,DB=CDB,BINS=CBINS)
    PSAT = STACKED_READ(PFLE,DB=PDB,BINS=PBINS)
    SSAT = STACKED_READ(SFLE,DB=SDB,BINS=SBINS)
    
    ; ===> Check that the files were open correctly
    FILECHECK = [IDLTYPE(CSAT),IDLTYPE(PSAT),IDLTYPE(SSAT)]
    OK = WHERE(FILECHECK EQ 'STRING',COUNT)
    IF COUNT GT 0 THEN BEGIN
      PLUN, LOG_LUN, 'ERROR: Reading the input files for ' + INFILES[OK]
      CONTINUE
    ENDIF
    
    ; ===> Check that the data sizes are the same
    CDAT = CSAT.CHLOR_A & CSZ = SIZEXYZ(CDAT,PX=XC,PY=YC,PZ=ZC)
    PDAT = PSAT.PAR     & PSZ = SIZEXYZ(PDAT,PX=XP,PY=YP,PZ=ZP)
    SDAT = SSAT.SST     & SSZ = SIZEXYZ(SDAT,PX=XS,PY=YS,PZ=ZS)
    
    IF XC NE XP OR XC NE XS THEN MESSAGE, 'ERROR: The X dimensions in the input data do not match'
    IF YC NE YP OR YC NE YS THEN MESSAGE, 'ERROR: The Y dimensions in the input data do not match'
    IF ZC NE ZP OR ZC NE ZS THEN MESSAGE, 'ERROR: The Z dimensions in the input data do not match'
    
    FOR M=0, N_ELEMENTS(MODELS)-1 DO BEGIN
      ALG = MODELS[M]
      PPFILE = PPFILES[M]
      IF ~FILE_MAKE(INFILES,PPFILE,OVERWRITE=OVERWRITE) THEN CONTINUE
      
      ; ===> Get PROD specific information to add to the INFO structure
      INFO_CONTENT = []
      FOR I=0, N_ELEMENTS(INPUT_PRODS)-1 DO BEGIN                                                                                         ; Loop through the products
        PR = PRODS_READ(INPUT_PRODS[I])                                                                                                 ; Get product specific information
        CASE PR.PROD OF
          'CHLOR_A':BEGIN & IALG = FC.ALG & RNG = CRANGE & END
          'PAR':    BEGIN & IALG = '' & RNG = PRANGE & END
          'SST':    BEGIN & IALG = '' & RNG = SRANGE & END
        ENDCASE
        DSTR = CREATE_STRUCT('PROD',PR.PROD,'ALG',IALG,'UNITS',PR.UNITS,'LONG_NAME',PR.CF_LONG_NAME, $                      ; Extract product specific information
          'STANDARD_NAME',PR.CF_STANDARD_NAME,'VALID_MIN',MIN(RNG),'VALID_MAX',MAX(RNG))
        INFO_CONTENT = CREATE_STRUCT(INFO_CONTENT,PR.PROD,DSTR)                                                                                  ; Add product specific information to the structure
      ENDFOR ; INPUT_PRODS
      
      ; ===> Create or read the HASH obj
      IF PPDHASH EQ [] THEN BEGIN
        IF ~FILE_TEST(PPFILE) THEN PPDHASH = D3HASH_MAKE(PPFILE, INPUT_FILES=INFILES, BINS=CBINS, PRODS=OUTPRODS, PX=CX, PY=CY, ADD_INFO='INPUT_PRODUCTS',INFO_CONTENT=INFO_CONTENT) $
                              ELSE PPDHASH = IDL_RESTORE(PPFILE)    ; Read the D3HASH file if it already exists and extract the D3 dabase
      ENDIF

      IF IDLTYPE(PPDHASH) NE 'OBJREF' THEN MESSAGE, 'ERROR: Unable to properly create or read the HASH obj'                                                ; Read the existing D3 file
      PPDB = PPDHASH['FILE_DB'].TOSTRUCT()
      D3_KEYS = PPDHASH.KEYS() & D3_KEYS = D3_KEYS.TOARRAY()                                                                  ; Get the D3HASH key names and convert the LIST to an array
      D3_PRODS = REMOVE(D3_KEYS,VALUES=['FILE_DB','PRODS','BINS','INFO','METADATA'])                                           ; Keep just the D3 variable names
       
      WRITEFILE = 0
      FOR D=0, N_ELEMENTS(CDB.PERIOD)-1 DO BEGIN
        CPER = CDB[D].PERIOD
        DP = DATE_PARSE(PERIOD_2DATE(CPER))
        
        ; ===> Find the matching periods in the databases
        CSQ = CDB[D].SEQ
        PSQ = PDB[WHERE(PDB.PERIOD EQ CDB[D].PERIOD,/NULL)].SEQ
        SSQ = SDB[WHERE(SDB.PERIOD EQ CDB[D].PERIOD,/NULL)].SEQ
        SEQ = WHERE(PPDHASH['FILE_DB','PERIOD'] EQ CDB[D].PERIOD,/NULL)
        IF PSQ EQ [] OR SSQ EQ [] THEN MESSAGE, 'ERROR: Unable to find a matching PAR or SST period for ' + CPER
        IF SEQ EQ [] THEN MESSAGE, 'ERROR: Unable to find matching PPD period for ' + CPER
        
        ; ===> Get the data for each variable
        CSAT = CDAT[*,*,CSQ]
        PSAT = PDAT[*,*,PSQ]
        SSAT = SDAT[*,*,SSQ]
    
        OKALL = WHERE(CSAT NE MISSINGS(CSAT) AND CSAT GT CRANGE[0] AND CSAT LT CRANGE[1] AND $
                      PSAT NE MISSINGS(PSAT) AND PSAT GT PRANGE[0] AND PSAT LT PRANGE[1] AND $
                      SSAT NE MISSINGS(SSAT) AND SSAT GT SRANGE[0] AND SSAT LT SRANGE[1],COUNT_ALL)
        
        IF COUNT_ALL EQ 0 THEN PLUN, LOG_LUN, 'No valid data found, SKIPPING ' + CPER,0
        IF COUNT_ALL EQ 0 THEN CONTINUE ; Continue if no valid data
  
        ; ===> Check the daily MTIMES
        CMT = CDB[CSQ].MTIME
        PMT = PDB[PSQ].MTIME
        SMT = SDB[SSQ].MTIME
        IF PPDHASH['FILE_DB','MTIME',SEQ] GE MAX([CMT,PMT,SMT]) AND ~KEYWORD_SET(OVERWRITE) THEN CONTINUE                     ; Check the MTIMES in the file DB and skip if the data is already in the database and does not need to be updated
        WRITEFILE = 1 
  
        ;   =====> Calculate Day Length for the given map
        DAY_LENGTH = I_SUN_KIRK_DAY_LENGTH_MAP(DP.IDOY,MAP=FC.MAP)
        DAY_LENGTH = DAY_LENGTH[CBINS-1]                                                                                      ; Subset the DAY_LENGTH for just the pixels in the CHL file (subtract 1 to convert the BINS to subscripts)
        
        ; ===> Add the file information to the D3 database in the D3HASH
        PPDHASH['FILE_DB','MTIME',SEQ] = DATE_NOW(/MTIME)                                                                     ; Add the file MTIME to the D3 database
        PPDHASH['FILE_DB','FULLNAME',SEQ] = PPFILE                                                                            ; Add the full file name to the D3 database
        PPDHASH['FILE_DB','NAME',SEQ] = (FILE_PARSE(PPFILE)).NAME_EXT                                                     ; Add the file "name" to the D3 database
        PPDHASH['FILE_DB','DATE_RANGE',SEQ] = DRANGE                                                                          ; Add the "daterange" to the D3 database
        PPDHASH['FILE_DB','INPUT_FILES',SEQ] = INFILES                                                                        ; Add the "input" files to the D3 database
        PPDHASH['FILE_DB','ORIGINAL_FILES',SEQ] = STRJOIN([CDB[CSQ].INPUT_FILES,PDB[PSQ].INPUT_FILES,SDB[SSQ].INPUT_FILES],';')
        
        PLUN, LUN, 'Calculating PP for ' + CPER, 0
        CASE ALG OF
          'VGPM':  PPD=PP_VGPM( CHL=CSAT[OKALL], SST=SSAT[OKALL], PAR=PSAT[OKALL], DAY_LENGTH=DAY_LENGTH[OKALL])
          'VGPM2': PPD=PP_VGPM2(CHL=CSAT[OKALL], SST=SSAT[OKALL], PAR=PSAT[OKALL], DAY_LENGTH=DAY_LENGTH[OKALL])        
        ENDCASE ; ALG
        
        ; ===> Loop through the OUTPROD and add to the PPHASH
        FOR O=0, N_ELEMENTS(OUTPRODS)-1 DO BEGIN
          OPROD = OUTPRODS[O]                                                                                               ; Get the name of the "stat"
          IF ~STRUCT_HAS(PPD,OPROD) THEN MESSAGE, 'ERROR: Check that the output product matches the PPHASH prods key'                       ; Make sure the stat names align
          BLANK = CSAT & BLANK[*] = MISSINGS(BLANK) ; Create a blank array for the output products
          BLANK[OKALL] = PPD.(WHERE(TAG_NAMES(PPD) EQ OPROD))
          PPDHASH[OPROD,*,*,SEQ] = BLANK
        ENDFOR ; OUTPRODS
      ENDFOR ; DB.PERIOD  
    
        
      ; ===> Update the metadata and save the HASH file
      IF KEYWORD_SET(WRITEFILE) THEN BEGIN
        PPDHASH['METADATA'] = D3HASH_METADATA(PPFILE, DB=PPDHASH['FILE_DB'])
        PLUN, LUN, 'Writing ' + PPFILE
        SAVE, PPDHASH, FILENAME=PPFILE, /COMPRESS                                                                          ; Save the file
      ENDIF
      PPDHASH = []                                                                                                          ; Remove the STATHASH to clear up memory

    ENDFOR ; MODELS
  ENDFOR ; FILES
  
  DONE:


END ; ***************** End of STACKED_MAKE_PRODS_PPD *****************
