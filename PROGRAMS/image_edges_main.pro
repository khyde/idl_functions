; $ID:	IMAGE_EDGES_MAIN.PRO,	2020-06-30-17,	USER-KJWH	$

  PRO IMAGE_EDGES_MAIN
;
; NAME:
;      IMAGE_EDGES_MAIN
;
; PURPOSE:
;         This procedure is a MAIN routine for running IMAGE_EDGES
;
; CATEGORY:
;          Edge Detection
;
; CALLING SEQUENCE:
;                  IMAGE_EDGES_MAIN
;
; INPUTS:
;        None
;
; KEYWORD PARAMETERS:
;                    None
;
; OUTPUTS:
;         Outputs from IMAGE_EDGES
;
; OPTIONAL OUTPUTS:
;
; RESTRICTIONS:
;  Assumes that the input files are the NOAA, Narragansett Standard Satellite Image Save files'
;
; PROCEDURE:
;
; EXAMPLE:
;
; NOTES:
;
; MODIFICATION HISTORY:
;		Written Jan 17, 2007 by J.O'Reilly (NOAA)
;
; ****************************************************************************************************
  ROUTINE_NAME = 'IMAGE_EDGES_MAIN'

; ****************************************
; *** P R O G R A M   D E F A U L T S  ***
; ****************************************
  ERROR = ''

; **************************************************************************************
; ** USER EDITED PARAMETERS FOR THE WORKING FOLDERS AND SUBFOLDERS FOR THIS PROJECT  ***
; **************************************************************************************
  DISK = 'C:'

  COMPUTER=GET_COMPUTER()
	PRINT, COMPUTER


  IF COMPUTER EQ 'BELKIN2' THEN DISK = 'C:'
  IF COMPUTER EQ 'LOLIGO' or COMPUTER EQ 'LAPSANG' THEN DISK = 'D:'
  DELIM= PATH_SEP()



; ***************************************************************
; *** Create the project folders if they do not already exist ***
; ***************************************************************
	PROJECT = 'EDGES'
  FOLDERS = ['FILES','DATA','DOC','BROWSE','PLOTS','SAVE']

  FILE_PROJECT, DISK=DISK, PROJECT=PROJECT, FOLDERS=FOLDERS
; ===> Now there should be the right subfolders in PROJECT
; and the subfolders (paths) are subsequently referered to as;
; !DIR_BROWSE,  !DIR_DATA,   !DIR_DOC,   !DIR_PLOTS,  !DIR_SAVE

	MAP = 'NEC'


;	**********************************
;	*** Get Landmask for this MAP ****
;	**********************************
 	IF MAP EQ 'NEC' THEN BEGIN
 		LANDMASK_FILE = DISK+'\IDL\IMAGES\MASK_LAND-NEC-PXY_1024_1024.PNG'
  ENDIF


; ********************************************************************************
; ***** U S E R    S W I T C H E S  Controlling which Processing STEPS to do *****
; ********************************************************************************
; 0 (Do not do the step)
; 1 (Do the step)
; 2 (Do the step and OVERWRITE any output if it alread exists)

; ===> Switches controlling which Processing STEPS to do

	DO_IMAGE_FILTER 			= 0

	DO_CANNY_SENSITIVITY 	= 0

	DO_MEDIAN_PREFILTER_TEST_SIMPLE = 0
	DO_MEDIAN_PREFILTER_STANDARD_IMAGES = 0

	DO_MEDIAN_PREFILTER   = 0


  DO_IMAGE_EDGES 				= 2

  DO_NEXT_STEP 					= 0


; **************************************************************
  IF DO_IMAGE_FILTER GE 1 THEN BEGIN
; **************************************************************
    OVERWRITE = DO_IMAGE_FILTER GE 2
    PRINT, 'S T E P:    DO_IMAGE_FILTER'
;   ===> Get the files to process

;	  TYPE = 'PNG'
 	  TYPE = 'SAVE'
