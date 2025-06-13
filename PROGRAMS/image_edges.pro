; $ID:	IMAGE_EDGES.PRO,	2020-07-08-15,	USER-KJWH	$

  PRO IMAGE_EDGES,  Files, DO_FILTER=do_filter, FILTER_NAME=filter_name, $   ; FILTER STEP 1

  												 DO_GAUSSIAN_SMOOTH=DO_GAUSSIAN_SMOOTH, GAUSSIAN_WIDTH=gaussian_width,GAUSSIAN_SIGMA=gaussian_sigma, $ ; SMOOTHING STEP 2

  												 EDGE_DETECTOR= edge_detector,  $

;													 SPECIAL KEYWORDS FOR CANNY
  												 CANNY_SMOOTH=CANNY_SMOOTH,CANNY_SIGMA=CANNY_SIGMA, CANNY_LOW=CANNY_LOW,CANNY_HIGH=CANNY_HIGH, $

  												 OVERWRITE=overwrite, ERROR = error
;
;
; NAME:
;      IMAGE_EDGES
;
; PURPOSE:
;         This procedure detects edges in 2-dimensional image arrays and writes image array results to idl save files.
;
; CATEGORY:
;          Edge Detection
;
; CALLING SEQUENCE:
;   Write the calling sequence here. Include only positional parameters
;   (i.e., NO KEYWORDS). For procedures, use the form:
;                                                     IMAGE_EDGES, Files
; INPUTS:
;        Files:  The full path and file names of the IDL 'Standard SAVE Files'
;
; KEYWORD PARAMETERS:
;		DO_FILTER.......	Filter out bad data (spikes)
;		FILTER_NAME.....	The filter to use in step 1 to smooth the input data


;		DO_GAUSSIAN_SMOOTH.	Apply a Gaussian Smoothing before edge detection step
;		GAUSSIAN_WIDTH... Width in pixels for the Gaussian Smoothing
;		GAUSSIAN_SIGMA... Sigma value used in in Gaussian Smoothing,
;
;   EDGE_DETECTOR.... The edge detection to apply to each input image

;		CANNY_LOW........	Canny Low parameter
;		CANNY_HIGH....... Canny High parameter
;		CANNY_SIGMA...... Canny Sigma value used in gaussian smoothing
;
;   OVERWRITE: 		Overwrite the output file if it already exists (overwrite = 1)
;   ERROR: '' = NO ERROR ;  'SOME ERROR MESSAGE' = ERROR
;
; OUTPUTS:
;    Data are output in standard SAVE files and PNG image files are made.
;
; OPTIONAL OUTPUTS:
;
; RESTRICTIONS:
;    Assumes that the input files are the NOAA, Narragansett Standard Satellite Image Save files'
;
; PROCEDURE:
;           This routine uses IDL'S CONVOL convolution routine for all edge detectors
;
; EXAMPLE:
;
; NOTES:;
;
; MODIFICATION HISTORY:
;			Written Jan 17, 2007 by J.O'Reilly (NOAA)
;
; ****************************************************************************************************
  ROUTINE_NAME = 'IMAGE_EDGES'

; ===> Initialize ERROR to a null string. If errors are encountered ERROR will be set to a message.
;      The calling routine can check error (e.g.IF ERROR NE 0 then there was a problem and do this or that)
  ERROR = ''
	LABELS_COMPASS=['N','E','S','W']
	NAME_EXTRA = ''

;	===> List of Products which will be log-transformed during processing steps
	LOG_PRODUCTS = ['CHLOR_A']

; *************************************
; *** C r e a t e    F i l t e r s  ***
; *************************************

; %%%  EDGE_DETECTOR_SOBEL  %%%
  EDGE_DETECTOR_SOBEL = FLTARR(3,3)
  EDGE_DETECTOR_SOBEL[0,[0,2]] = -1.;
  EDGE_DETECTOR_SOBEL[2,[0,2]] =  1.;
  EDGE_DETECTOR_SOBEL[0,1] = -2.;
  EDGE_DETECTOR_SOBEL[2,1] =  2.;
; //////////////////////////

