; $ID:	PP_OPAL.PRO,	2020-07-08-15,	USER-KJWH	$

;###############################################################################  EXAMPLES  VERSION  JEOR  DQY_443
	FUNCTION PP_OPAL, $
;*** REQUIRED INPUT ***(ONE VALUE OR ARRAY: SST, PAR,& KX MUST MATCH SIZE OF CHL)
	CHL				=	CHL, 			$; REMOTELY-SENSED CHLOROPHLL CONCENTRATION (MG M-3)
	SST 			= SST, 			$; SEA SURFACE TEMPERATURE (DEGREES C)
	PAR 			= PAR,			$; PAR (EINSTEIN M-2 D-1)
	KX        = KX,       $; ABSORPTION BY 'OTHER: I.E. CDOM'

;*** OPTIONAL INPUT *** (MUST MATCH SIZE OF CHL ARRAY)
	BOTTOM_DEPTH 	= BOTTOM_DEPTH, $; BOTTOM DEPTH (M)
	 
;*** OPAL VERSION # *** (1 OR 2)
	VERSION=VERSION,$ 
	 
;***	INPUT REQUIRED IF KEY DO_NEC_PROFILES  
  DO_NEC_PROFILES = DO_NEC_PROFILES,LON=LON,LAT=LAT,DOY=DOY,NUM_NEC=NUM_NEC,$
	   
;	*** INPUTS TO USE INSTEAD OF DEFAULTS 
  KW= KW,PHIMAX=PHIMAX, EK = EK ,LAYERS=LAYERS,EUFRACT= EUFRACT,Z_RES=Z_RES,WL = WL,$
    
