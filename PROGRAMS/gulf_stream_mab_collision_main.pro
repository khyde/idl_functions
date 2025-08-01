; $ID:	GULF_STREAM_MAB_COLLISION_MAIN.PRO,	2020-07-29-14,	USER-KJWH	$


  PRO GULF_STREAM_MAB_COLLISION_MAIN
;+
; NAME:
;       GULF_STREAM_MAB_COLLISION_MAIN
;
; PURPOSE:
;       Main for GULF_STREAM_COLLISION MANUSCRIPT
; MODIFICATION HISTORY: Nov 8, 2001 Written by J.O'Reilly
;-

 ROUTINE_NAME='GULF_STREAM_COLLISION_MAIN'

	PS=1


  !P.MULTI=[0,1,2]
  !P.BACKGROUND = 255 & !P.COLOR=0
   PAL_36
   N_SUBAREAS = 10
   SWATH_KMS = 20.0





;	*********************************************************************
;	*** S W I T C H E S *************************************************
;	*********************************************************************

	DO_MAKE_BATHY_ZEBRA             = 0


	DO_PNG_SST_EC 									=0
	DO_CH_TRANSECT									=0
	DO_SST_CONTOUR_WITH_CH_TRANSECT =0
	DO_MAKE_LATLON_SUBAREA					=0
	DO_TS_SUBAREA_CH_TRANSECT				=0
	DO_TS_SUBAREA_CH_TRANSECT_PLOT	=0
	DO_REMAP_SST_NEC_2MAB_GS 				=0



	DO_DETERMINE_SHELF_BREAK				= 0
	DO_SHELF_BREAK			  					= 0

	DO_MAKE_PERPENDICULARS_SHELF_BREAK_2LAND 							  	=	0
	DO_SHELF_BREAK_LINE_INTERSECTS_CAPE_HATTERAS_GS_TRANSECT 	= 0


	DO_MAKE_BATHY_WATERFALL_PLOT     													= 0
	DO_MAKE_BATHY_WATERFALL_KMS_LABELS_PLOT       						= 0



	DO_TS_SUBAREA_SB_SWATH             = 0
	DO_MAKE_ANNOTATED_KM_SUBAREA_PNG   = 0

	DO_KM_SUBAREAS_SWATH      = 1

;	**************************************************
;	*** M A K E    P R O J E C T    F O L D E R S  ***
;	**************************************************
	FILE_PROJECT,DISK='D',PROJECT='GULF_STREAM_MAB_COLLISION',FOLDERS=['DATA','BROWSE','SAVE','PLOTS','TS_SUBAREAS','TS_SUBAREAS\SAVE']

	IF GET_COMPUTER() EQ 'LAPSANG' THEN DRIVE='D:\'
	IF GET_COMPUTER() EQ 'LOLIGO' THEN DRIVE='E:\'


; ****************************************************************
  IF DO_MAKE_BATHY_ZEBRA GE 1 THEN BEGIN
 ; ****************************************************************

  	AFILE = !DIR_SAVE+'PERPENDICULARS_SHELF_BREAK_2LAND.CSV'
	  FN=FILE_PARSE(AFILE)
		DB = READ_CSV(AFILE)
		MAP = 'MAB_GS'
		BATHY=READ_BATHY(MAP=MAP,NAME=NAME)
		IMAGE = STRUCT_SD_2IMAGE(READALL(NAME),/ADD_COLORBAR,PAL='PAL_ZEBRA_GREY',LAND_COLOR=254)
		PAL_ZEBRA_GREY,R,G,B,/FLIP
		MED = 3
		CON=STRUCT_SD_CONTOUR(NAME,LEVELS=200,C_colors=0, C_thick=1,C_ANNOTATION=1,MIN_VALUE=MIN_VALUE, MIN_PTS=150,$
	    										/LINES,	/ADD_LAND,/ADD_COAST,/ADD_LAKES,/ADD_COLORBAR,ADD_EXTRA=ADD_EXTRA,/CONFILE,MED=MED,C_CHARSIZE=0.75)

		ZWIN,IMAGE
		CALL_PROCEDURE,'MAP_'+MAP
		TV,IMAGE
		PLOT_CONTOURS,STRUCT=CON,COLOR=251
		IM=TVRD()
		ZWIN
		PNG_FILE = !DIR_PLOTS+'SRTM30-MAB_GS-BATHY-ZEBRA.PNG'
	  WRITE_PNG,PNG_FILE,IM,R,G,B

	ENDIF
; \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\


; ****************************************************************
  IF DO_PNG_SST_EC GE 1 THEN BEGIN
 ; ****************************************************************
  	LABEL='DO_PNG_SST_EC'
  	DIR_IN = DRIVE+'WORK\STATS\'
  	DIR_OUT = DRIVE+'WORK\STATS_BROWSE\'
		FILES = FILE_SEARCH(DIR_IN+'!MONTH*N4AT-EC-*SST*.SAVE')
		LIST, FILES
		STRUCT_SD_2PNG,FILES,/OVERWRITE,/ADD_COAST,/ADD_LAND,/ADD_COLORBAR,/ADDDATE,DIR_OUT=DIR_OUT

		SKIP_DO_PNG_SST_EC:
	ENDIF
;	|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||

; ****************************************************************
  IF DO_CH_TRANSECT GE 1 THEN BEGIN
; ****************************************************************
  	LABEL='DO_CH_TRANSECT'
		FILES = FILE_SEARCH(DRIVE+'WORK\STATS_BROWSE\!MONTH*N4AT-EC-*SST*.PNG')
		NAME = 'CH_GS_TRANSECT'
		LIST, FILES
		AFILE = FILES(2)
		MAP = 'EC'
		WIDTH = 5
		XY=MAPS_2LONLAT(MAP='EC')

		START_LON = XY.LON(280,505)
		START_LAT = XY.LAT(280,505)
		PRINT, START_LON, START_LAT
		END_LON  = XY.LON(365,405)
		END_LAT 	= XY.LAT(365,405)
	  PRINT, END_LON,END_LAT

		LONS = [START_LON,END_LON]
		LATS = [START_LAT,END_LAT]


		AZ=MAP_2POINTS(START_LON,START_LAT,END_LON,END_LAT,/RHUMB)
		PRINT,AZ

		M=MAP_2POINTS(START_LON,START_LAT,END_LON,END_LAT,/RHUMB,/METERS)
		PRINT,M

		stop
		TXT_FILE = !DIR_SAVE+NAME+'-AZIMUTH.TXT'
		txt = [NUM2STR(START_LON), NUM2STR(START_LAT),NUM2STR(M[1])]
		WRITE_TXT,TXT_FILE,txt
		STOP

	  IMAGE=READ_PNG(AFILE,R,G,B)
	  TVLCT,R,G,B
	  ZWIN, IMAGE
	  CALL_PROCEDURE,'MAP_'+MAP
 		TV,IMAGE
	  PLOTGRAT,1./6,PSYM=3
	  PLOTGRAT, 1, SYMSIZE=2,PSYM=1
	  PLOTS, LONS, LATS, COLOR=TC[0]
		IM=TVRD()
;	  S		=	MAP_TRACK_INTERPOLATE(LONS= LONS,LATS= LATS,MAP=MAP,NAME=NAME)
    S = MAP_TRACK_SWATH(LONS=LONS, LATS=LATS, MAP=MAP, WIDTH=WIDTH, NAME=name, WITHIN_MAP=WITHIN_MAP)

	  TV,IM
	  PLOTS,S.LON,S.LAT,COLOR=TC(250)
	  IM2=TVRD()
	  ZWIN
	  SLIDEW, IM, TITLE='IMAGE'
	  SLIDEW, IM2,TITLE='INTERPOLATED TRANSECT'
	  PRINT, MAX(S.KMS)


		CSV_FILE = !DIR_SAVE+NAME+'-TRACK_INTERPOLATE.CSV'
		STRUCT_2CSV,CSV_FILE,S
		STOP

		SKIP_DO_CH_TRANSECT:
	ENDIF
;	|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||


; ****************************************************************
  IF DO_SST_CONTOUR_WITH_CH_TRANSECT GE 1 THEN BEGIN