; %%%  EDGE_DETECTOR_ROBERTS  %%%
  EDGE_DETECTOR_ROBERTS = FLTARR(2,2);
  EDGE_DETECTOR_ROBERTS[0,0] =  1.;
  EDGE_DETECTOR_ROBERTS[1,1] = -1.;
; //////////////////////////

; %%%  EDGE_DETECTOR_LAPLACE  %%%
  EDGE_DETECTOR_LAPLACE = FLTARR(3,3);
  EDGE_DETECTOR_LAPLACE[1, *] = -1.;
  EDGE_DETECTOR_LAPLACE[*, 1] = -1.;
  EDGE_DETECTOR_LAPLACE[1, 1] = 4.;
; //////////////////////////


; ===> Default EDGE_DETECTOR(s)
  IF N_ELEMENTS(EDGE_DETECTOR) EQ 0 THEN  EDGE_DETECTOR = ['SOBEL'] ELSE EDGE_DETECTOR = STRUPCASE(EDGE_DETECTOR)


; ************************************************
  N_FILES = N_ELEMENTS(FILES)

;	===> Must provide either files or an image
  IF N_FILES EQ 0 THEN BEGIN
     ERROR = 'Must provide files'
     RETURN
  ENDIF

;	===> Initialize LAST MAP
	LAST_MAP = ''

stop
; ************************************
  FOR _files = 0L, N_FILES-1L DO BEGIN
; ************************************
  	AFILE = FILES(_files)
    FN = FILE_PARSE(AFILE)
    FI = FILE_ALL(AFILE)
    MAP = FI.MAP

;		===> Get Landmask for this MAP
		IF MAP NE LAST_MAP THEN BEGIN
		  LANDMASK = READ_LANDMASK(MAP=MAP,/LAND)
		  ok_land = WHERE(LANDMASK EQ 1,COUNT_LAND)

;			===>  Call MAP_AZIMUTH to get the Azimuth (East of north) in degrees.
    	AZIMUTH = MAP_AZIMUTH(LANDMASK, MAP=MAP, ERROR=error)
		ENDIF


;		*********************
;		*** Read the Data ***
;		*********************
		IF STRUPCASE(FN.EXT) EQ 'PNG' THEN DATA=READ_PNG(AFILE,R,G,B)
		IF STRUPCASE(FN.EXT) EQ 'GIF' THEN READ_GIF, AFILE,DATA,R,G,B

		IF STRUPCASE(FN.EXT) EQ 'SAVE' THEN BEGIN
;   	===> Read the file and get the geophysical data
    	data = STRUCT_SD_READ(AFILE,STRUCT=STRUCT,SUBS=SUBS)
;   	===> Determine the product PROD from the structure
    	APROD = STRUCT.(0)

;			===> Make a png of the raw input file
			STRUCT_SD_2PNG,	AFILE,	DIR_OUT=!DIR_BROWSE,/ADD_COAST,/ADD_LAND,/ADDDATE,/ADD_COLORBAR,OVERWRITE=OVERWRITE

			IF APROD EQ 'SST' 		THEN 	EPSILON = 1.0
			IF APROD EQ 'CHLOR_A' THEN 	EPSILON = ALOG(2.0)

	  	FILE_LABEL 	= ''
	  	PROCESSING = ''

;			***********************************************************
;			*** Must change our missing data code (infinity) to NAN ***
			Data = INFINITY_2NAN(DATA)
;			***********************************************************
		ENDIF

;		************************************
;		*** Apply Filter to Remove Noise ***
;		************************************
		IF KEYWORD_SET(DO_FILTER) THEN BEGIN
			IF N_ELEMENTS(FILTER_NAME) EQ 1 THEN BEGIN
				IF FILTER_NAME EQ 'MF3_1D_5PT' THEN BEGIN
					PROCESSING=PROCESSING+FILTER_NAME+';'
					FILE_LABEL=FILE_LABEL+'-'+FILTER_NAME
					FILE_LABEL = REPLACE(FILE_LABEL,'--','-')

