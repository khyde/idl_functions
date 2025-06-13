; $ID:	H5_GET_DATA.PRO,	2016-08-26,	USER-KJWH	$

FUNCTION H5_GET_INPUT_PARAMETERS, FILE, LOOK=LOOK

;+
; NAME:
;   H5_GET_INPUT_PARAMETERS.PRO
;
; PURPOSE:
;   Read the Level 2 HDF5 files created by SeaDAS.
;
; CATEGORY:
;   READ Utilities
;
; CALLING SEQUENCE:
;   D = H5_GET_PROCESSING_CONTROL(FILE,PRODS=PRODS)
;   
; INPUTS:
;   FILE     := SEAWIFS, MODIS or other L2 data HDF5 file
;  
; KEYWORD PARAMETERS:
;
; OUTPUTS:
;   This function returns the "PROCESSING_CONTROL" structures (if present) from the HDF5 file
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
;     Written March 07, 2018 by K.J.W. Hyde, 28 Tarzwell Drive, NMFS, NOAA 02882 (kimberly.hyde@noaa.gov)
;                        
;     Modification History:
;     MAR 07, 2018 - KJWH: Adapted from H5_GET_DATA
;    
;-
; ****************************************************************************************************


  ROUTINE = 'H5_GET_INPUT_PARAMETERS'
  
  FID = H5F_OPEN(FILE)                                                                       ; Open HDF file
  H5_STRUCT = H5_PARSE(FILE)                                                                 ; Parses an HDF5 file and returns a nested structure containing all of the groups, datasets, and attributes.
  H5F_CLOSE, FID                                                                             ; Close the HDF file
  H5_CLOSE                                                                                   ; Close HDF
  
  IP = GET_TAG(H5_STRUCT,'PROCESSING_CONTROL.INPUT_PARAMETERS')                              ; Get the INPUT_PARAMETERS structure
  IF IP EQ [] THEN RETURN, IP                                                                ; If INPUT_PARAMETERS is not present, return []
  
  TAGS = TAG_NAMES(IP)                                                                       ; Get tag names 
  STR = []
  FOR N=0, N_ELEMENTS(TAGS)-1 DO BEGIN                                                       ; Loop through the tags
    SET = IP.(N)                                                                             ; Get the info from N tag
    IF IDLTYPE(SET) NE 'STRUCT' THEN CONTINUE                                                ; If the type is not a structure then continue
    NM = GET_TAG(SET,'_NAME')
    DT = GET_TAG(SET,'_DATA')
    IF NM EQ [] OR DT EQ [] THEN CONTINUE
    STR = CREATE_STRUCT(STR,NM,DT)
  ENDFOR  
  RETURN, STR

END
