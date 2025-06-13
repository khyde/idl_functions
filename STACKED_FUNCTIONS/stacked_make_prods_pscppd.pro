; $ID:	STACKED_MAKE_PRODS_PSCPPD.PRO,	2023-09-21-13,	USER-KJWH	$
  PRO STACKED_MAKE_PRODS_PSCPPD, PPDFILES=PPDFILES, PSCFILES=PSCFILES, $
                      PPD_ALGS=PPD_ALGS, ALG_VERSION=ALG_VERSION, $
                      FILE_LABEL=FILE_LABEL, DIR_OUT=DIR_OUT, LOGLUN=LOGLUN,$
                      OVERWRITE=OVERWRITE

;+
; NAME:
;   STACKED_MAKE_PRODS_PSCPPD
;
; PURPOSE:
;   Program to run the phytoplankton size class primary production algorithm and save as a "stacked" output file
;
; CATEGORY:
;   STACKED_FUNCTIONS
;
; CALLING SEQUENCE:
;   Result = STACKED_MAKE_PRODS_PSCPPD($Parameter1$, $Parameter2$, $Keyword=Keyword$, ...)
;
; REQUIRED INPUTS:
;   PPDFILES........ An array of primary production input files (montly "stacked" statistics)
;   PSCFILES........ An array of phytoplankton size class input files (monthly "stacked" statistics)
;;
; OPTIONAL INPUTS:
;   PPD_ALGS........ The algorithm name
;   ALG_VERSION..... The algorithm version passed to the specific algorithm program
;   FILE_LABEL...... The label for the output file
;   DIR_OUT......... The output directory
;   LOGLUN.......... The LUN for writing to log files
;
; KEYWORD PARAMETERS:
;   OVERWRITE........ Overwrite exiting files
;   
; OUTPUTS:
;   Phytoplankton size class primary production stacked files
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
; Copyright (C) 2023, Department of Commerce, National Oceanic and Atmospheric Administration, National Marine Fisheries Service,
;   Northeast Fisheries Science Center, Narragansett Laboratory.
;   This software may be used, copied, or redistributed as long as it is not sold and this copyright notice is reproduced on each copy made.
;   This routine is provided AS IS without any express or implied warranties whatsoever.
;
; AUTHOR:
;   This program was written on July 03, 2023 by Kimberly J. W. Hyde, Northeast Fisheries Science Center | NOAA Fisheries | U.S. Department of Commerce, 28 Tarzwell Dr, Narragansett, RI 02882
;    
; MODIFICATION HISTORY:
;   Jul 03, 2023 - KJWH: Initial code written
;-
; ****************************************************************************************************
  ROUTINE_NAME = 'STACKED_MAKE_PRODS_PSCPPD'
  COMPILE_OPT IDL2
  SL = PATH_SEP()
  
  IF ~N_ELEMENTS(LOGLUN) THEN LOG_LUN = [] ELSE LOG_LUN = LOGLUN

  ; ===> Check input files and ranges
  IF ~N_ELEMENTS(PPDFILES) OR ~N_ELEMENTS(PSCFILES) THEN MESSAGE, 'ERROR: Must provide PPD and PSC input files'
  INPUT_PRODS = ['PPD','PSC']

  ; ===> Check other input variables
  IF ~N_ELEMENTS(PPD_ALGS) THEN ALGS = 'MARMAP' ELSE ALGS = PPD_ALGS
  VALID = VALIDS('ALGS',ALGS,/VALID)
  OK = WHERE(VALID EQ 0,COUNT,COMPLEMENT=COMP,NCOMPLEMENT=NCOMP)
  IF COUNT GE 1 THEN PLUN, LOG_LUN, 'ERROR: Invalid PSC Algorithm(s) - '+ALGS[OK]
  IF NCOMP GE 1 THEN ALGS = ALGS[OK] ELSE MESSAGE, 'ERROR: No valid PSC algorithms provided'

  ; ===> Get file info
  FPP = PARSE_IT(PPDFILES,/ALL)
  FSC = PARSE_IT(PSCFILES)

  ; ===> Create output directory and file name(s)
  IF ~N_ELEMENTS(DIR_OUT) THEN DIR_OUT = REPLACE(FPP[0].DIR,FPP[0].SUB,'PSCPPD-'+ALGS)                                                 ; Create the output directory
  DIR_TEST, DIR_OUT                                                                                                                 ; Make the output directory folder
  IF ~N_ELEMENTS(FILE_LABEL) THEN FLABEL=FILE_LABEL_MAKE(PPDFILES[0],LST=['SENSOR','VERSION','SATELLITE','SAT_EXTRA','METHOD','MAP']) ELSE FLABEL=FILE_LABEL ; Create the output file label

  ; ===> Loop through files
  NFILES = N_ELEMENTS(PPDFILES)
  FOR F=0, NFILES-1 DO BEGIN
    DFLE = PPDFILES[F]                                                                                                              ; Get the file
    FP = FPP[F]
    PERIOD = FP.PERIOD
    PSTR = PERIOD_2STRUCT(PERIOD)
    DRANGE = STRJOIN(STRMID([PSTR.DATE_START,PSTR.DATE_END],0,8),'_')                                                      ; Get the daterange for the period

    DSAT = [] & SSAT = []
    FOR A=0, N_ELEMENTS(ALGS)-1 DO BEGIN
      ALG = ALGS[A]
      ALABEL = FLABEL + '-PSC-' + ALG

      CASE ALG OF
        'MARMAP': BEGIN & ALG_VER='V1' & INPUT_PRODS=['PPD','PSC_FMICRO'] & OPRODS=['PPD','PSC_MICRO','PSCPPD_MICRO','PSCPPD_NANOPICO','PSCPPD_FMICRO','PSCPPD_FNANOPICO'] & END
      ENDCASE
      IF N_ELEMENTS(ALG_VERSION) GT 0 THEN ALG_VER = ALG_VERSION

      ; ===> Find the matching PSC file 
      SFLE = PSCFILES[WHERE(FSC.PERIOD EQ FP.PERIOD,/NULL,COUNTS)] & IF COUNTS EQ 0 THEN CONTINUE
      IF COUNTS NE 1 THEN MESSAGE, 'ERROR: More than 1 PSC  file found for period ' + PERIOD
      FS = PARSE_IT(SFLE,/ALL)
      INFILES = [DFLE,SFLE]
    
      OUTFILE = DIR_OUT + PERIOD + '-' + ALABEL + '.SAV'
      IF ~FILE_MAKE(INFILES,OUTFILE,OVERWRITE=OVERWRITE) THEN CONTINUE

      ; ===> Read the data
      IF DSAT EQ [] THEN DSAT = STACKED_READ(DFLE,DB=DDB,BINS=DBINS)
      IF SSAT EQ [] THEN SSAT = STACKED_READ(SFLE,DB=SDB,BINS=SBINS)

      ; ===> Check that the files were opened correctly
      FILECHECK = [IDLTYPE(DSAT),IDLTYPE(SSAT)]
      OK = WHERE(FILECHECK EQ 'STRING',COUNT)
      IF COUNT GT 0 THEN BEGIN
        PLUN, LOG_LUN, 'ERROR: Reading the input files for ' + INFILES[OK]
        CONTINUE
      ENDIF

      ; ===> Check that the data sizes are the same
      DDAT = DSAT.PPD_MEAN & DSZ = SIZEXYZ(DDAT,PX=XD,PY=YD,PZ=ZD)
      SDAT = SSAT.PSC_FMICRO_MEAN  & SSZ = SIZEXYZ(SDAT,PX=XS,PY=YS,PZ=ZS)
      IF XD NE XS THEN MESSAGE, 'ERROR: The X dimensions in the input data do not match'
      IF YD NE YS THEN MESSAGE, 'ERROR: The Y dimensions in the input data do not match'
      IF ZD NE ZS THEN MESSAGE, 'ERROR: The Z dimensions in the input data do not match'
    
      ; ===> Get PROD specific information to add to the INFO structure
      INFO_CONTENT = []
      FOR I=0, N_ELEMENTS(INPUT_PRODS)-1 DO BEGIN                                                                                         ; Loop through the products
        PR = PRODS_READ(INPUT_PRODS[I])                                                                                                 ; Get product specific information
        CASE PR.PROD OF
          'PPD':BEGIN & IALG = FP.ALG & RNG = [PR.PROD_MIN,PR.PROD_MAX] & END
          'PSC_FMICRO':    BEGIN & IALG = FS.ALG & RNG = [PR.PROD_MIN,PR.PROD_MAX] & END
        ENDCASE
        DSTR = CREATE_STRUCT('PROD',PR.PROD,'ALG',IALG,'UNITS',PR.UNITS,'LONG_NAME',PR.CF_LONG_NAME, $                      ; Extract product specific information
          'STANDARD_NAME',PR.CF_STANDARD_NAME,'VALID_MIN',MIN(RNG),'VALID_MAX',MAX(RNG))
        INFO_CONTENT = CREATE_STRUCT(INFO_CONTENT,PR.PROD,DSTR)                                                                                  ; Add product specific information to the structure
      ENDFOR ; INPUT_PRODS

      ; ===> Create or read the HASH obj
      IF PSCHASH EQ [] THEN BEGIN
        IF ~FILE_TEST(OUTFILE) THEN PSCHASH = D3HASH_MAKE(OUTFILE, INPUT_FILES=INFILES, BINS=DBINS, PRODS=OPRODS, PX=CX, PY=CY, ADD_INFO='INPUT_PRODUCTS',INFO_CONTENT=INFO_CONTENT) $
                                                   ELSE PSCHASH = IDL_RESTORE(OUTFILE)    ; Read the D3HASH file if it already exists and extract the D3 dabase
      ENDIF

      IF IDLTYPE(PSCHASH) NE 'OBJREF' THEN MESSAGE, 'ERROR: Unable to properly create or read the HASH obj'                                                ; Read the existing D3 file
      PSCDB = PSCHASH['FILE_DB'].TOSTRUCT()
      D3_KEYS = PSCHASH.KEYS() & D3_KEYS = D3_KEYS.TOARRAY()                                                                  ; Get the D3HASH key names and convert the LIST to an array
      D3_PRODS = REMOVE(D3_KEYS,VALUES=['FILE_DB','PRODS','BINS','INFO','METADATA'])                                           ; Keep just the D3 variable names

      WRITEFILE = 0
      FOR D=0, N_ELEMENTS(DDB.PERIOD)-1 DO BEGIN
        CPER = DDB[D].PERIOD
        DP = DATE_PARSE(PERIOD_2DATE(CPER))

        ; ===> Find the matching periods in the databases
        DSQ = DDB[D].SEQ
        SSQ = SDB[WHERE(SDB.PERIOD EQ DDB[D].PERIOD,/NULL)].SEQ
        SEQ = WHERE(PSCHASH['FILE_DB','PERIOD'] EQ DDB[D].PERIOD,/NULL)
        IF SSQ EQ [] THEN MESSAGE, 'ERROR: Unable to find a matching PSC period for ' + CPER
        IF SEQ EQ [] THEN MESSAGE, 'ERROR: Unable to find matching PPD period for ' + CPER

        ; ===> Get the data for each variable
        DSAT = DDAT[*,*,DSQ]
        SSAT = SDAT[*,*,SSQ]
        OKALL = WHERE(DSAT NE MISSINGS(DSAT) AND DSAT AND SSAT NE MISSINGS(SSAT),COUNT_ALL)
        
        IF COUNT_ALL EQ 0 THEN PLUN, LOG_LUN, 'No valid data found, SKIPPING ' + DDB[D].PERIOD,0
        IF COUNT_ALL EQ 0 THEN CONTINUE ; Continue if no valid data

        ; ===> Check the daily MTIMES
        INMTIMES = DDB[DSQ].MTIME
        IF SSAT NE [] THEN INMTIMES=[INMTIMES,SDB[SSQ].MTIME]
        IF PSCHASH['FILE_DB','MTIME',SEQ] GE MAX(INMTIMES) AND ~KEYWORD_SET(OVERWRITE) THEN CONTINUE                     ; Check the MTIMES in the file DB and skip if the data is already in the database and does not need to be updated
        WRITEFILE = 1

        ; ===> Add the file information to the D3 database in the D3HASH
        PSCHASH['FILE_DB','MTIME',SEQ] = DATE_NOW(/MTIME)                                                                     ; Add the file MTIME to the D3 database
        PSCHASH['FILE_DB','FULLNAME',SEQ] = OUTFILE                                                                            ; Add the full file name to the D3 database
        PSCHASH['FILE_DB','NAME',SEQ] = (FILE_PARSE(OUTFILE)).NAME_EXT                                                     ; Add the file "name" to the D3 database
        PSCHASH['FILE_DB','DATE_RANGE',SEQ] = DRANGE                                                                          ; Add the "daterange" to the D3 database
        PSCHASH['FILE_DB','INPUT_FILES',SEQ] = INFILES                                                                        ; Add the "input" files to the D3 database

        ORGFILES = DDB[DSQ].INPUT_FILES
        IF SSAT NE [] THEN ORGFILES = [ORGFILES,SDB[SSQ].INPUT_FILES]
        PSCHASH['FILE_DB','ORIGINAL_FILES',SEQ] = STRJOIN(ORGFILES,';')

        PLUN, LUN, 'Calculating PSCPPD for ' + CPER, 0
        CASE ALG OF
          'MARMAP': PSCPPD = PHYTO_PP_MARMAP(PP=DSAT[OKALL], MICRO=SSAT[OKALL], VERBOSE=verbose)
        ENDCASE

        ; ===> Loop through the OUTPROD and add to the PPHASH
        FOR O=0, N_ELEMENTS(OPRODS)-1 DO BEGIN
          OPROD = OPRODS[O]                                                                                               ; Get the name of the "stat"
          IF ~STRUCT_HAS(PSCPPD,OPROD) THEN MESSAGE, 'ERROR: Check that the output product matches the PPHASH prods key'                       ; Make sure the stat names align
          BLANK = DSAT & BLANK[*] = MISSINGS(BLANK) ; Create a blank array for the output products
          BLANK[OKALL] = PSCPPD.(WHERE(TAG_NAMES(PSCPPD) EQ OPROD))
          PSCHASH[OPROD,*,*,SEQ] = BLANK
        ENDFOR ; INPUT PRODS
      ENDFOR ; DB.PERIOD


      ; ===> Update the metadata and save the HASH file
      IF KEYWORD_SET(WRITEFILE) THEN BEGIN
        PSCHASH['METADATA'] = D3HASH_METADATA(OUTFILE, DB=PSCHASH['FILE_DB'])
        PLUN, LUN, 'Writing ' + OUTFILE
        SAVE, PSCHASH, FILENAME=OUTFILE, /COMPRESS                                                                          ; Save the file
      ENDIF
      PSCHASH = []

    ENDFOR ; ALGS

  ENDFOR ; FILES


END ; ***************** End of STACKED_MAKE_PRODS_PSCPPD *****************
