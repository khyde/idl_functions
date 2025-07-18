; $ID:	PSERIES_LNP.PRO,	2020-07-08-15,	USER-KJWH	$

;###########################################################################################
PRO PSERIES_LNP,PSERIES_FILE,CSV_FILE=CSV_FILE,TEMPLATE_FILE=TEMPLATE_FILE,$
                DIR_OUT=DIR_OUT,OVERWRITE=OVERWRITE,FILE_LABEL=FILE_LABEL,$
                LOGIT = LOGIT
;+
; THIS PROGRAM CALCULATES THE LOMB PERIODOGRAM [LNP_TEST]TO DETERMINE DOMINANT TEMPORAL FREQUENCIES IN A PIXEL TIME SERIES [PSERIES] FILE
; SYNTAX:
;  PSERIES_LNP,PSERIES_FILE,CSV_FILE=CSV_FILE,TEMPLATE_FILE=TEMPLATE_FILE,DIR_OUT=DIR_OUT,OVERWRITE=OVERWRITE,FILE_LABEL=FILE_LABEL
;                      
; OUTPUT:
;   SAVE FILES FOR ALL LNP,STATS2 
;   
; KEYWORDS:
;   DIR_IN:    DIRECTORY FOR ISERIES .BYTE FILE
;   DIR_OUT:   DIRECTORY FOR SAVE,PS, & PNG FILES
;
; CATEGORY: TIME SERIES

; NOTES: PRESS ET.AL.  PAGE 688
;********************************************************************************************************       
;   "IN SUBTRACTING OFF THE DATA'S MEAN EQUATION (13.8.4) AREADY ASSUMED THAT YOU 
;  ARE NOT INTERESTED IN THE DATA'S ZERO FREQUENCY PEICE- WHICH IS THAT MEAN VALUE."
;  -[NOTE, THIS IS WHY WE DEMEAN THE DATA]
;  “ IN AN FFT METHOD, HIGHER INDEPENDENT FREQUENCIES WOULD BE INTEGER MULTIPLES OF 1/T.
;     BECAUSE WE ARE INTERESTED IN THE STATISTICAL SIGNIFICANCE OF ANY PEAK THAT MAY OCCUR, ;HOWEVER, 
;  WE HAD BETTER (-OVER) SAMPLE MORE FINELY THAN 1/T, SO THAT SAMPLE POINTS LIE ;CLOSE TO THE TOP. 
; THUS, THE ACCOMPANYING PROGRAM INCLUDES AN OVERSAMPLING PARAMETER ;CALLED OFAC; AVALUE OFAC ~>4 MIGHT BE TYPICAL IN USE.
; WE ALSO WANT TO SPECIFY HOW HIGH ;IN FREQUENCY TO GO , SAY FHI.  ONE GUIDE TO CHOOSING FHI IS TO COMPARE IT WITH THE 
; NYQUIST FREQUENCY FC THAT WOULD OBTAIN IF THE N DATA POINTS WERE EVENLY SPACED OVER THE TIME ;SPAN T, THAT IS, FC= N/(2/T)".
;||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||  
      
