; $ID:	FILE_NC_GLOBAL.PRO,	2020-07-08-15,	USER-KJWH	$
; #########################################################################; 
PRO FILE_NC_GLOBAL
;+
; PURPOSE:   EDIT THE GLOBAL ATTRIBUTES IN THE FILES IN !S.GLOBAL_PRODS THAT ARE NEEDED BY WRITE_NC
;
; CATEGORY: 
;
;
; INPUTS: NONE
;
;
; KEYWORDS:  NONE

; OUTPUTS: 
;
;; EXAMPLES:
;
; MODIFICATION HISTORY:
;     JUL 24, 2017  WRITTEN BY: J.E. O'REILLY
;     JUL 25,2017 JEOR: ;===> REMOVE ANY FILES WITH BPROD
;     JUL 26,2017 JEOR: FOR GRAD_CHL: GRAD_X CHANGED TO GRAD_CHL_X AND GRAD_Y CHANGED TO GRAD_CHL_Y [TO AGREE WITH CHANGES TO PRODS_MASTER]
;                       FOR GRAD_SST: GRAD_X CHANGED TO GRAD_SST_X AND GRAD_Y CHANGED TO GRAD_SST_Y [TO AGREE WITH CHANGES TO PRODS_MASTER]
;     JAN 26,2018 JEOR: ADDED REFERENCES FOR CHLOR_A,SST, AND PAR TO MAKE_PPD_VGPM2
;     FEB 08,2018 JEOR: REVISED CHL TAGS FOR  MAKE_PPD_VGPM
;     FEB 12,2018 JEOR: REMOVED 'NA' TAGS FROM STEP MAKE_PPD_VGPM
;-
; #########################################################################

;**************************
  ROUTINE = 'FILE_NC_GLOBAL'
;**************************
  

; ===> SWITCHES 
  MAKE_CHL_PAN       = ''
  MAKE_PPD_VGPM2     = ''
  MAKE_PPD_VGPM      = ''
  MAKE_GRAD_CHL      = 'Y'
  MAKE_GRAD_SST      = ''


;*******************************
  IF KEY(MAKE_CHL_PAN) THEN BEGIN
;******************************
    SWITCHES,MAKE_CHL_PAN,STOPP=STOPP,OVERWRITE=OVERWRITE,VERBOSE=VERBOSE,INIT=INIT,R_FILES=R_FILES,R_DATASETS=R_DATASETS
    PRINT,'THIS STEP ADDS A LOCAL TAG TO CHLOR_A GLOBAL FILES AND MAKES CHL_PAN FILES'
    IF STOPP THEN STOP

    APROD = 'CHLOR_A' &  BPROD = 'CHLOR_A-PAN'
    FILES = FLS(!S.GLOBAL_PRODS + '*' +  APROD + '-GLOBAL.SAV')
    ;===> REMOVE ANY FILES WITH BPROD
    OK = WHERE_STRING(FILES,BPROD,COUNT)
    IF COUNT GE 1 THEN FILES = REMOVE(FILES,OK)
    PLIST,FILES
    ;FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
    FOR NTH = 0,NOF(FILES) -1 DO BEGIN
      FILE = FILES[NTH]
      FP = PARSE_IT(FILE,/ALL)
      IF FP.SENSOR EQ 'SA' THEN FP.SENSOR = 'SEAWIFS_MODISA'

      NOTES = "Chlorophyll a values are derived from Xiaoju Pan's algorithm (2008)."
      NOTES = [NOTES, 'Pan (2008) is a regional algorithm intended for use in the Northeas U.S. Continental Shelf.']  
      NOTES = [NOTES, 'Inputs are remote sensing reflectance data at 488/490, 547/555, and 667/670 wavelengths.']
      NOTES = [NOTES, 'CHL = 10^{A0 + A1*ALOG10(Rrs1/Rrs2) + A2*ALOG10[(Rrs1/Rrs2)^2] + A3*ALOG10[(Rrs1/Rrs2)^3]}']
      
      PFILE,FILE,/R
      OUT = REPLACE(FILE,APROD,BPROD)
      S = IDL_RESTORE(FILE)
      ;===> GET SENSOR REFERENCES:
      F = FLS(!S.GLOBAL_PRODS + 'SEAWIFS-RRS_490-GLOBAL.SAV') & REF_SEAWIFS = STRUCT_READ(F,TAG='REFERENCE._DATA')
      F = FLS(!S.GLOBAL_PRODS + 'MODISA-RRS_488-GLOBAL.SAV')  & REF_MODIS   = STRUCT_READ(F,TAG='REFERENCE._DATA')
    ;  CASE FP.SENSOR OF
    ;    'SEAWIFS': BEGIN & REF = REF_SEAWIFS & END
    ;    'MODISA':  BEGIN & REF = REF_MODIS & END
    ;    'SA':      BEGIN & REF = REF_SEAWIFS & END
    ;  ENDCASE

