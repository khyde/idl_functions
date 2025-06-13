; $Id:	pp_opal_profile.pro,	March 12 2014	$

	FUNCTION PP_OPAL_PROFILE,CHL_VALUE=CHL_VALUE,CHL_DEPTH=CHL_DEPTH,DAILY_PAR=DAILY_PAR,LIGHT_VALUE=LIGHT_VALUE,LIGHT_DEPTH=LIGHT_DEPTH,$
	                         SST=SST,SCHL=SCHL,EUPHOTIC_DEPTH=EUPHOTIC_DEPTH,MAX_DEPTH=MAX_DEPTH,ZRES=ZRES,ERROR=ERROR

;+
; NAME:
;		PP_OPAL_PROFILE
;
; PURPOSE:;
;		This procedure is to generate integrated PP and profiles of PP from the OPAL model using in situ (or simulated) profile data as inputs.
;
; CATEGORY:
;		CATEGORY
;
; CALLING SEQUENCE:
;		NO KEYWORDS
;
; INPUTS:
;
; OPTIONAL INPUTS:
;
; KEYWORD PARAMETERS:
;
; OUTPUTS:
;   Structure containing the input data, the interpolated inputs to the model, integrated PP and the PP profile
;
; OPTIONAL OUTPUTS:    
;   
;	NOTES:
;
;
; MODIFICATION HISTORY:
;			Written March 12, 2014 by K.J.W.Hyde, 28 Tarzwell Drive, NMFS, NOAA 02882 (kimberly.hyde@noaa.gov)
;-
;	****************************************************************************************************
	ROUTINE_NAME = 'PP_OPAL_PROFILE'

;	===> Initialize ERROR to a null string. If errors are encountered ERROR will be set to a message.
;			 The calling routine can check error (e.g.IF ERROR NE 0 then there was a problem and do this or that)
	ERROR = ''

	LDEPTH = LIGHT_DEPTH
	LDATA  = LIGHT_VALUE	
	CDATA  = CHL_VALUE
	CDEPTH = CHL_DEPTH
	SST    = SST
	IF N_ELEMENTS(MAX_DEPTH) NE 1 THEN MAX_DEPTH = EUPHOTIC_DEPTH 

; Make structures to include all of the initial input data, interpolated profiles, constatns and other output from the model
	INFO = STRUCT_2MISSINGS(CREATE_STRUCT('DAILY_PAR',0.0,'SST',0.0,'ZEU',0.0,'EK',0.0,'KD',0.0,'Z90',0.0,'IZ90',0.0,'KD_Z90',0.0,'KCHL_PHOTO',0.0,'OPAL_INT_PP',0.0D,'CHL_EUPH',0.0))
  
; Constants  
  INFO.EK  = 17.0   ; ===> Hyperbolic Tangent (Einst m-2d-1)
  KW       = 0.04   ; ===> Pure water absorption (m-1)
  PHIMAX   = 0.02   ; ===> Maximum Quantum Efficiency (0.125 moles O2/mole photons) 
	
	INFO.DAILY_PAR  = DAILY_PAR
	INFO.SST        = SST	
	INFO.ZEU        = EUPHOTIC_DEPTH 	                  
  INFO.KD         = -ALOG(0.01)/EUPHOTIC_DEPTH
  INFO.Z90        = 1.0/INFO.KD
  INFO.IZ90       = EXP(-1)*INFO.DAILY_PAR
  INFO.KD_Z90     = -(ALOG(INFO.IZ90/INFO.DAILY_PAR))/INFO.Z90  
  INFO.KCHL_PHOTO = ((SST GE 14.475) * (0.00433*EXP(0.85*0.08249*SST))) + ((SST LT 14.475) * (0.0105+SST*0.0001)) ; Fraction of PAR absorbed by phytoplankton that is related to photosynthesis
  
; Create depth layers
  IF N_ELEMENTS(ZRES) NE 1 THEN Z_RES = 0.01 ELSE Z_RES = ZRES
  N_LAYERS=FIX(MAX_DEPTH/Z_RES)
  PROFILE_Z  = FINDGEN(N_LAYERS)*Z_RES
  PROFILE_Z = PROFILE_Z[WHERE(PROFILE_Z LE MAX_DEPTH)]
   
; ***** Calculate Quantum Yield (Phimax) based on data from Bob Vaillancourt *****
; PHIMAX = (-0.000008*(PROFILE_Z^2) + 0.0013*PROFILE_Z + 0.0139)/1.4
  
; ***** Interpolate PAR and CHL profiles *****                   
  PROF_PAR   = INTERP_XTEND(LDEPTH,ALOG(LDATA),PROFILE_Z)        
  PROF_CHL   = INTERP_XTEND(CDEPTH,CDATA,PROFILE_Z)        
  
  DEPTH         = PROF_PAR.X
  PAR           = EXP(PROF_PAR.Y)
  PAR_DATA_TYPE = PROF_PAR.TYPE
    
  CHL           = PROF_CHL.Y
  CHL_DATA_TYPE = PROF_CHL.TYPE

; ***** Determine the light properties in the water column *****      
  KPAR = -(ALOG(PAR/INFO.DAILY_PAR))/DEPTH
  KCHL = 0.0378*CHL^0.627                   ; ===> Absorption by Phytoplankton Chlorophyll a - Bricaud, Morel, Babin, Allali & Claustre, 1998 -  Aphi_440 = 0.0378*chl^0.627    
  KX   = KPAR-KW-KCHL

; ***** Calculate PP using OPAL *****      
  OPAL_PP          = (12*Z_RES*PHIMAX*(TANH(INFO.Ek/PAR))*INFO.KCHL_PHOTO*CHL*PAR)/Z_RES
  INTEGRATE_PP     = PROFILE_INTEGRATION(VAR=OPAL_PP, DEPTH=DEPTH, MAX_DEPTH=EUPHOTIC_DEPTH,ERROR=error, EXTRA=EXTRA) ; ===> Integrate (SUM) Productivity in the euphotic layer
  INFO.OPAL_INT_PP = 1000*INTEGRATE_PP.INTEGRATED_X  
  INTEGRATE_CHL    = PROFILE_INTEGRATION(VAR=CHL, DEPTH=DEPTH, MAX_DEPTH=EUPHOTIC_DEPTH,ERROR=error, EXTRA=EXTRA)     ; ===> Integrate (SUM) Chlorophyll in the euphotic layer
  INFO.CHL_EUPH    = INTEGRATE_CHL.INTEGRATED_X      
  
  PROF = CREATE_STRUCT('DEPTH',DEPTH,'PAR_DATA_TYPE',PAR_DATA_TYPE,'PAR',PAR,'CHL_DATA_TYPE',CHL_DATA_TYPE,'CHL',CHL,'PHIMAX',PHIMAX,'KPAR',KPAR,'KW',KW,'KCHL',KCHL,'KX',KX,'OPAL_PP',OPAL_PP)

           
  RETURN, CREATE_STRUCT(INFO,PROF)

END; #####################  End of Routine ################################
