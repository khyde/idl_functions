; $ID:	PHYTO_SIZE_HIRATA.PRO,	2023-09-21-13,	USER-KJWH	$
  FUNCTION PHYTO_SIZE_HIRATA, CHL, VERSION=VERSION, VERBOSE=VERBOSE

;+
; NAME:
;   PHYTO_SIZE_HIRATA
;
; PURPOSE:
;   Calculate phytoplankton size classes based on the global Hirata PSC model
;
; CATEGORY:
;   ALGORITHM_FUNCTIONS
;
; CALLING SEQUENCE:
;   Result = PHYTO_SIZE_HIRATA_NES(CHL)
;
; REQUIRED INPUTS:
;   CHL........ Chlorophyll data
;
; OPTIONAL INPUTS:
;   VERSION..... The version number for the coefficients
;
; KEYWORD PARAMETERS:
;   VERBOSE..... Set this keyword to print steps
;
; OUTPUTS:
;   This function returns the Hirata phytoplankton size class algorithm.
;
; OPTIONAL OUTPUTS:
;   None
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
;   PSC = PHYTO_SIZE_HIRATA(1.115)
;
; NOTES:
;   This is a based on:
;     Hirata et al., 2011 phytoplankton size class algorithm, adpated for the Northeast U.S. continetnal shelf (NES)
;     Hirata, T., Hardman-Mountford, N. J., Brewin, R. J. W., Aiken, J., Barlow, R., Suzuki, K., Isada, T., et al. 2011. Synoptic relationships between surface Chlorophyll-a and diagnostic pigments specific to phytoplankton functional types. Biogeosciences, 8: 311-327.
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
;   Aug 12, 2020 - KJWH: Initial code written - adapted from PHYTO_SIZE_HIRATA_NES
;   Mar 03, 2022 - KJWH: Changed version name from VER1 to V1
;                                       Changed output structure names to be consistent with the new PSC_ product names
;-
; ****************************************************************************************************
  ROUTINE_NAME = 'PHYTO_SIZE_HIRATA'
  COMPILE_OPT IDL2

  IF NONE(VERSION) THEN VERSION = 'V1'

; ===> Algorithm coefficients
  CASE VERSION OF
    'V1': BEGIN
      A0_MICRO = 0.9117
      A1_MICRO = -2.7330
      A2_MICRO = 0.4003
      A0_DIATOM = 1.3272
      A1_DIATOM = -3.9828
      A2_DIATOM = 0.1953
      A0_PICO  = 0.1529
      A1_PICO  = 1.0306
      A2_PICO  = -1.5576
      A3_PICO  = -1.8597
      A4_PICO  = 2.9954
    END
    ELSE: MESSAGE, 'ERROR: Version ' + VERSION + ' not recognized.'  
  ENDCASE
  
; ===> Set up blank output arrays
  TEMP = DOUBLE(CHL) & TEMP[*]   = MISSINGS(TEMP)
  MICRO    = TEMP
  NANO     = TEMP
  NANOPICO = TEMP
  PICO     = TEMP
  DIATOM   = TEMP
  DINO     = TEMP         
  GONE, TEMP

; ===> Find the "good" data data
  OK_GOOD = WHERE(CHL NE MISSINGS(0.0),COUNT_GOOD)
  IF COUNT_GOOD GT 0 THEN BEGIN
    LCHL = ALOG10(CHL[OK_GOOD])  ; Log the chlorophyll data
  
; ===> Calculated the "Hirata" phytoplankton size fractions (0-1) for the "good" data
    FPICO                              = (-1 / ((A0_PICO) + EXP(A1_PICO * LCHL + A2_PICO))) + A3_PICO*LCHL + A4_PICO
    FPICO[WHERE(FPICO GT 1,/NULL)]     = 1.0 ; % CORRECT FOR IF FRACTION EXCEEDS 1 OR IS LESS THAN 0
    FPICO[WHERE(FPICO LT 0,/NULL)]     = 0.0
    FMICRO                             = 1 / ((A0_MICRO) + EXP(A1_MICRO * LCHL + A2_MICRO))
    FMICRO[WHERE(FMICRO GT 1,/NULL)]   = 1.0
    FMICRO[WHERE(FMICRO LT 0,/NULL)]   = 0.0
    FDIATOM                            = 1 / ((A0_DIATOM) + EXP(A1_DIATOM * LCHL + A2_DIATOM))
    FDIATOM[WHERE(FDIATOM GT 1,/NULL)] = 1.0
    FDIATOM[WHERE(FDIATOM LT 0,/NULL)] = 0.0
    FDINO                              = FMICRO - FDIATOM
    FNANO                              = 1.0 - FMICRO - FPICO
    FNANOPICO                          = FPICO + FNANO
  
  ; ===> Convert to fraction to size-specific chl [mg/m^3]
    MICRO[OK_GOOD]      = CHL[OK_GOOD] * FMICRO
    NANO[OK_GOOD]       = CHL[OK_GOOD] * FNANO
    PICO[OK_GOOD]       = CHL[OK_GOOD] * FPICO
    NANOPICO[OK_GOOD]   = CHL[OK_GOOD] * FNANOPICO
    DIATOM[OK_GOOD]     = CHL[OK_GOOD] * FDIATOM
    DINO[OK_GOOD]       = CHL[OK_GOOD] * FDINO
  ENDIF ; COUNT_GOOD GT 0  
  
  RETURN, CREATE_STRUCT($
    'CHLOR_A',                  FLOAT(CHL),$
    'PSC_MICRO',                    FLOAT(MICRO),$
    'PSC_NANO',                     FLOAT(NANO),$
    'PSC_NANOPICO',                 FLOAT(NANOPICO),$
    'PSC_PICO',                     FLOAT(PICO),$
    'PSC_DIATOM',                   FLOAT(DIATOM),$
    'PSC_DINOFLAGELLATE',           FLOAT(DINO),$
    'PSC_FMICRO',         FLOAT(MICRO)/FLOAT(CHL),$
    'PSC_FNANO',          FLOAT(NANO)/FLOAT(CHL),$
    'PSC_FNANOPICO',      FLOAT(NANOPICO)/FLOAT(CHL),$
    'PSC_FPICO',          FLOAT(PICO)/FLOAT(CHL),$
    'PSC_FDIATOM',        FLOAT(DIATOM)/FLOAT(CHL),$
    'PSC_FDINOFLAGELLATE',FLOAT(DINO)/FLOAT(CHL))

END 
