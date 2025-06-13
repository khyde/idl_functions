; $ID:	FRONT_INDICATORS_MILLER.PRO,	2023-09-21-13,	USER-KJWH	$
  FUNCTION FRONT_INDICATORS_MILLER, GRAD_MAG=GRAD_MAG, GRAD_X=GRAD_X, GRAD_Y=GRAD_Y, CPERS_ORG=CPERS_ORG, THRESHOLD=THRESHOLD, PERSISTENCE=PERSISTENCE, BINS=BINS, $
                                    TRANSFORM=TRANSFORM, FULLSTRUCT=FULLSTRUCT

;+
; NAME:
;   FRONT_INDICATORS_MILLER
;
; PURPOSE:
;   To create frontal indicators based on Miller (2009) and Suberg et al. (2019) 
;
; CATEGORY:
;   FRONTS_FUNCTIONS
;
; CALLING SEQUENCE:
;   Result = FRONT_INDICATORS_MILLER(GRAD_MAG, GRAD_X=GRAD_X, GRAD_Y=GRAD_Y)
;
; REQUIRED INPUTS:
;   GRAD_MAG.......... Gradient magnitude data
;   GRAD_X............ Gradient magnitude X data
;   GRAD_Y............ Gradient magnitude Y data
;   CPERS_ORG......... The cumulative persistence from the previous week
;   THRESHOLD......... An array of 0 & 1 showing where the gradient magnitude exceeds the frontal threshold
;   PERSISTENCE....... The "persistence" threshold
;
; OPTIONAL INPUTS:
;   BINS.............. The bin numbers for remapping (used for testing purposes in order to make images)
;
; KEYWORD PARAMETERS:
;   TRANSFORM......... Keyword to indicate if the data should be log transformed before calculating the frontal indicators
;   FULLSTRUCT........ Keyword to include the temporary variables used to calculate the indicators in the structure
;   
; OUTPUTS:
;   A structure with the frontal metrics
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
; 
;
; NOTES:
;  Miller P. 2009. Composite front maps for improved visibility of dynamic sea-surface features on cloudy SeaWiFS and AVHRR data. Journal of Marine Systems 78:327-336.
;
;  Suberg LA, Miller PI, Wynn RB. 2019. On the use of satellite-derived frontal metrics in time series analyses of shelf-sea fronts, 
;    a study of the Celtic Sea. Deep Sea Research Part I: Oceanographic Research Papers 149:103033.
;   
; COPYRIGHT: 
; Copyright (C) 2021, Department of Commerce, National Oceanic and Atmospheric Administration, National Marine Fisheries Service,
;   Northeast Fisheries Science Center, Narragansett Laboratory.
;   This software may be used, copied, or redistributed as long as it is not sold and this copyright notice is reproduced on each copy made.
;   This routine is provided AS IS without any express or implied warranties whatsoever.
;
; AUTHOR:
;   This program was written on March 19, 2021 by Kimberly J. W. Hyde, Northeast Fisheries Science Center | NOAA Fisheries | U.S. Department of Commerce, 28 Tarzwell Dr, Narragansett, RI 02882
;    
; MODIFICATION HISTORY:
;   Mar 19, 2021 - KJWH: Initial code written
;   Apr 19, 2021 - KJWH: Added TRANSFORM keyword and steps to log-transform the GRAD_CHL data
;   Apr 21, 2021 - KJWH: Added XYMEAN keyword to return the XMEAN and YMEAN in the structure
;   Jul 02, 2021 - KJWH: Updated the log transformation - now just transforming the XMEAN and YMEAN when calculating the FMEAN
;                        Added steps to calculate the variance, standard deviation and persistence indicator
;                        Added PERSISTENCE (threshold) input variable 
;                        Changed XYMEAN keyword to FULLSTRUCT 
;   Jul 14, 2021 - KJWH: Added MASK variable to the output structure    
;                        Added the cumulative persistence variable to the output structure
;                        Added CPERS_ORG input variable for the cumulative persistence from the previous period, if not provided, the CPERS_ORG will be 0                  
;   Oct 27, 2021 - KJWH: Added BINS (i.e. mapping bin numbers) as an optional input.  The values are not used in the program, but are helpful when testing in order to convert L3B arrays into mapped images
;   Jul 31, 2023 - KJWH: Changed THRESHOLD to THRESHOLD_BOX to reflect the change in the frontal threshold calculation
;                        Added steps to determine the fronts based on the new frontal threshold method developed by S. Salois
;-
; ****************************************************************************************************
  ROUTINE_NAME = 'FRONT_INDICATORS_MILLER'
  COMPILE_OPT IDL2
  
  ; ===> Check required input parameters
  IF N_ELEMENTS(PERSISTENCE) NE 1 THEN MESSAGE,'ERROR: Must provide the persistence threshold value'
  IF N_ELEMENTS(GRAD_MAG)    EQ 0 THEN MESSAGE,'ERROR: Must input a data array.'
  IF N_ELEMENTS(GRAD_X) NE N_ELEMENTS(GRAD_MAG) OR N_ELEMENTS(GRAD_Y) NE N_ELEMENTS(GRAD_MAG) OR N_ELEMENTS(THRESHOLD) NE N_ELEMENTS(GRAD_MAG) THEN MESSAGE, 'ERROR: The array sizes of GRAD_MAG, GRAD_X, GRAD_Y and THRESHOLD must be the same.'
  
  PXY = SIZEXYZ(GRAD_MAG,PX=PX,PY=PY,PZ=PZ,N_DIMENSIONS=N_DIMENSIONS)
  IF N_DIMENSIONS NE 3 THEN MESSAGE, 'ERROR: Input array must be three dimensional'

  ; ===> Create blank arrays for the output pixels
  FMEAN=FLTARR(PX,PY) & FMEAN[*]=MISSINGS(0.0) & FPROB=FMEAN & FINTS=FMEAN & XMEAN=FMEAN & YMEAN=FMEAN & FVAR=FMEAN & FSTD=FMEAN & FPERSPROB=FMEAN 
  FPERS = INTARR(PX,PY) & CPERS=FPERS & MASK = FPERS
  
  ; ===> Determine the number of "clear" (cloud free) pixels in the time series 
  NCLEAR = INTARR(PX,PY) & NCLEAR[*] = 0 
  FOR Z=0, PZ-1 DO NCLEAR = NCLEAR+FINITE(GRAD_MAG[*,*,Z])
        
  ; ===> Calculate the gradient magnitude mean on all pixels that have "clear" data
  OK = WHERE(GRAD_MAG EQ MISSINGS(GRAD_MAG), COUNT, COMPLEMENT=CLEAR, NCOMPLEMENT=COUNT_GOOD) ; Find where the GRAD_MAG values are missing and change to 0.0
  IF COUNT_GOOD GT 0 THEN BEGIN     
    GMMEAN = FMEAN
    XGMEAN = MEAN(GRAD_X,/NAN,DIMENSION=3)
    YGMEAN = MEAN(GRAD_Y,/NAN,DIMENSION=3)
    CLR = WHERE(FINITE(XGMEAN) AND FINITE(YGMEAN),CT)
    IF KEYWORD_SET(TRANSFORM) THEN GMMEAN[CLR] = EXP(SQRT(ALOG(XGMEAN[CLR])^2 + ALOG(YGMEAN[CLR])^2)) $   ; Calcualte the GRAD_CHL mean
                              ELSE GMMEAN[CLR] = SQRT(XGMEAN[CLR]^2 + YGMEAN[CLR]^2)                      ; Calculate the GRAD_SST mean
    GMMEAN[WHERE(FINITE(GMMEAN) EQ 0,/NULL)] = MISSINGS(0.0)
  ENDIF

  ; ===> Convert all non-frontal pixels (those below the threshold or missing values) to 0.0
  OK = WHERE(THRESHOLD EQ 0 OR GRAD_MAG EQ MISSINGS(GRAD_MAG), COUNT, COMPLEMENT=OK_GOOD, NCOMPLEMENT=COUNT_GOOD)
  IF COUNT GT 1 THEN BEGIN
    GRAD_MAG[OK] = 0.0
    GRAD_X[OK]   = 0.0
    GRAD_Y[OK]   = 0.0
  ENDIF
      
  ; ===> Calculate the sum of the GRAD_MAG, GRAD_X & GRAD_Y variables for the pixels where GRAD_MAG exceeds the THRESHOLD
  XSUM=FLTARR(PX,PY) & XSUM[*]=0.0 & YSUM=XSUM & XSSQ=XSUM & YSSQ=XSUM 
  FOR Z=0, PZ-1 DO XSUM = XSUM + GRAD_X[*,*,Z]
  FOR Z=0, PZ-1 DO YSUM = YSUM + GRAD_Y[*,*,Z]
  
  ; ===> Look for the number of "valid" GRAD_MAG pixels that exceed the threshold
  NVALID = INTARR(PX,PY) & NVALID[*] = 0.0 
  OK_GOOD = WHERE(GRAD_MAG NE 0.0,/NULL,COUNT)                                ; Look for valid pixels
  IF COUNT EQ 0 THEN GOTO, DONE                                               ; If no pixels exceed the threshold, return the blank arrays
  FOR Z=0, PZ-1 DO BEGIN & OK = WHERE(GRAD_MAG[*,*,Z] NE 0.0,COUNT) & IF COUNT GT 0 THEN NVALID[OK] = NVALID[OK] + 1 & ENDFOR
          
  ; ===> Find the "clear" and "front" pixels where there is at least 1 frontal pixel
  CLEAR = WHERE(NCLEAR GT 0.0,COUNTV)                                         ; Subscripts for all pixels with "clear" (cloud-free) data
  FRONT = WHERE(NVALID NE 0.0,COUNTG)                                         ; Subscripts for all pixels with detected fronts
    
  ; ===> Calculate the frontal probability on all pixels that have "clear" data
  IF COUNTV GT 0 THEN FPROB[CLEAR] = FLOAT(NVALID[CLEAR])/FLOAT(NCLEAR[CLEAR])
   
  ; ===> Calculate the frontal mean on all pixels that exceed the frontal threshold
  IF COUNTG GT 0 THEN BEGIN
    XMEAN[FRONT] = XSUM[FRONT]/NVALID[FRONT]  
    YMEAN[FRONT] = YSUM[FRONT]/NVALID[FRONT]
    IF KEYWORD_SET(TRANSFORM) THEN FMEAN[FRONT] = EXP(SQRT(ALOG(XMEAN[FRONT])^2 + ALOG(YMEAN[FRONT])^2)) $
                              ELSE FMEAN[FRONT] = SQRT(XMEAN[FRONT]^2 + YMEAN[FRONT]^2)
    
    ; ===> Caculate the frontal variance and standard deviation   
    FOR Z=0, PZ-1 DO BEGIN
      GX = GRAD_X[*,*,Z] 
      IF KEYWORD_SET(TRANSFORM) THEN BEGIN & OKX=WHERE(GX GT 0.0,COUNT) & IF COUNT GT 1 THEN GX[OKX] = ALOG(GX[OKX]) & ENDIF
      OK = WHERE(GRAD_MAG[*,*,Z] NE 0.0,COUNT)
      IF COUNT GT 0 THEN BEGIN
        IF KEYWORD_SET(TRANSFORM) THEN XSSQ[OK] = XSSQ[OK] + (GX[OK]-ALOG(XMEAN[OK]))^2 ELSE XSSQ[OK] = XSSQ[OK] + (GX[OK]-XMEAN[OK])^2
      ENDIF
    ENDFOR
    FOR Z=0, PZ-1 DO BEGIN
      GY = GRAD_Y[*,*,Z] & 
      IF KEYWORD_SET(TRANSFORM) THEN BEGIN & OKY=WHERE(GY GT 0.0,COUNT) & IF COUNT GT 1 THEN GY[OKY] = ALOG(GY[OKY]) & ENDIF
      OK = WHERE(GRAD_MAG[*,*,Z] NE 0.0,COUNT)
      IF COUNT GT 0 THEN BEGIN
        IF KEYWORD_SET(TRANSFORM) THEN YSSQ[OK] = YSSQ[OK] + (GY[OK]-ALOG(YMEAN[OK]))^2 ELSE YSSQ[OK] = YSSQ[OK] + (GY[OK]-YMEAN[OK])^2
      ENDIF
    ENDFOR
    FVAR[FRONT] = (XSSQ[FRONT] + YSSQ[FRONT])/NVALID[FRONT]
    IF KEYWORD_SET(TRANSFORM) THEN FSTD[FRONT] = EXP(SQRT(FVAR[FRONT])) $
                              ELSE FSTD[FRONT] = SQRT(FVAR[FRONT])
  
    ; ===> Calculate the frontal intensity on all pixels that exceed the frontal threshold
    FINTS[FRONT] = FMEAN[FRONT] * FPROB[FRONT]
    
    ; ===> Calculate the frontal persistence on all pixels that exceed the persistence threshold
    FPERS[WHERE(NCLEAR EQ 0,/NULL)] = MISSINGS(FPERS)
    PERS = WHERE(FSTD LE PERSISTENCE AND NVALID NE 0.0, COUNTP)
    IF COUNTP GT 0 THEN FPERS[PERS] = 1
    FPERSPROB[PERS] = FPROB[PERS]
  ENDIF  
  
  ; ===> Calculate the cumulative persistence 
