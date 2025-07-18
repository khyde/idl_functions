; $ID:	MAKE_PP_SAVES.PRO,	2020-07-08-15,	USER-KJWH	$

  PRO MAKE_PP_SAVES, PP_MODELS=PP_MODELS, DIR_PP=DIR_PP, NEC_PROFILES=NEC_PROFILES,CHL_PROD=CHL_PROD,$
                     CHL_FILES=CHL_FILES, PAR_FILES=PAR_FILES, SST_FILES=SST_FILES,ACD_FILES=ACD_FILES,$
          				   CHL_RANGE=CHL_RANGE, PAR_RANGE=PAR_RANGE, SST_RANGE=SST_RANGE, ACDOM_RANGE=ACDOM_RANGE,$
          				   FILE_LABEL=FILE_LABEL, REVERSE_FILES=REVERSE_FILES, OVERWRITE=OVERWRITE, LOGLUN=LOGLUN
; NAME:
;       MAKE_PP_SAVES

; PURPOSE:
;       Calculate Primary Productivity using Behrenfeld-Falkowski Model (1997)
;
;
; KEYWORD PARAMETERS:
;				ACDOM_FILE must be the full path and name (e.g. 'D:\IDL\IMAGES\!ANNUAL-SEAWIFS-REPRO5-NEC-A_CDOM_443-MEAN.SAVE')
;   LOGLUN.............IF PROVIDED, THEN LUN FOR THE LOG FILE

; OUTPUTS:
;
; MODIFICATION HISTORY:
;       Written by:  J.E.O'Reilly, March 24, 2003.
; 			Jul 28, 2003 - TD:   Work with new file naming convention, use struct_sd_read,use struct_sd_stats
; 			Aug 21, 2003 - TD:   New land & coast file, new folder names
; 			Aug 26, 2003 - JOR:  Added reasonable data ranges for par,chl,sst; fixed land mask; Added DATA_RANGE TO mask
;				Jan 13, 2004 - JOR:  Added CHLOR_EUPHOTIC AND K_PAR to output structures
; 			Sep 30, 2004 - TD:   Add chlor+_euphotic & k_par for L3B
; 			Mar 26, 2005 - JOR:  Replaced bottom depth file: MAP_ETOPO2_2NEC_BATHY.SAVE with:
;											       New 30second resolution bottom: SRTM30-NEC-PXY_1024_1024-BATHY-SMOOTH_5.SAVE
;				Nov  8, 2006 - KJWH: Added the MASS_BAY model and additional KEYWORDS - STREAMLINED PP_SAT_MAIN
; 			Dec  4, 2006 - KJWH: Added CHL_RANGE, PAR_RANGE, SST_RANGE as additional keywords
; 			Jun 15, 2007 - KJWH: Modified the VGMB model
;       Jul 17, 2008 - TD:   Change remove SST_METHOD, add COVERAGE
;       Nov 12, 2013 - KJWH: Moved the WHERE statement to find all valid data to outside of the ALG loop, but kept WHERE statements for the OPAL and VGMB algs
;       Dec 16, 2013 - KJWH: Added DATE_SELECT function to select files in the date range
;       Apr  9, 2014 - KJWH  Replaced GET_MTIME calls with UPDATE_CHECK
;       Mar 17, 2015 - KJWH: Renamed MAKE_PP_SAVES
;                            Cleaned up and streamlined program, 
;                            Removed unnecessary text (e.g. MASKING steps), 
;                            Updated program names (e.g. changed STRUCT_SD_READ to STRUCT_READ), 
;                            Changed IF MODEL EQ xxx statements with CASE, 
;                            Removed steps to save CHLOR_EUPHOTIC and K_PAR (now saved inside the PPD structure)
;       Feb 07, 2017 - KJWH: Removed keywords MAP, BATHY_FILE, DATERANGE, NO_CHLOR_EUPHOTIC, NO_K_PAR, SENSOR, SATELLITE, COVERAGE, NO_BOTTOM_FLAG
;                            Removed DATE_SELECT(FILES) steps - This should be done in the wrapper program    
;       Feb 10, 2017 - KJWH: Updates to work with BIN files
;                            Now working with structures returned by the PP_xxxx programs - NOTE: Need to update several of the PP_XXXX programs to return structures
;                            *** Still need to update the information saved in the .SAV file with more detailed metadata                                      
;       Mar 09, 2017 - KJWH: Added steps to convert the 1D output arrays back to the original input map dimensions
;       Apr 05, 2017 - KJWH: Changed IF SST_FILE EQ [] to IF COUNTS EQ 0 and IF PAR_FILE EQ [] to IF COUNTP EQ 0
;       DEC 12, 2017 - KJWH: Added a step to check the SST map and remap if necessary
;       AUG 24, 2018 - KJWH: Added step to remap the PAR file if necessary (e.g. if you use the L3B2 SeaWiFS or MODISA PAR data with the OCCCI CHL)
;       FEB 25, 2019 - KJWH: Added LOGLUN keyword
;       JUL 29, 2020 - KJWH: Added COMPILE_OPT IDL2
;                            Replaced subscript () with []
;-
; ************************************************************************************8
  ROUTINE_NAME = 'MAKE_PP_SAVES'
  COMPILE_OPT IDL2
  
