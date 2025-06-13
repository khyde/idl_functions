; $ID:	PSIZE_UITZ.PRO,	2020-06-30-17,	USER-KJWH	$
; #########################################################################; 
FUNCTION PSIZE_UITZ,CHL_SUR, DEPTH=DEPTH, ZEU=ZEU,$
                          FUCO=FUCO,PERID=PERID,$ ; MICRO
                          HEX_FUCO=HEX_FUCO,BUT_FUCO=BUT_FUCO,ALLO=ALLO,$ ; NANO
                          TCHLB=TCHLB,ZEA=ZEA, $; PICO
                          VERBOSE=VERBOSE
;+
; NAME:
;   PSIZE_UITZ
; 
; PURPOSE: 
;   This function calculates the fraction of chlorophyll associated with three size-classes of phytoplankton [micro, nano & pico] 
;     using surface chlorophyll and 7 diagnostic (HPLC-type) pigments according to the Uitz et al., 2006 model.
;
; CATEGORY:
;   Algorithms
;
; REQUIRED INPUTS:
;    CHL_SUR ......... Surface chlorophyll concentration [mg/m^3]
;
; OPTIONAL INPUTS
;   ZEU ........... Euphotic depth [meters] if measured [if not then use ZEU_MM01]
; 
; KEYWORD PARAMETERSS:  
;    DEPTH ......... Depth [meters] for the HPLC pigment measurements
;    
;    VERBOSE ....... PRINT PROGRAM PROGRESS
;        
;        
;         
; OUTPUTS: 
;   A structure containing the 3 size class fractions [0 to 1.0]
;                


; EXAMPLE:
; 
; PROCEDURE:
; 1) CHL_SUR IS USED TO ESTIMATE INTEGRAL EUPHOTIC CHL [CHL_ZEU] AND THE EUPHOTIC DEPTH [ZEU], [IF NOT PROVIDED] 
; 2) THE DEPTH AND THE SEVEN DIAGNOSTIC PIGMENTS ARE PLACED IN A STRUCTURE [FOR KEEPING TRACK OF INPUTS -TAGS]
; 3) THE SEVEN DIAGNOSTIC PIGMENTS ARE INTEGRATED OVER DEPTH TO GET P_ZEU [INTEGRAL PIGMENT OVER EUPHOTIC LAYER]
; 3) SUM_PDW, THE WEIGHTED SUM OF DIAGNOSTIC PIGMENTS [ FOR THE EUPHOTIC ZONE] AS:
;    SUM_PDW =  1.41[FUCO] + 1.41[PERID] + 1.27[HEX_FUCO]+ 0.35[BUT_FUCO] + 0.60[ALLO] + 1.01[TCHLB]+ 0.86[ZEA]
;    WHERE THE THREE SIZE GROUPS ARE:
;    MICRO = FUCO,PERID
;    NANO =  HEX_FUCO,BUT_FUCO,ALLO
;    PICO =  TCHLB,ZEA
; 4) DERIVE THE FRACTIONS OF THE CHLOROPHYLL A CONCENTRATION ASSOCIATED WITH EACH OF THE THREE 
;    PHYTOPLANKTONIC CLASSES (FMICRO, FNANO AND FPICO)
; 5) MAKE AN OUTPUT STRUCTURE CONTAINING THE IMPORTANT INFO 
; 
; NOTES:
;   Pigment table
;        DIAGNOSTIC PIGMENT                   SIZE CLASS
;        --------------------------------------------------
;        FUCO     Fucoxanthin                 Microplankton
;        PERID    Peridinin                   Microplankton
;
;        HEX-FUCO 19-Hexanoyloxyfucoxanthin   Nanoplankton
;        BUT-FUCO 19-Butanoyloxyfucoxanthin   Nanoplankton
;        ALLO     Alloxanthin                 Nanoplankton
;
;        TCHLB    Chlorophyll-b+divinyl chlb  Picoplankton
;        ZEA      Zeaxanthin                  Picoplankton
;        --------------------------------------------------
;
; REFERENCE:
;   Uitz J, Claustre H, Morel A, Hooker SB (2006) Vertical distribution of phytoplankton communities in open ocean: An assessment based on surface chlorophyll. Journal of Geophysical Research 111 doi doi: 10.1029/2005jc003207
;
; Copyright (C) 2018, Department of Commerce, National Oceanic and Atmospheric Administration, National Marine Fisheries Service,
;   Northeast Fisheries Science Center, Narragansett Laboratory.
;   This software may be used, copied, or redistributed as long as it is not sold and this copyright notice is reproduced on each copy made.
;   This routine is provided AS IS without any express or implied warranties whatsoever.
;
;   This program was written by Kimberly Hyde, DOC/NOAA/NMFS/NEFSC Narragansett, RI, kimberly.hyde@noaa.gov
;          with assistance from John E. O'Reilly, DOC/NOAA/NMFS/NEFSC Narragansett, RI
;
; 
; MODIFICATION HISTORY.
;     Written Aug 22, 2018 by K.J.W. Hyde, NOAA/NEFSC/Narragansett Laboratory, 28 Tarzwell Drive, 02882 (kimberly.hyde@noaa.gov)
;                          Adapted from PIGS_2SIZE_CLASS written by J. E. O'Reilly
;    
;
;
; #########################################################################
;-
;***************************
  ROUTINE = 'PSIZE_UITZ'
