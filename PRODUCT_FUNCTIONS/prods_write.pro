; $ID:	PRODS_WRITE.PRO,	2022-03-21-16,	USER-KJWH	$
;#############################################################################################################
	PRO PRODS_WRITE,PROD,RANGE,LOG=LOG,UNITS=UNITS,OVERWRITE=OVERWRITE,_EXTRA = _EXTRA
;+
; NAME:
;		PRODS_WRITE
;
; PURPOSE: THIS PROGRAM ADD A PROD TO THE PRODS MAIN CSV DATABASE
;
; CATEGORY: PRODS
;		 
; CALLING SEQUENCE: PRODS_WRITE,PROD,RANGE
;
; INPUTS: PROD: STANDARD PROD NAME
;         RANGE: DATA RANGE TO USE WHEN BYTE-SCALING THE PROD E.G. [0,70] FOR PAR		
;	
; KEYWORD PARAMETERS:
;         LOG:  APPLY ALOG10 WHEN SCALING GEOPHYSICAL DATA TO BYTES
;         UNITS: SCIENTIFIC UNITS FOR THE PROD [SEE UNITS.PRO]
;         OVERWRITE: OVERWRITES THE PROD IN THE MAIN IF IT IS ALREADY PRESENT
;         
; OUTPUTS: APPENDS PROD TO MAIN CSV DATABASE : !S.MAIN + 'PRODS_MAIN.csv'

;		
;; EXAMPLES:
;===> PROD ALREADY IN MAIN:
;         PRODS_WRITE,'CHLOR_A',[0.01,64],/LOG,UNITS = UNITS('CHLOR_A',/NO_NAME)

