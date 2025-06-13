; $ID:	MISC_MAIN.PRO,	2020-07-08-15,	USER-KJWH	$
;+
; This Program is a main for MISC


; HISTORY:
;     Oct 15, 2004  Written by: J.E. O'Reilly
;-
; *************************************************************************

PRO MISC_MAIN
  ROUTINE_NAME='MISC_MAIN'

	DISK = 'D:'
  DELIM=DELIMITER(/PATH)
  PATH = DISK+DELIM + 'PROJECTS\MISC'+DELIM

	MAP = 'NEC'

 	LANDMASK = READALL('D:\IDL\IMAGES\MASK_NEC.PNG')
  OK_LAND = WHERE(LANDMASK NE 255)
  OK_COAST = WHERE(LANDMASK EQ 0)
  MASK = LANDMASK & MASK(*,*) = 0
  MASK(OK_LAND) = 1

; **************************************
; Directories
; Edit these as needed

	DIR_DATA = path+'DATA'+delim
  DIR_SAVE = path+'SAVE'+delim
  DIR_FLT  = path+'FLT'+delim
  DIR_PLOTS = path+'PLOTS'+delim
  DIR_ERRORS = path+'ERRORS'+delim
  DIR_TEMP   = path+'TEMP'+delim
  DIR_MOVIES   = path+'MOVIES'+delim

	DIR_ALL = [DIR_DATA,DIR_SAVE,DIR_PLOTS,DIR_ERRORS,DIR_FLT, DIR_TEMP, DIR_MOVIES]


; ===> FILES
	PNG_FILES = DIR_PLOTS + 'template.csv'
	SAVE_FILE  = DIR_SAVE  + '*.save'



; ****************************
; Set up color system defaults
	SETCOLOR



; ********************************************************************************
; ***** U S E R    S W I T C H E S  Controlling which Processing STEPS to do *****
; ********************************************************************************
;	0 (Do not do the step)
;	1 (Do the step)
; 2 (Do the step and OVERWRITE any output if it alread exists)

; ================>
; Switches controlling which Processing STEPS to do:
	DO_CHECK_DIRS = 1 ; GOOD IDEA TO ALWAYS KEEP THIS SWITCH ON




 	DO_SST_MAB_HARE				= 0
 	DO_CHLOR_A_MAB_HARE   = 0
 	DO_CLOUD_PROBABILITY  = 0




; *********************************************
; ******** C H E C K   D I R S  ***************
; *********************************************
  IF DO_CHECK_DIRS GE 1 THEN BEGIN
    PRINT, 'S T E P:    DO_CHECK_DIRS'
    FOR N=0,N_ELEMENTS(DIR_ALL)-1 DO BEGIN
      AFILE = STRMID(DIR_ALL(N),0,STRLEN(DIR_ALL(N))-1)
      IF FILE_TEST(AFILE,/DIRECTORY) EQ 0L THEN FILE_MKDIR,AFILE
    ENDFOR
  ENDIF ; IF DO_CHECK_DIRS GE 1 THEN BEGIN
; |||||||||||||||||||||||||||||||||||||||||||||||||




; **************************************************************
 	IF DO_SST_MAB_HARE GE 1 THEN BEGIN
; **************************************************************
		OVERWRITE = DO_SST_MAB_HARE GE 2
    PRINT, 'S T E P:    DO_SST_MAB_HARE'
		DRIVES=GET_DRIVE_NAMES()
		OK=WHERE(DRIVES.NAME EQ 'IOMEGA_HDD_13')
		DRIVE_IN = DRIVES[OK].DRIVE
		folder = 'ts_images_save_sst_ec\
	  FILES = FILE_SEARCH(DRIVE_IN+ folder + '!D_*N4ATG*.SAVE')

STOP
		DATA = READ_CSV(DIR_DATA+'HARE_STATIONS.CSV')


		DATE_RANGE = ['20060817','20060817']
		JD_RANGE = DATE_2JD(DATE_RANGE)
		FN = PARSE_IT(FILES,/ALL)
		JD = DATE_2JD(FN.DATE_START)
		OK = WHERE(JD GE JD_RANGE[0] AND JD LE JD_RANGE[1])
		FILES = FILES[OK]	 & 	FN=FN[OK]
		MAP_IN  = 'EC'
		MAP_OUT = 'MAB'
		PAL = 'PAL_SW3'

		PAL = 'PAL_SW3'
		TITLE_SLIDE = 1
		DIR_OUT = DIR_TEMP
		PROD = 'SST'
	 	_USE_PROD = 'SST'
	 	COLORBAR_TITLE = UNITS(_USE_PROD,/NAME,/UNIT)
	 	EVENT = 'SUMMER_UPWELLING'



		I=STRUCT_SD_REMAP(FILES=FILES,MAP_OUT='NEC')
		STOP
		FILES = REPLACE(FILES,'-EC-','-NEC-')
