; $ID:	STACKED_MAKE_PRODS_PSC.PRO,	2023-09-21-13,	USER-KJWH	$
  PRO STACKED_MAKE_PRODS_PSC, CHLFILES=CHLFILES, SSTFILES=SSTFILES, $
                              CHL_RANGE=CHL_RANGE, SST_RANGE=SST_RANGE, PSC_ALGS=PSC_ALGS, ALG_VERSION=ALG_VERSION, $
                              FILE_LABEL=FILE_LABEL, DIR_OUT=DIR_OUT, LOGLUN=LOGLUN,$
                              OVERWRITE=OVERWRITE

;+
; NAME:
;   STACKED_MAKE_PRODS_PSC
;
; PURPOSE:
;   Program to run the phytoplankton size class models and save as a "stacked" output file
;
; CATEGORY:
;   STACKED_FUNCTIONS
;
; CALLING SEQUENCE:
;   STACKED_MAKE_PRODS_PSC,$Parameter1$, $Parameter2$, $Keyword=Keyword$, ....
;
; REQUIRED INPUTS:
;   CHLFILES........ An array of chlorophyll input files (daily "stacks")
;   SSTFILES........ An array of sea surface temperature input files (daily "stacks")
;
; OPTIONAL INPUTS:
;   CHL_RANGE....... The range of "valid" chlorophyll data
;   SST_RANGE....... The range of "valid" SST data
;   PSC_ALGS........ Describe optional inputs here. If none, delete this section.
;   ALG_VERSION..... The algorithm version passed to the specific algorithm program
;   FILE_LABEL...... The label for the output file
;   DIR_OUT......... The output directory
;   LOGLUN.......... The LUN for writing to log files
;
; KEYWORD PARAMETERS:
;   OVERWRITE........ Overwrite exiting files
;   
; OUTPUTS:
;   Phytoplankton size class stacked files
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
;   This program was written on November 30, 2022 by Kimberly J. W. Hyde, Northeast Fisheries Science Center | NOAA Fisheries | U.S. Department of Commerce, 28 Tarzwell Dr, Narragansett, RI 02882
;    
; MODIFICATION HISTORY:
;   Nov 30, 2022 - KJWH: Initial code written
;   Mar 10, 2022 - KJWH: Added Hirata algorithm
;   Mar 15, 2023 - KJWH: Updated documentation
;-
; ****************************************************************************************************
  ROUTINE_NAME = 'STACKED_MAKE_PRODS_PSC'
  COMPILE_OPT IDL2
  SL = PATH_SEP()

  IF ~N_ELEMENTS(LOGLUN) THEN LOG_LUN = [] ELSE LOG_LUN = LOGLUN

  ; ===> Check input files and ranges
  IF ~N_ELEMENTS(CHLFILES) THEN MESSAGE, 'ERROR: Must provide CHL input files'
  IF N_ELEMENTS(CHL_RANGE) NE 2 THEN CRANGE = [0.0  , 189.0] ELSE CRANGE = CHL_RANGE
  IF N_ELEMENTS(SST_RANGE) NE 2 THEN SRANGE = [-3.0 ,  37.0] ELSE SRANGE = SST_RANGE
  INPUT_PRODS = ['CHLOR_A']
  
  ; ===> Check other input variables
  IF ~N_ELEMENTS(PSC_ALGS) THEN ALGS = 'TURNER' ELSE ALGS = PSC_ALGS
  VALID = VALIDS('ALGS',ALGS,/VALID)
  OK = WHERE(VALID EQ 0,COUNT,COMPLEMENT=COMP,NCOMPLEMENT=NCOMP)
  IF COUNT GE 1 THEN PLUN, LOG_LUN, 'ERROR: Invalid PSC Algorithm(s) - ',ALGS[OK]
  IF NCOMP GE 1 THEN ALGS = ALGS[OK] ELSE MESSAGE, 'ERROR: No valid PSC algorithms provided'

  ; ===> Get file info
  FCS = PARSE_IT(CHLFILES,/ALL)
  
  ; ===> Create output directory and file name(s)
  IF ~N_ELEMENTS(DIR_OUT) THEN DIR_OUT = REPLACE(FCS[0].DIR,FCS[0].SUB,'PSC-'+ALGS)                                                 ; Create the output directory
  DIR_OUT = REPLACE(DIR_OUT,'STACKED_INTERP','STACKED_SAVE')                                                                        ; Update the output directory
  DIR_TEST, DIR_OUT                                                                                                                 ; Make the output directory folder
  IF ~N_ELEMENTS(FILE_LABEL) THEN FLABEL=FILE_LABEL_MAKE(CHLFILES[0],LST=['SENSOR','VERSION','SATELLITE','SAT_EXTRA','METHOD','MAP']) ELSE FLABEL=FILE_LABEL ; Create the output file label
  
  ; ===> Loop through files
  NFILES = N_ELEMENTS(CHLFILES)
  FOR F=0, NFILES-1 DO BEGIN
    CFLE = CHLFILES[F]                                                                                                              ; Get the file
    INFILES = CFLE
    FC = FCS[F]
    PERIOD = FC.PERIOD
    PSTR = PERIOD_2STRUCT(PERIOD)
    DRANGE = STRJOIN(STRMID([PSTR.DATE_START,PSTR.DATE_END],0,8),'_')                                                      ; Get the daterange for the period

    CSAT = [] & SSAT = []
    FOR A=0, N_ELEMENTS(ALGS)-1 DO BEGIN
      ALG = ALGS[A]
      ALABEL = FLABEL + '-PSC-' + ALG
      
      CASE ALG OF
        'TURNER': BEGIN & ALG_VER='V1' & INPUT_PRODS=['CHLOR_A','SST'] & OPRODS=['CHLOR_A','PSC_MICRO','PSC_NANO','PSC_PICO'] & END
        'HIRATA': BEGIN & ALG_VER='V1' & INPUT_PRODS=['CHLOR_A'] & OPRODS=['CHLOR_A','PSC_MICRO','PSC_NANO','PSC_PICO','PSC_DIATOM','PSC_DINOFLAGELLATE'] & END
      ENDCASE
      IF N_ELEMENTS(ALG_VERSION) GT 0 THEN ALG_VER = ALG_VERSION
      
      ; ===> Find the matching SST file if needed
      IF HAS(INPUT_PRODS,'SST') THEN BEGIN
        IF ~N_ELEMENTS(SSTFILES) THEN MESSAGE, 'ERROR: Must provide SST input files'
        FSS = PARSE_IT(SSTFILES)
        SFLE = SSTFILES[WHERE(FSS.PERIOD EQ FC.PERIOD,/NULL,COUNTS)] & IF COUNTS EQ 0 THEN CONTINUE 
        IF COUNTS NE 1 THEN MESSAGE, 'ERROR: More than 1 SST file found for period ' + PERIOD
        FS = PARSE_IT(SFLE)
        INFILES = [CFLE,SFLE]
      ENDIF  

      PSCFILE = DIR_OUT + PERIOD + '-' + ALABEL + '.SAV'
      IF ~FILE_MAKE(INFILES,PSCFILE,OVERWRITE=OVERWRITE) THEN CONTINUE

      ; ===> Read the data
      IF CSAT EQ [] THEN CSAT = STACKED_READ(CFLE,DB=CDB,BINS=CBINS)
      IF SSAT EQ [] AND SFLE NE [] THEN SSAT = STACKED_READ(SFLE,DB=SDB,BINS=SBINS)

      ; ===> Check that the files were opened correctly
      FILECHECK = [IDLTYPE(CSAT),IDLTYPE(SSAT)]
      OK = WHERE(FILECHECK EQ 'STRING',COUNT)
      IF COUNT GT 0 THEN BEGIN
        PLUN, LOG_LUN, 'ERROR: Reading the input files for ' + INFILES[OK]
        CONTINUE
      ENDIF

      ; ===> Check that the data sizes are the same
      CDAT = CSAT.CHLOR_A & CSZ = SIZEXYZ(CDAT,PX=XC,PY=YC,PZ=ZC)
      IF SSAT NE [] THEN BEGIN
        SDAT = SSAT.SST     & SSZ = SIZEXYZ(SDAT,PX=XS,PY=YS,PZ=ZS)      
        IF XC NE XS THEN MESSAGE, 'ERROR: The X dimensions in the input data do not match'
        IF YC NE YS THEN MESSAGE, 'ERROR: The Y dimensions in the input data do not match'
        IF ZC NE ZS THEN MESSAGE, 'ERROR: The Z dimensions in the input data do not match'
      ENDIF  

      ; ===> Get PROD specific information to add to the INFO structure
      INFO_CONTENT = []
      FOR I=0, N_ELEMENTS(INPUT_PRODS)-1 DO BEGIN                                                                                         ; Loop through the products
        PR = PRODS_READ(INPUT_PRODS[I])                                                                                                 ; Get product specific information
        CASE PR.PROD OF
          'CHLOR_A':BEGIN & IALG = FC.ALG & RNG = CRANGE & END
          'SST':    BEGIN & IALG = '' & RNG = SRANGE & END
        ENDCASE
        DSTR = CREATE_STRUCT('PROD',PR.PROD,'ALG',IALG,'UNITS',PR.UNITS,'LONG_NAME',PR.CF_LONG_NAME, $                      ; Extract product specific information
          'STANDARD_NAME',PR.CF_STANDARD_NAME,'VALID_MIN',MIN(RNG),'VALID_MAX',MAX(RNG))
        INFO_CONTENT = CREATE_STRUCT(INFO_CONTENT,PR.PROD,DSTR)                                                                                  ; Add product specific information to the structure
      ENDFOR ; INPUT_PRODS
      
      ; ===> Create or read the HASH obj
      IF PSCHASH EQ [] THEN BEGIN
        IF ~FILE_TEST(PSCFILE) THEN PSCHASH = D3HASH_MAKE(PSCFILE, INPUT_FILES=INFILES, BINS=CBINS, PRODS=OPRODS, PX=CX, PY=CY, ADD_INFO='INPUT_PRODUCTS',INFO_CONTENT=INFO_CONTENT) $
                               ELSE PSCHASH = IDL_RESTORE(PSCFILE)    ; Read the D3HASH file if it already exists and extract the D3 dabase
      ENDIF

      IF IDLTYPE(PSCHASH) NE 'OBJREF' THEN MESSAGE, 'ERROR: Unable to properly create or read the HASH obj'                                                ; Read the existing D3 file
      PSCDB = PSCHASH['FILE_DB'].TOSTRUCT()
      D3_KEYS = PSCHASH.KEYS() & D3_KEYS = D3_KEYS.TOARRAY()                                                                  ; Get the D3HASH key names and convert the LIST to an array
      D3_PRODS = REMOVE(D3_KEYS,VALUES=['FILE_DB','PRODS','BINS','INFO','METADATA'])                                           ; Keep just the D3 variable names

      WRITEFILE = 0
      FOR D=0, N_ELEMENTS(CDB)-1 DO BEGIN
        CPER = CDB[D].PERIOD
        DP = DATE_PARSE(PERIOD_2DATE(CDB[D].PERIOD))

        ; ===> Find the matching periods in the databases
        CSQ = CDB[D].SEQ
        IF SSAT NE [] THEN SSQ = SDB[WHERE(SDB.PERIOD EQ CDB[D].PERIOD,/NULL)].SEQ
        SEQ = WHERE(PSCHASH['FILE_DB','PERIOD'] EQ CDB[D].PERIOD,/NULL)
        IF SSAT NE [] AND  SSQ EQ [] THEN MESSAGE, 'ERROR: Unable to find a matching SST period for ' + CPER
        IF SEQ EQ [] THEN MESSAGE, 'ERROR: Unable to find matching PPD period for ' + CPER

        ; ===> Get the data for each variable
        CSAT = CDAT[*,*,CSQ]
        IF SSAT NE [] THEN BEGIN
          SSAT = SDAT[*,*,SSQ]
          OKALL = WHERE(CSAT NE MISSINGS(CSAT) AND CSAT GT CRANGE[0] AND CSAT LT CRANGE[1] AND $
            SSAT NE MISSINGS(SSAT) AND SSAT GT SRANGE[0] AND SSAT LT SRANGE[1],COUNT_ALL)
        ENDIF ELSE OKALL = WHERE(CSAT NE MISSINGS(CSAT) AND CSAT GT CRANGE[0] AND CSAT LT CRANGE[1], COUNT_ALL)
        
        IF COUNT_ALL EQ 0 THEN PLUN, LOG_LUN, 'No valid data found, SKIPPING ' + CDB[D].PERIOD,0
        IF COUNT_ALL EQ 0 THEN CONTINUE ; Continue if no valid data

        ; ===> Check the daily MTIMES
        INMTIMES = CDB[CSQ].MTIME
        IF SSAT NE [] THEN INMTIMES=[INMTIMES,SDB[SSQ].MTIME]
        IF PSCHASH['FILE_DB','MTIME',SEQ] GE MAX(INMTIMES) AND ~KEYWORD_SET(OVERWRITE) THEN CONTINUE                     ; Check the MTIMES in the file DB and skip if the data is already in the database and does not need to be updated
        WRITEFILE = 1

        ; ===> Add the file information to the D3 database in the D3HASH
        PSCHASH['FILE_DB','MTIME',SEQ] = DATE_NOW(/MTIME)                                                                     ; Add the file MTIME to the D3 database
        PSCHASH['FILE_DB','FULLNAME',SEQ] = PSCFILE                                                                            ; Add the full file name to the D3 database
        PSCHASH['FILE_DB','NAME',SEQ] = (FILE_PARSE(PSCFILE)).NAME_EXT                                                     ; Add the file "name" to the D3 database
        PSCHASH['FILE_DB','DATE_RANGE',SEQ] = DRANGE                                                                          ; Add the "daterange" to the D3 database
        PSCHASH['FILE_DB','INPUT_FILES',SEQ] = INFILES                                                                        ; Add the "input" files to the D3 database
        
        ORGFILES = CDB[CSQ].INPUT_FILES
        IF SSAT NE [] THEN ORGFILES = [ORGFILES,SDB[SSQ].INPUT_FILES]
        PSCHASH['FILE_DB','ORIGINAL_FILES',SEQ] = STRJOIN(ORGFILES,';')

        PLUN, LUN, 'Calculating PSC for ' + CPER, 0
        CASE ALG OF
          'TURNER': PHYTO = PHYTO_SIZE_TURNER(CSAT[OKALL], SST=SSAT[OKALL], VERSION=ALG_VER, INIT=INIT, VERBOSE=VERBOSE)
          'HIRATA': PHYTO = PHYTO_SIZE_HIRATA(CSAT[OKALL],VERSION=ALG_VER)
        ENDCASE

        ; ===> Loop through the OUTPROD and add to the PPHASH
        FOR O=0, N_ELEMENTS(OPRODS)-1 DO BEGIN
          OPROD = OPRODS[O]                                                                                               ; Get the name of the "stat"
          IF ~STRUCT_HAS(PHYTO,OPROD) THEN MESSAGE, 'ERROR: Check that the output product matches the PPHASH prods key'                       ; Make sure the stat names align
          BLANK = CSAT & BLANK[*] = MISSINGS(BLANK) ; Create a blank array for the output products
          BLANK[OKALL] = PHYTO.(WHERE(TAG_NAMES(PHYTO) EQ OPROD))
          PSCHASH[OPROD,*,*,SEQ] = BLANK
        ENDFOR ; INPUT PRODS
      ENDFOR ; DB.PERIOD


      ; ===> Update the metadata and save the HASH file
      IF KEYWORD_SET(WRITEFILE) THEN BEGIN
        PSCHASH['METADATA'] = D3HASH_METADATA(PSCFILE, DB=PSCHASH['FILE_DB'])
        PLUN, LUN, 'Writing ' + PSCFILE
        SAVE, PSCHASH, FILENAME=PSCFILE, /COMPRESS                                                                          ; Save the file
      ENDIF
      PSCHASH = []
      
    ENDFOR ; ALGS
    
  ENDFOR ; FILES    

END ; ***************** End of STACKED_MAKE_PRODS_PSC *****************