;					===> Operate on the natural log of the product ?
					OK_LOG=WHERE(LOG_PRODUCTS EQ STRUPCASE(APROD),DO_LOG)
					IF DO_LOG EQ 1 THEN BEGIN
						DATA = EXP(MF3_1D_5PT(ALOG(Data),EPSILON=EPSILON, ITER=iter, FILTERED=filtered,P5_MAX=P5_MAX,P5_MIN=P5_MIN, P3_MIN=P3_MIN,P3_MAX=P3_MAX, ERROR = error))
					ENDIF ELSE BEGIN
						DATA = 		MF3_1D_5PT(			Data,	EPSILON=EPSILON, ITER=iter, FILTERED=filtered,P5_MAX=P5_MAX,P5_MIN=P5_MIN, P3_MIN=P3_MIN,P3_MAX=P3_MAX, ERROR = error)
					ENDELSE

;					===> Find the filtered (removed) points over water
				  OK=WHERE(LANDMASK EQ 0 AND FILTERED NE 0,COUNT)
				  TXT = STRTRIM(COUNT,2)+' Points Filtered (over water)'
					SAVE_FILTERED_DATA_FILE = !DIR_SAVE+FN.FIRST_NAME+FILE_LABEL+'.SAVE'

					STRUCT_SD_WRITE,SAVE_FILTERED_DATA_FILE, IMAGE=DATA,PROD=APROD,INFILE=AFILE,NOTES=PROCESSING,ERROR=ERROR
					STRUCT_SD_2PNG,	SAVE_FILTERED_DATA_FILE,	DIR_OUT=!DIR_BROWSE,/ADD_COAST,/ADD_LAND,/ADDDATE,/ADD_COLORBAR,OVERWRITE=OVERWRITE

;						===> Write the save and png showing the locations of the points that are filtered (removed)
					SAVE_FILTERED_FLAG_FILE = !DIR_SAVE+FN.FIRST_NAME+FILE_LABEL+'-FILTERED.SAVE'
					STRUCT_SD_WRITE,SAVE_FILTERED_FLAG_FILE, IMAGE=FILTERED,PROD='FLAG',INFILE=AFILE,NOTES=PROCESSING,ERROR=ERROR
					STRUCT_SD_2PNG, SAVE_FILTERED_FLAG_FILE, DIR_OUT=!DIR_BROWSE,COLORBAR_TITLE='Filtered',/ADD_COAST,/ADD_LAND,/ADDDATE,/ADD_COLORBAR,ADD_EXTRA=TXT,OVERWRITE=OVERWRITE

				ENDIF
			ENDIF
		ENDIF
;		///////////////////


;		***********************
;		*** Apply Smoothing ***
;		***********************
		IF KEYWORD_SET(DO_GAUSSIAN_SMOOTH) THEN BEGIN
			TXT_WIDTH= REPLACE(ROUNDS(GAUSSIAN_WIDTH),'.','_')
			TXT_SIGMA= REPLACE(ROUNDS(GAUSSIAN_SIGMA,1),'.','_')
		  TXT = '-GAUSS_'	+ TXT_WIDTH +'_SIG_'		+ TXT_SIGMA
			PROCESSING=PROCESSING + TXT + ';'
			FILE_LABEL=FILE_LABEL+TXT
			FILE_LABEL = REPLACE(FILE_LABEL,'--','-')

;			===> Operate on the natural log of the product ?
			OK_LOG=WHERE(LOG_PRODUCTS EQ STRUPCASE(APROD),DO_LOG)
			IF DO_LOG EQ 1 THEN BEGIN
				DATA = EXP(FILTER_GAUSSIAN(ALOG(DATA), WIDTH=GAUSSIAN_WIDTH, SIGMA=GAUSSIAN_SIGMA,ERROR=error))
			ENDIF ELSE BEGIN
				DATA = 		FILTER_GAUSSIAN(		 DATA, 	WIDTH=GAUSSIAN_WIDTH, SIGMA=GAUSSIAN_SIGMA,ERROR=error)
			ENDELSE

			SAVE_GAUSS_FILE = !DIR_SAVE+FN.FIRST_NAME+FILE_LABEL+'.SAVE'
		  STRUCT_SD_WRITE,SAVE_GAUSS_FILE, IMAGE=DATA,PROD=APROD,INFILE=AFILE,NOTES=PROCESSING,ERROR=ERROR
			STRUCT_SD_2PNG,	SAVE_GAUSS_FILE,	DIR_OUT=!DIR_BROWSE,/ADD_COAST,/ADD_LAND,/ADDDATE,/ADD_COLORBAR,OVERWRITE=OVERWRITE

 		ENDIF
