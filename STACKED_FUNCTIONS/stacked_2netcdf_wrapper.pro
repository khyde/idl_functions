; $ID:	STACKED_2NETCDF_WRAPPER.PRO,	2023-09-21-13,	USER-KJWH	$
  PRO STACKED_2NETCDF_WRAPPER, DATASETS, PRODS=PRODS, STAT_PRODS=STAT_PRODS, ANOMS=ANOMS,$
                               PERIODS=PERIODS, MAPS=MAPS, NETCDFMAP=NETCDFMAP, DIR_OUT=DIR_OUT, DATERANGE=DATERANGE, LOGLUN=LOGLUN, $
                               OVERWRITE=OVERWRITE

;+
; NAME:
;   STACKED_2NETCDF_WRAPPER
;
; PURPOSE:
;   Wrapper program to STACKED_2NETCDF program to generate netcdf files from input "stacked" files
;
; CATEGORY:
;   STACKED_FUNCTIONS
;
; CALLING SEQUENCE:
;   STACKED_2NETCDF_WRAPPER,$Parameter1$, $Parameter2$, $Keyword=Keyword$, ....
;
; REQUIRED INPUTS:
;   DATASETS.......... The input datasets
;   PRODS............... The product names of the input files
;
; OPTIONAL INPUTS:
;   PERIODS.......... The period(s) of the input files
;   MAPS............. The map(s) of the input files
;   NETCDFMAP........ The name of the output netcdf map
;   DIR_OUT.......... The output directory
;   DATERANGE........ The daterange of the input files
;
; KEYWORD PARAMETERS:
;   ANOMS............ Use the anomaly files instead of stats
;   OVERWRITE........ Overwrite the output netcdf files if they already exist
;   
; OUTPUTS:
;   Creates netcdf files for the input dataset, product and period
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
;   This program was written on May 26, 2023 by Kimberly J. W. Hyde, Northeast Fisheries Science Center | NOAA Fisheries | U.S. Department of Commerce, 28 Tarzwell Dr, Narragansett, RI 02882
;    
; MODIFICATION HISTORY:
;   May 26, 2023 - KJWH: Initial code written
;-
; ****************************************************************************************************
  ROUTINE_NAME = 'STACKED_2NETCDF_WRAPPER'
  COMPILE_OPT IDL2
  SL = PATH_SEP()

  IF ~N_ELEMENTS(DATASETS) THEN MESSAGE, 'ERROR: Must provide at least one dataset'
  IF ~N_ELEMENTS(PRODS) THEN MESSAGE,'ERROF: Must provide at least one input product name'
  IF ~N_ELEMENTS(PERIODS) THEN PERS = 'D' ELSE PERS = PERIODS
  IF ~N_ELEMENTS(STAT_PRODS) THEN STATPRODS = ['NUM','MIN','MAX','MED','MEAN','STD'] ELSE STATPRODS=STAT_PRODS
  IF KEYWORD_SET(ANOMS) THEN FILETYPE='STACKED_ANOMS' ELSE FILETYPE = []

  FOR D=0, N_ELEMENTS(DATASETS)-1 DO BEGIN
    DSET = DATASETS[D]
    IF ~N_ELEMENTS(DATERANGE) THEN DR = GET_DATERANGE(SENSOR_DATES(DSET)) ELSE DR = GET_DATERANGE(DATERANGE)
    IF ~N_ELEMENTS(MAPS) THEN MPS = SENSOR_MAPS(DSET) ELSE MPS = MAPS
      
    FOR R=0, N_ELEMENTS(PRODS)-1 DO BEGIN
      FOR S=0, n_ELEMENTS(PERS)-1 DO BEGIN
        FOR M=0, N_ELEMENTS(MPS)-1 DO BEGIN
          CASE MPS[M] OF
            'L3B4': MOUT = 'NESGRID4'
            'L3B2': MOUT = 'NESGRID2'
            'L3B1': MOUT = 'NESGRID1'
          ENDCASE
          IF ~N_ELEMENTS(NETCDFMAP) THEN MPOUT = MOUT ELSE MPOUT = NETCDFMAP
          
          VPROD = VALIDS('PRODS',PRODS[R])
          
          FILES = GET_FILES(DSET, PRODS=PRODS[R], PERIODS=PERS[S], MAPS=MPS[M], DATERANGE=DR, COUNT=COUNT,FILE_TYPE=FILETYPE)
          IF COUNT EQ 0 THEN CONTINUE
          
          FP = PARSE_IT(FILES[0],/ALL)
          IF ~N_ELEMENTS(DIR_OUT) THEN DIROUT = REPLACE(FP.DIR,[FP.MAP,FP.L2SUB],[MPOUT,'NETCDF']) ELSE DIROUT=DIR_OUT
          DIR_TEST, DIROUT
          
          CASE FP.L2SUB OF
            'STACKED_SAVE': NPRODS=VPROD
            'STACKED_STATS':NPRODS=VPROD + '_' + STATPRODS
            'STACKED_ANOMS':BEGIN
              CASE VPROD OF
                'CHLOR_A': NPRODS=VPROD + '_RATIO'
                'PPD': NPRODS=VPROD + '_RATIO'
                'SST': NPRODS=VPROD+'_DIF'
                'PSC_MICRO': NPRODS=VPROD+'_RATIO'
                'PSC_NANO': NPRODS=VPROD+'_RATIO'
                'PSC_PICO': NPRODS=VPROD+'_RATIO'
              ENDCASE
             END  
          ENDCASE
          
          STACKED_2NETCDF, FILES, D3PRODS=NPRODS, PERIOD_OUT=PERS[S], DIR_OUT=DIROUT, MAP_OUT=MPOUT, LOGLUN=LOGLUN, OVERWRITE=OVERWRITE        
          
        ENDFOR ; MAPS
      ENDFOR ; PERIODS
    ENDFOR ; PRODS
  ENDFOR; DATASETS  


END ; ***************** End of STACKED_2NETCDF_WRAPPER *****************
