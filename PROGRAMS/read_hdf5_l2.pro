; $ID:	READ_HDF5_L2.PRO,	2020-07-08-15,	USER-KJWH	$

FUNCTION READ_HDF5_L2, FILE, PRODS=PRODS, LOOK=LOOK

;+
; NAME:
;   READ_HDF5_L2.PRO
;
; PURPOSE:
;   Read the Level 2 HDF5 files created by SeaDAS.
;
; CATEGORY:
;   READ Utilities
;
; CALLING SEQUENCE:
;   D = READ_HDF5_L2(FILE,PRODS=PRODS)
;   
; INPUTS:
;   FILE     := SEAWIFS, MODIS or other L2 data HDF5 file
;   PRODS    := Products to extract from the HDF
;  
; KEYWORD PARAMETERS:
;
; OUTPUTS:
;   This function returns a data structure with the requested products from the HDF5 file
;
; OPTIONAL OUTPUTS:
;   ERROR:     
;
; PROCEDURE:
;     
; EXAMPLES:
;   
; NOTES:
;   
;
; MODIFICATION HISTORY:
;     Written June, 2015 by K.J.W. Hyde, 28 Tarzwell Drive, NMFS, NOAA 02882 (kimberly.hyde@noaa.gov)
;                        
;     Modification History:
;     Jul 23, 2015 - JOR:  Replaced STRUCT_MERGE with CREATE_STRUCT
;     Jul 23, 2015 - KJWH: Fixed issues when there is no GROUP associated with a DATASET
;     Oct 02, 2015 - KJWH: Added H5_CLOSE to the end to completely close the HDF5 file
;     Dec 03, 2015 - KJWH: Added keyword LOOK to just get the names in the HDF5 file
;
;-
; ****************************************************************************************************


  IF WHERE(STRUPCASE(PRODS) EQ 'SD') GE 0 THEN PRODS = 'SD'

  H5_LIST, FILE, OUTPUT=OUT     ; List the paths to the datasets contained in an HDF5 file.
  SZ = SIZE(OUT,/DIMENSIONS)    ; Get dimensions of the output
 
  GROUP = ''
  DATASET = '' 
  FOR N=0, SZ[1]-1 DO BEGIN     ; Loop through DATASETS to see if they match the input prod
    S = OUT(*,N)
    IF S[0] EQ 'dataset' THEN BEGIN
      POS = STRPOS(S[1],'/',/REVERSE_SEARCH)
      NAME = STRMID(S[1],POS+1)
      IF PRODS[0] NE 'SD' THEN OK_PROD = WHERE(STRUPCASE(PRODS) EQ STRUPCASE(NAME),COUNT_PROD) ELSE COUNT_PROD = 1 ; IF PRODS EQ 'SD' THEN GET ALL PRODS
      IF COUNT_PROD EQ 1 THEN IF DATASET[0] EQ '' THEN DATASET = S[1] ELSE DATASET = [DATASET,+S[1]]
    ENDIF
  ENDFOR
  
  IF N_ELEMENTS(DATASET) EQ 1 AND DATASET[0] EQ '' THEN RETURN, ''            ; Return '' if no datasets are found that match the input PRODS
  
  IF KEY(LOOK) THEN BEGIN  
    POS = STRPOS(DATASET,'/',/REVERSE_SEARCH)
    GRP = [] & FOR D=0, N_ELEMENTS(DATASET)-1 DO GRP = [GRP,STRMID(DATASET(D),1,POS(D)-1)]
    PRD = [] & FOR D=0, N_ELEMENTS(DATASET)-1 DO PRD = [PRD,STRMID(DATASET(D),POS(D)+1)]
    OK = WHERE(GRP EQ '', COUNT) & IF COUNT GE 1 THEN GRP[OK] = 'OTHER'
    UNQ = GRP[UNIQ(GRP[SORT(GRP)])]
    FOR U=0, N_ELEMENTS(UNQ)-1 DO BEGIN
      OK = WHERE(GRP EQ UNQ(U),COUNT)
      IF U EQ 0 THEN SD = CREATE_STRUCT(STRUPCASE(UNQ(U)),PRD[OK]) ELSE SD = [CREATE_STRUCT(SD,STRUPCASE(UNQ(U)),PRD[OK])]
    ENDFOR
    RETURN, SD  
  ENDIF
  
  FID = H5F_OPEN(FILE)                                                        ; Open HDF file
  H5_STRUCT = H5_PARSE(FILE)                                                  ; Parses an HDF5 file and returns a nested structure containing all of the groups, datasets, and attributes.
  TAGS = STRUPCASE(TAG_NAMES(H5_STRUCT))                                      ; Get the tagnames of the HDF5 file 
  FOR N=0, N_ELEMENTS(DATASET)-1 DO BEGIN                                     ; Loop through the PRODS
    
    SET = STRSPLIT(DATASET(N),'/',/EXTRACT)                                   ; Split the dataset name to get the GROUP and NAME
    GRP = SET[0]
    POS = WHERE(TAGS EQ STRUPCASE(GRP),COUNT) & IF COUNT EQ 0 THEN STOP       ; Check to make sure the GROUP name was found
    IF NOF(SET) EQ 1 THEN BEGIN                                               ; If no GROUP, then just read the info from the NAME
      STR = H5_STRUCT.(POS)
      NAME = GRP
      DSET_ID = H5D_OPEN(FID, NAME)                                           ; Open the DATASET from within the GROUP
      DATA = H5D_READ(DSET_ID)                                                ; Read the DATASET
      GOTO, MAKE_STRUCT
    ENDIF
    NAME =SET[1]
    H5_TAGS = STRUPCASE(TAG_NAMES(H5_STRUCT.(POS)))                           ; Get the tag names of the GROUP structure
    NPOS = WHERE(H5_TAGS EQ STRUPCASE(NAME),COUNT) & IF COUNT EQ 0 THEN STOP  ; Check to make sure the NAME is found 
    STR = H5_STRUCT.(POS).(NPOS)
   
    GRP_ID = H5G_OPEN(FID, GRP)                                               ; Open the GROUP
    DSET_ID = H5D_OPEN(GRP_ID, NAME)                                          ; Open the DATASET from within the GROUP
    H5G_CLOSE, GRP_ID                                                         ; Close the GROUP
    DATA = H5D_READ(DSET_ID)                                                  ; Read the DATASET
    
    MAKE_STRUCT:
    IF WHERE(STRUPCASE(TAG_NAMES(STR)) EQ 'IMAGE') GE 0 THEN OUTSTRUCT = STRUCT_COPY(STR,'IMAGE',/REMOVE) ; Remove the image tag if found
    OUTSTRUCT = CREATE_STRUCT(STR,CREATE_STRUCT('IMAGE',DATA))                ; Put the DATA into the IMAGE tag
    IF N EQ 0 THEN SD = CREATE_STRUCT(STRUPCASE(NAME),OUTSTRUCT) ELSE SD = CREATE_STRUCT(SD,CREATE_STRUCT(STRUPCASE(NAME),OUTSTRUCT))
    H5D_CLOSE, DSET_ID
    
  ENDFOR
  
  H5F_CLOSE, FID
  H5_CLOSE
  RETURN, SD

END