; ***  USE KX_PROFILE_SEABASS TO GET A STANDARD KX PROFILE [INSTED OF A VERTICALLY CONSTANT [KX = 0.02] 
  DO_KX_PROFILE  = DO_KX_PROFILE,$
   

; *** TO PRINT OUT VERSION INFO  
  VERBOSE=VERBOSE,$ 

;	*** OPTIONAL OUTPUT ***
  STRUCT=STRUCT,$ 
  ERROR	=	ERROR,$
  PROFILES = PROFILES,$
  INIT=INIT,$  ; INITIALIZE SEQUENCE VARIABLE SEQ
  CLOSE = CLOSE,$
  PCT_LIGHT = PCT_LIGHT,$ ;[OUTPUTS PP AT THE INPUT PERCENT-LIGHTS]
  QE_MODEL= QE_MODEL,$
  COEFFS=COEFFS,$ ; [USED DURING TESTING AND OPTIMIZATION OF VERSION 2 [DQY]
  _EXTRA=_EXTRA	; TO BE PASSED TO THE OUTPUT STRUCTURE

; NAME:
;       PP_OPAL
;
; PURPOSE:  CALCULATE PRIMARY PRODUCTIVITY (GC M-2 D-1).USING THE OPAL MODEL (OCEAN PRODUCTION FROM ABSORPTION OF LIGHT).
;  			    EQUATION FOR V1:  PROFILE_PP = 12*Z_THICK*PHIMAX*(TANH(EK/PROFILE_PAR))*KC_P*PROFILE_CHL*PROFILE_PAR;

;
; CATEGORY: PRIMARY PRODUCTIVITY
;
;
; KEYWORDS:
;         CHL ............. REMOTELY-SENSED CHLOROPHLL CONCENTRATION (MG M-3)
;         SST ............. SEA SURFACE TEMPERATURE (DEGREES C)
;         PAR ............. PAR (EINSTEIN M-2 D-1)
;         KX .............. ABSORPTION BY 'OTHER: I.E. CDOM' (PER METER]IF DO NOT WANT TO USE THE DEFAULT:0.02 (M-1)
;         BOTTOM_DEPTH .... BOTTOM DEPTH (METERS)
;         
;         LON ............. LONGITUDE [DEGREES] PASSED TO CHL_PROFILES_GET IF KEY(DO_NEC_PROFILES)
;         LAT ............. LATITUDE  [DEGREES] PASSED TO CHL_PROFILES_GET IF KEY(DO_NEC_PROFILES)
;         NUM_NEC ......... NUMBER OF 'CLOSEST' NEC CHL PROFILES TO FIND [DEFAULT = 5] PASSED TO CHL_PROFILES_GET IF KEY(DO_NEC_PROFILES)
;         KW .............. ABSORPTION BY WATER IF DO NOT WANT TO USE THE DEFAULT: KW=0.04 (M-1)
;         PHIMAX .......... MAXIMUM QUANTUM EFFICIENCY IF DO NOT WANT TO USE THE DEFAULT: PHIMAX=0.02
;         EK .............. HYPERBOLIC TANGENT (EINST M-2D-1)IF DO NOT WANT TO USE THE DEFAULT: EK = 17.0D
;         LAYERS .......... NUMBER OF LAYERS IN THE EUPHOTIC ZONE IF DO NOT WANT TO USE THE DEFAULT : LAYERS = 200
;         EUFRACT ......... EUPHOTIC FRACTION [DEFAULT IS 1 %]IF DO NOT WANT TO USE THE DEFAULT :EUFRACT = 0.01
;         DO_NEC_PROFILES . USE CHL_PROFILES_GET INSTEAD OF CHL_PROFILE_WOZNIAK
;         DO_KX_PROFILE ... USE KX_PROFILE_SEABASS TO GET A STANDARD KX PROFILE [INSTED OF A VERTICALLY CONSTANT [KX = 0.02] 
;         Z_RES ........... VERTICAL RESOLUTION [Z_RES = MAX_DEPTH/(LAYERS)]   
;         WL .............. WAVELENGTH PASSED TO KCHL =GET_APHI(WL,CHL = PROFILE_CHL) [WL =440 DEFAULT] 
;         VERBOSE ......... PRINT PROGRAM PROGRESS
;         VERSION ......... INPUT REQUEST FOR THE VERSION: 1,2 OR 3
;                           1 = ORIGINAL MARRA HO & TREES 2003; 
;                           2 = USE DAILY QUANTUM YIELD [DQY]
;         STRUCT .......... IF ONLY ONE SET OF INPUTS THEN RETURN A STRUCTURE WITH INPUTS AND VERTICAL OUTPUT ARRAYS
;         ERROR ........... ANY ERRORS ARE RETURNED AS A STRING IN THE KEY ERROR
;         PROFILES ........ PROFILES ARE WRITTEN TO THE PP_FILE USING WRITEU
;         INIT ............ INITIALIZE SEQUENCE VARIABLE [SEQ] HELD IN COMMON MEMORY   
;         CLOSE............ CLOSE THE PP_FILE
;         PCT_LIGHT ....... INPUT ARRAY OF PERCENT OF SURFACE LIGHT [E.G.MARMAP 100,69,46,25,10,3,1%] 
;                           RETURNS PP AT THOSE LIGHT-DEPTHS
;         QE_MODEL ........ QUANTUM_EFFICIENCY MODEL-FOR IRRADIANCE DEPENDENCE [EITHER TANH_MODEL OR ....]
;         COEFFS .......... COEFFICIENTS USED FOR SOLVING-OPTIMIZING OPAL USING AMOEBA [PASSED TO OD_2DQY]
;         _EXTRA .......... ANY INFO TO BE PASSED TO THE OUTPUT STRUCTURE
;            
;            
;            
;            
; OUTPUTS: INTEGRAL DAILY PRIMARY PRODUCTIVITY (PPD: GRAMS CARBON PER METER-SQUARE PER DAY)
; 
; EXAMPLES:
;       PRINT,PP_OPAL(CHL = 1, SST = 15., PAR=55., KX = 0.02,EK = 17,VERSION = 1,STRUCT = S);= 1.0544443
;       PRINT,PP_OPAL(CHL = 1, SST = 15., PAR=55., KX = 0.02,VERSION = 2,STRUCT=S)& ;= 1.0572485
;       PRINT,PP_OPAL(CHL = 1, SST = 15., PAR=55., KX = 0.02,EK = 17,VERSION = 2,STRUCT=S)& PLT_PP,S,/PNG
; 
; 
; CITATION:
;        MARRA, J., C.HO AND C.C. TREES. 2003.
;       "AN ALTERNATIVE ALGORITHM FOR THE CALCULATION OF PRIMARY PRODUCTIVITY
;       FROM REMOTE SENSING DATA. LDEO TECHNICAL REPORT # LDEO-2003-1."
;
;
; MODIFICATION HISTORY:
;				RECODED FROM MATLAB CODE (APPENDIX 1) RECEIVED FROM JOHN MARRA
;       JAN 13, 2004 WRITTEN BY:  J.E.O'REILLY,  AND SUBSEQUENTLY MODIFIED AS FOLLOWS:
;       APR     2007,JEOR:
;               NOW USES WOZNIAK ET AL. 2003 TO GENERATE CHL PROFILES;
;               KCHL IS COMPUTED USING BRICAUD, MOREL, BABIN, ALLALI & CLAUSTRE, 1998;
;               PHIMAX [0.02] FROM MARRA TREES O'REILLY 2007;
;               NOW ALLOWS FOR INPUT OF VARYING KX
;               KX AT 443NM IS DERIVED FROM KAHRU & MITCHEL 2001:
;               A_CDOM_300 = A_CDOM_300_KM(LWN443,LWN510)
;               SPECTRAL SLOPE OF SPECTRAL_S = 0.021 AND A_CDOM_443
;               ACDOM_443  = A_CDOM_300*EXP(-0.021*(443-300))
;
;       MAR 15,2014,JEOR:
;       THIS VERSION WAS COPIED FROM: APRIL 01 2007 
;       SWORDFISH-PP_OPAL-20070404190736[KIM HYDE]
;       THE MODIFICATION HISTORY FROM LATER VERSIONS WAS ALSO COPIED
;       NOTE: THIS VERSION AND THE APRIL 01 2007 VERSION 
;       DO NOT MAKE A ZEU_TABLE [TOO MUCH TIME] AND DO NOT INITIALIZE THIS TABLE INSTEAD:
;       THE DEPTH OF EUPHOTIC LAYER IS CALCULATED USING MOREL'S CASE I MODEL
;       MOREL AND BERTHON (1989) PAGE 1547, EQUATIONS 1A, 1B
;       Z_EU  =  (C_TOT GT 10.0)* 568.2*C_TOT^(-0.746) $
;           + (C_TOT LE 10.0)* 200.*C_TOT^(-0.293)

;       REPLACED CHL_SAT WITH CHL        
;       REMOVED KEYWORD INITIALIZE
;       REPLACED  KEYWORDS USED FOR OUTPUTS WITH  KEYWORD STRUCT
;       ALL PREVIOUS OPTIONAL OUTPUTS ALONG WITH INPUTS, AND KEY PARAMETERS
;       ARE NOW BUNDLED INTO A STRUCTURE, ACCESSED BY THE KEYWORD STRUCT;       
;       REFORMATTED & REVISED PROCEEDURE DOCUMENTATION
;       ADDED VERSION DATE 
;       ADDED KEYWORDS KW,PHIMAX,EK : INPUTS TO USE INSTEAD OF DEFAULTS
;       MAR 16,2014,JEOR:REVISED EK FROM 15.0 TO 17.0 TO OBTAIN BETTER AGREEMENT WITH VGPM2A AND MARMAP MEAN PPD
;       APR 11,2014,JEOR:
;                        ADDED KEYWORD N_LAYERS ,NOW USING NONE AND ANY FUNCTIONS
;                        INCREASED DEFAULT N_LAYERS FROM 100 TO 200 BASED ON GRAPH OF N_LAYERS VS PPD 
;                        [ASYMPTOTIC LEVEL PORTION OF RESPONSE STARTS ~200 LAYERS]
;      MAY 19,2014,JEOR, ADDED KEYWORD EUFRACT
;      JUN 23,2014,JEOR  ADDED KEYWORD VERBOSE
;      AUG 14,2014,JEOR, WRITE PROFILES TO A FILE: ADDED KEY _EXTRA TO HOLD ALL VALUES
;                        TO BE WRITTEN TO THE PROFILES  FILE USING WRITEU
;      AUG 20,2014,JEOR  REPLACED KEYWORD FILE WITH SAV 
;      SEP,11,2014,JEOR, MODIFIED DEFAULT OUTPUT FILE NAME WITH DATE STAMP IN NAME
;      SEP,14,2014,JEOR, SAV FILE NAMED SO VALID_FORMS EXTRACTS THE NUMBER OF LAYERS FROM THE FILE NAME
;      SEP 15,2014,JEOR, REPLACED N_LAYERS WITH LAYERS FOR VALID_FORMS TO WORK
;      OCT 1,2014,JEOR,  ADDED KEY NEW_PROFILES;CHANGED WZ TO CHL_Z
;                        IF CHL_Z EQ !NULL THEN CHL_Z = CHL_PROFILE_WOZNIAK(ACHL, Z_RES=Z_RES, MAX_DEPTH=MAX_DEPTH)
;      MAR 17,2015, KJWH:CHANGED NEW_PROFILES TO DO_NEC_PROFILES SINCE THE PROFILE DATA ARE MAINLY FOR THE NEC MAP PROJECTION
;                        FIXED LON/LAT INPUT ERROR IN CALL TO CHL_PROFILES_GET - NOW LON[NTH] & LAT[NTH]
;      JUL 17,2015,JEOR: 1) ADDED KEY DO_KX_PROFILE;
;                        2) ADDED KEY Z_RES 
;      AUG 02,2015,JEOR :KX_PROFILE=(KX_PROFILE_SEABASS(KX,Z_RES=Z_RES, MAX_DEPTH=MAX_DEPTH)).KX
;      AUG 03,2015,JEOR  ADDED Z_RES TO PROFILE STRUCTURE
;      JUL 04,2016,JEOR  ADDED KEY WL  & NOW USING GET_APHI
;      JUL 17,2016,JEOR  ADDED WL  TO STRUCT
;      AUG 23,2018,JEOR  IMPROVED DOCUMENTATION THROUGHOUT   
;      SEP 04,2018,JEOR  ADDED KEY DO_NPY_PROFILE
;      SEP 11,2018,JEOR  DOCUMENTED ALL KEYWORDS; CHANGED USE_KX_PROFILE TO DO_KX_PROFILE 
;      SEP 21,2018,JEOR  NOW USING NEW FUNCTION NORMALIZED_PHOTOSYNTHETIC_YIELD [CAMPBELL & O'REILLY 1988]
;      SEP 21,2018,JEOR  ADDED KEYWORD PCT_LIGHT;MAX_DEPTH = Z_EU*1.3
;      SEP 24,2018,JEOR  OUTPUT A STRUCTURE FOR PP FROM7 LIGHT-DEPTH
;      OCT 09,2018,JEOR  IF NOF(KX) EQ 1 AND NOF(CHL) GT 1 THEN KX = REPLICATE(KX,NOF(CHL))
;      OCT 16,2018,JEOR  ADDED KEYWORD QE_MODEL [AND ASSOCIATED CASE BLOCK
;      APR 18,2018,JEOR  REMOVED KEY DO_NPY_PROFILE AND RELATED CODE,ADDED KEY VERSION
;                        PP = (12000.0*APH*DPAR) * DQY
;      MAY 09,2019,JEOR  IF NONE(Z_RES) THEN Z_RES = MAX_DEPTH/(LAYERS)
;      MAY 11,2019,JEOR  ADDED KC_P TO OUTPUT STRUCTURE
;      MAY 19,2019,JEOR  REVIEWED AND REVISED STEPS IN PROCEDURE
;                        REMOVED UNUSED EQUATION FOR KC_SST: 
;                        KC_SST = ( (SST[NTH] GT 12)  * (0.00433*EXP(0.08249*SST[NTH])) )  + ( (SST[NTH] LE 12) * ( 0.0105+SST[NTH]*0.0001) );;
;                        [THIS VERSION OF OPAL USES KCHL (FROM BRICAUD,ET AL. 1998]
;                        AND INCORPORATES EFFECTS OF SST ON PP IN THE TERM KC_P] 
;                        EURIKA, I GOT VERSION 2 TO WORK!
;                        PROFILE_PP = 12*Z_THICK*DQY*KC_P*PROFILE_CHL*PROFILE_PAR;
;    MAY 20,2019,JEOR    IF NONE(WL) THEN WL = 443 ;DEFAULT WAVELENGTH
;    MAY 30,2019,JEOR    ADDED KEY COEFFS AND ;===> NEW [VERSION 3] PP BASED ON PP_OPAL_OPTIMIZE
;    JUN 05,2019,JEOR    ADDED PROFILE_DQY TO OUTPUT STRUCTURE
;    JUL 07,2019,JEOR    IF ANY(COEFFS) THEN  VERSION = 2; [TEST VERSION]
;    JUL 13,2019,JEOR    PROFILE_DQY = DQY  [ FOR OUTPUT STRUCT IN VERSION 2]
;    JUL 14,2019,JEOR    ADDED VERSION 3 = NORMALIZED PHOTOSYNTHIC YIELD- SEE CAMPBELL AND O'REILLY,1988]
;    jul 23,2019,JEOR    PROFILE_DQY = PHIMAX*(TANH(DOUBLE(EK[0])/PROFILE_PAR))   ; EK MUST BE SCALAR!!
;    AUG 23,2019,JEOR    CHANGE KEY NUM TO NUM_NEC [TO BE MORE SPECIFIC ABOUT THE NUMBER OF NEC PROFILES TO GET]
;                        REGROUPED TAGS BY TYPE [CATEGORY]
;                        CHANGED OUTPUT STRUCTURE TAG Z' TO 'DEPTH' TO BE MORE EXPLICIT ['DEPTH',ZTOP_PROFILE]
;                        IF NONE(WL) THEN WL = 440 ; 440 IS [HISTORICALLY WAS]THE DEFAULT WL FOR VERSION 1
;    SEP 17,2019,JEOR    VERSION 2 IS NOW BASED ON THE MEDIANS OF DQY_443 FOR THE STANDARD 7 MARMAP LIGHT-DEPTHS
;                        IF NONE(Z_RES) THEN Z_RES = MAX_DEPTH/(LAYERS) REPLACED WITH: Z_RES = MAX_DEPTH/(LAYERS)


;       
;############     PROCEDURE     ###################################################################################
; 
;				1) THIS PROGRAM GENERATES PRIMARY PRODUCTIVITY ESTIMATES [GRAMS OF CARBON PER SQUARE METER PER DAY]
;				   WITH COMPARABLE PRECISION FOR A WIDE RANGE OF EUPHOTIC DEPTHS.
;				   AFTER THE OCEAN PRODUCTION FROM ABSORPTION OF LIGHT [OPAL] METHOD [MARRA, HO & TREES, 2003];				   
;       
;       2) THE DEPTH OF EUPHOTIC LAYER (Z_EU) IN METERS IS ESTIMATED 
;          USING MOREL AND BERTHON'S CASE I MODEL:
;          MOREL AND BERTHON (1989) PAGE 1547, EQUATIONS 1A, 1B
;          Z_EU =(C_TOT GT 10.0)* 568.2*C_TOT^(-0.746)+(C_TOT LE 10.0)* 200.*C_TOT^(-0.293)


;				3) THE ESTIMATED EUPHOTIC DEPTH (Z_EU) IS DIVIDED BY THE NUMBER 
;				   OF LAYERS (LAYERS= 200= OPTIMAL PRECISION) TO GENERATE THE LAYER THICKNESS,
;				   Z_THICK, USED TO COMPUTATE PRIMARY PRODUCTIVITY FOR EACH LAYER.
;				
;				4) TO ENSURE WE HAVE ENOUGH LAYERS TO ENCOMPASS THE EUPHOTIC DEPTH 
;				   THE LAYER THICKNESS IS MULTIPLIED BY 1.3 TO GENERATE A MAXIMUM DEPTH(MAX_DEPTH):
;          MAX_DEPTH = Z_EU*1.3
;          
;       5) THE VERTICAL RESOLUTION (Z_RES) IS CALCULATED AS:
;          Z_RES = MAX_DEPTH/(LAYERS)
;
;       6) A CHL PROFILE,PROFILE_CHL, IS GENERATED FROM SURFACE TO MAX_DEPTH
;          USING THE MODEL OF WOZNIAK ET AL.(2003),ALONG WITH SURFACE CHL, Z_RES, AND MAX_DEPTH:          
;          CHL_Z = CHL_PROFILE_WOZNIAK(CHL, Z_RES=Z_RES, MAX_DEPTH=MAX_DEPTH)         
;          
;       7) THE ABSORPTION BY PHYTOPLANKTON CHLOROPHYLL A (KCHL) AT 443NM OR OTHER USER PROVIDED WAVELENGTH WL]
;          IS BASED ON THE  EQUATION FROM BRICAUD, MOREL, BABIN,ALLALI & CLAUSTRE, (1998): 
;          KCHL =GET_APHI(WL,CHL = PROFILE_CHL) 
;          
;      8)  KX,ABSORPTION BY CDOM [KX] AT SURFACE IS EITHER ASSUMED TO BE VERTICALLY CONSTANT,
;          OR VERTICALLY MODELED USING KX_PROFILE_SEABASS [MEDIAN SEABASS CLIMATOLOGICAL ADG_443 PROFILE] 
;          ;
;				9) THE PROFILE OF PAR ABSORPTION, PROFILE_KPAR, IS THEN COMPUTED 
;				   BASED ON THE ABSORPTION OF PAR BY PHYTOPLANKTON (KCHL), 
;				   WATER (KW), AND OTHER SUBSTANCES(KX):
;					 PROFILE_KPAR  = KW + KX[NTH] + KCHL					 

