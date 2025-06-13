; $ID:	SATSHIP_DEMO.PRO,	2020-07-08-15,	USER-KJWH	$

	PRO SATSHIP_DEMO

;+
; NAME:
;		SATSHIP_DEMO
;
; PURPOSE:
;		This procedure is the DEMO program to work with the SATSHIP routines.
;
; CATEGORY:
;
;
; CALLING SEQUENCE:
;
; INPUTS:
;
; OPTIONAL INPUTS:
;
; KEYWORD PARAMETERS:
;
; OUTPUTS:

;
;	NOTES:
;
;
; MODIFICATION HISTORY:
;			Written May 8, 2015 by K.J.W.Hyde, 28 Tarzwell Drive, NMFS, NOAA 02882 (kimberly.hyde@noaa.gov)
;-
;	****************************************************************************************************
	ROUTINE_NAME = 'SATSHIP_DEMO'

  SL = PATH_SEP()
    
  DIR_DEMO       = !S.DEMO + ROUTINE_NAME + SL     
  DIR_DATA       = DIR_DEMO + 'SATDATA' + SL & DIR_TEST, DIR_DATA
  DIR_OUT        = DIR_DEMO

  DATASETS       = ['OC-MODIS-LAC','OC-SEAWIFS-MLAC']
  L2_DIRS        = ['/nadata/PROJECTS/CliVEC/DATA/SATDATA/', '/satbackup1/archive/DATASETS/OC-SEAWIFS-MLAC/L2/']
  L1_DIRS        = [!S.SEADAS, '/satbackup1/archive/DATASETS/']
  L1             = ['L1A','L1']
  SKIP_FIND_HDF  = 1                                                                                        ; SKIP SEARCHING FOR ORIGINAL L2 FILES AND COPYING TO DEMO DIRECTORY  
  DIR_HDFDATA    = DIR_DEMO + 'SATDATA' + SL + 'L2' + SL   & DIR_TEST, DIR_HDFDATA                          ; PROJECT DIRECTORY TO COPY THE L2 HDF FILES TO
    
  MDATASETS      = ['SST-MUR-1KM']                                                                          ; DATASET TO FIND MAPPED SAVE FILES
  MAP            = 'NEC'                                                                                    ; MAP OF SAVE FILES
  MPRODS         = 'SST'                                                                                    ; PRODUCTS TO EXTRACT FROM MAPPED FILES
  MPERIOD        = 'D'                                                                                      ; PERIOD FOR THE SAVE FILE SEARCH
  MLABEL         = 'SST'                                                                                    ; LABEL FOR THE OUTPUT SAVE FILE
  SKIP_FIND_MAP  = 1                                                                                        ; SKIP SEARCHING FOR MAPPED SAV FILES AND COPYING TO DEMO DIRECTORY
  DIR_MAPDATA    = DIR_DEMO + 'SATDATA' + SL + 'SAVE' + SL & DIR_TEST, DIR_MAPDATA                          ; PROJECT DIRECTOY TO COPY THE SAVE FILES TO

  SHIP_FILE      = DIR_DEMO + 'SHIP_DATA.CSV'
  FLAG_BITS      = [0,1,2,3,4,5,8,9,12,14,15,16,25]                                                         ; L2 FLAGS TO APPLY TO THE UNMASKED L2 DATA
  AROUND         = 1                                                                                        ; AROUND = 1 IS 3X3 BOX TO USE WHEN SEARCHING FOR THE SATELLITE DATA
  HOURS          = [3,24]                                                                                   ; TIME DIFFERENCE IN HOURS BETWEEN SHIP AND SATELLITE MATCH-UPS
  SAVE_LABEL     = 'CHLOR_RRS_PAR'                                                                          ; LABEL FOR OUTPUT FILE
  SAT_PRODS      = ['CHLOR_A-PAN','PIGMENTS','PHYTOPLANKTON','DOC','A_CDOM','PPD-VGPM2','PPD-OPAL']         ; NEW SATELLITE PRODUCTS TO GENERATE
  DOC_ALGS       = ['MAB']                                                                                  ; ALGORITHM FOR THE DOC DATA                 
  A_CDOM_ALGS    = 'MLR_A412'                                                                               ; ALGORITHM FOR THE ACDOM DATA
  PRODS_LABEL    = SAVE_LABEL+'-CHLOR_A_PAN_PIGENTS'                                                        ; PRODUCT LABEL FOR THE OUTPUT FILE
  CRUISE_NAME    = 'CLIVEC_2009'                                                                            ; CRUISE NAME FOR THE OUTPUT FILE
  GET_QAA        = 0                                                                                        ; GET THE QAA DATA IN ADDITION TO RRS AND CHLOR_A FROM THE L2 HDF
  GET_GIOP       = 0                                                                                        ; GET THE GIOP DATA IN ADDITION TO RRS AND CHLOR_A FROM THE L2 HDF
  GET_LEE        = 0                                                                                        ; GET THE LEE DATA IN ADDITION TO RRS AND CHLOR_A FROM THE L2 HDF
      
  SHIP  = READALL(SHIP_FILE)                                                                                ; READ SHIP DATA
  IF HAS(SHIP,'DATE') EQ 0 THEN BEGIN
    SHIP = STRUCT_MERGE(REPLICATE(CREATE_STRUCT('DATE',''),N_ELEMENTS(SHIP)),SHIP)                          ; ADD DATE TAG TO SHIP_STRUCT IF IT DOES NOT ALREADY EXIST
    SHIPDATES = SHIP.YEAR + ADD_STR_ZERO(SHIP.MONTH) + ADD_STR_ZERO(SHIP.DAY) + ADD_STR_ZERO(SHIP.HOUR) + ADD_STR_ZERO(SHIP.MINUTE) + ADD_STR_ZERO(SHIP.SECOND)  ; CREATE SHIPDATE (THIS MAY VARY DEPENDING ON INPUT STRUCTURE)
    SHIP.DATE = SHIPDATES                                                                                   ; ADD DATE BACK TO STRUCTURE
    STRUCT_2CSV,SHIP_FILE,SHIP                                                                              ; SAVE FOR LATER USE
  ENDIF ELSE SHIPDATES = SHIP.DATE
  DATERANGE = MINMAX(SHIPDATES)                                                                             ; USE SHIPDATES TO ESTABLISH DATERANGE
  IF MIN(STRLEN(SHIPDATES) NE 14) THEN STOP                                                                 ; CHECK TO MAKE SURE THE SHIPDATES INCLUDE YYYYMMDDHHMMSS
  SHIP_STRUCT = STRUCT_2NUM(SHIP,EXCLUDE=['DATE','GMT_TIME','CRUISE','STATION'])                            ; CONVERT SHIP DATA TO FLOAT
  SHIP_STRUCT = STRUCT_RENAME(SHIP_STRUCT,['LONGITUDE','LATITUDE'],['LON','LAT'])                           ; CHECK TO MAKE SURE COORDINATE TAG NAMES ARE LON AND LAT
  SHIP_ID     = SHIP.YEAR + ADD_STR_ZERO(SHIP.MONTH) + ADD_STR_ZERO(SHIP.DAY) + ADD_STR_ZERO(SHIP.HOUR) + '_' + NUM2STR(SHIP.STATION) + '_' + NUM2STR(SHIP.LAT) + '_' + NUM2STR(SHIP.LON) ; CREATE UNIQUE ID THE REMOVE MULTIPLE ENTRIES PER STATION
  SHIP_STRUCT = SHIP_STRUCT[SORT(SHIP_ID)]                                                                  ; SORT STRUCTURE BASED ON ID
  SHIP_ID     = SHIP_ID[SORT(SHIP_ID)]                                                                      ; SORT ID TO MATCH SORTED STRUCTURE
  SHIP_STRUCT = SHIP_STRUCT[UNIQ(SHIP_ID)]                                                                  ; RETAIN ONLY UNIQ IDS IN SHIP_STRUCT
      