;	===> Constants
  SL = PATH_SEP() & DS=DELIMITER(/DASH) 
  IF NONE(LOGLUN)     THEN LOG_LUN = [] ELSE LOG_LUN = LOGLUN
	IF NONE(OVERWRITE)  THEN OVERWRITE = 0 
  IF NONE(SENSOR)     THEN SENSOR = 'PSAT'
  
; ===> Get file info
  FP = PARSE_IT(CHL_FILES[0],/ALL)
  MP = FP.MAP
  MS = MAPS_SIZE(MP,PX=PX,PY=PY)
  IF NONE(FILE_LABEL) THEN FILE_LABEL = FP.SENSOR+DS+FP.METHOD+DS+FP.MAP  
  WHILE HAS(FILE_LABEL,'--') DO FILE_LABEL = REPLACE(FILE_LABEL,'--','-')
    
; ===> Check PP models
  IF NONE(PP_MODELS) THEN MODELS = 'VGPM2A' ELSE MODELS = PP_MODELS
  VALID = VALIDS('ALGS',MODELS,/VALID)
  OK = WHERE(VALID EQ 0,COUNT)
  IF COUNT GE 1 THEN PLUN, LOG_LUN, 'ERROR: Invalid PP_MODELS - ',MODELS[OK]
  OK = WHERE(VALID EQ 1,COUNT)
  IF COUNT GE 1 THEN MODELS = MODELS[OK] ELSE GOTO, DONE
		
; ===> Valid Satellite Data Ranges 
  IF N_ELEMENTS(CHL_RANGE) NE 2 THEN _CHL_RANGE = [0.0  , 189.0] ELSE _CHL_RANGE = CHL_RANGE  ; note must be 189.0 or less to avoid the 32766's that are appearing due to rounding errors in the fortran ???
  IF N_ELEMENTS(PAR_RANGE) NE 2 THEN _PAR_RANGE = [0.0  ,  75.0] ELSE _PAR_RANGE = PAR_RANGE
  IF N_ELEMENTS(SST_RANGE) NE 2 THEN _SST_RANGE = [-3.0 ,  37.0] ELSE _SST_RANGE = SST_RANGE
  IF N_ELEMENTS(ACD_RANGE) NE 2 THEN _ACD_RANGE = [0.0  ,  10.0] ELSE _ACD_RANGE = ACD_RANGE
  NOTES =        'MAX CHLOR_A RANGE: '+ NUM2STR(_CHL_RANGE[0]) +' TO ' + NUM2STR(_CHL_RANGE[1])
  NOTES = [NOTES,'MAX PAR RANGE: '    + NUM2STR(_PAR_RANGE[0]) +' TO ' + NUM2STR(_PAR_RANGE[1])]
  NOTES = [NOTES,'MAX SST RANGE: '    + NUM2STR(_SST_RANGE[0]) +' TO ' + NUM2STR(_SST_RANGE[1])]
  NOTES = [NOTES,'MAX ACDOM RANGE: '  + NUM2STR(_ACD_RANGE[0]) +' TO ' + NUM2STR(_ACD_RANGE[1])]

