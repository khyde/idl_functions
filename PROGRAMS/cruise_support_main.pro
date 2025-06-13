; $ID:	CRUISE_SUPPORT_MAIN.PRO,	2021-04-15-17,	USER-KJWH	$

  PRO CRUISE_SUPPORT_MAIN, DATE, CRUISE_NAME=CRUISE_NAME, TEST=TEST, ERROR_LOG=ERROR_LOG

;+
; NAME:
;   ORPHANIDES_MAIN
;
; PURPOSE:
;   This MAIN procedure creates operational files (netcdf's, pngs, composites) to support research cruise efforts
;
; CATEGORY:
;   MAIN
;
; CALLING SEQUENCE:
;
; INPUTS:
;  
;
; OPTIONAL INPUTS:
;  
;
; KEYWORD PARAMETERS:
;   
;
; OUTPUTS:
;   This procedures outputs stats files, netcdfs, and png composites to a designated directory
;
; OPTIONAL OUTPUTS:
;   
; PROCEDURE:
;
; EXAMPLE:
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
;   This program was written by Kimberly Hyde, DOC/NOAA/NMFS/NEFSC Narragansett, RI, kimberly.hyde@noaa.gov with input from Chris Orphanides
;          
; 
;
; MODIFICATION HISTORY:
;			Written:  April 05, 2019 by K.J.W. Hyde, NOAA/NEFSC/Narragansett Laboratory, 28 Tarzwell Drive, 02882 (kimberly.hyde@noaa.gov)
;			Modified: Apr 08, 2019 - KJWH: 
;-
;	****************************************************************************************************
	ROUTINE_NAME = 'CRUISE_SUPPORT_MAIN'
	SL = PATH_SEP()
	DP = DATE_PARSE(DATE_NOW()) & DOW = STRUPCASE(DP.DOW) & MON = STRUPCASE(DP.MON) & DAY = DP.DAY
	IF NONE(DATE) THEN DATE = STRMID(DATE_NOW(),0,8) ELSE DATE = NUM2STR(DATE)
	
	IF NONE(CRUISE_NAME) THEN CRUISE_NAME = 'CO_2019'
	FOR CR=0, N_ELEMENTS(CRUISE_NAME)-1 DO BEGIN ; Loop through the various cruises
	  CRUISE = CRUISE_NAME(CR)
	  CASE CRUISE OF
	    'CO_2019': BEGIN
	      NAME = 'Orphanides April 2019 right whale survey'
	      VERSION = 'V2019'
	      DATERANGE = ['20190410','20190430']
	      NC_MAP = 'SNEGRID'
	      CP_MAP = 'MAB_GS'
	      DW_SENSORS = ['OC-MODISA-1KM','OC-VIIRS-1KM'];,'SST-MODISA-1KM','SST-MODIST-1KM','SST-MUR-1KM']
	      L2_SENSORS = ['MODISA','VIIRS']
	      BIN_SENSORS = ['MODISA','SMODISA','SMODIST','VIIRS']
	      STAT_SENSOR = 'SAV'
	      ADDRESSES = 'chris.orphanides@noaa.gov'
	      IF DP.HOUR GT '01' AND DP.HOUR LE '12' THEN L1A_DWLD = ''  ELSE L1A_DWLD = '' ; Don't run DOWNLOAD step in subsequent calls after 1 AM
	      IF DP.HOUR GT '02' AND DP.HOUR LE '12' THEN L2GEN    = ''  ELSE L2GEN    = 'Y' ; Don't run L2GEN step in subsequent calls after 2 AM
	      IF DP.HOUR GT '03' AND DP.HOUR LE '12' THEN L2BIN    = ''  ELSE L2BIN    = 'Y' ; Don't run L2BIN step in subsequent calls after 3 AM
	      IF DP.HOUR GT '04' AND DP.HOUR LE '12' THEN DO_STATS = ''  ELSE DO_STATS = 'Y' ; Don't run STATS step in subsequent calls after 4 AM
	      IF DP.HOUR GT '05' AND DP.HOUR LE '12' THEN NETCDFS  = ''  ELSE NETCDFS  = 'Y' ; Don't run NETCDF step in subsequent calls after 5 AM
	      IF DP.HOUR GT '06' AND DP.HOUR LE '12' THEN COMP     = ''  ELSE COMP     = '' ; Don't run COMPOSITION step in subsequent calls after 6 AM
	      IF DP.HOUR GE '01' AND DP.HOUR LE '12' THEN EMAIL    = 'Y' ELSE EMAIL    = ''  ; Don't email after the 11 PM run
	      DIR = !S.PROJECTS + 'ORPHANIDES' + SL + 'CRUISE_2019' + SL
	      
	      GET_ANC = 1
	      IF NONE(TEST) THEN TEST = 1
	      IF KEY(TEST) THEN BEGIN
	        L2_SENSORS = ['VIIRS','MODISA'] 
	        GET_ANC = 0
	        DATERANGE = ['20190410','20190430']
	        L1A_DWLD = 'Y' 
	        L2GEN    = 'Y' 
	        L2BIN    = 'Y' 
	        DO_STATS = 'Y' 
	        NETCDFS  = 'Y' 
	        COMP     = 'Y' 
	        EMAIL    = 'Y' 
	      ENDIF
	      
	    END
	  ENDCASE  
	
	  DIR_LOGS      = DIR + 'LOGS'      + SL
	  DIR_L1A       = DIR + 'L1A'       + SL
	  DIR_STATS     = DIR + 'STATS'     + SL
	  DIR_PNGS      = DIR + 'PNGS'      + SL
	  DIR_NETCDF    = DIR + 'NETCDF'    + SL
	  DIR_COMP      = DIR + 'COMPOSITE' + SL
	  DIR_ZIP       = DIR + 'ZIP'       + SL
	  DIR_EMAIL     = DIR + 'EMAIL'     + SL
	  DIR_TEST, [DIR_LOGS,DIR_STATS,DIR_PNGS,DIR_NETCDF,DIR_COMP,DIR_ZIP,DIR_EMAIL,DIR_L1A]
		
		
  	LOG_FILE = DIR_LOGS + 'cruise_support_main_log-'    + DATE  + '.log'
  	LOG_TEXT = DIR_LOGS + 'cruise_support_main_log-'    + DATE  + '.txt'
  	ERR_TEST = DIR_LOGS + 'cruise_support_main_errors-' + DATE  + '.txt'
  	EFILE    = DIR_EMAIL + 'EMAIL_SENT_' + DATE_NOW(/DATE_ONLY) + '.txt' ; Create a text file that indicates an email was sent.  
  	IF EXISTS(EFILE) AND DP.HOUR LT '12' AND ~KEY(TEST) THEN CONTINUE    ;   If present and it is before noon, don't rerun the program
    IF KEY(TEST) THEN LOGFILE=LOG_FILE ELSE LOGFILE = []
    
	  MAILTO = ['kimberly.hyde@noaa.gov'];, 'kimhyde@gmail.com', ADDRESSES]
  	ATTACH = []
  	LUN    = []

    CLOSE,/ALL 
    IF KEY(TEST) THEN OPENW, LUN, LOG_FILE, /APPEND, /GET_LUN, WIDTH=180 ;  ===> Open log file
  	PLUN, LUN,'******************************************************************************************************************',0
  	PLUN, LUN,'Starting ' + ROUTINE_NAME + ' log file: ' + LOG_FILE + ' on: ' + systime() + ' on ' + !S.COMPUTER, 1
  	PLUN, LUN,'Creating files and images for: ' + NAME,0  
  	PLUN, LUN,'******************************************************************************************************************',1

  	PLUN, LUN,'Checking for the ERROR file and if present, send email...'
  	IF EXISTS(ERR_TEST) AND EXISTS(LOG_FILE) AND ~KEY(TEST) THEN BEGIN
  	  FILE_COPY, LOG_FILE, ERR_TEST, /OVERWRITE
  	  ERR = READ_TXT(ERR_TEST)
  	  ERR = ['***** ERROR while creating files for ' + CRUISE + ' on ' + DATE + ' *****','','',ERR, '', '', '***** ERROR while running ' + ROUTINE_NAME + ' on ' + DATE + ' *****']
  	  IF N_ELEMENTS(ERR) GT 100 THEN ERR = [ERR(0:5),REPLICATE('.',10),ERR(-100:-1)]
  	  WRITE_TXT, ERR_TEST, ERR
  	  CMD = 'echo "' + ERR[0] + ' Check log file - ' + LOG_FILE + '. ' + '" | mailx -s "' + CRUISE + ' Processing ERROR - "' + DATE_NOW() + ' -a ' + ERR_TEST + ' ' + 'kimberly.hyde@noaa.gov'
  	  SPAWN, CMD, LOG, ERROR
  	  FILE_DELETE, ERR_TEST
  	ENDIF ELSE IF ~KEY(TEST) THEN WRITE_TXT, ERR_TEST, 'Temp file to look for errors in the BATCH_CRON processing.  If the file exists, then an error occurred when running CRUISE_SUPPORT_MAIN at ' + DATE

	  PLUN, LUN,'Starting ' + ROUTINE_NAME + ' at ' + SYSTIME()

  	IF KEY(L1A_DWLD) THEN BEGIN
      PLUN, LUN,'Starting BATCH_DOWNLOADS ' + SYSTIME()
      IF KEY(TEST) THEN BEGIN & CLOSE, LUN & FREE_LUN, LUN & ENDIF
      BATCH_DOWNLOADS, 'OC-VIIRS-1KM', SWITCHES='Y_' + STRJOIN(DATERANGE,'_'), LOGFILE=LOGFILE, /SKIP_PLOTS
      IF KEY(TEST) THEN OPENW, LUN, LOG_FILE, /APPEND, /GET_LUN, WIDTH=180 ;  ===> Close and reopen the log file
      PLUN, LUN,'Done runnig BATCH_DOWNLOADS ' + SYSTIME()
  	ENDIF ELSE PLUN, LUN, 'Skipping BATCH_DOWNLOADS step.'; L1A_DWLD 
  	
    IF KEY(L2GEN) THEN BEGIN
  	  PLUN, LUN,'Starting BATCH_SEADAS_L1A ' + SYSTIME()
  	  IF KEY(TEST) THEN BEGIN & CLOSE, LUN & FREE_LUN, LUN & ENDIF
  	  BATCH_SEADAS_L1A, L2_SENSORS, LOGFILE=LOGFILE, DATERANGE=DATERANGE, DIR_PROCESS=DIR_L1A, GET_ANC=GET_ANC
      IF KEY(TEST) THEN OPENW, LUN, LOG_FILE, /APPEND, /GET_LUN, WIDTH=180 ;  ===> Reopen the log file  	  
      PLUN, LUN,'Done runnig BATCH_SEADAS_L1A ' + SYSTIME()
  	ENDIF ELSE PLUN, LUN, 'Skipping BATCH_SEADAS_L1A step' ; L2GEN
  	
  	IF KEY(L2BIN) THEN BEGIN
  	  PLUN, LUN,'Starting BATCH_SEADAS_L2BIN ' + SYSTIME()
  	  IF KEY(TEST) THEN BEGIN & CLOSE, LUN & FREE_LUN, LUN & ENDIF
  	  BATCH_SEADAS_L2BIN, BIN_SENSORS, SERVERS=SERVERS, SUITE = 'CHL', LOGFILE=LOGFILE
  	  IF KEY(TEST) THEN OPENW, LUN, LOG_FILE, /APPEND, /GET_LUN, WIDTH=180 ;  ===> Close and reopen the log file
  	  PLUN, LUN,'Done runnig BATCH_SEADAS_L2BIN ' + SYSTIME()
  	ENDIF ELSE PLUN, LUN, 'Skipping BATCH_SEADAS_L2BIN step.' ; L2BIN
  	
  	IF KEY(DO_STATS) THEN BEGIN
  	  PLUN, LUN,'Starting BATCH_L3 - STATS ' + SYSTIME()
  	  SW = 'Y_' + STRJOIN(DATERANGE,'_') + '[SAV;PER=D3.D8.M;P=NC_CHL]' ; MODISA;PER=D3.D8.M;P=NC_CHL,VIIRS;PER=D3.D8.M;P=NC_CHL,
  	  IF KEY(TEST) THEN BEGIN & CLOSE, LUN & FREE_LUN, LUN & ENDIF
  	  BATCH_L3, DO_STATS=SW, LOGFILE=LOGFILE
      IF KEY(TEST) THEN OPENW, LUN, LOG_FILE, /APPEND, /GET_LUN, WIDTH=180 ;  ===> Close and reopen the log file  	  
      PLUN, 'Done runnig BATCH_L3 - STATS ' + SYSTIME() 	  
  	ENDIF ELSE PLUN, LUN, 'Skipping BATCH_L3 - STATS step' ; DO_STATS
  	
  	IF KEY(NETCDFS) THEN BEGIN
  	  PLUN, LUN,'Starting WRITE_NETCDF ' + SYSTIME()
  	  CASE CRUISE OF
  	    'CO_2019': BEGIN
  	      B = FLS(DIR_NETCDF + '*.nc',COUNT=BCOUNT)
  	      
  	      IF KEY(TEST) THEN BEGIN & CLOSE, LUN & FREE_LUN, LUN & ENDIF
  	      F = FLS(!S.OC + 'MODISA/L3B2/NC/CHL/*.nc', DATERANGE=DATERANGE)
  	      F = [F,FLS(!S.OC + 'VIIRS/L3B2/NC/CHL/*.nc', DATERANGE=DATERANGE)]
  	    ;  F = [F,FLS(!S.OC + 'JPSS1/L3B2/NC/CHL/*.nc', DATERANGE=DATERANGE)]
  	      WRITE_NETCDF, F, DIR_OUT=DIR_NETCDF, MAP_OUT=NC_MAP,OUTFILES=OUTFILES, NC_PRODS='chlor_a'
  	      
  	      
  	      S = FLS(!S.OC + 'SAV/L3B2/STATS/CHLOR_A-OCI/' + ['D3','D8','M'] + '_*.SAV',DATERANGE=DATERANGE)
  	      IF KEY(TEST) THEN PRODS_2PNG, S, DIR_OUT=DIR_PNGS + NC_MAP + SL + 'STATS' + SL, MAPP=NC_MAP
  	      WRITE_NETCDF, S, DIR_OUT=DIR_NETCDF, MAP_OUT=NC_MAP,OUTFILES=OUTFILES
          IF KEY(TEST) THEN OPENW, LUN, LOG_FILE, /APPEND, /GET_LUN, WIDTH=180 ;  ===> Close and reopen the log file     
  	     
  	      A = FLS(DIR_NETCDF + '*.nc',COUNT=NCOMP)
  	      OK = WHERE_MATCH(A, B, COMPLEMENT=COMP, NCOMPLEMENT=NCOMP)
  	      IF NCOMP GT 0 THEN BEGIN
  	        IF OK EQ [] THEN NEW = A ELSE NEW = A(COMP)
  	        PLUN, LUN, 'Created ' + ROUNDS(NCOMP) + ' new NETCDF files.'
  	        FOR N=0, NCOMP-1 DO PLUN, LUN, NEW(N),0
  	      ENDIF
  	     
  	     END
  	   ENDCASE  
  	  
  	  PLUN, LUN,'Done running WRITE_NETCDF ' + SYSTIME()
  	ENDIF ELSE PLUN, LUN, 'Skipping WRITE_NETCDF step.' ; NETCDF
  	