; ===> Find the L2(A) files to look for satship match-ups based on the station data      
  IF SKIP_FIND_HDF EQ 0 THEN BEGIN
    FILES = []
    FOR DTH=0, N_ELEMENTS(DATASETS)-1 DO BEGIN
      DIR_DATASETS = L2_DIRS(DTH)                                    ; DATASET DIRECTORY FOR THE L2 HDF FILES
      FILES = [FILES,FILE_SEARCH(DIR_DATASETS+'S_2009*'+['.hdf','.hdf.bz2','.nc'])]                            ; FIND BOTH .HDF (.NC) AND .BZ2 FILES
    ENDFOR ; FOR DTH = 0, N_ELEMENTS(DATASETS)-1 DO BEGIN     
    
    FILES = FILES[WHERE(FILES NE '')]   
    FILES = FILES[SORT(FILES)]                                                                             ; SORT FILES BY PERIOD
    FILES = DATE_SELECT(FILES,DATERANGE[0],DATERANGE[1])                                                   ; REDUCE FILES BASED ON DATERANGE
    IF FILES EQ [] THEN STOP                                                                               ; NO FILES FOUND
    SATFILES = SATSHIP_GET_FILES(FILES,SHIPDATES=SHIPDATES,SHIP_STRUCT=SHIP_STRUCT,HOURS=24,ERROR=ERROR, ERR_MSG=ERR_MSG)          ; FIND FILES THAT MATCH-UP WITH SHIPDATES
      
