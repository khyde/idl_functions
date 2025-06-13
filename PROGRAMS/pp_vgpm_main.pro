; $ID:	PP_VGPM_MAIN.PRO,	2020-07-08-15,	USER-KJWH	$

  PRO PP_VGPM_MAIN , DIR_CHL=dir_chl,dir_par=DIR_PAR, DIR_SST=dir_sst,DISK=DISK,MAP=MAP,PP_MODEL=PP_MODEL,TEMP_MODEL=TEMP_MODEL
; NAME:
;       PP_VGPM_MAIN
;
; PURPOSE:
;       Calculate Primary Productivity using Behrenfeld-Falkowski Model (1997)
;
;
; KEYWORD PARAMETERS:
;  TEMP_MODEL = 'TBF' ; TEMPERATURE MODEL: BEHRENFELD-FALKOWSKI
;  TEMP_MODEL = 'TMA' ; TEMPERATURE MODEL: EXPONENTIAL(MOREL-ANTOINE
; OUTPUTS:
;
; MODIFICATION HISTORY:
;       Written by:  J.E.O'Reilly, March 24, 2003.
; July 28, td, work with new file naming convention, use struct_sd_read,use struct_sd_stats
; Aug 21,2003, td new land & coast file, new folder names
; Aug 26, 2003,jor, added reasonable data ranges for par,chl,sst; fixed land mask; Added DATA_RANGE TO mask
;	Jan 13,2004 jor, Added CHLOR_EUPHOTIC AND K_PAR to output structures
;-

  ROUTINE_NAME = 'PP_VGPM_MAIN'
  STATUS = ''

  S=STATS[0]
  IF N_ELEMENTS(PP_MODEL) EQ 0 THEN _PP_MODEL = 'VGPM' ELSE _PP_MODEL = PP_MODEL
  SENSOR='PP'
  SATELLITE='Z'
  DIR_ROOT=SENSOR
  IF N_ELEMENTS(MAP) EQ 0 THEN _MAP = 'NEC' ELSE _MAP = MAP

  IF N_ELEMENTS(TEMP_MODEL) EQ 0 THEN TEMPERATURE_MODEL = '' ELSE  TEMPERATURE_MODEL = TEMP_MODEL

;	******************************************
; ***** Directories for Resource Files *****
;	******************************************
  DIR_PROGRAMS       = 'D:\IDL\PROGRAMS\'
  DIR_DATA           = 'D:\IDL\DATA\'
  DIR_IMAGES         = 'D:\IDL\IMAGES\'

;	******************************
;	***** C O N S T A N T S  *****
;	******************************
  COMPUTER=GET_COMPUTER() & NOW = LONG(STRMID(DATE_NOW(),0,8))
  SLASH=DELIMITER(/SLASH) & DASH=DELIMITER(/DASH) & UL=DELIMITER(/UL) & CM=DELIMITER(/COMMA) & AS = DELIMITER(/ASTER)
  NOW = NUM2STR(LONG(STRMID(DATE_NOW(),0,8)))


;	**********************************************************************************
;	***** P A R A M E T E R S   T H A T  D E P E N D  O N  M A P   C H O I C E   *****
;	**********************************************************************************
   IF _MAP EQ 'NEC' THEN BEGIN
    PX = 1024L & PY=1024L
    PX=uLONG(PX)
    PY=uLONG(PY)
    LAND_MASK = READALL(DIR_IMAGES+'MASK_LAND-NEC-PXY_1024_1024.PNG')
    OK_LAND = WHERE(LAND_MASK EQ 1,COUNT_LAND)
    BATHY = READALL(DIR_IMAGES+'MASK_BATHY-NEC-PXY_1024_1024-100M-EDIT.png')
    CLOUDIER, IMAGE=BATHY,CLOUDS=1,MASK=MASK,BOX=2,/QUIET
    OK_BATHS = WHERE(MASK EQ 1,COUNT_BATHY)

    DIR_CHL='e:\SEAWIFS\TS_IMAGES\SAVE\'
    DIR_PAR='e:\SEAWIFS\TS_IMAGES\SAVE\'
    DIR_SST='e:\AVHRR\TS_IMAGES\SAVE\'

    CHLOR_A_TARGETS = '!D_*SEAWIFS-OV2-REPRO4-NEC-CHLOR_A-INTERP-TS_IMAGES.SAVE'
    PAR_TARGETS     = '!D_*SEAWIFS-OV2-REPRO4-NEC-PAR-INTERP-TS_IMAGES.SAVE'
    SST_TARGETS     = '!D_*AVHRR-CW_CD-NEC-SST-INTERP-TS_IMAGES.SAVE'
  ENDIF
  IF _MAP EQ 'L3B' THEN BEGIN
    NBINS=5940423L
    PX=1L & PY = 5940423L
    COUNT_LAND = 0
    COUNT_BATHY = 0
    CHLOR_A_TARGETS= ''
    PAR_TARGETS = '  '
    SST_TARGERTS = ''
    LAND_MASK = REPLICATE(0,NBINS)

    DIR_CHL='G:\SEAWIFS\TS_IMAGES\SAVE\'
    DIR_PAR='G:\SEAWIFS\TS_IMAGES\SAVE\'
;   DIR_SST='E:\AVHRR\TS_IMAGES\SAVE\'
    DIR_SST='F:\COMBO\TS_IMAGES\SAVE\' ;  MORE THAN 1 SENSOR

    CHLOR_A_TARGETS = '!D_*-SEAWIFS-OV2-REPRO4-L3B-CHLOR_A-INTERP-TS_IMAGES.SAVE'
    PAR_TARGETS     = '!D_*-SEAWIFS-OV2-REPRO4-L3B-PAR-INTERP-TS_IMAGES.SAVE'
;   SST_TARGETS     = '!D_*-TS_IMAGES-AVHRR-N00-GDM-L3B-SST-INTERP-TS_IMAGES.SAVE'
    SST_TARGETS     = '!D_*-L3B-SST-INTERP-TS_IMAGES.SAVE' ;  MORE THAN 1 SENSOR

  ENDIF

;	******************************************************************
; ***** V A L I D   S A T E L L I T E   D A T A   R A N G E S  *****
;	******************************************************************
  CHLOR_A_RANGE = [0.0  , 200.0]
  PAR_RANGE     = [0.0  ,  75.0]
  SST_RANGE     = [-3.0 ,  37.0]
  NOTES_RANGE = ''
  NOTES_RANGE = NOTES_RANGE+'CHLOR_A-RANGE_GT_'+ NUM2STR(CHLOR_A_RANGE[0])  +'_LT_'+NUM2STR(CHLOR_A_RANGE[1])+';'
  NOTES_RANGE = NOTES_RANGE+'PAR-RANGE_GT_'    + NUM2STR(PAR_RANGE[0])      +'_LT_'+NUM2STR(PAR_RANGE[1])+';'
  NOTES_RANGE = NOTES_RANGE+'SST-RANGE_GT_'    + NUM2STR(SST_RANGE[0])      +'_LT_'+NUM2STR(SST_RANGE[1])

  TARGET_YEARS = [1998,1999,2000,2001,2002]

;	*************************************
;	***** D E F A U L T    D I S K  *****
;	*************************************
	IF N_ELEMENTS(DISK) EQ 0 THEN BEGIN
	  IF computer EQ 'LOLIGO'   THEN DISK = 'H:'
	  IF computer EQ 'BURRFISH' THEN DISK = 'G:'
	  IF computer EQ 'SUNDIAL'  THEN DISK = 'E:'
	  IF computer EQ 'SEAROBIN'  THEN DISK = 'E:'
	  IF computer EQ 'FLOUNDER'  THEN DISK = 'E:'
	ENDIF

;	*************************************************
;	***** O U T P U T   D I R E C T O R I E S   *****
;	*************************************************
  path = DISK + SLASH+ DIR_ROOT + SLASH ;;;
  DIR_SAVE              = path+'SAVE'             +SLASH
  DIR_LOG               = path+'log'              +SLASH
  DIR_REPORT            = path+'report'           +SLASH
  DIR_PROBLEMS          = path+'problems'         +SLASH

  DIR_ALL = [DIR_CHL,DIR_PAR,DIR_SST,DIR_SAVE,DIR_REPORT,DIR_PROBLEMS]

;	******************************************************************
; *********** J O B  S W I T C H E S  ******************************
;	******************************************************************
  DO_CHECK_DIRS                 = 1  ; Normally, keep this switch on
  DO_PP_DAILY_SAVE              = 1  ; 1 = DO  2 = OVERWRITE



;	###############################################
; #####  B E G I N   P R O C E S S I N G    #####
;	###############################################

; *********************************************
  IF DO_CHECK_DIRS GE 1 THEN BEGIN
; *********************************************
    PRINT, 'S T E P:    DO_CHECK_DIRS'
    FOR N=0,N_ELEMENTS(DIR_ALL)-1 DO BEGIN & AFILE = STRMID(DIR_ALL(N),0,STRLEN(DIR_ALL(N))-1) &
      IF FILE_TEST(AFILE,/DIRECTORY) EQ 0L THEN FILE_MKDIR,AFILE &  ENDFOR
  ENDIF
; |||||||||||||||||||||||||||||||||||||||||||||||||


; ************************************************************************
  IF DO_PP_DAILY_SAVE GE 1 THEN BEGIN
; ************************************************************************
    OVERWRITE = DO_PP_DAILY_SAVE EQ 2
    FOR _TEMPERATURE_MODEL = 0,N_ELEMENTS(TEMPERATURE_MODEL)-1L DO BEGIN
      TEMP_MODEL = TEMPERATURE_MODEL(_TEMPERATURE_MODEL)
      IF TEMP_MODEL EQ '' THEN _UL = '' ELSE _UL=UL
      METHOD = _PP_MODEL + _UL+ TEMP_MODEL
      PRINT, METHOD
;     REPORT  = DIR_REPORT+DIR_ROOT+ul+_PP_MODEL+UL+METHOD+UL+_MAP+UL+'PPD'+UL+NOW+'.TXT'
      REPORT  = DIR_REPORT+SENSOR+dash+satellite+dash+METHOD+dash+_MAP+dash+'PPD'+dash+NOW+'.TXT'

      LIST, REPORT,FILE=REPORT,/NOSEQ,/NOHEADING
;     =====> Get all chl files
      CHL_FILES= DIR_CHL + CHLOR_A_TARGETS


      FA_CHL = FILE_ALL(CHL_FILES)
      IF N_ELEMENTS(FA_CHL.FULLNAME) LT 2 THEN STOP
      S=SORT(FA_CHL.DATE_START) & FA_CHL=FA_CHL(S)

;     =====> Get all PAR files
      PAR_FILES= DIR_PAR + PAR_TARGETS
      FA_PAR    = FILE_ALL(PAR_FILES)
      IF N_ELEMENTS(FA_PAR.FULLNAME) LT 2 THEN STOP
      S=SORT(FA_PAR.DATE_START) & FA_PAR=FA_PAR(S)

;     ====== Get all SST files
      SST_FILES= DIR_SST + SST_TARGETS
      FA_SST = FILE_ALL(SST_FILES)
      IF N_ELEMENTS(FA_SST.FULLNAME) LT 2 THEN STOP
      S=SORT(FA_SST.DATE_START) & FA_SST=FA_SST(S)

;     LLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLL
;     Process Each set of Files With chl controling the triplets files
      FOR _file = 0,N_ELEMENTS(FA_CHL)-1L DO BEGIN

        CHL_FILE = FA_CHL(_file).fullname
        adate = FA_CHL(_file).date_start
        PERIOD_TXT=FA_CHL(_file).PERIOD

;       =====> Get Matching PAR for this day
        ok_par = WHERE(FA_PAR.date_start EQ adate,COUNT)
        IF COUNT NE 1 THEN CONTINUE
        PAR_FILE = FA_PAR(ok_par).fullname

;       =====> Get matching SST for this day
        ok_sst = WHERE(FA_SST.date_start EQ adate,COUNT)
        IF COUNT NE 1 THEN CONTINUE
        SST_FILE = FA_SST(ok_sst).fullname


;       =====> Check if output save file exists if so then skip it
        SAVEFILE = DIR_SAVE + PERIOD_TXT+dash+SENSOR+dash+SATELLITE+dash+METHOD+dash+_MAP+dash+'PPD'+'.SAVE'

        FA_SAVE=FILE_INFO(SAVEFILE)

        IF FA_CHL(_file).MTIME LT FA_SAVE.MTIME AND FA_PAR(OK_PAR).MTIME LT FA_SAVE.MTIME $
              AND FA_SST(OK_SST).MTIME LT FA_SAVE.MTIME AND OVERWRITE EQ 0 THEN CONTINUE

;       =====> Determine Day of Year
        doy = DATE_2DOY(adate) & doy = FIX(ROUND(DOY)) & doy=doy[0]

;       =====> Read the CHLOR_A Satellite data array for the NEC area
        CHL_SAT=STRUCT_SD_READ(CHL_FILE, PROD='CHLOR_A',STRUCT=struct,COUNT=count,SUBS=subs,ERROR=ERROR)
        STRUCT_CHL=STRUCT

;       =====> Read the PAR Satellite data array for the NEC area
        PAR_SAT=STRUCT_SD_READ(PAR_FILE, PROD='PAR',STRUCT=struct,COUNT=count,SUBS=subs,ERROR=ERROR)
        STRUCT_PAR=STRUCT

;       =====> Read the SST Satellite data array for the NEC area
        SST_SAT=STRUCT_SD_READ(SST_FILE, PROD='SST',STRUCT=struct,COUNT=count,SUBS=subs,ERROR=ERROR)
        STRUCT_SST=STRUCT

;       ===> Make an image_mask to represent good data [0] and bad data to be masked (=1)
        image_mask = BYTE(CHL_SAT) & image_mask(*,*) = 1 ; initially bad and masked

        OK_ALL = WHERE(LAND_MASK EQ 0 AND $
                chl_sat NE missings(chl_sat) AND chl_sat GT CHLOR_A_RANGE[0] AND chl_sat LT CHLOR_A_RANGE[1] AND $
                par_sat NE missings(par_sat) AND par_sat GT par_RANGE[0] AND par_sat LT par_RANGE[1] AND $
                sst_sat NE missings(sst_sat) AND sst_sat GT sst_RANGE[0] AND sst_sat LT sst_RANGE[1], count_all)

        IF count_all EQ 0 THEN CONTINUE ;|>|>|>|>|
        image_mask(ok_all) = 0 ; good data

;       ===> The pp program (PP_BEHRENFELD_NEC) below expects a full image... so we will mask after calculating pp
        OK_MISS=WHERE(image_mask EQ 1, count_MISS)

;       ===> Find the values over water that are outside the ranges for the 3 input sats
        IF COUNT_LAND GE 1 THEN BEGIN
          OK_OUTLIERS = WHERE(LAND_MASK EQ 0 AND IMAGE_MASK EQ 1,COUNT_OUTLIERS)
        ENDIF ELSE BEGIN
          COUNT_OUTLIERS = 0
        ENDELSE

;       =====> Get the size of the Chl_sat
        sz = SIZE(chl_sat)

;       =====> Calculate Day Length for the NEC area
        day_length = I_SUN_KIRK_DAY_LENGTH_MAP(DOY,MAP=_MAP)

;       =====> Ensure that DAY_LENGTH array is same size as CHL_SAT
        sz = SIZE(day_length)
        IF sz[1] NE PX OR sz(2) NE PY THEN STOP

;       *************************************************************************************
;       ********************     R U N     P P     M O D E L    *****************************
;       *************************************************************************************
        PPD = FLOAT(CHL_SAT) & PPD(*)=MISSINGS(PPD)
        CHLOR_EUPHOTIC = PPD
        K_PAR=PPD


				IF _PP_MODEL EQ 'VGPM' THEN BEGIN

        	PPD(OK_ALL)=PP_VGPM(CHL_SAT=chl_SAT(OK_ALL), SST_SAT=sst_SAT(OK_ALL),PAR=par_SAT(OK_ALL),$ ; INPUT
                            DAY_LENGTH=day_length(OK_ALL),TEMP_MODEL=TEMP_MODEL,$  ; INPUT
                            CHLOR_EUPHOTIC= _CHLOR_EUPHOTIC, K_PAR= _K_PAR)         ; OUTPUT FROM PP_VGPM
        ENDIF

				IF _PP_MODEL EQ 'HYR2' THEN BEGIN

        	PPD(OK_ALL)=PP_HYR2(CHL_SAT=chl_SAT(OK_ALL), SST_SAT=sst_SAT(OK_ALL),PAR=par_SAT(OK_ALL),$ ; INPUT
                            DAY_LENGTH=day_length(OK_ALL),TEMP_MODEL=TEMP_MODEL,$  ; INPUT
                            CHLOR_EUPHOTIC= _CHLOR_EUPHOTIC, K_PAR= _K_PAR)         ; OUTPUT FROM PP_VGPM
        ENDIF

        CHLOR_EUPHOTIC(OK_ALL) = _CHLOR_EUPHOTIC
        K_PAR(OK_ALL)          = _K_PAR

;       ============> make missing missing
        IF count_MISS GE 1 THEN PPD(OK_MISS) = MISSINGS(PPD)
;       ====================>
;       Print out statistics on all arrays provided to pp model
        PRINT, 'DATE: ',ADATE
;       Print out statistics on all arrays provided to REPORT TXT FILE
        LIST,/NOSEQ,/NOHEADING,FILE=REPORT
        LIST,/NOSEQ,/NOHEADING,FILE=REPORT , 'ADATE: '+ STRING(ADATE)
        LIST,/NOSEQ,/NOHEADING,FILE=REPORT , 'DOY: ' + STRING(DOY)
        LIST,/NOSEQ,/NOHEADING,FILE=REPORT , 'CHL_FILE: '+ CHL_FILE
        LIST,/NOSEQ,/NOHEADING,FILE=REPORT , 'PAR_FILE: '+ PAR_FILE
        LIST,/NOSEQ,/NOHEADING,FILE=REPORT , 'SST_FILE: '+ SST_FILE
        LIST,/NOSEQ,/NOHEADING,FILE=REPORT , 'DAY LENGTH RANGE: ' + NUM2STR(MIN(DAY_LENGTH))      +' To ' + NUM2STR(MAX(DAY_LENGTH))
        LIST,/NOSEQ,/NOHEADING,FILE=REPORT , 'Chl Range: '        + NUM2STR(MIN(chl_sat(ok_all))) +' To ' + NUM2STR(MAX(chl_sat(ok_all)))
        LIST,/NOSEQ,/NOHEADING,FILE=REPORT , 'PAR Range: '        + NUM2STR(MIN(PAR_sat(ok_all))) +' To ' + NUM2STR(MAX(PAR_sat(ok_all)))
        LIST,/NOSEQ,/NOHEADING,FILE=REPORT , 'SST Range: '        + NUM2STR(MIN(SST_sat(ok_all))) +' To ' + NUM2STR(MAX(SST_sat(ok_all)))

				LIST,/NOSEQ,/NOHEADING,FILE=REPORT , 'CHLOR_EUPHOTIC Range: ' + NUM2STR(MIN(CHLOR_EUPHOTIC(ok_all))) 	+' To ' + NUM2STR(MAX(CHLOR_EUPHOTIC(ok_all)))
  			LIST,/NOSEQ,/NOHEADING,FILE=REPORT , 'K_PAR Range: '        	+ NUM2STR(MIN(K_PAR(ok_all)))      			+' To ' + NUM2STR(MAX(K_PAR(ok_all)))

        LIST,/NOSEQ,/NOHEADING,FILE=REPORT , 'PPD Range: '        		+ NUM2STR(MIN(PPD(ok_all)))      				+' To ' + NUM2STR(MAX(PPD(ok_all)))



;       =====> Make Mask for Savefile
        IF _MAP NE 'L3B' THEN BEGIN
;         *************************************
;         *****  Make Mask for STRUCT_SD  *****
;         *************************************
;         ===> NOT_MASK (good data , 0b)
          CODE_NAME = 'NOT_MASK'
          MASK=BYTE(PPD) & MASK(*,*)=0B
          CODE_MASK     =          [0B]
          CODE_NAME_MASK=[CODE_NAME]

;         ===> LAND
          CODE_NAME='LAND'
          ACODE = MAX(CODE_MASK)+1B
          CODE_MASK     =[CODE_MASK,ACODE]
          CODE_NAME_MASK=[CODE_NAME_MASK,CODE_NAME]
          IF COUNT_LAND GE 1 THEN MASK(OK_LAND)  = ACODE

;         ===> OUTLIERS
          CODE_NAME='OUTLIERS'
          ACODE = MAX(CODE_MASK)+1B
          CODE_MASK     =[CODE_MASK,ACODE]
          CODE_NAME_MASK=[CODE_NAME_MASK,CODE_NAME]
          IF COUNT_OUTLIERS GE 1 THEN MASK(OK_OUTLIERS)  = ACODE
        ENDIF

;       ===> Encode PPD data to integer type and Write Structure
 				DATA_UNITS=UNITS('PPD')
 				SAVEFILE_PPD= SAVEFILE

        IMAGE=FIX(PPD) & IMAGE(*,*)= MISSINGS(IMAGE)
        IMAGE(OK_ALL) = SD_SCALES(PPD(OK_ALL),PROD='PPD',/DATA2INT,SCALING=SCALING,INTERCEPT=INTERCEPT,SLOPE=SLOPE,TRANSFORMATION=TRANSFORMATION)

        STRUCT_SD_WRITE,SAVEFILE_PPD,PROD='PPD', $
                  IMAGE=IMAGE,      MISSING_CODE=MISSINGS(IMAGE), $
                  MASK=MASK,        CODE_MASK=CODE_MASK,    CODE_NAME_MASK=CODE_NAME_MASK, $
                  SCALING=SCALING,  INTERCEPT=INTERCEPT,  SLOPE=SLOPE,TRANSFORMATION=TRANSFORMATION,$
                  DATA_UNITS=DATA_UNITS,PERIOD=PERIOD_TXT, $
                  SENSOR=[STRUCT_chl.sensor,STRUCT_par.sensor,STRUCT_sst.sensor],$
                  SATELLITE=[STRUCT_chl.satellite,STRUCT_par.satellite,STRUCT_sst.satellite],$
                  SAT_EXTRA=[STRUCT_chl.sat_extra,STRUCT_par.sat_extra,STRUCT_sst.sat_extra],$
                  METHOD=[STRUCT_chl.method,STRUCT_par.method,STRUCT_sst.method],$
                  SUITE =[STRUCT_chl.suite,STRUCT_par.suite,STRUCT_sst.suite],$
                  INFILE =[chl_file,par_file,sst_file],$
                  NOTES=NOTES_RANGE,       ERROR=ERROR


STOP

				IF TEMP_MODEL EQ 'TMA' AND _MAP NE 'L3B' THEN BEGIN

	;       ===> Encode CHLOR_EUPHOTIC data to integer type and Write Structure
	 				DATA_UNITS=UNITS('CHLOR_EUPHOTIC')
					SAVEFILE_CHLOR_EUPHOTIC=REPLACE(SAVEFILE,'PPD','CHLOR_EUPHOTIC')
	        IMAGE=FIX(CHLOR_EUPHOTIC) & IMAGE(*,*)= MISSINGS(IMAGE)
	        IMAGE(OK_ALL) = SD_SCALES(CHLOR_EUPHOTIC(OK_ALL),PROD='CHLOR_EUPHOTIC',/DATA2INT,SCALING=SCALING,INTERCEPT=INTERCEPT,SLOPE=SLOPE,TRANSFORMATION=TRANSFORMATION)

	        STRUCT_SD_WRITE,SAVEFILE_CHLOR_EUPHOTIC,PROD='CHLOR_EUPHOTIC', $
	                  IMAGE=IMAGE,      MISSING_CODE=MISSINGS(IMAGE), $
	                  MASK=MASK,        CODE_MASK=CODE_MASK,    CODE_NAME_MASK=CODE_NAME_MASK, $
	                  SCALING=SCALING,  INTERCEPT=INTERCEPT,  SLOPE=SLOPE,TRANSFORMATION=TRANSFORMATION,$
	                  DATA_UNITS=DATA_UNITS,PERIOD=PERIOD_TXT, $
	                  SENSOR=[STRUCT_chl.sensor,STRUCT_par.sensor,STRUCT_sst.sensor],$
	                  SATELLITE=[STRUCT_chl.satellite,STRUCT_par.satellite,STRUCT_sst.satellite],$
	                  SAT_EXTRA=[STRUCT_chl.sat_extra,STRUCT_par.sat_extra,STRUCT_sst.sat_extra],$
	                  METHOD=[STRUCT_chl.method,STRUCT_par.method,STRUCT_sst.method],$
	                  SUITE =[STRUCT_chl.suite,STRUCT_par.suite,STRUCT_sst.suite],$
	                  INFILE =[chl_file,par_file,sst_file],$
	                  NOTES=NOTES_RANGE,       ERROR=ERROR

	;       ===> Encode K_PAR data to integer type and Write Structure
					DATA_UNITS=UNITS('K_PAR')
					SAVEFILE_K_PAR=REPLACE(SAVEFILE,'PPD','K_PAR')
	        IMAGE=FIX(K_PAR) & IMAGE(*,*)= MISSINGS(IMAGE)
	        IMAGE(OK_ALL) = SD_SCALES(K_PAR(OK_ALL),PROD='K_PAR',/DATA2INT,SCALING=SCALING,INTERCEPT=INTERCEPT,SLOPE=SLOPE,TRANSFORMATION=TRANSFORMATION)

	        STRUCT_SD_WRITE,SAVEFILE_K_PAR,PROD='K_PAR', $
	                  IMAGE=IMAGE,      MISSING_CODE=MISSINGS(IMAGE), $
	                  MASK=MASK,        CODE_MASK=CODE_MASK,    CODE_NAME_MASK=CODE_NAME_MASK, $
	                  SCALING=SCALING,  INTERCEPT=INTERCEPT,  SLOPE=SLOPE,TRANSFORMATION=TRANSFORMATION,$
	                  DATA_UNITS=DATA_UNITS,PERIOD=PERIOD_TXT, $
	                  SENSOR=[STRUCT_chl.sensor,STRUCT_par.sensor,STRUCT_sst.sensor],$
	                  SATELLITE=[STRUCT_chl.satellite,STRUCT_par.satellite,STRUCT_sst.satellite],$
	                  SAT_EXTRA=[STRUCT_chl.sat_extra,STRUCT_par.sat_extra,STRUCT_sst.sat_extra],$
	                  METHOD=[STRUCT_chl.method,STRUCT_par.method,STRUCT_sst.method],$
	                  SUITE =[STRUCT_chl.suite,STRUCT_par.suite,STRUCT_sst.suite],$
	                  INFILE =[chl_file,par_file,sst_file],$
	                  NOTES=NOTES_RANGE,       ERROR=ERROR
        ENDIF ; IF TEMP_MODEL EQ 'TMA' AND _MAP NE 'L3B'

      ENDFOR;FOR _file = 0,N_ELEMENTS(FA_CHL)-1L DO BEGIN


    ENDFOR ; FOR TEMP MODEL
  ENDIF ; IF DO_PP_DAILY_SAVE EQ 1 THEN BEGIN
; |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||



DONE:
PRINT, ROUTINE_NAME+ ' FINISHED'
END; END OF PROGRAM

