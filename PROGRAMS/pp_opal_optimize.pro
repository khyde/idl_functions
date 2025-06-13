; $ID:	PP_OPAL_OPTIMIZE.PRO,	2020-07-08-15,	USER-KJWH	$
FUNCTION PP_OPAL_OPTIMIZE_,A
;########################################################################################## optimize BRACKET NOTES  JEOR SLOPE_INT  GOTO,  CASE  JEOR  NOTES  RETURN  METHOD
;  PURPOSE: THE PP_OPAL_OPTIMIZE_ FUNCTION IS CALLED BY PP_OPAL_OPTIMIZE 
;           TO CALCULATE THE STATISTICAL QUANTITY, THE RESIDUAL, TO BE MINIMIZED BY AMOEBA.
;           RESIDUAL_STAT [RESID_STAT] DETERMINES WHICH STATISTICAL QUANTITY IS USED TO CALCULATE THE RESIDUAL
;           MA,MB,MC,MD,ME,MF,& MG ARE THE MARMAP PP FROM THE 7 LIGHT-DEPTHS
;           O_A,O_B,O_C,O_D,O_E,O_F,O_G.ARE THE OUTPUTS FROM OPAL FOR THE SAME LIGHT-DEPTHS 
;###########################################################################################################################

COMMON FUNC_PP,NCALLS_,VERBOSE_,VERSION_,DEPTH,METHOD_,OPTICAL_DENSITY,DIR_,S_MA,MA,MB,MC,MD,ME,MF,MG, O_A, O_B, O_C, O_D, O_E, O_F, O_G,RESIDUAL,RESID_STAT,$
       AA_SLOPE,AA_INT,BB_SLOPE,BB_INT,CC_SLOPE,CC_INT,DD_SLOPE,DD_INT,EE_SLOPE,EE_INT,FF_SLOPE,FF_INT,GG_SLOPE,GG_INT  

NCALLS_ = NCALLS_ + 1

