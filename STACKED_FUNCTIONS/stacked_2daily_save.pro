; $ID:	STACKED_2DAILY_SAVE.PRO,	2023-09-21-13,	USER-KJWH	$
  PRO STACKED_2DAILY_SAVE, FILE, DATERANGE=DATERANGE, DIR_OUT=DIR_OUT

;+
; NAME:
;   STACKED_2DAILY_SAVE
;
; PURPOSE:
;   Exctract all data from a single day and save the structure as a SAV file (useful for creating test files when large stacked files take a long time to open)
;
; CATEGORY:
;   STACKED_FUNCTIONS
;
; CALLING SEQUENCE:
;   STACKED_2DAILY_SAVE(FILE, DATERANGE=DATERANGE)
;
; REQUIRED INPUTS:
;   FILE.......... Input "stacked" file(s) 
;
; OPTIONAL INPUTS:
;   DATERANGE.... The range of dates to extract from the stacked file
;   DIR_OUT...... The output directory
;
; KEYWORD PARAMETERS:
;   OVERWRITE.... Overwrite a file if it already exists
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
; Copyright (C) 2023, Department of Commerce, National Oceanic and Atmospheric Administration, National Marine Fisheries Service,
;   Northeast Fisheries Science Center, Narragansett Laboratory.
;   This software may be used, copied, or redistributed as long as it is not sold and this copyright notice is reproduced on each copy made.
;   This routine is provided AS IS without any express or implied warranties whatsoever.
;
; AUTHOR:
;   This program was written on July 11, 2023 by Kimberly J. W. Hyde, Northeast Fisheries Science Center | NOAA Fisheries | U.S. Department of Commerce, 28 Tarzwell Dr, Narragansett, RI 02882
;    
; MODIFICATION HISTORY:
;   Jul 11, 2023 - KJWH: Initial code written
;-
; ****************************************************************************************************
  ROUTINE_NAME = 'STACKED_2DAILY_SAVE'
  COMPILE_OPT IDL2
  SL = PATH_SEP()
  
  IF ~N_ELEMENTS(FILE) THEN MESSAGE, 'ERROR: Must provide at least one input file'
  
  FOR F=0, N_ELEMENTS(FILE)-1 DO BEGIN
    AFILE = FILE[F]
    FP = PARSE_IT(AFILE,/ALL)
    IF FP.DIR NE 'STACKED_SAVE' AND FP.PERIOD_CODE NE 'DD' THEN MESSAGE, 'ERROR: Input file must be a "stacked" daily save file.' 
    
    IF ~N_ELEMENTS(DATERANGE) THEN DR = GET_DATERANGE([FP.DATE_START,FP.DATE_END]) ELSE DR = GET_DATERANGE(DATERANGE)
    DATES = CREATE_DATE(DR[0],DR[1])
    IF ~N_ELEMENTS(DIR_OUT) THEN DIROUT = REPLACE(FP.DIR,FP.L2SUBDIR,'SAVE') ELSE DIROUT = DIR_OUT
    DIR_TEST, DIROUT
    
  ENDFOR


END ; ***************** End of STACKED_2DAILY_SAVE *****************
