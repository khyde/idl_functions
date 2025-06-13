; $ID:	PLOT_FILELIST.PRO,	2023-09-21-13,	USER-KJWH	$

  PRO PLOT_FILELIST, DATASETS, TYPES=TYPES, LEVELS=LEVELS, FOLDERS=FOLDERS, SKIP=SKIP, DATERANGE=DATERANGE, DIR_OUT=DIR_OUT, PLT_FILES=PLT_FILES, TXT_FILES=TXT_FILES, $
                     LOGLUN=LOGLUN, BUFFER=BUFFER, VERBOSE=VERBOSE, OVERWRITE=OVERWRITE

;+
; NAME:
;   PLOT_FILELIST
;
; PURPOSE:
;   This procedure plots the number of files in a given directory (parsed by period for STATS and ANOMS folders)
;
; CATEGORY:
;   Files/Plotting
;
; CALLING SEQUENCE:
;   PLOT_FILELIST, DATASET, TYPE=TYPE, PERIOD=PERIOD, PROD=PROD, DATERANGE=DATERANGE, OVERWRITE=OVERWRITE
;
; REQIORED INPUTS:
;   None
;
; OPTIONAL INPUTS:
;   DATASETS........ Dataset (MODISA, VIIRS, AVHRR, etc.) names
;   TYPES........... Data type (OC, FRONTS, PP, SST) directories
;   LEVELS.......... Data level (L1A, L2, etc) directories   
;   FOLDERS......... The valid folder names to search for in the directories
;   SKIP............ Folder names to skip 
;   DATERANGE....... Date range for the files and plots
;   DIR_OUT......... The output directory
;   LOGLUN.......... If provided, the LUN for the log file
;
; KEYWORD PARAMETERS:
;   BUFFER.......... To set the BUFFER for the plots
;   VERBOSE......... To print information
;   OVERWRITE....... To overwrite existing plots
;
; OUTPUTS:
;   PNG files in the output directory
;
; OPTIONAL OUTPUTS:
;   PLT_FILES..... An array of new and updated files created
;   TXT_FILES..... An array of any txt files containing lists of new files
; 
; EXAMPLE:
;   PLOT_FILELIST, 'OCCCI'
;
; NOTES:
;
;   
; COPYRIGHT: 
; Copyright (C) 2018, Department of Commerce, National Oceanic and Atmospheric Administration, National Marine Fisheries Service,
;   Northeast Fisheries Science Center, Narragansett Laboratory.
;   This software may be used, copied, or redistributed as long as it is not sold and this copyright notice is reproduced on each copy made.
;   This routine is provided AS IS without any express or implied warranties whatsoever.
;
;   This program was written by Kimberly Hyde, DOC/NOAA/NMFS/NEFSC Narragansett, RI, kimberly.hyde@noaa.gov
;   
;
; MODIFICATION HISTORY:
;	  Nov 12, 2019 - KJWH: Initial code written 
;		Dec 03, 2019 - KJWH: Continued developing and testing the code
;		                     Added the ability to output a list of new/update files (NEW_FILES)
;		Dec 11, 2019 - KJWH: Now also creating a list of files saved as a CSV and returning a list of new data files (TXT_FILES)                     
;                        Changed NEW_FILES to PLT_FILES
;                        Added LOGLUN keyword, changed PRINT to PLUN, LOG_LUN, and added LOGLUN to POF, PFILE commands
;   May 15, 2020 - KJWH: Added /YY_YEAR to the initial DATE_AXIS call to change from a 4 digit year to a 2 digit year
;                        Changed the XMINOR tickmarks to 3
;                        Changed the THICKness of the plotline from 1 to 3 to make the line stand out better when they overlay on the axis lines
;   Sep 08, 2020 - KJWH: Added COMPILE_OPT IDL2
;                        Updated documentation
;                        Changed subscript () to []
;                        Replicated the COLORS 
;                        Added ANOMS to the FOLDERS list
;-
;	****************************************************************************************************
	ROUTINE_NAME = 'PLOT_FILELIST'
  COMPILE_OPT IDL2
  SL = PATH_SEP()
  
	IF NONE(DATASETS)  THEN DATASETS  = ['SEAWIFS','MODISA','MODIST','VIIRS','JPSS1','AVHRR','MUR','OCCCI','SA','SAV','SAVJ'] 
	IF NONE(TYPES)     THEN TYPES     = ['OC','SST','PP','FRONTS']                                          
	IF NONE(LEVELS)    THEN LEVELS    = ['L1','L1A','L2','L3B2','L3B4','L3B9','L4','SIN']                   
	IF NONE(FOLDERS)   THEN FOLDERS   = ['STATS','NC','SAVE','INTERP_SAVE','ANOMS']                                 
	IF NONE(SKIP)      THEN SKIP      = ['LOG','LOGS','ADD_IFILE']
	IF ANY(DATERANGE)  THEN DTR       = DATERANGE ELSE DTR = ['19780101','21001231']
	IF NONE(LOGLUN)    THEN LOG_LUN   = [] ELSE LOG_LUN = LOGLUN
	IF NONE(BUFFER)    THEN BUFFER    = 1
	IF NONE(OVERWRITE) THEN OVERWRITE = 0
	
  PDIR = !S.LOGS + 'SENSOR_DATE_PLOTS' + SL 