print, 'There are no "reference" tags for the RRS data.  Do we need to include anything other than the NOTES information from above?'
stop
      REFERENCES = "Pan, X., Mannino, A., Russ, M.E., Hooker, S.B., 2008. Remote sensing of the absorption coefficients and chlorophyll a concentration in the United States southern Middle Atlantic Bight from SeaWiFS and MODIS-Aqua. Journal of Geophysical Research 113, C11022."
      LOCAL = CREATE_STRUCT('NOTES',NOTES)
      S = CREATE_STRUCT(S,LOCAL)
      S.LONG_NAME._DATA = 'Chlorophyll Concentration, Pan Algorithm'
      S.STANDARD_NAME._DATA = 'mass_integrated_per_square_meter_primary_productivity_in_sea_water

      S.REFERENCE._DATA = REFERENCES
      print, 'Jay, I updated the references and notes, but we still need to replace all of the "chloro_a" information in the S structure"
      print, 'Take a look at the LONG_NAME, UNITS, STANDARD_NAME etc. tags'
      ST, S.REFERENCE
      stop
      ;===> WRITE THE NEW STRUCTURE
      SAVE,FILENAME = OUT,S,/VERBOSE
      PFILE,OUT,/M
      IF STOPP THEN STOP
    ENDFOR;FOR NTH = 0,NOF(FILES) -1 DO BEGIN
  ENDIF ; CHLOR_A-PAN    


;*******************************
  IF KEY(MAKE_PPD_VGPM2) THEN BEGIN
