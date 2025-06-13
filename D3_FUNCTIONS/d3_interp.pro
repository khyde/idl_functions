; $ID:	D3_INTERP.PRO,	2020-07-08-15,	USER-KJWH	$
;+
;;#############################################################################################################
	PRO D3_INTERP, D3_FILE, D3_INTERP_FILE=D3_INTERP_FILE, SPAN=SPAN, N_GOOD=N_GOOD, SMO_WIDTH=SMO_WIDTH, STAT_TRANSFORM=STAT_TRANSFORM, $
	               DAYS_BEFORE=DAYS_BEFORE,DAYS_KEEP=DAYS_KEEP,VERBOSE=VERBOSE, OVERWRITE=OVERWRITE, LOGLUN=LOGLUN
;
; PURPOSE: INTERPOLATE & SMOOTH DATA IN A D3 FILE 
; 
; CATEGORY:	D3 FAMILY		 
;
; CALLING SEQUENCE: D3_INTERP,D3_FILE
;
; INPUTS: D3_FILE  [FROM D3_MAKE]

; OPTIONAL INPUTS:
;		NONE:	
;		
; KEYWORD PARAMETERS:
;     D3_INTERP_FILE.......... OUTPUT NAME OD THE D3_INTERP FILE
;     N_GOOD.................. MINIMUM NUMBER IN THE PSERIES TO INTERPOLATE [DEFAULT = 11] 
;     STAT_TRANSFORM.......... ALOG [OR NOT]
;     DAYS_BEFORE..............NUMBER OF PREVIOUS DAYS TO INCLUDE IN THE INTERPOLATION
;     DAYS_KEEP................NUMBER OF DAYS TO KEEP UNCHANGED AFTER DAYS_BEFORE 
;     VERBOSE................. PRINT PROGRAM PROGRESS
;     OVERWRITE............... OVERWRITE OUTPUT D3_INTERP_FILE
;     SPAN.................... THE SAMPLING GAP IN THE PSERIES (NUMBER OF DAYS) TO BLANK (MAKE MISSING) [DEFAULT = 7]
;     SMO_WIDTH............... WIDTH TO USE WITH THE TRICUBE SMOOTH FILTERING STEP
;     LOGLUN.................. If provided, the LUN for the log file
;    
; OUTPUTS: UPDATES THE D3 DATA ARRAYS IN COMMON MEMORY & REWRITES THE D3_FILE
;		
; EXAMPLES:
;           D3_INTERP,D3_FILE,SPAN=15
;          
;	NOTES:
;
;
; COPYRIGHT:
; Copyright (C) 2018, Department of Commerce, National Oceanic and Atmospheric Administration, National Marine Fisheries Service,
;   Northeast Fisheries Science Center, Narragansett Laboratory.
;   This software may be used, copied, or redistributed as long as it is not sold and this copyright notice is reproduced on each copy made.
;   This routine is provided AS IS without any express or implied warranties whatsoever.
;
;   This program was written by John E. O'Reilly, DOC/NOAA/NMFS/NEFSC Narragansett, RI
;          with assistance from Kimberly Hyde, DOC/NOAA/NMFS/NEFSC Narragansett, RI, kimberly.hyde@noaa.gov.  Inquiries should be directed to kimberly.hyde@noaa.gov
;          
; MODIFICATION HISTORY:
;       Written:  March 29, 2015 by John E. O'Reilly, NOAA/NEFSC/Narragansett Laboratory, 28 Tarzwell Drive, 02882
;       Modified:
;       APR 01, 2015 - JEOR: NO LONGER USING TS_SMOOTH (REDUNDANT WITH SMOOTHING FROM TRICUBE FILTER)
;       JAN 20, 2017 - KJWH: Added OVERWRITE and VERBOSE keywords
;                            Updated formatting
;                            Added FILE_UPDATE to determine if the D3_INTERP_FILE needs to be recreated
;       JAN 27, 2017 - KJWH: Added D3_INTERP_FILE to return the output file name    
;                            Updated how file names are replaced depending on whether the input is the original D3_FILE for the MED_FILL file  
;       FEB 02, 2017 - KJWH: Added keyword STATS_TRANSFORM and steps to TRANSFORM the PSERIES prior to interpolate and untransform prior to writing out the data     
;                            Changed FILE_ALL to PARSE_IT( ,/ALL)     
;                            Changed -DATA.FLT to -DAT.FLT to avoid errors when looking for VALID products (DATA is considered a valid product and -DATA.FLT interferes with finding the actual product)                           
;       APR 18, 2017 - KJWH: Changed KEY(PROD_INFO.LOG) to KEY(FIX(PROD_INFO.LOG)) - the former was always TRUE because PROD_INFO.LOG was a string and not a number
;       APR 25, 2017 - JEOR: OK = WHERE(FINITE(PSERIES) AND PSERIES NE LAND_CODE,COUNT)
;                            THIS WAS NEEDED TO CATCH THE NANS AND INFS
;       MAY 02, 2017 - JEOR: REMOVED LAND_CODE [NO LONGER NEEDED]
;                            INTERP_DB = STRUCT_COPY(DB,TAGNAMES = ['SEQ','PERIOD','NAME','JD','MTIME'])
;       MAY 03, 2017 - JEOR: DAYS_BEFORE = 60 ; INCLUDE THE PREVIOUS 60 DAYS IN THE INTERPOLATION WHEN UPDATING THE D3_INTERP_FILE
;       MAY 06, 2017 - JEOR: ADDED KEYS DAYS_BEFORE [DEFAULT = 60] AND DAYS_KEEP [DEFAULT = 30] 
;                            KIM : IF ANY(PKEEP) THEN  D3(XP,YP,KBEG:KEND) = PKEEP ;KIM THIS NEEDS TESTING
;       AUG 02, 2017 - KJWH: Updated formatting and some documentation
;                            Fixed BUG when interpolated a subset of days
;                              Changed: DAYS = I_JDS-FIRST(I_JDS) to DAYS = I_JDS(PBEG:PEND)-FIRST(I_JDS) - so that DAYS now represents the correct subset date range
;                              Removed: DAYS(PBEG:PEND) from INTP = INTERPX(_DAYS, PSERIES, DAYS, HELP=HLP, BAD=BAD, GAP=GAP, FIXBAD=XBAD) - because the days are subset above
;                            Fixed BUG when writing out the subsetted interpolated PSERIES to the D3
;                              Added:   PKEEP = 0L for when creating a completely new interpolated file
;                              Added:   IF PKEEP NE 0 THEN BLANKED = BLANKED(DAYS_KEEP:*) to remove the first 30 days from blanked so that they are not overwritten in the D3 (the first 30 days are used to spin-up the interpolation and should not be replaced)
;                              Changed: D3(XP,YP,PBEG:PEND) = BLANKED to D3(XP,YP,PKEEP:PEND) = BLANKED so that now we are not overwriting the first 30 days (or DAYS_KEEP) in the D3   
;                              Removed: IF PBEG NE 0 AND (PBEG + DAYS_KEEP) LT NOF(PSERIES) THEN BEGIN
;                                         KBEG = PBEG
;                                         KEND = (NOF(PSERIES)-1) <(KBEG + DAYS_KEEP)
;                                         PKEEP = PSERIES(KBEG:KEND)
;                                       ENDIF;IF PBEG NE 0 AND (PBEG + DAYS_KEEP) LT NOF(PSERIES) THEN BEGIN 
;       DEC 12, 2017 - KJWH: Updated the VERBOSE print out  
;       JAN 26, 2017 - KJWH: Added SMO_WIDTH keyword to set the WIDTH in the FILTER step
;                              IF NONE(SMO_WIDTH)   THEN WIDTH = 7             ; USE THE DEFAULT OF 7 FOR THE SMOOTH WIDTH
;                              IF FIX(PROD_INFO.D3_SMOOTH)GE 0 AND ~KEY(SMO_WIDTH) THEN WIDTH = FIX(PROD_INFO.D3_SMOOTH) ; IF NOT GIVEN AS A KEYWORD INPUT, THEN USE THE D3_SMOOTH INFO FROM PRODS MASTER
;                              IF WIDTH GT 0 THEN SMO = FILTER(INTP, FILT='TRICUBE', WIDTH=WIDTH) $                        ; SMOOTH INTP USING TRICUBE
;                                            ELSE SMO = INTP                                                               ; DON'T SMOOTH IF WIDTH IS 0
;                            Now untransforming the data before blanking the data gaps
;                              
;       NOV 15, 2018 - KJWH: Changed the PRINT commands to PLUN so that they can be captured in a log file if provided
;                            Added LOGFILE keyword    
;       FEB 22, 2019 - KJWH: Added Copyright info    
;       FEB 25, 2019 - KJWH: Changed REPORT, 'D3 IS DONE' to PLUN, LOG_LUN,'D3 IS DONE'       
;       SEP 09, 2019 - KJWH: Removed LOGFILE and now using an input LOGLUN to record the log information
                                              