;		TYPE = 'GIF'

    FILES=FILE_SEARCH(!DIR_FILES+'*.'+TYPE)

    WIDTH  = [5,7,9,11,13]
    FILTER = ['RAW','GAUSSIAN','TRICUBE','MEDIAN','MEDIAN_FILL']
    SIGMA = .5
    WIDTH =  5

		FILTER = 'MEDIAN'
		FILTER = 'GAUSSIAN'
		FILTER =  'MEDIAN_IGOR'



;	   NEXT RUN WITH SIGMA 1.5  ETC AND WITH FILTER = 'GAUSSIAN
;		 JUST UNCOMMENT NEXT LINE

;		SIGMA = 1.25 & FILTER = 'GAUSSIAN'

 		IMAGE_FILTER,  Files,  FILTER = filter,  WIDTH=WIDTH, SIGMA=sigma, LANDMASK_FILE=landmask_file, OVERWRITE=overwrite, ERROR = error

  ENDIF ; IF DO_IMAGE_FILTER GE 1 THEN BEGIN
; |||||||||||||||||||||||||||||||||||||||||||||||||


; **************************************************************
  IF DO_CANNY_SENSITIVITY GE 1 THEN BEGIN
; **************************************************************
    OVERWRITE = DO_CANNY_SENSITIVITY GE 2
    PRINT, 'S T E P:    DO_CANNY_SENSITIVITY'
;   ===> Get the files to process
 	  TYPE = 'SAVE'
    FILES=FILE_SEARCH(!DIR_FILES+'*.'+TYPE)
    FILTER = 'CANNY'
		FI=FILE_PARSE(FILES)

;		===> Sensitivity run
 		SIGMA_ARRAY = [0.2, 1.0, 2.0, 3.0, 4.0]
    FOR i=0,4,1 DO BEGIN
      SIGMA=SIGMA_ARRAY(i)
      FOR LOW  = 0.0, 0.75, 0.1 DO BEGIN
  			FOR DIFF = 0.2, (0.95-LOW), 0.1	DO BEGIN
        	HIGH = LOW + DIFF
        	IMAGE_EDGES,FILES,FILTER=FILTER,LOW=low,HIGH=high,SIGMA=sigma,LANDMASK_FILE=landmask_file, OVERWRITE=overwrite
		 		ENDFOR
			ENDFOR
		ENDFOR
  ENDIF ; IF DO_CANNY_SENSITIVITY GE 1 THEN BEGIN
; |||||||||||||||||||||||||||||||||||||||||||||||||



;	***********************************************
	IF DO_MEDIAN_PREFILTER_TEST_SIMPLE GE 1 THEN BEGIN
