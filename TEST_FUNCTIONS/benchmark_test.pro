; $ID:	BENCHMARK_TEST.PRO,	2024-03-06-11,	USER-KJWH	$
  PRO BENCHMARK_TEST

;+
; NAME:
;   BENCHMARK_TEST
;
; PURPOSE:
;   Determine the amount of time it takes to perform various processing steps
;
; CATEGORY:
;   TEST_FUNCTIONS
;
; CALLING SEQUENCE:
;   BENCHMARK_TEST
;
; REQUIRED INPUTS:
;   None 
;
; OPTIONAL INPUTS:
;   None
;
; KEYWORD PARAMETERS:
;   None
;
; OUTPUTS:
;   Processing times
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
; Copyright (C) 2024, Department of Commerce, National Oceanic and Atmospheric Administration, National Marine Fisheries Service,
;   Northeast Fisheries Science Center, Narragansett Laboratory.
;   This software may be used, copied, or redistributed as long as it is not sold and this copyright notice is reproduced on each copy made.
;   This routine is provided AS IS without any express or implied warranties whatsoever.
;
; AUTHOR:
;   This program was written on March 06, 2024 by Kimberly J. W. Hyde, Northeast Fisheries Science Center | NOAA Fisheries | U.S. Department of Commerce, 28 Tarzwell Dr, Narragansett, RI 02882
;    
; MODIFICATION HISTORY:
;   Mar 06, 2024 - KJWH: Initial code written
;-
; ****************************************************************************************************
  ROUTINE_NAME = 'BENCHMARK_TEST'
  COMPILE_OPT IDL3
  SL = PATH_SEP()
  
  DIR = !S.TEST + ROUTINE_NAME + SL & DIR_TEST, DIR
  
  ; Read and write a large file
  TIC
  F = GET_FILES('MUR',PRODS='SST',FILE_TYPE='NC',DATERANGE=['20230916'])
  D = READ_NC(F)
  SAVE, D, FILENAME=DIR + 'TEST_MUR_FILE_800MB.SAV' 
  CLOCKRW=TOC() & PRINT, CLOCKRW
    
  ; Create new stacked file from netcdfs
  TIC
  FILES_2STACKED_WRAPPER, 'OCCCI', DATERANGE='1997', DIR_OUT=DIR+'OCCCI/L3B4/STACKED_SAVE/CHLOR_A-CCI/', /OVERWRITE
  CLOCKFS=TOC() & PRINT, CLOCKFS
    
  TIC
  STACKED_STATS_WRAPPER, 'OCCCI', DATERANGE='1997', PRODS='CHLOR_A-CCI', PERIODS=['D3','D8','W','M'], DIR_IN=DIR+'OCCCI/', DIR_OUT=DIR+'OCCCI/L3B4/STACKED_STATS/CHLOR_A-CCI/',/OVERWRITE
  CLOCKSW=TOC() & PRINT, CLOCKSW
    
  TIC
  STACKED_STATS_WRAPPER, 'OCCCI', PRODS='CHLOR_A-CCI', PERIODS=['WEEK','MONTH'], DIR_OUT=DIR+'OCCCI/L3B4/STACKED_STATS/CHLOR_A-CCI/',/OVERWRITE
  CLOCKSC=TOC() & PRINT, CLOCKSC
    
  TOC
 
  PRINT, 'READ_WRITE_TIME ' + NUM2STR(CLOCKRW/60.0)
  PRINT, 'FILES_2STACKED_TIME ' + NUM2STR(CLOCKFS/60.0)
  PRINT, 'STACKED_STATS_TIME ' + NUM2STR(CLOCKSW/60.0)
  PRINT, 'CLIM_STATS_TIME ' + NUM2STR(CLOCKSc/60.0)
  PRINT, 'TOTAL ' + NUM2STR(TOTAL([CLOCKRW,CLOCKFS,CLOCKSW,CLOCKSC])/60.0)
  
  stop


END ; ***************** End of BENCHMARK_TEST *****************
