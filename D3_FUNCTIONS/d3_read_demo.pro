; $ID:	D3_READ_DEMO.PRO,	2020-07-01-12,	USER-KJWH	$
;+
; ######################################################################### 
  PRO D3_READ_DEMO

;  PURPOSE:   DEMO FOR D3_READ

; CATEGORY: D3 FAMILY
  
; KEYWORDS:
;         NONE 
;                    
; MODIFICATION HISTORY:
;     MAR 31,2015 WRITTEN BY: J.E. O'REILLY
; #########################################################################
;-

;***************************
ROUTINE_NAME  = 'D3_READ_DEMO'
;***************************
;===> DEFAULTS
LAND_CODE = -999.0
;===> HARD-WIRED FOR TESTING
DIR = !S.IDL_DEMO +'D3_INTERP_DEMO' + PATH_SEP() + 'D3' + PATH_SEP() + 'TEST_L3B_SUBSET' + PATH_SEP()
D3_FILE = FLS(DIR,'D3-PXY*-DATA.FLT')

D3_FILE = !S.OC + 'OCCCI/L3B4/D3/CHLOR_A-OCI/D3_20181201_20200131-OCCCI-V4_2-L3B4-PXY_1_23761676-CHLOR_A-OCI-INTERP.FLT'

;===> #############   SWITCHES   ############################
  DO_SITES				=	'Y'; 
 ;|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||

;******************************
IF KEY(DO_SITES) THEN BEGIN
;******************************
  , 'DO_SITES'
  PRINT,'THIS STEP PRINTS THE MINMAX OF PSERIES FROM SPECIFIC LOCATIONS'
  SWITCHES,DO_SITES,STOPP=STOPP,OVERWRITE=OVERWRITE,VERBOSE=VERBOSE,INIT=INIT,R_FILES=R_FILES,R_DATASETS=R_DATASETS
  IF STOPP THEN STOP
  SITES = ['GB_S_FLANK','GB_S_FLANK_2','GB_TMF','BAY_OF_FUNDY',$
    'GOM_CEN','BROWNS_BANK','CHES BAY LIGHT','AMBROSE LIGHT','BOOTH BAY HARBOR',$
    'CAPE HATTERAS SBF','HUDSON CANYON']
  ;FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
  FOR N = 0,N_ELEMENTS(SITES) -1 DO BEGIN
    SITE = SITES(N)
    LL = LOCATE(SITE)
    LON = LL.LON
    LAT = LL.LAT
    
    S = D3_READ(D3_FILE,LON=LON,LAT=LAT) & PRINT,SITE & P,MM(S)
  ENDFOR;FOR N = 0,N_ELEMENTS(SITES) -1 DO BEGIN
  ;FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
  
  IF VERBOSE THEN , 'DO_SITES'
ENDIF ; IF KEY(DO_SITES) THEN BEGIN
;||||||||||||||||||||||||||||||||||||||
; 



 IF VERBOSE THEN 

END; #####################  END OF ROUTINE ################################
