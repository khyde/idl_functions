; $ID:	PP_VGPM2.PRO,	2020-07-08-15,	USER-KJWH	$

  FUNCTION PP_VGPM2, CHL=CHL, SST=SST, PAR=PAR, DAY_LENGTH=DAY_LENGTH ; Required Input
  
; NAME:
;   PP_VGPM2
;
; PURPOSE:
;   Calculate Primary Productivity using Behrenfeld-Falkowski VGPM Model (1997), BUT with pbopt an exponential function of temperature
;
; CATEGORY:
;   ALGORITHM_FUNCTIONS
; 
; CALLING SEQUENCE:
;   PP_VGPM2, CHL=CHL, SST=SST, PAR=PAR, DAY_LENGTH=DAY_LENGTH
; 
;	REQUIRED INPUTS:
;   CHL..........	Satellite chlorophyll concentration (mg chlor_a m-3)
;   SST.......... Satellite Sea Surface Temperature (degrees C)
;		PAR..........	Satellite PAR measurements (Einstein m-2 d-1)
;		DAY_LENGTH...	Length of Day (hours)
;
;	OPTIONAL INPUTS:
;   None
;   
; KEYWORD PARAMETERS:
;		None
;		
; OUTPUTS:
;   A structure containin PPD - Daily Primary Productivity (gC m-2 d-1), 
;                         KD_PAR - Diffuse attenuation coefficient for PAR (m-1)
;                         ZEU - Euphotic depth (m)
;                         CHLOR_EUPHOTIC - Areal concentration of CHL within the euphotic depth (mg m-2)
;  
; COMMON BLOCKS:
;   None
;
; SIDE EFFECTS:
;   None
;
; RESTRICTIONS:
;   None
;
; EXAMPLE:
;
;
; NOTES:                         
;   VGPM Reference
;   Behrenfeld, M.J. and P.G. Falkowski. 1997. Photosynthetic Rates Derived from Satellite-based
;     Chlorophyll Concentration. Limnol. Oceanogr., 42[1]:1-20.
;
;   Pbopt/temperature Reference
;     Antoine, D., J.-M. Andre, and A. Morel. 1996. Oceanic primary production. 2. Estimation at global
;       scale from satellite (coastal zone color scanner) chlorophyll. Global Biogeochem. Cycles 10:57- 69.
; 
; COPYRIGHT:
; Copyright (C) 2000, Department of Commerce, National Oceanic and Atmospheric Administration, National Marine Fisheries Service,
;   Northeast Fisheries Science Center, Narragansett Laboratory.
;   This software may be used, copied, or redistributed as long as it is not sold and this copyright notice is reproduced on each copy made.
;   This routine is provided AS IS without any express or implied warranties whatsoever.
;
; AUTHOR:
;   This program was written on January 10, 2000 by John E. O'Reilly, Northeast Fisheries Science Center | NOAA Fisheries | U.S. Department of Commerce, 28 Tarzwell Dr, Narragansett, RI 02882
;
;
; MODIFICATION HISTORY:
;   Jan 10, 2000 - JEOR: Initial code writted - adapted from IDL code provided by M.Behrenfeld
;		Jan 13, 2004 - JEOR: Added output: K_PAR,CHLOR_EUPHOTIC
;		Mar 19, 2004 - JEOR: changed K_PAR to be positive coefficients
;		Mar 24, 2004 - JEOR: changed constants to be as in published equation
;		Jun 19, 2004 - JEOR: changed k_par to be negative
;		Aug 30, 2004 - JEOR: changed K_PAR to be positive
;		Mar 28, 2005 - JEOR: Removed bottom_depth as an option (See VGPM2A if want to consider bottom depths)
;		Feb 10, 2017 - KJWH: Now returning a structure with the PP, K_PAR, CHLOR_EUPHOTIC, ZEU, and DAY_LENGTH variables
;                        Changed CHL_SAT to CHL
;   Jan 04, 2023 - KJWH: Updated documentation
;                        Changed K_PAR output to KD_PAR for consistency with the variable in PRODS_MAIN
;                        Moved to ALGORITHMS_FUNCTION                     
;-

	ROUTINE_NAME='PP_VGPM2'

	IF N_ELEMENTS(CHL) EQ 0 OR N_ELEMENTS(SST) EQ 0 OR N_ELEMENTS(PAR) EQ 0 THEN STOP

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
; *************************************************************
; *************************************************************


;	==================================================================================
; Calculate CHLOR_EUPHOTIC from Satellite Surface Chlorophyll Data (mg Chl m-2)
;	================================================================================
  CHLOR_EUPHOTIC=38.0*FLOAT(CHL LT 1.)*(CHL > 0.)^0.425 + 40.2*FLOAT(CHL GE 1.)*(CHL > 0.)^0.507;

; =================================================================
;	Calculate Depth of Euphotic Layer using Morel's Case I model, (m)
; =================================================================
;;  Behrenfeld:
;;  Z_eu=(CHLOR_EUPHOTIC > 0.)-FLOAT(CHLOR_EUPHOTIC LE 0.)
;;  Z_eu=1/Z_eu
;;  Z_eu=(Z_eu > 0.)
;;  Z_eu=(568.2*(Z_eu le 0.1)*Z_eu^(.746)+ 200.*(Z_eu gt 0.1)*Z_eu^(.293))  ;Z_eu

	ZEU  =  (CHLOR_EUPHOTIC GT 10.0)* 568.2*CHLOR_EUPHOTIC^(-0.746) +  (CHLOR_EUPHOTIC LE 10.0)* 200.*CHLOR_EUPHOTIC^(-0.293)

; ==========================================================
; Calculate K_PAR  (m-1) POSITIVE coefficients
; ==========================================================
	K_PAR = FLOAT(-ALOG(0.01)/ZEU)

; =======================================
;	Set Maximum Depth to Euphotic Depth (m)
; =======================================
	Z_max = ZEU

; ==================================================================
;	Calculate the Pb_opt from Satellite Surface Temperature Data
;	Use Antoine, D., J.-M. Andre, and A. Morel. 1996
; ==================================================================
	Pb_opt = 1.54*10.^(0.0275*SST-0.07)

; ================================================================
; Calculate the Primary Production
; ================================================================
  PP = 0.66125*Pb_opt*( PAR/(PAR+4.1)) *(CHL > 0.)*Z_max*day_length

; ======================================
; Change to grams C m-1
;	======================================
	STR = CREATE_STRUCT('PPD',0.001*PP,'KD_PAR',K_PAR,'CHLOR_EUPHOTIC',CHLOR_EUPHOTIC,'ZEU',ZEU,'DAY_LENGTH',DAY_LENGTH)
	RETURN, STR

END; #####################  End of Routine ################################
