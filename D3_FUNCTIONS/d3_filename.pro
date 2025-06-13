; $ID:	D3_FILENAME.PRO,	2023-09-21-13,	USER-KJWH	$
  FUNCTION D3_FILENAME, FILES, DATERANGE=DATERANGE, FILE_LABEL=FILE_LABEL

;+
; NAME:
;   D3_FILENAME
;
; PURPOSE:
;   Create the default filename for the D3 files
;
; CATEGORY:
;   $CATEGORY$
;
; CALLING SEQUENCE:
;   Result = D3_FILENAME($Parameter1$, $Parameter2$, $Keyword=Keyword$, ...)
;
; REQUIRED INPUTS:
;   Parm1.......... Describe the positional input parameters here. 
;
; OPTIONAL INPUTS:
;   Parm2.......... Describe optional inputs here. If none, delete this section.
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
;   This program was written on March 01, 2021 by Kimberly J. W. Hyde, Northeast Fisheries Science Center | NOAA Fisheries | U.S. Department of Commerce, 28 Tarzwell Dr, Narragansett, RI 02882
;    
; MODIFICATION HISTORY:
;   Mar 01, 2021 - KJWH: Initial code written
;-
; ****************************************************************************************************
  ROUTINE_NAME = 'D3_FILENAME'
  COMPILE_OPT IDL2
  
  IF NONE(FILES) THEN MESSAGE, 'ERROR: Must provide input file(s)'
  FP = PARSE_IT(FILES)
  SETS = PERIOD_SETS(PERIOD_2JD(FP.PERIOD),PERIOD_CODE=PERIOD_OUT)
  IF N_ELEMENTS(SETS) GT 1 THEN MESSAGE, 'ERROR: Check PERIOD_SETS output.'
  PERIOD_NAME = SETS.PERIOD
  
 ; IF NONE(DATERANGE) THEN 
  
  ; ===> Set up the output directory
  IF NONE(DIR_OUT) THEN DIR_OUT = REPLACE(FP[0].DIR,['SAVE','STATS','ANOMS'],REPLICATE('STACKED_FILES'+SL+PERIOD_OUT+'_D3',3)) ; Set up the output directory
  DIR_OUT = REPLACE(DIR_OUT,MAPS[0],AMAP)                                                                                       ; Change the map in the output directory
  IF ~HAS(DIR_OUT,AMAP) THEN MESSAGE, 'ERROR: Check the output directory MAP information'                                       ; Check the output directory is correct
  DIR_TEST, DIR_OUT                                                                                                             ; Make the output directory if it does not already exist

  
  IF NONE(FILE_LABEL) THEN _FILE_LABEL = SI[0].FILELABEL + '-' + D3_PROD ELSE _FILE_LABEL=FILE_LABEL      
  
  ; ===> Define the D3 file names
  IF MOBINS EQ [] THEN MAP_PXY = AMAP + '-PXY_' + ROUNDS(PX) + '_' + ROUNDS(PY) ELSE BEGIN                                      ; Create a MAP, PX, PY label
    IF N_ELEMENTS(MOBINS) EQ PY THEN MAP_PXY = AMAP + '-PXY_' + ROUNDS(PX) + '_' + ROUNDS(PY) $                                 ; Create a L3B MAP label
    ELSE MAP_PXY = AMAP + '_' + L3BMAP + '-PXY_1_' + ROUNDS(N_ELEMENTS(MOBINS))                     ; Create a L3BMAP specific MAP label
  ENDELSE
  IF HAS(_FILE_LABEL,'PXY') EQ 0 THEN _FILE_LABEL = REPLACE(_FILE_LABEL, AMAP, MAP_PXY)                                         ; Add PXY_(PX)_(PY) to the file label

  IF NONE(D3_FILE) THEN BEGIN
    D3_FILE      = DIR_OUT +  PERIOD_NAME + '-' + _FILE_LABEL + '-D3_DAT.FLT'                                                   ; Create the complete D3_FILE name if not provided
    D3_FILE      = REPLACE(D3_FILE,'--','-')                                                                                    ; Clean up the file name
  ENDIF ELSE IF (FILE_PARSE(D3_FILE)).DIR EQ '' THEN D3_FILE = DIR_OUT + STRUPCASE(D3_FILE)
  



END ; ***************** End of D3_FILENAME *****************
