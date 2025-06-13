; $ID:	ZEU_MM01.PRO,	2020-07-01-12,	USER-KJWH	$
; #########################################################################; 
FUNCTION ZEU_MM01,CHL,MIXED=MIXED
;+
; PURPOSE: CALCULATE EUPHOTIC CHL AND EUPHOTIC DEPTH [ZEU] FROM SURFACE CHL USING THE MODEL OF UITZ ET AL.2006 
;
; CATEGORY: LIGHT
;
;
; INPUTS:
;       CHL ......... SURFACE CHLOROPHYLL CONCENTRATION [MG/M3]
;
;
; KEYWORDS:
;         MIXED.......... USE COEFFICIENTS FOR MIXED [NON-STRATIFIED WATER]
;                  
; OUTPUTS: DEPTH OF THE EUPHOTIC LAYER [1 PERCENT SURFACE RADIANCE]
; 
; 
; 
; 
; REFERENCES:

; 
; COEFFICIENTS IN THIS PROGRAM ARE FROM TABLE 4 IN :
;   UITZ, J, H. CLAUSTRE, A. MOREL, AND S. HOOKER,(2006)
;   VERTICAL DISTRIBUTION OF PHYTOPLANKTON COMMUNITIES IN OPEN OCEAN:
;   AN ASSESSMENT BASED ON SURFACE CHLOROPHYLL;
;   JOURNAL OF GEOPHYSICAL RESEARCH, VOL. 111, C08005, DOI:10.1029/2005JC003207;
;   
;   !NOTE:
;  CALCULATION OF EUPHOTIC DEPTH IS BASED ON [MOREL AND MARITORENA, 2001: [SEE PAGES 6,7 IN UITZ,ET AL (2006)
; "Thus the euphotic  depth was inferred from the [Chla] vertical profile, using a
;  bio-optical model for light propagation. In MB89, the model
;  of Morel [1988] was used. This model has been recently
;  revised [Morel and Maritorena, 2001], yielding minor
;  changes in Zeu (actually slightly increased Zeu values in oligotrophic waters). 
;  This revised model is used in the present study"
;  
; MOREL, A. (1988), OPTICAL MODELING OF THE UPPER OCEAN IN RELATION TO ITS
; BIOGENOUS MATTER CONTENT (CASE 1 WATERS), J. GEOPHYS. RES., 93(C9),
; 10,749– 10,768.  [
;; EXAMPLES: 
;           PRINT,(ZEU_UITZ([0.005,0.01,0.1,1.0,10,100])).ZEU
;           PRINT,(ZEU_UITZ([0.005,0.01,0.1,1.0,10,100],/MIXED)).ZEU
;
; MODIFICATION HISTORY:
;     MAY 30, 2018  WRITTEN BY: J.E. O'REILLY
;     JUN 07, 2018 JEOR: NOW USING 4TH/ ORDER POLYNOMIAL FROM MOREL AND MARITORENA 2001 [FIGURE 6]
;     JUN 11, 2018 JEOR: THE MOREL AND MARITORENA 2001 [FIGURE 6] 
;                        ZEU  =  (CHL_ZEU GT 10.0)* 568.2*CHL_ZEU^(-0.746) +  (CHL_ZEU LE 10.0)* 200.*CHL_ZEU^(-0.293)
;     JUL 12, 2018 - KJWH & JOER - VALIDATED THE POLYNOMIAL EQUATION
;                                  UPDATED THE DOUBLE LINEAR EQUATION
;                                  NOW RETURNING BOTH THE POLYNOMIAL ZEU ('ZEU') AND THE LINEAR ZEU ('ZEU_LIN') IN THE STRUCTURE
;                        
; #########################################################################
;-
;********************
  ROUTINE = 'ZEU_MM01'
;********************
; =========================================================================================
; CALCULATE CHL_ZEU (MG CHL M-2) FROM SATELLITE SURFACE CHLOROPHYLL CONCENTRATION [MG/M-3] 
; =========================================================================================
;CCCCCCCCCCCCCCCCCCC
  CASE (KEY(MIXED)) OF
    0: CHL_ZEU=36.1*FLOAT(CHL LT 1.)*(CHL > 0.)^0.357 + 37.7*FLOAT(CHL GE 1.)*(CHL > 0.)^0.615;
    1: CHL_ZEU=42.1*FLOAT(CHL > 0.)^0.538 
  ENDCASE;CASE (KEY(MIXED)) OF
;CCCCCCCCCCCCCCCCCCCCCCCCCCC
  
  CHL_ZEU(WHERE(CHL_ZEU LE 0.0,/NULL)) = MISSINGS(CHL_ZEU)

; =================================================================
; CALCULATE DEPTH OF EUPHOTIC LAYER USING MOREL & MARITORENA 2001 [SEE FIGURE 6]
; =================================================================
  
  ZEU = 10^(POLY(ALOG10(CHL_ZEU),[2.1236,0.932468,-1.4264,0.52776,-0.07617])) ; USING THE POLYNOMIAL VERSION

; EQUATION 6 IN MOREL & MARITORENA 2001 - USING THE LINEAR VERSION
  A = 912.5*CHL_ZEU^(-0.839)  ;ZEU = 912.5* CHL_ZEU^-0.839 ; WHEN ZEU GT 10 AND LT 102
  B = 426.3*CHL_ZEU^(-0.547)  ;ZEU  =426.3* CHL_ZEU^-0.547 ; WHEN ZEU GT 102 AND LT 180
  ZEU_LIN = ZEU
  OKB = WHERE(A GT 102,COUNTA,COMPLEMENT=OKA)
  ZEU_LIN(OKB) = B(OKB)
  ZEU_LIN(OKA) = A(OKA)


  RETURN,CREATE_STRUCT('CHL_ZEU',CHL_ZEU,'ZEU',ZEU,'ZEU_LIN',ZEU_LIN)


  
END; #####################  END OF ROUTINE ################################