;  IF N_ELEMENTS(CPERS_ORG) EQ 0 THEN CPERS_ORG = INTARR([PX,PY])                   ; If the cumulative persistence from the previous period is not provided, start at 0
;  IF N_ELEMENTS(CPERS_ORG) NE N_ELEMENTS(FPERS) THEN MESSAGE, 'ERROR: The number of values from CPERS_ORG must equal FPERS'
;  OK = WHERE(FPERS EQ 0,COUNT,COMPLEMENT=COMPLEMENT,NCOMPLEMENT=NCOMPLEMENT)       ; Find the persistent fronts from the current period
;  IF COUNT GT 0 THEN CPERS_ORG[OK] = 0                                             ; If there is no persistent front, then make the cumulative persistence from the previous period 0
;  CPERS = CPERS_ORG + FPERS*PZ                                                     ; Add the persistence value * then number of days (PZ) to the previous period's cumulative persistence
  
  ; ===> Clean up the output variables and change all non-real values to Inf
  NA = WHERE(FINITE(FMEAN) EQ 0,COUNTNA)
  IF COUNTNA GT 0 THEN BEGIN
    FMEAN[WHERE(FINITE(FMEAN) EQ 0,/NULL)] = MISSINGS(0.0)
    FPROB[WHERE(FINITE(FPROB) EQ 0,/NULL)] = MISSINGS(0.0)
    FINTS[WHERE(FINITE(FINTS) EQ 0,/NULL)] = MISSINGS(0.0)
  ENDIF
  
  ; ===> Create a MASK of the data (note, mask codes 1 and 2 reserved for land and coast respectively)
  MASK[WHERE(NVALID GT 0, /NULL)] = 3                                                 ; Find pixels that are clear with fronts and use the mask code 4
  MASK[WHERE(FPERS  EQ 1, /NULL)] = 4                                                 ; Find pixels with persistent fronts and use the mask code 5
  MASK[WHERE(NVALID EQ 0, /NULL)] = 2                                                 ; Find pixels that are clear but do not have fronts (VALID=0) and use the mask code 3
  MASK[WHERE(NCLEAR EQ 0, /NULL)] = 1                                                 ; Find cloudy/missing pixels (CLEAR = 0) and use the mask code 1
  
  DONE:
  ; ===> Make a MASK structure
  MASK_CODES = [0,1,2,3,4]
  MASK_NAMES = ['Land','Missing data', 'Non-front', 'Front', 'Persistent front']
  MASK_NOTES = 'Mask codes for the frontal indicators are: '
  FOR K=0, N_ELEMENTS(MASK_CODES)-1 DO MASK_NOTES = MASK_NOTES + STRTRIM(MASK_CODES[K],2)+'='+MASK_NAMES[K]+'; '
  MASK_NOTES = STRMID(MASK_NOTES,0,STRLEN(MASK_NOTES)-2)                                ; Remove the last '; '
  MSTR = CREATE_STRUCT('MASK',MASK, 'MASK_CODES', MASK_CODES, 'MASK_NAMES', MASK_NAMES, 'MASK_NOTES', MASK_NOTES)
    
  STRUCT = CREATE_STRUCT('GRADMEAN',GMMEAN,'PERSISTENCE_THRESHOLD',PERSISTENCE,'FCLEAR',NCLEAR,'FVALID',NVALID,'FMEAN',FMEAN,'FPROB',FPROB,'FINTENSITY',FINTS,$
                          'FSTD',FSTD,'FPERSIST',FPERS,'FPERSISTPROB',FPERSPROB,'FMASK',MSTR) ; 'FPERSISTCUM',CPERS,
  IF KEYWORD_SET(FULLSTRUCT) THEN STRUCT = CREATE_STRUCT(STRUCT,'XGMEAN',XGMEAN,'YGMEAN',YGMEAN,'XMEAN',XMEAN,'YMEAN',YMEAN,'XSUM_SQUARED',XSSQ,'YSUM_SQUARED',YSSQ,'FVARIANCE',FVAR)
  RETURN, STRUCT

END ; ***************** End of FRONT_INDICATORS_MILLER *****************
