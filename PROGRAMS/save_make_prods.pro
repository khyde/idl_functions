; $ID:	SAVE_MAKE_PRODS.PRO,	2021-11-29-15,	USER-KJWH	$
PRO SAVE_MAKE_PRODS, DATASET, PROD=PROD, SENSOR_VERSION=SENSOR_VERSION, SST_VERSION=SST_VERSION, COMPOSITE=COMPSITE, MPS=MPS, PERIOD=PERIOD, MASK=MASK, SST_GR=SST_GR, PPD_ALG=PPD_ALG, R_FILES=R_FILES, DATERANGE=DATERANGE, LOGLUN=LOGLUN, OVERWRITE=OVERWRITE

;+
; NAME:
;   SAVE_MAKE_PRODS
;
; PURPOSE:
;   This procedure will make save files for various products (e.g. CHLOR_A-PAN, PIGMENTS, DOC-MANNINO)
;
; CATEGORY:
;   ALGORITHM_FUNCTIONS
;
; CALLING SEQUENCE:
;   SAVE_MAKE_PRODS, DATASET, PROD=PROD, MP=MP, PERIOD=PERIOD, MASK=MASK, SST=SST, PPD_ALG=PPD_ALG
;
; REQUIRED INPUTS:
;   DATASET..... The name of the input dataset to be processed
;
; OPTIONAL INPUTS:
;   PROD.............. Product name to be processed (it is best to input only 1 product at a time)
;   SENSOR_VERSION ... The name of the version directory if not at the main level directory
;   SST_VERSION....... The name of the SST version directory if not at the main level directory
;   COMPOSITE......... Make a composite image for the PIGMENTS and PHYTO products
;   MPS............... Map name(s)
;   PERIOD............ Period of the input files
;   MASK.............. Mask name to generate subscripts that will be used to subset larger maps (e.g. LME or a map such as NWA)
;   SST............... The name of the type of SST to be used as an input to PIGMENTS_PAN
;   PPD_ALG........... The algorithm of the PPD data to be used in PHYTO_PAN
;   LOGLUN............ If provided, then lun for the log file
;   
; KEYWORD PARAMETERS:
;   R_FILES........... Reverse the file order
;   OVERWRITE......... Overwrite the output file if it already exists
;
; OUTPUTS:
;   This procedure generates SAV files for various products
;
; OPTIONAL OUTPUTS:
;   
;
; EXAMPLE:
;   DATASET = 'MODISA'
;   SAVE_MAKE_PRODS, DATASET
;   SAVE_MAKE_PRODS, DATASET, PROD='CHLOR_A-PAN'
;   SAVE_MAKE_PRODS, DATASET, PROD='CHLOR_A-PAN', MP='L3B2'
;   SAVE_MAKE_PRODS, DATASET, PROD='CHLOR_A-PAN', MP='L3B2', PERIOD='D',
;   SAVE_MAKE_PRODS, DATASET, PROD='PHYTO-PAN', MP='L3B2', PERIOD='D', MASK='NWA'
;   SAVE_MAKE_PRODS, DATASET, PROD='PIGMENTS-PAN', MP='L3B2', PERIOD='D', MASK='NWA', SST='AVINTERP_MUR'
;   SAVE_MAKE_PRODS, DATASET, PROD='PPD_SIZE', MP='L3B2', PERIOD='D', MASK='NWA', PPD_ALG='VGPM2'
;
; NOTES:
;
; REFERENCES:
;   See netcdf_references.csv for a list of the references associated with each product
;
; COPYRIGHT:
; Copyright (C) 2018, Department of Commerce, National Oceanic and Atmospheric Administration, National Marine Fisheries Service,
;   Northeast Fisheries Science Center, Narragansett Laboratory.
;   This software may be used, copied, or redistributed as long as it is not sold and this copyright notice is reproduced on each copy made.
;   This routine is provided AS IS without any express or implied warranties whatsoever.
;
; AUTHOR:
;   This program was written on August 21, 2018 by Kimberly J. W. Hyde, Northeast Fisheries Science Center | NOAA Fisheries | U.S. Department of Commerce, 28 Tarzwell Dr, Narragansett, RI 02882
; 
;
; MODIFICATION HISTORY:
;   Aug 21, 2018 - KJWH: Wrote intial code
;   Aug 22, 2018 - KJWH: Tested, refined, and documented the program
;                        Added MAP based MASK
;                        Added the UITZ phytoplankton size algorithm
;   AUG 27, 2018 - KJWH: Added VERSION for specific products and added the version to the savefile name                     
;   AUG 29, 2018 - KJWH: Added /SI to all calls to UNITS so that the 
;   AUG 30, 2018 - KJWH: Added R_FILES keyword to reverse the order of the files
;   OCT 16, 2018 - KJWH: Updated program to work with OCCCI data when creating CHLOR_A-WERDELL
;   OCT 24, 2018 - KJWH: Added info to work with VIIRS data
;   OCT 26, 2018 - KJWH: Fixed an issue with the L3B map masking
;   NOV 15, 2018 - KJWH: Changed the PRINT commands to PLUN so that they can be captured in a log file if provided
;                        Added LOGLUN keyword
;   FEB 04, 2019 - KJWH: Added COMPOSITE keyword and steps to call PIGMENTS_COMPOSITE and PHYTO_COMPOSITE in order to make composite pngs of the data  
;   DEC 12, 2019 - KJWH: Added info to work with JPSS1 data      
;   DEC 07, 2020 - KJWH: Updated documentation
;                        Added COMPILE_OPT IDL2
;                        Changed subscript () to []
;                        Added SENSOR_VERSION optional input to indicate the version of the input data  
;                        Now looping on SENSOR_VERSION       
;   DEC 08, 2020 - KJWH: Added ability to run just the BREWINSST_NES and not save BREWIN_NES    
;   NOV 29, 2021 - KJWH: Fixed bug for finding SST files (changed GET_FILES(...,MAPS=AMAM,... to GET_FILES(...,MAPS=AMAP,...)                      
;- 
; ************************************************************************************************************************************************************
  ROUTINE_NAME = 'SAVE_MAKE_PRODS'
  COMPILE_OPT IDL2

  SL = PATH_SEP()
  IF NONE(LOGLUN) THEN LOG_LUN = [] ELSE LOG_LUN = LOGLUN

  IF N_ELEMENTS(DATASET) NE 1 THEN MESSAGE, 'ERROR: Must input only 1 DATASET'
  SENSOR = VALIDS('SENSORS',DATASET)
  COVERAGE = VALIDS('COVERAGE',DATASET)

; ===> Defaults  
  IF NONE(MPS)     THEN MPS     = 'L3B2'
  IF NONE(PROD)    THEN PROD    = 'CHLOR_A-PAN'
  IF NONE(SST_GR)  THEN SST_GR  = 'AVINTERP_MUR'
  IF NONE(PPD_ALG) THEN PPD_ALG = 'VGPM2'
  IF NONE(MASK)    THEN MASK    = []
  IF NONE(DATERANGE) THEN DATERANGE = ['19780101',DATE_NOW(/DATE_ONLY)]
  IF NONE(SENSOR_VERSION) THEN SENSOR_VERSION = '' 
  
; ===> Loop through SENSOR_VERSION
  FOR VTH=0, N_ELEMENTS(SENSOR_VERSION)-1 DO BEGIN
    IF SENSOR_VERSION[VTH] EQ '' THEN DIRVER = '' ELSE DIRVER = SENSOR_VERSION[VTH] + SL
    IF DIRVER NE '' AND ~HAS(DIRVER,'VERSION') THEN DIRVER = 'VERSION_'+DIRVER
    SVER = SENSOR_VERSION[VTH]

; ===> Update prods - If both BREWIN_NES and BREWINSST_NES are provided, the latter can be removed because BREWIN_NES will do both
    OK = WHERE(PROD EQ 'PHYTO_SIZE-BREWIN_NES' OR PROD EQ 'PHYTO_SIZE-BREWINSST_NES',COUNT)
    IF COUNT EQ 2 THEN PROD = REMOVE(PROD,WHERE(PROD EQ 'PHYTO_SIZE-BREWINSST_NES'))  

; ===> Loop through MAPS
    FOR MTH=0, N_ELEMENTS(MPS)-1 DO BEGIN
      AMAP = MPS[MTH]

; ===> Loop through PRODS  
      FOR PTH=0, N_ELEMENTS(PROD)-1 DO BEGIN
        APROD = PROD[PTH]

; ===> Set up the output file directories
        DIR_SAVE = !S.OC + SENSOR + SL + DIRVER + AMAP  + SL + 'SAVE' + SL + APROD + SL
        IF APROD EQ 'PPD_SIZE' THEN DIR_SAVE = !S.PP + SENSOR + SL + DIRVER + AMAP  + SL + 'STATS' + SL + APROD + '-' + PPD_ALG + SL
        DIR_TEST, DIR_SAVE
        DIR_STATS = !S.OC + SENSOR + SL + DIRVER + AMAP + SL + 'STATS' + SL

; ===> Based on the input PROD name, determine the file search product (FPROD) and the name(s) of the prods inside the file (SPRODS)  
        VERSION = '' 
        FILE_TYPE = 'NC'
        CASE APROD OF
          'PIGMENTS-PAN':    BEGIN & VERSION='VER1' & FPROD='RRS'          & SPRODS=['RRS_490','RRS_555','RRS_670'] & END
          'PHYTO-PAN':       BEGIN & VERSION=''     & FPROD='PIGMENTS-PAN' & SPRODS='PIGMENTS-PAN' & FILE_TYPE='SAV' & END
          'PSIZE-UITZ':      BEGIN & VERSION=''     & FPROD='PIGMENTS-PAN' & SPRODS='PIGMENTS-PAN' & END
          'CHLOR_A-PAN':     BEGIN & VERSION='VER1' & FPROD='RRS'          & SPRODS=['RRS_490','RRS_555','RRS_670'] & END
          'CHLOR_A-SON':     BEGIN & VERSION=''     & FPROD='RRS'          & SPRODS=['RRS_490','RRS_555','RRS_670'] & END
          'CHLOR_A-WERDELL': BEGIN & VERSION=''     & FPROD='CHL'          & SPRODS='CHL_OCX' & END
          'DOC-MANNINO':     BEGIN & VERSION=''     & FPROD='RRS'          & SPRODS=['RRS_412','RRS_443','RRS_490','RRS_555','RRS_670','AT_412','AT_443'] & END
          'PIGMENT_STATS':   BEGIN & VERSION=''     & FPROD=['CHLA','CHLB','CHLC','CARO','ALLO','FUCO','PERID','NEO','VIOLA','DIA','ZEA','LUT']+'-PAN' & END
          'PPD_SIZE':        BEGIN & VERSION=''     & FPROD='PHYTO-PAN'    & SPRODS = 'PHYTO-PAN' & END
          'PHYTO_SIZE-BREWIN_NES': BEGIN & VERSION='VER2' & FPROD='CHL' & SPRODS=['DATA','SST'] & END
          'PHYTO_SIZE-BREWINSST_NES': BEGIN & VERSION='VER2' & FPROD='CHL' & SPRODS=['DATA','SST'] & END
          'PHYTO_SIZE-HIRATA_NES': BEGIN & VERSION='VER2' & FPROD='CHL' & SPRODS='DATA' & END
          'PHYTO_SIZE-HIRATA':     BEGIN & VERSION='VER1' & FPROD='CHL' & SPRODS='DATA' & END
          'PHYTO_SIZE-TURNER': BEGIN & VERSION='VER1' & FPROD='CHL' & SPRODS=['DATA','SST'] & END
          'POC-STRAMSKI':    BEGIN & VERSION='VER2' & FPROD='RRS' & SPRODS=['RRS_490','RRS_555'] & END
          ELSE: MESSAGE, 'ERROR: Unrecognized input PROD'
        ENDCASE

; ===> Sensor specific wavelengths
        IF SENSOR EQ 'MODISA' THEN SPRODS = REPLACE(SPRODS,['RRS_490','RRS_555','RRS_670'],['RRS_488','RRS_547','RRS_667']) ; Replace the SeaWiFS bands with the equivalent MODIS bands
        IF SENSOR EQ 'VIIRS'  THEN SPRODS = REPLACE(SPRODS,['RRS_490','RRS_555','RRS_670'],['RRS_486','RRS_551','RRS_671'])
        IF SENSOR EQ 'JPSS1'  THEN SPRODS = REPLACE(SPRODS,['RRS_490','RRS_555','RRS_670'],['RRS_489','RRS_556','RRS_667'])
        IF SENSOR EQ 'OCCCI'  THEN BEGIN
          FPROD  = REPLACE(FPROD,'CHL','CHLOR_A-CCI') 
          SPRODS = REPLACE(SPRODS,['RRS_555','RRS_670'],['RRS_560','RRS_665'])
          FILE_TYPE='SAVE' 
        ENDIF
        IF SENSOR EQ 'GLOBCOLOUR'  THEN BEGIN
          FPROD  = REPLACE(FPROD,'CHL','CHLOR_A-GSM')
          FILE_TYPE='SAVE'
        ENDIF
      
; ===> Find the other product files based on the output product    
        SSTFILES=[]
        CASE APROD OF
          'PHYTO_SIZE-HIRATA_NES': FILES = GET_FILES(SENSOR,PRODS=FPROD,VERSION=SVER,FILE_TYPE=FILE_TYPE, DATERANGE=DATERANGE, COUNT=COUNT)
          'PHYTO_SIZE-HIRATA':     FILES = GET_FILES(SENSOR,PRODS=FPROD,VERSION=SVER,FILE_TYPE=FILE_TYPE, DATERANGE=DATERANGE, COUNT=COUNT)
          
          'PHYTO_SIZE-BREWIN_NES': BEGIN
            DIR_TEST,REPLACE(DIR_SAVE,'BREWIN_NES','BREWINSST_NES')
            FILES = GET_FILES(SENSOR, PRODS=FPROD, VERSION=SVER, FILE_TYPE=FILE_TYPE, DATERANGE=DATERANGE, COUNT=COUNT)
            CASE SST_GR OF
              'AVINTERP_MUR': BEGIN ; USE INTERPOLATED AVHRR UNTIL MUR DATA IS AVAILABLE IN 2002
                VFILES = GET_FILES('AVHRR',MAPS='L3B4',FILE_TYPE='INTERP',PRODS='SST',VERSION=SST_VER,DATERANGE=DATERANGE,COUNT=VNUM) & VFP = PARSE_IT(VFILES)
                MFILES = GET_FILES('MUR',MAPS=AMAP,FILE_TYPE='SAVE',PRODS='SST',VERSION=SST_VER,DATERANGE=DATERANGE,COUNT=MNUM) & MFP = PARSE_IT(MFILES)
                IF DATE_2JD(DATERANGE[0]) LT DATE_2JD('20020601') THEN SSTFILES = [DATE_SELECT(VFILES,[DATERANGE[0],'20020531']),MFILES] ELSE SSTFILES = MFILES
              END
              ELSE: MESSAGE, 'Unrecognized SST input'
            ENDCASE
            SSTFILES = SSTFILES[WHERE(SSTFILES NE '')]
            FSP = PARSE_IT(SSTFILES)
          END
          
          'PHYTO_SIZE-BREWINSST_NES': BEGIN
            FILES = GET_FILES(SENSOR, PRODS=FPROD, VERSION=SVER, FILE_TYPE=FILE_TYPE, DATERANGE=DATERANGE, COUNT=COUNT)
            CASE SST_GR OF
              'AVINTERP_MUR': BEGIN ; USE INTERPOLATED AVHRR UNTIL MUR DATA IS AVAILABLE IN 2002
                VFILES = GET_FILES('AVHRR',MAPS='L3B4',FILE_TYPE='INTERP',PRODS='SST',VERSION=SST_VER,DATERANGE=DATERANGE,COUNT=VNUM) & VFP = PARSE_IT(VFILES)
                MFILES = GET_FILES('MUR',MAPS=AMAP,FILE_TYPE='SAVE',PRODS='SST',VERSION=SST_VER,DATERANGE=DATERANGE,COUNT=MNUM) & MFP = PARSE_IT(MFILES)
                IF DATE_2JD(DATERANGE[0]) LT DATE_2JD('20020601') THEN SSTFILES = [DATE_SELECT(VFILES,[DATERANGE[0],'20020531']),MFILES] ELSE SSTFILES = MFILES
              END
              ELSE: MESSAGE, 'Unrecognized SST input'
            ENDCASE
            SSTFILES = SSTFILES[WHERE(SSTFILES NE '')]
            FSP = PARSE_IT(SSTFILES)
          END
          
          'PHYTO_SIZE-TURNER': BEGIN
            IF SENSOR EQ 'OCCCI' THEN SPRODS = 'DATA' ELSE SPRODS = 'CHLOR_A'
            FILES = GET_FILES(SENSOR, PRODS=FPROD, VERSION=SVER, MAPS=AMAP, FILE_TYPE=FILE_TYPE, DATERANGE=DATERANGE, COUNT=COUNT)
            CASE SST_GR OF
              'AVINTERP_MUR': BEGIN ; USE INTERPOLATED AVHRR UNTIL MUR DATA IS AVAILABLE IN 2002
                VFILES = GET_FILES('AVHRR',MAPS='L3B4',FILE_TYPE='INTERP',PRODS='SST',VERSION=SST_VER,DATERANGE=DATERANGE,COUNT=VNUM) & VFP = PARSE_IT(VFILES)
                MFILES = GET_FILES('MUR',MAPS=AMAP,FILE_TYPE='SAVE',PRODS='SST',VERSION=SST_VER,DATERANGE=DATERANGE,COUNT=MNUM) & MFP = PARSE_IT(MFILES)
                IF DATE_2JD(DATERANGE[0]) LT DATE_2JD('20020601') THEN SSTFILES = [DATE_SELECT(VFILES,[DATERANGE[0],'20020531']),MFILES] ELSE SSTFILES = MFILES
              END
              ELSE: MESSAGE, 'Unrecognized SST input'
            ENDCASE
            SSTFILES = SSTFILES[WHERE(SSTFILES NE '')]
            FSP = PARSE_IT(SSTFILES)
          END
        
          'PIGMENTS-PAN': BEGIN
            FILES = GET_FILES(SENSOR,PRODS=FPROD,VERSION=SVER,FILE_TYPE=FILE_TYPE, DATERANGE=DATERANGE, COUNT=COUNT)
            CASE SST_GR OF
              'AVINTERP_MUR': BEGIN ; USE INTERPOLATED AVHRR UNTIL MUR DATA IS AVAILABLE IN 2002
                VFILES = GET_FILES('AVHRR',MAPS='L3B4',FILE_TYPE='INTERP',PROD='SST',VERSION=SST_VER,DATERANGE=DATERANGE,COUNT=VNUM) & VFP = PARSE_IT(VFILES)
                MFILES = GET_FILES('MUR',MAPS=AMAP,FILE_TYPE='SAVE',PROD='SST',VERSION=SST_VER,DATERANGE=DATERANGE,COUNT=MNUM) & MFP = PARSE_IT(MFILES)
                IF DATE_2JD(DATERANGE[0]) LT DATE_2JD('20020601') THEN SSTFILES = [DATE_SELECT(VFILES,[DATERANGE[0],'20020531']),MFILES] ELSE SSTFILES = MFILES
              END
              ELSE: MESSAGE, 'Unrecognized SST input'
            ENDCASE
            SSTFILES = SSTFILES[WHERE(SSTFILES NE '')]
            FSP = PARSE_IT(SSTFILES)          
          END  
               
          'PHYTO-PAN': BEGIN
            IF PERIOD EQ 'D' THEN FILES = FLS(REPLACE(DIR_SAVE,APROD,FPROD)+'D_*' + FPROD + '*.SAV',DATERANGE=DATERANGE,COUNT=COUNT) $
                             ELSE FILES = FLS(DIR_STATS+PIGMENTS[0]+SL+PERIOD+'_*'+PIGMENTS[0]+'*STATS*.SAV',DATERANGE=DATERANGE,COUNT=COUNT)
          END
        
          'CHLOR_A-WERDELL': BEGIN
            IF SENSOR EQ 'OCCCI' THEN BEGIN
              SPRODS = 'DATA'
              FILES = FLS(!S.OC + SENSOR + SL + AMAP +SL + 'SAVE' + SL + 'CHLOR_A-OCI' + SL + '*' + 'CHLOR_A-OCI' + '*.SAV',DATERANGE=DATERANGE, COUNT=COUNT)
            ENDIF ELSE FILES = FLS(!S.OC + SENSOR + SL + AMAP +SL + 'NC'   + SL + FPROD         + SL + '*' + FPROD         + '*.nc', DATERANGE=DATERANGE, COUNT=COUNT)
          END
          
          'PPD_SIZE': BEGIN ; Search for the PHYTO and PPD stats files
            FILES    = FLS(!S.OC  + SENSOR + SL + AMAP + SL + 'STATS' + SL + FPROD            + SL + PERIOD + '_*' + FPROD   + '*.SAV', DATERANGE=DATERANGE,COUNT=COUNT)
            PPDFILES = FLS(!S.PP + SENSOR + SL + AMAP + SL + 'STATS' + SL + 'PPD-' + PPD_ALG + SL + 'M_*PPD-'     + PPD_ALG + '*.SAV', DATERANGE=DATERANGE, COUNT=PNUM)
            PFP = PARSE_IT(PPDFILES)
          END
          
          ELSE: BEGIN
            FILES = GET_FILES(SENSOR,PRODS=FPROD,VERSION=SVER,FILE_TYPE=FILE_TYPE, DATERANGE=DATERANGE, COUNT=COUNT)
            ;IF SENSOR EQ 'OCCCI' THEN FILES = FLS(!S.OC + SENSOR + SL + AMAP + SL + 'SAVE' + SL + FPROD + SL + '*' + FPROD + '*.SAV', DATERANGE=DATERANGE, COUNT=COUNT)$
             ;                    ELSE FILES = FLS(!S.OC + SENSOR + SL + AMAP + SL + 'NC'   + SL + FPROD + SL + '*' + FPROD + '*.nc',  DATERANGE=DATERANGE, COUNT=COUNT)
          END
        ENDCASE
        IF COUNT EQ 0 THEN CONTINUE
      
; ===> Get the subscripts for the mask (if needed)      
        IF MASK NE [] THEN BEGIN
          CASE [1] OF
            MASK EQ 'LME': BEGIN
              STRUCT = READ_SHPFILE('LMES66', MAPP=AMAP, COLOR=COLORS, VERBOSE=VERBOSE)
              STRUCT = STRUCT_REMOVE(STRUCT.(0),['CENTRALARCTIC','COLORS','LMES66_OUTLINE'])
              SUBS = []
              FOR N=0, N_ELEMENTS(TAG_NAMES(STRUCT))-1 DO SUBS = [SUBS,STRUCT.(N).SUBS]
              BLK = MAPS_BLANK(AMAP,FILL=0) & BLK[SUBS] = 1
              MASK_SUBS = WHERE(BLK EQ 0)
            END ; 'LME'
            VALIDS('MAPS',MASK) NE '': BEGIN
              RMAP = MAPS_L3B_2MAP(MAPS_BLANK(AMAP),BINS,MAP_IN=AMAP,MAP_OUT=MASK,STRUCT_XPYP=STRUCT_XPYP)
              SUBS = STRUCT_XPYP.SUBS
              BLK = MAPS_BLANK(AMAP,FILL=0) & BLK[SUBS] = 1
              MASK_SUBS = WHERE(BLK EQ 0)
            END
            ELSE: MESSAGE, 'ERROR: Unrecognized MASK'
          ENDCASE
        ENDIF ; MASK NE []
      
; ===> Loop through files      
        IF KEY(R_FILES) THEN FILES = REVERSE(FILES)
        FOR F=0, N_ELEMENTS(FILES)-1 DO BEGIN
          FP = FILE_PARSE(FILES[F])
          SI = SENSOR_INFO(FILES[F])
          DATE = PERIOD_2DATE(SI.PERIOD)
          MS = MAPS_SIZE(SI.MAP,PX=PX,PY=PY)
          IF VERSION NE '' THEN PVER = '-'+VERSION ELSE PVER = VERSION
          SAVEFILE = DIR_SAVE + SI.PERIOD + '-' + REPLACE(SI.FILELABEL, SI.MAP, AMAP) + '-' + APROD + PVER + '.SAV'
          IF APROD EQ 'PPD_SIZE' THEN SAVEFILE = REPLACE(SAVEFILE,[SL+'SAVE'+SL,'PPSIZE'+PVER+'.SAV'],[SL+'STATS'+SL,'PPSIZE-'+PPD_ALG+PVER+'.SAV'])
          IF APROD EQ 'PHYTO-PAN' AND PERIOD NE 'D' THEN SAVEFILE = REPLACE(SAVEFILE,SL+'SAVE'+SL,SL+'STATS'+SL)
          IF SSTFILES NE [] THEN SST_FILE = SSTFILES[WHERE(FSP.PERIOD EQ SI.PERIOD,/NULL,COUNTS)] ELSE SST_FILE = []
          IF PPDFILES NE [] THEN PPD_FILE = PPDFILES[WHERE(PFP.PERIOD EQ SI.PERIOD,/NULL,COUNTP)] ELSE PPD_FILE = []
        
          IF APROD EQ 'PHYTO_SIZE-BREWIN_NES' THEN BEGIN
            IF FILE_MAKE([FILES[F],SST_FILE,PPD_FILE],[SAVEFILE,REPLACE(SAVEFILE,'BREWIN_NES','BREWINSST_NES')],OVERWRITE=OVERWRITE) EQ 0 THEN CONTINUE ; Check if file needs to be created or updated
          ENDIF ELSE IF FILE_MAKE([FILES[F],SST_FILE,PPD_FILE],SAVEFILE,OVERWRITE=OVERWRITE) EQ 0 THEN CONTINUE ; Check if file needs to be created or updated      
          
          IF APROD EQ 'PIGMENTS-PAN' AND SST_FILE EQ [] THEN CONTINUE ; >>>>>>>>>>>>>>> Must have SST file to run PIGMENTS
          IF APROD EQ 'PHYTO_SIZE-TURNER' AND SST_FILE EQ [] THEN CONTINUE ; >>>>>>>>>>>>>> Must have SST file to run TURNER PSIZE algorithm
          IF APROD EQ 'PHYTO-PAN' OR APROD EQ 'PPD_SIZE' THEN GOTO, SKIP_READ_NC ; >>>>>>>>>>>>>>>
          
          
          IF SENSOR EQ 'OCCCI' OR SENSOR EQ 'GLOBCOLOUR' THEN BEGIN
            D = STRUCT_READ(FILES[F],STRUCT=STR)
            DTAG = 'IMAGE'
          ENDIF ELSE BEGIN
            D = READ_NC(FILES[F],PRODS=SPRODS,GLOBAL=GLOBAL)
            DTAG = 'DATA'
            STR = D.SD
          ENDELSE
          IF IDLTYPE(D) EQ 'STRING' THEN MESSAGE, 'ERROR: Can not read ' + SPRODS + ' from ' + FILES[F]
          OK  = WHERE_MATCH(STRUPCASE(SPRODS),STRUPCASE(TAG_NAMES(STR)),COUNT)
          IF COUNT GE 1 THEN SPRODS = SPRODS[OK] ELSE BEGIN
            OK  = WHERE_MATCH(DTAG,STRUPCASE(TAG_NAMES(STR)),COUNT) 
            IF COUNT EQ 1 THEN SPRODS = DTAG ELSE CONTINUE ; >>>>>>>>>>>>>>>>>>>>>>>
          ENDELSE  
        
          RRS_412 = [] & RRS_443 = [] & RRS_490 = [] & RRS_555 = [] & RRS_670 = [] & CHL_OCX = [] & CHLOR_A = []; Make sure parameters are null before getting SPROD data
          FOR S=0, N_ELEMENTS(SPRODS)-1 DO BEGIN
            SPROD = STRUPCASE(SPRODS[S])
            CASE SPROD OF
              'RRS_412': RRS_412=MAPS_L3B_2ARR(GET(STR.RRS_412,DTAG),MP=AMAP,BINS=STR.RRS_412.BINS)
              'RRS_443': RRS_443=MAPS_L3B_2ARR(GET(STR.RRS_443,DTAG),MP=AMAP,BINS=STR.RRS_443.BINS)
              'RRS_486': RRS_488=MAPS_L3B_2ARR(GET(STR.RRS_486,DTAG),MP=AMAP,BINS=STR.RRS_486.BINS)
              'RRS_488': RRS_488=MAPS_L3B_2ARR(GET(STR.RRS_488,DTAG),MP=AMAP,BINS=STR.RRS_488.BINS)
              'RRS_489': RRS_490=MAPS_L3B_2ARR(GET(STR.RRS_489,DTAG),MP=AMAP,BINS=STR.RRS_489.BINS)
              'RRS_490': RRS_490=MAPS_L3B_2ARR(GET(STR.RRS_490,DTAG),MP=AMAP,BINS=STR.RRS_490.BINS)
              'RRS_547': RRS_547=MAPS_L3B_2ARR(GET(STR.RRS_547,DTAG),MP=AMAP,BINS=STR.RRS_547.BINS)
              'RRS_551': RRS_547=MAPS_L3B_2ARR(GET(STR.RRS_551,DTAG),MP=AMAP,BINS=STR.RRS_551.BINS)
              'RRS_555': RRS_555=MAPS_L3B_2ARR(GET(STR.RRS_555,DTAG),MP=AMAP,BINS=STR.RRS_555.BINS)
              'RRS_556': RRS_555=MAPS_L3B_2ARR(GET(STR.RRS_556,DTAG),MP=AMAP,BINS=STR.RRS_556.BINS)
              'RRS_560': RRS_555=MAPS_L3B_2ARR(GET(STR.RRS_560,DTAG),MP=AMAP,BINS=STR.RRS_560.BINS)
              'RRS_665': RRS_670=MAPS_L3B_2ARR(GET(STR.RRS_665,DTAG),MP=AMAP,BINS=STR.RRS_665.BINS)
              'RRS_667': RRS_667=MAPS_L3B_2ARR(GET(STR.RRS_667,DTAG),MP=AMAP,BINS=STR.RRS_667.BINS)
              'RRS_670': RRS_670=MAPS_L3B_2ARR(GET(STR.RRS_670,DTAG),MP=AMAP,BINS=STR.RRS_670.BINS)
              'RRS_671': RRS_667=MAPS_L3B_2ARR(GET(STR.RRS_671,DTAG),MP=AMAP,BINS=STR.RRS_671.BINS)
              'CHL_OCX': CHL_OCX=MAPS_L3B_2ARR(GET(STR.CHL_OCX,DTAG),MP=AMAP,BINS=STR.CHL_OCX.BINS)
              'CHL_OCI': CHLOR_A=MAPS_L3B_2ARR(GET(STR.CHLOR_A,DTAG),MP=AMAP,BINS=STR.CHLOR_A.BINS)
              'CHLOR_A': CHLOR_A=MAPS_L3B_2ARR(GET(STR.CHLOR_A,DTAG),MP=AMAP,BINS=STR.CHLOR_A.BINS)
              'DATA':    CHLOR_A=MAPS_L3B_2ARR(STR.DATA,             MP=AMAP,BINS=STR.BINS)
              'IMAGE':   CHLOR_A=MAPS_L3B_2ARR(STR.IMAGE,            MP=AMAP,BINS=STR.BINS)
            ENDCASE ; SPROD
          ENDFOR ; SPRODS
          
          IF SENSOR EQ 'JPSS1' THEN BEGIN
            RRS_670 = RRS_667 & RRS_667 = []  ; TEMPORARY WORK AROUND UNTIL THE ALGORITHMS ARE UPDATED FOR JPSS1 (AND VIIRS)
          ENDIF
        
          LBINS = MAPS_L3B_BINS(AMAP)
        
          SKIP_READ_NC:
        
          CASE APROD OF
            'CHLOR_A-PAN': BEGIN
              CHLPAN = CHLOR_A_PAN(RRS490=RRS_490,RRS488=RRS_488,RRS547=RRS_547,RRS555=RRS_555,RRS667=RRS_667,RRS670=RRS_670,SENSOR=SI.SENSOR,VERSION=VERSION)
              REF = 'Pan, X., Mannino, A., Russ, M.E., Hooker, S.B., 2008. Remote sensing of the absorption coefficients and chlorophyll a concentration in the United States southern Middle Atlantic Bight from SeaWiFS and MODIS-Aqua. Journal of Geophysical Research 113, C11022.'
              OK = WHERE(CHLPAN NE MISSINGS(CHLPAN),COUNT,/NULL)
              STRUCT_WRITE, CHLPAN[OK], BINS=LBINS[OK], FILE=SAVEFILE, DATA_UNITS=UNITS('CHLOR_A',/SI), INFILE=FILES[F], ALG='PAN', PROD='CHLOR_A', VERSION=VERSION, SATELLITE=SI.SATELLITE, SENSOR=SI.SENSOR, COVERAGE=SI.COVERAGE, LOGLUN=LOG_LUN
            END ; CHLOR_A-PAN
        
            'CHLOR_A-WERDELL': BEGIN
              CHLWER = CHLOR_A_WERDELL(CHL_OCX,SENSOR=SI.SENSOR)
              REF = 'Werdell, J., Bailey, S., Franz, B., Harding, L., Feldman, G., McClain, C., 2009. Regional and seasonal variabiilty of chlorophyll-a in Chesapeake Bay as observed by SeaWiFS and MODIS-Aqua. Remote Sensing of Environment 113, 1319-1330.'
              OK = WHERE(CHLWER NE MISSINGS(CHLWER),COUNT,/NULL)
              STRUCT_WRITE, CHLWER[OK], BINS=LBINS[OK], FILE=SAVEFILE, DATA_UNITS=UNITS('CHLOR_A',/SI), INFILE=FILES[F], ALG='WERDELL', PROD='CHLOR_A', SATELLITE=SI.SATELLITE, SENSOR=SI.SENSOR, COVERAGE=SI.COVERAGE, LOGLUN=LOG_LUN
            END ; CHLOR_A-WERDELL
                       
            'PHYTO_SIZE-BREWIN_NES': BEGIN
            ;  PLUN, LOG_LUN, 'Running PHTYO-BREWIN_NES for ' + SAVEFILE, 0
              SST = STRUCT_READ(SST_FILE,STRUCT=STR,BINS=SSTBINS)
              IF STR.MAP NE AMAP THEN SST = MAPS_REMAP(SST,MAP_IN=STR.MAP, MAP_OUT=AMAP, BINS=SSTBINS) ELSE BEGIN $
                IF STRUCT_HAS(STR,'BINS') THEN IF N_ELEMENTS(STR.BINS) NE PY THEN BEGIN   ; If the structure has the BINS tag then recreate the full BIN
                  BLK = FLTARR(PY) & BLK[*] = MISSINGS(0.0)
                  SBLK = BLK
                  MESSAGE, 'NEED TO CHECK THE SST BINS'
                  SBLK[STR.BINS] = S
                  SST = FLTARR(1,PY)
                  SST[0,*] = SBLK & GONE, SBLPHK
                ENDIF
              ENDELSE
              SZS = SIZEXYZ(SST,PX=SPX,PY=SPY)
              IF SPY NE PY THEN MESSAGE,'ERROR: SST array size is different from the input RRS data array size.'
              
              PHYTO = PHYTO_SIZE_BREWIN_NES(CHLOR_A, SST=SST, VERSION=VERSION, INIT=INIT, PSIZE=PSIZE, PHYTOSST=PHYTOSST, VERBOSE=VERBOSE)
              REF = ['Brewin, R.J.W., Sathyendranath, S., Hirata, T., Lavender, S.J., Barciela, R.M., Hardman-Mountford, N.J., 2010. A three-component model of phytoplankton size class for the Atlantic Ocean. Ecological Modelling 221, 1472?1483. https://doi.org/10.1016/j.ecolmodel.2010.02.014',$
                     'Brewin, R.J.W., Sathyendranath, S., Jackson, T., Barlow, R., Brotas, V., Airs, R., Lamont, T., 2015. Influence of light in the mixed-layer on the parameters of a three-component model of phytoplankton size class. Remote Sensing of Environment 168, 437?450. https://doi.org/10.1016/j.rse.2015.07.004',$
                     'Brewin, R.J.W., Ciavatta, S., Sathyendranath, S., Jackson, T., Tilstone, G., Curran, K., Airs, R.L., Cummings, D., Brotas, V., Organelli, E., Dall?Olmo, G., Raitsos, D.E., 2017. Uncertainty in Ocean-Color Estimates of Chlorophyll for Phytoplankton Groups. Front. Mar. Sci. 4. https://doi.org/10.3389/fmars.2017.00104']            
              STRUCT_WRITE, PSIZE, BINS=BINS, FILE=SAVEFILE, DATA_UNITS=UNITS('CHLOR_A',/SI), INFILE=FILES[F], ALG='BREWIN_NES', PROD='PHYTO_SIZE', SATELLITE=SI.SATELLITE, SENSOR=SI.SENSOR, COVERAGE=SI.COVERAGE, LOGLUN=LOG_LUN
              OK = WHERE(PHYTOSST.MICRO NE MISSINGS(PHYTOSST.MICRO),COUNT)
              IF COUNT GT 0 THEN STRUCT_WRITE, PHYTOSST, BINS=BINS, FILE=REPLACE(SAVEFILE,'BREWIN_NES','BREWINSST_NES'), DATA_UNITS=UNITS('CHLOR_A',/SI), INFILE=FILES[F], ALG='BREWINSST_NES', PROD='PHYTO_SIZE', SATELLITE=SI.SATELLITE, SENSOR=SI.SENSOR, COVERAGE=SI.COVERAGE, LOGLUN=LOG_LUN
              GONE, PHYTO & GONE, PSIZE & GONE, PHYTOSST
              IF KEY(COMPOSITE) THEN PHYTO_COMPOSITE, SAVEFILE
            END ; PHYTO-PAN
            
            'PHYTO_SIZE-BREWINSST_NES': BEGIN  ; Only save the BREWINSST_NES data and not the BREWIN_NES
              ;  PLUN, LOG_LUN, 'Running PHTYO-BREWIN_NES for ' + SAVEFILE, 0
              SST = STRUCT_READ(SST_FILE,STRUCT=STR,BINS=SSTBINS)
              IF STR.MAP NE AMAP THEN SST = MAPS_REMAP(SST,MAP_IN=STR.MAP, MAP_OUT=AMAP, BINS=SSTBINS) ELSE BEGIN $
                IF STRUCT_HAS(STR,'BINS') THEN IF N_ELEMENTS(STR.BINS) NE PY THEN BEGIN   ; If the structure has the BINS tag then recreate the full BIN
                BLK = FLTARR(PY) & BLK[*] = MISSINGS(0.0)
                SBLK = BLK
                MESSAGE, 'NEED TO CHECK THE SST BINS'
                SBLK[STR.BINS] = S
                SST = FLTARR(1,PY)
                SST[0,*] = SBLK & GONE, SBLPHK
              ENDIF
            ENDELSE
            SZS = SIZEXYZ(SST,PX=SPX,PY=SPY)
            IF SPY NE PY THEN MESSAGE,'ERROR: SST array size is different from the input RRS data array size.'

            PHYTO = PHYTO_SIZE_BREWIN_NES(CHLOR_A, SST=SST, VERSION=VERSION, INIT=INIT, PSIZE=PSIZE, PHYTOSST=PHYTOSST, VERBOSE=VERBOSE)
            REF = ['Brewin, R.J.W., Sathyendranath, S., Hirata, T., Lavender, S.J., Barciela, R.M., Hardman-Mountford, N.J., 2010. A three-component model of phytoplankton size class for the Atlantic Ocean. Ecological Modelling 221, 1472?1483. https://doi.org/10.1016/j.ecolmodel.2010.02.014',$
              'Brewin, R.J.W., Sathyendranath, S., Jackson, T., Barlow, R., Brotas, V., Airs, R., Lamont, T., 2015. Influence of light in the mixed-layer on the parameters of a three-component model of phytoplankton size class. Remote Sensing of Environment 168, 437?450. https://doi.org/10.1016/j.rse.2015.07.004',$
              'Brewin, R.J.W., Ciavatta, S., Sathyendranath, S., Jackson, T., Tilstone, G., Curran, K., Airs, R.L., Cummings, D., Brotas, V., Organelli, E., Dall?Olmo, G., Raitsos, D.E., 2017. Uncertainty in Ocean-Color Estimates of Chlorophyll for Phytoplankton Groups. Front. Mar. Sci. 4. https://doi.org/10.3389/fmars.2017.00104']
            STRUCT_WRITE, PHYTOSST, BINS=BINS, FILE=SAVEFILE, DATA_UNITS=UNITS('CHLOR_A',/SI), INFILE=FILES[F], ALG='BREWINSST_NES', PROD='PHYTO_SIZE', SATELLITE=SI.SATELLITE, SENSOR=SI.SENSOR, COVERAGE=SI.COVERAGE, LOGLUN=LOG_LUN
            GONE, PHYTO & GONE, PSIZE & GONE, PHYTOSST
            IF KEY(COMPOSITE) THEN PHYTO_COMPOSITE, SAVEFILE
          END ; PHYTO-PAN
          
          'PHYTO_SIZE-TURNER': BEGIN  ; Only save the BREWINSST_NES data and not the BREWIN_NES
            ;  PLUN, LOG_LUN, 'Running PHTYO_SIZE-TURNER for ' + SAVEFILE, 0
            SST = STRUCT_READ(SST_FILE,STRUCT=STR,BINS=SSTBINS)
            IF STR.MAP NE AMAP THEN BEGIN
              SST = MAPS_REMAP(SST,MAP_IN=STR.MAP, MAP_OUT=AMAP, BINS=SSTBINS) 
            ENDIF ELSE BEGIN 
              IF STRUCT_HAS(STR,'BINS') THEN IF N_ELEMENTS(STR.BINS) NE PY THEN BEGIN   ; If the structure has the BINS tag then recreate the full BIN
              BLK = FLTARR(PY) & BLK[*] = MISSINGS(0.0)
              SBLK = BLK
              MESSAGE, 'NEED TO CHECK THE SST BINS'
              SBLK[STR.BINS] = S
              SST = FLTARR(1,PY)
              SST[0,*] = SBLK & GONE, SBLPHK
            ENDIF
          ENDELSE
          SZS = SIZEXYZ(SST,PX=SPX,PY=SPY)
          IF SPY NE PY THEN MESSAGE,'ERROR: SST array size is different from the input CHL/RRS data array size.'

          PHYTO = PHYTO_SIZE_TURNER(CHLOR_A, SST=SST, VERSION=VERSION, INIT=INIT, VERBOSE=VERBOSE)
          REF = 'Turner, K. J., C. B. Mouw, K. J. W. Hyde, R. E. Morse, and A. B. Ciochetto Optimization and assessment of phytoplankton size class algorithms for ocean 2 color data on the Northeast U.S. continental shelf, Remote Sensing of Environment. in press          
          STOP
; TODO Look into using a HASH instead of a structure
; TODO Subset by BINS so missing data are not saved          
          STRUCT_WRITE, PHYTO, BINS=BINS, FILE=SAVEFILE, DATA_UNITS=UNITS('CHLOR_A',/SI), INFILE=FILES[F], ALG='TURNER', PROD='PHYTO_SIZE', SATELLITE=SI.SATELLITE, SENSOR=SI.SENSOR, COVERAGE=SI.COVERAGE, LOGLUN=LOG_LUN
          GONE, PHYTO & GONE, PSIZE & GONE, PHYTOSST
          IF KEY(COMPOSITE) THEN PHYTO_COMPOSITE, SAVEFILE
        END ; PHYTO-PAN
            
            'PHYTO_SIZE-HIRATA_NES': BEGIN
           ;   PLUN, LOG_LUN, 'Running PHYTO-HIRATA_NES for ' + SAVEFILE, 0
              PSIZE = PHYTO_SIZE_HIRATA_NES(CHLOR_A, VERSION=VERSION, VERBOSE=VERBOSE)
              REF = 'Hirata, T., Hardman-Mountford, N. J., Brewin, R. J. W., Aiken, J., Barlow, R., Suzuki, K., Isada, T., et al. 2011. Synoptic relationships between surface Chlorophyll-a and diagnostic pigments specific to phytoplankton functional types. Biogeosciences, 8: 311-327.'
              STRUCT_WRITE, PSIZE, BINS=BINS, FILE=SAVEFILE, DATA_UNITS=UNITS('CHLOR_A',/SI), INFILE=FILES[F], ALG='HIRATA_NES', PROD='PHYTO_SIZE', SATELLITE=SI.SATELLITE, SENSOR=SI.SENSOR, COVERAGE=SI.COVERAGE, LOGLUN=LOG_LUN
              GONE, PHYTO
              IF KEY(COMPOISTE) THEN PHYTO_COMPOSITE, SAVEFILE
            END ; PHYTO_SIZE-HIRATA_NES
            
            'PHYTO_SIZE-HIRATA': BEGIN
              PSIZE = PHYTO_SIZE_HIRATA(CHLOR_A, VERSION=VERSION, VERBOSE=VERBOSE)
              REF = 'Hirata, T., Hardman-Mountford, N. J., Brewin, R. J. W., Aiken, J., Barlow, R., Suzuki, K., Isada, T., et al. 2011. Synoptic relationships between surface Chlorophyll-a and diagnostic pigments specific to phytoplankton functional types. Biogeosciences, 8: 311-327.'
              STRUCT_WRITE, PSIZE, BINS=BINS, FILE=SAVEFILE, DATA_UNITS=UNITS('CHLOR_A',/SI), INFILE=FILES[F], ALG='HIRATA', PROD='PHYTO_SIZE', SATELLITE=SI.SATELLITE, SENSOR=SI.SENSOR, COVERAGE=SI.COVERAGE, LOGLUN=LOG_LUN
              GONE, PHYTO
              IF KEY(COMPOISTE) THEN PHYTO_COMPOSITE, SAVEFILE
            END ; PHYTO_SIZE-HIRATA (global)
        
            'PIGMENTS-PAN': BEGIN
              SST = STRUCT_READ(SST_FILE,STRUCT=STR)
              IF STR.MAP NE AMAP THEN SST = MAPS_REMAP(SST,MAP_IN=STR.MAP, MAP_OUT=AMAP, BINS=STR.BINS) ELSE BEGIN $
                IF STRUCT_HAS(STR,'BINS') THEN IF N_ELEMENTS(STR.BINS) NE PY THEN BEGIN                   ; If the structure has the BINS tag then recreate the full BIN
                  BLK = FLTARR(PY) & BLK[*] = MISSINGS(0.0)
                  SBLK = BLK
                  MESSAGE, 'NEED TO CHECK THE SST BINS'
                  SBLK[STR.BINS] = S
                  SST = FLTARR(1,PY)
                  SST[0,*] = SBLK & GONE, SBLPHK
                ENDIF
              ENDELSE
              SZS = SIZEXYZ(SST,PX=SPX,PY=SPY)
              IF SPY NE PY THEN MESSAGE,'ERROR: SST array size is different from the input RRS data array size.'
  
              PIGMENTS = PIGMENTS_PAN(RRS488=RRS_488, RRS490=RRS_490, RRS547=RRS_547, RRS555=RRS_555, RRS667=RRS_667, RRS670=RRS_670, SST=SST, SENSOR=SI.SENSOR, VERSION=VERSION)
              OK = WHERE(PIGMENTS.(0) NE MISSINGS(0.0),COUNT,/NULL)
              IF COUNT GT 0 AND COUNT LT N_ELEMENTS(LBINS) THEN BEGIN
                TAGS = TAG_NAMES(PIGMENTS)
                NEW = CREATE_STRUCT(TAGS[0],PIGMENTS.(0)[OK])
                FOR T=1, N_TAGS(PIGMENTS)-1 DO NEW = CREATE_STRUCT(NEW,TAGS[T],PIGMENTS.(T)[OK])
                PIGMENTS = NEW
                BINS = LBINS[OK]
                GONE, NEW
              ENDIF
              REF = 'Pan, X., Mannino, A., Russ, M.E., Hooker, S.B., Harding Jr, L.W., 2010. Remote sensing of phytoplankton pigment distribution in the United States northeast coast. Remote Sensing of Environment 114, 2403-2416.'
              IF PIGMENTS NE [] THEN STRUCT_WRITE, PIGMENTS, BINS=BINS, FILE=SAVEFILE, DATA_UNITS=UNITS('CHLOR_A',/SI), INFILE=FILES[F], ALG='PAN', PROD='PIGMENTS', SATELLITE=SI.SATELLITE, SENSOR=SI.SENSOR, COVERAGE=SI.COVERAGE, VERSION=VERSION, LOGLUN=LOG_LUN
              IF KEY(COMPOISTE) THEN PIGMENTS_COMPOSITE, SAVEFILE
            END ; PIGMENTS
          
            'PHYTO-PAN': BEGIN
              D = STRUCT_READ(FILES[F],STRUCT=PIGMENT_STRUCT,MASK=MASK_SUBS)
              IF HAS(PIGMENT_STRUCT,'BINS') THEN BINS = PIGMENT_STRUCT.BINS ELSE BINS = []
              IF PERIOD NE 'D' THEN BEGIN
                OKPG = WHERE(PIGMENT_STRUCT.MEAN NE MISSINGS(PIGMENT_STRUCT.MEAN),COUNT_PG)
                IF COUNT_PG EQ 0 THEN GOTO, DONE_PHYTO
                PIGMENT_STRUCT = CREATE_STRUCT(PIGMENT_STRUCT.PROD,PIGMENT_STRUCT.MEAN(OKPG))
                BINS = BINS(OKPG)
                PFILES = FILES[F]
                FOR PG=1, N_ELEMENTS(PIGMENTS)-1 DO BEGIN
                  DP = STRUCT_READ(REPLACE(FILES[F],PIGMENTS[0],PIGMENTS(PG)),STRUCT=PG_STRUCT,MASK=MASK_SUBS)
                  PIGMENT_STRUCT = CREATE_STRUCT(PIGMENT_STRUCT,PG_STRUCT.PROD,PG_STRUCT.MEAN(OKPG))
                  PFILES = [PFILES,REPLACE(FILES[F],PIGMENTS[0],PIGMENTS(PG))]
                ENDFOR
              ENDIF
              PLUN, LOG_LUN, 'Running PHYTO_PAN for ' + SAVEFILE, 0
              PHYTO = PHYTO_PAN(PIGMENT_STRUCT, VERSION=VERSION, INIT=INIT, VERBOSE=VERBOSE)
              REF = 'Pan, X., Mannino, A., Marshall, H.G., Filippino, K.C., Mulholland, M.R., 2011. Remote sensing of phytoplankton community composition along the northeast coast of the United States. Remote Sensing of Environment 115, 3731-3747.'
              STRUCT_WRITE, PHYTO, BINS=BINS, FILE=SAVEFILE, DATA_UNITS=UNITS('CHLOR_A',/SI), INFILE=FILES[F], ALG='PAN', PROD='PHYTO', SATELLITE=SI.SATELLITE, SENSOR=SI.SENSOR, COVERAGE=SI.COVERAGE, LOGLUN=LOG_LUN
              GONE, PHYTO
              IF KEY(COMPOISTE) THEN PHYTO_COMPOSITE, SAVEFILE
            END ; PHYTO-PAN
  
            'PPD_SIZE': BEGIN
              MDATA = STRUCT_READ(FILES[F],STRUCT=MSTRUCT,TAG='MICRO_PERCENTAGE')
              IF HAS(MSTRUCT,'BINS') THEN MDATA = MAPS_L3B_2ARR(MDATA,MP=MSTRUCT.MAP,BINS=MSTRUCT.BINS)
        
              PDATA = STRUCT_READ(PPD_FILE,STRUCT=PSTRUCT)
              IF HAS(PSTRUCT,'BINS') THEN PDATA = MAPS_L3B_2ARR(PDATA,MP=PSTRUCT.MAP,BINS=PSTRUCT.BINS)
        
              OKALL = WHERE(MDATA NE MISSINGS(MDATA) AND PDATA NE MISSINGS(PDATA),COUNTALL)
              IF COUNTALL EQ 0 THEN GOTO, SKIP_PPD_SIZE
        
              BINS = MAPS_L3B_BINS(MSTRUCT.MAP)
              BINS = BINS(OKALL)
        
              PLUN, LOG_LUN, 'Running PPD_SIZE for ' + SAVEFILE, 0
              PSIZE = PHYTO_PP_MARMAP(PP=PDATA(OKALL),MICRO=MDATA(OKALL),VERBOSE=verbose)
              ;    REF = 'Pan, X., Mannino, A., Marshall, H.G., Filippino, K.C., Mulholland, M.R., 2011. Remote sensing of phytoplankton community composition along the northeast coast of the United States. Remote Sensing of Environment 115, 3731-3747.'
              STRUCT_WRITE, PSIZE, BINS=BINS, FILE=SAVEFILE, DATA_UNITS=UNITS('PPD',/SI), INFILE=FILES[F], ALG=PPD_ALG, PROD='PPSIZE', SATELLITE=SI.SATELLITE, SENSOR=SI.SENSOR, COVERAGE=SI.COVERAGE, LOGLUN=LOG_LUN
              GONE, PSIZE
              SKIP_PPD_SIZE:
        
            END
        
            'DOC-MANNINO': BEGIN
              DOC = DOC_MANNINO(RRS412=RRS_412, RRS443=RRS_443, RRS547=RRS_547, RRS555=RRS_555, RRS667=RRS667, RRS670=RRS_670, DATE=DATE, ACDOM_ALG='MLR_A412', /LINEAR, INIT=INIT)
              REF = 'Pan, X., Mannino, A., Russ, M.E., Hooker, S.B., 2008. Remote sensing of the absorption coefficients and chlorophyll a concentration in the United States southern Middle Atlantic Bight from SeaWiFS and MODIS-Aqua. Journal of Geophysical Research 113, C11022.'
              REF = [REF,'Mannino, A., Signorini, S.R., Novak, M.G., Wilkin, J., Friedrichs, M.A.M., Najjar, R.G., 2016. Dissolved organic carbon fluxes in the Middle Atlantic Bight: An integrated approach based on satellite data and ocean model products. Journal of Geophysical Research: Biogeosciences, 312-336.']
              STRUCT_WRITE, DOC, BINS=LBINS, FILE=SAVEFILE, DATA_UNITS=UNITS('DOC',/SI), INFILE=FILES[F], ALG='MANNINO', PROD='DOC', SATELLITE=SI.SATELLITE, SENSOR=SI.SENSOR, COVERAGE=SI.COVERAGE, LOGLUN=LOG_LUN
            END ; DOC-MANNINO
          
            'POC-STRAMSKI': BEGIN
              POC = POC_STRAMSKI(RRS490=RRS_490, RRS555=RRS_555, WAVELENGTH=SPRODS[1], VERSION=VERSION)
              REF = 'Stramski, D., et al. (2008), Relationships between the surface concentration of particulate organic carbon and optical properties in the eastern South Pacific and eastern Atlantic Oceans, Biogeosciences, 5(1), 171-201.'
              STRUCT_WRITE, POC, BINS=LBINS, FILE=SAVEFILE, DATA_UNITS=UNITS('POC',/SI), INFILE=FILES[F], ALG='STRAMSKI', PROD='POC', SATELLITE=SI.SATELLITE, SENSOR=SI.SENSOR, COVERAGE=SI.COVERAGE, REFERENCE=REF, VERSION=VERSION, LOGLUN=LOG_LUN

            END ; POC-STRAMSKI
          ENDCASE ; APROD
          DONE_PHYTO:
        ENDFOR ; FILES
        
        IF APROD EQ 'DOC-MANNINO' THEN BEGIN
          FILES = FLS(DIR_SAVE + 'D_*' + '-' + REPLACE(SI.FILELABEL, SI.MAP, AMAP) + '-' + APROD + '.SAV',DATERANGE=DATERANGE)
          DOCS = ['ACDOM_412','DOC_CHS','DOC_DEL','DOC_HUD','DOC_MAB']
          ALGS = ['MAN_MLR','MANNINO','MANNINO','MANNINO','MANNINO']
          FOR Z=0, N_ELEMENTS(DOCS)-1 DO BEGIN
            DIR_STATS = SERVER + DATASET + SL + AMAP  + SL + 'STATS' + SL + DOCS(Z)+'-'+ALGS(Z) + SL  & DIR_TEST, DIR_STATS
            FILE_LABEL = REPLACE(FILE_LABEL_MAKE(FILES[0]),'DOC-MANNINO',DOCS(Z) + '-' + ALGS(Z))
            STATS_ARRAYS_PERIODS, FILES, STAT_PROD=DOCS(Z), DIR_OUT=DIR_STATS, PERIOD_CODE_OUT='M', FILE_LABEL=FILE_LABEL, DATERANGE=DATERANGE, DO_STATS=['MEAN','NUM'], KEY_STAT=KEY_STAT, FORCE_STATS=FORCE_STATS, OVERWRITE=OVERWRITE, VERBOSE=VERBOSE, LOGLUN=LOG_LUN
          ENDFOR
        ENDIF
    
      ENDFOR ; APRODS
    ENDFOR ; MAPS
  ENDFOR ; VERSION  
  
END
