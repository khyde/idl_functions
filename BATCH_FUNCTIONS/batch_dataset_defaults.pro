; $ID:	BATCH_DATASET_DEFAULTS.PRO,	2023-12-07-16,	USER-KJWH	$
  FUNCTION BATCH_DATASET_DEFAULTS, DATASETS

;+
; NAME:
;   BATCH_DATASET_DEFAULTS
;
; PURPOSE:
;   $PURPOSE$
;
; CATEGORY:
;   BATCH_FUNCTIONS
;
; CALLING SEQUENCE:
;   Result = BATCH_DATASET_DEFAULTS($Parameter1$, $Parameter2$, $Keyword=Keyword$, ...)
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
;   This program was written on December 07, 2023 by Kimberly J. W. Hyde, Northeast Fisheries Science Center | NOAA Fisheries | U.S. Department of Commerce, 28 Tarzwell Dr, Narragansett, RI 02882
;    
; MODIFICATION HISTORY:
;   Dec 07, 2023 - KJWH: Initial code written
;-
; ****************************************************************************************************
  ROUTINE_NAME = 'BATCH_DATASET_DEFAULTS'
  COMPILE_OPT IDL3
  SL = PATH_SEP()
  DP = DATE_PARSE(DATE_NOW())
  
  ; Default datasets
  IF ~N_ELEMENTS(DATASETS) THEN DSETS = ['OCCCI','ACSPO','ACSPONRT','MUR','AVHRR','GLOBCOLOUR']
  
  ; Default periods
  STAT_PERIODS = ['W','M','A','WEEK','MONTH','ANNUAL','D3','D8','DOY']
  ANOM_PERIODS=['W','M','A','D']
  ERDDAP_PERIODS = ['M']
  MAP_OUT = ['L3B2','L3B4']
  
  ; Default processing switches
  STEPS = CREATE_STRUCT($
    'DOWNLOAD_FILES', 1, $
    'NC_2STACKED', 1, $
    'PSC', 0, $
    'PPD', 0, $
    'FRONTS', 1, $
    'DO_STATS', 1, $
    'DO_ANOMS', 1, $
    'DO_NETCDFS', 0, $
    'DO_ERDDAP', 0, $
    'DO_ALL', 0)
  
  STRUCT = []
  
  FOR D=0, N_ELEMENTS(DSETS)-1 DO BEGIN
    DSET = DSETS[D]
    DATERANGE = SENSOR_DATES(DSET,/YEAR)
    DOWNLOAD_DATERANGE = DATERANGE
    STPS = STEPS ; Reinitialize the STEPS structure
    CASE DSET OF
      'OCCCI': BEGIN
        STPS.PSC = 1
        STPS.PPD = 1
      END ; OCCCI  
      'GLOBCOLOUR': BEGIN
        STPS.PSC = 1
        STPS.PPD = 1
        STPS.FRONTS = 0
        DOWNLOAD_DATERANGE = [DP.YEAR-1,DP.YEAR]
        STAT_PERIODS = ['W','M','A','WEEK','MONTH','ANNUAL']
        MAP_OUT = ['L3B4']
      END ; GLOBCOLOUR
      'AVHRR': BEGIN
        MAP_OUT = ['L3B4']
      END ; AVHRR
      ELSE: 
    ENDCASE
    
    STR = CREATE_STRUCT('DATASET',DSET, 'DATERANGE', DATERANGE, 'DOWNLOAD_DATERANGE', DOWNLOAD_DATERANGE, 'MAP_OUT',MAP_OUT, 'STAT_PERIODS',STAT_PERIODS, 'ANOM_PERIODS',ANOM_PERIODS, 'PROCESSING_STEPS',STPS)
    STRUCT = CREATE_STRUCT(STRUCT, DSET, STR)
    
  ENDFOR
  
  RETURN, STRUCT


END ; ***************** End of BATCH_DATASET_DEFAULTS *****************
