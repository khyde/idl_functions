; $ID:	PHYTO_SIZE_BREWIN_NES.PRO,	2023-09-21-13,	USER-KJWH	$
  FUNCTION PHYTO_SIZE_BREWIN_NES, CHL, SST=SST, PSIZE=PSIZE, PHYTOSST=PHYTOSST, VERSION=VERSION, VERBOSE=VERBOSE, INIT=INIT

;+
; NAME:
;   PHYTO_SIZE_BREWIN_NES
;
; PURPOSE:
;   Calculate phytoplankton size classes based on the Northeast shelf modified version of the Brewin PSC model
;
; CATEGORY:
;   Algorithms
;
; CALLING SEQUENCE:
;   Result = PHYTO_SIZE_BREWIN(CHL, SST=SST)
; 
;
; INPUTS:
;   CHL...... Chlorophyll data 
;
; OPTIONAL INPUTS:
;   SST...... SST data is necessary to use the SST specific coefficients
;   VERSION.. The version number for the coefficients
;
; KEYWORD PARAMETERS:
;   VERBOSE.. Set this keyword to print steps
; 
; OUTPUTS:
;   This function returns the NES version of the Hirata phytoplankton size class algorithm.
;
; OPTIONAL OUTPUTS:
;   PSIZE...... The structure with phytoplankton size class data calculated with the non-SST specific coefficients
;   SST_PSIZE.. The structure with phytoplankton size class data calculated with the SST specific coefficients
;
; COMMON BLOCKS: 
;   _PHYTO_SIZE_BREWIN_NES, SST - SST based coefficients
;   
; SIDE EFFECTS:  
;
; RESTRICTIONS:  
;
; EXAMPLE:
; 
;
; NOTES:
;   This is a modification of Brewin, R.J.W., Sathyendranath, S., Hirata, T., Lavender, S.J., Barciela, R.M., Hardman-Mountford, N.J., 2010. A three-component model of phytoplankton size class for the Atlantic Ocean. Ecological Modelling 221, 1472?1483. https://doi.org/10.1016/j.ecolmodel.2010.02.014
;   
;   Additional references:
;     Brewin, R.J.W., Sathyendranath, S., Jackson, T., Barlow, R., Brotas, V., Airs, R., Lamont, T., 2015. Influence of light in the mixed-layer on the parameters of a three-component model of phytoplankton size class. Remote Sensing of Environment 168, 437?450. https://doi.org/10.1016/j.rse.2015.07.004
;     Brewin, R.J.W., Ciavatta, S., Sathyendranath, S., Jackson, T., Tilstone, G., Curran, K., Airs, R.L., Cummings, D., Brotas, V., Organelli, E., Dall?Olmo, G., Raitsos, D.E., 2017. Uncertainty in Ocean-Color Estimates of Chlorophyll for Phytoplankton Groups. Front. Mar. Sci. 4. https://doi.org/10.3389/fmars.2017.00104
;   
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
;   Jul 02, 2020 - KJWH: Initial code written
;   Jul 16, 2020 - KJWH: Changed version from V1_0 to VER1 to avoid conflicts with similar "METHODS" (in valids)
;   Sep 15, 2020 - KJWH: Added version 2 coefficients (now the default) based on updated information from K. Turner
;                        Changed the location of the SST LUT from !S.MASTER to !S.ALGORITHM_FUNCTIONS
;                        Added and ERROR statement if the SST_LUT does not exist
;-
; ****************************************************************************************************
  ROUTINE_NAME = 'PHYTO_SIZE_BREWIN_NES'

  COMPILE_OPT IDL2

  COMMON _PHYTO_SIZE_BREWIN_NES, SST_COEFFS
  IF KEYWORD_SET(INIT) THEN SST_COEFFS = []    ; Create a NULL structure

  IF NONE(VERSION) THEN VERSION = 'VER2'

; ===> Algorithm coefficients
  CASE VERSION OF
    'VER1': BEGIN
      COEFF1 = 0.8147
      COEFF2 = 0.7776
      COEFF3 = 0.1509
      COEFF4 = 0.5429
      SST_FILE = !S.ALGORITHM_FUNCTIONS + 'BREWIN_PSIZE_NES_SST_LUT_VER1.csv'
    END
    'VER2': BEGIN
      COEFF1 = 0.8337
      COEFF2 = 0.7830
      COEFF3 = 0.1984
      COEFF4 = 0.3956
      SST_FILE = !S.ALGORITHM_FUNCTIONS + 'BREWIN_PSIZE_NES_SST_LUT_VER2.csv'
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
  SMICRO               = TEMP
  SNANO                = TEMP
  SNANOPICO            = TEMP
  SPICO                = TEMP
  
; ===> Look for SST and make sure the data arrays match
  IF N_ELEMENTS(SST) EQ 0 THEN SST = TEMP  
  IF N_ELEMENTS(SST) NE N_ELEMENTS(CHL) THEN MESSAGE,'ERROR: SST and CHL arrays do not match.'

