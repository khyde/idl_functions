; $ID:	H5_GET_DATA.PRO,	2020-07-08-15,	USER-KJWH	$

FUNCTION H5_GET_DATA, FILE, PRODS=PRODS, LOOK=LOOK

;+
; NAME:
;   H5_GET_DATA.PRO
;
; PURPOSE:
;   Read the Level 2 HDF5 files created by SeaDAS.
;
; CATEGORY:
;   READ Utilities
;
; CALLING SEQUENCE:
;   D = H5_GET_DATA(FILE,PRODS=PRODS)
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
;     Aug 25, 2016 - KJWH: Changed name to H5_GET_DATA to be consistent with other H5 programs
;                          If KEY(LOOK) then just return the product names found in the datasets instead of a structure
;                          Updated documentation
;     Aug 26, 2016 - KJWH: Added /CONVERT_ALL keyword to IDL_VALIDNAME() call                     
;
;-
; ****************************************************************************************************


  ROUTINE = 'H5_GET_DATA'

  IF NONE(PRODS) THEN PRODS = 'SD'

  H5_LIST, FILE, FILTER='dataset', OUTPUT=OUT     ; List the paths to the datasets contained in an HDF5 file.
  SZ = SIZE(OUT,/DIMENSIONS)    ; Get dimensions of the output
 
  GROUP = []
  DATASET = [] 
  PNAMES = []
  TYPE_SIZE = []
  FOR N=0, SZ[1]-1 DO BEGIN                                                                  ; Loop through DATASETS to extract the product names
    S = OUT(*,N)
    IF S[0] NE 'dataset' THEN CONTINUE
    POS = STRPOS(S[1],'/',/REVERSE_SEARCH)
    PNAMES  = [PNAMES,STRMID(S[1],POS+1)]    
    DATASET = [DATASET,S[1]]
    TYPE_SIZE = [TYPE_SIZE, S(2)]
  ENDFOR
  IF KEY(LOOK) THEN RETURN, PNAMES                                                           ; If just "looking" return all of the product names
  IF DATASET EQ [] THEN RETURN, 'ERROR: No DATASETS found in FILE - ' + FILE                 ; Return an error if there were no datasets in the file    
  OK_PROD = WHERE_MATCH(STRUPCASE(PNAMES),STRUPCASE(PRODS),COUNT_PROD)                       ; Find matching products
  IF COUNT_PROD EQ 0 AND HAS(PRODS,'SD') EQ 0 THEN RETURN, 'ERROR: No matching products found in FILE - ' + FILE
  IF COUNT_PROD GE 1 THEN DATASET = DATASET(OK_PROD)                                         ; Subset the DATASETs based on the input PRODS
   
  FID = H5F_OPEN(FILE)                                                                       ; Open HDF file
  H5_STRUCT = H5_PARSE(FILE)                                                                 ; Parses an HDF5 file and returns a nested structure containing all of the groups, datasets, and attributes.
  TAGS = STRUPCASE(TAG_NAMES(H5_STRUCT))                                                     ; Get the tagnames of the HDF5 file 
  FOR N=0, N_ELEMENTS(DATASET)-1 DO BEGIN                                                    ; Loop through the PRODS
    SET = STRSPLIT(DATASET(N),'/',/EXTRACT)                                                  ; Split the dataset name to get the GROUP and NAME
    GRP = SET[0]
    POS = WHERE(TAGS EQ STRUPCASE(IDL_VALIDNAME(GRP,/CONVERT_ALL)),COUNT) & IF COUNT EQ 0 THEN STOP       ; Check to make sure the GROUP name was found
    IF NOF(SET) EQ 1 THEN BEGIN                                                              ; If no GROUP, then just read the info from the NAME
      STR = H5_STRUCT.(POS)
      NAME = GRP
      DSET_ID = H5D_OPEN(FID, NAME)                                                          ; Open the DATASET from within the GROUP
      DT = H5D_READ(DSET_ID)                                                                 ; Read the DATASET
      GOTO, MAKE_STRUCT
    ENDIF
    NAME =SET[1]
    H5_TAGS = STRUPCASE(TAG_NAMES(H5_STRUCT.(POS)))                                          ; Get the tag names of the GROUP structure
    NPOS = WHERE(H5_TAGS EQ STRUPCASE(NAME),COUNT) & IF COUNT EQ 0 THEN STOP                 ; Check to make sure the NAME is found 
    STR = H5_STRUCT.(POS).(NPOS)
   
    IF TYPE_SIZE(N) EQ 'H5T_FLOAT [0]' THEN BEGIN                                            ; There is no DATASET within the group if the size is [0]
      DT = []                                                                                ; Create a NULL value for DATA
      GOTO, MAKE_STRUCT                                
    ENDIF
    
    GRP_ID = H5G_OPEN(FID, GRP)                                                              ; Open the GROUP
    DSET_ID = H5D_OPEN(GRP_ID, NAME)                                                         ; Open the DATASET from within the GROUP
    
    DT = H5D_READ(DSET_ID)                                                                   ; Read the DATASET
    H5G_CLOSE, GRP_ID                                                                        ; Close the GROUP
    H5D_CLOSE, DSET_ID                                                                       ; Close the DATASET
    
    
    MAKE_STRUCT:
    IF WHERE(STRUPCASE(TAG_NAMES(STR)) EQ 'IMAGE') GE 0 THEN OUTSTRUCT = STRUCT_COPY(STR,'IMAGE',/REMOVE) ; Remove the image tag if found
    IF DT NE [] THEN OUTSTRUCT = CREATE_STRUCT(STR,CREATE_STRUCT('IMAGE',DT))                                            ; Put the DATA into the IMAGE tag
    IF N EQ 0 THEN SD = CREATE_STRUCT(STRUPCASE(NAME),OUTSTRUCT) ELSE SD = CREATE_STRUCT(SD,CREATE_STRUCT(STRUPCASE(NAME),OUTSTRUCT))
    GONE, OUTSTRUCT
  ENDFOR
  
  H5F_CLOSE, FID
  H5_CLOSE
  RETURN, SD

END