;	************************************************

		FOR TYPE = 0,1 DO BEGIN

			FOR NTH = 0,6 DO BEGIN

				DATA = REPLICATE(0.,9,9)
				DATA(2,4)=0.8
				DATA(3,4)=2
				DATA(4,4)=3.1
				DATA(5,4)=2
				DATA(6,4)=0.84
				DATA(7,4)= -.3

				IF NTH EQ 1 THEN BEGIN
					DATA = REPLICATE(0.,9,9)
					DATA(4,2)=0.8
					DATA(4,3)=2
					DATA(4,4)=3.1
					DATA(4,5)=2
					DATA(4,6)=0.84
					DATA(4,7)= -.3
				ENDIF

	  		IF NTH EQ 2 THEN BEGIN
	  			DATA = REPLICATE(0.,9,9)
					DATA(2,2)=0.8
					DATA(3,3)=2
					DATA(4,4)=3.1
					DATA(5,5)=2
					DATA(6,6)=0.84
					DATA(7,7)= -.3
	  		ENDIF

				IF NTH EQ 3 THEN BEGIN
	  			DATA = REPLICATE(0.,9,9)
					DATA(6,2)=0.8
					DATA(5,3)=2
					DATA(4,4)=3.1
					DATA(3,5)=2
					DATA(2,6)=0.84
					DATA(1,7)= -.3
	  		ENDIF

	  		IF NTH EQ 4 THEN BEGIN
	  			DATA = REPLICATE(0.,9,9)
	  			DATA(2,4)=0.8
					DATA(3,4)=2
					DATA(4,4)=3.1
					DATA(5,4)=2
					DATA(6,4)=0.84
					DATA(7,4)= -.3

				  DATA(2,2)=0.8
					DATA(3,3)=2
					DATA(4,4)=3.1
					DATA(5,5)=2
					DATA(6,6)=0.84
					DATA(7,7)= -.3
	  		ENDIF

				IF NTH EQ 5 THEN BEGIN
	  		 DATA = REPLICATE(0.,9,9)
	  			DATA(2,4)=0.8
					DATA(3,4)=2
					DATA(4,4)=3.1
					DATA(5,4)=2
					DATA(6,4)=0.84
					DATA(7,4)= -.3

					DATA(4,2)=0.8
					DATA(4,3)=2
					DATA(4,4)=3.1
					DATA(4,5)=2
					DATA(4,6)=0.84
					DATA(4,7)= -.3

				 	DATA(2,2)=0.8
					DATA(3,3)=2
					DATA(4,4)=3.1
					DATA(5,5)=2
					DATA(6,6)=0.84
					DATA(7,7)= -.3

	  		ENDIF

				IF NTH EQ 6 THEN BEGIN
	  		 DATA = REPLICATE(0.,9,9)
	  			DATA(2,4)=0.8
					DATA(3,4)=2
					DATA(4,4)=3.1
					DATA(5,4)=2
					DATA(6,4)=0.84
					DATA(7,4)= -.3

					DATA(4,2)=0.8
					DATA(4,3)=2
					DATA(4,4)=3.1
					DATA(4,5)=2
					DATA(4,6)=0.84
					DATA(4,7)= -.3

				 	DATA(2,2)=0.8
					DATA(3,3)=2
					DATA(4,4)=3.1
					DATA(5,5)=2
					DATA(6,6)=0.84
					DATA(7,7)= -.3

					DATA(6,2)=0.8
					DATA(5,3)=2
					DATA(4,4)=3.1
					DATA(3,5)=2
					DATA(2,6)=0.84
					DATA(1,7)= -.3
	  		ENDIF

			IF TYPE EQ 1 THEN DATA = 10 - DATA ; VALLEY NOT PEAK

			TIMER
			MED = MF3_1D_5PT(DATA, DELTA=delta, ITER=iter, P5_MAX=p5_max, P5_MIN=p5_min, P3_MIN=P3_MIN,P3_MAX=P3_MAX, ERROR = error)
			TIMER,/STOP

			PRINT, DATA
			PRINT
			PRINT, P3_MIN
			PRINT, TOTAL(P3_MIN)
			PRINT
			PRINT, P3_MAX
			PRINT, TOTAL(P3_MAX)
			PRINT
			PRINT, P5_MIN
			PRINT, TOTAL(P5_MIN)
			PRINT
			PRINT, P5_MAX
			PRINT, TOTAL(P5_MAX)

			STOP
			ENDFOR
		ENDFOR
		STOP
	ENDIF
;	\\\\\\\\\

;	***********************************************
	IF DO_MEDIAN_PREFILTER_STANDARD_IMAGES GE 1 THEN BEGIN
;	************************************************
		FILES=FILE_SEARCH(!DIR_DATA+'*.dat')

		PX=600
		PY=480
	 	EPSILON = 1

