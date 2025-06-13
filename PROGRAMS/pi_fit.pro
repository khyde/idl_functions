; $ID:	PI_FIT.PRO,	2020-07-08-15,	USER-KJWH	$

; PI_FIT Function K.J.W.Hyde 30 June 2006
	 FUNCTION PI_FIT, LIGHT=LIGHT, PROD=PROD, CHL=CHL, LABEL=LABEL
;+
; NAME:
;       PI_FIT
;
; PURPOSE:
;       Fits Productivity vs Irradiance (PI) models to productivity (mgC/h) Irradiance data.
;				Models are:  PLATT, WEBB
;
;
; CATEGORY:
;				Productivity modeling
;
; CALLING SEQUENCE:
;				PROD = PI_FIT(LIGHT=LIGHT, PROD=PROD, CHL=CHL)
;
; INPUTS:
;				LIGHT = array of LIGHT values that correspond to the PROD values
;				PROD	= array of PROD values that correspond to the LIGHT values
;				CHL		= CHLOROPHYLL
;				LABEL = NAME OR ID OR LABEL TO ASSIGN TO THE LIGHT PRODUCTIVITY SET
;
;
; KEYWORD PARAMETERS:
;				NONE
;
; OUTPUTS:
;       PFIT 	= array of predicted productivity values
;				ALPHA	= initial slope of the curve
;				BETA	=	photoinhibition term
;				PSB		= theoretical maximum productivity without photoinhibition
;				PMAX	= maximum production with inhibition (see pmaxcalc.pro)
;				R2		= the coefficient of determination for the curve
;
;
; MODIFICATION HISTORY:
;       Written by:			K.J.W. Hyde		30 June 2006
;
; ****************************************************************************************************************************

	ROUTINE_NAME = 'PI_FIT'

	MODELS = ['PLATT_MODEL','WEBB_MODEL']							; Name of model functions
	NLIGHT = N_ELEMENTS(LIGHT)
	ITMAX = 10000																			; Maximum number of interations
	TOL = 1e-6																				; Convergence tolerance
	WEIGHTS = REPLICATE(1.0, NLIGHT)
	IF N_ELEMENTS(LABEL) NE 1 THEN LABEL = ''


;	===> Ensure data are sorted in order of increasing light intensity
	S=SORT(LIGHT) & LIGHT=LIGHT(S) & PROD=PROD(S)


;	===> Compute preliminary estimate of slope (alpha) based on the first 5 (lowest light) pairs
	STAT = STATS2(LIGHT(0:4),PROD(0:4),MODEL='LSY',/QUIET); Must ask for type=0 FOR LSY
	SLOPE = STAT.SLOPE

;	===> Create structure to hold all results
	NEW = CREATE_STRUCT('MODEL_NAME','','LABEL','','LIGHT',0.0,'PROD',0.0,'PFIT',0.0,'CHL',0.0,'ALPHA',0.0,'BETA',0.0,'PSB',0.0,'PMAX',0.0,$
											'B_ALPHA',0.0,'B_PMAX',0.0,'ITERATIONS',0.0,'CHISQ',0.0,'R2',0.0)
	NEW = STRUCT_2MISSINGS(NEW)
	NEW.LABEL = LABEL
	NEW = REPLICATE(NEW,N_ELEMENTS(LIGHT)*N_ELEMENTS(MODELS))

;	LLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLL
	FOR NTH = 0L, N_ELEMENTS(MODELS)-1 DO BEGIN
		POS = NTH*NLIGHT
		NEW(POS:POS+NLIGHT-1).LIGHT = LIGHT
		NEW(POS:POS+NLIGHT-1).PROD 	= PROD
		IF MODELS[NTH] EQ 'PLATT_MODEL' THEN A = [MAX(PROD),SLOPE, 0.001]					; Initial estimates for PSB, ALPHA, BETA for PLATT_MODEL
		IF MODELS[NTH] EQ 'WEBB_MODEL'  THEN A = [MAX(PROD),SLOPE]								; Initial estimates for PMAX and ALPHA for WEBB_MODEL
		AMODEL = MODELS[NTH]

;		===> Call CURVEFIT to solve for and refine model coefficients (A)
		PFIT = CURVEFIT(LIGHT, PROD, WEIGHTS, A,SIGMA, CHISQ=CHISQ,/DOUBLE, FUNCTION_NAME=MODELS[NTH], ITER=ITER, ITMAX=ITMAX, TOL=TOL, /NODERIVATIVE)

;		IF AMODEL EQ 'PLATT_MODEL' AND A(N_ELEMENTS(A)-1) LT 0 THEN BEGIN
;			AMODEL = 'PLATT_MODEL2'
;			A = [max(prod),slope]
;			PFIT = CURVEFIT(LIGHT, PROD, WEIGHTS, A,SIGMA, CHISQ=CHISQ,/DOUBLE, FUNCTION_NAME=AMODEL, ITER=ITER, ITMAX=ITMAX, TOL=TOL, /NODERIVATIVE)
;		ENDIF

		NEW(POS:POS+NLIGHT-1).PFIT = PFIT
		STAT = STATS2(PROD, PFIT, MODEL='LSY',/QUIET)
		NEW(POS).R2 = STAT.RSQ
		NEW(POS).ITERATIONS = ITER
		NEW(POS).CHISQ = CHISQ
		NEW(POS:POS+NLIGHT-1).MODEL_NAME = AMODEL
		IF AMODEL EQ 'PLATT_MODEL' THEN BEGIN
			NEW(POS).PSB 		= A[0]
			NEW(POS).ALPHA 	= A[1]
			NEW(POS).BETA 	= A(2)
 			IF A(2) LE 0 THEN NEW(POS).PMAX = A[0] ELSE	NEW(POS).PMAX  = PMAXCALC(PSB=A[0],ALPHA=A[1],BETA=A(2))
 			IF N_ELEMENTS(CHL) GE 1 THEN BEGIN
				NEW(POS).CHL		 = CHL
				NEW(POS).B_ALPHA = NEW(POS).ALPHA/CHL
				NEW(POS).B_PMAX  = NEW(POS).PMAX/CHL
			ENDIF ELSE 	PRINT, 'No chlorophyll data provided'
		ENDIF
		IF AMODEL EQ 'PLATT_MODEL2' OR AMODEL EQ 'WEBB_MODEL' THEN BEGIN
			NEW(POS).ALPHA 	= A[1]
			NEW(POS).BETA		= 0.0
			NEW(POS).PMAX 	= A[0]
			IF N_ELEMENTS(CHL) GE 1 THEN BEGIN
				NEW(POS).CHL		 = CHL
				NEW(POS).B_ALPHA = NEW(POS).ALPHA/CHL
				NEW(POS).B_PMAX  = NEW(POS).PMAX/CHL
			ENDIF ELSE 	PRINT, 'No chlorophyll data provided'
		ENDIF
	ENDFOR

	RETURN, NEW
END
