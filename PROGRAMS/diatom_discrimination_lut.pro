; $ID:	DIATOM_DISCRIMINATION_LUT.PRO,	2020-07-08-15,	USER-KJWH	$

	FUNCTION DIATOM_DISCRIMINATION_LUT, CHLOR_A=CHLOR_A, ED=ED, LUT_DIATOM=LUT_DIATOM, LUT_MIXED=LUT_MIXED

;+
; NAME:
;		DIATOM_DISCRIMINATION_LUT
;
; PURPOSE:;
;		This procedure generates the look-up tables used in Sathyendranath et al (2004) to distinguish diatoms from mixed populations using SeaWiFS.
;		  Look-up tables are generated for matched pairs of chlorophyll concentrations and reflectances.
;		  The model assumes that reflectance at a given wavelength just below the sea-surface (z=0) is the sum of 
;		    reflectances associated with Raman and elastic scattering.
;
; CATEGORY:
;		CATEGORY
;
; CALLING SEQUENCE:
;
;	ROUTINE_NAME, DIATOM_DISCRIMINATION_LUT
;
; OUTPUTS:
;		This function creates a save file for each look-up table.
;
;	NOTES:
;	    Sathyendranath, S., Watts, L., Devred, E., Platt, T., Caverhill, C., Maass, H., 2004. 
;	      Discrimination of diatoms from other phytoplankton using ocean-colour data. 
;	      Marine Ecology Progress Series 272, 59-68.
;	    
;	    Sathyendranath, S., Cotas, G., Stuart, V., Maass, H., Platt, T., 2001. 
;	      Remote sensing of phytoplankton pigments: a comparison of empirical and theoretical approaches. 
;	      International Journal of Remote Sensing 22 (2&3), 249-273.
;
;
; MODIFICATION HISTORY:
;			Written Jan 6, 2010    by K.J.W.Hyde, 28 Tarzwell Drive, NMFS, NOAA 02882 (kimberly.hyde@noaa.gov)
;			Modified July 7. 2010  by K.J.W.Hyde: Updated the model equations
;-
;	****************************************************************************************************
	ROUTINE_NAME = 'DIATOM_DISCRIMINATION'

