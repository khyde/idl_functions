; $ID:	SOOP_SUBAREA.PRO,	2020-07-08-15,	USER-KJWH	$

	PRO SOOP_SUBAREA

;+
; NAME:
;		SOOP_SUBAREA
;
; PURPOSE:;
;		This procedure creates a new subarea map for the SOOP data
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
;			Written April 24, 2009 by K.J.W.Hyde, 28 Tarzwell Drive, NMFS, NOAA 02882 (kimberly.hyde@noaa.gov)
;-
;	****************************************************************************************************
	ROUTINE_NAME = 'SOOP_SUBAREA'

;	===> Initialize ERROR to a null string. If errors are encountered ERROR will be set to a message.
;			 The calling routine can check error (e.g.IF ERROR NE 0 then there was a problem and do this or that)
	ERROR = ''
	
 	SL = DELIMITER(/PATH)
	DIR_PROJECTS = !S.PROJECTS
	DIR       = DIR_PROJECTS + 'SOOP' + SL
	DIR_DATA  = DIR + 'DATA' + SL
	DIR_PLOTS = DIR + 'PLOTS' + SL
	DIR_SAVE  = DIR + 'SAVE' + SL

	
	DO_SUBAREA_MAP				= 0
	


;	*******************************************************
	IF DO_SUBAREA_MAP GE 1 THEN BEGIN
;	*******************************************************
		OVERWRITE = DO_SUBAREA_MAP GE 2

		POLYGONS = ['gb_slp','gb_sof','gb_cen','gb_nof','gb_nec','gom_mb','gom_wb','gom_cl','gom_cb','gom_ss','mab_is','mab_os','mab_isl','mab_osl']

		DIR_PLOTS  = 'D:\PROJECTS\SOOP\PLOTS\'
		DIR_IMAGES = 'D:\IDL\IMAGES\'
		LANDMASK   = 'D:\IDL\IMAGES\MASK_LAND-NEC-PXY_1024_1024.PNG'

		LANDMASK = READ_LANDMASK(MAP='NEC',/STRUCT)
		IMG    = READ_LANDMASK(MAP='NEC')
   	ZWIN, IMG
	  OLDDEVICE= !D.NAME
		MAP_NEC
   	PAL_36,R,G,B

; Georges Bank Polygons
		gb_slp_lon=[ -72.3, -70.4, -69.8, -69.5, -71.8, -72.3]
		gb_slp_lat=[  39.1,  40.1,  40.0,  40.0,  38.8,  39.1]
		IM = MAP_DEG2IMAGE(IMG,gb_slp_lon,gb_slp_lat, X=x, Y=y,AROUND=0) & POLYFILL, X, Y, COLOR=5, /DEVICE
		gb_sof_lon=[ -70.4, -69.8, -69.5, -68.1597, -68.5769, -70.4]
		gb_sof_lat=[  40.1,  40.0,  40.0,  40.5892,  40.8806,  40.1]
		IM = MAP_DEG2IMAGE(IMG,gb_sof_lon,gb_sof_lat, X=x, Y=y,AROUND=0) & POLYFILL, X, Y, COLOR=6, /DEVICE
		gb_cen_lon=[ -68.1597, -68.5769, -67.3208, -67.2, -66.7, -68.1597]
		gb_cen_lat=[  40.5892,  40.8806,  41.4414,  41.7,  41.2,  40.5892]
		IM = MAP_DEG2IMAGE(IMG,gb_cen_lon,gb_cen_lat, X=x, Y=y,AROUND=0) & POLYFILL, X, Y, COLOR=7, /DEVICE
		gb_nof_lon=[ -67.2, -66.7372, -66.4109, -66.0846, -65.8670, -65.7582, -65.9540, -66.7, -67.2]
		gb_nof_lat=[  41.7,  42.2149,  42.2733,  42.2149,  42.0836,  41.8793,  41.5437,  41.2,  41.7]
		IM = MAP_DEG2IMAGE(IMG,gb_nof_lon,gb_nof_lat, X=x, Y=y,AROUND=0) & POLYFILL, X, Y, COLOR=8, /DEVICE
		gb_nec_lon=[ -66.7372, -66.4109, -66.0846, -65.8670, -65.7582, -65.9540, -65.3584, -65.5400, -65.7915, -66.0080, -66.3922, -66.7372]
		gb_nec_lat=[  42.2149,  42.2733,  42.2149,  42.0836,  41.8793,  41.5437,  41.8295,  42.1950,  42.3105,  42.4933,  42.5798,  42.2149]
		IM = MAP_DEG2IMAGE(IMG,gb_nec_lon,gb_nec_lat, X=x, Y=y,AROUND=0) & POLYFILL, X, Y, COLOR=9, /DEVICE