; ****************************************************************

		NAME = 'CH_GS_TRANSECT'
		CSV_FILE = !DIR_SAVE+NAME+'-TRACK_INTERPOLATE.CSV'
		S=READ_CSV(CSV_FILE)
		S=STRUCT_2NUM(S)

		FILES = FILE_SEARCH(DRIVE+'WORK\STATS\!MONTH*N4AT-EC-*SST*.SAVE')
		LEVELS = INTERVAL([20,30],0.5)
;		===> PLOT TRANSECT ATOP ALL 12 MONTHLY MEAN PNGS
		FOR NTH=0,N_ELEMENTS(FILES)-1 DO BEGIN
			AFILE=FILES[NTH]
			FN=FILE_PARSE(AFILE)
;			IMAGE=READ_PNG(AFILE,R,G,B)
			IMAGE=STRUCT_SD_CONTOUR(AFILE,PROD='SST',LEVELS=LEVELS,/ADD_LAND,DIR_OUT=!DIR_BROWSE,MED=9)
			ZWIN,IMAGE
			CALL_PROCEDURE,'MAP_'+MAP
			TV,IMAGE
		 	 PLOTS,S.LON,S.LAT,COLOR=TC[0]
		 	IMAGE=TVRD()
		 	ZWIN
		 	PNG_FILE = !DIR_BROWSE+FN.NAME+'-CONTOUR.PNG'
		 	WRITE_PNG,PNG_FILE,IMAGE,R,G,B

		ENDFOR

;		===> TAKE THE MARCH AND REMAP TO MAB_GS
		AFILE='D:\PROJECTS\GULF_STREAM_MAB_COLLISION\BROWSE\!MONTH_03-N4AT-EC-PXY_1024_1024-SST-MEAN-LEG-EDIT.PNG'
		IM=READ_PNG(AFILE,R,G,B)
		IM=MAP_REMAP(IM,MAP_IN='EC',MAP_OUT='MAB_GS')
		PNG_FILE=REPLACE(AFILE,'EC-PXY_1024_1024-', 'MAB_GS-PXY_1315_976-')
		WRITE_PNG, PNG_FILE,IM,R,G,B


		DO_SST_CONTOUR_WITH_CH_TRANSECT:
	ENDIF
;	|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||


; *******************************************************
; ******** M A K E   L A T L O N  S U B A R E A     *****
; *******************************************************
  IF DO_MAKE_LATLON_SUBAREA GE 1 THEN BEGIN
    PRINT, 'S T E P:    DO_MAKE_LATLON_SUBAREA'
    OVERWRITE = DO_MAKE_LATLON_SUBAREA GE 2
    MAP='EC'
    NAME = 'CH_GS_TRANSECT'

		FILE = !DIR_SAVE+NAME+'-TRACK_INTERPOLATE.CSV'

		S=MAPS_SIZE(MAP)
		PREFACE = 'LATLON_SUBAREA-'+MAP+'-'+ STRTRIM(S.PX,2)+'-'+STRTRIM(S.PY,2)+'-'

		EXIST=FILE_TEST(FILE )
		IF EXIST EQ 0 THEN GOTO,DONE_DO_MAKE_LATLON_SUBAREA ; >>>>>>>
		FN=FILE_PARSE(FILE)

		CON = READ_CSV(FILE)
    W=WORDS(FN.NAME)
    NAME=W[0]

		SAVE_FILE		= !DIR_SAVE  + 'LATLON_SUBAREA-'+MAP+'-PXY_'+STRTRIM(S.PX,2)+'_'+STRTRIM(S.PY,2)+'_'+NAME+'.SAVE'
		CSV_FILE   	= !DIR_SAVE  + 'LATLON_SUBAREA-'+MAP+'-PXY_'+STRTRIM(S.PX,2)+'_'+STRTRIM(S.PY,2)+'_'+NAME+'.CSV'
		PNG_FILE		= !DIR_SAVE  + 'LATLON_SUBAREA-'+MAP+'-PXY_'+STRTRIM(S.PX,2)+'_'+STRTRIM(S.PY,2)+'_'+NAME+'.PNG'

		IF FILE_TEST(SAVE_FILE) AND OVERWRITE EQ 0 THEN GOTO, DONE_DO_MAKE_LATLON_SUBAREA
;		===> Make the csv from scratch
;		SUBAREA_CODE	SUBAREA_NAME	NICKNAME
 		STRUCT= REPLICATE(CREATE_STRUCT('LON','','LAT','','AROUND','0','SUBAREA_CODE','','SUBAREA_NAME','','NICKNAME',''),N_ELEMENTS(CON))


;		===> TRACK
;		LLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLL
 		STRUCT.LAT=CON.LAT_SWATH
 		STRUCT.LON=CON.LON_SWATH
 		STRUCT.SUBAREA_CODE=STRTRIM(CON.POINT,2)
 		STRUCT.SUBAREA_NAME= NAME +'-'+STRTRIM(CON.POINT,2)
		OK=WHERE(STRUCT.LAT NE MISSINGS(STRUCT.LAT),COUNT)
		STRUCT=STRUCT[OK]

;		===> Write the savefile
		SAVE,FILENAME=SAVE_FILE,STRUCT,/COMPRESS

;		***> WRITE THE SAVEFILE TO D:\IDL\IMAGES
		FILE_COPY,SAVE_FILE,!S.IMAGES,/OVERWRITE

;		===> Write the Struct to a csv
		STRUCT_2CSV,CSV_FILE,STRUCT

;		===> Make a png showing the subareas
		land=READ_LANDMASK(MAP='EC')
		PAL_36

		ZWIN,LAND
		CALL_PROCEDURE,'MAP_'+MAP
		TV,LAND
		FOR NTH=0,N_ELEMENTS(STRUCT)-1 DO BEGIN
			LONS = STRSPLIT(STRUCT[NTH].LON,';',/EXTRACT)
			LATS = STRSPLIT(STRUCT[NTH].LAT,';',/EXTRACT)
			PLOTS,LONS,LATS,COLOR = STRUCT[NTH].SUBAREA_CODE*2
		ENDFOR
		IM=TVRD()
		ZWIN
		PAL_SW3,R,G,B
		WRITE_PNG,PNG_FILE,IM,R,G,B

 		DONE_DO_MAKE_LATLON_SUBAREA:
	ENDIF  ; DO_MAKE_LATLON_SUBAREA
; |||||||||||||||||||||||||||||||||||||||||||||||||



; ************************************************
; ********        TS  S U B A R E A S        *****
; ************************************************
  IF DO_TS_SUBAREA_CH_TRANSECT GE 1 THEN BEGIN
    PRINT, 'S T E P:    DO_TS_SUBAREA_CH_TRANSECT'
    OVERWRITE = DO_TS_SUBAREA_CH_TRANSECT GE 2
    SUBAREA_FILE		=  'LATLON_SUBAREA-EC-PXY_1024_1024_CH_GS_TRANSECT.SAVE'
    SUBAREA_CODES = INDGEN(100)+1

	  DIR_IN = 'E:\WORK\STATS\' ;!DIR_SAVE
	  FILE_TARGET = '!MONTH*N4ATG*SST*MEAN*.SAVE'
	  APROD = 'SST'
	  APERIOD = '!MONTH'
	  AMETHOD = 'N4AT'
	  DIR_OUT = !DIR_TS_SUBAREAS_SAVE
	  PERIOD_OUT = '!MONTH'
	  CSV = 1

	 	TS_SUBAREAS, DIR_IN=DIR_IN,FILE_TARGET=ATARGET,PROD=APROD,SUBAREA_PERIOD=APERIOD,$
                   SUBAREA_FILE=SUBAREA_FILE, SUBAREA_CODES=subarea_codes,METHOD=AMETHOD,$
                   DIR_OUT=DIR_OUT,OVERWRITE=overwrite,CSV=CSV,PERIOD_OUT=PERIOD_OUT



	ENDIF
;	\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\