;	===> Initialize ERROR to a null string. If errors are encountered ERROR will be set to a message.
;			 The calling routine can check error (e.g.IF ERROR NE 0 then there was a problem and do this or that)
	ERROR = ''

  ; For a given chlorophyll concentration, a model is used to compute reflectances at the 6 SeaWiFS wavebands.  
  ; Look-up tables are generated for matched pairs of chl concentrations and reflectances.
  
  ; The model assumes that reflectance just below the sea-surface is the sum of reflectances associated with Raman and elastic scattering.
                  

  ; EQUATION 1: R(wavelength,depth) = Eu/Ed (as a function of wavelength and depth) - Reflectance is the ratio of upwelling irradiance to downwelling irradiance
  ; EQUATION 2: R^E(wavelength) = r bb/a+bb (as a function of wavelength)
  ; EQUATION 3: a(wavelength) = aw + ap + ay (as a function of wavelength) | aw computed according to Pope & Fry (1997)
  ; EQUATION 4: a_p(wavelength) = U{1-exp(-SC)} + Ca2 (as a function of wavelenth)
  ;                     where U = C1^max[a*1-a*2] as a function of wavelength
  ; Case 1 model so all inherent properties are modelled as a function of chlorophyll a conentration
  
  WAVELENGTHS   = [362,412,386,443,421,490,435,510,468,555,547,670]
  RAMAN_WAVES   = [362,386,421,435,468,547]
  SEAWIFS_WAVES = [412,443,490,510,555,670]
  CW = READ_CSV('D:\IDL\PROGRAMS\CLEAR_WATER.CSV')
  OK = WHERE_MATCH(NUM2STR(CW.WL,DECIMALS=1),NUM2STR(WAVELENGTHS,DECIMALS=1),VALID=VALID)
  CW_A = FLOAT(CW[OK].AW_PF97)
  CW_B = FLOAT(CW[OK].BBW)
  AWATER    = CREATE_STRUCT('W362',CW_A[0],'W412',CW_A[1],'W386',CW_A(2),'W443',CW_A(3),'W421',CW_A(4),'W490',CW_A(5),'W435',CW_A(6),'W510',CW_A(7),'W468',CW_A(8),'W555',CW_A(9),'W547',CW_A(10),'W670',CW_A(11))
  BWATER    = CREATE_STRUCT('W362',CW_B[0],'W412',CW_B[1],'W386',CW_B(2),'W443',CW_B(3),'W421',CW_B(4),'W490',CW_B(5),'W435',CW_B(6),'W510',CW_B(7),'W468',CW_B(8),'W555',CW_B(9),'W547',CW_B(10),'W670',CW_B(11))                   
  MIXED_U   = CREATE_STRUCT('W362',0.0624, 'W412',0.0376, 'W386',0.0424, 'W443',0.0281, 'W421',0.0340, 'W490',0.0248, 'W435',0.0306, 'W510',0.0178, 'W468',0.0236, 'W555',0.00386,'W547',0.00542, 'W670',0.00586)
  MIXED_A2  = CREATE_STRUCT('W362',0.0273, 'W412',0.0269, 'W386',0.0236, 'W443',0.0310, 'W421',0.0285, 'W490',0.0146, 'W435',0.0316, 'W510',0.00979,'W468',0.0249, 'W555',0.00554,'W547',0.00644, 'W670',0.0169)
  MIXED_S   = CREATE_STRUCT('W362',0.541,  'W412',1.01,   'W386',0.753,  'W443',1.80,   'W421',1.23,   'W490',1.68,   'W435',1.65,   'W510',1.41,   'W468',2.12,   'W555',2.13,   'W547',1.93,    'W670',2.29)
  DIATOM_U  = CREATE_STRUCT('W362',0.0254, 'W412',0.103,  'W386',0.0277, 'W443',0.0747, 'W421',0.0939, 'W490',0.0122, 'W435',0.0897, 'W510',0.00786,'W468',0.0177, 'W555',0.00302,'W547',0.00349, 'W670',0.0110)
  DIATOM_A2 = CREATE_STRUCT('W362',0.0234, 'W412',0.00950,'W386',0.0161, 'W443',0.0118, 'W421',0.0102, 'W490',0.00981,'W435',0.0113, 'W510',0.00810,'W468',0.0128, 'W555',0.00443,'W547',0.00522, 'W670',0.0104)
  DIATOM_S  = CREATE_STRUCT('W362',8.72,   'W412',0.234,  'W386',2.43,   'W443',0.270,  'W421',0.252,  'W490',4.68,   'W435',0.248,  'W510',4.77,   'W468',2.95,   'W555',2.35,   'W547',3.12,    'W670',1.51)                           
           
  RFACTOR = 0.3 ; PROPORTIONALITY FACTOR (R)
  UD = 0.93     ; MEAN COSINE FOR DOWNWELLING
  UU = 0.5      ; MEAN COSINE FOR UPWELLING
  
  ARRAY = CHLOR_A & ARRAY(*) = MISSINGS(ARRAY)
  LUT_DIATOM = CREATE_STRUCT('CHLOR',CHLOR_A, 'R412',ARRAY, 'R443',ARRAY, 'R490',ARRAY, 'R510',ARRAY, 'R555',ARRAY, 'R670',ARRAY)    
  LUT_MIXED = LUT_DIATOM
  CTAGS = TAG_NAMES(LUT_DIATOM)    

  FOR WTH = 0L, N_ELEMENTS(SEAWIFS_WAVES)-1 DO BEGIN
    SWAVE = SEAWIFS_WAVES(WTH)
    RWAVE = RAMAN_WAVES(WTH)
    TAGS = TAG_NAMES(MIXED_U)
    OK_SEA = WHERE(STRMID(TAGS,1,3)  EQ STRTRIM(SWAVE,2))
    OK_RAM = WHERE(STRMID(TAGS,1,3)  EQ STRTRIM(RWAVE,2))
    OK_LUT = WHERE(STRMID(CTAGS,1,3) EQ STRTRIM(SWAVE,2))        