;          
;      10)  KC_P (THE FRACTION OF PAR ABSORBED BY PHYTOPLANKTON THAT IS RELATED TO PHOTOSYNTHESIS IS CALCULATED FROM SST:
;           KC_P = 0.0105+SST*0.0001  BELOW 14.475 DEGREES C AND
;           KC_P = 0.00433*EXP(0.85*0.08249*SST AT OR ABOVE 14.475 DEGREES C;
;           THESE TWO EXPRESSIONS ARE COMBINED AS:
;           KC_P = ((SST[NTH] GE 14.475)*(0.00433*EXP(0.85*0.08249*SST[NTH])))+$
;                 ( (SST[NTH] LT 14.475)*(0.0105+SST[NTH]*0.0001))

;
;			 11) THE FRACTION OF SURFACE PAR AT THE TOP AND BOTTOM OF EACH LAYER
;			     (LIGHT_FRACT_TOP, LIGHT_FRACT_BOT) AND THE
;					 MEAN FRACTION OF SURFACE PAR (LIGHT_FRACT_MEAN) 
;					 ARE DERIVED FOR EACH LAYER FROM THE PROFILE_KPAR.
;          PROFILE_PAR IS THE ESTIMATE OF MEAN PAR FOR EACH LAYER (EINSTEINS M-2 D-1);
;
;			 12) THE EUPHOTIC DEPTH (ZEU, 1%) AND THE IDENTIFICATION OF THOSE LAYERS WITHIN THE EUPHOTIC ZONE ARE OBTAINED BY
;					 SEARCHING FOR VALUES OF LIGHT_FRACT_TOP GT 0.01.
;
;			 13) SURFACE PAR (PAR) AND LIGHT_FRACT_MEAN ARE USED TO COMPUTE 
;			     THE MEAN PAR (EINSTEIN M-2 D-1) FOR EACH LAYER (PROFILE_PAR);
;
;			 14) THE PRIMARY PRODUCTIVITY PROFILE, PROFILE_PP (GC LAYER-1 D-1)
;			     IS COMPUTED FOR EACH LAYER ACCORDING TO:
;          PROFILE_PP = 12*Z_THICK*PHIMAX*(TANH(EK/PROFILE_PAR))*KC_P*PROFILE_CHL*PROFILE_PAR;
;					 WHERE:
;					 THE CONSTANT 12 IS USED TO CONVERT TO FROM MMOLE-MG TO G-MOLE-C;
;					 Z_THICK IS THE LAYER THICKNESS (M);
;					 PHIMAX IS THE OPERATIONALLY-DEFINED MAXIMUM QUANTUM EFFICIENCY (MOLES O2/MOLE PHOTONS);
;					 EK IS THE HALF-MAXIMUM PAR IRRADIANCE (EINSTEINS M-2 D-1);
;					 ;
;       15) THE INTEGRAL DAILY PRIMARY PRODUCTIVITY (PPD, GC M-2 D-1) IS 
;           COMPUTED AS THE SUM OF THE PROFILE_PP FOR LAYERS WITHIN 
;           THE EUPHOTIC ZONE.
;
;			  16) THE EUPHOTIC-INTEGRATED STANDING STOCKS OF CHLOROPHYLL, 
;			      CHLOR_EUPHOTIC (MG M-2), IS COMPUTED AS THE SUM OF THE 
;			      AMOUNTS IN EACH LAYER, ASSUMING THAT THE CHLOROPYLL 
;			      CONCENTRATION IN THE MIDDLE OF THE LAYER APPLIES TO 
;			      THE WHOLE LAYER.
;
;				17) IF BOTTOM DEPTH IS PROVIDED AND IF BOTTOM DEPTH 
;				    IS LESS THAN THE EUPHOTIC DEPTH (ZEU) THEN
;						PPD AND CHLOR_EUPHOTIC ARE COMPUTED 
;						FROM SURFACE TO BOTTOM DEPTH.
;
;				18) THE PROGRAM RETURNS PPD (G C M-2 D-1).
;
;				19) IF THE INPUT CONSISTS OF ONLY ONE VALUE FOR 
;				    CHL, SST, PAR  AND KX THEN INPUTS AND PROFILES OF:
;				    LIGHT_FRACT_MEAN,'PROFILE_CHL',PROFILE_CHL,$
;           'DEPTH',PROFILE_DQY,PROFILE_KPAR,PROFILE_PAR,$
;           AND PROFILE_PP ARE RETURNED IN A STRUCTURE 
;				    
;				    
;	! KIM, JAY ISSUES/DIFFERENCES TO CONSIDER:
;	 
;	 MARRA,HO& TREES,2003 USES ; KC = ( (SST[NTH] GT 12)  * (0.00433*EXP(0.08249*SST[NTH])) )  + ( (SST[NTH] LE 12) * ( 0.0105+SST[NTH]*0.0001) );;
;                         TO ESTIMATE ABSORPTION BY PHYTO WHILE WE USE:KCHL =GET_APHI(WL,CHL = PROFILE_CHL) 
;                         FROM BRICAUD, MOREL, BABIN, ALLALI & CLAUSTRE, 1998
;  MARRA,HO& TREES,2003  USES KE =10 MOL PHOTONS M-2 D [P.10] WHILE WE USE 17.0 
;                       [HIGHER HALF-SATURATION FOR VERTICALLY-MIXED SHELF WATER ?]
;  MARRA,HO& TREES,2003  GENERATES THE CHLOROPHYLL CONCENTRATION PROFILE FROM CHL_SAT 
;                        ALONG WITH GAUSSIAN PROFILE SHAPE PARAMETERS (LEWIS, PLATT)
;                        WHEREAS OPAL USES WOZNIAK ET AL.(2003)
;  MARRA,HO& TREES,2003  I DO NOT SEE ANY REFERENCE TO 440NM  FOR ABS BY WATER IN THE APPENDIX 
;                       [MAYBE THIS WAS IN THE ORIGINAL MATLAB CODE I GOT FROM JOHN?]
;                        WE SHOULD STANDARDIZE ON 443NM  [TO BE ABLE TO USE SATELITTE ADG_443 AND APH_443 DATA]
;                        NOTE THAT CHL ABS AT 440NM IS CLOSE TO THE MAX CHL ABS PEAK AT ~443NM [THE PEAK CHL ABS VARIES WITH CHL CONCENTRATION]
;                        CONSEQUENTLY, I REVISED WL = 440 TO WL = 443  
;                        [!HOWEVER VERSION 1 USES WL = 440 FOR HISTORICAL CORRECTNESS]

	    
;
;*****************
ROUTINE='PP_OPAL'
;*****************	
ERROR = ''
; ***************************
; ***** REQUIRED INPUTS *****
; ***************************
N_DATA = N_ELEMENTS(CHL)
IF N_DATA EQ 0 OR N_ELEMENTS(SST) NE N_DATA OR N_ELEMENTS(PAR) NE N_DATA THEN BEGIN
  ERROR='ERROR: N_ELEMENTS CHL AND SST AND PAR MUST MATCH'
  PRINT, ERROR & RETURN,ERROR