; ===> Find the L1(A) files that match the L2 files if needed for SeaDAS processing      
    L1FILES = []
    FOR DTH=0, N_ELEMENTS(DATASETS)-1 DO BEGIN
      L2FILES  = SATFILES[WHERE(VALID_SENSORS(SATFILES) EQ VALID_SENSORS(DATASETS(DTH)))]
      L1DIR    = L1_DIRS(DTH)+DATASETS(DTH)+SL+L1(DTH)+SL
      L1FILES  = [L1FILES,SATSHIP_GET_L1FILES(L2FILES,L1DIR)]
    ENDFOR
    IF L1FILES NE [] THEN WRITE_TXT, DIR_DEMO + 'L1FILES_TO_PROCESS.txt', L1FILES
      
; ===> Unzip files and move to PROJECTS directory (We should keep a copy of the files in the PROJECTS directory so that we know exactly which files were used for the extracts.         
    FP = PARSE_IT(SATFILES)                     ; This is especially important when publishing the data because the files in DATASETS could be replaced in the case of a recent reprocessing.)
    OK = WHERE(STRUPCASE(FP.EXT) EQ 'BZ2',COUNT,COMPLEMENT=COMPLEMENT,NCOMPLEMENT=NCOMPLEMENT)
    IF COUNT       GE 1 THEN ZIPIT, SATFILES[OK], DIR_OUT=DIR_HDFDATA
    IF NCOMPLEMENT GE 1 THEN FILE_COPY, SATFILES(COMPLEMENT), DIR_HDFDATA, /ALLOW_SAME
  ENDIF  
  HDFFILES = FILE_SEARCH(DIR_HDFDATA + ['*.nc','*.hdf'])
  
  ; ===> Find the MAPPED SAVE files to look for satship match-ups based on the station data
  IF SKIP_FIND_MAP EQ 0 THEN BEGIN
    FILES = []
    FOR DTH=0, N_ELEMENTS(MDATASETS)-1 DO BEGIN
      DIR_DATASETS = !S.DATASETS + MDATASETS(DTH) + SL + MAP + SL + 'SAVE' + SL + [MPRODS] + SL            ; DATASET DIRECTORY FOR THE MAPPED SAVE FILES
      FILES = [FILES,FILE_SEARCH(DIR_DATASETS+MPERIOD+'_*.SAV*')]                                                 ; FIND THE .SAV(E) FILES
    ENDFOR ; FOR DTH = 0, N_ELEMENTS(DATASETS)-1 DO BEGIN

    FILES = FILES[WHERE(FILES NE '')]
    FILES = FILES[SORT(FILES)]                                                                             ; SORT FILES BY PERIOD
    FILES = DATE_SELECT(FILES,DATERANGE[0],DATERANGE[1])                                                   ; REDUCE FILES BASED ON DATERANGE
    IF FILES EQ [] THEN STOP                                                                               ; NO FILES FOUND
    SAVEFILES = SATSHIP_GET_FILES(FILES,SHIPDATES=SHIPDATES,HOURS=24,ERROR=ERROR, ERR_MSG=ERR_MSG)         ; FIND FILES THAT MATCH-UP WITH SHIPDATES

    ; ===> Move files to PROJECTS directory (We should keep a copy of the files in the PROJECTS directory so that we know exactly which files were used for the extracts.
    FP = PARSE_IT(SAVEFILES)                ; This is especially important when publishing the data because the files in DATASETS could be replaced in the case of a recent reprocessing.)
    FILE_COPY, SAVEFILES, DIR_MAPDATA, /ALLOW_SAME
  ENDIF
  MAPFILES = FILE_SEARCH(DIR_MAPDATA + '*.SAV*')

