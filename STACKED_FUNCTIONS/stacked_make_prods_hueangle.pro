; $ID:	STACKED_MAKE_PRODS_HUEANGLE.PRO,	2023-09-21-13,	USER-KJWH	$
  PRO STACKED_MAKE_PRODS_HUEANGLE, ABSFILES=ABSFILES, BBFILES=BBFILES, $
                                   ALG_VERSION=ALG_VERSION, FILE_LABEL=FILE_LABEL, DIR_OUT=DIR_OUT, LOGLUN=LOGLUN,$
                                   OVERWRITE=OVERWRITE

;+
; NAME:
;   STACKED_MAKE_PRODS_HUEANGLE
;
; PURPOSE:
;   Program to run the Hue angle model by Zhongping Lee and save as a "stacked" output file
;
; CATEGORY:
;   STACKED_FUNCTIONS
;
; CALLING SEQUENCE:
;   STACKED_MAKE_PRODS_HUEANGLE, ABSFILES=ABSFILES, BBFILES=BBFILES
;
; REQUIRED INPUTS:
;   ABSFILES.......... An array of total absorption input files (daily or monthly "stacks")
;   BBFILES........... An array of backscattering input files (daily or monthly "stacks") 
;
; OPTIONAL INPUTS:
;   ALG_VERSION....... The algorithm version (currently a placeholder for future modifications to the algorithm)
;   FILE_LABEL........ The label for the output file
;   DIR_OUT........... The output directory
;   LOGLUN............ The LUN for writing to log files
;
; KEYWORD PARAMETERS:
;   OVERWRITE......... Overwrite exiting files
;
; OUTPUTS:
;   OUTPUT............ Describe the output of this program or function
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
;   Lee, Z., S. Shang, Y. Li, K. Luis, M. Dai, and Y. Wang (2022), Three-Dimensional Variation in Light Quality in the Upper Water Column Revealed With a Single Parameter, IEEE Transactions on Geoscience and Remote Sensing, 60, 1-10, doi:10.1109/TGRS.2021.3093014.
;   
; COPYRIGHT: 
; Copyright (C) 2023, Department of Commerce, National Oceanic and Atmospheric Administration, National Marine Fisheries Service,
;   Northeast Fisheries Science Center, Narragansett Laboratory.
;   This software may be used, copied, or redistributed as long as it is not sold and this copyright notice is reproduced on each copy made.
;   This routine is provided AS IS without any express or implied warranties whatsoever.
;
; AUTHOR:
;   This program was written on March 15, 2023 by Kimberly J. W. Hyde, Northeast Fisheries Science Center | NOAA Fisheries | U.S. Department of Commerce, 28 Tarzwell Dr, Narragansett, RI 02882
;    
; MODIFICATION HISTORY:
;   Mar 15, 2023 - KJWH: Initial code written
;-
; ****************************************************************************************************
  ROUTINE_NAME = 'STACKED_MAKE_PRODS_HUEANGLE'
  COMPILE_OPT IDL2
  SL = PATH_SEP()
  
  IF ~N_ELEMENTS(LOGLUN) THEN LOG_LUN = [] ELSE LOG_LUN = LOGLUN
  
  ; ===> Check for input files
  IF ~N_ELEMENTS(ABSFILES) THEN MESSAGE, 'ERROR: Must provide Total Absorption input files'
  IF ~N_ELEMENTS(BBFILES) THEN MESSAGE, 'ERROR: Must provide Backscattering input files'

  ; ===> Get file info
  FPA = PARSE_IT(ABSFILES,/ALL)
  FPB = PARSE_IT(BBFILES,/ALL)
  
  ; ===> Check the input file product


  ; ===> Get the input sensor information
  IF ~SAME([FPA.SENSOR,FPB.SENSOR]) THEN MESSAGE, 'ERROR: All input files must have the same sensor'
  SENSOR = FPA[0].SENSOR
  CASE SENSOR OF 
    'MODISA': WAVEBANDS = ['412','443','488','532','547']
    'OCCCI':  WAVEBANDS = ['412','443','488','510','560']
  ENDCASE
  
  ; ===> Check the input maps are the same
  IF ~SAME([FPA.MAP,FPB.MAP]) THEN MESSAGE, 'ERROR: All input files must have the same map.'
  
  ; ===> Create output directory and file name(s)
  IF ~N_ELEMENTS(DIR_OUT) THEN DIR_OUT = REPLACE(FCS[0].DIR,FCS[0].SUB,'HUEANGLE-LEE')                                                 ; Create the output directory
  DIR_TEST, DIR_OUT                                                                                                                 ; Make the output directory folder
  IF ~N_ELEMENTS(FILE_LABEL) THEN FLABEL=FILE_LABEL_MAKE(ABSFILES[0],LST=['SENSOR','VERSION','SATELLITE','SAT_EXTRA','METHOD','MAP']) ELSE FLABEL=FILE_LABEL ; Create the output file label

  ; ===> Loop through files
  NFILES = N_ELEMENTS(CHLFILES)
  FOR F=0, NFILES-1 DO BEGIN
    AFLE = ABSFILES[F]                                                                                                              ; Get the file
    FA = FPA[F]
    PERIOD = FA.PERIOD
    PSTR = PERIOD_2STRUCT(PERIOD)
    DRANGE = STRJOIN(STRMID([PSTR.DATE_START,PSTR.DATE_END],0,8),'_')                                                      ; Get the daterange for the period

    ; ===> Find the matching BB file
    BFLE = BBFILES[WHERE(FPB.PERIOD EQ FA.PERIOD,/NULL,COUNTB)] 
    IF COUNTB EQ 0 THEN MESSAGE, 'ERROR: Unable to find the matching BB file for period ' + PERIOD
    IF COUNTB GT 1 THEN MESSAGE, 'ERROR: More than 1 BB file found for period ' + PERIOD
    INFILES = [AFLE,BFLE]
    
    PSCFILE = DIR_OUT + PERIOD + '-' + ALABEL + '.SAV'
    IF ~FILE_MAKE(INFILES,PSCFILE,OVERWRITE=OVERWRITE) THEN CONTINUE

    ; ===> Read the data
    ASAT = STACKED_READ(AFLE,DB=ADB,BINS=ABINS)
    BSAT = STACKED_READ(BFLE,DB=BDB,BINS=BBINS)
    
    ; ===> Check that the files were opened correctly
    FILECHECK = [IDLTYPE(ASAT),IDLTYPE(BSAT)]
    OK = WHERE(FILECHECK EQ 'STRING',COUNT)
    IF COUNT GT 0 THEN BEGIN
      PLUN, LOG_LUN, 'ERROR: Reading the input files for ' + INFILES[OK]
      CONTINUE
    ENDIF
    
    ; ===> Extract the input
    
    ; ===> Check that the data sizes are the same
    CDAT = CSAT.CHLOR_A & CSZ = SIZEXYZ(CDAT,PX=XC,PY=YC,PZ=ZC)
    IF SSAT NE [] THEN BEGIN
      SDAT = SSAT.SST     & SSZ = SIZEXYZ(SDAT,PX=XS,PY=YS,PZ=ZS)
      IF XC NE XS THEN MESSAGE, 'ERROR: The X dimensions in the input data do not match'
      IF YC NE YS THEN MESSAGE, 'ERROR: The Y dimensions in the input data do not match'
      IF ZC NE ZS THEN MESSAGE, 'ERROR: The Z dimensions in the input data do not match'
    ENDIF
  ENDFOR ; NFILES  


    

END ; ***************** End of STACKED_MAKE_PRODS_HUEANGLE *****************