;	===> Output Directories
  DIR_MODELS = DIR_PP + 'PPD-' + MODELS + SL
  DIR_TEST,DIR_MODELS
    
; ===> Determine input files and map 
	IF NONE(CHL_FILES) THEN GOTO, DONE 
	IF NONE(PAR_FILES) THEN GOTO, DONE 
	IF NONE(SST_FILES) THEN GOTO, DONE 
	IF NONE(ACD_FILES) THEN ACD_FILES = '' ; Only need ACD_FILES for OPAL - Can continue running other models without ACD data 
	  
  IF KEY(REVERSE_DATES) THEN CHL_FILES = REVERSE(CHL_FILES)
  
  FP_PAR  = PARSE_IT(PAR_FILES)
  FP_SST  = PARSE_IT(SST_FILES)
  FP_ACD  = PARSE_IT(ACD_FILES)

; ====> Get map related data
  IF HAS(MODELS,'VGPM2A') OR HAS(MODELS,'OPAL') THEN BOTTOM = READ_BATHY(MAP=MAP)
  IF KEY(NEC_PROFILES) THEN LL = MAPS_2LONLAT(MAP)
      
; ===> Loop through files  
	FOR FTH=0L, N_ELEMENTS(CHL_FILES)-1 DO BEGIN
		CHL_FILE  = CHL_FILES[FTH]
		FPC    = PARSE_IT(CHL_FILE,/ALL)
		PERIOD = FPC.PERIOD
		DP     = DATE_PARSE(PERIOD_2DATE(PERIOD))
		
;   =====> Find the files for each subset
		PAR_FILE = PAR_FILES[WHERE(FP_PAR.PERIOD EQ PERIOD,/NULL,COUNTP)] & FPP = PARSE_IT(PAR_FILE,/ALL) & IF COUNTP EQ 0 THEN CONTINUE & IF COUNTP NE 1 THEN MESSAGE, 'ERROR: More than 1 PAR file found for period ' + PERIOD 
		SST_FILE = SST_FILES[WHERE(FP_SST.PERIOD EQ PERIOD,/NULL,COUNTS)] & FPS = PARSE_IT(SST_FILE,/ALL) & IF COUNTS EQ 0 THEN CONTINUE & IF COUNTS NE 1 THEN MESSAGE, 'ERROR: More than 1 SST file found for period ' + PERIOD
		ACD_FILE = ACD_FILES[WHERE(FP_ACD.PERIOD EQ PERIOD,/NULL,COUNTA)] & FPA = PARSE_IT(ACD_FILE,/ALL)                                & IF COUNTA GT 1 THEN MESSAGE, 'ERROR: More than 1 CDM file found for period ' + PERIOD
		
