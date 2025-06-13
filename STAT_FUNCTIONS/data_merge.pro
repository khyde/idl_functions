; $ID:	DATA_MERGE.PRO,	2023-09-21-13,	USER-KJWH	$
  FUNCTION DATA_MERGE, FILES, SUBSET_MAP=SUBSET_MAP, NC_PROD=NC_PROD, LOG=LOG

;+
; NAME:
;   DATA_MERGE
;
; PURPOSE:
;   Function merges the data from multiple files
;
; CATEGORY:
;   STAT_FUNCTIONS
;
; CALLING SEQUENCE:
;   Result = DATA_MERGE(FILES, SUBSET_MAP=SUBSET_MAP)
;
; REQUIRED INPUTS:
;   FILES.......... Input files to merge
;
; OPTIONAL INPUTS:
;   SUBSET_MAP..... If the input files are L3B, subset the data to a given map
;   NC_PROD........ The netcdf product name if the input file is a .nc
;
; KEYWORD PARAMETERS:
;   LOG............ Log the data when calculating the mean
;
; OUTPUTS:
;   OUTPUT.......... Describe the output of this program or function
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
;   
;   
; COPYRIGHT: 
; Copyright (C) 2021, Department of Commerce, National Oceanic and Atmospheric Administration, National Marine Fisheries Service,
;   Northeast Fisheries Science Center, Narragansett Laboratory.
;   This software may be used, copied, or redistributed as long as it is not sold and this copyright notice is reproduced on each copy made.
;   This routine is provided AS IS without any express or implied warranties whatsoever.
;
; AUTHOR:
;   This program was written on May 04, 2021 by Kimberly J. W. Hyde, Northeast Fisheries Science Center | NOAA Fisheries | U.S. Department of Commerce, 28 Tarzwell Dr, Narragansett, RI 02882
;    
; MODIFICATION HISTORY:
;   May 04, 2021 - KJWH: Initial code written
;   May 10, 2021 - KJWH: Added a step to change the merged data from -NaN to Inf (MISSINGS(0.0))
;   Nov 16, 2022 - KJWH: Now using MAPS_L3B_SUBSET to get the bin numbers for the subset map
;-
; ****************************************************************************************************
  ROUTINE_NAME = 'DATA_MERGE'
  COMPILE_OPT IDL2
  SL = PATH_SEP()
  
  IF N_ELEMENTS(FILES)         LT 1 THEN MESSAGE, 'ERROR: Must provide file names'
  FP = PARSE_IT(FILES,/ALL)
  FTAGS = TAG_NAMES(FP)
  STAGS = ['PERIOD','PROD','COVERAGE','MAP','METHOD']
  FOR S=0, N_ELEMENTS(STAGS)-1 DO IF ~SAME(FP.(WHERE(FTAGS EQ STAGS[S]))) THEN MESSAGE, 'ERROR: All input files do not have the same ' + STAGS[S]

  PR = PRODS_READ(FP[0].PROD)
  IF N_ELEMENTS(LOG) EQ 0 THEN PLOG = PR.LOG ELSE PLOG = LOG

  AMAP = FP[0].MAP
  BLANK = MAPS_BLANK(AMAP,FILL=MISSINGS(0.0))
  IF IS_L3B(AMAP) THEN N_BINS = N_ELEMENTS(MAPS_L3B_BINS(AMAP))
  MOBINS = []
  IF KEYWORD_SET(SUBSET_MAP) AND IS_L3B(AMAP) THEN BLANK = MAPS_L3B_SUBSET(BLANK,INPUT_MAP=AMAP,SUBSET_MAP=L3BSUBMAP,OCEAN_BINS=MOBINS)

  MS = SIZEXYZ(BLANK,PX=PX,PY=PY) & IF PY EQ 0 THEN PY = 1
  ARR  = FLTARR(PX,PY,N_ELEMENTS(FILES)) & ARR[*]=MISSINGS(0.0) 
  SARR = INTARR(PX,PY,N_ELEMENTS(FILES))
  NARR = INTARR(PX,PY)
  FOR F=0, N_ELEMENTS(FILES)-1 DO BEGIN
    IF STRUPCASE(FP[F].EXT) EQ 'SAV' THEN BEGIN
      DAT = STRUCT_READ(FILES[F],STRUCT=S, BINS=BINS)
      TAGS = TAG_NAMES(S)
    ENDIF ELSE BEGIN
      SI = SENSOR_INFO(FILES[F])
      IF N_ELEMENTS(NC_PROD) EQ 0 THEN NPROD=SI.NC_PROD ELSE NPROD = NC_PROD
      IF N_ELEMENTS(NPROD) NE 1 THEN MESSAGE, 'ERROR: need to check the nc_prod'    
      DAT = READ_NC(FILES[F],BINS=BINS,PROD=NPROD,/DATA)
      IF IDLTYPE(DAT) EQ 'STRING' THEN MESSAGE, DAT  
      DAT = VALID_DATA(DAT,PROD=FP[F].PROD)
    ENDELSE
    
    IF DAT EQ [] THEN MESSAGE, 'ERROR: Unable to correctly read ' + FILES[F]
    
    ; ===> Subset the data by the BINS if provided
    IF MOBINS EQ [] THEN BEGIN                                                                                                  ; If no subset map bins
      IF BINS NE [] THEN BEGIN                                                                                                  ; If no bins
        _DATA = BLANK                                                                                                           ; Make a blank array
        _DATA[BINS] = DAT                                                                                                         ; Fill in the blank array associated with the specified bin info with valid data
      ENDIF ELSE _DATA = N  ; BINS NE []                                                                                        ; If no bins or mobins, then _DATA = N
    ENDIF ELSE BEGIN  ; MOBINS = []
      IF BINS NE [] THEN BEGIN
        _DAT = MAPS_L3B_2ARR(DAT,MP=FP[F].MAP,BINS=BINS);FLTARR(N_BINS) & _DAT[*,*] = MISSINGS(_DAT)                                                                      ; Make a blank array for the full l3b array
        _DATA = BLANK                                                                                                           ; Create a blank array the size of MOBINS
        _DATA = _DAT[MOBINS]                                                                                                    ; Fill in the blank array with just the MOBINS data
        DELVAR, _DAT
      ENDIF ELSE _DATA = DAT[0,MOBINS] ; BINS NE []                                                                                 ; Subset the full array (n) with MOBINS
    ENDELSE
    
    ARR[*,*,F] = _DATA
    GONE, DAT
    GONE, _DATA
  
    OK_GOOD = WHERE(ARR[*,*,F] NE MISSINGS(ARR),COUNT)
    STMP = SARR[*,*,F]
    STMP[OK_GOOD] = 1
    IF COUNT GT 1 THEN SARR[*,*,F] = STMP
    NARR[OK_GOOD] = NARR[OK_GOOD] + 1
  ENDFOR ; FILES
  
  IF N_ELEMENTS(FILES) GT 1 THEN SBIT = BITS(SARR,/BIT_POSITION,DIMENSION=3) ELSE SBIT = SARR
  BITNOTE = 'The FILE_BITS contains the "bit" value based on whether the input file ("INFILES") has data at a given pixel location.'

  IF KEYWORD_SET(PLOG) THEN ARR = ALOG(ARR)
  IF N_ELEMENTS(FILES) GT 1 THEN MARR = MEAN(ARR,DIMENSION=3,/NAN) ELSE MARR = ARR
  IF KEYWORD_SET(PLOG) THEN MARR = EXP(MARR)
  OK = WHERE(FINITE(MARR) EQ 0,COUNT_MISS)
  IF COUNT_MISS GT 0 THEN MARR[OK] = MISSINGS(ARR)
  
  
  STR = CREATE_STRUCT('FILES',FILES,'BINS',MOBINS,'MERGED_DATA',MARR,'NUMBER_OBSERVATIONS',NARR,'FILE_BITS',SBIT,'NOTES', BITNOTE)
  RETURN, STR
  
  

END ; ***************** End of DATA_MERGE *****************
