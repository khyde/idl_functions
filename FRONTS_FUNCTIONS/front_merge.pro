; $ID:	FRONT_MERGE.PRO,	2023-09-21-13,	USER-KJWH	$
  FUNCTION FRONT_MERGE, FILES, SUBSET_MAP=SUBSET_MAP, SST_THRESHOLD=SST_THRESHOLD, CHL_THRESHOLD=CHL_THRESHOLD

;+
; NAME:
;   FRONT_MERGE
;
; PURPOSE:
;   Function to merge frontal data from multiple files
;
; CATEGORY:
;   FRONTS_FUNCTIONS
;
; CALLING SEQUENCE:
;   Result = FRONT_MERGE($Parameter1$, $Parameter2$, $Keyword=Keyword$, ...)
;
; REQUIRED INPUTS:
;   FILES.......... GRAD_SST or GRAD_CHL files
;
; OPTIONAL INPUTS:
;   SUBSET_MAP..... If the input files are L3B, subset the data to a given map
;   SST_THRESHOLD..
;   CHL_THRESHOLD..
;
; KEYWORD PARAMETERS:
;   KEY1........... Document keyword parameters like this. Note that the keyword is shown in ALL CAPS!
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
;   $Citations or any other useful notes$
;   
; COPYRIGHT: 
; Copyright (C) 2021, Department of Commerce, National Oceanic and Atmospheric Administration, National Marine Fisheries Service,
;   Northeast Fisheries Science Center, Narragansett Laboratory.
;   This software may be used, copied, or redistributed as long as it is not sold and this copyright notice is reproduced on each copy made.
;   This routine is provided AS IS without any express or implied warranties whatsoever.
;
; AUTHOR:
;   This program was written on April 21, 2021 by Kimberly J. W. Hyde, Northeast Fisheries Science Center | NOAA Fisheries | U.S. Department of Commerce, 28 Tarzwell Dr, Narragansett, RI 02882
;    
; MODIFICATION HISTORY:
;   Apr 21, 2021 - KJWH: Initial code written
;   Jun 28, 2021 - KJWH: Added steps to also merge the INDATA found in the fronts files
;   Nov 16, 2022 - KJWH: Now using MAPS_L3B_SUBSET to get the bin numbers for the subset map - MAY NEED TO CONFIRM OUTPUTS ARE CORRECT
;-
; ****************************************************************************************************
  ROUTINE_NAME = 'FRONT_MERGE'
  COMPILE_OPT IDL2
  SL = PATH_SEP()
  
  IF N_ELEMENTS(FILES)         LT 1 THEN MESSAGE, 'ERROR: Must provide file names'
  IF N_ELEMENTS(SST_THRESHOLD) EQ 0 THEN SST_THRESHOLD = 0.4
  IF N_ELEMENTS(CHL_THRESHOLD) EQ 0 THEN CHL_THRESHOLD = 0.01
  
  FP = PARSE_IT(FILES,/ALL)
  FTAGS = TAG_NAMES(FP)
  STAGS = ['PERIOD','PROD','ALG','COVERAGE','MAP','METHOD']
  FOR S=0, N_ELEMENTS(STAGS)-1 DO IF ~SAME(FP.(WHERE(FTAGS EQ STAGS[S]))) THEN MESSAGE, 'ERROR: All input files do not have the same ' + STAGS[S]
  
  CASE FP[0].PROD OF
    'GRAD_SST': BEGIN & GP = '_SST' & PLOG = 0 & THRESHOLD = SST_THRESHOLD & OTAG = 'SST' & END
    'GRAD_CHL': BEGIN & GP = '_CHL' & PLOG = 1 & THRESHOLD = CHL_THRESHOLD & OTAG = 'CHLOR_A' & END
  ENDCASE
  
  AMAP = FP[0].MAP
  BLANK = MAPS_BLANK(AMAP,FILL=MISSINGS(0.0)) 
  IF IS_L3B(AMAP) THEN N_BINS = N_ELEMENTS(MAPS_L3B_BINS(AMAP))
  
  ; ===> Get the input map info and map size
  AMAP = FP[0].MAP                                                                                                             ; Map name
  MS = MAPS_SIZE(AMAP, PX=PX, PY=PY)                                                                                           ; Get the size of the map

  ; ===> Get the bin numbers of the subset map
  MOBINS = []
  IF N_ELEMENTS(L3BSUBMAP) EQ 1 THEN BLANK = [0,MAPS_L3B_SUBSET(MAPS_BLANK(AMAP),INPUT_MAP=AMAP,SUBSET_MAP=L3BSUBMAP,OCEAN_BINS=MOBINS)] $ ; Get the BIN values for the subset map
                                ELSE IF IS_L3B(AMAP) THEN MOBINS = MAPS_L3B_BINS(AMAP)                                         ; Get the BIN values of the input map if it is an L3B map and no subset map is provided
  IF MOBINS NE [] THEN BEGIN & PX = 1  & PY = N_ELEMENTS(MOBINS) & ENDIF 
  
  IF PY EQ 0 THEN PY = 1
  GARR = FLTARR(PX,PY,N_ELEMENTS(FILES)) & GARR[*]=MISSINGS(0.0) & XARR=GARR & YARR=GARR & OARR=GARR
  SARR = INTARR(PX,PY,N_ELEMENTS(FILES)) 
  ORGFILES = []
  FOR F=0, N_ELEMENTS(FILES)-1 DO BEGIN
    
    D = STRUCT_READ(FILES[F],STRUCT=S)
    BINS = S.BINS 
    TAGS = TAG_NAMES(S) & INTAGS = WHERE(STRPOS(TAGS,'INDATA_') GE 0,COUNT)
    INSTRUCT = STRUCT_COPY(S,INTAGS)
    ORGFILES = [ORGFILES,S.INFILE]
    
    IF F GT 0 THEN BEGIN
      FOR I=0, N_ELEMENTS(INTAGS)-1 DO IF TAGS[INTAGS[I]] NE 'INDATA_ALG' THEN IF INSTR.(I) NE INSTRUCT.(I) THEN MESSAGE, 'ERROR: The "INDATA" values do not match for ' + INTAGS[I] 
    ENDIF ELSE INSTR = INSTRUCT
    
    FOR N=0, 3 DO BEGIN
      CASE N OF 
        0: DAT = S.(WHERE(TAGS EQ 'GRAD'  + GP, /NULL))
        1: DAT = S.(WHERE(TAGS EQ 'GRADX' + GP, /NULL))
        2: DAT = S.(WHERE(TAGS EQ 'GRADY' + GP, /NULL))
        3: DAT = S.(WHERE(TAGS EQ OTAG,         /NULL))
      ENDCASE
      IF DAT EQ [] THEN MESSAGE, 'ERROR: Data tag not found in structure.' 
    ; ===> Subset the data by the BINS if provided
      IF MOBINS EQ [] THEN BEGIN                                                                                                  ; If no subset map bins
        IF BINS NE [] THEN BEGIN                                                                                                  ; If no bins
          _DATA = BLANK                                                                                                           ; Make a blank array
          _DATA[BINS] = DAT                                                                                                       ; Fill in the blank array associated with the specified bin info with valid data
        ENDIF ELSE _DATA = N  ; BINS NE []                                                                                        ; If no bins or mobins, then _DATA = N
      ENDIF ELSE BEGIN  ; MOBINS = []
        IF BINS NE [] THEN BEGIN
          _DAT = MAPS_L3B_2ARR(DAT,MP=S.MAP,BINS=BINS);FLTARR(N_BINS) & _DAT[*,*] = MISSINGS(_DAT)                                ; Make a blank array for the full l3b array                                                                                                         ; Fill in the full l3b array with data
          _DATA = BLANK                                                                                                           ; Create a blank array the size of MOBINS
          _DATA = _DAT[MOBINS]                                                                                                    ; Fill in the blank array with just the MOBINS data
          GONE, _DAT
        ENDIF ELSE _DATA = DAT[0,MOBINS] ; BINS NE []                                                                             ; Subset the full array (n) with MOBINS
      ENDELSE
      
      CASE N OF 
        0: GARR[*,*,F] = _DATA
        1: XARR[*,*,F] = _DATA
        2: YARR[*,*,F] = _DATA 
        3: OARR[*,*,F] = _DATA
      ENDCASE
      GONE, DAT & GONE, _DATA     
    ENDFOR ; GRAD PRODS   
    OK_GOOD = WHERE(GARR[*,*,F] NE MISSINGS(GARR),COUNT)
    STMP = SARR[*,*,F]
    STMP[OK_GOOD] = 1
    IF COUNT GT 1 THEN SARR[*,*,F] = STMP
  ENDFOR ; FILES
  
  IF N_ELEMENTS(FILES) GT 1 THEN SBIT = BITS(SARR,/BIT_POSITION,DIMENSION=3) ELSE SBIT = SARR
  BITNOTE = 'The FILE_BITS contains the "bit" value based on whether the input file ("INFILES") has data at a given pixel location.' 
    
  IF N_ELEMENTS(FILES) GT 1 THEN STR0 = FRONT_INDICATORS_MILLER(GRAD_MAG=GARR, GRAD_X=XARR, GRAD_Y=YARR, TRANSFORM=PLOG,THRESHOLD=0.0,PERSISTENCE=1,/FULLSTRUCT) $
                            ELSE STR0 = CREATE_STRUCT('FCLEAR',SARR, 'FMEAN',GARR, 'XMEAN',XARR, 'YMEAN',YARR)
  
  IF KEYWORD_SET(PLOG) THEN OARR = ALOG(OARR)
  IF N_ELEMENTS(FILES) GT 1 THEN MARR = MEAN(OARR,DIMENSION=3,/NAN) ELSE MARR = OARR
  IF KEYWORD_SET(PLOG) THEN MARR = EXP(MARR)
  OK = WHERE(FINITE(MARR) EQ 0,COUNT_MISS)
  IF COUNT_MISS GT 0 THEN MARR[OK] = MISSINGS(OARR)
  
  STR = CREATE_STRUCT('INFILES',FILES,'ORGFILES',ORGFILES,'BINS',MOBINS,'NUMBER_OBSERVATIONS',STR0.FCLEAR,'FILE_BITS',SBIT,'GRAD'+GP, STR0.FMEAN, 'GRADX'+GP, STR0.XMEAN, 'GRADY'+GP, STR0.YMEAN, OTAG,MARR, 'NOTES', BITNOTE, INSTR)
  RETURN, STR

END ; ***************** End of FRONT_MEAN *****************