; *****************************************************
; ********  TS  S U B A R E A S    P L O T        *****
; *****************************************************
  IF DO_TS_SUBAREA_CH_TRANSECT_PLOT GE 1 THEN BEGIN
    PRINT, 'S T E P:    DO_TS_SUBAREA_CH_TRANSECT_PLOT'
    OVERWRITE = DO_TS_SUBAREA_CH_TRANSECT_PLOT GE 2

    DB = READ_CSV(!DIR_TS_SUBAREAS_SAVE+ '!MONTH-LATLON_SUBAREA-EC-PXY_1024_1024_CH_GS_TRANSECT-N4AT-SST.CSV')
    DB = STRUCT_2NUM(DB)

		TRANSECT_FILE = !DIR_SAVE+ 'CH_GS_TRANSECT-TRACK_INTERPOLATE.CSV'
		T=READ_CSV(TRANSECT_FILE)
		T = STRUCT_2NUM(T)
		T=STRUCT_RENAME(T,'POINT','SUBAREA_CODE')
		DB = STRUCT_JOIN(T,DB, TAGNAMES=['SUBAREA_CODE'])

		OK=WHERE(DB.FIRST_NAME NE MISSINGS(DB.FIRST_NAME))
		DB=DB[OK]
		CSV_FILE = !DIR_SAVE+'CH_GS_TRANSECT-EC-N4AT-SST-KMS.CSV'
		STRUCT_2CSV,CSV_FILE,DB
    P = PERIOD_2STRUCT(DB.FIRST_NAME)


		PS_FILE = !DIR_PLOTS+'CH_GS_TRANSECT-EC-N4AT-SST-KMS.PS'
 		PSPRINT,FILENAME=PS_FILE,/COLOR,/FULL
		FONT_TIMES
		PAL_36
		; MONTH     1  2  3  4   5    6   7    8   9   10  11  12
		COLORS = [  8, 3, 7, 9, 13, 	18, 23, 26, 20, 19, 17, 10]

		TITLE = 'Cape Hatteras-Gulf Stream Transect'
    PLOT, [0,300],[12,30],/NODATA, XTITLE='KM', YTITLE=UNITS('SST',/NAME,/UNIT),/YSTYLE,TITLE=TITLE
    GRIDS,COLOR=34,THICK=3

		STRUCT = REPLICATE(CREATE_STRUCT('MONTH','','KM','','SST',''),12)

	  FOR MONTH = 0,11 DO BEGIN
	  	AMONTH = MONTH + 1
	  	OK=WHERE(P.MONTH_START EQ AMONTH,COUNT)
	  	IF COUNT EQ 0 THEN CONTINUE ; >>>>>>>>>>>>>>>>>
	  	D=DB[OK]
	  	MAX_SST = MAX(D.MEAN,SUB)
	  	STRUCT(MONTH).KM =  NUM2STR(D(SUB).KMS,FORMAT='(F10.0)')
	  	STRUCT(MONTH).SST = NUM2STR(MAX_SST,FORMAT='(F10.1)')
	  	STRUCT(MONTH).MONTH = STRTRIM(AMONTH,2)
	    PLOTS, D.KMS,D.MED,COLOR= COLORS(MONTH), THICK = 9
	    PLOTS, D.KMS,D.MED,COLOR= 0, THICK = 1,LINESTYLE= MONTH MOD 3


	  ENDFOR

; 	  XYOUTS2, XPOS,YPOS,TXT,ALIGN=[0.5,0.5],BACKGROUND=255
		FOR NTH = 0,N_ELEMENTS(STRUCT)-1 DO BEGIN
 			XYOUTS2, STRUCT[NTH].KM,STRUCT[NTH].SST,STRUCT[NTH].MONTH,ALIGN=[0.5,0.5] ,BACKGROUND=255
;			XYOUTS, XPOS[NTH],YPOS[NTH],TXT[NTH],ALIGN=[0.5]
		ENDFOR




		POSITION = [0.360,0.563,0.505,0.74]
		STRUCT_SPREAD ,STRUCT, POSITION=POSITION, $
 										CHARSIZE_TAGS=0.9, COLOR_TAGS=COLOR_TAGS,$
 										CHARSIZE_DATA=0.9, COLOR_DATA=COLOR_DATA,$
 										COLOR_LINES = COLOR_LINES,$
 										FORMAT=format,$
 										ORIENTATION = ORIENTATION,$
 										NO_TAGS=no_tags,$
 										NO_LINES = 1,$
 										BACKGROUND=255,$
 										_EXTRA=_extra



	  FRAME,/PLOT,THICK=3,COLOR=0

 	  PSPRINT



; 	  IMAGE_TRIM,PS_FILE



		PS_FILE = !DIR_PLOTS+'CH_GS_TRANSECT-EC-N4AT-SST-KMS-CV.PS'
 		PSPRINT,FILENAME=PS_FILE,/COLOR,/FULL
		FONT_TIMES
		PAL_36
		; MONTH     1  2  3  4   5    6   7    8   9   10  11  12
		COLORS = [  8, 3, 7, 9, 13, 	18, 23, 26, 20, 19, 17, 10]

		TITLE = 'Cape Hatteras-Gulf Stream Transect'
    PLOT, [0,300],[0.01,30],/NODATA, XTITLE='KM', YTITLE=UNITS('SST',/NAME,/UNIT),/YSTYLE,TITLE=TITLE,/YLOG
    GRIDS,COLOR=34,THICK=3

		STRUCT = REPLICATE(CREATE_STRUCT('MONTH','','KM','','SST',''),12)

	  FOR MONTH = 0,11 DO BEGIN
	  	AMONTH = MONTH + 1
	  	OK=WHERE(P.MONTH_START EQ AMONTH,COUNT)
	  	IF COUNT EQ 0 THEN CONTINUE ; >>>>>>>>>>>>>>>>>
	  	D=DB[OK]
	  	MAX_SST = MAX(D.MEAN,SUB)
	  	STRUCT(MONTH).KM =  NUM2STR(D(SUB).KMS,FORMAT='(F10.0)')
	  	STRUCT(MONTH).SST = NUM2STR(MAX_SST,FORMAT='(F10.1)')
	  	STRUCT(MONTH).MONTH = STRTRIM(AMONTH,2)
	    PLOTS, D.KMS,D.CV,COLOR= COLORS(MONTH), THICK = 9
	    PLOTS, D.KMS,D.CV,COLOR= 0, THICK = 1,LINESTYLE= MONTH MOD 3


	  ENDFOR

; 	  XYOUTS2, XPOS,YPOS,TXT,ALIGN=[0.5,0.5],BACKGROUND=255
		FOR NTH = 0,N_ELEMENTS(STRUCT)-1 DO BEGIN
 			XYOUTS2, STRUCT[NTH].KM,STRUCT[NTH].SST,STRUCT[NTH].MONTH,ALIGN=[0.5,0.5] ,BACKGROUND=255
;			XYOUTS, XPOS[NTH],YPOS[NTH],TXT[NTH],ALIGN=[0.5]
		ENDFOR




		POSITION = [0.360,0.563,0.505,0.74]
		STRUCT_SPREAD ,STRUCT, POSITION=POSITION, $
 										CHARSIZE_TAGS=0.9, COLOR_TAGS=COLOR_TAGS,$
 										CHARSIZE_DATA=0.9, COLOR_DATA=COLOR_DATA,$
 										COLOR_LINES = COLOR_LINES,$
 										FORMAT=format,$
 										ORIENTATION = ORIENTATION,$
 										NO_TAGS=no_tags,$
 										NO_LINES = 1,$
 										BACKGROUND=255,$
 										_EXTRA=_extra



	  FRAME,/PLOT,THICK=3,COLOR=0

 	  PSPRINT

	PRINT,'DO SST CHL PLOT TO IDENTIFY CENTER OF GS'



	ENDIF
;\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\



; ****************************************************************
  IF DO_REMAP_SST_NEC_2MAB_GS GE 1 THEN BEGIN
 ; ****************************************************************
  	LABEL='DO_REMAP_SST_NEC_2MAB_GS'
		FILES = FILE_SEARCH('E:\WORK\STATS\!MONTH*N4AT-*SST*.SAVE')
		LIST, FILES
		MAP_OUT = 'MAB_GS'
		OUTFILES = REPLACE(FILES,'NEC',MAP_OUT)
		LIST, OUTFILES
		STOP

	  IF DO_REMAP_SST_NEC_2MAB_GS LT 2 AND MIN(FILE_TEST(OUTFILES)) EQ 1 THEN GOTO, SKIP_DO_REMAP_SST_NEC_2MAB_GS

;		A=STRUCT_SD_REMAP(FILES=FILES,MAP_OUT=MAP_OUT)
		STRUCT_SD_2PNG,OUTFILES,/ADD_COAST,/ADD_LAND,/OVERWRITE

		SKIP_DO_REMAP_SST_NEC_2MAB_GS:
	ENDIF
;	|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||



