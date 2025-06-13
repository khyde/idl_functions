; $ID:	DWLD_FILE_INFO.PRO,	2023-09-21-13,	USER-KJWH	$
  FUNCTION DWLD_FILE_INFO, FILES

;+
; NAME:
;   DWLD_FILE_INFO
;
; PURPOSE:
;   $PURPOSE$
;
; CATEGORY:
;   FILE_FUNCTIONS
;
; CALLING SEQUENCE:
;   Result = DWLD_FILE_INFO($Parameter1$, $Parameter2$, $Keyword=Keyword$, ...)
;
; REQUIRED INPUTS:
;   Parm1.......... Describe the positional input parameters here. 
;
; OPTIONAL INPUTS:
;   Parm2.......... Describe optional inputs here. If none, delete this section.
;
; KEYWORD PARAMETERS:
;   KEY1........... Document keyword parameters like this. Note that the keyword is shown in ALL CAPS!
;
; OUTPUTS:
;   OUTPUT.......... Describe the output of this program or function
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
;   This program was written on April 21, 2023 by Kimberly J. W. Hyde, Northeast Fisheries Science Center | NOAA Fisheries | U.S. Department of Commerce, 28 Tarzwell Dr, Narragansett, RI 02882
;    
; MODIFICATION HISTORY:
;   Apr 21, 2023 - KJWH: Initial code written
;-
; ****************************************************************************************************
  ROUTINE_NAME = 'DWLD_NC_INFO'
  COMPILE_OPT IDL2
  SL = PATH_SEP()
  
  PRODFILE = !S.IDL_MAINFILES + 'SENSOR_PRODS.csv'
  SENSORFILE = !S.IDL_MAINFILES + 'SENSORS_MAIN.csv'
  COMMON _DWLD_FILE_INFO, SENDB, PRODDB, DATETIME
  
  IF ~N_ELEMENTS(DATETIME) THEN DATETIME = SYSTIME(/JULIAN,/UTC)
  IF MAX(GET_MTIME([PRODFILE,SENSORFILE],/JD)) GT DATETIME THEN INIT=1
  IF SENDB EQ [] THEN INIT = 1
  IF PRODDB EQ [] THEN INIT = 1

  ; ===> If any of the files have been updated, then recreate the DB
  IF KEYWORD_SET(INIT) THEN BEGIN
    SENDB = CSV_READ(SENSORFILE)
    PRODDB = CSV_READ(PRODFILE)
    DATETIME = SYSTIME(/JULIAN,/UTC)
  ENDIF
  
  FP = FILE_PARSE(FILES)
  FPDIR = STR_BREAK(FP.DIR,SL)
  PR_DIR = FPDIR[*,-1]
  NC_DIR = FPDIR[*,-2]
  SC_DIR = FPDIR[*,-3] 
  VR_DIR = FPDIR[*,-4]
    
  S = STRUCT_COPY(FP,['NAME','NAME_EXT','EXT'])
  S = STRUCT_MERGE(S,REPLICATE(CREATE_STRUCT('PERIOD_CODE','','PERIOD','','SATNAME','','SATNAME_SUB','','INAME','', 'SENSOR','','SATELLITE','',$
    'METHOD','','MAP','','LEVEL','', 'COVERAGE','','N_BINS',0L,'DELIM','','N_PRODS',0L,'NC_PROD','','PRODS','','PROD_LABEL','','ALG','','FILELABEL','','SOURCE_URL',''),N_ELEMENTS(FILES)))
  S.DELIM = ';'
  S.SENSOR = VALIDS('SENSORS',REPLACE(FP.DIR,SL,'-'))
  
  BSET = WHERE_SETS(S.SENSOR+'-'+VR_DIR+'-'+SC_DIR+'-'+NC_DIR+'-'+PR_DIR)
  FOR B=0, N_ELEMENTS(BSET)-1 DO BEGIN
    SUBS = WHERE_SETS_SUBS(BSET[B])
    ASEN = BSET[B].VALUE
    SPLT = STR_BREAK(ASEN,'-')
    OKSEN = WHERE(SENDB.SENSOR EQ SPLT[0] AND SENDB.SOURCE_DATA_VERSION EQ SPLT[1] AND SENDB.SOURCE_DATA_DIR EQ SPLT[2],COUNTS)
    IF COUNTS GT 1 THEN MESSAGE, 'ERROR: More than one SENSORS_MAIN entry found for ' + ASEN
    IF COUNTS EQ 0 THEN MESSAGE, 'ERROR: No matching entries found in SENSORS_MAIN for ' + ASEN
    SDB = SENDB[OKSEN]
    
    S[SUBS].SATELLITE  = SDB.SATELLITE
    S[SUBS].METHOD     = SDB.SOURCE_DATA_VERSION
    S[SUBS].MAP        = SDB.SOURCE_DATA_MAP
    S[SUBS].LEVEL      = SDB.SOURCE_DATA_LEVEL
    S[SUBS].COVERAGE   = SDB.SOURCE_DATA_LEVEL
    S[SUBS].SOURCE_URL = SDB.SOURCE_DATA_URL
     
    ; ===> Get date and convert to period
    CASE SDB.SOURCE_DATA_SATDATE_FORMAT OF
      'PERIOD': SDATES = ''
      '': MESSAGE, 'ERROR: SATDATE format needs to be added to SENSORS_MAIN.csv'
      ELSE: BEGIN
        SATDATE = REPLACE(SDB.SOURCE_DATA_SATDATE_STRING,['.','_','-'],[' ',' ',' ']) ; ===> LOOK FOR DELIMITERS WITHIN THE NAME AND REPLACE WITH BLANK SPACES
        SATDATE = STR_BREAK(SATDATE,' ')
        OKDATE = WHERE(SATDATE EQ 'SATDATE',COUNT)
        IF COUNT EQ 0 THEN MESSAGE, 'ERROR: "SATDATE" not found in ' + SATDATE + '. Need to update entry in SENSORS_MAIN.csv'  
        
        NAMES = REPLACE(S[SUBS].NAME,['.','_','-'],[' ',' ',' '])
        NAMES = STR_BREAK(NAMES,' ')
        IF N_ELEMENTS(SATDATE) NE N_ELEMENTS(NAMES[0,*]) THEN MESSAGE, 'ERROR: SENSORS_MAIN.csv input information does not align with the file name.  Check the SOURCE_DATA_SATDATE_STRING field.'        
        SDATES = NAMES[*,OKDATE]
      END  
    ENDCASE
    
    PC = SDB.SOURCE_DATA_PERIOD_CODE + '_'
    CASE SDB.SOURCE_DATA_SATDATE_FORMAT OF
      'PERIOD': PERSTR = PERIOD_2STRUCT(NAMES)
      'YYYYMMDD': PERSTR = PERIOD_2STRUCT(PC + SDATES)
      'YYYYDOY': PERSTR = PERIOD_2STRUCT(PC + YDOY_2DATE(YEARDOY=SDATES,/SHORT))
      'TDATE': PERSTR = PERIOD_2STRUCT(PC + SATDATE_2DATE(SDATES)) ; New NASA date with the date and time seaparte by a "T"
      'NASADATE': PERSTR = PERIOD_2STRUCT(PC + SATDATE_2DATE(SDATES)); Old NASA date with the sensor letter followed by the YDOY date (e.g. S1998001174000)
      'NONE': DATES = REPLICATE(PERIOD_2STRUCT(''),N_ELEMENTS(SDATES))
      '': MESSAGE,'ERROR: Add date format information to SENSORS_MAIN.csv' 
      ELSE: MESSAGE,'ERROR: Unrecognized format: ' + SDB.SOURCE_DATA_SATDATE_FORMAT
    ENDCASE
      
    
    stop
    
    
    ; ===> Get product information
    OKPRD = WHERE(PRODDB.SENSOR EQ SPLT[0] AND PRODDB.NCPROD_DIR EQ SPLT[4],COUNTP)
    IF COUNTP EQ 0 THEN MESSAGE, 'ERROR: No matching entries found in SENSOR_PRODS for ' + ASEN
    PRDB = PRODDB[OKPRD]
    NC_PRODS = []
    V_PRODS = []
    ALGS = []
    FOR R=0, COUNTP-1 DO BEGIN
      NPRD = STRUPCASE(PRDB[R].NCPROD)
      VPRD = STRUPCASE(PRDB[R].PROD)
      ALG  = STRUPCASE(PRDB[R].ALG)
      IF STRPOS(NPRD,'XXX') GE 0 THEN BEGIN
        IF PRDB[R].PROD_WAVELENGTHS EQ '' THEN MESSAGE, 'ERROR: ' + NPRD + ' entry is missing the XXX wavelengths'
        WAVES = STR_BREAK(PRDB[R].PROD_WAVELENGTHS,';')
        FOR W=0, N_ELEMENTS(WAVES)-1 DO BEGIN
          NC_PRODS = [NC_PRODS, REPLACE(NPRD,'XXX',WAVES[W])]
          V_PRODS  = [V_PRODS, STRJOIN([REPLACE(VPRD,'XXX',WAVES[W]),ALG],'-')]
          ALGS     = [ALGS, ALG]
        ENDFOR ; Wavelengths
      ENDIF ELSE BEGIN
        NC_PRODS = [NC_PRODS,NPRD]
        V_PRODS  = [V_PRODS, STRJOIN([VPRD,ALG],'-')]
        ALGS     = [ALGS, ALG]
      ENDELSE
    ENDFOR ; Sensor prods
    S[SUBS].NC_PROD = STRJOIN(NC_PRODS,';')
    S[SUBS].PRODS   = STRJOIN(V_PRODS,';')
    S[SUBS].ALG     = STRJOIN(ALGS,';')
    
    
    
 STOP 
  
  ENDFOR

  RETURN, S

END ; ***************** End of DWLD_FILE_INFO *****************