ENDIF;IF N_DATA EQ 0 OR N_ELEMENTS(SST) NE N_DATA OR N_ELEMENTS(PAR) NE N_DATA THEN BEGIN
;||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||


; *****************************************
; ***** O P T I O N A L   I N P U T S *****
; *****************************************
; ===> IF BOTTOM_DEPTH VALUES ARE PROVIDED THEN VERTICAL INTEGRATION WILL BE FROM SURFACE TO THE LESSER OF EUPHOTIC AND BOTTOM DEPTHS
IF N_ELEMENTS(BOTTOM_DEPTH) EQ N_DATA THEN CHECK_BOTTOM = 1 ELSE CHECK_BOTTOM = 0
;||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||

IF NOF(KX) EQ 1 AND NOF(CHL) GT 1 THEN KX = REPLICATE(KX,NOF(CHL))

; ******************************
;	*****  D E F A U L T S   *****
; ******************************
IF NONE(VERSION) THEN VERSION = 1
;CCCCCCCCCCCCCCCC     
CASE (VERSION) OF
  1: BEGIN ; ADAPTED FROM MARRA,HO,TREES,2003
   VERSION_ = 'V1'
   IF NONE(WL) THEN WL = 440
  END;1
  
  2: BEGIN ; USES DAILY QUANTUM YIELD 
   VERSION_ = 'V2' ; SEP 18,2019
  END;2
  ELSE: BEGIN
    MESSAGE,'ERROR: VERSION MUST BE EITHER 1 OR 2'
  END
