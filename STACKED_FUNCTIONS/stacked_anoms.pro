; $ID:	STACKED_ANOMS.PRO,	2023-09-21-13,	USER-KJWH	$
  PRO STACKED_ANOMS, STATFILES, CLIMATOLOGY, DIR_OUT=DIR_OUT, ANOM=ANOM, DATARANGE=DATARANGE, LABEL_EXTRA=LABEL_EXTRA, RETURN_DATA=RETURN_DATA, RETURN_STRUCT=RETURN_STRUCT, LOGLUN=LOGLUN, OVERWRITE=OVERWRITE

;+
; NAME:
;   STACKED_ANOMS
;
; PURPOSE:
;   $PURPOSE$
;
; CATEGORY:
;   STACKED_FUNCTIONS
;
; CALLING SEQUENCE:
;   STACKED_ANOMS,$Parameter1$, $Parameter2$, $Keyword=Keyword$, ....
;
; REQUIRED INPUTS:
;   STATFILES
;   CLIMATOLOGY
;
; OPTIONAL INPUTS:
;   DIR_OUT.......  Output directory for the ANOMFILE
;   ANOM..........  Type of anomaly to calculate (RATIO and/or DIFFERENCE)
;   DATARANGE.....  Range of acceptable input data 
;   LABEL_EXTRA...  Extra info to include in the output ANOMFILE name
;   LOGLUN........ If provided, then lun for the log file
;   
; KEYWORD PARAMETERS:
;   RETURN_DATA... Return just the anomaly DATA instead of saving the file
;   RETURN_STRUCT. Return the anomaly STRUCTURE instead of saving the file 
;   OVERWRITE..... Overwrite an existing ANOMFILE
;
; OUTPUTS:
;   This program returns anomaly data, structure or a stacked anomaly save file
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
;   This routine was adapted from MAKE_ANOM_SAVES
;   
; COPYRIGHT: 
; Copyright (C) 2022, Department of Commerce, National Oceanic and Atmospheric Administration, National Marine Fisheries Service,
;   Northeast Fisheries Science Center, Narragansett Laboratory.
;   This software may be used, copied, or redistributed as long as it is not sold and this copyright notice is reproduced on each copy made.
;   This routine is provided AS IS without any express or implied warranties whatsoever.
;
; AUTHOR:
;   This program was written on December 08, 2022 by Kimberly J. W. Hyde, Northeast Fisheries Science Center | NOAA Fisheries | U.S. Department of Commerce, 28 Tarzwell Dr, Narragansett, RI 02882
;    
; MODIFICATION HISTORY:
;   Dec 08, 2022 - KJWH: Initial code written
;   Jan 13, 2022 - KJWH: Changed IF KEYWORD_SET(PRD.LOG) to IF KEYWORD_SET(FIX(PRD.LOG)) to fix the bug with the ANOM designation
;   Jun 01, 2023 - KJWH: Fixed bug with the file MTIME in the database.  Now using UTC (/GMT) time to match up with the SYSTIME
;-
; ****************************************************************************************************
  ROUTINE_NAME = 'STACKED_ANOMS'
  COMPILE_OPT IDL2
  SL = PATH_SEP()
  DASH = '-'
  
  IF ~N_ELEMENTS(STATFILES) THEN MESSAGE, 'ERROR: At least one non-climatology stat file is needed'
  IF N_ELEMENTS(CLIMATOLOGY) NE 1 THEN MESSAGE,'ERROR: Can only input one climatology stat file'
  IF ~N_ELEMENTS(LABEL_EXTRA) THEN LABEL_EXTRA='' ELSE LABEL_EXTRA = DASH + LABEL_EXTRA
  IF ~N_ELEMENTS(LOGLUN)    THEN LOG_LUN = [] ELSE LOG_LUN = LOGLUN

  FS=PARSE_IT(STATFILES,/ALL)
  FC=PARSE_IT(CLIMATOLOGY,/ALL)
  IF SAME([FS.MAP,FC.MAP]) THEN MP = FC.MAP ELSE MESSAGE, 'ERROR: AFILES and BFILES must have the same MAP projection'
  IF SAME([FS.MAP_SUBSET,FC.MAP_SUBSET]) THEN MP = MP + DASH + FC.MAP_SUBSET ELSE MESSAGE, 'ERROR: AFILES and BFILES must have the same MAP subset'
  IF SAME([FS.PXY,FC.PXY]) THEN MP = MP + DASH + FC.PXY ELSE MESSAGE, 'ERROR: AFILES and BFILES must have the same image dimensions (PXY)'
  MP = REPLACE(MP,'--','-') & IF STRPOS(MP,'-',/REVERSE_OFFSET) EQ STRLEN(MP)-1 THEN MP = STRMID(MP,0,STRLEN(MP)-1)

  MS = MAPS_SIZE(MP,PX=PX,PY=PY)

  IF SAME([FS.PROD,FC.PROD]) THEN PROD = FC.PROD ELSE MESSAGE, 'ERROR: AFILES and BFILES must have the same PROD'
  PRD = PRODS_READ(PROD)
  IF PRD EQ [] THEN MESSAGE, 'ERROR: ' + PROD + ' is not a valid product name'
  IF KEYWORD_SET(FIX(PRD.LOG)) THEN ANOM = 'RATIO' ELSE ANOM = 'DIF'
  
  IF N_ELEMENTS(DATARANGE) NE 2 THEN DRANGE = VALIDS('PROD_CRITERIA',PROD) ELSE DRANGE=DATARANGE

  IF ~N_ELEMENTS(DIR_OUT) THEN DIR_OUT = REPLACE(FS[0].DIR,['SAVE','STATS','NC'],['ANOMS','ANOMS','ANOMS'])
  DIR_TEST, DIR_OUT

  ; ===> GET FILE SPECIFIC INFORMATION TO CREATE THE OUTPUT FILE LABEL
  IF SAME([FS.SENSOR,FC.SENSOR])     THEN SENSOR   = FC.SENSOR   ELSE SENSOR   = FS[0].SENSOR   + UL + FC.SENSOR
  IF SAME([FS.METHOD,FC.METHOD])     THEN METHOD   = FC.METHOD   ELSE METHOD   = FS[0].METHOD   + DASH + FC.METHOD
  IF SAME([FS.COVERAGE,FC.COVERAGE]) THEN COVERAGE = FC.COVERAGE ELSE COVERAGE = FS[0].COVERAGE + DASH + FC.COVERAGE
  IF SAME([FS.ALG,FC.ALG])           THEN ALG      = FC.ALG      ELSE ALG      = FS[0].ALG      + DASH + FC.ALG
  IF SAME([FS.STATS,FC.STATS])       THEN STAT     = FC.STATS    ELSE STAT     = FS[0].STATS    + DASH + FC.STATS
  FILE_LABEL = SENSOR+DASH+FILE_LABEL_MAKE(STRJOIN([METHOD,COVERAGE,MP,PROD,ALG,STAT],'-')+'.')

  IF ANOM EQ 'RATIO' AND FS[0].PERIOD_CODE NE 'DD' THEN STAG = PROD + '_GMEAN' ELSE STAG = PROD + '_MEAN'
  IF ANOM EQ 'RATIO' AND FC.PERIOD_CODE NE 'DD' THEN CTAG = PROD + '_GMEAN' ELSE CTAG = PROD + '_MEAN'
  IF FS[0].PERIOD_CODE EQ 'DD' THEN STAG = PROD

  CDAT = []
  FOR S=0, N_ELEMENTS(STATFILES)-1 DO BEGIN
    PERIOD = FS[S].PERIOD+DASH+FC.PERIOD 
    ANOM_FILE = DIR_OUT+PERIOD+DASH+FILE_LABEL+DASH+'ANOM'+LABEL_EXTRA+'.SAV'
    IF FILE_MAKE([STATFILES[S],CLIMATOLOGY],ANOM_FILE,OVERWRITE=OVERWRITE) EQ 0 THEN CONTINUE
  
    IF CDAT EQ [] THEN BEGIN
      CDATA = STACKED_READ(CLIMATOLOGY,DB=CDB,BINS=CBINS)
      CDAT = STRUCT_GET(CDATA,CTAG) & GONE, CDATA
      CPER = PERIOD_2STRUCT(CDB.PERIOD)
      IF CDAT EQ [] THEN MESSAGE, 'ERROR: ' + CTAG + ' not found in ' + CLIMATOLOGY
      CSZ = SIZEXYZ(CDAT,PX=CPX,PY=CPY,PZ=CPZ)
    ENDIF
    
    SDATA = STACKED_READ(STATFILES[S], PRODS=PRODS, KEYS=AKEYS, DB=SDB, INFO=SINFO, BINS=SBINS)
    SPER = PERIOD_2STRUCT(SDB.PERIOD)

    OK = WHERE(SBINS NE CBINS, COUNT) & IF COUNT GT 0 THEN MESSAGE, 'ERROR: The BINS in the input files do not match.'
    SDAT = STRUCT_GET(SDATA,STAG) & GONE, SDATA
    IF SDAT EQ [] THEN MESSAGE, 'ERROR: ' + STAG + ' not found in ' + STATFILES[S]

    SSZ = SIZEXYZ(SDAT,PX=SPX,PY=SPY,PZ=SPZ)
    IF SPX NE CPX OR SPY NE CPY THEN MESSAGE, 'ERROR: The array dimenions for the input files do not match'

    ; ===> Create or read the HASH obj
    IF ANOMHASH EQ [] THEN BEGIN
      IF ~FILE_TEST(ANOM_FILE) THEN ANOMHASH = D3HASH_MAKE(ANOM_FILE, INPUT_FILES=STATFILES, BINS=CBINS, PRODS=PROD, $
        PX=CPX, PY=CPY, ANOM_TYPES=ANOM, DO_ANOMS=1) $
      ELSE ANOMHASH = IDL_RESTORE(ANOM_FILE)    ; Read the D3HASH file if it already exists and extract the D3 dabase
        
      IF IDLTYPE(ANOMHASH) NE 'OBJREF' THEN MESSAGE, 'ERROR: Unable to properly create or read the HASH obj'                                                ; Read the existing D3 file
      DBANOM = ANOMHASH['FILE_DB'].TOSTRUCT()
      D3_KEYS = ANOMHASH.KEYS() & D3_KEYS = D3_KEYS.TOARRAY()                                                                  ; Get the D3HASH key names and convert the LIST to an array
      D3_ANOM = REMOVE(D3_KEYS,VALUES=['FILE_DB','PRODS','BINS','INFO','METADATA'])
      IF N_ELEMENTS(D3_ANOM) NE 1 THEN MESSAGE, 'ERROR: Double check the anomaly products in the ANOMHASH'  ELSE D3_ANOM = D3_ANOM[0]                                        ; Keep just the D3 variable names
      DBCHECK = D3HASH_DB(ANOM_FILE,/ADD_INFILES,/ADD_ORIGINAL)                                                              ; Recreate the stat database to update the current DBSTAT if needed
      DBCHECK = STRUCT_RENAME(DBCHECK, ['FULLNAME','NAME'],['ANOMFILE','ANOMNAME'])
    ENDIF
  
       
    FOR R=0, N_ELEMENTS(SPER)-1 DO BEGIN
      APER = SPER[R]
      OKDB = WHERE(SDB.PERIOD EQ APER.PERIOD,/NULL)
      IF OKDB EQ [] THEN CONTINUE
      CASE APER.PERIOD_CODE OF
        'D': OKPER = WHERE(CPER.PERIOD_CODE EQ 'DOY'   AND CPER.DOY_START   EQ APER.DOY_START,/NULL)
        'W': OKPER = WHERE(CPER.PERIOD_CODE EQ 'WEEK'  AND CPER.WEEK_START  EQ APER.WEEK_START,/NULL)
        'M': OKPER = WHERE(CPER.PERIOD_CODE EQ 'MONTH' AND CPER.MONTH_START EQ APER.MONTH_START,/NULL)
        'A': OKPER = WHERE(CPER.PERIOD_CODE EQ 'ANNUAL',/NULL)
      ENDCASE
      IF OKPER EQ [] THEN CONTINUE
      PER = APER.PERIOD[OKPER]
      IF SDB[OKDB].MTIME EQ 0 THEN CONTINUE
      
      SEQ = WHERE(ANOMHASH['FILE_DB','PERIOD'] EQ PER[0],COUNT)
      IF COUNT EQ 0 THEN MESSAGE, 'ERROR: ' + PER + ' not found in the ANOMHASH database'
      
      ; ===> Add the file information to the D3 database in the D3HASH
      ANOMHASH['FILE_DB','MTIME',SEQ] = DATE_NOW(/MTIME,/GMT)                                                                     ; Add the file MTIME to the D3 database
      ANOMHASH['FILE_DB','ANOMFILE',SEQ] = ANOM_FILE                                                                         ; Add the full file name to the D3 database
      ANOMHASH['FILE_DB','ANOMNAME',SEQ] = (FILE_PARSE(ANOM_FILE)).NAME_EXT                                                  ; Add the file "name" to the D3 database
      ANOMHASH['FILE_DB','DATE_RANGE',SEQ] = DRANGE                                                                          ; Add the "daterange" to the D3 database
      ANOMHASH['FILE_DB','INPUT_FILES',SEQ] = STRJOIN([STATFILES[S],CLIMATOLOGY],'; ')                                       ; Add the "input" files to the D3 database
      ANOMHASH['FILE_DB','ORIGINAL_FILES',SEQ] = SDB[OKDB] .ORIGINAL_FILES                                                    ; Concatenate the "original" input files and add to the DB structure
                                                                              
      ; ===> Get the period specific data              
      CDT = CDAT[*,*,OKPER]
      SDT = SDAT[*,*,R]
      
      ; ===> Find the VALID data for each file and create a simple byte array to determine where both arrays have VALID data
      BIMAGE = BYTARR(CPX,CPY)
      BIMAGE[*,*] = 0
      VS = VALID_DATA(SDT,PROD=FS.PROD,RANGE=DRANGE,SUBS=SUBS,COUNT=COUNTS) & IF COUNTS EQ 0 THEN CONTINUE & BIMAGE[SUBS] = BIMAGE[SUBS] + 1
      VC = VALID_DATA(CDT,PROD=FC.PROD,RANGE=DRANGE,SUBS=SUBC,COUNT=COUNTC) & IF COUNTC EQ 0 THEN CONTINUE & BIMAGE[SUBC] = BIMAGE[SUBC] + 1
      
      ; ===> Find subscripts where both images have valid data and calculate the anomaly
      OK_DATA = WHERE(BIMAGE EQ 2,COUNT_DATA) & IF COUNT_DATA EQ 0 THEN CONTINUE

      ; ===> Add the anomaly output to the D3HASH
      PLUN, LUN, 'Calculating anomalies for ' + PER, 0
      CASE ANOM OF
        'RATIO': ANOMHASH[D3_ANOM,*,OK_DATA,SEQ]=SDT[OK_DATA]/CDT[OK_DATA]
        'DIF':   ANOMHASH[D3_ANOM,*,OK_DATA,SEQ]=SDT[OK_DATA]-CDT[OK_DATA]
      ENDCASE
      
    ENDFOR ; PERIODS
   
    ; ===> Update the metadata and file information
    ANOMHASH['METADATA'] = D3HASH_METADATA(ANOM_FILE, DB=ANOMHASH['FILE_DB'])                       ; Add the metadata for the file to the hash                                                                                                 ; Change the DATATYPE to stat

    ; ===> Save the ANOMHASH file
    PLUN, LUN, 'Writing ' + ANOM_FILE
    SAVE, ANOMHASH, FILENAME=ANOM_FILE, /COMPRESS                                                                          ; Save the file
    ANOMHASH = []                                                                                                          ; Remove the STATHASH to clear up memory
    
  ENDFOR ; STATFILES  
    
END ; ***************** End of STACKED_ANOMS *****************
