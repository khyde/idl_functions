; $ID:	PP_2DQY.PRO,	2019-05-14-12,	USER-KJWH	$
; #########################################################################; 
FUNCTION PP_2DQY,  PP=PP,APH=APH, DPAR=DPAR

;+
; NAME:
;   PP_2DQY
;
; PURPOSE:  
;   Calculate the DAILY QUANTUM YIELD 
;
; CATEGORY: 
;   PP
;
; INPUTS:
;   PP ........... Daily primary productivity (mg C m^-3 d^-1)
;   APH .......... Absorption of PAR by phytoplankton (m-1)
;   DPAR ......... The daily PAR irradiance at the sample depth in units of Einsteins (mole quanta m^-2 d^-1)
;
; OPTIONAL INPUTS:
;
;
; KEYWORDS:  
;         
; OUTPUTS:
;   DQY .......... Daily quantum yield at the sample depth (mole C / mole quanta m^-2 d^-1)  
;
; OPTIONAL OUTPUTS:
;
;
; EXAMPLES: 
;         
; EXAMPLES:
;
;
; NOTES:
;   Equation based on information from Robert Vaillancourt
;
; REFERENCES:
;
; COPYRIGHT:
; Copyright (C) 2018, Department of Commerce, National Oceanic and Atmospheric Administration, National Marine Fisheries Service,
;   Northeast Fisheries Science Center, Narragansett Laboratory.
;   This software may be used, copied, or redistributed as long as it is not sold and this copyright notice is reproduced on each copy made.
;   This routine is provided AS IS without any express or implied warranties whatsoever.
;
;   This program was written by John O'Reilly, DOC/NOAA/NMFS/NEFSC Narragansett, RI.  For inquires, contact kimberly.hyde@noaa.gov
;
; MODIFICATION HISTORY:
;     Written:  May 02, 2019 by J.E. O'Reilly, NOAA/NEFSC/Narragansett Laboratory, 28 Tarzwell Drive, 02882 (kimberly.hyde@noaa.gov)
;     Modified: May 14, 2019 - KJWH: Updated formatting and documenation (added copyright)
;                                    Replaced SAME(NOF(PP),NOF(APH),NOF(DPAR)) EQ 0 with N_ELEMENTS(PP) NE N_ELEMENTS(APH) OR N_ELEMENTS(DQY) NE N_ELEMENTS(DPAR)
;                                      to only use IDL based functions.
;   
;
; *****************************************************************************************************************************************
;-
  ROUTINE =  'PP_2DQY'

  IF N_ELEMENTS(PP) NE N_ELEMENTS(APH) OR N_ELEMENTS(DQY) NE N_ELEMENTS(DPAR) THEN MESSAGE,'ERROR: PP, APH, DPAR MUST BE SAME SIZE ARRAYS'

  DQY = PP/(12000*APH *DPAR)
  RETURN,DQY


END; #####################  END OF ROUTINE ################################
