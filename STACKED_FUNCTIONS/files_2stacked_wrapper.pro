; $ID:	FILES_2STACKED_WRAPPER.PRO,	2023-09-21-13,	USER-KJWH	$
  PRO FILES_2STACKED_WRAPPER, DATASETS, PRODS=PRODS, VERSION=VERSION, MAP_IN=MAP_IN, MAP_OUT=MAP_OUT, L3BSUBMAP=L3BSUBMAP, $
      PERIODS=PERIODS, DATERANGE=DATERANGE, DOY=DOY, REFRESH=REFRESH, ANALYSIS_ERROR=ANALYSIS_ERROR, DIR_OUT=DIR_OUT, OVERWRITE=OVERWRITE
;+
; NAME:
;   FILES_2STACKED_WRAPPER
;
; PURPOSE:
;   This program pulls together the DATASET specific information and calls FILES_2STACKED
;
; CATEGORY:
;   STACKED_FUNCTIONS
;
; CALLING SEQUENCE:
;   FILES_2STACKED_WRAPPER,DATASETS
;
; REQUIRED INPUTS:
;   DATASETS....... The dataset(s) to process
;
; OPTIONAL INPUTS:
;   DIR............. Location of the input directory  
;   PRODS........... Product names 
;   DIR_OUT......... Directory to store the stacked files 
;   VERSION......... The version of the data (used for the directory structure)
;   MAP_OUT......... Map to produce from the OCCCI files
;   L3BSUBSET....... Map to subset the L3B file
;   LOGLUN.......... If provided, the LUN for the log file
;   DATERANGE.... The daterange of the input files
;
; KEYWORD PARAMETERS:
;   DOY.................. Passed to FILES_2STACKED -> if set, will create 365 STACKED_TEMP DOY files that will be used when calculating the climatological DOY stats
;   REFRESH......... Refresh the MAPS_REMAP common memory
;   ANALYSIS_ERROR.. Include the analysis error data in the saved structure
;   OVERWRITE....... Overwrite file if it exists
;   
; OUTPUTS:
;   A "stacked" .SAV file with a single years worth of files in the stacked file
;
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
;   FILES_2STACKED_WRAPPER, DATASETS
;   FILES_2STACKED_WRAPPER, DATASETS, PRODS=['CHL']
;   FILES_2STACKED_WRAPPER, DATASETS, PRODS=['CHL','RRS'], MAPS_OUT=['L3B4']
;   FILES_2STACKED_WRAPPER, DATASETS, PRODS=['CHL','RRS'], MAPS_OUT=['L3B4'], /REFRESH
;   FILES_2STACKED_WRAPPER, DATASETS, PRODS=['CHL','RRS'], MAPS_OUT=['L3B4'], /REFRESH, L3BSUBSET='NWA'
;   FILES_2STACKED_WRAPPER, DATASETS, PRODS=['CHL','RRS'], MAPS_OUT=['L3B4'], /REFRESH, L3BSUBSET='NWA', /ANALYSIS_ERROR, /OVERWRITE
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
;   This program was written on December 02, 2022 by Kimberly J. W. Hyde, Northeast Fisheries Science Center | NOAA Fisheries | U.S. Department of Commerce, 28 Tarzwell Dr, Narragansett, RI 02882
;    
; MODIFICATION HISTORY:
;   Dec 02, 2022 - KJWH: Initial code written
;   Jan 24, 2023 - KJWH: Added the optional DATERANGE input
;   Feb 28, 2023 - KJWH: Added the DOY keyword and inputs to create the day-of-year STACKED_TEMP files
;   Mar 06, 2024 - KJWH: Added DIR_OUT to the input options
;-
; ****************************************************************************************************
  ROUTINE_NAME = 'FILES_2STACKED_WRAPPER'
  COMPILE_OPT IDL2
  SL = PATH_SEP()
  
  ; ===> Set up the defauls
  DIR_LOG = !S.LOGS + ROUTINE_NAME + SL & DIR_TEST, DIR_LOG
  IF ~N_ELEMENTS(LOGLUN)    THEN LOG_LUN = [] ELSE LOG_LUN = LOGLUN
  IF ~N_ELEMENTS(MAP_IN) THEN MAP_IN = ''
  IF ~N_ELEMENTS(MAP_OUT)  THEN MP = 'L3B4' ELSE MP = MAP_OUT
  IF ~N_ELEMENTS(L3BSUBMAP) THEN L3BSUBMAP = 'NWA'
  IF ~N_ELEMENTS(VERSION)   THEN VERSION = ''
  IF ~N_ELEMENTS(PERIODS) THEN PERS = '' ELSE PERS = PERIODS
  IF ~N_ELEMENTS(DATERANGE) THEN DTR = [] ELSE DTR = GET_DATERANGE(DATE_2YEAR([MIN(DATERANGE),MAX(DATERANGE)])) ; Be sure to convert the daterange to years to get the complete year
  IF KEYWORD_SET(ANALYSIS_ERROR) THEN AN_ERR = 1 ELSE AN_ERR = 0
  
  FOR D=0, N_ELEMENTS(DATASETS)-1 DO BEGIN
    DSET = DATASETS[D]
    IF ~N_ELEMENTS(DIR) THEN DIR = GET_DATASET_DIR(DSET)
    
    FOR M=0, N_ELEMENTS(MP)-1 DO BEGIN
      FILETYPE = 'NC'
      
      ; Set the default products (DPRDS), periods, and input/output maps for specific datasets
      CASE DSET OF             
        'OCCCI': BEGIN 
          DPRODS='CHLOR_A-CCI' 
          CASE MAP_IN OF 
            '1KM': BEGIN & MAPIN='SOURCE_1KM' & DMAP='L3B2' & END
            '4KM': BEGIN & MAPIN='SOURCE_MONTHLY' & DMAP='L3B4' & PERS='MONTHLY' & END
              ELSE: BEGIN & MAPIN='SOURCE' & DMAP='L3B4' & IF PERS[0] EQ '' THEN PERS=['DAILY'] & IF KEYWORD_SET(DOY) THEN PERS = '' & END
           ENDCASE  
        END
        'GLOBCOLOUR': BEGIN & DPRODS=['CHLOR_A-GSM','PAR'] & MAPIN='L3' & DMAP='L3B4' & END
        'CORAL': BEGIN & DPRODS='SST' & MAPIN='L3' & DMAP='L3B5' & END 
        'AVHRR': BEGIN & DPRODS='SST' & MAPIN='L3' & DMAP='L3B4' & END
        'MUR':    BEGIN & DPRODS='SST' &  MAPIN='L4' & IF ~N_ELEMENTS(MAP_OUT) THEN DMAP=['L3B4','L3B2'] ELSE DMAP=MAP_OUT & END
        'ACSPO': BEGIN & DPRODS='SST' & MAPIN='SOURCE' & DMAP='L3B2' & END
        'ACSPONRT': BEGIN & DPRODS='SST' & MAPIN='SOURCE' & DMAP='L3B2' & END
      ENDCASE ; DSET
      IF MP[M] NE 'L3B4' THEN OMAP = MP[M] ELSE OMAP = DMAP
        
      FOR R=0, N_ELEMENTS(PERS)-1 DO BEGIN
        APER = PERS[R]
        
        IF N_ELEMENTS(PRODS) GT 0 THEN SPRODS = STRUPCASE(PRODS) ELSE SPRODS = DPRODS
        FOR S=0, N_ELEMENTS(SPRODS)-1 DO BEGIN ; Loop through dataset/sensor prods
          APROD = SPRODS[S]
          OPRODS = APROD
          MPROD=[]
          CASE APROD OF  ; Get prod specific information (netcdf product=NPROD, output product(s)=OPRODS)
            'RRS': BEGIN & NPROD='RRS' & OPRODS = 'RRS_'+['412', '443', '490', '510', '560', '665']  & MPROD='RRS' & END
            'CHLOR_A-CCI': BEGIN & NPROD='CHL' & IF MAP_IN EQ '1KM' THEN NPROD='CHLOR_A-CCI' & END
            'CHLOR_A-GSM': NPROD='CHL1'
            'CHLOR_A-AV': NPROD='CHL1_AV'
            'KD_490': BEGIN & NPROD='KD490' & OPRODS = 'KD_490-ZHANG' & END
            'ADG': BEGIN & NPROD='IOP' &  OPRODS='ADG_'+['412', '443', '490', '510', '560', '665'] +'-QAA' & MPROD='ADG' & END
            'APH': BEGIN & NPROD='IOP' & OPRODS='APH_'+['412', '443', '490', '510', '560', '665'] +'-QAA' & MPROD='APH' & END
            'ATOT': BEGIN & IF APER EQ 'MONTHLY' THEN NPROD='ATOT' ELSE NPROD='IOP' & OPRODS='ATOT_'+['412', '443', '490', '510', '560', '665'] +'-QAA' & MPROD='ATOT' & END
            'BBP': BEGIN & IF APER EQ 'MONTHLY' THEN NPROD='BBP' ELSE NPROD='IOP' & OPRODS='BBP_'+['412', '443', '490', '510', '560', '665'] +'-QAA' & MPROD='BBP' & END
  ;'PHYTO_SIZE-TURNER': BEGIN & NPROD='PHYTO_SIZE-TURNER' & OPRODS=['MICRO','NANO','PICO','FMICRO','FNANO','FPICO'] + '-TURNER' & IF VERSION EQ '5.0' THEN FILETYPE='SAVE' & MAPIN='L3B4' & APER='' & END
            'SST': BEGIN & IF DSET EQ 'MUR' THEN OPRODS=['SST','SST_ERROR'] ELSE OPRODS = 'SST' & NPROD=APROD & END
            'GRAD_SST': BEGIN
              IF DSET EQ 'ACSPO' OR DSET EQ 'ACSPONRT' THEN  OPRODS = ['SST','GRAD_SST','GRADSST_FRONT'] ELSE OPRODS=[]
              MPROD = 'GRAD_SST'
              NPROD = 'SST'
            END  
            ELSE: NPROD = APROD
          ENDCASE
                
          IF KEYWORD_SET(DOY) THEN BEGIN
            FILETYPE='STACKED_SAVE'
            PERIOD = 'DD'
            NPROD = APROD
            IF HAS(APROD,'PSC_') THEN NPROD = 'PSC-' + VALIDS('ALGS',APROD)
            IF HAS(APROD,'ZEU') THEN NPROD = 'PPD-' + VALIDS('ALGS',APROD)
            IF DSET EQ 'MUR' THEN OPRODS = 'SST'
            MAPIN=OMAP
            AN_ERR = 0
          ENDIF 
          
          ; ===> Add Analysis Error products to the output product list
          IF KEYWORD_SET(AN_ERR) THEN BEGIN
            V = []
            FOR I=0, N_ELEMENTS(OPRODS)-1 DO BEGIN
              STR = STR_BREAK(OPRODS[I],'-')
              VP = STR[0]+'_'+['BIAS','RMSD']
              IF N_ELEMENTS(STR) GT 1 THEN VP = VP + '-' + STR[1] ; Add ALG back to the name
              V = [V, VP]
            ENDFOR
            OPRODS = SORTED([OPRODS,V])
          ENDIF
          
          ; ===> Find the files in the NC product directory
          FILES = GET_FILES(DSET, PRODS=NPROD, FILE_TYPE=FILETYPE,VERSION=VERSION,DATERANGE=DTR)
          IF FILES EQ [] THEN BEGIN
            PLUN, LUN, 'ERROR: No files found for ' + DSET
            CONTINUE
          ENDIF
          
          CASE APER OF
            'DAILY': FILES = FILES[WHERE_STRING(FILES,'DAILY',COUNT)]
            'MONTHLY': FILES = FILES[WHERE_STRING(FILES,'MONTHLY',COUNT)]
            ELSE: FILES = FILES
          ENDCASE
          
          IF FILES EQ [] THEN BEGIN
            PLUN, LUN, 'ERROR: No files found for ' + DSET + ' -' + APER
            CONTINUE
          ENDIF
          
          FILES_2STACKED, FILES, PRODS=OPRODS, STAT_TYPES=STAT_TYPES, D3_FILES=D3_FILES, DIR_OUT=DIR_OUT, MAP_OUT=OMAP, L3BSUBMAP=L3BSUBMAP, FILE_LABEL=FILE_LABEL, $
            MAINPROD=MPROD,DATERANGE=DTR, OUTFILE=OUTFILE, LOGLUN=LOGLUN, DOY=DOY, VERBOSE=VERBOSE, TESTING=TESTING, OVERWRITE=OVERWRITE
        
        ENDFOR ; PRODS
      ENDFOR ; PERIODS  
    ENDFOR ; MAP_OUT
  ENDFOR ; DATASET


END ; ***************** End of FILES_2STACKED_WRAPPER *****************