; ****************************************************************
  IF DO_DETERMINE_SHELF_BREAK GE 1 THEN BEGIN
 ; ****************************************************************
  	LABEL='DO_DETERMINE_SHELF_BREAK'
		FILES = FILE_SEARCH('D:\PROJECTS\SRTM30\SAVE\*MAB_GS*BATHY.SAVE')
		LIST, FILES
	  AFILE=FILES[0]
	  FN=FILE_PARSE(AFILE)

		DATA = STRUCT_SD_READ(AFILE)
		OK = WHERE(DATA GE 50 AND DATA LE 3000, COMPLEMENT=COMPLEMENT)
		BD = DATA
		BD(COMPLEMENT) = MISSINGS(BD)
		MED_BD = MEDIAN(BD,3)						& B_MED_BD= BYTSCL(MED_BD,MAX=3000, TOP=250)
		_SOBEL=SOBEL(MED_BD)   					& B_SOBEL=BYTSCL(_SOBEL,MAX=3000, TOP=250)
		MED_SOBEL = MEDIAN(_SOBEL,3) 		& B_MED_SOBEL=BYTSCL(MED_SOBEL,MAX=3000, TOP=250)

		SOBEL_MED_SOBEL = SOBEL(MED_SOBEL) 	& B_SOBEL_MED_SOBEL=BYTSCL(SOBEL_MED_SOBEL,MAX=3000, TOP=250)

	 																			 B_SOBEL_MED_SOBEL_SHELF=BYTSCL(SOBEL_MED_SOBEL,MAX=500, TOP=250)

		LEVELS = [150,160,170,180,200]
		LEVELS = 200


		C_COLORS = REPLICATE(255,N_ELEMENTS(LEVELS))
		C_THICK= REPLICATE(1,N_ELEMENTS(LEVELS))
		C_ANNOTATION=REPLICATE(1,N_ELEMENTS(LEVELS))
		MIN_PTS = REPLICATE(500,N_ELEMENTS(LEVELS))

		TXT = ARR_2STR(LEVELS,DELIM='_',/PLAIN)
		OUTFILE = !DIR_PLOTS+FN.FIRST_NAME+'-CONTOUR_'+TXT+'.PNG'

		CON=STRUCT_SD_CONTOUR(AFILE,LEVELS=levels,C_colors=C_colors, C_thick=C_thick,C_ANNOTATION=c_annotation,MIN_VALUE=MIN_VALUE, MIN_PTS=MIN_PTS,$
	    											/ADD_LAND,/ADD_COAST,/ADD_LAKES,/ADD_COLORBAR,ADD_EXTRA=ADD_EXTRA,/CONFILE,MED=MED,C_CHARSIZE=0.75)

		PAL_SW3,R,G,B
		WRITE_PNG,OUTFILE,CON,R,G,B

		CON=STRUCT_SD_CONTOUR(AFILE,LEVELS=levels,C_colors=C_colors, C_thick=C_thick,C_ANNOTATION=c_annotation,MIN_VALUE=MIN_VALUE, MIN_PTS=MIN_PTS,$
	    										/LINES,	/ADD_LAND,/ADD_COAST,/ADD_LAKES,/ADD_COLORBAR,ADD_EXTRA=ADD_EXTRA,/CONFILE,MED=MED,C_CHARSIZE=0.75)


		FOR NTH=0,N_ELEMENTS(LEVELS) -1 DO BEGIN
			ZWIN,B_SOBEL
			MAP_MAB_GS

			TV,B_MED_BD
	    PLOT_CONTOURS,'D:\PROJECTS\SRTM30\SAVE\SRTM30-MAB_GS-PXY_1315_976-BATHY-CON.CSV',COLOR= 255,VALUES=LEVELS[NTH],LINESTYLE=1
	    B_MED_BD_CON = TVRD()
	    B_MED_BD_CON=MAP_ADD_TXT(B_MED_BD_CON,0.2,0.8, STRTRIM(LEVELS[NTH],2)+' M',COLOR=255)
	    PNG_FILE = !DIR_PLOTS+FN.FIRST_NAME+'-'+STRTRIM(LEVELS[NTH],2)+'-SOBEL.PNG'
			PAL_SW3
			WRITE_PNG,PNG_FILE,B_MED_BD_CON,R,G,B

			TV,B_SOBEL
	    PLOT_CONTOURS,'D:\PROJECTS\SRTM30\SAVE\SRTM30-MAB_GS-PXY_1315_976-BATHY-CON.CSV',COLOR= 255,VALUES=LEVELS[NTH],LINESTYLE=1
	    B_SOBEL_CON = TVRD()
	    B_SOBEL_CON=MAP_ADD_TXT(B_SOBEL_CON,0.2,0.8, STRTRIM(LEVELS[NTH],2)+' M',COLOR=255)
	    PNG_FILE = !DIR_PLOTS+FN.FIRST_NAME+'-'+STRTRIM(LEVELS[NTH],2)+'-SOBEL.PNG'
			PAL_SW3
			WRITE_PNG,PNG_FILE,B_SOBEL_CON,R,G,B

			TV,B_SOBEL
	    PLOT_CONTOURS,'D:\PROJECTS\SRTM30\SAVE\SRTM30-MAB_GS-PXY_1315_976-BATHY-CON.CSV',COLOR= 255,VALUES=LEVELS[NTH],LINESTYLE=1
	    B_SOBEL_CON = TVRD()
	    B_SOBEL_CON=MAP_ADD_TXT(B_SOBEL_CON,0.2,0.8, STRTRIM(LEVELS[NTH],2)+' M',COLOR=255)
	    PNG_FILE = !DIR_PLOTS+FN.FIRST_NAME+'-'+STRTRIM(LEVELS[NTH],2)+'-SOBEL.PNG'
			PAL_SW3
			WRITE_PNG,PNG_FILE,B_SOBEL_CON,R,G,B

			TV,B_MED_SOBEL
	    PLOT_CONTOURS,'D:\PROJECTS\SRTM30\SAVE\SRTM30-MAB_GS-PXY_1315_976-BATHY-CON.CSV',COLOR= 255,VALUES=LEVELS[NTH],LINESTYLE=1
	    B_MED_SOBEL_CON = TVRD()
	    B_MED_SOBEL_CON=MAP_ADD_TXT(B_MED_SOBEL_CON,0.2,0.8, STRTRIM(LEVELS[NTH],2)+' M',COLOR=255)
	    PNG_FILE = !DIR_PLOTS+FN.FIRST_NAME+'-'+STRTRIM(LEVELS[NTH],2)+'-SOBEL-MED.PNG'
			PAL_SW3
			WRITE_PNG,PNG_FILE,B_MED_SOBEL_CON,R,G,B


			TV,B_SOBEL_MED_SOBEL
;	     NO 200 ISOBATH
	    B_SOBEL_MED_SOBEL_CON = TVRD()
	    B_SOBEL_MED_SOBEL_CON=MAP_ADD_TXT(B_SOBEL_MED_SOBEL_CON,0.2,0.8, STRTRIM(LEVELS[NTH],2)+' M',COLOR=255)
	    PNG_FILE = !DIR_PLOTS+FN.FIRST_NAME+'-SOBEL_MED_SOBEL.PNG'
			PAL_SW3
			WRITE_PNG,PNG_FILE,B_SOBEL_MED_SOBEL_CON,R,G,B

			TV,B_SOBEL_MED_SOBEL_SHELF
	    PLOT_CONTOURS,'D:\PROJECTS\SRTM30\SAVE\SRTM30-MAB_GS-PXY_1315_976-BATHY-CON.CSV',COLOR= 0,VALUES=LEVELS[NTH],LINESTYLE=1
	    B_SOBEL_MED_SOBEL_SHELF_CON = TVRD()
	    B_SOBEL_MED_SOBEL_SHELF_CON=MAP_ADD_TXT(B_SOBEL_MED_SOBEL_SHELF_CON,0.2,0.8, STRTRIM(LEVELS[NTH],2)+' M',COLOR=255)
	    PNG_FILE = !DIR_PLOTS+FN.FIRST_NAME+'-'+STRTRIM(LEVELS[NTH],2)+'-SOBEL_MED_SOBEL_SHELF.PNG'
			PAL_SW3
			WRITE_PNG,PNG_FILE,B_SOBEL_MED_SOBEL_SHELF_CON,R,G,B






	    ZWIN


	  STOP
		ENDFOR


		SKIP_DO_DETERMINE_SHELF_BREAK:
	ENDIF