;		//////


STOP
;		***********************************************************
  	FOR _EDGE_DETECTOR = 0,N_ELEMENTS(EDGE_DETECTOR)-1 DO BEGIN
;		***********************************************************
			AEDGE_DETECTOR = EDGE_DETECTOR(_EDGE_DETECTOR)
			PROCESSING=PROCESSING+ AEDGE_DETECTOR +';'
			FILE_LABEL_EDGE =FILE_LABEL + '-'+ AEDGE_DETECTOR
			FILE_LABEL_EDGE = REPLACE(FILE_LABEL,'--','-')

 			IF AEDGE_DETECTOR EQ 'CANNY' THEN BEGIN
      	IF N_ELEMENTS(CANNY_LOW) NE 1 THEN CANNY_LOW = 0.4
      	IF N_ELEMENTS(CANNY_HIGH) NE 1 THEN CANNY_HIGH = 0.8
      	IF N_ELEMENTS(CANNY_SIGMA) NE 1 THEN CANNY_SIGMA = 0.6
	 			TXT_SIGMA = ROUNDS(STRTRIM(CANNY_SIGMA,2),1) 	& TXT_SIGMA = REPLACE(TXT_SIGMA,'.','_')
				TXT_LOW 	= ROUNDS(STRTRIM(CANNY_LOW,2),1) 		& TXT_LOW 	= REPLACE(TXT_LOW,'.','_')
				TXT_HIGH 	= ROUNDS(STRTRIM(CANNY_HIGH,2),1) 	& TXT_HIGH 	= REPLACE(TXT_HIGH,'.','_')
				NAME_EXTRA = NAME_EXTRA + '-SIGMA'+ '_'	+ TXT_SIGMA
				NAME_EXTRA = NAME_EXTRA + '-LOW' 	+'_'	+ TXT_LOW
				NAME_EXTRA = NAME_EXTRA + '-HIGH'	+ '_'	+  TXT_HIGH
    	ENDIF


			SAVE_GRAD_MAG_FILE 	= !DIR_SAVE+	FN.FIRST_NAME+FILE_LABEL_EDGE+name_extra+'-GRAD_MAG.SAVE'
			SAVE_GRAD_DIR_FILE 	= !DIR_SAVE+	FN.FIRST_NAME+FILE_LABEL_EDGE+name_extra+'-GRAD_DIR.SAVE'
			PS_HIST_FILE      	= !DIR_PLOTS+	FN.FIRST_NAME+FILE_LABEL_EDGE+name_extra+'-GRAD_MAG-HIST.PS'

;			===> If the save_file exists then skip to next file
      IF FILE_TEST(SAVE_GRAD_MAG_FILE) EQ 1 AND OVERWRITE EQ 0 THEN CONTINUE ; >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

;     ===> Always use CONVOL for the convolution of the edge detectore with the image
;     CONVOL permits the identification of INVALID data and NAN

;			*********************************
;			**** Standard EDGE_DETECTORS  ***
;			*********************************

     	IF AEDGE_DETECTOR EQ 'SOBEL' THEN BEGIN;
        GX = CONVOL(DATA,       		EDGE_DETECTOR_SOBEL,	/CENTER)
        GY = CONVOL(DATA,TRANSPOSE(	EDGE_DETECTOR_SOBEL), /CENTER)
  		ENDIF

  		IF AEDGE_DETECTOR EQ 'ROBERTS'  THEN BEGIN;
        GX = CONVOL(DATA,       		EDGE_DETECTOR_ROBERTS,	/CENTER)
        GY = CONVOL(DATA,TRANSPOSE(	EDGE_DETECTOR_ROBERTS), /CENTER)
  		ENDIF

  		IF AEDGE_DETECTOR EQ 'LAPLACE' THEN BEGIN;
        GX = CONVOL(DATA,       		EDGE_DETECTOR_LAPLACE,	/CENTER)
        GY = CONVOL(DATA,TRANSPOSE(	EDGE_DETECTOR_LAPLACE), /CENTER)
  		ENDIF

      IF AEDGE_DETECTOR EQ 'CANNY' THEN BEGIN
