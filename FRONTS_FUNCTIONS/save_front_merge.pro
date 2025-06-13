; $ID:	SAVE_FRONT_MERGE.PRO,	2023-09-21-13,	USER-KJWH	$
  PRO SAVE_FRONT_MERGE, DATASETS, PRODS=PRODS, MAPP=MAPP, SUBSET_MAP=SUBSET_MAP, DAYNIGHT=DAYNIGHT, DIR_OUT=DIR_OUT, $
                        FILE_LABEL=FILE_LABEL, DATERANGE=DATERANGE, REVERSE_FILES=REVERSE_FILES, OVERWRITE=OVERWRITE

;+
; NAME:
;   SAVE_FRONT_MERGE
;
; PURPOSE:
;   Merge the data from daily frontal files
;
; CATEGORY:
;   FRONTS_FUNCTIONS
;
; CALLING SEQUENCE:
;   Result = SAVE_FRONT_MERGE($Parameter1$, $Parameter2$, $Keyword=Keyword$, ...)
;
; REQUIRED INPUTS:
;   None 
;
; OPTIONAL INPUTS:
;   DATASETS......... Datasets to merge
;   PRODS............ Product names to merge (default=GRAD_SST and GRAD_CHL)
;   MAPP............. Input map name
;   SUBSET_MAP....... Subset map for the FRONT and DATA merge programs (reduces the total amount of data to be within a smaller map subset)
;   DAYNIGHT......... To indicate if day time or night time files should be used (e.g. for the SST files) - NOTE: STILL NEEDS TO BE ADDED TO THE CODE BELOW
;   DIR_OUT.......... Directory for the output files
;   FILE_LABEL....... Label for the output file
;   DATERANGE........ Date range of the input data files
;
; KEYWORD PARAMETERS:
;   REVERSE_FILES.... Reverse the order of the files for processing
;   OVERWRITE........ Overwrite the output file if it already exists
;
; OUTPUTS:
;   Daily files with frontal data merged from different files
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
;   
;   
; COPYRIGHT: 
; Copyright (C) 2021, Department of Commerce, National Oceanic and Atmospheric Administration, National Marine Fisheries Service,
;   Northeast Fisheries Science Center, Narragansett Laboratory.
;   This software may be used, copied, or redistributed as long as it is not sold and this copyright notice is reproduced on each copy made.
;   This routine is provided AS IS without any express or implied warranties whatsoever.
;
; AUTHOR:
;   This program was written on April 21, 2021 by Kimberly J. W. Hyde, Northeast Fisheries Science Center | NOAA Fisheries | U.S. Department of Commerce, 28 Tarzwell Dr, Narragansett, RI 02882
;    
; MODIFICATION HISTORY:
;   Apr 21, 2021 - KJWH: Initial code written
;   May 10, 2021 - KJWH: Updated documentation
;                        Added SUBSET_MAP keyword to subset the L3B data to a specified map area
;   Jun 28, 2021 - KJWH: Removed the DATA_MERGE steps because the INDATA merging is now being done in FRONT_MERGE                     
;                       
;-
; ****************************************************************************************************
  ROUTINE_NAME = 'SAVE_FRONT_MERGE'
  COMPILE_OPT IDL2
  SL = PATH_SEP()
  DS = '-'
  
  IF N_ELEMENTS(DATASETS)   EQ 0 THEN DATASETS = ['AT']
  IF N_ELEMENTS(DIR_OUT)    NE N_ELEMENTS(DATASETS) THEN DIR_OUT = []
  IF N_ELEMENTS(PRODS)      EQ 0 THEN PRODS   = ['GRAD_SST-BOA','GRAD_CHL-BOA']
  IF N_ELEMENTS(MAPP)       NE 1 THEN MP       = 'L3B2'  ELSE MP  = MAPP
  IF N_ELEMENTS(DATERANGE)  EQ 0 THEN DTR      = []      ELSE DTR = GET_DATERANGE(DATERANGE)
  IF N_ELEMENTS(SUBSET_MAP) EQ 0 THEN SUBMAP   = 'NWA'   ELSE SUBMAP=SUBSET_MAP
  
  FOR D=0, N_ELEMENTS(DATASETS)-1 DO BEGIN
    DATASET = DATASETS[D]
    
    CASE DATASET OF
      'SA':  BEGIN & SENSORS=['SEAWIFS','MODISA']                  & FPRODS = 'GRAD_CHL-BOA' & END
      'SAT': BEGIN & SENSORS=['SEAWIFS','MODISA','MODIST']         & FPRODS = 'GRAD_CHL-BOA' & END
      'SAV': BEGIN & SENSORS=['SEAWIFS','MODISA','VIIRS']          & FPRODS = 'GRAD_CHL-BOA' & END
      'SATV':BEGIN & SENSORS=['SEAWIFS','MODISA','MODIST','VIIRS'] & FPRODS = 'GRAD_CHL-BOA' & END
      'ATV': BEGIN & SENSORS=['MODISA','MODIST','VIIRS']           & FPRODS = 'GRAD_CHL-BOA' & END
      'AV':  BEGIN & SENSORS=['MODISA','VIIRS']                    & FPRODS = 'GRAD_CHL-BOA' & END
      'AT':  BEGIN & SENSORS=['MODISA','MODIST']                   & FPRODS = PRODS          & END
      ELSE: SENSORS=DATASET
    ENDCASE
    
    FOR R=0, N_ELEMENTS(FPRODS)-1 DO BEGIN
      PROD = FPRODS[R]
      CASE PROD OF
        'GRAD_SST-BOA': BEGIN & LOG=0 & NC_PROD=[] & END
        'GRAD_CHL-BOA': BEGIN & LOG=1 & NC_PROD='chlor_a' & END
      ENDCASE
      
      FILES = []
      FOR S=0, N_ELEMENTS(SENSORS)-1 DO FILES = [FILES,GET_FILES(SENSORS[S],PRODS=PROD,MAPS=MP,PERIODS='D',DATERANGE=DTR, SUITE='FRONTS')]
      IF FILES EQ [] THEN CONTINUE
      
      FP = PARSE_IT(FILES,/ALL)
      FTAGS = TAG_NAMES(FP)
      STAGS = ['PROD','ALG','COVERAGE','MAP','METHOD']
      FOR S=0, N_ELEMENTS(STAGS)-1 DO IF ~SAME(FP.(WHERE(FTAGS EQ STAGS[S]))) THEN MESSAGE, 'ERROR: All input files do not have the same ' + STAGS[S]
      
      IF DIR_OUT EQ [] THEN ODIR = !S.FRONTS + DATASET + SL + MP + SL + 'SAVE' + SL + PROD + SL ELSE ODIR = DIR_OUT[D]
      IF N_ELEMENTS(FILE_LABEL) NE 1 THEN FILE_LABEL = FILE_LABEL_MAKE(FILES[0],LST=['METHOD','MAP'])
      
      BSETS = WHERE_SETS(FP.PERIOD)
      IF KEYWORD_SET(REVERSE_FILES) THEN BSETS = STRUCT_REVERSE(BSETS)
      FOR B=0, N_ELEMENTS(BSETS)-1 DO BEGIN
        SUBS = WHERE_SETS_SUBS(BSETS[B])
        BFILES = FILES[SUBS]
        BF = PARSE_IT(BFILES)
        
        OUTFILE = ODIR + STRJOIN([BF[0].PERIOD,DATASET,FILE_LABEL,PROD],DS) + '.SAV'  
        IF FILE_MAKE(BFILES,OUTFILE,OVERWRITE=OVERWRITE) EQ 0 THEN CONTINUE
        
        FR = FRONT_MERGE(BFILES,SUBSET_MAP=SUBMAP)
        
        STRUCT_WRITE, FR, FILE=OUTFILE
        
        
      ENDFOR ; PERIODS (BSETS)
    ENDFOR ; PRODS
  ENDFOR ; DATASETS
  
  


END ; ***************** End of FRONT_MERGE *****************
