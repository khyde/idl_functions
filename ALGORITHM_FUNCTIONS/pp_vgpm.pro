; $ID:	PP_VGPM.PRO,	2020-07-08-15,	USER-KJWH	$

  FUNCTION PP_VGPM, CHL=CHL, SST=SST, PAR=PAR, DAY_LENGTH=DAY_LENGTH ; Required Input

; NAME:
;   PP_VGPM
;
; PURPOSE:
;   Calculate Primary Productivity using Behrenfeld-Falkowski VGPM Model (1997) with pbopt a 7th order polynomial function of temperature
;
; CATEGORY:
;   ALGORITHM_FUNCTIONS
; 
; CALLING SEQUENCE:
;   PP_VGPM2, CHL=CHL, SST=SST, PAR=PAR, DAY_LENGTH=DAY_LENGTH
; 
; REQUIRED INPUTS:
;   CHL.......... Satellite chlorophyll concentration (mg chlor_a m-3)
;   SST.......... Satellite Sea Surface Temperature (degrees C)
;   PAR.......... Satellite PAR measurements (Einstein m-2 d-1)
;   DAY_LENGTH... Length of Day (hours)
;
; OPTIONAL INPUTS:
;   None
;   
; KEYWORD PARAMETERS:
;   None
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
; COPYRIGHT:
; Copyright (C) 2000, Department of Commerce, National Oceanic and Atmospheric Administration, National Marine Fisheries Service,
;   Northeast Fisheries Science Center, Narragansett Laboratory.
;   This software may be used, copied, or redistributed as long as it is not sold and this copyright notice is reproduced on each copy made.
;   This routine is provided AS IS without any express or implied warranties whatsoever.
;
; AUTHOR:
;   This program was written on January 10, 2000 by John E. O'Reilly, Northeast Fisheries Science Center | NOAA Fisheries | U.S. Department of Commerce, 28 Tarzwell Dr, Narragansett, RI 02882
;
; MODIFICATION HISTORY:
;   Jan 10, 2000 - JEOR: Initial code writted - adapted from IDL code provided by M.Behrenfeld
;   Jan 13, 2004 - JEOR: Added output: K_PAR,CHLOR_EUPHOTIC
;		Mar 19, 2004 - JEOR: Ahanged K_PAR to be positive coefficients
;		Mar 24, 2004 - JEOR: Ahanged constants to be as in published equation
;		Feb 10, 2017 - KJWH: Now returning a structure with the PP, K_PAR, CHLOR_EUPHOTIC, ZEU, and DAY_LENGTH variables
;				                     Changed CHL_SAT to CHL
;   Jan 04, 2023 - KJWH: Updated documentation
;                        Changed K_PAR output to KD_PAR for consistency with the variable in PRODS_MAIN
;                        Moved to ALGORITHMS_FUNCTION
;-

	ROUTINE_NAME='PP_VGPM'

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


	c0= 	1.2956
  c1=  2.749e-1 ;c1=0.2749
  c2=   6.17e-2 ;c2=6.17e-2
  c3=  -2.05e-2 ;c3=-2.05e-2
  c4=  2.462e-3 ;c4=2.46e-3
  c5= -1.348e-4 ;c5=-1.35e-4
  c6= 3.4132e-6 ;c6=3.42e-6
  c7=  -3.27e-8 ;c7=-3.28e-8

; *************************************************************
; *************************************************************


;	==================================================================================
; Calculate CHLOR_EUPHOTIC from Satellite Surface Chlorophyll Data (mg Chl m-2)
;	================================================================================
  CHLOR_EUPHOTIC= 38.0*FLOAT(CHL LT 1.)*(CHL > 0.)^0.425 + 40.2*FLOAT(CHL GE 1.)*(CHL > 0.)^0.507;

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
	ZEU  =  (CHLOR_EUPHOTIC GT 10.0)* 568.2*CHLOR_EUPHOTIC^(-0.746) +  (CHLOR_EUPHOTIC LE 10.0)* 200.*CHLOR_EUPHOTIC^(-0.293)


; ==========================================================
; Calculate K_PAR  (m-1) POSITIVE coefficients
; ==========================================================
	K_PAR = FLOAT(-ALOG(0.01)/ZEU)

; =======================================
;	Set Maximum Depth to Euphotic Depth (m)
; =======================================
	Z_max = Zeu


; ==================================================================
;	Calculate the Pb_opt from Satellite Surface Temperature Data
;	Use Behrenfeld-Falkowski Pb_opt vs. temperature model
; ==================================================================

    Pb_opt=4.*(SST gt 28.5)+1.13*(SST lt -1.)*(SST gt -10.)
    logic_arr=(SST le 28.5)*(SST ge -1.)
;   From M.Behrenfeld this was: SST=(0.1*SST > 1.e-5) ; But this altered the SST permanently
;		(also removed the 0.1*SST and now using the constants with e notation)
    _SST=(SST > 1.e-5)

    Pb_opt=FLOAT(logic_arr eq 0)*Pb_opt+FLOAT(logic_arr)* $
           (c7*_SST^7.+c6*_SST^6.+c5*_SST^5. $
           +c4*_SST^4.+c3*_SST^3.+c2*_SST^2. $
           +c1*_SST+c0)


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