; ===> Get a list of current plots and mtimes 
  CDIRS = FILE_SEARCH(PDIR+[TYPES]+SL+'*',/TEST_DIRECTORY,/MARK_DIRECTORY,COUNT=COUNTO)
  CFILES = []
  FOR F=0, N_ELEMENTS(CDIRS)-1 DO CFILES = [CFILES,FILE_SEARCH(CDIRS[F] + '*.png',COUNT=COUNTC)]
  CFILES = CFILES[WHERE(CFILES NE '')]
  CTIMES = GET_MTIME(CFILES)
  TXT_FILES = []
	
	COLORS = ['RED','BLUE','ORANGE','CYAN','NAVY','LIME','YELLOW','MAGENTA','LIGHT_BLUE','DARK_VIOLET','LIGHT_SEA_GREEN','CORAL','DARK_CYAN','INDIGO','FIREBRICK','PALE_GREEN','CORNFLOWER','DARK_MAGENTA','ORANGE_RED','SLATE_BLUE','DEEP_PINK']
	FOR T=0, N_ELEMENTS(TYPES)-1 DO BEGIN
	  TYPE = TYPES[T]
	  
  	FOR N=0, N_ELEMENTS(DATASETS)-1 DO BEGIN
  	  DATASET = DATASETS[N]
  	  PLUN, LOG_LUN, '***************************************************************************'
  	  PLUN, LOG_LUN, 'Checking ' + DATASET + ' for new files',0
  	  PLTDIR = PDIR + TYPE + SL + DATASET + SL   & DIR_TEST, PLTDIR
  	  
  	  SDATES = SENSOR_DATES(DATASET)                                                      ; Get the SENSOR daterange
  	  IF DTR[0] LT SDATES[0] THEN DTR[0] = SDATES[0]                                      ; If default start date (19810101), then change to the sensor start date
  	  IF DTR[1] GT SDATES[1] THEN DTR[1] = SDATES[1]                                      ; If default end date (21001231), then change to the sensor end date
  	  AX = DATE_AXIS([SDATES[0],SDATES[1]],/MONTH,/YY_YEAR,STEP_SIZE=6)
  	  
  	  FOR L=0, N_ELEMENTS(LEVELS)-1 DO BEGIN
  	    LEVEL = LEVELS[L]
  	    DIR = !S.DATASETS + TYPE + SL + DATASET + SL + LEVEL + SL 
  	    SDIRS = FILE_SEARCH(DIR+'*',/TEST_DIRECTORY,/MARK_DIRECTORY)
  	    
  	    FOR S=0, N_ELEMENTS(SDIRS)-1 DO BEGIN
      	  ADIR = SDIRS[S]
      	  FP = FILE_PARSE(ADIR)
          OK = WHERE(FOLDERS EQ FP.SUB,COUNT)
          IF COUNT EQ 0 THEN CONTINUE
          
          ODIRS = ADIR
          ODIRS = [ODIRS,FILE_SEARCH(ADIR+'*',/TEST_DIRECTORY,/MARK_DIRECTORY,COUNT=COUNTO)]
          ODIRS = ODIRS[WHERE(ODIRS NE '',/NULL)] & IF ODIRS EQ [] THEN CONTINUE
          
      	  CASE LEVEL OF
      	   'L1A': EXTS = ['bz2','nc']
      	   'L2':  EXTS = ['L2_SUB_OC','L2_LAC_SUB_OC','L2_MLAC_OC','L2_OC_SUB']
      	   ELSE:  EXTS = ['SAV','nc','bz2','LAC']
      	  ENDCASE
      	  
      	  CASE LEVEL OF
      	    'L1':  SRANGE=[0,5]
      	    'L1A': SRANGE=[0,10]
      	    'L2':  SRANGE=[0,10]
      	    'L3B2':SRANGE=[0,3]
      	    'L3B4':SRANGE=[0:8]
      	    'L3B9':SRANGE=[0:8]
      	    'SIN': SRANGE=[0:3]
      	    'L4':  SRANGE=[0,3]
      	  ENDCASE

      	  W = []
      	  FT = []
      	  RDIRS = []
      	  FOR F=0, N_ELEMENTS(ODIRS)-1 DO BEGIN
      	    FT = [FT,FILE_SEARCH(ODIRS[F] + '*.' + EXTS + '*',COUNT=COUNTP)]
      	    IF COUNTP EQ 0 THEN RDIRS = [RDIRS,F]
      	  ENDFOR
      	  FT = FT[WHERE(FT NE '',/NULL)]
      	  IF FT EQ [] THEN CONTINUE
      	  IF RDIRS NE [] THEN ODIRS = REMOVE(ODIRS,RDIRS)  
      	  
      	  PNGFILE = PLTDIR + STRJOIN([DATASET,LEVEL,FP.SUB],'-') + '.png'
      	  CSVFILE = PLTDIR + STRJOIN([DATASET,LEVEL,FP.SUB],'-') + '.csv'
      	  TXTFILE = PLTDIR + STRJOIN([DATASET,LEVEL,FP.SUB],'-') + '-NEW_FILES.txt'

          IF FILE_MAKE(FT,[CSVFILE,PNGFILE],OVERWRITE=OVERWRITE) EQ 0 THEN CONTINUE

      	  STR = REPLICATE(CREATE_STRUCT('FILE','','MTIME',0L),N_ELEMENTS(FT))
      	  STR.FILE = FT
      	  STR.MTIME = GET_MTIME(FT)
      	  IF EXISTS(CSVFILE) THEN BEGIN
      	    FLIST = CSV_READ(CSVFILE)
      	    OK = WHERE_MATCH(FT,FLIST.FILE,COUNT,VALID=VALID,COMPLEMENT=COMPLEMENT,NCOMPLEMENT=NCOMPLEMENT)
      	    IF NCOMPLEMENT GT 0 THEN BEGIN
      	      NEWFILES = FT[COMPLEMENT]
      	      TXT = '### ' + NUM2STR(NCOMPLEMENT) + ' New files for ' + STRJOIN([DATASET,LEVEL,FP.SUB],'-') + ' observed on ' + DATE_NOW(/DATE_ONLY) + ' ###'
      	      TXT = [TXT,NEWFILES]
      	      FOR T=0, N_ELEMENTS(TXT)-1 DO PLUN, LOG_LUN, TXT[T],0
      	      PFILE, NEWFILE, /W, LOGLUN=LOG_LUN 
      	      WRITE_TXT, TXTFILE, TXT
      	      TXT_FILES = [TXT_FILES,TXTFILE]
      	    ENDIF
      	  ENDIF
      	  PFILE, CSVFILE, /W, LOGLUN=LOG_LUN
      	  STRUCT_2CSV, CSVFILE, STR
      	  
      	  IF FILE_MAKE(FT,PNGFILE,OVERWRITE=OVERWRITE) EQ 0 THEN CONTINUE
      	  FOR O=0, N_ELEMENTS(ODIRS)-1 DO BEGIN
      	    ODIR = ODIRS[O]
      	    FO = FILE_PARSE(ODIR)
      	    IF WHERE(SKIP EQ FO.SUB) GE 0 THEN CONTINUE
      	    
      	    IF KEY(VERBOSE) THEN PLUN, LOG_LUN, 'Searching for files in ' + ODIR
      	    FILES = FLS(ODIR + '*.' + EXTS + '*',COUNT=COUNTP)
            TITLE = REPLACE(REMOVE_LAST_SLASH(ODIR),['/nadata/DATASETS/','/'],['','-']) + ' (N = ' + NUM2STR(COUNTP) + ')
            
      	    
      	    IF FP[0].SUB EQ 'STATS' OR FP[0].SUB EQ 'ANOMS' THEN BEGIN
              FF = PARSE_IT(FILES)                                            ; Parse file names to get date info
        	    PSET = WHERE_SETS(FF.PERIOD_CODE)
              PSET = PSET[WHERE(PSET.N GT 1)]
              PSET = PSET[WHERE(PSET.VALUE NE 'ANNUAL' AND PSET.VALUE NE 'MANNUAL',/NULL)]
              IF PSET EQ [] THEN CONTINUE
              PNGFILE = PLTDIR + STRJOIN([DATASET,LEVEL,FP[0].SUB,FF[0].SUB],'-') + '.png'
              IF FILE_MAKE(FILES,PNGFILE,OVERWRITE=OVERWRITE) EQ 0 THEN CONTINUE ; If no new files, then continue to next set
                      
              IF W EQ [] THEN W = WINDOW(DIMENSIONS=[1000,200*N_ELEMENTS(PSET)],BUFFER=BUFFER)
        	    FOR C=0, N_ELEMENTS(PSET)-1 DO BEGIN
        	      SET = WHERE_SETS_SUBS(PSET[C])
        	      TITLE = '"'+PSET[C].VALUE +'" '+ REPLACE(REMOVE_LAST_SLASH(ODIR),['/nadata/DATASETS/','/'],['','-']) + ' (N = ' + NUM2STR(COUNTP) + ')
        	      FLS = FILES[SET]
        	      FPS = PARSE_IT(FLS)
        	      
        	      IF PSET[C].VALUE EQ 'S' OR PSET[C].VALUE EQ 'D' THEN BEGIN
        	        DR = CREATE_DATE(MIN(FPS.DATE_START),MAX(FPS.DATE_END),/DOY)
        	        BSET = WHERE_SETS(FPS.YEAR_START+DATE_2DOY(FPS.DATE_START,/PAD))   ; Determine the number of files per day
        	      ENDIF ELSE BEGIN
        	        DR = CREATE_DATE(MIN(FPS.DATE_START),MAX(FPS.DATE_END))
        	        BSET = WHERE_SETS(PERIOD_2DATE(FPS.PERIOD))
        	      ENDELSE
        	      
        	      SYMSIZE = 0.2
        	      CASE PSET[C].VALUE OF
        	       'A':     BEGIN & SRANGE=[0,2] & AX = DATE_AXIS([SDATES[0],SDATES[1]],/YEAR) & SYMSIZE=1 & END
        	       'DOY':   BEGIN & SRANGE=[0,2] & AX = DATE_AXIS([SDATES[0],SDATES[1]],/FYEAR) & SYMSIZE = 0.3 & END
        	       'M':     BEGIN & SRANGE=[0,2] & AX = DATE_AXIS([SDATES[0],SDATES[1]],/MONTH,STEP_SIZE=6) & SYMSIZE=0.5 & END
        	       'MONTH': BEGIN & SRANGE=[0,2] & AX = DATE_AXIS([SDATES[0],SDATES[1]],/FYEAR) & SYMSIZE = 1 & END
        	       'W':     BEGIN & SRANGE=[0,2] & AX = DATE_AXIS([SDATES[0],SDATES[1]],/MONTH,STEP_SIZE=6) & END
        	       'WEEK':  BEGIN & SRANGE=[0,2] & AX = DATE_AXIS([SDATES[0],SDATES[1]],/FYEAR) & SYMSIZE = 0.5 & END
        	       ELSE: AX = DATE_AXIS([SDATES[0],SDATES[1]],/MONTH,STEP_SIZE=6)
        	      ENDCASE
        	      
        	      ARR = REPLICATE(0,N_ELEMENTS(DR))
        	      OK = WHERE_MATCH(BSET.VALUE,DR,VALID=VALID,COUNT)
        	      IF COUNT LT 1 THEN CONTINUE
        	      ARR = BSET[OK].N
        	      DR = DR[VALID]
        	      PLT = PLOT(AX.JD,SRANGE,/NODATA,XTICKNAME=AX.TICKNAME, XTICKVALUE=AX.TICKV, XMINOR=3,LAYOUT=[1,N_ELEMENTS(PSET),C+1], /CURRENT,XRANGE=AX.JD,YRANGE=SRANGE,TITLE=TITLE,MARGIN=[0.05,0.15,0.025,0.2])
        	      IF N_ELEMENTS(ARR) EQ 1 THEN SYM = SYMBOL(DATE_2JD(DR),ARR,'CIRCLE',SYM_COLOR=COLORS[C],/DATA,SYM_SIZE=SYMSIZE) ELSE $
        	      PLT = PLOT(DATE_2JD(DR),ARR,/CURRENT,/OVERPLOT,CLIP=0,SYMBOL='CIRCLE',COLOR=COLORS[C],SYM_COLOR=COLORS[C],THICK=3,SYM_SIZE=SYMSIZE)
        	    ENDFOR ; PSET (Number of periods)
        	    W.SAVE, PNGFILE
        	    W.CLOSE
        	    PFILE, PNGFILE, /W, LOGLUN=LOG_LUN
        	    CONTINUE
        	  ENDIF  
        	  
        	  IF W EQ [] THEN W = WINDOW(DIMENSIONS=[1000,200*N_ELEMENTS(ODIRS)],BUFFER=BUFFER)
      	    PLT = PLOT(AX.JD,SRANGE,/NODATA,XTICKNAME=AX.TICKNAME, XTICKVALUE=AX.TICKV, XMINOR=3,LAYOUT=[1,N_ELEMENTS(ODIRS),O+1], /CURRENT,XRANGE=AX.JD,YRANGE=SRANGE,TITLE=TITLE,MARGIN=[0.05,0.15,0.025,0.2])

        	  IF COUNTP GE 1 THEN BEGIN
        	    IF KEY(VERBOSE) THEN PLUN, LOG_LUN, NUM2STR(COUNTP) + ' files in ' + ODIR
        	    FP = PARSE_IT(FILES)                                            ; Parse file names to get date info
        	    DR = CREATE_DATE(MIN(FP.DATE_START),MAX(FP.DATE_END),/DOY)
        	    BSET = WHERE_SETS(FP.YEAR_START+DATE_2DOY(FP.DATE_START,/PAD))   ; Determine the number of files per day
        	    ARR = REPLICATE(0,N_ELEMENTS(DR))
        	    OK = WHERE_MATCH(BSET.VALUE,DR,VALID=VALID)
        	    ARR[VALID] = BSET[OK].N
        	    PLT = PLOT(YDOY_2JD(STRMID(DR,0,4),STRMID(DR,4,3)),ARR,/CURRENT,/OVERPLOT,CLIP=0,SYMBOL='CIRCLE',COLOR=COLORS[O],SYM_COLOR=COLORS[O],THICK=3,SYM_SIZE=0.1)  
        	  ENDIF ; COUNTP
        	ENDFOR ; ODIRS
      	     	
          IF W NE [] THEN BEGIN
            W.SAVE, PNGFILE 
            W.CLOSE  
            PFILE, PNGFILE, /W, LOGLUN=LOG_LUn
          ENDIF  
        	  
      	ENDFOR ; LEVEL
      ENDFOR ; DIR
    ENDFOR ; DATASET  
  ENDFOR ; TYPE
  
  ; ===> Get a list of current plots and mtimes
  NDIRS = FILE_SEARCH(PDIR+[TYPES]+SL+'*',/TEST_DIRECTORY,/MARK_DIRECTORY,COUNT=COUNTO)
  NFILES = []
  FOR F=0, N_ELEMENTS(NDIRS)-1 DO NFILES = [NFILES,FILE_SEARCH(NDIRS[F] + '*.png',COUNT=COUNTN)]
  NFILES = NFILES[WHERE(NFILES NE '')]
  NTIMES = GET_MTIME(NFILES)
	
	STR = REPLICATE(STRUCT_2MISSINGS(CREATE_STRUCT('NEW_FILES','','NEW_MTIMES',0L,'OLD_FILES','','OLD_MTIMES',0L)),N_ELEMENTS(NFILES))
	STR.NEW_FILES = NFILES
	STR.NEW_MTIMES = NTIMES
	OK = WHERE_MATCH(NFILES,CFILES,COUNT,VALID=VALID,COMPLEMENT=COMPLEMENT,NCOMPLEMENT=NCOMPLEMENT)
	STR[OK].OLD_FILES = CFILES[VALID]
	STR[OK].OLD_MTIMES = CTIMES[VALID]
	
	IF NCOMPLEMENT GT 0 THEN PLT_FILES = NFILES[COMPLEMENT] ELSE PLT_FILES = []
	OK = WHERE(STR.NEW_MTIMES GT STR.OLD_MTIMES AND STR.OLD_MTIMES NE MISSINGS(STR.OLD_MTIMES),COUNT)
	IF COUNT GT 0 THEN PLT_FILES = [PLT_FILES,NFILES[OK]]
	
	IF KEY(VERBOSE) AND PLT_FILES NE [] THEN FOR T=0, N_ELEMENTS(PLT_FILES)-1 DO PLUN, LOG_LUN, PLT_FILES[T],0
	


END; #####################  End of Routine ################################