;   Backscattering by particles
;   Bbp = 0.01* (0.78 - 0.42 * log10C)     
    BBP = 0.01*(0.78-0.42*ALOG10(CHLOR_A))      ; Equation 10 (Sath. et al., 2001)

;   Backscattering coefficient (by wavelength) - depth independent in this model is the sum of backscattering by pure water and particles in suspension - Equations 7-11 (Sath. et al., 2001)
;   Bb = 0.5 * Bbw + Bbp * Bp        
    BB_SEA        = (0.5*BWATER.(OK_SEA)) + BBP * (0.407*(CHLOR_A^0.795)) * (660.0/SWAVE)^(-1*ALOG10(CHLOR_A))  
    BB_RAM        = (0.5*BWATER.(OK_RAM)) + BBP * (0.407*(CHLOR_A^0.795)) * (660.0/RWAVE)^(-1*ALOG10(CHLOR_A))      

;   Absoprtion coefficient (by wavelength) - depth independent in this model - Equations 3-4 (Sath. et al., 2004)
;   A = Aw + Ay + Ap (Ap = [U*(1-exp(-S*Chl))] + C*a2)     
    A_DIATOM_SEA  = AWATER.(OK_SEA) + CHLOR_A*EXP(-0.015*SWAVE) + (DIATOM_U.(OK_SEA)*(1-EXP(-DIATOM_S.(OK_SEA)*CHLOR_A)))+(CHLOR_A*DIATOM_A2.(OK_SEA))
    A_MIXED_SEA   = AWATER.(OK_SEA) + CHLOR_A*EXP(-0.015*SWAVE) + (MIXED_U.(OK_SEA) *(1-EXP(-MIXED_S.(OK_SEA) *CHLOR_A)))+(CHLOR_A*MIXED_A2.(OK_SEA))        
    A_DIATOM_RAM  = AWATER.(OK_RAM) + CHLOR_A*EXP(-0.015*RWAVE) + (DIATOM_U.(OK_RAM)*(1-EXP(-DIATOM_S.(OK_RAM)*CHLOR_A)))+(CHLOR_A*DIATOM_A2.(OK_RAM))
    A_MIXED_RAM   = AWATER.(OK_RAM) + CHLOR_A*EXP(-0.015*RWAVE) + (MIXED_U.(OK_RAM) *(1-EXP(-MIXED_S.(OK_RAM) *CHLOR_A)))+(CHLOR_A*MIXED_A2.(OK_RAM))
        
;   Attenuation coefficient for downwelling irradiance - Equation 3 (S & P 1998)
    KD_DIATOM_SEA = (A_DIATOM_SEA + BB_SEA)/UD         
    KD_MIXED_SEA  = (A_MIXED_SEA  + BB_SEA)/UD        
    KD_DIATOM_RAM = (A_DIATOM_RAM + BB_RAM)/UD
    KD_MIXED_RAM  = (A_MIXED_RAM  + BB_RAM)/UD

;   Attenuation coefficient for upwelling irradiance        
    KU_DIATOM_SEA = (A_DIATOM_SEA + BB_SEA)/UU         ; Equation 4 (S & P 1998)
    KU_MIXED_SEA  = (A_MIXED_SEA  + BB_SEA)/UU
    KU_DIATOM_RAM = (A_DIATOM_RAM + BB_RAM)/UU
    KU_MIXED_RAM  = (A_MIXED_RAM  + BB_RAM)/UU

;   Reflectance just below the sea-surface (z=0) is assumed to be the sum of Raman and elastic scattering
;   Contribution from elastic scattering (R^E) (by wavelength at z=0)        
    RE_DIATOM = RFACTOR * (BB_SEA/(A_DIATOM_SEA + BB_SEA))
    RE_MIXED  = RFACTOR * (BB_SEA/(A_MIXED_SEA  + BB_SEA))
      
    OK_EDR = WHERE(STRMID(TAG_NAMES(ED),1) EQ NUM2STR(RWAVE))
    OK_EDS = WHERE(STRMID(TAG_NAMES(ED),1) EQ NUM2STR(SWAVE))        
    ED_RAM = ED.(OK_EDR)
    ED_SEA = ED.(OK_EDS)