; ===> Create a COMPOSITE image of the files  	
  	IF KEY(COMP) THEN BEGIN
  	  
  	  PLUN, LUN,'Starting COMPOSITING step ' + SYSTIME()
  	  CASE CRUISE OF
  	    'CO_2019': BEGIN
  	  
      	  FM = FLS(DIR_NETCDF + 'D_*MODISA*') & FPM = PARSE_IT(FM) 
      	  FV = FLS(DIR_NETCDF + 'D_*VIIRS*')  & FPV = PARSE_IT(FV) 
      	  F3 = FLS(DIR_NETCDF + 'D3_*SAV*')   & FP3 = PARSE_IT(F3) 
      	  F8 = FLS(DIR_NETCDF + 'D8_*SAV*')   & FP8 = PARSE_IT(F8) 
    
          LABELS = ['Daily MODISA', 'Daily VIIRS', '3-Day MODISA + VIIRS', '8-Day MODISA + VIIRS']
      	  MS = MAPS_SIZE(NC_MAP,PX=PX,PY=PY)
          IF MAX([PX,PY]) LT 512 THEN BEGIN & SX = PX*2 & SY = (PY*2)
                           ENDIF ELSE BEGIN & SX = PX & SY = PY & ENDELSE
          SP = PY/9
          CB = SY/4
          CY = SY + CB + SP*2
          CX = SX + SP*3
          CBPOS = [CX*.1,CB*.4,CX*.9,CB*.6]
          POS = LIST([0+SP,CY-PY-SP,PX+SP,CY-SP],$
                     [PX+SP*2,CY-PY-SP,SX+SP*2,CY-SP],$
                     [0+SP,CB-SP,PX+SP,CB+PY-SP],$
                     [PX+SP*2,CB-SP,SX+SP*2,CB+PY-SP])
      	  
      	  FOR I=0, N_ELEMENTS(FM)-1 DO BEGIN
      	    F = FM(I)
      	    FP = PARSE_IT(F)
      	    DE = STRMID(FP.DATE_END,0,8)
      	    
      	    V = FV[WHERE(STRMID(FPV.DATE_END,0,8) EQ DE, COUNT, /NULL)] & IF V NE [] THEN F = [F,V] ELSE F = [F,'']
      	    T = F3[WHERE(STRMID(FP3.DATE_END,0,8) EQ DE, COUNT, /NULL)] & IF T NE [] THEN F = [F,T] ELSE F = [F,''] 
      	    E = F8[WHERE(STRMID(FP8.DATE_END,0,8) EQ DE, COUNT, /NULL)] & IF E NE [] THEN F = [F,E] ELSE F = [F,'']
      	    
        	  CFILE = DIR_COMP + FP.PERIOD + '-' + CRUISE + '-CHLOR_A-COMPOSITION.PNG'
        	  IF ~FILE_MAKE(F,CFILE,OVERWRITE=OVERWRITE) THEN CONTINUE
        	    
        	  W = WINDOW(DIMENSIONS=[CX, CY],BUFFER=BUFFER)
      	    FOR N=0, N_ELEMENTS(F)-1 DO BEGIN
      	      IPOS = POS(N)
      	      IF F(N) NE '' THEN BEGIN
      	        D = READ_NC(F(N))
        	      OK = WHERE_STRING(TAG_NAMES(D.SD),'CHLOR_A',COUNT)
        	      IF COUNT GT 1 THEN BEGIN
        	        OK = WHERE(TAG_NAMES(D.SD) EQ 'CHLOR_A',COUNT)
        	        IF COUNT NE 1 THEN STOP
        	      ENDIF
        	      TS = STRMID(D.GLOBAL.TIME_COVERAGE_START,0,10)
        	      TE = STRMID(D.GLOBAL.TIME_COVERAGE_END,0,10)
        	      IF TS EQ TE THEN TM = TS ELSE TM = TS + ' to ' + TE 
        	      
        	      BIMG = PRODS_2BYTE(D.SD.(OK).IMAGE,PROD='CHLOR_A_0.3_30',MP=NC_MAP,/ADD_COAST,/ADD_LAND)
        	      IM = IMAGE(BIMG, RGB_TABLE=CPAL_READ('PAL_BR'), POSITION=IPOS,/CURRENT,/DEVICE, TITLE=LABELS(N), FONT_STYLE='BOLD', FONT_SIZE=12)
        	      TXT = TEXT(IPOS[0]+5, IPOS(3)-20, TM,        FONT_STYLE='BOLD', FONT_SIZE=10, /DEVICE)
        	    ENDIF 
        	    PG = POLYLINE([IPOS[0],IPOS[0],IPOS(2),IPOS(2),IPOS[0]],[IPOS[1],IPOS(3),IPOS(3),IPOS[1],IPOS[1]],THICK=2,/CURRENT,/DEVICE)
      	    ENDFOR 
      	    PRODS_COLORBAR, 'CHLOR_A_0.3_30', IMG=IM, POSITION=CBPOS, TEXTPOS=0, FONT_SIZE=CFONT_SIZE, TITLE=UNITS('CHLOROPHYLL'), TICKDIR=0,/DEVICE  
      	    W.SAVE, CFILE
      	    W.CLOSE
      	    PLUN, LUN, 'Created ' + CFILE, 0
      	  ENDFOR  
  	    END
  	  ENDCASE
  	  PLUN, LUN, 'Finished COMPOSITING step.' + SYSTIME()
  	ENDIF ELSE PLUN, LUN, 'Skipping COMPOSITING step.'
	
	  IF KEY(EMAIL) THEN BEGIN
  	  PLUN, LUN,'Starting step to email the desired files ' + SYSTIME()
  	  CASE CRUISE OF
  	    'CO_2019': BEGIN
  	      FM = FLS(DIR_NETCDF + 'D_*MODISA*') & FPM = PARSE_IT(FM) & FM = FM[WHERE(FPM.DATE_END EQ MAX(FPM.DATE_END),COUNT)] & IF COUNT NE 1 THEN STOP
  	      FV = FLS(DIR_NETCDF + 'D_*VIIRS*')  & FPV = PARSE_IT(FV) & FV = FV[WHERE(FPV.DATE_END EQ MAX(FPV.DATE_END),COUNT)] & IF COUNT NE 1 THEN STOP 
  	      F3 = FLS(DIR_NETCDF + 'D3_*SAV*')   & FP3 = PARSE_IT(F3) & F3 = F3[WHERE(FP3.DATE_END EQ MAX(FP3.DATE_END),COUNT)] & IF COUNT NE 1 THEN STOP
  	      F8 = FLS(DIR_NETCDF + 'D8_*SAV*')   & FP8 = PARSE_IT(F8) & F8 = F8[WHERE(FP8.DATE_END EQ MAX(FP8.DATE_END),COUNT)] & IF COUNT NE 1 THEN STOP
  	      CM = FLS(DIR_COMP   + 'D_*.PNG')    & FCM = PARSE_IT(CM) & CM = CM[WHERE(FCM.DATE_END EQ MAX(FCM.DATE_END),COUNT)] & IF COUNT NE 1 THEN STOP
  	      F = [FM, FV, F3, F8]
  
  	      LI, F
  	      ZFILE = DIR_ZIP + CRUISE + '-CHLOR_A_FILES-' + STRMID(DATE,0,8) + '.zip'
  	      IF FILE_MAKE(F, ZFILE, OVERWRITE=OVERWRITE) THEN BEGIN
  	        IF EXISTS(ZFILE) THEN FILE_DELETE, ZFILE
  	        FILE_ZIP, F, ZFILE, /VERBOSE
  	      ENDIF
  	      
  	      IF FILE_MAKE(ZFILE,EFILE,OVERWRITE=OVERWRITE) THEN BEGIN
  	      
    	      IF EXISTS(LOG_FILE) THEN FILE_COPY, LOG_FILE, LOG_TEXT, /OVERWRITE
  	        ATTACH = [LOG_TEXT, ZFILE, CM]
  	        ATTACH = ATTACH[WHERE(FILE_TEST(ATTACH) EQ 1,/NULL)]
  	        ATT = []
  	        FOR A=0, N_ELEMENTS(ATTACH)-1 DO ATT = [ATT, ' -a ' + ATTACH(A)]
  	        FP = FILE_PARSE(ATTACH)
  	        CMD = 'echo "' + CRUISE + ' finished on processing ' + SYSTIME() + '.  
  	        CMD = CMD + 'Emailing attachments ' + STRJOIN(FP.NAME_EXT, '; ') 
  	        CMD = CMD + '" | mailx -s "' + CRUISE + '     - ' + DATE_NOW(/DATE_ONLY) + '" ' + STRJOIN(ATT, ' ') + ' ' + STRJOIN(MAILTO, ' ')
  	        IF ATT NE [] THEN SPAWN, CMD, LOG, ERR
  	        FILE_DELETE, LOG_TEXT
    	      
            WRITE_TXT, EFILE, ['EMAIL sent to: ', '   '+ MAILTO, '', 'with attachments: ', '   ' + ATTACH, '', 'at ' + SYSTIME()]
          ENDIF ELSE PLUN, LUN, 'Skipping EMAIL step.'
  	    END
  	  ENDCASE


  	  PLUN, LUN,'Done running the step to email the desired files ' + SYSTIME()
  	  IF ANY(LUN) THEN BEGIN
  	    CLOSE, LUN & FREE_LUN, LUN
  	  ENDIF
  	  IF EXISTS(ERR_TEST) THEN FILE_DELETE, ERR_TEST
  	ENDIF ; EMAIL
	
	 

  	PRINT, '**** BATCH_CRON FINISHED ' + SYSTIME() + ' *****'
  	

	
	 
  ENDFOR ; Loop through the cruise names

END; #####################  End of Routine ################################
