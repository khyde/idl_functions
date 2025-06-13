; $ID:	PHYTO_PP_MARMAP.PRO,	2020-07-07-17,	USER-KJWH	$

FUNCTION PHYTO_PP_MARMAP,PP=PP,MICRO=MICRO,VERBOSE=verbose, ERROR=ERROR, ERR_MSG=ERR_MSG, MISSING=missing

;+
; NAME:
;   PHYTO_PP_MARMAP
;
; PURPOSE:;
;   This procedure uses the relationship between % Microplankton CHL and PP observed in the MARMAP dataset to estimate 
;   % Microplankton PP from the satelite derived PP and % Microplankton CHL (from Xiaoju Pan's alogorithm)
;
; CATEGORY:
;   CATEGORY
;
; CALLING SEQUENCE:
;
;   Result = FUNCTION_NAME(Parameter1, Parameter2, Foobar)
;
; INPUTS:
;   Parm1:  Describe the positional input parameters here. Note again that positional parameters are shown with Initial Caps.
;
; OPTIONAL INPUTS:
;   Parm2:  Describe optional inputs here. If you don't have any, just delete this section.
;
; KEYWORD PARAMETERS:
;   KEY1: Document keyword parameters like this. Note that the keyword is shown in ALL CAPS!
;
;
; OUTPUTS:
;   This function returns the
;
; OPTIONAL OUTPUTS:  ;
; COMMON BLOCKS:
; SIDE EFFECTS:
; RESTRICTIONS:
; PROCEDURE:
; EXAMPLE:
;
; NOTES:
;  Algorithm derived from the % Microplankton CHL and % Microplankton PP relationship in the MARMAP dataset (calculated by Michael Fogarty)
;
; MODIFICATION HISTORY:
;     Written January 03, 2013 by K.J.W.Hyde, 28 Tarzwell Drive, NMFS, NOAA 02882 (kimberly.hyde@noaa.gov) - Based on IDL code from Xiaoju Pan (xpanx001@gmail.com)
;     
;     
;-
;*************************************************************************************

  ERROR = 0

; CONVERT INPUT DATA TO DOUBLE PRECISION  
  TEMP  = DOUBLE(PP)
  MICRO = DOUBLE(MICRO)
  PP    = DOUBLE(PP)
    
; CREATE TEMP ARRAYS FOR OUTPUT DATA    
  TEMP(*)      = MISSINGS(TEMP)
  MICRO_PP     = TEMP
  NANO_PP      = TEMP
  PER_MICRO_PP = TEMP
  PER_NANO_PP  = TEMP
  
  OK_GOOD = WHERE(MICRO NE MISSINGS(MICRO) AND $             
                  PP    NE MISSINGS(PP)    AND $
                  MICRO GE 0d              AND $
                  PP    GE 0d              AND $
                  FINITE(MICRO)            AND $
                  FINITE(PP),COUNT_GOOD)

  IF COUNT_GOOD LT 1 THEN BEGIN
    ERROR = 1
    ERR_MSG = 'No valid input data to calculate PERCENT MICROPLANKTON PRIMARY PRODUCTION.'
    RETURN, []   ; If no valid input data, then return empty array
  ENDIF                  

  PER_MICRO_PP(OK_GOOD) = 0.822 * MICRO(OK_GOOD) ; Slope is based on a predictive regression model, R^2 = 0.91 (Type 1).  The y-intercept was not significant
  PER_NANO_PP(OK_GOOD)  = 100 - PER_MICRO_PP(OK_GOOD)
  MICRO_PP(OK_GOOD)     = PP(OK_GOOD) * PER_MICRO_PP(OK_GOOD)/100.
  NANO_PP(OK_GOOD)      = PP(OK_GOOD) - MICRO_PP(OK_GOOD) 
  
; ===> RETURN PIGMENT STRUCURE
  RETURN, CREATE_STRUCT('MICRO_CHL',        FLOAT(MICRO),$
                        'TOTAL_PP',         FLOAT(PP),$
                        'MICROPP',        FLOAT(MICRO_PP),$
                        'NANOPICOPP',     FLOAT(NANO_PP),$
                        'MICROPP_PERCENTAGE',    FLOAT(PER_MICRO_PP),$
                        'NANOPICOPP_PERCENTAGE', FLOAT(PER_NANO_PP))

END