; ===> Determine products to search for in the HDF file          
  CPRODS   = ['SOLZ','SENZ','OZONE','NO2_STRAT','NO2_TROPO','ANGSTROM','AOT']                                                                ; ANCILLARY PRODUCTS - JUST GET THE CENTER VALUE
  PRODUCTS = [         'CHLOR_A','PAR','RRS_412','RRS_443','RRS_490','RRS_510','RRS_555','RRS_670']                                          ; SEAWIFS PRODUCTS
  PRODUCTS = [PRODUCTS,'CHLOR_A','PAR','RRS_412','RRS_443','RRS_469','RRS_488','RRS_531','RRS_547','RRS_555','RRS_645','RRS_667','RRS_678']  ; MODIS PRODUCTS
  PRODUCTS = PRODUCTS[SORT(PRODUCTS)]
  PRODUCTS = PRODUCTS[UNIQ(PRODUCTS)]
  IF NONE(SKIP_L2_PRODS) THEN PRODUCTS = [PRODUCTS,'L2_FLAGS']
  IF GET_QAA EQ 1 THEN BEGIN ; Add QAA products to the extraction list
    SUITE  = VALID_SUITES(SENSOR+'_FULL',/PRODUCTS)
    QAA    = WHERE(STRPOS(STRUPCASE(SUITE.SUITE_PRODS),'QAA') GE 0)
    QAA_PRODS = SUITE(QAA).SUITE_PRODS
    POS = STRPOS(QAA_PRODS,'_',/REVERSE_SEARCH)
    FOR P=0,N_ELEMENTS(QAA_PRODS)-1 DO BEGIN
      QAA = QAA_PRODS(P)
      STRPUT, QAA, '-', POS(P)
      QAA_PRODS(P) = QAA
    ENDFOR
    PRODUCTS = [PRODUCTS,QAA_PRODS]
    SAVE_LABEL = SAVE_LABEL + '_QAA'
  ENDIF
  IF GET_GIOP EQ 1 THEN BEGIN ; Add GIOP products to the extraction list
    SUITE  = VALID_SUITES(SENSOR+'_FULL',/PRODUCTS)
    GIOP   = WHERE(STRPOS(STRUPCASE(SUITE.SUITE_PRODS),'GIOP') GE 0)
    GIOP_PRODS = SUITE(GIOP).SUITE_PRODS
    POS = STRPOS(GIOP_PRODS,'_',/REVERSE_SEARCH)
    FOR P=0,N_ELEMENTS(GIOP_PRODS)-1 DO BEGIN
      GIOP = GIOP_PRODS(P)
      STRPUT, GIOP, '-', POS(P)
      GIOP_PRODS(P) = GIOP      
    ENDFOR
    PRODUCTS = [PRODUCTS,GIOP_PRODS]
    SAVE_LABEL = SAVE_LABEL + '_GIOP'
  ENDIF
  IF GET_LEE EQ 1 THEN BEGIN ; Add LEE products to the extraction list
    SUITE  = VALID_SUITES(SENSOR+'_FULL',/PRODUCTS)
    LEE   = WHERE(STRPOS(STRUPCASE(SUITE.SUITE_PRODS),'LEE') GE 0)
    LEE_PRODS = SUITE(LEE).SUITE_PRODS
    POS = STRPOS(LEE_PRODS,'_',/REVERSE_SEARCH)
    FOR P=0,N_ELEMENTS(LEE_PRODS)-1 DO BEGIN
      LEE = LEE_PRODS(P)
      STRPUT, LEE, '-', POS(P)
      LEE_PRODS(P) = LEE      
    ENDFOR
    PRODUCTS = [PRODUCTS,LEE_PRODS]
    SAVE_LABEL = SAVE_LABEL + '_LEE'
  ENDIF

; ===> Extract the CHL and RRS data from the HDF file       
  HDFFILE = DIR_OUT+'SATSHIP_HDF-'+CRUISE_NAME+'-'+SAVE_LABEL+'.SAV'
  CSVFILE = DIR_OUT+'SATSHIP_HDF-'+CRUISE_NAME+'-'+SAVE_LABEL+'.CSV'
  IF FILE_MAKE([SHIP_FILE,HDFFILES],[HDFFILE,CSVFILE],OVERWRITE=OVERWRITE) EQ 0 THEN GOTO, SKIP_SATSHIP_HDF      
  SATSHIP = SATSHIP_L2(SHIP_STRUCT=SHIP_STRUCT,SAT_FILES=HDFFILES(0:10),AROUND=AROUND,HOURS=MAX(HOURS),FLAG_BITS=FLAG_BITS,PRODS=PRODUCTS,CPRODS=CPRODS)
  SAVE, FILENAME=HDFFILE, SATSHIP
  SATSHIP_2CSV, HDFFILE   ; Converts the complex structure to a format that can be saved as a .csv using STRJOIN
  SKIP_SATSHIP_HDF:
  