;		===>
    FILES=DIR_SAVE+'!D_20060817-N4ATG-NEC-PXY_1024_1024-SST-INTERP-TS_IMAGES.SAVE'
		STRUCT_SD_SAVE_2FLT,FILES, DIR_OUT=DIR_SAVE



		STRUCT_SD_2PNG,FILES,/ADD_COLORBAR,OVERWRITE=OVERWRITE,/ADD_LAND,$
										/ADDDATE ,/ADD_BATHY,BATHS=100,PAL=PAL,MAP_OUT=MAP_OUT,$
										DIR_OUT=DIR_TEMP,USE_PROD=_USE_PROD,COLORBAR_TITLE=COLORBAR_TITLE ,LAND_COLOR=254

		AFILE = DIR_TEMP+'!D_20060817-N4ATG-MAB-PXY_700_840-SST-INTERP-TS_IMAGES-LEG.PNG'
		IM=READ_PNG(AFILE,R,G,B)
		ZWIN,IM
		MAP_MAB
		TV,IM
		PLOTS, DATA.LON,DATA.LAT,PSYM=1
		IM=TVRD()
		ZWIN
		BFILE=REPLACE(AFILE,'-LEG.PNG','-LEG-STA.PNG')
		WRITE_PNG,BFILE,IM,R,G,B




		STOP
	ENDIF
;	|||||||||||||||||||||||||||||||||||||||||||||




; **************************************************************
 	IF DO_CHLOR_A_MAB_HARE GE 1 THEN BEGIN
; **************************************************************
		OVERWRITE = DO_CHLOR_A_MAB_HARE GE 2
    PRINT, 'S T E P:    DO_CHLOR_A_MAB_HARE'
		DRIVES=GET_DRIVE_NAMES()
		OK=WHERE(DRIVES.NAME EQ 'IOMEGA_HDD_13')
		DRIVE_IN = DRIVES[OK].DRIVE
		folder = 'ts_images_save_chlor_a_nec_MLAC\


	  ;FILES = FILE_SEARCH(DRIVE_IN+ folder + '!D_*-SEAWIFS-REPRO5-NEC-CHLOR_A-INTERP-TS_IMAGES.SAVE')
		FILES = FILE_SEARCH('D:\PROJECTS\MISC\SAVE\!D_*-SEAWIFS-REPRO5-EC-CHLOR_A-INTERP-TS_IMAGES.SAVE')
		A=STRUCT_SD_REMAP(FILES=FILES, MAP_OUT='NEC')
		FILES=DIR_SAVE+'!D_20060817-SEAWIFS-REPRO5-NEC-PXY_1024_1024-CHLOR_A-INTERP-TS_IMAGES.SAVE'
		;		===>
		STRUCT_SD_SAVE_2FLT,FILES, DIR_OUT=DIR_SAVE

		A=STRUCT_SD_REMAP(FILES=FILES, MAP_OUT='MAB')

		MAP_OUT = 'MAB'

STOP
    FILES = FILE_SEARCH(DIR_SAVE + '!D_20060817*MAB*.SAVE')
STOP
		DATA = READ_CSV(DIR_DATA+'HARE_STATIONS.CSV')



		PAL = 'PAL_SW3'
		TITLE_SLIDE = 1
		DIR_OUT = DIR_TEMP
		PROD = 'CHLOR_A'
	 	_USE_PROD = 'CHLOR_A'
	 	COLORBAR_TITLE = UNITS(_USE_PROD,/NAME,/UNIT)
	 	EVENT = 'SUMMER_UPWELLING'






		STRUCT_SD_2PNG,FILES,/ADD_COLORBAR,OVERWRITE=OVERWRITE,/ADD_LAND,$
										/ADDDATE ,/ADD_BATHY,BATHS=100,PAL=PAL,MAP_OUT=MAP_OUT,$
										DIR_OUT=DIR_TEMP,USE_PROD=_USE_PROD,COLORBAR_TITLE=COLORBAR_TITLE ,LAND_COLOR=254

		AFILE = DIR_TEMP+'!D_20060817-SEAWIFS-REPRO5-MAB-PXY_700_840-CHLOR_A-INTERP-TS_IMAGES-LEG.PNG'
		IM=READ_PNG(AFILE,R,G,B)
		ZWIN,IM
		MAP_MAB
		TV,IM
		PLOTS, DATA.LON,DATA.LAT,PSYM=1
		IM=TVRD()
		ZWIN
		BFILE=REPLACE(AFILE,'-LEG.PNG','-LEG-STA.PNG')
		WRITE_PNG,BFILE,IM,R,G,B




		STOP
	ENDIF
