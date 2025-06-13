; $ID:	PHYTO_SIZE_HIRATA_NES.PRO,	2023-09-21-13,	USER-KJWH	$
  FUNCTION PHYTO_SIZE_HIRATA_NES, CHL, VERSION=VERSION, VERBOSE=VERBOSE

;+
; NAME:
;   PHYTO_SIZE_HIRATA_NES
;
; PURPOSE:
;   Calculate phytoplankton size classes based on the Northeast shelf modified version of the Hirata PSC model
;
; CATEGORY:
;   Alogrithms
;
; CALLING SEQUENCE:
;   Result = PHYTO_SIZE_HIRATA_NES(CHL)
;
; INPUTS:
;   CHL........ Chlorophyll data
;
; OPTIONAL INPUTS:
;   VERSION..... The version number for the coefficients
;
; KEYWORD PARAMETERS:
;   VERBOSE..... Set this keyword to print steps
;
; OUTPUTS:
;   This function returns the NES version of the Hirata phytoplankton size class algorithm.
;
; OPTIONAL OUTPUTS:
;   
;
; COMMON BLOCKS: 
;   
;
; SIDE EFFECTS:  
;   
;
; RESTRICTIONS:  
;   
;
; EXAMPLE:
; 
;
; NOTES:
;   This is a modification of Hirata et al., 2011 phytoplankton size class algorithm, adpated for the Northeast U.S. continetnal shelf (NES)
;   Hirata, T., Hardman-Mountford, N. J., Brewin, R. J. W., Aiken, J., Barlow, R., Suzuki, K., Isada, T., et al. 2011. Synoptic relationships between surface Chlorophyll-a and diagnostic pigments specific to phytoplankton functional types. Biogeosciences, 8: 311-327.
;   The NES based coefficients were developed by Kyle Turner, University of Rhode Island, Graduate School of Oceanography as part of his MS Thesis
;   Publication to submitted in the Fall of 2020
;   
; COPYRIGHT: 
; Copyright (C) 2020, Department of Commerce, National Oceanic and Atmospheric Administration, National Marine Fisheries Service,
;   Northeast Fisheries Science Center, Narragansett Laboratory.
;   This software may be used, copied, or redistributed as long as it is not sold and this copyright notice is reproduced on each copy made.
;   This routine is provided AS IS without any express or implied warranties whatsoever.
;
; AUTHOR:
;   This program was written on July 02, 2020 by Kimberly J. W. Hyde, Northeast Fisheries Science Center | NOAA Fisheries | U.S. Department of Commerce, 28 Tarzwell Dr, Narragansett, RI 02882
;    
; MODIFICATION HISTORY:
;   Jul 02, 2020 - KJWH: Initial code written - adapted from code sent by Kyle Turner (URI)
;   Jul 08, 2020 - KJWH: Changed NANO_PICO to NANOPICO to be consistent with the "valid" product names
;   Jul 16, 2020 - KJWH: Changed version from V1_0 to VER1 to avoid conflicts with similar "METHODS" (in valids)
;   Sep 15, 2020 - KJWH: Added version 2 coefficients (now the default) based on updated information from K. Turner
;-
; ****************************************************************************************************
  ROUTINE_NAME = 'PHYTO_SIZE_HIRATA_NES'
  COMPILE_OPT IDL2

  IF NONE(VERSION) THEN VERSION = 'VER2'

; ===> Algorithm coefficients
  CASE VERSION OF
    'VER1': BEGIN
      B1_MICRO = 1.0297
      B2_MICRO = -1.6841
      B3_MICRO = -0.1216
      B1_PICO  = -3.4459
      B2_PICO  = 0.6681
      B3_PICO  = 2.2859
    END
    'VER2': BEGIN
      B1_MICRO = 1.0073
      B2_MICRO = -1.7253
      B3_MICRO = -0.0662
      B1_PICO  = -4.5916
      B2_PICO  = 0.5664
      B3_PICO  = 2.3861
    END
    ELSE: MESSAGE, 'ERROR: Version ' + VERSION + ' not recognized.'  
  ENDCASE
  
; ===> Set up blank output arrays
  TEMP = DOUBLE(CHL) & TEMP[*]   = MISSINGS(TEMP)
  MICRO                = TEMP
  NANO                 = TEMP
  NANOPICO             = TEMP
  PICO                 = TEMP
  GONE, TEMP

; ===> Find the "good" data data
  OK_GOOD = WHERE(CHL NE MISSINGS(0.0),COUNT_GOOD)
  IF COUNT_GOOD GT 0 THEN BEGIN
    LCHL = ALOG10(CHL[OK_GOOD])  ; Log the chlorophyll data
  
; ===> Calculated the "Hirata" phytoplankton size fractions (0-1) for the "good" data
    FPICO                            = 1 / ((B1_PICO) + EXP(B2_PICO * LCHL + B3_PICO));
    FPICO[WHERE(FPICO GT 1,/NULL)]   = 1 ; % CORRECT FOR IF FRACTION EXCEEDS 1 OR IS LESS THAN 0
    FPICO[WHERE(FPICO LT 0,/NULL)]   = 0
    FMICRO                           = 1 / ((B1_MICRO) + EXP(B2_MICRO * LCHL + B3_MICRO))
    FMICRO[WHERE(FMICRO GT 1,/NULL)] = 1
    FMICRO[WHERE(FMICRO LT 0,/NULL)] = 0
    FNANO                            = 1 - FMICRO - FPICO
    FNANOPICO                        = FPICO + FNANO
  
  ; ===> Convert to fraction to size-specific chl [mg/m^3]
    MICRO[OK_GOOD]      = CHL[OK_GOOD] * FMICRO
    NANO[OK_GOOD]       = CHL[OK_GOOD] * FNANO
    PICO[OK_GOOD]       = CHL[OK_GOOD] * FPICO
    NANOPICO[OK_GOOD]   = CHL[OK_GOOD] * FNANOPICO
  ENDIF ; COUNT_GOOD GT 0  
  
  RETURN, CREATE_STRUCT($
    'CHLOR_A',                  FLOAT(CHL),$
    'MICRO',                    FLOAT(MICRO),$
    'NANO',                     FLOAT(NANO),$
    'NANOPICO',                 FLOAT(NANOPICO),$
    'PICO',                     FLOAT(PICO),$
    'MICRO_PERCENTAGE',         FLOAT(MICRO)/FLOAT(CHL),$
    'NANO_PERCENTAGE',          FLOAT(NANO)/FLOAT(CHL),$
    'NANOPICO_PERCENTAGE',      FLOAT(NANOPICO)/FLOAT(CHL),$
    'PICO_PERCENTAGE',          FLOAT(PICO)/FLOAT(CHL))



END 
