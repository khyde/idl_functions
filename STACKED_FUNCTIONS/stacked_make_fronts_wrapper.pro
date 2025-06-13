; $ID:	STACKED_MAKE_FRONTS_WRAPPER.PRO,	2023-09-21-13,	USER-KJWH	$
  PRO STACKED_MAKE_FRONTS_WRAPPER, DATASETS, MAPS=MAPS, STAT_PERIODS=STAT_PERIODS, THRESHOLD_BOX=THRESHOLD_BOX, MAP_SUBSET=MAP_SUBSET,$
    INDICATOR_PERIODS=INDICATOR_PERIODS, NETCDF_MAP=NETCDF_MAP, DATERANGE=DATERANGE, _REF_EXTRA=EXTRA

;+
; NAME:
;   STACKED_MAKE_FRONTS_WRAPPER
;
; PURPOSE:
;   $PURPOSE$
;
; CATEGORY:
;   STACKED_FUNCTIONS
;
; CALLING SEQUENCE:
;   Result = STACKED_MAKE_FRONTS_WRAPPER($Parameter1$, $Parameter2$, $Keyword=Keyword$, ...)
;
; REQUIRED INPUTS:
;   None 
;
; OPTIONAL INPUTS:
;   DATASETS.......... Input dataset name(s)
;   STAT_PERIODS...... Stat periods to calculate
;   NETCDF_MAP........ The output map for the netcdf file
;
; KEYWORD PARAMETERS:
;   DO_STATS.......... Set keyword to run the frontal stats step
;   DO_FRONT_NETCDF... Set keyword to create netcdf files of the daily frontal data
;   DO_STAT_NETCDF.... Set keyword to create netcdf files of the frontal stats data
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
;   This program was written on January 06, 2023 by Kimberly J. W. Hyde, Northeast Fisheries Science Center | NOAA Fisheries | U.S. Department of Commerce, 28 Tarzwell Dr, Narragansett, RI 02882
;    
; MODIFICATION HISTORY:
;   Jan 06, 2023 - KJWH: Initial code written
;   Jan 30, 2023 - KJWH: Now looping through datasets - default datasets = AVHRR, CORAL, OCCCI
;                        Added DATASETS, STAT_PERIODS and NETCDF_MAP as optional input variables
;                        Added keywords, DO_STATS, DO_FRONT_NETCDF, DO_STAT_NETCDF to control the steps (the default is to do each step)
;                        If not input SST or CHL files are found, CONTINUE in the dataset loop
;   Aug 16, 2023 - KJWH: Added _REF_EXTRA=EXTRA keyword to use in place of the DO_STACKED, DO_FRONTS, etc keywords
;                        Added DO_INDICATORS step
;                        Added THRESHOLDBOX keyword 
;                        Now basing the output netcdf map on the input map
;                        
;-
; ****************************************************************************************************
  ROUTINE_NAME = 'STACKED_MAKE_FRONTS_WRAPPER'
  COMPILE_OPT IDL2
  SL = PATH_SEP()
  
  IF ~N_ELEMENTS(DATASETS) THEN DSETS = ['ACSPO','ACSPONRT','AVHRR','CORAL','MUR','OCCCI','GLOBCOLOUR'] ELSE DSETS = DATASETS
  IF ~N_ELEMENTS(STAT_PERIODS) THEN STATPERIODS = ['M','W','A','D8','WEEK','MONTH','ANNUAL'] ELSE STATPERIODS=STAT_PERIODS
  IF ~N_ELEMENTS(INDICATOR_PERIODS) THEN INDPERIODS = ['M','W','SEA'] ELSE INDPERIODS = INDICATOR_PERIODS
  IF ~N_ELEMENTS(THRESHOLD_BOX) THEN THRESHBOX = [3,9,15] ELSE THRESHBOX = THRESHOLD_BOX
  IF ~N_ELEMENTS(MAP_SUBSET) THEN MAPSUBSET = 'NWA' ELSE MAPSUBSET = MAP_SUBSET
    
  IF HAS(EXTRA,'DO_STACKED')      THEN DO_STACKED      = 1 ELSE DO_STACKED      = 0
  IF HAS(EXTRA,'DO_FRONTS')       THEN DO_FRONTS       = 1 ELSE DO_FRONTS       = 0
  IF HAS(EXTRA,'DO_STATS')        THEN DO_STATS        = 1 ELSE DO_STATS        = 0
  IF HAS(EXTRA,'DO_INDICATORS')   THEN DO_INDICATORS   = 1 ELSE DO_INDICATORS   = 0
  IF HAS(EXTRA,'DO_FRONT_NETCDF') THEN DO_FRONT_NETCDF = 1 ELSE DO_FRONT_NETCDF = 0
  IF HAS(EXTRA,'DO_STAT_NETCDF')  THEN DO_STAT_NETCDF  = 1 ELSE DO_STAT_NETCDF  = 0
  
  FOR N=0, N_ELEMENTS(DSETS)-1 DO BEGIN
    DSET = DSETS[N]
    
    CASE DSET OF 
      'OCCCI':      BEGIN & INPROD='CHLOR_A-CCI' & GPROD='GRAD_CHLKM-BOA' & NPROD='CHL' & MAPIN='L3B2' & END
      'GLOBCOLOUR': BEGIN & INPROD='CHLOR_A-GSM' & GPROD='GRAD_CHLKM-BOA' & NPROD='CHL' & MAPIN='L3B4' & END
      'MUR':        BEGIN & INPROD='SST'         & GPROD='GRAD_SSTKM-BOA' & NPROD='SST' & MAPIN='L3B2' & END
      ELSE:         BEGIN & INPROD='SST'         & GPROD='GRAD_SSTKM-BOA' & NPROD='SST' & MAPIN = SENSOR_MAPS(DSET)  & END
    ENDCASE
    
    IF N_ELEMENTS(MAPS) EQ 1 THEN MAPIN = MAPS[0]
    
    CASE MAPIN OF
      'L3B1': NCMAP = 'NESGRID'
      'L3B2': NCMAP = 'NESGRID2'
      'L3B4': NCMAP = 'NESGRID4'
    ENDCASE
    IF ~N_ELEMENTS(NETCDF_MAP) THEN NMAP = NCMAP ELSE NMAP = NETCDF_MAP
    
    IF KEYWORD_SET(DO_STACKED) THEN FILES_2STACKED_WRAPPER,DSET,PRODS=INPROD, MAP_OUT=MAPIN, DATERANGE=DATERANGE
        
    SFILES = GET_FILES(DSET,PRODS=INPROD, FILE_TYPE='STACKED_SAVE',MAPS=MAPIN, DATERANGE=DATERANGE, COUNT=COUNT)
    IF COUNT EQ 0 THEN CONTINUE
    
    IF KEYWORD_SET(DO_FRONTS) THEN STACKED_MAKE_FRONTS, SFILES, THRESHOLD_BOX=THRESHBOX, MAP_SUBSET=MAPSUBSET
    IF KEYWORD_SET(DO_STATS) THEN STACKED_STATS_WRAPPER, DSET, PRODS=GPROD,PERIODS=STATPERIODS, DATERANGE=DATERANGE
    
    SFILES = GET_FILES(DSET,PRODS=GPROD, FILE_TYPE='STACKED_SAVE', MAPS=MAPIN, DATERANGE=DATERANGE, COUNT=COUNT)
    IF KEYWORD_SET(DO_INDICATORS) AND COUNT GT 0 THEN STACKED_FRONT_INDICATORS, SFILES, NC_MAP=NMAP,PERIOD_CODE=INDPERIODS
  
    SFILES = GET_FILES(DSET,PRODS=GPROD, FILE_TYPE='STACKED_SAVE', MAPS=MAPIN, COUNT=COUNT)
    IF KEYWORD_SET(DO_FRONT_NETCDF) AND COUNT GT 0 THEN STACKED_2NETCDF, SFILES, MAP_OUT=NMAP, D3PRODS=[['GRAD','GRADX','GRADY']+'_'+NPROD, ['GRAD','GRADX','GRADY']+'_'+NPROD+'KM','GRAD'+NPROD+'_DIR']
    
    SFILES = GET_FILES(DSET,PRODS=GPROD, FILE_TYPE='STACKED_STATS', MAPS=MAPIN, PERIODS=STATPERIODS, COUNT=COUNT)
    IF KEYWORD_SET(DO_STAT_NETCDF)  AND COUNT GT 0 THEN STACKED_2NETCDF, SFILES, MAP_OUT=NMAP, D3PRODS=[['GRAD','GRADX','GRADY']+'_'+NPROD,'GRAD_'+NPROD+'_'+['NUM','MIN','MAX','VAR'],'GRAD'+NPROD+'_DIR']
  
  ENDFOR
  

END ; ***************** End of STACKED_MAKE_FRONTS_WRAPPER *****************