;	|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||

;D:\PROJECTS\GULF_STREAM_MAB_COLLISION\PLOTS\MAB_GS-PXY_5479_4067-BASEMAP_SOBEL_SOBEL_LINE.png

; ****************************************************************
  IF DO_SHELF_BREAK GE 1 THEN BEGIN
 ; ****************************************************************
  	LABEL='DO_DETERMINE_SHELF_BREAK'
		FILES = FILE_SEARCH('D:\PROJECTS\SRTM30\SAVE\*MAB_GS*BATHY.SAVE')
		LIST, FILES
	  AFILE=FILES[0]
	  FN=FILE_PARSE(AFILE)


		LEVELS = [200]
		C_COLORS = REPLICATE(0,N_ELEMENTS(LEVELS))
		C_THICK= REPLICATE(1,N_ELEMENTS(LEVELS))
		C_ANNOTATION=REPLICATE(LEVELS[0],N_ELEMENTS(LEVELS))
		MIN_PTS = REPLICATE(500,N_ELEMENTS(LEVELS))


;		===> DO THE CONTOUR TO GET THE 150M ISOBATH
		CON=STRUCT_SD_CONTOUR(AFILE,LEVELS=LEVELS,C_colors=C_colors, C_thick=C_thick,C_ANNOTATION=c_annotation,MIN_VALUE=MIN_VALUE, MIN_PTS=MIN_PTS,$
	    										/LINES,	/ADD_LAND,/ADD_COAST,/ADD_LAKES,/ADD_COLORBAR,ADD_EXTRA=ADD_EXTRA,/CONFILE,MED=MED,C_CHARSIZE=0.75)


;		===> LOOP ON MEDIAN, smoothing the bathymetry, contouring the smooth data and drawing the exact contour atop the smooth contour.
		MEDS = [5,9,13,21,31,51,71]

		meds = 5

		FOR NTH=0,N_ELEMENTS(MEDS) -1 DO BEGIN
			MED=MEDS[NTH]

			TXT = ARR_2STR(LEVELS,DELIM='_')+'m'+' Median_'+STRTRIM(MED,2)


			IMAGE=STRUCT_SD_CONTOUR(AFILE,LEVELS=LEVELS,C_colors=C_colors, C_thick=C_thick,C_ANNOTATION=c_annotation,MIN_VALUE=MIN_VALUE, MIN_PTS=MIN_PTS,$
	    											/ADD_LAND,/ADD_COAST,/ADD_LAKES,/ADD_COLORBAR,ADD_EXTRA=ADD_EXTRA,/CONFILE,MED=MED,C_CHARSIZE=0.75,$
	    											LABEL=TXT,CHARSIZE_LABEL=5)


;			===> Add the exact contour
			ZWIN,IMAGE
			MAP_MAB_GS
			TV,IMAGE
	    PLOT_CONTOURS,STRUCT=CON,COLOR=255,LEVELS=LEVELS
	    NEW=TVRD()
	    ZWIN
	    PAL_SW3,R,G,B
	    PNG_FILE = !DIR_PLOTS+FN.FIRST_NAME+'-'+STRTRIM(LEVELS,2)+'-Median_'+STRTRIM(MED,2)+'.PNG'
			WRITE_PNG,PNG_FILE,NEW,R,G,B
		ENDFOR


		SKIP_DO_SHLF_BREAK:
	ENDIF
;	|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||



; ****************************************************************
  IF DO_MAKE_PERPENDICULARS_SHELF_BREAK_2LAND GE 1 THEN BEGIN
 ; ****************************************************************
  	LABEL='DO_DETERMINE_SHELF_BREAK'
		AFILE = !DIR_PLOTS+'MAB_GS-PXY_5479_4067-BASEMAP_SOBEL_SOBEL_LINE.png'

	  FN=FILE_PARSE(AFILE)
		IMAGE = READ_PNG(AFILE,R,G,B)
		OK=WHERE(IMAGE EQ 0)
		IMAGE(WHERE(IMAGE EQ 1)) = 0
		IMAGE[OK] = 1
		MAP='MAB_GS'

;		===> Trace the Image to generate a vector of x,y
		XY = IMAGE_TRACE(IMAGE, 1,MASK=MASK, ERROR=ERROR)
		COPY=IMAGE & COPY(*) = 0 & COPY(XY.X,XY.Y)=1
		OK=WHERE(IMAGE NE COPY,COUNT)
		IF COUNT GE 1 THEN STOP

;		===> Convert x,y to lon,lat
		LL=MAPS_2LONLAT(MAP,/LOWER_LEFT) ; LOWER_LEFT TO EXACTLY FOLLOW THE TRACED LINE WHEN WE INTERPOLATE
		LONS = LL.LON(XY.X,XY.Y)
		LATS = LL.LAT(XY.X,XY.Y)

;		===> Interpolate lon,lat for this map
		I_LINE = MAP_TRACK_INTERPOLATE(LONS=LONS, LATS=LATS, MAP=MAP, NAME='SHELF_BREAK_SOBEL')

;		===> Make a csv and png of the Interpolated Line
		STRUCT_2CSV,!DIR_SAVE+'SHELF_BREAK_SOBEL.CSV',I_LINE
		PNG_FILE = !DIR_PLOTS+'SHELF_BREAK_SOBEL-INTERPOLATED.PNG
		ZWIN,IMAGE
		CALL_PROCEDURE,'MAP_'+MAP
		OK=WHERE(IMAGE EQ 1)
		COPY=IMAGE
		COPY[OK] = 26
		TV,COPY

		PLOTS,I_LINE.LON,I_LINE.LAT, COLOR=21,THICK=1
		IM=TVRD()
		PAL_36,R,G,B
		WRITE_PNG,PNG_FILE,IM,R,G,B


;		===> Generate a Swath along the interpolated line
		WIDTH_SWATH = 400
		WIDTH_SMOOTH = 51
		NAME = 'SHELF_BREAK_SOBEL'
		PRINT,'ITERATE THE SMOOTHING 3 THEN 7 THEN 11 TO MAKE THE ENDS OK

;		*** SMOOTH TO GENERATE THE PERPENDICULARS BUT OFFSET THEM BACK TO THE ACTUAL TRACK LINE
	 	TRACK	=	MAP_TRACK_SWATH(LONS=I_LINE.LON,LATS=I_LINE.LAT,MAP=MAP,NAME=NAME,WIDTH=WIDTH_SWATH,SMO=WIDTH_SMOOTH)

		PNG_FILE = !DIR_PLOTS+'SHELF_BREAK_SOBEL-INTERPOLATED-SMOOTH_'+STRTRIM(WIDTH_SMOOTH,2)+'.PNG
		ZWIN,IMAGE
		CALL_PROCEDURE,'MAP_'+MAP
		OK=WHERE(IMAGE EQ 1)
		COPY=IMAGE
		COPY[OK] = 26
		TV,COPY
		PLOTS,TRACK.LON,TRACK.LAT, COLOR=21,THICK=1
		IM=TVRD()
		PAL_36,R,G,B
		WRITE_PNG,PNG_FILE,IM,R,G,B

		STRUCT_2CSV,!DIR_SAVE+'PERPENDICULARS_SHELF_BREAK_2LAND.CSV',TRACK

		XP = STR_BREAK(TRACK.PX_SWATH,';')
		YP = STR_BREAK(TRACK.PY_SWATH,';')

		MAB_GS= MAP_REMAP(READ_LANDMASK(MAP='NEC'),MAP_IN='NEC',MAP_OUT=MAP)
		OK_LAND = WHERE(MAB_GS GE 1 AND MAB_GS LE 2)
		OK_WATER = WHERE(MAB_GS EQ 0)
		OK_I_LINE=WHERE(IMAGE EQ 1)

		MAB_GS(OK_WATER) = 255
		MAB_GS(XP,YP)=32
		MAB_GS(OK_I_LINE) = 0
		MAB_GS(OK_LAND) = 34