;		===> Determine which models need to run		
		_MODELS = []
		FOR PTH = 0L, N_ELEMENTS(MODELS)-1 DO BEGIN
			ALG = MODELS[PTH]
			IF VALIDS('SENSORS',DIR_PP,DELIM=SL) NE VALIDS('SENSORS',FILE_LABEL) THEN FL = REPLACE(FILE_LABEL,VALIDS('SENSORS',FILE_LABEL),VALIDS('SENSORS',DIR_PP)) ELSE FL = FILE_LABEL
	    SAVEFILE = DIR_PP+'PPD-'+ALG+SL+PERIOD+DS+FL+DS+'PPD-'+ALG+'.SAV'
	    CASE ALG OF
			  'OPAL': IF FILE_MAKE([CHL_FILE,PAR_FILE,SST_FILE,ACD_FILE],SAVEFILE,OVERWRITE=OVERWRITE) EQ 1 THEN _MODELS=[_MODELS,ALG]
				'VGMB': IF FILE_MAKE([CHL_FILE,PAR_FILE],                  SAVEFILE,OVERWRITE=OVERWRITE) EQ 1 THEN _MODELS=[_MODELS,ALG]
				ELSE:   IF FILE_MAKE([CHL_FILE,PAR_FILE,SST_FILE],         SAVEFILE,OVERWRITE=OVERWRITE) EQ 1 THEN _MODELS=[_MODELS,ALG]  
      ENDCASE  
		ENDFOR
		IF _MODELS EQ [] THEN CONTINUE

;   ===> Read the data
		IF STRUPCASE(FPC.EXT) EQ 'NC' THEN CHL_SAT=READ_NC(CHL_FILE,PRODS=CHL_PROD,/DATA, BINS=CBINS) ELSE CHL_SAT = STRUCT_READ(CHL_FILE,BINS=CBINS,COUNT=COUNTC)
		IF STRUPCASE(FPP.EXT) EQ 'NC' THEN PAR_SAT=READ_NC(PAR_FILE,PRODS='PAR',/DATA, BINS=PBINS)    ELSE PAR_SAT = STRUCT_READ(PAR_FILE,BINS=PBINS,COUNT=COUNTP) 
		IF STRUPCASE(FPS.EXT) EQ 'NC' THEN SST_SAT=READ_NC(SST_FILE,PRODS='SST',/DATA, BINS=SBINS)    ELSE SST_SAT = STRUCT_READ(SST_FILE,BINS=SBINS,COUNT=COUNTS) 

;   ===> Check that the files were open correctly
    FILECHECK = [IDLTYPE(CHL_SAT),IDLTYPE(PAR_SAT),IDLTYPE(SST_SAT)]
    OK = WHERE(FILECHECK EQ 'STRING',COUNT)
    IF COUNT GT 0 THEN BEGIN
      PLUN, LOG_LUN, 'ERROR: Reading the files for ' + SAVEFILE
      CONTINUE 
    ENDIF

;   ===> Remap PAR data if not the same map as CHL    
    IF FPC.MAP NE FPP.MAP THEN BEGIN
      PAR_SAT = MAPS_REMAP(PAR_SAT,MAP_IN=FPP.MAP,MAP_OUT=FPC.MAP,BINS=PBINS)
      PBINS = MAPS_L3B_BINS(FPC.MAP)
    ENDIF

;   ===> Remap SST data if not the same map as CHL
		IF FPS.MAP NE FPC.MAP THEN BEGIN
		  SST_SAT = MAPS_REMAP(SST_SAT,MAP_IN=FPS.MAP,MAP_OUT=FPC.MAP,BINS=SBINS)
		  SBINS = MAPS_L3B_BINS(FPC.MAP)
		ENDIF
		
