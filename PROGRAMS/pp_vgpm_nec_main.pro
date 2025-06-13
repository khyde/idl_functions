; $ID:	PP_VGPM_NEC_MAIN.PRO,	2020-07-08-15,	USER-KJWH	$

  PRO PP_VGPM_NEC_MAIN , FILES = FILES, DIR_CHL=dir_chl,dir_par=DIR_PAR, DIR_SST=dir_sst, PERIOD=period
; NAME:
;       PP_VGPM_NEC_MAIN
;
; PURPOSE:
;       Calculate Primary Productivity using Behrenfeld-Falkowski Model (1997)
;
;
; KEYWORD PARAMETERS:
;  TEMP_MODEL = 'TBF' ; TEMPERATURE MODEL: BEHRENFELD-FALKOWSKI
;  TEMP_MODEL = 'TMA' ;	TEMPERATURE MODEL: EXPONENTIAL(MOREL-ANTOINE
; OUTPUTS:
;
; MODIFICATION HISTORY:
;       Written by:  J.E.O'Reilly, March 21, 2003.
;	July 28, td, work with new file naming convention, use struct_sd_read,use struct_sd_stats
;	Aug 21,2003, td new land & coast file, new folder names
; Aug 26, 2003,jor, added reasonable data ranges for par,chl,sst; fixed land mask; Added DATA_RANGE TO mask

;-

	ROUTINE_NAME = 'PP_VGPM_NEC_MAIN'
	S=STATS[0]
; =================>
	IF N_ELEMENTS(MAP) NE 1 THEN AMAP = 'NEC' ELSE AMAP = MAP ; DEFAULT IS NORTHEAST US COAST
 ; ====================> Disk depends on computer
;	=====> Directories for resource files
  DIR_PROGRAMS       = 'D:\IDL\PROGRAMS\'
	DIR_DATA					 = 'D:\IDL\DATA\'
	DIR_IMAGES				 = 'D:\IDL\IMAGES\'
	time = DATE_NOW()
  computer = GET_COMPUTER()
  delim=DELIMITER(/PATH)
  DASH=DELIMITER(/DASH)
  UL=DELIMITER(/UL)
	ASTER=DELIMITER(/ASTER)
  SP = ' '

  PX=1024 & PY=1024
  PAL = 'PAL_SW3'
  BACKGROUND = 252
  LAND_COLOR = 252
  MISSING_COLOR = 251
  BATHY_COLOR = 252
  LINE_COLOR  = 235
  LINE_THICK  = 7

  ADD_LEG=1
  ADD_BATHY=1
  ADD_TIME_SCALE=1
	ADD_DATE = 1

	MAP = 'NEC'
	CHLOR_A_RANGE = [0.0  , 200.0]
  PAR_RANGE 		= [0.0	,  75.0]
  SST_RANGE 		= [-3.0	,  37.0]
  NOTES_RANGE = ''
 	NOTES_RANGE = NOTES_RANGE+'CHLOR_A-RANGE_GT_'+ NUM2STR(CHLOR_A_RANGE[0])	+'_LT_'+NUM2STR(CHLOR_A_RANGE[1])+';'
 	NOTES_RANGE = NOTES_RANGE+'PAR-RANGE_GT_'		 + NUM2STR(PAR_RANGE[0])			+'_LT_'+NUM2STR(PAR_RANGE[1])+';'
 	NOTES_RANGE = NOTES_RANGE+'SST-RANGE_GT_'		 + NUM2STR(SST_RANGE[0])			+'_LT_'+NUM2STR(SST_RANGE[1])


  LAND_MASK = READALL(DIR_IMAGES+'MASK_LAND-NEC-PXY_1024_1024.PNG')
  OK_LAND = WHERE(LAND_MASK EQ 1,COUNT_LAND)
;;;  LAND_MASK_THICK=MAP_NEC_WATER(THICK=23)

	IF ADD_BATHY EQ 1 THEN BEGIN
    ; old   BATHY = READALL('D:\IDL\IMAGES\NEC_MAP_BATHY_100_EDIT.png')
 		BATHY = READALL(DIR_IMAGES+'MASK_BATHY-NEC-100-PXY_1024_1024-EDIT.PNG')
    CLOUDIER, IMAGE=BATHY,CLOUDS=1,MASK=MASK,BOX=2,/QUIET
    OK_BATHS = WHERE(MASK EQ 1)
	ENDIF

; =====> Components for File Label
  DIR_ROOT	=	'PP'
  PP_MODEL	=	'PP_VGPM'
  AMAP			=	'NEC'
  APROD			=	'PPD'
	TARGET_YEARS = [1998,1999,2000,2001,2002]

	MONTH_NAMES = DT_MONTH_NAMES(/SHORT)

  IF computer EQ 'LOLIGO' 	THEN DISK = 'H:'
  IF computer EQ 'BURRFISH' THEN DISK = 'G:'
  IF computer EQ 'SUNDIAL'  THEN DISK = 'E:'
; =====> Directories for Chlorophyll,PAR, SST
  DIR_CHL='J:\SEAWIFS\TS_IMAGES\SAVE\'
  DIR_PAR='J:\SEAWIFS\TS_IMAGES\SAVE\'
  DIR_SST='E:\AVHRR\TS_IMAGES\SAVE\'

	path = DISK + delim+ DIR_ROOT + delim ;;;
; =====> Default directory for Output
  DIR_SAVE 							= path+'SAVE'							+delim
  DIR_BROWSE 						=	path+'browse'						+delim
  DIR_STATS 						=	path+'stats'						+delim
  DIR_STATS_BROWSE 			=	path+'stats_browse'			+delim
  DIR_STATS_BROWSE_PAGE	=	path+'stats_browse_page'+delim

  DIR_LOG								=	path+'log' 							+delim
  DIR_REPORT 						=	path+'report'						+delim
  DIR_PLOTS 						=	path+'plots'						+delim
  DIR_PROBLEMS 					=	path+'problems' 				+delim

 	DIR_TS_IMAGES 				=	path+'ts_images'				+delim
 	DIR_TS_IMAGES_BROWSE  = DIR_TS_IMAGES + 'browse'+delim
  DIR_TS_IMAGES_MOVIE  	=	DIR_TS_IMAGES + 'movie'	+delim

 	DIR_SHSTRATA					=	path+'shstrata'						+delim

  PROD_TXT = 'Mean Daily!CPrimary Production'

; ===>
;  EDT = '_MEDIAN_FILL'
  EDT = ''
  ;EXT = '.ARR'
  EXT = '.PNG'

  TEMP_MODELS = ['TBF','TMA']
 	TEMP_MODELS = ['TBF']
 	TEMP_MODELS = ['TMA']

  PERIODS=['!Y','!M']

  STAT_TYPES = ['MEAN','STD','CV']
  STAT_TYPES = ['CV']
  STAT_TYPES = ['MEAN']

;	************************ S W I T C H E S  ***********************
	DO_CHECK_DIRS  			        	= 1  ; Normally, keep this switch on
  DO_PP_DAILY_SAVE							= 2
  DO_PP_DAILY_BROWSE            = 2
  DO_PP_STATS_EXTRACT			 			= 0
  DO_PP_DAILY_COMPOSITE_PICTURE	= 0

  DO_PP_ANNUAL_VARIABILITY   		= 0

 	DO_PP_STATS_2BROWSE 					= 0

; ******* TS ISERIES ****************

  DO_PP_PNG_2AVI        				= 1


; ************ Shellfish Strata  **********
  DO_STATS_2SHSTRATA										= 0
  DO_PP_VGPM_SHSTRATA_TIMESERIES_PLOT 	= 0
  DO_PP_VGPM_SHSTRATA_TIMESERIES_MATRIX = 0

	DIR_ALL = [DIR_CHL,DIR_PAR,DIR_SST,DIR_SAVE,DIR_BROWSE,DIR_STATS_BROWSE,DIR_REPORT,DIR_PLOTS, $
           	DIR_PROBLEMS, DIR_TS_IMAGES, DIR_TS_IMAGES_BROWSE, DIR_TS_IMAGES_MOVIE,DIR_SHSTRATA]

  STATUS = ''

; *********************************************
	IF DO_CHECK_DIRS GE 1 THEN BEGIN
; *********************************************
    PRINT, 'S T E P:    DO_CHECK_DIRS'
    FOR N=0,N_ELEMENTS(DIR_ALL)-1 DO BEGIN & AFILE = STRMID(DIR_ALL(N),0,STRLEN(DIR_ALL(N))-1) &
    	IF FILE_TEST(AFILE,/DIRECTORY) EQ 0L THEN FILE_MKDIR,AFILE &  ENDFOR
  ENDIF
; |||||||||||||||||||||||||||||||||||||||||||||||||


;	************************************************************************
  IF DO_PP_DAILY_SAVE GE 1 THEN BEGIN
;	************************************************************************
   	OVERWRITE = DO_PP_DAILY_SAVE EQ 2
   	S_UNITS=UNITS('PPD')
   	FOR _TMODEL = 0,N_ELEMENTS(TEMP_MODELS)-1L DO BEGIN
    	TMODEL = TEMP_MODELS(_TMODEL)
    	PRINT, TMODEL
;  		REPORT  = DIR_REPORT+DIR_ROOT+ul+PP_MODEL+UL+TMODEL+UL+AMAP+UL+'PPD'+UL+TIME+'.TXT'
  		REPORT  = DIR_REPORT+DIR_ROOT+dash+PP_MODEL+UL+TMODEL+dash+AMAP+dash+'PPD'+dash+TIME+'.TXT'
  		LIST, REPORT,FILE=REPORT,/NOSEQ,/NOHEADING

; 		=====> Get all chl files
  		CHL_FILES= DIR_CHL + 'TS_IMAGES-SEAWIFS-OV2-REPRO4-NEC-CHLOR_A-INTERP-!D_*.SAVE'
  		FA_CHL = FILE_ALL(CHL_FILES)
  		IF N_ELEMENTS(FA_CHL.FULLNAME) LT 2 THEN STOP
  		S=SORT(FA_CHL.DATE_START) & FA_CHL=FA_CHL(S)

; 		=====> Get all PAR files
  		PAR_FILES= DIR_PAR + 'TS_IMAGES-SEAWIFS-OV2-REPRO4-NEC-PAR-INTERP-!D_*.SAVE'
  		FA_PAR    = FILE_ALL(PAR_FILES)
  		IF N_ELEMENTS(FA_PAR.FULLNAME) LT 2 THEN STOP
  		S=SORT(FA_PAR.DATE_START) & FA_PAR=FA_PAR(S)

; 		====== Get all SST files
  		SST_FILES= DIR_SST + 'TS_IMAGES-AVHRR-CW_CD-NEC-SST-INTERP-!D_*.SAVE'
  		FA_SST = FILE_ALL(SST_FILES)
			IF N_ELEMENTS(FA_SST.FULLNAME) LT 2 THEN STOP
  		S=SORT(FA_SST.DATE_START) & FA_SST=FA_SST(S)

; 		LLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLL
; 		Process Each set of Files With chl controling the triplets files
  		FOR _file = 0,N_ELEMENTS(FA_CHL)-1L DO BEGIN

    		CHL_FILE = FA_CHL(_file).fullname
    		adate = FA_CHL(_file).date_start
				PERIOD_TXT=FA_CHL(_file).PERIOD

;				=====> Get Matching PAR for this day
    		ok_par = WHERE(FA_PAR.date_start EQ adate,COUNT)
    		IF COUNT NE 1 THEN CONTINUE
    		PAR_FILE = FA_PAR(ok_par).fullname

;				=====> Get matching SST for this day
				ok_sst = WHERE(FA_SST.date_start EQ adate,COUNT)
    		IF COUNT NE 1 THEN CONTINUE
    		SST_FILE = FA_SST(ok_sst).fullname

;				=====> Check if output save file exists if so then skip it
				SAVEFILE = DIR_SAVE + PP_MODEL+ul + TMODEL +dash+AMAP+dash+'PPD'+ dash+ PERIOD_TXT + '.SAVE'

				FA_SAVE=FILE_INFO(SAVEFILE)

				IF FA_CHL(_file).MTIME LT FA_SAVE.MTIME AND FA_PAR(OK_PAR).MTIME LT FA_SAVE.MTIME $
							AND FA_SST(OK_SST).MTIME LT FA_SAVE.MTIME AND OVERWRITE EQ 0 THEN CONTINUE

;   		=====> Determine Day of Year
    		doy = DT_DATE2DOY(adate) & doy = FIX(ROUND(DOY)) & doy=doy[0]

;   		=====> Read the CHLOR_A Satellite data array for the NEC area
				CHL_SAT=STRUCT_SD_READ(CHL_FILE, PROD='CHLOR_A',STRUCT=struct,COUNT=count,SUBS=subs,ERROR=ERROR)
				STRUCT_CHL=STRUCT

;   		=====> Read the PAR Satellite data array for the NEC area
				PAR_SAT=STRUCT_SD_READ(PAR_FILE, PROD='PAR',STRUCT=struct,COUNT=count,SUBS=subs,ERROR=ERROR)
				STRUCT_PAR=STRUCT

;   		=====> Read the SST Satellite data array for the NEC area
				SST_SAT=STRUCT_SD_READ(SST_FILE, PROD='SST',STRUCT=struct,COUNT=count,SUBS=subs,ERROR=ERROR)
				STRUCT_SST=STRUCT

;				===> Make an image_mask to represent good data [0] and bad data to be masked (=1)
        image_mask = BYTE(CHL_SAT) & image_mask(*,*) = 1 ; initially bad and masked

				OK_ALL = WHERE(LAND_MASK EQ 0 AND $
								chl_sat NE missings(chl_sat) AND chl_sat GT CHLOR_A_RANGE[0] AND chl_sat LT CHLOR_A_RANGE[1] AND $
								par_sat NE missings(par_sat) AND par_sat GT par_RANGE[0] AND par_sat LT par_RANGE[1] AND $
								sst_sat NE missings(sst_sat) AND sst_sat GT sst_RANGE[0] AND sst_sat LT sst_RANGE[1], count_all)

				IF count_all EQ 0 THEN CONTINUE ;|>|>|>|>|
				image_mask(ok_all) = 0 ; good data

;				===> The pp program (PP_BEHRENFELD_NEC) below expects a full image... so we will mask after calculating pp
    		OK_MISS=WHERE(image_mask EQ 1, count_MISS)

;				===> Find the values over water that are outside the ranges for the 3 input sats
				OK_OUTLIERS = WHERE(LAND_MASK EQ 0 AND IMAGE_MASK EQ 1,COUNT_OUTLIERS)

;   		=====> Get the size of the Chl_sat
    		sz = SIZE(chl_sat)

;   		=====> Calculate Day Length for the NEC area
    		day_length = I_SUN_KIRK_DAY_LENGTH_MAP(DOY,MAP='NEC')

;   		=====> Ensure that DAY_LENGTH array is same size as CHL_SAT
    		sz = SIZE(day_length)
    		IF sz[1] NE PX OR sz(2) NE PY THEN STOP

;   		*************************************************************************************
;   		********************     R U N     P P     M O D E L    *****************************
;   		*************************************************************************************

    		PP=PP_VGPM(CHL_SAT=chl_SAT,   SST_SAT=sst_SAT,  DAY_LENGTH=day_length, PAR=par_SAT, TEMP_MODEL=tmodel)
   	 		PP = FLOAT(PP)
;				============> make missing missing
				IF count_MISS GE 1 THEN PP(OK_MISS) = MISSINGS(PP)
;   		====================>
;   		Print out statistics on all arrays provided to pp model
    		PRINT, 'DATE: ',ADATE
;   		Print out statistics on all arrays provided to REPORT TXT FILE
				LIST,/NOSEQ,/NOHEADING,FILE=REPORT
    		LIST,/NOSEQ,/NOHEADING,FILE=REPORT , 'ADATE: '+ STRING(ADATE)
    		LIST,/NOSEQ,/NOHEADING,FILE=REPORT , 'DOY: ' + STRING(DOY)
    		LIST,/NOSEQ,/NOHEADING,FILE=REPORT , 'CHL_FILE: '+ CHL_FILE
    		LIST,/NOSEQ,/NOHEADING,FILE=REPORT , 'PAR_FILE: '+ PAR_FILE
    		LIST,/NOSEQ,/NOHEADING,FILE=REPORT , 'SST_FILE: '+ SST_FILE
    		LIST,/NOSEQ,/NOHEADING,FILE=REPORT , 'DAY LENGTH RANGE: '	+ NUM2STR(MIN(DAY_LENGTH))			+' To '	+ NUM2STR(MAX(DAY_LENGTH))
    		LIST,/NOSEQ,/NOHEADING,FILE=REPORT , 'Chl Range: ' 				+ NUM2STR(MIN(chl_sat(ok_all))) +' To '	+ NUM2STR(MAX(chl_sat(ok_all)))
				LIST,/NOSEQ,/NOHEADING,FILE=REPORT , 'PAR Range: ' 				+ NUM2STR(MIN(PAR_sat(ok_all))) +' To '	+ NUM2STR(MAX(PAR_sat(ok_all)))
 				LIST,/NOSEQ,/NOHEADING,FILE=REPORT , 'SST Range: ' 				+ NUM2STR(MIN(SST_sat(ok_all)))	+' To '	+ NUM2STR(MAX(SST_sat(ok_all)))

				LIST,/NOSEQ,/NOHEADING,FILE=REPORT , 'PPD Range: ' 				+ NUM2STR(MIN(PP(ok_all)))			+' To '	+ NUM2STR(MAX(PP(ok_all)))

;   		=====> Write Save file

				DATA_UNITS=UNITS('PPD')
				IF MAP NE 'L3B' THEN BEGIN
;     		*************************************
;     		*****  Make Mask for STRUCT_SD  *****
;     		*************************************
;     		===> NOT_MASK (good data , 0b)
      		CODE_NAME = 'NOT_MASK'
      		MASK=BYTE(PP) & MASK(*,*)=0B
      		CODE_MASK     =          [0B]
      		CODE_NAME_MASK=[CODE_NAME]

;     		===> LAND
      		CODE_NAME='LAND'
      		ACODE = MAX(CODE_MASK)+1B
      		CODE_MASK     =[CODE_MASK,ACODE]
      		CODE_NAME_MASK=[CODE_NAME_MASK,CODE_NAME]
      		IF COUNT_LAND GE 1 THEN MASK(OK_LAND)  = ACODE

;     		===> OUTLIERS
      		CODE_NAME='OUTLIERS'
      		ACODE = MAX(CODE_MASK)+1B
      		CODE_MASK     =[CODE_MASK,ACODE]
      		CODE_NAME_MASK=[CODE_NAME_MASK,CODE_NAME]
      		IF COUNT_OUTLIERS GE 1 THEN MASK(OK_OUTLIERS)  = ACODE
      	ENDIF

      	STRUCT_SD_WRITE,SAVEFILE,PROD='PPD', $
                   IMAGE=PP,        MISSING_CODE=MISSINGS(PP), $
                   MASK=MASK,       CODE_MASK=CODE_MASK,    CODE_NAME_MASK=CODE_NAME_MASK, $
                   SCALING='linear' ,INTERCEPT= 0.0,         SLOPE= 1.0,       DATA_UNITS=DATA_UNITS,$
                   PERIOD=PERIOD_TXT, $
                   SENSOR=[STRUCT_chl.sensor,STRUCT_par.sensor,STRUCT_sst.sensor],$
                   SATELLITE=[STRUCT_chl.satellite,STRUCT_par.satellite,STRUCT_sst.satellite],$
                   SAT_EXTRA=[STRUCT_chl.sat_extra,STRUCT_par.sat_extra,STRUCT_sst.sat_extra],$
                   METHOD=[STRUCT_chl.method,STRUCT_par.method,STRUCT_sst.method],$
                   SUITE =[STRUCT_chl.suite,STRUCT_par.suite,STRUCT_sst.suite],$
                   INFILE =[STRUCT_chl.infile,STRUCT_par.infile,STRUCT_sst.infile],$
                   NOTES=NOTES_RANGE,       ERROR=ERROR


  		ENDFOR;FOR _file = 0,N_ELEMENTS(FA_CHL)-1L DO BEGIN
  	ENDFOR ; FOR TEMP MODEL
	ENDIF ; IF DO_PP_DAILY_SAVE EQ 1 THEN BEGIN
;	|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||


;	************************************************************************
  IF DO_PP_DAILY_BROWSE GE 1 THEN BEGIN
;	************************************************************************
	 	OVERWRITE = DO_PP_DAILY_BROWSE EQ 2

	 	FOR _TMODEL = 0,N_ELEMENTS(TEMP_MODELS)-1L DO BEGIN
    	TMODEL = TEMP_MODELS(_TMODEL)
    	PRINT, TMODEL
    	TARGETS=DIR_SAVE+PP_MODEL+UL+TMODEL+dash+AMAP+dash+APROD+dash+'*' +  '.SAVE'
    	FA = FILE_ALL(TARGETS)
 ;		============> LEGEND

			LEG = COLOR_BAR_SCALE(PROD=APROD,/NAME,/UNIT,px= 512, py=124,/TRIM,charsize=2.6,BACKGROUND=BACKGROUND,pos=[.04,.04,.96,.18],PAL= _PAL)
			SZ=SIZE(LEG,/STRUCT)
			XPOS = 0
			YPOS =  PY - SZ.DIMENSIONS[1] -1 ;

;			======> Process each
  		FOR _FILE = 0L,N_ELEMENTS(FA)-1 DO BEGIN

    		PPD_FILE = FA(_FILE).FULLNAME
				PNGFILE = DIR_TS_IMAGES_BROWSE+FA(_FILE).NAME+'-4avi.PNG'
    		EXIST=FILE_TEST(PNGFILE) &	IF EXIST GE 1 AND OVERWRITE EQ 0 THEN CONTINUE

    		PP_LABEL = PP_MODEL + ' '+ TMODEL

;   		=====> Read the PPD data array for the NEC area
				PPD_SAT=STRUCT_SD_READ(PPD_FILE, PROD='PPD',STRUCT=struct,COUNT=count,SUBS=subs,ERROR=ERROR)
				STRUCT_PPD=STRUCT
				OK_PPD=SUBS
				OK=WHERE(STRUCT.CODE_NAME_MASK EQ 'LAND',COUNT)
				IF COUNT EQ 1 THEN BEGIN
					LAND_CODE=STRUCT.CODE_MASK(OK[0])
					OK_LAND=WHERE(STRUCT.MASK EQ LAND_CODE,COUNT_LAND)
				ENDIF

				OK=WHERE(STRUCT.CODE_NAME_MASK EQ 'OUTLIERS',COUNT)
				IF COUNT EQ 1 THEN BEGIN
					OUTLIERS_CODE=STRUCT.CODE_MASK(OK[0])
					OK_OUTLIERS=WHERE(STRUCT.MASK EQ OUTLIERS_CODE,COUNT_OUTLIERS)
				ENDIF

     		DATE_TXT=[FA(_FILE).DATE_START]
     		j = dt_date2julian(DATE_TXT)
     		DATE_TXT= DT_FMT(J,/DAY)
     		DATE_TXT_CHARSIZE = 3
				LABEL= DATE_TXT + '!C' + PP_LABEL

;				===> Scale ppd_sat to make a binary png
    		SLIDE_AVI=SD_SCALES(PPD_sat,PROD=APROD,/DATA2BIN)
    		IF COUNT_LAND GE 1 THEN SLIDE_AVI(OK_LAND) = LAND_COLOR
    		IF COUNT_OUTLIERS GE 1 THEN SLIDE_AVI(OK_OUTLIERS) = MISSING_COLOR

				IF ADD_LEG EQ 1 THEN SLIDE_AVI(XPOS,YPOS) = LEG

;				=====> Write out pngfile for avi
				DT = FA(_FILE).DATE_START
				julian=DT_DATE2JULIAN(DT)
				IF ADD_TIME_SCALE EQ 1 THEN BEGIN
					BAR= DT_TIME_BAR(julian ,BACKGROUND=_BACKGROUND, LINE_COLOR=line_color, LINE_THICK=line_thick,/NO_YEAR, charsize = 2.5,charthick=3)
					SLIDE_AVI(20,810) = BAR
				ENDIF
				IF ADD_BATHY EQ 1 THEN 	SLIDE_AVI(OK_BATHS) = BATHY_COLOR
				ZWIN,SLIDE_AVI
				TV,SLIDE_AVI
				ADATE = STRTRIM(DT_FMT(DT_DATE2JULIAN(DT),/YMD,/DAY),2)
  			YDATE = STRTRIM(DT_FMT(DT_DATE2JULIAN(DT),/YMD,/YEAR),2)
  			IF ADD_TIME_SCALE EQ 1 THEN XYOUTS,250,770,/DEVICE,YDATE,COLOR=0,CHARSIZE=3,CHARTHICK=4,ALIGN=0.5
				IF ADD_DATE EQ 1 THEN XYOUTS,PX,PY-17,/DEVICE,ADATE,COLOR=0,CHARSIZE=1.5,CHARTHICK=2,ALIGN=1.02
				SLIDE_AVI=TVRD()
				ZWIN
  			PAL_SW3,R,G,B
    		WRITE_PNG,PNGFILE,SLIDE_AVI,R,G,B
  		ENDFOR ; for file
   	ENDFOR ;FOR _TMODEL = 0,N_ELEMENTS(TEMP_MODELS)-1L DO BEGIN
  ENDIF ; IF DO_PP_DAILY_BROWSE EQ 1 THEN BEGIN
;	||||||||||||||||||||||||||||||||||||||||||||||||||||||||||


;	************************************************************************
  IF DO_PP_STATS_EXTRACT GE 1 THEN BEGIN
;	************************************************************************
	 	OVERWRITE = DO_PP_STATS_EXTRACT EQ 2
	 	FOR _TMODEL = 0,N_ELEMENTS(TEMP_MODELS)-1L DO BEGIN
    	TMODEL = TEMP_MODELS(_TMODEL)
    	PRINT, TMODEL

STOP
    	TARGETS=DIR_SAVE+PP_MODEL+UL+TMODEL+dash+AMAP+dash+APROD+dash+'*.SAVE'
    	FA = FILE_ALL(TARGETS)

   		FOR _PERIOD = 0,N_ELEMENTS(PERIODS)-1 DO BEGIN
    		APERIOD = PERIODS(_PERIOD)
				JULIAN = DT_PERIOD2JULIAN(FA.PERIOD)

; 			===> Divide Files into sets based on dates
 				dt_sets=DT_PERIOD_SETS(JULIAN,DATA=FA.FULLNAME,period_code=APERIOD,LABEL=LABEL,DT_RANGE=DT_RANGE)

  			TAGNAMES = TAG_NAMES(DT_SETS)
;				LLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLL
   			FOR _DT = 0L,N_ELEMENTS(TAGNAMES)-1 DO BEGIN
    			ADT = TAGNAMES(_DT)
    			PERIOD_TXT = ADT
    			PRINT, ADT
    			FILE_LABEL = DIR_STATS_EXTRACT + PP_MODEL+UL+TMODEL+dash+AMAP+dash+APROD+dash+PERIOD_TXT
;					=====> See if output save already exists if so continue
     			TEST_FILE = FILE_LABEL + '_MEAN.SAVE'
     			EXIST=FILE_TEST(TEST_FILE)
     			IF EXIST EQ 1 AND OVERWRITE EQ 0 THEN CONTINUE

     			set= DT_SETS.(_DT)
     			NUM= LONARR(px,py)
    			SUM= FLTARR(px,py)
     			SSQ= FLTARR(px,py)
     			AVG=FLTARR(PX,PY) 	& AVG(*,*)=MISSINGS(AVG)
       		STD=FLTARR(PX,PY) 	& STD(*,*)=MISSINGS(STD)
       		CV	=FLTARR(PX,PY) 	& CV(*,*)	=MISSINGS(CV)
     			FOR _set = 0l,N_ELEMENTS(set)-1L DO BEGIN
       			PPD_FILE = SET(_set)
       			PRINT, PPD_FILE
       			SD = READALL(PPD_FILE)
      			NAMES = TAG_NAMES(SD)
 						OK_P = WHERE(NAMES EQ APROD, COUNT_P) & OK_P=OK_P[0]
      			IF COUNT_P EQ 0 THEN CONTINUE

      			IIMAGE 				= SD.(OK_P).IMAGE
      			SLOPE_IN      = sd.(OK_P).SLOPE
      			INTERCEPT_IN  = sd.(OK_P).INTERCEPT
      			SCALING_IN    = sd.(OK_P).SCALING
;     			Convert IIMAGE to geophysical units
      			IF STRUPCASE(SD.(OK_P).SCALING) EQ 'LINEAR'      THEN $
        			DATA=      FLOAT(IIMAGE)*(sd.(OK_P).SLOPE[0]) + sd.(OK_P).INTERCEPT[0]  ;;
      			IF STRUPCASE(SD.(OK_P).SCALING) EQ 'LOGARITHMIC' THEN $
        			DATA=10.0^(FLOAT(IIMAGE)*(sd.(OK_P).SLOPE[0]) + sd.(OK_P).INTERCEPT[0]) ;;

       			ok = where(DATA ne missings(DATA),count)
       			IF count GE 1 THEN BEGIN
         			NUM[OK]=NUM[OK]+	1L
         			SUM[OK]=SUM[OK]+	DATA[OK]
         			SSQ[OK]=SSQ[OK]+ 	DATA[OK]*DATA[OK]
       			ENDIF
     			ENDFOR ;FOR _set = 0l,N_ELEMENTS(set)-1L DO BEGIN


;					=====> Compute MEAN
					OK = WHERE(NUM GE 1,COUNT)
					IF COUNT GE 1 THEN BEGIN
						AVG[OK] = SUM[OK]/NUM[OK]
					ENDIF
;					=====> Compute STD	And CV
					OK2 = WHERE(NUM GE 2,COUNT)
					IF count GE 1 THEN BEGIN
           	STD(OK2)= (((SSQ(OK2)-((SUM(OK2)*SUM(OK2))/NUM(OK2)))^0.5)/((NUM(OK2)-1)^0.5)) ;
           	CV(OK2)	=  100d*(STD(OK2)/AVG(OK2)) ;
        	ENDIF
     			SAVE_FILE = FILE_LABEL + '_MEAN.SAVE'
     			SAVE,FILENAME=SAVE_FILE, AVG,/COMPRESS
		 			SAVE_FILE = FILE_LABEL + '_STD.SAVE'
     			SAVE,FILENAME=SAVE_FILE, STD,/COMPRESS
     			SAVE_FILE = FILE_LABEL + '_CV.SAVE'
     			SAVE,FILENAME=SAVE_FILE, CV,/COMPRESS
  			ENDFOR ;FOR _set = 0l,N_ELEMENTS(set)-1L DO BEGIN
  		ENDFOR; FOR _PERIOD
	 	ENDFOR ; FOR _TMODEL = 0,N_ELEMENTS(TEMP_MODELS)-1L DO BEGIN
  ENDIF ; IF DO_PP_DAILY_SAVE_MEAN_YEAR EQ 1 THEN BEGIN
;	|||||||||||||||||||||||||||||||||||||||||||||||||


;	************************************************************************
  IF DO_PP_DAILY_COMPOSITE_PICTURE GE 1 THEN BEGIN
;	************************************************************************
		TEMP_MODEL = 'TMA'
		APROD='PPD'
  	FA= FILE_ALL(DIR_SAVE + MODEL+ '_T'+ TEMP_MODEL+'_NEC_PPD_DATE_*'  + '.SAVE')

  	FOR _PERIOD = 0,N_ELEMENTS(PERIODS)-1 DO BEGIN
    	APERIOD = PERIODS(_PERIOD)
  		S=SORT(FA.DATE_START) & FA=FA(S)
  		JULIAN	=	DT_DATE2JULIAN(FA.DATE_START)
  		DT_SETS	= DT_PERIOD(JULIAN,PERIOD=APERIOD,DATA=FA.FULLNAME)

  		TAGNAMES = TAG_NAMES(DT_SETS)
;			LLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLL
   		FOR _DT = 0L,N_ELEMENTS(TAGNAMES)-1 DO BEGIN
    		ADT = TAGNAMES(_DT)
    		PERIOD_TXT = ADT
    		PRINT, ADT

     		set= DT_SETS.(_DT)
     		FIRST_IMAGE = 0
     		FOR _set = 0l,N_ELEMENTS(set)-1L DO BEGIN
       		PPD_FILE = SET(_set)
       		pp=READALL(PPD_FILE)
       		PRINT, PPD_FILE

       		IF FIRST_IMAGE EQ 0 THEN BEGIN
         		FI=FILE_ALL(PPD_FILE)
       			FIRST_IMAGE = 1
       		ENDIF
      		ok_miss = where(pp EQ missings(pp),count_miss)

      		IMAGE=SD_SCALES(PP,PROD=APROD,/DATA2BIN)

    			IMAGE(OK_LAND) = LAND_COLOR
    			OK = WHERE(LAND_MASK_THICK EQ 255 AND IMAGE EQ 0,COUNT)
    			IF COUNT GE 1 THEN IMAGE[OK] = 253

;					SHRINK IMAGE
      		IMAGE = REBIN(IMAGE,256,256)
     		ENDFOR ; FOR _SET
      	FILE_LABEL = DIR_PLOTS + 'PP_SEAWIFS_'+APROD + PERIOD_TXT +  '_'+TEMP_MODEL
     		PNGFILE = FILE_LABEL + '_COMPOSITE.PNG'
     		WRITE_PNG,PNGFILE,BIMAGE,R,G,B
  		ENDFOR ; FOR _DT = 0L,N_ELEMENTS(TAGNAMES)-1 DO BEGIN
  	ENDFOR; FOR _PERIOD
  ENDIF ; IF DO_PP_DAILY_MEAN_YEAR EQ 1 THEN BEGIN
;	|||||||||||||||||||||||||||||||||||||||||||||||||




;	************************************************************************
  IF DO_PP_ANNUAL_VARIABILITY GE 1 THEN BEGIN
;	************************************************************************
  	OVERWRITE = DO_PP_ANNUAL_VARIABILITY EQ 2
		FOR _TMODEL = 0,N_ELEMENTS(TEMP_MODELS)-1 DO BEGIN
    	TMODEL = TEMP_MODELS(_TMODEL)
    	PRINT, TMODEL
    	ASTAT = 'MEAN'
    	PERIOD_TXT = '_Y_'+NUM2STR(TARGET_YEARS)+UL+NUM2STR(TARGET_YEARS)

    	TARGETS = DIR_STATS_EXTRACT + PP_MODEL+UL+TMODEL+UL+AMAP+UL+APROD+PERIOD_TXT+UL+ASTAT+'.SAVE'
    	FA = FILE_ALL(TARGETS)

  		OK = WHERE(FA.PERIOD EQ 'Y' AND FA.STAT EQ ASTAT AND $
  				LONG(FA.YEAR_START) GE FIRST(TARGET_YEARS) AND LONG(FA.YEAR_START) LE LAST(TARGET_YEARS) $
  				AND FA.YEAR_START EQ FA.YEAR_END,COUNT)
  		IF COUNT NE N_ELEMENTS(TARGET_YEARS) THEN STOP
    	FA=FA[OK]

			S=SORT(FA.DATE_START) & FA=FA(S)
    	PERIOD_TXT =  '_Y_'+ FIRST(FA.YEAR_START) + '_'+ LAST(FA.YEAR_START)
    	FILE_LABEL = DIR_STATS_EXTRACT + PP_MODEL+UL+TMODEL+UL+AMAP+UL+APROD+PERIOD_TXT
    	FILE_LABEL=STRTRIM(STRCOMPRESS(FILE_LABEL, /REMOVE_ALL),2)
;			=====> See if output save already exists if so continue
    	TEST_FILE = FILE_LABEL+UL+ASTAT+'.SAVE'
    	EXIST=FILE_TEST(TEST_FILE)

    	IF EXIST EQ 1 AND OVERWRITE EQ 0 THEN CONTINUE


    	SET = FA.FULLNAME
;			LLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLL
    	NUM= LONARR(px,py)
    	SUM= FLTARR(px,py)
    	SSQ= FLTARR(px,py)
    	AVG=	FLTARR(PX,PY) 	& AVG(*,*)=MISSINGS(AVG)
    	STD=	FLTARR(PX,PY) 	& STD(*,*)=MISSINGS(STD)
    	CV=		FLTARR(PX,PY) 	& CV(*,*)	=MISSINGS(CV)

;			LLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLL
    	FOR _set = 0l,N_ELEMENTS(set)-1L DO BEGIN
    		PPD_FILE = SET(_set)
    		EXIST=FILE_TEST(PPD_FILE)
    		IF EXIST EQ 0  THEN CONTINUE

      	pp=READALL(PPD_FILE)
      	PRINT, PPD_FILE
      	ok = where(pp ne missings(pp),count)
      	IF count GE 1 THEN BEGIN
        	NUM[OK]=NUM[OK]+	1L
        	SUM[OK]=SUM[OK]+	PP[OK]
        	SSQ[OK]=SSQ[OK]+ PP[OK]*PP[OK]
      	ENDIF
    	ENDFOR
 ;		===========> Compute MEAN
			OK = WHERE(NUM GE 1,COUNT)
			IF COUNT GE 1 THEN BEGIN
				AVG[OK] = SUM[OK]/NUM[OK]
			ENDIF
;			============> Compute STD	And CV
			OK2 = WHERE(NUM GE 2,COUNT)
			IF count GE 1 THEN BEGIN
      	STD(OK2)= (((SSQ(OK2)-((SUM(OK2)*SUM(OK2))/NUM(OK2)))^0.5)/((NUM(OK2)-1)^0.5)) ;
      	CV(OK2)	=  100d*(STD(OK2)/AVG(OK2)) ;
    	ENDIF

; 		==================> Write out save files
     	SAVE_FILE = FILE_LABEL + UL+'MEAN.SAVE'
     	SAVE,FILENAME=SAVE_FILE, AVG,/COMPRESS

		 	SAVE_FILE = FILE_LABEL + UL+'STD.SAVE'
     	SAVE,FILENAME=SAVE_FILE, STD,/COMPRESS

     	SAVE_FILE = FILE_LABEL + UL+'CV.SAVE'
     	SAVE,FILENAME=SAVE_FILE, CV,/COMPRESS
  	ENDFOR ; MODEL
  ENDIF ; IF DO_PP_ANNUAL_VARIABILITY EQ 1 THEN BEGIN
;	|||||||||||||||||||||||||||||||||||||||||||||||||


;	************************************************************************
  IF DO_PP_STATS_2BROWSE GE 1 THEN BEGIN
;	************************************************************************
		OVERWRITE = DO_PP_STATS_2BROWSE EQ 2
		FOR _TMODEL = 0,N_ELEMENTS(TEMP_MODELS)-1L DO BEGIN
    TMODEL = TEMP_MODELS(_TMODEL)
    PRINT, TMODEL
    STATS = ['MEAN','CV']
		TARGETS = DIR_STATS_EXTRACT + PP_MODEL+UL+TMODEL+UL+AMAP+UL+APROD+ASTER+UL+STATS+'.SAVE'
    FA = FILE_ALL(TARGETS)
    OK = WHERE(FA.STAT NE MISSINGS(FA.STAT),COUNT)
    IF COUNT EQ 0 THEN STOP
    FA=FA[OK]

  	PROD_TXT = 'Mean Daily!CPrimary Production'


  	FOR _FILE = 0L,N_ELEMENTS(FA)-1 DO BEGIN
    	PPD_FILE = FA(_FILE).FULLNAME
    	APERIOD = FA(_FILE).PERIOD
    	ASTAT = FA(_FILE).STAT

			PNGFILE = DIR_STATS_BROWSE+FA(_FILE).NAME+'.PNG'
			EXIST = FILE_TEST(PNGFILE)
			IF EXIST EQ 1 AND OVERWRITE EQ 0 THEN CONTINUE

    	PRINT, 'Reading: '+PPD_FILE
    	PP = READALL(PPD_FILE)
    	IF N_ELEMENTS(PP) LT 10 THEN CONTINUE

   		IF APERIOD EQ 'DT' THEN BEGIN
     		DATE_TXT=[FA(_FILE).DATE_START,FA(_FILE).DATE_END]
     		j = dt_date2julian(DATE_TXT)
     		DATE_TXT= DT_FMT(J,/DAY)
     		DATE_TXT= DATE_TXT[0]+' -!C'+DATE_TXT[1]
     		DATE_TXT_CHARSIZE = 3
    	ENDIF

   		IF APERIOD EQ 'Y' THEN BEGIN
     		DATE_TXT=[FA(_FILE).DATE_START,FA(_FILE).DATE_END]
     		j = dt_date2julian(DATE_TXT)
     		DATE_TXT= DT_FMT(J,/DAY)
     		DATE_TXT= DATE_TXT[0]+' -!C'+DATE_TXT[1]
     		DATE_TXT_CHARSIZE = 3
    	ENDIF

			IF APERIOD EQ 'YM' THEN BEGIN
     		DATE_TXT=[FA(_FILE).DATE_START,FA(_FILE).DATE_END]
     		j = dt_date2julian(DATE_TXT)
     		DATE_TXT= DT_FMT(J,/DAY)
     		DATE_TXT= DATE_TXT[0]+' -!C'+DATE_TXT[1]
     		DATE_TXT_CHARSIZE = 3
    	ENDIF

;			==================>

    	IF ASTAT EQ 'MEAN' THEN APROD = 'PPD'
    	IF ASTAT EQ 'STD' THEN APROD = 'STD'
    	IF ASTAT EQ 'CV' THEN APROD = 'LOGPER'
    	IF ASTAT EQ 'CV' AND APERIOD EQ 'DT' THEN  APROD = 'PER'

    	IMAGE=SD_SCALES(PP,PROD=APROD,/DATA2BIN)
    	IMAGE(OK_LAND) = LAND_COLOR
    	OK = WHERE(LAND_MASK_THICK EQ 255 AND IMAGE EQ 0,COUNT)
    	IF COUNT GE 1 THEN IMAGE[OK] = 253

	    PP_LABEL = PP_MODEL + ' '+ TMODEL

			LABEL= DATE_TXT + '!C' + PP_LABEL

	;		============> LEGEND
	    LEG = COLOR_BAR_SCALE(PROD=APROD,/NAME,/UNIT,px= 600, py=135,/TRIM,GRACE=7, charsize=2.8,BACKGROUND=BACKGROUND,pos=[.04,.04,.96,.18],PAL= _PAL)
			SZ=SIZE(LEG,/STRUCT)
			XPOS = 0
			YPOS =  PY - SZ.DIMENSIONS[1] -1
			IF ADD_LEG EQ 1 THEN IMAGE(XPOS,YPOS) = LEG

			IMAGE = MAP_ADD_TXT(IMAGE,0.01,0.83,LABEL, COLOR=0,charsize=DATE_TXT_CHARSIZE,CHARTHICK=3)

    	PAL_SW3,R,G,B
    	WRITE_PNG,PNGFILE,IMAGE,R,G,B
 		ENDFOR ; for file
 	ENDFOR; FOR _TMODEL = 0,N_ELEMENTS(TEMP_MODELS)-1L DO BEGIN
ENDIF ; IF DO_PP_STATS_2BROWSE EQ 1 THEN BEGIN
;	||||||||||||||||||||||||||||||||||||||||||||||||||||||||||



; ***************************************************************
  IF  DO_PP_PNG_2AVI GE 1 THEN BEGIN
; *****************************************************************
   	PRINT, 'S T E P:    DO_PP_PNG_2AVI'
    PRINT,'make an avi file from PPD pngs '
    OVERWRITE = DO_PP_PNG_2AVI EQ 2
;   TS_IMAGES_PRODUCTS=['CHLOR_A']
    TS_IMAGES_EXT='PNG'
    MATH_TARGET='INTERP'
    EDIT_TARGET=''
    ;IF ASENSOR EQ 'AVHRR' THEN EDIT_TARGET=''
    FORM='ISERIES'
    FORM =''
    DO_PERIOD='DATE'
		FILE_LABEL = 'PP_VGPM_TMA-NEC-PPD'
		PRODUCTS = 'PPD'
		TS_IMAGE_EXT='PNG'

		FA_data = FILE_ALL(DIR_TS_IMAGES_BROWSE+FILE_LABEL+'*'+'-4avi.PNG')
    DATE_START=FA_DATA.DATE_START & S=SORT(DATE_START) & DATE_START=DATE_START(S)
		DD='!DD_'+STRMID(FIRST(DATE_START),0,8)+UL +STRMID(LAST(DATE_START),0,8)

  ; Strip off everything after INTERP from first file name for output avi name
    AVI_NAME = FA_DATA[0].FIRST_NAME
    POS = STRPOS(AVI_NAME,'-PPD')
    IF POS GE 0 THEN AVI_NAME = STRMID(AVI_NAME,0,POS+4)

    AVI_FILE  = DIR_TS_IMAGES_MOVIE + AVI_NAME +DASH+DD+'.AVI'
    FA_OUT = FILE_ALL(AVI_FILE)

    IF FA_OUT.FULLNAME NE '' THEN BEGIN
      IF MAX(FA_DATA.MTIME) LT FA_OUT.MTIME AND OVERWRITE EQ 0 THEN GOTO, DONE
    ENDIF;IF FA_OUT.FULLNAME NE ''

    MAKE_AVI,FILES=FA_DATA.FULLNAME,DIR_OUT=DIR_TS_IMAGES_MOVIE,FILE_LABEL=file_label,PAL=pal, $
              WIDTH=width, HEIGHT= height,BITS=bits,QUALITY=quality, FPS=fps, AVI_FILE=avi_file


  ENDIF;F DO_PP_PNG_2AVI EQ 1 THEN BEGIN
; ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||



; ***************************************************************
	IF  DO_STATS_2SHSTRATA GE 1 THEN BEGIN
; *****************************************************************
   	PRINT, 'S T E P:    DO_STATS_2SHSTRATA'
   	PRINT,'Extract ppd data from STATS images to make a MATRIX (MONTHLY X SHELLFISH STRATA)'
   	OVERWRITE = DO_STATS_2SHSTRATA EQ 2
   	SHSTRATA_MASK = READALL(DIR_DATA + 'shstrata_MASK.SAVE')
   	H=HISTOGRAM(SHSTRATA_MASK,MIN=0)&OK=WHERE(H GT 0) &   SUBAREAS=OK(1:*) ; 95 STRATA

		FOR _TMODEL = 0,N_ELEMENTS(TEMP_MODELS)-1L DO BEGIN
    	TMODEL = TEMP_MODELS(_TMODEL)
    	PRINT, TMODEL
    	ASTAT = 'MEAN'
    	APERIOD = 'YM'
			TARGETS = DIR_STATS_EXTRACT + PP_MODEL+UL+TMODEL+UL+AMAP+UL+APROD+ASTER+UL+ASTAT+'.SAVE'
    	FA = FILE_ALL(TARGETS)
    	OK = WHERE(FA.STAT EQ ASTAT AND FA.PERIOD EQ APERIOD,COUNT)
    	IF COUNT EQ 0 THEN STOP
    	FA=FA[OK]
; 		=====> Sort the data chron
      j=DT_DATE2JULIAN(FA.DATE_START)
      srt=SORT(J)
      FA=FA(srt)

;			=====> Make a structure to hold output stats
			DB 	= CREATE_STRUCT('NAME','','PROD','','PERIOD','','DATE_START','','DATE_END','','STRAT_NUM',0L)

			S=STATS(0,MISSING=0,/QUIET)
			S=STRUCT_COPY(S,TAGS=[0,1,2,3,4,5,6,7,8]) &
			DB=STRUCT_MERGE(DB,S)

			DB	=	REPLICATE(DB,N_ELEMENTS(FA)*N_ELEMENTS(SUBAREAS))

			COUNTER = -1L
  		FOR _FILE = 0L,N_ELEMENTS(FA)-1 DO BEGIN
    		PPD_FILE = FA(_FILE).FULLNAME
    		PRINT, 'Reading: '+PPD_FILE
    		PP = READALL(PPD_FILE)
    		FOR _SUBAREA = 0,N_ELEMENTS(SUBAREAS)-1 DO BEGIN
    		  COUNTER=COUNTER+1L
    			ASUBAREA = FIX(SUBAREAS(_subarea))
    			ok=WHERE(SHSTRATA_MASK EQ ASUBAREA)
    			DATA = PP[OK]
    			S=STATS(DATA,/QUIET)
    			DB(COUNTER).NAME=PPD_FILE
    			DB(COUNTER).PROD=APROD
    			DB(COUNTER).PERIOD=FA(_FILE).PERIOD
    			DB(COUNTER).DATE_START=FA(_FILE).DATE_START
    			DB(COUNTER).DATE_END=FA(_FILE).DATE_END
    			DB(COUNTER).STRAT_NUM=ASUBAREA
    			DB(COUNTER).N= S.N
    			DB(COUNTER).MIN= S.MIN
    			DB(COUNTER).MAX= S.MAX
    			DB(COUNTER).SUM= S.SUM
    			DB(COUNTER).SSQ= S.SSQ
    			DB(COUNTER).MED= S.MED
    			DB(COUNTER).MEAN= S.MEAN
    			DB(COUNTER).VAR= S.VAR
    			DB(COUNTER).STD= S.STD
    		ENDFOR ;FOR _SUBAREA = 0,N_ELEMENTS(SUBAREAS)-1 DO BEGIN
 			ENDFOR ; for file
	 		SAVEFILE = DIR_SHSTRATA + PP_MODEL+ul+TMODEL+ul+AMAP+ul+APROD+ul+'SHSTRATA_STATS.SAVE'
 			SAVE,FILENAME=SAVEFILE,/COMPRESS, DB
 			SAVE_2CSV,SAVEFILE
 		ENDFOR; 	FOR _TMODEL = 0,N_ELEMENTS(TEMP_MODELS)-1L DO BEGIN
	ENDIF ; IF DO_STATS_2SHSTRATA EQ 1 THEN BEGIN
;	||||||||||||||||||||||||||||||||||||||||||||||||||||||||||



; ***************************************************************
  IF  DO_PP_VGPM_SHSTRATA_TIMESERIES_PLOT GE 1 THEN BEGIN
; *****************************************************************
   	PRINT, 'S T E P:    DO_PP_VGPM_SHSTRATA_TIMESERIES_PLO'
   	PRINT,'Extract ppd data from STATS images to make a MATRIX (MONTHLY X SHELLFISH STRATA)'
   	OVERWRITE = DO_PP_VGPM_SHSTRATA_TIMESERIES_PLOT EQ 2
   	SHSTRATA_MASK = READALL(DIR_DATA + 'shstrata_MASK.SAVE')
   	H=HISTOGRAM(SHSTRATA_MASK,MIN=0)&OK=WHERE(H GT 0) &   SUBAREAS=OK(1:*) ; 95 STRATA
		FOR _TMODEL = 0,N_ELEMENTS(TEMP_MODELS)-1L DO BEGIN
    	TMODEL = TEMP_MODELS(_TMODEL)
    	PRINT, TMODEL
    	ASTAT = 'MEAN'
    	APERIOD = 'YM'
			TARGET = DIR_SHSTRATA + PP_MODEL+ul+TMODEL+ul+AMAP+ul+APROD+ul+'SHSTRATA_STATS.SAVE'
			FILE=FILELIST(TARGET)
			;PP_VGPM_TMANEC_PPD_SHSTRATA_STATS.SAVE
			PP_VGPM_SHSTRATA_TIMESERIES_PLOT,FILE=file,SENSOR_NAME=sensor_name,$
	                METHOD=method,MAP=map,DIR_OUT=DIR_PLOTS,PS=1

 		ENDFOR; 	FOR _TMODEL = 0,N_ELEMENTS(TEMP_MODELS)-1L DO BEGIN
 	ENDIF ; IF DO_STATS_2SHSTRATA_PLOT EQ 1 THEN BEGIN
;	||||||||||||||||||||||||||||||||||||||||||||||||||||||||||


; ***************************************************************
  IF  DO_PP_VGPM_SHSTRATA_TIMESERIES_MATRIX GE 1 THEN BEGIN
; *****************************************************************
   	PRINT, 'S T E P:    DO_PP_VGPM_SHSTRATA_TIMESERIES_MATRIX'
   	PRINT,'Extract ppd data from STATS images to make a MATRIX (MONTHLY X SHELLFISH STRATA)'
   	OVERWRITE = DO_PP_VGPM_SHSTRATA_TIMESERIES_PLOT EQ 2
   	SHSTRATA_MASK = READALL(DIR_DATA + 'shstrata_MASK.SAVE')
   	H=HISTOGRAM(SHSTRATA_MASK,MIN=0)&OK=WHERE(H GT 0) &   SUBAREAS=OK(1:*) ; 95 STRATA
		FOR _TMODEL = 0,N_ELEMENTS(TEMP_MODELS)-1L DO BEGIN
    	TMODEL = TEMP_MODELS(_TMODEL)
    	PRINT, TMODEL
    	ASTAT = 'MEAN'
    	APERIOD = 'YM'
			TARGET = DIR_SHSTRATA + PP_MODEL+ul+TMODEL+ul+AMAP+ul+APROD+ul+'SHSTRATA_STATS.SAVE'
			FILE=FILELIST(TARGET)
			DB = READALL(FILE)
			A=STRUCT_COPY(DB,TAGNAMES=['PROD','STRAT_NUM'])
			B=STRUCT_COPY(DB,TAGNAMES='MEAN')
			C=CREATE_STRUCT('YEAR',0,'MONTH',0) &C =REPLICATE(C,N_ELEMENTS(DB))
			D=STRUCT_MERGE(A,C)
			D=STRUCT_MERGE(D,B)
			D=STRUCT_RENAME(D,'DATE_START','DATE')
			D.YEAR=STRMID(DB.DATE_START,0,4)
			D.MONTH=STRMID(DB.DATE_START,4,2)
; 		=====> Now narrow selection down to those strata that have subareas codes
      STRATA = READALL('D:\IDL\SHAPEFILES\shstrata_regions.csv')
			ok = WHERE(STRATA.SCALLOP_SUBREGION NE '')
			TARGETS = STRATA[OK].STRAT_NUM
			S=SORT(TARGETS)& TARGETS= TARGETS(S)

			OK = WHERELIST(LONG(D.STRAT_NUM),'EQ',LONG(TARGETS))
			d=d(ok)
			SAVEFILE=DIR_SHSTRATA+'TEMP.SAVE'
			SAVE,FILENAME=SAVEFILE,D
			SAVE_2CSV,SAVEFILE
			;PP_VGPM_TMANEC_PPD_SHSTRATA_STATS.SAVE
			STRATA = READALL('D:\IDL\SHAPEFILES\shstrata_regions.csv')

 		ENDFOR; 	FOR _TMODEL = 0,N_ELEMENTS(TEMP_MODELS)-1L DO BEGIN
 	ENDIF ; IF DO_PP_VGPM_SHSTRATA_TIMESERIES_MATRIX EQ 1 THEN BEGIN
;	||||||||||||||||||||||||||||||||||||||||||||||||||||||||||


DONE:
PRINT, ROUTINE_NAME+ ' FINISHED'
END; END OF PROGRAM