;				===> Use the DATA_FILTERED (not DATA_SMOOTHED) because CANNY will do the gaussian smoothing
      	CANNY_EDGES = CANNY_J(DATA,low=CANNY_LOW, high=CANNY_HIGH, sigma=canny_sigma, IMAGE_SMO=IMAGE_SMO, GX=gx, GY=gy, SECTOR=sector)
      	SAVE_EDGES_FILE 	= !DIR_SAVE+FN.FIRST_NAME+FILE_LABEL_EDGE+name_extra+'-CANNY_EDGES.SAVE'
      	STRUCT_SD_WRITE,SAVE_EDGES_FILE, IMAGE=CANNY_EDGES,PROD='EDGES',INFILE=AFILE,NOTES=PROCESSING,ERROR=ERROR
      	STRUCT_SD_2PNG,	SAVE_EDGES_FILE,DIR_OUT=!DIR_BROWSE,/ADD_COAST,/ADD_LAND,/ADDDATE,/ADD_COLORBAR,OVERWRITE=OVERWRITE
    	ENDIF

;			************************************
;			*** Calculate Gradient Magnitude ***
;			************************************
  		GRAD_MAG = SQRT(GX^2 + GY^2)

;     ************************************
;     *** Calculate Gradient Direction ***
;     ************************************
      GRAD_DIR = ATAN(GY, GX)
;			===> Adjust from zero system of degrees being east to zero being north and change radians to degrees
			GRAD_DIR = (GRAD_DIR-!PI/2)*!RADEG
;			===> Adjust to 0-360 scheme
			GRAD_DIR = (540 - GRAD_DIR) MOD 360

