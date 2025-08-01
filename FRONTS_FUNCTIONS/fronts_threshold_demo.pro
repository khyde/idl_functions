; $ID:	FRONTS_THRESHOLD_DEMO.PRO,	2023-09-21-13,	USER-KJWH	$
  PRO FRONTS_THRESHOLD_DEMO

;+
; NAME:
;   FRONTS_THRESHOLD_DEMO
;
; PURPOSE:
;   $PURPOSE$
;
; PROJECT:
;   FRONTAL_METRICS
;
; CALLING SEQUENCE:
;   Result = FRONTS_THRESHOLD_DEMO($Parameter1$, $Parameter2$, $Keyword=Keyword$, ...)
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
; Copyright (C) 2023, Department of Commerce, National Oceanic and Atmospheric Administration, National Marine Fisheries Service,
;   Northeast Fisheries Science Center, Narragansett Laboratory.
;   This software may be used, copied, or redistributed as long as it is not sold and this copyright notice is reproduced on each copy made.
;   This routine is provided AS IS without any express or implied warranties whatsoever.
;
; AUTHOR:
;   This program was written on July 07, 2023 by Kimberly J. W. Hyde, Northeast Fisheries Science Center | NOAA Fisheries | U.S. Department of Commerce, 28 Tarzwell Dr, Narragansett, RI 02882
;    
; MODIFICATION HISTORY:
;   Jul 07, 2023 - KJWH: Initial code written
;-
; ****************************************************************************************************
  ROUTINE_NAME = 'FRONTS_THRESHOLD_DEMO'
  COMPILE_OPT IDL2
  SL = PATH_SEP()
  
  TEST_DIR = !S.FRONTAL_METRICS + 'IDL_TEST' + SL & DIR_TEST, TEST_DIR
  GRAD_SST_SUBSET = !S.FRONTAL_METRICS + 'csv_files/grad_sst_test_data.csv'
  
  F = GET_FILES('ACSPO', PRODS='GRAD_SST-BOA')
  D = STACKED_READ(F[-1])
  ms= maps_remap(D.grad_sst[*,*,38],bins=d.bins, map_in='L3B2',map_out='NES')
  subs = ms[400:499,400:499]
  write_csv,  grad_sst_subset, subs
  imgr, subs, prod='grad_sst', delay=5, PNG=TEST_DIR + 'grad_sst_test_data.png'
  ;STACKED_2PNGS, F[-1], PRODS='GRAD_SST', MAP_OUT='NES'
  STOP
  
 
  
  TESTDATA = !S.FRONTAL_METRICS + 'csv_files/simulated_grad_mag.csv'
  TDAT = CSV_READ(TESTDATA)
  TDAT = REFORM(TDAT.X,10,10)
  PLUN, [], 'Input grad mag values', 1
  PRINT, REFORM(ROUNDS(TDAT,2),10,10)
  TPNG = TEST_DIR + 'simulated_grad_mag_input_data.png'
  IF FILE_MAKE(TESTDATA,TPNG) THEN IMGR,TDAT,PNG=TPNG, DELAY=1
  
  THOLD = FRONTS_THRESHOLD(TDAT)
  PLUN, [], 'Threshold values', 1
  PRINT, REFORM(ROUNDS(THOLD,2),10,10)
  HPNG = TEST_DIR + 'simulated_grad_mag_threshold.png'
  IF FILE_MAKE(TESTDATA,HPNG) THEN IMGR,THOLD,PNG=HPNG, DELAY=1
  
  TFRONT = TDAT < THOLD
  
  STOP


END ; ***************** End of FRONTS_THRESHOLD_DEMO *****************
