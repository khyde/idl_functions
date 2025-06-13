; $ID:	BATCH_MUR.PRO,	2023-12-07-15,	USER-KJWH	$
  PRO BATCH_MUR, DATERANGE=DATERANGE, DO_ALL=DO_ALL, OVERWRITE=OVERWRITE, _EXTRA=EXTRA

;+
; NAME:
;   BATCH_MUR
;
; PURPOSE:
;   Batch program for processing the OCCCI dataset
;
; CATEGORY:
;   BATCH_FUNCTIONS
;
; CALLING SEQUENCE:
;   BATCH_MUR
;   
; REQUIRED INPUTS:
;   None
;
; OPTIONAL INPUTS:
;   DATERANGE.......... The date range of files to process
;   _EXTRA........... Used to indicate which processing steps to run
;
; KEYWORD PARAMETERS:
;   OVERWRITE........ Keyword to overwrite existing files
;   DO_ALL........... Set to do all processing steps
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
  ROUTINE_NAME = 'BATCH_MUR'
  COMPILE_OPT IDL3
  SL = PATH_SEP()
  
  DSET = 'MUR'
  
  ; ===> Manually adjust the processing steps as needed
  IF HAS(EXTRA,'DOWNLOAD_FILES') OR KEYWORD_SET(DO_ALL) THEN DOWNLOAD_FILES = 1 ELSE DOWNLOAD_FILES = 0
  IF HAS(EXTRA,'NC_2STACKED')    OR KEYWORD_SET(DO_ALL) THEN NC_2STACKED = 1    ELSE NC_2STACKED = 0
  IF HAS(EXTRA,'DO_FRONTS')      OR KEYWORD_SET(DO_ALL) THEN FRONTS = 1         ELSE FRONTS = 0
  IF HAS(EXTRA,'DO_STATS')       OR KEYWORD_SET(DO_ALL) THEN DO_STATS = 1       ELSE DO_STATS = 0
  IF HAS(EXTRA,'DO_ANOMS')       OR KEYWORD_SET(DO_ALL) THEN DO_ANOMS = 1       ELSE DO_ANOMS = 0
  IF HAS(EXTRA,'NETCDFS')        OR KEYWORD_SET(DO_ALL) THEN NETCDFS = 1        ELSE NETCDFS = 0

  IF ~N_ELEMENTS(DATERANGE) THEN DR = [] ELSE DR = GET_DATERANGE(DATERANGE)

  IF KEYWORD_SET(DOWNLOAD_FILES)  THEN DWLD_MUR_SST, YEARS=YEAR_RANGE(DR)                                               ; Download the full product suite (CHL, RRS, IOP) for the 4km global data
  IF KEYWORD_SET(NC_2STACKED)     THEN FILES_2STACKED_WRAPPER, DSET, PRODS=['SST'], DATERANGE=DR, MAP_OUT=['L3B4','L3B2'], OVERWRITE=OVERWRITE
  IF KEYWORD_SET(FRONTS)          THEN STACKED_MAKE_FRONTS_WRAPPER, DSET, /DO_STATS, /DO_FRONT_NETCDF, /DO_STAT_NETCDF, DATERANGE=DR, OVERWRITE=OVERWRITE
  IF KEYWORD_SET(DO_STATS)        THEN STACKED_STATS_WRAPPER, DSET, PRODS='SST', PERIODS=['W','M','A','WEEK','MONTH','ANNUAL','D3','D8','DOY'], MAPP=['L3B4','L3B2'], DATERANGE=DR, OVERWRITE=OVERWRITE
  IF KEYWORD_SET(DO_ANOMS)        THEN STACKED_ANOMS_WRAPPER, DSET, PRODS='SST',  PERIODS=['W','M','A'],MAPP=['L3B4','L3B2'], DATERANGE=DR, OVERWRITE=OVERWRITE

    

END ; ***************** End of BATCH_MUR *****************
