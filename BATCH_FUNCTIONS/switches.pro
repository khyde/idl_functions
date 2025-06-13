; $ID:	SWITCHES.PRO,	2023-09-21-13,	USER-KJWH	$

  PRO SWITCHES,STEP, SHOW=SHOW,$
               STOPP=STOPP,OVERWRITE=OVERWRITE,VERBOSE=VERBOSE,INIT=INIT,TEST=TEST,BUFFER=BUFFER,$
               R_FILES=R_FILES,R_DATASETS=R_DATASETS,R_MAPS=R_MAPS,R_PRODS=R_PRODS,R_YEAR=R_YEAR,$
               DATERANGE=DATERANGE,DATASETS=DATASETS,DPRODS=DPRODS,DMAPS=DMAPS,DPERIODS=DPERIODS,NPROCESS=NPROCESS
;+
; NAME:
;   SWITCHES
;   
; PURPOSE: 
;   Parses the "SWITCH" in a batch processing step and sets some specific keywords 
;  
; CATEGORY: 
;   BATCH functions (because it is associated with batch processing)
;   
; REQUIRED INPUTS:
;   STEP.......... The input text that will be parsed  
;   
; OPTIONAL INPUTS:
;  None
;  
; KEYWORD PARAMETERS:
;   SHOW ......... PRINT THE SWITCHES THAT ARE ON
;
; OUTPUTS
;   Returns a variety of option outputs to be used as inputs or keywords in batch processing
;           
; OPTIONAL OUTPUTS          
;   STOPP ........ Set the STOP keyword in the batch process (initates optional "stops" in the program)
;   OVERWRITE .... Set the OVERWRITE keyword in the batch process (will overwrite files if they exist)
;   VERBOSE ...... Set the VERBOSE keyword in the batch process (will print program progress)
;   INIT ......... Set the keyword to INITIALIZE something in the program (e.g. a COMMON block)
;   TEST ......... Set the TEST keyword in the batch process (initiates a "test" mode in the program)
;   BUFFER ....... Set the BUFFER keyword in the batch process (will plot figures in the background)
;   
;   R_FILES ...... Set the keyword to reverse the order of FILES for processing
;   R_DATASETS ... Set the keyword to reverse the order of DATASETS for processing
;   R_MAPS........ Set the keyword to reverse the order of MAPS for processing
;   R_PRODS....... Set the keyword to reverse the order of PRODS for processing
;   R_YEAR........ Set the keyword to reverse the order of YEARS for processing
;   
;   DATERANGE..... Returns the DATERANGE to be used for processing
;   DATASETS...... Returns the DATASET(s) to be used in the processings step
;   DPRODS........ Returns the PROD(s) to be used in the processings step
;   DMAPS......... Returns the MAP(s) to be used in the processings step
;   DPERIODS...... Returns the PERIOD(s) to be used in the processings step
;   NPROCESS...... Returns the number of PROCESSES for any jobs run in parallel
;           
; COMMON BLOCKS:
;   None
;
; SIDE EFFECTS:
;   None
;
; RESTRICTIONS:
;   This program requires specific format for the input
;   S Sets the STOPP output 
;   O Sets the OVERWRITE output
;   V Sets the VERBOSE output
;   I Sets the INIT output
;   T Sets the TEST output
;   B Sets the BUFFER output
;   
;   RF Reverse files
;   RD Reverse datasets
;   RM Reverse maps
;   RP Reverse prods
;   RY Reverse years
;   
;   [] Are used to bracket dataset specific information (e.g. DATASET, DPRODS, DMAPS, DPERIODS)
;   , Is used to separate datasets (e.g. [AVHRR,MODISA])
;   PER= Identifies the periods requested for a dataset (e.g. [AVHRR;PER=M])
;   P= Identifies the products requested for a dataset (e.g. [AVHRR;P=SST])
;   M= Identifies the maps requested for a dataset (e.g. [AVHRR;M=L3B4])
;   ;  Is used to separate information for each dataset (e.g. [AVHRR;PER=M;P=SST;M=L3B4])
;   .  Is used to separate multiple period, prod or map requests for a dataset (e.g. [AVHRR;PER=M.MONTH.A;P=SST;M=L3B4.NEC])
;   
;   _ Is needed before the DATERANGE input (e.g. RF_2002_2020)
;   NP(x) Is used to return the number of processes (the number is in the () ) 
; 
; EXAMPLES: 
;   SWITCHES,'SVORDRF',STOPP=STOPP,OVERWRITE=OVERWRITE,VERBOSE=VERBOSE, R_FILES=R_FILES, R_DATASETS=R_DATASETS
;   SWITCHES,'Y_2008[SEAWIFS;P=CHLOR_A-PAN;PER=D8]',STOPP=STOPP,OVERWRITE=OVERWRITE,VERBOSE=VERBOSE,INIT=INIT,R_FILES=R_FILES,R_DATASETS=R_DATASETS,R_MAPS=R_MAPS,R_PRODS=R_PRODS,DPRODS=D_PRODS,DMAPS=D_MAPS,DPERIODS=D_PERIODS,DATERANGE=DATERANGE,DATASETS=DATASETS
;   SWITCHES,'SVORDF',/SHOW
;
; COPYRIGHT:
; Copyright (C) 2015, Department of Commerce, National Oceanic and Atmospheric Administration, National Marine Fisheries Service,
;   Northeast Fisheries Science Center, Narragansett Laboratory.
;   This software may be used, copied, or redistributed as long as it is not sold and this copyright notice is reproduced on each copy made.
;   This routine is provided AS IS without any express or implied warranties whatsoever.
;
; AUTHOR:
;   This program was written on March 09, 2018 by John E O'Reilly and Kimberly J. W. Hyde, Northeast Fisheries Science Center | NOAA Fisheries | U.S. Department of Commerce, 28 Tarzwell Dr, Narragansett, RI 02882
; 
; MODIFICATION HISTORY:
;   MAR 09, 2015 - JEOR: Initial code written WRITTEN BY: KJW HYDE & J.E. O'REILLY
;   MAR 17, 2015 - JEOR: Added the keyword INIT
;   APR 02, 2015 - JEOR: Shortened REVERSE_FILES to R_FILES and REVERSE_DATASETS to R_DATASETS
;   AUG 10, 2015 - KJWH: Removed STOPE = HAS(STEP,'E')
;                        Added R_MAPS to reverse the order of maps
;   SEP 16, 2015 - KJWH: Added SWITCH_NAME keyword to return the name of the switch
;   SEP 16, 2015 - JOR:  Updated SWITCH_NAME = STEP [ STEP HAS ONLY LETTERS LIKE S,V,O ETC]
;   OCT 05, 2015 - KJWH: Added DATERANGE logic   
;   OCT 07, 2015 - KJWH: Added R_PRODS   
;   OCT 20, 2015 - KJWH: Updated DATERANGE logic 
;   MAR 29, 2016 - KJWH: Added DATERANGE = [MIN(DATERANGE),MAX(DATERANGE)] ; Make sure the earlier date is first     
;   SEP 26, 2016 - KWJH: Added DATASETS keyword to output the list of datasets to run in the BATCH programs    
;   OCT 03, 2016 - KJHW: Moved the DATASETS block to the beginning and removing the text string within [] for further anaylsis     
;   FEB 14, 2017 - KJWH: Added DPRODS and DMAPS keywords and logic to return DATASET specific products and maps in a LIST
;   FEB 21, 2017 - KJWH: Added TEST keyword 
;   SEP 22, 2017 - KJWH: Changed the minimum DATERANGE to be 19780101 to accomodate CZCS data
;   NOV 16, 2017 - KJWH: Added DPERIODS keyword to extract PERIODS (used for STATS) from the switch input
;   JAN 29, 2018 - KJWH: Added a BUFFER keyword for plotting routines
;   APR 18, 2018 - KJWH: Added DPERIODS = [] ; DATASETS PERIOD LIST to create a null list for the PERIODS
;   MAY 09, 2018 - KJWH: Added JEOR's SHOW keyword and updated the code to print what keywords are set (added example)
;   FEB 24, 2019 - KJWH: Added R_YEAR to reverse the order of the years for processing
;   JUL 02, 2019 - KJWH: Added NPROCESS to return the number of parallel processes to run
;   SEP 13, 2019 - KJWH: Added step to look for DATASETS that start with ";".  If yes, then make the DATASET = ' '
;   JUL 01, 2020 - KJWH: Added COMPILE_OPT IDL2
;                        Changed subscript () to []
;                        Removed the default DATERANGE of '19780101','21001231', now DATERANGE will be NULL if not provided
;   AUG 18, 2021 - KJWH: Added STRUPCASE() to eliminate case sensitive errors   
;                        Moved to BATCH functions                  
;-
; #########################################################################

  ROUTINE_NAME  = 'SWITCHES'
  COMPILE_OPT IDL2