;		Check mid value is on the line
 		MAB_GS(ROUND(FLOAT(XP(*,200))),ROUND(FLOAT(YP(*,200)))) = 18

		ZWIN,MAB_GS
		CALL_PROCEDURE,'MAP_'+MAP
		TV,MAB_GS
		PLOTS, TRACK.LON,TRACK.LAT,COLOR=21,THICK=1
		IM=TVRD()
		ZWIN
		PAL_36,R,G,B &WRITE_PNG,!DIR_PLOTS+'PERPENDICULARS_SHELF_BREAK_2LAND.PNG',IM,R,G,B


		SKIP_DO_MAKE_PERPENDICULARS_SHELF_BREAK_2LAND:
	ENDIF
;	|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||





; ****************************************************************
  IF DO_SHELF_BREAK_LINE_INTERSECTS_CAPE_HATTERAS_GS_TRANSECT GE 1 THEN BEGIN
 ; ****************************************************************
  	LABEL='DO_SHELF_BREAK_LINE_INTERSECTS_CAPE_HATTERAS_GS_TRANSECT'
  	AFILE = !DIR_SAVE+'PERPENDICULARS_SHELF_BREAK_2LAND.CSV'
	  FN=FILE_PARSE(AFILE)
		DB = READ_CSV(AFILE)

		MAP = 'MAB_GS'
		M = MAPS_SIZE(MAP)
		PAL = 'PAL_36'
		LAND=READ_LANDMASK(MAP=MAP,/STRUCT)
;		IMAGE = STRUCT_SD_2IMAGE(READALL(NAME),/ADD_COLORBAR,PAL=PAL,LAND_COLOR=254)

;		===> CHECK THAT THE FIRST DB PERPENDICULAR (WHICH STARTS AT 0 KM BY DEFINITION) CROSSES OUR CH SST TRANSECT
	  CH  = READ_CSV(!DIR_SAVE+'CH_GS_TRANSECT-TRACK_INTERPOLATE.CSV')
		DIST   = REPLICATE(0.0,51)
;		LLLLLLLLLLLLLLLLLLLLLLL
		FOR NTH = 0,50 DO BEGIN
			D=DB[NTH]
		 	XP = ROUND(FLOAT(STR_BREAK(D.PX_SWATH,';')))
		 	YP = ROUND(FLOAT(STR_BREAK(D.PY_SWATH,';')))
			NEAR = 5000.0
			OK=WHERE_NEAREST_LONLAT( FLOAT(CH.LON),FLOAT(CH.LAT),D.LON,D.LAT,Count, NEAR=NEAR, VALID=valid,$
													 NCOMPLEMENT=ncomplement,COMPLEMENT=complement,NINVALID=ninvalid,INVALID=invalid, CLOSEST=CLOSEST,$
													 DOUBLE=DOUBLE, ERROR=error,ERR_MSG=err_msg)
			DIST[NTH] = MIN(CLOSEST)
		ENDFOR
		MIN_DIST = MIN(DIST,SUB)
		D = DB(SUB)

;		===> KM OFFSET INTERSECTION WITH CH TRANSECT
		KM_OFFSET = D.KMS
		PRINT, SUB
		PRINT,KM_OFFSET

		XP = ROUND(FLOAT(STR_BREAK(D.PX_SWATH,';')))
	 	YP = ROUND(FLOAT(STR_BREAK(D.PY_SWATH,';')))
	 	LON = REFORM(FLOAT(STR_BREAK(D.LON_SWATH,';')))
	 	LAT = REFORM(FLOAT(STR_BREAK(D.LAT_SWATH,';')))


;		===> Display the Closest perpendicular to the CH transect
		ZWIN,[M.PX,M.PY]
		CALL_PROCEDURE,'MAP_'+MAP
		ERASE,255
		PLOTS,CH.LON, CH.LAT, COLOR= 21
		OPLOT, LON,LAT, COLOR= 8
		IM=TVRD()
		ZWIN
		IM(LAND.LAND) = 34
		IM(LAND.COAST) = 0
		CALL_PROCEDURE,PAL,R,G,B
		PNG_FILE = !DIR_PLOTS+'CH_TRANSECT_ZERO_KM_ALONG_SHELF_BREAK.PNG'
		WRITE_PNG,PNG_FILE,IM,R,G,B

	ENDIF;  IF DO_SHELF_BREAK_LINE_INTERSECTS_CAPE_HATTERAS_GS_TRANSECT GE 1 THEN BEGIN
;	\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\


; ****************************************************************
  IF DO_MAKE_BATHY_WATERFALL_PLOT GE 1 THEN BEGIN
; ****************************************************************
  	LABEL='DO_DETERMINE_SHELF_BREAK'
  	AFILE = !DIR_SAVE+'PERPENDICULARS_SHELF_BREAK_2LAND.CSV'
	  FN=FILE_PARSE(AFILE)
		DB = READ_CSV(AFILE)



;		===> Calculate center of swath
		SWATH_CENTER = DB[0].NPTS/2		; = 200 with 401 pts

		MAP = 'MAB_GS'
		BATHY=READ_BATHY(MAP=MAP)

		PS_FILE = !DIR_PLOTS+'BATHY_WATERFALL-'+MAP+'.PS'
 	 	PSPRINT,/COLOR,/FULL,FILENAME=PS_FILE
 	 	!P.MULTI=0
 	 	PAL_36
 	 	CIRCLE,2,fill=0 ,/ROTATE,THICK=1

		SZ=SIZE(BATHY,/STRUCT)
		PX = SZ.DIMENSIONS[0]
		PY = SZ.DIMENSIONS[1]

;		===> LIGHT SMOOTHING
		BATHY = MEDIAN(BATHY,5)

;		===> MAX KMS
		MAX_KMS = MAX(FLOAT(DB.KMS))

;		===> TAKE 1400KM AND DIVIDE INTO 0-1 NORMAL
		F_NUM = FLOAT(N_ELEMENTS(DB))
		Y_FRACTION = 0.25
		increment = (1-Y_FRACTION)/ (F_NUM)
		XPOS = [0.01,0.95]


		SAMPLE = 5
		YTICKV = FIX(INTERVAL([0,1300.],50))
		KM_FROM_CH = ROUND(FLOAT(DB.KMS))

		TEMP = CREATE_STRUCT('SUB',-1L, 'KMS','')

		LEGEND, ['Shelf Break (Sobel Bottom Grid)','200m','Max 2nd Derivative Bottom Cross Shelf Transect'], psym=[88,1,1],color=[0,8,21],POS=[0.05,0.15 ],charsize=0.75,/norm


;		LLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLL
		FOR NTH=0L,N_ELEMENTS(DB)-1L DO BEGIN
			D = DB[NTH]
		 	XP = ROUND(FLOAT(STR_BREAK(D.PX_SWATH,';')))
		 	YP = ROUND(FLOAT(STR_BREAK(D.PY_SWATH,';')))
		 	LON = (FLOAT(STR_BREAK(D.LON_SWATH,';')))
		 	LAT = (FLOAT(STR_BREAK(D.LAT_SWATH,';')))

;			===> Find the perpendicular points in the swath that are within the map domain
		 	SUBS=WHERE(XP GE 0 AND XP LE PX-1 AND YP GE 0 AND YP LE PY-1,COUNT)

			IF COUNT EQ 0 THEN CONTINUE ; >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

;			===> Redefine XP,YP,LON,LAT,BD
			XP=XP(SUBS)
			YP=YP(SUBS)
			LON=LON(SUBS)
			LAT=LAT(SUBS)
			BD = BATHY(XP,YP)

;			===> Calculate the lower and upper positions for the plot
			LOWER = FLOAT[NTH]*INCREMENT
			UPPER = LOWER+ Y_FRACTION
			IF NTH MOD SAMPLE EQ 0 THEN BEGIN
				PLOT, [150,250], [ -2000,0],XSTYLE=5,YSTYLE=5,POSITION=[XPOS[0],LOWER, XPOS[1],UPPER] ,/NODATA,/NOERASE,/NORMAL


;				===> Label for yaxis
				IF NTH MOD 50 EQ 0 THEN BEGIN
					TXT_KMS = STRTRIM(ROUND(FLOAT(D.KMS)),2)
					XYOUTS2,150,0, TXT_KMS,ALIGN = [1.01,0.5],COLOR=0,CHARSIZE=0.75

					TEMP.SUB = NTH
					TEMP.KMS = TXT_KMS
					IF N_ELEMENTS(STRUCT_LABEL) EQ 0 THEN STRUCT_LABEL = TEMP ELSE STRUCT_LABEL = [STRUCT_LABEL,TEMP]
				ENDIF


				OK_MID = WHERE(SUBS EQ SWATH_CENTER)
 				PLOTS, SWATH_CENTER, -BD(OK_MID),PSYM=8,COLOR=0 ,SYMSIZE=0.5

