; $ID:	T_TEST_SLOPE.PRO,	2014-10-24-08	$  NAN
;#################################################################################
FUNCTION T_TEST_SLOPE, X=X, Y=Y, MODEL=MODEL, ALPHA=ALPHA, SLOPE_SIG=SLOPE_SIG,STAT=STAT,VERBOSE=VERBOSE
;X=X,Y=Y,ALPHA = ALPHA,MODEL=MODEL,STAT = STATS2_,SLOPE_SIG=SLOPE_SIG
;+
; NAME:
;       T_TEST_SLOPE.PRO
;
; PURPOSE:
;       TEST THE SIGNIFICANCE OF THE SLOPE USING A T-TEST
;				BASED ON EQUATIONS IN BIOMETERY: THE PRINCIPLE AND PRACTICE OF STATISTICS 
;				IN BIOLOGICAL RESEARCH, CHAPTER 14 BY
;					SOKAL AND ROHLF, 1981 (MORE RECENT EDITIONS ARE AVAILABLE)
;					    
;
; KEYWORDS (INPUTS) <<<<<<<<<<<<<<<<<
;     X:      X VALUES FOR LINEAR REGRESSION
;     Y:      Y VALUES FOR LINEAR REGRESSION
;     MODEL:  REGRESSION MODEL TO BE INPUT INTO STATS2 [DEFAULT = 'LSY']
;     ALPHA:  CONFIDENCE INTERVAL [DEFAULT= 0.95D]
;     SLOPE_SIG: 'SIG_DIF' OR 'NOT_SIG_DIF'  [OUTPUT]
;     STAT:   STRUCTURE RETURNED FROM STATS2
;     VERBOSE:  PRINTS SLOPE_SIG RESULTS

;
; RETURN:
;   RETURN, [TS,TSA]
;     WHERE TS:   T-STATISTIC FOR THE SLOPE
;           TSA:  CUT-OFF FOR TS TO BE SIGNFICANT AT THE GIVEN ALPHA
;					
;					
;
; MODIFICATION HISTORY:
; WRITTEN BY:  K. HYDE SEPTEMBER 9, 2005
; 
; JUL 17,2014,JOR FORMATTING,USE NEW FUNCTIONS: NONE.
;                  IF NONE(ALPHA) THEN ALPHA = 0.05D
;                  ADDED KEYWORD VERBOSE
; JUL 31,2014,JOR, INCORPORATED INTO STATS2 
;                  ADDED KEYWORD STAT [TO BYPASS CALLING STATS2 AND GETTING STUCK IN AN INFINITE LOOP]
;                  IF NONE(STAT) THEN STAT = STATS2(X,Y,MODEL=_MODEL,/QUIET)
;                  REPLACED SLOPE_P WITH SLOPE_SIG [NOT A CONTINUOUS PROBABILITY VALUE BUT A SIG_DIF/NOT_SIG_DIF TXT RESULT]
;                  REPLACED RETURN,[ABS(TS),TSA] WITH > RETURN,[TS,TSA] TO CONSERVE THE ACTUAL T_VAL
;  OCT 24,ADDED ,/NAN) TO TOTAL FUNCTIONS

 
;                   

;####################################################################################


;*******************************
ROUTINE_NAME='T_TEST_SLOPE.PRO'
;*******************************
;

;	IF THE NULL HYPOTHESIS CAN NOT BE REJECTED, THEN THERE IS NO EVIDENCE THAT 
;	THE REGRESSION IS SIGNIFICANTLY DEVIANT FROM 0 (EITHER
;	IN THE POSITIVE OR NEGATIVE DIRECTION)
;###############################################################################

IF N_ELEMENTS(X) NE N_ELEMENTS(Y) THEN BEGIN
	MESSAGE, 'ERROR: NUMBER OF ELEMENTS OF X MUST EQUAL Y'
ENDIF;IF N_ELEMENTS(X) NE N_ELEMENTS(Y) THEN BEGIN
  
IF NONE(ALPHA) THEN ALPHA = 0.05D

;===> COMPUTE UNIVARIATE STATS
XSTAT = STATS(X,/QUIET)
YSTAT = STATS(Y,/QUIET)