; ===> Extract SST from mapped SAV files and add to the CHL/RRS file
  MAPFILE = DIR_OUT+'SATSHIP_MAP-'+CRUISE_NAME+'-'+MLABEL+'.SAV'
  CSVFILE = DIR_OUT+'SATSHIP_MAP-'+CRUISE_NAME+'-'+MLABEL+'.CSV'
  IF FILE_MAKE([SHIP_FILE,MAPFILES],[MAPFILE,CSVFILE],OVERWRITE=OVERWRITE) EQ 0 THEN GOTO, SKIP_SATSHIP_MAP
  SATSHIP = SATSHIP_MAP(SHIP_STRUCT=SHIP_STRUCT,SAT_FILES=MAPFILES,AROUND=AROUND,HOURS=12)  
  SAVE, FILENAME=MAPFILE, SATSHIP
  SATSHIP_2CSV, MAPFILE
  SKIP_SATSHIP_MAP:
  
; ===> Merge data from HDF and MAP files
  SAVEFILE = DIR_OUT + 'SATSHIP_MERGE-'+CRUISE_NAME+'-'+SAVE_LABEL+'-'+MLABEL+'.SAV'
  CSVFILE  = DIR_OUT + 'SATSHIP_MERGE-'+CRUISE_NAME+'-'+SAVE_LABEL+'-'+MLABEL+'.CSV'
  IF FILE_MAKE([HDFFILE,MAPFILE],[SAVEFILE,CSVFILE],OVERWRITE=OVERWRITE) EQ 0 THEN GOTO, SKIP_SATSHIP_MERGE
  SATSHIP = SATSHIP_MERGE(HDFFILE=HDFFILE,MAPFILE=MAPFILE)
  SAVE, FILENAME=SAVEFILE, SATSHIP
  SATSHIP_2CSV, SAVEFILE
  SKIP_SATSHIP_MERGE:
      
; ===> Create new products from the extracted RRS data and add ship data   
  PRODFILE = DIR_OUT+CRUISE_NAME+'-'+PRODS_LABEL+'.SAV'
  CSVFILE  = DIR_OUT+CRUISE_NAME+'-'+PRODS_LABEL+'.CSV'
  IF FILE_MAKE(SAVEFILE,[PRODFILE,CSVFILE],OVERWRITE=OVERWRITE) EQ 0 THEN GOTO, SKIP_SATSHIP_PROD  
  SATPROD = SATSHIP_PROD(SATFILE=SAVEFILE, SATPRODS=SAT_PRODS,DOC_ALGS=DOC_ALGS,A_CDOM_ALGS=A_CDOM_ALGS,KEEP_BITS=KEEP_BITS,KEEP_FLAGS=KEEP_FLAGS) ; Return a single structure, a structure for each prod or loop on prods and create one file for each prod that can later be concatenated????   
  SAVE, FILENAME=PRODFILE, SATPROD
  SATSHIP_2CSV, PRODFILE   ; Converts the complex structure to a format that can be saved as a .csv using STRJOIN
  SKIP_SATSHIP_PROD: 
      
; ===> Match-up SHIP data and create STAT files for the prods
  SATPRODS  = ['CHLOR_A','CHLOR_A_PAN','DOC_MAB']
  SHIPPRODS = ['CHLOR_A','CHLOR_A',    'DOC']
  ANCPRODS  = ['SOLZ','SENZ','AOT_865','ANGSTROME','OZONE','NO2_TROPO','NO2_STRAT']
  MATCHFILE = DIR_OUT+CRUISE_NAME+'-'+PRODS_LABEL+'-MATCHUPS.SAV'
  CSVFILES  = DIR_OUT+CRUISE_NAME+'-'+PRODS_LABEL+'-MATCHUPS-'+SATPRODS+'.CSV'
  IF FILE_MAKE([PRODFILE,SHIP_FILE],[MATCHFILE,CSVFILES],OVERWRITE=OVERWRITE) EQ 0 THEN GOTO, SKIP_SATSHIP_MATCHUP
  SATSTATS = SATSHIP_MATCHUP(SATFILE=PRODFILE,SATPRODS=SATPRODS,SHIPFILE=SHIP_FILE,SHIPPRODS=SHIPPRODS,ANCPRODS=ANCPRODS,ERROR=ERROR,ERR_MSG=ERR_MSG)
  SAVE, FILENAME=MATCHFILE, SATSTATS
  SATSHIP_MATCHUP_2CSV, MATCHFILE
  SKIP_SATSHIP_MATCHUP:
           