; ===> Find the "good" data data
  OK_GOOD = WHERE(CHL NE MISSINGS(0.0),COUNT_GOOD)
  IF COUNT_GOOD GT 0 THEN BEGIN
    GCHL = CHL[OK_GOOD]
    FPICO = (COEFF3 * (1 - EXP(-1 * (COEFF4 / COEFF3) * GCHL))) / GCHL
    FNANOPICO = (COEFF1 * (1 - EXP(-1 * (COEFF2 / COEFF1) * GCHL))) / GCHL       ;"piconano" refers to the combined pico and nano populations
    FNANO = FNANOPICO - FPICO;
    FMICRO = (GCHL - (COEFF1 * (1 - EXP(-1 * (COEFF2 / COEFF1) * GCHL)))) / GCHL;

; ===> Convert to fraction to size-specific CHL [mg/m^3]
    MICRO[OK_GOOD]      = GCHL * FMICRO
    NANO[OK_GOOD]       = GCHL * FNANO
    PICO[OK_GOOD]       = GCHL * FPICO
    NANOPICO[OK_GOOD]   = GCHL * FNANOPICO
  ENDIF
  
; ===> Use the input SST data to find the coeffients
  OK_GOOD = WHERE(CHL NE MISSINGS(CHL) AND SST NE MISSINGS(SST),COUNT_GOOD)
  IF COUNT_GOOD GT 0 THEN BEGIN
    GCHL = CHL[OK_GOOD]
    GSST = SST[OK_GOOD]
    
    FPICO = CHL & FPICO[*,*] = MISSINGS(0.0D)
    FNANOPICO = FPICO
    FNANO = FPICO
    FMICRO = FPICO
    
    OK_MIN = WHERE(SST LE MIN(SST_COEFFS.SST),COUNT_MIN) & IF COUNT_MIN GT 0 THEN SST[OK_MIN] = MIN(SST_COEFFS.SST)
    OK_MAX = WHERE(SST GE MAX(SST_COEFFS.SST),COUNT_MAX) & IF COUNT_MAX GT 0 THEN SST[OK_MAX] = MAX(SST_COEFFS.SST)
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
    SMICRO[OK_GOOD]      = GCHL * FMICRO
    SNANO[OK_GOOD]       = GCHL * FNANO
    SPICO[OK_GOOD]       = GCHL * FPICO
    SNANOPICO[OK_GOOD]   = GCHL * FNANOPICO
 
   ENDIF

   PSIZE = CREATE_STRUCT($
      'CHLOR_A',                  FLOAT(CHL),$
      'MICRO',                    FLOAT(MICRO),$
      'NANO',                     FLOAT(NANO),$
      'NANOPICO',                 FLOAT(NANOPICO),$
      'PICO',                     FLOAT(PICO),$
      'MICRO_PERCENTAGE',         FLOAT(MICRO)/FLOAT(CHL),$
      'NANO_PERCENTAGE',          FLOAT(NANO)/FLOAT(CHL),$
      'NANOPICO_PERCENTAGE',      FLOAT(NANOPICO)/FLOAT(CHL),$
      'PICO_PERCENTAGE',          FLOAT(PICO)/FLOAT(CHL))   
      
   PHYTOSST = CREATE_STRUCT($
      'CHLOR_A',                  FLOAT(CHL),$
      'SST',                      FLOAT(SST),$
      'MICRO',                    FLOAT(SMICRO),$
      'NANO',                     FLOAT(SNANO),$
      'NANOPICO',                 FLOAT(SNANOPICO),$
      'PICO',                     FLOAT(SPICO),$
      'MICRO_PERCENTAGE',         FLOAT(SMICRO)/FLOAT(CHL),$
      'NANO_PERCENTAGE',          FLOAT(SNANO)/FLOAT(CHL),$
      'NANOPICO_PERCENTAGE',      FLOAT(SNANOPICO)/FLOAT(CHL),$
      'PICO_PERCENTAGE',          FLOAT(SPICO)/FLOAT(CHL))   
      
   STRUCT = STRUCT_REMOVE(PHYTOSST,'CHLOR_A')
   STRUCT = STRUCT_RENAME(STRUCT,['MICRO','NANO','NANOPICO','PICO','MICRO_PERCENTAGE','NANO_PERCENTAGE','NANOPICO_PERCENTAGE','PICO_PERCENTAGE'],['SST_MICRO','SST_NANO','SST_NANOPICO','SST_PICO','SST_MICRO_PERCENTAGE','SST_NANO_PERCENTAGE','SST_NANOPICO_PERCENTAGE','SST_PICO_PERCENTAGE'],/STRUCT_ARRAYS)
   STRUCT = STRUCT_MERGE(PSIZE,STRUCT)
      
   RETURN, STRUCT
   
END ; **************************************** E N D   O F    P R O G R A M ****************************************    