;				===> Plot the good Bottom Depths against their SUBS subscripts (centered on SWATH_CENTER)
		 		OK_BD=WHERE(FINITE(BD))
 				OPLOT, SUBS(OK_BD) , -BD(OK_BD) ,COLOR=34


;				===> APPROXIMATE THE 200M BY INTERPOLATION
				OK_200M = INTERPOL(SUBS(OK_BD), BD(OK_BD), 200)
				IF FINITE(OK_200M) EQ 0 THEN STOP

				PLOTS,  OK_200M , -200, PSYM=1,COLOR=8,SYMSIZE=0.5

;				===> Determine 2nd derrivative
				DELTA= DERIV(DERIV(BD))
				OK_DERIV = WHERE(BD GE 70 AND BD LE 400 AND FINITE(BD),COUNT_DERIV)
				MAX_DELTA = MAX(DELTA(OK_DERIV),SUB)
				PLOTS, SUBS(OK_DERIV(SUB)), -BD(OK_DERIV(SUB)),PSYM=1,COLOR=21 ,SYMSIZE=0.5
 			ENDIF
		ENDFOR

		PSPRINT
		STRUCT_2CSV,!DIR_SAVE+'BATHY_WATERFALL-' + MAP + '-LABELS.CSV',STRUCT_LABEL

	ENDIF ;		////////////////////////////////////////////////////////////////

; ****************************************************************
  IF DO_MAKE_BATHY_WATERFALL_KMS_LABELS_PLOT GE 1 THEN BEGIN
; ****************************************************************

		AFILE = !DIR_SAVE+'PERPENDICULARS_SHELF_BREAK_2LAND.CSV'
	  FN=FILE_PARSE(AFILE)
		DB = READ_CSV(AFILE)
		MAP = 'MAB_GS'
		LAB = READ_CSV(!DIR_SAVE+'BATHY_WATERFALL-' + MAP + '-LABELS.CSV')
stop
;		===> Make a map showing where the subs for the labels are
		FILES = FILE_SEARCH('D:\PROJECTS\SRTM30\SAVE\*MAB_GS*BATHY.SAVE')
		LIST, FILES
	  AFILE=FILES[0]
	  STRUCT_SD_2PNG,AFILE,/ADD_COLORBAR,/OVERWRITE,DIR_OUT=!DIR_PLOTS
		FN=FILE_PARSE(AFILE)
		BFILE = !DIR_PLOTS+FN.FIRST_NAME+'-LEG.PNG'
		IMAGE=READ_PNG(BFILE,R,G,B)
	  MED = 3
		CON=STRUCT_SD_CONTOUR(AFILE,LEVELS=200,C_colors=0, C_thick=1,C_ANNOTATION=1,MIN_VALUE=MIN_VALUE, MIN_PTS=150,$
	    										/LINES,	/ADD_LAND,/ADD_COAST,/ADD_LAKES,/ADD_COLORBAR,ADD_EXTRA=ADD_EXTRA,/CONFILE,MED=MED,C_CHARSIZE=0.75)
		MAP='MAB_GS'
		ZWIN,IMAGE
		CALL_PROCEDURE,'MAP_'+MAP
		TV,IMAGE
		PLOTS,DB.LON, DB.LAT,COLOR = 253,THICK=3

		PLOT_CONTOURS,STRUCT=CON[0], COLOR=0
		XYOUTS2,DB(LAB.SUB).LON,DB(LAB.SUB).LAT, STRTRIM(LAB.KMS,2), ALIGN=[0.5,0.5],COLOR=0,CHARTHICK=1,CHARSIZE=1.5
		IM=TVRD()
		ZWIN

		PNG_FILE = !DIR_PLOTS+'BATHY_WATERFALL-' + MAP + '-KM_LABELS_200M.PNG'
		WRITE_PNG,PNG_FILE,IM,R,G,B
	ENDIF
; //////////////////////////////////////////////////////////////


; ****************************************************************
  IF DO_TS_SUBAREA_SB_SWATH GE 1 THEN BEGIN
; ****************************************************************

		AFILE = !DIR_SAVE+'PERPENDICULARS_SHELF_BREAK_2LAND.CSV'
	  FN=FILE_PARSE(AFILE)
		DB = READ_CSV(AFILE)
		MAP = 'MAB_GS'

;		===> Calculate center of swath
		SWATH_CENTER = DB[0].NPTS/2		; = 200 with 401 pts

		INFO=MAPS_INFO('MAB_GS')
;		SCALE IS ABOUT 0.75KM/PIXEL

		SWATH_WIDTH = FIX( ROUND(SWATH_KMS/0.75)) ; = 27 PIXELS
	 	PERP_LON = (FLOAT(STR_BREAK(DB.LON_SWATH,';')))
	 	PERP_LAT = (FLOAT(STR_BREAK(DB.LAT_SWATH,';')))

;		===> Make a map SUBAREA
 	  MAP='MAB_GS'
		ZWIN,IMAGE
		CALL_PROCEDURE,'MAP_'+MAP
		ERASE,0

;		===> APPROX THICKNESS FOR A 20KM SWATH ON EITHER SIDE OF THE SB LINE
		OPLOT,DB.LON, DB.LAT,COLOR = 1,THICK= 53,LINESTYLE=0
		OPLOT,DB.LON, DB.LAT,COLOR = 253,THICK=1,LINESTYLE=0
		IM=TVRD()
		ZWIN

		PNG_FILE = !DIR_PLOTS+'MASK_SUBAREA-MAB_GS-PXY_1315_976-SHELF_BREAK-DRAFT.PNG'
		PAL_36,R,G,B
		WRITE_PNG,PNG_FILE,IM,R,G,B


STOP

;		EDIT FILE IN COREL AND SAVE AS MASK_SUBAREA-MAB_GS-PXY_1315_976-SHELF_BREAK-DRAFT-EDIT.PNG

    AFILE = !DIR_PLOTS+'MASK_SUBAREA-MAB_GS-PXY_1315_976-SHELF_BREAK-DRAFT-EDIT.PNG'
    IM=READ_PNG(AFILE,R,G,B)

;		===> TRY DIVIDING UP INTO 9 REGIONS
		MAX_KM = MAX(FLOAT(DB.KMS))
		IN = INTERVAL([0,MAX_KM],max_km/N_SUBAREAS) & HELP, IN
		BATHY = READ_PNG(!DIR_PLOTS+'SRTM30-MAB_GS-BATHY-ZEBRA_FLIP.PNG',R,G,B)
		OK=WHERE_NEAREST(FLOAT(DB.KMS), IN, NEAR=50)
		SUB_LAT = PERP_LAT(OK,*) & SUB_LON = PERP_LON(OK,*)
		ZWIN,BATHY
		CALL_PROCEDURE,'MAP_'+MAP
		TV,BATHY
		FOR NTH=0,N_ELEMENTS(SUB_LAT(*,0))-1 DO BEGIN & ALON=SUB_LON(NTH,*) & ALAT = SUB_LAT(NTH,*) & PLOTS,ALON,ALAT,COLOR=255,THICK=1 & ENDFOR
		TEMP=TVRD()
		ZWIN
		SLIDEW,TEMP

STOP

;		NOW ADD BLACK LINES TO EDIT IMAGE
		AFILE = !DIR_PLOTS+'MASK_SUBAREA-MAB_GS-PXY_1315_976-SHELF_BREAK-DRAFT-EDIT.PNG'
    IM=READ_PNG(AFILE,R,G,B)
		ZWIN,BATHY
		CALL_PROCEDURE,'MAP_'+MAP
		ERASE,255
		FOR NTH=0,N_ELEMENTS(SUB_LAT(*,0))-1 DO BEGIN & ALON=SUB_LON(NTH,*) & ALAT = SUB_LAT(NTH,*) & PLOTS,ALON,ALAT,COLOR=0,THICK=1 & ENDFOR
		TEMP=TVRD()
		ZWIN
		SLIDEW,TEMP
		OK=WHERE(TEMP EQ 0)
		IM[OK] = 0
    BOX=COLORBOX(BOX=32)
    IM(600,0)=BOX
    WRITE_PNG,!DIR_PLOTS+'MASK_SUBAREA-MAB_GS-PXY_1315_976-SHELF_BREAK-DRAFT-EDIT-LINES.PNG',IM,R,G,B



	ENDIF ; DO_TS_SUBAREA_SB_SWATH