ENDCASE;CASE (VERSION) OF
;CCCCCCCCCCCCCCCCCCCCCCCC

  IF KEY(VERBOSE) THEN PRINT,VERSION_
  IF NONE(WL) THEN WL = 443 ;DEFAULT WAVELENGTH IF NONE PROVIDED
  IF NONE(KW) THEN KW = 0.04 ; ===> PURE WATER PAR ABSORPTION (M-1)
 ; ===> PHIMAX: MAXIMUM QUANTUM EFFICIENCY IS ~0.125 MOLES O2/MOLE PHOTONS
  IF NONE(PHIMAX) THEN PHIMAX=0.02;[= AVG VALUE] MARRA TREES AND O'REILLY,2007.P.160 "ABOUT ONE-SIXTH THE MAXIMUM VALUE"]
  IF NONE(QE_MODEL) THEN QE_MODEL = 'TANH_MODEL'; HYPERBOLIC TANGENT MODEL
  IF NONE(EK)THEN EK = 17.0D  ; HYPERBOLIC TANGENT (EINST M-2D-1) EK MUST BE DOUBLE FOR TANH TO WORK PROPERLY
  ;===> EUPHOTIC FRACTION [DEFAULT IS 1% OF SURFACE PAR]
  IF NONE(EUFRACT) THEN EUFRACT = 0.01
  ;===> DEFAULT IS TO TURN OFF DO_KX_PROFILE BECAUSE IT GREATLY INCREASES PROCESSING TIME OF OPAL
  ;    [AND DOES NOT ALTER THE OPUPUT VERY MUCH]
  IF NONE(DO_KX_PROFILE) THEN DO_KX_PROFILE = 0
 
; ##### COMMON TO HOLD ON TO SEQUENCE AND PP_FILE AND KX_PROFILE
  COMMON PP_OPAL_,SEQ,PP_FILE
;||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||

IF KEY(INIT) THEN GONE,SEQ
IF NONE(SEQ) THEN SEQ = 0UL ELSE SEQ = SEQ + 1

; ===> NUMBER OF LAYERS IN THE EUPHOTIC ZONE [200 = BEST PRECISION IN OUTPUT INTEGRAL PPD]
IF NONE(LAYERS) THEN LAYERS= 200

  ;######     MAKE PP_FILE OUTPUT FILE ?   #####
  IF KEY(PROFILES)  THEN PP_FILE = !S.IDL_TEMP + ROUTINE +'-' +'LAYERS' + '_'+ ROUNDS(LAYERS) + '-'+ DATE_NOW()+ '.PROFILES'