;******************************
    SWITCHES,MAKE_PPD_VGPM2,STOPP=STOPP,OVERWRITE=OVERWRITE,VERBOSE=VERBOSE,INIT=INIT,R_FILES=R_FILES,R_DATASETS=R_DATASETS
    PRINT,'THIS STEP ADDS A LOCAL TAG TO CHLOR_A GLOBAL FILES AND MAKES PPD_VGPM2 FILES'
    IF STOPP THEN STOP

    APROD = 'CHLOR_A' &  BPROD = 'PPD-VGPM2'
    FILES = FLS(!S.GLOBAL_PRODS + '*' +  APROD + '-GLOBAL.SAV')
    ;===> REMOVE ANY FILES WITH BPROD
    OK = WHERE_STRING(FILES,BPROD,COUNT)
    IF COUNT GE 1 THEN FILES = REMOVE(FILES,OK)
    PLIST,FILES
    ;FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
    FOR NTH = 0,NOF(FILES) -1 DO BEGIN
      FILE = FILES[NTH]
      FP = PARSE_IT(FILE,/ALL)
      IF FP.SENSOR EQ 'SA' THEN FP.SENSOR = 'SEAWIFS_MODISA'

      NOTES = 'Primary production calculated using Behrenfeld-Falkowsi VGPM Model (1997), but with the pbopt polynomial function replaced with an exponential function from Eppley (1972).'
      NOTES = [NOTES, 'Input data include chlorophyll a (CHL), photosynthetic available radiation (PAR), sea surface temperature (SST) and day length (DL).']
      NOTES = [NOTES, 'CHL and PAR are derived from the ' + FP.SENSOR + ' sensor(s)']
      NOTES = [NOTES, 'SST data are from AVHRR Pathfinder (1997 to May 31, 2002) and GHRSST MUR (June 1, 2002 to present)']
      NOTES = [NOTES, 'DL is calculated based on the day of year and latitude according to Kirk (1994)']

      PFILE,FILE,/R
      OUT = REPLACE(FILE,APROD,BPROD)
      S = IDL_RESTORE(FILE)
      ;===> GET SENSOR REFERENCES:
      F = FLS(!S.GLOBAL_PRODS + 'AVHRR-SST-GLOBAL.SAV')       & REF_AVHRR       = STRUCT_READ(F, TAG='REFERENCES')
      F = FLS(!S.GLOBAL_PRODS + 'MUR-SST-GLOBAL.SAV')         & REF_MUR         = STRUCT_READ(F,TAG = 'REFERENCES')+ 'and JPL MUR MEaSUREs Project. 2015. GHRSST Level 4 MUR Global Foundation Sea Surface Temperature Analysis (v4.1). Ver. 4.1. PO.DAAC, CA, USA.'
      F = FLS(!S.GLOBAL_PRODS + 'SEAWIFS-PAR-GLOBAL.SAV')     & REF_PAR_SEAWIFS = STRUCT_READ(F,TAG = 'REFERENCE._DATA')
      F = FLS(!S.GLOBAL_PRODS + 'MODISA-PAR-GLOBAL.SAV')      & REF_PAR_MODIS   = STRUCT_READ(F,TAG = 'REFERENCE._DATA')
      F = FLS(!S.GLOBAL_PRODS + 'SEAWIFS-CHLOR_A-GLOBAL.SAV') & REF_CHL_SEAWIFS = STRUCT_READ(F,TAG = 'REFERENCE._DATA')
      F = FLS(!S.GLOBAL_PRODS + 'MODISA-CHLOR_A-GLOBAL.SAV')  & REF_CHL_MODIS   = STRUCT_READ(F,TAG = 'REFERENCE._DATA')
      CASE FP.SENSOR OF
        'SEAWIFS': BEGIN & REF_PAR = REF_PAR_SEAWIFS & REF_CHL = REF_CHL_SEAWIFS & END
        'MODISA':  BEGIN & REF_PAR = REF_PAR_SEAWIFS & REF_CHL = REF_CHL_SEAWIFS & END
        'SA':      BEGIN & REF_PAR = REF_PAR_SEAWIFS & REF_CHL = REF_CHL_SEAWIFS & END
      ENDCASE

      REFERENCES = "Behrenfeld & Falkowsi, 1997."
      REFERENCES = REFERENCES + "An algorithm for oceanic front detection in chlorophyll and sst satellite imagery. "
      REFERENCES = REFERENCES + "Journal of Marine Systems 78(3), 319-326., DOI: 0.1016/J.JMARSYS.2008.11.018"
      REFERENCES = [REFERENCES, "Eppley, R.W., 1972. Temperature and phytoplankton growth in the sea. Fishery Bulletin 70, 1063-1085."] ; Reference for the Eppley function
      REFERENCES = [REFERENCES, "Kirk, J.T.O., 1994. Light and Photosynthesis in Aquatic Ecosystems. Cambridge University Press, Cambridge, UK., 509pp."]
      REFERENCES = [REFERENCES, REF_AVHRR, REF_MUR, REF_PAR, REF_CHL]
      LOCAL = CREATE_STRUCT('NOTES',NOTES)
      S = CREATE_STRUCT(S,LOCAL)
      S.REFERENCE._DATA = REFERNCES
      print, 'Jay, I updated the references and notes, but we still need to replace all of the "chloro_a" information in the S structure"
      print, 'Take a look at the LONG_NAME, UNITS, STANDARD_NAME etc. tags'
      PRINT, 'I also replaced the _data in the "reference" tag with the references listed above.'
      ST, S.LONG_NAME
      stop
      ;===> WRITE THE NEW STRUCTURE
      SAVE,FILENAME = OUT,S,/VERBOSE
      PFILE,OUT,/M
      IF STOPP THEN STOP
    ENDFOR;FOR NTH = 0,NOF(FILES) -1 DO BEGIN
  ENDIF    

