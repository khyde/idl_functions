; $ID:	PHYTO_SIZE_BREWIN.PRO,	2023-09-21-13,	USER-KJWH	$
  FUNCTION PHYTO_SIZE_BREWIN, CHL, VERSION=VERSION, VERBOSE=VERBOSE

;+
; NAME:
;   PHYTO_SIZE_BREWIN
;
; PURPOSE:
;   Calculate phytoplankton size classes based on the global Brewin PSC model
;
; CATEGORY:
;   ALGORITHM_FUNCTIONS
;
; CALLING SEQUENCE:
;   Result = PHYTO_SIZE_BREWIN($Parameter1$, $Parameter2$, $Keyword=Keyword$, ...)
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
;   This function returns the Brewin phytoplankton size class algorithm.
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
;   PSC = PHYTO_SIZE_BREWIN(1.115)
;
; NOTES:
;   Brewin, R.J.W., Sathyendranath, S., Hirata, T., Lavender, S.J., Barciela, R.M., Hardman-Mountford, N.J., 2010. A three-component model of phytoplankton size class for the Atlantic Ocean. Ecological Modelling 221, 1472?1483. https://doi.org/10.1016/j.ecolmodel.2010.02.014
;   
;   Additional references:
;     Brewin, R.J.W., Sathyendranath, S., Jackson, T., Barlow, R., Brotas, V., Airs, R., Lamont, T., 2015. Influence of light in the mixed-layer on the parameters of a three-component model of phytoplankton size class. Remote Sensing of Environment 168, 437?450. https://doi.org/10.1016/j.rse.2015.07.004
;     Brewin, R.J.W., Ciavatta, S., Sathyendranath, S., Jackson, T., Tilstone, G., Curran, K., Airs, R.L., Cummings, D., Brotas, V., Organelli, E., Dall?Olmo, G., Raitsos, D.E., 2017. Uncertainty in Ocean-Color Estimates of Chlorophyll for Phytoplankton Groups. Front. Mar. Sci. 4. https://doi.org/10.3389/fmars.2017.00104
;   
;;   
; COPYRIGHT: 
; Copyright (C) 2022, Department of Commerce, National Oceanic and Atmospheric Administration, National Marine Fisheries Service,
;   Northeast Fisheries Science Center, Narragansett Laboratory.
;   This software may be used, copied, or redistributed as long as it is not sold and this copyright notice is reproduced on each copy made.
;   This routine is provided AS IS without any express or implied warranties whatsoever.
;
; AUTHOR:
;   This program was written on January 13, 2022 by Kimberly J. W. Hyde, Northeast Fisheries Science Center | NOAA Fisheries | U.S. Department of Commerce, 28 Tarzwell Dr, Narragansett, RI 02882
;    
; MODIFICATION HISTORY:
;   Jan 13, 2022 - KJWH: Initial code written
;-
; ****************************************************************************************************
  ROUTINE_NAME = 'PHYTO_SIZE_BREWIN'
  COMPILE_OPT IDL2
  SL = PATH_SEP()
  
  COMMON _PHYTO_SIZE_BREWIN_NES, SST_COEFFS
  IF KEYWORD_SET(INIT) THEN SST_COEFFS = []    ; Create a NULL structure

  IF NONE(VERSION) THEN VERSION = 'VER1'

  ; ===> Algorithm coefficients
  CASE VERSION OF
    'VER1': BEGIN
      COEFF1 = []
      COEFF2 = []
      COEFF3 = []
      COEFF4 = []
      
    END
    ELSE: MESSAGE, 'ERROR: Version ' + VERSION + ' not recognized.'
  ENDCASE


END ; ***************** End of PHYTO_SIZE_BREWIN *****************
