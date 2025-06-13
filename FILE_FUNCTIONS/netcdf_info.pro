; $ID:	NETCDF_INFO.PRO,	2023-09-21-13,	USER-KJWH	$

  FUNCTION NETCDF_INFO, FILES

;+
; NAME:
;   NETCDF_INFO
;
; PURPOSE:
;   This function will extract the necessary info needed from a file name and NETCDF_MAIN files to create the global metadata for the output netcdf file
;
; CATEGORY:
;   FILE_FUNCTIONS
;
; CALLING SEQUENCE:
;   Result = NETCDF_INFO(FILES)
;
; REQUIRED INPUTS:
;   FILES: An array of files to parse and use to generate the metadata
;
; OPTIONAL INPUTS:
;
; KEYWORD PARAMETERS:
;   
; OUTPUTS:
;   This function returns a structure with the metadata information
;
; OPTIONAL OUTPUTS:
;   
; COMMON BLOCKS:
;   _NETCDF_INFO..... Stores the information from the main netcdf files
;
; SIDE EFFECTS:
;   None
;
; RESTRICTIONS:
;   This program relies on the maine netcdf files NETCDF_SENSORS.csv and NETCDF_ALG_REFERENCES to be current and accurate
;
; EXAMPLE:
;
;
; NOTES:
;
; PROCEDURE:
;
;
; EXAMPLE:
;   ST, NETCDF_INFO(!S.OC + 'MODISA/L3B2/STATS/CHLOR_A-OCI/M_201404-MODISA-R2015-L3B2-CHLOR_A-OCI-STATS.SAV') 
;
; NOTES:
;   Will only work with standard NEFSC created .SAV files in the DATASETS directory
;   NetCDF Metadata conventions: http://cfconventions.org/Data/cf-conventions/cf-conventions-1.7/cf-conventions.html#description-of-file-contents
;
;   
; COPYRIGHT: 
; Copyright (C) 2018, Department of Commerce, National Oceanic and Atmospheric Administration, National Marine Fisheries Service,
;   Northeast Fisheries Science Center, Narragansett Laboratory.
;   This software may be used, copied, or redistributed as long as it is not sold and this copyright notice is reproduced on each copy made.
;   This routine is provided AS IS without any express or implied warranties whatsoever.
;
; AUTHOR:
;   This program was written on March 12, 2019 by Kimberly J. W. Hyde, Northeast Fisheries Science Center | NOAA Fisheries | U.S. Department of Commerce, 28 Tarzwell Dr, Narragansett, RI 02882
;         
;
; MODIFICATION HISTORY:
;  Mar 12, 2019 by K.J.W. Hyde, NOAA/NEFSC/Narragansett Laboratory, 28 Tarzwell Drive, 02882 (kimberly.hyde@noaa.gov)
;	 Mar 18, 2019 - KJWH: Added CONTIBUTOR information extracted from NETCDF_SENSORS.csv
;	 Mar 25, 2019 - KJWH: Updated ALG_REFERENCE to now use NETCDF_ALG_REFERENCES.csv file
;	                      Added COMMON block for the main netcdf files (SENSOR, ALG_REFERENCES and GLOBAL)
;	                      Updated the "algorithm" portion of the title
;  Mar 27, 2019 - KJWH: Added TIME, DURATION and CLIMATOLOGY information
;  Apr 11, 2019 - KJWH: Changed PERIOD to PERIOD_CODE in the output structure
;                       Now using PERIOD_NAME in the output title
;  May 17, 2019 - KJWH: Added DIR_SUITE keyword for when the files are not in one of the default SUITE directories (e.g. the input file is in !S.PROJECTS)                     
;                       Added MONTH3 period info
;  Jun 17, 2020 - KJWH: Added information for the 'DD' period code   
;  Jun 25, 2020 - KJWH: Updated the OC-CCI IOP product information (added ATOT, APH, ADG, BBP)   
;  Aug 12, 2020 - KJWH: Added COMPILE_OPT IDL2
;                       Changed subscript () to []
;                       Removed MAPIN and MAPOUT keywords because they are not used
;                       Added documentation    
;                       Moved from PROGRAMS to FILE_FUNCTIONS    
;                       Added the algorithm name to the output structure STR[VALID].ALG = ALGS[OK}.ALG       
;  Dec 23, 2020 - KJWH: Changed IF SUITE EQ SL THEN MESSAGE, 'ERROR: to IF COUNT GT 0 THEN MESSAGE, 'ERROR:
;  Dec 29, 2020 - KJWH: Added WEEK period code 
;  Jan 27, 2021 - KJWH: Added TIME_UNITS and TIME_ORIGIN to the output structure
;  Oct 06, 2021 - KJWH: Changed the name of the MASTER files to MAIN and changed the location from IDL_NETCDF to IDL_MAINFILES
;  Mar 14, 2021 - KJWH: Now using PERIODS_READ to get the period code information
;  Jun 30, 2022 - KJWH: Removed DIR_SUITE and other SUITE related variables since the !S.DATASETS is no longer separated by "suites"
;  Oct 07, 2022 - KJWH: Added DD3 and DD8 period code durations
;-
;	****************************************************************************************************
	ROUTINE_NAME = 'NETCDF_INFO'
	COMPILE_OPT IDL2
	SL = PATH_SEP()
	
	COMMON _NETCDF_INFO, SENS, ALGS, MTIMES 
	
	MAINS = ['S','A']
	SMAIN = !S.MAINFILES + 'NETCDF_SENSORS.csv'
	AMAIN = !S.MAINFILES + 'NETCDF_ALG_REFERENCES.csv'
	MFILES = [SMAIN,AMAIN]
	IF N_ELEMENTS(MTIMES) NE 2 THEN MTIMES = GET_MTIME(MFILES)
	
	FOR N=0, N_ELEMENTS(MAINS)-1 DO BEGIN
	  IF GET_MTIME(MFILES[N]) GT MTIMES[N] THEN INIT = 1 ELSE INIT = 0
	  CASE MAINS[N] OF 
	    'S': BEGIN IF NONE(SENS)   OR KEY(INIT) THEN BEGIN & SENS   = CSV_READ(SMAIN) & MTIMES[N] = GET_MTIME(SMAIN) & ENDIF & END
	    'A': BEGIN IF NONE(ALGS)   OR KEY(INIT) THEN BEGIN & ALGS   = CSV_READ(AMAIN) & MTIMES[N] = GET_MTIME(AMAIN) & ENDIF & END
	  ENDCASE
	ENDFOR
	
	STR = REPLICATE(STRUCT_2MISSINGS(CREATE_STRUCT('FILE','','NC_NAME','','TITLE','','ID','','HISTORY','','SUMMARY','','KEYWORDS','',$
	  'MAP', '', 'RESOLUTION','', $
	  'PERIOD_CODE','','PERIOD_NAME','','PERIOD_METHOD','','CLIM_BOUNDS','','CLIM_METHOD','','CLIM_START',0.0,'CLIM_END',0.0,$
	  'TIME',0.0D,'TIME_UNITS','','TIME_ORIGIN','','TIME_START','','TIME_END','','DURATION','',$
	  'IOOS_CATEGORY','','STATISTIC_LABEL','','LEVEL','','PROD','','PROD_NAME','','ALG', '','ALG_NAME','','ALG_REFERENCE','','UNITS','','SENSOR','','PLATFORM','','PLATFORM_TYPE','', 'SHORT_NAME','',$
	  'CONTRIBUTOR_NAME','','CONTRIBUTOR_ROLE','','SOURCE_DATA_URL','','SOURCE_DATA_DOI','','SOURCE_DATA_LEVEL','','SOURCE_DATA_VERSION','','SOURCE_DATA_ACCESS_DATE','')),N_ELEMENTS(FILES))
			
	FP = PARSE_IT(FILES,/ALL)
	MPIN = FP.MAP
	IF N_ELEMENTS(MAP_OUT) EQ 1 THEN MPOUT = REPLICATE(MAP_OUT,N_ELEMENTS(FILES))
	IF NONE(MAP_OUT) THEN MPOUT = FP.MAP
	IF N_ELEMENTS(MPOUT) NE N_ELEMENTS(FILES) THEN MESSAGE, 'ERROR: Check MAP_OUT information'
	
	