;		LLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLL
		FOR NTH=0,N_ELEMENTS(FILES)-1 DO BEGIN
		 	afile=FILES[NTH]

			DATA = READ_BINARY(AFILE,DATA_TYPE=4, DATA_DIMS=[600,480] )
			data=TRANSPOSE(data)
			DATA=ROTATE(DATA,7)


		 	FN=FILE_PARSE(AFILE)

			TIMER
			MED = MF3_1D_5PT(DATA, EPSILON=EPSILON, ITER=iter, P5_MAX=p5_max, P5_MIN=p5_min, P3_MIN=P3_MIN,P3_MAX=P3_MAX, ERROR = error)
			TIMER,/STOP


			LOADCT,34 & SLIDEW, bytscl(DATA)	,TITLE='DATA'
			LOADCT,34 & SLIDEW, bytscl(MED)	,TITLE='MED'
			PNG_DATA=!DIR_BROWSE+FN.FIRST_NAME+'-DATA.PNG'
			PNG_MED=!DIR_BROWSE+FN.FIRST_NAME+'-MED.PNG'
			TVLCT,R,G,B,/GET
			WRITE_PNG,PNG_DATA, BYTSCL(DATA),R,G,B
			WRITE_PNG,PNG_MED, BYTSCL(MED),R,G,B
		ENDFOR

	ENDIF
;	\\\\\\\\\

;	**************************************
	IF DO_MEDIAN_PREFILTER GE 1 THEN BEGIN
;	**************************************

	FILE = 'D:\PROJECTS\EDGES\FILES\!T_200105030701-AVHRR-N16-S3-CW_CD-NEC-SST.SAVE'
	PROD = 'SST'
	DATA = STRUCT_SD_READ(FILE)

 ;	TIMER
	MED = MF3_1D_5PT(DATA, EPSILON=EPSILON, ITER=iter, P5_MAX=p5_max, P5_MIN=p5_min, P3_MIN=P3_MIN,P3_MAX=P3_MAX, ERROR = error)
;	TIMER,/STOP

STOP

	FN=FILE_PARSE(FILE)

;	===> Make a png image of the INPUT IMAGE
	IMAGE = SD_SCALES(DATA,PROD=PROD,/DATA2BIN)
	LEG 	= COLOR_BAR_SCALE(PROD=PROD,PX=500,CHARSIZE=1.25,/CUT,BACKGROUND=254)
	IMAGE(5,900) = LEG
	PAL_SW3,R,G,B
	PNGFILE = !DIR_BROWSE+FN.FIRST_NAME+'.PNG'
	WRITE_PNG,PNGFILE,IMAGE,R,G,B


;	===> Make a png image of the MEDIAN IMAGE
	IMAGE = SD_SCALES(MED,PROD=PROD,/DATA2BIN)
	LEG 	= COLOR_BAR_SCALE(PROD=PROD,PX=500,CHARSIZE=1.25,/CUT,BACKGROUND=254)
	IMAGE(5,900) = LEG
	PAL_SW3,R,G,B
	PNGFILE = !DIR_BROWSE+FN.FIRST_NAME+'-MF3_1D_5PT.PNG'
	WRITE_PNG,PNGFILE,IMAGE,R,G,B

;	===> Make a png image of the Difference between the original and the MEDIAN IMAGE

	IMAGE = SD_SCALES( (DATA-MED), PROD='DIF_5',/DATA2BIN)
	OK=WHERE(DATA EQ MED,COUNT)
	IF COUNT GE 1 THEN IMAGE[OK]=254
	LEG 	= COLOR_BAR_SCALE(PROD='DIF_3',TITLE='Original-Median '+UNITS(PROD),PX=500,CHARSIZE=1.25,/CUT,BACKGROUND=254)
	IMAGE(5,900) = LEG
	PAL_ANOM,R,G,B

	PNGFILE = !DIR_BROWSE+FN.FIRST_NAME+'-ORIG-MEDFILTER.PNG'
	WRITE_PNG,PNGFILE,IMAGE,R,G,B


;	===> Make a png image of the Peak
	LEG = COLOR_BAR_SCALE(PROD='NUM2',TITLE='Valley=1, Peak=2',PX=500,CHARSIZE=1.25,/CUT,BACKGROUND=254)
	IMAGE= P5_MIN
	OK=WHERE(P5_MAX  EQ 1,COUNT)
	IF COUNT GE 1 THEN IMAGE[OK] = 2
	IMAGE = BYTE(SCALE(P5_MAX,[0,250],MIN=0,MAX=2))
  IMAGE(5,900) = LEG
  PAL_SW3,R,G,B
	PNGFILE = !DIR_BROWSE+FN.FIRST_NAME+'-PEAK_VALLEY.PNG'
	WRITE_PNG,PNGFILE,IMAGE,R,G,B



