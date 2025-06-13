; $ID:	PHYTO_SIZE_TURNER.PRO,	2023-09-21-13,	USER-KJWH	$
  FUNCTION PHYTO_SIZE_TURNER, CHL, SST=SST, VERSION=VERSION, VERBOSE=VERBOSE, INIT=INIT

;+
; NAME:
;   PHYTO_SIZE_TURNER
;
; PURPOSE:
;   Calculate phytoplankton size classes based on the Northeast shelf modified version of the Turner PSC model
;
; CATEGORY:
;   Algorithms
;
; CALLING SEQUENCE:
;   Result = PHYTO_SIZE_TURNER(CHL, SST=SST)
; 
; REQUIRED INPUTS:
;   CHL...... Chlorophyll data 
;   SST...... Sea surface temperature data
;
; OPTIONAL INPUTS:
;   VERSION.. The version number for the coefficients
;
; KEYWORD PARAMETERS:
;   VERBOSE.. Set this keyword to print steps
;   INIT..... To reset the SST look up table stored in the COMMON block
; 
; OUTPUTS:
;   This function returns a structure containing phytoplankton size class data derived from the TURNER algorithm.
;
; OPTIONAL OUTPUTS:
;   None
;
; COMMON BLOCKS: 
;   _PHYTO_SIZE_TURNER, SST_COEFFS - SST based coefficients from the look up table
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
;  
;   Turner, K. J., C. B. Mouw, K. J. W. Hyde, R. Morse, and A. B. Ciochetto (2021), 
;     Optimization and assessment of phytoplankton size class algorithms for ocean 
;     color data on the Northeast U.S. continental shelf, Remote Sensing of Environment, 267, 112729, 
;     doi:https://doi.org/10.1016/j.rse.2021.112729.
;   
;   The NES based coefficients were developed by Kyle Turner, University of Rhode Island, Graduate School of Oceanography as part of his MS Thesis
;      
;   
; COPYRIGHT: 
; Copyright (C) 2021, Department of Commerce, National Oceanic and Atmospheric Administration, National Marine Fisheries Service,
;   Northeast Fisheries Science Center, Narragansett Laboratory.
;   This software may be used, copied, or redistributed as long as it is not sold and this copyright notice is reproduced on each copy made.
;   This routine is provided AS IS without any express or implied warranties whatsoever.
;
; AUTHOR:
;   This program was written on September 29, 2021 by Kimberly J. W. Hyde, Northeast Fisheries Science Center | NOAA Fisheries | U.S. Department of Commerce, 28 Tarzwell Dr, Narragansett, RI 02882
;    
; MODIFICATION HISTORY:
;   Sep 29, 2021 - KJWH: Initial code written; adapted from PHYTO_SIZE_BREWIN_NES
;   Feb 15, 2022 - KJWH: Updated the Turner et al reference
;   Mar 13, 2023 - KJwh: Changed COMMON variable from _PHYTO_SIZE_BREWIN_NES to _PHYTO_SIZE_TURNER
;-   
; ****************************************************************************************************
  ROUTINE_NAME = 'PHYTO_SIZE_TURNER'

  COMPILE_OPT IDL2

  COMMON _PHYTO_SIZE_TURNER, SST_COEFFS
  IF KEYWORD_SET(INIT) THEN SST_COEFFS = []    ; Create a NULL structure

  IF ~N_ELEMENTS(VERSION) THEN VERSION = 'V1'
  
  ; ===> Look for CHL & SST and make sure the data arrays match
  IF N_ELEMENTS(SST) EQ 0 OR N_ELEMENTS(CHL) EQ 0 THEN MESSAGE, 'ERROR: Both CHL & SST data must be provided as inputs.'
  IF N_ELEMENTS(SST) NE N_ELEMENTS(CHL) THEN MESSAGE,'ERROR: SST and CHL arrays do not match.'

; ===> Algorithm coefficients
  CASE VERSION OF
    'V1': BEGIN
      COEFF1 = 0.8337
      COEFF2 = 0.7830
      COEFF3 = 0.1984
      COEFF4 = 0.3956
      SST_FILE = !S.ALGORITHM_FUNCTIONS + 'TURNER_PSIZE_SST_LUT_VER1.csv'
    END
    ELSE: MESSAGE, 'ERROR: Version ' + VERSION + ' not recognized.'
  ENDCASE
  IF ~FILE_TEST(SST_FILE) THEN MESSAGE, 'ERROR: ' + SST_FILE + ' does not exist.'