;	|||||||||||||||||||||||||||||||||||||||||||||



;	*****************************************
	IF DO_CLOUD_PROBABILITY GE 1 THEN BEGIN
;	*****************************************
		FILE= FILELIST(DIR_WORK+'\STATS\!ANNUAL*NEC-*CLDICE*.SAVE')
		LIST, FILE
		FN=PARSE_IT(FILE)



		PNG_FILE = !DIR_BROWSE + FN.FIRST_NAME+'-CON.PNG'
		LEVELS = [ 50,55,60,65,70,75,80,85,90,95,100]

		MED = 33
		C_ANNOTATION = ROUNDS(LEVELS,2)
		C_ANNOTATION = NUM2STR(LEVELS,TRIM=2)
		C_COLORS = [251,252,253,254,255,255,255,255,255,255,255]
		C_COLORS = REPLICATE(0,N_ELEMENTS(LEVELS))
		MIN_PTS=500
		ADD_COLORBAR=1
		SPECIAL_SCALE='HIGH'
		C_CHARSIZE = 1.5
		COLORBAR_TITLE='Cloud Probability (%)'


;	*** Alter prob to be percent
		STRUCT=READALL(FILE)
		OK=WHERE(STRUCT.(0).IMAGE NE MISSINGS(STRUCT.(0).IMAGE))
		STRUCT.(0).IMAGE[OK] = STRUCT.(0).IMAGE[OK]*100.
		SAVE,FILENAME='JUNK.SAVE',STRUCT,/COMPRESS
		USE_PROD='PERCENT'
		CON=STRUCT_SD_CONTOUR('JUNK.SAVE', LEVELS=levels,C_COLORS=c_colors,C_ANNOTATION=c_annotation, MED=med,MIN_PTS=MIN_PTS,$
															ADD_COLORBAR= ADD_COLORBAR,COLORBAR_TITLE=COLORBAR_TITLE, MIN_VALUE=min_value,MAX_VALUE=max_value,LINES=lines,$
															PNGFILE=PNGFILE,CONFILE=confile,DIR_OUT=dir_out,PAL=pal,MASK_IMAGE=MASK_IMAGE,MASK_COLOR=mask_color,NO_MASK=no_mask,$
															BACKGROUND=BACKGROUND, USE_PROD=USE_PROD,$
															LABEL=label, POS_LABEL=pos_label,SPECIAL_SCALE=SPECIAL_SCALE,C_CHARSIZE=C_CHARSIZE, _EXTRA=_extra)

		PAL_SW3,R,G,B
		R(1:250) = REVERSE(R(1:250))
		G(1:250) = REVERSE(G(1:250))
		B(1:250) = REVERSE(B(1:250))
		TVLCT,R,G,B

		COAST=READ_LANDMASK(MAP='NEC',/COAST)
		DILATED = DILATE( COAST, REPLICATE(1,4,4),1,1)
		OK = WHERE(DILATED EQ 1)
		CON[OK] = 254
		ok=WHERE(COAST EQ 1)
		CON[OK] = 251


;		===> CLEAN UP RIGHT AND LOWER EDGES OF SPURIOUS LINES
		NEW = MEDIAN_FILL(FLOAT(CON),BOX=[3,11],missing=0,MIN_FRACT= 0.1)
		COPY = CON
		COPY(1007:*,*) = 	NEW(1007:*,*)


		WRITE_PNG,PNG_FILE,COPY,R,G,B


	ENDIF
;	|||||||||||||||||||||||||||||||||||||||||


PRINT,'END OF MISC_MAIN.PRO'

END; #####################  End of Routine ################################
