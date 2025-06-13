; $ID:	STACKED_MAKE_PRODS_PARZ.PRO,	2023-09-21-13,	USER-KJWH	$
  PRO STACKED_MAKE_PRODS_PARZ, ABSFILES=ABSFILES, BBPFILES=BBPFILES, PARFILES=PARFILES, DEPTHS=DEPTHS

;+
; NAME:
;   STACKED_MAKE_PRODS_PARZ
;
; PURPOSE:
;   $PURPOSE$
;
; CATEGORY:
;   STACKED_FUNCTIONS
;
; CALLING SEQUENCE:
;   STACKED_MAKE_PRODS_PARZ,$Parameter1$, $Parameter2$, $Keyword=Keyword$, ....
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
;   This program was written on April 21, 2023 by Kimberly J. W. Hyde, Northeast Fisheries Science Center | NOAA Fisheries | U.S. Department of Commerce, 28 Tarzwell Dr, Narragansett, RI 02882
;    
; MODIFICATION HISTORY:
;   Apr 21, 2023 - KJWH: Initial code written
;-
; ****************************************************************************************************
  ROUTINE_NAME = 'STACKED_MAKE_PRODS_PARZ'
  COMPILE_OPT IDL2
  SL = PATH_SEP()
  
  IF ~N_ELEMENTS(LOGLUN) THEN LOG_LUN = [] ELSE LOG_LUN = LOGLUN
  
  ; ===> Check for input files
  IF ~N_ELEMENTS(ABSFILES) THEN MESSAGE, 'ERROR: Must provide Total Absorption input files'
  IF ~N_ELEMENTS(BBPFILES) THEN MESSAGE, 'ERROR: Must provide Backscattering input files' 
  IF ~N_ELEMENTS(PARFILES) THEN MESSAGE, 'ERROR: Must provide PAR input files'  
  
  ; ===> Get file info
  FPA = PARSE_IT(ABSFILES,/ALL)
  FPB = PARSE_IT(BBPFILES,/ALL)
  FPP = PARSE_IT(PARFILES,/ALL)
  
  ; ===> Get the input sensor information
  IF ~SAME([FPA.SENSOR,FPB.SENSOR]) THEN MESSAGE, 'ERROR: All input files must have the same sensor'
  SENSOR = FPA[0].SENSOR
  CASE SENSOR OF
    'MODISA': WAVEBANDS = ['488']
    'OCCCI':  WAVEBANDS = ['490']
  ENDCASE

  ; ===> Check the input maps are the same
  IF ~SAME([FPA.MAP,FPB.MAP,FPP.MAP]) THEN MESSAGE, 'ERROR: All input files must have the same map.'

  ; ===> Create output directory and file name(s)
  IF ~N_ELEMENTS(DIR_OUT) THEN DIR_OUT = REPLACE(FPA[0].DIR,FPA[0].SUB,'PARZ-LEE')                                                 ; Create the output directory
  DIR_TEST, DIR_OUT                                                                                                                 ; Make the output directory folder
  IF ~N_ELEMENTS(FILE_LABEL) THEN FLABEL=FILE_LABEL_MAKE(ABSFILES[0],LST=['SENSOR','VERSION','SATELLITE','SAT_EXTRA','METHOD','MAP']) ELSE FLABEL=FILE_LABEL ; Create the output file label

  ; ===> Loop through files
  NFILES = N_ELEMENTS(ABSFILES)
  FOR F=0, NFILES-1 DO BEGIN
    AFLE = ABSFILES[F]                                                                                                              ; Get the file
    FA = FPA[F]
    PERIOD = FA.PERIOD
    PSTR = PERIOD_2STRUCT(PERIOD)
    DRANGE = STRJOIN(STRMID([PSTR.DATE_START,PSTR.DATE_END],0,8),'_')                                                      ; Get the daterange for the period

    ; ===> Find the matching BBP file
    BFLE = BBPFILES[WHERE(FPB.PERIOD EQ FA.PERIOD,/NULL,COUNTB)]
    IF COUNTB EQ 0 THEN MESSAGE, 'ERROR: Unable to find the matching BB file for period ' + PERIOD
    IF COUNTB GT 1 THEN MESSAGE, 'ERROR: More than 1 BB file found for period ' + PERIOD
    
    ; ===> Find the matching PAR file
    PFLE = PARFILES[WHERE(FPP.PERIOD EQ FA.PERIOD,/NULL,COUNTP)]
    IF COUNTP EQ 0 THEN MESSAGE, 'ERROR: Unable to find the matching PAR file for period ' + PERIOD
    IF COUNTP GT 1 THEN MESSAGE, 'ERROR: More than 1 PAR file found for period ' + PERIOD
    
    INFILES = [AFLE,BFLE,PFLE]
    PARZFILE = DIR_OUT + PERIOD + '-' + FLABEL + 'PARZ-LEE.SAV'
    IF ~FILE_MAKE(INFILES,PARZFILE,OVERWRITE=OVERWRITE) THEN CONTINUE

    ; ===> Read the data
    ASAT = STACKED_READ(AFLE,DB=ADB,BINS=ABINS)
    BSAT = STACKED_READ(BFLE,DB=BDB,BINS=BBINS)
    PSAT = STACKED_READ(PFLE,DB=PDB,BINS=PBINS)

    ; ===> Check that the files were opened correctly
    FILECHECK = [IDLTYPE(ASAT),IDLTYPE(BSAT),IDLTYPE(PSAT)]
    OK = WHERE(FILECHECK EQ 'STRING',COUNT)
    IF COUNT GT 0 THEN BEGIN
      PLUN, LOG_LUN, 'ERROR: Reading the input files for ' + INFILES[OK]
      CONTINUE
    ENDIF

    ; ===> Extract the input

    ; ===> Check that the data sizes are the same
    ADAT = ASAT.ATOT_490 & ASZ = SIZEXYZ(ADAT,PX=XA,PY=YA,PZ=ZA)
    IF BSAT NE [] THEN BEGIN
      BDAT = BSAT.BBP_490 & BSZ = SIZEXYZ(BDAT,PX=XB,PY=YB,PZ=ZB)
      PDAT = PSAT.PAR_MEAN & BSZ = SIZEXYZ(PDAT,PX=XP,PY=YP,PZ=ZP)
      IF XA NE XB OR XA NE XP THEN MESSAGE, 'ERROR: The X dimensions in the input data do not match'
      IF YA NE YB OR YA NE YP THEN MESSAGE, 'ERROR: The Y dimensions in the input data do not match'
      IF ZA NE ZB OR ZA NE ZP THEN MESSAGE, 'ERROR: The Z dimensions in the input data do not match'
    ENDIF
  ENDFOR ; NFILES
  
  
  FOR Z=0, ZA-1 DO BEGIN
    PARZ = PARZ_LEE(ABS490=ADAT[*,*,Z], BBP490=BDAT[*,*,Z], PAR=PDAT[*,*,Z], DEPTH=[0,10,100])
  ENDFOR
  
  
  stop


END ; ***************** End of STACKED_MAKE_PRODS_PARZ *****************