;*******************************
  IF KEY(MAKE_PPD_VGPM) THEN BEGIN
;******************************
    SWITCHES,MAKE_PPD_VGPM,STOPP=STOPP,OVERWRITE=OVERWRITE,VERBOSE=VERBOSE,INIT=INIT,R_FILES=R_FILES,R_DATASETS=R_DATASETS
    PRINT,'THIS STEP ADDS A LOCAL TAG TO CHLOR_A GLOBAL FILES AND MAKES PPD_VGPM FILES'
    IF STOPP THEN STOP

    APROD = 'CHLOR_A' &  BPROD = 'PPD-VGPM'
    FILES = FLS(!S.GLOBAL_PRODS + '*' +  APROD + '-GLOBAL.SAV')
    ;===> REMOVE ANY FILES WITH BPROD
    OK = WHERE_STRING(FILES,BPROD,COUNT)
    IF COUNT GE 1 THEN FILES = REMOVE(FILES,OK)
    PLIST,FILES
    ;FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
    FOR NTH = 0,NOF(FILES) -1 DO BEGIN
      FILE = FILES[NTH]
      FP = PARSE_IT(FILE,/ALL)
      IF FP.SENSOR EQ 'SA' THEN FP.SENSOR = 'SEAWIFS_MODISA'
      
      NOTES = 'Primary production calculated using Behrenfeld-Falkowsi VGPM Model (1997) with the 7th order polynomail pbopt function of temperature.'
      NOTES = [NOTES, 'Input data include chlorophyll a (CHL), photosynthetic available radiation (PAR), sea surface temperature (SST) and day length (DL).']
      NOTES = [NOTES, 'CHL and PAR are derived from the ' + FP.SENSOR + ' sensor(s)']
      NOTES = [NOTES, 'SST data are from AVHRR Pathfinder (1997 to May 31, 2002) and GHRSST MUR (June 1, 2002 to present)']
      NOTES = [NOTES, 'DL is calculated based on the day of year and latitude according to Kirk (1994)']

      PFILE,FILE,/R
      OUT = REPLACE(FILE,APROD,BPROD)
      S = IDL_RESTORE(FILE)
      ;===> GET SENSOR REFERENCES:
      F = FLS(!S.GLOBAL_PRODS + 'AVHRR-SST-GLOBAL.SAV')       & REF_AVHRR       = STRUCT_READ(F, TAG='REFERENCES')
      F = FLS(!S.GLOBAL_PRODS + 'MUR-SST-GLOBAL.SAV')         & REF_MUR         = STRUCT_READ(F,TAG = 'REFERENCES')+ 'and JPL MUR MEaSUREs Project. 2015. GHRSST Level 4 MUR Global Foundation Sea Surface Temperature Analysis (v4.1). Ver. 4.1. PO.DAAC, CA, USA.'
      F = FLS(!S.GLOBAL_PRODS + 'SEAWIFS-PAR-GLOBAL.SAV')     & REF_PAR_SEAWIFS = STRUCT_READ(F,TAG = 'REFERENCE._DATA')
      F = FLS(!S.GLOBAL_PRODS + 'MODISA-PAR-GLOBAL.SAV')      & REF_PAR_MODIS   = STRUCT_READ(F,TAG = 'REFERENCE._DATA')
      F = FLS(!S.GLOBAL_PRODS + 'SEAWIFS-CHLOR_A-GLOBAL.SAV') & REF_CHL_SEAWIFS = STRUCT_READ(F,TAG = 'REFERENCE._DATA')
      F = FLS(!S.GLOBAL_PRODS + 'MODISA-CHLOR_A-GLOBAL.SAV')  & REF_CHL_MODIS   = STRUCT_READ(F,TAG = 'REFERENCE._DATA')
      CASE FP.SENSOR OF 
        'SEAWIFS': BEGIN & REF_PAR = REF_PAR_SEAWIFS & REF_CHL = REF_CHL_SEAWIFS & END
        'MODISA':  BEGIN & REF_PAR = REF_PAR_SEAWIFS & REF_CHL = REF_CHL_SEAWIFS & END
        'SA':      BEGIN & REF_PAR = REF_PAR_SEAWIFS & REF_CHL = REF_CHL_SEAWIFS & END
      ENDCASE
      
      REFERENCES = "Behrenfeld & Falkowsi, 1997."
      REFERENCES = REFERENCES + "An algorithm for oceanic front detection in chlorophyll and sst satellite imagery. "
      REFERENCES = REFERENCES + "Journal of Marine Systems 78(3), 319-326., DOI: 0.1016/J.JMARSYS.2008.11.018"
      REFERENCES = [REFERENCES, "Kirk, J.T.O., 1994. Light and Photosynthesis in Aquatic Ecosystems. Cambridge University Press, Cambridge, UK., 509pp."]
      REFERENCES = [REFERENCES, REF_AVHRR, REF_MUR, REF_PAR, REF_CHL]
      LOCAL = CREATE_STRUCT('NOTES',NOTES)
      S = CREATE_STRUCT(S,LOCAL)
      S.REFERENCE._DATA = STRJOIN(REFERENCES,';;')