; //////////////////////////////////////////////////////////////



; ****************************************************************
  IF DO_MAKE_ANNOTATED_KM_SUBAREA_PNG GE 1  THEN BEGIN
; ****************************************************************
		MAP = 'MAB_GS'

		SUBAREA_IMAGE = READ_PNG(!DIR_PLOTS+'MASK_SUBAREA-MAB_GS-PXY_1315_976-SHELF_BREAK.png',R,G,B)
		BATHY = READ_PNG(!DIR_PLOTS+'SRTM30-MAB_GS-BATHY-ZEBRA_FLIP.PNG',R,G,B)

		FILE = !DIR_SAVE+'PERPENDICULARS_SHELF_BREAK_2LAND.CSV'
	  FN=FILE_PARSE(FILE)
		DB = READ_CSV(FILE)

		MAX_KM = MAX(FLOAT(DB.KMS))
		IN = INTERVAL([0,MAX_KM],max_km/N_SUBAREAS) & HELP, IN

		OK=WHERE_NEAREST(FLOAT(DB.KMS), IN, NEAR=50)
		PERP_LON = (FLOAT(STR_BREAK(DB.LON_SWATH,';')))
	 	PERP_LAT = (FLOAT(STR_BREAK(DB.LAT_SWATH,';')))
		SUB_LON = PERP_LON(OK,*)
		SUB_LAT = PERP_LAT(OK,*)

		PERP_PX = (FLOAT(STR_BREAK(DB.PX_SWATH,';')))
	 	PERP_PY = (FLOAT(STR_BREAK(DB.PY_SWATH,';')))
	 	SUB_PX = PERP_PX(OK,*)
		SUB_PY = PERP_PY(OK,*)

		SWATH_CENTER = DB[0].NPTS/2		; = 200 with 401 pts

		SWATH_WIDTH = FIX( ROUND(SWATH_KMS/0.75)) ; = 27 PIXELS



		FONT_TIMES
		ZWIN,SUBAREA_IMAGE
		CALL_PROCEDURE,'MAP_'+MAP
		ERASE,255
		FOR NTH=0,N_ELEMENTS(IN)-1 DO BEGIN
			LABEL = STRTRIM(FIX(ROUND(IN[NTH])),2)
			IF NTH EQ 1 THEN LABEL = LABEL + ' km'
			ALON= REFORM(SUB_LON(NTH,*)) & ALAT = REFORM(SUB_LAT(NTH,*))
			APX= REFORM(SUB_PX(NTH,*)) & APY = REFORM(SUB_PY(NTH,*))
			S=STATS2(APX,APY,TYPE='4')
			ANGLE = atan(S.slope)*!radeg
			IF SIGN(ANGLE) EQ 1 THEN ANGLE =   -1*ANGLE
			NPIXELS = CEIL(ANGLE_2PIXELS(ANGLE)*SWATH_WIDTH)

;			===> Place an symbol at the ends of each major subarea division transect
;			SUB_START = SWATH_CENTER - NPIXELS
;			SUB_END  = SWATH_CENTER + NPIXELS
;			PLOTS,ALON(SUB_START),ALAT(SUB_START),COLOR=31,THICK=1,PSYM=1
;			PLOTS,ALON(SUB_END),ALAT(SUB_END),COLOR=31,THICK=1,PSYM=1
			XYOUTS2, ALON(SWATH_CENTER), ALAT(SWATH_CENTER) , LABEL, ALIGN=[0,0.5],ORIENTATION=ANGLE,CHARSIZE=3,COLOR= 1
			PLOTS, ALON(SWATH_CENTER), ALAT(SWATH_CENTER) , PSYM=1, COLOR= 1,THICK=3,SYMSIZE=1.6


		ENDFOR
		IMAGE_KM=TVRD()
		ZWIN


;		===> Make an outline of just the shelf subareas
		COPY=SUBAREA_IMAGE
 		COPY(*,*)=255
 		OK_SUBAREA=WHERE(SUBAREA_IMAGE GE 1 AND SUBAREA_IMAGE LE 10)
 		COPY(OK_SUBAREA) = SUBAREA_IMAGE(OK_SUBAREA)


;		===> OUTLINE the subareas
		NEW=IMAGE_OUTLINE(COPY)
		ok_outline=WHERE(NEW EQ 1)

		COPY=NEW & COPY(*) = 255 & COPY(OK_OUTLINE)=0

		OK_IMAGE_KM = WHERE(IMAGE_KM EQ 1)
 		COPY(OK_IMAGE_KM) = 0


		BATHY=READ_BATHY(MAP=MAP,NAME=NAME)

		MED = 3
		CON=STRUCT_SD_CONTOUR(NAME,LEVELS=200,C_colors=0, C_thick=1,C_ANNOTATION=1,MIN_VALUE=MIN_VALUE, MIN_PTS=150,$
	    										/LINES,	/ADD_LAND,/ADD_COAST,/ADD_LAKES,/ADD_COLORBAR,ADD_EXTRA=ADD_EXTRA,/CONFILE,MED=MED,C_CHARSIZE=0.75)
		ZWIN,COPY
		CALL_PROCEDURE,'MAP_'+MAP
	  TV,COPY
	  PLOT_CONTOURS,STRUCT=CON,COLOR=0
		COPY=TVRD()
		ZWIN


		LAND=READ_LANDMASK(MAP='MAB_GS',/STRUCT)
stop

		COPY(LAND.LAND) = 34
		COPY(LAND.COAST) = 0
		PAL_36,R,G,B
		WRITE_PNG,!DIR_PLOTS+MAP+'-SUBAREAS_KM.PNG',COPY,R,G,B

	ENDIF ; DO_TS_SUBAREA_SB_SWATH
; //////////////////////////////////////////////////////////////


; ****************************************************************
  IF DO_KM_SUBAREAS_SWATH GE 1 THEN BEGIN
; ****************************************************************
		MAP = 'MAB_GS'
		M=MAPS_SIZE(MAP)
		FILE = !DIR_SAVE+'PERPENDICULARS_SHELF_BREAK_2LAND.CSV'
	  FN=FILE_PARSE(FILE)
		DB = READ_CSV(FILE)

		MAX_KM = MAX(FLOAT(DB.KMS))
   	PERP_PX = (FLOAT(STR_BREAK(DB.PX_SWATH,';')))
	 	PERP_PY = (FLOAT(STR_BREAK(DB.PY_SWATH,';')))

		SWATH_CENTER = DB[0].NPTS/2		; = 200 with 401 pts

		SWATH_WIDTH = FIX( ROUND(SWATH_KMS/0.75)) ; = 27 PIXELS

		IMAGE = REPLICATE(MISSINGS(0),M.PX,M.PY)
		FOR NTH=0,N_ELEMENTS(PERP_PX(*,0))-1L DO BEGIN
			SUBAREA_CODE = NTH+1L
			APX= REFORM(PERP_PX(NTH,*)) & APY = REFORM(PERP_PY(NTH,*))


			S=STATS2(APX,APY,TYPE='4',/FAST,ERROR=ERROR)
			IF ERROR EQ 1 THEN CONTINUE

			ANGLE = atan(S.slope)*!radeg
			IF SIGN(ANGLE) EQ 1 THEN ANGLE =   -1*ANGLE
			NPIXELS = CEIL(ANGLE_2PIXELS(ANGLE)*SWATH_WIDTH)

	IF NPIXELS EQ 0 THEN NPIXELS = SWATH_WIDTH
			LANDWARD_PX = APX( (SWATH_CENTER-NPIXELS):(SWATH_CENTER-1))
			SEAWARD_PX  = APX(SWATH_CENTER+1: (SWATH_CENTER+NPIXELS))

			LANDWARD_PY = APY( (SWATH_CENTER-NPIXELS):(SWATH_CENTER-1))
			SEAWARD_PY  = APY(SWATH_CENTER+1: (SWATH_CENTER+NPIXELS))

			IMAGE(LANDWARD_PX,LANDWARD_PY) = SUBAREA_CODE
			IMAGE(SEAWARD_PX,SEAWARD_PY) = SUBAREA_CODE + 10000L
		ENDFOR

STOP

	ENDIF
STOP




;XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
END