KX = 0.02; OPAL DEFAULT
PCT_LIGHT = [100,69,46,25,10,3,1]
;===> PASS ALL SURFACE [100%-LIGHT-DEPTH TO OPAL,ALONG WITH THE LATEST ESTIMATE OF PARAMETER A [COEFFS] 
;    [VERSION '3' OF OPAL USES THESE COEFFICIENTS TO CALCULATE THE POLYNOMIAL FUNCTION RELATING OD TO DQY ]
 OP = PP_OPAL(CHL = S_MA.CHL, SST= S_MA.TEMP, PAR= S_MA.PAR,KX = KX,COEFFS = A,PCT_LIGHT =PCT_LIGHT,VERSION = VERSION_)
 O_A = OP.PCT_100 
 O_B = OP.PCT_69
 O_C = OP.PCT_46
 O_D = OP.PCT_25
 O_E = OP.PCT_10
 O_F = OP.PCT_3
 O_G = OP.PCT_1
 ;===> CHANGE ANY ZEROS TO MISSINGS(0.0) 
 OK = WHERE(O_A EQ 0,COUNT ) & IF COUNT GE 1 THEN O_A[OK] = MISSINGS(0.0)
 OK = WHERE(O_B EQ 0,COUNT ) & IF COUNT GE 1 THEN O_B[OK] = MISSINGS(0.0)
 OK = WHERE(O_C EQ 0,COUNT ) & IF COUNT GE 1 THEN O_C[OK] = MISSINGS(0.0)
 OK = WHERE(O_D EQ 0,COUNT ) & IF COUNT GE 1 THEN O_D[OK] = MISSINGS(0.0)
 OK = WHERE(O_E EQ 0,COUNT ) & IF COUNT GE 1 THEN O_E[OK] = MISSINGS(0.0)
 OK = WHERE(O_F EQ 0,COUNT ) & IF COUNT GE 1 THEN O_F[OK] = MISSINGS(0.0)
 OK = WHERE(O_G EQ 0,COUNT ) & IF COUNT GE 1 THEN O_G[OK] = MISSINGS(0.0)
 
 ;===>CONVERT OPAL FROM GC/M3/D TO MGC/M3/D[TO AGREE WITH MARMAP DATA UNITS]
 O_A = 1000.*O_A
 O_B = 1000.*O_B
 O_C = 1000.*O_C
 O_D = 1000.*O_D
 O_E = 1000.*O_E
 O_F = 1000.*O_F
 O_G = 1000.*O_G

 ;CCCCCCCCCC
 CASE [1] OF
  
    RESID_STAT EQ 'RMSE_ALL_7' : BEGIN
     ;****************************************************************************************************
      ;===> COMBINE ALL MARMAP PP [MAINTAINING THEIR ORDER-WE ONLY NEED TO MAKE MARMAP ARRAY ONCE]
      IF NONE(MARMAP) THEN MARMAP = [MA,MB,MC,MD,ME,MF,MG]
      ;===> COMBINE ALL OPAL PP [MAINTAINING THEIR ORDER]
      OPAL = [O_A,O_B,O_C,O_D,O_E,O_F,O_G]
      ;===> COMPUTE RMSE RESIDUAL BETWEEN THE TWO SETS OF PP
      ;===>
      RESIDUAL = ABS(RMSE(MARMAP,OPAL))
      
    END;: RMSE_ALL_7
    ;|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
    
   RESID_STAT EQ '3_STATS': BEGIN
     ;****************************************************************************************************
     ;PP_100 LIGHT_DEPTH AA
     X = ALOG10(MA) & Y = ALOG10(O_A)
     ;****************************************************************************************************
     ;===> COMPUTE Q_RMSE, INTERCEPT,SLOPE REDUCED MAJOR AXIS
     S = STATS2(X,Y)
     SLOPE = S.SLOPE
     INT   = S.INT
     RSQ   = S.RSQ
     AA_SLOPE = SLOPE & AA_INT = INT
     AA_RESIDUAL =  DOUBLE(ABS(1.0-SLOPE)) + ABS(INT)   + (1.0-ABS(RSQ))
     ;||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||

     ;****************************************************************************************************
     ;PP_69 LIGHT_DEPTH BB
     X = ALOG10(MB) & Y = ALOG10(O_B)
     ;****************************************************************************************************
     S = STATS2(X,Y)
     SLOPE = S.SLOPE
     INT   = S.INT
     RSQ   = S.RSQ
     BB_SLOPE = SLOPE & BB_INT = INT
     BB_RESIDUAL =  DOUBLE(ABS(1.0-SLOPE)) + ABS(INT)   + (1.0-ABS(RSQ))
     ;||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||

     ;****************************************************************************************************
     ;PP_46 LIGHT_DEPTH CC
     X = ALOG10(MC) & Y = ALOG10(O_C)
     ;****************************************************************************************************
     S = STATS2(X,Y)
     SLOPE = S.SLOPE
     INT   = S.INT
     RSQ   = S.RSQ
     CC_SLOPE = SLOPE & CC_INT = INT
     CC_RESIDUAL =  DOUBLE(ABS(1.0-SLOPE)) + ABS(INT)   + (1.0-ABS(RSQ))
     ;||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||

     ;****************************************************************************************************
     ;PP_25 LIGHT_DEPTH DD
     X = ALOG10(MD) & Y = ALOG10(O_D)
     ;****************************************************************************************************
     S = STATS2(X,Y)
     SLOPE = S.SLOPE
     INT   = S.INT
     RSQ   = S.RSQ
     DD_SLOPE = SLOPE & DD_INT = INT
     DD_RESIDUAL =  DOUBLE(ABS(1.0-SLOPE)) + ABS(INT)   + (1.0-ABS(RSQ))
     ;||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||

     ;****************************************************************************************************
     ;PP_10 LIGHT_DEPTH EE
     X = ALOG10(ME) & Y = ALOG10(O_E)
     ;****************************************************************************************************
     S = STATS2(X,Y)
     SLOPE = S.SLOPE
     INT   = S.INT
     RSQ   = S.RSQ
     EE_SLOPE = SLOPE & EE_INT = INT
     EE_RESIDUAL =  DOUBLE(ABS(1.0-SLOPE)) + ABS(INT)   + (1.0-ABS(RSQ))
     ;||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||

     ;****************************************************************************************************
     ;PP_3 LIGHT_DEPTH FF
     X = ALOG10(MF) & Y = ALOG10(O_F)
     ;****************************************************************************************************
     S = STATS2(X,Y)
     SLOPE = S.SLOPE
     INT   = S.INT
     RSQ   = S.RSQ
     FF_SLOPE = SLOPE & FF_INT = INT
     FF_RESIDUAL =  DOUBLE(ABS(1.0-SLOPE)) + ABS(INT)   + (1.0-ABS(RSQ))
     ;||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||

     ;****************************************************************************************************
     ;PP_1 LIGHT_DEPTH GG
     X = ALOG10(MG) & Y = ALOG10(O_G)
     ;****************************************************************************************************
     S = STATS2(X,Y)
     SLOPE = S.SLOPE
     INT   = S.INT
     RSQ   = S.RSQ
     GG_SLOPE = SLOPE & GG_INT = INT
     GG_RESIDUAL =  DOUBLE(ABS(1.0-SLOPE)) + ABS(INT)   + (1.0-ABS(RSQ))
     ;||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||

     ;===> TOTAL THE RESIDUALS AND RETURN CONTROL TO AMOEBA FOR THE NEXT ITERATION
     RESIDUAL =  ABS(AA_RESIDUAL)  + ABS(BB_RESIDUAL) + ABS(CC_RESIDUAL) + ABS(DD_RESIDUAL) + ABS(EE_RESIDUAL) + ABS(FF_RESIDUAL) + ABS(GG_RESIDUAL)
     RESIDUAL = 0.0 > RESIDUAL < 10.0; PREVENTS AN INFINITY RESIDUAL
   END;'3_STATS'
    ;|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
   
   RESID_STAT EQ 'SLOPE_INT': BEGIN
     
;****************************************************************************************************
;PP_100 LIGHT_DEPTH AA
X = ALOG10(MA) & Y = ALOG10(O_A)
;****************************************************************************************************
S = STATS2(X,Y)
SLOPE = S.SLOPE
INT   = S.INT
AA_SLOPE = SLOPE & AA_INT = INT
AA_RESIDUAL =  DOUBLE(ABS(1.0-SLOPE)) + ABS(INT)

;||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||

;****************************************************************************************************
;PP_69 LIGHT_DEPTH BB
X = ALOG10(MB) & Y = ALOG10(O_B)
;****************************************************************************************************
S = STATS2(X,Y)
SLOPE = S.SLOPE
INT   = S.INT
BB_SLOPE = SLOPE & BB_INT = INT
BB_RESIDUAL =  DOUBLE(ABS(1.0-SLOPE)) + ABS(INT)
;||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||

;****************************************************************************************************
;PP_46 LIGHT_DEPTH CC
X = ALOG10(MC) & Y = ALOG10(O_C)
;****************************************************************************************************
S = STATS2(X,Y)
SLOPE = S.SLOPE
INT   = S.INT
CC_SLOPE = SLOPE & CC_INT = INT
CC_RESIDUAL =  DOUBLE(ABS(1.0-SLOPE)) + ABS(INT)

;||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||

;****************************************************************************************************
;PP_25 LIGHT_DEPTH DD
X = ALOG10(MD) & Y = ALOG10(O_D)
;****************************************************************************************************
S = STATS2(X,Y)
SLOPE = S.SLOPE
INT   = S.INT
DD_SLOPE = SLOPE & DD_INT = INT
DD_RESIDUAL =  DOUBLE(ABS(1.0-SLOPE)) + ABS(INT)
;||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||

;****************************************************************************************************
;PP_10 LIGHT_DEPTH EE
X = ALOG10(ME) & Y = ALOG10(O_E)
;****************************************************************************************************
S = STATS2(X,Y)
SLOPE = S.SLOPE
INT   = S.INT
EE_SLOPE = SLOPE & EE_INT = INT
EE_RESIDUAL =  DOUBLE(ABS(1.0-SLOPE)) + ABS(INT)
;||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||

;****************************************************************************************************
;PP_3 LIGHT_DEPTH FF
X = ALOG10(MF) & Y = ALOG10(O_F)
;****************************************************************************************************
S = STATS2(X,Y)
SLOPE = S.SLOPE
INT   = S.INT
FF_SLOPE = SLOPE & FF_INT = INT
FF_RESIDUAL =  DOUBLE(ABS(1.0-SLOPE)) + ABS(INT)
;||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||

;****************************************************************************************************
;PP_1 LIGHT_DEPTH GG
X = ALOG10(MG) & Y = ALOG10(O_G)
;****************************************************************************************************
S = STATS2(X,Y)
SLOPE = S.SLOPE
INT   = S.INT
GG_SLOPE = SLOPE & GG_INT = INT
GG_RESIDUAL =  DOUBLE(ABS(1.0-SLOPE)) + ABS(INT)
;||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
     ;||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
     RESIDUAL =  ABS(AA_RESIDUAL)  + ABS(BB_RESIDUAL) + ABS(CC_RESIDUAL) + ABS(DD_RESIDUAL) + ABS(EE_RESIDUAL) + ABS(FF_RESIDUAL) + ABS(GG_RESIDUAL)
   END;'SLOPE_INT'
    ;|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
      

   RESID_STAT EQ 'PROFILE_DIF' : BEGIN
     ;===>CONSTRUCT MARMAP & OPAL PROFILES
     RESIDUAL = 0.0D
     ;FFFFFFFFFFFFFFFFFFFFFFFFFFFFF
     FOR NTH = 0,NOF(MA)-1 DO BEGIN
       MAR_PROFILE = [MA[NTH],MB[NTH],MC[NTH],MD[NTH],ME[NTH],MF[NTH],MG[NTH]]
       OP_PROFILE = [O_A[NTH],O_B[NTH],O_C[NTH],O_D[NTH],O_E[NTH],O_F[NTH],O_G[NTH]]
       ;===> SUM OF THE SQUARED DIFFERENCE BETWEEN THE TWO PROFILES
       DIF = TOTAL((MAR_PROFILE - OP_PROFILE)^2,/NAN)
       RESIDUAL = RESIDUAL + DIF
     ENDFOR;FOR NTH = 0,NOF(MA)-1 DO BEGIN
     ;FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
 END;'PROFILE_DIF'
;||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
   
   
   ;*****************************************************************************************************
   RESID_STAT EQ 'RMSE_DIF' : BEGIN
   ;===>CONSTRUCT MARMAP & OPAL PROFILES
     RESIDUAL = 0.0D
     ;FFFFFFFFFFFFFFFFFFFFFFFFFFFFF
     FOR NTH = 0,NOF(MA)-1 DO BEGIN
       MAR_PROFILE = [MA[NTH],MB[NTH],MC[NTH],MD[NTH],ME[NTH],MF[NTH],MG[NTH]]
       OP_PROFILE = [O_A[NTH],O_B[NTH],O_C[NTH],O_D[NTH],O_E[NTH],O_F[NTH],O_G[NTH]]
       ;===> RMSE OF THE TWO PROFILES
         DIF = ABS(RMSE(MAR_PROFILE, OP_PROFILE))
       RESIDUAL = RESIDUAL + DIF
     ENDFOR;FOR NTH = 0,NOF(MA)-1 DO BEGIN
    ;FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
   END;'RMSE_DIF'
;||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
   ELSE: BEGIN
    MESSAGE,'ERROR: RESID_STAT NOT FOUND'
   END
 ENDCASE;CASE (1) OF
 ;||||||||||||||||||||

;===> PRINT THE RESIDUAL, AND COEFFICIENTS  AND RETURN CONTROL TO AMOEBA FOR THE NEXT ITERATION
PRINT_NCALLS:
;PRINT,NCALLS_,RESIDUAL,A
RETURN,RESIDUAL
 
;###############################################################################################
END; #####################  END OF PP_OPAL_OPTIMIZE_ FUNCTION ####################################################
;###############################################################################################


;#########################################################################################################################################################
 PRO PP_OPAL_OPTIMIZE,METHOD=METHOD,RESIDUAL_STAT=RESIDUAL_STAT,VERBOSE=VERBOSE
 
; PURPOSE:THIS PROGRAM USES AMOEBA TO FIND THE PARAMETERS GIVING THE BEST AGREEMENT BETWEEN OPAL AND MARMAP PP 
;         AT THE 7 STANDARD LIGHT-DEPTHS'



; INPUTS: NONE [THE DATABASE IS READ BELOW AND HAS ALL NEEDED INPUTS TO PP_OPAL
;         
;           
;KEYWORDS:
;         VERBOSE ......... PRINTS PROGRAM PROGRESS
;         RESIDUAL_STAT.... THE STATICAL METHOD USED IN THE MINIMIZATION BY AMOEBA 
;         METHOD........... VALID METHODS: IN THIS PROGRAM 
;                           THE METHOD RELATES TO THE INITIAL GUESS FOR THE 5 POLYNOMIAL REGRESSION COEFFICIENTS:
;         'QUANTUM_YIELD_CURVE'  RUNS PP_OPAL TO GET A STRUCTURE WITH A PROFILE OF QUANTUM_YIELD
;                               THEN A 4TH-ORDER POLYNOMIAL CURVE IS FITTED TO THE OPTICAL DENSITY VS PROFILE_QUANTUM_YIELD CURVE
;                               AND THE 5 POLYNOMIAL REGRESSION COEFFICIENTS ARE THE INITIAL GUESS FOR 'A' GIVEN TO AMOEBA
;                               
;        'MARMAP_MEDIAN_DQY_CURVE'  INITIAL GUESS=  A = [  0.00269,  0.00467,  0.00938, -0.00367,  0.00035] ;MARMAP ONLY COEFFICIENTS 443 NM
;        'ONDEQUE_DQY'              INITIAL GUESS=  A = [  0.00285,  0.00388,  0.00891, -0.00338,  0.00032] ; [BASED ON BOTH MARMAP AND ONDEQUE DATA MEDIANS]
;     
;         RESIDUAL_STAT............      VALID STATS: IN THIS PROGRAM
;         4_STATS:                       SUMS 4 STATICS FOR ALL 7 MARMAP AND OPAL LIGHT-DEPTHS
;         PROFILE_DIF        :           SQUARE OF THE DIFFERENCES IN THE (MARMAP-OPAL) PROFILES [NOT GOOD - GIVES NEGATIVE DQYS]  
;         RMSE_DIF           :           RMSE BETWEEN THE (MARMAP-OPAL) PROFILES                 [NOT GOOD - GIVES NEGATIVE DQYS]           
;                      

;_______________________________________________________________________________________________                                   
;  OUTPUTS:
;          1) CSV FILE WITH RESULTS FROM THE OPTIMIZATION 
;          2) PNG IMAGE FILE SHOWING OD VS. DQY_443
;         
;_______________________________________________________________________________________________                           
;         
;          
; NOTES:
;      THIS ROUTINE ASSUMES IDL VERSION 8.5,8.6, OR 8.7
;
; MODIFICATION HISTORY:
;  WRITTEN BY J.O'REILLY MAY 30,2019
;  JUN 03, 2019 - JEOR: FTOL = DOUBLE(1E-8),SCALE= 0.0001D,NCALLS = 621 
;  JUN 05, 2019 - JEOR: ADDED FTOL TO OUTPUT STRUCT 
;  JUN 08, 2019 - JEOR: ADDED STAT TO OUTPUT STRUCT
;  JUN 10, 2019 - JEOR: ADDED CASE BLOCKS FOR SEVERAL STAT METHODS  AND ADDED STAT & METHOD TO OUTPUT PNG NAME
;  JUN 11, 2019 - JEOR: ADDED P0 [INITIAL COEFFICIENTS FOR AMOEBA] TO OUTPUT STRUCTURE
;  JUN 12, 2019 - JEOR: TRIED METHOD LAST_A [TO SEE IF RESIDUAL COULD BE FURTHER LOWERED BY USING THE LAST COEFFICIENTS FROM AMOEBA AS THE STARTING 
;                       P0 COEFFICIENTS IN A SECOND RUN THROUGH AMOEBA]  [NO IMPROVEMENT IN SLOPES,SO DELETED THIS METHOD]
;  JUN 20, 2019 - JEOR: REVISED CONSTRAINING SLOPES AND INTERCEPTS
;  JUL 05, 2019 - JEOR: TRIED USING STATS_Y2X IN SLOPE_INT [NO IMPROVEMENT IN AGREEMENT BETWEEN MARMAP VS OPAL PROFILES
;  JUL 13, 2019 - JEOR: NO FURTHER IMPROVEMENTS IN LOWERING RESIDUALS AND AGREEMENT BETWEEN MARMAP AND OPAL PROFILES
;  JUL 14, 2019 - JEOR: NOW MUST SPECIFY VERSION [2 OR 3] AND PROVIDE COEFFS TO PP_OPAL
;  JUL 29, 2019 - JEOR: ADDED  RESIDUAL_STAT EQ '4_STATS_Y2X'
;  AUG 03, 2019 - JEOR: ADDED  RESIDUAL_STAT EQ '3_STATS'
;  SEP 06, 2019 - JEOR: ADDED  AA_SLOPE,AA_INT,BB_SLOPE,BB_INT,CC_SLOPE,CC_INT ETC TO COMMON AND TO OUTPUT STRUCT
;  SEP 09, 2019 - JEOR: ADDED ITERATION SECTION [5 NESTED LOOPS TO SOLVE OPAL = MARMAP PP]
;  SEP 21, 2019 - JEOR: AMOEBA CAN NOT HANDLE OPTIMIZING 14 UNKNOWNS [7 SLOPES + 7 INTERCEPTS]
;                         I FOUND THAT I COULD NOT GET A RESIDUAL NEAR ZERO BECAUSE ONE SLOPE WAS CLOSE TO 1 [SAY AA LIGHT-DEPTH 
;                         AT THE EXPENSE OF OTHERS , SAY GG, WHICH HAD A SLOPE FAR FROM 1.0
;                         THE NOW TRYING THE ITERATION METHOD [LOOPING]
;  SEP 22, 2019 - JEOR:  Added RESID_STAT EQ 'RMSE_ALL_7' [THIS MAY BE A GOOD WAY OF DEALING WITH TOO MANY SLOPES AND INTERCEPTS]?
;                        NO, RMSE_ALL_7 GENERATES A CURVE WITH NEGATIVE DQYS!
;  SEP 23, 2019 - JEOR:  ADDED A CSV LOG FILE TO RECORD PROGRESS DURING LOOPING
;  SEP 25, 2019 - JEOR & KJWH: FIXED BUG INSIDE LOOP WHEN FIND GOOD SLOPES AND INTERCEPTS [THEN GOTO,WRITE_STRUCT 
;  SEP 26, 2019 - JEOR: FIND BEST COEFFS FROM LAST RUN AND USE THESE IN NEXT RUN
;  SEP 28, 2019 - JEOR: FIXED MATH ERROR IN RESID EQ 'JUST_STATS'TO : AA_RESIDUAL =  DOUBLE(ABS(1.0-SLOPE)) + ABS(INT) ; FOR AA THROUGH FF
;                       REMOVED CASE RESID_STAT = '4_STATS' AND CASE 'JUST_STATS' [SAME AS SLOPE_INT]
;  SEP 30, 2019 - KJWH: Using PLUN (PRINT plus PRINTF) to write out the looping residual information instead of CSV_WRITE   
;                       Also recording the minimum and maximum slopes in the output               
;###########################################################################################################################

;***************************  
ROUTINE = 'PP_OPAL_OPTIMIZE'
;***************************   COEFFS
PATH = !S.PROJECTS + 'OPAL' + PATH_SEP()
DIR = FILE_FOLDERS(PATH,FOLDERS = ['DATA','FIGS','SAV'])
PRINT,'THIS PROGRAM RUNS PP_OPAL_OPTIMIZE TO FIND THE PARAMETERS GIVING THE BEST AGREEMENT BETWEEN OPAL AND MARMAP AT THE 7 STANDARD LIGHT-DEPTHS'
SAV = PATH + 'MARMAP_PP_DATA_PROFILE.SAV'
DB = STRUCT_READ(SAV)
IF NONE(DB) THEN MESSAGE,'ERROR: DB IS REQUIRED'


COMMON FUNC_PP,NCALLS_,VERBOSE_,VERSION_,DEPTH,METHOD_,OPTICAL_DENSITY,DIR_,S_MA,MA,MB,MC,MD,ME,MF,MG, O_A, O_B, O_C, O_D, O_E, O_F, O_G,RESIDUAL,RESID_STAT,$
       AA_SLOPE,AA_INT,BB_SLOPE,BB_INT,CC_SLOPE,CC_INT,DD_SLOPE,DD_INT,EE_SLOPE,EE_INT,FF_SLOPE,FF_INT,GG_SLOPE,GG_INT  
;#######################################################################
;===> PROGRAM DEFAULTS:
;STOP
;IF NONE(METHOD) THEN METHOD = 'MARMAP_MEDIANS'
IF NONE(METHOD) THEN METHOD = 'ITERATION'
METHOD_ = METHOD ; PASSED THROUH COMMON
RESIDUAL_STAT = 'SLOPE_INT'     ; 
;===> FIT A POLY TO THE ODS VS I_DQY
DEG = 4  ; 4TH -ORDER POLYVERSION   ; DQY
;DEG = 7  ; 7TH -ORDER POLYVERSION   ; DID NOT CONVERGE
VERSION = 2
VERSION_ = VERSION; PASSED THROUH COMMON
VERBOSE = 1
VERBOSE_ = VERBOSE


;###############################################################################################################
; USE MEDIAN ODS AND MEDIAN DQYS FROM MARMAP ['TABLE_MARMAP_OD_DQY.CSV'] PRINT,
; THESE MEDIANS ARE THE BEST POSSIBLE STARTING COEFFS
OD= [0.000000,0.371064,0.776529,1.38629,2.30258,3.50656,4.60517]
DQY = [0.00257832,0.00587228,0.0101052,0.0187703,0.0284102,0.0298008,0.0242385]
;===> 200 LAYERS IS DEFAULT IN OPAL
LAYERS = 200.0
ODS = INTERPOL(INTERVAL([0.0,MAX(OD)],1.0),LAYERS)
I_DQY = INTERPOL(DQY,OD,ODS)

COEFFS = REFORM(POLY_FIT(ODS,I_DQY,DEG)) ;  0.00270196   0.00589045   0.00768804  -0.00312135  0.000303507
;===> SHOW THAT THE CURVE FROM 4TH-ORDER POLY IS A GOOD ESTIMATER OF THE ACTUAL MEDIAN VALUES:
PT, ODS,I_DQY
PT,ODS,POLY(ODS,COEFFS),COLOR = 'RED',/OVERPLOT,OBJ=OBJ,XTITLE = 'OPTICAL DENSITY',YTITLE = 'DQY_443',TITLE = 'MARMAP MEDIANS'
WAIT,2
OBJ.CLOSE

DEPTH = 'M3'; WRITTEN TO THE OUTPUT STRUCTURE TO INDICATE PP VALUES ARE BY DEPTH [ NOT BY M2]
;===> PARAMETERS FOR AMOEBA [ NOT USED FOR THE ITERATION METHOD]
FTOL = DOUBLE(1E-8); [SEE IDL HELP ON AMOEBA]
NCALLS_ = 0L ;       [SEE IDL HELP ON AMOEBA]
SCALE= 0.0001D ;     [SEE IDL HELP ON AMOEBA] 
NOTES = 'USING NEW SLOPE_INT'
DIR_ = DIR
GONE,O_A & GONE, O_B & GONE, O_C & GONE, O_D & GONE, O_E & GONE, O_F & GONE, O_G
;===> EDIT DIR_OUT AS NEEDED:
DIR_OUT =  DIR.SAV
IF NONE(CSV_FILE) THEN CSV_FILE =  DIR_OUT +ROUTINE + '.CSV'
GONE,A
;|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
;

;===> GET SUBS FOR EACH OF THE MARMAP STANDARD 7 LIGHT-DEPTHS
A_SUBS = WHERE(DB.LIGHT_CODE EQ 'AA',COUNT_A)
B_SUBS = WHERE(DB.LIGHT_CODE EQ 'BB',COUNT_B)
C_SUBS = WHERE(DB.LIGHT_CODE EQ 'CC',COUNT_C)
D_SUBS = WHERE(DB.LIGHT_CODE EQ 'DD',COUNT_D)
E_SUBS = WHERE(DB.LIGHT_CODE EQ 'EE',COUNT_E)
F_SUBS = WHERE(DB.LIGHT_CODE EQ 'FF',COUNT_F)
G_SUBS = WHERE(DB.LIGHT_CODE EQ 'GG',COUNT_G)
IF SAME([COUNT_A,COUNT_B,COUNT_C,COUNT_D,COUNT_E,COUNT_F,COUNT_G]) EQ 0 THEN MESSAGE,'ERROR: AA THROUGH FF COUNTS MUST BE THE SAME'

;===> EXTRACT SUBSETS FROM DB FOR ALL 7 LIGHT-DEPTHS
S_MA = DB(A_SUBS)
S_MB = DB(B_SUBS)
S_MC = DB(C_SUBS)
S_MD = DB(D_SUBS)
S_ME = DB(E_SUBS)
S_MF = DB(F_SUBS)
S_MG = DB(G_SUBS)

;===> EXTRACT PP_TOT FROM ALL 7 LIGHT-DEPTHS [AND PASS TO PP_OPAL_OPTIMIZE_ VIA COMMON]
MA = S_MA.PP_TOT
MB = S_MB.PP_TOT
MC = S_MC.PP_TOT
MD = S_MD.PP_TOT
ME = S_ME.PP_TOT
MF = S_MF.PP_TOT
MG = S_MG.PP_TOT
;===> CHANGE ANY ZEROS TO MISSINGS(0.0)  
OK = WHERE(MA EQ 0,COUNT ) & IF COUNT GE 1 THEN MA[OK] = MISSINGS(0.0)
OK = WHERE(MB EQ 0,COUNT ) & IF COUNT GE 1 THEN MB[OK] = MISSINGS(0.0)
OK = WHERE(MC EQ 0,COUNT ) & IF COUNT GE 1 THEN MC[OK] = MISSINGS(0.0)
OK = WHERE(MD EQ 0,COUNT ) & IF COUNT GE 1 THEN MD[OK] = MISSINGS(0.0)
OK = WHERE(ME EQ 0,COUNT ) & IF COUNT GE 1 THEN ME[OK] = MISSINGS(0.0)
OK = WHERE(MF EQ 0,COUNT ) & IF COUNT GE 1 THEN MF[OK] = MISSINGS(0.0)
OK = WHERE(MG EQ 0,COUNT ) & IF COUNT GE 1 THEN MG[OK] = MISSINGS(0.0)

 

RESIDUAL_STAT ='SLOPE_INT'
RESID_STAT = RESIDUAL_STAT

PRINT,'USING VERSION  ' + STRTRIM(VERSION) 
PRINT,'USING METHOD  ' + METHOD 
PRINT,'USING RESIDUAL_STAT  ' + RESIDUAL_STAT 
PRINT,'NOTES : ',NOTES
PRINT,'DEGREE = ', DEG
WAIT,1
IF METHOD EQ 'ITERATION' THEN GOTO,ITERATION  ; [DO NOT USE AMOEBA]

;##########################################################################################  DEG
; GIVE AMOEBA STARTING COEFFICIENTS [A= OPTIMAL_COEFFICIENTS]  
;##########################################################################################
A= AMOEBA(FTOL,FUNCTION_NAME='PP_OPAL_OPTIMIZE_',FUNCTION_VAL=F_VAL,NCALLS=NCALLS,P0=COEFFS,SCALE=SCALE,NMAX = 5000)
IF N_ELEMENTS(A) EQ 1 THEN  MESSAGE,'AMOEBA FAILED TO CONVERGE'
;|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||


PRINT,' POLYNOMIAL COEFFICIENTS A  =   ',A
GOTO,WRITE_STRUCT
;###################################################################################################################
;ITERATION METHOD TO FIND COEFFICIENTS FOR DQY POLYNOMIAL WHICH GIVE GOOD AGREEMENT BETWEEN OPAL AND MARMAP PP
ITERATION:
;STOP
;===> GET THE LOWEST RESIDUAL [AND BEST COEFFS] FROM THR LOG OF OUTPUT FROM THE LAST RUN
  LOG = DIR_OUT +ROUTINE + '-LOG.CSV'
  IF EXISTS(LOG) THEN BEGIN
    D = CSV_READ(LOG)
    P,MIN(D.RESIDUAL,SUB)
    COEFFS = D(SUB).COEFFS
    COEFFS =FLOAT((STR_SEP(COEFFS,';')))
    P,COEFFS
    STOP
  ENDIF




;STOP; KIM, STEP THROUGH TO UNDERSTAND MY RANGES AND STEPS FOR EACH OF THE 5 POLYNOMIAL COEFFICIENTS 
    ;[THESE ARE WHAT WE NEED TO FIGURE OUT TO GET 7 SLOPES BETWEEN 0.99-1.01 AND 7 INTERCEPTS BETWEEN -0.01 AND 0.01]
;===> THIS FIRST SET OF STARTING COEFFS FOR THE ITERATION METHOD

  BRACK = 500 ; PERCENT OF THE COEFFICIENT TO SUBTRACT AND ADD,[USING BRACKET] TO GET THE RANGE FOR THE LOOPING FOR EACH COEFFICIENT
;  KIM I THINK WE HAVE NOT SEARCHED A WIDE ENOUGH RANGE OF COEFFS THBREFORE BRACK = 500  ~ FACTOR OF 1/5TH TO 5 

  RANGE0 = BRACKET(COEFFLS[0],BRACK,/PCT)
  RANGE1 = BRACKET(COEFFLS[1],BRACK,/PCT)
  RANGE2 = BRACKET(COEFFLS(2),BRACK,/PCT)
  RANGE3 = BRACKET(COEFFLS(3),BRACK,/PCT)
  RANGE4 = BRACKET(COEFFLS(4),BRACK,/PCT)
  PRINT,RANGE0[0],COEFFLS[0], RANGE0[1]; 0.00267494   0.00270196   0.00272897
  PRINT,RANGE1[0],COEFFLS[1], RANGE1[1]; 0.00583155   0.00589045   0.00594936
  PRINT,RANGE2[0],COEFFLS(2), RANGE2[1];00.00761116   0.00768804   0.00776492
  PRINT,RANGE3[0],COEFFLS(3), RANGE3[1];-0.00315257  -0.00312135  -0.00309014
  PRINT,RANGE4[0],COEFFLS(4), RANGE4[1];0.000300472  0.000303507  0.000306542

  STEP = 0.001 ; INCREMENT MULTIPLYER STEP IN EACH LOOP 
  
  STEP0 = ABS(COEFFLS[0]) * STEP
  STEP1 = ABS(COEFFLS[1]) * STEP
  STEP2 = ABS(COEFFLS(2)) * STEP
  STEP3 = ABS(COEFFLS(3)) * STEP
  STEP4 = ABS(COEFFLS(4)) * STEP
  PRINT,' THE NUMBER OF INCREMENTS FOR EACH LOOP'
  PRINT,NOF(INTERVAL(RANGE0,STEP0))
  PRINT,NOF(INTERVAL(RANGE1,STEP1))
  PRINT,NOF(INTERVAL(RANGE2,STEP2))
  PRINT,NOF(INTERVAL(RANGE3,STEP3))
  PRINT,NOF(INTERVAL(RANGE4,STEP4))
;  STOP
  
  FTOL = 0.05
  ;===> RANGE FOR ACCEPTABLE SLOPES AND INTERCEPTS
  RANGE_SLOPE = BRACKET(1.0,FTOL)
  RANGE_INT = BRACKET(0.0,FTOL)
  LOW_SLOPE = RANGE_SLOPE[0] & UPP_SLOPE = RANGE_SLOPE[1]
  LOW_INT = RANGE_INT[0] & UPP_INT = RANGE_INT[1]
  PRINT,'SLOPE WILL RANGE BETWEEN',RANGE_SLOPE
  PRINT,'INTERCEPT WILL RANGE BETWEEN ',RANGE_INT
;  STOP
  
  RESIDUAL = 999.0; MAKE LARGE SO DO NOT FIND THIS AS THE MINIMUM IN THE NEXT RUN
;===> MAKE A CSV FILE TO RECORD THE PROGRESS DURING LOOPING
  LOG = DIR_OUT +ROUTINE + '-LOG.CSV'
;LOOP ON THE 5 COEFFICIENTS
;FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
  LOGFILE = DIR_OUT + ROUTINE + '-FTOL_' + ROUNDS(FTOL,3) + '.CSV'
  OPENW, LUN, LOGFILE, /GET_LUN, WIDTH=180 ;  ===> Open log file
  PLUN, LUN, STRJOIN(['NCALLS','RESIDUAL','MIN_SLOPE','MAX_SLOPE','L0','L1','L2','L3','L4'],','),0

  FOR L0 = RANGE0[0],RANGE0[1],STEP0 DO BEGIN
    FOR L1 = RANGE1[0],RANGE1[1],STEP1 DO BEGIN ; L1 EFFECTS THE LARGEST CHANGE 
      FOR L2 = RANGE2[0],RANGE2[1],STEP2 DO BEGIN
        FOR L3 = RANGE3[0],RANGE3[1],STEP3 DO BEGIN
          FOR L4 = RANGE4[0],RANGE4[1],STEP4 DO BEGIN
            
            A = [L0,L1,L2,L3,L4]
            
            RESID = PP_OPAL_OPTIMIZE_(A)
            MIN_SLOPE = MIN([AA_SLOPE,BB_SLOPE,CC_SLOPE,DD_SLOPE,EE_SLOPE,FF_SLOPE,GG_SLOPE])
            MAX_SLOPE = MAX([AA_SLOPE,BB_SLOPE,CC_SLOPE,DD_SLOPE,EE_SLOPE,FF_SLOPE,GG_SLOPE])
            PLUN, LUN, STRJOIN([NCALLS_,RESID,MIN_SLOPE,MAX_SLOPE,A],','),0 
            ;===> CHECK ON SLOPES AND INTERCEPTS FOR 7 LIGHT-DEPTHS
            IF AA_SLOPE GT LOW_SLOPE AND AA_SLOPE LT UPP_SLOPE AND AA_INT GT LOW_INT AND AA_INT LT UPP_INT AND $
               BB_SLOPE GT LOW_SLOPE AND BB_SLOPE LT UPP_SLOPE AND BB_INT GT LOW_INT AND BB_INT LT UPP_INT AND $
               CC_SLOPE GT LOW_SLOPE AND CC_SLOPE LT UPP_SLOPE AND CC_INT GT LOW_INT AND CC_INT LT UPP_INT AND $
               DD_SLOPE GT LOW_SLOPE AND DD_SLOPE LT UPP_SLOPE AND DD_INT GT LOW_INT AND DD_INT LT UPP_INT AND $
               EE_SLOPE GT LOW_SLOPE AND EE_SLOPE LT UPP_SLOPE AND EE_INT GT LOW_INT AND EE_INT LT UPP_INT AND $
               FF_SLOPE GT LOW_SLOPE AND FF_SLOPE LT UPP_SLOPE AND FF_INT GT LOW_INT AND FF_INT LT UPP_INT AND $
               GG_SLOPE GT LOW_SLOPE AND GG_SLOPE LT UPP_SLOPE AND GG_INT GT LOW_INT AND GG_INT LT UPP_INT  $
               THEN GOTO,WRITE_STRUCT
             ENDFOR; FOR L0 = RANGE0(0),RANGE0(1),STEP0 DO BEGIN
           ENDFOR; FOR L1 = RANGE1(0),RANGE1(1),STEP1 DO BEGIN ; L1 EFFECTS LARGEST CHANGE 
         ENDFOR; L2 = RANGE2(0),RANGE2(1),STEP2 DO BEGIN
       ENDFOR; L3 = RANGE3(0),RANGE3(1),STEP3 DO BEGIN
     ENDFOR; L4 = RANGE4(0),RANGE4(1),STEP4 DO BEGIN
;FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
;END OF ITERATION LOOPING
;|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
 FLUSH, LUN & CLOSE, LUN & FREE_LUN, LUN
 GOTO,DONE ; LOOPING IS DONE AND DID NOT SOLVE FOR SLOPES AND INTERCEPTS

  WRITE_STRUCT:
  
  FLUSH, LUN & CLOSE, LUN & FREE_LUN, LUN
  
  N = NOF(MA)
  IF NONE(NOTES) THEN NOTES = ''
;####################################################################################################  
  STRUCT = CREATE_STRUCT('ROUTINE',ROUTINE,'VERSION',VERSION,$
          'DEPTH',DEPTH,$
          'METHOD',METHOD,$
          'RESIDUAL_STAT',RESIDUAL_STAT,$
          'P0',STRJOIN(A,';'),$
          'FTOL',STRTRIM(FTOL,2),$
          'SCALE',STRTRIM(SCALE,2),$
          'RESIDUAL',STRTRIM(RESIDUAL,2),$
          'NCALLS',NCALLS_,$
          'DATE',DATE_FORMAT(DATE_NOW()),$
          'N',STRING(N,FORMAT = '(I5)'),$
          'DEG',DEG,$
          'COEFFICIENTS',STRJOIN(A,';'),$
          'AA_SLOPE',AA_SLOPE,'AA_INT',AA_INT, $
          'BB_SLOPE',BB_SLOPE,'BB_INT',BB_INT, $
          'CC_SLOPE',CC_SLOPE,'CC_INT',CC_INT, $
          'DD_SLOPE',DD_SLOPE,'DD_INT',DD_INT, $
          'EE_SLOPE',EE_SLOPE,'EE_INT',EE_INT, $
          'FF_SLOPE',FF_SLOPE,'FF_INT',FF_INT, $
          'GG_SLOPE',GG_SLOPE,'GG_INT',GG_INT, $
          'NOTES',NOTES)
;||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||

;################################################################################################
;===> WRITE STRUCT TO A CSV_FILE
;################################################################################################
APPEND =  FILE_TEST(CSV_FILE) ;ADD TO CSV_FILE IF ALREADY EXISTS
CSV_WRITE,CSV_FILE,STRUCT,APPEND = APPEND
;|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||


;################################################################################################
;===> MAKE A PNG OF THE NEW DQY VS OD
PLT = PLOT(INTERVAL([0,4.60517],.01),OD_2DQY(INTERVAL([0,4.60517],.01),COEFFS = A),$
  XTICKV = [0,1,2,3,4,5],XTITLE = 'OD',YTITLE = 'DQY!D443!N',COLOR = 'RED',THICK = 3,TITLE = 'OPTIMAL_DQY_COEFFICIENTS')& PLT_GRIDS,PLT;
  TXT = STRJOIN(ROUNDS(A,5,/SIG),';') + '     SCALE =  ' + ROUNDS(SCALE,5,/SIG)
  T = TEXT(0.05,0.01,/NORMAL,TXT,TARGET = PLT)
FILE = DIR.FIGS +ROUTINE +'-' + METHOD + '-' + RESIDUAL_STAT + '-' + ROUNDS(DEG)+ '.PNG'
PLT.SAVE,FILE
PLT.CLOSE
;STOP
;|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
;################################################################################################
;===> PLOT MARMAP VS OPAL RESULTS FOR EACH LIGHT-DEPTH
;################################################################################################

;||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||

DONE:


END; #####################  END OF ROUTINE ################################