;	===> Make a png image of the PMAX
	LEG = COLOR_BAR_SCALE(PROD='NUM8',TITLE='PMIN',PX=500,CHARSIZE=1.25,/CUT,BACKGROUND=254)
	IMAGE = BYTE(SCALE(P3_MIN,[0,250],MIN=0,MAX=8))
	IMAGE(5,900) = LEG
	PAL_SW3,R,G,B
	PNGFILE = !DIR_BROWSE+FN.FIRST_NAME+'-P3_MIN.PNG'
	WRITE_PNG,PNGFILE,IMAGE,R,G,B

;	===> Make a png image of the PMIN
	LEG = COLOR_BAR_SCALE(PROD='NUM8',TITLE='PMAX',PX=500,CHARSIZE=1.25,/CUT,BACKGROUND=254)
	IMAGE = BYTE(SCALE(P3_MAX,[0,250],MIN=0,MAX=8))
	IMAGE(5,900) = LEG
	PAL_SW3,R,G,B
 	PNGFILE = !DIR_BROWSE+FN.FIRST_NAME+'-P3_MAX.PNG'
	WRITE_PNG,PNGFILE,IMAGE,R,G,B

	ENDIF
; ||||||||

; **************************************************************
  IF DO_IMAGE_EDGES GE 1 THEN BEGIN
; **************************************************************
    OVERWRITE = DO_IMAGE_EDGES GE 2
    PRINT, 'S T E P:    DO_IMAGE_EDGES'
;   ===> Get the files to process


 	  TYPE = 'SAVE'

    FILES=FILE_SEARCH(!DIR_FILES+'*.'+TYPE)

;   EDGE_DETECTOR = 'CANNY'
 		CANNY_LOW = 0.4
 		CANNY_HIGH = 0.8
 		CANNY_SIGMA=0.6


;		%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
;		%%% Narragansett Processing %%%
;		%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		DO_FILTER   = 1
		FILTER_NAME = 'MF3_1D_5PT'
		DO_GAUSSIAN_SMOOTH = 1
		GAUSSIAN_WIDTH	= 5
		GAUSSIAN_SIGMA	= 0.6
		EDGE_DETECTOR = 'SOBEL'
;		%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

;	  EDGE_DETECTOR = 'CANNY'

STOP

		IMAGE_EDGES,Files, DO_FILTER=do_filter, FILTER_NAME=filter_name, $   ; FILTER STEP 1

  					DO_GAUSSIAN_SMOOTH=DO_GAUSSIAN_SMOOTH, GAUSSIAN_WIDTH=gaussian_width,GAUSSIAN_SIGMA=gaussian_sigma, $ ; SMOOTHING STEP 2

  					EDGE_DETECTOR= edge_detector,  $

;						SPECIAL KEYWORDS FOR CANNY
  					CANNY_SMOOTH=CANNY_SMOOTH,CANNY_SIGMA=CANNY_SIGMA, CANNY_LOW=CANNY_LOW,CANNY_HIGH=CANNY_HIGH, $

  					OVERWRITE=overwrite, ERROR = error
;

  ENDIF ; IF DO_IMAGE_EDGES GE 1 THEN BEGIN
; |||||||||||||||||||||||||||||||||||||||||||||||||




; **************************************************************
  IF DO_NEXT_STEP GE 1 THEN BEGIN
; **************************************************************
    OVERWRITE = DO_NEXT_STEP GE 2
    PRINT, 'S T E P:    DO_NEXT_STEP'

  ENDIF ; IF DO_NEXT_STEP GE 1 THEN BEGIN
; |||||||||||||||||||||||||||||||||||||||||||||||||

END; #####################  End of Routine ################################
