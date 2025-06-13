; $ID:	PP_VGPM2_MBZ.PRO,	2020-07-08-15,	USER-KJWH	$

  FUNCTION PP_VGPM2_MBZ, CHL_SAT=chl_SAT,   SST_SAT = sst_SAT, PAR = par,$ ; Required Input
                    DAY_LENGTH = day_length,  $              					; Required Input
                    K_PAR=K_PAR,CHLOR_EUPHOTIC=CHLOR_EUPHOTIC 				; Optional Output
; NAME:
;       PP_VGPM2Z
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
;
;
; KEYWORD PARAMETERS:
;		REQUIRED INPUTS:
; 		CHL_SAT:  		Satellite chlorophyll concentration (mg chlor_a m-3)
;   	SST_SAT:  		Satellite Sea Surface Temperature (degrees C)
;			PAR:					Satellite PAR measurements (Einstein m-2 d-1)
;			DAY_LENGTH:  	Length of Day (hours)
;
;		OPTIONAL INPUTS:
;
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
;				March 28, 2005 Removed bottom_depth as an option (See VGPM2A if want to consider bottom depths)
;				October, 2005 kjwh Added Mass Bay calculation for Zeu
;-

	ROUTINE_NAME='PP_VGPM2_MBZ'

	IF N_ELEMENTS(CHL_SAT) EQ 0 OR N_ELEMENTS(SST_SAT) EQ 0 OR N_ELEMENTS(PAR) EQ 0 THEN STOP

; *************************************************************
;	***************** C O N S T A N T S  ************************
; *************************************************************
  Daytime=0
  Chl_tot=0.0
  Z_eu=0.0
  Pb_opt=4.54
  SST_SAT2=0.0
  sqr2=SQRT(2.)
  sqr2n1=sqr2+1.


; *************************************************************
; *************************************************************


;	==================================================================================
; Calculate CHLOR_EUPHOTIC from Satellite Surface Chlorophyll Data (mg Chl m-2)
;	================================================================================
  CHLOR_EUPHOTIC=38.0*FLOAT(Chl_sat LT 1.)*(Chl_sat > 0.)^0.425 $
       +40.2*FLOAT(Chl_sat GE 1.)*(Chl_sat > 0.)^0.507;

; =================================================================
;	Calculate Depth of Euphotic Layer using Morel's Case I model, (m)
; =================================================================
;;  Behrenfeld:
;;  Z_eu=(CHLOR_EUPHOTIC > 0.)-FLOAT(CHLOR_EUPHOTIC LE 0.)
;;  Z_eu=1/Z_eu
;;  Z_eu=(Z_eu > 0.)
;;  Z_eu=(568.2*(Z_eu le 0.1)*Z_eu^(.746)+ 200.*(Z_eu gt 0.1)*Z_eu^(.293))  ;Z_eu

;	Z_eu  =  (CHLOR_EUPHOTIC GT 10.0)* 568.2*CHLOR_EUPHOTIC^(-0.746) +  (CHLOR_EUPHOTIC LE 10.0)* 200.*CHLOR_EUPHOTIC^(-0.293)
	Z_EU = MB_ZEU(CHL=CHL_SAT)

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
	Pb_opt = 1.54*10.^(0.0275*SST_SAT-0.07)

; ================================================================
; Calculate the Primary Production
; ================================================================
  PP = 0.66125*Pb_opt*( PAR/(PAR+4.1)) *(Chl_sat > 0.)*Z_max*day_length

; ======================================
; Change to grams C m-1
;	======================================
	RETURN, (0.001*PP)

END; #####################  End of Routine ################################