;	==========================
;	MAKE ARRAYS TO HOLD OUTPUT
;	==========================
 	PPD		=REPLICATE(0.0D,N_DATA)
 	K_PAR	=REPLICATE(0.0D,N_DATA)
 	ZEU		=REPLICATE(0.0D,N_DATA)
 	CHLOR_EUPHOTIC	=REPLICATE(0.0D,N_DATA)
 	BOTTOM_FLAG=REPLICATE(0B,N_DATA)
;  ||||||||||||||||||||||||||||||||||||||
;   	
 	;===> IF ANY PCT_LIGHT THEN DIMENSION A STRUCTURE ARRAY TO HOLD RESULTS OF PP FOR THE LIGHT_DEPTHS 
;###############################################	
  IF  ANY(PCT_LIGHT) THEN  BEGIN
    ;FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
    FOR L = 0,NOF(PCT_LIGHT)-1 DO BEGIN
      TAG = 'PCT_' + ROUNDS(PCT_LIGHT(L))
      S = CREATE_STRUCT(TAG,0.0D)
      IF NONE(PP_PCT_LIGHT) THEN PP_PCT_LIGHT = S ELSE PP_PCT_LIGHT = CREATE_STRUCT(PP_PCT_LIGHT,S)
    ENDFOR;FOR L = 0,NOF(PCT_LIGHT)-1 DO BEGIN
    ;FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
    ;
    ;===> REPLICATE THE PP_PCT_LIGHT STRUCTURE TO HOLD ALL INPUT DATA [N_DATA]
    PP_PCT_LIGHT = REPLICATE(PP_PCT_LIGHT,N_DATA)
  ENDIF;ANY(PCT_LIGHT) THEN  BEGIN
;||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
    



;	*********************************************** 
;	*** MAIN LOOP TO PROCESS EACH SET OF INPUTS ***
; ***********************************************

;FFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
 	FOR NTH=0L,N_DATA-1L DO BEGIN
  	ACHL = CHL[NTH]
;		===> CALCULATE AN ESTIMATED EUPHOTIC DEPTH
;		CALCULATE 'TOTAL PIGMENT CONTENT' ~ CHLOR_EUPHOTIC (MG CHL M-2) FROM CPD
;		MOREL AND BERTHON (1989) PAGE 1550, TABLE 2, EQUATIONS 2B, 2C
  	C_TOT	=38.0*FLOAT(ACHL LT 1.)*(ACHL > 0.)^0.425 $
    	  	+40.2*FLOAT(ACHL GE 1.)*(ACHL > 0.)^0.507;

; 	===> CALCULATE DEPTH OF EUPHOTIC LAYER USING MOREL'S CASE I MODEL,(M)
;		MOREL AND BERTHON (1989) PAGE 1547, EQUATIONS 1A, 1B
		Z_EU =(C_TOT GT 10.0)* 568.2*C_TOT^(-0.746)+ $
		      (C_TOT LE 10.0)* 200.0*C_TOT^(-0.293)


;		===> TO ENSURE WE HAVE ENOUGH LAYERS TO EXCEED THE EUPHOTIC DEPTH USE A 1.3 FACTOR
		MAX_DEPTH = Z_EU*1.3		
    Z_RES = MAX_DEPTH/(LAYERS)
    

    ;###########################################################################################
    ;===> USE CHL PROFILES FROM NORTHEAST COAST-SHELF OR THOSE FROM WOZNIAK?
    IF KEY(DO_NEC_PROFILES) THEN BEGIN      
      CHL_Z =  CHL_PROFILES_GET(LON=LON[NTH],LAT=LAT[NTH],DOY=DOY,CHL=ACHL,NUM=NUM_NEC,PNUMS=PNUMS)
      ;IF CHL_ IS !NULL THEN FAILED TO GET AN AVERAGE PROFILE SO DEFAULT TO WOZNIAK
      IF CHL_Z EQ !NULL THEN CHL_Z = CHL_PROFILE_WOZNIAK(ACHL, Z_RES=Z_RES, MAX_DEPTH=MAX_DEPTH)
    ENDIF ELSE BEGIN
      CHL_Z = CHL_PROFILE_WOZNIAK(ACHL, Z_RES=Z_RES, MAX_DEPTH=MAX_DEPTH)
    ENDELSE;IF KEY(DO_NEC_PROFILES) THEN BEGIN
;||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
    
    
 		PROFILE_CHL=CHL_Z.CHL
 		
  	N_DEPTHS = N_ELEMENTS(CHL_Z.Z)
  	
;   ################################################################################################################  	
;		===> MAKE DEPTH PROFILES FOR THE TOP AND MIDDLE OF EACH LAYER
  	ZTOP_PROFILE	=	CHL_Z.Z

		Z_THICK = ZTOP_PROFILE[1] - ZTOP_PROFILE[0]
  	ZBOT_PROFILE	= SHIFT(ZTOP_PROFILE,-1)
  	;===> THE ABOVE SHIFT FUNCTION RESULTS IN REPLACING THE LAST ARRAY VALUE WITH A ZERO FROM THE SURFACE
  	;    THIS NEXT LINE FIXES THIS BY SETTING THE LAST ZBOT_PROFILE VALUE TO ADJACENT VALUES N_DEPTHS-2 & N_DEPTHS-3]
  	ZBOT_PROFILE(N_DEPTHS-1) = ZBOT_PROFILE(N_DEPTHS-2) + (ZBOT_PROFILE(N_DEPTHS-2) - ZBOT_PROFILE(N_DEPTHS-3))
;||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||

;   ##########################################################################################################
;   FRACTION OF PAR ABSORBED BY PHYTOPLANKTON THAT IS RELATED TO PHOTOSYNTHESIS 
; 	*** KC_P  COMBINE BOTH EXPRESSIONS FROM J.MARRA ***
  	KC_P = ((SST[NTH] GE 14.475)*(0.00433*EXP(0.85*0.08249*SST[NTH])))+$
  	      ( (SST[NTH] LT 14.475)*(0.0105+SST[NTH]*0.0001))
;   |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||


;		###############################################################
;		*** ABSORPTION BY PHYTOPLANKTON CHLOROPHYLL A      ***
;		*** BRICAUD, MOREL, BABIN, ALLALI & CLAUSTRE, 1998 ***
        KCHL =GET_APHI(WL,CHL = PROFILE_CHL)