;***************************
;===> CONSTANTS
  P_ZEU = []
  VRES = 0.1 ;[INTERPOLATE VERTICALLY-DEPTH AT 0.1 M RESOLUTION, FOR SHALLOW ZEU]

;===> IF HAVE CHL_SUR AND NO DEPTH PROVIDED THEN ZEU AND ALL OUTPUT ARE BASED ON MODEL
  IF ANY(CHL_SUR) AND NONE(DEPTH) THEN DEPTH = 0.0

;===> CHECK ON REQUIRED INPUTS
  IF NONE(CHL_SUR) OR NONE(DEPTH) $
                   OR NONE(FUCO) OR NONE(PERID) $
                   OR NONE(HEX_FUCO) OR NONE(BUT_FUCO)OR NONE(ALLO) $
                   OR NONE(TCHLB) OR NONE(ZEA) THEN MESSAGE,'ERROR: MISSING SOME INPUTS'
                 
;===> CHECK THAT NUMBER OF DEPTH AND PIGS MATCH
;===> DETERMINE WHICH BANDS AND THE NUMBER OF BANDS THAT WERE PROVIDED 
  N1 = N_ELEMENTS(DEPTH)
  N2 = N_ELEMENTS(FUCO)
  N3 = N_ELEMENTS(PERID)
  N4 = N_ELEMENTS(HEX_FUCO)
  N5 = N_ELEMENTS(BUT_FUCO)
  N6 = N_ELEMENTS(ALLO)
  N7 = N_ELEMENTS(TCHLB)
  N8 = N_ELEMENTS(ZEA)
  
  N_INPUTS = FIX(TOTAL([N1,N2,N3,N4,N5,N6,N7,N8])/N1)
  IF TOTAL([N1,N2,N3,N4,N5,N6,N7,N8]) MOD N_INPUTS NE 0 THEN MESSAGE,'ERROR: N_ELEMENTS IN THE INPUTS PROVIDED MUST BE THE SAME'

;|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||                 
;############################################################################################
; 1) CHL_SUR IS USED TO ESTIMATE INTEGRAL EUPHOTIC CHL [CHL_ZEU] AND THE EUPHOTIC DEPTH [ZEU]
;############################################################################################
  S = ZEU_MM01(CHL_SUR)
  CHL_ZEU = S.CHL_ZEU
  IF NONE(ZEU) THEN ZEU = S.ZEU
  
;############################################################################################
; 2) THE DEPTH AND THE SEVEN DIAGNOSTIC PIGMENTS ARE PLACED IN A STRUCTURE [FOR KEEPING TRACK OF INPUTS -TAGS]
;############################################################################################
  D = CREATE_STRUCT('DEPTH',DEPTH,'FUCO',FUCO,'PERID',PERID, 'HEX_FUCO',HEX_FUCO,'BUT_FUCO',BUT_FUCO,'ALLO',ALLO,'TCHLB',TCHLB,'ZEA',ZEA)

;############################################################################################
; 3) THE SEVEN DIAGNOSTIC PIGMENTS ARE INTEGRATED OVER DEPTH TO GET P_ZEU [INTEGRAL PIGMENT OVER EUPHOTIC LAYER]
;############################################################################################

  PIGS = ['FUCO', 'PERID', 'HEX_FUCO', 'BUT_FUCO', 'ALLO', 'TCHLB', 'ZEA']
  TAGS = TAG_NAMES(D)
;FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
  FOR NTH = 1,NOF(TAGS)-1 DO BEGIN; [BEGIN AT 1 TO SKIP DEPTH TAG]
    PIG = PIGS(NTH-1)
    X   = D.DEPTH       ;===> INTEGRATE PIG OVER DEPTH  
    Y   = 0.0 > D.(NTH) ;===> ENSURE NO NEGATIVE PIGS ARE INTEGRATED [AS WITH CLIVEC TCHLB] 
    BAD = MISSINGS(Y)
    XX  = INTERVAL([0.0,ZEU],VRES)
  
    IF NOF(X) GE 2 THEN YY  = INTERPX(X,Y,XX,BAD = BAD) ELSE YY = REPLICATE(Y[0],NOF(XX)) ;===< ONLY 1 DEPTH THEN DO NOT INTERPOLATE OVER DEPTH
    P_ZEU = CREATE_STRUCT(P_ZEU,PIG,YY)
  
  ENDFOR;FOR NTH = 0,NOF(PIGS) -1 DO BEGIN
;FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF

  IF KEY(VERBOSE) THEN ST,P_ZEU

;##########################################################################################################
;3) SUM_PDW, THE WEIGHTED SUM OF DIAGNOSTIC PIGMENTS [ FOR THE EUPOTIC COLUMN] AS:
;    SUM_PDW =  TOTAL(1.41[FUCO] + 1.41[PERID] + 1.27[HEX_FUCO]+ 0.35[BUT_FUCO] + 0.60[ALLO] + 1.01[TCHLB]+ 0.86[ZEA])
;##########################################################################################################
 
 ;===> MULTIPLY BY VRES TO COMPENSATE FOR THE INCREASED NUMBER OF LAYERS DURING INTERPOLATION [10X]
  SUM_PDW =  VRES * TOTAL(1.41*P_ZEU.FUCO + 1.41*P_ZEU.PERID + 1.27*P_ZEU.HEX_FUCO + 0.35*P_ZEU.BUT_FUCO + 0.60*P_ZEU.ALLO + 1.01*P_ZEU.TCHLB+ 0.86*P_ZEU.ZEA)
; SUM_PDW "REPRESENTS THE CHLOROPHYLL A CONCENTRATION, WHICH CAN BE RECONSTRUCTED FROM THE
; KNOWLEDGE OF THE CONCENTRATION OF THE SEVEN OTHER PIGMENTS.: UITZ PAGE 6.
; SO, SURFACE CHL TIMES ZEU SHOUL BE APPROXIMATELY EQUAL TO SUM_PDW [JEOR]
  IF KEY(VERBOSE) THEN PRINT,ZEU*CHL_SUR,'    VERSUS ' ,SUM_PDW

;##########################################################################################################
; 4) DERIVE THE FRACTIONS OF THE CHLOROPHYLL A CONCENTRATION ASSOCIATED WITH EACH OF THE THREE 
; PHYTOPLANKTONIC CLASSES (FMICRO, FNANO AND FPICO) 
;##########################################################################################################

;===> NOTE MULTIPLY BY VRES TO COMPENSATE FOR THE INCREASED NUMBER OF LAYERS DURING INTERPOLATION [10X]
  FMICRO = VRES*TOTAL((1.41*P_ZEU.FUCO + 1.41* P_ZEU.PERID))/SUM_PDW
  FNANO = VRES*TOTAL((1.27*P_ZEU.HEX_FUCO + 0.35*P_ZEU.BUT_FUCO + 0.60*P_ZEU.ALLO))/SUM_PDW
  FPICO = VRES*TOTAL(( 1.01*P_ZEU.TCHLB+ 0.86*P_ZEU.ZEA))/SUM_PDW
  TOT_FRACTION = FMICRO+ FNANO + FPICO ;THE SUM OF THE 3 FRACTIONS SHOULD BE 1.0
  IF KEY(VERBOSE) THEN PRINT,'THE SUM OF THE 3 FRACTIONS IS: ',TOT_FRACTION

;##########################################################################################################
; 5) MAKE AN OUTPUT STRUCTURE CONTAINING THE FRACTIONS OF THE 3 SIZE CLASSES AND ANY OTHER IMPORTANT INFO
;##########################################################################################################
  S=CREATE_STRUCT('CHL_SUR',CHL_SUR,'ZEU',FLOAT(ZEU),'CHL_ZEU',CHL_ZEU,'SUM_PDW',SUM_PDW,'FMICRO',FMICRO,'FNANO',FNANO,'FPICO',FPICO)
  GONE,ZEU
  RETURN,S
  ;KIM WE MAY WANT TO ADD OTHER INFO TO THE OUTPUT STRUCT?

 
END; #####################  END OF ROUTINE ################################