; ===> Make individual SATSHIP plots
  BUFFER    = 1
  SATPRODS  = ['CHLOR_A','CHLOR_A_PAN','DOC_MAB']
  TITLEPROD = ['CHLOR_A','CHLOR_A-PAN','DOC-MAB']
  LOGLOG    = [1,1,0]
  GMEAN     = [1,1,0]
  FMEAN     = [0,0,1]
  TIME_DIF  = [3,6,12]
  FOR T=0, N_ELEMENTS(TIME_DIF)-1 DO BEGIN
    PLTFILES  = DIR_OUT+CRUISE_NAME+'-'+PRODS_LABEL+'-MATCHUPS-'+SATPRODS+'-'+NUM2STR(TIME_DIF(T))+'HR.PNG'
    TITLE = 'TIME DIFFERENCE = ' + NUM2STR(TIME_DIF(T)) + ' HOURS'
    FOR N=0, N_ELEMENTS(SATPRODS)-1 DO BEGIN
      IF FILE_MAKE(MATCHFILE,PLTFILES(N),OVERWRITE=OVERWRITE) EQ 0 THEN CONTINUE
      SATPLOTS = SATSHIP_PLOT(SATPRODS(N), MATCHFILE, TIME_DIF=TIME_DIF(T), TITLE=TITLE, PROD_TITLE=TITLEPROD(N), USE_GMEAN=GMEAN(N), USE_FILTER_MEAN=FMEAN(N), CURRENT=CURRENT, BUFFER=BUFFER, LAYOUT=LAYOUT, POS=POS, COLORS=COLORS, SENSORS=SENSORS, BKGR=BKGR, LOGLOG=LOGLOG(N), EXTRA=EXTRA)  
      IF BUFFER EQ 0 THEN WAIT, 5
      SATPLOTS.SAVE, PLTFILES(N)
      SATPLOTS.CLOSE
    ENDFOR
  ENDFOR  

; ===> Make a composite SATSHIP plot   
  PLTFILE  = DIR_OUT+CRUISE_NAME+'-'+PRODS_LABEL+'-MATCHUPS-'+STRJOIN(SATPRODS,'_')+'-COMPOSITE.PNG'
  IF FILE_MAKE(MATCHFILE,PLTFILE,OVERWRITE=OVERWRITE) EQ 0 THEN GOTO, SKIP_SATSHIP_COMPOSITE
  W = WINDOW(DIMENSIONS=[900,900])
  CURRENT = 1
  BUFFER = 0
  COUNTER = 1
  NO_STATS = 1
  NO_LEG = 1
  FOR N=0, N_ELEMENTS(SATPRODS)-1 DO BEGIN
    FOR T=0, N_ELEMENTS(TIME_DIF)-1 DO BEGIN
      TITLE = 'TIME DIFFERENCE = ' + NUM2STR(TIME_DIF(T)) + ' HOURS'      
      LAYOUT = [3,3,COUNTER]      
      SATPLOTS = SATSHIP_PLOT(SATPRODS(N), MATCHFILE, PLTSTATS=PLTSTATS, TIME_DIF=TIME_DIF(T), TITLE=TITLE, PROD_TITLE=TITLEPROD(N), USE_GMEAN=GMEAN(N), USE_FILTER_MEAN=FMEAN(N), $
                 CURRENT=CURRENT, BUFFER=BUFFER, LAYOUT=LAYOUT, COLORS=COLORS, SENSORS=SENSORS, BKGR=BKGR, LOGLOG=LOGLOG(N), NO_STATS=NO_STATS, NO_LEG=NO_LEG, MARGIN=[0.22,0.22,0.1,0.1])
      SAT_POS = SATPLOTS.POSITION
      POS = [SAT_POS[0]+0.01,SAT_POS(3)-0.08]
      TT = TEXT(POS[0],POS[1],PLTSTATS.ALLDATA.STATSTRING,COLOR='BLACK',FONT_SIZE=8,BUFFER=BUFFER,/RELATIVE,ALIGNMENT=0,/CURRENT)
      COUNTER = COUNTER + 1
    ENDFOR
  ENDFOR
  W.SAVE, PLTFILE
  W.CLOSE
  SKIP_SATSHIP_COMPOSITE:

END; #####################  End of Routine ################################