;
;#################################################################################
;-
;*****************************
  ROUTINE_NAME  = 'D3_INTERP'
;*****************************
 
  SL = PATH_SEP()

;===> DEFAULTS
  IF NONE(SPAN)        THEN SPAN = 7  
  IF NONE(N_GOOD)      THEN N_GOOD = 11           ; MINIMUM NUMBER IN THE PSERIES TO INTERPOLATE
  IF NONE(DAYS_BEFORE) THEN DAYS_BEFORE = 60      ; INCLUDE THE PREVIOUS 60 DAYS IN THE INTERPOLATION WHEN UPDATING THE D3_INTERP_FILE
  IF NONE(DAYS_KEEP)   THEN DAYS_KEEP = 30        ; KEEP THE 30 DAYS AFTER DAYS_BEFORE 
  IF NONE(SMO_WIDTH)   THEN WIDTH = 7             ; USE THE DEFAULT OF 7 FOR THE SMOOTH WIDTH

  IF NONE(LOGLUN)    THEN LOG_LUN = [] ELSE LOG_LUN = LOGLUN
  PLUN, LUN, 'Starting ' + ROUTINE_NAME
  
  IF NONE(D3_FILE) THEN MESSAGE,'ERROR: D3_FILE IS REQUIRED'
  
  D3_DB_FILE        = REPLACE(D3_FILE,'-D3_DAT.FLT','-D3_DB.SAV')
  D3_INTERP_FILE    = REPLACE(D3_FILE,'-D3_DAT.FLT','-D3_INTERP.FLT')
  D3_INTERP_DB_FILE = REPLACE(D3_FILE,'-D3_DAT.FLT','-D3_INTERP_DB.SAV')
  TEMP_FILE         = REPLACE(D3_INTERP_FILE,'-D3_INTERP.FLT','-D3_INTERP-TEMP.FLT') 
  IF FILE_MAKE(D3_FILE,D3_INTERP_FILE,OVERWRITE=OVERWRITE) EQ 0 THEN GOTO, DONE
  
  IF EXISTS(D3_INTERP_FILE) THEN BEGIN
    FILE_COPY, D3_INTERP_FILE, TEMP_FILE, /OVERWRITE,VERBOSE=VERBOSE  ; 1) MAKE A TEMP COPY OF THE D3_INTERP_FILE
    FILE_COPY, D3_FILE, D3_INTERP_FILE, /OVERWRITE,VERBOSE=VERBOSE    ; 2) COPY THE UPDATED [LARGER] D3_FILE TO THE D3_INTERP_FILE
    OPENR,1,TEMP_FILE                                                 ; 3) OPEN THE TEMP FILE
    SZ_TEMP = (FSTAT[1]).SIZE                                         ; 4) GET THE SIZE OF THE TEMP_FILE
    OPENU,2,D3_INTERP_FILE                                            ; 5) USE OPENU TO UPDATE
    COPY_LUN, 1, 2, SZ_TEMP, TRANSFER_COUNT=TRANSFER_COUNT            ; 6) USE COPY_LUN TO TRANSFER ALL THE PREVIOUSLY INTERPOLATED DATA FROM THE TEMP_FILE TO THE D3_INTERP_FILE
    
    IF TRANSFER_COUNT EQ SZ_TEMP THEN BEGIN                           ; 7) ENSURE THE BYTES TRANSFERRED EQUALS THE SIZE IN BYTES OF THE ORIGINAL D3_INTERP_FILE
      CLOSE,1
      CLOSE,2
      FILE_DELETE,TEMP_FILE,/VERBOSE                                  ; 8) DELETE THE TEMP_FILE      
    ENDIF ELSE BEGIN
      MESSAGE,'ERROR: INCORRECT NUMBER OF BYTES TRANSFERRED'
    ENDELSE ; IF TRANSFER_COUNT EQ SZ_TEMP THEN BEGIN
  ENDIF ELSE BEGIN 
    FILE_COPY, D3_FILE, D3_INTERP_FILE, /OVERWRITE,VERBOSE=VERBOSE    ; THE D3_INTERP_FILE IS COPIED FROM THE D3_FILE [SO THE D3_FILE IS UNCHANGED]
  ENDELSE ; IF EXISTS(D3_INTERP_FILE) THEN BEGIN