;	SUITE = SUITEDIR
;	IF NONE(DIR_SUITE) THEN FOR T=0, N_ELEMENTS(SUITEDIR)-1 DO SUITE[T] = STRMID(SUITEDIR[T],0,STRPOS(SUITEDIR[T],SL)) $ ; Determine SUITE (OC, SST, PP) the file 
;	                   ELSE SUITE = STRMID(REPLACE(DIR_SUITE,!S.DATASETS,''),0,8)
;	SUITE = REMOVE_LAST_SLASH(SUITE)
;	OK = WHERE_STRING(SUITE, SL, COUNT)
;	WHILE COUNT GT 0 DO BEGIN
;	  SUITE[OK] = FILE_DIRNAME(SUITE[OK]) ; Remove all text after the first slash (including the slash) to get the SUITE (OC, SST, PP, FRONTS) name
;   OK = WHERE_STRING(SUITE, SL, COUNT)
;    IF COUNT GT 0 THEN MESSAGE, 'ERROR: Check file name and SUITE directory'
;	ENDWHILE
;
;	B = WHERE_SETS(SUITE)
;	FOR N=0, N_ELEMENTS(B)-1 DO BEGIN
;	  SUBS = WHERE_SETS_SUBS(B[N])
;    CASE B[N].VALUE OF
;      'OC':  STR[SUBS].IOOS_CATEGORY = 'Ocean Color'
;      'SST': STR[SUBS].IOOS_CATEGORY = 'Temperature'
;      'PP':  STR[SUBS].IOOS_CATEGORY = 'Productivity'
;      'FRONTS': STR[SUBS].IOOS_CATEGORY = 'Other'
;      'BATHY': STR[SUBS].IOOS_CATEGORY = 'Bathymetry'
;      '': STR[SUBS].IOOS_CATEGORY = 'NA'
;    ENDCASE
;  ENDFOR    
	
	PR = PRODS_READ()
	FP = PARSE_IT(FILES,/ALL)
	STR.FILE = FP.NAME_EXT
	OK = WHERE_MATCH(PR.PROD,FP.PROD,VALID=VALID)
	SUITE = PR[OK].SUITE
	
  ; ===> Get SOURCE information based on the SENSOR
  OK = WHERE_MATCH(STRUPCASE(SENS.SUITE+'_'+SENS.SENSOR+'_'+SENS.SOURCE_DATA_VERSION),STRUPCASE(SUITE+'_'+FP.SENSOR+'_'+FP.METHOD), COUNT, VALID=VALID, NINVALID=NINVALID, INVALID=INVALID)
  IF NINVALID GT 0 THEN MESSAGE, 'ERROR: Check NETCDF_SENSORS for the missing suite - ' + SUITE[INVALID] + '_' + FP[INVALID].SENSOR +'_'+FP[INVALID].METHOD
  STR[VALID].CONTRIBUTOR_NAME         = SENS[OK].CONTRIBUTOR_NAME
  STR[VALID].CONTRIBUTOR_ROLE         = SENS[OK].CONTRIBUTOR_ROLE
  STR[VALID].SOURCE_DATA_URL          = SENS[OK].SOURCE_DATA_URL
  STR[VALID].SOURCE_DATA_LEVEL        = SENS[OK].SOURCE_DATA_LEVEL
  STR[VALID].SOURCE_DATA_DOI          = SENS[OK].SOURCE_DATA_DOI
  STR[VALID].SENSOR                   = SENS[OK].SENSOR_NAME
  STR[VALID].PLATFORM                 = SENS[OK].PLATFORM
  STR[VALID].PLATFORM_TYPE            = SENS[OK].PLATFORM_TYPE
  STR[VALID].SOURCE_DATA_VERSION      = SENS[OK].SOURCE_DATA_VERSION
  STR[VALID].SOURCE_DATA_ACCESS_DATE  = SENS[OK].SOURCE_DATA_ACCESS_DATE 
  STR[VALID].SHORT_NAME               = SENS[OK].SHORTNAME
  
	; ===> Get PERIOD description based on the period code
	;PCS = ['','S',    'D',    'D3',   'D8',   'DD',                         'DOY',                           'W',             'WEEK',                 'M',      'M3',                'MONTH',                 'MONTH3',                           'A',     'ANNUAL']
	;PCL = ['Undefined','Daily','Daily','3-day','8-day','Daily (merged daily files)', 'Climatological day of the year','Weekly (7-day)','Climatological weekly','Monthly','3-month (seasonal)','Climatological monthly','Climatological 3-month (seasonal)','Annual','Climatological annual']
	
	PCS = PERIODS_READ()
	IF PCS EQ [] THEN MESSAGE, 'ERROR: ' + FP[0].PERIOD_CODE + ' is not a valid PERIOD'
  OK = WHERE_MATCH(PCS.PERIOD_CODE,FP.PERIOD_CODE,COUNT,VALID=VALID,NINVALID=NINVALID,INVALID=INVALID)

  STR[VALID].PERIOD_CODE = PCS[OK].PERIOD_CODE
	STR[VALID].PERIOD_NAME = PCS[OK].PERIOD_DESCRIPTION
	
	IF NINVALID GT 0 THEN MESSAGE, ROUNDS(NINVALID) + ' periods not identified'
	OK = WHERE(STR.PERIOD_CODE EQ 'ANNUAL',COUNT)
	IF COUNT GE 1 THEN STR[OK].PERIOD_METHOD = 'Annual statistics use monthly input data'
	
	; ===> Get the TIME information based on the period code
	B = WHERE_SETS(FP.PERIOD_CODE)
	FOR N=0, N_ELEMENTS(B)-1 DO BEGIN
	  SUBS = WHERE_SETS_SUBS(B[N])
	  DS   = DATE_2JD(FP[SUBS].DATE_START) & YS = FIX(FP[SUBS].YEAR_START)
	  DE   = DATE_2JD(FP[SUBS].DATE_END)   & YE = FIX(FP[SUBS].YEAR_END)
  	DURATION = (PERIODS_READ(B[N].VALUE)).PERIOD_DURATION
  	IF DURATION EQ '' THEN BEGIN
    	CASE B[N].VALUE OF
    	  'DD':     DURATION = STRTRIM(ROUND(DE-DS),2) + ' days'
    	  'DD8':    DURATION = STRTRIM(ROUND(DE-DS)-7,2) + ' days'
    	  'DD3':    DURATION = STRTRIM(ROUND(DE-DS)-2,2) + ' days'
    	  'DOY':    DURATION = STRTRIM(YE-YS+1,2) + ' years'  
    	  'WEEK':   DURATION = STRTRIM(YE-YS+1,2) + ' years'
    	  'MM':     DURATION = STRTRIM(ROUND((DE-DS)/30),2) + ' months'
    	  'MM3':    DURATION = STRTRIM(ROUND((DE-DS)/30),2) + ' months'
    	  'WW':     DURATION = STRTRIM(ROUND((DE-DS)/7),2) + ' weeks'
    	  'MONTH':  DURATION = STRTRIM(YE-YS+1,2) + ' years' 
    	  'MONTH3': DURATION = STRTRIM(YE-YS+1,2) + ' years' 
    	  'ANNUAL': DURATION = STRTRIM(YE-YS+1,2) + ' years' 
    	  'AA':     DURATION = STRTRIM(YE-YS+1,2) + ' years'
    	  '':       DURATION = 'Undefined'
    	ENDCASE
    ENDIF	
	  IF B[N].VALUE NE '' THEN BEGIN
  	  STR[SUBS].TIME = JD_2SECONDS1970(DS)
  	  STR[SUBS].TIME_UNITS = 'seconds since 1970-01-01T00:00:00Z'
  	  STR[SUBS].TIME_ORIGIN = '1970-01-01T00:00:00Z'
  	  STR[SUBS].DURATION = DURATION
  	  STR[SUBS].TIME_START = DATE_FORMAT(FP[SUBS].DATE_START,/STANDARD)
  	  STR[SUBS].TIME_END   = DATE_FORMAT(FP[SUBS].DATE_END,/STANDARD)
    ENDIF
  ENDFOR	 

  ; ===> Add CLIMATOLOGY information
  OK = WHERE_STRING(STRUPCASE(STR.PERIOD_NAME),'CLIMAT',COUNT)
  IF COUNT GE 1 THEN BEGIN
    SET = STR[OK]
    DS   = DATE_2JD(FP[OK].DATE_START) 
    DE   = DATE_2JD(FP[OK].DATE_END)
    TS = STR[OK].TIME_START
    TE = STR[OK].TIME_END
    B = WHERE_SETS(SET.PERIOD_CODE)
    FOR N=0, N_ELEMENTS(B)-1 DO BEGIN
      SUBS = WHERE_SETS_SUBS(B[N])
      YS = STRMID(TS[SUBS],0,4)
      YE = STRMID(TE[SUBS],0,4)
      SET[SUBS].CLIM_BOUNDS = STRMID(TS[SUBS],0,10) + ' - ' + STRMID(TE[SUBS],0,10)
      SET[SUBS].CLIM_START = JD_2SECONDS1970(DS[SUBS])
      SET[SUBS].CLIM_END   = JD_2SECONDS1970(DE[SUBS])
      CASE B[N].VALUE OF
        'DOY':    SET[SUBS].CLIM_METHOD = 'Climatology of the daily data for the day of year over a specified range of years (' + YS + '-' + YE + ')'
        'WEEK':   SET[SUBS].CLIM_METHOD = 'Climatology of the weekly data over a specified range of years (' + YS + '-' + YE + ')'
        'MONTH':  SET[SUBS].CLIM_METHOD = 'Climatology of the monthly data over a specified range of years (' + YS + '-' + YE + ')'
        'MONTH3': SET[SUBS].CLIM_METHOD = 'Climatology of the seasonal (3-month) data over a specified range of years (' + YS + '-' + YE + ')'
        'ANNUAL': SET[SUBS].CLIM_METHOD = 'Climatology of the annual data over a specified range of year (' + YS + '-' + YE + ')'
      ENDCASE
    ENDFOR
    STR[OK].CLIM_BOUNDS = SET.CLIM_BOUNDS
    STR[OK].CLIM_METHOD = SET.CLIM_METHOD
    STR[OK].CLIM_START  = SET.CLIM_START
    STR[OK].CLIM_END    = SET.CLIM_END
  ENDIF

  ; ===> Create LEVEL & STATS label
  OK = WHERE(FP.MATH EQ 'STATS',COUNT,COMPLEMENT=COMPLEMENT,NCOMPLEMENT=NCOMP)
  IF COUNT GT 0 THEN BEGIN
    STR[OK].LEVEL = 'level 3'
    IF ~N_ELEMENTS(STAT_TAGS) THEN STR[OK].STATISTIC_LABEL = 'statistics' ELSE BEGIN
      CASE N_ELEMENTS(STAT_TAGS) OF
        1: STR[OK].STATISTIC_LABEL = STRLOWCASE(STAT_TAGS)
        2: STR[OK].STATISTIC_LABEL = STRJOIN(STRLOWCASE(STAT_TAGS),' and')
        ELSE: STR[OK].STATISTIC_LABEL = STRJOIN(STRLOWCASE(STAT_TAGS[0:-2]),', ') + ' and ' + STRLOWCASE(STAT_TAGS(-1))
      ENDCASE
    ENDELSE
  ENDIF
  OK = WHERE(STR.STATISTIC_LABEL NE '',COUNT)                      & IF COUNT GE 1 THEN STR[OK].STATISTIC_LABEL = STR[OK].STATISTIC_LABEL + ' of'
  OK = WHERE(FP.LEVEL NE '',COUNT)                            & IF COUNT GT 0 THEN STR[OK].LEVEL = FP[OK].LEVEL 
  STR.LEVEL = REPLACE(STR.LEVEL,['L1','L2','L3','L4'],['level 1','level 2','level 3','level 4'])
  OK = WHERE(FP.LEVEL EQ 'L1A',COUNT)                         & IF COUNT GT 0 THEN STR[OK].LEVEL = 'level 1A'
  OK = WHERE(FP.SENSOR EQ 'MUR',COUNT)                        & IF COUNT GE 1 THEN STR[OK].LEVEL = 'level 4'
  OK = WHERE(STR.LEVEL EQ '' AND FP.PERIOD_CODE EQ 'D',COUNT) & IF COUNT GE 1 THEN STR[OK].LEVEL = 'level 3'
  OK = WHERE(STR.LEVEL EQ '' AND FP.PERIOD_CODE EQ 'S',COUNT) & IF COUNT GE 1 THEN STR[OK].LEVEL = 'level 2'
  STR.STATISTIC_LABEL = STR.LEVEL + ' ' + STR.STATISTIC_LABEL 

  ; ===> Create ANOM label
  OKANOM = WHERE(FP.MATH EQ 'ANOM',COUNTANOM,COMPLEMENT=COMPLEMENT,NCOMPLEMENT=NCOMP)
  IF COUNTANOM GT 0 THEN BEGIN
    STR[OKANOM].LEVEL = 'level 3'
    STR = STRUCT_RENAME(STR,'STATISTIC_LABEL','ANOMALY_LABEL')
    STR[OKANOM].ANOMALY_LABEL = 'anomaly'
    STR[OKANOM].PERIOD_NAME = REPLACE(STR[OKANOM].PERIOD_NAME,' range','')
  ENDIF
   

	; ===> Get PROD information
	STR.PROD = STRUPCASE(FP.PROD)
	OK = WHERE_MATCH(PR.PROD,FP.PROD,COUNT,VALID=VALID,NINVALID=NINVALID,INVALID=INVALID)
	IF COUNT GT 0 THEN BEGIN
	  STR[VALID].PROD_NAME  = STRLOWCASE(PR[OK].LONG_NAME)
	  STR[VALID].UNITS      = STRLOWCASE(PR[OK].UNITS)
	  STR[VALID].IOOS_CATEGORY = PR[OK].IOOS_CATEGORY
	ENDIF
	
	IF NINVALID GT 0 THEN BEGIN
	  FF = FP[INVALID] 
	  OK = WHERE(FF.LEVEL EQ 'L1' OR FF.LEVEL EQ 'L1A' OR FF.LEVEL EQ 'L2',COUNT) 
	  IF COUNT GE 1 THEN FF[OK].PROD = 'LEVEL'
	  
	  B = WHERE_SETS(FF.SENSOR)
	  FOR N=0, N_ELEMENTS(B)-1 DO BEGIN
	    SUBS = WHERE_SETS_SUBS(B[N])
	    SF = FF[SUBS]
	    CASE B[N].VALUE OF
	      'AVHRR': BEGIN & SF[SUBS].PROD = 'SST' & SF[SUBS].ALG = 'AVHRR' & END
	      'MUR':   BEGIN & SF[SUBS].PROD = 'SST' & SF[SUBS].ALG = 'MUR' & END
	      'OCCCI': BEGIN
	        SUB = SF[OK]
	        SB = WHERE_SETS(SUB.SUB)
	        FOR S=0, N_ELEMENTS(SB)-1 DO BEGIN
	          SS = WHERE_SETS_SUBS(SB[S])
	          CASE SB[S].VALUE OF
	            'CHL':         BEGIN & SUB[SS].PROD  = 'CHLOR_A' & SUB[SS].ALG  = 'CCI'   & END
	            'CHLOR_A-CCI': BEGIN & SUB[SS].PROD  = 'CHLOR_A' & SUB[SS].ALG  = 'CCI'   & END
	            'PPD-VGPM2':   BEGIN & SUB[SS].PROD  = 'PPD'     & SUB[SS].ALG  = 'VGPM2' & END
	            'RRS':         BEGIN & SUB[SS].PROD  = 'RRS'     & SUB[SS].ALG  = ''      & END
	            'IOP':         BEGIN & SUB[SS].PROD  = 'IOP'     & SUB[SS].ALG  = 'QAA'   & END
	            'ATOT':        BEGIN & SUB[SS].PROD  = 'ATOT'    & SUB[SS].ALG  = 'QAA'   & END
	            'ADG':         BEGIN & SUB[SS].PROD  = 'ADG'     & SUB[SS].ALG  = 'QAA'   & END
	            'APH':         BEGIN & SUB[SS].PROD  = 'APH'     & SUB[SS].ALG  = 'QAA'   & END
	            'BBP':         BEGIN & SUB[SS].PROD  = 'BBP'     & SUB[SS].ALG  = 'QAA'   & END
	            'KD_490':      BEGIN & SUB[SS].PROD  = 'KD_490'  & SUB[SS].ALG = 'LEE'    & END
	            'PHYTO_SIZE-HIRATA_NES': BEGIN & SUB[SS].PROD = 'PHYTO_SIZE' & SUB[SS].ALG = 'HIRATA_NES' & END
	            'PHYTO_SIZE-BREWINSST_NES': BEGIN & SUB[SS].PROD = 'PHYTO_SIZE' & SUB[SS].ALG = 'BREWINSST_NES' & END
	          END
	        ENDFOR ; SB
	        SF[OK].PROD = SUB.PROD
	        SF[OK].ALG  = SUB.ALG
	      END ; OCCCI
	      ELSE: BEGIN ; MODISA, MODIST, SEAWIFS, VIIRS (NASA)
	        OK = WHERE(FF[SUBS].LEVEL EQ 'L3',COUNT)
	        IF COUNT GE 1 THEN BEGIN
	          SUB = SF[OK]
	          SB = WHERE_SETS(SUB.SUB)
	          FOR S=0, N_ELEMENTS(SB)-1 DO BEGIN
	            SS = WHERE_SETS_SUBS(SB[S])
	            CASE SB[S].VALUE OF
	              'RRS': SUB[SS].PROD = 'RRS'
	              'SST': SUB[SS].PROD = 'SST'
	              'CHL':  BEGIN & SUB[SS].PROD = 'CHLOR_A' & SUB[SS].ALG = 'OCI'          & END
	              'SST4': BEGIN & SUB[SS].PROD = 'SST'     & SUB[SS].ALG = 'N_4UM'        & END
	              'NSST': BEGIN & SUB[SS].PROD = 'SST'     & SUB[SS].ALG = 'N_11UM'       & END	 
	              'POC':  BEGIN & SUB[SS].PROD = 'POC'     & SUB[SS].ALG = 'STRAMSKI'     & END     
	              'PIC':  BEGIN & SUB[SS].PROD = 'PIC'     & SUB[SS].ALG = 'BALCH'        & END   
	              'PFT':  BEGIN & SUB[SS].PROD = 'PFT'     & SUB[SS].ALG = 'UITZ; HIRATA' & END     
                'PAR':  BEGIN & SUB[SS].PROD = 'PAR'     & SUB[SS].ALG = 'FROUIN'       & END
	            END  
	          ENDFOR ; SB
	          SF[OK].PROD = SUB.PROD
            SF[OK].ALG  = SUB.ALG
	        ENDIF ; L3
	      END ; MODISA, MODIST, SEAWIFS, VIIRS (NASA)     
	    ENDCASE
	    FF[SUBS].PROD = SF.PROD
	    FF[SUBS].ALG  = SF.ALG
	  ENDFOR
	  STR[INVALID].PROD = FF.PROD
	  STR[INVALID].ALG  = FF.ALG
	  FP[INVALID].PROD = FF.PROD
	  FP[INVALID].ALG  = FF.ALG
	  OK = WHERE_MATCH(PR.PROD,FP.PROD,COUNT,VALID=VALID,NINVALID=NINVALID,INVALID=INVALID)
	  IF COUNT GT 0 THEN STR[VALID].PROD_NAME = STRLOWCASE(PR[OK].LONG_NAME)
	  IF COUNT GT 0 THEN STR[VALID].UNITS = PR[OK].UNITS
	ENDIF
  
  B = WHERE_SETS(FP.PROD)
  FOR N=0, N_ELEMENTS(B)-1 DO BEGIN
    SUBS = WHERE_SETS_SUBS(B[N])
    PROD = B[N].VALUE
    OK = WHERE(FP[SUBS].ALG EQ '',COUNT)
    IF COUNT GE 1 THEN BEGIN
      CASE STRMID(PROD,0,3) OF
        'LEV': FP[SUBS].ALG = ''
        'POC': FP[SUBS].ALG = 'STRAMSKI'
        'PIC': FP[SUBS].ALG = 'BALCH'
        'PAR': FP[SUBS].ALG = 'FROUIN'
        'RRS': FP[SUBS].ALG = ''
        'SST': BEGIN
          FF = FP[SUBS]
          BI = WHERE_SETS(FF.SENSOR)
          FOR I=0, N_ELEMENTS(BI)-1 DO BEGIN
            ISUBS = WHERE_SETS_SUBS(BI[I])
            CASE BI[I].VALUE OF 
              'MUR':   FF[ISUBS].ALG = 'MUR'
              'AVHRR': FF[ISUBS].ALG = 'AVHRR'
              'CORAL': FF[ISUBS].ALG = 'CORALTEMP'
              'ACSPO': FF[ISUBS].ALG = 'ACSPO'
              'ACSPONRT': FF[ISUBS].ALG = 'ACSPO'
            ENDCASE
          ENDFOR
          FP[SUBS].ALG = FF.ALG
        END
        'GRA': BEGIN ; GRAD_SST
          FF = FP[SUBS]
          BI = WHERE_SETS(FF.SENSOR)
          FOR I=0, N_ELEMENTS(BI)-1 DO BEGIN
            ISUBS = WHERE_SETS_SUBS(BI[I])
            CASE BI[I].VALUE OF
              'ACSPO': FF[ISUBS].ALG = 'ACSPO'
              'ACSPONRT': FF[ISUBS].ALG = 'ACSPO'
            ENDCASE
          ENDFOR
          FP[SUBS].ALG = FF.ALG   
        END       
      ENDCASE
    ENDIF  
  ENDFOR
  OK = WHERE(STR.PROD EQ 'LEVEL',COUNT) & IF COUNT GE 1 THEN STR[OK].PROD = ''

	; ===> Get ALG information
	REFS = []
	FOR R=0, N_ELEMENTS(ALGS)-1 DO BEGIN
	  REF = [ALGS[R].REF1,ALGS[R].REF2,ALGS[R].REF3,ALGS[R].REF4,ALGS[R].REF5,ALGS[R].REF6,ALGS[R].REF7,ALGS[R].REF8,ALGS[R].REF9,ALGS[R].REF10]
	  REFS = [REFS,STRJOIN(REF[WHERE(REF NE '',/NULL)],'; ')] 
	ENDFOR
	OK = WHERE_MATCH(ALGS.ALG,FP.ALG,COUNT,VALID=VALID,NINVALID=NINVALID,INVALID=INVALID)
	IF COUNT GT 0 THEN BEGIN 
	  STR[VALID].ALG_REFERENCE = REFS[OK]
	  STR[VALID].ALG_NAME      = ALGS[OK].LONG_NAME
	  STR[VALID].ALG           = ALGS[OK].ALG
	ENDIF  
	
	IF COUNTANOM GT 0 THEN STR.TITLE = STR.PERIOD_NAME+' '+STR.ANOMALY_LABEL+' of '+STR.PROD+' data from the '+STR.SHORT_NAME+' '+ STR.PLATFORM_TYPE $
                    ELSE STR.TITLE = STR.PERIOD_NAME+' '+STR.STATISTIC_LABEL+' '+STR.PROD+' data from the '+STR.SHORT_NAME+' '+ STR.PLATFORM_TYPE
	OK = WHERE(STR.ALG_NAME NE '',COUNT)
	IF COUNT GE 1 THEN STR[OK].TITLE = REPLACE(STR[OK].TITLE,STR.PROD+' data from the ',STR[OK].PROD+' data ('+STR[OK].ALG_NAME+') from the ')
	STR.TITLE = REPLACE(STR.TITLE,['Undefined ','NA'],['',''])
	STR.TITLE = REPLACE(STR.TITLE,['   ','  '],[' ',' '])
	
	RETURN, STR
	
END; #####################  End of Routine ################################