;	Gulf of Maine Polygons
		gom_mb_lon=[ -70.8548, -70.1359, -70.1083, -70.8410, -70.8548]
		gom_mb_lat=[  43.0294,  43.1294,  42.3136,  42.1952,  43.0294]
		IM = MAP_DEG2IMAGE(IMG,gom_mb_lon,gom_mb_lat, X=x, Y=y,AROUND=0) & POLYFILL, X, Y, COLOR=10, /DEVICE
		gom_wb_lon=[ -70.1359, -69.2926, -69.2788, -70.1083, -70.1359]
		gom_wb_lat=[  43.1294,  43.1996,  42.4320,  42.3136,  43.1294]
		IM = MAP_DEG2IMAGE(IMG,gom_wb_lon,gom_wb_lat, X=x, Y=y,AROUND=0) & POLYFILL, X, Y, COLOR=11, /DEVICE
		gom_cl_lon=[ -69.2926, -68.0346, -68.0622, -69.2788, -69.2926]
		gom_cl_lat=[  43.1996,  43.2873,  42.5943,  42.4320,  43.1996]
		IM = MAP_DEG2IMAGE(IMG,gom_cl_lon,gom_cl_lat, X=x, Y=y,AROUND=0) & POLYFILL, X, Y, COLOR=12, /DEVICE
		gom_cb_lon=[ -68.0346, -67.0668, -67.0668, -68.0622, -68.0346]
		gom_cb_lat=[  43.2873,  43.2697,  42.7171,  42.5943,  43.2873]
		IM = MAP_DEG2IMAGE(IMG,gom_cb_lon,gom_cb_lat, X=x, Y=y,AROUND=0) & POLYFILL, X, Y, COLOR=13, /DEVICE
		gom_ss_lon=[ -67.0668, -65.4770, -65.4631, -67.0668, -67.0668]
		gom_ss_lat=[  43.2697,  43.4232,  42.9189,  42.7171,  43.2697]
		IM = MAP_DEG2IMAGE(IMG,gom_ss_lon,gom_ss_lat, X=x, Y=y,AROUND=0) & POLYFILL, X, Y, COLOR=14, /DEVICE

