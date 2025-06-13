; $ID:	PP_VGMB.PRO,	2020-07-08-15,	USER-KJWH	$

  FUNCTION PP_VGMB, CHL_SAT=CHL_SAT, PAR=PAR,SST_SAT=sst_sat,$ 												; Required Input
                    DAY_LENGTH = day_length,  $              													; Required Input
                    K_PAR=K_PAR,CHLOR_EUPHOTIC=CHLOR_EUPHOTIC,PB_opt=PB_opt,ZEU=zeu 	; Optional Output

; NAME:
;       PP_VGPMB
;
; PURPOSE:
;       Calculate Primary Productivity using Behrenfeld-Falkowski VGPM Model (1997)
;				BUT with euphotic depth, euphotic chlorophyll, and pbopt models specific for Massachusetts Bay
;
;				Behrenfeld, M.J. and P.G. Falkowski. 1997.
;				Photosynthetic Rates Derived from Satellite-based
;				Chlorophyll Concentration. Limnol. Oceanogr., 42[1]:1-20.
;
;				Zeu and Chlzeu modeled after:
;				Morel and Berthon, 1989 Surface pigments, algal biomass profiles, and potential production of the euphotic layer:
;				Relationships reinvestigated in view of remote sensing applications. Limnol. Oceanogr., 34(8):1545-1562
;
; KEYWORD PARAMETERS:
;		REQUIRED INPUTS:
; 		CHL_SAT:  		Satellite chlorophyll concentration (mg chlor_a m-3)
;			PAR_SAT:			Satellite PAR measurements (Einstein m-2 d-1)
;   	SST_SAT:  		Satellite Sea Surface Temperature (degrees C)
;			DAY_LENGTH:  	Length of Day (hours)
;
;
;		OPTIONAL OUTPUT:
;				 K_PAR:						Extinction coefficient of downwelling PAR (coefficients are positive, m-1)
;				 CHLOR_EUPHOTIC:  Concentration of chlorophyll in the euphotic layer (mg chl m-2)
; 	OUTPUTS:
;        Primary Productivity, (gC m-2 d-1)
;
; MODIFICATION HISTORY:
;       Written by:  J.E.O'Reilly, Jan, 2000, From IDL code provided to me from M.Behrenfeld
;				Jan 13,2004 jor added output: K_PAR,CHLOR_EUPHOTIC
;				Mar 19, 2004 jor changed K_PAR to be positive coefficients
;				Mar 24, 2004 jor changed constants to be as in published equation
;				June 19, 2004 jor changed k_par to be negative
;				Aug 30, 2004 jor changed K_PAR to be positive
;				Sept 15, 2005 kjwh modified the PP_VGPM2 program to include Massachusetts Bay parameters
;-

	ROUTINE_NAME='PP_VGMB'

	IF N_ELEMENTS(CHL_SAT) NE N_ELEMENTS(PAR) OR N_ELEMENTS(CHL_SAT) EQ 0 THEN STOP

; *************************************************************
; *************************************************************

;	=============================================================================
; Calculate CHLOR_EUPHOTIC from Satellite Surface Chlorophyll Data (mg Chl m-2)
;	=============================================================================
;	MASSACHUSETTS BAY MODEL
	CHLOR_EUPHOTIC = MB_CHLeu(CHL=CHL_SAT)

; =================================
;	Calculate Depth of Euphotic Layer
; =================================
;	MASSACHUSETTS BAY MODEL
	ZEU = MB_ZEU(CHL=CHL_SAT)

; ==========================================================
; Calculate K_PAR  (m-1) POSITIVE coefficients
; ==========================================================
	K_PAR = FLOAT(-ALOG(0.01)/ZEU)

; =======================================
;	Set Maximum Depth to Euphotic Depth (m)
; =======================================
	Z_max = zeu

; ==================================================================
;	Pb_opt from in situ data
; ==================================================================
	PB_OPT = PBOPT_MB(SST=SST_SAT, CHL=CHL_SAT)

; ================================================================
; Calculate the Primary Production
; ================================================================
  PP = 0.66125*Pb_opt*( PAR/(PAR+4.1)) *(CHL_SAT > 0.)*Z_max*day_length


; ======================================
; Change to grams C m-1
;	======================================
	RETURN, PP*0.001


END; #####################  End of Routine ################################
