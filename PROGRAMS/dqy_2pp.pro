; $ID:	DQY_2PP.PRO,	2019-05-13-12,	USER-KJWH	$
; #########################################################################; 
FUNCTION DQY_2PP, APH=APH, DPAR=DPAR, DQY=DQY

;+
; NAME: 
;   DQY_2PP
; 
; PURPOSE:  
;   Calculate primary productivity from daily quantum yield 
;
; CATEGORY: 
;   PP
;
; CALLING SEQUENCE:
;   PP = DQY_2PP, APH=APH, DPAR=DPAR, DQY=DQY
;
; INPUTS:
;   DQY ......... The daily quantum yield at the sample depth in units of DAILY QUANTUM YIELD (mole CARBON mole QUANTA_-1 m^-2 d^-1)
;   APH ......... Absorption of PAR by phytoplankton (m^-1)
;   DPAR ........ The daily PAR irradiance at the sample depth in units of einsteins (mole QUANTA m^-2 d^-1)
;
; OPTIONAL INPUTS:
; 
; 
; KEYWORDS:  
; 
;         
; OUTPUTS: 
;   PRIMARY PRODUCTIVITY at the sample depth [mg C m^-3 d^-1]
;
; OPTIONAL OUTPUTS:
; 
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
;
; MODIFICATION HISTORY:
;     Written:  May 02, 2019 by J.E. O'Reilly, NOAA/NEFSC/Narragansett Laboratory, 28 Tarzwell Drive, 02882 (kimberly.hyde@noaa.gov)
;     Modified: May 13, 2019 - KJWH: Updated formatting and documenation (added copyright)
;                                    Replaced SAME(NOF(DQY),NOF(APH),NOF(DPAR)) EQ 0 with N_ELEMENTS(DQY) NE N_ELEMENTS(APH) OR N_ELEMENTS(DQY) NE N_ELEMENTS(DPAR) 
;                                      to only use IDL based functions.
;
; 
; 
; *****************************************************************************************************************************************
;-
  ROUTINE = 'DQY_2PP'


  IF N_ELEMENTS(DQY) NE N_ELEMENTS(APH) OR N_ELEMENTS(DQY) NE N_ELEMENTS(DPAR) THEN MESSAGE,'ERROR: DQY, APH, DPAR MUST BE SAME SIZE ARRAYS'
  
  PP  = (12000.0*APH*DPAR) * DQY
  RETURN,PP


END; #####################  END OF ROUTINE ################################