;	Mid-Atlantic Bight
		mab_is_lon =[-74.3374, -73.5760, -72.6084, -73.4142, -74.3374]
		mab_is_lat =[ 40.5262,  39.6578,  40.4825,  40.9564,  40.5262]
		IM = MAP_DEG2IMAGE(IMG,mab_is_lon,mab_is_lat, X=x, Y=y,AROUND=0) & POLYFILL, X, Y, COLOR=15, /DEVICE
		mab_os_lon =[-73.5760, -72.9486, -71.7107, -72.6084, -73.5760]
		mab_os_lat =[ 39.6578,  38.8869,  39.8882,  40.4825,  39.6578]
		IM = MAP_DEG2IMAGE(IMG,mab_os_lon,mab_os_lat, X=x, Y=y,AROUND=0) & POLYFILL, X, Y, COLOR=16, /DEVICE
		mab_isl_lon=[-72.9486, -71.7921, -70.3923, -71.7107, -72.9486]
		mab_isl_lat=[ 38.8869,  37.5066,  39.2039,  39.8882,  38.8869]
		IM = MAP_DEG2IMAGE(IMG,mab_isl_lon,mab_isl_lat, X=x, Y=y,AROUND=0) & POLYFILL, X, Y, COLOR=17, /DEVICE
		mab_osl_lon=[-71.7921, -70.4263, -68.8364, -70.3923, -71.7921]
		mab_osl_lat=[ 37.5066,  35.8889,  38.3450,  39.2039,  37.5066]
		IM = MAP_DEG2IMAGE(IMG,mab_osl_lon,mab_osl_lat, X=x, Y=y,AROUND=0) & POLYFILL, X, Y, COLOR=18, /DEVICE

		IM_SUBS = tvrd()		
		IM=MAP_ADD_BATHY(IMG,BATHS=[50,200],COLOR=34,MAP='NEC')
		TV,IM
		IM_BATH=TVRD()
		IM=MAP_ADD_BATHY_LABEL(IMG, MAP='NEC', BATHS=[50,200],COLOR=22)
		TV,IM
		IM_LABEL=TVRD()
		ZWIN

    OK_IMAGE = WHERE(IMG NE 0)
    IM_SUBS(OK_IMAGE) = IMG(OK_IMAGE)
		MASK = IM_SUBS
		IMG(LANDMASK.OCEAN) = 36
		OK = WHERE(IM_SUBS NE 0)
		IMG[OK] = IM_SUBS[OK]
		OK = WHERE(IM_BATH NE 0)
		IMG[OK] = IM_BATH[OK]
		OK = WHERE(IM_LABEL NE 0)
		IMG[OK] = 0

		IMG(LANDMASK.LAND)  = 32
		IMG(LANDMASK.COAST) = 0

		OK = WHERE(MASK NE 0)
		IM_SUBS[OK] = MASK[OK]

		EDITFILE = DIR_IMAGES	+ 'MASK_SUBAREA-NEC-PXY_1024_1024-SOOP_POLYGONS-TO_BE_EDITED.PNG' & WRITE_PNG, EDITFILE, IM_SUBS, R,G,B
		MASKFILE = DIR_IMAGES + 'MASK_SUBAREA-NEC-PXY_1024_1024-SOOP_POLYGONS.PNG'
		PNGFILE  = DIR_IMAGES	+ 'MASK_SUBAREA-NEC-PXY_1024_1024-SOOP_POLYGONS-DISPLAY.PNG' & WRITE_PNG, PNGFILE, IMG, R,G,B
  	CSVFILE  = DIR_IMAGES	+ 'MASK_SUBAREA-NEC-PXY_1024_1024-SOOP_POLYGONS.CSV'
  	SAVEFILE = DIR_IMAGES + 'MASK_SUBAREA-NEC-PXY_1024_1024-SOOP_POLYGONS.SAVE'


		STRUCT1=CREATE_STRUCT('SUBAREA_CODE','','SUBAREA_NAME','','NICKNAME','')
		STRUCT1=REPLICATE(STRUCT1,3)
		STRUCT1[0].SUBAREA_CODE =0 	& STRUCT1[0].SUBAREA_NAME = 'OCEAN' 		& STRUCT1[0].NICKNAME='OCEAN'
		STRUCT1[1].SUBAREA_CODE =1 	& STRUCT1[1].SUBAREA_NAME = 'COAST' 		& STRUCT1[1].NICKNAME='COAST'
		STRUCT1(2).SUBAREA_CODE =2 	& STRUCT1(2).SUBAREA_NAME = 'LAND'  		& STRUCT1(2).NICKNAME='LAND'

		STRUCT=CREATE_STRUCT('SUBAREA_CODE','','SUBAREA_NAME','','NICKNAME','')
		STRUCT=REPLICATE(STRUCT,N_ELEMENTS(POLYGONS))
		STRUCT.SUBAREA_CODE = INDGEN(N_ELEMENTS(POLYGONS))+5
		STRUCT.SUBAREA_NAME = STRUPCASE(POLYGONS)
		STRUCT.NICKNAME     = STRUPCASE(POLYGONS)

		CSV = STRUCT_CONCAT(STRUCT1,STRUCT)

		INFILE=MASKFILE
		NOTES='MASK_SUBAREA'

;			===> Write the Struct to a csv
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

	ENDIF		; DO_SUBAREA_MAP
	


END; #####################  End of Routine ################################



