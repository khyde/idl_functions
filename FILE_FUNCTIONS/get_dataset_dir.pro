; $ID:	GET_DATASET_DIR.PRO,	2023-09-21-13,	USER-KJWH	$
  FUNCTION GET_DATASET_DIR, DATASET

;+
; NAME:
;   GET_DATASET_DIR
;
; PURPOSE:
;   Function to get the directory location of a specific dataset found in the !S structure
;
; CATEGORY:
;   FILE_FUNCTIONS
;
; CALLING SEQUENCE:
;   Result = GET_DATASET_DIR(DATASET)
;
; REQUIRED INPUTS:
;   DATASET.......... The name of the dataset to search for in the !S structure 
;
; OPTIONAL INPUTS:
;   None
;
; KEYWORD PARAMETERS:
;   None
;
; OUTPUTS:
;   The file directory location for the specified dataset
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
; Copyright (C) 2022, Department of Commerce, National Oceanic and Atmospheric Administration, National Marine Fisheries Service,
;   Northeast Fisheries Science Center, Narragansett Laboratory.
;   This software may be used, copied, or redistributed as long as it is not sold and this copyright notice is reproduced on each copy made.
;   This routine is provided AS IS without any express or implied warranties whatsoever.
;
; AUTHOR:
;   This program was written on July 07, 2022 by Kimberly J. W. Hyde, Northeast Fisheries Science Center | NOAA Fisheries | U.S. Department of Commerce, 28 Tarzwell Dr, Narragansett, RI 02882
;    
; MODIFICATION HISTORY:
;   Jul 07, 2022 - KJWH: Initial code written
;-
; ****************************************************************************************************
  ROUTINE_NAME = 'GET_DATASET_DIR'
  COMPILE_OPT IDL2
  SL = PATH_SEP()

  SDIR = []
  FOR S=0, N_ELEMENTS(DATASET)-1 DO BEGIN
    OK = WHERE_MATCH(STRUPCASE(TAG_NAMES(!S)), STRUPCASE(DATASET[S]),COUNT)
    IF COUNT EQ 0 THEN MESSAGE, 'ERROR: ' + DATASET[S] + ' not found in !S', /CONTINUE
    IF COUNT EQ 0 THEN SDIR = [SDIR,''] ELSE SDIR = [SDIR,!S.(OK)]
  ENDFOR
   
  RETURN, SDIR

END ; ***************** End of GET_DATASET_DIR *****************