; ===> UNMAP IF MEMORY-MAPPED
  IF IS_SHM(D3_FILE) THEN SHMUNMAP,'D3'
  IF IS_SHM(D3_INTERP_FILE) THEN SHMUNMAP,'D3'

; ===> GET DIMENSIONS, MAP AND PROD FROM THE D3_FILE
  FA=PARSE_IT(D3_FILE,/ALL) & PX=LONG(FA.PX) & PY=LONG(FA.PY) & PZ=LONG(FA.PZ) & MAPP=FA.MAP & PROD=FA.PROD

; ===> GET N_FILES FROM THE DB
  DB=STRUCT_READ(D3_DB_FILE) & N_FILES=NOF(DB) & IF KEY(VERBOSE) THEN PLUN, LOG_LUN,'N_FILES:  ' ,N_FILES

; ===> MAKE THE INTERP_DB FROM THE DB IF IT DOES NOT EXIST
  IF EXISTS(D3_INTERP_DB_FILE) THEN BEGIN
    INTERP_DB = IDL_RESTORE(D3_INTERP_DB_FILE) 
    PBEG      = LAST(INTERP_DB.SEQ)-DAYS_BEFORE                               ; BEGINNING OF THE PSERIES RANGE TO INTERPOLATE   
    PEND      = LAST(DB.SEQ)                                                  ; END OF THE PSERIES RANGE TO INTERPOLATE
    PKEEP     = PBEG + DAYS_KEEP                                              ; BEGINNING OF THE INTERPOLATED PSERIES TO KEEP IN THE NEW D3
    INTERP_DB = DB                                                            ; UPDATE THE INTERP_DB
    INTERP_DB = STRUCT_RENAME(INTERP_DB,'DATE_RANGE','DONE')
    INTERP_DB.DONE = 1
    SAVE,FILENAME = D3_INTERP_DB_FILE,INTERP_DB,/VERBOSE                      ; WRITE THE INTERP_DB TO THE D3_INTERP_DB_FILE   
  ENDIF ELSE BEGIN
    PBEG = 0L & PEND = N_FILES-1L & PKEEP = 0L                                ; DEFINE THE PSERIES RANGE
    INTERP_DB = DB                                                            ; UPDATE THE INTERP_DB
    INTERP_DB =STRUCT_RENAME(INTERP_DB,'DATE_RANGE','DONE')
    INTERP_DB.DONE = 1 
    SAVE,FILENAME = D3_INTERP_DB_FILE,INTERP_DB,/VERBOSE                      ; WRITE THE INTERP_DB TO THE D3_INTERP_DB_FILE
  ENDELSE ; IF EXISTS(D3_INTERP_DB_FILE) THEN BEGIN
  IF KEY(VERBOSE) THEN PLUN, LOG_LUN,'INTERPOLATION WILL BE FROM  '+ STRMID(PERIOD_2DATE(DB(PBEG).PERIOD),0,8) + '  TO  '+ STRMID(PERIOD_2DATE(DB(PEND).PERIOD),0,8)

  JDS = PERIOD_2JD(DB.PERIOD)
  I_JDS = ULONG(INTERVAL([ULONG(MIN(JDS)),ULONG(MAX(JDS))],1)) 

  OPENU, D3_LUN, D3_INTERP_FILE, /GET_LUN                                     ; OPEN THE D3_INTERP_FILE FOR READING AND WRITING
  SHMMAP ,'D3',/FLOAT,DIMENSION= [PX,PY,N_FILES] , FILENAME=D3_INTERP_FILE    ; MAP THE D3 ARRAY TO THE D3_FILE
  D3 = SHMVAR('D3')                                                           ; GET THE D3 ARR

 ; IF KEY(VERBOSE) THEN PRINT, 'INITIAL # MISSING DATA IN D3 =  '+ STR_COMMA(N_ELEMENTS(WHERE(D3 EQ MISSINGS(D3))))  ; REPORT THE NUMBER OF MISSING VALUES IN THE D3 DATA ARRAY