; MODIFICATION HISTORY:
;   MARCH 26,2002 WRITTEN BY: J.E. O'REILLY
;   MAY 29,2002 TD, WORK WITH SD_ANALYSES_MAIN.PRO
;   JUNE 10,2002  INSTEAD OF SKIPPING PSERIES WITH LESS THAN NEEDED NUMBER, WRITE OUT BLANKS TO PRESERVE ALL PX,PY RESULTS
;   JUNE 17,2002  ADDED MEAN TO THE TREND.COMPRESS FILE
;   JUNE 24,2002  WORK WITH L3B
;   JULY  8,2002  CHANGE FIX TO LONG,CHANGE POSITION OF COUNT,PX,PY
;   AUG 25,2008 T.DUCAS SEND IN PSERIES_FILE INSTEAD OF DIR_IN,OUTPUT FILE NAMING
;   NOV.15,2009,JOR (THERE WAS AN ERROR IN TIME_AXIS IN THE EARLIER VERSION - (NOW USING YRFRA.PRO)
;               NOW THE CONSTANTS FOR THE LOMB PERIODOGRAM WILL BE THE 
;               DEFAULTS IN LNP_TEST(HIFAC=1,OFAC=4)
;   NOV.30,2009,JOR:   (ADDED BACK DEMEAN STEP (SEE NOTES FROM  PRESS ET AL.)
;                     (REPLACED _OUT WITH _LNP,OUTFILE WITH LNPFILE, COUNT_OUT WITH COUNT_LNPFILE)
;   DEC 1,2009 JOR:  THIS IS THE LATEST AND THE CORRECT VERSION OF PSERIES_LNP.PRO  !!!!!
;                       THE DATA ARE DEMEANED BUT, NOT DETRENDED PRIOR TO LNP_TEST STEP
;                          CHANGED LUN_OUT TO LUN_LNP
;                          CHANGED FA_OUT TO FA_LNP
;                          CHANGED COUNT_DATA_OUT TO COUNT_OUTFILES
;                          REMOVED TIME_AXIS,COUNTER
;                          CALLING YRFRA AND USING YF NOW 
;   MAR 28,2012,JOR, EDITS;UPPERCASE
;   MAR 29,2012,JOR, MIN_GOOD  = 20  CHANGED TO MIN_GOOD  = 100; BECAUSE THE MISSIONS SERIES ARE FROM 1997-2012
;                         CHANGED TEMPLATE TO TEMPLATE_FILE TO AVOID AMBIGUITY
;                         WRITING OUT FREQ_VALUES PER LATEST EXAMPLES PSERIES_LNP_NEW
;                         IF PROD EQ 'CHLOR_A' THEN DATA = ALOG10(DATA)  CHANGED TO:
;                         IF PROD EQ 'CHLOR_A' THEN DATA = ALOG(DATA)
;   MAR 29,2012,JOR, REPLACED DMEAN KEYWORD WITH'MEAN' 
;   APR,3,2012,JOR        COMPRESS OUTPUT:    OPENW,LUN_LNP,LNPFILE,/GET_LUN,/COMPRESS
;                                             OPENW,LUN_STATS,STATFILE,/GET_LUN,/COMPRESS
;   ARP 4,2012,JOR CHANGED   DAYS=INTERVAL([0,12],BASE=2,.025)
;                       TO   DAYS=INTERVAL([0,16],BASE=2,.025); TO RANGE 16 YRS 1997-TO 2013
;   APR 5,2012,JOR,CHANGED    OK = WHERE(DAYS GE 1 AND DAYS LT (365.25*10.2)) TO:
;                             OK = WHERE(DAYS GE 1 AND DAYS LT (365.25*16.2))
;   APR 6,2012,JOR, CHANGED LNP AND TREND EXT FROM '.DAT' TO '.COMPRESS'ADDED KEYWORD FILE_LABEL
;   APR 9,2012,JOR  CHANGED '.COMPRESS' TO '.LNP'
;   APR 9,2012,JOR, !MAJOR CHANGES IN OUTPUT FILES
;                   NOW DIRECTLY MAKING/OUTPUT COMPRESSED SAVE FILES FOR:
;                   FREQ_SAVE, CNUM_SAVE,JMAX_CPY_SAVE, MAX_PEAK_SAVE, FAP_SAVE,LNP_NF_SAVE,
;                   SLOPE_SAVE,INTERCEPT_SAVE,GMEAN_SAVE, VAR_SAVE,
;                   LNP_006CPY_SAVE,LNP_012CPY_SAVE,LNP_025CPY_SAVE,LNP_050CPY_SAVE,LNP_075CPY_SAVE,
;                   LNP_1CPY_SAVE,LNP_2CPY_SAVE,LNP_3CPY_SAVE,LNP_4CPY_SAVE,LNP_5CPY_SAVE
;                   REMOVED KEYWORD FREQ; ADDED N_FREQ,FREQ_VALUES TO LNP_FILE 
;                   ADDED LINEAR INTERPOL OF WK2 AT CPYS; ARRAYS FOR CYCLES PER YEAR; 
;                   ADDED SAVES FOR THESE AS WELL.
;                   NOW USING MOMENT TO CALC MEAN AND VAR; 
;                   MEAN USED TO MAKED DEMEANED_DATA[ NO LONGER DEMEAN.PRO ]
;                   
;   APR 16,2012,JOR, CHANGED        ARRAY_JMAX_CPY(_PX,_PY)=JMAX 
;                         TO        ARRAY_JMAX_CPY(_PX,_PY)=WK1(JMAX)
;                    CHANGED        ARRAY_SIGNIF
;                         TO        ARRAY_FAP
;              
;                    ;===> [SINCE CHL WERE LOG-TRANSFORMED:ANTILOG THE GEOMETRIC MEAN]
;                           IF PROD EQ 'CHLOR_A' THEN AVG=EXP(AVG) 
;                           'TREND-MEAN.SAVE' CHANGED TO 'MEAN.SAVE'
;   APR 22,2012,JOR, MADE PROD SAME AS ASTAT WHEN WRITING STRUCTURES SO THAT SD_SCALES AND COLOR_BAR WILL WORK PROPERLY
;   APR 24,2012,JOR: RENAMED ARRAY_MAX_CPY TO ARRAY_JMAX_CPY; LNP_MAX TO LNP_MAX_PEAK
;   APR 26,2012,JOR, MOVED VARIANCE EARLIER SO IT IS ALWAYS COMPUTED 
;   APR 27,2012,JOR: CHANGED MIN_GOOD:
;                     MIN_GOOD  = 2; COMPUTE NUM, AVG,VAR WHEN COUNT_GOOD GE MIN_GOOD
;   APR 29,2012,JOR,  TO AVOID NAME CONFLICTS WITH TAGS 'SLOPE' AND 'INTERCEPT' CHANGED :
;                               PROD='SLOPE',ASTAT='SLOPE' TO PROD='TREND_SLOPE',ASTAT='TREND_SLOPE'
;                               PROD='INTERCEPT',ASTAT='INTERCEPT' TO PROD='TREND_INTERCEPT',ASTAT='TREND_INTERCEPT',
;                               TREND-INT.SAVE TO TREND-INTERCEPT.SAVE
;                               
;                               
;   MAY 6,2012,JOR:
;                  WK2_DAN=FILTER_DANIELL(WK2,5); EFFECTIVELY SAME AS BLOOMFIELD'S WIDTH = 6      
;                  USING JD_2DYEAR   INSTEAD OF YRFRA  
;                  DYEAR = JD_2DYEAR(DATE_2JD(DATE))
;                  MAY 7,2012,ADDED HIFAC = 2
;                  RESULT = LNP_TEST(FLOAT(_DYEAR), FLOAT(DETRENDED_DATA), WK1 = WK1, WK2 = WK2, JMAX = JMAX,HIFAC=2)

;   MAY 9,2012,JOR: LNP_TEST ,HIFAC=2/DOUBLE
;                    /DOUBLE MUST BE USED WITH LNP_TEST TO GET A PRECICE VALUE FOR FAP [RESULT[1]
;                    DELETED: IF JMAX EQ 0 THEN STOP;  IF WK1(JMAX) EQ 0 THEN STOP
;                    DELETED: IF _PX GE 275 AND _PY GE 900 THEN STOP        
;                    RESULT = LNP_TEST( _DYEAR, DETRENDED_DATA, WK1 = WK1, WK2 = WK2, JMAX = JMAX, HIFAC=2,/DOUBLE)
;   MAY 14,2012,JOR ADDED VARIABLE DAN_PEAK, DAN_PEAK(_PX,_PY)=WK2_DAN(JMAX)
;   JUL 27,2012,JOR, CHANGED TREND-SLOPE TO TREND_SLOPE
;   AUG 3,2012,JOR  CHANGED DAN_PEAK TO LNP_DAN_PEAK
;   FEB 23,2013,JOR, ENSURED THAT PRODS ARE IN VALID_PRODS
;   FEB 28,2013,JOR   DELETED ARR_FREQ AND FREQ_SAVE,
;                     DAN_PEAK_SAVE    = DIR_OUT+ '!STUDY' +_FILE_LABEL + 'LNP_DAN_PEAK.SAVE'
;                     INFILE= LNP_DAT_FILE WAS NOT DEFINED SO
;                     INFILE = [PSERIES_FILE,CSV_FILE,TEMPLATE_FILE]
;   NOV 19,2013,JOR ADDED KEYWORD LOGIT [DEFAULT = 0  NO ALOG(UNTRANSFORMED)
;   NOV 20,2013,JOR:
;                    RENAMED FROM TS_PSERIES_LNP
;                    IF DO_LOG EQ 1 THEN UNSCALED_DATA = ALOG(UNSCALED_DATA)
;                    
;##################################################################################################################
;-

;***************************************
  ROUTINE_NAME='PSERIES_LNP'
;***************************************
; PROD  TREND_SLOPE FREQ EXP  FAP POF REPLACE STOP LNP_006CPY FILE_TEST   LNP_TEST  FREQ   MIN_GOOD  YF  PSTOP first  POF  INTERVAL  LNP_TEST 275

; ===> ??? LOG-TRANSFORM CHLOR_A UNSCALED_DATA  ===> ???
        IF KEYWORD_SET(LOGIT) EQ 0 THEN BEGIN
          TXT ='DATA WILL NOT BE LOG-TRANSFORMED '
          REPORT,TXT
          DO_LOG = 0
          WAIT,5
        ENDIF ELSE BEGIN
          TXT = 'DATA WILL BE LOG-TRANSFORMED '
          REPORT,TXT
          WAIT,5 
          DO_LOG = 1
        ENDELSE; IF LOGIT EQ 0 THEN BEGIN
          
;===> DEFINE MINIMUM OF GOOD DATA IN EACH PSERIES FOR COMPUTATION OF VARIOUS STATS:
MIN_GOOD  = 2; COMPUTE NUM, AVG,VAR WHEN COUNT_GOOD GE MIN_GOOD
MIN_GOOD_LNP  = 100; IGNORE & SKIP OVER  ANY LNP_TEST WHEN COUNT_GOOD LT MIN_GOOD_LNP


IF N_ELEMENTS(PSERIES_FILE) LT 1 OR N_ELEMENTS(CSV_FILE) LT 1 OR N_ELEMENTS(TEMPLATE_FILE) LT 1 THEN STOP
INFILE = [PSERIES_FILE,CSV_FILE,TEMPLATE_FILE]
IF N_ELEMENTS(OVERWRITE)    NE 1 THEN _OVERWRITE = 0 ELSE _OVERWRITE = OVERWRITE

; ===>CHARACTER CONSTANTS
AS = '*' & UL ='_'& DASH = '-' & CM =',' & COMPUTER=GET_COMPUTER() & DELIM=PATH_SEP()& NOW = LONG(STRMID(DATE_NOW(),0,8))

; =======> 
  FA_PSERIES  = FILE_ALL(PSERIES_FILE)
  IF N_ELEMENTS(DIR_OUT) NE 1 THEN DIR_OUT = FA_PSERIES[0].DIR
  FA_CSV      = FILE_ALL(CSV_FILE)
  FA_TEMPLATE_FILE = FILE_ALL(TEMPLATE_FILE)

  IF FA_PSERIES[0].FULLNAME EQ '' OR FA_CSV[0].FULLNAME EQ '' OR FA_TEMPLATE_FILE[0].FULLNAME EQ '' THEN BEGIN
    PRINT, 'NO FILES TO PROCESS!!!!!, GOTO,DONE'
    PRINT, '???????????? NO FILES TO PROCESS!!!!!, GOTO,DONE'
    GOTO, DONE
  ENDIF;IF FA_PSERIES[0].FULLNAME EQ '' OR FA_CSV[0].FULLNAME EQ '' OR FA_TEMPLATE_FILE[0].FULLNAME EQ '' THEN BEGIN

  PROD        = FA_PSERIES[0].PROD
  SENSOR      = FA_PSERIES[0].SENSOR
  METHOD      = FA_PSERIES[0].METHOD
  MAP         = FA_PSERIES[0].MAP
  DATA_TYPE   = FA_PSERIES[0].EXT
  EDIT_TARGET = FA_PSERIES[0].EDIT
  MATH_TARGET = FA_PSERIES[0].MATH
  PRINT,FA_PSERIES.NAME +' IS ' +STR_COMMA(FA_PSERIES.SIZE) + '   BYTES'

;STOP
; ===> CHECK THAT DATA, CSV AND TEMPLATE_FILE BELONG TOGETHER
  LIST=['SENSOR','SATELLITE', 'METHOD','COVERAGE','MAP','PROD']
  PSERIES_LABEL    =FILE_LABEL_MAKE(FA_PSERIES.NAME,LIST=LIST)
  CSV_LABEL     =FILE_LABEL_MAKE(FA_CSV.NAME,LIST=LIST)
  TEMPLATE_FILE_LABEL=FILE_LABEL_MAKE(FA_TEMPLATE_FILE.NAME,LIST=LIST)
  IF (PSERIES_LABEL NE CSV_LABEL) OR (PSERIES_LABEL NE TEMPLATE_FILE_LABEL) THEN BEGIN
    PRINT, 'DATA, CSV OR TEMPLATE_FILE FILE LABELS DO NOT MATCH. GOTO DONE'
    GOTO,DONE
  ENDIF


; =======> GET SCALING,INTERCEPT AND SLOPE, PX, PY
  DATA=STRUCT_SD_READ(TEMPLATE_FILE,prod=PROD,STRUCT=STRUCT,COUNT=count_good,SUBS=OK_GOOD,ERROR=error)

  PX=LONG(STRUCT.PX)
  PY=LONG(STRUCT.PY)
  IF STRUCT.MAP NE MAP THEN STOP

  N_SERIES = LONG64(PX)*LONG64(PY)

  FA_LNP = FILE_ALL(DIR_OUT+'TS_IMAGES-'+PSERIES_LABEL+'-PSERIES_*.*')
  
; >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> OUTPUT FILES >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  LNP_CSV   = DIR_OUT + FA_PSERIES.FIRST_NAME+DASH+'LNP.CSV'

 ; =======> Read the CSV FILE WITH THE INAMES
  CSV = CSV_READ(FA_CSV.FULLNAME)
  ;$$$ NEXT LINE MAY NEED CHECKING 'FA_CSV.FIRST_NAME' OR 'FA_CSV.NAME'??
  DATE=STRMID(CSV.FIRST_NAME,3,8)
  
;===> DECIMAL YEAR FROM DATE
  DYEAR = JD_2DYEAR(DATE_2JD(DATE))

; =======> WRITE THE EDIT_SERIES_CSV FILE
  TXT=STRUCT_2STRING(CSV)
  TXT = ['DATE,FIRST_NAME,NAME',TXT]
  WRITE_TXT,LNP_CSV,TXT
  PFILE,LNP_CSV
  TXT=''
; **************************************************************************
; ***  CHECK CONSISTENCY OF PX,PY,N_IMAGES AND DIMENSIONS OF INPUT FILE ***
; **************************************************************************
  N_IMAGES  = N_ELEMENTS(CSV)
  FA_N_IMAGES = LONG(FA_PSERIES.SERIES)
  IF FA_N_IMAGES NE N_IMAGES THEN STOP

  JULIAN    = PERIOD_2JD(CSV.FIRST_NAME)
  SERIES_START = LONG64[0]
  SERIES_END   = LONG64(N_SERIES)-1
;===> LOWER,UPPER  VALUES FOR INTEGER DATA
  LOWER = -32766
  UPPER = 32766
;===> LOWER,UPPER  VALUES FOR BYTE DATA
  IF FA_PSERIES.EXT EQ 'BYTE' THEN BEGIN
    SERIES     = BYTARR(N_IMAGES)
    LOWER      = 1
    UPPER      = 249
  ENDIF
  IF FA_PSERIES.EXT EQ 'INT'  THEN SERIES = INTARR(N_IMAGES)
  IF FA_PSERIES.EXT EQ 'FLOAT'  THEN SERIES = FLTARR(N_IMAGES)
  IF FA_PSERIES.EXT EQ 'DOUBLE'   THEN SERIES = DBLARR(N_IMAGES)

  CLOSE,/ALL
; =======> OPEN PSERIES FILE FOR READING
  OPENR,LUN_IN,FA_PSERIES.FULLNAME,/GET_LUN
  PFILE,FA_PSERIES.FULLNAME,/R
  PFILE,FA_PSERIES.FULLNAME,/S
;STOP
; ******************************************************
;  ===>     MAKE ARRAYS TO HOLD LNP_TEST RESULTS
; ******************************************************
PRINT,'MAKING MEMORY ARRAYS FOR:'+ROUTINE_NAME
PX=STRUCT.PX
PY=STRUCT.PY
;===> FROM LNP_TEST
ARRAY_NUM         = REPLICATE(MISSINGS(0L),PX,PY)
ARRAY_JMAX_CPY    = REPLICATE(MISSINGS(0.0),PX,PY)
ARRAY_MAX_PEAK    = REPLICATE(MISSINGS(0.0),PX,PY)
ARRAY_FAP         = REPLICATE(MISSINGS(0.0D),PX,PY)
ARRAY_AVG_NF      = REPLICATE(MISSINGS(0.0),PX,PY)
ARRAY_VAR         = REPLICATE(MISSINGS(0.0),PX,PY)
ARRAY_MEAN        = REPLICATE(MISSINGS(0.0),PX,PY)
DAN_PEAK          = REPLICATE(MISSINGS(0.0),PX,PY)

;===> FROM STATS2, TREND ANALYSIS 
ARRAY_INTERCEPT   = REPLICATE(MISSINGS(0.0),PX,PY)
ARRAY_SLOPE       = REPLICATE(MISSINGS(0.0),PX,PY)

; ===> INTERPOLATED CYCLES
ARRAY_LNP_006CPY  = REPLICATE(MISSINGS(0.0),PX,PY)
ARRAY_LNP_012CPY  = REPLICATE(MISSINGS(0.0),PX,PY)
ARRAY_LNP_025CPY  = REPLICATE(MISSINGS(0.0),PX,PY)
ARRAY_LNP_050CPY  = REPLICATE(MISSINGS(0.0),PX,PY)
ARRAY_LNP_075CPY  = REPLICATE(MISSINGS(0.0),PX,PY)
ARRAY_LNP_1CPY    = REPLICATE(MISSINGS(0.0),PX,PY)
ARRAY_LNP_2CPY    = REPLICATE(MISSINGS(0.0),PX,PY)
ARRAY_LNP_3CPY    = REPLICATE(MISSINGS(0.0),PX,PY)
ARRAY_LNP_4CPY    = REPLICATE(MISSINGS(0.0),PX,PY)
ARRAY_LNP_5CPY    = REPLICATE(MISSINGS(0.0),PX,PY)

;**************************************************************************
;**************************************************************************
;===> MAKE OUTPUT SAVE FILE NAMES FROM FILE_LABEL
;**************************************************************************
;**************************************************************************
PRINT,'MAKING SAVE FILE NAMES FOR:'+ROUTINE_NAME
_FILE_LABEL='-'+FILE_LABEL+'-'

NUM_SAVE        = DIR_OUT+  '!STUDY' +_FILE_LABEL +'LNP_NUM.SAVE'
JMAX_CPY_SAVE    = DIR_OUT+ '!STUDY' +_FILE_LABEL +'LNP_JMAX_CPY.SAVE'
MAX_PEAK_SAVE    = DIR_OUT+ '!STUDY' +_FILE_LABEL +'LNP_MAX_PEAK.SAVE'
FAP_SAVE         = DIR_OUT+ '!STUDY' +_FILE_LABEL +'LNP_FAP.SAVE'
LNP_NF_SAVE      = DIR_OUT+ '!STUDY' +_FILE_LABEL +'AVG_NF.SAVE'

SLOPE_SAVE       = DIR_OUT+ '!STUDY' +_FILE_LABEL +'TREND_SLOPE.SAVE'
INTERCEPT_SAVE   = DIR_OUT+ '!STUDY' +_FILE_LABEL +'TREND-INTERCEPT.SAVE'
MEAN_SAVE        = DIR_OUT+ '!STUDY' +_FILE_LABEL +'CHLOR_A-MEAN.SAVE'
VAR_SAVE         = DIR_OUT+ '!STUDY' +_FILE_LABEL + 'VAR.SAVE'
DAN_PEAK_SAVE    = DIR_OUT+ '!STUDY' +_FILE_LABEL + 'LNP_DAN_PEAK.SAVE'


LNP_006CPY_SAVE  = DIR_OUT+ '!STUDY' +_FILE_LABEL + 'LNP_006CPY.SAVE'
LNP_012CPY_SAVE  = DIR_OUT+ '!STUDY' +_FILE_LABEL + 'LNP_012CPY.SAVE'
LNP_025CPY_SAVE  = DIR_OUT+ '!STUDY' +_FILE_LABEL + 'LNP_025CPY.SAVE'
LNP_050CPY_SAVE  = DIR_OUT+ '!STUDY' +_FILE_LABEL + 'LNP_050CPY.SAVE'
LNP_075CPY_SAVE  = DIR_OUT+ '!STUDY' +_FILE_LABEL + 'LNP_075CPY.SAVE'
LNP_1CPY_SAVE    = DIR_OUT+ '!STUDY' +_FILE_LABEL + 'LNP_1CPY.SAVE'
LNP_2CPY_SAVE    = DIR_OUT+ '!STUDY' +_FILE_LABEL + 'LNP_2CPY.SAVE'
LNP_3CPY_SAVE    = DIR_OUT+ '!STUDY' +_FILE_LABEL + 'LNP_3CPY.SAVE'
LNP_4CPY_SAVE    = DIR_OUT+ '!STUDY' +_FILE_LABEL + 'LNP_4CPY.SAVE'
LNP_5CPY_SAVE    = DIR_OUT+ '!STUDY' +_FILE_LABEL + 'LNP_5CPY.SAVE'

;*********************************************************************************
;   LOOP ON EACH PIXEL'S TIME SERIES FORMED FROM N_IMAGES
;*********************************************************************************
;   
;FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
;===> FOR EACH PIXEL Y COORDINATE
   FOR _PY = 0L,PY-1L DO BEGIN
     POF,_PY,PY
;FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF 
;===> FOR EACH PIXEL X COORDINATE
     FOR _PX = 0L,PX-1L DO BEGIN
     
      READU,LUN_IN,SERIES
      OK_GOOD = WHERE(SERIES GE LOWER AND SERIES LE UPPER,COUNT_GOOD)
;===> FILL ARRAY_NUM WITH COUNT EACH TIME [EVEN WHEN COUNT_GOOD IS ZERO OR LT MIN_GOOD
      ARRAY_NUM(_PX,_PY) = COUNT_GOOD
      
;IIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIII
      IF COUNT_GOOD GE MIN_GOOD THEN BEGIN
        SERIES_GOOD = SERIES(OK_GOOD)
        _DYEAR=DYEAR(OK_GOOD)
        ;**************************************************************************************************
        ; ===> RESTORE ACTUAL DATA VALUES FROM BYTE-SCALED OR INT-SCALED VALUES MADE BY TS_IMAGES_2ISERIES       
        ;**************************************************************************************************
        IF FA_PSERIES.EXT EQ 'BYTE' THEN UNSCALED_DATA = SD_SCALES(PROD=PROD,SERIES_GOOD,/BIN2DATA)
        IF FA_PSERIES.EXT EQ 'INT'  THEN UNSCALED_DATA = SD_SCALES(PROD=PROD,SERIES_GOOD,/INT2DATA)
        ;**************************************************************************************************
        ;||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
        ;
        
      
        ; NOV 19,2013 JOR 
        IF DO_LOG EQ 1 THEN UNSCALED_DATA = ALOG(UNSCALED_DATA)
        
        ;COMPUTE MOMENT:  A FOUR-ELEMENT VECTOR CONTAINING
        ; THE MEAN, VARIANCE, SKEWNESS, AND KURTOSIS OF THE INPUT VECTOR. 
        ;IF THE VECTOR CONTAINS N IDENTICAL ELEMENTS, 
        ;MOMENT COMPUTES THE MEAN AND VARIANCE, AND RETURNS THE IEEE VALUE 
        ;NAN FOR THE SKEWNESS AND KURTOSIS, WHICH ARE NOT DEFINED. 
        
        M = MOMENT(UNSCALED_DATA ,/NAN)
        AVG=M[0] 
        ;===> VARIANCE:
        ARRAY_VAR(_PX,_PY) = M[1]
       

        ;=========>>>>  DEMEAN THE DATA (FOR THE REASON STATED ABOVE BY PRESS] >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
        DEMEANED_DATA= UNSCALED_DATA-AVG
        
        ;##############################################################
        ;###   DO THE TREND CALCULATION (ON THE DEMEANED DATA)      ###
        S=STATS2(_DYEAR,DEMEANED_DATA,MODEL='LSY',/QUIET)
        ARRAY_INTERCEPT(_PX,_PY) = S.INT
        ARRAY_SLOPE(_PX,_PY) = S.SLOPE
        ;||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||        
        
        ;################################################################
        ;===> DETREND THE DATA [ UNLESS SLOPE IS ALREADY ZERO ]
        IF S.SLOPE NE 0 THEN DETRENDED_DATA = DETREND(_DYEAR,DEMEANED_DATA,REG_TYPE='LSY')
        ;|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
 
        
        
        ;##########################################################      
        ; CAN NOW ANTI-LOG AVG BECAUSE DEMEANED STEP WAS DONE ABOVE
        ; [IF DATA WERE WERE LOG-TRANSFORMED: DO_LOG = 1, 
        ; THEN ANTILOG AVG TO GET THE GEOMETRIC MEAN]
        ;##########################################################      
        
        IF DO_LOG EQ 1 THEN AVG=EXP(AVG)
        ARRAY_MEAN(_PX,_PY) = AVG
        ;|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
        
        
       
        
        
        ; *** NOW USE THE STRICTER CRITERION MIN_GOOD_LNP FOR REQUIRED OBSERVATIONS FOR LNP_TEST
        ;*************************************************************************************
        IF COUNT_GOOD LT MIN_GOOD_LNP THEN GOTO,SKIP_LNP; >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
      
        ;   =======> LOMB PERIODOGRAM 
        ; ===> LOMB PERIODOGRAM (MUCH FASTER WHEN USING FLOAT INPUTS THAN DOUBLE PRECISION INPUTS)
        ;||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
        
        ;******************************************************************************************************
        RESULT = LNP_TEST( _DYEAR, DETRENDED_DATA, WK1 = WK1, WK2 = WK2, JMAX = JMAX, HIFAC=2,/DOUBLE)
        ;******************************************************************************************************

        WK2_DAN=FILTER_DANIELL(WK2,5); EFFECTIVELY SAME AS BLOOMFIELD'S RECOMMENDED WIDTH = 6
        
        ;===>   GET THE MAX DANIELL PEAK:  
        WK2_DAN_MAX=MAX(WK2_DAN) ;   
         
        ;   =======> FILL THE OUTPUT ARRAYS
        ARRAY_AVG_NF(_PX,_PY)=FIRST(WK1)
        ARRAY_JMAX_CPY(_PX,_PY)=WK1(JMAX)
        ARRAY_MAX_PEAK(_PX,_PY)=RESULT[0]
        ARRAY_FAP(_PX,_PY)=RESULT[1]
        DAN_PEAK(_PX,_PY) = WK2_DAN_MAX
        ;===> INTERPOLATE WK2_DAN TO STANDARD FREQUENCY CYCLES [CPYS)
        CPYS = [0.0625,0.125,0.250,0.500,0.750,1.00,2.00,3.00,4.00,5.00]
        ;SPLINE YIELDS BETTER FIT THAN LSQUADRATIC AND QUADRATIC AND SPLINE GIVES NEGATIVE VALUES WHICH MAY BE FLAGGED
        ; BUT DEFAULT-LINEAR INTERPOLATION IS THE CLEAREST TO DESCRIBE, 
        ; AND FILTER_DANIELL HAS ALREADY SMOOTHED THE WK2 PERIODOGRAM

        ;===> INTERPOLATE THE SMOOTHED WK2 ARRAY FROM FILTER_DANIELL 
        ;*************************************************
        IWK2_DAN= INTERPOL(WK2_DAN, WK1,CPYS)
        ;*************************************************
              
        ARRAY_LNP_006CPY(_PX,_PY)=IWK2_DAN[0]
        ARRAY_LNP_012CPY(_PX,_PY)=IWK2_DAN[1]
        ARRAY_LNP_025CPY(_PX,_PY)=IWK2_DAN(2)
        ARRAY_LNP_050CPY(_PX,_PY)=IWK2_DAN(3)
        ARRAY_LNP_075CPY(_PX,_PY)=IWK2_DAN(4)
        ARRAY_LNP_1CPY(_PX,_PY)  =IWK2_DAN(5)
        ARRAY_LNP_2CPY(_PX,_PY)  =IWK2_DAN(6)
        ARRAY_LNP_3CPY(_PX,_PY)  =IWK2_DAN(7)
        ARRAY_LNP_4CPY(_PX,_PY)  =IWK2_DAN(8)
        ARRAY_LNP_5CPY(_PX,_PY)  =IWK2_DAN(9)
      ENDIF;IF COUNT_GOOD LT MIN_GOOD THEN BEGIN
 SKIP_LNP:     
    ENDFOR ;FOR _PX = 0L,PX-1L DO BEGIN
;FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF  
  
  ENDFOR ;  FOR _PY = 0L,PY-1L DO BEGIN
;FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
;
;
;
;
;
;*****************************************************************************
;===>>>>>> WRITE STATS,TREND AND LNP ARRAYS  AS SD STRUCTURE SAVE FILES
;*****************************************************************************
WRITE_SAVES:
PRINT,'WRITING SAVE FILES FOR:'+ROUTINE_NAME

        KM_PER_PIXEL = 1
        _NOTE = '-BASED ON LN-TRANSFORMED DATA'
        STRUCT_SD_WRITE,NUM_SAVE,PROD='NUM',ASTAT='NUM', $
                      IMAGE=ARRAY_NUM,    MISSING_CODE=MISSINGS(ARRAY_NUM), $
                      MAP=MAP, $
                      INFILE=INFILE,$
                      NOTES = PROD + _NOTE,      ERROR=ERROR
       

        STRUCT_SD_WRITE,JMAX_CPY_SAVE,PROD='LNP_JMAX_CPY',ASTAT='LNP_JMAX_CPY', $
                      IMAGE=ARRAY_JMAX_CPY,    MISSING_CODE=MISSINGS(ARRAY_JMAX_CPY), $
                      MAP=MAP, $
                      INFILE=INFILE,$
                      NOTES = PROD + _NOTE,      ERROR=ERROR

        STRUCT_SD_WRITE,MAX_PEAK_SAVE,PROD='LNP_MAX_PEAK',ASTAT='LNP_MAX_PEAK', $
                      IMAGE=ARRAY_MAX_PEAK,    MISSING_CODE=MISSINGS(ARRAY_MAX_PEAK), $
                      MAP=MAP, $
                      INFILE=INFILE,$
                      NOTES = PROD + _NOTE,      ERROR=ERROR

        STRUCT_SD_WRITE,FAP_SAVE,PROD='LNP_FAP',ASTAT='LNP_FAP', $
                      IMAGE=ARRAY_FAP,    MISSING_CODE=MISSINGS(ARRAY_FAP), $
                      MAP=MAP, $
                      INFILE=INFILE,$
                      NOTES = PROD + _NOTE,      ERROR=ERROR
                      
        STRUCT_SD_WRITE,LNP_NF_SAVE,PROD='LNP_NF',ASTAT='LNP_NF', $
                      IMAGE=ARRAY_AVG_NF,    MISSING_CODE=MISSINGS(ARRAY_AVG_NF), $
                      MAP=MAP, $
                      INFILE=INFILE,$
                      NOTES = PROD + _NOTE ,      ERROR=ERROR            
                      
        STRUCT_SD_WRITE,MEAN_SAVE,PROD='CHLOR_A',ASTAT='GMEAN', $
                      IMAGE=ARRAY_MEAN,    MISSING_CODE=MISSINGS(ARRAY_MEAN), $
                      MAP=MAP, $
                      INFILE=INFILE,$
                      NOTES = PROD + _NOTE ,      ERROR=ERROR
                      
        STRUCT_SD_WRITE,VAR_SAVE,PROD='VAR',ASTAT='LNP_VAR', $
                      IMAGE=ARRAY_VAR,    MISSING_CODE=MISSINGS(ARRAY_VAR), $
                      MAP=MAP, $
                      INFILE=INFILE,$
                      NOTES = PROD + _NOTE ,      ERROR=ERROR   
        STRUCT_SD_WRITE,DAN_PEAK_SAVE,PROD='LNP_DAN_PEAK',ASTAT='LNP_DAN_PEAK', $
                      IMAGE=DAN_PEAK,    MISSING_CODE=MISSINGS(DAN_PEAK), $
                      MAP=MAP, $
                      INFILE=INFILE,$
                      NOTES = PROD + _NOTE ,      ERROR=ERROR   
                                                                       
        STRUCT_SD_WRITE,SLOPE_SAVE,PROD='TREND_SLOPE',ASTAT='TREND_SLOPE', $
                      IMAGE=ARRAY_SLOPE,    MISSING_CODE=MISSINGS(ARRAY_SLOPE), $
                      MAP=MAP, $
                      INFILE=INFILE,$
                      NOTES = PROD + _NOTE ,      ERROR=ERROR                   
                      
        STRUCT_SD_WRITE,INTERCEPT_SAVE,PROD='TREND_INTERCEPT',ASTAT='TREND_INTERCEPT', $
                      IMAGE=ARRAY_INTERCEPT,    MISSING_CODE=MISSINGS(ARRAY_INTERCEPT), $
                      MAP=MAP, $
                      INFILE=INFILE,$
                      NOTES = PROD + _NOTE,      ERROR=ERROR


;*********************************************************************************************************
;===> CYCLES FROM LINEAR INTERPOLATION OF WK2 AT CPYS = [0.0625,0.125,0.250,0.500,0.750,1.00,2.00,3.00,4.00,5.00]
;*********************************************************************************************************

        STRUCT_SD_WRITE,lnp_006CPY_SAVE ,PROD='LNP_006CPY',ASTAT='LNP_006CPY', $
                      IMAGE=ARRAY_LNP_006CPY,    MISSING_CODE=MISSINGS(ARRAY_LNP_006CPY), $
                      MAP=MAP, $
                      INFILE=INFILE,$
                      NOTES = PROD + _NOTE,      ERROR=ERROR
        STRUCT_SD_WRITE,lnp_012CPY_SAVE ,PROD='LNP_012CPY',ASTAT='LNP_012CPY', $
                      IMAGE=ARRAY_LNP_012CPY,    MISSING_CODE=MISSINGS(ARRAY_LNP_012CPY), $
                      MAP=MAP, $
                      INFILE=INFILE,$
                      NOTES = PROD + _NOTE,      ERROR=ERROR

        STRUCT_SD_WRITE,lnp_025CPY_SAVE ,PROD='LNP_025CPY',ASTAT='LNP_025CPY', $
                      IMAGE=ARRAY_LNP_025CPY,    MISSING_CODE=MISSINGS(ARRAY_LNP_025CPY), $
                      MAP=MAP, $
                      INFILE=INFILE,$
                      NOTES = PROD + _NOTE,      ERROR=ERROR

        STRUCT_SD_WRITE,lnp_050CPY_SAVE ,PROD='LNP_050CPY',ASTAT='LNP_050CPY', $
                      IMAGE=ARRAY_LNP_050CPY,    MISSING_CODE=MISSINGS(ARRAY_LNP_050CPY), $
                      MAP=MAP, $
                      INFILE=INFILE,$
                      NOTES = PROD + _NOTE,      ERROR=ERROR

        STRUCT_SD_WRITE,lnp_075CPY_SAVE ,PROD='LNP_075CPY',ASTAT='LNP_075CPY', $
                      IMAGE=ARRAY_LNP_075CPY,    MISSING_CODE=MISSINGS(ARRAY_LNP_075CPY), $
                      MAP=MAP, $
                      INFILE=INFILE,$
                      NOTES = PROD + _NOTE,      ERROR=ERROR

        STRUCT_SD_WRITE,lnp_1CPY_SAVE ,PROD='LNP_1CPY',ASTAT='LNP_1CPY', $
                      IMAGE=ARRAY_LNP_1CPY,    MISSING_CODE=MISSINGS(ARRAY_LNP_1CPY), $
                      MAP=MAP, $
                      INFILE=INFILE,$
                      NOTES = PROD + _NOTE,      ERROR=ERROR

        STRUCT_SD_WRITE,lnp_2CPY_SAVE ,PROD='LNP_2CPY',ASTAT='LNP_2CPY', $
                      IMAGE=ARRAY_LNP_2CPY,    MISSING_CODE=MISSINGS(ARRAY_LNP_2CPY), $
                      MAP=MAP, $
                      INFILE=INFILE,$
                      NOTES = PROD + _NOTE,      ERROR=ERROR

        STRUCT_SD_WRITE,lnp_3CPY_SAVE ,PROD='LNP_3CPY',ASTAT='LNP_3CPY', $
                      IMAGE=ARRAY_LNP_3CPY,    MISSING_CODE=MISSINGS(ARRAY_LNP_3CPY), $
                      MAP=MAP, $
                      INFILE=INFILE,$
                      NOTES = PROD + _NOTE,      ERROR=ERROR

        STRUCT_SD_WRITE,lnp_4CPY_SAVE ,PROD='LNP_4CPY',ASTAT='LNP_4CPY', $
                      IMAGE=ARRAY_LNP_4CPY,    MISSING_CODE=MISSINGS(ARRAY_LNP_4CPY), $
                      MAP=MAP, $
                      INFILE=INFILE,$
                      NOTES = PROD + _NOTE,      ERROR=ERROR

        STRUCT_SD_WRITE,lnp_5CPY_SAVE ,PROD='LNP_5CPY',ASTAT='LNP_5CPY', $
                      IMAGE=ARRAY_LNP_5CPY,    MISSING_CODE=MISSINGS(ARRAY_LNP_5CPY), $
                      MAP=MAP, $
                      INFILE=INFILE,$
                      NOTES = PROD + _NOTE,      ERROR=ERROR

  
  ;STOP
DONE :

CLOSE,/ALL

END   ; #####################  END OF ROUTINE ################################