;   Contribution from Raman scattering (first-order) at the sea-surface (z=0)
    RR_DIATOM = (ED_RAM/ED_SEA) * (BB_RAM/UD) * (1/(KD_DIATOM_RAM+KU_DIATOM_SEA))
    RR_MIXED  = (ED_RAM/ED_SEA) * (BB_RAM/UD) * (1/(KD_MIXED_RAM +KU_MIXED_SEA))

;   Total reflectance is the sum of the Raman (R^R) and elastic (R^E) scattering.  
;   Reflectance is computed according to Eq. 26 in Sathyendranant and Platt (1998) and 
;   includes the first three Raman scattering terms accounting for single upward 
;   Raman scatter and 2 second-order terms accounting for the combination of elastic and Raman scattering events (R^RE and R^ER).        
    REF_DIATOM = RE_DIATOM + [RR_DIATOM * (1+(BB_SEA/KU_DIATOM_SEA)+(BB_RAM/(0.5*(KD_DIATOM_RAM+KU_DIATOM_RAM))))]
    REF_MIXED  = RE_MIXED  + [RR_MIXED  * (1+(BB_SEA/KU_MIXED_SEA) +(BB_RAM/(0.5*(KD_MIXED_RAM +KU_MIXED_RAM))))]
    
    OK_TAGS = WHERE(TAG_NAMES(LUT_DIATOM) EQ 'R'+NUM2STR(SWAVE))
    LUT_DIATOM.(OK_TAGS) = REF_DIATOM
    LUT_MIXED.(OK_TAGS)  = REF_MIXED         
  ENDFOR      
  
  
  RD510_555 = FLOAT(ROUNDS(LUT_DIATOM.R510/LUT_DIATOM.R555,5))
  CD510_555 = INTERP_XTEND(RD510_555,CHLOR_A,FLOAT(ROUNDS(INTERVAL([MIN(RD510_555),MAX(RD510_555)],0.00001),5)))
  GONE, RD510_555
  
  RD490_670 = FLOAT(ROUNDS(LUT_DIATOM.R490/LUT_DIATOM.R670,5))   
  CD490_670 = INTERP_XTEND(RD490_670,CHLOR_A,FLOAT(ROUNDS(INTERVAL([MIN(RD490_670),MAX(RD490_670)],0.00001),5)))
  GONE, RD490_670
  
  RM510_555 = FLOAT(ROUNDS(LUT_MIXED.R510/LUT_MIXED.R555,5))
  CM510_555 = INTERP_XTEND(RM510_555,CHLOR_A,FLOAT(ROUNDS(INTERVAL([MIN(RM510_555),MAX(RM510_555)],0.00001),5)))
  GONE, RM510_555
  
  RM490_670 = FLOAT(ROUNDS(LUT_MIXED.R490/LUT_MIXED.R670,5))   
  CM490_670 = INTERP_XTEND(RM490_670,CHLOR_A,FLOAT(ROUNDS(INTERVAL([MIN(RM490_670),MAX(RM490_670)],0.00001),5)))
  GONE, RM490_670
    
  STRUCT = CREATE_STRUCT('DIATOM_RR510_555',CD510_555.X,'CHL_DIATOM_RR510_555',CD510_555.Y,$
                         'DIATOM_RR490_670',CD490_670.X,'CHL_DIATOM_RR490_670',CD490_670.Y,$
                         'MIXED_RR510_555', CM510_555.X,'CHL_MIXED_RR510_555', CM510_555.Y,$
                         'MIXED_RR490_670', CM490_670.X,'CHL_MIXED_RR490_670', CM490_670.Y)
  
  GONE, CD510_555
  GONE, CD490_670
  GONE, CM510_555
  GONE, CM490_670
  
  
  RETURN, STRUCT
   
END; #####################  End of Routine ################################