; ===> Read the SST_COEFFICIENT file if not in COMMON
  IF IDLTYPE(SST_COEFFS) NE 'STRUCT' THEN SST_COEFFS = CSV_READ(SST_FILE)

; ===> Set up blank output arrays
  TEMP = DOUBLE(CHL) & TEMP[*] = MISSINGS(TEMP)
  MICRO                = TEMP
  NANO                 = TEMP
  NANOPICO             = TEMP
  PICO                 = TEMP
    
; ===> Use the input SST data to find the coeffients
  OK_GOOD = WHERE(CHL NE MISSINGS(CHL) AND SST NE MISSINGS(SST),COUNT_GOOD)
  IF COUNT_GOOD GT 0 THEN BEGIN
    GCHL = CHL[OK_GOOD]
    GSST = SST[OK_GOOD]
    
    FPICO = CHL & FPICO[*,*] = MISSINGS(0.0D)
    FNANOPICO = FPICO
    FNANO = FPICO
    FMICRO = FPICO
    
    OK_MIN = WHERE(GSST LE MIN(SST_COEFFS.SST),COUNT_MIN) & IF COUNT_MIN GT 0 THEN GSST[OK_MIN] = MIN(SST_COEFFS.SST)
    OK_MAX = WHERE(GSST GE MAX(SST_COEFFS.SST),COUNT_MAX) & IF COUNT_MAX GT 0 THEN GSST[OK_MAX] = MAX(SST_COEFFS.SST)
    B = WHERE_SETS(ROUNDS(GSST,2))
    FOR N=0, N_ELEMENTS(B)-1 DO BEGIN
      BSUBS = WHERE_SETS_SUBS(B[N])
      OK_SST = WHERE_NEAREST(SST_COEFFS.SST,FLOAT(B[N].VALUE),COUNT)
      IF COUNT NE 1 THEN MESSAGE, 'ERROR: ' + B[N].VALUE + ' not found in the look-up table.'
      
      COEFF1 = SST_COEFFS[OK_SST].COEFF1
      COEFF2 = SST_COEFFS[OK_SST].COEFF2
      COEFF3 = SST_COEFFS[OK_SST].COEFF3
      COEFF4 = SST_COEFFS[OK_SST].COEFF4
      
      FPICO[BSUBS]     = (COEFF3 * (1 - EXP(-1 * (COEFF4 / COEFF3) * GCHL[BSUBS]))) / GCHL[BSUBS]
      FNANOPICO[BSUBS] = (COEFF1 * (1 - EXP(-1 * (COEFF2 / COEFF1) * GCHL[BSUBS]))) / GCHL[BSUBS]  
      FNANO[BSUBS]     = FNANOPICO[BSUBS] - FPICO[BSUBS]
      FMICRO[BSUBS]    = (GCHL[BSUBS] - (COEFF1 * (1 - EXP(-1 * (COEFF2 / COEFF1) * GCHL[BSUBS])))) / GCHL[BSUBS]
           
    ENDFOR
    
    ; ===> Convert to fraction to size-specific CHL [mg/m^3]
    MICRO[OK_GOOD]      = GCHL * FMICRO
    NANO[OK_GOOD]       = GCHL * FNANO
    PICO[OK_GOOD]       = GCHL * FPICO
    NANOPICO[OK_GOOD]   = GCHL * FNANOPICO
 
   ENDIF

   PSIZE = CREATE_STRUCT($
      'CHLOR_A',       FLOAT(CHL),$
      'SST',           FLOAT(SST),$
      'PSC_MICRO',     FLOAT(MICRO),$
      'PSC_NANO',      FLOAT(NANO),$
      'PSC_NANOPICO',  FLOAT(NANOPICO),$
      'PSC_PICO',      FLOAT(PICO),$
      'PSC_FMICRO',    FLOAT(MICRO)/FLOAT(CHL),$
      'PSC_FNANO',     FLOAT(NANO)/FLOAT(CHL),$
      'PSC_FNANOPICO', FLOAT(NANOPICO)/FLOAT(CHL),$
      'PSC_FPICO',     FLOAT(PICO)/FLOAT(CHL))   
            
   RETURN, PSIZE
   
END ; **************************************** End of PHYTO_SIZE_TURNER ****************************************    