;===> ADD NEW PROD:
;         PRODS_WRITE,'CHL_GLOBAL',[0.01,100.00],/LOG,UNITS=UNITS('CHLOR_A',/NO_NAME),LONG_NAME = 'CHLOROPHYLL GLOBAL'
;         PRODS_WRITE,'KM2',[1,1000],UNITS=UNITS('KM2',/NO_NAME),LOG = 1,LONG_NAME = 'AREA IN KM2',/OVERWRITE
;         PRODS_WRITE,'PIXEL_AREAS',[0,100],UNITS=UNITS('KM2',/NO_NAME),LOG = 0,LONG_NAME = 'PIXEL AREA IN KM2',/OVERWRITE
;         PRODS_WRITE,'PIXEL_AREA',[1.55,1.57],UNITS=UNITS('KM2',/NO_NAME),LOG = 1,LONG_NAME = 'AREA IN KM2',/OVERWRITE
;         PRODS_WRITE,'ADG_443',[0.01,1.00],/LOG,UNITS=UNITS('ABS',/NO_NAME),LONG_NAME = 'ADG_443'
;===> ADD SAME NEW PROD BUT CHANGE RANGE [USING OVERWRITE]:         
;         PRODS_WRITE,'CHL_GLOBAL',[0.001,200.00],/LOG,UNITS=UNITS('CHLOR_A',/NO_NAME),LONG_NAME = 'CHLOROPHYLL GLOBAL',/OVERWRITE
;         PRODS_WRITE,'ADG_443',[0.001,1.00],/LOG,UNITS=UNITS('ABS',/NO_NAME),LONG_NAME = 'ADG_443'
;         PRODS_WRITE,'SST',UNITS=UNITS('SST',/NO_NAME),/OVERWRITE
;         PRODS_WRITE,'DEPTH_SHELF',[1,1000],UNITS=UNITS('DEPTH',/NO_NAME),LONG_NAME = 'DEPTH SHELF',/OVERWRITE
;         PRODS_WRITE,'PIXEL_AREA',[6,6.4],UNITS=UNITS('KM2',/NO_NAME),LOG = 1,LONG_NAME = 'AREA IN KM2',/OVERWRITE
;         PRODS_WRITE,'PPD_.2_2',[0.2,2],UNITS=UNITS('PPD',/NO_NAME),LOG = 0,LONG_NAME = 'PPD_.2_2',/OVERWRITE
;         PRODS_WRITE,'NUM_1_30',[1,30],UNITS='DAYS',LOG = 1,LONG_NAME = 'NUM_0_300',/OVERWRITE;
;         PRODS_WRITE,'CBAR',[0,255],UNITS='NUM',LOG = 0,LONG_NAME = 'COLORBAR',/OVERWRITE;
;         PRODS_WRITE,'PPD_.2_2.1',[0.2,2.1],UNITS=UNITS('PPD',/NO_NAME),LOG = 0,LONG_NAME = 'PPD_.2_2',/OVERWRITE
;         PRODS_WRITE,'PPY_3_3000',[3,3000],UNITS=UNITS('PPY',/NO_NAME),LOG = 1,LONG_NAME = 'PPY_3_3000',/OVERWRITE
;         PRODS_WRITE,'PPY_3_1000',[3,1000],UNITS=UNITS('PPY',/NO_NAME),LOG = 1,LONG_NAME = 'PPY_3_3000',/OVERWRITE
;         PRODS_WRITE,'NUM_1_250',[1,250],UNITS=UNITS('NUM',/NO_NAME),LOG = 1,LONG_NAME = 'NUM_1_250',/OVERWRITE
;   NOTES:
;   
;   WE NO LONGER NEED TO SPECIFY 'SPECIAL_SCALES' 
;   AS WAS DONE WITH SD_SCALES TO SCALE GEOPHYSICAL DATA INTO BYTES 
;   FOR MAKING PNGS
;   
;   INSTEAD, WE MAKE A UNIQUE NEW PROD IN THE MAIN BY USING PRODS_WRITE 
;   USING A NAME FOR THE PROD THAT HAS MEANING LIKE 'CHL_GLOBAL' 
;   WHEN WE ARE DEALING WITH THE FULL 4 ORDERS-OF-MAGNITUDE RANGE IN CHLOR_A
;   
;   OR CHL_NAFO,OR CHL_LMES,ETC. FOR A PARTICULAR PROJECT, OR REGION OF INTEREST
;   
;   PRODS_WRITE REQUIRES ONLY:
;   THE PROD NAME;
;   THE RANGE OF THE GEOPHYSICAL DATA TO ENCOMPASS;
;   AND '/LOG' IF YOU WANT ALOG10 BYTE-SCALING OF THE DATA 
;   WHEN SCALING TO MAKE A COLORBAR OR BYTE DATA IMAGES FOR PNGS
;   
;   WITH JUST THE NEW PROD NAME AND RANGE 
;   PRODS_WRITE AUTOMATICALLY DETERMINES THE SLOPE AND INTERCEPT 
;   [USING SCALE.PRO]
;   AND CREATES A NEW STRUCTURE RECORD IN THE MAIN
;   THAT MAY BE USED FOR BOTH COLORBAR AND BYTE-SCALING OF DATA TO IMAGES    
;    
;   THERE IS NO LIMIT TO THE NUMBER OF PRODS!
;   AND ONCE THE NEW PROD IS IN THE DATABASE 
;   IT WILL ALSO BE A VALID PROD USING VALID_PRODS.PRO
;   
;   
; MODIFICATION HISTORY:
;			WRITTEN DEC 23,2013 J.O'REILLY
;			DEC 27,2013,JOR REFINEMENTS
;			DEC 30,2013,JOR MORE REFINEMENTS
;			JAN 3,2014, JOR,ADDED KEYWORD OVERWRITE	
;			JAN 8,2014, JOR,REVISED FOR THE CSV MAIN DATABASE	
;			JAN 10,2013,JOR ADDED COMMON AND DONE_BACKUP
;			JAN 15,2014,JOR ADDED EXAMPLES AND MORE TESTING
;			JAN 16,2014,JOR ADDED IDL_VALIDNAME
;			                FIXED PROB WITH SCALING:
;			                LOG EQ 1 AND MIN(_RANGE) NE 0.0
;			JAN 23,2014,JOR: PROD =STRUPCASE(IDL_VALIDNAME(PROD , /CONVERT_ALL)); ENSURE PROD NAME IS VALID
;                      ;===> ENSURE PROD IS IN MAIN AND INITIALIZE MAIN
;                       NAMES = PRODS_READ(/NAMES,/INIT)
;     FEB 10,2014,JOR  CHANGE DATE STAMP TO STANDARD DATE FORMAT:
;     FEB 10,2014,JOR  DATE = STRTRIM(DATE_NOW(),2)
;     APR 13,2014,JOR: MAIN = !S.MAIN + 'PRODS_MAIN.csv'


