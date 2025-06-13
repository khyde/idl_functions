; $ID:	PP_OPAL_MICRO.PRO,	2016-09-01,	USER-JOR	$
; #########################################################################; 
FUNCTION PP_OPAL_MICRO, CHL       = CHL,$; REMOTELY-SENSED CHLOROPHLL CONCENTRATION (MG M-3)
                        SST       = SST,      $; SEA SURFACE TEMPERATURE (DEGREES C)
                        PAR       = PAR,      $; PAR (EINSTEIN M-2 D-1)
                        KX        = KX        ; ABSORPTION BY 'OTHER: I.E. CDOM'
;+
; PURPOSE:  RETURN THE PERCENTAGE OF OPAL INTEGRAL PRODUCTION THAT IS BY MICROPLANKTON 
;
; CATEGORY: PRODUCTION;
;
;
; INPUTS: 
;       CHL..... REMOTELY-SENSED CHLOROPHLL CONCENTRATION (MG M-3)
;       SST..... SEA SURFACE TEMPERATURE (DEGREES C)
;       PAR..... (EINSTEIN M-2 D-1)
;        KX..... ABSORPTION BY 'OTHER: I.E. CDOM' [M-1]
; 
;
;
; KEYWORDS:  NONE

;
;; EXAMPLES:
;    PRINT, PP_OPAL_MICRO(CHL = 1., SST = 15., PAR=55., KX = 0.02); = 22.612985 PERCENT MICRO

;
; MODIFICATION HISTORY:
;     AUG 24,2016  WRITTEN BY: J.E. O'REILLY
;     AUG 31,2016,JOR REFINED
;-
; #########################################################################

;******************************
ROUTINE_NAME  = 'PP_OPAL_MICRO'
;******************************
;===> DEFAULTS & CONSTANTS:
COEFFS = [0.125 , 0.047 , -0.036 , 0.007] ; 3RD-ORDER POLY REGRESSION COEFFICIENTS
WLS =[440,560,675]
MAX_YFIT = 0.143364
;===> INTERCEPT AND SLOPE FROM LOG10 REGRESSION OF MODELED (PP_560/PP_440) 
;     VS. LOG10 PERCENT MICRO PRODUCTION
INT = -3.151
SLOPE = 5.013
;|||||||||||||||||||||||||||||||||||||||||||||||||



IF NONE(KX) THEN KX = 0.02
;
;
;===> RUN OPAL FOR EACH OF THE THREE WAVELENGTHS IN THE ABSORPTION SHAPE INDEX
PP_440 = PP_OPAL(CHL = CHL, SST = SST, PAR=PAR, KX = KX,WL = 440)
PP_560 = PP_OPAL(CHL = CHL, SST = SST, PAR=PAR, KX = KX,WL = 560)
PP_675 = PP_OPAL(CHL = CHL, SST = SST, PAR=PAR, KX = KX,WL = 675)
 

X = PP_675
Y = PP_560/PP_440
X = ALOG10(X)
Y = ALOG10(Y)

;===> RUN POLY TO GET PREDICTED Y
YFIT = POLY(X,COEFFS)
PMICRO = 10.0^(INT + SLOPE*(YFIT/MAX_YFIT))
RETURN,PMICRO

END; #####################  END OF ROUTINE ################################