;   ===> If data has subset BINS, convert to full BIN array		
		BLK = FLTARR(PY) & BLK[*] = MISSINGS(0.0)
		IF ANY(CBINS) THEN IF N_ELEMENTS(CBINS) NE PY THEN CHL_SAT = MAPS_L3B_2ARR(CHL_SAT,MP=MP,BINS=CBINS)
		IF ANY(PBINS) THEN IF N_ELEMENTS(PBINS) NE PY THEN PAR_SAT = MAPS_L3B_2ARR(PAR_SAT,MP=MP,BINS=PBINS)
		IF ANY(SBINS) THEN IF N_ELEMENTS(SBINS) NE PY THEN SST_SAT = MAPS_L3B_2ARR(SST_SAT,MP=MP,BINS=SBINS)
		  		
		OKALL = WHERE(CHL_SAT NE MISSINGS(CHL_SAT) AND CHL_SAT GT _CHL_RANGE[0] AND CHL_SAT LT _CHL_RANGE[1] AND $
            		  PAR_SAT NE MISSINGS(PAR_SAT) AND PAR_SAT GT _PAR_RANGE[0] AND PAR_SAT LT _PAR_RANGE[1] AND $
             		  SST_SAT NE MISSINGS(SST_SAT) AND SST_SAT GT _SST_RANGE[0] AND SST_SAT LT _SST_RANGE[1],COUNT_ALL)
    IF COUNT_ALL EQ 0 THEN PLUN, LOG_LUN, 'No valid data found, SKIPPING ' + PERIOD+DS+FILE_LABEL+DS+'PPD-'+_MODELS[0]+'.SAV'
    IF COUNT_ALL EQ 0 THEN CONTINUE ; Continue if no valid data
    
;   =====> Calculate Day Length for the given map
    DAY_LENGTH = I_SUN_KIRK_DAY_LENGTH_MAP(DP.IDOY,MAP=MP)
    SZ = SIZEXYZ(DAY_LENGTH,PX=DPX,PY=DPY) 
    IF DPX NE PX OR DPY NE PY THEN STOP
    
    NOTES = [NOTES,'DAY LENGTH RANGE: ' + NUM2STR(MIN(DAY_LENGTH))     + ' To ' + NUM2STR(MAX(DAY_LENGTH))]
    NOTES = [NOTES,'CHL Range: '        + NUM2STR(MIN(CHL_SAT[OKALL])) + ' To ' + NUM2STR(MAX(CHL_SAT[OKALL]))]
    NOTES = [NOTES,'PAR RANGE: '        + NUM2STR(MIN(PAR_SAT[OKALL])) + ' To ' + NUM2STR(MAX(PAR_SAT[OKALL]))]
    NOTES = [NOTES,'SST RANGE: '        + NUM2STR(MIN(SST_SAT[OKALL])) + ' To ' + NUM2STR(MAX(SST_SAT[OKALL]))]
    
;   ===> Loop through PP Models
		FOR PTH = 0L, N_ELEMENTS(_MODELS)-1 DO BEGIN
			ALG = _MODELS[PTH]			
	    SAVEFILE = DIR_PP + 'PPD-'+ALG+SL+PERIOD+DS+FILE_LABEL+DS+'PPD-'+ALG+'.SAV'
	    PLUN, LOG_LUN, 'Running: ' + ALG + ' model for: ' + SAVEFILE
		  OK_ALL = OKALL ; Reset OK_ALL in case it was overwritten by a previous model run (e.g. OPAL has a special OK_ALL = WHERE() statement)
		