;			
;#################################################################################
;-
;***************************
ROUTINE_NAME  = 'PRODS_WRITE'
;***************************
; IDL_VALIDNAME
COMMON  _PRODS_WRITE,DONE_BACKUP
IF NONE(DONE_BACKUP) THEN DONE_BACKUP = 0

;###################  CONSTANTS  #############################
CB_RANGE = [1,250] ; COLORBAR RANGE -ALSO USED FOR BYTE-SCALING]

RANGE_DEFAULT = [0.01,100] ; USED IF RANGE NOT PROVIDED
LOG_DEFAULT = 0; = LINEAR SCALING
;===> PRODS MAIN DATABASE
PMAIN = !S.MAINFILES + 'PRODS_MAIN.csv'
;===> PERIOD TO ADD TO THE NEW PROD RECORD
PERIOD = 'S_'+STRTRIM(DATE_NOW(),2)
;||||||||||||||||||||||||||||||||||||||||||||||||||||

;#####################    CHECK INPUTS  ################################
IF N_ELEMENTS(PROD) EQ 0 THEN MESSAGE,'ERROR: MUST PROVIDE PRODS'
PROD =STRUPCASE(IDL_VALIDNAME(PROD , /CONVERT_ALL)); ENSURE PROD NAME IS VALID
IF KEYWORD_SET(LOG) THEN _LOG = LOG ELSE _LOG = LOG_DEFAULT
IF N_ELEMENTS(RANGE) EQ 2 THEN _RANGE = RANGE ELSE _RANGE = RANGE_DEFAULT
IF KEYWORD_SET(OVERWRITE) THEN _OVERWRITE = 1 ELSE _OVERWRITE = 0
IF N_ELEMENTS(UNITS) EQ 1 THEN _UNITS = UNITS ELSE _UNITS = ''
;|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||

;

;################################################################
;#########  ALLOW FILE COPY TO BACKUP MAIN   ##################
;#########  ONLY ONCE DURING AN IDL SESSION    ##################
;################################################################
IF _OVERWRITE EQ 1 AND DONE_BACKUP EQ 0 THEN BEGIN
  COPY = REPLACE(PMAIN,'_MAIN','_MAIN'+'-' + DATE_NOW())
  IF FILE_TEST(PMAIN) EQ 1 THEN  FILE_COPY,PMAIN,COPY,/VERBOSE,/OVERWRITE
  DONE_BACKUP=1
ENDIF;IF _OVERWRITE EQ 1 AND DONE_BACKUP EQ 0 THEN BEGIN
;||||||||||||||||||||||||||||||||||||||||||||||||||||||||
  
DB = PRODS_READ(/INIT)

OK_PROD= WHERE(DB.PROD EQ PROD,COUNT_PROD)
;####################### REMOVE PROD AND REWRITE MAIN  ?   ###############
IF COUNT_PROD GE 1 AND _OVERWRITE EQ 1 THEN BEGIN     
  ;===> REMOVE PROD,  RESORT,  AND REWRITE MAIN
  DB = REMOVE(DB,OK_PROD)
  DB = STRUCT_SORT(DB, TAGNAMES='PROD')
  STRUCT_2CSV,PMAIN,DB & PFILE,PMAIN,/W 
  ;===> REFRESH COUNT_PROD
  OK_PROD= WHERE(DB.PROD EQ PROD,COUNT_PROD)
ENDIF;IF COUNT_PROD GE 1 AND _OVERWRITE EQ 1 THEN BEGIN
;||||||||||||||||||||||||||||||||||||||||||||||||||||||


;#######################  PROD IS ALREADY IN MAIN ?  ###############
IF COUNT_PROD EQ 1 AND _OVERWRITE EQ 0 THEN BEGIN
  TXT = PROD + '  IS ALREADY IN MAIN ... USE KEYWORD OVERWRITE TO REPLACE IT'  
  FOREACH ELEMENT, INDGEN(3), KEY DO BEGIN PRINT, TXT & PRINT & WAIT,1 & END
