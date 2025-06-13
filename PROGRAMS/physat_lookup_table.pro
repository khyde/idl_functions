; $ID:	PHYSAT_LOOKUP_TABLE.PRO,	2020-07-08-15,	USER-KJWH	$

	PRO PHYSAT_LOOKUP_TABLE

;+
; NAME:
;		PHYSAT_LOOKUP_TABLE
;
; PURPOSE:
;		This procedure generates the LOOK UP TABLE to be used in PHYSAT_ALVAIN.
;
; CATEGORY:
;		Algorithms
;
; CALLING SEQUENCE:
;		
;
; INPUTS:
;		
;
; OPTIONAL INPUTS:
;		
;
; KEYWORD PARAMETERS:
;		
;
;
; OUTPUTS:
;		
;		
; REFERENCES:
;	    Alvain, S., Moulin, C., Dandonneau, Y., Bréon, F.M., 2005. Remote sensing of phytoplankton groups in case 1 waters from global SeaWiFS imagery. 
;	        Deep Sea Research Part I: Oceanographic Research Papers 52 (11), 1989-2004.
;	    
;	    Alvain, S., Moulin, C., Dandonneau, Y., Loisel, H., 2008. Seasonal distribution and succession of dominant phytoplankton groups in the global ocean: A satellite view. 
;	        Global Biogeochemical Cycles 22.
;
; NOTES:
; 
; COPYRIGHT:
; Copyright (C) 2018, Department of Commerce, National Oceanic and Atmospheric Administration, National Marine Fisheries Service,
;   Northeast Fisheries Science Center, Narragansett Laboratory.
;   This software may be used, copied, or redistributed as long as it is not sold and this copyright notice is reproduced on each copy made.
;   This routine is provided AS IS without any express or implied warranties whatsoever.
;
;   This program was adapted by Kimberly Hyde, DOC/NOAA/NMFS/NEFSC Narragansett, RI, kimberly.hyde@noaa.gov (original algorithm code and chemtax_ratio_subsets.csv file provided by Xiaoju Pan).
;
;
; MODIFICATION HISTORY:
;     Written: January 21, 2010 by K.J.W.Hyde, 28 Tarzwell Drive, NMFS, NOAA 02882 (kimberly.hyde@noaa.gov) 
;     Modified: MAR 26, 2019 - KJWH: Reviewed and updated documentation and code
;
;
;-
;	****************************************************************************************************
	ROUTINE_NAME = 'PHYSAT_LOOKUP_TABLE'

;	===> Initialize ERROR to a null string. If errors are encountered ERROR will be set to a message.
;			 The calling routine can check error (e.g.IF ERROR NE 0 then there was a problem and do this or that)
	ERROR = ''

  DO_CHL_TABLE  = 0
  DO_NLW_TABLES = 0
  DO_REF_TABLES = 1

; DATE RANGE FOR THE INPUT FILES
  DATE_RANGE = ['19980101','20071231'] 

  COMPUTER = GET_COMPUTER()
  IF COMPUTER EQ 'HALIBUT' THEN DIR_PROJECTS = 'D:\PROJECTS\PHYTO_FUNCTIONAL\' ELSE DIR_PROJECTS = 'T:\PROJECTS\PHYTO_FUNCTIONAL\'
  DIR_DATA   = 'D:\IDL\DATA\'
  DIR_IN     = 'S:\OC-SEAWIFS-MLAC-NEC\'
  DIR_SAVE   = DIR_IN + 'SAVE\'
  DIR_LKUP   = DIR_PROJECTS + 'LOOK_UP_FILES\'
  DIR_REF    = DIR_PROJECTS + 'NLW_REF\'
    
; CHLOROPHYLL VALUES FOR THE LOOK-UP TABLE    
  CHL_INTERVALS = [0.04,0.06,0.08,0.09,0.1,0.11,0.12,0.13,0.14,0.15,0.16,0.18,0.2,0.24,0.28,0.3,0.35,0.4,0.45,0.5,0.6,0.8,1.0,1.4,1.8,2.0,3.0,4.0,5.0,6.0,8.0,10.0,15.0,20.0,25.0,30.0]
  
; LIST OF WAVELENGTHS FOR THE LOOK-UP TABLE  
  WAVES = ['412','443','490','510','555']
    
  CHL_STRUCT = DIR_LKUP + 'LOOK_UP_TABLE-CHLOROPHYLL_STRUCTURE.SAVE'
  
  IF DO_CHL_TABLE GE 1 THEN BEGIN
    CHL_OVERWRITE = DO_CHL_TABLE GT 1
    IF FILE_TEST(CHL_STRUCT) EQ 1 AND CHL_OVERWRITE EQ 0 THEN GOTO, DO_NLW_STRUCTURE
  