;   ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
;   
;           
;   ##############################################################################################################
;		===> CALCULATE PROFILE_KPAR FROM PROFILE_CHL PLUS EXTINCTION COEFFICIENTS FOR WATER AND 'OTHER'
;   PROFILE_KPAR = KW +KX + KC*PROFILE_CHL [AFTER MARRA]
;     USE THE MEDIAN WATER COLUMN KX PROFILE FROM ALL SEABASS DATA OR THE SINGLE VALUE FOR KX_?
 		  IF KEY(DO_KX_PROFILE) THEN BEGIN
        S = KX_PROFILE_SEABASS(KX,Z_RES=Z_RES, MAX_DEPTH=MAX_DEPTH)       
 		    PROFILE_KPAR  = KW + S.KX + KCHL  
 		  ENDIF ELSE BEGIN
        PROFILE_KPAR  = KW + KX[NTH] + KCHL
 		  ENDELSE;IF KEY(DO_KX_PROFILE) THEN BEGIN  
;||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||


;##################################################################################################
;   CALCULATE LIGHT PROFILES FOR TOP,BOTTOM AND THE MEAN OF EACH LAYER

; 	===> FRACTION OF SURFACE [1.0] LIGHT AT THE TOP OF EACH LAYER
 		LIGHT_FRACT_TOP	= EXP(PROFILE_KPAR[0]*Z_THICK + TOTAL(-1.0D*PROFILE_KPAR*Z_THICK,/CUMULATIVE,/DOUBLE))

;  	===> FRACTION OF SURFACE LIGHT AT THE MIDDLE OF EACH LAYER (NOT USED)
;; 	LIGHT_FRACT_MID = EXP(PROFILE_KPAR[0]*Z_THICK*0.5 + TOTAL(-1.0D*PROFILE_KPAR*Z_THICK,/CUMULATIVE,/DOUBLE))


; 	===> FRACTION OF SURFACE LIGHT AT THE BOTTOM OF EACH LAYER:
 		LIGHT_FRACT_BOT	= EXP(         											TOTAL(-1.0D*PROFILE_KPAR*Z_THICK,/CUMULATIVE,/DOUBLE))

;		===> MEAN FRACTION OF SURFACE LIGHT FOR EACH LAYER
;				(LIGHT_FRACTION_MEAN VALUES ARE SLIGHTLY GREATER THAN VALUES AT THE MIDDLE OF EACH LAYER [LIGHT_FRACT_MID])
		AA = -PROFILE_KPAR* Z_THICK
		LIGHT_FRACT_MEAN = -1*LIGHT_FRACT_TOP*((1.0D - EXP(AA))/AA)
;||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||


;##################################################################################################
;		===> CALCULATE PAR PROFILE (EINSTEINS M-2 D-1) FOR EACH LAYER)
		PROFILE_PAR = PAR[NTH]*LIGHT_FRACT_MEAN
;||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||

;##################################################################################################
;  	===> FIND THE LAYERS WITHIN THE EUPHOTIC ZONE (THE DEEPEST LAYER FOUND WILL CONTAIN THE 0.01 VALUE WITHIN THAT LAYER)
	 	OK=WHERE(LIGHT_FRACT_TOP GT EUFRACT,COUNT)
	 	INDEX_Z_MAX =  (0L > (COUNT-1) ) 

;		===> DETERMINE Z_MAX, THE DEPTH AT THE BOTTOM OF THE DEEPEST LAYER FOUND WITHIN THE EUPHOTIC ZONE
	 	Z_MAX = ZBOT_PROFILE(INDEX_Z_MAX)
	 	ZEU[NTH]  = Z_MAX
;||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||


;##################################################################################################
; 	===> IF BOTTOM DEPTH IS PROVIDED THEN MAKE Z_MAX THE LESSER OF THE EUPHOTIC AND BOTTOM DEPTH 
; 	     AND RECOMPUTE THE INDEX_Z_MAX
		IF CHECK_BOTTOM EQ 1 THEN BEGIN
			IF BOTTOM_DEPTH[NTH] LT Z_MAX THEN BEGIN
				BOTTOM_FLAG[NTH] = 1
				OK=WHERE(ZBOT_PROFILE LE BOTTOM_DEPTH[NTH],COUNT)
	 			INDEX_Z_MAX= 0L > (COUNT-1)   ; DO NOT ALLOW ANY -1 SUBSCRIPTS
	 			Z_MAX = ZBOT_PROFILE(INDEX_Z_MAX)
	 			ZEU[NTH]  = Z_MAX
			ENDIF
		ENDIF
