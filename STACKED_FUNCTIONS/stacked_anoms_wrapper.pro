; $ID:	STACKED_ANOMS_WRAPPER.PRO,	2023-09-21-13,	USER-KJWH	$
  PRO STACKED_ANOMS_WRAPPER, DATASETS, PRODS=PRODS, PERIODS=PERIODS, MAPP=MAPP, DATERANGE=DATERANGE, CLIMATOLOGY_RANGE=CLIMATOLOGY_RANGE, VERSION=VERSION, OVERWRITE=OVERWRITE

;+
; NAME:
;   STACKED_ANOMS_WRAPPER
;
; PURPOSE:
;   $PURPOSE$
;
; CATEGORY:
;   STACKED_FUNCTIONS
;
; CALLING SEQUENCE:
;   STACKED_ANOMS_WRAPPER,$Parameter1$, $Parameter2$, $Keyword=Keyword$, ....
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
; Copyright (C) 2022, Department of Commerce, National Oceanic and Atmospheric Administration, National Marine Fisheries Service,
;   Northeast Fisheries Science Center, Narragansett Laboratory.
;   This software may be used, copied, or redistributed as long as it is not sold and this copyright notice is reproduced on each copy made.
;   This routine is provided AS IS without any express or implied warranties whatsoever.
;
; AUTHOR:
;   This program was written on December 08, 2022 by Kimberly J. W. Hyde, Northeast Fisheries Science Center | NOAA Fisheries | U.S. Department of Commerce, 28 Tarzwell Dr, Narragansett, RI 02882
;    
; MODIFICATION HISTORY:
;   Dec 08, 2022 - KJWH: Initial code written
;-
; ****************************************************************************************************
  ROUTINE_NAME = 'STACKED_ANOMS_WRAPPER'
  COMPILE_OPT IDL2
  SL = PATH_SEP()
 
 
  IF ~N_ELEMENTS(DATASETS) THEN MESSAGE, 'ERROR: Must provide at least one input dataset.'
  IF ~N_ELEMENTS(PRODS)    THEN MESSAGE, 'ERROR: Must provide at least on product name.'
  IF ~N_ELEMENTS(PERIODS)  THEN PERIODS = ['W','M','A'] ; MESSAGE, 'ERROR: Must provide at least one output period code.'
  IF N_ELEMENTS(DATASETS) GT 1 AND TYPENAME(PRODS) NE 'LIST' THEN MESSAGE, 'ERROR: If more than one dataset provided, must input product names as a "LIST"'
  IF ~N_ELEMENTS(VERSION) THEN VERSION = []
  IF N_ELEMENTS(MAPP) GE 1 THEN MAPS = MAPP ELSE MAPS = ''
  IF ~N_ELEMENTS(CLIMATOLOGY_RANGE) THEN CLIM_RANGE = 'DEFAULT' ELSE CLIM_RANGE = CLIMATOLOGY_RANGE

  FOR D=0, N_ELEMENTS(DATASETS)-1 DO BEGIN
    DATASET = DATASETS[D]
    IF TYPENAME(PRODS) EQ 'LIST' THEN DPRODS = PRODS[D] ELSE DPRODS = PRODS

    FOR M=0, N_ELEMENTS(MAPS)-1 DO BEGIN
      MP = MAPS[M]
      IF MP EQ '' THEN MP = []

      ; TODO ===> Set up dataset specific information
      CASE DATASET OF
        'ACSPONRT': CLIMDATASET = 'ACSPO'
        ELSE: CLIMDATASET = DATASET
      ENDCASE
      IF TYPENAME(PRODS) EQ 'LIST' THEN DPRODS = PRODS[D] ELSE DPRODS = PRODS
  
      FOR A=0, N_ELEMENTS(DPRODS)-1 DO BEGIN
        APROD = DPRODS[A]
        ALG = VALIDS('ALGS',DPRODS[A])
  
         ; ===> Get the output products from input files that have multiple products (e.g. PSC) 
        CASE VALIDS('PRODS',APROD) OF 
          'PSC': OPRODS = ['PSC_MICRO','PSC_NANO','PSC_PICO','PSC_FMICRO','PSC_FNANO','PSC_FPICO'] + '-' + ALG
          ELSE:  OPRODS = APROD  
        ENDCASE
  
        FOR O=0, N_ELEMENTS(OPRODS)-1 DO BEGIN
          OPROD = OPRODS[O]
  
          ; ===> Clean up files before starting (in case this step doesn't get to run at the end
          FILES = GET_FILES(DATASET,PRODS=OPROD,FILE_TYPE='STACKED_ANOMS',VERSION=VERSION,MAPS=MP,COUNT=COUNT,CLIMATOLOGY=CLIM_RANGE) & FP = FILE_PARSE(FILES)
          ;IF COUNT GT 1 THEN STACKED_ANOMS_CLEANUP, FP[0].DIR,MOVE_FILES=0
          STACKED_STATS_CLEANUP, DATASET, PRODS=OPROD, MAPS=MP,MOVE_FILES=0 ; Double check that the STAT directories don't include any "OLD" files

          FOR R=0, N_ELEMENTS(PERIODS)-1 DO BEGIN
            STATPERIOD = PERIODS[R]
            CSTR = PERIODS_READ(STATPERIOD)
            IF CSTR EQ [] THEN MESSAGE, 'ERROR: ' + STATPERIOD + ' is not a valid period code.'                                           ; Make sure the period code is valid
            CLIMPERIOD = CSTR.ANOM_PERIOD
            IF CLIMPERIOD EQ '' THEN MESSAGE, 'ERROR: Check the ANOM_PERIOD in PERIODS_MAIN.csv'
    
            
            STATFILES   = GET_FILES(DATASET,PRODS=OPROD, MAPS=MP,PERIODS=STATPERIOD, FILE_TYPE='STACKED', DATERANGE=DATERANGE,VERSION=VERSION,COUNT=COUNTS)
            CLIMATOLOGY = GET_FILES(CLIMDATASET,PRODS=OPROD, MAPS=MP,PERIODS=CLIMPERIOD, FILE_TYPE='STACKED', DATERANGE=DATERANGE,VERSION=VERSION,COUNT=COUNTC)
            IF COUNTS EQ 0 OR COUNTC EQ 0 THEN CONTINUE
            
            FOR C=0, N_ELEMENTS(CLIMATOLOGY)-1 DO BEGIN
              PLUN, LUN, 'Running ANOMS for ' + DATASET + ' - ' + OPROD + ' for period ' + STATPERIOD
              STACKED_ANOMS, STATFILES, CLIMATOLOGY[C]
            ENDFOR ; CLIMATOLOGIES  
            
          ENDFOR ; PERIODS
          
          FILES = GET_FILES(DATASET,PRODS=OPROD,FILE_TYPE='STACKED_ANOMS',VERSION=VERSION,MAPS=MP,COUNT=COUNT) & FP = FILE_PARSE(FILES)
          ;IF COUNT GT 1 THEN STACKED_ANOMS_CLEANUP, FP[0].DIR,MOVE_FILES=0
  
        ENDFOR ; OUTPUT PRODUCTS (OPRODS)  
      ENDFOR ; PRODS
    ENDFOR ; MAPS  
  ENDFOR ; DATASETS    


END ; ***************** End of STACKED_ANOMS_WRAPPER *****************