;   FIND CHLOROPHYLL FILES
    CHL_FILES = FILE_SEARCH(DIR_SAVE + '!S_*NEC*CHLOR_A*.SAVE')
    FP = PARSE_IT(CHL_FILES)
    OK = WHERE(FP.DATE_START GE DATE_RANGE[0] AND FP.DATE_START LE DATE_RANGE[1])
    CHL_FILES = CHL_FILES[OK] & FP = FP[OK]
      
  ; LOOP THROUGH EACH CHL FILE THEN FIND THE SUBSCRIPTS FOR EACH CHLOROPHYLL INTERVAL    
    TIMER
    FOR NTH = 0L, N_ELEMENTS(CHL_FILES)-1 DO BEGIN
      CHL = STRUCT_SD_READ(CHL_FILES[NTH])
      PERIOD = FP[NTH].PERIOD
      FOR CTH = 0L, N_ELEMENTS(CHL_INTERVALS)-1 DO BEGIN
        INT = CHL_INTERVALS(CTH)
        INT_TAG = 'CHL$' + REPLACE(NUM2STR(INT,DECIMALS=2),'.','_')                                        ; CREATE TAGNAMES FROM THE CHLOROPHYLL INTERVAL
        OK = WHERE(CHL GE INT-0.005 AND CHL LE INT+0.005,COUNT)                                            ; FIND THE SUBSCRIPTS WHERE CHLOROPHYLL IT +/- 0.01 OF THE INTERVAL VALUE
        IF COUNT GE 1 THEN SUBS = OK ELSE SUBS = MISSINGS[OK]                                              ; IF NO SUBCRIPTS ARE FOUND, MAKE SUBS 'MISSINGS'              
        IF CTH EQ 0 THEN NEW = CREATE_STRUCT(INT_TAG,SUBS) ELSE NEW = TEMPORARY(CREATE_STRUCT(NEW,INT_TAG,SUBS))      ; CREATE STRUCTURE TO HOLD ALL SUBSCRIPTS      
      ENDFOR
      IF NTH EQ 0 THEN STRUCT = CREATE_STRUCT(PERIOD,NEW) ELSE STRUCT = TEMPORARY(CREATE_STRUCT(STRUCT,CREATE_STRUCT(PERIOD,NEW)))
      GONE, NEW
      GONE, CHL
      GONE, SUBS
    ENDFOR  
    SAVE, STRUCT, FILENAME=CHL_STRUCT
    GONE, STRUCT
    PRINT, 'CHLOROPHYLL TIMER'
    TIMER,/STOP
  ENDIF ; DO_CHL_TABLE  
  
  DO_NLW_STRUCTURE:
  IF DO_NLW_TABLES GE 1 THEN BEGIN
    NLW_OVERWRITE = DO_NLW_TABLES GT 1
  
    TIMER
    STRUCT = IDL_RESTORE(CHL_STRUCT)
    PTAGS = TAG_NAMES(STRUCT)
    CTAGS = TAG_NAMES(STRUCT.(0))

