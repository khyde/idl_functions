; $ID:	FPP_LMES.PRO,	2021-04-15-17,	USER-KJWH	$

	PRO FPP_LMES

;+
; NAME:
;		FPP_LMES
;
; PURPOSE:;
;		This procedure is the MAIN program for creating data and figures for the FAO/LME project with Michael Fogarty
;
; CATEGORY:
;		CATEGORY
;
; CALLING SEQUENCE:
;		NO KEYWORDS
;
; INPUTS:
;
; OPTIONAL INPUTS:
;
; KEYWORD PARAMETERS:
;
;	NOTES:
;
;
; MODIFICATION HISTORY:
;			Written Sep 6, 2017 by K.J.W.Hyde, 28 Tarzwell Drive, NMFS, NOAA 02882 (kimberly.hyde@noaa.gov)
;			Adapted from ECOAP_FISHERIES and ECOAP_NESPP - old plots and composites can still be found in ECOAP_FISHERIES
;-
;	****************************************************************************************************
	ROUTINE_NAME = 'FPP_LMES'

  SL = PATH_SEP()
	
	DIR_PROJECTS = !S.PROJECTS + 'ECOAP' + SL + ROUTINE_NAME + SL 	
	DIR_SUMMARY  = DIR_PROJECTS + 'SUBAREA_SUMMARY' + SL
	DIR_DATASETS = DIR_PROJECTS + 'DATASETS' + SL
  DIR_SAVE     = DIR_PROJECTS + 'DATA_BY_SUBAREA' + SL
  DIR_SAVE_PAN = DIR_PROJECTS + 'DATA_BY_SUBAREA_PAN' + SL
  DIR_SAVE_OC  = DIR_PROJECTS + 'DATA_BY_SUBAREA_OCI' + SL
	DIR_PLOTS    = DIR_PROJECTS + 'PLOTS' + SL
	DIR_DATA     = DIR_PROJECTS + 'DATA' + SL
	DIR_COMPS    = DIR_PROJECTS + 'COMPOSITES' + SL
	DIR_SZ_CLASS = DIR_PROJECTS + 'SZ_CLASS_TIMESERIES' + SL
	DIR_COMPARE  = DIR_PROJECTS + 'COMPARE' + SL
	DIR_COMPAREP = DIR_PROJECTS + 'COMPARE_PP' + SL
	DIR_TEST,[DIR_PLOTS,DIR_SAVE,DIR_SAVE_PAN,DIR_SAVE_OC,DIR_SUMMARY,DIR_COMPS,DIR_COMPARE,DIR_COMPAREP,DIR_SZ_CLASS]
  
  DO_SUBAREA_PNGS     = ''
  
; The following blocks extracts and summarizes the CHL and PP data for the LME/FAO regions  
  DO_MONTHLY_EXTRACTS = '' ; Updated 9/08/17 - Step (1) Extract monthly CHL and PP data from the satellite files for each LME/FAO region
  DO_MONTHLY_SUMS     = '' ; Added 8/15/13 - Step (2) Create monthly, annual and areal sums of PP
  DO_PP_CORRECTION    = 'Y' ; Added 6/4/14  - Step (3) Correct for missing PP values
  DO_PP_CONCATENATE   = '' ; Added 3/30/15 - Step (4) Concatenate all of the PP data into a single spreadsheet
  DO_PP_CLIM_ANN_MEAN = '' ; Added 7/30/15 - To concatenate all of the PP data and generate climatological annual means 
  DO_PP_CLIM_MON_MEAN = '' ; Added 12/9/15 - To concatenate aall of the CHL & PP data and generate climatological monthly means
  DO_PP_COMPARE       = '' ; Added 5/28/14 - Compares methods to fill in for the missing PP data during high latitude winters  
  DO_MONTHLY_COMPS    = '' ; Added 5/19/14 - To show the monthly composites and highlight the MISSING data during some months
  DO_SUMMED_STATS     = '' ; Added 8/19/13
  DO_FINAL_COMPOSITES = '' ; Added 8/22/13, updated 12/7/15
  
  DO_QQ_CF_PLOTS      = 0 ; Added 6/3/14  - Generates Quantile and Cumulative Frequency plots for the PP comparison data
  DO_CHL_PP_SZ_PLOTS  = 0 ; Added 3/31/14 - To show the monthly CHL and PP size class data from SeaWiFS and MODIS
  DO_COMPARE_PLOTS    = 0 ; Added 3/5/14  - To compare the SeaWiFS and MODIS data
  DO_COMPARE_PP       = 0 ; Added 3/12/14 - To compare the OPAL and VGPM2 data from SeaWiFS and MODIS 
  
  DO_HISTOGRAMS       = 0 ; Added 5/31/13  
  DO_LME_FAO_SUBAREAS = 0 ; Added 3/25/13  
  DO_SUBAREA_2LONLAT  = 0 ; Added 5/2/13
  DO_GLOBAL_SUBAREAS  = 0 ; Added 3/4/13
  DO_FAO_BOUNDARIES   = 0
  DO_GLOBAL_PLOTS     = 0
  DO_NEC_PLOTS        = 0
  DO_PHYTO_PLOTS      = 0
  DO_PP_SIZE_PLOTS    = 0
  DO_BATHY_LMES       = 0 ; Added 9/19/13
  
 
  EXCLUDE_LMES = ['ANTARCTICA','HUDSONBAYCOMPLEX','BEAUFORTSEA','CANADIANHIGHARCTIC_NORTHGREENLAND','CENTRALARCTIC','NORTHERNBERING_CHUKCHISEAS','EASTSIBERIANSEA','BARENTSSEA','KARASEA','LAPTEVSEA'] 
  STRUCT = READ_SHPFILE(!S.IDL_SHAPEFILES + 'LME66' + SL + 'LMEs66.shp', MAPP='L3B9', COLOR=COLORS, VERBOSE=VERBOSE)
  STRUCT = STRUCT_REMOVE(STRUCT.(0),['COLORS','LMES66_OUTLINE',EXCLUDE_LMES])
  LMES = TAG_NAMES(STRUCT)
  SDATES = ['1998','2007']
  MDATES = ['2008','2016']
  LME_MASKS = ['LME_TOTAL','LME_LT_300','LME_GT_300']
  FAO_MASKS = ['FAO_TOTAL','FAO_MINUS_LME']

; *******************************************************
  IF KEY(DO_SUBAREA_PNGS) THEN BEGIN
; *******************************************************
    SNAME = DO_SUBAREA_PNGS
    PRINT, 'Running: ' + 'DO_SUBAREA_PNGS'
    SWITCHES,DO_SUBAREA_PNGS,STOPP=STOPP,OVERWRITE=OVERWRITE,VERBOSE=VERBOSE,INIT=INIT,R_FILES=R_FILES,R_DATASETS=R_DATASETS,R_MAPS=R_MAPS,DATASETS=DATASETS,DATERANGE=DATERANGE

    BUFFER = 0
    MP = 'ROBINSON'
    STRUCT = READ_SHPFILE(!S.IDL_SHAPEFILES + 'LME66' + SL + 'LMEs66.shp', MAPP=MP, COLOR=COLORS, VERBOSE=VERBOSE)
    STRUCT = STRUCT_REMOVE(STRUCT.(0),['COLORS','LMES66_OUTLINE',EXCLUDE_LMES])    
    
    
    IMG = MAPS_BLANK(MP,FILL=255)
    LAND = READ_LANDMASK(MP,/STRUCT)
    BATH = READ_BATHY(MP)
    
    CLRS = [16,   64,   111,  32,   127,  0,    174,  190,  95,   222,  80,   238,  4,    52,   99,   83,   115,  68,   206,  87,   8,    147,  0,    210,  20,   178,  36,   226,  0,    242,  48,   214,  123,  76,   246,  0,    198,  40,   167,  60,   194,  28,   135,  230,  103,  182,  139,  107,  12,   91,   24,   234,  56,   0]    ; 131
    RGB = CPAL_READ('PAL_BR')
     
    FOR N=0, N_ELEMENTS(TAG_NAMES(STRUCT))-1 DO BEGIN
      CLR = BYTE((N+2)*23)
      WHILE CLR EQ 0 OR CLR GE 250 DO CLR = BYTE(CLR + N)
      IMG(STRUCT.(N).SUBS) = CLR  
    ENDFOR
    
    IMG(LAND.LAND) = 253
    IMG(LAND.COAST) = 0
    IM = IMAGE(IMG,RGB_TABLE=RGB,MARGIN=0,BUFFER=BUFFER,DIMENSIONS=[2048,1024])
    
    IMLT = IMG & OKLT = WHERE(IMLT GT 0 AND IMLT LT 250 AND BATH LE 300.0,COUNTLT)
    IMGT = IMG & OKGT = WHERE(IMGT GT 0 AND IMGT LT 250 AND BATH GT 300.0,COUNTGT)
    
    IMLT(OKLT) = 254
    IMGT(OKGT) = 254
    
    ILT = IMAGE(IMLT,RGB_TABLE=RGB,MARGIN=0,BUFFER=BUFFER,DIMENSIONS=[2048,1024])
    IGT = IMAGE(IMGT,RGB_TABLE=RGB,MARGIN=0,BUFFER=BUFFER,DIMENSIONS=[2048,1024])
    
    STOP
    IM.SAVE,  DIR_PLOTS + 'LMES_FULL-'  +MP+'_PROJECTION.PNG'
    ILT.SAVE, DIR_PLOTS + 'LMES_LT_300-'+MP+'_PROJECTION.PNG'
    IGT.SAVE, DIR_PLOTS + 'LMES_GT_300-'+MP+'_PROJECTION.PNG'
    IM.CLOSE & ILT.CLOSE & IGT.CLOSE
    STOP

  ENDIF
  
; *******************************************************
  IF KEY(DO_MONTHLY_EXTRACTS) THEN BEGIN
; *******************************************************
    SNAME = DO_MONTHLY_EXTRACTS
    PRINT, 'Running: ' + 'DO_MONTHLY_EXTRACTS'
    SWITCHES,DO_MONTHLY_EXTRACTS,STOPP=STOPP,OVERWRITE=OVERWRITE,VERBOSE=VERBOSE,INIT=INIT,R_FILES=R_FILES,R_DATASETS=R_DATASETS,R_MAPS=R_MAPS,DATASETS=DATASETS,DATERANGE=DATERANGE	
  	RERUN_MONTHLY_EXTRACTS:
  	  	  	
  	SENSORS = ['SEAWIFS','MODIS']
  	CHL  = ['CHLOR_A-OCI','PAR','MICRO','NANOPICO'] & SCHL = ['CHLOR_A-OCI','PAR','PHYTO-PAN','PHYTO-PAN']  
  	PP   = ['PPD-VGPM2','MICROPP','NANOPICOPP','MICROPP_PERCENTAGE','NANOPICOPP_PERCENTAGE'] & SPP = ['PPD-VGPM2',REPLICATE('PPSIZE',N_ELEMENTS(PP)-1)]  	
  	YEARS = YEAR_RANGE(MIN([SDATES,MDATES]),MAX([SDATES,MDATES]),/STRING) 
  	PERIODS = ['M','MONTH'] 	
  	PP_CHL_INPUT = ['OCI']
  	IF KEY(REVERSE_CHL) THEN PP_CHL_INPUT = REVERSE(PP_CHL_INPUT)
  	FOR CHLI=0, N_ELEMENTS(PP_CHL_INPUT)-1 DO BEGIN
  	  CHLIN = PP_CHL_INPUT(CHLI)
  	  IF CHLIN EQ 'PAN' THEN DIR_SAVE = DIR_SAVE_PAN ELSE DIR_SAVE = DIR_SAVE_OC
  	  DIRS = []
  	  PRODS = [] & SPRODS = []
  	  FOR S=0, N_ELEMENTS(SENSORS)-1 DO BEGIN
  	    SUBS = []
  	    CASE SENSORS(S) OF
  	      'SEAWIFS': BEGIN
  	        MP   = 'L3B9'
  	        CDIR = !S.DATASETS + 'OC-SEAWIFS-9KM' + SL + MP + SL + 'STATS' + SL 
  	        PDIR = !S.PP      + 'PP-SEAWIFS-9KM' + SL + MP + SL + 'STATS' + SL   
  	        STRUCT = READ_SHPFILE(!S.IDL_SHAPEFILES + 'LME66' + SL + 'LMEs66.shp', MAPP=MP, COLOR=COLORS, VERBOSE=VERBOSE)
  	        L3B9 = STRUCT_REMOVE(STRUCT.(0),['COLORS','LMES66_OUTLINE',EXCLUDE_LMES])
  	        L3B9_SUBS = MAPS_BLANK(MP,FILL=0)
  	        FOR N=0, N_ELEMENTS(TAG_NAMES(L3B9))-1 DO L3B9_SUBS(L3B9.(N).SUBS) = N+1
  	        L3B9_MASK = WHERE(L3B9_SUBS EQ 0)	       
  	        L3B9_AREAS = MAPS_PIXAREA(MP)
  	        L3B9_BATHY = READ_BATHY(MP)
  	      END
  	      'MODIS': BEGIN
  	        MP   = 'L3B4'
  	        CDIR = !S.DATASETS + 'OC-MODISA-4KM' + SL + MP + SL + 'STATS' + SL  
            PDIR = !S.PP      + 'PP-MODISA-4KM' + SL + MP + SL + 'STATS' + SL   
            STRUCT = READ_SHPFILE(!S.IDL_SHAPEFILES + 'LME66' + SL + 'LMEs66.shp', MAPP=MP, COLOR=COLORS, VERBOSE=VERBOSE)
  	        L3B4 = STRUCT_REMOVE(STRUCT.(0),['COLORS','LMES66_OUTLINE',EXCLUDE_LMES])
  	        L3B4_SUBS = MAPS_BLANK(MP,FILL=0)
  	        FOR N=0, N_ELEMENTS(TAG_NAMES(L3B4))-1 DO L3B4_SUBS(L3B4.(N).SUBS) = N+1
  	        L3B4_MASK = WHERE(L3B4_SUBS EQ 0)
  	        L3B4_BATHY = READ_BATHY(MP)
  	        L3B4_AREAS = MAPS_PIXAREA(MP)
  	      END
  	    ENDCASE
  	    DIRS   = [DIRS,REPLICATE(CDIR,N_ELEMENTS(CHL)),REPLICATE(PDIR,N_ELEMENTS(PP))]
  	    PRODS  = [PRODS,CHL,PP]
  	    SPRODS = [SPRODS,SCHL,SPP] ; FILE_SEARCH PRODS
  	  ENDFOR
  	  
  	  FOR P=0, N_ELEMENTS(PERIODS)-1 DO BEGIN
      	IF PERIODS(P) EQ 'MONTH' THEN YRS = 0 ELSE YRS = YEARS
      	IF YRS[0] NE 0 AND KEY(REVERSE_YEARS) THEN YEARS = REVERSE(YEARS)
      	FOR Y=0, N_ELEMENTS(YRS)-1 DO BEGIN
      	  IF PERIODS(P) EQ 'MONTH' THEN APERIOD = 'MONTH' ELSE APERIOD = 'M_'+YEARS(Y)
    	  	FOR R=0, N_ELEMENTS(DIRS)-1 DO BEGIN
    	  		DIR_OUT = DIR_SAVE + PRODS(R) + SL 
    	  		SPROD = SPRODS(R)
    	  		DIR_EXTRA = ''
            IF APERIOD   EQ 'MONTH' THEN IF SPRODS(R) EQ 'PPSIZE' OR SPRODS(R) EQ 'PHYTO-PAN' THEN SPROD = PRODS(R) 
            IF SPRODS(R) EQ 'PPSIZE' AND APERIOD NE 'MONTH' THEN DIR_EXTRA = '-VGPM2' 
            IF SPRODS(R) EQ 'PHYTO-PAN' AND APERIOD EQ 'MONTH' THEN DIR_EXTRA = '-PAN'
            DIR_TEST,DIR_OUT    	
            DIR_SEARCH = DIRS(R)+SPROD+DIR_EXTRA+SL  		
    	  		FILES = FLS(DIR_SEARCH+APERIOD+'*'+SPROD+'*.SAV',COUNT=COUNTF)
    	  ;		IF SPRODS(R) EQ 'PPSIZE' THEN FILES = FS(DIRS(R)+SPRODS(R)+'-VGPM2'+SL+APERIOD+'*'+SPRODS(R)+'*.SAV',COUNT=COUNTF)
    	  		PRINT, 'Found ' + NUM2STR(COUNTF) + ' files for ' + APERIOD + ' in: ' + DIR_SEARCH + ' - '+PRODS(R)
    	  		IF COUNTF EQ 0 THEN CONTINUE

    	  		FP = PARSE_IT(FILES)
    	  		FILES = FILES[SORT(FP.MONTH_START)]
    	  		FP = PARSE_IT(FILES,/ALL)  	  		
    	  		SAVEFILES = []
    	  		FOR N=0, N_ELEMENTS(LMES)-1 DO SAVEFILES = [SAVEFILES,DIR_OUT+APERIOD+'-'+CHLIN+'-'+REPLACE(FP[0].NAME,[FP[0].PERIOD,SPRODS(R)],['LME_' + ADD_STR_ZERO(N+1) + '_' + LMES(N),PRODS(R)])+'.SAV']
    	  		IF FILE_MAKE(FILES,SAVEFILES,OVERWRITE=OVERWRITE) EQ 0 THEN CONTINUE
    	  		
    	  		CASE FP[0].MAP OF
    	  		  'L3B9': BEGIN & MASK = L3B9_MASK & BATHY = L3B9_BATHY & SUBAREAS = L3B9_SUBS & AREAS = L3B9_AREAS & END
    	  		  'L3B4': BEGIN & MASK = L3B4_MASK & BATHY = L3B4_BATHY & SUBAREAS = L3B4_SUBS & AREAS = L3B4_AREAS & END
    	  		  ELSE: BEGIN & MASK = [] & BATHY = [] & END
    	  		ENDCASE
    	  		
    	  		STRUCT = []
    	  		FOR N=0, N_ELEMENTS(FILES)-1 DO BEGIN
    	  		 D = STRUCT_READ(FILES(N),MASK=MASK,STRUCT=S)
    	  		 IF PRODS(R) NE SPRODS(R) AND APERIOD NE 'MONTH' THEN D = STRUCT_GET(S,PRODS(R))
    	  		 IF APERIOD EQ 'MONTH' THEN D = STRUCT_GET(S,'MEAN')
    	  		 IF D EQ [] THEN MESSAGE, 'ERROR GETTING DATA FROM FILE'
    	  		 D = MAPS_L3B_2ARR(D,MP=S.MAP,BINS=S.BINS)
    	  		 STRUCT = CREATE_STRUCT(STRUCT,FP(N).PERIOD,D)
    	  		ENDFOR ; FILES
    	  		GONE, D
    	  		TAGS = TAG_NAMES(STRUCT)
    	  		
    	  		FOR N=0, N_ELEMENTS(LMES)-1 DO BEGIN
    	  			ACODE = N+1
    	  			SAVEFILE = SAVEFILES(N)
    	  			IF FILE_MAKE(FILES,SAVEFILE,OVERWRITE=OVERWRITE) EQ 0 THEN CONTINUE
    	  			
    	  			OKT = WHERE(SUBAREAS EQ ACODE,COUNTT)
    	  			OKL = WHERE(SUBAREAS EQ ACODE AND BATHY LE 300,COUNTL)
    	  			OKG = WHERE(SUBAREAS EQ ACODE AND BATHY GE 300,COUNTG)
    	  			TEMP = CREATE_STRUCT('LME_TOTAL_AREA',AREAS(OKT))
    	  			IF COUNTL GT 0 THEN TEMP = CREATE_STRUCT(TEMP,'LME_LT_300_AREA',AREAS(OKL))
    	  			IF COUNTG GT 0 THEN TEMP = CREATE_STRUCT(TEMP,'LME_GT_300_AREA',AREAS(OKG))
    	  			
    	  			IF COUNTT GE 1 THEN FOR T=0, N_ELEMENTS(TAGS)-1 DO TEMP = CREATE_STRUCT(TEMP,TAGS(T)+'_LME_TOTAL', STRUCT.(T)(OKT))
    	  			IF COUNTL GE 1 THEN FOR T=0, N_ELEMENTS(TAGS)-1 DO TEMP = CREATE_STRUCT(TEMP,TAGS(T)+'_LME_LT_300',STRUCT.(T)(OKL))
    	  			IF COUNTG GE 1 THEN FOR T=0, N_ELEMENTS(TAGS)-1 DO TEMP = CREATE_STRUCT(TEMP,TAGS(T)+'_LME_GT_300',STRUCT.(T)(OKG))
    	  			PRINT, 'Writing ' + SAVEFILE
              SAVE,FILENAME=SAVEFILE,TEMP,/COMPRESS
              GONE, TEMP
    	  		ENDFOR ; LMES
    	  		GONE, STRUCT
    	  	ENDFOR ; DIRS
    	  ENDFOR ; YEARS 
    	ENDFOR ; PERIODS 	
	  ENDFOR ; CHLIN 	
  ENDIF ; DO_MONTHLY_EXTRACTS
  
; *******************************************************
  IF KEY(DO_MONTHLY_SUMS) THEN BEGIN
; *******************************************************
    SNAME = DO_MONTHLY_SUMS
    PRINT, 'Running: ' + 'DO_MONTHLY_SUMS'
    SWITCHES,DO_MONTHLY_SUMS,STOPP=STOPP,OVERWRITE=OVERWRITE,VERBOSE=VERBOSE,INIT=INIT,R_FILES=R_FILES,R_DATASETS=R_DATASETS,R_MAPS=R_MAPS,DATASETS=DATASETS,DATERANGE=DATERANGE

 	
  	REPEAT_EXTRACT_SUMS:
  	REVERSE_OC      = 0
    REVERSE_SENSORS = 0 
    REVERSE_PP      = 0
    REVERSE_NAMES   = 0
  	
  	CODE_TYPE  = ['LME'];'FAO']
  	PP_TARGETS = ['VGPM2'];,'OPAL']
    PP_CHL_INPUT = ['OCI'];,'PAN']
    IF KEY(REVERSE_OC) THEN PP_CHL_INPUT = REVERSE(PP_CHL_INPUT)
    IF KEY(REVERSE_PP) THEN PP_TARGETS   = REVERSE(PP_TARGETS)
    FOR CHLI=0, N_ELEMENTS(PP_CHL_INPUT)-1 DO BEGIN ; Loop through CHL algorithms
      CHLIN = PP_CHL_INPUT(CHLI)
      IF CHLIN EQ 'PAN' THEN DIR_SAVE = DIR_SAVE_PAN ELSE DIR_SAVE = DIR_SAVE_OC
      FOR TAR=0, N_ELEMENTS(PP_TARGETS)-1 DO BEGIN  ; Loop through PP algorithms
        PP_TARGET = PP_TARGETS(TAR)
        SENSORS = ['SEAWIFS','MODIS']
        IF KEY(REVERSE_SENSORS) THEN SENSORS = REVERSE(SENSORS)
        FOR SEN=0, N_ELEMENTS(SENSORS)-1 DO BEGIN   ; Loop through SENSORS
          SENSOR = SENSORS(SEN)
          PRINT, 'Extracting ' + CHLIN + ' data for ' + SENSOR + ' ' + PP_TARGET
          
          CHL  = ['CHLOR_A-'+CHLIN, 'MICRO', 'NANOPICO']        
          PPD  = ['PPD-'+PP_TARGET,'MICROPP','NANOPICOPP','MICROPP_PERCENTAGE','NANOPICOPP_PERCENTAGE'] 
          PRODS = [CHL,PPD]
          DIRS  = DIR_SAVE + PRODS + SL
          YEARS = YEAR_RANGE(SDATES[0],SDATES[1],/STRING)
          IF STRMID(SENSOR,0,3) EQ 'MOD' THEN YEARS = YEAR_RANGE(MDATES[0],MDATES[1],/STRING)
  	
        	FOR C=0, N_ELEMENTS(CODE_TYPE)-1 DO BEGIN  ; Loop through CODE types (LME/FAO)
        		IF CODE_TYPE(C) EQ 'LME' THEN NAMES = LMES ELSE NAMES = FAO_NAMES     
        		IF KEY(REVERSE_NAMES) THEN NAMES = REVERSE(NAMES)  		
        		FOR N=0, N_ELEMENTS(NAMES)-1 DO BEGIN    ; Loop through NAMES
              ANAME = NAMES(N)
              FOR P=0, N_ELEMENTS(PRODS)-1 DO BEGIN  ; Loop through PRODS
                APROD = PRODS(P)
                SAVES = FILE_SEARCH(DIRS(P)+'M*'+'-'+CHLIN+'-'+CODE_TYPE(C)+'_*'+ANAME+'-'+STRMID(SENSOR,0,3)+'*-*'+APROD+'*.SAV')                                                                                              
                IF N_ELEMENTS(SAVES) LE 1 THEN CONTINUE
                FP = FILE_PARSE(SAVES)
                PERIOD = STR_BREAK(FP.NAME,'-') & PERIOD = PERIOD(*,0)
                SAVEFILE = DIRS(P) + REPLACE(FP[0].NAME_EXT,[FIRST(PERIOD[0])],['ALL'])             
                IF FILE_MAKE(SAVES,SAVEFILE,OVERWRITE=OVERWRITE) EQ 0 THEN CONTINUE
                PRINT, 'Working on: ' + SAVEFILE
                COUNTER = 0
                FOR S=0, N_ELEMENTS(SAVES)-1 DO BEGIN ; Loop through SAVES
                  YR = PERIOD(S)
                  IF YR[0] NE 'MONTH' THEN YR = STR_BREAK(YR[0],'_') ELSE YR = YR[0]
                  IF N_ELEMENTS(YR) GT 1 THEN IF WHERE(YR[1] EQ YEARS) LT 0 THEN CONTINUE
                  DATA = IDL_RESTORE(SAVES(S))
                  IF IDLTYPE(DATA) EQ 'STRING' THEN BEGIN
                    FILE_DELETE, SAVES(S)
                    GOTO, RERUN_MONTHLY_EXTRACTS
                  ENDIF  
                  PRINT, '     Adding data from: ' + SAVES(S)
                  IF COUNTER EQ 0 THEN OUTSTRUCT =  DATA ELSE OUTSTRUCT = CREATE_STRUCT(OUTSTRUCT,STRUCT_COPY(DATA,TAGNAMES=['LME_TOTAL_AREA','LME_LT_300_AREA','LME_GT_300_AREA','FAO_TOTAL_AREA','FAO_MINUS_LME_AREA'],/REMOVE)) ; Merge the SAVE files
                  IF N_ELEMENTS(TAG_NAMES(OUTSTRUCT)) EQ 1 THEN STOP
                  GONE, DATA
                  COUNTER = COUNTER + 1
                ENDFOR ; SAVES 
                SAVE,FILENAME=SAVEFILE,OUTSTRUCT,/COMPRESS
                GONE, OUTSTRUCT
              ENDFOR ; PRODS
            ENDFOR ; CODES
          ENDFOR ; CODE_TYPES
    
          FOR C=0, N_ELEMENTS(CODE_TYPE)-1 DO BEGIN  ; Loop through CODE TYPES
            IF CODE_TYPE(C) EQ 'LME' THEN NAMES = LMES ELSE NAMES = FAO_NAMES      
            IF CODE_TYPE(C) EQ 'LME' THEN NMASKS = 3        ELSE NMASKS = 2
            IF CODE_TYPE(C) EQ 'LME' THEN MASKS = LME_MASKS ELSE MASKS = FAO_MASKS
            FOR N=0, N_ELEMENTS(NAMES)-1 DO BEGIN    ; Loop through CODES             
              ANAME = NAMES(N)          
                                                     ; Find the files associated with the appropriate CODE, CHL alg, SENSOR and PRODUCT
              CTSAVE = FILE_SEARCH(DIRS[0] + 'ALL-' + CHLIN + '-' + CODE_TYPE(C) + '_*' + ANAME + '-' + STRMID(SENSOR,0,3) + '*' + PRODS[0] + '*.SAV')
              CMSAVE = FILE_SEARCH(DIRS[1] + 'ALL-' + CHLIN + '-' + CODE_TYPE(C) + '_*' + ANAME + '-' + STRMID(SENSOR,0,3) + '*' + PRODS[1] + '*.SAV')
              CNSAVE = FILE_SEARCH(DIRS(2) + 'ALL-' + CHLIN + '-' + CODE_TYPE(C) + '_*' + ANAME + '-' + STRMID(SENSOR,0,3) + '*' + PRODS(2) + '*.SAV')
              PTSAVE = FILE_SEARCH(DIRS(3) + 'ALL-' + CHLIN + '-' + CODE_TYPE(C) + '_*' + ANAME + '-' + STRMID(SENSOR,0,3) + '*' + PRODS(3) + '*.SAV')
              PMSAVE = FILE_SEARCH(DIRS(4) + 'ALL-' + CHLIN + '-' + CODE_TYPE(C) + '_*' + ANAME + '-' + STRMID(SENSOR,0,3) + '*' + PRODS(4) + '*.SAV')
              PNSAVE = FILE_SEARCH(DIRS(5) + 'ALL-' + CHLIN + '-' + CODE_TYPE(C) + '_*' + ANAME + '-' + STRMID(SENSOR,0,3) + '*' + PRODS(5) + '*.SAV')
        	    SAVES = [CTSAVE,CMSAVE,CNSAVE,PTSAVE,PMSAVE,PNSAVE]
        	    POS = STRPOS(CTSAVE,CODE_TYPE(C)+'_',/REVERSE_SEARCH) + STRLEN(CODE_TYPE(C)+'_')
        	    ACODE = STRMID(CTSAVE,POS,2)
        	    
        	    DIR_CSV   = DIR_SAVE + 'STATS-CSV'  + SL + CODE_TYPE(C) + '_'  + STR_PAD(ACODE,2) + '-' + ANAME + SL         
              DIR_STATS = DIR_SAVE + 'STATS-SAVE' + SL 
              DIR_TEST,[DIR_CSV,DIR_STATS]
             
              CTDATA = []
              FOR M=0, N_ELEMENTS(MASKS)-1 DO BEGIN  ; Loop through MASKS
                                                     ; Output file names
                MSAVEFILE = DIR_STATS + 'MONTHLY_SUM-' + CHLIN + '-' + SENSORS(SEN) + '-' + CODE_TYPE(C) + '_' + ACODE + '-' + ANAME + '-' + MASKS(M) + '-CHL_PRIMARY_PRODUCTION-' + PP_TARGET + '-STATS.SAV'          
                MCSVFILE  = DIR_CSV   + 'MONTHLY_SUM-' + CHLIN + '-' + SENSORS(SEN) + '-' + CODE_TYPE(C) + '_' + ACODE + '-' + ANAME + '-' + MASKS(M) + '-CHL_PRIMARY_PRODUCTION-' + PP_TARGET + '-STATS.CSV'
                ASAVEFILE = DIR_STATS + 'ANNUAL_SUM-'  + CHLIN + '-' + SENSORS(SEN) + '-' + CODE_TYPE(C) + '_' + ACODE + '-' + ANAME + '-' + MASKS(M) + '-CHL_PRIMARY_PRODUCTION-' + PP_TARGET + '-STATS.SAV'
                ACSVFILE  = DIR_CSV   + 'ANNUAL_SUM-'  + CHLIN + '-' + SENSORS(SEN) + '-' + CODE_TYPE(C) + '_' + ACODE + '-' + ANAME + '-' + MASKS(M) + '-CHL_PRIMARY_PRODUCTION-' + PP_TARGET + '-STATS.CSV'
           
                IF FILE_MAKE(SAVES,[MSAVEFILE,ASAVEFILE,MCSVFILE,ACSVFILE], OVERWRITE=OVERWRITE) EQ 0 THEN CONTINUE
                
                PRINT, 'Calculating stats for: ' + SENSORS(SEN) + '-' + STR_PAD(ACODE,2) + '-' + ANAME + '-' + MASKS(M) + '-' + PP_TARGET + '_' + CHLIN
                IF CTDATA EQ [] THEN BEGIN
                  CTDATA = IDL_RESTORE(CTSAVE) & DT =     IDLTYPE(CTDATA)
                  CMDATA = IDL_RESTORE(CMSAVE) & DT = [DT,IDLTYPE(CMDATA)]
                  CNDATA = IDL_RESTORE(CNSAVE) & DT = [DT,IDLTYPE(CNDATA)]
                  PTDATA = IDL_RESTORE(PTSAVE) & DT = [DT,IDLTYPE(PTDATA)]
                  PMDATA = IDL_RESTORE(PMSAVE) & DT = [DT,IDLTYPE(PMDATA)]
                  PNDATA = IDL_RESTORE(PNSAVE) & DT = [DT,IDLTYPE(PNDATA)]
                  TAGS   = TAG_NAMES(CTDATA)
                  SAVES  = [CTSAVE,CMSAVE,CNSAVE,PTSAVE,PMSAVE,PNSAVE]
                  OK     = WHERE(DT EQ 'STRING',COUNT)
                  IF COUNT GE 1 THEN BEGIN
                    FILE_DELETE, SAVES[OK]
                    GOTO, REPEAT_EXTRACT_SUMS
                  ENDIF  
                ENDIF
                IF MAX(STRPOS(TAGS,MASKS(M))) LT 0 THEN CONTINUE
                
                STRUCT = CREATE_STRUCT('SENSOR','','CHL_ALG','','PP_ALG','','YEAR','','MONTH','','MASK','','SUBAREA_NAME','','SUBAREA_CODE',0L,$ ; Set up MONTHLY output structure
                                       'N_SUBAREA_PIXELS',0L,'TOTAL_PIXEL_AREA_KM2',0.0D,$                                    ; Pixel area information
                                                                                                                              ; Total, Micro and Nano-pico Chlorophyll data
                                       'TCHL_N_PIXELS',       0L,  'MCHL_N_PIXELS',       0L,  'NCHL_N_PIXELS',       0L,  $  ; Number of valid CHL pixels
                                       'TCHL_N_PIXELS_AREA',  0.0D,'MCHL_N_PIXELS_AREA',  0.0D,'NCHL_N_PIXELS_AREA',  0.0D,$  ; Area of valid pixels ?
                                       'TCHL_MEAN',           0.0, 'MCHL_MEAN',           0.0, 'NCHL_MEAN',           0.0, $  ; Mean CHL                                  
                                       'TCHL_SPATIAL_VAR',    0.0, 'MCHL_SPATIAL_VAR',    0.0, 'NCHL_SPATIAL_VAR',    0.0, $  ; CHL spatial variance
                                                                                                                              ; Total, Micro and Nano-pico PP data
                                       'TPP_N_PIXELS',        0L,  'MPP_N_PIXELS',        0L,  'NPP_N_PIXELS',        0L,  $  ; Number of valid PP pixels
                                       'TPP_N_PIXELS_AREA',   0.0D,'MPP_N_PIXELS_AREA',   0.0D,'NPP_N_PIXELS_AREA',   0.0D,$  ; Area of valid pixels ?
                                       'TPP_SPATIAL_SUM',     0.0D,'MPP_SPATIAL_SUM',     0.0D,'NPP_SPATIAL_SUM',     0.0D,$  ; Sum of PP pixels within the subarea
                                       'TPP_MONTHLY_SUM',     0.0D,'MPP_MONTHLY_SUM',     0.0D,'NPP_MONTHLY_SUM',     0.0D,$  ; ?
                                       'TPP_MEAN',            0.0, 'MPP_MEAN',            0.0, 'NPP_MEAN',            0.0, $  ; Mean PP                              
                                       'TPP_SPATIAL_VAR',     0.0, 'MPP_SPATIAL_VAR',     0.0, 'NPP_SPATIAL_VAR',     0.0)    ; PP spatial variance
                                       
                                      
                                            
                MONTHS = ['01','02','03','04','05','06','07','08','09','10','11','12']
                STRUCT = REPLICATE(STRUCT_2MISSINGS(STRUCT),N_ELEMENTS(YEARS)*12)
                
                YSTRUCT = CREATE_STRUCT('SENSOR','','CHL_ALG','','PP_ALG','','YEAR','','MASK','','SUBAREA_NAME','','SUBAREA_CODE',0L,$ ; Set up ANNUAL output structure
                                        'N_SUBAREA_PIXELS',0L,   'TOTAL_PIXEL_AREA_KM2',0.0D,$                                ; Pixel area information
                                        'TCHL_ANNUAL_MEAN',0.0,  'MCHL_ANNUAL_MEAN',    0.0,  'NCHL_ANNUAL_MEAN',0.0,$  ; Annual mean CHL
                                        'TPP_ANNUAL_MEAN', 0.0,  'MPP_ANNUAL_MEAN',     0.0,  'NPP_ANNUAL_MEAN', 0.0,$  ; Annual mean PP
                                        'TPP_ANNUAL_SUM',  0.0D, 'MPP_ANNUAL_SUM',      0.0D, 'NPP_ANNUAL_SUM',  0.0D,$ ; Annual sum
                                        'TPP_N_MONTHS',    0L,   'MPP_N_MONTHS',        0L,   'NPP_N_MONTHS',    0L,$   ; Number of months used to calculate the annual summed PP
                                        'TPP_ANNUAL_MTON', 0.0,  'MPP_ANNUAL_MTON',     0.0D, 'NPP_ANNUAL_MTON', 0.0D)  ; Annual PP sum converted to million tons
                YSTRUCT = REPLICATE(STRUCT_2MISSINGS(YSTRUCT),N_ELEMENTS(YEARS))
                I = 0
                STRUCT.SENSOR  = SENSORS(SEN) & YSTRUCT.SENSOR  = SENSORS(SEN)
                STRUCT.PP_ALG  = PP_TARGET    & YSTRUCT.PP_ALG  = PP_TARGET
                STRUCT.CHL_ALG = CHLIN        & YSTRUCT.CHL_ALG = CHLIN
                FOR Y=0, N_ELEMENTS(YEARS)-1 DO BEGIN 
        	  		  FOR MTH=0, N_ELEMENTS(MONTHS)-1 DO BEGIN
        	  			  STRUCT(I).YEAR = YEARS(Y)        
        	  			  STRUCT(I).MONTH = MONTHS(MTH)
                    STRUCT(I).MASK = MASKS(M)
                    STRUCT(I).SUBAREA_CODE = ACODE
                    STRUCT(I).SUBAREA_NAME = ANAME
                    CASE STRUCT(I).MASK OF
                      'LME_TOTAL'     : STRUCT(I).N_SUBAREA_PIXELS = N_ELEMENTS(CTDATA.LME_TOTAL_AREA) ; Number of pixels within the subarea
                      'LME_LT_300'    : STRUCT(I).N_SUBAREA_PIXELS = N_ELEMENTS(CTDATA.LME_LT_300_AREA)
                      'LME_GT_300'    : STRUCT(I).N_SUBAREA_PIXELS = N_ELEMENTS(CTDATA.LME_GT_300_AREA)
                      'FAO_TOTAL'     : STRUCT(I).N_SUBAREA_PIXELS = N_ELEMENTS(CTDATA.FAO_TOTAL_AREA)
                      'FAO_MINUS_LME' : STRUCT(I).N_SUBAREA_PIXELS = N_ELEMENTS(CTDATA.FAO_MINUS_LME_AREA)
                    ENDCASE
                    
                    CASE STRUCT(I).MASK OF
                      'LME_TOTAL'      : STRUCT(I).TOTAL_PIXEL_AREA_KM2 = TOTAL(CTDATA.LME_TOTAL_AREA,/NAN) ; Total area of the pixels within the subarea
                      'LME_LT_300'     : STRUCT(I).TOTAL_PIXEL_AREA_KM2 = TOTAL(CTDATA.LME_LT_300_AREA,/NAN)
                      'LME_GT_300'     : STRUCT(I).TOTAL_PIXEL_AREA_KM2 = TOTAL(CTDATA.LME_GT_300_AREA,/NAN)
                      'FAO_TOTAL'      : STRUCT(I).TOTAL_PIXEL_AREA_KM2 = TOTAL(CTDATA.FAO_TOTAL_AREA,/NAN)
                      'FAO_MINUS_LME'  : STRUCT(I).TOTAL_PIXEL_AREA_KM2 = TOTAL(CTDATA.FAO_MINUS_LME_AREA,/NAN)
                    ENDCASE  
                                                          
                    ATAG = 'M_' + YEARS(Y) + MONTHS(MTH) + '_' + MASKS(M) ; Input structure tag
                    PTAG = STRUCT(I).MASK + '_AREA'                       ; Pixel area tag
                    CTPOS = WHERE(TAG_NAMES(CTDATA) EQ ATAG) & CTAP = WHERE(TAG_NAMES(CTDATA) EQ PTAG)  ; Find positions of ATAG and PTAG
                    CMPOS = WHERE(TAG_NAMES(CMDATA) EQ ATAG) & CMAP = WHERE(TAG_NAMES(CMDATA) EQ PTAG)
                    CNPOS = WHERE(TAG_NAMES(CNDATA) EQ ATAG) & CNAP = WHERE(TAG_NAMES(CNDATA) EQ PTAG)
                    PTPOS = WHERE(TAG_NAMES(PTDATA) EQ ATAG) & PTAP = WHERE(TAG_NAMES(PTDATA) EQ PTAG)
                    PMPOS = WHERE(TAG_NAMES(PMDATA) EQ ATAG) & PMAP = WHERE(TAG_NAMES(PMDATA) EQ PTAG)
                    PNPOS = WHERE(TAG_NAMES(PNDATA) EQ ATAG) & PNAP = WHERE(TAG_NAMES(PNDATA) EQ PTAG)
                    
                    IF CTPOS EQ -1 OR CMPOS EQ -1 THEN CONTINUE
                    CT = CTDATA.(CTPOS) & CTA = CTDATA.(CTAP)                                ; Data & Pixel area for each PROD 
                    CM = CMDATA.(CMPOS) & CMA = CMDATA.(CMAP)
                    CN = CNDATA.(CNPOS) & CNA = CNDATA.(CNAP)
                    TP = PTDATA.(PTPOS) & PTA = PTDATA.(PTAP)
                    MP = PMDATA.(PMPOS) & PMA = PMDATA.(PMAP)
                    NP = PNDATA.(PNPOS) & PNA = PNDATA.(PNAP)
                      
                    OKCT = WHERE(CT GT 0 AND CT NE MISSINGS(0.0),COUNTCT) ; Find non-missing data
                    OKCM = WHERE(CM GT 0 AND CM NE MISSINGS(0.0),COUNTCM)
                    OKCN = WHERE(CN GT 0 AND CN NE MISSINGS(0.0),COUNTCN)
                    OKPT = WHERE(TP GT 0 AND TP NE MISSINGS(0.0),COUNTPT)
                    OKPM = WHERE(MP GT 0 AND MP NE MISSINGS(0.0),COUNTPM)
                    OKPN = WHERE(NP GT 0 AND NP NE MISSINGS(0.0),COUNTPN)    
                    
          	  			STRUCT(I).TCHL_N_PIXELS = COUNTCT                      ; Number of valid pixels
                    STRUCT(I).MCHL_N_PIXELS = COUNTCM
                    STRUCT(I).NCHL_N_PIXELS = COUNTCN
                    STRUCT(I).TPP_N_PIXELS  = COUNTPT
                    STRUCT(I).MPP_N_PIXELS  = COUNTPM
                    STRUCT(I).NPP_N_PIXELS  = COUNTPN
                   
                    IF COUNTCT GT 1 THEN STRUCT(I).TCHL_N_PIXELS_AREA = TOTAL(CTA(OKCT),/NAN)       ; Determine the area of the valid pixels
                    IF COUNTCM GT 1 THEN STRUCT(I).MCHL_N_PIXELS_AREA = TOTAL(CMA(OKCM),/NAN)
                    IF COUNTCN GT 1 THEN STRUCT(I).NCHL_N_PIXELS_AREA = TOTAL(CNA(OKCN),/NAN)
                    IF COUNTPT GT 1 THEN STRUCT(I).TPP_N_PIXELS_AREA  = TOTAL(PTA(OKPT),/NAN)
                    IF COUNTPM GT 1 THEN STRUCT(I).MPP_N_PIXELS_AREA  = TOTAL(PMA(OKPM),/NAN)
                    IF COUNTPN GT 1 THEN STRUCT(I).NPP_N_PIXELS_AREA  = TOTAL(PNA(OKPN),/NAN)
                    
                    IF COUNTCT GT 1 THEN STRUCT(I).TCHL_MEAN = GEOMEAN(CT(OKCT),/NAN)               ; Geometric mean of the valid CHL and PP data
                    IF COUNTCM GT 1 THEN STRUCT(I).MCHL_MEAN = GEOMEAN(CM(OKCM),/NAN)
                    IF COUNTCN GT 1 THEN STRUCT(I).NCHL_MEAN = GEOMEAN(CN(OKCN),/NAN)
                    IF COUNTPT GT 1 THEN STRUCT(I).TPP_MEAN  = GEOMEAN(TP(OKPT),/NAN) 
                    IF COUNTPM GT 1 THEN STRUCT(I).MPP_MEAN  = GEOMEAN(MP(OKPM),/NAN)
                    IF COUNTPN GT 1 THEN STRUCT(I).NPP_MEAN  = GEOMEAN(NP(OKPN),/NAN)
                          
                    IF COUNTCT GT 1 THEN STRUCT(I).TCHL_SPATIAL_VAR = VARIANCE(CT(OKCT),/NAN)       ; Variance of the valid CHL and PP data
                    IF COUNTCM GT 1 THEN STRUCT(I).MCHL_SPATIAL_VAR = VARIANCE(CM(OKCM),/NAN)
                    IF COUNTCM GT 1 THEN STRUCT(I).NCHL_SPATIAL_VAR = VARIANCE(CN(OKCN),/NAN)
                    IF COUNTPT GT 1 THEN STRUCT(I).TPP_SPATIAL_VAR  = VARIANCE(TP(OKPT),/NAN)
                    IF COUNTPM GT 1 THEN STRUCT(I).MPP_SPATIAL_VAR  = VARIANCE(MP(OKPM),/NAN)
                    IF COUNTPN GT 1 THEN STRUCT(I).NPP_SPATIAL_VAR  = VARIANCE(NP(OKPN),/NAN)
                    
          	  			IF COUNTPT GT 1 THEN STRUCT(I).TPP_SPATIAL_SUM  = TOTAL(TP(OKPT)*1000000*PTA(OKPT),/NAN) 
                    IF COUNTPM GT 1 THEN STRUCT(I).MPP_SPATIAL_SUM  = TOTAL(MP(OKPM)*1000000*PMA(OKPT),/NAN)
                    IF COUNTPN GT 1 THEN STRUCT(I).NPP_SPATIAL_SUM  = TOTAL(NP(OKPN)*1000000*PNA(OKPT),/NAN)
          	  			
          	  			IF COUNTPT GT 1 THEN STRUCT(I).TPP_MONTHLY_SUM  = STRUCT(I).TPP_SPATIAL_SUM*DAYS_MONTH(MONTHS(MTH),YEAR=YEARS(Y))
          	  			IF COUNTPM GT 1 THEN STRUCT(I).MPP_MONTHLY_SUM  = STRUCT(I).MPP_SPATIAL_SUM*DAYS_MONTH(MONTHS(MTH),YEAR=YEARS(Y))
          	  			IF COUNTPN GT 1 THEN STRUCT(I).NPP_MONTHLY_SUM  = STRUCT(I).NPP_SPATIAL_SUM*DAYS_MONTH(MONTHS(MTH),YEAR=YEARS(Y))
                    
                    I = I+1
      	  			  ENDFOR ; Loop through each MONTH
   	  			  
        			    YSTRUCT(Y).YEAR = YEARS(Y)                      
                  YSTRUCT(Y).MASK = MASKS(M)
                  YSTRUCT(Y).SUBAREA_CODE = ACODE
                  YSTRUCT(Y).SUBAREA_NAME = ANAME
                  YSTRUCT(Y).N_SUBAREA_PIXELS      = STRUCT[0].N_SUBAREA_PIXELS 
                  YSTRUCT(Y).TOTAL_PIXEL_AREA_KM2  = STRUCT[0].TOTAL_PIXEL_AREA_KM2
            
                  OKY = WHERE(STRUCT.YEAR EQ YEARS(Y))
 ; IF YEARS(Y) EQ '1998' AND MASKS(M) EQ 'LME_TOTAL' AND N EQ 0 THEN TEMP = STRUCT(OKY)
 ; IF YEARS(Y) EQ '1998' AND MASKS(M) EQ 'LME_TOTAL' AND N GT 0 THEN TEMP = STRUCT_CONCAT(TEMP,STRUCT(OKY))                
                  YSTRUCT(Y).TCHL_ANNUAL_MEAN    = MEAN(STRUCT(OKY).TCHL_MEAN,/NAN)
                  YSTRUCT(Y).MCHL_ANNUAL_MEAN    = MEAN(STRUCT(OKY).MCHL_MEAN,/NAN)
                  YSTRUCT(Y).NCHL_ANNUAL_MEAN    = MEAN(STRUCT(OKY).NCHL_MEAN,/NAN)
                  
                  YSTRUCT(Y).TPP_ANNUAL_MEAN    = MEAN(STRUCT(OKY).TPP_MEAN,/NAN)*365
                  YSTRUCT(Y).MPP_ANNUAL_MEAN    = MEAN(STRUCT(OKY).MPP_MEAN,/NAN)*365
                  YSTRUCT(Y).NPP_ANNUAL_MEAN    = MEAN(STRUCT(OKY).NPP_MEAN,/NAN)*365
                  YSTRUCT(Y).TPP_ANNUAL_SUM = TOTAL(STRUCT(OKY).TPP_MONTHLY_SUM,/NAN)
                  YSTRUCT(Y).MPP_ANNUAL_SUM = TOTAL(STRUCT(OKY).MPP_MONTHLY_SUM,/NAN)
                  YSTRUCT(Y).NPP_ANNUAL_SUM = TOTAL(STRUCT(OKY).NPP_MONTHLY_SUM,/NAN) 
                  
                  YSTRUCT(Y).TPP_N_MONTHS = N_ELEMENTS(WHERE(STRUCT(OKY).TPP_MONTHLY_SUM NE MISSINGS(0.0)))
                  YSTRUCT(Y).MPP_N_MONTHS = N_ELEMENTS(WHERE(STRUCT(OKY).MPP_MONTHLY_SUM NE MISSINGS(0.0)))
                  YSTRUCT(Y).NPP_N_MONTHS = N_ELEMENTS(WHERE(STRUCT(OKY).NPP_MONTHLY_SUM NE MISSINGS(0.0)))
               
                  YSTRUCT(Y).TPP_ANNUAL_MTON   = YSTRUCT(Y).TPP_ANNUAL_SUM * 1E-6
                  YSTRUCT(Y).MPP_ANNUAL_MTON   = YSTRUCT(Y).MPP_ANNUAL_SUM * 1E-6 
                  YSTRUCT(Y).NPP_ANNUAL_MTON   = YSTRUCT(Y).NPP_ANNUAL_SUM * 1E-6  
                             
      	  			ENDFOR ; Loop through each year
      	  			
                SAVE, FILENAME=MSAVEFILE,STRUCT,/COMPRESS
                SAVE, FILENAME=ASAVEFILE,YSTRUCT,/COMPRESS
                STRUCT_2CSV,MCSVFILE,STRUCT
                STRUCT_2CSV,ACSVFILE,YSTRUCT  
                SKIP_FILE:        
              ENDFOR ; MASKS   
            ENDFOR   ; CODES        
          ENDFOR     ; CODE_TYPE
        ENDFOR       ; SENSORS
        
        ASAVEFILE = DIR_SUMMARY + 'UNCORRECTED_ANNUAL_SUM-'+CHLIN+'-SEA_MOD-LME_FAO-CHL_PRIMARY_PRODUCTION-'+PP_TARGET+'-STATS.SAV'
        ACSVFILE  = DIR_SUMMARY + 'UNCORRECTED_ANNUAL_SUM-'+CHLIN+'-SEA_MOD-LME_FAO-CHL_PRIMARY_PRODUCTION-'+PP_TARGET+'-STATS.CSV'
        FILES = FILE_SEARCH(DIR_STATS + 'ANNUAL_SUM-'+CHLIN+'-'+'*-CHL_PRIMARY_PRODUCTION-'+PP_TARGET+'-STATS.SAV')

        IF FILE_MAKE(FILES,[ASAVEFILE,ACSVFILE],OVERWRITE=OVERWRITE) EQ 0 THEN CONTINUE
        FOR N=0, N_ELEMENTS(NAMES)-1 DO BEGIN
          ANAME = NAMES(N)
          FILES = FILE_SEARCH(DIR_STATS + 'ANNUAL_SUM-'+CHLIN+'-*'+ANAME+'*-CHL_PRIMARY_PRODUCTION-'+PP_TARGET+'-STATS.SAV')
          FOR F=0, N_ELEMENTS(FILES)-1 DO BEGIN
            DATA = IDL_RESTORE(FILES(F))
            IF F EQ 0 THEN SUBSTRUCT = DATA ELSE SUBSTRUCT = STRUCT_CONCAT(DATA,SUBSTRUCT)
          ENDFOR
          SUBSTRUCT = SUBSTRUCT[SORT(SUBSTRUCT.YEAR)]
          IF N EQ 0 THEN OUTSTRUCT = SUBSTRUCT ELSE OUTSTRUCT = STRUCT_CONCAT(OUTSTRUCT,SUBSTRUCT)
        ENDFOR  
        PRINT, 'Writing: ' + ASAVEFILE
        SAVE, FILENAME=ASAVEFILE,OUTSTRUCT,/COMPRESS
        STRUCT_2CSV,ACSVFILE,OUTSTRUCT
      ENDFOR    ; PP_TARGET
    ENDFOR      ; CHLIN    
  ENDIF  ; DO_MONTHLY_SUMS


; *******************************************************
  IF KEY(DO_PP_CORRECTION) THEN BEGIN
; *******************************************************
      SNAME = DO_PP_CORRECTION
      PRINT, 'Running: ' + 'DO_PP_CORRECTION'
      SWITCHES,DO_PP_CORRECTION,STOPP=STOPP,OVERWRITE=OVERWRITE,VERBOSE=VERBOSE,INIT=INIT,R_FILES=R_FILES,R_DATASETS=R_DATASETS,R_MAPS=R_MAPS,DATASETS=DATASETS,DATERANGE=DATERANGE


    SKIP_PNGS       = 1
    REVERSE_OC      = 0
    REVERSE_SENSORS = 0
    REVERSE_PP      = 0
    
    CODE_TYPE = ['LME'];,'FAO']
    PP_TARGETS = ['VGPM2'];,'OPAL']
    PP_CHL_INPUT = ['OCI'];,'PAN']
    IF KEY(REVERSE_OC) THEN PP_CHL_INPUT = REVERSE(PP_CHL_INPUT)
    IF KEY(REVERSE_PP) THEN PP_TARGETS   = REVERSE(PP_TARGETS)
    FOR CHLI=0, N_ELEMENTS(PP_CHL_INPUT)-1 DO BEGIN ; Loop through CHL algorithms
      CHLIN = PP_CHL_INPUT(CHLI)
      IF CHLIN EQ 'PAN' THEN DIR_SAVE = DIR_SAVE_PAN ELSE DIR_SAVE = DIR_SAVE_OC
      FOR TAR=0, N_ELEMENTS(PP_TARGETS)-1 DO BEGIN  ; Loop through PP algorithms
        PP_TARGET = PP_TARGETS(TAR)
        FOR C=0, N_ELEMENTS(CODE_TYPE)-1 DO BEGIN  ; Loop through CODE TYPES
          IF CODE_TYPE(C) EQ 'LME' THEN NAMES = LMES ELSE NAMES = FAO_NAMES
          IF CODE_TYPE(C) EQ 'LME' THEN NMASKS = 3        ELSE NMASKS = 2
          IF CODE_TYPE(C) EQ 'LME' THEN MASKS = LME_MASKS ELSE MASKS = FAO_MASKS
          
          OUTSTRUCT  = []
          OUTYSTRUCT = []

          DIR_CONCAT  = DIR_SAVE + 'PP_CORRECTED_CONCAT' + SL & DIR_TEST, DIR_CONCAT
          MCONCATFILE = DIR_CONCAT + 'MONTHLY_CORRECTED_SUM-' + CHLIN + '-' + CODE_TYPE(C) + '-MERGED_CHL_PP_' + PP_TARGET + '.SAV'
          MCSVCONCAT  = DIR_CONCAT + 'MONTHLY_CORRECTED_SUM-' + CHLIN + '-' + CODE_TYPE(C) + '-MERGED_CHL_PP_' + PP_TARGET + '.CSV'
          ACONCATFILE = DIR_CONCAT + 'ANNUAL_CORRECTED_SUM-'  + CHLIN + '-' + CODE_TYPE(C) + '-MERGED_CHL_PP_' + PP_TARGET + '.SAV'
          ACSVCONCAT  = DIR_CONCAT + 'ANNUAL_CORRECTED_SUM-'  + CHLIN + '-' + CODE_TYPE(C) + '-MERGED_CHL_PP_' + PP_TARGET + '.CSV'
          
          SENSORS = ['MODIS','SEAWIFS']
          IF KEY(REVERSE_SENSORS) THEN SENSORS = REVERSE(SENSORS)
          FOR SEN=0, N_ELEMENTS(SENSORS)-1 DO BEGIN   ; Loop through SENSORS
            SENSOR = SENSORS(SEN)
            CHL  = ['CHLOR_A-'+CHLIN, 'MICRO', 'NANOPICO']        
            PPD  = ['PPD-'+PP_TARGET,'MICROPP','NANOPICOPP','MICROPP_PERCENTAGE','NANOPICOPP_PERCENTAGE'] 
            PRODS = [CHL,PPD]
            DIRS  = DIR_SAVE + PRODS + SL
            YEARS = YEAR_RANGE('1998','2007',/STRING)
            IF STRMID(SENSOR,0,3) EQ 'MOD' THEN YEARS = YEAR_RANGE('2008','2014',/STRING)      
            
            FOR N=0, N_ELEMENTS(NAMES)-1 DO BEGIN    ; Loop through CODES
              ANAME = NAMES(N)
              ; Find the files associated with the appropriate CODE, CHL alg, SENSOR and PRODUCT
              TCHSAVE = FILE_SEARCH(DIRS[0] + 'ALL-' + CHLIN + '-' + CODE_TYPE(C) + '_*' + ANAME + '-' + STRMID(SENSOR,0,3) + '*' + PRODS[0] + '*.SAV')
              MCHSAVE = FILE_SEARCH(DIRS[1] + 'ALL-' + CHLIN + '-' + CODE_TYPE(C) + '_*' + ANAME + '-' + STRMID(SENSOR,0,3) + '*' + PRODS[1] + '*.SAV')
              NCHSAVE = FILE_SEARCH(DIRS(2) + 'ALL-' + CHLIN + '-' + CODE_TYPE(C) + '_*' + ANAME + '-' + STRMID(SENSOR,0,3) + '*' + PRODS(2) + '*.SAV')

              TPPSAVE = FILE_SEARCH(DIRS(3) + 'ALL-' + CHLIN + '-' + CODE_TYPE(C) + '_*' + ANAME + '-' + STRMID(SENSOR,0,3) + '*' + PRODS(3) + '*.SAV')
              MPPSAVE = FILE_SEARCH(DIRS(4) + 'ALL-' + CHLIN + '-' + CODE_TYPE(C) + '_*' + ANAME + '-' + STRMID(SENSOR,0,3) + '*' + PRODS(4) + '*.SAV')
              NPPSAVE = FILE_SEARCH(DIRS(5) + 'ALL-' + CHLIN + '-' + CODE_TYPE(C) + '_*' + ANAME + '-' + STRMID(SENSOR,0,3) + '*' + PRODS(5) + '*.SAV')
              SAVES = [TCHSAVE,MCHSAVE,NCHSAVE,TPPSAVE,MPPSAVE,NPPSAVE]
              POS = STRPOS(TCHSAVE,CODE_TYPE(C)+'_',/REVERSE_SEARCH) + STRLEN(CODE_TYPE(C)+'_')
              ACODE = STRMID(TCHSAVE,POS,2)
              DIR_CSV   = DIR_SAVE + 'PP_CORRECTED-STATS-CSV'  + SL + CODE_TYPE(C) + '_'  + ACODE + '-' + ANAME + SL
              DIR_STATS = DIR_SAVE + 'PP_CORRECTED-STATS-SAVE' + SL
              DIR_PNGS  = DIR_SAVE + 'PP_COMPARE-PNGS' + SL
              DIR_TEST,[DIR_CSV,DIR_STATS,DIR_PNGS]

              TPPDATA = []
              FOR M=0, N_ELEMENTS(MASKS)-1 DO BEGIN  ; Loop through MASKS
                ; Output file names
                MSAVEFILE = DIR_STATS + 'MONTHLY_CORRECTED_SUM-' + CHLIN + '-' + SENSORS(SEN) + '-' + CODE_TYPE(C) + '_' + ACODE + '-' + ANAME + '-' + MASKS(M) + '-CHL_PRIMARY_PRODUCTION-' + PP_TARGET + '-STATS.SAV'
                MCSVFILE  = DIR_CSV   + 'MONTHLY_CORRECTED_SUM-' + CHLIN + '-' + SENSORS(SEN) + '-' + CODE_TYPE(C) + '_' + ACODE + '-' + ANAME + '-' + MASKS(M) + '-CHL_PRIMARY_PRODUCTION-' + PP_TARGET + '-STATS.CSV'
                ASAVEFILE = DIR_STATS + 'ANNUAL_CORRECTED_SUM-'  + CHLIN + '-' + SENSORS(SEN) + '-' + CODE_TYPE(C) + '_' + ACODE + '-' + ANAME + '-' + MASKS(M) + '-PAR_PRIMARY_PRODUCTION-' + PP_TARGET + '-STATS.SAV'
                ACSVFILE  = DIR_CSV   + 'ANNUAL_CORRECTED_SUM-'  + CHLIN + '-' + SENSORS(SEN) + '-' + CODE_TYPE(C) + '_' + ACODE + '-' + ANAME + '-' + MASKS(M) + '-PAR_PRIMARY_PRODUCTION-' + PP_TARGET + '-STATS.CSV'
                PNGFILE   = DIR_PNGS  + 'SUMMED_PP_COMPARISON-'  + CHLIN + '-' + SENSORS(SEN) + '-' + CODE_TYPE(C) + '_' + ACODE + '-' + ANAME + '-' + MASKS(M) + '-' + PP_TARGET + '.PNG'
                PNGMEAN   = DIR_PNGS  + 'MEAN_PP_COMPARISON-'    + CHLIN + '-' + SENSORS(SEN) + '-' + CODE_TYPE(C) + '_' + ACODE + '-' + ANAME + '-' + MASKS(M) + '-' + PP_TARGET + '.PNG'
                
                STRUCT  = []
                YSTRUCT = []
                IF FILE_MAKE(SAVES,[MSAVEFILE,MCSVFILE,ASAVEFILE,ACSVFILE], OVERWRITE=OVERWRITE) EQ 0 THEN GOTO, SKIP_STATS
               
                IF TPPDATA EQ [] THEN BEGIN
                  TCHDATA = IDL_RESTORE(TCHSAVE)
                  MCHDATA = IDL_RESTORE(MCHSAVE)
                  NCHDATA = IDL_RESTORE(NCHSAVE)
                  TPPDATA = IDL_RESTORE(TPPSAVE)
                  MPPDATA = IDL_RESTORE(MPPSAVE)
                  NPPDATA = IDL_RESTORE(NPPSAVE)
                  TAGS   = TAG_NAMES(TPPDATA)
                ENDIF
                IF MAX(STRPOS(TAGS,MASKS(M))) LT 0 THEN CONTINUE
                
                TITLE = SENSORS(SEN) + '-' + STR_PAD(ACODE,2) + '-' + ANAME + '-' + MASKS(M)
                PRINT, 'Correcting PP stats for: ' + SENSORS(SEN) + '-' + STR_PAD(ACODE,2) + '-' + ANAME + '-' + MASKS(M) + '-' + PP_TARGET + '_' + CHLIN
           
                STRUCT = CREATE_STRUCT('SENSOR','','CHL_ALG','','PP_ALG','','YEAR',0L,'MONTH','','MASK','','SUBAREA_NAME','','SUBAREA_CODE',0L,$ ; Set up MONTHLY output structure
                  'N_SUBAREA_PIXELS',0L,'TOTAL_PIXEL_AREA_KM2',0.0D,$                                    ; Pixel area information
                  ; Total, Micro and Nano-pico Chlorophyll data
                  'TCHL_N_PIXELS',       0L,     'MCHL_N_PIXELS',       0L,       'NCHL_N_PIXELS',       0L,  $  ; Number of valid CHL pixels
                  'TCHL_PIXEL_AREA',     0.0D,   'MCHL_PIXEL_AREA',     0.0D,     'NCHL_PIXEL_AREA',     0.0D,$  ; Area of valid pixels ?
                  'TCHL_MEAN',           0.0,    'MCHL_MEAN',           0.0,      'NCHL_MEAN',           0.0, $  ; Mean CHL
                  'TCHL_SPATIAL_VAR',    0.0,    'MCHL_SPATIAL_VAR',    0.0,      'NCHL_SPATIAL_VAR',    0.0, $  ; CHL spatial variance
                  
                  ; Monthly Total PP data
                  'TPP_N_PIXELS',        0L,     'TPPCLIM_N_PIXELS',       0L,    'TPP_N_MISSING_PIXELS',   0L,   $  ; Number of pixels
                  'TPP_PIXEL_AREA',      0.0D,   'TPPCLIM_PIXEL_AREA',     0.0D,  'TPP_MISSING_PIXEL_AREA', 0.0D, $  ; Area of pixels
                  'TPP_MEAN',            0.0D,   'TPPCLIM_MEAN',            0.0D,$  ; Mean TPP
                  'TPP_SPATIAL_VAR',     0.0D,   'TPPCLIM_SPATIAL_VAR',     0.0D,$  ; PP spatial variance
                  'TPP_SPATIAL_SUM',     0.0D,   'TPPCLIM_SPATIAL_SUM',     0.0D,$  ; Sum of TPP pixels within the subarea
                  'TPP_MONTHLY_SUM',     0.0D,   'TPPCLIM_MONTHLY_SUM',     0.0D,$  ; Sum of TPP pixels converted from per day to per month
                  
                  ; Monthly Micro PP data
                  'MPP_N_PIXELS',        0L,     'MPPCLIM_N_PIXELS',       0L,    'MPP_N_MISSING_PIXELS',   0L,   $  ; Number of pixels
                  'MPP_PIXEL_AREA',      0.0D,   'MPPCLIM_PIXEL_AREA',     0.0D,  'MPP_MISSING_PIXEL_AREA', 0.0D, $  ; Area of pixels
                  'MPP_MEAN',            0.0D,   'MPPCLIM_MEAN',           0.0D,$  ; Mean MPP
                  'MPP_SPATIAL_VAR',     0.0D,   'MPPCLIM_SPATIAL_VAR',    0.0D,$  ; PP spatial variance
                  'MPP_SPATIAL_SUM',     0.0D,   'MPPCLIM_SPATIAL_SUM',    0.0D,$  ; Sum of MPP pixels within the subarea
                  'MPP_MONTHLY_SUM',     0.0D,   'MPPCLIM_MONTHLY_SUM',    0.0D,$  ; Sum of MPP pixels converted from per day to per month
                  
                  ; Monthly Nano-pico NPP data
                  'NPP_N_PIXELS',        0L,     'NPPCLIM_N_PIXELS',       0L,    'NPP_N_MISSING_PIXELS',   0L,   $  ; Number of pixels
                  'NPP_PIXEL_AREA',      0.0D,   'NPPCLIM_PIXEL_AREA',     0.0D,  'NPP_MISSING_PIXEL_AREA', 0.0D, $  ; Area of pixels
                  'NPP_MEAN',            0.0D,   'NPPCLIM_MEAN',           0.0D,$  ; Mean NPP
                  'NPP_SPATIAL_VAR',     0.0D,   'NPPCLIM_SPATIAL_VAR',    0.0D,$  ; NPP spatial variance
                  'NPP_SPATIAL_SUM',     0.0D,   'NPPCLIM_SPATIAL_SUM',    0.0D,$  ; Sum of NPP pixels within the subarea
                  'NPP_MONTHLY_SUM',     0.0D,   'NPPCLIM_MONTHLY_SUM',    0.0D)   ; Sum of NPP pixels converted from per day to per month
                  
                MONTHS = MONTH_RANGE(/STRING)
                STRUCT = REPLICATE(STRUCT_2MISSINGS(STRUCT),N_ELEMENTS(YEARS)*12)

                YSTRUCT = CREATE_STRUCT('YEAR',0L,'SENSOR','','CHL_ALG','','PP_ALG','','MASK','','SUBAREA_NAME','','SUBAREA_CODE',0L,$ ; Set up ANNUAL output structure
                  'N_SUBAREA_PIXELS',0L,   'TOTAL_PIXEL_AREA_KM2',0.0D,$                                ; Pixel area information
                  ; Annual mean CHL
                  'TCHL_ANNUAL_MEAN',0.0,  'MCHL_ANNUAL_MEAN',    0.0,  'NCHL_ANNUAL_MEAN',0.0,$  
                  
                  ; Annual Total PP data
                  'TPP_N_MONTHS',    0L,   'TPP_CLIM_N_MONTHS',   0L,   $ ; Number of months used to calculate the annual summed TPP
                  'TPP_ANNUAL_MEAN', 0.0,  'TPP_CLIM_ANNUAL_MEAN',0.0,  $ ; Annual mean TPP
                  'TPP_DAILY_MEAN',  0.0,  'TPP_CLIM_DAILY_MEAN', 0.0,  $ ; Annual daily mean TPP
                  'TPP_ANNUAL_SUM',  0.0D, 'TPP_CLIM_ANNUAL_SUM', 0.0D, $ ; Annual sum
                  'TPP_ANNUAL_MTON', 0.0D, 'TPP_CLIM_ANNUAL_MTON',0.0D, $ ; Annual PP sum converted to million tons
                  'TPP_ANNUAL_TTON', 0.0D, 'TPP_CLIM_ANNUAL_TTON',0.0D, $ ; Annual PP sum converted to thousand metric tons
                  
                  ; Annual Micro PP data
                  'MPP_N_MONTHS',    0L,   'MPP_CLIM_N_MONTHS',   0L,   $ ; Number of months used to calculate the annual summed MPP
                  'MPP_ANNUAL_MEAN', 0.0,  'MPP_CLIM_ANNUAL_MEAN',0.0,  $ ; Annual mean MPP
                  'MPP_DAILY_MEAN',  0.0,  'MPP_CLIM_DAILY_MEAN', 0.0,  $ ; Annual daily mean MPP
                  'MPP_ANNUAL_SUM',  0.0D, 'MPP_CLIM_ANNUAL_SUM', 0.0D, $ ; Annual sum
                  'MPP_ANNUAL_MTON', 0.0D, 'MPP_CLIM_ANNUAL_MTON',0.0D, $ ; Annual MPP sum converted to metric tons
                  'MPP_ANNUAL_TTON', 0.0D, 'MPP_CLIM_ANNUAL_TTON',0.0D, $ ; Annual MPP sum converted to thousand metric tons
                  
                  ; Annual Nano-Pico PP data
                  'NPP_N_MONTHS',    0L,   'NPP_CLIM_N_MONTHS',   0L,   $ ; Number of months used to calculate the annual summed NPP
                  'NPP_ANNUAL_MEAN', 0.0,  'NPP_CLIM_ANNUAL_MEAN',0.0,  $ ; Annual mean NPP
                  'NPP_DAILY_MEAN',  0.0,  'NPP_CLIM_DAILY_MEAN', 0.0,  $ ; Annual daily mean NPP
                  'NPP_ANNUAL_SUM',  0.0D, 'NPP_CLIM_ANNUAL_SUM', 0.0D, $ ; Annual sum
                  'NPP_ANNUAL_MTON', 0.0D, 'NPP_CLIM_ANNUAL_MTON',0.0D, $ ; Annual NPP sum converted to metric tons
                  'NPP_ANNUAL_TTON', 0.0D, 'NPP_CLIM_ANNUAL_TTON',0.0D)   ; Annual MPP sum converted to thousand metric tons
                YSTRUCT = REPLICATE(STRUCT_2MISSINGS(YSTRUCT),N_ELEMENTS(YEARS))
                I = -1
                STRUCT.SENSOR  = SENSORS(SEN) & YSTRUCT.SENSOR  = SENSORS(SEN)
                STRUCT.PP_ALG  = PP_TARGET    & YSTRUCT.PP_ALG  = PP_TARGET
                STRUCT.CHL_ALG = CHLIN        & YSTRUCT.CHL_ALG = CHLIN

                FOR Y=0, N_ELEMENTS(YEARS)-1 DO BEGIN
                  FOR MTH=0, N_ELEMENTS(MONTHS)-1 DO BEGIN
                    I = I+1
                    STRUCT(I).YEAR = YEARS(Y)
                    STRUCT(I).MONTH = MONTHS(MTH)
                    STRUCT(I).MASK = MASKS(M)
                    STRUCT(I).SUBAREA_CODE = ACODE
                    STRUCT(I).SUBAREA_NAME = ANAME
                    CASE STRUCT(I).MASK OF
                      'LME_TOTAL'     : STRUCT(I).N_SUBAREA_PIXELS = N_ELEMENTS(TPPDATA.LME_TOTAL_AREA) ; Number of pixels within the subarea
                      'LME_LT_300'    : STRUCT(I).N_SUBAREA_PIXELS = N_ELEMENTS(TPPDATA.LME_LT_300_AREA)
                      'LME_GT_300'    : STRUCT(I).N_SUBAREA_PIXELS = N_ELEMENTS(TPPDATA.LME_GT_300_AREA)
                      'FAO_TOTAL'     : STRUCT(I).N_SUBAREA_PIXELS = N_ELEMENTS(TPPDATA.FAO_TOTAL_AREA)
                      'FAO_MINUS_LME' : STRUCT(I).N_SUBAREA_PIXELS = N_ELEMENTS(TPPDATA.FAO_MINUS_LME_AREA)
                    ENDCASE

                    CASE STRUCT(I).MASK OF
                      'LME_TOTAL'      : STRUCT(I).TOTAL_PIXEL_AREA_KM2 = TOTAL(TPPDATA.LME_TOTAL_AREA,/NAN) ; Total area of the pixels within the subarea
                      'LME_LT_300'     : STRUCT(I).TOTAL_PIXEL_AREA_KM2 = TOTAL(TPPDATA.LME_LT_300_AREA,/NAN)
                      'LME_GT_300'     : STRUCT(I).TOTAL_PIXEL_AREA_KM2 = TOTAL(TPPDATA.LME_GT_300_AREA,/NAN)
                      'FAO_TOTAL'      : STRUCT(I).TOTAL_PIXEL_AREA_KM2 = TOTAL(TPPDATA.FAO_TOTAL_AREA,/NAN)
                      'FAO_MINUS_LME'  : STRUCT(I).TOTAL_PIXEL_AREA_KM2 = TOTAL(TPPDATA.FAO_MINUS_LME_AREA,/NAN)
                    ENDCASE
                    
                    TN = TAG_NAMES(TPPDATA)
                    OK = WHERE(STRMID(TN,0,5) EQ 'MONTH' AND STRMID(TN,6,2) EQ MONTHS(MTH),COUNT)
                    MPERIOD = STRMID(TN[OK],0,8)
                    MTAG = MPERIOD[0] + MASKS(M)
                    PTAG = 'M_' + YEARS(Y) + MONTHS(MTH) + '_' + MASKS(M) ; Input structure tag
                    ATAG = STRUCT(I).MASK + '_AREA'                       ; Pixel area tag
                   
                    TCPOS = WHERE(TAG_NAMES(TCHDATA) EQ PTAG) & TACOS = WHERE(TAG_NAMES(TCHDATA) EQ ATAG) & TMCOS = WHERE(STRMID(TAG_NAMES(TCHDATA),0,8) EQ MPERIOD[0] AND STRMID(TAG_NAMES(TCHDATA),19) EQ MASKS(M))
                    MCPOS = WHERE(TAG_NAMES(MCHDATA) EQ PTAG) & MACOS = WHERE(TAG_NAMES(MCHDATA) EQ ATAG) & MMCOS = WHERE(STRMID(TAG_NAMES(MCHDATA),0,8) EQ MPERIOD[1] AND STRMID(TAG_NAMES(MCHDATA),19) EQ MASKS(M))
                    NCPOS = WHERE(TAG_NAMES(NCHDATA) EQ PTAG) & NACOS = WHERE(TAG_NAMES(NCHDATA) EQ ATAG) & NMCOS = WHERE(STRMID(TAG_NAMES(NCHDATA),0,8) EQ MPERIOD(2) AND STRMID(TAG_NAMES(NCHDATA),19) EQ MASKS(M))
                    TPPOS = WHERE(TAG_NAMES(TPPDATA) EQ PTAG) & TAPOS = WHERE(TAG_NAMES(TPPDATA) EQ ATAG) & TMPOS = WHERE(STRMID(TAG_NAMES(TPPDATA),0,8) EQ MPERIOD[0] AND STRMID(TAG_NAMES(TPPDATA),19) EQ MASKS(M))
                    MPPOS = WHERE(TAG_NAMES(MPPDATA) EQ PTAG) & MAPOS = WHERE(TAG_NAMES(MPPDATA) EQ ATAG) & MMPOS = WHERE(STRMID(TAG_NAMES(MPPDATA),0,8) EQ MPERIOD[1] AND STRMID(TAG_NAMES(MPPDATA),19) EQ MASKS(M))
                    NPPOS = WHERE(TAG_NAMES(NPPDATA) EQ PTAG) & NAPOS = WHERE(TAG_NAMES(NPPDATA) EQ ATAG) & NMPOS = WHERE(STRMID(TAG_NAMES(NPPDATA),0,8) EQ MPERIOD(2) AND STRMID(TAG_NAMES(NPPDATA),19) EQ MASKS(M))
                    IF TPPOS EQ -1 OR MPPOS EQ -1 OR TCPOS EQ -1 OR MCPOS EQ -1 THEN CONTINUE
                    
                    CT = TCHDATA.(TCPOS) & CTA = TCHDATA.(TACOS)                       ; M Data & Pixel area for each PROD
                    CM = MCHDATA.(MCPOS) & CMA = MCHDATA.(MACOS)  
                    CN = NCHDATA.(NCPOS) & CNA = NCHDATA.(NACOS) 
                    TP = TPPDATA.(TPPOS) & TA = TPPDATA.(TAPOS) & TL = TPPDATA.(TMPOS) ; M/MONTH Data & Pixel area for each PROD
                    MP = MPPDATA.(MPPOS) & MA = MPPDATA.(MAPOS) & ML = MPPDATA.(MMPOS)
                    NP = NPPDATA.(NPPOS) & NA = NPPDATA.(NAPOS) & NL = NPPDATA.(NMPOS)
                    
                    OK = WHERE(CT EQ 0,COUNT0T) & IF COUNT0T GT 0 THEN CT[OK] = MISSINGS(0.0) ; Replace 0 values with missings
                    OK = WHERE(CM EQ 0,COUNT0M) & IF COUNT0M GT 0 THEN CM[OK] = MISSINGS(0.0)
                    OK = WHERE(CN EQ 0,COUNT0N) & IF COUNT0N GT 0 THEN CN[OK] = MISSINGS(0.0)
                    OK = WHERE(TP EQ 0,COUNT0T) & IF COUNT0T GT 0 THEN TP[OK] = MISSINGS(0.0) ; Replace 0 values with missings
                    OK = WHERE(MP EQ 0,COUNT0M) & IF COUNT0M GT 0 THEN MP[OK] = MISSINGS(0.0)
                    OK = WHERE(NP EQ 0,COUNT0N) & IF COUNT0N GT 0 THEN NP[OK] = MISSINGS(0.0)

                    OKTC = WHERE(CT NE MISSINGS(0.0),COUNTCT,COMPLEMENT=NO_TC) ; Find non-missing data
                    OKMC = WHERE(CM NE MISSINGS(0.0),COUNTCM,COMPLEMENT=NO_MC)
                    OKNC = WHERE(CN NE MISSINGS(0.0),COUNTCN,COMPLEMENT=NO_NC)
                    OKTP = WHERE(TP NE MISSINGS(0.0),COUNTTP,COMPLEMENT=NO_TP) ; Find non-missing data
                    OKMP = WHERE(MP NE MISSINGS(0.0),COUNTMP,COMPLEMENT=NO_MP) 
                    OKNP = WHERE(NP NE MISSINGS(0.0),COUNTNP,COMPLEMENT=NO_NP) 
                    
                    OKTM = WHERE(TL GT 0 AND TL NE MISSINGS(0.0),COUNTTM,COMPLEMENT=NO_TM) ; Find where MONTH data is non-missing
                    OKMM = WHERE(ML GT 0 AND ML NE MISSINGS(0.0),COUNTMM,COMPLEMENT=NO_MM)
                    OKNM = WHERE(NL GT 0 AND NL NE MISSINGS(0.0),COUNTNM,COMPLEMENT=NO_NM)
                    
                    OKTF = WHERE(TP EQ MISSINGS(0.0) AND TL NE MISSINGS(0.0) AND TL GT 0,COUNTTF) ; Find where to Fill in missing pixels with MONTH data
                    OKMF = WHERE(MP EQ MISSINGS(0.0) AND ML NE MISSINGS(0.0) AND ML GT 0,COUNTMF) 
                    OKNF = WHERE(NP EQ MISSINGS(0.0) AND NL NE MISSINGS(0.0) AND NL GT 0,COUNTNF) 
            
                    IF COUNTTF EQ 0 AND COUNTTP GE 9 THEN TPCLIM = TP(OKTP) ELSE IF COUNTTP GE 9 THEN BEGIN & TPCLIM = [TP(OKTP),TL(OKTF)] & IF N_ELEMENTS(TPCLIM) NE COUNTTM THEN STOP & ENDIF ELSE TPCLIM = [] ; Fill in missing pixels with climatology pixels and check to makes sure the number of observations are within 1 pixels (often there is a difference of 1 pixel)
                    IF COUNTMF EQ 0 AND COUNTMP GE 9 THEN MPCLIM = MP(OKMP) ELSE IF COUNTMP GE 9 THEN BEGIN & MPCLIM = [MP(OKMP),ML(OKMF)] & IF N_ELEMENTS(MPCLIM) NE COUNTMM THEN STOP & ENDIF ELSE MPCLIM = [] ; (want a minimum of 9 valid pixels)
                    IF COUNTNF EQ 0 AND COUNTNP GE 9 THEN NPCLIM = NP(OKNP) ELSE IF COUNTNP GE 9 THEN BEGIN & NPCLIM = [NP(OKNP),NL(OKNF)] & IF N_ELEMENTS(NPCLIM) NE COUNTNM THEN STOP & ENDIF ELSE NPCLIM = [] 
                   
                    IF TPCLIM EQ [] THEN TACLIM = 0.0 ELSE BEGIN & IF COUNTTF EQ 0 THEN TACLIM = TA(OKTP) ELSE TACLIM = [TA(OKTP),TA(OKTF)] & IF N_ELEMENTS(TACLIM) NE COUNTTM THEN STOP & ENDELSE ; Determine the area of the valid + filled in climatology pixesl and check to make sure the number of observations match up
                    IF MPCLIM EQ [] THEN MACLIM = 0.0 ELSE BEGIN & IF COUNTMF EQ 0 THEN MACLIM = MA(OKMP) ELSE MACLIM = [MA(OKMP),MA(OKMF)] & IF N_ELEMENTS(MACLIM) NE COUNTMM THEN STOP & ENDELSE
                    IF NPCLIM EQ [] THEN NACLIM = 0.0 ELSE BEGIN & IF COUNTNF EQ 0 THEN NACLIM = NA(OKNP) ELSE NACLIM = [NA(OKNP),NA(OKNF)] & IF N_ELEMENTS(NACLIM) NE COUNTNM THEN STOP & ENDELSE
             
                    STRUCT(I).TCHL_N_PIXELS            = COUNTCT                          ; Number of valid TOTAL CHL pixels
                    STRUCT(I).MCHL_N_PIXELS            = COUNTCM                          ; Number of valid MICRO CHL pixels
                    STRUCT(I).NCHL_N_PIXELS            = COUNTCN                          ; Number of valid NANO-PICO CHL pixels
                    STRUCT(I).TPP_N_PIXELS             = COUNTTP                          ; Number of valid TOTAL PP pixels
                    STRUCT(I).MPP_N_PIXELS             = COUNTMP                          ; Number of valid MICRO PP pixels
                    STRUCT(I).NPP_N_PIXELS             = COUNTNP                          ; Number of valid NANO-PICO PP pixels
                    
                    STRUCT(I).TPPCLIM_N_PIXELS         = COUNTTM                          ; Number of valid MONTHLY TOTAL PP pixels
                    STRUCT(I).MPPCLIM_N_PIXELS         = COUNTMM                          ; Number of valid MONTHLY MICRO PP pixels
                    STRUCT(I).NPPCLIM_N_PIXELS         = COUNTNM                          ; Number of valid MONTHLY NANO-PICO PP pixels
                    
                    STRUCT(I).TPP_N_MISSING_PIXELS     = COUNTTF                          ; Number of missing TOTAL PP pixels to be filled in with climatology data
                    STRUCT(I).MPP_N_MISSING_PIXELS     = COUNTMF                          ; Number of missing MICRO PP pixels to be filled in with climatology data
                    STRUCT(I).NPP_N_MISSING_PIXELS     = COUNTNF                          ; Number of missing NANO-PICO PP pixels to be filled in with climatology data
                    
                    IF COUNTTP LT 10 THEN CONTINUE                                        ; If less than 10 valid pixels then continue
                    STRUCT(I).TCHL_PIXEL_AREA          = TOTAL(CTA(OKTC),/NAN)            ; Area of the valid TOTAL CHL pixels
                    STRUCT(I).MCHL_PIXEL_AREA          = TOTAL(CMA(OKMC),/NAN)            ; Area of the valid MICRO CHL pixels
                    STRUCT(I).NCHL_PIXEL_AREA          = TOTAL(CNA(OKNC),/NAN)            ; Area of the valid NANO-PICO CHL pixels
                    STRUCT(I).TPP_PIXEL_AREA           = TOTAL(TA(OKTP),/NAN)             ; Area of the valid TOTAL PP pixels
                    STRUCT(I).MPP_PIXEL_AREA           = TOTAL(MA(OKMP),/NAN)             ; Area of the valid MICRO PP pixels
                    STRUCT(I).NPP_PIXEL_AREA           = TOTAL(NA(OKNP),/NAN)             ; Area of the valid NANO-PICO PP pixels
                  
                    STRUCT(I).TPP_MISSING_PIXEL_AREA   = TOTAL(TA(NO_TP),/NAN)            ; Area of the missing TOTAL PP pixels
                    STRUCT(I).MPP_MISSING_PIXEL_AREA   = TOTAL(MA(NO_MP),/NAN)            ; Area of the missing MICRO PP pixels
                    STRUCT(I).NPP_MISSING_PIXEL_AREA   = TOTAL(NA(NO_NP),/NAN)            ; Area of the missing NANO-PICO PP pixels
                   
                    STRUCT(I).TPPCLIM_PIXEL_AREA = TOTAL(TL(OKTM),/NAN)                   ; Area of the TOTAL PP CLIMATOLOGY pixels
                    STRUCT(I).MPPCLIM_PIXEL_AREA = TOTAL(ML(OKMM),/NAN)                   ; Area of the MICRO PP CLIMATOLOGY pixels
                    STRUCT(I).NPPCLIM_PIXEL_AREA = TOTAL(NL(OKNM),/NAN)                   ; Area of the NANO-PICO PP CLIMATOLOGY pixels
                   
                    STRUCT(I).TCHL_MEAN = GEOMEAN(CT(OKTC),/NAN)                          ; Geometric mean of the valid TOTAL CHL data
                    STRUCT(I).MCHL_MEAN = GEOMEAN(CM(OKMC),/NAN)                          ; Geometric mean of the valid MICRO CHL data
                    STRUCT(I).NCHL_MEAN = GEOMEAN(CN(OKNC),/NAN)                          ; Geometric mean of the valid NANO-PICO CHL data
                    STRUCT(I).TPP_MEAN  = GEOMEAN(TP(OKTP),/NAN)                          ; Geometric mean of the valid TOTAL PP data
                    STRUCT(I).MPP_MEAN  = GEOMEAN(MP(OKMP),/NAN)                          ; Geometric mean of the valid MICRO PP data
                    STRUCT(I).NPP_MEAN  = GEOMEAN(NP(OKNP),/NAN)                          ; Geometric mean of the valid NANO-PICO PP data
                      
                    STRUCT(I).TPPCLIM_MEAN = GEOMEAN(TL(OKTM),/NAN)                       ; Geometrict mean of the valid MONTHLY TOTAL PP data
                    STRUCT(I).MPPCLIM_MEAN = GEOMEAN(ML(OKMM),/NAN)                       ; Geometrict mean of the valid MONTHLY MICRO PP data
                    STRUCT(I).NPPCLIM_MEAN = GEOMEAN(NL(OKNM),/NAN)                       ; Geometrict mean of the valid MONTHLY NANO-PICO PP data
                        
                    STRUCT(I).TCHL_SPATIAL_VAR = VARIANCE(CT(OKTC),/NAN)                  ; Spatial variance of the valid TOTAL CHL data
                    STRUCT(I).MCHL_SPATIAL_VAR = VARIANCE(CM(OKMC),/NAN)                  ; Spatial variance of the valid MICRO CHL data
                    STRUCT(I).NCHL_SPATIAL_VAR = VARIANCE(CN(OKNC),/NAN)                  ; Spatial variance of the valid NANO-PICO CHL data
                    STRUCT(I).TPP_SPATIAL_VAR  = VARIANCE(TP(OKTP),/NAN)                  ; Spatial variance of the valid TOTAL PP data
                    STRUCT(I).MPP_SPATIAL_VAR  = VARIANCE(MP(OKMP),/NAN)                  ; Spatial variance of the valid MICRO PP data
                    STRUCT(I).NPP_SPATIAL_VAR  = VARIANCE(NP(OKNP),/NAN)                  ; Spatial variance of the valid NANO-PICO PP data
                    
                    STRUCT(I).TPP_SPATIAL_SUM  = TOTAL(TP(OKTP)*1000000*TA(OKTP),/NAN)    ; Spatial sum of the valid TOTAL PP data     * 1000000 m^2/km^2 * area of the valid pixels = (gC/subarea/day)
                    STRUCT(I).MPP_SPATIAL_SUM  = TOTAL(MP(OKMP)*1000000*MA(OKMP),/NAN)    ; Spatial sum of the valid MICRO PP data     * 1000000 m^2/km^2 * area of the valid pixels = (gC/subarea/day)
                    STRUCT(I).NPP_SPATIAL_SUM  = TOTAL(NP(OKNP)*1000000*NA(OKNP),/NAN)    ; Spatial sum of the valid NANO-PICO PP data * 1000000 m^2/km^2 * area of the valid pixels = (gC/subarea/day)
                    
                    STRUCT(I).TPP_MONTHLY_SUM   = STRUCT(I).TPP_SPATIAL_SUM*DAYS_MONTH(MONTHS(MTH),YEAR=YEARS(Y)) ; Spatial monthly sum of valid TOTAL PP     * days/month = (gC/subarea/month)
                    STRUCT(I).MPP_MONTHLY_SUM   = STRUCT(I).MPP_SPATIAL_SUM*DAYS_MONTH(MONTHS(MTH),YEAR=YEARS(Y)) ; Spatial monthly sum of valid MICRO PP     * days/month = (gC/subarea/month)
                    STRUCT(I).NPP_MONTHLY_SUM   = STRUCT(I).NPP_SPATIAL_SUM*DAYS_MONTH(MONTHS(MTH),YEAR=YEARS(Y)) ; Spatial monthly sum of valid NANO-PICO PP * days/month = (gC/subarea/month)
                    
                    IF TPCLIM EQ [] OR MPPCLIM EQ [] THEN CONTINUE                        ; If no climatology corrected data then continue
                    STRUCT(I).TPPCLIM_MEAN = GEOMEAN(TPCLIM,/NAN)                         ; Geometric mean of the valid + climatology filled TOTAL PP pixels
                    STRUCT(I).MPPCLIM_MEAN = GEOMEAN(MPCLIM,/NAN)                         ; Geometric mean of the valid + climatology filled MICRO PP pixels
                    STRUCT(I).NPPCLIM_MEAN = GEOMEAN(NPCLIM,/NAN)                         ; Geometric mean of the valid + climatology filled NANO-PICO PP pixels
                    
                    STRUCT(I).TPPCLIM_SPATIAL_VAR = VARIANCE(TPCLIM,/NAN)                 ; Variance mean of the valid + climatology filled TOTAL PP pixels
                    STRUCT(I).MPPCLIM_SPATIAL_VAR = VARIANCE(MPCLIM,/NAN)                 ; Variance mean of the valid + climatology filled MICRO PP pixels
                    STRUCT(I).NPPCLIM_SPATIAL_VAR = VARIANCE(NPCLIM,/NAN)                 ; Variance mean of the valid + climatology filled NANO-PICO PP pixels
                    
                    STRUCT(I).TPPCLIM_SPATIAL_SUM = TOTAL(TPCLIM*1000000*TACLIM,/NAN)     ; Spatial sum of the valid + climatology filled TOTAL PP data     * 1000000 m^2/km^2 * area of the valid + climatology pixels = (gC/subarea/day)
                    STRUCT(I).MPPCLIM_SPATIAL_SUM = TOTAL(MPCLIM*1000000*MACLIM,/NAN)     ; Spatial sum of the valid + climatology filled MICRO PP data     * 1000000 m^2/km^2 * area of the valid + climatology pixels = (gC/subarea/day)
                    STRUCT(I).NPPCLIM_SPATIAL_SUM = TOTAL(NPCLIM*1000000*NACLIM,/NAN)     ; Spatial sum of the valid + climatology filled NANO-PICO PP data * 1000000 m^2/km^2 * area of the valid + climatology pixels = (gC/subarea/day)
                    
                    STRUCT(I).TPPCLIM_MONTHLY_SUM = STRUCT(I).TPPCLIM_SPATIAL_SUM*DAYS_MONTH(MONTHS(MTH),YEAR=YEARS(Y)) ; Spatial monthly sum of valid + climatology TOTAL PP     * days/month = (gC/subarea/month)
                    STRUCT(I).MPPCLIM_MONTHLY_SUM = STRUCT(I).MPPCLIM_SPATIAL_SUM*DAYS_MONTH(MONTHS(MTH),YEAR=YEARS(Y)) ; Spatial monthly sum of valid + climatology MICRO PP     * days/month = (gC/subarea/month)
                    STRUCT(I).NPPCLIM_MONTHLY_SUM = STRUCT(I).NPPCLIM_SPATIAL_SUM*DAYS_MONTH(MONTHS(MTH),YEAR=YEARS(Y)) ; Spatial monthly sum of valid + climatology NANO-PICO PP * days/month = (gC/subarea/month)

                  ENDFOR ; Loop through each MONTH
                  
                  YSTRUCT(Y).YEAR                  = YEARS(Y)
                  YSTRUCT(Y).MASK                  = MASKS(M)
                  YSTRUCT(Y).SUBAREA_CODE          = ACODE
                  YSTRUCT(Y).SUBAREA_NAME          = ANAME
                  YSTRUCT(Y).N_SUBAREA_PIXELS      = STRUCT[0].N_SUBAREA_PIXELS
                  YSTRUCT(Y).TOTAL_PIXEL_AREA_KM2  = STRUCT[0].TOTAL_PIXEL_AREA_KM2

                  OKY = WHERE(STRUCT.YEAR EQ YEARS(Y))
                  
                  YSTRUCT(Y).TCHL_ANNUAL_MEAN      = MEAN(STRUCT(OKY).TCHL_MEAN,/NAN) ; Mean of the monthly mean valid TOTAL PP (gC/m^2/day)
                  YSTRUCT(Y).MCHL_ANNUAL_MEAN      = MEAN(STRUCT(OKY).MCHL_MEAN,/NAN) ; Mean of the monthly mean valid MICRO PP (gC/m^2/day)
                  YSTRUCT(Y).NCHL_ANNUAL_MEAN      = MEAN(STRUCT(OKY).NCHL_MEAN,/NAN) ; Mean of the monthly mean valid NANO-PICO PP (gC/m^2/day)

                  YSTRUCT(Y).TPP_DAILY_MEAN        = MEAN(STRUCT(OKY).TPP_MEAN,/NAN) ; Mean of the monthly mean valid TOTAL PP (gC/m^2/day)
                  YSTRUCT(Y).MPP_DAILY_MEAN        = MEAN(STRUCT(OKY).MPP_MEAN,/NAN) ; Mean of the monthly mean valid MICRO PP (gC/m^2/day)
                  YSTRUCT(Y).NPP_DAILY_MEAN        = MEAN(STRUCT(OKY).NPP_MEAN,/NAN) ; Mean of the monthly mean valid NANO-PICO PP (gC/m^2/day)
                  
                  YSTRUCT(Y).TPP_ANNUAL_MEAN       = MEAN(STRUCT(OKY).TPP_MEAN,/NAN)*365 ; Mean of the monthly mean valid TOTAL PP * 365 days/yr (gC/m^2/yr)
                  YSTRUCT(Y).MPP_ANNUAL_MEAN       = MEAN(STRUCT(OKY).MPP_MEAN,/NAN)*365 ; Mean of the monthly mean valid MICRO PP * 365 days/yr (gC/m^2/yr)
                  YSTRUCT(Y).NPP_ANNUAL_MEAN       = MEAN(STRUCT(OKY).NPP_MEAN,/NAN)*365 ; Mean of the monthly mean valid NANO-PICO PP * 365 days/yr (gC/m^2/yr)
                  
                  YSTRUCT(Y).TPP_ANNUAL_SUM        = TOTAL(STRUCT(OKY).TPP_MONTHLY_SUM,/NAN) ; Sum of the monthly sums for the valid TOTAL PP pixels (gC/subarea/year)
                  YSTRUCT(Y).MPP_ANNUAL_SUM        = TOTAL(STRUCT(OKY).MPP_MONTHLY_SUM,/NAN) ; Sum of the monthly sums for the valid MICRO PP pixels (gC/subarea/year)
                  YSTRUCT(Y).NPP_ANNUAL_SUM        = TOTAL(STRUCT(OKY).NPP_MONTHLY_SUM,/NAN) ; Sum of the monthly sums for the valid NANO-PICO PP pixels (gC/subarea/year)
                  
                  YSTRUCT(Y).TPP_N_MONTHS          = N_ELEMENTS(WHERE(STRUCT(OKY).TPP_MONTHLY_SUM NE MISSINGS(0.0))) ; Number of months with valid TOTAL PP data
                  YSTRUCT(Y).MPP_N_MONTHS          = N_ELEMENTS(WHERE(STRUCT(OKY).MPP_MONTHLY_SUM NE MISSINGS(0.0))) ; Number of months with valid MICRO PP data
                  YSTRUCT(Y).NPP_N_MONTHS          = N_ELEMENTS(WHERE(STRUCT(OKY).NPP_MONTHLY_SUM NE MISSINGS(0.0))) ; Number of months with valid NANO-PICO PP data
                  
                  YSTRUCT(Y).TPP_ANNUAL_MTON       = YSTRUCT(Y).TPP_ANNUAL_SUM * 1E-6 ; Convert the valid TOTAL PP sum to metric ton (mton/subarea/year)
                  YSTRUCT(Y).MPP_ANNUAL_MTON       = YSTRUCT(Y).MPP_ANNUAL_SUM * 1E-6 ; Convert the valid MICRO PP sum to metric ton (mton/subarea/year)
                  YSTRUCT(Y).NPP_ANNUAL_MTON       = YSTRUCT(Y).NPP_ANNUAL_SUM * 1E-6 ; Convert the valid NANO-PICO PP sum to metric ton (mton/subarea/year)

                  YSTRUCT(Y).TPP_ANNUAL_TTON       = YSTRUCT(Y).TPP_ANNUAL_MTON/1000 ; Convert the valid TOTAL PP sum to thousand metric ton (mton/subarea/year)
                  YSTRUCT(Y).MPP_ANNUAL_TTON       = YSTRUCT(Y).MPP_ANNUAL_MTON/1000 ; Convert the valid MICRO PP sum to thousand metric ton (mton/subarea/year)
                  YSTRUCT(Y).NPP_ANNUAL_TTON       = YSTRUCT(Y).NPP_ANNUAL_MTON/1000 ; Convert the valid NANO-PICO PP sum to thousand metric ton (mton/subarea/year)

                  YSTRUCT(Y).TPP_CLIM_DAILY_MEAN  = MEAN(STRUCT(OKY).TPPCLIM_MEAN,/NAN) ; Mean of the monthly mean climatology corrected TOTAL PP (gC/m^2/day)
                  YSTRUCT(Y).MPP_CLIM_DAILY_MEAN  = MEAN(STRUCT(OKY).MPPCLIM_MEAN,/NAN) ; Mean of the monthly mean climatology corrected MICRO PP (gC/m^2/day)
                  YSTRUCT(Y).NPP_CLIM_DAILY_MEAN  = MEAN(STRUCT(OKY).NPPCLIM_MEAN,/NAN) ; Mean of the monthly mean climatology corrected NANO-PICO PP (gC/m^2/day)

                  YSTRUCT(Y).TPP_CLIM_ANNUAL_MEAN  = MEAN(STRUCT(OKY).TPPCLIM_MEAN,/NAN)*365 ; Mean of the monthly mean climatology corrected TOTAL PP * 365 days/yr (gC/m^2/yr)
                  YSTRUCT(Y).MPP_CLIM_ANNUAL_MEAN  = MEAN(STRUCT(OKY).MPPCLIM_MEAN,/NAN)*365 ; Mean of the monthly mean climatology corrected MICRO PP * 365 days/yr (gC/m^2/yr)
                  YSTRUCT(Y).NPP_CLIM_ANNUAL_MEAN  = MEAN(STRUCT(OKY).NPPCLIM_MEAN,/NAN)*365 ; Mean of the monthly mean climatology corrected NANO-PICO PP * 365 days/yr (gC/m^2/yr)
                  
                  YSTRUCT(Y).TPP_CLIM_ANNUAL_SUM   = TOTAL(STRUCT(OKY).TPPCLIM_MONTHLY_SUM,/NAN) ; Sum of the monthly sums for the climatology corrected TOTAL PP pixels (gC/subarea/year)
                  YSTRUCT(Y).MPP_CLIM_ANNUAL_SUM   = TOTAL(STRUCT(OKY).MPPCLIM_MONTHLY_SUM,/NAN) ; Sum of the monthly sums for the climatology corrected MICRO PP pixels (gC/subarea/year)
                  YSTRUCT(Y).NPP_CLIM_ANNUAL_SUM   = TOTAL(STRUCT(OKY).NPPCLIM_MONTHLY_SUM,/NAN) ; Sum of the monthly sums for the climatology corrected NANO-PICO PP pixels (gC/subarea/year)
                  
                  YSTRUCT(Y).TPP_CLIM_N_MONTHS     = N_ELEMENTS(WHERE(STRUCT(OKY).TPPCLIM_MONTHLY_SUM NE MISSINGS(0.0))) ; Number of months with climatology corrected TOTAL PP data
                  YSTRUCT(Y).MPP_CLIM_N_MONTHS     = N_ELEMENTS(WHERE(STRUCT(OKY).MPPCLIM_MONTHLY_SUM NE MISSINGS(0.0))) ; Number of months with climatology corrected MICRO PP data
                  YSTRUCT(Y).NPP_CLIM_N_MONTHS     = N_ELEMENTS(WHERE(STRUCT(OKY).NPPCLIM_MONTHLY_SUM NE MISSINGS(0.0))) ; Number of months with climatology corrected NANO-PICO PP data
               
                  YSTRUCT(Y).TPP_CLIM_ANNUAL_MTON  = YSTRUCT(Y).TPP_CLIM_ANNUAL_SUM * 1E-6  ; Convert the climatology corrected TOTAL PP sum to million metric ton (mton/subarea/year)
                  YSTRUCT(Y).MPP_CLIM_ANNUAL_MTON  = YSTRUCT(Y).MPP_CLIM_ANNUAL_SUM * 1E-6  ; Convert the climatology corrected MICRO PP sum to million metric ton (mton/subarea/year)
                  YSTRUCT(Y).NPP_CLIM_ANNUAL_MTON  = YSTRUCT(Y).NPP_CLIM_ANNUAL_SUM * 1E-6  ; Convert the climatology corrected NANO-PICO PP sum to million metric ton (mton/subarea/year)
               
                  YSTRUCT(Y).TPP_CLIM_ANNUAL_TTON  = YSTRUCT(Y).TPP_CLIM_ANNUAL_MTON/1000  ; Convert the climatology corrected TOTAL PP sum to thousand metric ton (mton/subarea/year)
                  YSTRUCT(Y).MPP_CLIM_ANNUAL_TTON  = YSTRUCT(Y).MPP_CLIM_ANNUAL_MTON/1000  ; Convert the climatology corrected MICRO PP sum to thousand metric ton (mton/subarea/year)
                  YSTRUCT(Y).NPP_CLIM_ANNUAL_TTON  = YSTRUCT(Y).NPP_CLIM_ANNUAL_MTON/1000  ; Convert the climatology corrected NANO-PICO PP sum to thousand metric ton (mton/subarea/year)
  
                ENDFOR ; Loop through each year
                
                SAVE, FILENAME=MSAVEFILE,STRUCT,/COMPRESS
                SAVE, FILENAME=ASAVEFILE,YSTRUCT,/COMPRESS
                STRUCT_2CSV,MCSVFILE,STRUCT
                STRUCT_2CSV,ACSVFILE,YSTRUCT

                SKIP_STATS:
                IF KEY(SKIP_PNGS) THEN GOTO, SKIP_PNGFILE
                
                IF FILE_MAKE([MSAVEFILE,ASAVEFILE],PNGMEAN,OVERWRITE=OVERWRTE) EQ 0 THEN GOTO, SKIP_PNGMEAN
                IF  STRUCT EQ [] THEN  STRUCT = IDL_RESTORE(MSAVEFILE)
                IF YSTRUCT EQ [] THEN YSTRUCT = IDL_RESTORE(ASAVEFILE)
                BUFFER = 1
                NBARS = 6
                
                W  = WINDOW(DIMENSIONS=[900,1200],BUFFER=BUFFER)
                BR = BARPLOT(YSTRUCT.YEAR,YSTRUCT.TPP_ANNUAL_MEAN,      INDEX=0, NBARS=NBARS, FILL_COLOR='RED', POSITION=[.12,.8,.85,.95],FONT_STYLE='BOLD',MARGIN=[0.125,0.1,0.05,0.1], TITLE=TITLE, XMINOR=0, XTICKINTERVAL=1, YTITLE=UNITS('PPY'), XTITLE='Year',/CURRENT)
                BR = BARPLOT(YSTRUCT.YEAR,YSTRUCT.TPP_CLIM_ANNUAL_MEAN, INDEX=1, NBARS=NBARS, FILL_COLOR='CYAN', /OVERPLOT)
                
                BR = BARPLOT(YSTRUCT.YEAR,YSTRUCT.MPP_ANNUAL_MEAN,      INDEX=2, NBARS=NBARS, FILL_COLOR='NAVY', /OVERPLOT)
                BR = BARPLOT(YSTRUCT.YEAR,YSTRUCT.MPP_CLIM_ANNUAL_MEAN, INDEX=3, NBARS=NBARS, FILL_COLOR='SPRING_GREEN', /OVERPLOT)
                
                BR = BARPLOT(YSTRUCT.YEAR,YSTRUCT.NPP_ANNUAL_MEAN,      INDEX=4, NBARS=NBARS, FILL_COLOR='ORANGE', /OVERPLOT)
                BR = BARPLOT(YSTRUCT.YEAR,YSTRUCT.NPP_CLIM_ANNUAL_MEAN, INDEX=5, NBARS=NBARS, FILL_COLOR='ROYAL_BLUE', /OVERPLOT)

                FOR MTH=0, N_ELEMENTS(MONTHS)-1 DO BEGIN
                  OK = WHERE(STRUCT.MONTH EQ MONTHS(MTH))
                  MSTR = STRUCT[OK]
                  MSTR = MSTR[SORT(MSTR.YEAR)]
                  IF MIN(MSTR.TPP_MEAN) EQ MISSINGS(MSTR.TPP_MEAN) THEN CONTINUE
                  LAYOUT = [4,4,5+MTH]
                  YTITLE = UNITS('PPD')
                  MARGIN = [0.2,0.1,0.07,0.1]
                  BR1 = BARPLOT(MSTR.YEAR,MSTR.TPP_MEAN,     INDEX=0, NBARS=NBARS, FILL_COLOR='RED',LAYOUT=LAYOUT,MARGIN=MARGIN,FONT_STYLE='BOLD',TITLE=MONTH_NAMES(MONTHS(MTH)),XMINOR=1,XTICKINTERVAL=2,YTITLE=YTITLE,/CURRENT)
                  BR1 = BARPLOT(MSTR.YEAR,MSTR.TPPCLIM_MEAN, INDEX=1, NBARS=NBARS, FILL_COLOR='CYAN',        /OVERPLOT)
                  BR1 = BARPLOT(MSTR.YEAR,MSTR.MPP_MEAN,     INDEX=2, NBARS=NBARS, FILL_COLOR='NAVY',        /OVERPLOT)
                  BR1 = BARPLOT(MSTR.YEAR,MSTR.MPPCLIM_MEAN, INDEX=3, NBARS=NBARS, FILL_COLOR='SPRING_GREEN',/OVERPLOT)
                  BR1 = BARPLOT(MSTR.YEAR,MSTR.NPP_MEAN,     INDEX=4, NBARS=NBARS, FILL_COLOR='ORANGE',      /OVERPLOT)
                  BR1 = BARPLOT(MSTR.YEAR,MSTR.NPPCLIM_MEAN, INDEX=5, NBARS=NBARS, FILL_COLOR='ROYAL_BLUE',  /OVERPLOT) 
                  BR1.XTICKNAME = YEAR_2YY(BR1.XTICKNAME)
                ENDFOR

                T = TEXT(0.855,0.94,'Org. Total',          FONT_STYLE='BOLD',FONT_COLOR='RED',         /NORMAL)
                T = TEXT(0.855,0.91,'Clim. Cor. Total',    FONT_STYLE='BOLD',FONT_COLOR='CYAN',        /NORMAL)
                T = TEXT(0.855,0.88,'Org. Micro',          FONT_STYLE='BOLD',FONT_COLOR='NAVY',        /NORMAL)
                T = TEXT(0.855,0.85,'Clim. Cor. Micro',    FONT_STYLE='BOLD',FONT_COLOR='SPRING_GREEN',/NORMAL)
                T = TEXT(0.855,0.82,'Org. Nano-pico',      FONT_STYLE='BOLD',FONT_COLOR='ORANGE',      /NORMAL)
                T = TEXT(0.855,0.79,'Clim. Cor. Nano-pico',FONT_STYLE='BOLD',FONT_COLOR='ROYAL_BLUE',  /NORMAL)

                PRINT, 'Writing: ' + PNGMEAN
                W.SAVE,PNGMEAN,RESOLUTION=300
                W.CLOSE
                SKIP_PNGMEAN:

                IF FILE_MAKE([MSAVEFILE,ASAVEFILE],PNGFILE,OVERWRITE=OVERWRITE) EQ 0 THEN GOTO, SKIP_PNGFILE
                IF  STRUCT EQ [] THEN  STRUCT = IDL_RESTORE(MSAVEFILE)
                IF YSTRUCT EQ [] THEN YSTRUCT = IDL_RESTORE(ASAVEFILE)
                BUFFER = 1
                NBARS = 6
                W  = WINDOW(DIMENSIONS=[900,1200],BUFFER=BUFFER)
                BR = BARPLOT(YSTRUCT.YEAR,YSTRUCT.TPP_ANNUAL_MTON*1E-6,     INDEX=0, NBARS=NBARS, FILL_COLOR='RED', POSITION=[.12,.8,.85,.95],FONT_STYLE='BOLD',MARGIN=[0.125,0.1,0.05,0.1], TITLE=TITLE, XMINOR=0, XTICKINTERVAL=1, YTITLE='PP (gC/subarea/yr)', XTITLE='Year',/CURRENT)
                BR = BARPLOT(YSTRUCT.YEAR,YSTRUCT.TPP_CLIM_ANNUAL_MTON*1E-6,INDEX=1, NBARS=NBARS, FILL_COLOR='CYAN', /OVERPLOT)

                BR = BARPLOT(YSTRUCT.YEAR,YSTRUCT.MPP_ANNUAL_MTON*1E-6,     INDEX=2, NBARS=NBARS, FILL_COLOR='NAVY', /OVERPLOT)
                BR = BARPLOT(YSTRUCT.YEAR,YSTRUCT.MPP_CLIM_ANNUAL_MTON*1E-6,INDEX=3, NBARS=NBARS, FILL_COLOR='SPRING_GREEN', /OVERPLOT)

                BR = BARPLOT(YSTRUCT.YEAR,YSTRUCT.NPP_ANNUAL_MTON*1E-6,     INDEX=4, NBARS=NBARS, FILL_COLOR='ORANGE', /OVERPLOT)
                BR = BARPLOT(YSTRUCT.YEAR,YSTRUCT.NPP_CLIM_ANNUAL_MTON*1E-6,INDEX=5, NBARS=NBARS, FILL_COLOR='ROYAL_BLUE', /OVERPLOT)

                FOR MTH=0, N_ELEMENTS(MONTHS)-1 DO BEGIN
                  OK = WHERE(STRUCT.MONTH EQ MONTHS(MTH))
                  MSTR = STRUCT[OK]
                  MSTR = MSTR[SORT(MSTR.YEAR)]
                  IF MIN(MSTR.TPP_MONTHLY_SUM) EQ MISSINGS(MSTR.TPP_MONTHLY_SUM) OR MAX(MSTR.TPP_MONTHLY_SUM) EQ 0.0 THEN CONTINUE
                  LAYOUT = [4,4,5+MTH]
                  YTITLE = 'Monthly PP'
                  MARGIN = [0.2,0.1,0.07,0.1]
                  
                  BR1 = BARPLOT(MSTR.YEAR,MSTR.TPP_MONTHLY_SUM*1E-12,     INDEX=0, NBARS=NBARS, FILL_COLOR='RED',LAYOUT=LAYOUT,MARGIN=MARGIN,FONT_STYLE='BOLD',TITLE=MONTH_NAMES(MONTHS(MTH)),XMINOR=1,XTICKINTERVAL=2,YTITLE='PP (gC/subarea/month)',/CURRENT)
                  BR1 = BARPLOT(MSTR.YEAR,MSTR.TPPCLIM_MONTHLY_SUM*1E-12, INDEX=1, NBARS=NBARS, FILL_COLOR='CYAN',        /OVERPLOT)
                  BR1 = BARPLOT(MSTR.YEAR,MSTR.MPP_MONTHLY_SUM*1E-12,     INDEX=2, NBARS=NBARS, FILL_COLOR='NAVY',        /OVERPLOT)
                  BR1 = BARPLOT(MSTR.YEAR,MSTR.MPPCLIM_MONTHLY_SUM*1E-12, INDEX=3, NBARS=NBARS, FILL_COLOR='SPRING_GREEN',/OVERPLOT)
                  BR1 = BARPLOT(MSTR.YEAR,MSTR.NPP_MONTHLY_SUM*1E-12,     INDEX=4, NBARS=NBARS, FILL_COLOR='ORANGE',      /OVERPLOT)
                  BR1 = BARPLOT(MSTR.YEAR,MSTR.NPPCLIM_MONTHLY_SUM*1E-12, INDEX=5, NBARS=NBARS, FILL_COLOR='ROYAL_BLUE',  /OVERPLOT)
                  BR1.XTICKNAME = YEAR_2YY(BR1.XTICKNAME)
                ENDFOR

                T = TEXT(0.855,0.94,'Org. Total',          FONT_STYLE='BOLD',FONT_COLOR='RED',         /NORMAL)
                T = TEXT(0.855,0.91,'Clim. Cor. Total',    FONT_STYLE='BOLD',FONT_COLOR='CYAN',        /NORMAL)
                T = TEXT(0.855,0.88,'Org. Micro',          FONT_STYLE='BOLD',FONT_COLOR='NAVY',        /NORMAL)
                T = TEXT(0.855,0.85,'Clim. Cor. Micro',    FONT_STYLE='BOLD',FONT_COLOR='SPRING_GREEN',/NORMAL)
                T = TEXT(0.855,0.82,'Org. Nano-pico',      FONT_STYLE='BOLD',FONT_COLOR='ORANGE',      /NORMAL)
                T = TEXT(0.855,0.79,'Clim. Cor. Nano-pico',FONT_STYLE='BOLD',FONT_COLOR='ROYAL_BLUE',  /NORMAL)
            
                PRINT, 'Writing: ' + PNGFILE
                W.SAVE,PNGFILE,RESOLUTION=300
                W.CLOSE
                SKIP_PNGFILE:
                
                GONE, STRUCT
                GONE, YSTRUCT
                IF OUTSTRUCT  EQ [] THEN OUTSTRUCT  = IDL_RESTORE(MSAVEFILE) ELSE OUTSTRUCT  = STRUCT_CONCAT(OUTSTRUCT,IDL_RESTORE(MSAVEFILE))
                IF OUTYSTRUCT EQ [] THEN OUTYSTRUCT = IDL_RESTORE(ASAVEFILE) ELSE OUTYSTRUCT = STRUCT_CONCAT(OUTYSTRUCT,IDL_RESTORE(ASAVEFILE))
              ENDFOR ; MASKS
              GONE, TPPDATA
              GONE, MPPDATA
              GONE, NPPDATA
            ENDFOR   ; CODE
          ENDFOR     ; SENSORS
          
          OUT_MONTH = OUTSTRUCT[SORT(ADD_STR_ZERO(OUTSTRUCT.SUBAREA_CODE)+OUTSTRUCT.MASK+NUM2STR(OUTSTRUCT.YEAR)+NUM2STR(OUTSTRUCT.MONTH))]
          OUT_YEAR  = OUTYSTRUCT[SORT(ADD_STR_ZERO(OUTYSTRUCT.SUBAREA_CODE)+OUTYSTRUCT.MASK+NUM2STR(OUTYSTRUCT.YEAR))]
          
          PRINT, 'Writing: ' + MCONCATFILE
          SAVE, FILENAME=MCONCATFILE,OUT_MONTH,/COMPRESS
          SAVE, FILENAME=ACONCATFILE,OUT_YEAR,/COMPRESS
          STRUCT_2CSV,MCSVCONCAT,OUT_MONTH
          STRUCT_2CSV,ACSVCONCAT,OUT_YEAR
          GONE, OUTSTRUCT
          GONE, OUTYSTRUCT
        ENDFOR       ; CODE_TYPE
      ENDFOR         ; PP_TARGETS
    ENDFOR           ; PP_CHL_INPUT
  ENDIF              ; DO_PP_CORRECTION

; *******************************************************
  IF DO_PP_CONCATENATE GE 1 THEN BEGIN
; *******************************************************
    OVERWRITE = DO_PP_CONCATENATE GE 2
    
    CODE_TYPE = ['LME','FAO']
    LME_MASKS = ['LME_TOTAL','LME_LT_300','LME_GT_300']
    FAO_MASKS = ['FAO_TOTAL','FAO_MINUS_LME']
    
    SENSORS    = ['SEAWIFS','MODIS']
    PP_TARGETS = ['VGPM2','OPAL']
    PP_CHL_INPUT = ['OC']
    
    FOR CHLI=0, N_ELEMENTS(PP_CHL_INPUT)-1 DO BEGIN ; Loop through CHL algorithms
      CHLIN = PP_CHL_INPUT(CHLI)
      DIR_IN = DIR_PROJECTS + 'DATA_BY_SUBAREA_' + CHLIN + SL + 'PP_CORRECTED_CONCAT' + SL
      FOR C=0, N_ELEMENTS(CODE_TYPE)-1 DO BEGIN     ; Loop through CODE types
        CASE CODE_TYPE(C) OF
          'LME': MASKS = LME_MASKS    
          'FAO': MASKS = FAO_MASKS
        ENDCASE
        SAVEFILE = DIR_SUMMARY + 'ANNUAL_CORRECTED_SUM-' + CHLIN + '-' + CODE_TYPE(C) + '-MERGED_CHL_PP_DATA.SAV' 
        CSVFILE  = DIR_SUMMARY + 'ANNUAL_CORRECTED_SUM-' + CHLIN + '-' + CODE_TYPE(C) + '-MERGED_CHL_PP_DATA.CSV'
        FILES  = FILE_SEARCH(DIR_IN + 'ANNUAL_CORRECTED_SUM-' + CHLIN + '*' + CODE_TYPE(C) + '*CHL_PRIMARY_PRODUCTION-*-STATS.SAV')
        IF FILE_MAKE(FILES,[SAVEFILE,CSVFILE],OVERWRITE=OVERWRITE) EQ 0 THEN CONTINUE
        FOR S=0, N_ELEMENTS(SENSORS)-1 DO BEGIN     
          FOR P=0, N_ELEMENTS(PP_TARGETS)-1 DO BEGIN
            FILES  = FILE_SEARCH(DIR_IN + 'ANNUAL_CORRECTED_SUM-' + CHLIN + '-' + SENSORS(S) + '*' + CODE_TYPE(C) + '*CHL_PRIMARY_PRODUCTION-'+PP_TARGETS(P)+'-STATS.SAV')
            STR = IDL_RESTORE(FILES)
            IF P EQ 0 THEN STR = STRUCT_COPY(STR,TAGNAMES=['YEAR','SENSOR','SUBAREA_CODE','SUBAREA_NAME','MASK','TCHL_ANNUAL_MEAN','MCHL_ANNUAL_MEAN','NCHL_ANNUAL_MEAN',$
                                            'TPP_CLIM_DAILY_MEAN','MPP_CLIM_DAILY_MEAN','NPP_CLIM_DAILY_MEAN','TPP_CLIM_ANNUAL_TTON','MPP_CLIM_ANNUAL_TTON','NPP_CLIM_ANNUAL_TTON'])$
                      ELSE STR = STRUCT_COPY(STR,TAGNAMES=['YEAR','SENSOR','SUBAREA_CODE','SUBAREA_NAME','MASK',$
                                            'TPP_CLIM_DAILY_MEAN','MPP_CLIM_DAILY_MEAN','NPP_CLIM_DAILY_MEAN','TPP_CLIM_ANNUAL_TTON','MPP_CLIM_ANNUAL_TTON','NPP_CLIM_ANNUAL_TTON'])

            IF P EQ 0 THEN STR = STRUCT_RENAME(STR,['TCHL_ANNUAL_MEAN',    'MCHL_ANNUAL_MEAN',    'NCHL_ANNUAL_MEAN'],    ['TOTAL_CHL','MICRO_CHL','NANO_CHL'])
            STR = STRUCT_RENAME(STR,['TPP_CLIM_DAILY_MEAN', 'MPP_CLIM_DAILY_MEAN', 'NPP_CLIM_DAILY_MEAN'], ['TOTAL_PP_', 'MICRO_PP_', 'NANO_PP_'] +PP_TARGETS(P))
            STR = STRUCT_RENAME(STR,['TPP_CLIM_ANNUAL_TTON','MPP_CLIM_ANNUAL_TTON','NPP_CLIM_ANNUAL_TTON'],['TOTAL_',    'MICRO_',    'NANO_']    +PP_TARGETS(P))
            IF P EQ 0 THEN STRUCT = STR ELSE STRUCT = STRUCT_JOIN(STRUCT,STR,TAGNAMES=['YEAR','SENSOR','SUBAREA_NAME','SUBAREA_CODE','MASK'])
          ENDFOR  
          STRUCT = STRUCT[SORT(ROUNDS(STRUCT.YEAR)+'_'+ADD_STR_ZERO(STRUCT.SUBAREA_CODE)+'_'+STRUCT.MASK)]
          IF S EQ 0 THEN CSTR = STRUCT ELSE CSTR = STRUCT_CONCAT(CSTR,STRUCT)  
        ENDFOR
        SETS = WHERE_SETS(CSTR.SUBAREA_NAME)
        FOR S=0, N_ELEMENTS(SETS)-1 DO BEGIN
          SUBS = WHERE_SETS_SUBS(SETS(S))
          SET  = CSTR(SUBS)
          MSETS = WHERE_SETS(SET.MASK)
          FOR M=0, N_ELEMENTS(MSETS)-1 DO BEGIN
            SUBS = WHERE_SETS_SUBS(MSETS(M))
            MSET = SET(SUBS)
            MASK = MSET[0].MASK
            CASE MASK OF
              'LME_TOTAL'    : TAG = 'ALL'
              'LME_LT_300'   : TAG = 'LT300'
              'LME_GT_300'   : TAG = 'GT300'
              'FAO_TOTAL'    : TAG = 'ALL'
              'FAO_MINUS_LME': TAG = 'NOLME'
            ENDCASE
            MSET = STRUCT_RENAME(MSET,['TOTAL_CHL',        'MICRO_CHL',        'NANO_CHL',        'TOTAL_PP_VGPM2',        'MICRO_PP_VGPM2',        'NANO_PP_VGPM2',        'TOTAL_PP_OPAL',        'MICRO_PP_OPAL',        'NANO_PP_OPAL'          ],$
                                      ['TOTAL_'+TAG+'_CHL','MICRO_'+TAG+'_CHL','NANO_'+TAG+'_CHL','TOTAL_'+TAG+'_PP_VGPM2','MICRO_'+TAG+'_PP_VGPM2','NANO_'+TAG+'_PP_VGPM2','TOTAL_'+TAG+'_PP_OPAL','MICRO_'+TAG+'_PP_OPAL','NANO_'+TAG+'_PP_OPAL'])
            MSET = STRUCT_RENAME(MSET,['TOTAL_VGPM2',        'MICRO_VGPM2',        'NANO_VGPM2',        'TOTAL_OPAL',        'MICRO_OPAL',        'NANO_OPAL'],$
                                      ['TOTAL_'+TAG+'_VGPM2','MICRO_'+TAG+'_VGPM2','NANO_'+TAG+'_VGPM2','TOTAL_'+TAG+'_OPAL','MICRO_'+TAG+'_OPAL','NANO_'+TAG+'_OPAL']) 
            MSET = STRUCT_COPY(MSET,TAGNAMES='MASK',/REMOVE)
            IF M EQ 0 THEN OSET = MSET ELSE OSET = STRUCT_JOIN(OSET,MSET,TAGNAMES=['YEAR','SENSOR','SUBAREA_CODE','SUBAREA_NAME'])
          ENDFOR  
          IF S EQ 0 THEN FSTRUCT = OSET ELSE FSTRUCT = STRUCT_CONCAT(FSTRUCT,OSET)
        ENDFOR  
        
        FSTRUCT = FSTRUCT[SORT(ADD_STR_ZERO(FSTRUCT.SUBAREA_CODE)+ROUNDS(FSTRUCT.YEAR))]         
        SAVE, FILENAME=SAVEFILE,FSTRUCT,/COMPRESS
        STRUCT_2CSV,CSVFILE,FSTRUCT
      ENDFOR ; CODE_TYPE
    ENDFOR ; PP_CHL_INPUT
    
    FOR CHLI=0, N_ELEMENTS(PP_CHL_INPUT)-1 DO BEGIN ; Loop through CHL algorithms
      CHLIN = PP_CHL_INPUT(CHLI)
      DIR_IN = DIR_PROJECTS + 'DATA_BY_SUBAREA_' + CHLIN + SL + 'PP_CORRECTED_CONCAT' + SL
      FOR C=0, N_ELEMENTS(CODE_TYPE)-1 DO BEGIN     ; Loop through CODE types
        CASE CODE_TYPE(C) OF
          'LME': MASKS = LME_MASKS
          'FAO': MASKS = FAO_MASKS
        ENDCASE
        SAVEFILE = DIR_SUMMARY + 'MONTHLY_CORRECTED_SUM-' + CHLIN + '-' + CODE_TYPE(C) + '-MERGED_CHL_PP_DATA.SAV'
        CSVFILE  = DIR_SUMMARY + 'MONTHLY_CORRECTED_SUM-' + CHLIN + '-' + CODE_TYPE(C) + '-MERGED_CHL_PP_DATA.CSV'
        FILES  = FILE_SEARCH(DIR_IN + 'MONTHLY_CORRECTED_SUM-' + CHLIN + '*' + CODE_TYPE(C) + '*CHL_PRIMARY_PRODUCTION-*-STATS.SAV')
        IF FILE_MAKE(FILES,[SAVEFILE,CSVFILE],OVERWRITE=OVERWRITE) EQ 0 THEN CONTINUE
        FOR S=0, N_ELEMENTS(SENSORS)-1 DO BEGIN
          FOR P=0, N_ELEMENTS(PP_TARGETS)-1 DO BEGIN
            FILES  = FILE_SEARCH(DIR_IN + 'MONTHLY_CORRECTED_SUM-' + CHLIN + '-' + SENSORS(S) + '*' + CODE_TYPE(C) + '*CHL_PRIMARY_PRODUCTION-'+PP_TARGETS(P)+'-STATS.SAV')
            STR = IDL_RESTORE(FILES)
            IF P EQ 0 THEN STR = STRUCT_COPY(STR,TAGNAMES=['YEAR','MONTH','SENSOR','SUBAREA_CODE','SUBAREA_NAME','MASK','TCHL_MEAN','MCHL_MEAN','NCHL_MEAN',$
              'TPPCLIM_MEAN','MPPCLIM_MEAN','NPPCLIM_MEAN'])$
            ELSE STR = STRUCT_COPY(STR,TAGNAMES=['YEAR','MONTH','SENSOR','SUBAREA_CODE','SUBAREA_NAME','MASK',$
              'TPPCLIM_MEAN','MPPCLIM_MEAN','NPPCLIM_MEAN'])

            IF P EQ 0 THEN STR = STRUCT_RENAME(STR,['TCHL_MEAN',    'MCHL_MEAN',    'NCHL_MEAN'],    ['TOTAL_CHL','MICRO_CHL','NANO_CHL'])
            STR = STRUCT_RENAME(STR,['TPPCLIM_MEAN', 'MPPCLIM_MEAN', 'NPPCLIM_MEAN'], ['TOTAL_PP_', 'MICRO_PP_', 'NANO_PP_'] +PP_TARGETS(P))
            IF P EQ 0 THEN STRUCT = STR ELSE STRUCT = STRUCT_JOIN(STRUCT,STR,TAGNAMES=['YEAR','MONTH','SENSOR','SUBAREA_NAME','SUBAREA_CODE','MASK'])
          ENDFOR
          STRUCT = STRUCT[SORT(ROUNDS(STRUCT.YEAR)+'_'+ADD_STR_ZERO(STRUCT.SUBAREA_CODE)+'_'+STRUCT.MASK)]
          IF S EQ 0 THEN CSTR = STRUCT ELSE CSTR = STRUCT_CONCAT(CSTR,STRUCT)
        ENDFOR
        SETS = WHERE_SETS(CSTR.SUBAREA_NAME)
        FOR S=0, N_ELEMENTS(SETS)-1 DO BEGIN
          SUBS = WHERE_SETS_SUBS(SETS(S))
          SET  = CSTR(SUBS)
          MSETS = WHERE_SETS(SET.MASK)
          FOR M=0, N_ELEMENTS(MSETS)-1 DO BEGIN
            SUBS = WHERE_SETS_SUBS(MSETS(M))
            MSET = SET(SUBS)
            MASK = MSET[0].MASK
            CASE MASK OF
              'LME_TOTAL'    : TAG = 'ALL'
              'LME_LT_300'   : TAG = 'LT300'
              'LME_GT_300'   : TAG = 'GT300'
              'FAO_TOTAL'    : TAG = 'ALL'
              'FAO_MINUS_LME': TAG = 'NOLME'
            ENDCASE
            MSET = STRUCT_RENAME(MSET,['TOTAL_CHL',        'MICRO_CHL',        'NANO_CHL',        'TOTAL_PP_VGPM2',        'MICRO_PP_VGPM2',        'NANO_PP_VGPM2',        'TOTAL_PP_OPAL',        'MICRO_PP_OPAL',        'NANO_PP_OPAL'          ],$
              ['TOTAL_'+TAG+'_CHL','MICRO_'+TAG+'_CHL','NANO_'+TAG+'_CHL','TOTAL_'+TAG+'_PP_VGPM2','MICRO_'+TAG+'_PP_VGPM2','NANO_'+TAG+'_PP_VGPM2','TOTAL_'+TAG+'_PP_OPAL','MICRO_'+TAG+'_PP_OPAL','NANO_'+TAG+'_PP_OPAL'])
            ;MSET = STRUCT_RENAME(MSET,['TOTAL_VGPM2',        'MICRO_VGPM2',        'NANO_VGPM2',        'TOTAL_OPAL',        'MICRO_OPAL',        'NANO_OPAL'],$
            ;  ['TOTAL_'+TAG+'_VGPM2','MICRO_'+TAG+'_VGPM2','NANO_'+TAG+'_VGPM2','TOTAL_'+TAG+'_OPAL','MICRO_'+TAG+'_OPAL','NANO_'+TAG+'_OPAL'])
            MSET = STRUCT_COPY(MSET,TAGNAMES='MASK',/REMOVE)
            IF M EQ 0 THEN OSET = MSET ELSE OSET = STRUCT_JOIN(OSET,MSET,TAGNAMES=['YEAR','MONTH','SENSOR','SUBAREA_CODE','SUBAREA_NAME'])
          ENDFOR
          IF S EQ 0 THEN FSTRUCT = OSET ELSE FSTRUCT = STRUCT_CONCAT(FSTRUCT,OSET)
        ENDFOR

        FSTRUCT = FSTRUCT[SORT(ADD_STR_ZERO(FSTRUCT.SUBAREA_CODE)+NUM2STR(FSTRUCT.YEAR)+NUM2STR(FSTRUCT.MONTH))]
        SAVE, FILENAME=SAVEFILE,FSTRUCT,/COMPRESS
        STRUCT_2CSV,CSVFILE,FSTRUCT
      ENDFOR ; CODE_TYPE
    ENDFOR ; PP_CHL_INPUT   
  ENDIF ; DO_PP_CONCATENATE

; *******************************************************
  IF DO_PP_CLIM_ANN_MEAN GE 1 THEN BEGIN
; *******************************************************
    OVERWRITE = DO_PP_CLIM_ANN_MEAN GE 2

    CODE_TYPE = ['LME','FAO']
    LME_MASKS = ['LME_TOTAL','LME_LT_300','LME_GT_300']
    FAO_MASKS = ['FAO_TOTAL','FAO_MINUS_LME']

    SENSORS    = ['SEAWIFS','MODIS']
    PP_TARGETS = ['VGPM2','OPAL']
    PP_CHL_INPUT = ['OC']

    FOR CHLI=0, N_ELEMENTS(PP_CHL_INPUT)-1 DO BEGIN ; Loop through CHL algorithms
      CHLIN = PP_CHL_INPUT(CHLI)
      DIR_IN = DIR_PROJECTS + 'DATA_BY_SUBAREA_' + CHLIN + SL + 'PP_CORRECTED_CONCAT' + SL
      FOR C=0, N_ELEMENTS(CODE_TYPE)-1 DO BEGIN     ; Loop through CODE types
        CASE CODE_TYPE(C) OF
          'LME': MASKS = LME_MASKS
          'FAO': MASKS = FAO_MASKS
        ENDCASE
        SAVEFILE = DIR_SUMMARY + 'CLIMATOLOGICAL_ANNUAL_MEAN_CORRECTED-' + CHLIN + '-' + CODE_TYPE(C) + '-MERGED_CHL_PP_DATA.SAV'
        CSVFILE  = DIR_SUMMARY + 'CLIMATOLOGICAL_ANNUAL_MEAN_CORRECTED-' + CHLIN + '-' + CODE_TYPE(C) + '-MERGED_CHL_PP_DATA.CSV'
        FILES  = FILE_SEARCH(DIR_IN + 'ANNUAL_CORRECTED_SUM-' + CHLIN + '*' + CODE_TYPE(C) + '*CHL_PRIMARY_PRODUCTION-*-STATS.SAV')
        IF FILE_MAKE(FILES,[SAVEFILE,CSVFILE],OVERWRITE=OVERWRITE) EQ 0 THEN CONTINUE
        FOR S=0, N_ELEMENTS(SENSORS)-1 DO BEGIN
          FOR P=0, N_ELEMENTS(PP_TARGETS)-1 DO BEGIN
            FILES  = FILE_SEARCH(DIR_IN + 'ANNUAL_CORRECTED_SUM-' + CHLIN + '-' + SENSORS(S) + '*' + CODE_TYPE(C) + '*CHL_PRIMARY_PRODUCTION-'+PP_TARGETS(P)+'-STATS.SAV')
            STR = IDL_RESTORE(FILES)
          
             ;  IF P EQ 0 THEN                
            IF P EQ 0 THEN STR = STRUCT_COPY(STR,TAGNAMES=['YEAR','SENSOR','SUBAREA_CODE','SUBAREA_NAME','MASK','TOTAL_PIXEL_AREA_KM2','TCHL_ANNUAL_MEAN',    'MCHL_ANNUAL_MEAN',    'NCHL_ANNUAL_MEAN', $
                                            'TPP_CLIM_ANNUAL_MEAN','MPP_CLIM_ANNUAL_MEAN','NPP_CLIM_ANNUAL_MEAN','TPP_CLIM_ANNUAL_TTON','MPP_CLIM_ANNUAL_TTON','NPP_CLIM_ANNUAL_TTON']) $
                      ELSE STR = STRUCT_COPY(STR,TAGNAMES=['YEAR','SENSOR','SUBAREA_CODE','SUBAREA_NAME','MASK','TOTAL_PIXEL_AREA_KM2',$
                                            'TPP_CLIM_ANNUAL_MEAN','MPP_CLIM_ANNUAL_MEAN','NPP_CLIM_ANNUAL_MEAN','TPP_CLIM_ANNUAL_TTON','MPP_CLIM_ANNUAL_TTON','NPP_CLIM_ANNUAL_TTON'])

            IF P EQ 0 THEN STR = STRUCT_RENAME(STR,['TCHL_ANNUAL_MEAN',    'MCHL_ANNUAL_MEAN',    'NCHL_ANNUAL_MEAN'],    ['TOTAL_CHL','MICRO_CHL','NANO_CHL'])
            STR = STRUCT_RENAME(STR,['TPP_CLIM_ANNUAL_MEAN','MPP_CLIM_ANNUAL_MEAN','NPP_CLIM_ANNUAL_MEAN'], ['TOTAL_PP_MEAN_', 'MICRO_PP_MEAN_', 'NANO_PP_MEAN_'] +PP_TARGETS(P))
            STR = STRUCT_RENAME(STR,['TPP_CLIM_ANNUAL_TTON','MPP_CLIM_ANNUAL_TTON','NPP_CLIM_ANNUAL_TTON'],['TOTAL_TTON_',    'MICRO_TTON_',    'NANO_TTON_']    +PP_TARGETS(P))
            IF P EQ 0 THEN STRUCT = STR ELSE STRUCT = STRUCT_JOIN(STRUCT,STR,TAGNAMES=['YEAR','SENSOR','SUBAREA_NAME','SUBAREA_CODE','MASK','TOTAL_PIXEL_AREA_KM2'])
          ENDFOR  
          STRUCT = STRUCT[SORT(ROUNDS(STRUCT.YEAR)+'_'+ADD_STR_ZERO(STRUCT.SUBAREA_CODE)+'_'+STRUCT.MASK)]
          IF S EQ 0 THEN CSTR = STRUCT ELSE CSTR = STRUCT_CONCAT(CSTR,STRUCT)  
        ENDFOR
        
        SETS = WHERE_SETS(CSTR.MASK)
        FOR M=0, N_ELEMENTS(SETS)-1 DO BEGIN
          SUBS = WHERE_SETS_SUBS(SETS(M))
          SET  = CSTR(SUBS)
          MSETS = WHERE_SETS(ADD_STR_ZERO(SET.SUBAREA_CODE))
          TEMP  = REPLICATE(CREATE_STRUCT('SUBAREA_CODE',0L,'SUBAREA_NAME','','MASK','','AREA_KM2',0.0D,'ANNUAL_MEAN_CHL_TOTAL',0.0,'ANNUAL_MEAN_CHL_MICRO',0.0,'ANNUAL_MEAN_CHL_NANO',0.0,$
                  'ANNUAL_MEAN_VGPM2_TOTAL',0.0D,'ANNUAL_MEAN_VGPM2_MICRO',0.0D,'ANNUAL_MEAN_VGPM2_NANO',0.0D,'MEAN_VGPM2_TTON_TOTAL',0.0D,'MEAN_VGPM2_TTON_MICRO',0.0D,'MEAN_VGPM2_TTON_NANO',0.0D,$
                  'ANNUAL_MEAN_OPAL_TOTAL', 0.0D,'ANNUAL_MEAN_OPAL_MICRO', 0.0D,'ANNUAL_MEAN_OPAL_NANO', 0.0D,'MEAN_OPAL_TTON_TOTAL', 0.0D,'MEAN_OPAL_TTON_MICRO', 0.0D,'MEAN_OPAL_TTON_NANO', 0.0),N_ELEMENTS(MSETS))
          FOR S=0, N_ELEMENTS(MSETS)-1 DO BEGIN
            SUBS = WHERE_SETS_SUBS(MSETS(S))
            MSET = SET(SUBS)
            MASK = MSET[0].MASK
            TEMP(S).SUBAREA_CODE = MSET[0].SUBAREA_CODE
            TEMP(S).SUBAREA_NAME = MSET[0].SUBAREA_NAME
            TEMP(S).MASK         = MSET[0].MASK
            TEMP(S).AREA_KM2     = MSET[0].TOTAL_PIXEL_AREA_KM2
            
            TEMP(S).ANNUAL_MEAN_CHL_TOTAL     = MEAN(MSET.TOTAL_CHL)
            TEMP(S).ANNUAL_MEAN_CHL_MICRO     = MEAN(MSET.MICRO_CHL)
            TEMP(S).ANNUAL_MEAN_CHL_NANO      = MEAN(MSET.NANO_CHL)
            
            TEMP(S).ANNUAL_MEAN_VGPM2_TOTAL   = MEAN(MSET.TOTAL_PP_MEAN_VGPM2)
            TEMP(S).ANNUAL_MEAN_VGPM2_MICRO   = MEAN(MSET.MICRO_PP_MEAN_VGPM2)
            TEMP(S).ANNUAL_MEAN_VGPM2_NANO    = MEAN(MSET.NANO_PP_MEAN_VGPM2)
            TEMP(S).MEAN_VGPM2_TTON_TOTAL     = MEAN(MSET.TOTAL_TTON_VGPM2)
            TEMP(S).MEAN_VGPM2_TTON_MICRO     = MEAN(MSET.MICRO_TTON_VGPM2)
            TEMP(S).MEAN_VGPM2_TTON_NANO      = MEAN(MSET.NANO_TTON_VGPM2)
            
            TEMP(S).ANNUAL_MEAN_OPAL_TOTAL   = MEAN(MSET.TOTAL_PP_MEAN_OPAL)
            TEMP(S).ANNUAL_MEAN_OPAL_MICRO   = MEAN(MSET.MICRO_PP_MEAN_OPAL)
            TEMP(S).ANNUAL_MEAN_OPAL_NANO    = MEAN(MSET.NANO_PP_MEAN_OPAL)
            TEMP(S).MEAN_OPAL_TTON_TOTAL     = MEAN(MSET.TOTAL_TTON_OPAL)
            TEMP(S).MEAN_OPAL_TTON_MICRO     = MEAN(MSET.MICRO_TTON_OPAL)
            TEMP(S).MEAN_OPAL_TTON_NANO      = MEAN(MSET.NANO_TTON_OPAL)
            
          ENDFOR  
          IF M EQ 0 THEN FSTRUCT = TEMP ELSE FSTRUCT = STRUCT_CONCAT(FSTRUCT,TEMP)
        ENDFOR  
               
        SAVE, FILENAME=SAVEFILE,FSTRUCT,/COMPRESS
        STRUCT_2CSV,CSVFILE,FSTRUCT
      ENDFOR ; CODE_TYPE
    ENDFOR ; PP_CHL_INPUT
  ENDIF ; DO_PP_CLIM_ANN_MEAN
  
; *******************************************************
  IF DO_PP_CLIM_MON_MEAN GE 1 THEN BEGIN
; *******************************************************
    OVERWRITE = DO_PP_CLIM_MON_MEAN GE 2

    CODE_TYPE = ['LME','FAO']
    LME_MASKS = ['LME_TOTAL','LME_LT_300','LME_GT_300']
    FAO_MASKS = ['FAO_TOTAL','FAO_MINUS_LME']

    SENSORS    = ['SEAWIFS','MODIS']
    PP_TARGETS = ['VGPM2','OPAL']
    PP_CHL_INPUT = ['OC']

    FOR CHLI=0, N_ELEMENTS(PP_CHL_INPUT)-1 DO BEGIN ; Loop through CHL algorithms
      CHLIN = PP_CHL_INPUT(CHLI)
      DIR_IN = DIR_PROJECTS + 'DATA_BY_SUBAREA_' + CHLIN + SL + 'PP_CORRECTED_CONCAT' + SL
      FOR C=0, N_ELEMENTS(CODE_TYPE)-1 DO BEGIN     ; Loop through CODE types
        CASE CODE_TYPE(C) OF
          'LME': MASKS = LME_MASKS
          'FAO': MASKS = FAO_MASKS
        ENDCASE
        SAVEFILE = DIR_SUMMARY + 'CLIMATOLOGICAL_MONTHLY_MEAN_CORRECTED-' + CHLIN + '-' + CODE_TYPE(C) + '-MERGED_CHL_PP_DATA.SAV'
        CSVFILE  = DIR_SUMMARY + 'CLIMATOLOGICAL_MONTHLY_MEAN_CORRECTED-' + CHLIN + '-' + CODE_TYPE(C) + '-MERGED_CHL_PP_DATA.CSV'
        FILES  = FILE_SEARCH(DIR_IN + 'MONTHLY_CORRECTED_SUM-' + CHLIN + '*' + CODE_TYPE(C) + '*CHL_PRIMARY_PRODUCTION-*-STATS.SAV')
        IF FILE_MAKE(FILES,[SAVEFILE,CSVFILE],OVERWRITE=OVERWRITE) EQ 0 THEN CONTINUE
        FOR S=0, N_ELEMENTS(SENSORS)-1 DO BEGIN
          FOR P=0, N_ELEMENTS(PP_TARGETS)-1 DO BEGIN
            FILES  = FILE_SEARCH(DIR_IN + 'MONTHLY_CORRECTED_SUM-' + CHLIN + '-' + SENSORS(S) + '*' + CODE_TYPE(C) + '*CHL_PRIMARY_PRODUCTION-'+PP_TARGETS(P)+'-STATS.SAV')
            STR = IDL_RESTORE(FILES)
            IF P EQ 0 THEN STR = STRUCT_COPY(STR,TAGNAMES=['YEAR','MONTH','SENSOR','SUBAREA_CODE','SUBAREA_NAME','MASK','TOTAL_PIXEL_AREA_KM2','TCHL_MEAN','MCHL_MEAN','NCHL_MEAN','TPPCLIM_MEAN','MPPCLIM_MEAN','NPPCLIM_MEAN'])$
                      ELSE STR = STRUCT_COPY(STR,TAGNAMES=['YEAR','MONTH','SENSOR','SUBAREA_CODE','SUBAREA_NAME','MASK','TOTAL_PIXEL_AREA_KM2','TPPCLIM_MEAN','MPPCLIM_MEAN','NPPCLIM_MEAN'])
            IF P EQ 0 THEN STR = STRUCT_RENAME(STR,['TCHL_ANNUAL_MEAN',    'MCHL_ANNUAL_MEAN',    'NCHL_ANNUAL_MEAN'],    ['TOTAL_CHL','MICRO_CHL','NANO_CHL'])
                           STR = STRUCT_RENAME(STR,['TPPCLIM_MEAN', 'MPPCLIM_MEAN', 'NPPCLIM_MEAN'], ['TOTAL_PP_MEAN_', 'MICRO_PP_MEAN_', 'NANO_PP_MEAN_'] +PP_TARGETS(P))
            IF P EQ 0 THEN STRUCT = STR ELSE STRUCT = STRUCT_JOIN(STRUCT,STR,TAGNAMES=['YEAR','MONTH','SENSOR','SUBAREA_NAME','SUBAREA_CODE','MASK','TOTAL_PIXEL_AREA_KM2'])
          ENDFOR
          STRUCT = STRUCT[SORT(NUM2STR(STRUCT.YEAR)+'_'+ADD_STR_ZERO(STRUCT.SUBAREA_CODE)+'_'+STRUCT.MASK)]
          IF S EQ 0 THEN CSTR = STRUCT ELSE CSTR = STRUCT_CONCAT(CSTR,STRUCT)
        ENDFOR

        SETS = WHERE_SETS(CSTR.MASK)
        FOR M=0, N_ELEMENTS(SETS)-1 DO BEGIN
          SUBS = WHERE_SETS_SUBS(SETS(M))
          SET  = CSTR(SUBS)
          MSETS = WHERE_SETS(ADD_STR_ZERO(SET.SUBAREA_CODE)+'_'+NUM2STR(SET.MONTH))
          TEMP  = REPLICATE(CREATE_STRUCT('SUBAREA_CODE',0L,'SUBAREA_NAME','','MASK','','AREA_KM2',0.0D, 'MONTH','',$
            'CLIM_MONTH_CHL_TOTAL', 0.0D,'CLIM_MONTH_CHL_MICRO', 0.0D,'CLIM_MONTH_CHL_NANO', 0.0D,$
            'CLIM_MONTH_MEAN_VGPM2_TOTAL',0.0D,'CLIM_MONTH_MEAN_VGPM2_MICRO',0.0D,'CLIM_MONTH_MEAN_VGPM2_NANO',0.0D,$
            'CLIM_MONTH_MEAN_OPAL_TOTAL', 0.0D,'CLIM_MONTH_MEAN_OPAL_MICRO', 0.0D,'CLIM_MONTH_MEAN_OPAL_NANO', 0.0D),N_ELEMENTS(MSETS))
          FOR S=0, N_ELEMENTS(MSETS)-1 DO BEGIN
            SUBS = WHERE_SETS_SUBS(MSETS(S))
            MSET = SET(SUBS)
            MASK = MSET[0].MASK
            TEMP(S).SUBAREA_CODE                = MSET[0].SUBAREA_CODE
            TEMP(S).SUBAREA_NAME                = MSET[0].SUBAREA_NAME
            TEMP(S).MASK                        = MSET[0].MASK
            TEMP(S).AREA_KM2                    = MSET[0].TOTAL_PIXEL_AREA_KM2
            TEMP(S).MONTH                       = MSET[0].MONTH

            TEMP(S).CLIM_MONTH_CHL_TOTAL        = GEOMEAN(MSET.TCHL_MEAN,/NAN)
            TEMP(S).CLIM_MONTH_CHL_MICRO        = GEOMEAN(MSET.MCHL_MEAN,/NAN)
            TEMP(S).CLIM_MONTH_CHL_NANO         = GEOMEAN(MSET.NCHL_MEAN,/NAN)
            
            TEMP(S).CLIM_MONTH_MEAN_VGPM2_TOTAL = GEOMEAN(MSET.TOTAL_PP_MEAN_VGPM2,/NAN)
            TEMP(S).CLIM_MONTH_MEAN_VGPM2_MICRO = GEOMEAN(MSET.MICRO_PP_MEAN_VGPM2,/NAN)
            TEMP(S).CLIM_MONTH_MEAN_VGPM2_NANO  = GEOMEAN(MSET.NANO_PP_MEAN_VGPM2,/NAN)
            
            TEMP(S).CLIM_MONTH_MEAN_OPAL_TOTAL  = GEOMEAN(MSET.TOTAL_PP_MEAN_OPAL,/NAN)
            TEMP(S).CLIM_MONTH_MEAN_OPAL_MICRO  = GEOMEAN(MSET.MICRO_PP_MEAN_OPAL,/NAN)
            TEMP(S).CLIM_MONTH_MEAN_OPAL_NANO   = GEOMEAN(MSET.NANO_PP_MEAN_OPAL,/NAN)
            

          ENDFOR
          IF M EQ 0 THEN FSTRUCT = TEMP ELSE FSTRUCT = STRUCT_CONCAT(FSTRUCT,TEMP)
        ENDFOR

        SAVE, FILENAME=SAVEFILE,FSTRUCT,/COMPRESS
        STRUCT_2CSV,CSVFILE,FSTRUCT
      ENDFOR ; CODE_TYPE
    ENDFOR ; PP_CHL_INPUT
  ENDIF ; DO_PP_CLIM_MON_MEAN
  
; *******************************************************
  IF DO_PP_COMPARE GE 1 THEN BEGIN
; *******************************************************
    OVERWRITE = DO_PP_COMPARE GE 2

    MAP = 'GEQ'
    LMES = READALL(!S.DATA + 'lme_names.csv')
    EXCLUDE_LMES = ['64','63','62','61','58','57','56','55','54']
    OK = WHERE_MATCH(LMES.CODE,EXCLUDE_LMES,COUNT,COMPLEMENT=COMPLEMENT)
    LME_CODES = LMES(COMPLEMENT).CODE
    LME_NAMES = LMES(COMPLEMENT).SUBAREA_NAME
    FAO_CODES = [21, 27, 31, 34, 37, 41, 47, 48, 51, 57, 58, 61, 67, 71, 77, 81, 87]
    FAO_NAMES = ['NORTHWEST_ATLANTIC', 'NORTHEAST_ATLANTIC', 'WESTERN_CENTRAL_ATLANTIC', 'EASTERN_CENTRAL_ATLANTIC', 'MEDITERRANEAN_BLACK_SEA', 'SOUTHWEST_ATLANTIC', 'SOUTHEAST_ATLANTIC', 'ATLANTIC_ANTARCTIC',$
      'WESTERN_INDIAN','EASTERN_INDIAN','INDIAN_ANTARCTIC_SOUTHERN','NORTHWEST_PACIFIC','NORTHEAST_PACIFIC','WESTERN_CENTRAL_PACIFIC','EASTERN_CENTRAL_PACIFIC','SOUTHWEST_PACIFIC','SOUTHEAST_PACIFIC']

    CODE_TYPE = ['LME'] ;,'FAO'
    LME_MASKS = ['LME_TOTAL'] ;,'LME_LT_300','LME_GT_300'
    FAO_MASKS = ['FAO_TOTAL','FAO_MINUS_LME']

    PP_TARGETS = ['VGPM2']
    PP_CHL_INPUT = ['OC','PAN']
    FOR CHLI=0, N_ELEMENTS(PP_CHL_INPUT)-1 DO BEGIN ; Loop through CHL algorithms
      CHLIN = PP_CHL_INPUT(CHLI)
      IF CHLIN EQ 'PAN' THEN DIR_SAVE = DIR_SAVE_PAN ELSE DIR_SAVE = DIR_SAVE_OC
      FOR TAR=0, N_ELEMENTS(PP_TARGETS)-1 DO BEGIN  ; Loop through PP algorithms
        PP_TARGET = PP_TARGETS(TAR)
        SENSORS = ['SEAWIFS','MODIS']
        FOR SEN=0, N_ELEMENTS(SENSORS)-1 DO BEGIN   ; Loop through SENSORS
          SENSOR = SENSORS(SEN)
          CHL  = ['CHLOR_A-PAN', 'MICRO-PAN', 'NANOPICO-PAN']
          IF SENSOR EQ 'MODIS'   AND CHLIN EQ 'OC' THEN CHL[0] = 'CHLOR_A-OC3M'
          IF SENSOR EQ 'SEAWIFS' AND CHLIN EQ 'OC' THEN CHL[0] = 'CHLOR_A-OC4'
          PPD = ['PPD-'] + PP_TARGET
          PRODS = ['PAR',PPD]
          DIRS  = DIR_SAVE + PRODS + SL
          YEARS = YEAR_RANGE('1998','2007',/STRING)
          IF STRMID(SENSOR,0,3) EQ 'MOD' THEN YEARS = YEAR_RANGE('2008','2014',/STRING)
        
          FOR C=0, N_ELEMENTS(CODE_TYPE)-1 DO BEGIN  ; Loop through CODE TYPES
            IF CODE_TYPE(C) EQ 'LME' THEN CODES = LME_CODES ELSE CODES = FAO_CODES
            IF CODE_TYPE(C) EQ 'LME' THEN NAMES = LME_NAMES ELSE NAMES = FAO_NAMES
            IF CODE_TYPE(C) EQ 'LME' THEN NMASKS = 3        ELSE NMASKS = 2
            IF CODE_TYPE(C) EQ 'LME' THEN MASKS = LME_MASKS ELSE MASKS = FAO_MASKS
            FOR N=0, N_ELEMENTS(CODES)-1 DO BEGIN    ; Loop through CODES
              ACODE = FIX(CODES(N))
              ANAME = NAMES(N)
              ; Find the files associated with the appropriate CODE, CHL alg, SENSOR and PRODUCT
              PRSAVE = FILE_SEARCH(DIRS[0] + 'ALL-' + CHLIN + '-' + CODE_TYPE(C) + '_CODE_' + NUM2STR(ACODE) + '-' + ANAME+'-' + STRMID(SENSOR,0,3) + '*' + PRODS[0] + '*.SAV*')
              PPSAVE = FILE_SEARCH(DIRS[1] + 'ALL-' + CHLIN + '-' + CODE_TYPE(C) + '_CODE_' + NUM2STR(ACODE) + '-' + ANAME+'-' + STRMID(SENSOR,0,3) + '*' + PRODS[1] + '*.SAV*')
              SAVES = [PRSAVE,PPSAVE]
              DIR_CSV   = DIR_SAVE + 'PP_COMPARE-STATS-CSV'  + SL + CODE_TYPE(C) + '_'  + STR_PAD(ACODE,2) + '-' + ANAME + SL
              DIR_STATS = DIR_SAVE + 'PP_COMPARE-STATS-SAVE' + SL
              DIR_PNGS  = DIR_SAVE + 'PP_COMPARE-PNGS' + SL
              DIR_TEST,[DIR_CSV,DIR_STATS,DIR_PNGS]

              PPDATA = []
              FOR M=0, N_ELEMENTS(MASKS)-1 DO BEGIN  ; Loop through MASKS
                ; Output file names
                MSAVEFILE = DIR_STATS + 'MONTHLY_SUM-' + CHLIN + '-' + SENSORS(SEN) + '-' + CODE_TYPE(C) + '_CODE_' + STR_PAD(ACODE,2) + '-' + ANAME + '-' + MASKS(M) + '-PAR_PRIMARY_PRODUCTION-' + PP_TARGET + '-STATS.SAV'
                MCSVFILE  = DIR_CSV   + 'MONTHLY_SUM-' + CHLIN + '-' + SENSORS(SEN) + '-' + CODE_TYPE(C) + '_CODE_' + STR_PAD(ACODE,2) + '-' + ANAME + '-' + MASKS(M) + '-PAR_PRIMARY_PRODUCTION-' + PP_TARGET + '-STATS.CSV'
                ASAVEFILE = DIR_STATS + 'ANNUAL_SUM-'  + CHLIN + '-' + SENSORS(SEN) + '-' + CODE_TYPE(C) + '_CODE_' + STR_PAD(ACODE,2) + '-' + ANAME + '-' + MASKS(M) + '-PAR_PRIMARY_PRODUCTION-' + PP_TARGET + '-STATS.SAV'
                ACSVFILE  = DIR_CSV   + 'ANNUAL_SUM-'  + CHLIN + '-' + SENSORS(SEN) + '-' + CODE_TYPE(C) + '_CODE_' + STR_PAD(ACODE,2) + '-' + ANAME + '-' + MASKS(M) + '-PAR_PRIMARY_PRODUCTION-' + PP_TARGET + '-STATS.CSV'
                PNGFILE   = DIR_PNGS  + 'ANNUAL_PP_COMPARISON-'+ CHLIN + '-' + SENSORS(SEN) + '-' + CODE_TYPE(C) + '_CODE_' + STR_PAD(ACODE,2) + '-' + ANAME + '-' + MASKS(M) + '-' + PP_TARGET + '.PNG'
                PNGMEAN   = DIR_PNGS  + 'ANNUAL_PP_MEANS-'+ CHLIN + '-' + SENSORS(SEN) + '-' + CODE_TYPE(C) + '_CODE_' + STR_PAD(ACODE,2) + '-' + ANAME + '-' + MASKS(M) + '-' + PP_TARGET + '.PNG'
                IF UPDATE_CHECK(OUTFILES=[MSAVEFILE,ASAVEFILE,MCSVFILE,ACSVFILE,PNGFILE,PNGMEAN], INFILES=SAVES) EQ 0 AND NOT KEYWORD_SET(OVERWRITE) THEN CONTINUE
                
                TITLE = SENSORS(SEN) + '-' + STR_PAD(ACODE,2) + '-' + ANAME + '-' + MASKS(M)
                PRINT, 'Calculating stats for: ' + TITLE
                IF PPDATA EQ [] THEN BEGIN
                  PRDATA = IDL_RESTORE(PRSAVE)
                  PPDATA = IDL_RESTORE(PPSAVE)
                  TAGS   = TAG_NAMES(PPDATA)
                ENDIF
                
                STRUCT = CREATE_STRUCT('SENSOR','','CHL_ALG','','PP_ALG','','YEAR',0L,'MONTH','','MASK','','SUBAREA_NAME','','SUBAREA_CODE',0L,$ ; Set up MONTHLY output structure
                  'N_SUBAREA_PIXELS',0L,'TOTAL_PIXEL_AREA_KM2',0.0D,$                                    ; Pixel area information
                  ; Total, Micro and Nano-pico Chlorophyll data
                  'PAR_N_PIXELS',       0L,  $  ; Number of valid CHL pixels
                  'PAR_N_PIXELS_AREA',  0.0D,$  ; Area of valid pixels ?
                  'PAR_MEAN',           0.0, $  ; Mean CHL
                  'PAR_SPATIAL_VAR',    0.0, $  ; CHL spatial variance
                  ; Total, Micro and Nano-pico PP data
                  'PP_N_PIXELS',        0L,     'PPCLIM_N_PIXELS',       0L,    'PP_N_MISSING_PIXELS',   0L,    'PPCOR_N_TOTAL_PIXELS',   0L,   'PPCLIM_N_TOTAL_PIXELS',  0L,   $   ; Number of pixels
                  'PP_PIXEL_AREA',      0.0D,   'PPCLIM_PIXEL_AREA',     0.0D,  'PP_MISSING_PIXEL_AREA', 0.0D,  'PPCOR_TOTAL_PIXEL_AREA', 0.0D, 'PPCLIM_TOTAL_PIXEL_AREA',0.0D, $  ; Area of pixels 
                  'PP_SPATIAL_SUM',     0.0D,   'PPCOR_SPATIAL_SUM',     0.0D,  'PPCLIM_SPATIAL_SUM',     0.0D,$  ; Sum of PP pixels within the subarea
                  'PP_MONTHLY_SUM',     0.0D,   'PPCOR_MONTHLY_SUM',     0.0D,  'PPCLIM_MONTHLY_SUM',     0.0D,$  ; ?
                  'PP_MEAN',            0.0D,   'PPCOR_MEAN',            0.0D,  'PPCLIM_MEAN',            0.0D,$  ; Mean PP
                  'PP_SPATIAL_VAR',     0.0D,   'PPCOR_SPATIAL_VAR',     0.0D,  'PPCLIM_SPATIAL_VAR',     0.0D)   ; PP spatial variance

                MONTHS = ['01','02','03','04','05','06','07','08','09','10','11','12']
                STRUCT = REPLICATE(STRUCT_2MISSINGS(STRUCT),N_ELEMENTS(YEARS)*12)

                YSTRUCT = CREATE_STRUCT('SENSOR','','CHL_ALG','','PP_ALG','','YEAR',0L,'MASK','','SUBAREA_NAME','','SUBAREA_CODE',0L,$ ; Set up ANNUAL output structure
                  'N_SUBAREA_PIXELS',0L,   'TOTAL_PIXEL_AREA_KM2',0.0D,$                                ; Pixel area information
                  'PAR_ANNUAL_MEAN',0.0,  $ ; Annual mean PAR
                  'PP_N_MONTHS',    0L,   'PP_MCOR_N_MONTHS',     0L,   'PP_CLIM_N_MONTHS',   0L,                                $ ; Number of months used to calculate the annual summed PP
                  'PP_ANNUAL_MEAN', 0.0,  'PP_MCOR_ANNUAL_MEAN',  0.0,  'PP_CLIM_ANNUAL_MEAN',0.0,                               $ ; Annual mean PP
                  'PP_ANNUAL_SUM',  0.0D, 'PP_MCOR_ANNUAL_SUM',   0.0D, 'PP_CLIM_ANNUAL_SUM', 0.0D, 'PP_ADJ_SPATIAL_MEAN', 0.0D, $ ; Annual sum
                  'PP_ANNUAL_MTON', 0.0D, 'PP_MCOR_ANNUAL_MTON',  0.0D, 'PP_CLIM_ANNUAL_MTON',0.0D, 'PP_ADJ_ANNUAL_MTON', 0.0D)    ; Annual PP sum converted to million tons
                YSTRUCT = REPLICATE(STRUCT_2MISSINGS(YSTRUCT),N_ELEMENTS(YEARS))
                I = -1
                STRUCT.SENSOR  = SENSORS(SEN) & YSTRUCT.SENSOR  = SENSORS(SEN)
                STRUCT.PP_ALG  = PP_TARGET    & YSTRUCT.PP_ALG  = PP_TARGET
                STRUCT.CHL_ALG = CHLIN        & YSTRUCT.CHL_ALG = CHLIN
             
                FOR Y=0, N_ELEMENTS(YEARS)-1 DO BEGIN
                  FOR MTH=0, N_ELEMENTS(MONTHS)-1 DO BEGIN
                    I = I+1
                    STRUCT(I).YEAR = YEARS(Y)
                    STRUCT(I).MONTH = MONTHS(MTH)
                    STRUCT(I).MASK = MASKS(M)
                    STRUCT(I).SUBAREA_CODE = ACODE
                    STRUCT(I).SUBAREA_NAME = ANAME
                    CASE STRUCT(I).MASK OF
                      'LME_TOTAL'     : STRUCT(I).N_SUBAREA_PIXELS = N_ELEMENTS(PPDATA.LME_TOTAL_AREA) ; Number of pixels within the subarea
                      'LME_LT_300'    : STRUCT(I).N_SUBAREA_PIXELS = N_ELEMENTS(PPDATA.LME_LT_300_AREA)
                      'LME_GT_300'    : STRUCT(I).N_SUBAREA_PIXELS = N_ELEMENTS(PPDATA.LME_GT_300_AREA)
                      'FAO_TOTAL'     : STRUCT(I).N_SUBAREA_PIXELS = N_ELEMENTS(PPDATA.FAO_TOTAL_AREA)
                      'FAO_MINUS_LME' : STRUCT(I).N_SUBAREA_PIXELS = N_ELEMENTS(PPDATA.FAO_MINUS_LME_AREA)
                    ENDCASE

                    CASE STRUCT(I).MASK OF
                      'LME_TOTAL'      : STRUCT(I).TOTAL_PIXEL_AREA_KM2 = TOTAL(PPDATA.LME_TOTAL_AREA) ; Total area of the pixels within the subarea
                      'LME_LT_300'     : STRUCT(I).TOTAL_PIXEL_AREA_KM2 = TOTAL(PPDATA.LME_LT_300_AREA)
                      'LME_GT_300'     : STRUCT(I).TOTAL_PIXEL_AREA_KM2 = TOTAL(PPDATA.LME_GT_300_AREA)
                      'FAO_TOTAL'      : STRUCT(I).TOTAL_PIXEL_AREA_KM2 = TOTAL(PPDATA.FAO_TOTAL_AREA)
                      'FAO_MINUS_LME'  : STRUCT(I).TOTAL_PIXEL_AREA_KM2 = TOTAL(PPDATA.FAO_MINUS_LME_AREA)
                    ENDCASE

                    ATAG = 'M_' + YEARS(Y) + MONTHS(MTH) + '_' + MASKS(M) ; Input structure tag
                    PTAG = STRUCT(I).MASK + '_AREA'                       ; Pixel area tag
                    TN = TAG_NAMES(PPDATA)
                    OK = WHERE(STRMID(TN,0,5) EQ 'MONTH' AND STRMID(TN,6,2) EQ MONTHS(MTH))
                    MPERIOD = STRMID(TN[OK],0,18)
                    MTAG = MPERIOD[0] + '_' + MASKS(M)
                    
                    PRPOS = WHERE(TAG_NAMES(PRDATA) EQ ATAG) & PRAP = WHERE(TAG_NAMES(PRDATA) EQ PTAG) ; Find positions of ATAG and PTAG
                    PPPOS = WHERE(TAG_NAMES(PPDATA) EQ ATAG) & PPAP = WHERE(TAG_NAMES(PPDATA) EQ PTAG)
                    MRPOS = WHERE(TAG_NAMES(PRDATA) EQ MTAG) 
                    MPPOS = WHERE(TAG_NAMES(PRDATA) EQ MTAG) 
                    
                    IF PRPOS EQ -1 OR PPPOS EQ -1 THEN CONTINUE
                    PR = PRDATA.(PRPOS) & PRA = PRDATA.(PRAP)                                ; Data & Pixel area for each PROD
                    PP = PPDATA.(PPPOS) & PPA = PPDATA.(PPAP)
                    MR = PRDATA.(MRPOS) & MP  = PPDATA.(MPPOS)
                    
                    OKPR = WHERE(PR GT 0 AND PR NE MISSINGS(0.0),COUNTPR,COMPLEMENT=NO_PAR) ; Find non-missing data
                    OKPP = WHERE(PP GT 0 AND PP NE MISSINGS(0.0),COUNTPP,COMPLEMENT=NO_PP)
                    MISS_PP = WHERE(PR GT 0 AND PR NE MISSINGS(0.0) AND PP EQ MISSINGS(0.0), COUNT_MISS_PP)
                    
                    OKMR = WHERE(MR GT 0 AND MR NE MISSINGS(0.0),COUNTMR,COMPLEMENT=NO_CLIM_PAR)
                    OKMP = WHERE(MP GT 0 AND MP NE MISSINGS(0.0),COUNTMP,COMPLEMENT=NO_CLIM_PP)
                    MISS_CLIM = WHERE(MP GT 0 AND MP NE MISSINGS(0.0) AND PP EQ MISSINGS(0.0),COUNT_MISS_CLIM)
                    
                    STRUCT(I).PAR_N_PIXELS    = COUNTPR                         ; Number of valid PAR pixels
                    STRUCT(I).PP_N_PIXELS     = COUNTPP                         ; Number of valid PP pixels
                    STRUCT(I).PPCLIM_N_PIXELS = COUNTMP                         ; Number of valid pixels in the MONTHLY PP climatology
                    STRUCT(I).PP_N_MISSING_PIXELS   = COUNT_MISS_PP             ; Number of missing PP pixels
                    STRUCT(I).PPCOR_N_TOTAL_PIXELS  = COUNT_MISS_PP + COUNTPP   ; Number of total PP pixels after M correction
                    STRUCT(I).PPCLIM_N_TOTAL_PIXELS = COUNT_MISS_CLIM + COUNTPP ; Number of total PP pixels after MONTH correction
                    IF COUNTPR EQ 0 THEN CONTINUE ; NO PAR DATA...
                    
                    STRUCT(I).PAR_N_PIXELS_AREA       = TOTAL(PRA(OKPR))        ; Area of the valid PAR pixels
                    STRUCT(I).PP_PIXEL_AREA           = TOTAL(PPA(OKPP))        ; Area of the valid PP pixels
                    STRUCT(I).PP_MISSING_PIXEL_AREA   = TOTAL(PPA(MISS_PP))     ; Area of the missing PP pixels
                    STRUCT(I).PPCLIM_PIXEL_AREA       = TOTAL(PPA(OKMP))        ; Area of the MONTH PP pixels
                    STRUCT(I).PPCOR_TOTAL_PIXEL_AREA  = STRUCT(I).PP_PIXEL_AREA + STRUCT(I).PP_MISSING_PIXEL_AREA ; Total area of the M corrected PP pixels
                    STRUCT(I).PPCLIM_TOTAL_PIXEL_AREA = STRUCT(I).PP_PIXEL_AREA + TOTAL(PPA(MISS_CLIM))           ; Total area of the MONTH corrected PP pixels
                    
                    STRUCT(I).PAR_MEAN = MEAN(PR(OKPR))                   ; Mean of the valid PAR data
                    IF COUNTPP GT 1 THEN STRUCT(I).PP_MEAN  = GEOMEAN(PP(OKPP)) ELSE STRUCT(I).PP_MEAN = MISSINGS(0.0)                ; Geometric mean of the valid PP data
                    STRUCT(I).PPCLIM_MEAN = GEOMEAN(MP(OKMP))                ; Geometrict mean of the valid MONTHLY PP data
                    STRUCT(I).PAR_SPATIAL_VAR = VARIANCE(PR(OKPR))        ; Variance of the valid PAR and PP data
                    STRUCT(I).PP_SPATIAL_VAR  = VARIANCE(PP(OKPP))
                    STRUCT(I).PP_SPATIAL_SUM  = TOTAL(PP(OKPP)*1000000*PPA(OKPP))
                    STRUCT(I).PP_MONTHLY_SUM  = STRUCT(I).PP_SPATIAL_SUM*DAYS_MONTH(MONTHS(MTH),YEAR=YEARS(Y))
                    
                    IF COUNTPP GT 1 THEN BEGIN
                      PPCOR = [PP(OKPP),REPLICATE(STRUCT(I).PP_MEAN,COUNT_MISS_PP)] & IF ABS(N_ELEMENTS(PPCOR) - STRUCT(I).PPCOR_N_TOTAL_PIXELS) GT 2 THEN STOP
                      STRUCT(I).PPCOR_MEAN = GEOMEAN(PPCOR)
                      STRUCT(I).PPCOR_SPATIAL_VAR  = VARIANCE(PPCOR)
                      STRUCT(I).PPCOR_SPATIAL_SUM  = TOTAL(PPCOR*1000000*PPA(OKPR))
                      STRUCT(I).PPCOR_MONTHLY_SUM  = STRUCT(I).PPCOR_SPATIAL_SUM*DAYS_MONTH(MONTHS(MTH),YEAR=YEARS(Y))
                    ENDIF
                    
                    PPCLIM = [PP(OKPP),MP(MISS_CLIM)] & IF ABS(N_ELEMENTS(PPCLIM) - STRUCT(I).PPCLIM_N_TOTAL_PIXELS) GT 2 THEN STOP
                    STRUCT(I).PPCLIM_MEAN = GEOMEAN(PPCLIM)
                    STRUCT(I).PPCLIM_SPATIAL_VAR = VARIANCE(PPCLIM)
                    STRUCT(I).PPCLIM_SPATIAL_SUM = TOTAL(PPCLIM*1000000*PPA(OKMP))
                    STRUCT(I).PPCLIM_MONTHLY_SUM = STRUCT(I).PPCLIM_SPATIAL_SUM*DAYS_MONTH(MONTHS(MTH),YEAR=YEARS(Y))
                  
                  ENDFOR ; Loop through each MONTH

                  YSTRUCT(Y).YEAR = YEARS(Y)
                  YSTRUCT(Y).MASK = MASKS(M)
                  YSTRUCT(Y).SUBAREA_CODE = ACODE
                  YSTRUCT(Y).SUBAREA_NAME = ANAME
                  YSTRUCT(Y).N_SUBAREA_PIXELS      = STRUCT[0].N_SUBAREA_PIXELS
                  YSTRUCT(Y).TOTAL_PIXEL_AREA_KM2  = STRUCT[0].TOTAL_PIXEL_AREA_KM2

                  OKY = WHERE(STRUCT.YEAR EQ YEARS(Y))
                  YSTRUCT(Y).PAR_ANNUAL_MEAN = MEAN(STRUCT(OKY).PAR_MEAN,/NAN)
                  YSTRUCT(Y).PP_ANNUAL_MEAN  = MEAN(STRUCT(OKY).PP_MEAN,/NAN)*365
                  YSTRUCT(Y).PP_ANNUAL_SUM   = TOTAL(STRUCT(OKY).PP_MONTHLY_SUM,/NAN)
                  YSTRUCT(Y).PP_N_MONTHS     = N_ELEMENTS(WHERE(STRUCT(OKY).PP_MONTHLY_SUM NE MISSINGS(0.0)))
                  YSTRUCT(Y).PP_ANNUAL_MTON  = YSTRUCT(Y).PP_ANNUAL_SUM * 1E-6
                  
                  YSTRUCT(Y).PP_MCOR_ANNUAL_MEAN  = MEAN(STRUCT(OKY).PPCOR_MEAN,/NAN)*365
                  YSTRUCT(Y).PP_MCOR_ANNUAL_SUM   = TOTAL(STRUCT(OKY).PPCOR_MONTHLY_SUM,/NAN)
                  YSTRUCT(Y).PP_MCOR_N_MONTHS     = N_ELEMENTS(WHERE(STRUCT(OKY).PPCOR_MONTHLY_SUM NE MISSINGS(0.0)))
                  YSTRUCT(Y).PP_MCOR_ANNUAL_MTON  = YSTRUCT(Y).PP_MCOR_ANNUAL_SUM * 1E-6
                  
                  YSTRUCT(Y).PP_CLIM_ANNUAL_MEAN  = MEAN(STRUCT(OKY).PPCLIM_MEAN,/NAN)*365
                  YSTRUCT(Y).PP_CLIM_ANNUAL_SUM   = TOTAL(STRUCT(OKY).PPCLIM_MONTHLY_SUM,/NAN)
                  YSTRUCT(Y).PP_CLIM_N_MONTHS     = N_ELEMENTS(WHERE(STRUCT(OKY).PPCLIM_MONTHLY_SUM NE MISSINGS(0.0)))
                  YSTRUCT(Y).PP_CLIM_ANNUAL_MTON  = YSTRUCT(Y).PP_CLIM_ANNUAL_SUM * 1E-6
   
                  YSTRUCT(Y).PP_ADJ_SPATIAL_MEAN = YSTRUCT(Y).PP_ANNUAL_MEAN * YSTRUCT(Y).TOTAL_PIXEL_AREA_KM2 * 1000000
                  YSTRUCT(Y).PP_ADJ_ANNUAL_MTON  = YSTRUCT(Y).PP_ADJ_SPATIAL_MEAN * 1E-6
         
                ENDFOR ; Loop through each year
                
                BUFFER = 1
                W  = WINDOW(DIMENSIONS=[900,1200],BUFFER=BUFFER)
                BR = BARPLOT(YSTRUCT.YEAR,YSTRUCT.PP_ANNUAL_MEAN,      INDEX=0, NBARS=3, FILL_COLOR='RED', POSITION=[.12,.8,.85,.95],FONT_STYLE='BOLD',MARGIN=[0.125,0.1,0.05,0.1], TITLE=TITLE, XMINOR=0, XTICKINTERVAL=1, YTITLE=UNITS('PPD'), XTITLE='Year',/CURRENT)
                BR = BARPLOT(YSTRUCT.YEAR,YSTRUCT.PP_MCOR_ANNUAL_MEAN, INDEX=1, NBARS=3, FILL_COLOR='NAVY', /OVERPLOT)
                BR = BARPLOT(YSTRUCT.YEAR,YSTRUCT.PP_CLIM_ANNUAL_MEAN, INDEX=2, NBARS=3, FILL_COLOR='CYAN', /OVERPLOT)
                
                FOR M=0, N_ELEMENTS(MONTHS)-1 DO BEGIN
                  OK = WHERE(STRUCT.MONTH EQ MONTHS(M))
                  MSTR = STRUCT[OK]
                  MSTR = MSTR[SORT(MSTR.YEAR)]
                  IF MIN(MSTR.PP_MONTHLY_SUM) EQ MISSINGS(0.0) THEN CONTINUE
                  LAYOUT = [4,4,5+M]
                  YTITLE = UNITS('PPD')
                  MARGIN = [0.18,0.1,0.07,0.1]
                  BR1 = BARPLOT(MSTR.YEAR,MSTR.PP_MEAN,    INDEX=0, NBARS=3, FILL_COLOR='RED',LAYOUT=LAYOUT,MARGIN=MARGIN,FONT_STYLE='BOLD',TITLE=MONTH_NAMES(MONTHS(M)),XMINOR=1,XTICKINTERVAL=2,YTITLE=YTITLE,/CURRENT)
                  BR1.XTICKNAME = YEAR_2YY(BR1.XTICKNAME)
                  BR1 = BARPLOT(MSTR.YEAR,MSTR.PPCOR_MEAN, INDEX=1, NBARS=3, FILL_COLOR='NAVY', /OVERPLOT)
                  BR1 = BARPLOT(MSTR.YEAR,MSTR.PPCLIM_MEAN,INDEX=2, NBARS=3, FILL_COLOR='CYAN', /OVERPLOT)
                ENDFOR

                T = TEXT(0.855,0.9,'Original',      FONT_STYLE='BOLD',FONT_COLOR='RED',/NORMAL)
                T = TEXT(0.855,0.88,'Monthly Cor.',FONT_STYLE='BOLD',FONT_COLOR='NAVY',/NORMAL)
                T = TEXT(0.855,0.86,'Climaology Cor.',FONT_STYLE='BOLD',FONT_COLOR='CYAN',/NORMAL)

                W.SAVE,PNGMEAN,RESOLUTION=300
                W.CLOSE
                
                BUFFER = 1
                W  = WINDOW(DIMENSIONS=[900,1200],BUFFER=BUFFER)
                BR = BARPLOT(YSTRUCT.YEAR,YSTRUCT.PP_ANNUAL_MTON,      INDEX=0, NBARS=3, FILL_COLOR='RED', POSITION=[.12,.8,.85,.95],FONT_STYLE='BOLD',MARGIN=[0.125,0.1,0.05,0.1], TITLE=TITLE, XMINOR=0, XTICKINTERVAL=1, YTITLE='PP (mton yr!U-1!N)', XTITLE='Year',/CURRENT)
                BR = BARPLOT(YSTRUCT.YEAR,YSTRUCT.PP_MCOR_ANNUAL_MTON, INDEX=1, NBARS=3, FILL_COLOR='NAVY', /OVERPLOT)
                BR = BARPLOT(YSTRUCT.YEAR,YSTRUCT.PP_CLIM_ANNUAL_MTON, INDEX=2, NBARS=3, FILL_COLOR='CYAN', /OVERPLOT)
         ;       BR = BARPLOT(YSTRUCT.YEAR,YSTRUCT.PP_ADJ_ANNUAL_MTON,  INDEX=3, NBARS=3, FILL_COLOR='CYAN', /OVERPLOT)
                
                
                FOR M=0, N_ELEMENTS(MONTHS)-1 DO BEGIN
                  OK = WHERE(STRUCT.MONTH EQ MONTHS(M))
                  MSTR = STRUCT[OK]
                  MSTR = MSTR[SORT(MSTR.YEAR)]
                  IF MIN(MSTR.PP_MONTHLY_SUM) EQ MISSINGS(0.0) THEN CONTINUE
                  LAYOUT = [4,4,5+M]   
                  YTITLE = 'Monthly PP'            
                  MARGIN = [0.18,0.1,0.07,0.1]    
                  BR1 = BARPLOT(MSTR.YEAR,MSTR.PP_MONTHLY_SUM * 1E-12,    INDEX=0, NBARS=3, FILL_COLOR='RED',LAYOUT=LAYOUT,MARGIN=MARGIN,FONT_STYLE='BOLD',TITLE=MONTH_NAMES(MONTHS(M)),XMINOR=1,XTICKINTERVAL=2,YTITLE=YTITLE,/CURRENT)
               ;   T = TEXT(MSTR.YEAR,MSTR.PPCOR_MONTHLY_SUM*1E-12,NUM2STR(MSTR.PPCLIM_N_PIXELS-MSTR.PP_N_PIXELS ),FONT_SIZE=8,/DATA,TARGET=BR1)
                  BR1.XTICKNAME = YEAR_2YY(BR1.XTICKNAME)
                  BR1 = BARPLOT(MSTR.YEAR,MSTR.PPCOR_MONTHLY_SUM * 1E-12, INDEX=1, NBARS=3, FILL_COLOR='NAVY', /OVERPLOT)
                  BR1 = BARPLOT(MSTR.YEAR,MSTR.PPCLIM_MONTHLY_SUM * 1E-12,INDEX=2, NBARS=3, FILL_COLOR='CYAN', /OVERPLOT)         
                ENDFOR
                
                T = TEXT(0.855,0.9,'Original',      FONT_STYLE='BOLD',FONT_COLOR='RED',/NORMAL)
                T = TEXT(0.855,0.88,'Monthly Cor.',FONT_STYLE='BOLD',FONT_COLOR='NAVY',/NORMAL)
                T = TEXT(0.855,0.86,'Climaology Cor.',FONT_STYLE='BOLD',FONT_COLOR='CYAN',/NORMAL)
           ;     T = TEXT(0.855,0.84,'Annual Cor.',FONT_STYLE='BOLD',FONT_COLOR='CYAN',/NORMAL)
                
                W.SAVE,PNGFILE,RESOLUTION=300
                W.CLOSE

                SAVE, FILENAME=MSAVEFILE,STRUCT,/COMPRESS
                SAVE, FILENAME=ASAVEFILE,YSTRUCT,/COMPRESS
                STRUCT_2CSV,MCSVFILE,STRUCT
                STRUCT_2CSV,ACSVFILE,YSTRUCT
                
              ENDFOR ; MASKS
            ENDFOR   ; CODE
            STOP
          ENDFOR     ; CODE_TYPE
        ENDFOR       ; SENSORS
      ENDFOR         ; PP_TARGETS
    ENDFOR           ; PP_CHL_INPUT
  ENDIF              ; DO_PP_COMPARE
  
  
  
; *******************************************************
  IF DO_QQ_CF_PLOTS GE 1 THEN BEGIN
; *******************************************************
    OVERWRITE = DO_QQ_CF_PLOTS GE 2

    MAP = 'GEQ'
    LMES = READALL(!S.DATA + 'lme_names.csv')
    EXCLUDE_LMES = ['64','63','62','61','58','57','56','55','54']
    OK = WHERE_MATCH(LMES.CODE,EXCLUDE_LMES,COUNT,COMPLEMENT=COMPLEMENT)
    LME_CODES = LMES(COMPLEMENT).CODE
    LME_NAMES = LMES(COMPLEMENT).SUBAREA_NAME
    FAO_CODES = [21, 27, 31, 34, 37, 41, 47, 48, 51, 57, 58, 61, 67, 71, 77, 81, 87]
    FAO_NAMES = ['NORTHWEST_ATLANTIC', 'NORTHEAST_ATLANTIC', 'WESTERN_CENTRAL_ATLANTIC', 'EASTERN_CENTRAL_ATLANTIC', 'MEDITERRANEAN_BLACK_SEA', 'SOUTHWEST_ATLANTIC', 'SOUTHEAST_ATLANTIC', 'ATLANTIC_ANTARCTIC',$
      'WESTERN_INDIAN','EASTERN_INDIAN','INDIAN_ANTARCTIC_SOUTHERN','NORTHWEST_PACIFIC','NORTHEAST_PACIFIC','WESTERN_CENTRAL_PACIFIC','EASTERN_CENTRAL_PACIFIC','SOUTHWEST_PACIFIC','SOUTHEAST_PACIFIC']

    CODE_TYPE = ['LME'] ;,'FAO'
    LME_MASKS = ['LME_TOTAL'] ;,'LME_LT_300','LME_GT_300'
    FAO_MASKS = ['FAO_TOTAL','FAO_MINUS_LME']

    PP_TARGETS = ['VGPM2']
    PP_CHL_INPUT = ['OC','PAN']
    FOR CHLI=0, N_ELEMENTS(PP_CHL_INPUT)-1 DO BEGIN ; Loop through CHL algorithms
      CHLIN = PP_CHL_INPUT(CHLI)
      IF CHLIN EQ 'PAN' THEN DIR_SAVE = DIR_SAVE_PAN ELSE DIR_SAVE = DIR_SAVE_OC
      FOR TAR=0, N_ELEMENTS(PP_TARGETS)-1 DO BEGIN  ; Loop through PP algorithms
        PP_TARGET = PP_TARGETS(TAR)
        SENSORS = ['SEAWIFS','MODIS']
        FOR SEN=0, N_ELEMENTS(SENSORS)-1 DO BEGIN   ; Loop through SENSORS
          SENSOR = SENSORS(SEN)
          CHL  = ['CHLOR_A-PAN', 'MICRO-PAN', 'NANOPICO-PAN']
          IF SENSOR EQ 'MODIS'   AND CHLIN EQ 'OC' THEN CHL[0] = 'CHLOR_A-OC3M'
          IF SENSOR EQ 'SEAWIFS' AND CHLIN EQ 'OC' THEN CHL[0] = 'CHLOR_A-OC4'
          PPD = ['PPD-'] + PP_TARGET
          PRODS = ['PAR',PPD]
          DIRS  = DIR_SAVE + PRODS + SL
          YEARS = YEAR_RANGE('1998','2007',/STRING)
          IF STRMID(SENSOR,0,3) EQ 'MOD' THEN YEARS = YEAR_RANGE('2008','2014',/STRING)

          FOR C=0, N_ELEMENTS(CODE_TYPE)-1 DO BEGIN  ; Loop through CODE TYPES
            IF CODE_TYPE(C) EQ 'LME' THEN CODES = LME_CODES ELSE CODES = FAO_CODES
            IF CODE_TYPE(C) EQ 'LME' THEN NAMES = LME_NAMES ELSE NAMES = FAO_NAMES
            IF CODE_TYPE(C) EQ 'LME' THEN NMASKS = 3        ELSE NMASKS = 2
            IF CODE_TYPE(C) EQ 'LME' THEN MASKS = LME_MASKS ELSE MASKS = FAO_MASKS
            
            FOR M=0, N_ELEMENTS(MASKS)-1 DO BEGIN  ; Loop through MASKS
              ORG_DATA = []
              COR_DATA = []
              CLI_DATA = []
              
              AORG_DATA = []
              ACOR_DATA = []
              ACLI_DATA = []
              
              FOR N=0, N_ELEMENTS(CODES)-1 DO BEGIN    ; Loop through CODES
                ACODE = FIX(CODES(N))
                ANAME = NAMES(N)
                
                DIR_STATS = DIR_SAVE + 'PP_COMPARE-STATS-SAVE' + SL
                DIR_PNGS  = DIR_SAVE + 'PP_QQ_CF-PNGS' + SL & DIR_TEST,DIR_PNGS
              
                ; Find the files associated with the appropriate CODE, CHL alg, SENSOR and PRODUCT
                MSAVE = DIR_STATS + 'MONTHLY_SUM-' + CHLIN + '-' + SENSORS(SEN) + '-' + CODE_TYPE(C) + '_CODE_' + STR_PAD(ACODE,2) + '-' + ANAME + '-' + MASKS(M) + '-PAR_PRIMARY_PRODUCTION-' + PP_TARGET + '-STATS.SAVE'
                ASAVE = DIR_STATS + 'ANNUAL_SUM-'  + CHLIN + '-' + SENSORS(SEN) + '-' + CODE_TYPE(C) + '_CODE_' + STR_PAD(ACODE,2) + '-' + ANAME + '-' + MASKS(M) + '-PAR_PRIMARY_PRODUCTION-' + PP_TARGET + '-STATS.SAVE'
                SAVES = [MSAVE,ASAVE]
                
                ; Output file names
                QPFILE = DIR_PNGS  + 'MONTHLY_QQ_PLOTS-'+ CHLIN + '-' + SENSORS(SEN) + '-' + CODE_TYPE(C) + '_CODE_' + STR_PAD(ACODE,2) + '-' + ANAME + '-' + MASKS(M) + '-' + PP_TARGET + '.PNG'
                QQFILE = DIR_PNGS  + 'QQ_PLOTS-'        + CHLIN + '-' + SENSORS(SEN) + '-' + CODE_TYPE(C) + '_ALL-'  + MASKS(M) + '-' + PP_TARGET + '.PNG'
                QMFILE = DIR_PNGS  + 'QQ_PLOTS_MONTHLY-'+ CHLIN + '-' + SENSORS(SEN) + '-' + CODE_TYPE(C) + '_ALL-'  + MASKS(M) + '-' + PP_TARGET + '.PNG'
                CFFILE = DIR_PNGS  + 'CF_PLOTS-'        + CHLIN + '-' + SENSORS(SEN) + '-' + CODE_TYPE(C) + '_ALL-'  + MASKS(M) + '-' + PP_TARGET + '.PNG'
                CMFILE = DIR_PNGS  + 'CF_PLOTS_MONHTLY-'+ CHLIN + '-' + SENSORS(SEN) + '-' + CODE_TYPE(C) + '_ALL-'  + MASKS(M) + '-' + PP_TARGET + '.PNG'  
                
                TITLE = SENSORS(SEN) + '-' + STR_PAD(ACODE,2) + '-' + ANAME + '-' + MASKS(M)
                PRINT, 'Calculating stats for: ' + TITLE
                MDATA = IDL_RESTORE(MSAVE)
                ADATA = IDL_RESTORE(ASAVE)
                
                ORG_DATA = [ORG_DATA,MDATA.PP_MONTHLY_SUM]
                COR_DATA = [COR_DATA,MDATA.PPCOR_MONTHLY_SUM]
                CLI_DATA = [CLI_DATA,MDATA.PPCLIM_MONTHLY_SUM]
                
                IF N EQ 0 THEN STRUCT = MDATA ELSE STRUCT = STRUCT_CONCAT(STRUCT,MDATA)
                IF N EQ 0 THEN ASTRUCT = ADATA ELSE ASTRUCT = STRUCT_CONCAT(ASTRUCT,ADATA)
                
                AORG_DATA = [AORG_DATA,ADATA.PP_ANNUAL_SUM]
                ACOR_DATA = [ACOR_DATA,ADATA.PP_MCOR_ANNUAL_SUM]
                ACLI_DATA = [ACLI_DATA,ADATA.PP_CLIM_ANNUAL_SUM]
                
                QCORR = QUANTILE(MDATA.PP_MONTHLY_SUM*1E-12,MDATA.PPCOR_MONTHLY_SUM*1E-12,XX=XX_ORG,YY=YY_COR,/QUIET)
                QCLIM = QUANTILE(MDATA.PP_MONTHLY_SUM*1E-12,MDATA.PPCLIM_MONTHLY_SUM*1E-12,XX=XX_ORG,YY=YY_CLIM,/QUIET)
                QCC   = QUANTILE(MDATA.PPCOR_MONTHLY_SUM*1E-12,MDATA.PPCLIM_MONTHLY_SUM*1E-12,XX=XX_COR,YY=YY_CLIM2,/QUIET)
                
                IF UPDATE_CHECK(OUTFILES=[QPFILE], INFILES=SAVES) EQ 0 AND NOT KEYWORD_SET(OVERWRITE) THEN CONTINUE

                BUFFER = 1
                W = WINDOW(DIMENSIONS=[1000,400],BUFFER=BUFFER)
                MARGIN = [0.18,0.15,0.1,0.1]
                PCORR = PLOT(XX_ORG,YY_COR,  XTITLE='$PP Original (monthly sum*10^{12})$',         YTITLE='$PP Monthly Corrected (monthly sum*10^{12})$',    COLOR='RED', SYMBOL='CIRCLE',/SYM_FILLED,LAYOUT=[3,1,1],MARGIN=MARGIN,/CURRENT)
                PLT_ONE2ONE, PCORR
                PCLIM = PLOT(XX_ORG,YY_CLIM, XTITLE='$PP Original (monthly sum*10^{12})$',         YTITLE='$PP Climatology Corrected (monthly sum*10^{12})$',COLOR='NAVY',SYMBOL='CIRCLE',/SYM_FILLED,LAYOUT=[3,1,2],MARGIN=MARGIN,/CURRENT,TITLE=TITLE)
                PLT_ONE2ONE, PCLIM
                PCC   = PLOT(XX_COR,YY_CLIM2,XTITLE='$PP Monthly Corrected (monthly sum*10^{12})$',YTITLE='$PP Climatology Corrected (monthly sum*10^{12})$',COLOR='CYAN',SYMBOL='CIRCLE',/SYM_FILLED,LAYOUT=[3,1,3],MARGIN=MARGIN,/CURRENT)
                PLT_ONE2ONE, PCC
                W.SAVE, QPFILE, RESOLUTION=300
                W.CLOSE
              ENDFOR ; CODES
              
              IF UPDATE_CHECK(OUTFILES=[QQFILE], INFILES=SAVES) EQ 0 AND NOT KEYWORD_SET(OVERWRITE) THEN GOTO, SKIP_QQFILE
                QCORR = QUANTILE(ORG_DATA*1E-12,COR_DATA*1E-12,XX=XX_ORG,YY=YY_COR,/QUIET)
                QCLIM = QUANTILE(ORG_DATA*1E-12,CLI_DATA*1E-12,XX=XX_ORG,YY=YY_CLIM,/QUIET)
                QCC   = QUANTILE(COR_DATA*1E-12,CLI_DATA*1E-12,XX=XX_COR,YY=YY_CLIM2,/QUIET)
  
                BUFFER = 0
                W = WINDOW(DIMENSIONS=[1000,800],BUFFER=BUFFER)
                MARGIN = [0.2,0.15,0.1,0.1]
                PCORR = PLOT(XX_ORG,YY_COR,  XTITLE='$PP Original (monthly sum*10^{12})$',         YTITLE='$PP Monthly Corrected (monthly sum*10^{12})$',    COLOR='RED', SYMBOL='CIRCLE',/SYM_FILLED,LAYOUT=[3,2,1],MARGIN=MARGIN,/CURRENT)
                PLT_ONE2ONE, PCORR
                PCLIM = PLOT(XX_ORG,YY_CLIM, XTITLE='$PP Original (monthly sum*10^{12})$',         YTITLE='$PP Climatology Corrected (monthly sum*10^{12})$',COLOR='NAVY',SYMBOL='CIRCLE',/SYM_FILLED,LAYOUT=[3,2,2],MARGIN=MARGIN,/CURRENT,TITLE='Monthly')
                PLT_ONE2ONE, PCLIM
                PCC   = PLOT(XX_COR,YY_CLIM2,XTITLE='$PP Monthly Corrected (monthly sum*10^{12})$',YTITLE='$PP Climatology Corrected (monthly sum*10^{12})$',COLOR='CYAN',SYMBOL='CIRCLE',/SYM_FILLED,LAYOUT=[3,2,3],MARGIN=MARGIN,/CURRENT)
                PLT_ONE2ONE, PCC
              
                QCORR = QUANTILE(AORG_DATA*1E-12,ACOR_DATA*1E-12,XX=XX_ORG,YY=YY_COR,/QUIET)
                QCLIM = QUANTILE(AORG_DATA*1E-12,ACLI_DATA*1E-12,XX=XX_ORG,YY=YY_CLIM,/QUIET)
                QCC   = QUANTILE(ACOR_DATA*1E-12,ACLI_DATA*1E-12,XX=XX_COR,YY=YY_CLIM2,/QUIET)
                
                PCORR = PLOT(XX_ORG,YY_COR,  XTITLE='$PP Original (annual sum*10^{12})$',         YTITLE='$PP Monthly Corrected (annual sum*10^{12})$',    COLOR='RED', SYMBOL='CIRCLE',/SYM_FILLED,LAYOUT=[3,2,4],MARGIN=MARGIN,/CURRENT)
                PLT_ONE2ONE, PCORR
                PCLIM = PLOT(XX_ORG,YY_CLIM, XTITLE='$PP Original (annual sum*10^{12})$',         YTITLE='$PP Climatology Corrected (annual sum*10^{12})$',COLOR='NAVY',SYMBOL='CIRCLE',/SYM_FILLED,LAYOUT=[3,2,5],MARGIN=MARGIN,/CURRENT,TITLE='Annual')
                PLT_ONE2ONE, PCLIM
                PCC   = PLOT(XX_COR,YY_CLIM2,XTITLE='$PP Monthly Corrected (annual sum*10^{12})$',YTITLE='$PP Climatology Corrected (annual sum*10^{12})$',COLOR='CYAN',SYMBOL='CIRCLE',/SYM_FILLED,LAYOUT=[3,2,6],MARGIN=MARGIN,/CURRENT)
                PLT_ONE2ONE, PCC
                W.SAVE, QQFILE, RESOLUTION=300
                W.CLOSE
              SKIP_QQFILE:
              
              IF UPDATE_CHECK(OUTFILES=[QMFILE], INFILES=SAVES) EQ 0 AND NOT KEYWORD_SET(OVERWRITE) THEN GOTO, SKIP_QMFILE
                MONTHS = STR_PAD(MONTH_RANGE(),2)
                MARGIN = [0.2,0.15,0.1,0.1]
                W = WINDOW(DIMENSIONS=[1200,800],BUFFER=BUFFER)
                FOR MON=0, N_ELEMENTS(MONTHS)-1 DO BEGIN
                  OK = WHERE(STRUCT.MONTH EQ MONTHS(MON))
                  QCORR = QUANTILE(STRUCT[OK].PP_MONTHLY_SUM*1E-12,   STRUCT[OK].PPCOR_MONTHLY_SUM*1E-12, XX=XX_ORG,YY=YY_COR,/QUIET)
                  QCLIM = QUANTILE(STRUCT[OK].PP_MONTHLY_SUM*1E-12,   STRUCT[OK].PPCLIM_MONTHLY_SUM*1E-12,XX=XX_ORG,YY=YY_CLIM,/QUIET)
                  QCC   = QUANTILE(STRUCT[OK].PPCOR_MONTHLY_SUM*1E-12,STRUCT[OK].PPCLIM_MONTHLY_SUM*1E-12,XX=XX_COR,YY=YY_CLIM2,/QUIET)
                  
                  XRANGE = NICE_RANGE([XX_ORG,XX_COR])
                  YRANGE = NICE_RANGE([YY_COR,YY_CLIM])
                  PCORR = PLOT(XX_ORG,YY_COR,  XRANGE=XRANGE,YRANGE=YRANGE,COLOR='RED', SYMBOL='CIRCLE',/SYM_FILLED,XTITLE='',YTITLE='',LAYOUT=[4,3,1+MON],MARGIN=MARGIN,/CURRENT,TITLE=MONTH_NAMES(MONTHS(MON)))
                  PCLIM = PLOT(XX_ORG,YY_CLIM, XRANGE=XRANGE,YRANGE=YRANGE,COLOR='NAVY',SYMBOL='CIRCLE',/SYM_FILLED,/CURRENT,/OVERPLOT)
                  PCC   = PLOT(XX_COR,YY_CLIM2,XRANGE=XRANGE,YRANGE=YRANGE,COLOR='CYAN',SYMBOL='CIRCLE',/SYM_FILLED,/CURRENT,/OVERPLOT)
                  PLT_ONE2ONE, PCORR
     
                ENDFOR
                T = TEXT(0.1,0.01,'Monthly Cor. over Original',      FONT_STYLE='BOLD',FONT_COLOR='RED',/NORMAL)
                T = TEXT(0.4,0.01,'Climatology Cor. over Original',  FONT_STYLE='BOLD',FONT_COLOR='NAVY',/NORMAL)
                T = TEXT(0.7,0.01,'Climaology Cor. over Monthly Cor',FONT_STYLE='BOLD',FONT_COLOR='CYAN',/NORMAL)
    
                W.SAVE, QMFILE, RESOLUTION=300
                W.CLOSE
              SKIP_QMFILE:
              
              IF UPDATE_CHECK(OUTFILES=[CFFILE], INFILES=SAVES) EQ 0 AND NOT KEYWORD_SET(OVERWRITE) THEN GOTO, SKIP_CFFILE
              BUFFER = 0
              W = WINDOW(DIMENSIONS=[1000,800],BUFFER=BUFFER)
              MARGIN = [0.2,0.15,0.1,0.1]
              FOR YTH=0, N_ELEMENTS(YEARS)-1 DO BEGIN
                ORG = 0
                COR = 0
                CLI = 0
                CF_ORG = []
                CF_COR = []
                CF_CLI = []
               
                FOR CFR=0, N_ELEMENTS(CODES)-1 DO BEGIN
                  OK = WHERE(ASTRUCT.SUBAREA_CODE EQ CODES(CFR) AND ASTRUCT.YEAR EQ YEARS(YTH))
                  ORG = ORG + ASTRUCT[OK].PP_ANNUAL_SUM
                  CF_ORG = [CF_ORG,ORG]
                  COR = COR + ASTRUCT[OK].PP_MCOR_ANNUAL_SUM
                  CF_COR = [CF_COR,COR]
                  CLI = CLI + ASTRUCT[OK].PP_CLIM_ANNUAL_SUM
                  CF_CLI = [CF_CLI,CLI]
                ENDFOR
                
                CFO = PLOT(FIX(CODES),CF_ORG*1E-16,COLOR='RED', SYMBOL='CIRCLE',SYM_SIZE=0.5,/SYM_FILLED,XMAJOR=11,MARGIN=MARGIN,XMINOR=0,XTITLE='LME CODE',YTITLE='Cumulative Annual Sum PP',TITLE=YEARS(YTH),LAYOUT=[4,3,YTH+1],/CURRENT)
                CFC = PLOT(FIX(CODES),CF_COR*1E-16,COLOR='NAVY',SYMBOL='CIRCLE',SYM_SIZE=0.5,/SYM_FILLED,/OVERPLOT)
                CFL = PLOT(FIX(CODES),CF_CLI*1E-16,COLOR='CYAN',SYMBOL='CIRCLE',SYM_SIZE=0.5,/OVERPLOT)
              ENDFOR
              
              W.SAVE, CFFILE, RESOLUTION=300
              W.CLOSE
              SKIP_CFFILE:
    stop          
              IF UPDATE_CHECK(OUTFILES=[CMFILE], INFILES=SAVES) EQ 0 AND NOT KEYWORD_SET(OVERWRITE) THEN GOTO, SKIP_CMFILE
              BUFFER = 0
              W = WINDOW(DIMENSIONS=[1000,800],BUFFER=BUFFER)
              MARGIN = [0.2,0.15,0.1,0.1]
              MONTHS = MONTH_RANGE()
              FOR MTH=0, N_ELEMENTS(MONTHS)-1 DO BEGIN
                ORG = 0
                COR = 0
                CLI = 0
                CF_ORG = []
                CF_COR = []
                CF_CLI = []

                FOR CFR=0, N_ELEMENTS(CODES)-1 DO BEGIN
                  OK = WHERE(STRUCT.SUBAREA_CODE EQ CODES(CFR) AND STRUCT.MONTH EQ NUM2STR(MONTHS(MTH)),COUNT)
                  IF COUNT GT 0 THEN BEGIN 
                    ORG = ORG + STRUCT[OK].PP_MONTHLY_SUM
                    COR = COR + STRUCT[OK].PPCOR_MONTHLY_SUM
                    CLI = CLI + STRUCT[OK].PPCLIM_MONTHLY_SUM
                  ENDIF  
                  CF_ORG = [CF_ORG,ORG]
                  CF_COR = [CF_COR,COR]
                  CF_CLI = [CF_CLI,CLI]
                ENDFOR

                CFO = PLOT(FIX(CODES),CF_ORG*1E-12,COLOR='RED', SYMBOL='CIRCLE',SYM_SIZE=0.5,/SYM_FILLED,XMAJOR=11,MARGIN=MARGIN,XMINOR=0,XTITLE='LME CODE',YTITLE='Cumulative Monthly Sum PP',TITLE=MONTH_NAMES(MONTHS(MTH)),LAYOUT=[4,3,MTH+1],/CURRENT)
                CFC = PLOT(FIX(CODES),CF_COR*1E-12,COLOR='NAVY',SYMBOL='CIRCLE',SYM_SIZE=0.5,/SYM_FILLED,/OVERPLOT)
                CFL = PLOT(FIX(CODES),CF_CLI*1E-12,COLOR='CYAN',SYMBOL='CIRCLE',SYM_SIZE=0.5,/OVERPLOT)
              ENDFOR
              stop
              W.SAVE, CMFILE, RESOLUTION=300
              W.CLOSE
              SKIP_CMFILE:
              
            ENDFOR   ; CODE
        STOP    
          ENDFOR     ; CODE_TYPE
        ENDFOR       ; SENSORS
      ENDFOR         ; PP_TARGETS
    ENDFOR           ; PP_CHL_INPUT
  ENDIF              ; DO_QQ_CF_PLOTS   
  
  
; *******************************************************
  IF DO_MONTHLY_COMPS GE 1 THEN BEGIN
; *******************************************************
    OVERWRITE = DO_MONTHLY_COMPS GE 2

    MAP = 'GEQ'
    LMES = READALL(!S.DATA + 'lme_names.csv')
    EXCLUDE_LMES = ['64','63','62','61','58','57','56','55','54']
    OK = WHERE_MATCH(LMES.CODE,EXCLUDE_LMES,COUNT,COMPLEMENT=COMPLEMENT)
    LME_CODES = LMES(COMPLEMENT).CODE
    LME_NAMES = LMES(COMPLEMENT).SUBAREA_NAME
    
    CODE_TYPE = ['LME'] ; FAO
    LME_MASKS = ['LME_TOTAL']
    
    PP_TARGETS = ['VGPM2','OPAL']
    PP_CHL_INPUT = ['OC','PAN']
    PRODS = ['CHLOR_A','PPD','PAR','SST']
    FOR CHLI=0, N_ELEMENTS(PP_CHL_INPUT)-1 DO BEGIN ; Loop through CHL algorithms
      CHLIN = PP_CHL_INPUT(CHLI)
      IF CHLIN EQ 'PAN' THEN DIR_PNG = DIR_SAVE_PAN ELSE DIR_PNG = DIR_SAVE_OC
      DIR_OUT = DIR_PNG + 'PNG_COMPOSITES' + SL & DIR_TEST,DIR_OUT
      FOR TAR=0, N_ELEMENTS(PP_TARGETS)-1 DO BEGIN  ; Loop through PP algorithms
        PP_TARGET = PP_TARGETS(TAR)
        SENSORS = ['SEAWIFS','MODIS']
        FOR SEN=0, N_ELEMENTS(SENSORS)-1 DO BEGIN   ; Loop through SENSORS
          SENSOR = SENSORS(SEN)
          CHL = 'CHLOR_A-PAN'
          PPD = 'PPD-'+PP_TARGET
          PAR = 'PAR'
          SST = 'SST'
          SDIR = 'SST-PAT-4'
          CASE SENSOR OF
            'SEAWIFS': BEGIN
              CDIR  = 'OC-SEAWIFS-9'
              IF CHLIN EQ 'PAN' THEN PDIR = 'PP-SEAWIFS_PAN-PAT-9' ELSE PDIR = 'PP-SEAWIFS-PAT-9'
              IF CHLIN EQ 'OC'  THEN CHL = 'CHLOR_A-OC4'
            END
            'MODIS': BEGIN
              CDIR  = 'OC-MODIS-4'
              IF CHLIN EQ 'PAN' THEN PDIR  = 'PP-MODIS_PAN-PAT-4' ELSE PDIR = 'PP-MODIS-PAT-4'
              IF CHLIN EQ 'OC'  THEN CHL = 'CHLOR_A-OC3M'
            END
          ENDCASE
          
          
          YEARS = YEAR_RANGE('1998','2007',/STRING)
          IF STRMID(SENSOR,0,3) EQ 'MOD' THEN YEARS = YEAR_RANGE('2008','2014',/STRING)        
          FOR Y=0, N_ELEMENTS(YEARS)-1 DO BEGIN
            AYEAR = YEARS(Y)
            DIRS  = [CDIR,PDIR,CDIR,SDIR,'',CDIR,PDIR,CDIR,SDIR]
            PRODS = [CHL,PPD,PAR,SST,'',CHL,PPD,PAR,SST]
            PERIODS = ['MONTH','MONTH','MONTH','MONTH','','M_'+AYEAR,'M_'+AYEAR,'M_'+AYEAR,'M_'+AYEAR]
            STAT    = ['NUM','NUM','NUM','NUM','','MEAN','MEAN','MEAN','MEAN']
            FOR C=0, N_ELEMENTS(CODE_TYPE)-1 DO BEGIN  ; Loop through CODE types (LME/FAO)
              CODES = LME_CODES
              NAMES = LME_NAMES
 ;codes = reverse(codes)
 ;names = reverse(names)             
              FOR N=0, N_ELEMENTS(CODES)-1 DO BEGIN    ; Loope through CODES
                ACODE = FIX(CODES(N))
                ANAME = NAMES(N)
                FILES = []
                FOR D=0, N_ELEMENTS(DIRS)-1 DO FILES = [FILES,FILE_SEARCH(FIX_PATH(!S.DATASETS + DIRS(D)+'/GEQ/STATS/'+PRODS(D)+'/'+PERIODS(D)+'*'+PRODS(D)+'*-'+STAT(D)+'.SAVE'))]
                FILES = FILES[WHERE(FILES NE '')]
                FP = PARSE_IT(FILES)
                PNGFILE = DIR_OUT + 'MONTH_'+YEARS(Y)+'_COMPOSITE-'+CHLIN+'-'+REPLACE(FP[0].NAME,FP[0].PERIOD, 'LME_CODE_' + NUM2STR(ACODE) + '-' + ANAME)+'.PNG'
                IF FILE_MAKE(FILES,PNGFILE,OVERWRITE=OVERWRITE) EQ 0 THEN CONTINUE
                
                BUF = 1
                SPC  = 10
                LF   = SPC * 2
                RT   = SPC * 8
                TP   = SPC * 5
                BOT  = SPC * 2
                NCOL = 12
                NROW = 9
                XDM  = 90
                YDM  = 90
                XNSPACE = NCOL-1 & YNSPACE = NROW-1
                WIDTH   = LF  + NCOL*XDM + XNSPACE*SPC + RT
                HEIGHT  = BOT + NROW*YDM + YNSPACE*SPC + TP
                W = WINDOW(DIMENSIONS=[WIDTH,HEIGHT],BUFFER=BUF)
                COUNTER = 0
                T = TEXT(WIDTH/2,HEIGHT-TP/2,REPLACE(ANAME,'_',' '),ALIGNMENT=0.5,VERTICAL_ALIGNMENT=0.25,/DEVICE,FONT_STYLE='BOLD')
                FOR D=0, N_ELEMENTS(DIRS)-1 DO BEGIN
                  IF DIRS(D) EQ '' THEN CONTINUE
                  FILES = FILE_SEARCH(FIX_PATH(!S.DATASETS + DIRS(D)+'/GEQ/STATS/'+PRODS(D)+'/'+PERIODS(D)+'*'+PRODS(D)+'*-'+STAT(D)+'.SAVE'))
                  FP = PARSE_IT(FILES)
                  FILES = FILES[SORT(FP.MONTH_START)]
                  MAPOUT = 'LME_'+ANAME
                  M = MAPS_SIZE(MAPOUT)
                  OUTLINE_FILE = FILE_SEARCH(DIR_OUTLINES + 'MASK_OUTLINE-LME_TOTAL-'+MAPOUT+'*-PXY_*'+'.PNG')
                  OUTLINE_COLOR = 0
                  OUTLINE_THICK = 2
                  FOR F=0, N_ELEMENTS(FILES)-1 DO BEGIN
                    C = COUNTER MOD NCOL
                    XPOS = LF + C*XDM + C*SPC
                    IF C EQ 0 THEN R = COUNTER/NCOL ELSE R = 0
                    IF F EQ 0 THEN YPOS = HEIGHT - TP - R*YDM - R*SPC ELSE YPOS = YPOS
                    POS = [XPOS,YPOS-YDM,XPOS+XDM,YPOS]
                    COUNTER = COUNTER + 1  
         if files(f) eq '' then CONTINUE           
                    DATA = STRUCT_SD_READ(FILES(F),STRUCT=STRUCT,MAP_OUT=MAPOUT)
                    PS   = PERIOD_2STRUCT(STRUCT.PERIOD)
                    MONTH = MONTH_NAMES(PS.MONTH_START,/SHORT)
                    IF D EQ 0 THEN TMT = TEXT(POS[0]+XDM/2,POS(3)+5,              MONTH,  ALIGNMENT=0.5,FONT_STYLE='BOLD',FONT_SIZE=10,/DEVICE)    
                    IF D EQ 5 THEN TMT = TEXT(POS[0]+XDM/2,POS(3)+5,AYEAR + ' ' + MONTH,  ALIGNMENT=0.5,FONT_STYLE='BOLD',FONT_SIZE=10,/DEVICE)
                    IF F EQ 0 THEN TYR = TEXT(LF/2,POS[1]+YDM/2,    VALIDS('PRODS',PRODS(D)),ALIGNMENT=0.5,FONT_STYLE='BOLD',FONT_SIZE=12,/DEVICE,VERTICAL_ALIGNMENT=0.5,ORIENTATION=90)        
                    USEPROD = VALIDS('PRODS',PRODS(D))
                    IF STRMID(STRUCT.PERIOD,0,5) EQ 'MONTH' THEN BEGIN
                      USEPROD = 'PERCENT' 
                      STRUCT.IMAGE = STRUCT.IMAGE/FLOAT(N_ELEMENTS(YEAR_RANGE(PS.YEAR_START,PS.YEAR_END)))*100.0 
                    ENDIF  
                    IM = STRUCT_SD_2IMAGE_NG(STRUCT,IMG_POSITION=POS,USE_PROD=USEPROD,SPECIAL_SCALE=SPECIAL_SCALE,/ADD_LAND,/ADD_COAST,/DEVICE,/CURRENT,PAL=PAL,/ADD_OUTLINE,OUTLINE_FILE=OUTLINE_FILE,OUTLINE_COLOR=OUTLINE_COLOR,OUTLINE_THICK=OUTLINE_THICK)
                  ENDFOR
                  
                  IF USEPROD EQ 'PERCENT' THEN TITLE = '%' ELSE TITLE = UNITS(VALIDS('PRODS',PRODS(D)),/NO_NAME)
                  CBAR = COLOR_BAR_SCALE_NG(PROD=USEPROD,SPECIAL_SCALE=SPECIAL_SCALE,PX=POS(2)+SPC/2,PY=POS(3),CHARSIZE=10,BACKGROUND=255,XDIM=YDM/5,YDIM=YDM,$
                    PAL=PAL,TITLE=TITLE,VERTICAL=1,RIGHT=1,FONT='HELVETICA',/CURRENT)
                ENDFOR ; DIRS 
                PRINT, 'WRITING: ' + PNGFILE
                W.SAVE,PNGFILE,RESOLUTION=200
                W.CLOSE 
              ENDFOR ; CODES
            ENDFOR ; YEARS
          ENDFOR ; CODE_TYPE
        ENDFOR ; SENSOR
      ENDFOR ; PP_TARGET
    ENDFOR ; CHL_ALG              
    STOP
  ENDIF ; DO_MONTHLY_COMPS  
    
; *******************************************************
  IF DO_SUMMED_STATS GE 1 THEN BEGIN  
; *******************************************************  

    OVERWRITE = DO_SUMMED_STATS GE 2
    
    DIR_STATS = DIR_SAVE_PAN + 'STATS-SAVE' + SL 
    
    
    FILES = FILE_SEARCH(DIR_STATS + 'ANNUAL_SUM*PRIMARY_PRODUCTION-STATS.SAVE')
    SAVEFILE = DIR_STATS + 'LME_FAO-CHL_PRIMARY_PRODUCTION-ANNUAL-SUMMARY.SAVE'
    CSVFILE  = DIR_STATS + 'LME_FAO-CHL_PRIMARY_PRODUCTION-ANNUAL-SUMMARY.csv'
    
    
    FOR I=0, N_ELEMENTS(FILES)-1 DO BEGIN
      D = IDL_RESTORE(FILES(I))
      IF I EQ 0 THEN STRUCT = D ELSE STRUCT = STRUCT_CONCAT(STRUCT,D)
    ENDFOR
    NEW = REPLICATE(CREATE_STRUCT('CATEGORY',''),N_ELEMENTS(STRUCT))
    NEW.CATEGORY = STRMID(STRUCT.MASK,0,3)
    STRUCT = STRUCT_MERGE(NEW,STRUCT)
    STRUCT = STRUCT[WHERE(STRUCT.CATEGORY NE MISSINGS(''))]
    STRUCT = STRUCT_COPY(STRUCT,TAGNAMES=['N_SUBAREA_PIXELS','TOTAL_PIXEL_AREA_KM2','PIXEL_GIS_RATIO','N_PIXELS_PER_GIS_AREA',$
      'TPP_ANNUAL_PIX_SUM','MPP_ANNUAL_PIX_SUM','NPP_ANNUAL_PIX_SUM','TPP_ANNUAL_GIS','MPP_ANNUAL_GIS','NPP_ANNUAL_GIS'],/REMOVE)
    STRUCT = STRUCT_RENAME(STRUCT,['TCHL_ANNUAL_MEAN',     'MCHL_ANNUAL_MEAN',     'NCHL_ANNUAL_MEAN',    'TPP_ANNUAL_MEAN',     'MPP_ANNUAL_MEAN',     'NPP_ANNUAL_MEAN',    'TPP_ANNUAL_GTON',     'MPP_ANNUAL_GTON',     'NPP_ANNUAL_GTON'],$
                                  ['TOTAL_CHL_ANNUAL_MEAN','MICRO_CHL_ANNUAL_MEAN','NANO_CHL_ANNUAL_MEAN','TOTAL_PP_ANNUAL_MEAN','MICRO_PP_ANNUAL_MEAN','NANO_PP_ANNUAL_MEAN','SUMMED_TOTAL_PP_GTON','SUMMED_MICRO_PP_GTON','SUMMED_NANO_PP_GTON'])
    SAVE,FILENAME=SAVEFILE,STRUCT
    STRUCT_2CSV,CSVFILE,STRUCT    
  STOP
			
	  DIR_STATS = DIR_SAVE + 'STATS-SAVE' + SL
		FILES = FILE_SEARCH(DIR_STATS + 'ANNUAL_SUM*PRIMARY_PRODUCTION-STATS.SAVE')
		SAVEFILE = DIR_STATS + 'ANNUAL-PRIMARY_PRODUCTION-STATS-SUMMARY.SAVE'
		CSVFILE  = DIR_STATS + 'ANNUAL-PRIMARY_PRODUCTION-STATS-SUMMARY.csv'
		
		STRUCT = CREATE_STRUCT('CATEGORY','','SUBAREA_CODE','','SUBAREA_NAME','','MASK','','GIS_AREA_KM2',0D,$
		  'INTERANNUAL_TOTAL_CHL_MEAN',0.0,'INTERANNUAL_MICRO_CHL_MEAN',0.0,'INTERANNUAL_NANO_CHL_MEAN',0.0,$
		  'INTERANNUAL_TOTAL_PP_MEAN',0.0,'INTERANNUAL_MICRO_PP_MEAN',0.0,'INTERANNUAL_NANO_PP_MEAN',0.0,$
		  'INTERANNUAL_TOTAL_SUMMED_PP_MEAN',0.0,'INTERANNUAL_MICRO_SUMMED_PP_MEAN',0.0,'INTERANNUAL_NANO_SUMMED_PP_MEAN',0.0,$
		  'INTERANNUAL_TOTAL_PP_VAR',0.0,'INTERANNUAL_MICRO_PP_VAR',0.0,'INTERANNUAL_NANO_PP_VAR',0.0)
		STRUCT = REPLICATE(STRUCT_2MISSINGS(STRUCT),N_ELEMENTS(FILES)*3)
		
		FOR I=0, N_ELEMENTS(FILES)-1 DO BEGIN
		  FP = FILE_PARSE(FILES(I))
		  D = IDL_RESTORE(FILES(I))
		  TAGS = TAG_NAMES(D)
		  
		  STRUCT(I).CATEGORY               = STRMID(D[0].MASK,0,3)
		  STRUCT(I).SUBAREA_CODE           = D[0].SUBAREA_CODE
		  STRUCT(I).SUBAREA_NAME           = D[0].SUBAREA_NAME
		  STRUCT(I).MASK                   = D[0].MASK
		  STRUCT(I).GIS_AREA_KM2           = D[0].GIS_AREA_KM2
		  STRUCT(I).INTERANNUAL_TOTAL_CHL_MEAN  = MEAN(D.TCHL_ANNUAL_MEAN,/NAN)
		  STRUCT(I).INTERANNUAL_MICRO_CHL_MEAN  = MEAN(D.MCHL_ANNUAL_MEAN,/NAN)
		  STRUCT(I).INTERANNUAL_NANO_CHL_MEAN   = MEAN(D.NCHL_ANNUAL_MEAN,/NAN)
		  STRUCT(I).INTERANNUAL_TOTAL_PP_MEAN  = MEAN(D.TPP_ANNUAL_MEAN,/NAN)
		  STRUCT(I).INTERANNUAL_MICRO_PP_MEAN  = MEAN(D.MPP_ANNUAL_MEAN,/NAN)
		  STRUCT(I).INTERANNUAL_NANO_PP_MEAN   = MEAN(D.NPP_ANNUAL_MEAN,/NAN)
		  STRUCT(I).INTERANNUAL_TOTAL_SUMMED_PP_MEAN  = MEAN(D.TPP_ANNUAL_GTON,/NAN)
		  STRUCT(I).INTERANNUAL_MICRO_SUMMED_PP_MEAN  = MEAN(D.MPP_ANNUAL_GTON,/NAN)
		  STRUCT(I).INTERANNUAL_NANO_SUMMED_PP_MEAN   = MEAN(D.NPP_ANNUAL_GTON,/NAN)
		  STRUCT(I).INTERANNUAL_TOTAL_PP_VAR  = VARIANCE(D.TPP_ANNUAL_GTON,/NAN)
		  STRUCT(I).INTERANNUAL_MICRO_PP_VAR  = VARIANCE(D.MPP_ANNUAL_GTON,/NAN)
		  STRUCT(I).INTERANNUAL_NANO_PP_VAR   = VARIANCE(D.NPP_ANNUAL_GTON,/NAN)
		ENDFOR
		STRUCT = STRUCT[WHERE(STRUCT.CATEGORY NE MISSINGS(''))]
		SAVE,FILENAME=SAVEFILE,STRUCT
		STRUCT_2CSV,CSVFILE,STRUCT		
  			
  ENDIF ; DO_SUMMED_STATS 		

  
  
  
; *******************************************************
  IF DO_FINAL_COMPOSITES GE 1 THEN BEGIN
; *******************************************************
    OVERWRITE = DO_FINAL_COMPOSITES GE 2
     
    CHLIN = 'OC'
    PPALG = 'VGPM2'
    IF CHLIN EQ 'PAN' THEN DIR_CONCAT = DIR_SAVE_PAN + 'PP_CORRECTED_CONCAT' + SL ELSE DIR_CONCAT = DIR_SAVE_OC + 'PP_CORRECTED_CONCAT' + SL 
    BUFFER = 1
    
    TARGETS = ['LME','FAO']    
    MAP_IN = 'GEQ'
    SPDIR = DIR_DATASETS + 'PP-SEAWIFS-PAT-9/GEQ/'
    SCDIR = DIR_DATASETS + 'OC-SEAWIFS-9/GEQ/'
    MPDIR = DIR_DATASETS + 'PP-MODIS-PAT-4/GEQ/'
    MCDIR = DIR_DATASETS + 'OC-MODIS-4/GEQ/'
    
  ;  LAND = READ_LANDMASK(MAP=MAP_IN,PX=4096,PY=2048,/STRUCT)
  ;  LL = MAPS_2LONLAT(MAP_IN,PX=4096,PY=2048)
  ;  IMG = BYTARR(4096,2048) & IMG(*) = 251
  ;  IMG(LAND.LAND)  = 251
  ;  IMG(LAND.OCEAN) = 254      
    
    CFILE   = FILE_SEARCH(FIX_PATH(SCDIR + 'STATS\CHLOR_A-OC4\ANNUAL*GEQ*MEAN.SAVE'))
    MCFILE  = FILE_SEARCH(FIX_PATH(SCDIR + 'STATS\MICRO-PAN\ANNUAL*GEQ*MEAN.SAVE'))
    NCFILE  = FILE_SEARCH(FIX_PATH(SCDIR + 'STATS\NANOPICO-PAN\ANNUAL*GEQ*MEAN.SAVE'))
    MCPFILE = FILE_SEARCH(FIX_PATH(SCDIR + 'STATS\MICRO_PERCENTAGE-PAN\ANNUAL*GEQ*MEAN.SAVE'))
    NCPFILE = FILE_SEARCH(FIX_PATH(SCDIR + 'STATS\NANOPICO_PERCENTAGE-PAN\ANNUAL*GEQ*MEAN.SAVE'))
    
    VFILE   = FILE_SEARCH(FIX_PATH(SPDIR + 'STATS\PPD-VGPM2\ANNUAL*GEQ*MEAN.SAVE'))
    VMFILE  = FILE_SEARCH(FIX_PATH(SPDIR + 'STATS\MICROPP-MARMAP_PAN_VGPM2\ANNUAL*GEQ*MEAN.SAVE'))
    VNFILE  = FILE_SEARCH(FIX_PATH(SPDIR + 'STATS\NANOPICOPP-MARMAP_PAN_VGPM2\ANNUAL*GEQ*MEAN.SAVE'))
    VMPFILE = FILE_SEARCH(FIX_PATH(SPDIR + 'STATS\MICROPP_PERCENTAGE-MARMAP_PAN_VGPM2\ANNUAL*GEQ*MEAN.SAVE'))
    VNPFILE = FILE_SEARCH(FIX_PATH(SPDIR + 'STATS\NANOPICOPP_PERCENTAGE-MARMAP_PAN_VGPM2\ANNUAL*GEQ*MEAN.SAVE'))
    
    FOR TAR=0, N_ELEMENTS(TARGETS)-1 DO BEGIN
      ATARGET = TARGETS(TAR)
      TARGET  = STRMID(ATARGET,0,3)
      
      MFILE   = DIR_SUMMARY + 'CLIMATOLOGICAL_MONTHLY_MEAN_CORRECTED-' + CHLIN + '-' + TARGET + '-MERGED_CHL_PP_DATA.SAV'
      AFILE   = DIR_CONCAT + 'ANNUAL_CORRECTED_SUM-' + CHLIN + '-' + TARGET + '-MERGED_CHL_PP_' + PPALG + '.SAV'
      
      MONTH_DATA  = IDL_RESTORE(MFILE)
      ANNUAL_DATA = IDL_RESTORE(AFILE)
      MONTH_DATA( WHERE(FINITE(MONTH_DATA.CLIM_MONTH_CHL_MICRO)        EQ 0)).CLIM_MONTH_CHL_MICRO        = 0.0 ; Make missing data 0.0 for the bar plots
      MONTH_DATA( WHERE(FINITE(MONTH_DATA.CLIM_MONTH_CHL_NANO)         EQ 0)).CLIM_MONTH_CHL_NANO         = 0.0
      MONTH_DATA( WHERE(FINITE(MONTH_DATA.CLIM_MONTH_MEAN_VGPM2_MICRO) EQ 0)).CLIM_MONTH_MEAN_VGPM2_MICRO = 0.0
      MONTH_DATA( WHERE(FINITE(MONTH_DATA.CLIM_MONTH_MEAN_VGPM2_NANO)  EQ 0)).CLIM_MONTH_MEAN_VGPM2_NANO  = 0.0
      ANNUAL_DATA(WHERE(FINITE(ANNUAL_DATA.MCHL_ANNUAL_MEAN)           EQ 0)).MCHL_ANNUAL_MEAN            = 0.0
      ANNUAL_DATA(WHERE(FINITE(ANNUAL_DATA.NCHL_ANNUAL_MEAN)           EQ 0)).NCHL_ANNUAL_MEAN            = 0.0
      ANNUAL_DATA(WHERE(FINITE(ANNUAL_DATA.MPP_CLIM_ANNUAL_TTON)       EQ 0)).MPP_CLIM_ANNUAL_TTON        = 0.0
      ANNUAL_DATA(WHERE(FINITE(ANNUAL_DATA.NPP_CLIM_ANNUAL_TTON)       EQ 0)).NPP_CLIM_ANNUAL_TTON        = 0.0
      
      IF TARGET EQ 'FAO' THEN BEGIN  
        SUBAREA1 = 'FAO_TOTAL'
        SUBAREA2 = 'FAO_MINUS_LME'
        TARS = READALL(!S.DATA+'FAO_NAMES.csv')             
        MASK = STRUCT_SD_READ(!S.SUBAREAS + 'MASK_SUBAREA-'+MAP_IN+'-PXY_4096_2048-FAO_MINUS.SAV',STRUCT=FSTRUCT)
        TFAO = STRUCT_SD_READ(!S.SUBAREAS + 'MASK_SUBAREA-'+MAP_IN+'-PXY_4096_2048-FAO_TOTAL.SAV',STRUCT=FSTRUCT)
        L3 = []      
        EXCLUDE_FAOS = ['0','1','2','18','37','48','58','88']
        OK = WHERE_MATCH(FSTRUCT.SUBAREA_CODE,EXCLUDE_FAOS,COUNT,COMPLEMENT=COMPLEMENT)
        CODES = FSTRUCT.SUBAREA_CODE(COMPLEMENT)
        NAMES = FSTRUCT.SUBAREA_NAME(COMPLEMENT)
      ENDIF  
      IF TARGET EQ 'LME' THEN BEGIN     
        SUBAREA1 = 'LME_LT_300'
        SUBAREA2 = 'LME_GT_300'  
        TARS = READALL(!S.DATA + 'lme_names.csv') 
        MASK = STRUCT_SD_READ(!S.SUBAREAS + 'MASK_SUBAREA-'+MAP_IN+'-PXY_4096_2048-LME_TOTAL.SAV',STRUCT=LSTRUCT)
        L3   = STRUCT_SD_READ(!S.SUBAREAS + 'MASK_SUBAREA-'+MAP_IN+'-PXY_4096_2048-LME_0_300.SAV',STRUCT=L3STRUCT)
        EXCLUDE_LMES = ['255','0','251','64','63','62','61','58','57','56','55','54']
        OK = WHERE_MATCH(LSTRUCT.SUBAREA_CODE,EXCLUDE_LMES,COUNT,COMPLEMENT=COMPLEMENT)
        CODES  = LSTRUCT.SUBAREA_CODE(COMPLEMENT)
        NAMES  = LSTRUCT.SUBAREA_NAME(COMPLEMENT)        
      ENDIF  
      FOR C=0, N_ELEMENTS(CODES)-1 DO BEGIN
        CODE = CODES(C)
;if code eq 32 then stop        
        NAME = NAMES(C)
        OK = WHERE(TARS.SUBAREA_NAME EQ NAME)
        TITLE = TARS[OK].NAME
        PNGFILE = FIX_PATH(DIR_COMPS + TARGET +'_' + NUM2STR(CODE) + '-' + NAME+'-PHYTO_COMPOSITE.PNG')
        
        IF FILE_MAKE([MFILE,AFILE],PNGFILE,OVERWRITE=OVERWRITE) EQ 0 THEN CONTINUE
        MDATA  = MONTH_DATA[WHERE(MONTH_DATA.SUBAREA_NAME EQ NAME)]
        ADATA  = ANNUAL_DATA[WHERE(ANNUAL_DATA.SUBAREA_NAME EQ NAME)]
         
        OUTLINE_FILES = []
        IF TARGET EQ 'LME' THEN BEGIN
          PAL_36,R,G,B
          M = MAPS_SIZE('LME_'+NAME)     
          
          LME_OUTLINE_FILE = FILE_SEARCH(DIR_OUTLINES + 'MASK_OUTLINE-LME_TOTAL-LME_' + NAME + '-PXY_*.PNG',COUNT) & IF COUNT NE 1 THEN STOP
          

          L3_OUTLINE_FILE = DIR_OUTLINES + 'MASK_OUTLINE-LME_0_300-'+M.MAP+'-PXY_'+STRTRIM(M.PX,2)+'_'+STRTRIM(M.PY,2)+'.PNG'
          IF FILE_TEST(L3_OUTLINE_FILE) EQ 0 THEN STOP
          
          LANDMASK_FILE = !S.LANDMASKS + 'MASK_LAND-'+M.MAP+'-PXY_'+STRTRIM(M.PX,2)+'_'+STRTRIM(M.PY,2)+'.PNG'
          IF FILE_TEST(LANDMASK_FILE) EQ 0 THEN STOP
          
          
          
          OUTLINE_FILES = [L3_OUTLINE_FILE,LME_OUTLINE_FILE]
          OUTLINE_COLORS = [255,0]
          OUTLINE_THICK = 2
              
        ENDIF 
        
        IF TARGET EQ 'FAO' THEN BEGIN
          PAL_36,R,G,B
          M = MAPS_SIZE('FAO_'+NAME)
          OUTLINE_FILE = DIR_OUTLINES + 'MASK_OUTLINE-FAO_TOTAL-'+M.MAP+'-PXY_'+STRTRIM(M.PX,2)+'_'+STRTRIM(M.PY,2)+'.PNG'
          IF FILE_TEST(OUTLINE_FILE) EQ 1 AND NOT KEYWORD_SET(OVERWRITE) THEN GOTO, SKIP_OUTLINE_FAO
          OK = WHERE(TFAO EQ CODE,COUNT)
          IF COUNT GE 10 THEN BEGIN
            BLANK = BYTARR(4096,2048)
            BLANK[OK] = 255
            BLANK = MAP_REMAP(BLANK,MAP_IN=MAP_IN,MAP_OUT=M.MAP,FAO_CODE_OUT=CODE,PX_OUT=M.PX,PY_OUT=M.PY,/REFRESH)
            OUTLINE = IMAGE_OUTLINE(BLANK)
            OUTLINE(WHERE(OUTLINE EQ 1)) = 250
            WRITE_PNG, OUTLINE_FILE,OUTLINE,R,G,B
          ENDIF
          SKIP_OUTLINE_FAO:
          
          FAO_OUTLINE_FILE = DIR_OUTLINES + 'MASK_OUTLINE-FAO_MINUS-'+M.MAP+'-PXY_'+STRTRIM(M.PX,2)+'_'+STRTRIM(M.PY,2)+'.PNG'
          IF FILE_TEST(FAO_OUTLINE_FILE) EQ 1 AND NOT KEYWORD_SET(OVERWRITE) THEN GOTO, SKIP_FAO_OUTLINE
          OK = WHERE(MASK EQ CODE,COUNT)
          IF COUNT GT 10 THEN BEGIN
            BLANK = BYTARR(4096,2048)
            BLANK[OK] = 255
            BLANK = MAP_REMAP(BLANK,MAP_IN=MAP_IN,MAP_OUT=M.MAP,FAO_CODE_OUT=CODE,PX_OUT=M.PX,PY_OUT=M.PY,/REFRESH)
            OUTLINE = IMAGE_OUTLINE(BLANK)
            OUTLINE(WHERE(OUTLINE EQ 1)) = 250
            WRITE_PNG, FAO_OUTLINE_FILE,OUTLINE,R,G,B
          ENDIF
          SKIP_FAO_OUTLINE:
          OUTLINE_FILES = [FAO_OUTLINE_FILE]
          OUTLINE_COLORS = [0]
          OUTLINE_THICK = 4
                    
          LANDMASK_FILE = !S.LANDMASKS + 'MASK_LAND-'+M.MAP+'-PXY_'+STRTRIM(M.PX,2)+'_'+STRTRIM(M.PY,2)+'.PNG'
          IF FILE_TEST(LANDMASK_FILE) EQ 0 OR KEYWORD_SET(OVERWRITE) THEN $
            LANDMASK_REMAP,MAP_OUT=M.MAP,MAP_IN=MAP_IN,PX_OUT=M.PX,PY_OUT=M.PY,FIX_COAST=1,OVERWRITE=OVERWRITE
        ENDIF

        LAND_COLOR = 251
        CSCALE = 'LOW' 
        VSCALE = 'LOW'
        CPSCALE = '100'
        VPSCALE = '100'
        CGROUPS = ['MICRO','NANOPICO']
        CCOLORS = ['YELLOW','MEDIUM_AQUAMARINE']
        PGROUPS = ['MICRO','NANOPICO']
        PCOLORS = ['YELLOW','MEDIUM_AQUAMARINE']
            
        DATA = STRUCT_SD_READ(CFILE,  MAP_OUT=TARGET+'_'+NAME,LME_CODE_OUT=CODE,STRUCT=CHL)  
        DATA = STRUCT_SD_READ(MCFILE, MAP_OUT=TARGET+'_'+NAME,LME_CODE_OUT=CODE,STRUCT=CMICRO)
        DATA = STRUCT_SD_READ(NCFILE, MAP_OUT=TARGET+'_'+NAME,LME_CODE_OUT=CODE,STRUCT=CNANO) 
        DATA = STRUCT_SD_READ(MCPFILE,MAP_OUT=TARGET+'_'+NAME,LME_CODE_OUT=CODE,STRUCT=CMPER) 
        DATA = STRUCT_SD_READ(NCPFILE,MAP_OUT=TARGET+'_'+NAME,LME_CODE_OUT=CODE,STRUCT=CNPER) 
        DATA = STRUCT_SD_READ(VFILE,  MAP_OUT=TARGET+'_'+NAME,LME_CODE_OUT=CODE,STRUCT=VGPM)  
        DATA = STRUCT_SD_READ(VMFILE, MAP_OUT=TARGET+'_'+NAME,LME_CODE_OUT=CODE,STRUCT=VMICRO)
        DATA = STRUCT_SD_READ(VNFILE, MAP_OUT=TARGET+'_'+NAME,LME_CODE_OUT=CODE,STRUCT=VNANO) 
        DATA = STRUCT_SD_READ(VMPFILE,MAP_OUT=TARGET+'_'+NAME,LME_CODE_OUT=CODE,STRUCT=VMPER) 
        DATA = STRUCT_SD_READ(VNPFILE,MAP_OUT=TARGET+'_'+NAME,LME_CODE_OUT=CODE,STRUCT=VNPER) 
        GONE, DATA
      
        W = WINDOW(DIMENSIONS=[800,1040],BUFFER=BUFFER)
        T    = TEXT(400,1020,TARGET+' (' + NUM2STR(CODE) + ') ' + TITLE,ALIGNMENT=0.5,/DEVICE,FONT_SIZE=14,FONT_STYLE='BOLD') 
        TT   = TEXT([150,590],[1000,1000],['Chlorophyll','Primary Production'],ALIGNMENT=0.5,/DEVICE,FONT_SIZE=14)      
        TS   = TEXT([70, 220,470,620],[685,685,685,685],['Micro','Nano+Pico','Micro','Nano+Pico'],FONT_SIZE=12,ALIGNMENT=0.5,/DEVICE)      
   
        CIM  = STRUCT_SD_2IMAGE_NG(CHL, IMG_POSITION=[5,  705,295,995],USE_PROD='CHLOR_A',SPECIAL_SCALE=CSCALE,/ADD_OUTLINE,/ADD_LAND,/ADD_COAST,LAND_COLOR=LAND_COLOR,OUTLINE_FILE=OUTLINE_FILES,OUTLINE_COLOR=OUTLINE_COLORS,OUTLINE_THICK=OUTLINE_THICK,/CURRENT,MARGIN=MARGIN,/DEVICE,BUFFER=BUFFER)
        VIM  = STRUCT_SD_2IMAGE_NG(VGPM,IMG_POSITION=[405,705,695,995],USE_PROD='PPD',    SPECIAL_SCALE=VSCALE,/ADD_OUTLINE,/ADD_LAND,/ADD_COAST,LAND_COLOR=LAND_COLOR,OUTLINE_FILE=OUTLINE_FILES,OUTLINE_COLOR=OUTLINE_COLORS,OUTLINE_THICK=OUTLINE_THICK,/CURRENT,MARGIN=MARGIN,/DEVICE,BUFFER=BUFFER)
        
        CIM  = STRUCT_SD_2IMAGE_NG(CMICRO,IMG_POSITION=[5,  540,145,680],USE_PROD='CHLOR_A',SPECIAL_SCALE=CSCALE,/ADD_OUTLINE,/ADD_LAND,/ADD_COAST,LAND_COLOR=LAND_COLOR,OUTLINE_FILE=OUTLINE_FILES,OUTLINE_COLOR=OUTLINE_COLORS,OUTLINE_THICK=OUTLINE_THICK,/CURRENT,MARGIN=MARGIN,/DEVICE,BUFFER=BUFFER)
        CIM  = STRUCT_SD_2IMAGE_NG(CNANO, IMG_POSITION=[155,540,295,680],USE_PROD='CHLOR_A',SPECIAL_SCALE=CSCALE,/ADD_OUTLINE,/ADD_LAND,/ADD_COAST,LAND_COLOR=LAND_COLOR,OUTLINE_FILE=OUTLINE_FILES,OUTLINE_COLOR=OUTLINE_COLORS,OUTLINE_THICK=OUTLINE_THICK,/CURRENT,MARGIN=MARGIN,/DEVICE,BUFFER=BUFFER)
        CIM  = STRUCT_SD_2IMAGE_NG(CMPER, IMG_POSITION=[5,  390,145,530],USE_PROD='PERCENT',SPECIAL_SCALE=CPSCALE,/ADD_OUTLINE,/ADD_LAND,/ADD_COAST,LAND_COLOR=LAND_COLOR,OUTLINE_FILE=OUTLINE_FILES,OUTLINE_COLOR=OUTLINE_COLORS,OUTLINE_THICK=OUTLINE_THICK,/CURRENT,MARGIN=MARGIN,/DEVICE,BUFFER=BUFFER)
        CIM  = STRUCT_SD_2IMAGE_NG(CNPER, IMG_POSITION=[155,390,295,530],USE_PROD='PERCENT',SPECIAL_SCALE=CPSCALE,/ADD_OUTLINE,/ADD_LAND,/ADD_COAST,LAND_COLOR=LAND_COLOR,OUTLINE_FILE=OUTLINE_FILES,OUTLINE_COLOR=OUTLINE_COLORS,OUTLINE_THICK=OUTLINE_THICK,/CURRENT,MARGIN=MARGIN,/DEVICE,BUFFER=BUFFER)
        
        VIM  = STRUCT_SD_2IMAGE_NG(VMICRO,IMG_POSITION=[405,540,545,680],USE_PROD='PPD',    SPECIAL_SCALE=VSCALE,/ADD_OUTLINE,/ADD_LAND,/ADD_COAST,LAND_COLOR=LAND_COLOR,OUTLINE_FILE=OUTLINE_FILES,OUTLINE_COLOR=OUTLINE_COLORS,OUTLINE_THICK=OUTLINE_THICK,/CURRENT,MARGIN=MARGIN,/DEVICE,BUFFER=BUFFER)
        VIM  = STRUCT_SD_2IMAGE_NG(VNANO, IMG_POSITION=[555,540,695,680],USE_PROD='PPD',    SPECIAL_SCALE=VSCALE,/ADD_OUTLINE,/ADD_LAND,/ADD_COAST,LAND_COLOR=LAND_COLOR,OUTLINE_FILE=OUTLINE_FILES,OUTLINE_COLOR=OUTLINE_COLORS,OUTLINE_THICK=OUTLINE_THICK,/CURRENT,MARGIN=MARGIN,/DEVICE,BUFFER=BUFFER)
        VIM  = STRUCT_SD_2IMAGE_NG(VMPER, IMG_POSITION=[405,390,545,530],USE_PROD='PERCENT',SPECIAL_SCALE=VPSCALE,/ADD_OUTLINE,/ADD_LAND,/ADD_COAST,LAND_COLOR=LAND_COLOR,OUTLINE_FILE=OUTLINE_FILES,OUTLINE_COLOR=OUTLINE_COLORS,OUTLINE_THICK=OUTLINE_THICK,/CURRENT,MARGIN=MARGIN,/DEVICE,BUFFER=BUFFER)
        VIM  = STRUCT_SD_2IMAGE_NG(VNPER, IMG_POSITION=[555,390,695,530],USE_PROD='PERCENT',SPECIAL_SCALE=VPSCALE,/ADD_OUTLINE,/ADD_LAND,/ADD_COAST,LAND_COLOR=LAND_COLOR,OUTLINE_FILE=OUTLINE_FILES,OUTLINE_COLOR=OUTLINE_COLORS,OUTLINE_THICK=OUTLINE_THICK,/CURRENT,MARGIN=MARGIN,/DEVICE,BUFFER=BUFFER)
        
        BAR = COLOR_BAR_SCALE_NG(PROD='CHLOR_A',SPECIAL_SCALE=CSCALE, PX=305,PY=985,CHARSIZE=10,BACKGROUND=252,XDIM=20,YDIM=260,PAL='PAL_SW3',VERTICAL=1,RIGHT=1,FONT='HELVETICA',/CURRENT,TITLE=UNITS('CHLOROPHYLL'),BUFFER=BUFFER)
        BAR = COLOR_BAR_SCALE_NG(PROD='PPD',    SPECIAL_SCALE=VSCALE, PX=705,PY=985,CHARSIZE=10,BACKGROUND=252,XDIM=20,YDIM=260,PAL='PAL_SW3',VERTICAL=1,RIGHT=1,FONT='HELVETICA',/CURRENT,TITLE=UNITS('PRIMARY_PRODUCTION'),BUFFER=BUFFER)
        BAR = COLOR_BAR_SCALE_NG(PROD='CHLOR_A',SPECIAL_SCALE=CSCALE, PX=305,PY=675,CHARSIZE=10,BACKGROUND=252,XDIM=20,YDIM=130,PAL='PAL_SW3',VERTICAL=1,RIGHT=1,FONT='HELVETICA',/CURRENT,TITLE=UNITS('CHLOROPHYLL'),BUFFER=BUFFER)
        BAR = COLOR_BAR_SCALE_NG(PROD='PERCENT',SPECIAL_SCALE=CPSCALE,PX=305,PY=525,CHARSIZE=10,BACKGROUND=252,XDIM=20,YDIM=130,PAL='PAL_SW3',VERTICAL=1,RIGHT=1,FONT='HELVETICA',/CURRENT,TITLE=UNITS('PERCENT'),BUFFER=BUFFER)
        BAR = COLOR_BAR_SCALE_NG(PROD='PPD',    SPECIAL_SCALE=CSCALE, PX=705,PY=675,CHARSIZE=10,BACKGROUND=252,XDIM=20,YDIM=130,PAL='PAL_SW3',VERTICAL=1,RIGHT=1,FONT='HELVETICA',/CURRENT,TITLE=UNITS('PRIMARY_PRODUCTION'),BUFFER=BUFFER)
        BAR = COLOR_BAR_SCALE_NG(PROD='PERCENT',SPECIAL_SCALE=VPSCALE,PX=705,PY=525,CHARSIZE=10,BACKGROUND=252,XDIM=20,YDIM=130,PAL='PAL_SW3',VERTICAL=1,RIGHT=1,FONT='HELVETICA',/CURRENT,TITLE=UNITS('PERCENT'),BUFFER=BUFFER)          


; ***** BAR PLOTS *****
        NBARS = 2
        MX = DATE_AXIS([20200101,20201231],/MONTH,/MID,/FYEAR,STEP_SIZE=1)
        MXRANGE = DATE_2JD([201912316,20210114])
        MBOT = REPLICATE(0, 12)
        
        AX = DATE_AXIS([19980101,20140101],/YEAR,/YY,STEP_SIZE=2)
        AXRANGE = DATE_2JD([19970101,20150101])      
        ABOT = REPLICATE(0,17)
        
;       MONTHLY CHLOROPHYLL BAR PLOTS
        SUBS1 = MDATA[WHERE(MDATA.MASK EQ SUBAREA1)] & MCHL1 = SUBS1.CLIM_MONTH_CHL_MICRO & NCHL1 = SUBS1.CLIM_MONTH_CHL_NANO
        SUBS2 = MDATA[WHERE(MDATA.MASK EQ SUBAREA2)] & MCHL2 = SUBS2.CLIM_MONTH_CHL_MICRO & NCHL2 = SUBS2.CLIM_MONTH_CHL_NANO
        MAX_CHL = MAX([MCHL1+NCHL1,MCHL2+NCHL2],/NAN) 
        MDATES = JD_ADD(DATE_2JD('2020'+SUBS1.MONTH),14,/DAY)
        
        POSITION = [65,230,345,370]
        P = PLOT(MXRANGE,[0,MAX_CHL],YTITLE='CHL ' + UNITS('CHLOROPHYLL',/NO_NAME),TITLE='Monthly',XTICKVALUE=MX.TICKV,FONT_SIZE=11,POSITION=POSITION,XRANGE=MXRANGE,$
          XMINOR=0,YMINOR=2,XSTYLE=1,XTICKNAME=MX.TICKNAME,/NODATA,BUFFER=BUFFER,MARGIN=MARGIN,LAYOUT=LAYOUT,/CURRENT,/DEVICE)
        BYRANGE = P.YRANGE
        YTICKNAME = P.YTICKNAME
        YTICKV  = P.YTICKVALUE
        YMINOR = P.YMINOR
              
        NBAR1 = BARPLOT(MDATES,NCHL1,      NBARS=NBARS,INDEX=0,BOTTOM_VALUES=MBOT, FILL_COLOR='MEDIUM_AQUAMARINE',LINESTYLE=LINESTYLE,/OVERPLOT,YRANGE=BYRANGE,XRANGE=MXRANGE,XTICKVALUE=MX.TICKV,XTICKNAME=MX.TICKNAME,YTICKVALUE=YTICKV,YTICKNAME=YTICKNAME,YMINOR=YMINOR,BUFFER=BUFFER)
        MBAR1 = BARPLOT(MDATES,NCHL1+MCHL1,NBARS=NBARS,INDEX=0,BOTTOM_VALUES=NCHL1,FILL_COLOR='YELLOW',           LINESTYLE=LINESTYLE,/OVERPLOT,YRANGE=BYRANGE,XRANGE=MXRANGE,XTICKVALUE=MX.TICKV,XTICKNAME=MX.TICKNAME,YTICKVALUE=YTICKV,YTICKNAME=YTICKNAME,YMINOR=YMINOR,BUFFER=BUFFER)
        NBAR2 = BARPLOT(MDATES,NCHL2,      NBARS=NBARS,INDEX=1,BOTTOM_VALUES=MBOT, FILL_COLOR='BLUE',             LINESTYLE=LINESTYLE,/OVERPLOT,YRANGE=BYRANGE,XRANGE=MXRANGE,XTICKVALUE=MX.TICKV,XTICKNAME=MX.TICKNAME,YTICKVALUE=YTICKV,YTICKNAME=YTICKNAME,YMINOR=YMINOR,BUFFER=BUFFER)
        MBAR2 = BARPLOT(MDATES,NCHL2+MCHL2,NBARS=NBARS,INDEX=1,BOTTOM_VALUES=NCHL2,FILL_COLOR='ORANGE',           LINESTYLE=LINESTYLE,/OVERPLOT,YRANGE=BYRANGE,XRANGE=MXRANGE,XTICKVALUE=MX.TICKV,XTICKNAME=MX.TICKNAME,YTICKVALUE=YTICKV,YTICKNAME=YTICKNAME,YMINOR=YMINOR,BUFFER=BUFFER) 

;       ANNUAL CHLOROPHYLL BAR PLOTS
        SUBS1 = ADATA[WHERE(ADATA.MASK EQ SUBAREA1)] & MCHL1 = SUBS1.MCHL_ANNUAL_MEAN & NCHL1 = SUBS1.NCHL_ANNUAL_MEAN
        SUBS2 = ADATA[WHERE(ADATA.MASK EQ SUBAREA2)] & MCHL2 = SUBS2.MCHL_ANNUAL_MEAN & NCHL2 = SUBS2.NCHL_ANNUAL_MEAN
        MAX_CHL = MAX([MCHL1+NCHL1,MCHL2+NCHL2],/NAN)
        ADATES = DATE_2JD(SUBS1.YEAR)
        
        POSITION = [65,55,345,195]
        P = PLOT(AXRANGE,[0,MAX_CHL],YTITLE='CHL ' + UNITS('CHLOROPHYLL',/NO_NAME),TITLE='Annual',XTICKVALUE=AX.TICKV,FONT_SIZE=11,POSITION=POSITION,XRANGE=AXRANGE,$
          XMINOR=0,YMINOR=2,XSTYLE=1,XTICKNAME=AX.TICKNAME,/NODATA,BUFFER=BUFFER,MARGIN=MARGIN,LAYOUT=LAYOUT,/CURRENT,/DEVICE)
        BYRANGE = P.YRANGE
        YTICKNAME = P.YTICKNAME
        YTICKV  = P.YTICKVALUE
        YMINOR = P.YMINOR
              
        NBAR1 = BARPLOT(ADATES,NCHL1,      NBARS=NBARS,INDEX=0,BOTTOM_VALUES=ABOT, FILL_COLOR='MEDIUM_AQUAMARINE',LINESTYLE=LINESTYLE,/OVERPLOT,YRANGE=BYRANGE,XRANGE=AXRANGE,XTICKVALUE=AX.TICKV,XTICKNAME=AX.TICKNAME,YTICKVALUE=YTICKV,YTICKNAME=YTICKNAME,YMINOR=YMINOR,BUFFER=BUFFER)
        MBAR1 = BARPLOT(ADATES,NCHL1+MCHL1,NBARS=NBARS,INDEX=0,BOTTOM_VALUES=NCHL1,FILL_COLOR='YELLOW',           LINESTYLE=LINESTYLE,/OVERPLOT,YRANGE=BYRANGE,XRANGE=AXRANGE,XTICKVALUE=AX.TICKV,XTICKNAME=AX.TICKNAME,YTICKVALUE=YTICKV,YTICKNAME=YTICKNAME,YMINOR=YMINOR,BUFFER=BUFFER)
        NBAR2 = BARPLOT(ADATES,NCHL2,      NBARS=NBARS,INDEX=1,BOTTOM_VALUES=ABOT, FILL_COLOR='BLUE',             LINESTYLE=LINESTYLE,/OVERPLOT,YRANGE=BYRANGE,XRANGE=AXRANGE,XTICKVALUE=AX.TICKV,XTICKNAME=AX.TICKNAME,YTICKVALUE=YTICKV,YTICKNAME=YTICKNAME,YMINOR=YMINOR,BUFFER=BUFFER)
        MBAR2 = BARPLOT(ADATES,NCHL2+MCHL2,NBARS=NBARS,INDEX=1,BOTTOM_VALUES=NCHL2,FILL_COLOR='ORANGE',           LINESTYLE=LINESTYLE,/OVERPLOT,YRANGE=BYRANGE,XRANGE=AXRANGE,XTICKVALUE=AX.TICKV,XTICKNAME=AX.TICKNAME,YTICKVALUE=YTICKV,YTICKNAME=YTICKNAME,YMINOR=YMINOR,BUFFER=BUFFER)
        
;       MONTHLY PRODUCTIVITY BAR PLOTS            
        SUBS1 = MDATA[WHERE(MDATA.MASK EQ SUBAREA1)] & MPP1 = SUBS1.CLIM_MONTH_MEAN_VGPM2_MICRO & NPP1 = SUBS1.CLIM_MONTH_MEAN_VGPM2_NANO
        SUBS2 = MDATA[WHERE(MDATA.MASK EQ SUBAREA2)] & MPP2 = SUBS2.CLIM_MONTH_MEAN_VGPM2_MICRO & NPP2 = SUBS2.CLIM_MONTH_MEAN_VGPM2_NANO
        MAX_PP = MAX([MPP1+NPP1,MPP2+NPP2],/NAN)
        MDATES = JD_ADD(DATE_2JD('2020'+SUBS1.MONTH),14,/DAY)
        
        POSITION = [460,230,740,370]
        P = PLOT(MXRANGE,[0,MAX_PP],YTITLE='PP ' + UNITS('PPD',/NO_NAME),TITLE='Monthly',XTICKVALUE=MX.TICKV,FONT_SIZE=11,POSITION=POSITION,XRANGE=MXRANGE,$
          XMINOR=0,YMINOR=2,XSTYLE=1,XTICKNAME=MX.TICKNAME,/NODATA,BUFFER=BUFFER,MARGIN=MARGIN,LAYOUT=LAYOUT,/CURRENT,/DEVICE)
        BYRANGE = P.YRANGE
        YTICKNAME = P.YTICKNAME
        YTICKV  = P.YTICKVALUE
        YMINOR = P.YMINOR
              
        NBAR1 = BARPLOT(MDATES,NPP1,     NBARS=NBARS,INDEX=0,BOTTOM_VALUES=MBOT,FILL_COLOR='MEDIUM_AQUAMARINE',LINESTYLE=LINESTYLE,/OVERPLOT,YRANGE=BYRANGE,XRANGE=MXRANGE,XTICKVALUE=MX.TICKV,XTICKNAME=MX.TICKNAME,YTICKVALUE=YTICKV,YTICKNAME=YTICKNAME,YMINOR=YMINOR,BUFFER=BUFFER)
        MBAR1 = BARPLOT(MDATES,NPP1+MPP1,NBARS=NBARS,INDEX=0,BOTTOM_VALUES=NPP1,FILL_COLOR='YELLOW',           LINESTYLE=LINESTYLE,/OVERPLOT,YRANGE=BYRANGE,XRANGE=MXRANGE,XTICKVALUE=MX.TICKV,XTICKNAME=MX.TICKNAME,YTICKVALUE=YTICKV,YTICKNAME=YTICKNAME,YMINOR=YMINOR,BUFFER=BUFFER)
        NBAR2 = BARPLOT(MDATES,NPP2,     NBARS=NBARS,INDEX=1,BOTTOM_VALUES=MBOT,FILL_COLOR='BLUE',             LINESTYLE=LINESTYLE,/OVERPLOT,YRANGE=BYRANGE,XRANGE=MXRANGE,XTICKVALUE=MX.TICKV,XTICKNAME=MX.TICKNAME,YTICKVALUE=YTICKV,YTICKNAME=YTICKNAME,YMINOR=YMINOR,BUFFER=BUFFER)
        MBAR3 = BARPLOT(MDATES,NPP2+MPP2,NBARS=NBARS,INDEX=1,BOTTOM_VALUES=NPP2,FILL_COLOR='ORANGE',           LINESTYLE=LINESTYLE,/OVERPLOT,YRANGE=BYRANGE,XRANGE=MXRANGE,XTICKVALUE=MX.TICKV,XTICKNAME=MX.TICKNAME,YTICKVALUE=YTICKV,YTICKNAME=YTICKNAME,YMINOR=YMINOR,BUFFER=BUFFER)
                     
;       ANNUAL PRODUCTIVITY BAR PLOTS        
        SUBS1 = ADATA[WHERE(ADATA.MASK EQ SUBAREA1)] & MPP1 = SUBS1.MPP_CLIM_ANNUAL_TTON/1000000 & NPP1 = SUBS1.NPP_CLIM_ANNUAL_TTON/1000000
        SUBS2 = ADATA[WHERE(ADATA.MASK EQ SUBAREA2)] & MPP2 = SUBS2.MPP_CLIM_ANNUAL_TTON/1000000 & NPP2 = SUBS2.NPP_CLIM_ANNUAL_TTON/1000000
        MAX_PP = MAX([MPP1+NPP1,MPP2+NPP2],/NAN)
        ADATES = DATE_2JD(SUBS1.YEAR)
      
        POSITION = [460,55,740,195]
        P = PLOT(AXRANGE,[0,MAX_PP],YTITLE='PP x 10!U6!N (t yr!U-1!N)',TITLE='Annual',XTICKVALUE=AX.TICKV,FONT_SIZE=11,POSITION=POSITION,XRANGE=AXRANGE,$
          XMINOR=0,YMINOR=2,XSTYLE=1,XTICKNAME=AX.TICKNAME,/NODATA,BUFFER=BUFFER,MARGIN=MARGIN,LAYOUT=LAYOUT,/CURRENT,/DEVICE)
        BYRANGE = P.YRANGE
        YTICKNAME = P.YTICKNAME
        YTICKV  = P.YTICKVALUE
        YMINOR = P.YMINOR
              
        NLBAR = BARPLOT(ADATES,NPP1,     NBARS=NBARS,INDEX=0,BOTTOM_VALUES=BOT, FILL_COLOR='MEDIUM_AQUAMARINE',LINESTYLE=LINESTYLE,/OVERPLOT,YRANGE=BYRANGE,XRANGE=AXRANGE,XTICKVALUE=AX.TICKV,XTICKNAME=AX.TICKNAME,YTICKVALUE=YTICKV,YTICKNAME=YTICKNAME,YMINOR=YMINOR,BUFFER=BUFFER)
        MLBAR = BARPLOT(ADATES,NPP1+MPP2,NBARS=NBARS,INDEX=0,BOTTOM_VALUES=NPP1,FILL_COLOR='YELLOW',           LINESTYLE=LINESTYLE,/OVERPLOT,YRANGE=BYRANGE,XRANGE=AXRANGE,XTICKVALUE=AX.TICKV,XTICKNAME=AX.TICKNAME,YTICKVALUE=YTICKV,YTICKNAME=YTICKNAME,YMINOR=YMINOR,BUFFER=BUFFER)
        NGBAR = BARPLOT(ADATES,NPP2,     NBARS=NBARS,INDEX=1,BOTTOM_VALUES=BOT, FILL_COLOR='BLUE',             LINESTYLE=LINESTYLE,/OVERPLOT,YRANGE=BYRANGE,XRANGE=AXRANGE,XTICKVALUE=AX.TICKV,XTICKNAME=AX.TICKNAME,YTICKVALUE=YTICKV,YTICKNAME=YTICKNAME,YMINOR=YMINOR,BUFFER=BUFFER)
        MGBAR = BARPLOT(ADATES,NPP2+MPP2,NBARS=NBARS,INDEX=1,BOTTOM_VALUES=NPP2,FILL_COLOR='ORANGE',           LINESTYLE=LINESTYLE,/OVERPLOT,YRANGE=BYRANGE,XRANGE=AXRANGE,XTICKVALUE=AX.TICKV,XTICKNAME=AX.TICKNAME,YTICKVALUE=YTICKV,YTICKNAME=YTICKNAME,YMINOR=YMINOR,BUFFER=BUFFER)
  
        IF TARGET EQ 'LME' THEN BEGIN
          X = [0,30,30,0,0] & Y = [0,0,15,15,0]
          
          PY1 = 18
          PY2 = 3
          PX1 = 80 
          PX2 = 495      
          T1 = TEXT(PX1+45,PY1+7.5,'Nano + Picoplankton (0-300 m)',FONT_SIZE=11,/DEVICE,ALIGNMENT=0,VERTICAL_ALIGNMENT=0.5)
          T2 = TEXT(PX1+45,PY2+7.5,'Nano + Picoplankton (>300 m)', FONT_SIZE=11,/DEVICE,ALIGNMENT=0,VERTICAL_ALIGNMENT=0.5)
          P1 = POLYGON(X,Y,POSITION=[PX1,PY1,PX1+40,PY1+15],FILL_COLOR='MEDIUM_AQUAMARINE',/FILL_BACKGROUND,/CURRENT,/DEVICE)
          P2 = POLYGON(X,Y,POSITION=[PX1,PY2,PX1+40,PY2+15],FILL_COLOR='BLUE',             /FILL_BACKGROUND,/CURRENT,/DEVICE)
          
          T3 = TEXT(PX2+45,PY1+7.5,'Microplankton (0-300 m)',FONT_SIZE=11,/DEVICE,ALIGNMENT=0,VERTICAL_ALIGNMENT=0.5)
          T4 = TEXT(PX2+45,PY2+7.5,'Microplankton (>300 m)', FONT_SIZE=11,/DEVICE,ALIGNMENT=0,VERTICAL_ALIGNMENT=0.5)
          P3 = POLYGON(X,Y,POSITION=[PX2,PY1,PX2+40,PY1+15],FILL_COLOR='YELLOW',/FILL_BACKGROUND,/CURRENT,/DEVICE)      
          P4 = POLYGON(X,Y,POSITION=[PX2,PY2,PX2+40,PY2+15],FILL_COLOR='ORANGE',/FILL_BACKGROUND,/CURRENT,/DEVICE)
        ENDIF
        IF TARGET EQ 'FAO' THEN BEGIN
          X = [0,30,30,0,0] & Y = [0,0,15,15,0]
          
          PY = 8
          P1 = 70
          P2 = 495
          TO = TEXT(P1+45,PY+7.5,'Nano + Picoplankton ',FONT_SIZE=12,/DEVICE,ALIGNMENT=0,VERTICAL_ALIGNMENT=0.5)
          PO = POLYGON(X,Y,POSITION=[P1,   PY,P1+30,PY+15],FILL_COLOR='MEDIUM_AQUAMARINE',/FILL_BACKGROUND,/CURRENT,/DEVICE)
  ;        PO = POLYGON(X,Y,POSITION=[P1+20,PY,P1+40,PY+15],FILL_COLOR='BLUE',/FILL_BACKGROUND,/CURRENT,/DEVICE)
          
          TO = TEXT(P2+45,PY+7.5,'Microplankton ',FONT_SIZE=12,/DEVICE,ALIGNMENT=0,VERTICAL_ALIGNMENT=0.5)
          PO = POLYGON(X,Y,POSITION=[P2,   PY,P2+30,PY+15],FILL_COLOR='YELLOW',/FILL_BACKGROUND,/CURRENT,/DEVICE)
  ;        PO = POLYGON(X,Y,POSITION=[P2+20,PY,P2+40,PY+15],FILL_COLOR='ORANGE',/FILL_BACKGROUND,/CURRENT,/DEVICE)  
        ENDIF        
     
        W.SAVE, PNGFILE
        W.CLOSE   
  
      ENDFOR
        
    ENDFOR
STOP    
  ENDIF ; DO_FINAL_COMPOSITES











  ; *******************************************************
  IF DO_CHL_PP_SZ_PLOTS GE 1 THEN BEGIN
    ; *******************************************************
    OVERWRITE = DO_CHL_PP_SZ_PLOTS GE 2

    BUFFER = 0
    TARGETS = ['LME', 'FAO']
    SUBAREAS = ['MASK_SUBAREA-GEQ-PXY_4096_2048-LME_TOTAL'];'MASK_SUBAREA-GEQ-PXY_4096_2048-FAO_TOTAL'
    MAP = 'GEQ'
    SCDIR = 'OC-SEAWIFS-9'
    MCDIR = 'OC-MODIS-4'
    SPDIR = 'PP-SEAWIFS-PAT-9'
    MPDIR = 'PP-MODIS-PAT-4'

    PERIODS = 'M'

    DATES    = LIST([19970101,201510101],[19970101,20150101])
    ADATE    = ['19970101000000','20071231000000']
    BDATE    = ['20080101000000','20151231000000']
    DATASETA = [SCDIR,SPDIR]
    DATASETB = [MCDIR,MPDIR]
    PRODSA  = LIST(['CHLOR_A-OC4', 'MICRO-PAN','NANOPICO-PAN'], ['PPD-VGPM2','MICROPP-MARMAP_PAN_VGPM2','NANOPICOPP-MARMAP_PAN_VGPM2'])
    PRODSB  = LIST(['CHLOR_A-OC3M','MICRO-PAN','NANOPICO-PAN'], ['PPD-VGPM2','MICROPP-MARMAP_PAN_VGPM2','NANOPICOPP-MARMAP_PAN_VGPM2'])

    TPRODS  = ['Chlorophyll ' + UNITS('CHLOR_A',/NO_NAME),'Primary Production - VGPM2 ' + UNITS('PPD',/NO_NAME)]
    CTITLES = ['CHL ' + UNITS('CHLOR_A',/NO_NAME),'PP-VGPM2 '+UNITS('PPD',/NO_NAME)]
    LEGENDA = ['SeaWiFS','SeaWiFS']
    LEGENDB = ['MODIS', 'MODIS']
    MYRANGE = LIST([0,5],[0,3])
    AYRANGE = LIST([0,2],[0,1.2])
    MXYRANGE = LIST([0.1,10],[0.1,10])
    AXYRANGE = LIST([0.1,10],[0.1,10])
    SCALEA  = ['HIGH','LOW']
    SCALEB  = ['HIGH','LOW']
    LOGSA   = [1,1]
    LOGSB   = [1,1]
    LOGXY   = [1,1]

    WINX = 850
    WINY = 1100
    XSPACE = 20. & XPER = XSPACE/WINX
    CTITLE = ' '

    YMINOR=1
    FONTSIZE = 8.5
    SYMSIZE = 0.45
    THICK = 2
    FONT = 0
    YMARGIN = [0.3,0.3]
    XMARGIN = [4,1]
    COLORA = 'ORANGE_RED'
    COLORB = 'DARK_BLUE'
    COLORXY  = !COLOR.(WHERE(TAG_NAMES(!COLOR) EQ COLORA))
    COLORREG = !COLOR.(WHERE(TAG_NAMES(!COLOR) EQ COLORB))
    START_POS = LIST([0.03,0.82,0.95,0.94],[0.03,0.33,0.95,0.45])

    FOR TAR=0, N_ELEMENTS(TARGETS)-1 DO BEGIN
      ATARGET = TARGETS(TAR)
      TARGET  = STRMID(ATARGET,0,3)
      FOR STH=0, N_ELEMENTS(SUBAREAS)-1 DO BEGIN
        SUBAREAFILE = !S.SUBAREAS + SUBAREAS(STH) + '.SAVE'
        SUBMASK = STRUCT_SD_READ(SUBAREAFILE,STRUCT=SUB_STRUCT)

        IF TARGET EQ 'FAO' THEN BEGIN
          TARS = READALL(!S.DATA+'FAO_NAMES.csv')
          EXCLUDE_FAOS = ['0','1','2','18','37','48','58','88']
          OK = WHERE_MATCH(SUB_STRUCT.SUBAREA_CODE,EXCLUDE_FAOS,COUNT,COMPLEMENT=COMPLEMENT)
          CODES = SUB_STRUCT.SUBAREA_CODE(COMPLEMENT)
          NAMES = SUB_STRUCT.SUBAREA_NAME(COMPLEMENT)
        ENDIF
        IF TARGET EQ 'LME' THEN BEGIN
          TARS = READALL(!S.DATA + 'lme_names.csv')
          EXCLUDE_LMES = ['255','0','251','64','63','62','61','58','57','56','55','54']
          OK = WHERE_MATCH(SUB_STRUCT.SUBAREA_CODE,EXCLUDE_LMES,COUNT,COMPLEMENT=COMPLEMENT)
          CODES  = SUB_STRUCT.SUBAREA_CODE(COMPLEMENT)
          NAMES  = SUB_STRUCT.SUBAREA_NAME(COMPLEMENT)
        ENDIF
        MSTATS  = REPLICATE(STRUCT_2MISSINGS(CREATE_STRUCT('SUBAREA_NAME','','SUBAREA_CODE','','PRODX','','PRODY','',$
          'N', 0L,'SLOPE', 0.0,'INTERCEPT', 0.0,'RSQ', 0.0)),N_ELEMENTS(CODES)*2)

        CC = -1
        FOR C=0, N_ELEMENTS(CODES)-1 DO BEGIN
          NAME = NAMES(C)
          CODE = CODES(C)
          OK = WHERE(TARS.SUBAREA_NAME EQ NAME)
          TITLE = TARS[OK].NAME
          TSAS = [] & ANNAS = []
          TSBS = [] & ANNBS = []
          FOR D=0, N_ELEMENTS(DATASETA)-1 DO TSAS  = [TSAS, FILE_SEARCH(!S.DATASETS + DATASETA(D) + SL + MAP + SL + 'TS_SUBAREAS-STATS' + SL + 'A_ANNUAL_M_MANNUAL_MONTH*' + SUBAREAS(STH) + '*.SAVE')]
          FOR D=0, N_ELEMENTS(DATASETB)-1 DO TSBS  = [TSBS, FILE_SEARCH(!S.DATASETS + DATASETB(D) + SL + MAP + SL + 'TS_SUBAREAS-STATS' + SL + 'A_ANNUAL_M_MANNUAL_MONTH*' + SUBAREAS(STH) + '*.SAVE')]
          FOR D=0, N_ELEMENTS(DATASETA)-1 DO ANNAS = [ANNAS,FILE_SEARCH(!S.DATASETS + DATASETA(D) + SL + MAP + SL + 'STATS' + SL + PRODSA(D) + SL + 'ANNUAL*-MEAN.SAVE')]
          FOR D=0, N_ELEMENTS(DATASETB)-1 DO ANNBS = [ANNBS,FILE_SEARCH(!S.DATASETS + DATASETB(D) + SL + MAP + SL + 'STATS' + SL + PRODSB(D) + SL + 'ANNUAL*-MEAN.SAVE')]

          PNGFILE = FIX_PATH(DIR_SZ_CLASS + TARGET +'_' + NUM2STR(CODE) + '-' + NAME+'-CHL_PP_SZ_CLASSES-SEAWIFS_MODIS.PNG')
          UPDATE = UPDATE_CHECK(INFILES=[TSAS,TSBS,ANNAS,ANNBS],OUTFILE=PNGFILE)
          IF UPDATE EQ 0 AND NOT KEYWORD_SET(OVERWRITE) THEN CONTINUE
          PRINT, 'Working on: ' + PNGFILE
          MASK = STRUCT_SD_REMAP(FILES=SUBAREAFILE,MAP_OUT=TARGET+'_'+NAME,LME_CODE_OUT=CODE,/RETURN_STRUCT)

          IF NOT KEYWORD_SET(DO_STATS_ONLY) THEN BEGIN
            W = WINDOW(DIMENSIONS=[WINX,WINY],BUFFER=BUFFER)
            TITLE = TARS[OK].NAME
            TXT = TEXT(0.5,0.97,TITLE,ALIGNMENT=0.5,FONT_SIZE=14)
          ENDIF

          FOR DTH=0, N_ELEMENTS(DATASETA)-1 DO BEGIN
            PRODA  = PRODSA(DTH) & LOGA = LOGSA(DTH) & SSA = SCALEA(DTH) & SENSORA = VALID_SENSORS(DATASETA(DTH))
            PRODB  = PRODSB(DTH) & LOGB = LOGSB(DTH) & SSB = SCALEA(DTH) & SENSORB = VALID_SENSORS(DATASETB(DTH))
            LEGA   = LEGENDA(DTH)
            LEGB   = LEGENDB(DTH)
            TPROD  = TPRODS(DTH)
            CTITLE = CTITLES(DTH)
            XSCALE = SD_SCALES([1,250],PROD=VALIDS('PRODS',PRODA),SPECIAL_SCALE=SSA,/BIN2DATA) & YSCALE = SD_SCALES([1,250],PROD=VALIDS('PRODS',PRODB),SPECIAL_SCALE=SSB,/BIN2DATA)
            IF KEYWORD_SET(LOGA) THEN XRANGE = NICE_RANGE(ALOG10(XSCALE))ELSE XRANGE = NICE_RANGE(XSCALE)
            IF KEYWORD_SET(LOGB) THEN YRANGE = NICE_RANGE(ALOG10(YSCALE))ELSE YRANGE = NICE_RANGE(YSCALE)
            BINX=(XRANGE[1]-XRANGE[0])/100. & BINY=(YRANGE[1]-YRANGE[0])/100.
            XTITLE = UNITS(TPROD) + ' - ' + VALIDS('ALGS',PRODA) + ' Algorithm (' + SENSORA + ')'

            TSA = FILE_SEARCH(!S.DATASETS + DATASETA(DTH) + SL + MAP + SL + 'TS_SUBAREAS-STATS' + SL + 'A_ANNUAL_M_MANNUAL_MONTH*' + SUBAREAS(STH) + '*.SAVE') & IF TSA[0] EQ '' THEN CONTINUE
            TSB = FILE_SEARCH(!S.DATASETS + DATASETB(DTH) + SL + MAP + SL + 'TS_SUBAREAS-STATS' + SL + 'A_ANNUAL_M_MANNUAL_MONTH*' + SUBAREAS(STH) + '*.SAVE') & IF TSB[0] EQ '' THEN CONTINUE

            X     = DATE_2JD(DATES(DTH))
            AX    = DATE_AXIS(X,/MONTH, /YY_YEAR,STEP_SIZE=4)
            AYR   = DATE_AXIS(X,/YEAR)
            XTICKNAMES = REPLICATE(' ',N_ELEMENTS(AX.TICKNAME))

            DATA  = IDL_RESTORE(TSA)
            DATB  = IDL_RESTORE(TSB)
            TAGSA = TAG_NAMES(DATA)
            TAGSB = TAG_NAMES(DATB)
            OKAT = WHERE(TAGSA EQ 'MEAN_' + REPLACE(PRODA[0],'-','_'))
            OKBT = WHERE(TAGSB EQ 'MEAN_' + REPLACE(PRODB[0],'-','_'))
            OKAM = WHERE(TAGSA EQ 'MEAN_' + REPLACE(PRODA[1],'-','_'))
            OKBM = WHERE(TAGSB EQ 'MEAN_' + REPLACE(PRODB[1],'-','_'))
            OKAN = WHERE(TAGSA EQ 'MEAN_' + REPLACE(PRODA(2),'-','_'))
            OKBN = WHERE(TAGSB EQ 'MEAN_' + REPLACE(PRODB(2),'-','_'))

            MA = DATA[WHERE(DATA.PERIOD_CODE EQ 'M' AND DATA.SUBAREA_CODE EQ CODE AND PERIOD_2DATE(DATA.PERIOD) GE MIN(ADATE) AND PERIOD_2DATE(DATA.PERIOD) LE MAX(ADATE))]
            MB = DATB[WHERE(DATB.PERIOD_CODE EQ 'M' AND DATB.SUBAREA_CODE EQ CODE AND PERIOD_2DATE(DATB.PERIOD) GE MIN(BDATE) AND PERIOD_2DATE(DATB.PERIOD) LE MAX(BDATE))]
            MATPROD = MA.(OKAM) + MA.(OKAN) & MBTPROD = MB.(OKBM) + MB.(OKBN)
            MAMPROD = MA.(OKAM) & MBMPROD = MB.(OKBM)
            MANPROD = MA.(OKAN) & MBNPROD = MB.(OKBN)

            CDATA = REPLICATE(STRUCT_2MISSINGS(CREATE_STRUCT('PERIOD','','PERIOD_CODE','','SUBAREA_CODE',0L,'SUBAREA_NAME','','DATA_AT',0.0,'DATA_BT',0.0,'DATA_AM',0.0,'DATA_BM',0.0,'DATA_AN',0.0,'DATA_BN',0.0)),N_ELEMENTS(MA))
            CDATA.PERIOD = MA.PERIOD
            CDATA.PERIOD_CODE = MA.PERIOD_CODE
            CDATA.SUBAREA_CODE = MA.SUBAREA_CODE
            CDATA.SUBAREA_NAME = MA.SUBAREA_NAME
            CDATA.DATA_AT = MA.(OKAT)
            CDATA.DATA_AM = MA.(OKAM)
            CDATA.DATA_AN = MA.(OKAN)
            OK = WHERE_MATCH(CDATA.PERIOD,MB.PERIOD,COUNT,VALID=VALID,COMPLEMENT=COMPLEMENT)
            CDATA[OK].DATA_BT = MB(VALID).(OKBT)
            CDATA[OK].DATA_BM = MB(VALID).(OKBM)
            CDATA[OK].DATA_BN = MB(VALID).(OKBN)

            CDATA = CDATA[WHERE(CDATA.DATA_AT NE MISSINGS(0.0) AND CDATA.DATA_BT NE MISSINGS(0.0))]

            YRANGE = NICE_RANGE([0,MAX([MATPROD,MBTPROD],/NAN)+0.75])
            POSITION1 = START_POS(DTH)
            TXT = TEXT(POSITION1[0]+0.01,POSITION1(3)+0.005,TPROD,FONT_SIZE=12,FONT_STYLE='BOLD')
            PM = PLOT(AX.JD,YRANGE,YTITLE=UNITS(TPROD,/NO_NAME),FONT_SIZE=FONTSIZE,YMINOR=YMINOR,XMAJOR=AX.TICKS,XMINOR=0,XTICKNAME=AX.TICKNAME,XTICKVALUES=AX.TICKV,POSITION=POSITION1,/NODATA,/CURRENT)
            XTICKV = PM.XTICKVALUES & OK = WHERE(JD_2MONTH(XTICKV) EQ '01',COUNT)
            FOR G=1,COUNT-1 DO GR = PLOT([XTICKV(OK(G)),XTICKV(OK(G))],YRANGE,COLOR='GREY',/OVERPLOT,XRANGE=AX.JD,YRANGE=YRANGE)
            GR = PLOT(DATE_2JD([MAX(ADATE),MAX(ADATE)]),YRANGE,COLOR='BLACK',THICK=3,/OVERPLOT,XRANGE=AX.JD,YRANGE=YRANGE)
            TA = TEXT(DATE_2JD(MAX(ADATE)),MAX(YRANGE),LEGA+'  ',ALIGNMENT=1,VERTICAL_ALIGNMENT=0,FONT_COLOR=COLORB,FONT_SIZE=FONTSIZE+2,FONT_STYLE='BOLD',/DATA,TARGET=PM,CLIP=0)
            TB = TEXT(DATE_2JD(MAX(ADATE)),MAX(YRANGE),'  '+LEGB,ALIGNMENT=0,VERTICAL_ALIGNMENT=0,FONT_COLOR=COLORB,FONT_SIZE=FONTSIZE+2,FONT_STYLE='BOLD',/DATA,TARGET=PM,CLIP=0)

            BOT = REPLICATE(0, N_ELEMENTS([MANPROD,MBNPROD]))
            YY = [MANPROD,MBNPROD,BOT]
            XX = [PERIOD_2JD(MA.PERIOD),PERIOD_2JD(MB.PERIOD),REVERSE(PERIOD_2JD(MB.PERIOD)),REVERSE(PERIOD_2JD(MA.PERIOD))]
            OK = WHERE(YY NE MISSINGS(YY),COMPLEMENT=COMPLEMENT)
            POLY = POLYGON(XX[OK],YY[OK],FILL_COLOR=COLORA,/FILL_BACKGROUND,TARGET=PM,/DATA,LINESTYLE=6)

            BOT = REPLICATE(0, N_ELEMENTS([MAMPROD,MBMPROD]))
            YY = [MAMPROD+MANPROD,MBMPROD+MBNPROD,REVERSE([MANPROD,MBNPROD])]
            XX = [PERIOD_2JD(MA.PERIOD),PERIOD_2JD(MB.PERIOD),REVERSE(PERIOD_2JD(MB.PERIOD)),REVERSE(PERIOD_2JD(MA.PERIOD))]
            OK = WHERE(YY NE MISSINGS(YY))
            POLY = POLYGON(XX[OK],YY[OK],FILL_COLOR=COLORB,/FILL_BACKGROUND,TARGET=PM,/DATA,LINESTYLE=6)

            P1 = PLOT(PERIOD_2JD(MA.PERIOD),MATPROD,XRANGE=AX.JD,YRANGE=YRANGE,/OVERPLOT,/CURRENT,COLOR=COLORB,SYMBOL='CIRCLE',SYM_SIZE=0.65,/SYM_FILLED)
            P2 = PLOT(PERIOD_2JD(MB.PERIOD),MBTPROD,XRANGE=AX.JD,YRANGE=YRANGE,/OVERPLOT,/CURRENT,COLOR=COLORB,SYMBOL='CIRCLE',SYM_SIZE=0.65,/SYM_FILLED)
            TA = TEXT(POSITION1[0]+.02,POSITION1(3)-0.02,'Microplankton',    FONT_COLOR=COLORB,FONT_SIZE=FONTSIZE+4,FONT_STYLE='BOLD')
            TB = TEXT(POSITION1[0]+.02,POSITION1(3)-0.032,'Nano+picoplankton',FONT_COLOR=COLORA,FONT_SIZE=FONTSIZE+4,FONT_STYLE='BOLD')

            PAL='PAL_SW3'
            POSITIONS = LIST([0.06,POSITION1[1]-.19,0.24,POSITION1[1]-.01],$
              [0.39,POSITION1[1]-.19,0.57,POSITION1[1]-.01],$
              [0.72,POSITION1[1]-.19,0.90,POSITION1[1]-.01])
            XBAR = 15
            YBAR = 150
            ANNAT = FILE_SEARCH(!S.DATASETS + DATASETA(DTH) + SL + MAP + SL + 'STATS' + SL + PRODA[0] + SL + 'ANNUAL*-MEAN.SAVE')
            ANNAM = FILE_SEARCH(!S.DATASETS + DATASETA(DTH) + SL + MAP + SL + 'STATS' + SL + PRODA[1] + SL + 'ANNUAL*-MEAN.SAVE')
            ANNAN = FILE_SEARCH(!S.DATASETS + DATASETA(DTH) + SL + MAP + SL + 'STATS' + SL + PRODA(2) + SL + 'ANNUAL*-MEAN.SAVE')

            ANNBT = FILE_SEARCH(!S.DATASETS + DATASETB(DTH) + SL + MAP + SL + 'STATS' + SL + PRODB[0] + SL + 'ANNUAL*-MEAN.SAVE')
            ANNBM = FILE_SEARCH(!S.DATASETS + DATASETB(DTH) + SL + MAP + SL + 'STATS' + SL + PRODB[1] + SL + 'ANNUAL*-MEAN.SAVE')
            ANNBN = FILE_SEARCH(!S.DATASETS + DATASETB(DTH) + SL + MAP + SL + 'STATS' + SL + PRODB(2) + SL + 'ANNUAL*-MEAN.SAVE')

            IF TARGET EQ 'LME' THEN BEGIN
              PAL_36,R,G,B
              M = MAPS_SIZE('LME_'+NAME,/old)
              LANDMASK_FILE = !S.IMAGES + 'MASK_LAND-'+M.MAP+'-PXY_'+STRTRIM(M.PX,2)+'_'+STRTRIM(M.PY,2)+'.PNG'
              OUTLINE_FILES = DIR_OUTLINES + 'MASK_OUTLINE-LME_TOTAL-'+M.MAP+'-PXY_'+STRTRIM(M.PX,2)+'_'+STRTRIM(M.PY,2)+'.PNG'
            ENDIF

            IF TARGET EQ 'FAO' THEN BEGIN
              PAL_36,R,G,B
              M = MAPS_SIZE('FAO_'+NAME,/old)
              LANDMASK_FILE = !S.IMAGES + 'MASK_LAND-'+M.MAP+'-PXY_'+STRTRIM(M.PX,2)+'_'+STRTRIM(M.PY,2)+'.PNG'
              OUTLINE_FILES = DIR_OUTLINES + 'MASK_OUTLINE-FAO_TOTAL-'+M.MAP+'-PXY_'+STRTRIM(M.PX,2)+'_'+STRTRIM(M.PY,2)+'.PNG'
            ENDIF
            OUTLINE_COLORS = 0
            OUTLINE_THICK = 2
            LAND_COLOR = 251
            ATDAT = STRUCT_SD_READ(ANNAT, MAP_OUT=TARGET+'_'+NAME,LME_CODE_OUT=CODE,STRUCT=ATSTRUCT)
            AMDAT = STRUCT_SD_READ(ANNAM, MAP_OUT=TARGET+'_'+NAME,LME_CODE_OUT=CODE,STRUCT=AMSTRUCT)
            ANDAT = STRUCT_SD_READ(ANNAN, MAP_OUT=TARGET+'_'+NAME,LME_CODE_OUT=CODE,STRUCT=ANSTRUCT)

            POSITION = POSITIONS[0] & PX = WINX*(POSITION(2)+0.015) & PY = WINY*(POSITION(3)-0.025)
            ATPNG = STRUCT_SD_2IMAGE_NG(ATSTRUCT,IMG_POSITION=POSITION,USE_PROD=PRODA[0],SPECIAL_SCALE=SSA,/ADD_OUTLINE,/ADD_LAND,/ADD_COAST,LAND_COLOR=LAND_COLOR,OUTLINE_FILE=OUTLINE_FILES,OUTLINE_COLOR=OUTLINE_COLORS,OUTLINE_THICK=OUTLINE_THICK,/CURRENT,MARGIN=MARGIN,BUFFER=BUFFER)
            TX = TEXT(POSITION[0]+(POSITION(2)-POSITION[0])/2,POSITION[1]+0.02,LEGA+' Total ',FONT_SIZE=FONTSIZE+1,VERTICAL_ALIGNMENT=1.0,ALIGNMENT=0.5)
            ABAR = COLOR_BAR_SCALE_NG(PROD=PRODA[0],SPECIAL_SCALE=SSA,PX=PX,PY=PY,CHARSIZE=FONTSIZE+1,XDIM=XBAR,YDIM=YBAR,PAL=PAL,NO_NAME=0,NO_UNIT=0,VERTICAL=1,RIGHT=1,FONT='HELVETICA',TITLE=CTITLE)

            POSITION = POSITIONS[1] & PX = WINX*(POSITION(2)+0.015) & PY = WINY*(POSITION(3)-0.025)
            AMPNG = STRUCT_SD_2IMAGE_NG(AMSTRUCT,IMG_POSITION=POSITION,USE_PROD=PRODA[0],SPECIAL_SCALE=SSA,/ADD_OUTLINE,/ADD_LAND,/ADD_COAST,LAND_COLOR=LAND_COLOR,OUTLINE_FILE=OUTLINE_FILES,OUTLINE_COLOR=OUTLINE_COLORS,OUTLINE_THICK=OUTLINE_THICK,/CURRENT,MARGIN=MARGIN,BUFFER=BUFFER)
            TY = TEXT(POSITION[0]+(POSITION(2)-POSITION[0])/2,POSITION[1]+0.02,LEGA+' Microplankton',FONT_SIZE=FONTSIZE+1,VERTICAL_ALIGNMENT=1.0,ALIGNMENT=0.5)
            ABAR = COLOR_BAR_SCALE_NG(PROD=PRODA[0],SPECIAL_SCALE=SSA,PX=PX,PY=PY,CHARSIZE=FONTSIZE+1,XDIM=XBAR,YDIM=YBAR,PAL=PAL,NO_NAME=0,NO_UNIT=0,VERTICAL=1,RIGHT=1,FONT='HELVETICA',TITLE=CTITLE)

            POSITION = POSITIONS(2) & PX = WINX*(POSITION(2)+0.015) & PY = WINY*(POSITION(3)-0.025)
            ANPNG = STRUCT_SD_2IMAGE_NG(ANSTRUCT,IMG_POSITION=POSITION,USE_PROD=PRODA[0],SPECIAL_SCALE=SSA,/ADD_OUTLINE,/ADD_LAND,/ADD_COAST,LAND_COLOR=LAND_COLOR,OUTLINE_FILE=OUTLINE_FILES,OUTLINE_COLOR=OUTLINE_COLORS,OUTLINE_THICK=OUTLINE_THICK,/CURRENT,MARGIN=MARGIN,BUFFER=BUFFER)
            TA = TEXT(POSITION[0]+(POSITION(2)-POSITION[0])/2,POSITION[1]+0.02,LEGA+' Nano+picoplankton',FONT_SIZE=FONTSIZE+1,VERTICAL_ALIGNMENT=1.0,ALIGNMENT=0.5)
            ABAR = COLOR_BAR_SCALE_NG(PROD=PRODA[0],SPECIAL_SCALE=SSA,PX=PX,PY=PY,CHARSIZE=FONTSIZE+1,XDIM=XBAR,YDIM=YBAR,PAL=PAL,NO_NAME=0,NO_UNIT=0,VERTICAL=1,RIGHT=1,FONT='HELVETICA',TITLE=CTITLE)

            GONE, ATDAT
            GONE, AMDAT
            GONE, ANDAT

            POSITIONS = LIST([0.06,POSITION1[1]-.34,0.24,POSITION1[1]-.16],$
              [0.39,POSITION1[1]-.34,0.57,POSITION1[1]-.16],$
              [0.72,POSITION1[1]-.34,0.90,POSITION1[1]-.16])

            BTDAT = STRUCT_SD_READ(ANNBT, MAP_OUT=TARGET+'_'+NAME,LME_CODE_OUT=CODE,STRUCT=BTSTRUCT)
            BMDAT = STRUCT_SD_READ(ANNBM, MAP_OUT=TARGET+'_'+NAME,LME_CODE_OUT=CODE,STRUCT=BMSTRUCT)
            BNDAT = STRUCT_SD_READ(ANNBN, MAP_OUT=TARGET+'_'+NAME,LME_CODE_OUT=CODE,STRUCT=BNSTRUCT)

            POSITION = POSITIONS[0] & PX = WINX*(POSITION(2)+0.015) & PY = WINY*(POSITION(3)-0.025)
            BTPNG = STRUCT_SD_2IMAGE_NG(BTSTRUCT,IMG_POSITION=POSITION,USE_PROD=PRODB[0],SPECIAL_SCALE=SSB,/ADD_OUTLINE,/ADD_LAND,/ADD_COAST,LAND_COLOR=LAND_COLOR,OUTLINE_FILE=OUTLINE_FILES,OUTLINE_COLOR=OUTLINE_COLORS,OUTLINE_THICK=OUTLINE_THICK,/CURRENT,MARGIN=MARGIN,BUFFER=BUFFER)
            TX = TEXT(POSITION[0]+(POSITION(2)-POSITION[0])/2,POSITION[1]+0.02,LEGB+' Total ',FONT_SIZE=FONTSIZE+1,VERTICAL_ALIGNMENT=1.0,ALIGNMENT=0.5)
            ABAR = COLOR_BAR_SCALE_NG(PROD=PRODB[0],SPECIAL_SCALE=SSB,PX=PX,PY=PY,CHARSIZE=FONTSIZE+1,XDIM=XBAR,YDIM=YBAR,PAL=PAL,NO_NAME=0,NO_UNIT=0,VERTICAL=1,RIGHT=1,FONT='HELVETICA',TITLE=CTITLE)

            POSITION = POSITIONS[1] & PX = WINX*(POSITION(2)+0.015) & PY = WINY*(POSITION(3)-0.025)
            BMPNG = STRUCT_SD_2IMAGE_NG(BMSTRUCT,IMG_POSITION=POSITION,USE_PROD=PRODB[0],SPECIAL_SCALE=SSB,/ADD_OUTLINE,/ADD_LAND,/ADD_COAST,LAND_COLOR=LAND_COLOR,OUTLINE_FILE=OUTLINE_FILES,OUTLINE_COLOR=OUTLINE_COLORS,OUTLINE_THICK=OUTLINE_THICK,/CURRENT,MARGIN=MARGIN,BUFFER=BUFFER)
            TY = TEXT(POSITION[0]+(POSITION(2)-POSITION[0])/2,POSITION[1]+0.02,LEGB+' Microplankton',FONT_SIZE=FONTSIZE+1,VERTICAL_ALIGNMENT=1.0,ALIGNMENT=0.5)
            ABAR = COLOR_BAR_SCALE_NG(PROD=PRODB[0],SPECIAL_SCALE=SSB,PX=PX,PY=PY,CHARSIZE=FONTSIZE+1,XDIM=XBAR,YDIM=YBAR,PAL=PAL,NO_NAME=0,NO_UNIT=0,VERTICAL=1,RIGHT=1,FONT='HELVETICA',TITLE=CTITLE)

            POSITION = POSITIONS(2) & PX = WINX*(POSITION(2)+0.015) & PY = WINY*(POSITION(3)-0.025)
            BNPNG = STRUCT_SD_2IMAGE_NG(BNSTRUCT,IMG_POSITION=POSITION,USE_PROD=PRODB[0],SPECIAL_SCALE=SSB,/ADD_OUTLINE,/ADD_LAND,/ADD_COAST,LAND_COLOR=LAND_COLOR,OUTLINE_FILE=OUTLINE_FILES,OUTLINE_COLOR=OUTLINE_COLORS,OUTLINE_THICK=OUTLINE_THICK,/CURRENT,MARGIN=MARGIN,BUFFER=BUFFER)
            TA = TEXT(POSITION[0]+(POSITION(2)-POSITION[0])/2,POSITION[1]+0.02,LEGB+' Nano+picoplankton',FONT_SIZE=FONTSIZE+1,VERTICAL_ALIGNMENT=1.0,ALIGNMENT=0.5)
            ABAR = COLOR_BAR_SCALE_NG(PROD=PRODB[0],SPECIAL_SCALE=SSB,PX=PX,PY=PY,CHARSIZE=FONTSIZE+1,XDIM=XBAR,YDIM=YBAR,PAL=PAL,NO_NAME=0,NO_UNIT=0,VERTICAL=1,RIGHT=1,FONT='HELVETICA',TITLE=CTITLE)

            GONE, BTDAT
            GONE, BMDAT
            GONE, BNDAT

          ENDFOR ; DATASETS
          PRINT, 'Writing: ' + PNGFILE
          W.SAVE,PNGFILE,RESOLUTION=600
          W.CLOSE
        ENDFOR ; CODES
      ENDFOR ; TARGETS
    ENDFOR ; SUBAREAS
    ; STOP

  ENDIF ; DO_CHL_PP_SZ_PLOTS

  ; *******************************************************
  IF DO_COMPARE_PLOTS GE 1 THEN BEGIN
    ; *******************************************************
    OVERWRITE = DO_COMPARE_PLOTS GE 2

    BUFFER = 1
    DO_STATS_ONLY = 1
    TARGETS = ['LME'] ; 'FAO'
    SUBAREAS = ['MASK_SUBAREA-GEQ-PXY_4096_2048-LME_TOTAL'];'MASK_SUBAREA-GEQ-PXY_4096_2048-FAO_TOTAL'
    MAP = 'GEQ'
    SCDIR = 'OC-SEAWIFS-9'
    MCDIR = 'OC-MODIS-4'
    SPDIR = 'PP-SEAWIFS-PAT-9'
    MPDIR = 'PP-MODIS-PAT-4'

    PERIODS = ['M','A']
    TITLE_PERIODS = ['Monthly', 'Annual']

    DATES    = LIST([19970101,201310101],[19970101,20130101])
    DATASETA = [MCDIR,MPDIR]
    DATASETB = [SCDIR,SPDIR]
    PRODSA  = ['CHLOR_A-OC3M','PPD-VGPM2']
    PRODSB  = ['CHLOR_A-OC4', 'PPD-VGPM2']
    TPRODS  = ['Chlorophyll','Primary Production']
    LEGENDA = ['MODIS OC3M', 'MODIS PP VGPM2']
    LEGENDB = ['SeaWiFS OC4','SeaWiFS PP VGPM2']
    MYRANGE = LIST([0,5],[0,3])
    AYRANGE = LIST([0,2],[0,1.2])
    MXYRANGE = LIST([0.1,10],[0.1,10])
    AXYRANGE = LIST([0.1,10],[0.1,10])
    SCALEA  = ['HIGH','LOW']
    SCALEB  = ['HIGH','LOW']
    LOGSA   = [1,1]
    LOGSB   = [1,1]
    LOGXY   = [1,1]

    WINX = 850
    WINY = 1100
    XSPACE = 20. & XPER = XSPACE/WINX
    CTITLE = ' '

    YMINOR=1
    FONTSIZE = 8.5
    SYMSIZE = 0.45
    THICK = 2
    FONT = 0
    YMARGIN = [0.3,0.3]
    XMARGIN = [4,1]
    COLORA = 'ORANGE_RED'
    COLORB = 'DARK_BLUE'
    COLORXY  = !COLOR.(WHERE(TAG_NAMES(!COLOR) EQ COLORA))
    COLORREG = !COLOR.(WHERE(TAG_NAMES(!COLOR) EQ COLORB))
    START_POS = LIST([0.03,0.82,0.68,0.94],[0.03,0.33,0.68,0.45])

    FOR TAR=0, N_ELEMENTS(TARGETS)-1 DO BEGIN
      ATARGET = TARGETS(TAR)
      TARGET  = STRMID(ATARGET,0,3)
      FOR STH=0, N_ELEMENTS(SUBAREAS)-1 DO BEGIN
        SUBAREAFILE = !S.SUBAREAS + SUBAREAS(STH) + '.SAVE'
        SUBMASK = STRUCT_SD_READ(SUBAREAFILE,STRUCT=SUB_STRUCT)

        IF TARGET EQ 'FAO' THEN BEGIN
          TARS = READALL(!S.DATA+'FAO_NAMES.csv')
          EXCLUDE_FAOS = ['0','1','2','18','37','48','58','88']
          OK = WHERE_MATCH(SUB_STRUCT.SUBAREA_CODE,EXCLUDE_FAOS,COUNT,COMPLEMENT=COMPLEMENT)
          CODES = SUB_STRUCT.SUBAREA_CODE(COMPLEMENT)
          NAMES = SUB_STRUCT.SUBAREA_NAME(COMPLEMENT)
        ENDIF
        IF TARGET EQ 'LME' THEN BEGIN
          TARS = READALL(!S.DATA + 'lme_names.csv')
          EXCLUDE_LMES = ['255','0','251','64','63','62','61','58','57','56','55','54']
          OK = WHERE_MATCH(SUB_STRUCT.SUBAREA_CODE,EXCLUDE_LMES,COUNT,COMPLEMENT=COMPLEMENT)
          CODES  = SUB_STRUCT.SUBAREA_CODE(COMPLEMENT)
          NAMES  = SUB_STRUCT.SUBAREA_NAME(COMPLEMENT)
        ENDIF
        MSTATS  = REPLICATE(STRUCT_2MISSINGS(CREATE_STRUCT('SUBAREA_NAME','','SUBAREA_CODE','','PRODX','','PRODY','',$
          'N', 0L,'SLOPE', 0.0,'INTERCEPT', 0.0,'RSQ', 0.0)),N_ELEMENTS(CODES)*2)

        CC = -1
        FOR C=0, N_ELEMENTS(CODES)-1 DO BEGIN
          NAME = NAMES(C)
          CODE = CODES(C)
          OK = WHERE(TARS.SUBAREA_NAME EQ NAME)
          TITLE = TARS[OK].NAME
          TSAS = [] & ANNAS = []
          TSBS = [] & ANNBS = []
          FOR D=0, N_ELEMENTS(DATASETA)-1 DO TSAS  = [TSAS, FILE_SEARCH(!S.DATASETS + DATASETA(D) + SL + MAP + SL + 'TS_SUBAREAS-STATS' + SL + 'A_ANNUAL_M_MANNUAL_MONTH*' + SUBAREAS(STH) + '*.SAVE')]
          FOR D=0, N_ELEMENTS(DATASETB)-1 DO TSBS  = [TSBS, FILE_SEARCH(!S.DATASETS + DATASETB(D) + SL + MAP + SL + 'TS_SUBAREAS-STATS' + SL + 'A_ANNUAL_M_MANNUAL_MONTH*' + SUBAREAS(STH) + '*.SAVE')]
          FOR D=0, N_ELEMENTS(DATASETA)-1 DO ANNAS = [ANNAS,FILE_SEARCH(!S.DATASETS + DATASETA(D) + SL + MAP + SL + 'STATS' + SL + PRODSA(D) + SL + 'ANNUAL*-MEAN.SAVE')]
          FOR D=0, N_ELEMENTS(DATASETB)-1 DO ANNBS = [ANNBS,FILE_SEARCH(!S.DATASETS + DATASETB(D) + SL + MAP + SL + 'STATS' + SL + PRODSB(D) + SL + 'ANNUAL*-MEAN.SAVE')]

          PNGFILE = FIX_PATH(DIR_COMPARE + TARGET +'_' + NUM2STR(CODE) + '-' + NAME+'-SEAWIFS_MODIS_COMPARE.PNG')
          UPDATE = UPDATE_CHECK(INFILES=[TSAS,TSBS,ANNAS,ANNBS],OUTFILE=PNGFILE)
          IF UPDATE EQ 0 AND NOT KEYWORD_SET(OVERWRITE) THEN CONTINUE
          PRINT, 'Working on: ' + PNGFILE
          MASK = STRUCT_SD_REMAP(FILES=SUBAREAFILE,MAP_OUT=TARGET+'_'+NAME,LME_CODE_OUT=CODE,/RETURN_STRUCT)

          IF NOT KEYWORD_SET(DO_STATS_ONLY) THEN BEGIN
            W = WINDOW(DIMENSIONS=[WINX,WINY],BUFFER=BUFFER)
            TITLE = TARS[OK].NAME
            TXT = TEXT(0.5,0.97,TITLE,ALIGNMENT=0.5,FONT_SIZE=14)
          ENDIF

          FOR DTH=0, N_ELEMENTS(DATASETA)-1 DO BEGIN
            PRODA = PRODSA(DTH) & LOGA = LOGSA(DTH) & SSA = SCALEA(DTH) & SENSORA = VALID_SENSORS(DATASETA(DTH))
            PRODB = PRODSB(DTH) & LOGB = LOGSB(DTH) & SSB = SCALEA(DTH) & SENSORB = VALID_SENSORS(DATASETB(DTH))
            LEGA  = LEGENDA(DTH)
            LEGB  = LEGENDB(DTH)
            TPROD = TPRODS(DTH)
            XSCALE = SD_SCALES([1,250],PROD=VALIDS('PRODS',PRODA),SPECIAL_SCALE=SSA,/BIN2DATA) & YSCALE = SD_SCALES([1,250],PROD=VALIDS('PRODS',PRODB),SPECIAL_SCALE=SSB,/BIN2DATA)
            IF KEYWORD_SET(LOGA) THEN XRANGE = NICE_RANGE(ALOG10(XSCALE))ELSE XRANGE = NICE_RANGE(XSCALE)
            IF KEYWORD_SET(LOGB) THEN YRANGE = NICE_RANGE(ALOG10(YSCALE))ELSE YRANGE = NICE_RANGE(YSCALE)
            BINX=(XRANGE[1]-XRANGE[0])/100. & BINY=(YRANGE[1]-YRANGE[0])/100.
            XTITLE = UNITS(TPROD) + ' - ' + VALIDS('ALGS',PRODA) + ' Algorithm (' + SENSORA + ')'
            YTITLE = UNITS(TPROD) + ' - ' + VALIDS('ALGS',PRODB) + ' Algorithm (' + SENSORB + ')'

            TSA = FILE_SEARCH(!S.DATASETS + DATASETA(DTH) + SL + MAP + SL + 'TS_SUBAREAS-STATS' + SL + 'A_ANNUAL_M_MANNUAL_MONTH*' + SUBAREAS(STH) + '*.SAVE') & IF TSA[0] EQ '' THEN CONTINUE
            TSB = FILE_SEARCH(!S.DATASETS + DATASETB(DTH) + SL + MAP + SL + 'TS_SUBAREAS-STATS' + SL + 'A_ANNUAL_M_MANNUAL_MONTH*' + SUBAREAS(STH) + '*.SAVE') & IF TSB[0] EQ '' THEN CONTINUE

            X     = DATE_2JD(DATES(DTH))
            AX    = DATE_AXIS(X,/MONTH, /YY_YEAR,STEP_SIZE=4)
            AYR   = DATE_AXIS(X,/YEAR)
            XTICKNAMES = REPLICATE(' ',N_ELEMENTS(AX.TICKNAME))

            DATA  = IDL_RESTORE(TSA)
            DATB  = IDL_RESTORE(TSB)
            TAGSA = TAG_NAMES(DATA)
            TAGSB = TAG_NAMES(DATB)
            OKA = WHERE(TAGSA EQ 'MEAN_' + REPLACE(PRODA,'-','_'))
            OKB = WHERE(TAGSB EQ 'MEAN_' + REPLACE(PRODB,'-','_'))

            MA = DATA[WHERE(DATA.PERIOD_CODE EQ 'M' AND DATA.SUBAREA_CODE EQ CODE)] & MAPROD = MA.(OKA) & MB = DATB[WHERE(DATB.PERIOD_CODE EQ 'M' AND DATB.SUBAREA_CODE EQ CODE)] & MBPROD = MB.(OKB)
            AA = DATA[WHERE(DATA.PERIOD_CODE EQ 'A' AND DATA.SUBAREA_CODE EQ CODE)] & AAPROD = AA.(OKA) & AB = DATB[WHERE(DATB.PERIOD_CODE EQ 'A' AND DATB.SUBAREA_CODE EQ CODE)] & ABPROD = AB.(OKB)

            CDATA = REPLICATE(STRUCT_2MISSINGS(CREATE_STRUCT('PERIOD','','PERIOD_CODE','','SUBAREA_CODE',0L,'SUBAREA_NAME','','DATA_A',0.0,'DATA_B',0.0)),N_ELEMENTS(MA)+N_ELEMENTS(AA))
            CDATA.PERIOD = [MA.PERIOD,AA.PERIOD]
            CDATA.PERIOD_CODE = [MA.PERIOD_CODE,AA.PERIOD_CODE]
            CDATA.SUBAREA_CODE = [MA.SUBAREA_CODE,AA.SUBAREA_CODE]
            CDATA.SUBAREA_NAME = [MA.SUBAREA_NAME,AA.SUBAREA_NAME]
            CDATA.DATA_A = [MA.(OKA),AA.(OKA)]
            OK = WHERE_MATCH(CDATA.PERIOD,MB.PERIOD,COUNT,VALID=VALID,COMPLEMENT=COMPLEMENT)
            CDATA[OK].DATA_B = MB(VALID).(OKB)
            OK = WHERE_MATCH(CDATA.PERIOD,AB.PERIOD,COUNT,VALID=VALID,COMPLEMENT=COMPLEMENT)
            CDATA[OK].DATA_B = AB(VALID).(OKB)
            CDATA = CDATA[WHERE(CDATA.DATA_A NE MISSINGS(0.0) AND CDATA.DATA_B NE MISSINGS(0.0))]
            OKXY = WHERE(CDATA.PERIOD_CODE EQ 'M' AND DATE_2YEAR(PERIOD_2DATE(CDATA.PERIOD)) LE '2007')

            STATS_STRUCT = STATS2(ALOG10(CDATA(OKXY).DATA_A),ALOG10(CDATA(OKXY).DATA_B),MODEL='RMA',PARAMS=PARAMS, DECIMALS=3,SHOW=0,FAST=fast,FILE=file,DOUBLE_SPACE=double_space)
            CC = CC + 1
            MSTATS(CC).SUBAREA_NAME=NAME
            MSTATS(CC).SUBAREA_CODE=CODE
            MSTATS(CC).PRODX = PRODA
            MSTATS(CC).PRODY = PRODB
            MSTATS(CC).N = STATS_STRUCT.N
            MSTATS(CC).SLOPE = STATS_STRUCT.SLOPE
            MSTATS(CC).INTERCEPT = STATS_STRUCT.INT
            MSTATS(CC).RSQ = STATS_STRUCT.RSQ
            IF KEYWORD_SET(DO_STATS_ONLY) AND DTH LT N_ELEMENTS(DATASETA)-1 THEN CONTINUE
            IF KEYWORD_SET(DO_STATS_ONLY) AND DTH EQ N_ELEMENTS(DATASETA)-1 THEN GOTO, SKIP_PLOTS

            YRANGE = NICE_RANGE([0,MAX([MAPROD,MBPROD],/NAN)+0.75])
            POSITION1 = START_POS(DTH)
            TXT = TEXT(POSITION1[0]+0.01,POSITION1(3)+0.005,TPROD,FONT_SIZE=12,FONT_STYLE='BOLD')
            PM = PLOT(AX.JD,YRANGE,YTITLE=UNITS(TPROD,/NO_NAME),FONT_SIZE=FONTSIZE,YMINOR=YMINOR,XMAJOR=AX.TICKS,XMINOR=0,XTICKNAME=XTICKNAMES,XTICKVALUES=AX.TICKV,POSITION=POSITION1,/NODATA,/CURRENT)
            XTICKV = PM.XTICKVALUES & OK = WHERE(JD_2MONTH(XTICKV) EQ '01',COUNT)
            FOR G=1,COUNT-1 DO GR = PLOT([XTICKV(OK(G)),XTICKV(OK(G))],YRANGE,COLOR='GREY',/OVERPLOT,XRANGE=AX.JD,YRANGE=YRANGE)
            P1 = PLOT(PERIOD_2JD(MA.PERIOD),MAPROD,XRANGE=AX.JD,YRANGE=YRANGE,/OVERPLOT,/CURRENT,COLOR=COLORA,SYMBOL='CIRCLE',SYM_SIZE=0.65,/SYM_FILLED)
            P2 = PLOT(PERIOD_2JD(MB.PERIOD),MBPROD,XRANGE=AX.JD,YRANGE=YRANGE,/OVERPLOT,/CURRENT,COLOR=COLORB,SYMBOL='CIRCLE',SYM_SIZE=0.65)
            TD = TEXT(POSITION1[0]+.02,POSITION1(3)-0.02,'Monthly',FONT_SIZE=FONTSIZE+2,FONT_STYLE='BOLD')
            TA = TEXT(POSITION1[0]+.02,POSITION1(3)-0.032,LEGA,FONT_COLOR=COLORA,FONT_SIZE=FONTSIZE+2,FONT_STYLE=FONT_STYLE)
            TB = TEXT(POSITION1[0]+.02,POSITION1(3)-0.044,LEGB,FONT_COLOR=COLORB,FONT_SIZE=FONTSIZE+2,FONT_STYLE=FONT_STYLE)

            XYPOSITION = [POSITION1(2)+0.07,POSITION1[1]+0.0,0.96,POSITION1(3)]
            STATS_POS = [XYPOSITION[0]+0.01, XYPOSITION(3)-0.057]
            IF KEYWORD_SET(LOGXY) THEN LOGLOG = 1 ELSE LOGLOG = 0

            XYRANGE = NICE_RANGE(MXYRANGE(DTH))
            P = PLOTXY_NG(CDATA(OKXY).DATA_A,CDATA(OKXY).DATA_B,DECIMALS=3,LOGLOG=LOGLOG,/QUIET,/CURRENT,MODEL='RMA',PARAMS=[2,3,4,8],POSITION=XYPOSITION,CHARSIZE=FONTSIZE,PSYM='CIRCLE',$
              XTITLE='',YTITLE='',SYM_COLOR=COLORXY,SYMSIZE=SYMSIZE,THICK=THICK,XRANGE=XYRANGE,YRANGE=XYRANGE,/GRID_NONE,MARGIN=MARGIN,STATS_CHARSIZE=STATS_CHARSIZE,$
              XTICKNAME=XTICKNAME,YTICKNAME=YTICKNAME,STATS_POS=STATS_POS,/ONE2ONE,ONE_COLOR=253,ONE_THICK=ONE_THICK,ONE_LINESTYLE=ONE_LINESTYLE,BUFFER=BUFFER,REG_COLOR=COLORREG,REG_MID_COLOR=COLORREG,REG_THICK=2)
            ;TX = TEXT(XYPOSITION[0]+(XYPOSITION(2)-XYPOSITION[0])/2.,XYPOSITION(1)-0.025,LEGA,ALIGNMENT=0.5,FONT_SIZE=FONTSIZE)
            TY = TEXT(XYPOSITION[0]-0.035,XYPOSITION[1]+(XYPOSITION(3)-XYPOSITION[1])/2.,LEGB,ALIGNMENT=0.5,FONT_SIZE=FONTSIZE,ORIENTATION=90)

            YRANGE = NICE_RANGE([0,MAX([AAPROD,ABPROD],/NAN)+0.4])
            POSITION2 = [POSITION1[0],POSITION1[1]-0.13,POSITION1(2),POSITION1(3)-0.13]
            PA = PLOT(AX.JD,YRANGE,YTITLE=UNITS(TPROD,/NO_NAME),FONT_SIZE=FONTSIZE,YMINOR=YMINOR,XMAJOR=AX.TICKS,XMINOR=0,XTICKNAME=AX.TICKNAME,XTICKVALUES=AX.TICKV,POSITION=POSITION2,/NODATA,/CURRENT)
            XTICKV = PA.XTICKVALUES & OK = WHERE(JD_2MONTH(XTICKV) EQ '01',COUNT)
            FOR G=1,COUNT-1 DO GR = PLOT([XTICKV(OK(G)),XTICKV(OK(G))],YRANGE,COLOR='GREY',/OVERPLOT,XRANGE=AX.JD,YRANGE=YRANGE)
            P1 = PLOT(PERIOD_2JD(AA.PERIOD),AAPROD,XRANGE=AX.JD,YRANGE=YRANGE,/OVERPLOT,/CURRENT,COLOR=COLORA,SYMBOL='CIRCLE',SYM_SIZE=1.0,/SYM_FILLED)
            P2 = PLOT(PERIOD_2JD(AB.PERIOD),ABPROD,XRANGE=AX.JD,YRANGE=YRANGE,/OVERPLOT,/CURRENT,COLOR=COLORB,SYMBOL='CIRCLE',SYM_SIZE=1.0)
            TD = TEXT(POSITION2[0]+.02,POSITION2(3)-0.02,'Annual',FONT_SIZE=FONTSIZE+2,FONT_STYLE='BOLD')
            TA = TEXT(POSITION2[0]+.02,POSITION2(3)-0.032,LEGA,FONT_COLOR=COLORA,FONT_SIZE=FONTSIZE+2,FONT_STYLE=FONT_STYLE)
            TB = TEXT(POSITION2[0]+.02,POSITION2(3)-0.044,LEGB,FONT_COLOR=COLORB,FONT_SIZE=FONTSIZE+2,FONT_STYLE=FONT_STYLE)

            XYPOSITION = [POSITION2(2)+0.07,POSITION2[1]-0.01,0.96,POSITION2(3)-.01]
            STATS_POS = [XYPOSITION[0]+0.01, XYPOSITION(3)-0.057]
            IF KEYWORD_SET(LOGXY) THEN LOGLOG = 1 ELSE LOGLOG = 0
            OKXY = WHERE(CDATA.PERIOD_CODE EQ 'A')
            XYRANGE = NICE_RANGE(AXYRANGE(DTH))
            P = PLOTXY_NG(CDATA(OKXY).DATA_A,CDATA(OKXY).DATA_B,DECIMALS=3,LOGLOG=LOGLOG,/QUIET,/CURRENT,MODEL='RMA',PARAMS=[2,3,4,8],POSITION=XYPOSITION,CHARSIZE=FONTSIZE,PSYM='CIRCLE',$
              XTITLE='',YTITLE='',SYM_COLOR=COLORXY,SYMSIZE=SYMSIZE*2,THICK=THICK,XRANGE=XYRANGE,YRANGE=XYRANGE,/GRID_NONE,MARGIN=MARGIN,STATS_CHARSIZE=STATS_CHARSIZE,$
              XTICKNAME=XTICKNAME,YTICKNAME=YTICKNAME,STATS_POS=STATS_POS,/ONE2ONE,ONE_COLOR=253,ONE_THICK=ONE_THICK,ONE_LINESTYLE=ONE_LINESTYLE,BUFFER=BUFFER,REG_COLOR=COLORREG,REG_MID_COLOR=COLORREG,REG_THICK=1)
            ;TX = TEXT(XYPOSITION[0]+(XYPOSITION(2)-XYPOSITION[0])/2.,XYPOSITION(1)-0.025,LEGA,ALIGNMENT=0.5,FONT_SIZE=FONTSIZE)
            TY = TEXT(XYPOSITION[0]-0.035,XYPOSITION[1]+(XYPOSITION(3)-XYPOSITION[1])/2.,LEGB,ALIGNMENT=0.5,FONT_SIZE=FONTSIZE,ORIENTATION=90)

            PAL='PAL_SW3'
            POSITIONS = LIST([0.06,POSITION1[1]-.32,0.24,POSITION1(3)-.26],$
              [0.28,POSITION1[1]-.32,0.46,POSITION1(3)-.26],$
              [0.50,POSITION1[1]-.32,0.68,POSITION1(3)-.26],$
              [POSITION2(2)+0.07,POSITION1(3)-0.41,0.96,POSITION1(3)-.28])
            XBAR = 5
            YBAR = 140
            ANNA = FILE_SEARCH(!S.DATASETS + DATASETA(DTH) + SL + MAP + SL + 'STATS' + SL + PRODA + SL + 'ANNUAL*-MEAN.SAVE')
            ANNB = FILE_SEARCH(!S.DATASETS + DATASETB(DTH) + SL + MAP + SL + 'STATS' + SL + PRODB + SL + 'ANNUAL*-MEAN.SAVE')

            IF TARGET EQ 'LME' THEN BEGIN
              PAL_36,R,G,B
              M = MAPS_SIZE('LME_'+NAME,/old)
              LANDMASK_FILE = !S.IMAGES + 'MASK_LAND-'+M.MAP+'-PXY_'+STRTRIM(M.PX,2)+'_'+STRTRIM(M.PY,2)+'.PNG'
              OUTLINE_FILES = DIR_OUTLINES + 'MASK_OUTLINE-LME_TOTAL-'+M.MAP+'-PXY_'+STRTRIM(M.PX,2)+'_'+STRTRIM(M.PY,2)+'.PNG'
            ENDIF

            IF TARGET EQ 'FAO' THEN BEGIN
              PAL_36,R,G,B
              M = MAPS_SIZE('FAO_'+NAME,/old)
              LANDMASK_FILE = !S.IMAGES + 'MASK_LAND-'+M.MAP+'-PXY_'+STRTRIM(M.PX,2)+'_'+STRTRIM(M.PY,2)+'.PNG'
              OUTLINE_FILES = DIR_OUTLINES + 'MASK_OUTLINE-FAO_TOTAL-'+M.MAP+'-PXY_'+STRTRIM(M.PX,2)+'_'+STRTRIM(M.PY,2)+'.PNG'
            ENDIF
            OUTLINE_COLORS = 0
            OUTLINE_THICK = 2
            ;  IF OUTLINE_FILES[0] EQ '' THEN STOP
            LAND_COLOR = 251
            ADAT = STRUCT_SD_READ(ANNA, MAP_OUT=TARGET+'_'+NAME,LME_CODE_OUT=CODE,STRUCT=ASTRUCT)
            BDAT = STRUCT_SD_READ(ANNB, MAP_OUT=TARGET+'_'+NAME,LME_CODE_OUT=CODE,STRUCT=BSTRUCT)
            RSTRUCT = MAKE_ANOM_SAVES(FILEA=ANNA,FILEB=ANNB,DIR_OUT=DIR_TEMP,ANOM=ANOM,/RETURN_STRUCT)
            RSTRUCT = STRUCT_SD_REMAP(STRUCT=RSTRUCT,MAP_OUT=TARGET+'_'+NAME,LME_CODE_OUT=CODE,REFRESH=REFRESH)

            POSITION = POSITIONS[0] & PX = WINX*(POSITION[0]-0.015) & PY = WINY*(POSITION(3)-0.025)
            ABAR = COLOR_BAR_SCALE_NG(PROD=ASTRUCT.PROD,SPECIAL_SCALE=SSA,PX=PX,PY=PY,CHARSIZE=FONTSIZE-1,XDIM=XBAR,YDIM=YBAR,PAL=PAL,NO_NAME=1,NO_UNIT=1,VERTICAL=1,LEFT=1,FONT='HELVETICA',TITLE=CTITLE)
            APNG = STRUCT_SD_2IMAGE_NG(ASTRUCT,IMG_POSITION=POSITION,USE_PROD=PRODA,SPECIAL_SCALE=SSA,/ADD_OUTLINE,/ADD_LAND,/ADD_COAST,LAND_COLOR=LAND_COLOR,OUTLINE_FILE=OUTLINE_FILES,OUTLINE_COLOR=OUTLINE_COLORS,OUTLINE_THICK=OUTLINE_THICK,/CURRENT,MARGIN=MARGIN,BUFFER=BUFFER)
            TX = TEXT(POSITION[0]+(POSITION(2)-POSITION[0])/2,POSITION[1]+0.015,LEGA,FONT_SIZE=FONTSIZE+1,VERTICAL_ALIGNMENT=1.0,ALIGNMENT=0.5)

            POSITION = POSITIONS[1] & PX = WINX*(POSITION[0]-0.015) & PY = WINY*(POSITION(3)-0.025)
            BBAR = COLOR_BAR_SCALE_NG(PROD=BSTRUCT.PROD,SPECIAL_SCALE=SSB,PX=PX,PY=PY,CHARSIZE=FONTSIZE-1,XDIM=XBAR,YDIM=YBAR,PAL=PAL,NO_NAME=1,NO_UNIT=1,VERTICAL=1,LEFT=1,FONT='HELVETICA',TITLE=CTITLE)
            BPNG = STRUCT_SD_2IMAGE_NG(BSTRUCT,IMG_POSITION=POSITION,USE_PROD=PRODB,SPECIAL_SCALE=SSB,/ADD_OUTLINE,/ADD_LAND,/ADD_COAST,LAND_COLOR=LAND_COLOR,OUTLINE_FILE=OUTLINE_FILES,OUTLINE_COLOR=OUTLINE_COLORS,OUTLINE_THICK=OUTLINE_THICK,/CURRENT,MARGIN=MARGIN,BUFFER=BUFFER)
            TY = TEXT(POSITION[0]+(POSITION(2)-POSITION[0])/2,POSITION[1]+0.015,LEGB,FONT_SIZE=FONTSIZE+1,VERTICAL_ALIGNMENT=1.0,ALIGNMENT=0.5)

            POSITION = POSITIONS(2) & PX = WINX*(POSITION[0]-0.015) & PY = WINY*(POSITION(3)-0.025)
            RBAR = COLOR_BAR_SCALE_NG(PROD=RSTRUCT.MATH,PX=PX,PY=PY,CHARSIZE=FONTSIZE-1,XDIM=XBAR,YDIM=YBAR,PAL='PAL_ANOMG',NO_NAME=1,NO_UNIT=1,VERTICAL=1,LEFT=1,FONT='HELVETICA',TITLE=CTITLE)
            RPNG = STRUCT_SD_2IMAGE_NG(RSTRUCT,SPECIAL_SCALE=SPECIAL_SCALE,PAL='PAL_ANOMG',IMG_POSITION=POSITION,/ADD_OUTLINE,/ADD_LAND,/ADD_COAST,LAND_COLOR=LAND_COLOR,OUTLINE_FILE=OUTLINE_FILES,OUTLINE_COLOR=OUTLINE_COLORS,OUTLINE_THICK=OUTLINE_THICK,/CURRENT,MARGIN=MARGIN,BUFFER=BUFFER)
            TA = TEXT(POSITION[0]+(POSITION(2)-POSITION[0])/2,POSITION[1]+0.015,LEGA+' : '+LEGB,FONT_SIZE=FONTSIZE+1,VERTICAL_ALIGNMENT=1.0,ALIGNMENT=0.5)

            POSITION=POSITIONS(3)
            STATS_POS = [POSITION[0] + 0.01, POSITION(3) - 0.057]
            OKXY = WHERE(ADAT NE MISSINGS(0.0) AND BDAT NE MISSINGS(0.0) AND MASK.IMAGE EQ CODE)

            P = PLOTXY_NG(BDAT(OKXY),ADAT(OKXY),DECIMALS=3,LOGLOG=LOGLOG,/QUIET,/CURRENT,MODEL='RMA',PARAMS=[2,3,4,8],POSITION=POSITION,CHARSIZE=FONTSIZE,PSYM='CIRCLE',$
              XTITLE='',YTITLE='',SYM_COLOR=COLORXY,SYMSIZE=SYMSIZE,THICK=THICK,XRANGE=NICE_RANGE(XSCALE),YRANGE=NICE_RANGE(YSCALE),/GRID_NONE,MARGIN=MARGIN,STATS_CHARSIZE=STATS_CHARSIZE,$
              XTICKNAME=XTICKNAME,YTICKNAME=YTICKNAME,STATS_POS=STATS_POS,/ONE2ONE,ONE_COLOR=253,ONE_THICK=ONE_THICK,ONE_LINESTYLE=ONE_LINESTYLE,REG_COLOR=COLORREG,REG_MID_COLOR=COLORREG)
            GONE, ADAT
            GONE, BDAT
            TX = TEXT(POSITION[0]+(POSITION(2)-POSITION[0])/2.,POSITION[1]-0.025,LEGA,ALIGNMENT=0.5,FONT_SIZE=FONTSIZE)
            TY = TEXT(POSITION[0]-0.035,POSITION[1]+(POSITION(3)-POSITION[1])/2.,LEGB,ALIGNMENT=0.5,FONT_SIZE=FONTSIZE,ORIENTATION=90)
          ENDFOR ; DATASETS
          PRINT, 'Writing: ' + PNGFILE
          W.SAVE,PNGFILE,RESOLUTION=600
          W.CLOSE
          SKIP_PLOTS:
        ENDFOR ; CODES
        STRUCT_2CSV,DIR_COMPARE+'MONTHLY_STATS_CHL_PP.CSV',MSTATS
      ENDFOR ; TARGETS
    ENDFOR ; SUBAREAS
    ; STOP

  ENDIF ; DO_COMPARE_PLOTS

  ; *******************************************************
  IF DO_COMPARE_PP GE 1 THEN BEGIN
    ; *******************************************************
    OVERWRITE = DO_COMPARE_PP GE 2

    BUFFER = 1
    TARGETS = ['LME'] ; 'FAO'
    SUBAREAS = ['MASK_SUBAREA-GEQ-PXY_4096_2048-LME_TOTAL'];'MASK_SUBAREA-GEQ-PXY_4096_2048-FAO_TOTAL'
    MAP = 'GEQ'
    SCDIR = 'OC-SEAWIFS-9'
    MCDIR = 'OC-MODIS-4'
    SPDIR = 'PP-SEAWIFS-PAT-9'
    MPDIR = 'PP-MODIS-PAT-4'

    PERIODS = ['M','A']
    TITLE_PERIODS = ['Monthly', 'Annual']

    DATES    = LIST([19970101,201310101],[19970101,20130101])
    DATASETA = [SPDIR,MPDIR]
    DATASETB = [SPDIR,MPDIR]
    PRODSA  = ['PPD-VGPM2','PPD-VGPM2']
    PRODSB  = ['PPD-OPAL', 'PPD-OPAL']
    TPRODS  = ['Primary Production','Primary Production']
    LEGENDA = ['SeaWiFS PP VGPM2','MODIS PP VGPM2']
    LEGENDB = ['SeaWiFS PP OPAL', 'MODIS PP OPAL']
    MYRANGE = LIST([0,3],[0,3])
    AYRANGE = LIST([0,1.2],[0,1.2])
    MXYRANGE = LIST([0.01,10],[0.01,10])
    AXYRANGE = LIST([0.01,10],[0.01,10])
    SCALEA  = ['LOW','LOW']
    SCALEB  = ['LOW','LOW']
    LOGSA   = [1,1]
    LOGSB   = [1,1]
    LOGXY   = [1,1]

    WINX = 850
    WINY = 1100
    XSPACE = 20. & XPER = XSPACE/WINX
    CTITLE = ' '

    YMINOR=1
    FONTSIZE = 8.5
    SYMSIZE = 0.45
    THICK = 2
    FONT = 0
    YMARGIN = [0.3,0.3]
    XMARGIN = [4,1]
    COLORA = 'ORANGE_RED'
    COLORB = 'DARK_BLUE'
    COLORXY  = !COLOR.(WHERE(TAG_NAMES(!COLOR) EQ COLORA))
    COLORREG = !COLOR.(WHERE(TAG_NAMES(!COLOR) EQ COLORB))
    START_POS = LIST([0.03,0.82,0.68,0.94],[0.03,0.33,0.68,0.45])

    FOR TAR=0, N_ELEMENTS(TARGETS)-1 DO BEGIN
      ATARGET = TARGETS(TAR)
      TARGET  = STRMID(ATARGET,0,3)

      FOR STH=0, N_ELEMENTS(SUBAREAS)-1 DO BEGIN
        SUBAREAFILE = !S.IMAGES + SUBAREAS(STH) + '.SAVE'
        SUBMASK = STRUCT_SD_READ(SUBAREAFILE,STRUCT=SUB_STRUCT)

        IF TARGET EQ 'FAO' THEN BEGIN
          TARS = READALL(!S.DATA+'FAO_NAMES.csv')
          EXCLUDE_FAOS = ['0','1','2','18','37','48','58','88']
          OK = WHERE_MATCH(SUB_STRUCT.SUBAREA_CODE,EXCLUDE_FAOS,COUNT,COMPLEMENT=COMPLEMENT)
          CODES = SUB_STRUCT.SUBAREA_CODE(COMPLEMENT)
          NAMES = SUB_STRUCT.SUBAREA_NAME(COMPLEMENT)
        ENDIF
        IF TARGET EQ 'LME' THEN BEGIN
          TARS = READALL(!S.DATA + 'lme_names.csv')
          EXCLUDE_LMES = ['255','0','251','64','63','62','61','58','57','56','55','54']
          OK = WHERE_MATCH(SUB_STRUCT.SUBAREA_CODE,EXCLUDE_LMES,COUNT,COMPLEMENT=COMPLEMENT)
          CODES  = SUB_STRUCT.SUBAREA_CODE(COMPLEMENT)
          NAMES  = SUB_STRUCT.SUBAREA_NAME(COMPLEMENT)
        ENDIF
        ;codes = reverse(codes)
        ;names = reverse(names)
        FOR C=0, N_ELEMENTS(CODES)-1 DO BEGIN
          CODE = CODES(C)
          NAME = NAMES(C)
          OK = WHERE(TARS.SUBAREA_NAME EQ NAME)
          TITLE = TARS[OK].NAME
          TSAS = [] & ANNAS = []
          TSBS = [] & ANNBS = []
          FOR D=0, N_ELEMENTS(DATASETA)-1 DO TSAS  = [TSAS, FILE_SEARCH(!S.DATASETS + DATASETA(D) + SL + MAP + SL + 'TS_SUBAREAS-STATS' + SL + 'A_ANNUAL_M_MANNUAL_MONTH*' + SUBAREAS(STH) + '*.SAVE')]
          FOR D=0, N_ELEMENTS(DATASETB)-1 DO TSBS  = [TSBS, FILE_SEARCH(!S.DATASETS + DATASETB(D) + SL + MAP + SL + 'TS_SUBAREAS-STATS' + SL + 'A_ANNUAL_M_MANNUAL_MONTH*' + SUBAREAS(STH) + '*.SAVE')]
          FOR D=0, N_ELEMENTS(DATASETA)-1 DO ANNAS = [ANNAS,FILE_SEARCH(!S.DATASETS + DATASETA(D) + SL + MAP + SL + 'STATS' + SL + PRODSA(D) + SL + 'ANNUAL*-MEAN.SAVE')]
          FOR D=0, N_ELEMENTS(DATASETB)-1 DO ANNBS = [ANNBS,FILE_SEARCH(!S.DATASETS + DATASETB(D) + SL + MAP + SL + 'STATS' + SL + PRODSB(D) + SL + 'ANNUAL*-MEAN.SAVE')]

          PNGFILE = FIX_PATH(DIR_COMPAREP + TARGET +'_' + NUM2STR(CODE) + '-' + NAME+'-VGPM2_OPAL-SEAWIFS_MODIS-COMPARE.PNG')
          UPDATE = UPDATE_CHECK(INFILES=[TSAS,TSBS,ANNAS,ANNBS],OUTFILE=PNGFILE)
          IF UPDATE EQ 0 AND NOT KEYWORD_SET(OVERWRITE) THEN CONTINUE
          PRINT, 'Working on: ' + PNGFILE
          MASK = STRUCT_SD_REMAP(FILES=SUBAREAFILE,MAP_OUT=TARGET+'_'+NAME,LME_CODE_OUT=CODE,/RETURN_STRUCT)

          W = WINDOW(DIMENSIONS=[WINX,WINY],BUFFER=BUFFER)
          OK = WHERE(TARS.SUBAREA_NAME EQ NAME)
          TITLE = TARS[OK].NAME
          TXT = TEXT(0.5,0.97,TITLE,ALIGNMENT=0.5,FONT_SIZE=14)

          FOR DTH=0, N_ELEMENTS(DATASETA)-1 DO BEGIN
            PRODA = PRODSA(DTH) & LOGA = LOGSA(DTH) & SSA = SCALEA(DTH) & SENSORA = VALID_SENSORS(DATASETA(DTH))
            PRODB = PRODSB(DTH) & LOGB = LOGSB(DTH) & SSB = SCALEA(DTH) & SENSORB = VALID_SENSORS(DATASETB(DTH))
            LEGA  = LEGENDA(DTH)
            LEGB  = LEGENDB(DTH)
            TPROD = TPRODS(DTH)
            XSCALE = SD_SCALES([1,250],PROD=VALIDS('PRODS',PRODA),SPECIAL_SCALE=SSA,/BIN2DATA) & YSCALE = SD_SCALES([1,250],PROD=VALIDS('PRODS',PRODB),SPECIAL_SCALE=SSB,/BIN2DATA)
            IF KEYWORD_SET(LOGA) THEN XRANGE = NICE_RANGE(ALOG10(XSCALE))ELSE XRANGE = NICE_RANGE(XSCALE)
            IF KEYWORD_SET(LOGB) THEN YRANGE = NICE_RANGE(ALOG10(YSCALE))ELSE YRANGE = NICE_RANGE(YSCALE)
            BINX=(XRANGE[1]-XRANGE[0])/100. & BINY=(YRANGE[1]-YRANGE[0])/100.
            XTITLE = UNITS(TPROD) + ' - ' + VALIDS('ALGS',PRODA) + ' Algorithm (' + SENSORA + ')'
            YTITLE = UNITS(TPROD) + ' - ' + VALIDS('ALGS',PRODB) + ' Algorithm (' + SENSORB + ')'

            TSA = FILE_SEARCH(!S.DATASETS + DATASETA(DTH) + SL + MAP + SL + 'TS_SUBAREAS-STATS' + SL + 'A_ANNUAL_M_MANNUAL_MONTH*' + SUBAREAS(STH) + '*.SAVE') & IF TSA[0] EQ '' THEN CONTINUE
            TSB = FILE_SEARCH(!S.DATASETS + DATASETB(DTH) + SL + MAP + SL + 'TS_SUBAREAS-STATS' + SL + 'A_ANNUAL_M_MANNUAL_MONTH*' + SUBAREAS(STH) + '*.SAVE') & IF TSB[0] EQ '' THEN CONTINUE

            X     = DATE_2JD(DATES(DTH))
            AX    = DATE_AXIS(X,/MONTH, /YY_YEAR,STEP_SIZE=4)
            AYR   = DATE_AXIS(X,/YEAR)
            XTICKNAMES = REPLICATE(' ',N_ELEMENTS(AX.TICKNAME))

            DATA  = IDL_RESTORE(TSA)
            DATB  = IDL_RESTORE(TSB)
            TAGSA = TAG_NAMES(DATA)
            TAGSB = TAG_NAMES(DATB)
            OKA = WHERE(TAGSA EQ 'MEAN_' + REPLACE(PRODA,'-','_'))
            OKB = WHERE(TAGSB EQ 'MEAN_' + REPLACE(PRODB,'-','_'))

            MA = DATA[WHERE(DATA.PERIOD_CODE EQ 'M' AND DATA.SUBAREA_CODE EQ CODE)] & MAPROD = MA.(OKA) & MB = DATB[WHERE(DATB.PERIOD_CODE EQ 'M' AND DATB.SUBAREA_CODE EQ CODE)] & MBPROD = MB.(OKB)
            AA = DATA[WHERE(DATA.PERIOD_CODE EQ 'A' AND DATA.SUBAREA_CODE EQ CODE)] & AAPROD = AA.(OKA) & AB = DATB[WHERE(DATB.PERIOD_CODE EQ 'A' AND DATB.SUBAREA_CODE EQ CODE)] & ABPROD = AB.(OKB)

            CDATA = REPLICATE(STRUCT_2MISSINGS(CREATE_STRUCT('PERIOD','','PERIOD_CODE','','SUBAREA_CODE',0L,'SUBAREA_NAME','','DATA_A',0.0,'DATA_B',0.0)),N_ELEMENTS(MA)+N_ELEMENTS(AA))
            CDATA.PERIOD = [MA.PERIOD,AA.PERIOD]
            CDATA.PERIOD_CODE = [MA.PERIOD_CODE,AA.PERIOD_CODE]
            CDATA.SUBAREA_CODE = [MA.SUBAREA_CODE,AA.SUBAREA_CODE]
            CDATA.SUBAREA_NAME = [MA.SUBAREA_NAME,AA.SUBAREA_NAME]
            CDATA.DATA_A = [MA.(OKA),AA.(OKA)]
            OK = WHERE_MATCH(CDATA.PERIOD,MB.PERIOD,COUNT,VALID=VALID,COMPLEMENT=COMPLEMENT)
            CDATA[OK].DATA_B = MB(VALID).(OKB)
            OK = WHERE_MATCH(CDATA.PERIOD,AB.PERIOD,COUNT,VALID=VALID,COMPLEMENT=COMPLEMENT)
            CDATA[OK].DATA_B = AB(VALID).(OKB)
            CDATA = CDATA[WHERE(CDATA.DATA_A NE MISSINGS(0.0) AND CDATA.DATA_B NE MISSINGS(0.0))]

            YRANGE = NICE_RANGE([0,MAX([MAPROD,MBPROD],/NAN)+0.75])
            POSITION1 = START_POS(DTH)
            TXT = TEXT(POSITION1[0]+0.01,POSITION1(3)+0.005,TPROD,FONT_SIZE=12,FONT_STYLE='BOLD')
            PM = PLOT(AX.JD,YRANGE,YTITLE=UNITS(TPROD,/NO_NAME),FONT_SIZE=FONTSIZE,YMINOR=YMINOR,XMAJOR=AX.TICKS,XMINOR=0,XTICKNAME=XTICKNAMES,XTICKVALUES=AX.TICKV,POSITION=POSITION1,/NODATA,/CURRENT)
            XTICKV = PM.XTICKVALUES & OK = WHERE(JD_2MONTH(XTICKV) EQ '01',COUNT)
            FOR G=1,COUNT-1 DO GR = PLOT([XTICKV(OK(G)),XTICKV(OK(G))],YRANGE,COLOR='GREY',/OVERPLOT,XRANGE=AX.JD,YRANGE=YRANGE)
            P1 = PLOT(PERIOD_2JD(MA.PERIOD),MAPROD,XRANGE=AX.JD,YRANGE=YRANGE,/OVERPLOT,/CURRENT,COLOR=COLORA,SYMBOL='CIRCLE',SYM_SIZE=0.65,/SYM_FILLED)
            P2 = PLOT(PERIOD_2JD(MB.PERIOD),MBPROD,XRANGE=AX.JD,YRANGE=YRANGE,/OVERPLOT,/CURRENT,COLOR=COLORB,SYMBOL='CIRCLE',SYM_SIZE=0.65)
            TD = TEXT(POSITION1[0]+.02,POSITION1(3)-0.02,'Monthly',FONT_SIZE=FONTSIZE+2,FONT_STYLE='BOLD')
            TA = TEXT(POSITION1[0]+.02,POSITION1(3)-0.032,LEGA,FONT_COLOR=COLORA,FONT_SIZE=FONTSIZE+2,FONT_STYLE=FONT_STYLE)
            TB = TEXT(POSITION1[0]+.02,POSITION1(3)-0.044,LEGB,FONT_COLOR=COLORB,FONT_SIZE=FONTSIZE+2,FONT_STYLE=FONT_STYLE)

            XYPOSITION = [POSITION1(2)+0.07,POSITION1[1]+0.0,0.96,POSITION1(3)]
            STATS_POS = [XYPOSITION[0]+0.01, XYPOSITION(3)-0.057]
            IF KEYWORD_SET(LOGXY) THEN LOGLOG = 1 ELSE LOGLOG = 0
            OKXY = WHERE(CDATA.PERIOD_CODE EQ 'M')
            XYRANGE = NICE_RANGE(MXYRANGE(DTH))
            P = PLOTXY_NG(CDATA(OKXY).DATA_B,CDATA(OKXY).DATA_A,DECIMALS=3,LOGLOG=LOGLOG,/QUIET,/CURRENT,MODEL='RMA',PARAMS=[2,3,4,8],POSITION=XYPOSITION,CHARSIZE=FONTSIZE,PSYM='CIRCLE',$
              XTITLE='',YTITLE='',SYM_COLOR=COLORXY,SYMSIZE=SYMSIZE,THICK=THICK,XRANGE=XYRANGE,YRANGE=XYRANGE,/GRID_NONE,MARGIN=MARGIN,STATS_CHARSIZE=STATS_CHARSIZE,$
              XTICKNAME=XTICKNAME,YTICKNAME=YTICKNAME,STATS_POS=STATS_POS,/ONE2ONE,ONE_COLOR=253,ONE_THICK=ONE_THICK,ONE_LINESTYLE=ONE_LINESTYLE,BUFFER=BUFFER,REG_COLOR=COLORREG,REG_MID_COLOR=COLORREG,REG_THICK=2)
            ;TX = TEXT(XYPOSITION[0]+(XYPOSITION(2)-XYPOSITION[0])/2.,XYPOSITION(1)-0.025,LEGA,ALIGNMENT=0.5,FONT_SIZE=FONTSIZE)
            TY = TEXT(XYPOSITION[0]-0.035,XYPOSITION[1]+(XYPOSITION(3)-XYPOSITION[1])/2.,LEGB,ALIGNMENT=0.5,FONT_SIZE=FONTSIZE,ORIENTATION=90)

            YRANGE = NICE_RANGE([0,MAX([AAPROD,ABPROD],/NAN)+0.4])
            POSITION2 = [POSITION1[0],POSITION1[1]-0.13,POSITION1(2),POSITION1(3)-0.13]
            PA = PLOT(AX.JD,YRANGE,YTITLE=UNITS(TPROD,/NO_NAME),FONT_SIZE=FONTSIZE,YMINOR=YMINOR,XMAJOR=AX.TICKS,XMINOR=0,XTICKNAME=AX.TICKNAME,XTICKVALUES=AX.TICKV,POSITION=POSITION2,/NODATA,/CURRENT)
            XTICKV = PA.XTICKVALUES & OK = WHERE(JD_2MONTH(XTICKV) EQ '01',COUNT)
            FOR G=1,COUNT-1 DO GR = PLOT([XTICKV(OK(G)),XTICKV(OK(G))],YRANGE,COLOR='GREY',/OVERPLOT,XRANGE=AX.JD,YRANGE=YRANGE)
            P1 = PLOT(PERIOD_2JD(AA.PERIOD),AAPROD,XRANGE=AX.JD,YRANGE=YRANGE,/OVERPLOT,/CURRENT,COLOR=COLORA,SYMBOL='CIRCLE',SYM_SIZE=1.0,/SYM_FILLED)
            P2 = PLOT(PERIOD_2JD(AB.PERIOD),ABPROD,XRANGE=AX.JD,YRANGE=YRANGE,/OVERPLOT,/CURRENT,COLOR=COLORB,SYMBOL='CIRCLE',SYM_SIZE=1.0)
            TD = TEXT(POSITION2[0]+.02,POSITION2(3)-0.02,'Annual',FONT_SIZE=FONTSIZE+2,FONT_STYLE='BOLD')
            TA = TEXT(POSITION2[0]+.02,POSITION2(3)-0.032,LEGA,FONT_COLOR=COLORA,FONT_SIZE=FONTSIZE+2,FONT_STYLE=FONT_STYLE)
            TB = TEXT(POSITION2[0]+.02,POSITION2(3)-0.044,LEGB,FONT_COLOR=COLORB,FONT_SIZE=FONTSIZE+2,FONT_STYLE=FONT_STYLE)

            XYPOSITION = [POSITION2(2)+0.07,POSITION2[1]-0.01,0.96,POSITION2(3)-.01]
            STATS_POS = [XYPOSITION[0]+0.01, XYPOSITION(3)-0.057]
            IF KEYWORD_SET(LOGXY) THEN LOGLOG = 1 ELSE LOGLOG = 0
            OKXY = WHERE(CDATA.PERIOD_CODE EQ 'A')
            XYRANGE = NICE_RANGE(AXYRANGE(DTH))
            P = PLOTXY_NG(CDATA(OKXY).DATA_B,CDATA(OKXY).DATA_A,DECIMALS=3,LOGLOG=LOGLOG,/QUIET,/CURRENT,MODEL='RMA',PARAMS=[2,3,4,8],POSITION=XYPOSITION,CHARSIZE=FONTSIZE,PSYM='CIRCLE',$
              XTITLE='',YTITLE='',SYM_COLOR=COLORXY,SYMSIZE=SYMSIZE*2,THICK=THICK,XRANGE=XYRANGE,YRANGE=XYRANGE,/GRID_NONE,MARGIN=MARGIN,STATS_CHARSIZE=STATS_CHARSIZE,$
              XTICKNAME=XTICKNAME,YTICKNAME=YTICKNAME,STATS_POS=STATS_POS,/ONE2ONE,ONE_COLOR=253,ONE_THICK=ONE_THICK,ONE_LINESTYLE=ONE_LINESTYLE,BUFFER=BUFFER,REG_COLOR=COLORREG,REG_MID_COLOR=COLORREG,REG_THICK=1)
            ;TX = TEXT(XYPOSITION[0]+(XYPOSITION(2)-XYPOSITION[0])/2.,XYPOSITION(1)-0.025,LEGA,ALIGNMENT=0.5,FONT_SIZE=FONTSIZE)
            TY = TEXT(XYPOSITION[0]-0.035,XYPOSITION[1]+(XYPOSITION(3)-XYPOSITION[1])/2.,LEGB,ALIGNMENT=0.5,FONT_SIZE=FONTSIZE,ORIENTATION=90)

            PAL='PAL_SW3'
            POSITIONS = LIST([0.06,POSITION1[1]-.32,0.24,POSITION1(3)-.26],$
              [0.28,POSITION1[1]-.32,0.46,POSITION1(3)-.26],$
              [0.50,POSITION1[1]-.32,0.68,POSITION1(3)-.26],$
              [POSITION2(2)+0.07,POSITION1(3)-0.41,0.96,POSITION1(3)-.28])
            XBAR = 5
            YBAR = 140
            ANNA = FILE_SEARCH(!S.DATASETS + DATASETA(DTH) + SL + MAP + SL + 'STATS' + SL + PRODA + SL + 'ANNUAL*-MEAN.SAVE')
            ANNB = FILE_SEARCH(!S.DATASETS + DATASETB(DTH) + SL + MAP + SL + 'STATS' + SL + PRODB + SL + 'ANNUAL*-MEAN.SAVE')

            IF TARGET EQ 'LME' THEN BEGIN
              PAL_36,R,G,B
              M = MAPS_SIZE('LME_'+NAME,/old)
              LANDMASK_FILE = !S.IMAGES + 'MASK_LAND-'+M.MAP+'-PXY_'+STRTRIM(M.PX,2)+'_'+STRTRIM(M.PY,2)+'.PNG'
              OUTLINE_FILES = DIR_OUTLINES + 'MASK_OUTLINE-LME_TOTAL-'+M.MAP+'-PXY_'+STRTRIM(M.PX,2)+'_'+STRTRIM(M.PY,2)+'.PNG'
            ENDIF

            IF TARGET EQ 'FAO' THEN BEGIN
              PAL_36,R,G,B
              M = MAPS_SIZE('FAO_'+NAME,/old)
              LANDMASK_FILE = !S.IMAGES + 'MASK_LAND-'+M.MAP+'-PXY_'+STRTRIM(M.PX,2)+'_'+STRTRIM(M.PY,2)+'.PNG'
              OUTLINE_FILES = DIR_OUTLINES + 'MASK_OUTLINE-FAO_TOTAL-'+M.MAP+'-PXY_'+STRTRIM(M.PX,2)+'_'+STRTRIM(M.PY,2)+'.PNG'
            ENDIF
            OUTLINE_COLORS = 0
            OUTLINE_THICK = 2
            ;  IF OUTLINE_FILES[0] EQ '' THEN STOP
            LAND_COLOR = 251
            ADAT = STRUCT_SD_READ(ANNA, MAP_OUT=TARGET+'_'+NAME,LME_CODE_OUT=CODE,STRUCT=ASTRUCT)
            BDAT = STRUCT_SD_READ(ANNB, MAP_OUT=TARGET+'_'+NAME,LME_CODE_OUT=CODE,STRUCT=BSTRUCT)
            RSTRUCT = MAKE_ANOM_SAVES(FILEA=ANNA,FILEB=ANNB,DIR_OUT=DIR_TEMP,ANOM=ANOM,/RETURN_STRUCT)
            RSTRUCT = STRUCT_SD_REMAP(STRUCT=RSTRUCT,MAP_OUT=TARGET+'_'+NAME,LME_CODE_OUT=CODE,REFRESH=REFRESH)

            POSITION = POSITIONS[0] & PX = WINX*(POSITION[0]-0.015) & PY = WINY*(POSITION(3)-0.025)
            ABAR = COLOR_BAR_SCALE_NG(PROD=ASTRUCT.PROD,SPECIAL_SCALE=SSA,PX=PX,PY=PY,CHARSIZE=FONTSIZE-1,XDIM=XBAR,YDIM=YBAR,PAL=PAL,NO_NAME=1,NO_UNIT=1,VERTICAL=1,LEFT=1,FONT='HELVETICA',TITLE=CTITLE)
            APNG = STRUCT_SD_2IMAGE_NG(ASTRUCT,IMG_POSITION=POSITION,USE_PROD=PRODA,SPECIAL_SCALE=SSA,/ADD_OUTLINE,/ADD_LAND,/ADD_COAST,LAND_COLOR=LAND_COLOR,OUTLINE_FILE=OUTLINE_FILES,OUTLINE_COLOR=OUTLINE_COLORS,OUTLINE_THICK=OUTLINE_THICK,/CURRENT,MARGIN=MARGIN,BUFFER=BUFFER)
            TX = TEXT(POSITION[0]+(POSITION(2)-POSITION[0])/2,POSITION[1]+0.015,LEGA,FONT_SIZE=FONTSIZE+1,VERTICAL_ALIGNMENT=1.0,ALIGNMENT=0.5)

            POSITION = POSITIONS[1] & PX = WINX*(POSITION[0]-0.015) & PY = WINY*(POSITION(3)-0.025)
            BBAR = COLOR_BAR_SCALE_NG(PROD=BSTRUCT.PROD,SPECIAL_SCALE=SSB,PX=PX,PY=PY,CHARSIZE=FONTSIZE-1,XDIM=XBAR,YDIM=YBAR,PAL=PAL,NO_NAME=1,NO_UNIT=1,VERTICAL=1,LEFT=1,FONT='HELVETICA',TITLE=CTITLE)
            BPNG = STRUCT_SD_2IMAGE_NG(BSTRUCT,IMG_POSITION=POSITION,USE_PROD=PRODB,SPECIAL_SCALE=SSB,/ADD_OUTLINE,/ADD_LAND,/ADD_COAST,LAND_COLOR=LAND_COLOR,OUTLINE_FILE=OUTLINE_FILES,OUTLINE_COLOR=OUTLINE_COLORS,OUTLINE_THICK=OUTLINE_THICK,/CURRENT,MARGIN=MARGIN,BUFFER=BUFFER)
            TY = TEXT(POSITION[0]+(POSITION(2)-POSITION[0])/2,POSITION[1]+0.015,LEGB,FONT_SIZE=FONTSIZE+1,VERTICAL_ALIGNMENT=1.0,ALIGNMENT=0.5)

            POSITION = POSITIONS(2) & PX = WINX*(POSITION[0]-0.015) & PY = WINY*(POSITION(3)-0.025)
            RBAR = COLOR_BAR_SCALE_NG(PROD=RSTRUCT.MATH,PX=PX,PY=PY,CHARSIZE=FONTSIZE-1,XDIM=XBAR,YDIM=YBAR,PAL='PAL_ANOMG',NO_NAME=1,NO_UNIT=1,VERTICAL=1,LEFT=1,FONT='HELVETICA',TITLE=CTITLE)
            RPNG = STRUCT_SD_2IMAGE_NG(RSTRUCT,SPECIAL_SCALE=SPECIAL_SCALE,PAL='PAL_ANOMG',IMG_POSITION=POSITION,/ADD_OUTLINE,/ADD_LAND,/ADD_COAST,LAND_COLOR=LAND_COLOR,OUTLINE_FILE=OUTLINE_FILES,OUTLINE_COLOR=OUTLINE_COLORS,OUTLINE_THICK=OUTLINE_THICK,/CURRENT,MARGIN=MARGIN,BUFFER=BUFFER)
            TA = TEXT(POSITION[0]+(POSITION(2)-POSITION[0])/2,POSITION[1]+0.015,LEGA+' : '+LEGB,FONT_SIZE=FONTSIZE+1,VERTICAL_ALIGNMENT=1.0,ALIGNMENT=0.5)

            POSITION=POSITIONS(3)
            STATS_POS = [POSITION[0] + 0.01, POSITION(3) - 0.057]
            OKXY = WHERE(ADAT NE MISSINGS(0.0) AND BDAT NE MISSINGS(0.0) AND MASK.IMAGE EQ CODE)

            P = PLOTXY_NG(BDAT(OKXY),ADAT(OKXY),DECIMALS=3,LOGLOG=LOGLOG,/QUIET,/CURRENT,MODEL='RMA',PARAMS=[2,3,4,8],POSITION=POSITION,CHARSIZE=FONTSIZE,PSYM='CIRCLE',$
              XTITLE='',YTITLE='',SYM_COLOR=COLORXY,SYMSIZE=SYMSIZE,THICK=THICK,XRANGE=NICE_RANGE(XSCALE),YRANGE=NICE_RANGE(YSCALE),/GRID_NONE,MARGIN=MARGIN,STATS_CHARSIZE=STATS_CHARSIZE,$
              XTICKNAME=XTICKNAME,YTICKNAME=YTICKNAME,STATS_POS=STATS_POS,/ONE2ONE,ONE_COLOR=253,ONE_THICK=ONE_THICK,ONE_LINESTYLE=ONE_LINESTYLE,REG_COLOR=COLORREG,REG_MID_COLOR=COLORREG)
            GONE, ADAT
            GONE, BDAT
            TX = TEXT(POSITION[0]+(POSITION(2)-POSITION[0])/2.,POSITION[1]-0.025,LEGA,ALIGNMENT=0.5,FONT_SIZE=FONTSIZE)
            TY = TEXT(POSITION[0]-0.035,POSITION[1]+(POSITION(3)-POSITION[1])/2.,LEGB,ALIGNMENT=0.5,FONT_SIZE=FONTSIZE,ORIENTATION=90)
          ENDFOR ; DATASETS
          PRINT, 'Writing: ' + PNGFILE
          W.SAVE,PNGFILE,RESOLUTION=600
          W.CLOSE
        ENDFOR ; CODES
      ENDFOR ; TARGETS
    ENDFOR ; SUBAREAS
    ;  STOP

  ENDIF ; DO_COMPARE_PP


  ; ********************************************
  IF DO_LME_FAO_SUBAREAS GE 1 THEN BEGIN
    ; ********************************************
    PAL_36,R,G,B

    OVERWRITE = DO_LME_FAO_SUBAREAS GE 1

    MAPS = ['GEQ']
    DIR_IMAGES = !S.IMAGES
    DIR_SUBAREAS = FIX_PATH(DIR_PROJECTS + 'FISHERIES\SUBAREAS\')

    TARGETS = ['FAO_total','FAO_minus','LME_total','LME_0_300','LME_300']
    FOR TAR=0, N_ELEMENTS(TARGETS)-1 DO BEGIN
      ATARGET = TARGETS(TAR)
      TARGET = STRMID(ATARGET,0,3)
      SAVE_FILE = DIR_SUBAREAS + STRUPCASE(ATARGET) + '_SUBAREAS.SAVE'
      AREA_FILE = DIR_SUBAREAS + 'AREA_' + ATARGET  + '.csv'
      FILES = FILE_SEARCH(DIR_SUBAREAS + ATARGET + '.csv')
      IF GET_MTIME(SAVE_FILE) LT MIN(GET_MTIME(FILES)) THEN BEGIN
        FOR N=0, N_ELEMENTS(FILES)-1 DO BEGIN
          AFILE = FILES(N)
          DATA = READALL(AFILE)
          IF N EQ 0 THEN STRUCT = DATA ELSE STRUCT = STRUCT_CONCAT(STRUCT,DATA)
          GONE, DATA
        ENDFOR
        SAVE,FILENAME=SAVE_FILE,STRUCT,/COMPRESS
      ENDIF ELSE STRUCT = IDL_RESTORE(SAVE_FILE)

      STRUCT = STRUCT_MERGE(REPLICATE(CREATE_STRUCT('SUBAREA_NAME','','SUBAREA_CODE',0,'SUBAREA_COLOR',0,'LAT',0.0,'LON',0.0),N_ELEMENTS(STRUCT)),STRUCT)

      FOR MTH=0,N_ELEMENTS(MAPS)-1 DO BEGIN
        AMAP = MAPS(MTH)
        MS = MAPS_SIZE(AMAP) & MS_ROB = MAPS_SIZE('ROBINSON')
        PX = MS.PX_OUT      & PX_ROB = MS_ROB.PX_OUT
        PY = MS.PY_OUT      & PY_ROB = MS_ROB.PY_OUT

        LANDMASK = READ_LANDMASK(MAP=AMAP,PX=PX,PY=PY,/STRUCT)
        MAXLAT = 89.9560
        MAXLON = 179.955
        OK = WHERE(FLOAT(STRUCT.ET_Y) GE  MAXLAT,COUNT)  & IF COUNT GE 1 THEN STRUCT[OK].ET_Y = STRING(MAXLAT)
        OK = WHERE(FLOAT(STRUCT.ET_Y) LE -MAXLAT,COUNT)  & IF COUNT GE 1 THEN STRUCT[OK].ET_Y = STRING(-MAXLAT)
        OK = WHERE(FLOAT(STRUCT.ET_X) GE  MAXLON,COUNT)  & IF COUNT GE 1 THEN STRUCT[OK].ET_X = STRING(MAXLON)
        OK = WHERE(FLOAT(STRUCT.ET_X) LE -MAXLON,COUNT)  & IF COUNT GE 1 THEN STRUCT[OK].ET_X = STRING(-MAXLON)
        STRUCT.LAT = FLOAT(STRUCT.ET_Y)
        STRUCT.LON = FLOAT(STRUCT.ET_X)

        COLORS = []
        IF TARGET EQ 'FAO' THEN BEGIN
          PAL_36,R,G,B
          OCEAN_COLOR = 36 & OCEAN_SUB = 0
          COAST_COLOR = 0  & COAST_SUB = 1
          LAND_COLOR  = 32 & LAND_SUB  = 2
          STRUCT.SUBAREA_CODE = STRUCT.F_AREA
          SETS = WHERE_SETS(STRUCT.F_AREA)

          FOR N=0, N_ELEMENTS(SETS)-1 DO BEGIN
            SUBS = WHERE_SETS_SUBS(SETS(N))
            CASE SETS(N).VALUE OF
              '18': BEGIN STRUCT(SUBS).SUBAREA_NAME = 'ARCTIC_SEA'                & STRUCT(SUBS).SUBAREA_COLOR = 5  & END
              '21': BEGIN STRUCT(SUBS).SUBAREA_NAME = 'NORTHWEST_ATLANTIC'        & STRUCT(SUBS).SUBAREA_COLOR = 7  & END
              '27': BEGIN STRUCT(SUBS).SUBAREA_NAME = 'NORTHEAST_ATLANTIC'        & STRUCT(SUBS).SUBAREA_COLOR = 9  & END
              '31': BEGIN STRUCT(SUBS).SUBAREA_NAME = 'WESTERN_CENTRAL_ATLANTIC'  & STRUCT(SUBS).SUBAREA_COLOR = 11 & END
              '34': BEGIN STRUCT(SUBS).SUBAREA_NAME = 'EASTERN_CENTRAL_ATLANTIC'  & STRUCT(SUBS).SUBAREA_COLOR = 13 & END
              '37': BEGIN STRUCT(SUBS).SUBAREA_NAME = 'MEDITERRANEAN_BLACK_SEA'   & STRUCT(SUBS).SUBAREA_COLOR = 15 & END
              '41': BEGIN STRUCT(SUBS).SUBAREA_NAME = 'SOUTHWEST_ATLANTIC'        & STRUCT(SUBS).SUBAREA_COLOR = 17 & END
              '47': BEGIN STRUCT(SUBS).SUBAREA_NAME = 'SOUTHEAST_ATLANTIC'        & STRUCT(SUBS).SUBAREA_COLOR = 19 & END
              '48': BEGIN STRUCT(SUBS).SUBAREA_NAME = 'ATLANTIC_ANTARCTIC'        & STRUCT(SUBS).SUBAREA_COLOR = 21 & END
              '51': BEGIN STRUCT(SUBS).SUBAREA_NAME = 'WESTERN_INDIAN'            & STRUCT(SUBS).SUBAREA_COLOR = 23 & END
              '57': BEGIN STRUCT(SUBS).SUBAREA_NAME = 'EASTERN_INDIAN'            & STRUCT(SUBS).SUBAREA_COLOR = 6  & END
              '58': BEGIN STRUCT(SUBS).SUBAREA_NAME = 'INDIAN_ANTARCTIC_SOUTHERN' & STRUCT(SUBS).SUBAREA_COLOR = 8  & END
              '61': BEGIN STRUCT(SUBS).SUBAREA_NAME = 'NORTHWEST_PACIFIC'         & STRUCT(SUBS).SUBAREA_COLOR = 10 & END
              '67': BEGIN STRUCT(SUBS).SUBAREA_NAME = 'NORTHEAST_PACIFIC'         & STRUCT(SUBS).SUBAREA_COLOR = 12 & END
              '71': BEGIN STRUCT(SUBS).SUBAREA_NAME = 'WESTERN_CENTRAL_PACIFIC'   & STRUCT(SUBS).SUBAREA_COLOR = 14 & END
              '77': BEGIN STRUCT(SUBS).SUBAREA_NAME = 'EASTERN_CENTRAL_PACIFIC'   & STRUCT(SUBS).SUBAREA_COLOR = 16 & END
              '81': BEGIN STRUCT(SUBS).SUBAREA_NAME = 'SOUTHWEST_PACIFIC'         & STRUCT(SUBS).SUBAREA_COLOR = 18 & END
              '87': BEGIN STRUCT(SUBS).SUBAREA_NAME = 'SOUTHEAST_PACIFIC'         & STRUCT(SUBS).SUBAREA_COLOR = 20 & END
              '88': BEGIN STRUCT(SUBS).SUBAREA_NAME = 'PACIFIC_ANTARCTIC'         & STRUCT(SUBS).SUBAREA_COLOR = 22 & END
            ENDCASE
          ENDFOR
        ENDIF
        IF TARGET EQ 'LME' THEN BEGIN
          PAL_SW3,R,G,B
          OCEAN_COLOR = 255 & OCEAN_SUB = 255
          COAST_COLOR = 0   & COAST_SUB = 0
          LAND_COLOR  = 251 & LAND_SUB  = 251

          LMES = READALL(!S.DATA + 'lme_names.csv')
          CODES = FIX(LMES.CODE)
          NAMES = STRUPCASE(REPLACE(STRTRIM(LMES.SUBAREA_NAME,2),' ','_'))
          SETS = WHERE_SETS(STRUCT.LME_NUMBER)
          FOR N=0, N_ELEMENTS(SETS)-1 DO BEGIN
            SUBS = WHERE_SETS_SUBS(SETS(N))
            SUBAREA = FIX(SETS(N).VALUE)
            OK = WHERE(CODES EQ SUBAREA)
            STRUCT(SUBS).SUBAREA_NAME = NAMES(OK[0])
            STRUCT(SUBS).SUBAREA_CODE = CODES(OK[0])
            STRUCT(SUBS).SUBAREA_COLOR = SD_SCALES(CODES(OK[0]),PROD='NUM',SPECIAL_SCALE=NUM2STR(N_ELEMENTS(SETS)),/DATA2BIN)
          ENDFOR
        ENDIF

        MASKFILE = DIR_IMAGES + 'MASK_SUBAREA-GEQ-PXY_'+NUM2STR(PX)+'_'+NUM2STR(PY)+'-'+STRUPCASE(ATARGET)+'.PNG'
        DISFILE  = DIR_IMAGES + 'MASK_SUBAREA-GEQ-PXY_'+NUM2STR(PX)+'_'+NUM2STR(PY)+'-'+STRUPCASE(ATARGET)+'-DISPLAY.PNG'
        CSVFILE  = DIR_IMAGES + 'MASK_SUBAREA-GEQ-PXY_'+NUM2STR(PX)+'_'+NUM2STR(PY)+'-'+STRUPCASE(ATARGET)+'.CSV'
        SAVEFILE = DIR_IMAGES + 'MASK_SUBAREA-GEQ-PXY_'+NUM2STR(PX)+'_'+NUM2STR(PY)+'-'+STRUPCASE(ATARGET)+'.SAVE'
        ROBFILE  = DIR_IMAGES + 'MASK_SUBAREA-ROBINSON-PXY_'+NUM2STR(PX_ROB)+'_'+NUM2STR(PY_ROB)+'-'+STRUPCASE(ATARGET)+'-DISPLAY.PNG'

        IF MIN(GET_MTIME([CSVFILE,SAVEFILE])) GT GET_MTIME(SAVE_FILE) THEN CONTINUE
        IF MIN(GET_MTIME([MASKFILE,DISFILE,ROBFILE])) GT GET_MTIME(SAVE_FILE) THEN GOTO, SKIP_MAKE_MASK

        SETS = WHERE_SETS(STRUCT.SUBAREA_CODE)
        POLYGONS = SETS.VALUE
        IMG      = LANDMASK.LANDMASK
        ZWIN, IMG
        OLDDEVICE= !D.NAME
        CALL_PROCEDURE,'MAP_'+AMAP
        FOR N=0, N_ELEMENTS(SETS)-1 DO BEGIN
          SUBS = WHERE_SETS_SUBS(SETS(N))
          DATA = STRUCT(SUBS)
          POLY = DATA[0].SUBAREA_CODE
          COLOR = DATA[0].SUBAREA_COLOR
          IF TARGET EQ 'FAO' THEN BEGIN
            CASE POLY OF
              '18': DO_SPLIT = 1
              '61': DO_SPLIT = 1
              '71': DO_SPLIT = 1
              '81': DO_SPLIT = 1
              '88': DO_SPLIT = 1
              ELSE: DO_SPLIT = 0
            ENDCASE
          ENDIF ELSE DO_SPLIT = 0

          SUBSETS = WHERE_SETS(DATA.ET_IDR)
          FOR D=0, N_ELEMENTS(SUBSETS)-1 DO BEGIN
            SUBSET = WHERE_SETS_SUBS(SUBSETS(D))
            SUBDATA = DATA(SUBSET)

            IF DO_SPLIT EQ 1 THEN BEGIN
              OK = WHERE(FLOAT(SUBDATA.LON LE 0.0))
              LON = FLOAT(SUBDATA[OK].LON) & LON = [LON,LON[0]]
              LAT = FLOAT(SUBDATA[OK].LAT) & LAT = [LAT,LAT[0]]
              IM = MAP_DEG2IMAGE(IMG,LON,LAT, X=x, Y=y,AROUND=0)
              IF MIN(X) EQ -1 OR MIN(Y) EQ -1 THEN STOP
              POLYFILL, X, Y, COLOR=COLOR, /DEVICE

              OK = WHERE(FLOAT(SUBDATA.LON GT 0.0))
              LON = FLOAT(SUBDATA[OK].LON) & LON = [LON,LON[0]]
              LAT = FLOAT(SUBDATA[OK].LAT) & LAT = [LAT,LAT[0]]
              IM = MAP_DEG2IMAGE(IMG,LON,LAT, X=x, Y=y,AROUND=0)
              IF MIN(X) EQ -1 OR MIN(Y) EQ -1 THEN STOP
              POLYFILL, X, Y, COLOR=COLOR, /DEVICE
            ENDIF ELSE BEGIN
              LON = FLOAT(SUBDATA.LON) & LON = [LON,LON[0]]
              LAT = FLOAT(SUBDATA.LAT) & LAT = [LAT,LAT[0]]
              IM = MAP_DEG2IMAGE(IMG,LON,LAT, X=x, Y=y,AROUND=0)
              IF MIN(X) EQ -1 OR MIN(Y) EQ -1 THEN STOP
              POLYFILL, X, Y, COLOR=COLOR, /DEVICE
              ;  plot, x,y,xstyle=4,ystyle=4,color=150
            ENDELSE
          ENDFOR
        ENDFOR

        IM_SUBS = TVRD()
        ZWIN
        OK_SUBS = WHERE(IM_SUBS GT 0)
        MASK = IM_SUBS & MASK(*) = MISSINGS(MASK)

        IMG(LANDMASK.OCEAN) = OCEAN_COLOR      & MASK(LANDMASK.OCEAN) = OCEAN_COLOR
        IMG(OK_SUBS)        = IM_SUBS(OK_SUBS) & MASK(OK_SUBS)        = IM_SUBS(OK_SUBS)
        IMG(LANDMASK.LAND)  = LAND_COLOR       & MASK(LANDMASK.LAND)  = LAND_COLOR
        IMG(LANDMASK.COAST) = COAST_COLOR      & MASK(LANDMASK.COAST) = COAST_COLOR

        WRITE_PNG, MASKFILE, MASK, R,G,B
        WRITE_PNG, DISFILE, IMG, R,G,B
        WRITE_PNG, ROBFILE, MAP_REMAP(IMG,MAP_IN=AMAP,MAP_OUT='ROBINSON'),R,G,B
        GONE, MASK
        GONE, IMG
        GONE, IM_SUBS
        GONE, LANDMASK
        SKIP_MAKE_MASK:

        STRUCT1=CREATE_STRUCT('SUBAREA_CODE',0L,'SUBAREA_NAME','','NICKNAME','','SUBAREA_COLOR',0L,'SUBAREA_AREA_KM2',0.0)
        STRUCT1=REPLICATE(STRUCT1,3)
        STRUCT1[0].SUBAREA_CODE = OCEAN_SUB  & STRUCT1[0].SUBAREA_NAME = 'OCEAN' & STRUCT1[0].NICKNAME='OCEAN' & STRUCT1[0].SUBAREA_COLOR = OCEAN_COLOR
        STRUCT1[1].SUBAREA_CODE = COAST_SUB  & STRUCT1[1].SUBAREA_NAME = 'COAST' & STRUCT1[1].NICKNAME='COAST' & STRUCT1[1].SUBAREA_COLOR = COAST_COLOR
        STRUCT1(2).SUBAREA_CODE = LAND_SUB   & STRUCT1(2).SUBAREA_NAME = 'LAND'  & STRUCT1(2).NICKNAME='LAND'  & STRUCT1(2).SUBAREA_COLOR = LAND_COLOR

        UNQ = UNIQ(STRUCT.SUBAREA_NAME)
        DATA = STRUCT(UNQ)
        DATA = DATA[SORT(DATA.SUBAREA_CODE)]
        NEW=CREATE_STRUCT('SUBAREA_CODE',0L,'SUBAREA_NAME','','NICKNAME','','SUBAREA_COLOR',0L,'SUBAREA_AREA_KM2',0.0D)
        NEW=REPLICATE(NEW,N_ELEMENTS(DATA))
        NEW.SUBAREA_CODE = FIX(DATA.SUBAREA_CODE)
        NEW.SUBAREA_NAME = STRUPCASE(DATA.SUBAREA_NAME)
        NEW.NICKNAME     = STRUPCASE(DATA.SUBAREA_NAME)
        NEW.SUBAREA_COLOR = FIX(DATA.SUBAREA_COLOR)

        AREA = READALL(AREA_FILE)
        TAGS = TAG_NAMES(AREA)
        IF TARGET EQ 'FAO' THEN POS = WHERE(TAGS EQ 'F_AREA') ELSE POS = WHERE(TAGS EQ 'LME_NUMBER')
        FOR A=0, N_ELEMENTS(NEW)-1 DO BEGIN
          OK = WHERE(AREA.(POS) EQ NEW(A).SUBAREA_CODE,COUNT)
          NEW(A).SUBAREA_AREA_KM2 = TOTAL(DOUBLE(AREA[OK].AREA_KM2))
        ENDFOR
        CSV = STRUCT_CONCAT(STRUCT1,NEW)

        ;     ===> Write the Struct to a csv
        STRUCT_2CSV,CSVFILE,CSV
        OK=WHERE(CSV.SUBAREA_CODE NE MISSINGS(CSV.SUBAREA_CODE))
        SUBAREA_CODE= CSV[OK].SUBAREA_CODE
        SUBAREA_NAME= CSV[OK].SUBAREA_NAME
        SUBAREA_COLOR = CSV[OK].SUBAREA_COLOR
        DATA = READ_PNG(MASKFILE)
        IMG  = DATA & IMG(*) = MISSINGS(IMG)
        FOR N=0, N_ELEMENTS(SUBAREA_COLOR)-1 DO BEGIN
          OK = WHERE(DATA EQ SUBAREA_COLOR(N),COUNT_COLOR)
          IF COUNT_COLOR GE 1 THEN IMG[OK] = SUBAREA_CODE(N)
        ENDFOR

        INFILE=MASKFILE
        NOTES='MASK_SUBAREA'

        STRUCT_SD_WRITE,SAVEFILE, IMAGE=IMG, PROD=PROD,  MAP=MAP, $
          MISSING_CODE=missing_code, MISSING_NAME=missing_name, $
          SUBAREA_CODE=SUBAREA_CODE,SUBAREA_NAME=subarea_name,SUBAREA_COLOR=subarea_color,$
          SCALING='LINEAR',  INTERCEPT=0.0,  SLOPE=1.0,TRANSFORMATION=TRANSFORMATION,$
          DATA_UNITS='',PERIOD=PERIOD, $
          INFILE=INFILE,$
          NOTES='MASK_SUBAREA', OVERWRITE=OVERWRITE, ERROR=ERROR

      ENDFOR
    ENDFOR
  ENDIF ; DO_LME_FAO_SUBAREAS

  ; ********************************************
  IF DO_SUBAREA_2LONLAT GE 1 THEN BEGIN
    ; ********************************************
    PAL_36,R,G,B

    OVERWRITE = DO_SUBAREA_2LONLAT GE 1

    MAPS = ['GEQ']
    DIR_SUBAREAS = FIX_PATH(DIR_PROJECTS + 'FISHERIES\SUBAREAS\')

    TARGETS = ['FAO_TOTAL','FAO_MINUS','LME_TOTAL','LME_0_300','LME_300']
    SAVE_FILES = !S.IMAGES + 'MASK_SUBAREA-GEQ-PXY_4096_2048-' + STRUPCASE(TARGETS) + '.SAVE'
    CSV_FILE  = DIR_SUBAREAS + 'SUBAREA_EXTRACTION-' + STRJOIN(TARGETS,'_')  + '.csv'
    DATA = MAKE_DATA_LAT_LON(SAVE_FILES, PROD=TARGETS,OVERWRITE=OVERWRITE)
    STRUCT_2CSV,CSVFILE,DATA



  ENDIF ; DO_SUBAREA_2LONLAT

  ; *******************************************************
  IF DO_GLOBAL_SUBAREAS GE 1 THEN BEGIN
    ; *******************************************************
    OVERWRITE = DO_GLOBAL_SUBAREAS GE 2

    PAL_36,R,G,B


    DIR_PLOTS  = FIX_PATH('D:\PROJECTS\ECOAP\FISHERIES')
    DIR_IMAGES = !S.IMAGES
    LANDFILE = DIR_IMAGES + 'MASK_LAND-GEQ-PXY_4096_2048-NOLAKES.PNG'
    EDITFILE = DIR_IMAGES + 'MASK_SUBAREA-GEQ-PXY_4096_2048-GLOBAL_POLYGONS-TO_BE_EDITED.PNG'
    MASKFILE = DIR_IMAGES + 'MASK_SUBAREA-GEQ-PXY_4096_2048-GLOBAL_POLYGONS.PNG'
    DISFILE  = DIR_IMAGES + 'MASK_SUBAREA-GEQ-PXY_4096_2048-GLOBAL_POLYGONS-DISPLAY.PNG'
    CSVFILE  = DIR_IMAGES + 'MASK_SUBAREA-GEQ-PXY_4096_2048-GLOBAL_POLYGONS.CSV'
    SAVEFILE = DIR_IMAGES + 'MASK_SUBAREA-GEQ-PXY_4096_2048-GLOBAL_POLYGONS.SAVE'

    POLYGONS = ['ARCTIC','MID_LATITUDES','SOUTHERN','INLAND']
    MASKCOLORS = [5, 6,7,36]
    DISCOLORS  = [20,5,9,35]

    LANDMASK = READ_LANDMASK(LANDFILE,PX=4096,PY=2048,/STRUCT)
    IF FILE_TEST(MASKFILE) EQ 1 AND NOT KEYWORD_SET(OVERWRITE) THEN GOTO, SKIP_EDITFILE
    IMG      = LANDMASK.LANDMASK
    ZWIN, IMG
    OLDDEVICE= !D.NAME
    MAP_GEQ
    LL = MAPS_2LONLAT('GEQ',PX=4096,PY=2048)
    OKA = WHERE(LL.LAT GT 60)  ;   ARCTIC
    OKS = WHERE(LL.LAT LT -60) ;   SOUTHERN
    ZWIN
    GONE, LL
    PAL_36,R,G,B

    IMG(LANDMASK.OCEAN) = 5
    IMG(OKA)            = 6
    IMG(OKS)            = 7
    IMG(LANDMASK.LAND)  = LANDMASK.LAND_CODE
    IMG(LANDMASK.COAST) = LANDMASK.COAST_CODE

    WRITE_PNG, EDITFILE, IMG, R,G,B
    SKIP_EDITFILE:

    IMG = READ_PNG(MASKFILE)
    DIS = IMG
    FOR N=0, N_ELEMENTS(MASKCOLORS)-1 DO BEGIN
      OK = WHERE(IMG EQ MASKCOLORS(N),COUNT)
      IF COUNT GE 1 THEN DIS[OK] = DISCOLORS(N)
    ENDFOR
    DIS(LANDMASK.LAND)  = 32
    DIS(LANDMASK.COAST) = 0
    WRITE_PNG, DISFILE, DIS, R,G,B

    OK_MISS = WHERE(IMG EQ 36)
    IMG(OK_MISS) = MISSINGS(IMG)
    STRUCT1=CREATE_STRUCT('SUBAREA_CODE','','SUBAREA_NAME','','NICKNAME','')
    STRUCT1=REPLICATE(STRUCT1,3)
    STRUCT1[0].SUBAREA_CODE =0  & STRUCT1[0].SUBAREA_NAME = 'OCEAN'     & STRUCT1[0].NICKNAME='OCEAN'
    STRUCT1[1].SUBAREA_CODE =1  & STRUCT1[1].SUBAREA_NAME = 'COAST'     & STRUCT1[1].NICKNAME='COAST'
    STRUCT1(2).SUBAREA_CODE =2  & STRUCT1(2).SUBAREA_NAME = 'LAND'      & STRUCT1(2).NICKNAME='LAND'

    STRUCT=CREATE_STRUCT('SUBAREA_CODE','','SUBAREA_NAME','','NICKNAME','')
    STRUCT=REPLICATE(STRUCT,N_ELEMENTS(POLYGONS))
    STRUCT.SUBAREA_CODE = INDGEN(N_ELEMENTS(POLYGONS))+5
    STRUCT.SUBAREA_NAME = STRUPCASE(POLYGONS)
    STRUCT.NICKNAME     = STRUPCASE(POLYGONS)

    CSV = STRUCT_CONCAT(STRUCT1,STRUCT)

    INFILE=MASKFILE
    NOTES='MASK_SUBAREA'

    ;     ===> Write the Struct to a csv
    STRUCT_2CSV,CSVFILE,CSV
    OK=WHERE(CSV.SUBAREA_CODE NE MISSINGS(CSV.SUBAREA_CODE))
    SUBAREA_CODE= CSV[OK].SUBAREA_CODE
    SUBAREA_NAME= CSV[OK].SUBAREA_NAME
    DATA = READ_PNG(MASKFILE)

    STRUCT_SD_WRITE,SAVEFILE, IMAGE=DATA, PROD=PROD,  MAP=MAP, $
      MISSING_CODE=missing_code, MISSING_NAME=missing_name, $
      SUBAREA_CODE=SUBAREA_CODE,SUBAREA_NAME=subarea_name,$
      SCALING='LINEAR',  INTERCEPT=0.0,  SLOPE=1.0,TRANSFORMATION=TRANSFORMATION,$
      DATA_UNITS='',PERIOD=PERIOD, $
      INFILE=INFILE,$
      NOTES='MASK_SUBAREA', OVERWRITE=OVERWRITE, ERROR=ERROR

  ENDIF   ; DO_GLOBAL_SUBAREA

  ; ********************************************
  IF DO_FAO_BOUNDARIES GE 1 THEN BEGIN
    ; ********************************************
    PAL_SW3_REVERSE,R,G,B

    FAO = READALL(DIR_PROJECTS + 'FISHERIES\FAO_SUBAREAS\fa_vertices.csv')
    FAO = STRUCT_2FLT(FAO)
    PX = 8640
    PY = 4320
    M = MAPS_2LONLAT('GEQ',PX=PX,PY=PY)
    OK = WHERE(FAO.LAT GE MAX(M.LAT),COUNT)  & IF COUNT GE 1 THEN FAO[OK].LAT = 89.9560
    OK = WHERE(FAO.LAT LE MIN(M.LAT),COUNT)  & IF COUNT GE 1 THEN FAO[OK].LAT = -89.9561
    OK = WHERE(FAO.LON GE MAX(M.LON),COUNT)  & IF COUNT GE 1 THEN FAO[OK].LON = 179.955
    OK = WHERE(FAO.LON LE MIN(M.LON),COUNT)  & IF COUNT GE 1 THEN FAO[OK].LON = -179.955
    SETS = WHERE_SETS(FAO.F_AREA)

    FOR N=0, N_ELEMENTS(SETS)-1 DO BEGIN
      SUBS = WHERE_SETS_SUBS(SETS(N))
      CASE SETS(N).VALUE OF
        '18': BEGIN FAO(SUBS).SUBAREA_NAME = 'ARCTIC_SEA'                & FAO(SUBS).SUBAREA_CODE = 5  & END
        '21': BEGIN FAO(SUBS).SUBAREA_NAME = 'NORTHWEST_ATLANTIC'        & FAO(SUBS).SUBAREA_CODE = 7  & END
        '27': BEGIN FAO(SUBS).SUBAREA_NAME = 'NORTHEAST_ATLATNIC'        & FAO(SUBS).SUBAREA_CODE = 9  & END
        '31': BEGIN FAO(SUBS).SUBAREA_NAME = 'WESTERN_CENTRAL_ATLANTIC'  & FAO(SUBS).SUBAREA_CODE = 11 & END
        '34': BEGIN FAO(SUBS).SUBAREA_NAME = 'EASTERN_CENTRAL_ATLANTIC'  & FAO(SUBS).SUBAREA_CODE = 13 & END
        '37': BEGIN FAO(SUBS).SUBAREA_NAME = 'MEDITERRANEAN_BLACK_SEA'   & FAO(SUBS).SUBAREA_CODE = 15 & END
        '41': BEGIN FAO(SUBS).SUBAREA_NAME = 'SOUTHWEST_ATLANTIC'        & FAO(SUBS).SUBAREA_CODE = 17 & END
        '47': BEGIN FAO(SUBS).SUBAREA_NAME = 'SOUTHEAST_ATLANTIC'        & FAO(SUBS).SUBAREA_CODE = 19 & END
        '48': BEGIN FAO(SUBS).SUBAREA_NAME = 'ATLANTIC_ANTARCTIC'        & FAO(SUBS).SUBAREA_CODE = 21 & END
        '51': BEGIN FAO(SUBS).SUBAREA_NAME = 'WESTERN_INDIAN'            & FAO(SUBS).SUBAREA_CODE = 23 & END
        '57': BEGIN FAO(SUBS).SUBAREA_NAME = 'EASTERN_INDIAN'            & FAO(SUBS).SUBAREA_CODE = 6  & END
        '58': BEGIN FAO(SUBS).SUBAREA_NAME = 'INDIAN_ANTARCTIC_SOUTHERN' & FAO(SUBS).SUBAREA_CODE = 8  & END
        '61': BEGIN FAO(SUBS).SUBAREA_NAME = 'NORTHWEST_PACIFIC'         & FAO(SUBS).SUBAREA_CODE = 10 & END
        '67': BEGIN FAO(SUBS).SUBAREA_NAME = 'NORTHEAST_PACIFIC'         & FAO(SUBS).SUBAREA_CODE = 12 & END
        '71': BEGIN FAO(SUBS).SUBAREA_NAME = 'WESTERN_CENTRAL_PACIFIC'   & FAO(SUBS).SUBAREA_CODE = 14 & END
        '77': BEGIN FAO(SUBS).SUBAREA_NAME = 'EASTERN_CENTRAL_PACIFIC'   & FAO(SUBS).SUBAREA_CODE = 16 & END
        '81': BEGIN FAO(SUBS).SUBAREA_NAME = 'SOUTHWEST_PACIFIC'         & FAO(SUBS).SUBAREA_CODE = 18 & END
        '87': BEGIN FAO(SUBS).SUBAREA_NAME = 'SOUTHEAST_PACIFIC'         & FAO(SUBS).SUBAREA_CODE = 20 & END
        '88': BEGIN FAO(SUBS).SUBAREA_NAME = 'PACIFIC_ANTARCTIC'         & FAO(SUBS).SUBAREA_CODE = 22 & END
      ENDCASE
    ENDFOR

    DIR_IMAGES = !S.IMAGES
    LANDMASK_FILE = DIR_IMAGES + 'MASK_LAND-GEQ-PXY_'+NUM2STR(PX)+'_'+NUM2STR(PY)+'.PNG'
    LANDMASK = READ_LANDMASK(MAP='GEQ',PX=PX,PY=PY,/STRUCT)
    PAL_36,R,G,B

    SETS = WHERE_SETS(FAO.SUBAREA_NAME)
    POLYGONS = SETS.VALUE
    IMG      = READ_PNG(LANDMASK_FILE)
    ZWIN, IMG
    OLDDEVICE= !D.NAME
    MAP_GEQ
    FOR N=0, N_ELEMENTS(SETS)-1 DO BEGIN
      POLY = POLYGONS(N)
      SUBS = WHERE_SETS_SUBS(SETS(N))
      DATA = FAO(SUBS)
      COLOR = DATA[0].SUBAREA_CODE
      CASE POLY OF
        'ARCTIC_SEA': DO_SPLIT = 1
        'NORTHWEST_PACIFIC': DO_SPLIT = 1
        'WESTERN_CENTRAL_PACIFIC': DO_SPLIT = 1
        'SOUTHWEST_PACIFIC': DO_SPLIT = 1
        'PACIFIC_ANTARCTIC': DO_SPLIT = 1
        ELSE: DO_SPLIT = 0
      ENDCASE

      IF DO_SPLIT EQ 1 THEN BEGIN
        OK = WHERE(FLOAT(DATA.LON LE 0.0))
        LON = FLOAT(DATA[OK].LON) & LON = [LON,LON[0]]
        LAT = FLOAT(DATA[OK].LAT) & LAT = [LAT,LAT[0]]
        IM = MAP_DEG2IMAGE(IMG,LON,LAT, X=x, Y=y,AROUND=0)
        IF MIN(X) EQ -1 OR MIN(Y) EQ -1 THEN STOP
        POLYFILL, X, Y, COLOR=COLOR, /DEVICE

        OK = WHERE(FLOAT(DATA.LON GT 0.0))
        LON = FLOAT(DATA[OK].LON) & LON = [LON,LON[0]]
        LAT = FLOAT(DATA[OK].LAT) & LAT = [LAT,LAT[0]]
        IM = MAP_DEG2IMAGE(IMG,LON,LAT, X=x, Y=y,AROUND=0)
        IF MIN(X) EQ -1 OR MIN(Y) EQ -1 THEN STOP
        POLYFILL, X, Y, COLOR=COLOR, /DEVICE
      ENDIF ELSE BEGIN
        LON = FLOAT(DATA.LON) & LON = [LON,LON[0]]
        LAT = FLOAT(DATA.LAT) & LAT = [LAT,LAT[0]]
        IM = MAP_DEG2IMAGE(IMG,LON,LAT, X=x, Y=y,AROUND=0)
        IF MIN(X) EQ -1 OR MIN(Y) EQ -1 THEN STOP
        POLYFILL, X, Y, COLOR=COLOR, /DEVICE
      ENDELSE
    ENDFOR

    IM_SUBS = TVRD()
    ZWIN
    OK_IMAGE = WHERE(IMG NE 0)
    IM_SUBS(OK_IMAGE) = IMG(OK_IMAGE)
    MASK = IM_SUBS
    IMG(LANDMASK.OCEAN) = 36
    OK = WHERE(IM_SUBS GE 5)
    IMG[OK] = IM_SUBS[OK]
    IMG(LANDMASK.LAND)  = 32
    IMG(LANDMASK.COAST) = 0
    OK = WHERE(MASK NE 0)
    IM_SUBS[OK] = MASK[OK]

    EDITFILE = DIR_IMAGES + 'MASK_SUBAREA-GEQ-PXY_'+NUM2STR(PX)+'_'+NUM2STR(PY)+'-FAO_POLYGONS-TO_BE_EDITED.PNG' & WRITE_PNG, EDITFILE, IM_SUBS, R,G,B
    MASKFILE = DIR_IMAGES + 'MASK_SUBAREA-GEQ-PXY_'+NUM2STR(PX)+'_'+NUM2STR(PY)+'-FAO_POLYGONS.PNG'
    PNGFILE  = DIR_IMAGES + 'MASK_SUBAREA-GEQ-PXY_'+NUM2STR(PX)+'_'+NUM2STR(PY)+'-FAO_POLYGONS-DISPLAY.PNG' & WRITE_PNG, PNGFILE, IMG, R,G,B
    CSVFILE  = DIR_IMAGES + 'MASK_SUBAREA-GEQ-PXY_'+NUM2STR(PX)+'_'+NUM2STR(PY)+'-FAO_POLYGONS.CSV'
    SAVEFILE = DIR_IMAGES + 'MASK_SUBAREA-GEQ-PXY_'+NUM2STR(PX)+'_'+NUM2STR(PY)+'-FAO_POLYGONS.SAVE'

    STRUCT1=CREATE_STRUCT('SUBAREA_CODE',0L,'SUBAREA_NAME','','NICKNAME','')
    STRUCT1=REPLICATE(STRUCT1,3)
    STRUCT1[0].SUBAREA_CODE = 0L  & STRUCT1[0].SUBAREA_NAME = 'OCEAN' & STRUCT1[0].NICKNAME='OCEAN'
    STRUCT1[1].SUBAREA_CODE = 1L  & STRUCT1[1].SUBAREA_NAME = 'COAST' & STRUCT1[1].NICKNAME='COAST'
    STRUCT1(2).SUBAREA_CODE = 2L  & STRUCT1(2).SUBAREA_NAME = 'LAND'  & STRUCT1(2).NICKNAME='LAND'

    UNQ = UNIQ(FAO.SUBAREA_NAME)
    DATA = FAO(UNQ)
    DATA = DATA[SORT(DATA.SUBAREA_CODE)]
    STRUCT=CREATE_STRUCT('SUBAREA_CODE',0L,'SUBAREA_NAME','','NICKNAME','')
    STRUCT=REPLICATE(STRUCT,N_ELEMENTS(DATA))
    STRUCT.SUBAREA_CODE = FIX(DATA.SUBAREA_CODE)
    STRUCT.SUBAREA_NAME = STRUPCASE(DATA.SUBAREA_NAME)
    STRUCT.NICKNAME     = STRUPCASE(DATA.SUBAREA_NAME)
    CSV = STRUCT_CONCAT(STRUCT1,STRUCT)

    ;     ===> Write the Struct to a csv
    STRUCT_2CSV,CSVFILE,CSV
    OK=WHERE(CSV.SUBAREA_CODE NE MISSINGS(CSV.SUBAREA_CODE))
    SUBAREA_CODE= CSV[OK].SUBAREA_CODE
    SUBAREA_NAME= CSV[OK].SUBAREA_NAME
    DATA = READ_PNG(MASKFILE)

    INFILE=MASKFILE
    NOTES='MASK_SUBAREA'

    STRUCT_SD_WRITE,SAVEFILE, IMAGE=DATA, PROD=PROD,  MAP=MAP, $
      MISSING_CODE=missing_code, MISSING_NAME=missing_name, $
      SUBAREA_CODE=SUBAREA_CODE,SUBAREA_NAME=subarea_name,$
      SCALING='LINEAR',  INTERCEPT=0.0,  SLOPE=1.0,TRANSFORMATION=TRANSFORMATION,$
      DATA_UNITS='',PERIOD=PERIOD, $
      INFILE=INFILE,$
      NOTES='MASK_SUBAREA', OVERWRITE=OVERWRITE, ERROR=ERROR
    STOP
  ENDIF ; DO_FAO_BOUNDARIES


  ; *******************************************************
  IF DO_GLOBAL_PLOTS GE 1 THEN BEGIN
    ; *******************************************************
    OVERWRITE = DO_GLOBAL_PLOTS GE 2

    SL = DELIMITER(/PATH)

    SKIP_LMES = [18,19,20,21,33,54,55,56,57,58,59,60,61,62,63]
    PAC_LMES  = [13,11,10, 4, 3, 2, 1,53,52,51,50,49,48,47,40,41,42,46]
    IND_LMES  = [43,44,45,39,38,37,36,35,34,32,31,30]
    ATL_LMES  = [29,28,27,26,25,24,23,22, 9, 8, 7, 6, 5,12,17,16,15,14]
    SKIP_FAOS = [5,8,22,21]
    FAO       = [7,9,11,13,15,17,19,23,6,10,12,14,16,18,20]
    LMES      = LIST(PAC_LMES,IND_LMES,ATL_LMES)
    SAVENAME  = ['PACIFIC_LMES','INDIAN_LMES','ATLANTIC_LMES']

    AX = DATE_AXIS(['19980101','20070101'],/YEAR,/YY_YEAR)
    PRANGE = [0,2]
    CRANGE = [0,2]

    SUBAREAS  = ['LME_TOTAL','LME_0_300','LME_300','FAO_TOTAL','FAO_MINUS']
    PDATASETS = ['PP-SEAWIFS-PAT-9']
    CDATASETS = ['OC-SEAWIFS-9']
    MAPS      = ['GEQ']
    PERIODS   = ['A_ANNUAL']
    PP_ALGS   = ['PPD-OPAL','PPD-VGPM2']
    CH_ALGS   = ['CHLOR_A-OC4']

    FOR STH=0, N_ELEMENTS(SUBAREAS)-1 DO BEGIN
      FOR DTH=0, N_ELEMENTS(PDATASETS)-1 DO BEGIN
        FOR MTH=0, N_ELEMENTS(MAPS)-1 DO BEGIN
          PFILE = FILE_SEARCH(!S.DATASETS+PDATASETS(DTH)+SL+MAPS(MTH)+SL+'TS_SUBAREAS'+SL+PERIODS+'-MASK_SUBAREA-GEQ-PXY_4096_2048-'+SUBAREAS(STH)+'-*-MULTI_PRODS.SAVE')
          CFILE = FILE_SEARCH(!S.DATASETS+CDATASETS(DTH)+SL+MAPS(MTH)+SL+'TS_SUBAREAS'+SL+PERIODS+'*MASK_SUBAREA-GEQ-PXY_4096_2048-'+SUBAREAS(STH)+'-*'+STRJOIN(CH_ALGS,'_')+'*.SAVE')

          PDATA = IDL_RESTORE(PFILE) & APDATA = PDATA[WHERE(PDATA.PERIOD EQ 'ANNUAL_1998_2007')] & PDATA=PDATA[WHERE(PDATA.PERIOD_CODE EQ 'A')] & PTAGS = TAG_NAMES(PDATA)
          CDATA = IDL_RESTORE(CFILE) & ACDATA = CDATA[WHERE(CDATA.PERIOD EQ 'ANNUAL_1998_2007')] & CDATA=CDATA[WHERE(CDATA.PERIOD_CODE EQ 'A')] & CTAGS = TAG_NAMES(CDATA)

          BARPNG = DIR_PLOTS + 'ANNUAL-PP_CHL-'+SUBAREAS(STH)+'-BARPLOT.PNG'
          IF GET_MTIME(BARPNG) LT GET_MTIME(MAX([PFILE,CFILE])) OR KEYWORD_SET(OVERWRITE) THEN BEGIN
            IF SUBAREAS(STH) NE 'LME' THEN BEGIN APDATA = APDATA([FAO,SKIP_FAOS]-5) & ACDATA = ACDATA([FAO,SKIP_FAOS]-5) & ENDIF
            IF SUBAREAS(STH) EQ 'LME' THEN XTICKVALUES = ACDATA[WHERE(ODD(ACDATA.SUBAREA_CODE) EQ 1)].SUBAREA_CODE ELSE XTICKVALUES = ACDATA.SUBAREA_CODE-4
            IF SUBAREAS(STH) EQ 'LME' THEN CRANGE = [0,4] ELSE CRANGE = [0,1]
            IF SUBAREAS(STH) EQ 'LME' THEN PRANGE = [0,4] ELSE PRANGE = [0,1]
            XTITLE = STRMID(SUBAREAS(STH),0,3)+' Subarea Code'
            W = WINDOW(DIMENSIONS = [1024,1536])
            BC = BARPLOT(INDGEN(1,N_ELEMENTS(ACDATA))+1,ACDATA.MEAN_CHLOR_A_OC4,FILL_COLOR='LIME_GREEN',YRANGE=CRANGE,YTITLE=UNITS('CHLOROPHYLL'),         XTICKVALUES=XTICKVALUES,XRANGE=[1,N_ELEMENTS(ACDATA)],XSTYLE=3,XTITLE=XTITLE,XMAJOR=31,XMINOR=1,MARGIN=0.1,LAYOUT=[1,4,1],/CURRENT)
            ;     BC = BARPLOT(INDGEN(1,N_ELEMENTS(APDATA))+1,APDATA.MEAN_PPD_OPAL,   FILL_COLOR='ORANGE',    YRANGE=PRANGE,YTITLE='OPAL '+UNITS('PPD'),         XTICKVALUES=XTICKVALUES,XRANGE=[1,N_ELEMENTS(APDATA)],XSTYLE=3,XTITLE=XTITLE,XMAJOR=31,XMINOR=1,MARGIN=0.1,LAYOUT=[1,4,2],/CURRENT)
            BC = BARPLOT(INDGEN(1,N_ELEMENTS(APDATA))+1,APDATA.MEAN_PPD_VGPM2,  FILL_COLOR='NAVY',      YRANGE=PRANGE,YTITLE='VGPM (Eppley) '+UNITS('PPD'),XTICKVALUES=XTICKVALUES,XRANGE=[1,N_ELEMENTS(APDATA)],XSTYLE=3,XTITLE=XTITLE,XMAJOR=31,XMINOR=1,MARGIN=0.1,LAYOUT=[1,4,3],/CURRENT)
            IF STRPOS(SUBAREAS(STH),'LME') GE 0 THEN BEGIN
              T1 = APDATA(0:15)  & FOR T=0, N_ELEMENTS(T1)-1 DO TT = TEXT(0.05,0.23-(0.015*T),NUM2STR(T1(T).SUBAREA_CODE) + ' - ' + T1(T).SUBAREA_NAME,/NORMAL,FONT_SIZE=10)
              T2 = APDATA(16:31) & FOR T=0, N_ELEMENTS(T2)-1 DO TT = TEXT(0.30,0.23-(0.015*T),NUM2STR(T2(T).SUBAREA_CODE) + ' - ' + T2(T).SUBAREA_NAME,/NORMAL,FONT_SIZE=10)
              T3 = APDATA(32:47) & FOR T=0, N_ELEMENTS(T3)-1 DO TT = TEXT(0.55,0.23-(0.015*T),NUM2STR(T3(T).SUBAREA_CODE) + ' - ' + T3(T).SUBAREA_NAME,/NORMAL,FONT_SIZE=10)
              T4 = APDATA(48:62) & FOR T=0, N_ELEMENTS(T4)-1 DO TT = TEXT(0.80,0.23-(0.015*T),NUM2STR(T4(T).SUBAREA_CODE) + ' - ' + T4(T).SUBAREA_NAME,/NORMAL,FONT_SIZE=10)
            ENDIF ELSE BEGIN
              T1 = APDATA(0:4)   & FOR T=0, N_ELEMENTS(T1)-1 DO TT = TEXT(0.05,0.2-(0.02*T),NUM2STR(1+T) +' - '+STR_CAP(REPLACE(T1(T).SUBAREA_NAME,'_',' '),/ALL),/NORMAL,FONT_SIZE=10)
              T2 = APDATA(5:9)   & FOR T=0, N_ELEMENTS(T2)-1 DO TT = TEXT(0.30,0.2-(0.02*T),NUM2STR(6+T) +' - '+STR_CAP(REPLACE(T2(T).SUBAREA_NAME,'_',' '),/ALL),/NORMAL,FONT_SIZE=10)
              T3 = APDATA(10:14) & FOR T=0, N_ELEMENTS(T3)-1 DO TT = TEXT(0.55,0.2-(0.02*T),NUM2STR(11+T)+' - '+STR_CAP(REPLACE(T3(T).SUBAREA_NAME,'_',' '),/ALL),/NORMAL,FONT_SIZE=10)
              T4 = APDATA(15:18) & FOR T=0, N_ELEMENTS(T4)-1 DO TT = TEXT(0.80,0.2-(0.02*T),NUM2STR(16+T)+' - '+STR_CAP(REPLACE(T4(T).SUBAREA_NAME,'_',' '),/ALL),/NORMAL,FONT_SIZE=10)
            ENDELSE
            W.SAVE,BARPNG,RESOLUTION=300
            W.CLOSE
          ENDIF

          IF STRPOS(SUBAREAS(STH),'LME') GE 0 THEN BEGIN
            FOR LTH=0, N_ELEMENTS(LMES)-1 DO BEGIN
              LME = LMES(LTH)
              PNGFILE = DIR_PLOTS + 'ANNUAL-PP_CHL-'+SAVENAME(LTH)+'.PNG'
              IF GET_MTIME(PNGFILE) GT GET_MTIME(MAX([PFILE,CFILE])) AND NOT KEYWORD_SET(OVERWRITE) THEN CONTINUE
              W = WINDOW(DIMENSIONS=[N_ELEMENTS(LME)*100,900])
              FOR CTH=0, N_ELEMENTS(LME)-1 DO BEGIN
                PDAT = PDATA[WHERE(PDATA.SUBAREA_CODE EQ LME(CTH))]
                CDAT = CDATA[WHERE(CDATA.SUBAREA_CODE EQ LME(CTH))]
                LAYOUT = [N_ELEMENTS(LME)/3,3,CTH+1]
                POS1 = WHERE(PTAGS EQ 'MEAN_' + REPLACE(PP_ALGS[0],'-','_'))
                POS2 = WHERE(PTAGS EQ 'MEAN_' + REPLACE(PP_ALGS[1],'-','_'))
                POS3 = WHERE(CTAGS EQ 'MEAN_' + REPLACE(CH_ALGS[0],'-','_'))
                TITLE = REPLACE(PDAT[0].SUBAREA_NAME,'_',' ') + ' LME'
                MARGIN = [0.1,0.1,0.1,0.1]
                YRANGE = PRANGE
                IF LME(CTH) EQ 48 THEN YRANGE = [0,2.5]
                IF LME(CTH) EQ 23 THEN YRANGE = [0,5]
                P1 = PLOT(PERIOD_2JD(PDAT.PERIOD),PDAT.(POS1),THICK=2,SYMBOL='CIRCLE',/SYM_FILLED,COLOR='ORANGE',NAME='PP-VGPM (Eppley) '+UNITS('PPD',/NO_NAME),/CURRENT,TITLE=TITLE,MARGIN=MARGIN,XRANGE=AX.JD,YRANGE=YRANGE,XTICKVALUES=AX.TICKV,XTICKNAME=AX.TICKNAME,LAYOUT=LAYOUT,XMINOR=0)
                P2 = PLOT(PERIOD_2JD(PDAT.PERIOD),PDAT.(POS2),THICK=2,SYMBOL='CIRCLE',/SYM_FILLED,COLOR='NAVY',  NAME='PP-OPAL '+UNITS('PPD',/NO_NAME),/OVERPLOT)
                C1 = PLOT(PERIOD_2JD(CDAT.PERIOD),CDAT.(POS3),THICK=2,SYMBOL='CIRCLE',/SYM_FILLED,COLOR='LIME_GREEN',NAME=UNITS('CHLOROPHYLL'),/OVERPLOT)
                IF CTH EQ 0 THEN L = LEGEND(TARGET=[P1,P2,C1],POSITION=[0.01,0.97],/RELATIVE,SHADOW=0,FONT_SIZE=9,HORIZONTAL_ALIGNMENT='LEFT',COLOR='WHITE',THICK=0,/AUTO_TEXT_COLOR,SAMPLE_WIDTH=0.08,VERTICAL_SPACING=0.01)
              ENDFOR
              W.SAVE,PNGFILE,RESOLUTION=300
              W.CLOSE
            ENDFOR
          ENDIF ELSE BEGIN
            PNGFILE = DIR_PLOTS + 'ANNUAL-PP_CHL-FAO.PNG'
            IF GET_MTIME(PNGFILE) LT GET_MTIME(MAX([PFILE,CFILE])) OR KEYWORD_SET(OVERWRITE) THEN BEGIN
              W = WINDOW(DIMENSIONS=[N_ELEMENTS(LME)*100,900])
              FOR CTH=0, N_ELEMENTS(FAO)-1 DO BEGIN
                PDAT = PDATA[WHERE(PDATA.SUBAREA_CODE EQ FAO(CTH))]
                CDAT = CDATA[WHERE(CDATA.SUBAREA_CODE EQ FAO(CTH))]
                LAYOUT = [N_ELEMENTS(FAO)/3,3,CTH+1]
                POS1 = WHERE(PTAGS EQ 'MEAN_' + REPLACE(PP_ALGS[0],'-','_'))
                POS2 = WHERE(PTAGS EQ 'MEAN_' + REPLACE(PP_ALGS[1],'-','_'))
                POS3 = WHERE(CTAGS EQ 'MEAN_' + REPLACE(CH_ALGS[0],'-','_'))
                TITLE = STR_CAP(REPLACE(PDAT[0].SUBAREA_NAME,'_',' '),DELIM=' ',/ALL) + '(FAO)'
                MARGIN = [0.1,0.1,0.1,0.1]
                YRANGE = [0,1.0]
                P1 = PLOT(PERIOD_2JD(PDAT.PERIOD),PDAT.(POS1),THICK=2,SYMBOL='CIRCLE',/SYM_FILLED,COLOR='ORANGE',NAME='PP-VGPM (Eppley) '+UNITS('PPD',/NO_NAME),/CURRENT,TITLE=TITLE,MARGIN=MARGIN,XRANGE=AX.JD,YRANGE=YRANGE,XTICKVALUES=AX.TICKV,XTICKNAME=AX.TICKNAME,LAYOUT=LAYOUT,XMINOR=0)
                P2 = PLOT(PERIOD_2JD(PDAT.PERIOD),PDAT.(POS2),THICK=2,SYMBOL='CIRCLE',/SYM_FILLED,COLOR='NAVY',  NAME='PP-OPAL '+UNITS('PPD',/NO_NAME),/OVERPLOT)
                C1 = PLOT(PERIOD_2JD(CDAT.PERIOD),CDAT.(POS3),THICK=2,SYMBOL='CIRCLE',/SYM_FILLED,COLOR='LIME_GREEN',NAME=UNITS('CHLOROPHYLL'),/OVERPLOT)
                IF CTH EQ 0 THEN L = LEGEND(TARGET=[P1,P2,C1],POSITION=[0.01,0.97],/RELATIVE,SHADOW=0,FONT_SIZE=9,HORIZONTAL_ALIGNMENT='LEFT',COLOR='WHITE',THICK=0,/AUTO_TEXT_COLOR,SAMPLE_WIDTH=0.08,VERTICAL_SPACING=0.01)
              ENDFOR
              W.SAVE,PNGFILE,RESOLUTION=300
              W.CLOSE
            ENDIF
          ENDELSE
        ENDFOR
      ENDFOR
    ENDFOR
  ENDIF ; DO_GLOBAL_PLOTS

  ; *******************************************************
  IF DO_NEC_PLOTS GE 1 THEN BEGIN
    ; *******************************************************
    OVERWRITE = DO_NEC_PLOTS GE 2

    SL = DELIMITER(/PATH)

    DATE_RANGE = DATE_2JD(['19980101','20071231'])
    SUBAREAS = ['ECOREGIONS_FULL_NO_ESTUARIES','ESTUARY_SHELF_LME']
    PDATASET = ['PP-SEAWIFS_PAN-PAT-MLAC']
    CDATASET = ['OC-SEAWIFS-MLAC']
    SUBPER   = ['A_ANNUAL_M_MANNUAL_MONTH']
    PERIODS  = ['MONTH','M_'+NUM2STR(INDGEN(10)+1998),'A_']
    OUTPER   = ['MONTH','M_'+NUM2STR(INDGEN(10)+1998),'A']
    PERSTR   = [5,REPLICATE(6,N_ELEMENTS(PERIODS)-2),2]
    TITLES   = ['NE Shelf','Mid-Atlantic Bight','Georges Bank','Gulf of Maine','Scotian Shelf']
    CODES    = [32,7,5,6,8]
    DATES    = ['Climatology (1998-2007)',NUM2STR(INDGEN(10)+1998),'Annual Mean (1998-2007)']

    PY = [0,100]
    WIDTH = 6

    PFILES = [] & CFILES = []
    FOR S=0, N_ELEMENTS(SUBAREAS)-1 DO PFILES = [PFILES,FILE_SEARCH(!S.DATASETS+PDATASET+SL+'NEC'+SL+'TS_SUBAREAS'+SL+SUBPER+'*MASK_SUBAREA-NEC-PXY_1024_1024-'+SUBAREAS(S)+'*-MULTI_PRODS.SAVE')]
    FOR S=0, N_ELEMENTS(SUBAREAS)-1 DO CFILES = [CFILES,FILE_SEARCH(!S.DATASETS+CDATASET+SL+'NEC'+SL+'TS_SUBAREAS'+SL+SUBPER+'*MASK_SUBAREA-NEC-PXY_1024_1024-'+SUBAREAS(S)+'*-MULTI_PRODS.SAVE')]

    PDATA = IDL_RESTORE(PFILES[0])
    CDATA = IDL_RESTORE(CFILES[0])
    FOR S=1, N_ELEMENTS(PFILES)-1 DO PDATA = STRUCT_CONCAT(PDATA,IDL_RESTORE(PFILES(S)))
    FOR S=1, N_ELEMENTS(CFILES)-1 DO CDATA = STRUCT_CONCAT(CDATA,IDL_RESTORE(CFILES(S)))
    COMBO = STRUCT_JOIN(CDATA, PDATA, TAGNAMES=['PERIOD','PERIOD_CODE','MASK','SUBAREA_CODE','SUBAREA_NAME','N_SUBAREA'])
    TAGS = TAG_NAMES(COMBO)
    CPOSC = WHERE(TAGS EQ 'MEAN_CHLOR_A_PAN')
    DPOSC = WHERE(TAGS EQ 'MEAN_DIATOM_PAN')
    PPOSV = WHERE(TAGS EQ 'MEAN_PPD_VGPM2')
    PPOSO = WHERE(TAGS EQ 'MEAN_PPD_OPAL')
    DPOSV = WHERE(TAGS EQ 'MEAN_MICROPP_MARMAP_PAN_VGPM2')
    DPOSO = WHERE(TAGS EQ 'MEAN_MICROPP_MARMAP_PAN_OPAL')

    FOR PTH =0, N_ELEMENTS(PERIODS)-1 DO BEGIN
      PNGFILE = FIX_PATH(DIR_PLOTS + OUTPER(PTH)+'-NESLME-SIZE_CLASS_PERCENTAGES-WITH_PHYTO.PNG')
      IF GET_MTIME(PNGFILE) GT MIN(GET_MTIME([PFILES,CFILES])) AND NOT KEYWORD_SET(OVERWRITE) THEN CONTINUE
      MDATA = COMBO[WHERE(STRMID(COMBO.PERIOD,0,PERSTR(PTH)) EQ PERIODS(PTH))]
      IF PERIODS(PTH) EQ 'A_' THEN MDATA = MDATA[WHERE(PERIOD_2JD(MDATA.PERIOD) GE DATE_RANGE[0] AND PERIOD_2JD(MDATA.PERIOD) LE DATE_RANGE[1])]
      AX = DATE_AXIS([20200101,20201431],/MONTH,/MID,/FYEAR)
      XRANGE = DATE_2JD([20200101,20201431])

      IF PERIODS(PTH) EQ 'A_' THEN BEGIN
        AX = DATE_AXIS([19980101,20070101],/YEAR,/YY)
        XRANGE = DATE_2JD([19980101,20070107])
      ENDIF

      W = WINDOW(DIMENSIONS=[1750,1300])
      D = TEXT(0.5,0.98,DATES(PTH),FONT_SIZE=14,ALIGNMENT=0.5)
      COUNTER = 1
      YPOS  = [0.95,0.77,0.59,0.41,0.23]
      YDIF  = 0.14
      XDIF  = 0.18
      XPOS0 = 0.04
      XPOS1 = 0.285
      XPOS2 = 0.53
      XPOS3 = 0.775
      FOR N=0, N_ELEMENTS(CODES)-1 DO BEGIN
        LAYOUT = [3,5,COUNTER]
        ADATA = MDATA[WHERE(MDATA.SUBAREA_CODE EQ CODES(N) AND MDATA.(WHERE(TAGS EQ 'FIRST_NAME_CHLOR_A_PAN')) NE '')] & ADATA = ADATA[SORT(DATE_2DOY(PERIOD_2DATE(ADATA.PERIOD)))]
        VDATA = MDATA[WHERE(MDATA.SUBAREA_CODE EQ CODES(N) AND MDATA.(WHERE(TAGS EQ 'FIRST_NAME_PPD_VGPM2')) NE '')]   & VDATA = VDATA[SORT(DATE_2DOY(PERIOD_2DATE(VDATA.PERIOD)))]
        ODATA = MDATA[WHERE(MDATA.SUBAREA_CODE EQ CODES(N) AND MDATA.(WHERE(TAGS EQ 'FIRST_NAME_PPD_OPAL')) NE '')]    & ODATA = ODATA[SORT(DATE_2DOY(PERIOD_2DATE(ODATA.PERIOD)))]

        XDATES = JD_ADD(YDOY_2JD('2020',DATE_2DOY(PERIOD_2DATE(ADATA.PERIOD))),14,/DAY)
        IF PERIODS(PTH) EQ 'A_' THEN XDATES = PERIOD_2JD(ADATA.PERIOD)

        DGROUPS = ['DIATOM', 'DINOFLAGELLATE','BROWN',            'GREEN',            'CRYPTOPHYTE','PICO']
        DCOLORS = ['CRIMSON','BLUE',   'ORANGE','MEDIUM_AQUAMARINE','YELLOW',    'AQUA']
        LGD     = ['Diatoms','Dinoflagellates','Brown Algae','Green Algae','Cryptophytes','Picoplankton']
        CGROUPS = ['MICRO','NANO','PICO']
        CCOLORS = ['YELLOW','MEDIUM_BLUE','ORANGE_RED']
        PGROUPS = ['MICRO','NANOPICO']
        PCOLORS = ['YELLOW','MEDIUM_AQUAMARINE']
        MARGIN  = [0.15,0.15,0.15,0.2]
        IF PERIODS(PTH) EQ 'A_' THEN CYRANGE = [0.2,0.8] ELSE CYRANGE = [0,1.2]
        IF PERIODS(PTH) EQ 'A_' THEN PYRANGE = [0.0,0.8] ELSE PYRANGE = [0,1.2]

        BOTTOM = 0
        PER1 = REPLICATE(0,N_ELEMENTS(XDATES))
        TOT = ADATA.(CPOSC)
        DIATOM = ADATA.(DPOSC)
        FOR NTH = 0L, N_ELEMENTS(DGROUPS)-1 DO BEGIN
          GROUP = DGROUPS[NTH]
          POS = WHERE(TAGS EQ 'MEAN_' + GROUP + '_PERCENTAGE_PAN')
          PER = ADATA.(POS)
          OK = WHERE(PER EQ MISSINGS(PER),COUNT) & IF COUNT GE 1 THEN PER[OK] = 0.0
          IF NTH EQ 0 THEN BEGIN
            IF N EQ 0 THEN TITLE = 'Chlorophyll !8a!N!X!C'+TITLES(N) ELSE TITLE = TITLES(N)
            POSITION = [XPOS0,YPOS(N)-YDIF,XPOS0+XDIF,YPOS(N)]
            P = PLOT(XDATES,REPLICATE(0,N_ELEMENTS(ADATA)),YTITLE='Composition (%)',XTICKVALUE=AX.TICKV,FONT_SIZE=11,TITLE=TITLE,POSITION=POSITION,$
              XMINOR=0,YRANGE=[0,100],AXIS_STYLE=1,XSTYLE=1,XTICKNAME=AX.TICKNAME,/NODATA,BUFFER=BUFFER,MARGIN=MARGIN,LAYOUT=LAYOUT,/CURRENT)
            BOT = REPLICATE(0, N_ELEMENTS(ADATA))
            YY = [PER,BOT]
            XX = [XDATES,REVERSE(XDATES)]
            POLY = POLYGON(XX,YY,FILL_COLOR=DCOLORS[NTH],/FILL_BACKGROUND,TARGET=P,/DATA,LINESTYLE=6)
          ENDIF
          PER1 = PER + PER1
          YY = [PER1,REVERSE(BOTTOM)]
          XX = [XDATES,REVERSE(XDATES)]
          IF NTH GE 1 THEN POLY = POLYGON(XX,YY,FILL_COLOR=DCOLORS[NTH],/FILL_BACKGROUND,TARGET=P,/DATA,LINESTYLE=6)
          BOTTOM = PER1
        ENDFOR
        P2 = PLOT(XDATES,TOT,COLOR='GREY',/CURRENT,AXIS_STYLE=0,XTICKVALUE=AX.TICKV,XRANGE=P.XRANGE,YRANGE=CYRANGE,MARGIN=MARGIN,THICK=3,LINESTYLE=0,LAYOUT=LAYOUT,POSITION=POSITION)
        PD = PLOT(XDATES,DIATOM,COLOR='GREY',/CURRENT,AXIS_STYLE=0,XTICKVALUE=AX.TICKV,XRANGE=P.XRANGE,YRANGE=CYRANGE,MARGIN=MARGIN,THICK=3,LINESTYLE=2,LAYOUT=LAYOUT,POSITION=POSITION)
        A1 = AXIS('Y',TARGET=P2,LOCATION=[MAX(P.XRANGE),0,0],TEXTPOS=1,MINOR=2,TICKFONT_SIZE=11,TEXT_COLOR='BLACK',TICKDIR=1,TITLE=UNITS('CHLOR_A',/NO_NAME),TICKLEN=0.05,YRANGE=CYRANGE) ;AXIS,YAXIS=1,YRANGE=[0,300],/SAVE, YTITLE=YTITLE2,CHARSIZE=CHARSIZE,COLOR=0
        A2 = AXIS('X',TARGET=P,LOCATION=[MIN(P.XRANGE),100,0],MAJOR=0,MINOR=0,COLOR='BLACK')

        BOTTOM = 0
        PER1 = REPLICATE(0,N_ELEMENTS(XDATES))
        TOT = ADATA.(CPOSC)
        FOR NTH = 0L, N_ELEMENTS(CGROUPS)-1 DO BEGIN
          GROUP = CGROUPS[NTH]
          POS = WHERE(TAGS EQ 'MEAN_' + GROUP + '_PERCENTAGE_PAN')
          PER = ADATA.(POS)
          OK = WHERE(PER EQ MISSINGS(PER),COUNT) & IF COUNT GE 1 THEN PER[OK] = 0.0
          IF NTH EQ 0 THEN BEGIN
            IF N EQ 0 THEN TITLE = 'Chlorophyll !8a!N!X!C'+TITLES(N) ELSE TITLE = TITLES(N)
            POSITION = [XPOS1,YPOS(N)-YDIF,XPOS1+XDIF,YPOS(N)]
            P = PLOT(XDATES,REPLICATE(0,N_ELEMENTS(ADATA)),YTITLE='Composition (%)',XTICKVALUE=AX.TICKV,FONT_SIZE=11,TITLE=TITLE,POSITION=POSITION,$
              XMINOR=0,YRANGE=[0,100],AXIS_STYLE=1,XSTYLE=1,XTICKNAME=AX.TICKNAME,/NODATA,BUFFER=BUFFER,MARGIN=MARGIN,LAYOUT=LAYOUT,/CURRENT)
            BOT = REPLICATE(0, N_ELEMENTS(ADATA))
            YY = [PER,BOT]
            XX = [XDATES,REVERSE(XDATES)]
            POLY = POLYGON(XX,YY,FILL_COLOR=CCOLORS[NTH],/FILL_BACKGROUND,TARGET=P,/DATA,LINESTYLE=6)
          ENDIF
          PER1 = PER + PER1
          YY = [PER1,REVERSE(BOTTOM)]
          XX = [XDATES,REVERSE(XDATES)]
          IF NTH GE 1 THEN POLY = POLYGON(XX,YY,FILL_COLOR=CCOLORS[NTH],/FILL_BACKGROUND,TARGET=P,/DATA,LINESTYLE=6)
          BOTTOM = PER1
        ENDFOR
        P2 = PLOT(XDATES,TOT,COLOR='GREY',/CURRENT,AXIS_STYLE=0,XTICKVALUE=AX.TICKV,XRANGE=P.XRANGE,YRANGE=CYRANGE,MARGIN=MARGIN,THICK=3,LINESTYLE=0,LAYOUT=LAYOUT,POSITION=POSITION)
        PD = PLOT(XDATES,DIATOM,COLOR='GREY',/CURRENT,AXIS_STYLE=0,XTICKVALUE=AX.TICKV,XRANGE=P.XRANGE,YRANGE=CYRANGE,MARGIN=MARGIN,THICK=3,LINESTYLE=2,LAYOUT=LAYOUT,POSITION=POSITION)
        A1 = AXIS('Y',TARGET=P2,LOCATION=[MAX(P.XRANGE),0,0],TEXTPOS=1,MINOR=2,TICKFONT_SIZE=11,TEXT_COLOR='BLACK',TICKDIR=1,TITLE=UNITS('CHLOR_A',/NO_NAME),TICKLEN=0.05,YRANGE=CYRANGE) ;AXIS,YAXIS=1,YRANGE=[0,300],/SAVE, YTITLE=YTITLE2,CHARSIZE=CHARSIZE,COLOR=0
        A2 = AXIS('X',TARGET=P,LOCATION=[MIN(P.XRANGE),100,0],MAJOR=0,MINOR=0,COLOR='BLACK')

        XDATES = JD_ADD(YDOY_2JD('2020',DATE_2DOY(PERIOD_2DATE(VDATA.PERIOD))),14,/DAY)
        IF PERIODS(PTH) EQ 'A_' THEN XDATES = PERIOD_2JD(VDATA.PERIOD)
        BOTTOM = 0
        COUNTER = COUNTER + 1
        LAYOUT = [3,5,COUNTER]
        TOT = VDATA.(PPOSV)
        DIATOM = VDATA.(DPOSV)
        PER1 = REPLICATE(0,N_ELEMENTS(XDATES))
        FOR NTH = 0L, N_ELEMENTS(PGROUPS)-1 DO BEGIN
          GROUP = PGROUPS[NTH]
          POS = WHERE(TAGS EQ 'MEAN_PPD_' + GROUP + '_PERCENTAGE_MARMAP_PAN_VGPM2')
          PER = VDATA.(POS)
          OK = WHERE(PER EQ MISSINGS(PER),COUNT) & IF COUNT GE 1 THEN PER[OK] = 0.0
          IF NTH EQ 0 THEN BEGIN
            IF N EQ 0 THEN TITLE = 'Primary Production (VGPM-Eppley)!C'+TITLES(N) ELSE TITLE = TITLES(N)
            POSITION = [XPOS2,YPOS(N)-YDIF,XPOS2+XDIF,YPOS(N)]
            P = PLOT(XDATES,REPLICATE(0,N_ELEMENTS(VDATA)),YTITLE='Composition (%)',XTICKVALUE=AX.TICKV,FONT_SIZE=11,TITLE=TITLE,POSITION=POSITION,$
              XMINOR=0,YRANGE=[0,100],AXIS_STYLE=1,XSTYLE=1,XTICKNAME=AX.TICKNAME,/NODATA,BUFFER=BUFFER,MARGIN=MARGIN,LAYOUT=LAYOUT,/CURRENT)
            BOT = REPLICATE(0, N_ELEMENTS(VDATA))
            YY = [PER,BOT]
            XX = [XDATES,REVERSE(XDATES)]
            POLY = POLYGON(XX,YY,FILL_COLOR=PCOLORS[NTH],/FILL_BACKGROUND,TARGET=P,/DATA,LINESTYLE=6)
          ENDIF
          PER1 = PER + PER1
          YY = [PER1,REVERSE(BOTTOM)]
          XX = [XDATES,REVERSE(XDATES)]
          IF NTH GE 1 THEN POLY = POLYGON(XX,YY,FILL_COLOR=PCOLORS[NTH],/FILL_BACKGROUND,TARGET=P,/DATA,LINESTYLE=6)
          BOTTOM = PER1
        ENDFOR
        P2 = PLOT(XDATES,TOT,COLOR='GREY',/CURRENT,AXIS_STYLE=0,XTICKVALUE=AX.TICKV,XRANGE=P.XRANGE,MARGIN=MARGIN,THICK=3,LINESTYLE=0,LAYOUT=LAYOUT,POSITION=POSITION,YRANGE=PYRANGE)
        PD = PLOT(XDATES,DIATOM,COLOR='GREY',/CURRENT,AXIS_STYLE=0,XTICKVALUE=AX.TICKV,XRANGE=P.XRANGE,YRANGE=PYRANGE,MARGIN=MARGIN,THICK=3,LINESTYLE=2,LAYOUT=LAYOUT,POSITION=POSITION)
        A1 = AXIS('Y',TARGET=P2,LOCATION=[MAX(P.XRANGE),0,0],TEXTPOS=1,MINOR=2,TICKFONT_SIZE=11,TEXT_COLOR='BLACK',TICKDIR=1,TITLE=UNITS('PPD',/NO_NAME),TICKLEN=0.05,YRANGE=PYRANGE) ;AXIS,YAXIS=1,YRANGE=[0,300],/SAVE, YTITLE=YTITLE2,CHARSIZE=CHARSIZE,COLOR=0
        A2 = AXIS('X',TARGET=P,LOCATION=[MIN(P.XRANGE),100,0],MAJOR=0,MINOR=0,COLOR='BLACK')

        COUNTER = COUNTER + 1
        LAYOUT = [3,5,COUNTER]
        XDATES = JD_ADD(YDOY_2JD('2020',DATE_2DOY(PERIOD_2DATE(ODATA.PERIOD))),14,/DAY)
        IF PERIODS(PTH) EQ 'A_' THEN XDATES = PERIOD_2JD(ODATA.PERIOD)
        BOTTOM = 0
        TOT = ODATA.(PPOSV)
        DIATOM = ODATA.(DPOSV)
        PER1 = REPLICATE(0,N_ELEMENTS(XDATES))
        FOR NTH = 0L, N_ELEMENTS(PGROUPS)-1 DO BEGIN
          GROUP = PGROUPS[NTH]
          POS = WHERE(TAGS EQ 'MEAN_PPD_' + GROUP + '_PERCENTAGE_MARMAP_PAN_VGPM2')
          PER = ODATA.(POS)
          OK = WHERE(PER EQ MISSINGS(PER),COUNT) & IF COUNT GE 1 THEN PER[OK] = 0.0
          IF NTH EQ 0 THEN BEGIN
            IF N EQ 0 THEN TITLE = 'Primary Production (OPAL)!C'+TITLES(N) ELSE TITLE = TITLES(N)
            POSITION = [XPOS3,YPOS(N)-YDIF,XPOS3+XDIF,YPOS(N)]
            P = BARPLOT(XDATES,REPLICATE(0,N_ELEMENTS(ODATA)),YTITLE='Composition (%)',XTICKVALUE=AX.TICKV,FONT_SIZE=11,TITLE=TITLE,POSITION=POSITION,$
              XMINOR=0,YRANGE=[0,100],AXIS_STYLE=1,XSTYLE=1,XTICKNAME=AX.TICKNAME,/NODATA,BUFFER=BUFFER,MARGIN=MARGIN,LAYOUT=LAYOUT,/CURRENT)
            BOT = REPLICATE(0, N_ELEMENTS(ODATA))
            YY = [PER,BOT]
            XX = [XDATES,REVERSE(XDATES)]
            POLY = POLYGON(XX,YY,FILL_COLOR=PCOLORS[NTH],/FILL_BACKGROUND,TARGET=P,/DATA,LINESTYLE=6)
          ENDIF
          PER1 = PER + PER1
          YY = [PER1,REVERSE(BOTTOM)]
          XX = [XDATES,REVERSE(XDATES)]
          IF NTH GE 1 THEN POLY = POLYGON(XX,YY,FILL_COLOR=PCOLORS[NTH],/FILL_BACKGROUND,TARGET=P,/DATA,LINESTYLE=6)
          BOTTOM = PER1
        ENDFOR
      ENDFOR

      XPOS = [0.035,0.085,0.17,0.035,0.1,0.17]
      YPOS = 0.06 & YPOS2 = 0.04
      FOR SY=0, 2 DO S = SYMBOL(XPOS(SY),YPOS,'SQUARE',SYM_SIZE=1.5,SYM_COLOR='WHITE',SYM_FILL_COLOR=DCOLORS(SY),/SYM_FILLED,LABEL_STRING=LGD(SY),LABEL_FONT_SIZE=12,LABEL_POSITION='R',/NORMAL)
      FOR SY=3, N_ELEMENTS(LGD)-1 DO S = SYMBOL(XPOS(SY),YPOS2,'SQUARE',SYM_SIZE=1.5,SYM_COLOR='WHITE',SYM_FILL_COLOR=DCOLORS(SY),/SYM_FILLED,LABEL_STRING=LGD(SY),LABEL_FONT_SIZE=12,LABEL_POSITION='R',/NORMAL)

      LGD = ['Microplankton','Nanoplankton','Picoplankton']
      LGCOLORS = ['YELLOW','MEDIUM_BLUE','ORANGE_RED']
      XPOS = [0.3,0.39,0.345]
      FOR SY=0, N_ELEMENTS(LGD)-2 DO S = SYMBOL(XPOS(SY),YPOS,'SQUARE',SYM_SIZE=1.5,SYM_COLOR='WHITE',SYM_FILL_COLOR=LGCOLORS(SY),/SYM_FILLED,LABEL_STRING=LGD(SY),LABEL_FONT_SIZE=12,LABEL_POSITION='R',/NORMAL)
      S = SYMBOL(XPOS(2),YPOS2,'SQUARE',SYM_SIZE=1.5,SYM_COLOR='WHITE',SYM_FILL_COLOR=LGCOLORS(2),/SYM_FILLED,LABEL_STRING=LGD(2),LABEL_FONT_SIZE=12,LABEL_POSITION='R',/NORMAL)

      LGD = ['Microplankton','Nano+Picoplankton']
      LGCOLORS = ['YELLOW','MEDIUM_AQUAMARINE']
      XPOS = [0.535,0.615]
      FOR SY=0, N_ELEMENTS(LGD)-1 DO S = SYMBOL(XPOS(SY),YPOS,'SQUARE',SYM_SIZE=1.5,SYM_COLOR='WHITE',SYM_FILL_COLOR=LGCOLORS(SY),/SYM_FILLED,LABEL_STRING=LGD(SY),LABEL_FONT_SIZE=12,LABEL_POSITION='R',/NORMAL)
      XPOS = [0.78,0.860]
      FOR SY=0,N_ELEMENTS(LGD)-1 DO S = SYMBOL(XPOS(SY),YPOS,'SQUARE',SYM_SIZE=1.5,SYM_COLOR='WHITE',SYM_FILL_COLOR=LGCOLORS(SY),/SYM_FILLED,LABEL_STRING=LGD(SY),LABEL_FONT_SIZE=12,LABEL_POSITION='R',/NORMAL)


      ;      LGD = ['Microplankton','Nanoplankton','Picoplankton','Nano+Picoplankton']
      ;      LGCOLORS = ['YELLOW','MEDIUM_BLUE','ORANGE_RED','MEDIUM_AQUAMARINE']
      ;      XPOS = [0.31,0.41,0.51,0.61]
      ;      YPOS = 0.03
      ;      FOR SY=0, N_ELEMENTS(LGD)-1 DO S = SYMBOL(XPOS(SY),YPOS,'SQUARE',SYM_SIZE=1.5,SYM_COLOR='WHITE',SYM_FILL_COLOR=LGCOLORS(SY),/SYM_FILLED,LABEL_STRING=LGD(SY),LABEL_FONT_SIZE=12,LABEL_POSITION='R',/NORMAL)

      W.SAVE, PNGFILE, RESOLUTION=300, BIT_DEPTH=2
      W.CLOSE
    ENDFOR
    STOP


  ENDIF ; DO_NEC_PLOTS


  ; *******************************************************
  IF DO_PHYTO_PLOTS GE 1 THEN BEGIN
    ; *******************************************************
    OVERWRITE = DO_PHYTO_PLOTS GE 2

    SL = DELIMITER(/PATH)

    DATE_RANGE = DATE_2JD(['19970901','20071231'])
    SUBAREAS = ['ECOREGIONS_FULL_NO_ESTUARIES','ESTUARY_SHELF_LME']
    CDATASET = ['OC-SEAWIFS-MLAC']
    SUBPER   = ['A_ANNUAL_M_MANNUAL_MONTH']
    PERIODS  = ['MONTH','M_'+NUM2STR(INDGEN(10)+1998),'A_']
    OUTPER   = ['MONTH','M_'+NUM2STR(INDGEN(10)+1998),'A']
    PERSTR   = [5,REPLICATE(6,N_ELEMENTS(PERIODS)-2),2]
    TITLES   = ['NE Shelf','Mid-Atlantic Bight','Georges Bank','Gulf of Maine','Scotian Shelf']
    CODES    = [32,7,5,6,8]
    DATES    = ['Climatology (1998-2007)',NUM2STR(INDGEN(10)+1998),'Annual Mean (1998-2007)']

    PY = [0,100]
    WIDTH = 6
    CFILES = []
    FOR S=0, N_ELEMENTS(SUBAREAS)-1 DO CFILES = [CFILES,FILE_SEARCH(!S.DATASETS+CDATASET+SL+'NEC'+SL+'TS_SUBAREAS'+SL+SUBPER+'*MASK_SUBAREA-NEC-PXY_1024_1024-'+SUBAREAS(S)+'*-MULTI_PRODS.SAVE')]

    CDATA = IDL_RESTORE(CFILES[0])
    FOR S=1, N_ELEMENTS(CFILES)-1 DO CDATA = STRUCT_CONCAT(CDATA,IDL_RESTORE(CFILES(S)))
    CDATA = CDATA[WHERE(PERIOD_2JD(CDATA.PERIOD) GE DATE_RANGE[0] AND PERIOD_2JD(CDATA.PERIOD) LE DATE_RANGE[1])]
    TAGS = TAG_NAMES(CDATA)
    POSC = WHERE(TAGS EQ 'MEAN_CHLOR_A_PAN')
    POSM = WHERE(TAGS EQ 'MEAN_MICRO_PERCENTAGE_PAN')
    POSN = WHERE(TAGS EQ 'MEAN_NANO_PERCENTAGE_PAN')

    FOR PTH =0, N_ELEMENTS(PERIODS)-1 DO BEGIN
      PNGFILE = FIX_PATH(DIR_PLOTS + OUTPER(PTH)+'-NESLME-SIZE_CLASS_PERCENTAGES_WITH_BARPLOTS.PNG')
      IF GET_MTIME(PNGFILE) GT MIN(GET_MTIME(CFILES)) AND NOT KEYWORD_SET(OVERWRITE) THEN CONTINUE
      MDATA = CDATA[WHERE(STRMID(CDATA.PERIOD,0,PERSTR(PTH)) EQ PERIODS(PTH))]
      AX = DATE_AXIS([20200101,20201431],/MONTH,/MID,/FYEAR)
      XRANGE = DATE_2JD([20200101,20201431])

      IF PERIODS(PTH) EQ 'A_' THEN BEGIN
        AX = DATE_AXIS([19980101,20070101],/YEAR,/YY)
        XRANGE = DATE_2JD([19980101,20070107])
      ENDIF

      W = WINDOW(DIMENSIONS=[1000,1300])
      D = TEXT(0.5,0.97,DATES(PTH),FONT_SIZE=14,ALIGNMENT=0.5)
      COUNTER = 1
      YPOS = [0.93,0.75,0.57,0.39,0.21]
      YDIF = 0.14
      XDIF = 0.39
      XPOS1 = 0.06
      XPOS2 = 0.57
      FOR N=0, N_ELEMENTS(CODES)-1 DO BEGIN
        ADATA = MDATA[WHERE(MDATA.SUBAREA_CODE EQ CODES(N) AND MDATA.(WHERE(TAGS EQ 'FIRST_NAME_CHLOR_A_PAN')) NE '')] & ADATA = ADATA[SORT(DATE_2DOY(PERIOD_2DATE(ADATA.PERIOD)))]
        XDATES = JD_ADD(YDOY_2JD('2020',DATE_2DOY(PERIOD_2DATE(ADATA.PERIOD))),14,/DAY)
        IF PERIODS(PTH) EQ 'A_' THEN XDATES = PERIOD_2JD(ADATA.PERIOD)
        CGROUPS = ['DIATOM', 'DINOFLAGELLATE','BROWN',      'GREEN',       'CRYPTOPHYTE','PICO']
        BGROUPS = ['DIATOM', 'DINOFLAGELLATE','BROWN_ALGAE','GREEN_ALGAE', 'CRYPTOPHYTE','PICO']
        CCOLORS = ['CRIMSON','AQUA',          'ORANGE',     'BLUE',        'YELLOW',     'MEDIUM_AQUAMARINE']
        LGD     = ['Diatoms','Dinoflagellates','Brown Algae','Green Algae','Cryptophytes','Picoplankton']
        MARGIN  = [0.15,0.15,0.15,0.2]
        CYRANGE = [0,2.0]
        BOTTOM = 0
        PER1 = REPLICATE(0,N_ELEMENTS(XDATES))
        TOT = ADATA.(POSC)
        MICRO = ADATA.(POSM)
        NANO = ADATA.(POSN) + ADATA.(POSM)
        FOR NTH = 0L, N_ELEMENTS(CGROUPS)-1 DO BEGIN
          GROUP = CGROUPS[NTH]
          POS = WHERE(TAGS EQ 'MEAN_' + GROUP + '_PERCENTAGE_PAN')
          PER = ADATA.(POS)
          OK = WHERE(PER EQ MISSINGS(PER),COUNT) & IF COUNT GE 1 THEN PER[OK] = 0.0
          IF NTH EQ 0 THEN BEGIN
            IF N EQ 0 THEN TITLE = 'Percent Phytoplankton Composition!C'+TITLES(N) ELSE TITLE = TITLES(N)
            POSITION = [XPOS1,YPOS(N)-YDIF,XPOS1+XDIF,YPOS(N)]
            P = PLOT(XDATES,REPLICATE(0,N_ELEMENTS(ADATA)),YTITLE='Composition (%)',XTICKVALUE=AX.TICKV,FONT_SIZE=11,TITLE=TITLE,POSITION=POSITION,$
              XMINOR=0,YRANGE=[0,100],AXIS_STYLE=1,XSTYLE=1,XTICKNAME=AX.TICKNAME,/NODATA,BUFFER=BUFFER,MARGIN=MARGIN,LAYOUT=LAYOUT,/CURRENT)
            BOT = REPLICATE(0, N_ELEMENTS(ADATA))
            YY = [PER,BOT]
            XX = [XDATES,REVERSE(XDATES)]
            POLY = POLYGON(XX,YY,FILL_COLOR=CCOLORS[NTH],/FILL_BACKGROUND,TARGET=P,/DATA,LINESTYLE=6)
          ENDIF
          PER1 = PER + PER1
          YY = [PER1,REVERSE(BOTTOM)]
          XX = [XDATES,REVERSE(XDATES)]
          IF NTH GE 1 THEN POLY = POLYGON(XX,YY,FILL_COLOR=CCOLORS[NTH],/FILL_BACKGROUND,TARGET=P,/DATA,LINESTYLE=6)
          BOTTOM = PER1
        ENDFOR
        PM = PLOT(XDATES,MICRO,COLOR='BLACK',/CURRENT,/OVERPLOT,THICK=3,LINESTYLE=0,AXIS_STYLE=1)
        PN = PLOT(XDATES,NANO, COLOR='BLACK',/CURRENT,/OVERPLOT,THICK=3,LINESTYLE=0,AXIS_STYLE=1)

        P2 = PLOT(XDATES,TOT,COLOR='GREY',/CURRENT,AXIS_STYLE=0,XTICKVALUE=AX.TICKV,XRANGE=P.XRANGE,YRANGE=CYRANGE,MARGIN=MARGIN,THICK=3,LINESTYLE=2,LAYOUT=LAYOUT,POSITION=POSITION)
        A1 = AXIS('Y',TARGET=P2,LOCATION=[MAX(P.XRANGE),0,0],TEXTPOS=1,MINOR=2,TICKFONT_SIZE=11,TEXT_COLOR='BLACK',TICKDIR=1,TITLE=UNITS('CHLOR_A',/NO_NAME),TICKLEN=0.05,YRANGE=CYRANGE) ;AXIS,YAXIS=1,YRANGE=[0,300],/SAVE, YTITLE=YTITLE2,CHARSIZE=CHARSIZE,COLOR=0
        A2 = AXIS('X',TARGET=P,LOCATION=[MIN(P.XRANGE),100,0],MAJOR=0,MINOR=0,COLOR='BLACK')

        BOTTOM = 0
        PER1 = REPLICATE(0,N_ELEMENTS(XDATES))
        TOT = ADATA.(POSC)
        MICRO = ADATA.(POSM)
        NANO = ADATA.(POSN) + ADATA.(POSM)
        FOR NTH = 0L, N_ELEMENTS(BGROUPS)-1 DO BEGIN
          GROUP = BGROUPS[NTH]
          POS = WHERE(TAGS EQ 'MEAN_' + GROUP + '_PAN')
          PER = ADATA.(POS)
          OK = WHERE(PER EQ MISSINGS(PER),COUNT) & IF COUNT GE 1 THEN PER[OK] = 0.0
          IF NTH EQ 0 THEN BEGIN
            IF N EQ 0 THEN TITLE = 'Phytoplankton Chlorophyll !8a!N!X!C'+TITLES(N) ELSE TITLE = TITLES(N)
            POSITION = [XPOS2,YPOS(N)-YDIF,XPOS2+XDIF,YPOS(N)]
            P = PLOT(XDATES,REPLICATE(0,N_ELEMENTS(ADATA)),YTITLE=UNITS('CHLOROPHYLL'),XTICKVALUE=AX.TICKV,FONT_SIZE=11,TITLE=TITLE,POSITION=POSITION,$
              XMINOR=0,YMINOR=2,YRANGE=CYRANGE,XSTYLE=1,XTICKNAME=AX.TICKNAME,/NODATA,BUFFER=BUFFER,MARGIN=MARGIN,LAYOUT=LAYOUT,/CURRENT)
            BOT = REPLICATE(0, N_ELEMENTS(ADATA))
            BAR = BARPLOT(XDATES,PER,BOTTOM_VALUES=BOT,FILL_COLOR=CCOLORS[NTH],LINESTYLE=6,/OVERPLOT)
          ENDIF
          PER1 = PER + PER1
          IF NTH GE 1 THEN BAR = BARPLOT(XDATES,PER1,BOTTOM_VALUES=BOTTOM,FILL_COLOR=CCOLORS[NTH],LINESTYLE=6,/OVERPLOT)
          BOTTOM = PER1
        ENDFOR
      ENDFOR

      XPOS = [.17,.26,.39,.51,.62,.74]
      YPOS = 0.028
      FOR SY=0, N_ELEMENTS(XPOS)-1 DO S = SYMBOL(XPOS(SY),YPOS,'SQUARE',SYM_SIZE=1.5,SYM_COLOR='WHITE',SYM_FILL_COLOR=CCOLORS(SY),/SYM_FILLED,LABEL_STRING=LGD(SY),LABEL_FONT_SIZE=12,LABEL_POSITION='R',/NORMAL)
      ;      YPOS = 0.015
      ;      FOR SY=3, N_ELEMENTS(LGD)-1 DO S = SYMBOL(XPOS(SY),YPOS,'SQUARE',SYM_SIZE=1.5,SYM_COLOR='WHITE',SYM_FILL_COLOR=CCOLORS(SY),/SYM_FILLED,LABEL_STRING=LGD(SY),LABEL_FONT_SIZE=12,LABEL_POSITION='R',/NORMAL)
      W.SAVE, PNGFILE, RESOLUTION=300, BIT_DEPTH=2
      W.CLOSE
    ENDFOR
    STOP


  ENDIF ; DO_PHYTO_PLOTS


  ; *******************************************************
  IF DO_PP_SIZE_PLOTS GE 1 THEN BEGIN
    ; *******************************************************
    OVERWRITE = DO_PP_SIZE_PLOTS GE 2

    SL = DELIMITER(/PATH)
    BUFFER = 0

    DATE_RANGE = DATE_2JD(['19970901','20071231'])
    SUBAREAS = ['LME','FAO','GLOBAL']
    CDATASET = ['PP-SEAWIFS-PAT-9']
    SUBPER   = ['A_ANNUAL_MANNUAL_MONTH']
    PERIODS  = ['MONTH','A_']
    OUTPER   = ['MONTH','A']
    PERSTR   = [5,2]
    TITLES   = ['LME_','FAO_','GLOBAL_']
    CODES    = []
    DATES    = ['Climatology (1998-2007)',NUM2STR(INDGEN(10)+1998),'Annual Mean (1998-2007)']

    PY = [0,100]
    WIDTH = 6
    CFILES = []
    FOR S=0, N_ELEMENTS(SUBAREAS)-1 DO CFILES = [CFILES,FILE_SEARCH(!S.DATASETS+CDATASET+SL+'GEQ'+SL+'TS_SUBAREAS'+SL+SUBPER+'*MASK_SUBAREA-GEQ-*'+SUBAREAS(S)+'*-MULTI_PRODS.SAVE')]

    CDATA = IDL_RESTORE(CFILES[0])
    FOR S=1, N_ELEMENTS(CFILES)-1 DO CDATA = STRUCT_CONCAT(CDATA,IDL_RESTORE(CFILES(S)))
    CDATA = CDATA[WHERE(PERIOD_2JD(CDATA.PERIOD) GE DATE_RANGE[0] AND PERIOD_2JD(CDATA.PERIOD) LE DATE_RANGE[1])]
    FOR S=0, N_ELEMENTS(SUBAREAS)-1 DO BEGIN
      OK = WHERE(STRPOS(CDATA.MASK,SUBAREAS(S)) GE 0)
      CDATA[OK].MASK = SUBAREAS(S)
    ENDFOR

    TAGS = TAG_NAMES(CDATA)
    MPOSV = WHERE(TAGS EQ 'MEAN_MICROPP_MARMAP_PAN_VGPM2')
    MPOSO = WHERE(TAGS EQ 'MEAN_MICROPP_MARMAP_PAN_OPAL')
    NPOSV = WHERE(TAGS EQ 'MEAN_NANOPICOPP_MARMAP_PAN_VGPM2')
    NPOSO = WHERE(TAGS EQ 'MEAN_NANOPICOPP_MARMAP_PAN_OPAL')

    AXX = DATE_AXIS([20200101,20201431],/MONTH,/MID,/FYEAR)
    XXRANGE = DATE_2JD([20200101,20201431])
    AXY = DATE_AXIS([19980101,20070101],/YEAR,/YY)
    XYRANGE = DATE_2JD([19980101,20070107])
    PGROUPS = ['MICRO','NANOPICO']
    PCOLORS = ['YELLOW','MEDIUM_AQUAMARINE']
    MARGIN  = [0.15,0.15,0.15,0.2]
    PYRANGE = [0,1.2]
    BSETS = WHERE_SETS(CDATA.MASK + '_' + NUM2STR(CDATA.SUBAREA_CODE))
    FOR BTH = 0L, N_ELEMENTS(BSETS)-1 DO BEGIN
      SUBS = WHERE_SETS_SUBS(BSETS(BTH))
      SDATA = CDATA(SUBS)

      PNGFILE = FIX_PATH(DIR_PLOTS + BSETS(BTH).VALUE+'-SIZE_CLASS_PERCENTAGES.PNG')
      IF GET_MTIME(PNGFILE) GT MIN(GET_MTIME(CFILES)) AND NOT KEYWORD_SET(OVERWRITE) THEN CONTINUE
      W = WINDOW(DIMENSIONS=[1024,1024],BUFFER=BUFFER)
      D = TEXT(0.5,0.97,BSETS(BTH).VALUE + ' ' + SDATA[0].SUBAREA_NAME,FONT_SIZE=14,ALIGNMENT=0.5)
      COUNTER = 1
      XPOS = [0.08,0.55]
      YPOS = [0.53, 0.08]
      YDIF = 0.4
      XDIF = 0.35


      FOR PTH=0, N_ELEMENTS(PERIODS)-1 DO BEGIN
        VDATA = SDATA[WHERE(STRMID(SDATA.PERIOD,0,PERSTR(PTH)) EQ PERIODS(PTH))]
        VDATA = VDATA[SORT(DATE_2DOY(PERIOD_2DATE(VDATA.PERIOD)))]
        XDATES = JD_ADD(YDOY_2JD('2020',DATE_2DOY(PERIOD_2DATE(VDATA.PERIOD))),14,/DAY)

        IF PERIODS(PTH) EQ 'A_' THEN XDATES = PERIOD_2JD(VDATA.PERIOD)
        IF PERIODS(PTH) EQ 'A_' THEN AX = AXY ELSE AX = AXX
        BOTTOM = 0
        COUNTER = COUNTER + 1
        TOT = VDATA.MEAN_MICROPP_MARMAP_PAN_VGPM2 + VDATA.MEAN_NANOPICOPP_MARMAP_PAN_VGPM2
        PER1 = REPLICATE(0,N_ELEMENTS(XDATES))
        FOR NTH = 0L, N_ELEMENTS(PGROUPS)-1 DO BEGIN
          GROUP = PGROUPS[NTH]
          POS = WHERE(TAGS EQ 'MEAN_PPD_' + GROUP + '_PERCENTAGE_MARMAP_PAN_VGPM2')
          PER = VDATA.(POS)
          OK = WHERE(PER EQ MISSINGS(PER),COUNT) & IF COUNT GE 1 THEN PER[OK] = 0.0
          IF NTH EQ 0 THEN BEGIN
            ;  IF N EQ 0 THEN TITLE = 'Primary Production (VGPM-Eppley)!C'+TITLES(N) ELSE TITLE = TITLES(N)
            POSITION = [XPOS[0],YPOS(PTH),XPOS[0]+XDIF,YPOS(PTH)+YDIF]
            P = PLOT(XDATES,REPLICATE(0,N_ELEMENTS(VDATA)),YTITLE='Composition (%)',XTICKVALUE=AX.TICKV,FONT_SIZE=11,TITLE=TITLE,POSITION=POSITION,$
              XMINOR=0,YRANGE=[0,100],AXIS_STYLE=1,XSTYLE=1,XTICKNAME=AX.TICKNAME,/NODATA,BUFFER=BUFFER,MARGIN=MARGIN,LAYOUT=LAYOUT,/CURRENT)
            BOT = REPLICATE(0, N_ELEMENTS(VDATA))
            YY = [PER,BOT]
            XX = [XDATES,REVERSE(XDATES)]
            POLY = POLYGON(XX,YY,FILL_COLOR=PCOLORS[NTH],/FILL_BACKGROUND,TARGET=P,/DATA,LINESTYLE=6)
          ENDIF
          PER1 = PER + PER1
          YY = [PER1,REVERSE(BOTTOM)]
          XX = [XDATES,REVERSE(XDATES)]
          IF NTH GE 1 THEN POLY = POLYGON(XX,YY,FILL_COLOR=PCOLORS[NTH],/FILL_BACKGROUND,TARGET=P,/DATA,LINESTYLE=6)
          BOTTOM = PER1
        ENDFOR
        P2 = PLOT(XDATES,TOT,COLOR='GREY',/CURRENT,AXIS_STYLE=0,XTICKVALUE=AX.TICKV,XRANGE=P.XRANGE,MARGIN=MARGIN,THICK=3,LINESTYLE=0,LAYOUT=LAYOUT,POSITION=POSITION,YRANGE=PYRANGE)
        A1 = AXIS('Y',TARGET=P2,LOCATION=[MAX(P.XRANGE),0,0],TEXTPOS=1,MINOR=2,TICKFONT_SIZE=11,TEXT_COLOR='BLACK',TICKDIR=1,TITLE='VGPM-Eppley ' + UNITS('PPD',/NO_NAME),TICKLEN=0.05,YRANGE=PYRANGE) ;AXIS,YAXIS=1,YRANGE=[0,300],/SAVE, YTITLE=YTITLE2,CHARSIZE=CHARSIZE,COLOR=0
        A2 = AXIS('X',TARGET=P,LOCATION=[MIN(P.XRANGE),100,0],MAJOR=0,MINOR=0,COLOR='BLACK')

        IF PERIODS(PTH) EQ 'A_' THEN XDATES = PERIOD_2JD(VDATA.PERIOD)
        BOTTOM = 0
        COUNTER = COUNTER + 1
        LAYOUT = [2,2,3]
        TOT = VDATA.MEAN_MICROPP_MARMAP_PAN_OPAL + VDATA.MEAN_NANOPICOPP_MARMAP_PAN_OPAL
        PER1 = REPLICATE(0,N_ELEMENTS(XDATES))
        FOR NTH = 0L, N_ELEMENTS(PGROUPS)-1 DO BEGIN
          GROUP = PGROUPS[NTH]
          POS = WHERE(TAGS EQ 'MEAN_PPD_' + GROUP + '_PERCENTAGE_MARMAP_PAN_OPAL')
          PER = VDATA.(POS)
          OK = WHERE(PER EQ MISSINGS(PER),COUNT) & IF COUNT GE 1 THEN PER[OK] = 0.0
          IF NTH EQ 0 THEN BEGIN
            ; IF N EQ 0 THEN TITLE = 'Primary Production (VGPM-Eppley)!C'+TITLES(N) ELSE TITLE = TITLES(N)
            POSITION = [XPOS[1],YPOS(PTH),XPOS[1]+XDIF,YPOS(PTH)+YDIF]
            P = PLOT(XDATES,REPLICATE(0,N_ELEMENTS(VDATA)),YTITLE='Composition (%)',XTICKVALUE=AX.TICKV,FONT_SIZE=11,TITLE=TITLE,POSITION=POSITION,$
              XMINOR=0,YRANGE=[0,100],AXIS_STYLE=1,XSTYLE=1,XTICKNAME=AX.TICKNAME,/NODATA,BUFFER=BUFFER,MARGIN=MARGIN,LAYOUT=LAYOUT,/CURRENT)
            BOT = REPLICATE(0, N_ELEMENTS(VDATA))
            YY = [PER,BOT]
            XX = [XDATES,REVERSE(XDATES)]
            POLY = POLYGON(XX,YY,FILL_COLOR=PCOLORS[NTH],/FILL_BACKGROUND,TARGET=P,/DATA,LINESTYLE=6)
          ENDIF
          PER1 = PER + PER1
          YY = [PER1,REVERSE(BOTTOM)]
          XX = [XDATES,REVERSE(XDATES)]
          IF NTH GE 1 THEN POLY = POLYGON(XX,YY,FILL_COLOR=PCOLORS[NTH],/FILL_BACKGROUND,TARGET=P,/DATA,LINESTYLE=6)
          BOTTOM = PER1
        ENDFOR
        P2 = PLOT(XDATES,TOT,COLOR='GREY',/CURRENT,AXIS_STYLE=0,XTICKVALUE=AX.TICKV,XRANGE=P.XRANGE,MARGIN=MARGIN,THICK=3,LINESTYLE=0,LAYOUT=LAYOUT,POSITION=POSITION,YRANGE=PYRANGE)
        A1 = AXIS('Y',TARGET=P2,LOCATION=[MAX(P.XRANGE),0,0],TEXTPOS=1,MINOR=2,TICKFONT_SIZE=11,TEXT_COLOR='BLACK',TICKDIR=1,TITLE='OPAL ' + UNITS('PPD',/NO_NAME),TICKLEN=0.05,YRANGE=PYRANGE) ;AXIS,YAXIS=1,YRANGE=[0,300],/SAVE, YTITLE=YTITLE2,CHARSIZE=CHARSIZE,COLOR=0
        A2 = AXIS('X',TARGET=P,LOCATION=[MIN(P.XRANGE),100,0],MAJOR=0,MINOR=0,COLOR='BLACK')
      ENDFOR


      W.SAVE, PNGFILE, RESOLUTION=300, BIT_DEPTH=2
      W.CLOSE

    ENDFOR
    STOP


  ENDIF ; DO_PP_SIZE_PLOTS


  ; *******************************************************
  IF DO_BATHY_LMES GE 1 THEN BEGIN
    ; *******************************************************
    OVERWRITE = DO_BATHY_LMES GE 2

    BUFFER = 1

    TARGETS = ['LME']
    MAP_IN = 'GEQ'
    PDIR = !S.DATASETS + 'PP-SEAWIFS-PAT-9\GEQ\'
    CDIR = !S.DATASETS + 'OC-SEAWIFS-9\GEQ\'

    PRODS = ['CHLOR_A','PPD','BATHY']
    FOR P=0, N_ELEMENTS(PRODS)-1 DO BEGIN
      UPROD = PRODS(P)
      CASE UPROD OF
        'CHLOR_A': BEGIN
          INFILE = FILE_SEARCH(FIX_PATH(CDIR + 'STATS\CHLOR_A-OC4\ANNUAL*GEQ*MEAN.SAVE'))
          DIR_OUT = DIR_PLOTS + 'CHLOR_A_LMES\'
          SS = 'MEDIUM'
          UPROD = 'CHLOR_A'
          PAL = 'PAL_SW3'
        END
        'PPD': BEGIN
          INFILE = FILE_SEARCH(FIX_PATH(PDIR + 'STATS\PPD-VGPM2\ANNUAL*GEQ*MEAN.SAVE'))
          DIR_OUT = DIR_PLOTS + 'PPD_LMES\'
          SS = 'LOW'
          UPROD = 'PPD'
          PAL = 'PAL_SW3'
        END
        'BATHY': BEGIN
          INFILE = !S.BATHY + 'SRTM30PLUS-GEQ-PXY_4096_2048-BATHY-SMOOTH_5.SAVE'
          DIR_OUT = DIR_PLOTS + 'BATHY_LMES\'
          SS = ''
          UPROD = 'BATHY'
          PAL = 'PAL_BATHY'
        END
      ENDCASE
      DIR_TEST, DIR_OUT

      LAND = READ_LANDMASK(MAP=MAP_IN,PX=4096,PY=2048,/STRUCT)
      LL = MAPS_2LONLAT(MAP_IN,PX=4096,PY=2048)
      IMG = BYTARR(4096,2048) & IMG(*) = 251
      IMG(LAND.LAND)  = 251
      IMG(LAND.OCEAN) = 254

      FOR TAR=0, N_ELEMENTS(TARGETS)-1 DO BEGIN
        ATARGET = TARGETS(TAR)
        TARGET  = STRMID(ATARGET,0,3)
        IF TARGET EQ 'LME' THEN BEGIN
          TARS = READALL(!S.DATA + 'lme_names.csv')
          MASK = STRUCT_SD_READ(!S.IMAGES + 'MASK_SUBAREA-'+MAP_IN+'-PXY_4096_2048-LME_TOTAL.SAVE',STRUCT=LSTRUCT)
          L3   = STRUCT_SD_READ(!S.IMAGES + 'MASK_SUBAREA-'+MAP_IN+'-PXY_4096_2048-LME_0_300.SAVE',STRUCT=L3STRUCT)
          EXCLUDE_LMES = ['255','0','251','64','63','62','61','58','57','56','55','54']
          OK = WHERE_MATCH(LSTRUCT.SUBAREA_CODE,EXCLUDE_LMES,COUNT,COMPLEMENT=COMPLEMENT)
          CODES  = LSTRUCT.SUBAREA_CODE(COMPLEMENT)
          NAMES  = LSTRUCT.SUBAREA_NAME(COMPLEMENT)
        ENDIF
        FOR C=0, N_ELEMENTS(CODES)-1 DO BEGIN
          CODE = CODES(C)
          NAME = NAMES(C)
          OK = WHERE(TARS.SUBAREA_NAME EQ NAME)
          TITLE = TARS[OK].NAME
          PNGFILE = FIX_PATH(DIR_OUT + TARGET +'_' + NUM2STR(CODE) + '-' + NAME+'-'+UPROD+'.PNG')
          IF FILE_TEST(PNGFILE) EQ 1 AND NOT KEYWORD_SET(OVERWRITE) THEN CONTINUE

          OUTLINE_FILES = []
          IF TARGET EQ 'LME' THEN BEGIN
            PAL_36,R,G,B
            M = MAPS_SIZE('LME_'+NAME)
            LME_OUTLINE_FILE = DIR_OUTLINES + 'MASK_OUTLINE-LME_TOTAL-'+M.MAP+'-PXY_'+STRTRIM(M.PX,2)+'_'+STRTRIM(M.PY,2)+'.PNG'
            L3_OUTLINE_FILE = DIR_OUTLINES + 'MASK_OUTLINE-LME_0_300-'+M.MAP+'-PXY_'+STRTRIM(M.PX,2)+'_'+STRTRIM(M.PY,2)+'.PNG'
            OUTLINE_FILES = [L3_OUTLINE_FILE,LME_OUTLINE_FILE]
            OUTLINE_COLORS = [255,0]
            OUTLINE_THICK = 2

            LANDMASK_FILE = !S.IMAGES + 'MASK_LAND-'+M.MAP+'-PXY_'+STRTRIM(M.PX,2)+'_'+STRTRIM(M.PY,2)+'.PNG'
            IF FILE_TEST(LANDMASK_FILE) EQ 0 OR KEYWORD_SET(OVERWRITE) THEN $
              LANDMASK_REMAP,MAP_OUT=M.MAP,MAP_IN=MAP_IN,PX_OUT=M.PX,PY_OUT=M.PY,FIX_COAST=1,OVERWRITE=OVERWRITE
          ENDIF

          LAND_COLOR = 251
          PYE = 80
          DATA = STRUCT_SD_READ(INFILE,STRUCT=STRUCT,MAP_OUT=M.MAP,LME_CODE_OUT=CODE,PX_OUT=M.PX,PY_OUT=M.PY)
          W = WINDOW(DIMENSIONS=[M.PX,M.PY+PYE],BUFFER=BUFFER)
          IM  = STRUCT_SD_2IMAGE_NG(STRUCT,IMG_POSITION=[0,PYE,M.PX,PYE+M.PY],PAL=PAL,USE_PROD=UPROD,SPECIAL_SCALE=SS,/ADD_OUTLINE,/ADD_LAND,/ADD_COAST,LAND_COLOR=LAND_COLOR,OUTLINE_FILE=OUTLINE_FILES,OUTLINE_COLOR=OUTLINE_COLORS,OUTLINE_THICK=OUTLINE_THICK,/CURRENT,MARGIN=MARGIN,/DEVICE,BUFFER=BUFFER)
          BAR = COLOR_BAR_SCALE_NG(PROD=UPROD,SPECIAL_SCALE=SS, PX=M.PX/8,PY=PYE-30,CHARSIZE=14,BACKGROUND=252,XDIM=M.PX-M.PX/4,YDIM=20,PAL=PAL,VERTICAL=0,BOTTOM=1,FONT='HELVETICA',/CURRENT,TITLE=UNITS(UPROD),BUFFER=BUFFER)
          W.SAVE,PNGFILE,RESOLUTION=300
          W.CLOSE
        ENDFOR
      ENDFOR
    ENDFOR
    STOP
  ENDIF ; DO_BATHY_LMES

stop
  
; *******************************************************
  IF DO_COMPOSITES GE 1 THEN BEGIN
; *******************************************************
    OVERWRITE = DO_COMPOSITES GE 2
    
    BUFFER = 0
    
    PDIR = !S.DATASETS + 'PP-SEAWIFS-PAT-9\GEQ\'
    CDIR = !S.DATASETS + 'OC-SEAWIFS-9\GEQ\'
    TARGETS = ['FAO_TOTAL','FAO_MINUS','LME_TOTAL','LME_0_300','LME_300']
    LMES = READALL(!S.DATA + 'lme_names.csv')
    FOR TAR=0, N_ELEMENTS(TARGETS)-1 DO BEGIN
      ATARGET = TARGETS(TAR)
      TARGET  = STRMID(ATARGET,0,3)
      IF TARGET EQ 'FAO' THEN CONTINUE
      MASK  = STRUCT_SD_READ(!S.IMAGES + 'MASK_SUBAREA-GEQ-PXY_4096_2048-'+STRUPCASE(ATARGET)+'.SAVE',STRUCT=STRUCT)
      
      CFILE   = FILE_SEARCH(FIX_PATH(CDIR + 'STATS\CHLOR_A-OC4\ANNUAL*GEQ*MEAN.SAVE'))
      MCFILE  = FILE_SEARCH(FIX_PATH(CDIR + 'STATS\MICRO-PAN\ANNUAL*GEQ*MEAN.SAVE'))
      NCFILE  = FILE_SEARCH(FIX_PATH(CDIR + 'STATS\NANOPICO-PAN\ANNUAL*GEQ*MEAN.SAVE'))
      MCPFILE = FILE_SEARCH(FIX_PATH(CDIR + 'STATS\MICRO_PERCENTAGE-PAN\ANNUAL*GEQ*MEAN.SAVE'))
      NCPFILE = FILE_SEARCH(FIX_PATH(CDIR + 'STATS\NANOPICO_PERCENTAGE-PAN\ANNUAL*GEQ*MEAN.SAVE'))
      
      VFILE   = FILE_SEARCH(FIX_PATH(PDIR + 'STATS\PPD-VGPM2\ANNUAL*GEQ*MEAN.SAVE'))
      VMFILE  = FILE_SEARCH(FIX_PATH(PDIR + 'STATS\MICROPP-MARMAP_PAN_VGPM2\ANNUAL*GEQ*MEAN.SAVE'))
      VNFILE  = FILE_SEARCH(FIX_PATH(PDIR + 'STATS\NANOPICOPP-MARMAP_PAN_VGPM2\ANNUAL*GEQ*MEAN.SAVE'))
      VMPFILE = FILE_SEARCH(FIX_PATH(PDIR + 'STATS\MICROPP_PERCENTAGE-MARMAP_PAN_VGPM2\ANNUAL*GEQ*MEAN.SAVE'))
      VNPFILE = FILE_SEARCH(FIX_PATH(PDIR + 'STATS\NANOPICOPP_PERCENTAGE-MARMAP_PAN_VGPM2\ANNUAL*GEQ*MEAN.SAVE'))
      
      SCFILE  = FILE_SEARCH(FIX_PATH(CDIR + 'TS_SUBAREAS\A_ANNUAL_MANNUAL_MONTH-MASK_SUBAREA-GEQ-PXY_4096_2048-'+ATARGET+'-SEAWIFS-R2010-9-MULTI_PRODS.SAVE'))
      SPFILE  = FILE_SEARCH(FIX_PATH(PDIR + 'TS_SUBAREAS\A_ANNUAL_MANNUAL_MONTH-MASK_SUBAREA-GEQ-PXY_4096_2048-'+ATARGET+'-SEA_AV4-9-MULTI_PRODS.SAVE'))
      FILES  = [CFILE,MCFILE,NCFILE,MCPFILE,NCPFILE,VFILE,VMFILE,VNFILE,VMPFILE,VNPFILE,SCFILE,SPFILE]
      SCDATA  = IDL_RESTORE(SCFILE)
      SPDATA  = IDL_RESTORE(SPFILE)
      SDATA = STRUCT_JOIN(SCDATA,SPDATA,TAGNAMES=['PERIOD','PERIOD_CODE','MASK','SUBAREA_CODE','SUBAREA_NAME','N_SUBAREA'])
      BSET = WHERE_SETS(SDATA.SUBAREA_CODE)
      GONE, SCDATA
      GONE, SPDATA
      
      FOR N=0, N_ELEMENTS(BSET)-1 DO BEGIN
        SUBS = WHERE_SETS_SUBS(BSET(N))
        SET  = SDATA(SUBS)
        CODE = SET[0].SUBAREA_CODE
        NAME = SET[0].SUBAREA_NAME
        IF NAME EQ 'ANTARCTIC' THEN CONTINUE
        OK = WHERE(LMES.SUBAREA_NAME EQ NAME)
        TITLE = LMES[OK].NAME
        PNGFILE = FIX_PATH(DIR_COMPS + NAME+'-PHYTO_COMPOSITE.PNG')
        IF GET_MTIME(PNGFILE) GT MIN(GET_MTIME(FILES)) AND NOT KEYWORD_SET(OVERWRITE) THEN CONTINUE
        M = MAPS_SIZE('LME_'+NAME)
        OUTLINE_FILE = FIX_PATH(!S.IDL + 'LME\TO_BE_EDITED-MASK_OUTLINE-'+M.MAP+'-PXY_'+STRTRIM(M.PX,2)+'_'+STRTRIM(M.PY,2)+'.PNG')
        IF FILE_TEST(OUTLINE_FILE) EQ 0 THEN OUTLINE_FILE = []
        
        BATHY = 300
        CSCALE = 'LOW'
        VSCALE = 'LOW'
        CPSCALE = '100'
        VPSCALE = '100'
        CGROUPS = ['MICRO','NANOPICO']
        CCOLORS = ['YELLOW','MEDIUM_AQUAMARINE']
        PGROUPS = ['MICRO','NANOPICO']
        PCOLORS = ['YELLOW','MEDIUM_AQUAMARINE']
        
        DATA = STRUCT_SD_READ(CFILE,  MAP_OUT='LME_'+NAME,LME_CODE_OUT=CODE,STRUCT=CHL)
        DATA = STRUCT_SD_READ(MCFILE, MAP_OUT='LME_'+NAME,LME_CODE_OUT=CODE,STRUCT=CMICRO)
        DATA = STRUCT_SD_READ(NCFILE, MAP_OUT='LME_'+NAME,LME_CODE_OUT=CODE,STRUCT=CNANO)
        DATA = STRUCT_SD_READ(MCPFILE,MAP_OUT='LME_'+NAME,LME_CODE_OUT=CODE,STRUCT=CMPER)
        DATA = STRUCT_SD_READ(NCPFILE,MAP_OUT='LME_'+NAME,LME_CODE_OUT=CODE,STRUCT=CNPER)
        DATA = STRUCT_SD_READ(VFILE,  MAP_OUT='LME_'+NAME,LME_CODE_OUT=CODE,STRUCT=VGPM)
        DATA = STRUCT_SD_READ(VMFILE, MAP_OUT='LME_'+NAME,LME_CODE_OUT=CODE,STRUCT=VMICRO)
        DATA = STRUCT_SD_READ(VNFILE, MAP_OUT='LME_'+NAME,LME_CODE_OUT=CODE,STRUCT=VNANO)
        DATA = STRUCT_SD_READ(VMPFILE,MAP_OUT='LME_'+NAME,LME_CODE_OUT=CODE,STRUCT=VMPER)
        DATA = STRUCT_SD_READ(VNPFILE,MAP_OUT='LME_'+NAME,LME_CODE_OUT=CODE,STRUCT=VNPER)
        GONE, DATA
        
        W = WINDOW(DIMENSIONS=[800,1040],BUFFER=BUFFER)
        T    = TEXT(400,1020,'LME (' + NUM2STR(CODE) + ') ' + TITLE,ALIGNMENT=0.5,/DEVICE,FONT_SIZE=14,FONT_STYLE='BOLD')
        TT   = TEXT([150,590],[995,995],['Chlorophyll','Primary Production'],ALIGNMENT=0.5,/DEVICE,FONT_SIZE=14)
        TS   = TEXT([70, 220,470,620],[680,680,680,680],['Micro','Nano+Pico','Micro','Nano+Pico'],FONT_SIZE=12,ALIGNMENT=0.5,/DEVICE)
        TS   = TEXT([125,265,525,665],[365,365,365,365],['Monthly','Annual','Monthly','Annual'],FONT_SIZE=12,ALIGNMENT=0.5,/DEVICE)
        
        CIM  = STRUCT_SD_2IMAGE_NG(CHL, IMG_POSITION=[5,  700,295,990],USE_PROD='CHLOR_A',SPECIAL_SCALE=CSCALE,/ADD_LAND,LAND_COLOR=252,/ADD_LME_OUTLINE,OUTLINE_FILE=OUTLINE_FILE,/ADD_BATHY,BATHS=BATHY,BATHY_COLOR=0,BATHY_THICK=3,/CURRENT,MARGIN=MARGIN,/DEVICE)
        VIM  = STRUCT_SD_2IMAGE_NG(VGPM,IMG_POSITION=[405,710,695,990],USE_PROD='PPD',    SPECIAL_SCALE=VSCALE,/ADD_LAND,LAND_COLOR=252,/ADD_LME_OUTLINE,OUTLINE_FILE=OUTLINE_FILE,/ADD_BATHY,BATHS=BATHY,BATHY_COLOR=0,BATHY_THICK=3,/CURRENT,MARGIN=MARGIN,/DEVICE)
        
        CIM  = STRUCT_SD_2IMAGE_NG(CMICRO,IMG_POSITION=[5,  535,145,675],USE_PROD='CHLOR_A',SPECIAL_SCALE=CSCALE,/ADD_LAND,LAND_COLOR=252,/ADD_LME_OUTLINE,OUTLINE_FILE=OUTLINE_FILE,/ADD_BATHY,BATHS=BATHY,BATHY_COLOR=0,BATHY_THICK=3,/CURRENT,MARGIN=MARGIN,/DEVICE)
        CIM  = STRUCT_SD_2IMAGE_NG(CNANO, IMG_POSITION=[155,535,295,675],USE_PROD='CHLOR_A',SPECIAL_SCALE=CSCALE,/ADD_LAND,LAND_COLOR=252,/ADD_LME_OUTLINE,OUTLINE_FILE=OUTLINE_FILE,/ADD_BATHY,BATHS=BATHY,BATHY_COLOR=0,BATHY_THICK=3,/CURRENT,MARGIN=MARGIN,/DEVICE)
        CIM  = STRUCT_SD_2IMAGE_NG(CMPER, IMG_POSITION=[5,  385,145,525],USE_PROD='PERCENT',SPECIAL_SCALE=CPSCALE,/ADD_LAND,LAND_COLOR=252,/ADD_LME_OUTLINE,OUTLINE_FILE=OUTLINE_FILE,/ADD_BATHY,BATHS=BATHY,BATHY_COLOR=0,BATHY_THICK=3,/CURRENT,MARGIN=MARGIN,/DEVICE)
        CIM  = STRUCT_SD_2IMAGE_NG(CNPER, IMG_POSITION=[155,385,295,525],USE_PROD='PERCENT',SPECIAL_SCALE=CPSCALE,/ADD_LAND,LAND_COLOR=252,/ADD_LME_OUTLINE,OUTLINE_FILE=OUTLINE_FILE,/ADD_BATHY,BATHS=BATHY,BATHY_COLOR=0,BATHY_THICK=3,/CURRENT,MARGIN=MARGIN,/DEVICE)
        
        VIM  = STRUCT_SD_2IMAGE_NG(VMICRO,IMG_POSITION=[405,535,545,675],USE_PROD='PPD',    SPECIAL_SCALE=VSCALE,/ADD_LAND,LAND_COLOR=252,/ADD_LME_OUTLINE,OUTLINE_FILE=OUTLINE_FILE,/ADD_BATHY,BATHS=BATHY,BATHY_COLOR=0,BATHY_THICK=3,/CURRENT,MARGIN=MARGIN,/DEVICE)
        VIM  = STRUCT_SD_2IMAGE_NG(VNANO, IMG_POSITION=[555,535,695,675],USE_PROD='PPD',    SPECIAL_SCALE=VSCALE,/ADD_LAND,LAND_COLOR=252,/ADD_LME_OUTLINE,OUTLINE_FILE=OUTLINE_FILE,/ADD_BATHY,BATHS=BATHY,BATHY_COLOR=0,BATHY_THICK=3,/CURRENT,MARGIN=MARGIN,/DEVICE)
        VIM  = STRUCT_SD_2IMAGE_NG(VMPER, IMG_POSITION=[405,385,545,525],USE_PROD='PERCENT',SPECIAL_SCALE=VPSCALE,/ADD_LAND,LAND_COLOR=252,/ADD_LME_OUTLINE,OUTLINE_FILE=OUTLINE_FILE,/ADD_BATHY,BATHS=BATHY,BATHY_COLOR=0,BATHY_THICK=3,/CURRENT,MARGIN=MARGIN,/DEVICE)
        VIM  = STRUCT_SD_2IMAGE_NG(VNPER, IMG_POSITION=[555,385,695,525],USE_PROD='PERCENT',SPECIAL_SCALE=VPSCALE,/ADD_LAND,LAND_COLOR=252,/ADD_LME_OUTLINE,OUTLINE_FILE=OUTLINE_FILE,/ADD_BATHY,BATHS=BATHY,BATHY_COLOR=0,BATHY_THICK=3,/CURRENT,MARGIN=MARGIN,/DEVICE)
        
        BAR = COLOR_BAR_SCALE_NG(PROD='CHLOR_A',SPECIAL_SCALE=CSCALE, PX=305,PY=980,CHARSIZE=10,BACKGROUND=252,XDIM=20,YDIM=260,PAL='PAL_SW3',VERTICAL=1,RIGHT=1,FONT='HELVETICA',/CURRENT,TITLE=UNITS('CHLOROPHYLL'))
        BAR = COLOR_BAR_SCALE_NG(PROD='PPD',    SPECIAL_SCALE=VSCALE, PX=705,PY=980,CHARSIZE=10,BACKGROUND=252,XDIM=20,YDIM=260,PAL='PAL_SW3',VERTICAL=1,RIGHT=1,FONT='HELVETICA',/CURRENT,TITLE=UNITS('PRIMARY_PRODUCTION'))
        BAR = COLOR_BAR_SCALE_NG(PROD='CHLOR_A',SPECIAL_SCALE=CSCALE, PX=305,PY=670,CHARSIZE=10,BACKGROUND=252,XDIM=20,YDIM=130,PAL='PAL_SW3',VERTICAL=1,RIGHT=1,FONT='HELVETICA',/CURRENT,TITLE=UNITS('CHLOROPHYLL'))
        BAR = COLOR_BAR_SCALE_NG(PROD='PERCENT',SPECIAL_SCALE=CPSCALE,PX=305,PY=520,CHARSIZE=10,BACKGROUND=252,XDIM=20,YDIM=130,PAL='PAL_SW3',VERTICAL=1,RIGHT=1,FONT='HELVETICA',/CURRENT,TITLE=UNITS('PERCENT'))
        BAR = COLOR_BAR_SCALE_NG(PROD='PPD',    SPECIAL_SCALE=CSCALE, PX=705,PY=670,CHARSIZE=10,BACKGROUND=252,XDIM=20,YDIM=130,PAL='PAL_SW3',VERTICAL=1,RIGHT=1,FONT='HELVETICA',/CURRENT,TITLE=UNITS('PRIMARY_PRODUCTION'))
        BAR = COLOR_BAR_SCALE_NG(PROD='PERCENT',SPECIAL_SCALE=VPSCALE,PX=705,PY=520,CHARSIZE=10,BACKGROUND=252,XDIM=20,YDIM=130,PAL='PAL_SW3',VERTICAL=1,RIGHT=1,FONT='HELVETICA',/CURRENT,TITLE=UNITS('PERCENT'))
        
        TAGS = TAG_NAMES(SET)
        ASET = SET[WHERE(SET.PERIOD_CODE EQ 'A' AND DATE_2YEAR(PERIOD_2DATE(SET.PERIOD)) LE 2007)]
        ASET = ASET[SORT(DATE_2DOY(PERIOD_2DATE(ASET.PERIOD)))]
        ADATES = PERIOD_2JD(ASET.PERIOD)
        AX = DATE_AXIS([19980101,20070101],/YEAR,/YY,STEP_SIZE=2)
        
        MSET = SET[WHERE(SET.PERIOD_CODE EQ 'MONTH' AND SET.FIRST_NAME_MICRO_PAN NE '')]
        MSET = MSET[SORT(DATE_2DOY(PERIOD_2DATE(MSET.PERIOD)))]
        MDATES = JD_ADD(YDOY_2JD('2020',DATE_2DOY(PERIOD_2DATE(MSET.PERIOD))),14,/DAY)
        MX = DATE_AXIS([20200101,20201431],/MONTH,/MID,/FYEAR,STEP_SIZE=2)
        
        BOTTOM = 0
        COUNTER = 0
        COUNTER = COUNTER + 1
        ACTOT = ASET.MEAN_MICRO_PAN + ASET.MEAN_NANOPICO_PAN
        MCTOT = MSET.MEAN_MICRO_PAN + MSET.MEAN_NANOPICO_PAN
        APTOT = ASET.MEAN_MICROPP_MARMAP_PAN_VGPM2 + ASET.MEAN_NANOPICOPP_MARMAP_PAN_VGPM2
        MPTOT = MSET.MEAN_MICROPP_MARMAP_PAN_VGPM2 + MSET.MEAN_NANOPICOPP_MARMAP_PAN_VGPM2
        
        ;     ***** CHLOROPHYLL COMPOSITION PLOTS *****
        PER1 = REPLICATE(0,N_ELEMENTS(MDATES))
        FOR NTH = 0L, N_ELEMENTS(CGROUPS)-1 DO BEGIN
          GROUP = CGROUPS[NTH]
          POS = WHERE(TAGS EQ 'MEAN_' + GROUP + '_PERCENTAGE_PAN')
          PER = MSET.(POS)
          OK = WHERE(PER EQ MISSINGS(PER),COUNT) & IF COUNT GE 1 THEN PER[OK] = 0.0
          IF NTH EQ 0 THEN BEGIN
            POSITION = [60,220,185,360]
            P = PLOT(MDATES,REPLICATE(0,N_ELEMENTS(MSET)),YTITLE='Percent Composition (%)',XTICKVALUE=MX.TICKV,FONT_SIZE=11,POSITION=POSITION,$
              XMINOR=0,YRANGE=[0,100],AXIS_STYLE=1,XSTYLE=1,XTICKNAME=MX.TICKNAME,/NODATA,BUFFER=BUFFER,MARGIN=MARGIN,LAYOUT=LAYOUT,/CURRENT,/DEVICE)
            BOT = REPLICATE(0, N_ELEMENTS(MSET))
            YY = [PER,BOT]
            XX = [MDATES,REVERSE(MDATES)]
            POLY = POLYGON(XX,YY,FILL_COLOR=CCOLORS[NTH],/FILL_BACKGROUND,TARGET=P,/DATA,LINESTYLE=6)
          ENDIF
          PER1 = PER + PER1
          YY = [PER1,REVERSE(BOTTOM)]
          XX = [MDATES,REVERSE(MDATES)]
          IF NTH GE 1 THEN POLY = POLYGON(XX,YY,FILL_COLOR=CCOLORS[NTH],/FILL_BACKGROUND,TARGET=P,/DATA,LINESTYLE=6)
          BOTTOM = PER1
        ENDFOR
        P2 = PLOT(MDATES,MCTOT,COLOR='GREY',/CURRENT,AXIS_STYLE=0,XTICKVALUE=MX.TICKV,XRANGE=P.XRANGE,MARGIN=MARGIN,THICK=3,LINESTYLE=0,LAYOUT=LAYOUT,POSITION=POSITION,/DEVICE)
        YRANGE = P2.YRANGE
        A1 = AXIS('Y',TARGET=P2,LOCATION=[MAX(P.XRANGE),0,0],TEXTPOS=1,MINOR=2,TICKFONT_SIZE=11,TEXT_COLOR='BLACK',TICKDIR=1,TICKLEN=0.05,TICKNAME=REPLICATE(' ',6),YRANGE=YRANGE) ;AXIS,YAXIS=1,YRANGE=[0,300],/SAVE, YTITLE=YTITLE2,CHARSIZE=CHARSIZE,COLOR=0
        A2 = AXIS('X',TARGET=P,LOCATION=[MIN(P.XRANGE),100,0],MAJOR=0,MINOR=0,COLOR='BLACK')
        
        PER1 = REPLICATE(0,N_ELEMENTS(ADATES))
        FOR NTH = 0L, N_ELEMENTS(CGROUPS)-1 DO BEGIN
          GROUP = CGROUPS[NTH]
          POS = WHERE(TAGS EQ 'MEAN_' + GROUP + '_PERCENTAGE_PAN')
          PER = ASET.(POS)
          OK = WHERE(PER EQ MISSINGS(PER),COUNT) & IF COUNT GE 1 THEN PER[OK] = 0.0
          IF NTH EQ 0 THEN BEGIN
            POSITION = [200,220,325,360]
            P = PLOT(ADATES,REPLICATE(0,N_ELEMENTS(ASET)),YTITLE='',XTICKVALUE=AX.TICKV,FONT_SIZE=11,POSITION=POSITION,$
              XMINOR=0,YRANGE=[0,100],AXIS_STYLE=1,XSTYLE=1,XTICKNAME=AX.TICKNAME,YTICKNAME=REPLICATE(' ',6),/NODATA,BUFFER=BUFFER,MARGIN=MARGIN,LAYOUT=LAYOUT,/CURRENT,/DEVICE)
            BOT = REPLICATE(0, N_ELEMENTS(ASET))
            YY = [PER,BOT]
            XX = [ADATES,REVERSE(ADATES)]
            POLY = POLYGON(XX,YY,FILL_COLOR=CCOLORS[NTH],/FILL_BACKGROUND,TARGET=P,/DATA,LINESTYLE=6)
          ENDIF
          PER1 = PER + PER1
          YY = [PER1,REVERSE(BOTTOM)]
          XX = [ADATES,REVERSE(ADATES)]
          IF NTH GE 1 THEN POLY = POLYGON(XX,YY,FILL_COLOR=CCOLORS[NTH],/FILL_BACKGROUND,TARGET=P,/DATA,LINESTYLE=6)
          BOTTOM = PER1
        ENDFOR
        P2 = PLOT(ADATES,ACTOT,COLOR='GREY',/CURRENT,AXIS_STYLE=0,XTICKVALUE=AX.TICKV,XRANGE=P.XRANGE,MARGIN=MARGIN,THICK=3,LINESTYLE=0,LAYOUT=LAYOUT,POSITION=POSITION,YRANGE=YRANGE,/DEVICE)
        A1 = AXIS('Y',TARGET=P2,LOCATION=[MAX(P.XRANGE),0,0],TEXTPOS=1,MINOR=2,TICKFONT_SIZE=11,TEXT_COLOR='BLACK',TICKDIR=1,TICKLEN=0.05,YRANGE=YRANGE,TITLE='CHL ' + UNITS('CHLOROPHYLL',/NO_NAME)) ;AXIS,YAXIS=1,YRANGE=[0,300],/SAVE, YTITLE=YTITLE2,CHARSIZE=CHARSIZE,COLOR=0
        A2 = AXIS('X',TARGET=P, LOCATION=[MIN(P.XRANGE),100,0],MAJOR=0,MINOR=0,COLOR='BLACK')
        
        
        ;     Productivity Composition plots
        PER1 = REPLICATE(0,N_ELEMENTS(MDATES))
        FOR NTH = 0L, N_ELEMENTS(PGROUPS)-1 DO BEGIN
          GROUP = PGROUPS[NTH]
          POS = WHERE(TAGS EQ 'MEAN_PPD_' + GROUP + '_PERCENTAGE_MARMAP_PAN_VGPM2')
          PER = MSET.(POS)
          OK = WHERE(PER EQ MISSINGS(PER),COUNT) & IF COUNT GE 1 THEN PER[OK] = 0.0
          IF NTH EQ 0 THEN BEGIN
            POSITION = [460,220,585,360]
            P = PLOT(MDATES,REPLICATE(0,N_ELEMENTS(MSET)),YTITLE='Percent Composition (%)',XTICKVALUE=MX.TICKV,FONT_SIZE=11,POSITION=POSITION,$
              XMINOR=0,YRANGE=[0,100],AXIS_STYLE=1,XSTYLE=1,XTICKNAME=MX.TICKNAME,/NODATA,BUFFER=BUFFER,MARGIN=MARGIN,LAYOUT=LAYOUT,/CURRENT,/DEVICE)
            BOT = REPLICATE(0, N_ELEMENTS(MSET))
            YY = [PER,BOT]
            XX = [MDATES,REVERSE(MDATES)]
            POLY = POLYGON(XX,YY,FILL_COLOR=PCOLORS[NTH],/FILL_BACKGROUND,TARGET=P,/DATA,LINESTYLE=6)
          ENDIF
          PER1 = PER + PER1
          YY = [PER1,REVERSE(BOTTOM)]
          XX = [MDATES,REVERSE(MDATES)]
          IF NTH GE 1 THEN POLY = POLYGON(XX,YY,FILL_COLOR=PCOLORS[NTH],/FILL_BACKGROUND,TARGET=P,/DATA,LINESTYLE=6)
          BOTTOM = PER1
        ENDFOR
        P2 = PLOT(MDATES,MPTOT,COLOR='GREY',/CURRENT,AXIS_STYLE=0,XTICKVALUE=MX.TICKV,XRANGE=P.XRANGE,MARGIN=MARGIN,THICK=3,LINESTYLE=0,LAYOUT=LAYOUT,POSITION=POSITION,/DEVICE)
        YRANGE = P2.YRANGE
        A1 = AXIS('Y',TARGET=P2,LOCATION=[MAX(P.XRANGE),0,0],TEXTPOS=1,MINOR=2,TICKFONT_SIZE=11,TEXT_COLOR='BLACK',TICKDIR=1,TICKLEN=0.05,TICKNAME=REPLICATE(' ',6),YRANGE=YRANGE) ;AXIS,YAXIS=1,YRANGE=[0,300],/SAVE, YTITLE=YTITLE2,CHARSIZE=CHARSIZE,COLOR=0
        A2 = AXIS('X',TARGET=P,LOCATION=[MIN(P.XRANGE),100,0],MAJOR=0,MINOR=0,COLOR='BLACK')
        
        PER1 = REPLICATE(0,N_ELEMENTS(ADATES))
        FOR NTH = 0L, N_ELEMENTS(PGROUPS)-1 DO BEGIN
          GROUP = PGROUPS[NTH]
          POS = WHERE(TAGS EQ 'MEAN_PPD_' + GROUP + '_PERCENTAGE_MARMAP_PAN_VGPM2')
          PER = ASET.(POS)
          OK = WHERE(PER EQ MISSINGS(PER),COUNT) & IF COUNT GE 1 THEN PER[OK] = 0.0
          IF NTH EQ 0 THEN BEGIN
            POSITION = [600,220,725,360]
            P = PLOT(ADATES,REPLICATE(0,N_ELEMENTS(ASET)),YTITLE='',XTICKVALUE=AX.TICKV,FONT_SIZE=11,POSITION=POSITION,$
              XMINOR=0,YRANGE=[0,100],AXIS_STYLE=1,XSTYLE=1,XTICKNAME=AX.TICKNAME,YTICKNAME=REPLICATE(' ',6),/NODATA,BUFFER=BUFFER,MARGIN=MARGIN,LAYOUT=LAYOUT,/CURRENT,/DEVICE)
            BOT = REPLICATE(0, N_ELEMENTS(ASET))
            YY = [PER,BOT]
            XX = [ADATES,REVERSE(ADATES)]
            POLY = POLYGON(XX,YY,FILL_COLOR=PCOLORS[NTH],/FILL_BACKGROUND,TARGET=P,/DATA,LINESTYLE=6)
          ENDIF
          PER1 = PER + PER1
          YY = [PER1,REVERSE(BOTTOM)]
          XX = [ADATES,REVERSE(ADATES)]
          IF NTH GE 1 THEN POLY = POLYGON(XX,YY,FILL_COLOR=PCOLORS[NTH],/FILL_BACKGROUND,TARGET=P,/DATA,LINESTYLE=6)
          BOTTOM = PER1
        ENDFOR
        P2 = PLOT(ADATES,APTOT,COLOR='GREY',/CURRENT,AXIS_STYLE=0,XTICKVALUE=AX.TICKV,XRANGE=P.XRANGE,MARGIN=MARGIN,THICK=3,LINESTYLE=0,LAYOUT=LAYOUT,POSITION=POSITION,YRANGE=YRANGE,/DEVICE)
        A1 = AXIS('Y',TARGET=P2,LOCATION=[MAX(P.XRANGE),0,0],TEXTPOS=1,MINOR=2,TICKFONT_SIZE=11,TEXT_COLOR='BLACK',TICKDIR=1,TICKLEN=0.05,YRANGE=YRANGE,TITLE='PP ' + UNITS('PRIMARY_PRODUCTION',/NO_NAME)) ;AXIS,YAXIS=1,YRANGE=[0,300],/SAVE, YTITLE=YTITLE2,CHARSIZE=CHARSIZE,COLOR=0
        A2 = AXIS('X',TARGET=P, LOCATION=[MIN(P.XRANGE),100,0],MAJOR=0,MINOR=0,COLOR='BLACK')
        
        
        ;     ***** CHLOROPHYLL BAR PLOTS *****
        MX = DATE_AXIS([20200101,20201431],/MONTH,/MID,/FYEAR,STEP_SIZE=2) & MXRANGE = DATE_2JD([20191215,20210115])
        AX = DATE_AXIS([19980101,20070101],/YEAR,/YY,STEP_SIZE=2)          & AXRANGE = DATE_2JD([19970101,20080101])
        PER1 = REPLICATE(0,N_ELEMENTS(MDATES))
        OK = WHERE(MCTOT EQ MISSINGS(MCTOT),COUNT) & IF COUNT GE 1 THEN MCTOT[OK] = 0.0
        FOR NTH = 0L, N_ELEMENTS(CGROUPS)-1 DO BEGIN
          GROUP = CGROUPS[NTH]
          POS = WHERE(TAGS EQ 'MEAN_' + GROUP + '_PAN')
          PER = MSET.(POS)
          OK = WHERE(PER EQ MISSINGS(PER),COUNT) & IF COUNT GE 1 THEN PER[OK] = 0.0
          IF NTH EQ 0 THEN BEGIN
            POSITION = [60,60,185,200]
            P = PLOT(MXRANGE,[0,MAX(MCTOT)],YTITLE='CHL ' + UNITS('CHLOROPHYLL',/NO_NAME),XTICKVALUE=MX.TICKV,FONT_SIZE=11,POSITION=POSITION,XRANGE=MXRANGE,$
              XMINOR=0,YMINOR=2,XSTYLE=1,XTICKNAME=MX.TICKNAME,/NODATA,BUFFER=BUFFER,MARGIN=MARGIN,LAYOUT=LAYOUT,/CURRENT,/DEVICE)
            BYRANGE = P.YRANGE
            YTICKNAME = P.YTICKNAME
            YTICKV  = P.YTICKVALUE
            YMINOR = P.YMINOR
            BOT = REPLICATE(0, N_ELEMENTS(MSET))
            BAR = BARPLOT(MDATES,PER,NBARS=NBARS,INDEX=CTH,BOTTOM_VALUES=BOT,FILL_COLOR=CCOLORS[NTH],LINESTYLE=LINESTYLE,/OVERPLOT,YRANGE=BYRANGE,XRANGE=MXRANGE,XTICKVALUE=MX.TICKV,XTICKNAME=MX.TICKNAME,YTICKVALUE=YTICKV,YTICKNAME=YTICKNAME,YMINOR=YMINOR)
          ENDIF
          PER1 = PER + PER1
          IF NTH GE 1 THEN BAR = BARPLOT(MDATES,PER1,NBARS=NBARS,INDEX=CTH,BOTTOM_VALUES=BOTTOM,FILL_COLOR=CCOLORS[NTH],LINESTYLE=LINESTYLE,/OVERPLOT,YRANGE=BYRANGE,YTICKVALUE=YTICKV,YTICKNAME=YTICKNAME,YMINOR=YMINOR)
          BOTTOM = PER1
        ENDFOR
        
        PER1 = REPLICATE(0,N_ELEMENTS(ADATES))
        OK = WHERE(ACTOT EQ MISSINGS(ACTOT),COUNT) & IF COUNT GE 1 THEN ACTOT[OK] = 0.0
        FOR NTH = 0L, N_ELEMENTS(CGROUPS)-1 DO BEGIN
          GROUP = CGROUPS[NTH]
          POS = WHERE(TAGS EQ 'MEAN_' + GROUP + '_PAN')
          PER = ASET.(POS)
          OK = WHERE(PER EQ MISSINGS(PER),COUNT) & IF COUNT GE 1 THEN PER[OK] = 0.0
          IF NTH EQ 0 THEN BEGIN
            POSITION = [200,60,325,200]
            P = PLOT(AXRANGE,BYRANGE,XTICKVALUE=AX.TICKV,FONT_SIZE=11,POSITION=POSITION,YTICKNAME=REPLICATE(' ',N_ELEMENTS(YTICKNAME)),XRANGE=AXRANGE,YRANGE=BYRANGE,YTICKVALUE=YTICKV,YMINOR=YMINOR,$
              XMINOR=0,XSTYLE=1,XTICKNAME=AX.TICKNAME,/NODATA,BUFFER=BUFFER,MARGIN=MARGIN,LAYOUT=LAYOUT,/CURRENT,/DEVICE)
            BOT = REPLICATE(0, N_ELEMENTS(ASET))
            BAR = BARPLOT(ADATES,PER,NBARS=NBARS,INDEX=CTH,BOTTOM_VALUES=BOT,FILL_COLOR=CCOLORS[NTH],LINESTYLE=LINESTYLE,YTICKNAME=P.YTICKNAME,/OVERPLOT,YRANGE=BYRANGE,XRANGE=AXRANGE,XTICKVALUE=AX.TICKV,XTICKNAME=AX.TICKNAME,YTICKVALUE=YTICKV,YMINOR=YMINOR)
          ENDIF
          PER1 = PER + PER1
          IF NTH GE 1 THEN BAR = BARPLOT(ADATES,PER1,NBARS=NBARS,INDEX=CTH,BOTTOM_VALUES=BOTTOM,FILL_COLOR=CCOLORS[NTH],LINESTYLE=LINESTYLE,/OVERPLOT,YRANGE=BYRANGE,XRANGE=AXRANGE,XTICKVALUE=AX.TICKV,XTICKNAME=AX.TICKNAME,YTICKVALUE=YTICKV,YTICKNAME=P.YTICKNAME,YMINOR=YMINOR)
          BOTTOM = PER1
        ENDFOR
        A1 = AXIS('Y',TARGET=P,LOCATION=[MAX(P.XRANGE),0,0],TEXTPOS=1,MINOR=YMINOR,MAJOR=YMAJOR,TICKFONT_SIZE=11,TEXT_COLOR='BLACK',TICKDIR=1,TICKLEN=0.05,YRANGE=BYRANGE,TITLE='CHL ' + UNITS('CHLOROPHYLL',/NO_NAME),TICKVALUE=YTICKV,TICKNAME=YTICKNAME)
        
        ;     ***** PRODUCTION BAR PLOTS *****
        PER1 = REPLICATE(0,N_ELEMENTS(MDATES))
        OK = WHERE(MPTOT EQ MISSINGS(MPTOT),COUNT) & IF COUNT GE 1 THEN MPTOT[OK] = 0.0
        FOR NTH = 0L, N_ELEMENTS(PGROUPS)-1 DO BEGIN
          GROUP = PGROUPS[NTH]
          POS = WHERE(TAGS EQ 'MEAN_PPD_' + GROUP + '_MARMAP_PAN_VGPM2')
          PER = MSET.(POS)
          OK = WHERE(PER EQ MISSINGS(PER),COUNT) & IF COUNT GE 1 THEN PER[OK] = 0.0
          IF NTH EQ 0 THEN BEGIN
            POSITION = [460,60,585,200]
            P = PLOT(MXRANGE,[0,MAX(MPTOT)],YTITLE='PP ' + UNITS('PRIMARY_PRODUCTION',/NO_NAME),XTICKVALUE=MX.TICKV,FONT_SIZE=11,POSITION=POSITION,XRANGE=MXRANGE,$
              XMINOR=0,YMINOR=2,XSTYLE=1,XTICKNAME=MX.TICKNAME,/NODATA,BUFFER=BUFFER,MARGIN=MARGIN,LAYOUT=LAYOUT,/CURRENT,/DEVICE)
            BYRANGE = P.YRANGE
            YTICKNAME = P.YTICKNAME
            YTICKV  = P.YTICKVALUE
            YMINOR = P.YMINOR
            BOT = REPLICATE(0, N_ELEMENTS(MSET))
            BAR = BARPLOT(MDATES,PER,NBARS=NBARS,INDEX=CTH,BOTTOM_VALUES=BOT,FILL_COLOR=CCOLORS[NTH],LINESTYLE=LINESTYLE,/OVERPLOT,YRANGE=BYRANGE,XRANGE=MXRANGE,XTICKVALUE=MX.TICKV,XTICKNAME=MX.TICKNAME,YTICKVALUE=YTICKV,YTICKNAME=YTICKNAME,YMINOR=YMINOR)
          ENDIF
          PER1 = PER + PER1
          IF NTH GE 1 THEN BAR = BARPLOT(MDATES,PER1,NBARS=NBARS,INDEX=CTH,BOTTOM_VALUES=BOTTOM,FILL_COLOR=CCOLORS[NTH],LINESTYLE=LINESTYLE,/OVERPLOT,YRANGE=BYRANGE,YTICKVALUE=YTICKV,YTICKNAME=YTICKNAME,YMINOR=YMINOR)
          BOTTOM = PER1
        ENDFOR
        
        PER1 = REPLICATE(0,N_ELEMENTS(ADATES))
        OK = WHERE(ACTOT EQ MISSINGS(ACTOT),COUNT) & IF COUNT GE 1 THEN ACTOT[OK] = 0.0
        FOR NTH = 0L, N_ELEMENTS(PGROUPS)-1 DO BEGIN
          GROUP = PGROUPS[NTH]
          POS = WHERE(TAGS EQ 'MEAN_PPD_' + GROUP + '_MARMAP_PAN_VGPM2')
          PER = ASET.(POS)
          OK = WHERE(PER EQ MISSINGS(PER),COUNT) & IF COUNT GE 1 THEN PER[OK] = 0.0
          IF NTH EQ 0 THEN BEGIN
            POSITION = [600,60,725,200]
            P = PLOT(AXRANGE,BYRANGE,XTICKVALUE=AX.TICKV,FONT_SIZE=11,POSITION=POSITION,YTICKNAME=REPLICATE(' ',N_ELEMENTS(YTICKNAME)),XRANGE=AXRANGE,YRANGE=BYRANGE,YTICKVALUE=YTICKV,YMINOR=YMINOR,$
              XMINOR=0,XSTYLE=1,XTICKNAME=AX.TICKNAME,/NODATA,BUFFER=BUFFER,MARGIN=MARGIN,LAYOUT=LAYOUT,/CURRENT,/DEVICE)
            BOT = REPLICATE(0, N_ELEMENTS(ASET))
            BAR = BARPLOT(ADATES,PER,NBARS=NBARS,INDEX=CTH,BOTTOM_VALUES=BOT,FILL_COLOR=CCOLORS[NTH],LINESTYLE=LINESTYLE,/OVERPLOT,YRANGE=BYRANGE,XRANGE=AXRANGE,XTICKVALUE=AX.TICKV,XTICKNAME=AX.TICKNAME,YTICKVALUE=YTICKV,YTICKNAME=P.YTICKNAME,YMINOR=YMINOR)
          ENDIF
          PER1 = PER + PER1
          IF NTH GE 1 THEN BAR = BARPLOT(ADATES,PER1,NBARS=NBARS,INDEX=CTH,BOTTOM_VALUES=BOTTOM,FILL_COLOR=CCOLORS[NTH],LINESTYLE=LINESTYLE,/OVERPLOT,YRANGE=BYRANGE,XRANGE=AXRANGE,XTICKVALUE=AX.TICKV,XTICKNAME=AX.TICKNAME,YTICKVALUE=YTICKV,YTICKNAME=P.YTICKNAME,YMINOR=YMINOR)
          BOTTOM = PER1
        ENDFOR
        A1 = AXIS('Y',TARGET=P,LOCATION=[MAX(P.XRANGE),0,0],TEXTPOS=1,MAJOR=YMAJOR,MINOR=YMINOR,TICKFONT_SIZE=11,TEXT_COLOR='BLACK',TICKDIR=1,TICKLEN=0.05,YRANGE=BYRANGE,TITLE='PP ' + UNITS('PRIMARY_PRODUCTION',/NO_NAME),TICKVALUE=YTICKV,TICKNAME=YTICKNAME)
        
        X = [0,30,30,0,0] & Y = [0,0,15,15,0]
        PO = POLYGON(X,Y,POSITION=[250,10,280,25],FILL_COLOR=CCOLORS[1],/FILL_BACKGROUND,/CURRENT,/DEVICE)
        PO = POLYGON(X,Y,POSITION=[410,10,440,25],FILL_COLOR=CCOLORS[0],/FILL_BACKGROUND,/CURRENT,/DEVICE)
        TO = TEXT(390,17.5,'Microplankton',FONT_SIZE=12,/DEVICE,ALIGNMENT=1,VERTICAL_ALIGNMENT=0.5)
        TO = TEXT(445,17.5,'Nano + Picoplankton',FONT_SIZE=12,/DEVICE,ALIGNMENT=0,VERTICAL_ALIGNMENT=0.5)
        
        W.SAVE, PNGFILE, RESOLUTION=300, BIT_DEPTH=2
        W.CLOSE
        
      ENDFOR
      
      STOP
    ENDFOR
  ENDIF ; DO_COMPOSITES
  
; *******************************************************
  IF DO_BAR_PLOT GE 1 THEN BEGIN
; *******************************************************
    OVERWRITE = DO_BAR_PLOT GE 2
    
    SL = DELIMITER(/PATH)
    
    DATE_RANGE = DATE_2JD(['19970901','20071231'])
    SUBAREAS = ['ECOREGIONS_FULL_NO_ESTUARIES','ESTUARY_SHELF_LME']
    CDATASET = ['OC-SEAWIFS-MLAC']
    SUBPER   = ['A_ANNUAL_M_MANNUAL_MONTH']
    PERIODS  = ['MONTH','M_'+NUM2STR(INDGEN(10)+1998),'A_']
    OUTPER   = ['MONTH','M_'+NUM2STR(INDGEN(10)+1998),'A']
    PERSTR   = [5,REPLICATE(6,N_ELEMENTS(PERIODS)-2),2]
    TITLES   = ['NE Shelf','Mid-Atlantic Bight','Georges Bank','Gulf of Maine','Scotian Shelf']
    CODES    = [32,7,5,6,8]
    DATES    = ['Climatology (1998-2007)',NUM2STR(INDGEN(10)+1998),'Annual Mean (1998-2007)']
    BGROUPS = ['DIATOM', 'DINOFLAGELLATE','BROWN_ALGAE','GREEN_ALGAE', 'CRYPTOPHYTE','PICO']
    BGROUPS = ['DIATOM', 'DINOFLAGELLATE','BROWN','GREEN', 'CRYPTOPHYTE','PICO']+'_PERCENTAGE'
 ;   BGROUPS = ['MICRO','NANO','PICO']+'_PERCENTAGE'
    CCOLORS = ['CRIMSON','AQUA',          'ORANGE',     'BLUE',        'YELLOW',     'MEDIUM_AQUAMARINE']
 ;   CCOLORS = ['BLUE',        'ORANGE',     'AQUA']
        
    PY = [0,100]     
    CYRANGE = [0,100]   
    WIDTH = 6
    CFILES = []
    FOR S=0, N_ELEMENTS(SUBAREAS)-1 DO CFILES = [CFILES,FILE_SEARCH(!S.DATASETS+CDATASET+SL+'NEC'+SL+'TS_SUBAREAS'+SL+SUBPER+'*MASK_SUBAREA-NEC-PXY_1024_1024-'+SUBAREAS(S)+'*-MULTI_PRODS.SAVE')]
    
    CDATA = IDL_RESTORE(CFILES[0])          
    FOR S=1, N_ELEMENTS(CFILES)-1 DO CDATA = STRUCT_CONCAT(CDATA,IDL_RESTORE(CFILES(S)))
    CDATA = CDATA[WHERE(CDATA.PERIOD_CODE EQ 'A')]
    CDATA = CDATA[WHERE(PERIOD_2JD(CDATA.PERIOD) GE DATE_RANGE[0] AND PERIOD_2JD(CDATA.PERIOD) LE DATE_RANGE[1])]
    TAGS = TAG_NAMES(CDATA)
    POSC = WHERE(TAGS EQ 'MEAN_CHLOR_A_PAN')
    POSM = WHERE(TAGS EQ 'MEAN_MICRO_PERCENTAGE_PAN')
    POSN = WHERE(TAGS EQ 'MEAN_NANO_PERCENTAGE_PAN')
    
    W = WINDOW(DIMENSIONS=[600,400])
    AX = DATE_AXIS([19980101,20070101],/YEAR,/YY)
    XRANGE = DATE_2JD([19980101,20070107])
    FOR CTH=0, N_ELEMENTS(CODES)-1 DO BEGIN
      ADATA = CDATA[WHERE(CDATA.SUBAREA_CODE EQ CODES(CTH) AND CDATA.(WHERE(TAGS EQ 'FIRST_NAME_CHLOR_A_PAN')) NE '')] 
      ADATA = ADATA[SORT(DATE_2DOY(PERIOD_2DATE(ADATA.PERIOD)))]        
      XDATES = PERIOD_2JD(ADATA.PERIOD)    
      
      NBARS = 5
      
      
      BOTTOM = 0
      PER1 = REPLICATE(0,N_ELEMENTS(XDATES))    
      TOT = ADATA.(POSC)
      MICRO = ADATA.(POSM)
      NANO = ADATA.(POSN) + ADATA.(POSM) 
      FOR NTH = 0L, N_ELEMENTS(BGROUPS)-1 DO BEGIN
        GROUP = BGROUPS[NTH]
        POS = WHERE(TAGS EQ 'MEAN_' + GROUP + '_PAN')
        PER = ADATA.(POS)      
        OK = WHERE(PER EQ MISSINGS(PER),COUNT) & IF COUNT GE 1 THEN PER[OK] = 0.0
        IF NTH EQ 0 THEN BEGIN              
         ; IF CTH EQ 0 THEN TITLE = 'Phytoplankton Chlorophyll !8a!N!X!C'+TITLES(N) ELSE TITLE = TITLES(N)
         ; POSITION = [XPOS2,YPOS(N)-YDIF,XPOS2+XDIF,YPOS(N)]
         IF CTH EQ 0 THEN $
          P = PLOT(XDATES,REPLICATE(0,N_ELEMENTS(ADATA)),YTITLE='Chlorophyll Percent Composition',XTICKVALUE=AX.TICKV,FONT_SIZE=11,TITLE=TITLE,POSITION=POSITION,$
            XMINOR=0,YMINOR=2,YRANGE=CYRANGE,XSTYLE=1,XTICKNAME=AX.TICKNAME,/NODATA,BUFFER=BUFFER,MARGIN=MARGIN,LAYOUT=LAYOUT,/CURRENT)
          BOT = REPLICATE(0, N_ELEMENTS(ADATA))
          BAR = BARPLOT(XDATES,PER,NBARS=NBARS,INDEX=CTH,BOTTOM_VALUES=BOT,FILL_COLOR=CCOLORS[NTH],LINESTYLE=LINESTYLE,/OVERPLOT)            
        ENDIF          
        PER1 = PER + PER1          
        IF NTH GE 1 THEN BAR = BARPLOT(XDATES,PER1,NBARS=NBARS,INDEX=CTH,BOTTOM_VALUES=BOTTOM,FILL_COLOR=CCOLORS[NTH],LINESTYLE=LINESTYLE,/OVERPLOT)
        BOTTOM = PER1
      ENDFOR  
        
      
      
      
    
    ENDFOR
  stop  
  ENDIF ; DO_BAR_PLOT 
  
  
  ; *******************************************************
  IF DO_TROND_SUBAREAS GE 1 THEN BEGIN
    ; *******************************************************
    OVERWRITE = DO_TROND_SUBAREAS GE 2
    
    PAL_36,R,G,B
    
    POLYGONS = ['NORTH_SEA','LOFOTEN','GEORGES_BANK','ICELAND','WEST_GREENLAND']
    
    DIR_PLOTS  = FIX_PATH('D:\PROJECTS\ECOAP\FISHERIES')
    DIR_IMAGES = !S.IMAGES
    LANDMASK_FILE = DIR_IMAGES + 'MASK_LAND-GEQ-PXY_4096_2048-NOLAKES.PNG'
    
    LANDMASK = READ_LANDMASK(MAP='GEQ',PX=4096,PY=2048,/STRUCT)
    IMG      = READ_PNG(LANDMASK_FILE)
    ZWIN, IMG
    OLDDEVICE= !D.NAME
    MAP_GEQ
    PAL_36,R,G,B
    
    ; PP Polygons
    NS_LON=[  0.0,  5.0,  5.0,  0.0,  0.0]
    NS_LAT=[ 54.0, 54.0, 59.0, 59.0, 54.0]
    IM = MAP_DEG2IMAGE(IMG,NS_LON,NS_LAT, X=x, Y=y,AROUND=0) & POLYFILL, X, Y, COLOR=5, /DEVICE
    LF_LON=[ 10.0, 15.0, 15.0, 10.0, 10.0]
    LF_LAT=[ 65.0, 65.0, 70.0, 70.0, 65.0]
    IM = MAP_DEG2IMAGE(IMG,LF_LON,LF_LAT, X=x, Y=y,AROUND=0) & POLYFILL, X, Y, COLOR=6, /DEVICE
    GB_LON=[-77.0,-66.0,-66.0,-77.0,-77.0]
    GB_LAT=[ 40.0, 40.0, 45.0, 45.0, 40.0 ]
    IM = MAP_DEG2IMAGE(IMG,GB_LON,GB_LAT, X=x, Y=y,AROUND=0) & POLYFILL, X, Y, COLOR=7, /DEVICE
    IC_LON=[-26.0,-20.0,-20.0,-26.0,-26.0]
    IC_LAT=[ 61.0, 61.0, 66.0, 66.0, 61.0]
    IM = MAP_DEG2IMAGE(IMG,IC_LON,IC_LAT, X=x, Y=y,AROUND=0) & POLYFILL, X, Y, COLOR=8, /DEVICE
    WG_LON=[-52.0,-47.0,-47.0,-52.0,-52.0]
    WG_LAT=[ 59.0, 59.0, 64.0, 64.0, 59.0]
    IM = MAP_DEG2IMAGE(IMG,WG_LON,WG_LAT, X=x, Y=y,AROUND=0) & POLYFILL, X, Y, COLOR=9, /DEVICE
    
    IM_SUBS = TVRD()
    
    OK_IMAGE = WHERE(IMG NE 0)
    IM_SUBS(OK_IMAGE) = IMG(OK_IMAGE)
    MASK = IM_SUBS
    IMG(LANDMASK.OCEAN) = 36
    OK = WHERE(IM_SUBS GE 5)
    IMG[OK] = IM_SUBS[OK]
    IMG(LANDMASK.LAND)  = 32
    ;IMG(LANDMASK.LAKE)  = 35
    IMG(LANDMASK.COAST) = 0
    
    OK = WHERE(MASK NE 0)
    IM_SUBS[OK] = MASK[OK]
    
    EDITFILE = DIR_IMAGES + 'MASK_SUBAREA-GEQ-PXY_4096_2048-TROND_PP_POLYGONS-TO_BE_EDITED.PNG' & WRITE_PNG, EDITFILE, IM_SUBS, R,G,B
    MASKFILE = DIR_IMAGES + 'MASK_SUBAREA-GEQ-PXY_4096_2048-TROND_PP_POLYGONS.PNG'
    PNGFILE  = DIR_IMAGES + 'MASK_SUBAREA-GEQ-PXY_4096_2048-TROND_PP_POLYGONS-DISPLAY.PNG' & WRITE_PNG, PNGFILE, IMG, R,G,B
    CSVFILE  = DIR_IMAGES + 'MASK_SUBAREA-GEQ-PXY_4096_2048-TROND_PP_POLYGONS.CSV'
    SAVEFILE = DIR_IMAGES + 'MASK_SUBAREA-GEQ-PXY_4096_2048-TROND_PP_POLYGONS.SAVE'
    
    
    STRUCT1=CREATE_STRUCT('SUBAREA_CODE','','SUBAREA_NAME','','NICKNAME','')
    STRUCT1=REPLICATE(STRUCT1,3)
    STRUCT1[0].SUBAREA_CODE =0  & STRUCT1[0].SUBAREA_NAME = 'OCEAN'     & STRUCT1[0].NICKNAME='OCEAN'
    STRUCT1[1].SUBAREA_CODE =1  & STRUCT1[1].SUBAREA_NAME = 'COAST'     & STRUCT1[1].NICKNAME='COAST'
    STRUCT1(2).SUBAREA_CODE =2  & STRUCT1(2).SUBAREA_NAME = 'LAND'      & STRUCT1(2).NICKNAME='LAND'
    
    STRUCT=CREATE_STRUCT('SUBAREA_CODE','','SUBAREA_NAME','','NICKNAME','')
    STRUCT=REPLICATE(STRUCT,N_ELEMENTS(POLYGONS))
    STRUCT.SUBAREA_CODE = INDGEN(N_ELEMENTS(POLYGONS))+5
    STRUCT.SUBAREA_NAME = STRUPCASE(POLYGONS)
    STRUCT.NICKNAME     = STRUPCASE(POLYGONS)
    
    CSV = STRUCT_CONCAT(STRUCT1,STRUCT)
    
    INFILE=MASKFILE
    NOTES='MASK_SUBAREA'
    
    ;     ===> Write the Struct to a csv
    STRUCT_2CSV,CSVFILE,CSV
    OK=WHERE(CSV.SUBAREA_CODE NE MISSINGS(CSV.SUBAREA_CODE))
    SUBAREA_CODE= CSV[OK].SUBAREA_CODE
    SUBAREA_NAME= CSV[OK].SUBAREA_NAME
    DATA = READ_PNG(MASKFILE)
    
    STRUCT_SD_WRITE,SAVEFILE, IMAGE=DATA, PROD=PROD,  MAP=MAP, $
      MISSING_CODE=missing_code, MISSING_NAME=missing_name, $
      SUBAREA_CODE=SUBAREA_CODE,SUBAREA_NAME=subarea_name,$
      SCALING='LINEAR',  INTERCEPT=0.0,  SLOPE=1.0,TRANSFORMATION=TRANSFORMATION,$
      DATA_UNITS='',PERIOD=PERIOD, $
      INFILE=INFILE,$
      NOTES='MASK_SUBAREA', OVERWRITE=OVERWRITE, ERROR=ERROR
      
  ENDIF   ; DO_TROND_SUBAREAS 

END; #####################  End of Routine ################################


