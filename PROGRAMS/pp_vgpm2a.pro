; $ID:	PP_VGPM2A.PRO,	2020-07-08-15,	USER-KJWH	$

  FUNCTION PP_VGPM2A, CHL_SAT=CHL_SAT,   SST = SST, PAR = par,$ ; Required Input
                    DAY_LENGTH = day_length,  $              					; Required Input
                    BOTTOM_DEPTH = BOTTOM_DEPTH, $  									; Optional Input
										BOTTOM_FLAG  = BOTTOM_FLAG, $
                    K_PAR=K_PAR,CHLOR_EUPHOTIC=CHLOR_EUPHOTIC 				; Optional Output
; NAME:
;       PP_VGPM2
;
; PURPOSE:
;       Calculate Primary Productivity using Behrenfeld-Falkowski VGPM Model (1997)
;				BUT with pbopt an exponential function of temperature
;
;				Behrenfeld, M.J. and P.G. Falkowski. 1997.
;				Photosynthetic Rates Derived from Satellite-based
;				Chlorophyll Concentration. Limnol. Oceanogr., 42[1]:1-20.

;				Pbopt vs temperature after:
;			  Antoine, D., J.-M. Andre, and A. Morel. 1996. Oceanic primary production. 2. Estimation at global
;				scale from satellite (coastal zone color scanner) chlorophyll. Global Biogeochem. Cycles 10:57-69.
;
;				Compensates for Bottom depth by PP(D) = PP(Zeu) [1 - exp(-4.61D/Zeu)]/0.99  or PP(D) = PP(Zeu) [1 - exp(-KPAR)]/0.99 (Signorini, McClain, O'Reilly)
;
;
; KEYWORD PARAMETERS:
;		REQUIRED INPUTS:
; 		CHL_SAT:  		Satellite chlorophyll concentration (mg chlor_a m-3)
;   	SST:  		Satellite Sea Surface Temperature (degrees C)
;			PAR:					Satellite PAR measurements (Einstein m-2 d-1)
;			DAY_LENGTH:  	Length of Day (hours)
;
;		OPTIONAL INPUTS:
;			BOTTOM_DEPTH:	Depth of Bottom (meters) OPTIONAL
;
;	OPTIONAL OUTPUT:
;				 K_PAR:						Extinction coefficient of downwelling PAR (coefficients are positive, m-1)
;				 CHLOR_EUPHOTIC:  Concentration of chlorophyll in the euphotic layer (mg chl m-2)
; OUTPUTS:
;        Primary Productivity, (gC m-2 d-1)
;
; MODIFICATION HISTORY:
;       Written by:  J.E.O'Reilly, Jan, 2000, From IDL code provided to me from M.Behrenfeld
;				Jan 13,2004 jor added output: K_PAR,CHLOR_EUPHOTIC
;				Mar 19, 2004 jor changed K_PAR to be positive coefficients
;				Mar 24, 2004 jor changed constants to be as in published equation
;				June 19, 2004 jor changed k_par to be negative
;				Aug 30, 2004 jor changed K_PAR to be positive
;-

	ROUTINE_NAME='PP_VGPM2A'

	IF N_ELEMENTS(CHL_SAT) EQ 0 OR N_ELEMENTS(SST) EQ 0 OR N_ELEMENTS(PAR) EQ 0 THEN STOP

; *************************************************************
;	***************** C O N S T A N T S  ************************
; *************************************************************
  Daytime=0
  Chl_tot=0.0
  Z_eu=0.0
  Pb_opt=4.54
  SST2=0.0
  sqr2=SQRT(2.)
  sqr2n1=sqr2+1.


	ALOG_1PERCENT = ALOG(0.01)
; *************************************************************
; *************************************************************


;	==================================================================================
; Calculate CHLOR_EUPHOTIC from Satellite Surface Chlorophyll Data (mg Chl m-2)
;	================================================================================
  CHLOR_EUPHOTIC=38.0*FLOAT(CHL_SAT LT 1.)*(CHL_SAT > 0.)^0.425 $
       +40.2*FLOAT(CHL_SAT GE 1.)*(CHL_SAT > 0.)^0.507;

; =================================================================
;	Calculate Depth of Euphotic Layer using Morel's Case I model, (m)
; =================================================================
;;  Behrenfeld:
;;  Z_eu=(CHLOR_EUPHOTIC > 0.)-FLOAT(CHLOR_EUPHOTIC LE 0.)
;;  Z_eu=1/Z_eu
;;  Z_eu=(Z_eu > 0.)
;;  Z_eu=(568.2*(Z_eu le 0.1)*Z_eu^(.746)+ 200.*(Z_eu gt 0.1)*Z_eu^(.293))  ;Z_eu

; =================================================================
;	Calculate Depth of Euphotic Layer using Morel's Case I model, (m)
; =================================================================
	Z_eu  =  (CHLOR_EUPHOTIC GT 10.0)* 568.2*CHLOR_EUPHOTIC^(-0.746) +  (CHLOR_EUPHOTIC LE 10.0)* 200.*CHLOR_EUPHOTIC^(-0.293)


; ==========================================================
; Calculate K_PAR  (m-1) POSITIVE coefficients
; ==========================================================
	K_PAR = FLOAT(-ALOG(0.01)/Z_EU)

; =======================================
;	Set Maximum Depth to Euphotic Depth (m)
; =======================================
	Z_max = Z_eu

; ==================================================================
;	Calculate the Pb_opt from Satellite Surface Temperature Data
;	Use Antoine, D., J.-M. Andre, and A. Morel. 1996
; ==================================================================
	Pb_opt = 1.54*10.^(0.0275*SST-0.07)

; ================================================================
; Calculate the Primary Production
; ================================================================
  PP = 0.66125*Pb_opt*( PAR/(PAR+4.1)) *(CHL_SAT > 0.)*Z_max*day_length


; ================================================================================
;	If Bottom Depth is provided then make Maximum Depth LE  Bottom Depth
;	AND $$$ Correct PP for depth with a negative exponential weighting
; ================================================================================
	IF N_ELEMENTS(BOTTOM_DEPTH) EQ N_ELEMENTS(CHL_SAT) THEN BEGIN
		BOTTOM_FLAG = REPLICATE(0B,N_ELEMENTS(CHL_SAT))
		OK_BOTTOM=WHERE(BOTTOM_DEPTH LT Z_eu, COUNT_BOTTOM_DEPTH)
		IF COUNT_BOTTOM_DEPTH GE 1 THEN BEGIN
			CHLOR_EUPHOTIC(OK_BOTTOM) = CHLOR_EUPHOTIC(OK_BOTTOM) * (BOTTOM_DEPTH(OK_BOTTOM)/Z_EU(OK_BOTTOM))
			Z_max(OK_BOTTOM) =   BOTTOM_DEPTH(OK_BOTTOM)
			BOTTOM_FLAG(OK_BOTTOM) = 1B
			PP(OK_BOTTOM) = PP(OK_BOTTOM)* (1.0 - EXP(ALOG_1PERCENT*Z_max(OK_BOTTOM)/Z_eu(OK_BOTTOM)))/0.99
		ENDIF
	ENDIF ELSE BOTTOM_FLAG = -1L


; ======================================
; Change to grams C m-1
;	======================================
	RETURN, (0.001*PP)


END; #####################  End of Routine ################################