;   LOOP THROUGH EACH NLW WAVELENGTH TO CALCULATE THE MEAN FOR THE GIVEN CHLOROHYLL INTERVAL  
    FOR NTH = 0L, N_ELEMENTS(NLWS)-1 DO BEGIN
      NLW_SAVE  = DIR_LKUP + 'NLW_' + NLWS[NTH] + '-CHLOROPHYLL_INTERVAL-MEAN.SAVE'
      IF FILE_TEST(NLW_SAVE) EQ 1 AND NLW_OVERWRITE EQ 0 THEN CONTINUE
      SUM = CREATE_STRUCT(CTAGS,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0) ; STRUCTURE TO HOLD THE NLW 'SUM'
      NUM = CREATE_STRUCT(CTAGS,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0) ; STRUCTURE TO HOLD THE NLW 'NUM' (COUNT)
      AVG = CREATE_STRUCT(CTAGS,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0) ; STRUCTURE TO HOLD THE NLW 'AVG' (MEAN)
      NLW_FILES = FILE_SEARCH(DIR_SAVE + '!S_*NLW_'+NLWS[NTH]+'*.SAVE')    
      FP = PARSE_IT(NLW_FILES)
      FOR PTH = 0L, N_ELEMENTS(PTAGS)-1 DO BEGIN
        PERIOD = STRUCT.(PTH)
        CTAGS  = TAG_NAMES(PERIOD)
        OK = WHERE(FP.PERIOD EQ PTAGS(PTH),COUNT)            
        IF COUNT NE 1 THEN CONTINUE
        FILE = NLW_FILES[OK]
        DATA = STRUCT_SD_READ(FILE)
        FOR CTH = 0L, N_ELEMENTS(CTAGS)-1 DO BEGIN
          SUBS = PERIOD.(CTH)
          OK = WHERE(SUBS NE MISSINGS(SUBS),COUNT)
          IF COUNT EQ 0 THEN CONTINUE        
          NLW = DATA(SUBS)
          OK = WHERE(NLW NE MISSINGS(NLW) AND NLW GT 0.0,COUNT_NUM)
          IF COUNT_NUM EQ 0 THEN CONTINUE
          SUM.(CTH) = SUM.(CTH)+TOTAL(NLW[OK])
          NUM.(CTH) = NUM.(CTH)+COUNT_NUM 
        ENDFOR
      ENDFOR
      
  ;   LOOP THROUGH CTAGS TO CREATE THE MEAN FOR EACH CHLOROPHYLL INTERVAL
      FOR CTH = 0L, N_ELEMENTS(CTAGS)-1 DO BEGIN      
        AVG.(CTH) = SUM.(CTH)/NUM.(CTH)
      ENDFOR
      SAVE, AVG, FILENAME = NLW_SAVE
    ENDFOR  
    PRINT, 'NLW_TIMER'
    TIMER,/STOP
  ENDIF ; DO_NLW_TABLES
  
  IF DO_REF_TABLES GE 1 THEN BEGIN
    REF_OVERWRITE = DO_REF_TABLES GT 1
  
    TIMER
    STRUCT = IDL_RESTORE(CHL_STRUCT)
    PTAGS = TAG_NAMES(STRUCT)
    CTAGS = TAG_NAMES(STRUCT.(0))
 
;   LOOP THROUGH EACH NLW WAVELENGTH TO CALCULATE THE MEAN FOR THE GIVEN CHLOROHYLL INTERVAL  
    FOR NTH = 0L, N_ELEMENTS(NLWS)-1 DO BEGIN
      NLW_SAVE  = DIR_LKUP + 'NLW_' + NLWS[NTH] + '-REFERENCE-CHLOROPHYLL_INTERVAL-MEAN.SAVE'
      IF FILE_TEST(NLW_SAVE) EQ 1 AND REF_OVERWRITE EQ 0 THEN CONTINUE
      SUM = CREATE_STRUCT(CTAGS,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0) ; STRUCTURE TO HOLD THE NLW 'SUM'
      NUM = CREATE_STRUCT(CTAGS,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0) ; STRUCTURE TO HOLD THE NLW 'NUM' (COUNT)
      AVG = CREATE_STRUCT(CTAGS,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0) ; STRUCTURE TO HOLD THE NLW 'AVG' (MEAN)
      NLW_FILES = FILE_SEARCH(DIR_REF + '!S_*NLW_'+NLWS[NTH]+'*.SAVE')    
      FP = PARSE_IT(NLW_FILES)
      FOR PTH = 0L, N_ELEMENTS(PTAGS)-1 DO BEGIN
        PERIOD = STRUCT.(PTH)
        CTAGS  = TAG_NAMES(PERIOD)
        OK = WHERE(FP.PERIOD EQ PTAGS(PTH),COUNT)            
        IF COUNT NE 1 THEN CONTINUE
        FILE = NLW_FILES[OK]
        DATA = STRUCT_SD_READ(FILE)
        FOR CTH = 0L, N_ELEMENTS(CTAGS)-1 DO BEGIN
          SUBS = PERIOD.(CTH)
          OK = WHERE(SUBS NE MISSINGS(SUBS),COUNT)
          IF COUNT EQ 0 THEN CONTINUE        
          NLW = DATA(SUBS)
          OK = WHERE(NLW NE MISSINGS(NLW) AND NLW GT 0.0,COUNT_NUM)
          IF COUNT_NUM EQ 0 THEN CONTINUE
          SUM.(CTH) = SUM.(CTH)+TOTAL(NLW[OK])
          NUM.(CTH) = NUM.(CTH)+COUNT_NUM 
        ENDFOR
      ENDFOR
      
  ;   LOOP THROUGH CTAGS TO CREATE THE MEAN FOR EACH CHLOROPHYLL INTERVAL
      FOR CTH = 0L, N_ELEMENTS(CTAGS)-1 DO BEGIN      
        AVG.(CTH) = SUM.(CTH)/NUM.(CTH)
      ENDFOR
      SAVE, AVG, FILENAME = NLW_SAVE
    ENDFOR  
    PRINT, 'NLW_TIMER'
    TIMER,/STOP
  ENDIF ; DO_REF_TABLES  
  
  

STOP
; 
  

	END; #####################  End of Routine ################################