; ===> Create null arrays for some outputs 
  DATASETS = []
  DPRODS   = [] ; DATASETS PRODUCTS LIST
  DMAPS    = [] ; DATASETS MAPS LIST
  DPERIODS = [] ; DATASETS PERIOD LIST
  
  ; ===> Look for datasets - must be surrounded by []
  IF HAS(STEP,'[') THEN BEGIN
    POS1 = STRPOS(STEP,'[')
    POS2 = STRPOS(STEP,']')
    IF POS1 EQ -1 OR POS2 EQ -1 THEN GOTO, SKIP_DATASETS ; ===> DATASETS MUST BE SURROUNDED BY []
    DATASETS = STRSPLIT(STRMID(STEP,POS1+1,POS2-POS1-1),',',/EXTRACT)
    STEP = STRMID(STEP,0,POS1) + STRMID(STEP,POS2+1) ; ===> Rewrite STEP by removing the DATASETS information and avoiding conflicts with other specified characters (i.e. O for OVERWRITE)
    
; ===> Look for DATASET specific items (e.g. MAPS, PRODS)    
    DP = REPLICATE('',N_ELEMENTS(DATASETS)) ; DATASET PRODS
    DM = DP                                 ; DATASET MAPS
    DR = DP                                 ; DATASET PERIODS
    FOR D=0, N_ELEMENTS(DATASETS)-1 DO BEGIN
      IF STRMID(DATASETS[D],0,1) EQ ';' THEN DATASETS[D] = ' ' + DATASETS[D]
      SP = STRSPLIT(STRUPCASE(DATASETS[D]),';',/EXTRACT)
      DATASETS[D] = SP[0]
      IF N_ELEMENTS(SP) EQ 1 THEN CONTINUE
      
      FOR S=1, N_ELEMENTS(SP)-1 DO BEGIN
        IF HAS(SP[S],'P=')   THEN DP[D] = SP[S]
        IF HAS(SP[S],'M=')   THEN DM[D] = SP[S]  
        IF HAS(SP[S],'PER=') THEN DR[D] = SP[S]
      ENDFOR ; PARSED DATASET INFO
      
      DPRODS = LIST([])
      FOR R=0, N_ELEMENTS(DP)-1 DO BEGIN
        PRODS = REPLACE(DP[R],['P=','.'],['',','])
        IF PRODS EQ '' THEN DPRODS.ADD,[] ELSE DPRODS.ADD,PRODS 
      ENDFOR
      DPRODS.REMOVE,0
      
      DMAPS = LIST([])
      FOR R=0, N_ELEMENTS(DM)-1 DO BEGIN
        MPS = REPLACE(DM[R],['M=','.'],['',','])
        IF MPS EQ '' THEN DMAPS.ADD,[] ELSE DMAPS.ADD,MPS
      ENDFOR
      DMAPS.REMOVE,0
      
      DPERIODS = LIST([])
      FOR R=0, N_ELEMENTS(DR)-1 DO BEGIN
        PERIODS = REPLACE(DR[R],['PER=','.'],['',','])
        IF PERIODS EQ '' THEN DPERIODS.ADD,[] ELSE DPERIODS.ADD,PERIODS
      ENDFOR
      DPERIODS.REMOVE,0

    ENDFOR ; DATASETS
    
  ENDIF
  SKIP_DATASETS:


;===> Pass characters in step to has to turn on or off each keyword
  OVERWRITE  = HAS(STEP,'O')
  VERBOSE    = HAS(STEP,'V')
  STOPP      = HAS(STEP,'S')
  INIT       = HAS(STEP,'I')
  TEST       = HAS(STEP,'T')
  BUFFER     = HAS(STEP,'B')
  
  R_DATASETS = HAS(STEP,'RD') OR HAS(STEP,'R_DATASETS')
  R_FILES    = HAS(STEP,'RF') OR HAS(STEP,'R_FILES')
  R_MAPS     = HAS(STEP,'RM') OR HAS(STEP,'R_MAPS')
  R_PRODS    = HAS(STEP,'RP') OR HAS(STEP,'R_PRODS')
  R_YEAR     = HAS(STEP,'RY') OR HAS(STEP,'R_YEAR')
  
;===> Look for n processes (the number must be bracketed by parentheses)
  IF HAS(STEP,'NP') THEN BEGIN
    NPROCESS = FIX(STRMID(STEP,STRPOS(STEP,'(')+1,STRPOS(STEP,')')-STRPOS(STEP,'(')-1))
  ENDIF

; ===> Look for date range (must be separated by an underscore)_
  DATERANGE = ['19780101','21001231']
  IF HAS(STEP,'_') THEN BEGIN  
    SP = STRSPLIT(STEP,'_',/EXTRACT)
    DATERANGE[0] = SP[1]
    IF N_ELEMENTS(SP) EQ 3 THEN DATERANGE[1] = SP[2] ELSE DATERANGE[1] = STRMID(SP[1],0,4) ; Only get the year from DATE_START, then add 1231 below 
    
    IF STRLEN(DATERANGE[0]) EQ 4 THEN DATERANGE[0] = DATERANGE[0] + '0101'
    IF STRLEN(DATERANGE[1]) EQ 4 THEN DATERANGE[1] = DATERANGE[1] + '1231'
    DATERANGE = [MIN(DATERANGE),MAX(DATERANGE)] ; Make sure the earlier date is first
  ENDIF ELSE DATERANGE = []
  
; ===> Print the switches 
  IF KEY(SHOW) THEN BEGIN
    SWN = ['R_MAPS','R_FILES','R_PRODS','R_DATASETS','DMAPS','DPERIODS','DATERANGE','TEST','VERBOSE','OVERWRITE','INIT','BUFFER','STOPP','NPROCESS']
    SWS = [ R_MAPS,  R_FILES,  R_PRODS,  R_DATASETS,  DMAPS,  DPERIODS,  DATERANGE,  TEST,  VERBOSE,  OVERWRITE,  INIT,  BUFFER,  STOPP,  NPROCESS]
    FOR N=0, NOF(SWS)-1 DO IF KEY(SWS[N]) THEN PRINT, SWN[N] + ' keyword set' 
  ENDIF

  
END; #####################  END OF ROUTINE ################################