;   ======> Make dummy output arrays
            
		  CASE ALG OF		  
  			'VGPM': BEGIN			 
  			  INFILES = [CHL_FILE,PAR_FILE,SST_FILE]
  			  IF FILE_MAKE(INFILES,SAVEFILE,OVERWRITE=OVERWRITE) EQ 0 THEN GOTO, SKIP_MODEL  
         	PPD=PP_VGPM(CHL_SAT=CHL_SAT[OK_ALL], SST=SST_SAT[OK_ALL], PAR=PAR_SAT[OK_ALL], DAY_LENGTH=DAY_LENGTH[OK_ALL]) 
        END ; VGPM
  
  			'VGPM_MBZ':  BEGIN			  
  				INFILES = [CHL_FILE,PAR_FILE,SST_FILE]
          IF FILE_MAKE(INFILES,SAVEFILE,OVERWRITE=OVERWRITE) EQ 0 THEN GOTO, SKIP_MODEL  
   stop ; need to update PP_xxx to return a structure (see PP_VGPM)     
     ;     PPD[OK_ALL]=PP_VGPM_MBZ(CHL_SAT=CHL_SAT[OK_ALL], SST=SST_SAT[OK_ALL], PAR=PAR_SAT[OK_ALL], DAY_LENGTH=day_length[OK_ALL],CHLOR_EUPHOTIC=_CHLOR_EUPHOTIC,K_PAR=_K_PAR) 
        END ; VGPM_MBZ

			  'VGPM2': BEGIN       
          INFILES = [CHL_FILE,PAR_FILE,SST_FILE]
          IF FILE_MAKE(INFILES,SAVEFILE,OVERWRITE=OVERWRITE) EQ 0 THEN GOTO, SKIP_MODEL 
          PPD=PP_VGPM2(CHL=CHL_SAT[OK_ALL], SST=SST_SAT[OK_ALL], PAR=PAR_SAT[OK_ALL], DAY_LENGTH=day_length[OK_ALL]) 
        END ; VGPM2

        'VGPM2_MBZ': BEGIN       
          INFILES = [CHL_FILE,PAR_FILE,SST_FILE]
          IF FILE_MAKE(INFILES,SAVEFILE,OVERWRITE=OVERWRITE) EQ 0 THEN GOTO, SKIP_MODEL  
    stop ; need to update PP_xxx to return a structure (see PP_VGPM)            
          PPD[OK_ALL]=PP_VGPM2_MBZ(CHL_SAT=CHL_SAT[OK_ALL], SST=SST_SAT[OK_ALL], PAR=PAR_SAT[OK_ALL], DAY_LENGTH=day_length[OK_ALL],CHLOR_EUPHOTIC=_CHLOR_EUPHOTIC,K_PAR=_K_PAR) 
        END ; VGPM2_MBZ

			  'VGPM2A': BEGIN
  				INFILES = [CHL_FILE,PAR_FILE,SST_FILE]
  				IF FILE_MAKE(INFILES,SAVEFILE,OVERWRITE=OVERWRITE) EQ 0 THEN GOTO, SKIP_MODEL  
  				IF N_ELEMENTS(BOTTOM) EQ 1 OR BOTTOM EQ [] THEN GOTO, SKIP_MODEL  ; ===> Check for bottom data
  stop ; need to update PP_xxx to return a structure (see PP_VGPM)      				
      		PPD[OK_ALL]=PP_VGPM2A(CHL_SAT=CHL_SAT[OK_ALL],SST=SST_SAT[OK_ALL],PAR=PAR_SAT[OK_ALL],DAY_LENGTH=DAY_LENGTH[OK_ALL],BOTTOM_DEPTH=BOTTOM[OK_ALL],BOTTOM_FLAG=_BOTTOM_FLAG,CHLOR_EUPHOTIC=_CHLOR_EUPHOTIC,K_PAR=_K_PAR)         
   			END ; VGPM2A

			  'OPAL':  BEGIN
  				IF ACD_FILE EQ '' THEN BEGIN
  					PLUN, LOG_LUN,'MUST PROVIDE ACDOM_FILE AND SST_FILE FOR OPAL ALG, SKIPPING ' + ALG + ' MODEL FOR: ' + SAVEFILE  
  				 	GOTO, SKIP_MODEL 
  				ENDIF
          INFILES = [CHL_FILE,PAR_FILE,SST_FILE,ACD_FILE]
          IF FILE_MAKE(INFILES,SAVEFILE,OVERWRITE=OVERWRITE) EQ 0 THEN GOTO, SKIP_MODEL  
          IF N_ELEMENTS(BOTTOM) EQ 1 OR BOTTOM EQ [] THEN GOTO, SKIP_MODEL 
      		ACD_SAT=STRUCT_READ(ACD_FILE,STRUCT=SACD)
  				IF SACD.ALG EQ 'GSM' THEN BEGIN
  					OK=WHERE(ACD_SAT EQ -999.000,COUNT)
  					IF COUNT GT 0 THEN ACD_SAT[OK]=MISSINGS(0.0)
  				ENDIF
          IF STRUCT_HAS(SACD,'BINS') THEN IF N_ELEMENTS(SACD.BINS) NE PY THEN BEGIN                   ; If the structure has the BINS tag then recreate the full BIN
  				  ABLK = BLK
  				  ABLK[ACHL.BINS] = ACD_SAT
  				  ACD_SAT = FLTARR(1,PY)
  				  ACD_SAT[0,*] = ABLK & GONE, ABLK
  				ENDIF

		      OK_ALL = WHERE(CHL_SAT NE MISSINGS(CHL_SAT) AND CHL_SAT GT _CHL_RANGE[0]	AND CHL_SAT LT _CHL_RANGE[1] AND $
                    		 PAR_SAT NE MISSINGS(PAR_SAT) AND PAR_SAT GT _PAR_RANGE[0]	AND PAR_SAT LT _PAR_RANGE[1] AND $
                    		 ACD_SAT NE MISSINGS(ACD_SAT) AND ACD_SAT GT _ACD_RANGE[0] AND ACD_SAT LT _ACD_RANGE[1] AND $
                    		 SST_SAT NE MISSINGS(SST_SAT) AND SST_SAT GT _SST_RANGE[0]	AND SST_SAT LT _SST_RANGE[1],COUNT_OPAL)
          IF COUNT_OPAL EQ 0 THEN GOTO, SKIP_MODEL 
          