;||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
;
;
;		===> COMPUTE EUPHOTIC K_PAR (FROM SURFACE TO 1% DEPTH, OR BOTTOM DEPTH IF LESS THAN 1% LIGHT DEPTH
		K_PAR[NTH] = -ALOG(LIGHT_FRACT_BOT(INDEX_Z_MAX))/ZBOT_PROFILE(INDEX_Z_MAX)

	
;##########  VERSION ?  ##########################################################################################
CASE (VERSION) OF
1: BEGIN
  ;===> ORIGINAL AFTER  MARRA, J., C.HO AND C.C. TREES. 2003.
  ;        [MODELS OTHER THAN TANH_MODEL MAY BE ADDED INTO THE FOLLOWING CASE BLOCK]
    ;  B = (EK/(EK + PROFILE_PAR)); IN APPENDIX OF MARRA ET.AL. 2003 [FOR EXAMPLE]
  CASE (QE_MODEL) OF
  ;===> CALCULATE PRIMARY PRODUCTIVITY FOR EACH LAYER(12: CONVERT TO G-MOLE-C FROM MMOLE-MG)
    'TANH_MODEL': BEGIN
;      PROFILE_PP = 12*Z_THICK*PHIMAX*(TANH(EK/PROFILE_PAR))*KC_P*PROFILE_CHL*PROFILE_PAR; ORIGINAL EQUATION
       PROFILE_DQY = PHIMAX*(TANH(EK[0]/PROFILE_PAR))  
       PROFILE_PP = 12*Z_THICK*PROFILE_DQY*KC_P*PROFILE_CHL*PROFILE_PAR;
    END;TANH_MODEL
    ELSE: MESSAGE,'ERROR: QE_MODEL NOT FOUND'
  ENDCASE;CASE (QE_MODEL) OF
END; VERSION 1

2: BEGIN
  ;===> NEW VERSION 2 BASED ON HYDE,O'REILLY,& MARRA
  IF NONE(COEFFS) THEN BEGIN 
    ;===> NEW [VERSION 2] PP BASED ON MEDIANS MARMAP DAILY QUANTUM YIELD[ DQY_443
    ;===> GET OPTICAL DEPTHS FOR EACH OF THE LAYERS IN THE EUPHOTIC LAYER 
   ODS = INTERPOL(INTERVAL([0.0,-1*ALOG(EUFRACT)],1.0),LAYERS)
    ;===> STANDARD MARMAP PERCENT LIGHT VALUES:
    PERCENT_LIGHT = [ 100,            69,        46,        25,        10,         3,         1]
    OPTICAL_DENSITIES = -1*ALOG(FLOAT(PERCENT_LIGHT)/100.0) & OPTICAL_DENSITIES[0] = 0.0
   ;===> MEDIAN MARMAP DQY_443
    DQY_443 = [0.002578322,0.005872285,0.01010522,0.01877031,0.02841022,0.02980077,0.02423847];ORIGINAL
    
    PROFILE_DQY = INTERPOL(DQY_443,OPTICAL_DENSITIES,ODS)
    PROFILE_PP = 12*Z_THICK*PROFILE_DQY*KC_P*PROFILE_CHL*PROFILE_PAR
 ENDIF ELSE BEGIN 
  ;===> GET DQY BASED ON LIGHT_FRACT_MEAN  [FRACT IS USED BY OD_2DQY TO CONVERT TO OPTICAL DEPTH,
; DQY  DAILY QUANTUM YIELD (MOLE CARBON / MOLE QUANTA M-2 D-1) 
    PROFILE_DQY = OD_2DQY(LIGHT_FRACT_MEAN,/FRACT,COEFFS = COEFFS)
    PROFILE_PP = 12*Z_THICK*PROFILE_DQY*KC_P*PROFILE_CHL*PROFILE_PAR
  ENDELSE;IF NONE(COEFFS) THEN BEGIN
   
END;VERSION 2

ELSE: BEGIN
END
ENDCASE
;||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
;  
   

;####################################################################################################
;===> ANY(PCT_LIGHT) ? THEN STORE RESULTS IN THE PP_PCT_LIGHT STRUCTURE 
IF ANY(PCT_LIGHT) THEN BEGIN
  OK = WHERE_NEAREST(LIGHT_FRACT_TOP,(PCT_LIGHT/100.0),COUNT)
  ; NOTE JEOR: MUST DIVIDE BY Z_THICK [TO GET PPD FOR A CUBIC METER] BECAUSE EACH OF THE 200 LAYERS 
  ; IN PROFILE_PP IS VERY THIN, USUALLY MUCH LESS THAN A METER THICK
  VALS = PROFILE_PP[OK]/Z_THICK 
  
  ;===>ASSIGN EACH VALUE TO ITS LIGHT-DEPTH
  ;FFFFFFFFFFFFFFFFFFFFFFFFFFFFF
  FOR L = 0,NOF(VALS)-1 DO BEGIN
      PP_PCT_LIGHT[NTH].(L) = VALS(L)
  ENDFOR;FOR L = 0,NOF(VALS)-1 DO BEGIN
  ;FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
ENDIF;IF ANY(PCT_LIGHT) THEN BEGIN
;||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||

;		===> INTEGRATE (SUM) PRODUCTIVITY IN THE EUPHOTIC LAYER
    PPD[NTH]=TOTAL(PROFILE_PP(0:INDEX_Z_MAX),/DOUBLE);

;		===> INTEGRATE (SUM) CHLOROPHYLL IN THE EUPHOTIC LAYER;
 		CHLOR_EUPHOTIC[NTH]=TOTAL(PROFILE_CHL(0:INDEX_Z_MAX)*Z_THICK,/DOUBLE);

ENDFOR ; 	FOR NTH=0L,N_DATA-1L DO BEGIN
;FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
;END OF MAIN LOOP FOR PROCESSING EACH SET OF INPUTS

IF N_ELEMENTS(BOTTOM_DEPTH) EQ 0 THEN _BOTTOM_DEPTH = 0 ELSE _BOTTOM_DEPTH = BOTTOM_DEPTH


;##########################################################################
; IF ONLY ONE SET OF INPUTS THEN MAKE A STRUCTURE
IF N_ELEMENTS(CHL) EQ 1 THEN BEGIN
STRUCT = CREATE_STRUCT('SEQ',SEQ,'MODEL','OPAL','VERSION',VERSION_,'DATE',DATE_NOW(),$
         'CHL',CHL[0],'PAR',PAR[0],'SST',SST,'KX',KX,'KC_P',KC_P,'WL',WL,'NLAYERS',LAYERS,'Z_RES',Z_RES,'EUFRACT',EUFRACT,$
         'ZEU',ZEU,'EK',EK,'K_PAR',K_PAR[0],$
         'CHLOR_EUPHOTIC',CHLOR_EUPHOTIC,'BOTTOM_DEPTH',_BOTTOM_DEPTH,'BOTTOM_FLAG',BOTTOM_FLAG,$
         'LIGHT_FRACT_MEAN',LIGHT_FRACT_MEAN,'PROFILE_CHL',PROFILE_CHL,$
         'DEPTH',ZTOP_PROFILE,$
         'PROFILE_DQY',PROFILE_DQY,'PROFILE_KPAR',PROFILE_KPAR,'PROFILE_PAR',PROFILE_PAR,$
         'PROFILE_PP',PROFILE_PP,'PPD',PPD,'KCHL',KCHL,_EXTRA=_EXTRA)
ENDIF;IF N_ELEMENTS(CHL) EQ 1 THEN BEGIN
;||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
;     
IF KEY(PROFILES) THEN  BEGIN
  IF FILE_TEST(PP_FILE) EQ 0 THEN BEGIN
    CLOSE,1
    OPENW,1,PP_FILE
  ENDIF;IF FILE_TEST(PP_FILE) EQ 0 THEN BEGIN    
    WRITEU,1,STRUCT  
  IF  FILE_TEST(PP_FILE) EQ 1 AND KEY(CLOSE) THEN CLOSE,1
ENDIF;IF KEY(SAV) THEN  BEGIN
  
  
;##########################################################################
;===> RETURN: PPD OR
;             A STRUCTURE [STRUCT] WITH PROFILE_CHL,PROFILE_PAR,PPD,ETC. OR 
;             A STRUCTURE CONTAINING PPD AT THE INPUT LIGHT-DEPTHS 
;     OR JUST THE PPD VALUES TOTALED FOR THE EUPHOTIC LAYER ?  
 IF  ANY(PCT_LIGHT) THEN RETURN,PP_PCT_LIGHT  ELSE RETURN,PPD
;||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||

END; #####################  END OF ROUTINE ################################