;===> COMPUTE BIVARIATE STATS
IF NONE(MODEL) THEN _MODEL = 'LSY' ELSE _MODEL = MODEL
;===> ENSURE THAT STAT IS ONLY ONE MODEL
IF N_ELEMENTS(STAT) GT 1 THEN BEGIN
  MESSAGE,'ERROR: STATS2 MUST BE RERUN WITH A MODEL CHOICE'
  STOP
ENDIF;IF N_ELEMENTS(STAT) NE 1 THEN BEGIN
  
;===> IF STAT IS ALREADY PASSED IN FROM STATS2 THEN DO NOT CALL STATS2 AGAIN
IF NONE(STAT) THEN STAT = STATS2(X,Y,MODEL=_MODEL,/QUIET)
SLOPE   = STAT.SLOPE
INT     = STAT.INT
PRED_Y  = (SLOPE * X) + INT

MX		  = XSTAT.MEAN
MY		  = YSTAT.MEAN
SUMX 	  = TOTAL(X,/NAN)	& SUMX2 = TOTAL(X^2,/NAN)
SUMY	  = TOTAL(Y,/NAN)  & SUMY2 = TOTAL(Y^2,/NAN)
SUMXY   = TOTAL(X*Y,/NAN)
N       = XSTAT.N
B       = SUMXY/SUMX2
XX 		  = X - MX
YY 		  = Y - MY
XX2		  = XX^2
YY2 	  = YY^2
SUMXX2  = TOTAL(XX2,/NAN)
SUMYY2  = TOTAL(YY2,/NAN)
XXYY    = XX*YY
SUMXXYY = TOTAL(XXYY,/NAN)

;TOTAL SUM OF SQUARES Y					& MEAN SQUARE Y TOTAL
SUMYY2  = TOTAL((Y-MY),/NAN)^2				& SUMYY2M = SUMYY2/(N-1)

;TOTAL SUM OF SQUARES X					& MEAN SQUARE X TOTAL
SUMXX2  = TOTAL((X-MX)^2,/NAN)			& SUMX2M = SUMXX2/(N-1)

;REGRESSION SUM OF SQUARES				& MEAN SQUARE REGRESSION
RGSS = TOTAL((PRED_Y-MY)^2,/NAN)			& RGSSM = RGSS/1

;RESIDUAL SUM OF SQUARES					& MEAN SQUARE RESIDUAL
RSS = TOTAL((Y-PRED_Y)^2,/NAN)				& RSSM = RSS/(N-2)

;F VALUE
F = RGSSM/RSSM

;STANDARD ERROR OF THE ESTIMATE
SYX = SQRT(RSSM)

;STANDARD ERROR OF THE SLOPE
SES = SQRT(RSSM/SUMXX2)

;DEGREES OF FREEDOM
DF = N-2

;T STATISTIC
TS = SLOPE/SES

;COMPUTE THE TWO TAILED CONFIDENCE INTERVAL TO DETERMINE IF 'T' IS SIGNIFICANT
TSA = T_CVF(ALPHA/2,DF)
IF KEY(VERBOSE) THEN PRINT, 'ALPHA = ', ALPHA

;95% CONFIDENCE LIMITS FOR REGRESSION COEFFICIENT
TSB = T_CVF(0.05/2,DF)*SES
CL1 = SLOPE - TSB
CL2 = SLOPE + TSB

IF ABS(TS) GE TSA THEN BEGIN
	IF KEY(VERBOSE) THEN PRINT, 'REJECT H0:   ', ABS(STRTRIM(TS,2)), '  >=  ', STRTRIM(TSA,2), '  SIGNIFICANT AT P = ',STRTRIM(ALPHA,2), ', END T-TEST'
	SLOPE_SIG = 'SIG_DIF'
	RETURN,[TS,TSA]	
ENDIF;IF ABS(TS) GE TSA THEN BEGIN

IF ABS(TS) LT TSA THEN BEGIN
	IF KEY(VERBOSE) THEN PRINT, 'REJECT HA:   ', ABS(STRTRIM(TS,2)), '  <  ', STRTRIM(TSA,2), '  NOT SIGNIFICANT AT P = ',STRTRIM(ALPHA,2)
	SLOPE_SIG = 'NOT_SIG_DIF'
	RETURN, [TS,TSA]
ENDIF;IF ABS(TS) LT TSA THEN BEGIN


END; #####################  END OF ROUTINE ################################