;    	  	===> Check the cdom data and convert to ACDOM_443 if needed
      		IF SACD.ALG EQ 'KM'                THEN ACD_SAT[OK_ALL] = A_CDOM_300_2_A_CDOM_443(ACD_SAT[OK_ALL])
      		IF STRPOS(SACD.PROD,'355') GE 1 THEN ACD_SAT[OK_ALL] = ACD_SAT[OK_ALL]*EXP(-0.021*(443-355))
    	    NOTES = [NOTES,'ACDOM RANGE: ' + NUM2STR(MIN(ACD_SAT[OK_ALL]))   +' TO ' + NUM2STR(MAX(ACD_SAT[OK_ALL]))]
    	    
    	    IF KEY(NEC_PROFILES) THEN BEGIN & LON = LL.LON[OK_ALL] & LAT = LL.LAT[OK_ALL] & ENDIF
   stop ; need to update PP_xxx to return a structure (see PP_VGPM)       	    
    	    PPD[OK_ALL]=PP_OPAL(CHL=CHL_SAT[OK_ALL],SST=SST_SAT[OK_ALL],PAR=PAR_SAT[OK_ALL],KX=ACD_SAT[OK_ALL],BOTTOM_DEPTH=BOTTOM[OK_ALL],BOTTOM_FLAG=BOTTOM_FLAG,CHLOR_EUPHOTIC=_CHLOR_EUPHOTIC,K_PAR=_K_PAR,$
    	                         NEC_PROFILES=NEC_PROFILES, LON=LON, LAT=LAT, DOY=DP.IDOY, NUM=NUM)    
        END ; 'OPAL' 

        'MARRA': BEGIN
				  INFILES = [CHL_FILE,PAR_FILE,SST_FILE,BATHY_FILE]
				  IF FILE_MAKE(INFILES,SAVEFILE,OVERWRITE=OVERWRITE) EQ 0 THEN GOTO, SKIP_MODEL  
				  IF N_ELEMENTS(BOTTOM) EQ 1 OR BOTTOM EQ [] THEN GOTO, SKIP_MODEL  ; ===> Check for bottom data
		 stop ; need to update PP_xxx to return a structure (see PP_VGPM)     		  
       ;   PPD[OK_ALL]=PP_MARRA(CHL_SAT=CHL_SAT[OK_ALL], SST=SST_SAT[OK_ALL], PAR=PAR_SAT[OK_ALL], DAY_LENGTH=DAY_LENGTH[OK_ALL], BOTTOM_DEPTH=BOTTOM[OK_ALL], CHLOR_EUPHOTIC=_CHLOR_EUPHOTIC,K_PAR=_K_PAR) 
        END ; MARRA

        'VGMB': BEGIN
          INFILES = [CHL_FILE,PAR_FILE]
          IF FILE_MAKE(INFILES,SAVEFILE,OVERWRITE=OVERWRITE) EQ 0 THEN GOTO, SKIP_MODEL  
		      OK_ALL = WHERE(CHL_SAT NE MISSINGS(CHL_SAT) AND CHL_SAT GT _CHL_RANGE[0] AND CHL_SAT LT _CHL_RANGE[1] AND $
	    		               PAR_SAT NE MISSINGS(PAR_SAT) AND PAR_SAT GT _PAR_RANGE[0] AND PAR_SAT LT _PAR_RANGE[1], COUNT_VGMB)
	   stop ; need to update PP_xxx to return a structure (see PP_VGPM)       		               
        	PPD[OK_ALL]=PP_VGMB(CHL_SAT=CHL_SAT[OK_ALL],PAR=PAR_SAT[OK_ALL],DAY_LENGTH=DAY_LENGTH[OK_ALL],CHLOR_EUPHOTIC=_CHLOR_EUPHOTIC,K_PAR=_K_PAR) 
 			  END ; 'VGMB'
 	    ENDCASE		

      NOTES = [NOTES,'PPD Range: ' + NUM2STR(MIN(PPD.PPD)) +' To ' + NUM2STR(MAX(PPD.PPD,/ABSOLUTE))]
 			DATA_UNITS=UNITS('PPD')
 			
 			IF HAS(MP,'L3B') THEN PPD = CREATE_STRUCT('BINS',OK_ALL,'NBINS',COUNT_ALL,'TOTAL_BINS',MS.PY,PPD) ELSE BEGIN ; Add BIN info to the PPD structure
        SZ = SIZEXYZ(PPD.PPD,PX=OPX,PY=OPY)
        IF OPX NE PX OR OPY NE PY THEN BEGIN
          STRUCT = []
          TAGS = TAG_NAMES(PPD)
          FOR N=0, N_TAGS(PPD)-1 DO BEGIN ; LOOP THROUGH STRUCTURE TAGS
            TMP = CHL_SAT & TMP[*] = MISSINGS(CHL_SAT)
            TMP[OK_ALL] = PPD.(N)       ; CONVERT 1D ARRAY BACK TO MAP DIMENSIONS
            STRUCT = CREATE_STRUCT(STRUCT,TAGS(N),TMP)
          ENDFOR  
          PPD = STRUCT & GONE, STRUCT & GONE, TMP & GONE, BLK
        ENDIF ; IF DIMENSIONS DON'T MATCH
      ENDELSE ; IF MP NE 'L3B'
 			  
      STRUCT_WRITE, PPD, DATA=PPD.PPD, FILE=SAVEFILE, PROD='PPD', MISSING_CODE=MISSINGS(PPD), ALG=ALG, DATA_UNITS=UNITS('PPD'), SENSOR=SENSOR, INFILE=INFILES, NOTES=NOTES, LOGLUN=LOG_LUN
      GONE, PPD
      SKIP_MODEL:  
    ENDFOR ;FOR PTH = 0L, N_ELEMENTS(_MODELS)-1 DO BEGIN
    GONE,CHL_SAT
    GONE,PAR_SAT
    GONE,SST_SAT
    GONE,ACD_SAT
  ENDFOR ;FOR FTH=0L, N_ELEMENTS(FSETS)-1 DO BEGIN
	DONE:
	PLUN, LOG_LUN, ROUTINE_NAME+ ' FINISHED'
END; END OF PROGRAM




