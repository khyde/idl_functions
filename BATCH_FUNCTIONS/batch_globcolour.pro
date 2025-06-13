; $ID:	BATCH_GLOBCOLOUR.PRO,	2023-10-30-23,	USER-KJWH	$
  PRO BATCH_GLOBCOLOUR, DATERANGE=DATERANGE, OVERWRITE=OVERWRITE, _EXTRA=EXTRA

;+
; NAME:
;   BATCH_GLOBCOLOUR
;
; PURPOSE:
;   Batch program for processing the GLOBCOLOUR dataset
;
; CATEGORY:
;   BATCH_FUNCTIONS
;
; CALLING SEQUENCE:
;   BATCH_GLOBCOLOUR,
;   
; REQUIRED INPUTS:
;   None
;
; OPTIONAL INPUTS:
;   DATERANGE.......... The date range of files to process
;
; KEYWORD PARAMETERS:
;   OVERWRITE.......... Keyword to overwrite existing files
;
; OUTPUTS:
;   New and processed GLOBCOLOUR files
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
;   This program was written on October 30, 2023 by Kimberly J. W. Hyde, Northeast Fisheries Science Center | NOAA Fisheries | U.S. Department of Commerce, 28 Tarzwell Dr, Narragansett, RI 02882
;    
; MODIFICATION HISTORY:
;   Oct 30, 2023 - KJWH: Initial code written
;-
; ****************************************************************************************************
  ROUTINE_NAME = 'BATCH_GLOBCOLOUR'
  COMPILE_OPT IDL3
  SL = PATH_SEP()
  
  ; ===> Manually adjust the processing steps as needed
  IF HAS(EXTRA,'DOWNLOAD_FILES' ) THEN DOWNLOAD_FILES = 1 ELSE DOWNLOAD_FILES = 0
  IF HAS(EXTRA,'NC_2STACKED' )        THEN NC_2STACKED = 1        ELSE NC_2STACKED = 0
  IF HAS(EXTRA,'DO_PSC' )                      THEN PSC = 1                          ELSE PSC = 0
  IF HAS(EXTRA,'DO_PPD' )                      THEN PPD = 1                         ELSE PPD = 0
  IF HAS(EXTRA,'DO_STATS' )               THEN DO_STATS = 1              ELSE DO_STATS = 0
  IF HAS(EXTRA,'DO_ANOMS' )            THEN DO_ANOMS = 1            ELSE DO_ANOMS = 0
  IF HAS(EXTRA,'NETCDFS' )                THEN NETCDFS = 1                ELSE NETCDFS = 0

  IF ~N_ELEMENTS(DATERANGE) THEN DR = [] ELSE DR = GET_DATERANGE(DATERANGE)

  IF KEYWORD_SET(DOWNLOAD_FILES) THEN DWLD_GLOBCOLOUR, YEARS=YEAR_RANGE(DR)                                               ; Download the full product suite (CHL, RRS, IOP) for the 4km global data

  IF KEYWORD_SET(NC_2STACKED) THEN FILES_2STACKED_WRAPPER, 'GLOBCOLOUR', PRODS=['CHLOR_A-GSM','PAR','PIC','POC'], DATERANGE=DR, OVERWRITE=OVERWRITE

  IF KEYWORD_SET(PSC) THEN STACKED_MAKE_PRODS_WRAPPER, 'GLOBCOLOUR', /DO_PSC,DO_STATS=DO_STATS, DO_ANOMS=DO_ANOMS, MAPIN=['L3B4'], DATERANGE=DR, OVERWRITE=OVERWRITE
  IF KEYWORD_SET(PPD) THEN STACKED_MAKE_PRODS_WRAPPER, 'GLOBCOLOUR', /DO_PPD,/DO_STACKED,/DO_INTERP,DO_STATS=DO_STATS, DO_ANOMS=DO_ANOMS, DATERANGE=DR, OVERWRITE=OVERWRITE
  

END ; ***************** End of BATCH_GLOBCOLOUR *****************
