; $ID:	STACKED_MAKE_PRODS_WRAPPER.PRO,	2023-09-21-13,	USER-KJWH	$
  PRO STACKED_MAKE_PRODS_WRAPPER, DATASETS, MAPP=MAPP, DATERANGE=DATERANGE, OVERWRITE=OVERWRITE, _EXTRA=EXTRA
;+
; NAME:
;   STACKED_MAKE_PRODS_WRAPPER
;
; PURPOSE:
;   Wrapper program to create the PPD and PSC data
;
; CATEGORY:
;   STACKED_FUNCTIONS
;
; CALLING SEQUENCE:
;   STACKED_MAKE_PRODS_WRAPPER
;
; REQUIRED INPUTS:
;   None
;
; OPTIONAL INPUTS:
;   DATASETS.......... The input datasets
;   MAPP.................. The input data MAP
;   DATERANGE...... The daterange for processing the data
;
; KEYWORD PARAMETERS:
;   DO_STACKED..... Keyword to create the input stacked data files
;   DO_INTERP...... Keyword to run the interpolation step for the input data
;   DO_PPD......... Keyword to generate the PPD products
;   DO_PSC......... Keyword to generate the PSC products
;   DO_PARZ_LEE.... Keyword to generate the PARZ products
;   DO_STATS....... Keyword to generate the product (PPD or PSC) stats - Can also be used to indicate the stat periods to generate (e.g. DO_STATS=['M','MONTH'])
;   DO_ANOMS....... Keyword to generate the product (PPD or PSC) anomalies - Can also be used to indicate the anomaly periods to generate (e.g. DO_ANOMS=['M','A'])
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
;   This program was written on November 30, 2022 by Kimberly J. W. Hyde, Northeast Fisheries Science Center | NOAA Fisheries | U.S. Department of Commerce, 28 Tarzwell Dr, Narragansett, RI 02882
;    
; MODIFICATION HISTORY:
;   Nov 30, 2022 - KJWH: Initial code written
;   Oct 02, 2023 - KJWH: Added MAPP input
;-
; ****************************************************************************************************
  ROUTINE_NAME = 'STACKED_MAKE_PRODS_WRAPPER'
  COMPILE_OPT IDL2
  SL = PATH_SEP()
  DP = DATE_PARSE(DATE_NOW()) 
  
  IF ~N_ELEMENTS(DATASETS) THEN DATASETS = ['OCCCI','GLOBCOLOUR']
  
  IF HAS(EXTRA,'DO_STACKED') THEN DO_STACKED = 1 ELSE DO_STACKED = 0
  IF HAS(EXTRA,'DO_INTERP') THEN DO_INTERP = 1 ELSE DO_INTERP = 0
  IF HAS(EXTRA,'DO_PPD') THEN DO_PPD = 1 ELSE DO_PPD = 0
  IF HAS(EXTRA,'DO_PSC') THEN DO_PSC = 1 ELSE DO_PSC = 0
  IF HAS(EXTRA,'DO_PARZ_LEE') THEN DO_PARZ_LEE = 1 ELSE DO_PARZ_LEE = 0
  IF HAS(EXTRA,'DO_PSC_PPD') THEN DO_PSC_PPD = 1 ELSE DO_PSC_PPD = 0
  IF HAS(EXTRA,'DO_STATS') THEN DO_STATS =1 ELSE DO_STATS = 0
  IF HAS(EXTRA,'DO_ANOMS') THEN DO_ANOMS = 1 ELSE DO_ANOMS = 0
  IF HAS(EXTRA,'PSC_ALGS') THEN PSCALGS = EXTRA.PSC_ALGS ELSE PSCALGS = 'TURNER'
  
  IF ~N_ELEMENTS(MAPP) THEN MAPS = 'L3B4' ELSE MAPS=MAPP
  
  IF IDLTYPE(DO_STATS) NE 'STRING'  THEN STAT_PERS=['M','W','MONTH','WEEK','A','ANNUAL'] ELSE STAT_PERS = DO_STATS
  IF IDLTYPE(DO_ANOMS) NE 'STRING' THEN ANOM_PERS=['M','W','A'] ELSE ANOM_PERS = DO_ANOMS
  
  FOR D=0, N_ELEMENTS(DATASETS)-1 DO BEGIN
    DSET = DATASETS[D]
    IF ~N_ELEMENTS(DATERANGE) THEN DR = SENSOR_DATES(DSET,/YEAR) ELSE DR = GET_DATERANGE(DATERANGE)

    CASE DSET OF
      'OCCCI':      BEGIN & CPROD='CHLOR_A-CCI' & END
      'GLOBCOLOUR': BEGIN & CPROD='CHLOR_A-GSM' & END
    ENDCASE

    FOR M=0, N_ELEMENTS(MAPS)-1 DO BEGIN
      MAPIN = MAPS[M]      
      IF KEYWORD_SET(DO_STACKED) THEN BEGIN
        FILES_2STACKED_WRAPPER,DSET,PRODS=CPROD,MAP_OUT=MAPIN
        FILES_2STACKED_WRAPPER, 'GLOBCOLOUR',PRODS='PAR'
        FILES_2STACKED_WRAPPER,'MUR',PRODS='SST',MAP_OUT=MAPIN
        FILES_2STACKED_WRAPPER,'AVHRR',PRODS='SST'
      ENDIF  
    
      IF KEYWORD_SET(DO_INTERP) THEN BEGIN
        STACKED_INTERP, GET_FILES(DSET,PRODS=CPROD,FILE_TYPE='STACKED_SAVE',MAPS=MAPIN)
        STACKED_INTERP, GET_FILES('AVHRR',PRODS='SST', FILE_TYPE='STACKED_SAVE',MAPS=MAPIN,DATERANGE=['1996','2003'])    
      ENDIF
  
      IF KEYWORD_SET(DO_PPD) THEN BEGIN
        CF = GET_FILES(DSET,PRODS=CPROD,FILE_TYPE='STACKED_INTERP',DATERANGE=DR,MAPS=MAPIN, COUNT=COUNTF)
        PF = GET_FILES('GLOBCOLOUR',PRODS='PAR',FILE_TYPE='STACKED_SAVE',DATERANGE=DR,MAPS=MAPIN)
        SFA = GET_FILES('AVHRR',PRODS='SST', FILE_TYPE='STACKED_INTERP',DATERANGE=['1997','2002'],MAPS=MAPIN)
        SFM = GET_FILES('MUR',PRODS='SST', FILE_TYPE='STACKED_SAVE',DATERANGE=['2003',DR[1]],MAPS=MAPIN)
    
        STACKED_MAKE_PRODS_PPD, CHLFILES=CF, PARFILES=PF, SSTFILES=[SFA,SFM]
        IF KEYWORD_SET(DO_STATS) THEN STACKED_STATS_WRAPPER, DSET, PRODS='PPD-VGPM2', PERIODS=STAT_PERS, MAPP=MAPIN, L3BSUBSET='NWA', OUTSTATS=OUTSTATS, DATERANGE=DR, VERSION=VERSION, OVERWRITE=OVERWRITE
        IF KEYWORD_SET(DO_ANOMS) THEN STACKED_ANOMS_WRAPPER, DSET, PRODS='PPD-VGPM2',PERIODS=ANOM_PERS, MAPP=MAPIN, DATERANGE=DR
      ENDIF ; DO_PPD
    
      IF KEYWORD_SET(DO_PSC) THEN BEGIN  
        CF = GET_FILES(DSET,VERSION=EXTRA.VERSION,PRODS=CPROD,FILE_TYPE='STACKED_SAVE',DATERANGE=DR,MAPS=MAPIN)
        SFA = GET_FILES('AVHRR',PRODS='SST', FILE_TYPE='STACKED_INTERP',DATERANGE=['1997','2002'],MAPS=MAPIN)
        SFM = GET_FILES('MUR',PRODS='SST', FILE_TYPE='STACKED_SAVE',DATERANGE=['20030101',DR[1]],MAPS=MAPIN)
      
        IF HAS(PSCALGS,'TURNER') THEN BEGIN
          STACKED_MAKE_PRODS_PSC, CHLFILES=CF, SSTFILES=[SFA,SFM],PSC_ALGS='TURNER'
          IF KEYWORD_SET(DO_STATS) THEN STACKED_STATS_WRAPPER, DSET, PRODS='PSC-TURNER', PERIODS=STAT_PERS, MAPP=MAPIN, L3BSUBSET='NWA', OUTSTATS=OUTSTATS, DATERANGE=DR, VERSION=VERSION, OVERWRITE=OVERWRITE
          IF KEYWORD_SET(DO_ANOMS) THEN STACKED_ANOMS_WRAPPER, DSET, PRODS='PSC-TURNER',PERIODS=ANOM_PERS, DATERANGE=DR
        ENDIF
        IF HAS(PSCALGS,'HIRATA') THEN BEGIN
          STACKED_MAKE_PRODS_PSC, CHLFILES=CF, SSTFILES=[],PSC_ALGS='HIRATA'
          IF KEYWORD_SET(DO_STATS) THEN STACKED_STATS_WRAPPER, DSET, PRODS='PSC-HIRATA', PERIODS=STAT_PERS, MAPP=MAPIN, L3BSUBSET='NWA', OUTSTATS=OUTSTATS, DATERANGE=DR, VERSION=VERSION, OVERWRITE=OVERWRITE
          IF KEYWORD_SET(DO_ANOMS) THEN STACKED_ANOMS_WRAPPER, DSET, PRODS='PSC-HIRATA',PERIODS=ANOM_PERS, DATERANGE=DR
        ENDIF
      ENDIF ; DO_PSC
  
      IF KEYWORD_SET(DO_PARZ_LEE) THEN BEGIN
        AF = GET_FILES(DSET,PRODS='ATOT-QAA',FILE_TYPE='STACKED_SAVE', PERIOD='M', DATERANGE=DR)
        BF = GET_FILES(DSET,PRODS='BBP-QAA',FILE_TYPE='STACKED_SAVE', PERIOD='M',DATERANGE=DR)
        PF = GET_FILES('GLOBCOLOUR',PRODS='PAR',PERIODS='M')
        STACKED_MAKE_PRODS_PARZ, ABSFILES=AF, BBPFILES=BF, PARFILES=PF, DEPTHS=DEPTHS
      ENDIF
      
      IF KEYWORD_SET(DO_PSC_PPD) THEN BEGIN
        IF KEYWORD_SET(DO_STATS) THEN STACKED_STATS_WRAPPER, DSET, PRODS=['PPD-VGPM2','PSC_FMICRO-TURNER'], PERIODS='M', MAPP=MAPIN, L3BSUBSET='NWA', OUTSTATS=OUTSTATS, DATERANGE=DR, VERSION=VERSION, OVERWRITE=OVERWRITE        
        PPDF = GET_FILES(DSET,PRODS='PPD-VGPM2',VERSION=EXTRA.VERSION,FILE_TYPE='STACKED_STATS', PERIOD='M', DATERANGE=DR)
        PSCF = GET_FILES(DSET,PRODS='PSC_FMICRO-TURNER',VERSION=EXTRA.VERSION,FILE_TYPE='STACKED_STATS', PERIOD='M',DATERANGE=DR)
        STACKED_MAKE_PRODS_PSCPPD, PPDFILES=PPDF, PSCFILES=PSCF
      ENDIF
      
    ENDFOR ; MAPS  
  ENDFOR ; DATASETS
  
END ; ***************** End of STACKED_MAKE_PRODS_WRAPPER *****************