print, 'Jay, I updated the references and notes, but we still need to replace all of the "chloro_a" information in the S structure"
print, 'Take a look at the LONG_NAME, UNITS, STANDARD_NAME etc. tags'
PRINT, 'I also replaced the _data in the "reference" tag with the references listed above.'
CLEAR
;    KIM I DO NOT KNOW WHAT PRECISION, SIGN SHOULD BE IN S.LONG_NAME 
;    KIM THERE ARE A LOT OF TAGS THAT DO NOT RELATE TO PPD REMOVE THEM  AS FOLLOWING:
 NA = ['STARTDIRECTION','ENDDIRECTION','DAY_NIGHT_FLAG','EARTH_SUN_DISTANCE_CORRECTION','PROCESSING_LEVEL',$
      'CDM_DATA_TYPE','IDENTIFIER_PRODUCT_DOI_AUTHORITY']
 S = STRUCT_REMOVE(S,NA)
ST, S.LONG_NAME  
P,  S.TITLE   
P,  S._NAME   
ST, S.UNITS   
ST, S.STANDARD_NAME   
;===> REPLACE TAGS IN S [kim I PUT ??? WHERE I AM NOT SURE
 S.TITLE = 'Primary Productivity Data'
 S.INSTITUTION = 'NOAA,National Marine Fisheries Service,Northeast Fisheries Science Center, Narragansett, RI'
 S.PLATFORM = 'Satellite Data and Computer Model'
 s.INSTRUMENT = 'Computer Model'
 S.LONG_NAME._DATA = 'Primary Productivity, VGPM Model'
 S.UNITS._DATA = 'gC m^2 d^-1'
 S._FILLVALUE._DATA = !VALUES.F_INFINITY
 S.VALID_MIN._DATA =  0.0 ; 
 S.VALID_MAX._DATA =  20.0    ; = PPD = 20 GC/M2/DAY  [kim check this]
 S.NAMING_AUTHORITY = '???'
 S.CREATOR_URL =  '???'
 S.PROJECT =  '???'
 S.LICENSE = '???'
 S.PUBLISHER_NAME = 'NOAA/NMFS/NEFC'
 S.PUBLISHER_EMAIL= 'kimberly.hyde@noaa.gov'
 
 S._NAME  = 'PPD'
 S.CREATOR_NAME = 'Dr.Kimberly J. W. Hyde'
 S.CREATOR_EMAIL = 'kimberly.hyde@noaa.gov'
 S.UNITS._DATA = 'grams Carbon per meter-squared per day'
 S.KEYWORDS = REPLACE(S.KEYWORDS,'Chlorophyll','Primary Productivity')
 ;===>  MAP IS NOT PRESENT IN FP SO MUST FIGURE OUT WHICH MAP [TO GET SPATIALRESOLUTION FROM MAPS_SCALE]
; MAPS_SCALE,'GEQ',KMP_Y=KMP_Y ;KMP_Y
; S.SPATIALRESOLUTION = KMP_Y  ;  ??
 ST,S
 PRINT,S.REFERENCE._DATA
 PRINT,S.LONG_NAME._DATA
 PRINT,S.UNITS._DATA
 PRINT,S._FILLVALUE._DATA
 PRINT,S.VALID_MIN._DATA
 PRINT,S.VALID_MAX._DATA
 PRINT,S.NOTES
 
 
 
    IF STOPP THEN STOP
      ;===> WRITE THE NEW STRUCTURE
      SAVE,FILENAME = OUT,S,/VERBOSE
      PFILE,OUT,/M
      IF STOPP THEN STOP
    ENDFOR;FOR NTH = 0,NOF(FILES) -1 DO BEGIN
    ;FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF

  ENDIF;IF KEY(MAKE_GRAD_CHL) THEN BEGIN
  ;|||||||||||||||||||||||||||||||||||||||||||||||||||||

;*******************************
  IF KEY(MAKE_GRAD_CHL) THEN BEGIN
;******************************
    SWITCHES,MAKE_GRAD_CHL,STOPP=STOPP,OVERWRITE=OVERWRITE,VERBOSE=VERBOSE,INIT=INIT,R_FILES=R_FILES,R_DATASETS=R_DATASETS
    PRINT,'THIS STEP ADDS A LOCAL TAG TO CHLOR_A GLOBAL FILES AND MAKES GRAD_CHL FILES'
    IF STOPP THEN STOP
    
    REFERENCE = "Belkin, I.M., & J.E. O'Reilly, 2009."
    REFERENCE = REFERENCE + "An algorithm for oceanic front detection in chlorophyll and sst satellite imagery. "
    REFERENCE = REFERENCE + "Journal of Marine Systems 78(3), 319-326., DOI: 0.1016/J.JMARSYS.2008.11.018"
  
    
    APROD = ['CHLOR_A','CHLOR_A-OCI'] &  BPROD = 'GRAD_CHL'
    FILES = FLS(!S.GLOBAL_PRODS + '*' +  [APROD] + '-GLOBAL.SAV') 
    ;===> REMOVE ANY FILES WITH BPROD
    OK = WHERE_STRING(FILES,BPROD,COUNT)
    IF COUNT GE 1 THEN FILES = REMOVE(FILES,OK)
    PLIST,FILES 
    ;FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
    FOR NTH = 0,NOF(FILES) -1 DO BEGIN
      FILE = FILES[NTH]
      PFILE,FILE,/R
      IF HAS(FILE,APROD[1]) THEN OUT = REPLACE(FILE,APROD[1],BPROD) ELSE OUT = REPLACE(FILE,APROD[0],BPROD)
      IF ~FILE_MAKE(FILE,OUT,OVERWRITE=OVERWRITE) THEN CONTINUE
      S = IDL_RESTORE(FILE)
      ;===> MAKE A LOCAL STRUCTURE TO ADD TO THE GLOBAL STRUCTURE 
      GRAD_CHL = CREATE_STRUCT('GRAD_CHL','Chlorophyll Gradient Deg/Km')
      GRAD_CHL_X = CREATE_STRUCT('GRAD_CHL_X','Chlorophyll Gradient in the X Direction Deg/Km')
      GRAD_CHL_Y = CREATE_STRUCT('GRAD_CHL_Y','Chlorophyll Gradient in the Y Direction Deg/Km')
      GRAD_DIR = CREATE_STRUCT('GRAD_DIR','Chlorophyll Gradient Direction Degrees from North')
  
      LOCAL = CREATE_STRUCT('LOCAL',CREATE_STRUCT(GRAD_CHL,GRAD_CHL_X,GRAD_CHL_Y,GRAD_DIR,'REFERENCE',REFERENCE))
      S = CREATE_STRUCT(S,LOCAL)
     
      ;===> WRITE THE NEW STRUCTURE
      SAVE,FILENAME=OUT, S,/VERBOSE    
      PFILE,OUT,/M
      IF STOPP THEN STOP
    ENDFOR;FOR NTH = 0,NOF(FILES) -1 DO BEGIN
  ;FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF

  ENDIF;IF KEY(MAKE_GRAD_CHL) THEN BEGIN
;|||||||||||||||||||||||||||||||||||||||||||||||||||||


;*******************************
  IF KEY(MAKE_GRAD_SST) THEN BEGIN
;******************************

    SWITCHES,MAKE_GRAD_SST,STOPP=STOPP,OVERWRITE=OVERWRITE,VERBOSE=VERBOSE,INIT=INIT,R_FILES=R_FILES,R_DATASETS=R_DATASETS
    PRINT,'THIS STEP ADDS A LOCAL TAG TO SST GLOBAL FILES AND MAKES GRAD_SST FILES'
    IF STOPP THEN STOP
    
    REFERENCE = "Belkin, I.M., & J.E. O'Reilly, 2009."
    REFERENCE = REFERENCE + "An algorithm for oceanic front detection in chlorophyll and sst satellite imagery. "
    REFERENCE = REFERENCE + "Journal of Marine Systems 78(3), 319-326., DOI: 0.1016/J.JMARSYS.2008.11.018"
  
    APROD = 'SST' &  BPROD = 'GRAD_SST'
    FILES = FLS(!S.GLOBAL_PRODS + '*' +  APROD + '-GLOBAL.SAV')
  
    ;===> REMOVE ANY FILES WITH BPROD
    OK = WHERE_STRING(FILES,BPROD,COUNT)
    IF COUNT GE 1 THEN FILES = REMOVE(FILES,OK)
    PLIST,FILES
    ;FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
    FOR NTH = 0,NOF(FILES) -1 DO BEGIN
      FILE = FILES[NTH]
      PFILE,FILE,/R
      OUT = REPLACE(FILE,APROD,BPROD)
      S = IDL_RESTORE(FILE)
      ;===> MAKE A LOCAL STRUCTURE TO ADD TO THE GLOBAL STRUCTURE
      GRAD_SST = CREATE_STRUCT('GRAD_SST','Sea Surface Temperature Gradient Degrees Celcius/Km')
      GRAD_SST_X = CREATE_STRUCT('GRAD_SST_X','Sea Surface Temperature Gradient in the X Direction Degrees Celcius/Km')
      GRAD_SST_Y = CREATE_STRUCT('GRAD_SST_Y','Sea Surface Temperature Gradient kn the Y Direction Degrees Celcius/Km')
      GRAD_DIR = CREATE_STRUCT('GRAD_DIR','Sea Surface Temperature Gradient Direction Degrees from North')
      ;===> MUST CALL TAG REFERENCE TO AVOID DUPLICATION WITH REFERENCE TAG IN ORIGINAL GLOBAL STRUCT
      LOCAL = CREATE_STRUCT('LOCAL',CREATE_STRUCT(GRAD_SST,GRAD_SST_X,GRAD_SST_Y,GRAD_DIR,'REFERENCE',REFERENCE))
      S = CREATE_STRUCT(S,LOCAL)
      ;===> WRITE THE NEW STRUCTURE
      SAVE,FILENAME = OUT,S,/VERBOSE
      PFILE,OUT,/M
      IF STOPP THEN STOP
    ENDFOR;FOR NTH = 0,NOF(FILES) -1 DO BEGIN
  ;FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF

  ENDIF;IF KEY(MAKE_GRAD_SST) THEN BEGIN
;|||||||||||||||||||||||||||||||||||||||||||||||||||||



END; #####################  END OF ROUTINE ################################
