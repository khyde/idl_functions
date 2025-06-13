; $ID:	STATS_2STACKED.PRO,	2023-09-21-13,	USER-KJWH	$
  PRO STATS_2STACKED, FILES, PERIOD_CODE=PERIOD_CODE, STAT=STAT, OUTFILE=OUTFILE, OVERWRITE=OVERWRITE

;+
; NAME:
;   STATS_2STACKED
;
; PURPOSE:
;   Extract the mean from yearly STACKED_STATS files (e.g. WW amd MM) and create a single file to use to create the climatological stats (e.g. WEEK and MONTH)  
;
; CATEGORY:
;   STACKED_FUNCTIONS
;
; CALLING SEQUENCE:
;   STATS_2STACKED, FILES
;
; REQUIRED INPUTS:
;   FILES.......... Input STACKED_STATS files
;
; OPTIONAL INPUTS:
;   STAT........... The statistic to extract (default = MEAN)
;
; KEYWORD PARAMETERS:
;   OVERWRITE...... Overwrite an existing file
;
; OUTPUTS:
;   New STACKED_STAT files
;
; OPTIONAL OUTPUTS:
;   OUTFILE........ The name of the merged output file
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
;   This program was written on October 18, 2022 by Kimberly J. W. Hyde, Northeast Fisheries Science Center | NOAA Fisheries | U.S. Department of Commerce, 28 Tarzwell Dr, Narragansett, RI 02882
;    
; MODIFICATION HISTORY:
;   Oct 18, 2022 - KJWH: Initial code written
;   Nov 14, 2022 - Changed D3HASH_MAKE to SAVE_2STACKED
;   Dec 01, 2022 - Changed SAVE_2STACKED to FILES_2STACKED
;-
; ****************************************************************************************************
  ROUTINE_NAME = 'STATS_2STACKED'
  COMPILE_OPT IDL2
  SL = PATH_SEP()

  IF ~N_ELEMENTS(FILES) THEN MESSAGE, 'ERROR: Must provide at least one input file.'                                    ; Make sure there is at least one file
  FP = PARSE_IT(FILES,/ALL)                                                                                             ; Parse the file names                     
  IF ~SAME(FP.SENSOR) THEN MESSAGE, 'ERROR: All input files must have the same sensor.'                                 ; Make sure the SENSOR is the same for all files
  IF ~SAME(FP.PROD_ALG) THEN MESSAGE, 'ERROR: All input files must have the same PROD-ALG.'                             ; Make sure the PROD and ALG are the same for all files
  IF ~SAME(FP.MAP) THEN MESSAGE, 'ERROR: All input files must have the same MAP.'                                       ; Make sure the MAP is the same for all files
  IF ~SAME(FP.MAP_SUBSET) THEN MESSAGE, 'ERROR: All input files must have the same subset MAP.'                         ; Make sure the SUBSET MAP is the same for all files
  
  DIR_OUT = REPLACE(FP[0].DIR,'STACKED_STATS','STACKED_TEMP') & DIR_TEST, DIR_OUT                                       ; Create the output directory
  
  SENSOR_DATERANGE = SENSOR_DATES(FP[0].SENSOR)                                                                         ; Get the daterange based on the SENSOR
  APROD = FP[0].PROD                                                                                                    ; Get the PROD name
  
  CASE APROD OF 
    'GRAD_SST': BEGIN & APROD=['GRADX_SST','GRADY_SST'] & STAT = '' & END
    'GRAD_CHL': BEGIN & APROD=['GRADX_CHL','GRADY_CHL'] & STAT = '' & END
    ELSE: IF ~N_ELEMENTS(STAT) THEN STAT = 'MEAN'                                                                               ; If the "stat" type is not provided, use the MEAN
  ENDCASE
  
  IF ~SAME(FP.PERIOD_CODE) THEN MESSAGE, 'ERROR: All input files must have the same period code.'                       ; Make sure the input files have the same period code
  PERS = PERIODS_READ()                                                                                                 ; Read PERIODS_MAIN
  ISTR = PERS[WHERE(PERS.PERIOD_CODE EQ FP[0].PERIOD_CODE)]                                                             ; Get the period information of the input files
  CASE ISTR.PERIOD_CODE OF                                                                                              ; Based on the period code...
    'MM': SPERS = YEAR_MONTH_RANGE(SENSOR_DATERANGE[0],SENSOR_DATERANGE[1])                                             ; Get the "month" dates for the full sensor date range
    'WW': SPERS = YEAR_WEEK_RANGE(SENSOR_DATERANGE[0],SENSOR_DATERANGE[1])                                              ; Get the "week" dates for the full sensor date range
    'MM3':SPERS = YEAR_MONTH_RANGE(SENSOR_DATERANGE[0],SENSOR_DATERANGE[1]) 
  ENDCASE          
  STACKED_PERIOD = STRJOIN([ISTR.PERIOD_CODE,MIN(SPERS),MAX(SPERS)],'_')                                                ; Create the new stacked period code
    
  FOR S=0, N_ELEMENTS(STAT)-1 DO BEGIN                                                                                  ; Loop on the stat types
    ASTAT = STAT[S]
    SPROD = APROD + '_' + ASTAT                                                                                         ; Get the tagname for the PROD + STAT in the input files
    OUTFILE = DIR_OUT + REPLACE(FP[0].NAME_EXT,[FP[0].PERIOD,'STACKED_STATS'],[STACKED_PERIOD,'STACKED_TEMP-'+ASTAT])   ; Creat the new output file name  
    FILES_2STACKED, FILES, PRODS=APROD, STAT_TYPE=ASTAT, L3BSUBMAP=L3BSUBMAP, OUTFILE=OUTFILE, DIR_OUT=DIR_OUT, OVERWRITE=OVERWRITE, LOGLUN=LOGLUN
  ENDFOR ; Stats 

END ; ***************** End of STATS_2STACKED *****************
