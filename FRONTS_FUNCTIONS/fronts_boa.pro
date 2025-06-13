; $ID:	FRONTS_BOA.PRO,	2023-09-21-13,	USER-KJWH	$
;############################################################################
  FUNCTION FRONTS_BOA, ARRAY, LOG=LOG, GRAD_TAG=GRAD_TAG, WIDTH=WIDTH, HEIGHT=HEIGHT, AZIMUTH=AZIMUTH, EPSILON=EPSILON, LANDMASK=LANDMASK
;
; NAME:
;   FRONTS_BOA (BELKIN & O'REILLY ALGORITHM FOR FRONT DETECTION)
;
; PURPOSE:
;   This function detects frontal gradients 2-dimenional image arrays.
;
; CATEGORY:
;   FRONTS
;
; CALLING SEQUENCE:
;   STRUCT = FRONTS_BOA(ARRAY, LOG=LOG, KM=KM) 
;
; REQUIRED INPUTS:
;   ARRAY......... 2D input array
;        
; OPTIONAL INPUTS
;   GRAD_TAG...... Tag name for the gradient magnitude output (default = GRAD_MAG)
;   WIDTH......... Width of the pixels in kilometers in input image array
;   HEIGHT........ Height of the pixels in kilometers in input image array
;   AZIMUTH....... Azimuth angle of the pixels in input image array
;   EPSILON....... Input to MF3_1D_5PT
;   LANDMASK...... Landmask for the image array (to exlude image dialation of land pixels)
; 
; KEYWORD PARAMETERS:
;   LOG........... Indicate whether the image should be log transformed (i.e. CHLOR_A data) before calculating the gradient magnitude
;       
; OUTPUTS:
;   A nested structure with the GRAD_MAG (gradient magnitude), 
;                               GRAD_X (gradient in horizontal direction),
;                               GRAD_Y (gradient in vertical direction),
;                               GRAD_DIR (gradient direction, in degrees), and
;                               FILTERED_PIXELS (pixels removed by MF3_1D_5PT). ;     
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
;   Input data must be a two-dimensional array
;    
; REFERENCE:
;   Belkin, I.M., & J.E. O'Reilly, 2009. An Algorithm for Oceanic Front Detection in Chlorophyll and SST Satellite Imagery.
;         Journal of Marine Systems 78(3), 319-326., doi: 0.1016/J.JMARSYS.2008.11.018 
;   
; PROCEDURE:
;   2D array must be provided
;   For chlorophyll (CHLOR_A) and other log-normally distributed data the arrays 
;   If the input files must be log-transformed using the natural log function (ALOG), before running boa
;   This routine uses idl's CONVOL convolution routine for the edge detector.
;   The kernel is centered over each array element.
;   Array elements that are not finite or are NAN are treated as missing data (NAN by CONVOL).
;   The special median filtering program (MF3_1D_5PT by I.M. Belkin) is used to eliminate noisy data.
;   MF3_1D_5PT (applies a special median filter to noisy images)
;       
; NOTES:
; 
; COPYRIGHT:
;  Copyright (C) 2015, Department of Commerce, National Oceanic and Atmospheric Administration, National Marine Fisheries Service,
;   Northeast Fisheries Science Center, Narragansett Laboratory.
;   This software may be used, copied, or redistributed as long as it is not sold and this copyright notice is reproduced on each copy made.
;   This routine is provided AS IS without any express or implied warranties whatsoever.
;
; AUTHOR:
;  This program was written by Igor Belkin, Graduate School of Oceanography | University of Rhode Island | Narragansett, RI
;                              John E. O'Reilly, Northeast Fisheries Science Center | NOAA Fisheries | U.S. Department of Commerce, 28 Tarzwell Dr, Narragansett, RI 02882
;                              Kimberly Hyde, Northeast Fisheries Science Center | NOAA Fisheries | U.S. Department of Commerce, 28 Tarzwell Dr, Narragansett, RI 02882
;  Question about the code should be direct to kimberly.hyde@noaa.gov
;  Question regarding the method should be directed to igormbelkin@gmail.com
;
; MODIFICATION HISTORY:
;   JAN 17, 2007 - JEOR: Initial code written
;   AUG 25, 2007 - TD:   Fixed GRAD_DIR (it was off by 180 degrees) 
;                        GRAD_DIR=(GRAD_DIR + 180) MOD 360
;   JUN 10, 2008 - KJWH: Simplified program for operational use
;   NOV  4, 2010 - JEOR: Reviewed
;                        Added more documentation, minor modifications (deleted superfluous lines)
;                        Added examples and reference and tested the program.
;   JAN 20, 2011 - IMB:  Jianyu Hu and Fan Zhang - Added code to adjust gradient magnitude for distance (average pixel size)                                                   
;   JAN 22, 2011 - JEOR & IMB: Added keyword KM To accept average size of pixel in input image array (KM is used to correct gradient magnitude for the distance between pixels)
;                        Removed code which smooths (gaussian) image array before edge detection because the smoothing was creating artifacts along coastlines.
;   APR  2, 2012 - IMB:  Added median filter (ESTIMATOR_FILTER)
;   NOV 12, 2015 - KJWH: Created BOASNRA.PRO from BOASNRA_ITERMF.PRO - Now the program only performs the edge detection steps and returns a nested structure with the output data                                                   
;   DEC 22, 2015 - KJWH: Minor updates to formatting  
;   DEC 30, 2015 - KJWH: Updated to remove nar lab specific functions     
;   DEC 31, 2015 - KJWH: Renamed to FRONTS_BOA and removed BOA_ITERMF medium filter of the gradient magnitude and direction step (per I. Belkin's suggestion)       
;   MAR 11, 2016 - KJWH: Added documentation    
;   MAR 30, 2016 - KJWH: Addded WIDTH and HEIGHT keywords and code to use the actual pixels sizes instead of generic dimensions 
;   APR 04, 2016 - KJWH: Corrected potential bug when no WIDTH or HEIGHT values are provided
;   APR 12, 2016 - JEOR: Added IF NONE(WIDTH)  THEN _WIDTH  = 1  ELSE _WIDTH  = WIDTH  ; DEFAULT TO 1, THE APPROXIMATE WIDTH OF A PIXEL IN A 1 KM IMAGE
;                              IF NONE(HEIGHT) THEN _HEIGHT = 1  ELSE _HEIGHT = HEIGHT  ; DEFAULT TO 1, THE APPROXIMATE HEIGHT OF A PIXEL IN A 1 KM IMAGE
;                        To agree with the sobel kernel it is necessary to vertically flip the kernel to get GRAD_Y 
;   APR 14, 2016 - JEOR&KJWH: Explicitly make and apply KERNEL_X and KERNEL_Y
;   APR 14, 2016 - KJWH: Added step to change the GRAD_DIR to INF where GRAD_MAG=0 - GRAD_DIR[WHERE(GRAD_MAG EQ 0.0,/NULL)] = MISSING_INF
;   JUN 27, 2015 - JEOR: Fixed major bug [EXP was missing for CHLOR_A [when LOG = 1]:  FARR = EXP(MF3_1D_5PT(ARR, E
;   JUN 28, 2015 - JEOR: Added IF KEYWORD_SET(LOG) THEN BEGIN;[MUST EXP TO PRESERVE ORIGINAL DATA WHEN LOG=1]
;                               FARR = EXP(MF3_1D_5PT(ARR, EPSILON=EPSILON, ITER=ITER, FILTERED=FILTERED, P5_MAX=P5_MAX, P5_MIN=P5_MIN, DIF_8=DIF_8, ERROR=ERROR))
;                             ENDIF ELSE BEGIN
;                               FARR = MF3_1D_5PT(ARR, EPSILON=EPSILON, ITER=ITER, FILTERED=FILTERED, P5_MAX=P5_MAX, P5_MIN=P5_MIN, DIF_8=DIF_8, ERROR=ERROR)
;                             ENDELSE
;   JUN 29, 2016 - KJWH: Changed NONE() to N_ELEMENTS() to minimize the number of narr lab functions used in this program so it can easily be shared with others
;                        Removed the EXP(MF3_1D_5PT) update from JUN 27-28 because EXP(FARR) is later in the code 
;                        Updated how the mask was applied to the data and now just untransforming the good data 
;                        Added MEDIAN_FILL step
;                        Added MEDFIL tag to the output structure and changed MDFIL tag to MDFILTER
;                        Added WHERE_NOISE
;   JUL 18, 2016 - KJWH: Added a place holder for the azimuth correction
;                        Added UNCOR_GRAD_DIR output to the boa structure
;   AUG 09, 2016 - KJWH: Removed WHERE_NOISE block    
;   AUG 10, 2016 - KJHW: RemovedNOISE_RemovedARRAY FROM THE OUTPUT STRUCTURE   
;   AUG 16, 2016 - JEOR: Added GRAD_DIR-AZIMUTH CORRECTION
;   AUG 17, 2016 - KJWH: Added AZIMUTH check info    
;                        Added ERROR check for valid data.  If all data are MISSINGS, then return an error string.     
;   SEP 23, 2016 - KJWH: ADDED LANDMASK keyword and if provided, the landmask will be excluded from the cloud mask dialation 
;   OCT 21, 2016 - KJWH: Removed GRAD_MAG_RATIO FROM THE OUTPUT STRUCTURE NAME AND NOW JUST RETURNING GRAD_MAG (WHICH WILL BE RENAMED TO GRAD_CHL OR GRAD_DIR IN SAVE_MAKE_FRONTS)          
;   MAR 27, 2017 - KJWH: Now returning the full structure of products, which will then be parsed out using SAVE_MAKE_FRONTS    
;   MAR 15, 2021 - KJWH: Updated documentation
;                        Added COMPIL_OPT IDL2
;                        Changed subscripts from () to []
;                        Moved to FRONT_FUNCTIONS     
;                        Updated the GRAD_X and GRAD_Y tag names depending on the GRAD_TAG          
;   DEC 07, 2022 - KJWH: Now returning both the gradient/pixel and gradient/km in the structure
;   JAN 06, 2023 - KJWH: Updated the output tag names
;-
  ROUTINE_NAME = 'FRONTS_BOA'
  COMPILE_OPT IDL2

; ===> DEFAULTS
  IF N_ELEMENTS(GRAD_TAG) NE 1 THEN GRAD_TAG = 'GRAD_MAG'
  CASE GRAD_TAG OF
    'GRAD_MAG': BEGIN & INPUT_TAG='INPUT_DATA' & GRADX_TAG = 'GRAD_X'    & GRADY_TAG = 'GRAD_Y'    & GRADXKM_TAG='GRAD_XKM'    & GRADYKM_TAG  = 'GRAD_YKM'    & GRADKM_TAG = 'GRAD_MAGKM' &  GRADDIR_TAG = 'GRAD_DIR'    & END
    'GRAD_CHL': BEGIN & INPUT_TAG='CHLOR_A'    & GRADX_TAG = 'GRADX_CHL' & GRADY_TAG = 'GRADY_CHL' & GRADXKM_TAG='GRADX_CHLKM' & GRADYKM_TAG  = 'GRADY_CHLKM' & GRADKM_TAG = 'GRAD_CHLKM' &  GRADDIR_TAG = 'GRADCHL_DIR' & END
    'GRAD_SST': BEGIN & INPUT_TAG='SST'        & GRADX_TAG = 'GRADX_SST' & GRADY_TAG = 'GRADY_SST' & GRADXKM_TAG='GRADX_SSTKM' & GRADYKM_TAG  = 'GRADY_SSTKM' & GRADKM_TAG = 'GRAD_SSTKM' &  GRADDIR_TAG = 'GRADSST_DIR' & END
  ENDCASE

; ===> CONSTANTS
  MISSING_INF = !VALUES.F_INFINITY
  MISSING_NAN = !VALUES.F_NAN

;===> MAKE KERNEL_X FOR CONVOL
  KERNEL_X = FLTARR(3,3)
  KERNEL_X[0,[0,2]] = -1.
  KERNEL_X[2,[0,2]] =  1.
  KERNEL_X[0,1] = -2.
  KERNEL_X[2,1] =  2.
  
;===> MAKE KERNEL_Y FOR CONVOL
  KERNEL_Y= ROTATE(TRANSPOSE(KERNEL_X),7)

; ===> SET UP ARRAYS 
  SZ = SIZE(ARRAY,/DIMENSIONS)      ; DETERMINE THE INPUT ARRAY DIMENSIONS
  PX = SZ[0]                        ; X ARRAY LENGTH
  PY = SZ[1]                        ; Y ARRAY LENGTH
  MASK = BYTARR(PX,PY)              ; MAKE A BLANK BYTE ARRAY FOR THE MASK

;===> SET UP PIXEL DISTANCE AND AZIMUTH ARRAYS
  IF N_ELEMENTS(WIDTH)   EQ 0 THEN WIDTH   = 1                                                ; DEFAULT TO 1, THE APPROXIMATE WIDTH OF A PIXEL IN A 1 KM IMAGE
  IF N_ELEMENTS(HEIGHT)  EQ 0 THEN HEIGHT  = 1                                                ; DEFAULT TO 1, THE APPROXIMATE HEIGHT OF A PIXEL IN A 1 KM IMAGE
  IF N_ELEMENTS(WIDTH) NE N_ELEMENTS(ARRAY) OR N_ELEMENTS(HEIGHT) NE N_ELEMENTS(ARRAY) THEN BEGIN   ; MAKE A DISTANCE ARRAY WITH THE SAME DIMENSIONS AS THE INPUT ARRAY
    _WIDTH  = INTARR(PX,PY) &  _WIDTH[*]  = WIDTH  ; MAKE A BLANK ARRAY & FILL IT WITH THE WIDTH
    _HEIGHT = INTARR(PX,PY) &  _HEIGHT[*] = HEIGHT ; MAKE A BLANK ARRAY & FILL IT WITH THE HEIGHT
  ENDIF ELSE BEGIN
    _WIDTH = WIDTH
    _HEIGHT = HEIGHT
  ENDELSE
  IF N_ELEMENTS(AZIMUTH) EQ 0 THEN AZIMUTH = 0
  IF N_ELEMENTS(AZIMUTH) NE N_ELEMENTS(ARRAY) THEN BEGIN
    _AZIMUTH = INTARR(PX,PY) & AZIMUTH[*] = AZIMUTH
  ENDIF ELSE _AZIMUTH = AZIMUTH
  
; ===> TRANSFORM LOG-NORMALLY DISTRIBUTED DATA
  IF KEYWORD_SET(LOG) THEN ARR = ALOG(ARRAY) ELSE ARR = ARRAY     ; PRESERVE ORIGINAL ARRAY
  
; ===> FILL IN ISOLATED MISSING PIXEL
  ARR = MEDIAN_FILL(ARR,COUNT,BOX=3,FRACT_GOOD=0.67) 

; ===> CHANGE MISSING DATA CODE (INFINITY) TO NAN 
  IF ANY(LANDMASK) THEN OK_MISSING = WHERE(FINITE(ARR) EQ 0 OR LANDMASK EQ 1,/NULL,COUNT_MISSING,NCOMPLEMENT=N_GOOD) $  
                   ELSE OK_MISSING = WHERE(FINITE(ARR) EQ 0,/NULL,COUNT_MISSING,NCOMPLEMENT=N_GOOD)        ; FIND WHERE ARRAY EQUALS INFINITY
  IF N_GOOD EQ 0 THEN RETURN, 'ERROR: NO VALID DATA IN THE ARRAY'
  IF COUNT_MISSING GE 1 THEN BEGIN
    ARR[OK_MISSING] = MISSING_NAN                                 ; CHANGE INFINITY TO NAN
    MASK[OK_MISSING]  = 1                                         ; CHANGE CORRESPONDING PIXELS IN THE MASK TO 1
    ARR_OF_ONES = REPLICATE(1B, 3, 3)                             ; CREATE DIALATION ARRAY
    MASK = DILATE(MASK, ARR_OF_ONES, /PRESERVE_TYPE)              ; DILATE THE MASK TO REMOVE ARTIFACTS AT THE BOUNDARIES OF MISSING DATA (I.E. CLOUDS AND LAND)
  ENDIF

; ===> MEDIAN FILTER    
  FARR = MF3_1D_5PT(ARR, EPSILON=EPSILON, ITER=ITER, FILTERED=FILTERED, P5_MAX=P5_MAX, P5_MIN=P5_MIN, DIF_8=DIF_8, ERROR=ERROR)
  IF SIZE(FARR,/TNAME) EQ 'STRING' THEN MESSAGE, '  ERROR: ' + FARR
          
; ===> EDGE DETECTION USING CONVOL
  GRAD_X = CONVOL(FARR, KERNEL_X, INVALID=MISSING_INF, MISSING=MISSING_INF, /NORMALIZE, /EDGE_TRUNCATE, /NAN) 
  GRAD_Y = CONVOL(FARR, KERNEL_Y, INVALID=MISSING_INF, MISSING=MISSING_INF, /NORMALIZE, /EDGE_TRUNCATE, /NAN)

; ===> COMPUTE GRADIENT MAGNITUDE GRAD_X AND GRAD_Y PER KILOMETER
  GRAD_XKM = GRAD_X/_WIDTH 
  GRAD_YKM = GRAD_Y/_HEIGHT
    
; ===> CALCULATE GRADIENT MAGNITUDE
  GRAD_MAG = SQRT(GRAD_X^2 + GRAD_Y^2)
  GRAD_MAGKM = SQRT(GRAD_XKM^2 + GRAD_YKM^2)
  
; ===> CALCULATE GRADIENT DIRECTION AND CHANGE RADIANS TO DEGREES 
  GRAD_DIR = (ATAN(GRAD_Y, GRAD_X))*!RADEG

; ===> ADJUST TO 0-360 SCHEME (MAKE NEGATIVE DEGREES POSITIVE)
  OK = WHERE(GRAD_DIR LT 0, COUNT)
  IF COUNT GE 1 THEN GRAD_DIR[OK] = 360 - ABS(GRAD_DIR[OK])

; ===> CONVERT DEGREES SO THAT 0 DEGREES IS NORTH AND EAST IS 90 DEGREES
  GRAD_DIR = (360 - GRAD_DIR + 90) MOD 360

; ===> DO AZIMUTH CORRECTION OF THE GRAD_DIR
  ORG_GRAD_DIR = GRAD_DIR
  GRAD_DIR = GRAD_DIR - _AZIMUTH 

; ===> FIND WHERE GRAD_MAG = 0.0 AND CHANGE GRAD_DIR TO MISSINGS
  ORG_GRAD_DIR[WHERE(GRAD_MAG EQ 0.0,/NULL)] = MISSING_INF
  GRAD_DIR[WHERE(GRAD_MAG EQ 0.0,/NULL)] = MISSING_INF
    
; ===> APPLY THE MASK TO THE OUTPUT DATA AND CHANGE NAN BACK TO INFINITY
  OK_MASK=WHERE(MASK EQ 1,COUNT_MASK,COMPLEMENT=GOOD,NCOMPLEMENT=NGOOD)
  IF COUNT_MASK GE 1 THEN BEGIN
    ARR[OK_MASK]        = MISSING_INF & ARR        = NAN_2INFINITY(ARR)
    FARR[OK_MASK]       = MISSING_INF & FARR       = NAN_2INFINITY(FARR)
    GRAD_MAG[OK_MASK]   = MISSING_INF & GRAD_MAG   = NAN_2INFINITY(GRAD_MAG)
    GRAD_DIR[OK_MASK]   = MISSING_INF & GRAD_DIR   = NAN_2INFINITY(GRAD_DIR)
    ORG_GRAD_DIR[OK_MASK] = MISSING_INF & ORG_GRAD_DIR = NAN_2INFINITY(ORG_GRAD_DIR)
    GRAD_X[OK_MASK]     = MISSING_INF & GRAD_X     = NAN_2INFINITY(GRAD_X)
    GRAD_Y[OK_MASK]     = MISSING_INF & GRAD_Y     = NAN_2INFINITY(GRAD_Y)
    GRAD_MAGKM[OK_MASK] = MISSING_INF & GRAD_MAGKM = NAN_2INFINITY(GRAD_MAGKM)
    GRAD_XKM[OK_MASK]   = MISSING_INF & GRAD_XKM   = NAN_2INFINITY(GRAD_XKM)
    GRAD_YKM[OK_MASK]   = MISSING_INF & GRAD_YKM   = NAN_2INFINITY(GRAD_YKM)
  ENDIF
  
; ===> UNTRANSFORM THE GRAD_MAG, GRAD_X & GRAD_Y IF PROD IS CHLOR_A
  IF KEYWORD_SET(LOG) THEN BEGIN
    ARR[GOOD]        = EXP(ARR[GOOD])
    FARR[GOOD]       = EXP(FARR[GOOD])
    GRAD_MAG[GOOD]   = EXP(GRAD_MAG[GOOD]) 
    GRAD_X[GOOD]     = EXP(GRAD_X[GOOD])
    GRAD_Y[GOOD]     = EXP(GRAD_Y[GOOD])
    GRAD_MAGKM[GOOD] = EXP(GRAD_MAGKM[GOOD])
    GRAD_XKM[GOOD]   = EXP(GRAD_XKM[GOOD])
    GRAD_YKM[GOOD]   = EXP(GRAD_YKM[GOOD])
  ENDIF;IF PROD EQ 'CHLOR_A' THEN BEGIN

; ===> CREATE A STRUCTURE WITH ALL OF THE FRONTS DATA
  STR = CREATE_STRUCT((INPUT_TAG),ARRAY, 'MEDFIL',ARR, 'MDFILTER',FARR, (GRAD_TAG),GRAD_MAG, (GRADX_TAG),GRAD_X, (GRADY_TAG),GRAD_Y, $
                     (GRADKM_TAG),GRAD_MAGKM, (GRADXKM_TAG), GRAD_XKM, (GRADYKM_TAG),GRAD_YKM, 'UNCOR_GRAD_DIR',ORG_GRAD_DIR, (GRADDIR_TAG), GRAD_DIR, 'MASK', MASK, 'FILTERED', FILTERED,'AZIMUTH',AZIMUTH)
  
  RETURN, STR
  
END; #####################  END OF ROUTINE ################################
