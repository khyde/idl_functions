; $ID:	STACKED_2PNGS.PRO,	2023-09-21-13,	USER-KJWH	$
  PRO STACKED_2PNGS, FILES, PRODS=PRODS, STATPRODS=STATPRODS, PNGPROD=PNGPROD, DATERANGE=DATERANGE, MAP_OUT=MAP_OUT, ADD_DATE=ADD_DATE, DIR_OUT=DIR_OUT, $
    NO_SAVE=NO_SAVE, OVERWRITE=OVERWRITE, _EXTRA=_EXTRA, OUTIMG=OUTIMG

;+
; NAME:
;   STACKED_2PNGS
;
; PURPOSE:
;   Create PNG files from the stacked files
;
; CATEGORY:
;   STACKED_FUNCTIONS
;
; CALLING SEQUENCE:
;   STACKED_2PNGS, FILES
;
; REQUIRED INPUTS:
;   FILES.............. Input "stacked" files (daily saves, stats, anomalies, etc.)
;
; OPTIONAL INPUTS:
;   PRODS....... The product names within the stacked files to plot
;   STATPRODS... For STAT files, indicate the "stat" (MEAN, MEDIAN, etc.) to be plotted
;   PNGPROD..... The plotting prod for the output png
;   DATERANGE... The daterange of the output pngs
;   DIR_OUT..... The output directory
;
; KEYWORD PARAMETERS:
;   OVERWRITE.... Overwrite existing files
;   INIT......... Reinitialize the COMMON information
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
;   This program was written on May 10, 2023 by Kimberly J. W. Hyde, Northeast Fisheries Science Center | NOAA Fisheries | U.S. Department of Commerce, 28 Tarzwell Dr, Narragansett, RI 02882
;    
; MODIFICATION HISTORY:
;   May 10, 2023 - KJWH: Initial code written
;-
; ****************************************************************************************************
  ROUTINE_NAME = 'STACKED_2PNGS'
  COMPILE_OPT IDL2
  SL = PATH_SEP()
  
  COMMON _STACKED_2PNGS, PREV_FILE=PREV_FILE, FILE_MTIME=FILE_MTIME, D=D, DB=DB
  IF KEYWORD_SET(INIT) THEN PREV_FILE = []
  
  IF ~N_ELEMENTS(DATERANGE) THEN DTR = [] ELSE DTR = GET_DATERANGE(DATERANGE)
  IF ~N_ELEMENTS(MAP_OUT) THEN MAPOUT='NES' ELSE MAPOUT=MAP_OUT
  
  FOR F=0, N_ELEMENTS(FILES)-1 DO BEGIN
    FP = PARSE_IT(FILES[F],/ALL)
    IF ~N_ELEMENTS(PRODS) THEN STACKED_PRODS = VALIDS('PRODS',FP.PROD) ELSE STACKED_PRODS = VALIDS('PRODS',PRODS)            ; If the STAT_PROD (the name of the product to extract and calculate stats) is not provided, use the default PROD from the file name
    IF FP.L2SUB EQ 'STACKED_STATS'  THEN IF ~N_ELEMENTS(STATPRODS) THEN STACKED_PRODS = STACKED_PRODS + '_MEAN' ELSE STACKED_PRODS = STACKED_PRODS + '_' + STATPRODS
    IF FP.L2SUB EQ 'STACKED_ANOMS'  THEN IF ~N_ELEMENTS(ANOMPRODS) THEN BEGIN
      CASE STACKED_PRODS OF
        'SST':  STACKED_PRODS = STACKED_PRODS + '_DIF' 
        ELSE:  STACKED_PRODS = STACKED_PRODS + '_RATIO' 
      ENDCASE  
    ENDIF ELSE STACKED_PRODS = STACKED_PRODS + '_' + ANOMPRODS

    IF STACKED_PRODS EQ '' THEN MESSAGE, 'ERROR: The input PROD is not a VALID product name'                                       ; Check that product name is "valid"
    
    IF PREV_FILE NE [] THEN BEGIN
      IF PREV_FILE NE FILES[F] OR FILE_MTIME NE GET_MTIME(FILES[F]) THEN D = STACKED_READ(FILES[F],DB=DB) 
    ENDIF ELSE D = STACKED_READ(FILES[F],DB=DB)
    PREV_FILE = FILES[F] & FILE_MTIME = GET_MTIME(PREV_FILE)
    IF DTR NE [] THEN OKSEQ = WHERE_MATCH(PERIOD_2DATE(DB.PERIOD), DATE_SELECT(PERIOD_2DATE(DB.PERIOD),DTR),COUNTSEQ) ELSE $
                                     OKSEQ = WHERE(DB.PERIOD NE MISSINGS(DB.PERIOD),COUNTSEQ)
      FOR M=0, N_ELEMENTS(MAPOUT)-1 DO BEGIN
        AMAP = MAPOUT[M]
        FOR S=0, N_ELEMENTS(STACKED_PRODS)-1 DO BEGIN
          APROD = STACKED_PRODS[S]
          VPROD = VALIDS('PRODS',APROD)
          IF HAS(APROD,'RATIO') THEN SPROD = 'RATIO' ELSE SPROD = VPROD
          IF N_ELEMENTS(PNGPROD) EQ 1 THEN SPROD = PNGPROD
          POS = WHERE(TAG_NAMES(D) EQ APROD,COUNT)
          IF COUNT NE 1 THEN MESSAGE, 'ERROR: ' + APROD + ' not found in structure'
          PDAT = D.(POS)
          
          PINFO  = WHERE(TAG_NAMES(D.INFO) EQ VPROD,COUNT)
          IF COUNT NE 1 THEN MESSAGE, 'ERROR: Need to figure out product information...'
          
          IF ~N_ELEMENTS(DIR_OUT) THEN DIROUT = REPLACE(FP.DIR,[FP.MAP,FP.PROD,'STACKED_SAVE','STACKED_STATS','STACKED_ANOMS'],[AMAP,APROD,'PNGS','PNGS','PNGS']) ELSE DIROUT=DIR_OUT
          IF ~KEYWORD_SET(NO_SAVE) THEN DIR_TEST, DIROUT
          
          FOR C=0, COUNTSEQ-1 DO BEGIN
            PNGFILE = DIROUT + REPLACE(FP.NAME, [FP.PERIOD,FP.MAP,FP.MAP_SUBSET,FP.PXY,FP.PROD,FP.L2SUB,'STACKED'],[DB[OKSEQ[C]].PERIOD,AMAP,'','',VPROD,'','']) + '.png'
            PNGFILE = REPLACE(PNGFILE,'-.','.')
            WHILE STRPOS(PNGFILE,'--') GT 0 DO PNGFILE = REPLACE(PNGFILE,'--','-')
                        
            IF DB[OKSEQ[C]].MTIME EQ 0 THEN CONTINUE ; Data does not exist in the file
            IF DB[OKSEQ[C]].MTIME LT GET_MTIME(PNGFILE) AND ~KEYWORD_SET(OVERWRITE) AND ~KEYWORD_SET(NO_SAVE) THEN CONTINUE
                        
            DAT = PDAT[*,*,OKSEQ[C]]
            DAT = MAPS_REMAP(DAT,MAP_IN=FP.MAP,MAP_OUT=AMAP,BINS=D.BINS)
            IF KEYWORD_SET(ADD_DATE) THEN BEGIN
              DP = PERIOD_2STRUCT(DB[OKSEQ[C]].PERIOD)
              IF DP.PERIOD_CODE EQ 'D' OR DP.PERIOD_CODE EQ 'S' THEN ADDDATE = DATE_FORMAT(DP.DATE_START,/DAY) ELSE $
                ADDDATE = DATE_FORMAT(DP.DATE_START,/DAY) + ' - ' + DATE_FORMAT(DP.DATE_END,/DAY)
            ENDIF ELSE ADDDATE = []
            PRODS_2PNG, DATA_IMAGE=DAT, MAPP=AMAP, PROD=SPROD, PNGFILE=PNGFILE, ADD_DATE=ADDDATE, _EXTRA=_EXTRA, NO_SAVE=NO_SAVE, OBJ=OUTIMG
            IF KEYWORD_SET(NO_SAVE) THEN GOTO, DONE
          ENDFOR ; SEQ
          
        ENDFOR; PRODS
      ENDFOR ; MAPS
    ENDFOR ; FILES
  
  DONE: 

END ; ***************** End of STACKED_2PNGS *****************