;			===> Adjust GRAD_DIR to compensate for the map projection
;					 (e.g. with a Lambert Conic Projection, only the central longitude is pointing exactly North)
;     (e.g. NEC, vertical (1023,1022) to (1023,1023) azimuth = 5.25737 So, so must add 5.25737 to GRAD_DIR
 			GRAD_DIR = GRAD_DIR + AZIMUTH
			GRAD_DIR = GRAD_DIR MOD 360 ; Ensure 0 to 360 system


 			STRUCT_SD_WRITE,SAVE_GRAD_MAG_FILE, IMAGE=GRAD_MAG,PROD='GRAD_MAG',INFILE=AFILE,NOTES=PROCESSING,ERROR=ERROR
 			STRUCT_SD_2PNG,	SAVE_GRAD_MAG_FILE,	DIR_OUT=!DIR_BROWSE,/ADD_COAST,/ADD_LAND,/ADDDATE,/ADD_COLORBAR,OVERWRITE=OVERWRITE

			DATA_UNITS = 'Azimuth '+ UNITS('DEG')
 			STRUCT_SD_WRITE,SAVE_GRAD_DIR_FILE, IMAGE=GRAD_DIR,PROD='GRAD_DIR',INFILE=AFILE,NOTES=PROCESSING,DATA_UNITS=DATA_UNITS,ERROR=ERROR
			STRUCT_SD_2PNG,	SAVE_GRAD_DIR_FILE,	DIR_OUT=!DIR_BROWSE,/ADD_COAST,/ADD_LAND,/ADDDATE,USE_PROD='DEG',PAL='PAL_NESW',OVERWRITE=OVERWRITE

;			===> Read the png just made and Add a compass
			PNG_GRAD_DIR_FILE = !DIR_BROWSE+	FN.FIRST_NAME+FILE_LABEL_EDGE+name_extra+'-GRAD_DIR.PNG'
			IMAGE = READ_PNG(PNG_GRAD_DIR_FILE,R,G,B)
;			===> Make a Gradient Direction color legend
	  	ZWIN, [150,150] & FONTS,'TIMES' & ERASE,252 & COLOR_CIRCLE ,LABELS_COMPASS,CHARSIZE=3 & LEG=TVRD() & ZWIN

;			===> Standard NARR Maps:
			IF MAP EQ 'NEC' THEN IMAGE(30,860) = LEG
			WRITE_PNG,PNG_GRAD_DIR_FILE,IMAGE,R,G,B


;    	*********************************************************************
;    	*** Make a PostScript Plot of the GRAD_MAG and Direction Frequencies  ***
;    	*********************************************************************
     	PSPRINT,FILENAME=PS_HIST_FILE,/COLOR,/FULL
     	PAL_36

;    	===> PLOT THE HISTOGRAM OF THE GRAD_MAG FREQUENCIES
;    	===> Bin size and min starting point for histogram
     	BIN_HIST_GRAD_MAG = 0.25 & MIN_HIST_GRAD_MAG = 0.0


;    	===> Find the good (finite) data
     	OK_GRAD_MAG=WHERE(FINITE(GRAD_MAG) AND GRAD_MAG NE MISSINGS(GRAD_MAG),COUNT_GRAD_MAG)
;			/////////////////////////////////////////////////////////////////////////////////////

;    	===> Histogram of edges
     	H = HISTOGRAM(GRAD_MAG(OK_GRAD_MAG),MIN=MIN_HIST_GRAD_MAG,BIN=BIN_HIST_GRAD_MAG)

;    	===> Make an xaxis array matching the Histogram result (H)
     	X = FINDGEN(N_ELEMENTS(H)) * BIN_HIST_GRAD_MAG

;    	===> Set up a panel plot 1 by 2
     	!p.multi=[0,2,2]

     	TITLE = FN.NAME+'   '+PROCESSING
     	PLOT,H, /XLOG,       /XSTYLE,/YSTYLE,XRANGE=[0.9,MAX(X)], XMARGIN=[5,5],YMARGIN=[2,2],XTITLE='Gradient Magnitude',YTITLE='Frequency',/NODATA

     	XYOUTS, 0.5,!Y.WINDOW[1]+0.02, TITLE,CHARSIZE=1.0,/NORMAL,ALIGN=0.5

     	GRIDS,COLOR=34
     	OPLOT,H,COLOR=6,THICK=1,PSYM=1,SYMSIZE=0.2
     	PLOT,H, /XLOG,/YLOG, /XSTYLE,/YSTYLE,XRANGE=[0.9,MAX(X)], XMARGIN=[5,5],YMARGIN=[2,2],XTITLE='Gradient Magnitude',YTITLE='Frequency',/NODATA
     	GRIDS,COLOR=34
			OPLOT,H,COLOR=6,THICK=1,PSYM=1,SYMSIZE=0.2



;    	===> Find the good (finite) data
     	OK_GRAD_DIR=WHERE(FINITE(GRAD_DIR) AND GRAD_DIR NE MISSINGS(GRAD_DIR),COUNT_GRAD_DIR)
;			/////////////////////////////////////////////////////////////////////////////////////

			BIN_HIST_GRAD_DIR = 1
;    	===> Histogram of gradient direction
     	H = HISTOGRAM(GRAD_DIR(OK_GRAD_DIR),MIN=0,max=359.9999,BIN=BIN_HIST_GRAD_DIR)

;    	===> Make an xaxis array matching the Histogram result (H)
     	X = FINDGEN(N_ELEMENTS(H)) * BIN_HIST_GRAD_DIR



     	PLOT,H,         /XSTYLE,/YSTYLE,XRANGE=[0.9,MAX(X)], XMARGIN=[5,5],YMARGIN=[3,3],XTITLE='Gradient Direction Degrees',YTITLE='Frequency',/NODATA
     	GRIDS,COLOR=34
     	OPLOT,H,COLOR=6,THICK=1,PSYM=1,SYMSIZE=0.2
     	PLOT,H,  /YLOG, /XSTYLE,/YSTYLE,XRANGE=[0.9,MAX(X)], XMARGIN=[5,5],YMARGIN=[3,3],XTITLE='Gradient Direction Degrees',YTITLE='Frequency',/NODATA
     	GRIDS,COLOR=34
			OPLOT,H,COLOR=6,THICK=1,PSYM=1,SYMSIZE=0.2


     	PSPRINT ; Close the PostScript Device
;			///////////////////////////////////////////////


  	ENDFOR ; FOR _EDGE_DETECTOR = 0,N_ELEMENTS(EDGE_DETECTORS)-1 DO BEGIN
	ENDFOR ; FOR _files = 0L, N_FILES-1 DO BEGIN



  END; #####################  End of Routine ################################