; ===> GET PRODUCT INFO
  PROD_INFO = PRODS_READ(PROD)                                                ; GET THE PRODUCT INFO
  IF KEY(FIX(PROD_INFO.LOG)) THEN _STAT_TRANSFORM = 'ALOG'                    ; READ THE LOG INFO FROM THE PRODUCT STRUCTURE
  IF KEY(STAT_TRANSFORM)     THEN _STAT_TRANSFORM = STAT_TRANSFORM            ; IF NOT PREDETERMINED, USE THE LOG INFO TO DETERMINE THE TRANSFORMATION STATUS
  IF FIX(PROD_INFO.D3_SMOOTH)GE 0 AND ~KEY(SMO_WIDTH) THEN WIDTH = FIX(PROD_INFO.D3_SMOOTH) ; IF NOT GIVEN AS A KEYWORD INPUT, THEN USE THE D3_SMOOTH INFO FROM PRODS MASTER
  
;===> LOOP OVER ALL PIXELS ,XP,YP, TO GET EACH PSERIES
  FOR YP = 0L,PY-1 DO BEGIN
    FOR XP = 0L,PX-1 DO BEGIN
      PSERIES = REFORM(D3(XP,YP,PBEG:PEND))
      OK = WHERE(FINITE(PSERIES),COUNT)
      IF COUNT EQ 0 THEN CONTINUE ; >>> ALL PIXELS ARE MISSINGS [USUALLY LAND]
      POF,YP,PY,OUTTXT=POFTXT,/QUIET, /NOPRO
      PLUN, LOG_LUN, 'Found ' + NUM2STR(COUNT) + ' valid pixels out of ' + NUM2STR(N_ELEMENTS(PSERIES)) + ' in array ' + POFTXT, 0
      PSERIES = PSERIES[OK]
      DAYS    = I_JDS(PBEG:PEND)-FIRST(I_JDS)
      _DAYS   = DAYS[OK]
      _JDS    = JDS[OK]
      
      IF N_ELEMENTS(PSERIES) LT N_GOOD THEN BEGIN                                             ; MUST HAVE AT LEAST N_GOOD POINTS IF NOT THEN MAKE MISSINGS
        D3(XP,YP,PBEG:PEND) = MISSINGS(D3)
        CONTINUE  ; >>> NOT ENOUGH VALID PIXELS TO RUN THE INTERPOLATION STEP
      ENDIF;IF N_ELEMENTS(_PSERIES) LT 11 THEN BEGIN  
      
      IF KEY(_STAT_TRANSFORM) THEN PSERIES = ALOG(PSERIES) ; TRANSFORM THE PSERIES 
      
      INTP = INTERPX(_DAYS, PSERIES, DAYS, HELP=HLP, BAD=BAD, GAP=GAP, FIXBAD=FIXBAD)             ; LINEARLY INTERPOLATE _PSERIES TO ALL THE DAYS IN THIS PSERIES      
      IF WIDTH GT 0 THEN SMO = FILTER(INTP, FILT='TRICUBE', WIDTH=WIDTH) $                        ; SMOOTH INTP USING TRICUBE  
                    ELSE SMO = INTP                                                               ; DON'T SMOOTH IF WIDTH IS 0            
      IF KEY(_STAT_TRANSFORM) THEN SMO = EXP(SMO)                                                 ; UNTRANSFORM THE INTERPOLATED PSERIES
      BLANKED = D3_INTERP_BLANK(JD=_JDS, INTERP_DATA=SMO, INTERP_JD=I_JDS(PBEG:PEND), SPAN=SPAN)  ; BLANK OUT GAPS > BLANK DAYS     
      IF PKEEP NE 0 THEN BLANKED = BLANKED(DAYS_KEEP:*)                                           ; REMOVE THE FIRST 30 DAYS FROM BLANKED SO THAT THEY ARE NOT OVERWRITTEN IN THE D3 (THE FIRST 30 DAYS ARE USED TO SPIN-UP THE INTERPOLATION AND SHOULD NOT BE REPLACED)
      D3(XP,YP,PKEEP:PEND) = BLANKED                                                              ; REPLACE D3 WITH THE INTERPOLATED-SMOOTHED-BLANKED (SUBSETTED) PSERIES 
    ENDFOR;FOR XP = 0L,PX-1 DO BEGIN
  ENDFOR;FOR YP = 0L,PY-1 DO BEGIN
  
;===>REPORT THE NUMBER OF MISSING VALUES IN THE D3 DATA ARRAY AFTER INTERP AND SMOOTHING
  IF KEY(VERBOSE) THEN BEGIN
  ;  PRINT, 'FINAL # MISSING DATA IN D3.DATA =  '+ STR_COMMA(N_ELEMENTS(WHERE(D3 EQ MISSINGS(D3))))
    PFILE,D3_INTERP_FILE, LOGLUN=LOG_LUN
  ENDIF

; ===> CLEAN UP
  IF IS_SHM(D3_INTERP_FILE) THEN SHMUNMAP,'D3'
  GONE,D3
  PLUN, LOG_LUN,'D3 IS DONE'
  
  
  DONE:          
END; #####################  END OF ROUTINE ################################