ENDIF;IF COUNT_PROD EQ 1 AND _OVERWRITE EQ 0 THEN BEGIN
;||||||||||||||||||||||||||||||||||||||||||||||||||||||

;############################################################################
;#########################   ADD NEW PROD TO MAIN  ########################
;############################################################################
IF COUNT_PROD EQ 0 THEN BEGIN  
  PFILE,PROD,/M
  IF NONE(LOG) THEN LOG = 0 
  S = PRODS_STRUCT()  
  ;;NAMES = PRODS_READ(/NAMES,/INIT)
  T = PRODS_TICKS(PROD, _RANGE,LOG=LOG)
  
  ;@@@@@@@@@@@@  COMPUTE SLOPE AND INTERCEPT USING SCALE  @@@@@@@@@@@@@@@@@@@  
  IF LOG EQ 1 AND MIN(_RANGE) NE 0.0 THEN BEGIN
    SCALED = SCALE(CB_RANGE, ALOG10(_RANGE),INTERCEPT=INTERCEPT,SLOPE=SLOPE)
  ENDIF ELSE BEGIN
    SCALED = SCALE(CB_RANGE, _RANGE,INTERCEPT=INTERCEPT,SLOPE=SLOPE)
    SCALED = ROUNDS(SCALED,3)
  ENDELSE;IF LOG EQ 1 AND MIN(_RANGE) NE 0.0 THEN BEGIN
  ;||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||

  ;######################################################################
  ;######################    FILL THE STRUCTURE S   #####################
  ;######################################################################
  STRUCT_ASSIGN,T,S
  ;;STRUCT_ASSIGN,STRUCT_IT(T.TICKS,NAME ='TICKS'),S,/NOZERO
  STRUCT_ASSIGN,STRUCT_IT(_UNITS,'UNITS'),S,/NOZERO
  STRUCT_ASSIGN,STRUCT_IT(INTERCEPT,'INTERCEPT'),S,/NOZERO
  STRUCT_ASSIGN,STRUCT_IT(SLOPE,'SLOPE'),S,/NOZERO
  STRUCT_ASSIGN,STRUCT_IT(_RANGE[0],'LOWER'),S,/NOZERO
  STRUCT_ASSIGN,STRUCT_IT(_RANGE[1],'UPPER'),S,/NOZERO
  STRUCT_ASSIGN,STRUCT_IT(CB_RANGE[0],'C_LOW'),S,/NOZERO
  STRUCT_ASSIGN,STRUCT_IT(CB_RANGE[1],'C_HI'),S,/NOZERO  
  STRUCT_ASSIGN,STRUCT_IT(PERIOD,'PERIOD'),S,/NOZERO                
  
  ;************************************
  IF N_ELEMENTS(_EXTRA) GE 1 THEN BEGIN
  ;************************************  
    TAGNAMES = TAG_NAMES(_EXTRA)
    ;FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
    FOR NTH = 0,N_ELEMENTS(TAGNAMES) -1 DO BEGIN
      NAME = TAGNAMES[NTH]
      POS = WHERE(TAGNAMES EQ NAME)
      VAL = _EXTRA.(POS)
      STRUCT_ASSIGN,STRUCT_IT(VAL,NAME),S,/NOZERO
    ENDFOR;FOR NTH = 0,N_ELEMENTS(TAGNAMES) -1 DO BEGIN
    ;FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF   
  ENDIF;IF N_ELEMENTS(_EXTRA) GE 1 THEN BEGIN
  ;||||||||||||||||||||||||||||||||||||||||||
 
  ;########################################################
  ;############> APPEND THE RECORD TO THE MAIN ##########
  ;########################################################
  STRUCT_2CSV, PMAIN,S,/APPEND & PF,PROD & PFILE,PMAIN,/A
  ;===> ENSURE PROD IS IN MAIN
   NAMES = PRODS_READ(/NAMES,/INIT) & 
   OK= WHERE(NAMES EQ PROD,COUNT_PROD)
   
   IF COUNT_PROD EQ 0 THEN MESSAGE,'ERROR: ' + PROD + ' IS NOT IN MAIN'
ENDIF;IF COUNT_PROD EQ 0 THEN BEGIN 
;||||||||||||||||||||||||||||||||||

END; #####################  END OF ROUTINE ################################
