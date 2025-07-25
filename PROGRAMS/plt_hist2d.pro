; $ID:	PLT_HIST2D.PRO,	2020-07-08-15,	USER-KJWH	$

;###################################################################################################
	PRO PLT_HIST2D, X,	Y,$;  X,Y ARRAYS ARE THE ONLY REQUIRED INPUTS  
	                       ;  EVERYTHING ELSE IS OPTIONAL.
	          
	           
;################ PLOT WINDOW SETUP
CURRENT=CURRENT,$                    ; ADD PLOT TO CURRENT WINDOW
DEVICE=DEVICE,$                      ; USE DEVICE COORDINATES
NORMAL=NORMAL,$                      ; USE NORMAL COORDINATES
DATA=DATA,$                          ; USE DATA COORDINATES
LAYOUT=LAYOUT,$                      ; PLOT LAYOUT
PLT_DIMS=PLT_DIMS,$                  ; PLOT DIMENSIONS
POSITION=POSITION,$                  ; POSITION OF THE PLOT IN THE WINDOW
 
;############## OUTPUT
FILE=FILE,$                          ; FULL NAME OF THE OUTPUT FILE
DELAY=DELAY,$                        ; SECONDS TO DELAY CLOSING PLOT WINDOW
VERBOSE=VERBOSE,$                    ; PRINT PROGRAM STATUS
BUFFER=BUFFER,$                      ; DRAW THE PLOT IN THE BUFFER INSTEAD OF THE SCREEN
BORDER=BORDER,$                      ; [SEE SAVE METHOD]
BIT_DEPTH=BIT_DEPTH,$                ; [SEE SAVE METHOD]
MARGIN=MARGIN,$                      ; [SEE PLOT FUNCTION]
OBJ=OBJ,$                            ; TO GET THE PLOT OBJECT
IMAGE = IMAGE,$                      ; (THE JOINT FREQUENCY ARRAY FROM HIST2D)
DATE_ADD=DATE_ADD,$                  ; ADD A DATE TIMESTAMP IN THE LOWER RIGHT CORNER OF THE PLOT
           
;############## AXES SETUP
XLOG=XLOG,$                          ; FOR A LOG10(X) REGRESSION AND  STATISTICS
YLOG=YLOG,$                          ; FOR A LOG10(Y) REGRESSION AND  STATISTICS
AXES_COLOR=AXES_COLOR,$              ; COLOR OF MAIN PLOT AXES
AXES_THICK=AXES_THICK,$              ; THICKNESS OF MAIN AXES
AXES_FONT_SIZE=AXES_FONT_SIZE,$      ; SIZE OF THE AXES FONT
ASPECT_RATIO=ASPECT_RATIO,$          ; RATIO OF Y PLOT DIMENSIONS TO X PLOT DIMENSION

;################ TITLES    #####
TITLE=TITLE,$                        ; PLOT TITLE
XTITLE=XTITLE,$                      ; X-AXIS TITLE
YTITLE=YTITLE,$                      ; Y-AXIS TITLE
    
;############### PLOT BACKGROUND  #####
BACKGROUND_COLOR=BACKGROUND_COLOR,$  ; PLOT BACKGROUND COLOR
                     

;############## PASSED TO STATS2.PRO
MODEL=MODEL,$                        ; REGRESSION MODEL
PARAMS=PARAMS,$                      ; PASSED TO STATS2.PRO
DECIMALS=DECIMALS,$                  ; PASSED TO STATS2.PRO
            
;############## MISSING DATA AND OUTLIERS
MISSINGX=MISSINGX,$                  ; MISSING VALUE FOR X
MISSINGY=MISSINGY,$                  ; MISSING VALUE FOR Y
OUTLIERS=OUTLIERS,$                  ; VALUES TO REMOVE FROM REGRESSION

;############## STATISTICS LEGEND PLT_STRUCT
STATS_ADD=STATS_ADD,$                ; DO PLOT THE REGRESSION LEGEND RESULTS
STATS_POS=STATS_POS,$                ; POSITION FOR STATS LEGEND (DATA UNITS,X,Y)
STATS_COLOR=STATS_COLOR,$            ; STATS LEGEND COLOR
STATS_SIZE=STATS_SIZE,$              ; STATS LEGEND TEXT SIZE
STATS_ALIGN=STATS_ALIGN,$            ; ALIGNMENT FOR THE STATS LEGEND
DOUBLE_SPACE=DOUBLE_SPACE,$          ; DOUBLE LINE SPACES BETWEEN STAT LEGEND OUTPUT

;############## REGRESSION LINE:  PLT_SLOPE
REG_ADD=REG_ADD,$                    ; ADD THE REGRESSION
REG_COLOR=REG_COLOR,$                ; COLOR OF THE REGRESSION LINE
REG_THICK=REG_THICK,$                ; THICKNESS OF THE REGRESSION LINE
REG_LINESTYLE=REG_LINESTYLE,$        ; LINESTYLE OF THE REGRESSION LINE
REG_MID_COLOR=REG_MID_COLOR,$        ; COLOR OF THE OVERPLOTTING REGRESSION LINE
REG_MID_THICK=REG_MID_THICK,$        ; THICKNESS OF THE OVERPLOTTING REGRESSION LINE
REG_MID_LINESTYLE=REG_MID_LINESTYLE,$; LINESTYLE OF THE OVERPLOTTING REGRESSION LINE

;################ ONE2ONE LINE  #####  PLT_ONE2ONE
ONE_ADD=ONE_ADD,$                    ; ADD A ONE2ONE LINE
ONE_COLOR=ONE_COLOR,$                ; COLOR OF THE ONE2ONE LINE
ONE_THICK=ONE_THICK,$                ; THICKNESS OF THE ONE2ONE LINE
ONE_LINESTYLE=ONE_LINESTYLE,$        ; LINESTYLE OF THE ONE2ONE LINE


;############## PLOT MEAN X,Y:   PLT_MEAN
MEAN_ADD=MEAN_ADD,$                  ; ADD A SYMBOL AT THE MEAN X,Y
MEAN_SYMBOL=MEAN_SYMBOL,$            ; SYMBOL TO USE FOR THE MEAN
MEAN_SIZE=MEAN_SIZE,$                ; SIZE OF THE MEAN SYMBOL
MEAN_COLOR=MEAN_COLOR,$              ; COLOR OF THE MEAN SYMBOL
MEAN_THICK=MEAN_THICK,$              ; THICKNESS OF THE MEAN SYMBOL


;################    GRID #####  PLT_GRIDS
GRID_ADD=GRID_ADD,$                  ; ADD A GRID
GRID_COLOR=GRID_COLOR,$              ; COLOR OF THE GRID
GRID_THICK=GRID_THICK,$              ; THICKNESS OF THE GRID
GRID_LINESTYLE=GRID_LINESTYLE,$      ; LINESTYLE OF THE GRID
            
;################ COLORBAR ##### PRODS_COLORBAR
CB_ADD  = CB_ADD ,$                  ; ADD A COLORBAR
CB_FONT  = CB_FONT,$                 ; COLORBAR FONT
CB_COLOR = CB_COLOR,$                ; COLOR OF THE BORDER AND TICKMARKS OF THE COLORBAR
CB_SIZE  = CB_SIZE,$                 ; FONT SIZE FOR THE COLORBAR
CB_POSITION = CB_POSITION,$          ; COLORBAR POSITION E.G.[0.30,0.865,0.70,0.875]
CB_COMMA = CB_COMMA,$                ; ADD COMMAS TO COLORBAR TICKNAMES
CB_TITLE = CB_TITLE,$                ; COLORBAR TITLE
PAL=PAL,$                            ; PALETTE PROGRAM NAME FOR THE COLORBAR [DEFAULT=PAL_FREQ]

;################ HIST2D PARAMETERS ##### (SEE IDL HELP FOR HIST2D ROUTINE)
SAMPLE = SAMPLE,$                    ; SUBSAMPLE THE X,Y, DATA
MIN_X=MIN_X,$                        ;  THE MINIMUM X VALUE TO CONSIDER.[DEFAULT = MIN(NICE_RANGE) 
MAX_X=MAX_X,$                        ;  THE MAXIMUM X VALUE TO CONSIDER.[DEFAULT = MIN(NICE_RANGE) 
MIN_Y=MIN_Y,$                        ;  THE MINIMUM Y VALUE TO CONSIDER.[DEFAULT = MIN(NICE_RANGE)   
MAX_Y=MAX_Y,$                        ;  THE MAXIMUM Y VALUE TO CONSIDER.[DEFAULT = MIN(NICE_RANGE)  
BIN_X=BIN_X,$                        ;  THE X BIN SIZE TO USE.(SEE IDL HELP FOR HIST2D ROUTINE
BIN_Y=BIN_Y,$                        ;  THE Y BIN SIZE TO USE.(SEE IDL HELP FOR HIST2D ROUTINE
PERCENT=PERCENT,$                    ; EXPRESS THE JOINT FREQUENCY AS A PERCENT OF THE TOTAL  
LOG_FREQ=LOG_FREQ,$                  ; DISPLAY THE HISTOGRAM AND COLOR BAR AS THE LOG OF THE FREQUENCY
SMO=SMO,$                            ; SMOOTHING FACTOR TO APPLY TO THE FREQUENCY HISTOGRAM (SMO = 8 IS USUALLY GOOD)
ISOTROPIC=ISOTROPIC,$                ; FORCE THE SCALING OF THE X AND Y AXES TO BE EQUAL 
VERTICAL= VERTICAL,$                 ; VERTICAL COLORBAR
HORIZONTAL= HORIZONTAL,$             ; HORIZONTAL COLORBAR
ZERO_COLOR=ZERO_COLOR,$              ; COLOR FOR ZERO FREQUENCIES
BKG_COLOR=BKG_COLOR,$                ; COLOR FOR HIST BACKGROUND
MIN_COLOR=MIN_COLOR,$                ; MINIMUM COLOR USED IN SCALING FREQ TO BYTES
MAX_COLOR=MAX_COLOR,$                ; MAXIMUM COLOR USED IN SCALING FREQ TO BYTES
;LAB_TXT=LAB_TXT,$                   ; RESERVED FOR FUTURE
STATS_PARAMS=STATS_PARAMS,$          ; PASSED TO STATS2.PRO
FAST=FAST                            ; PASSED TO STATS2.PRO


;+
; NAME:
;       PLT_HIST2D
;
; PURPOSE:
;       THIS PROGRAM PLOTS A 2-DIMENSIONAL FREQUENCY DENSITY PLOT OF TWO VARIABLES,
;				AND OPTIONALLY THE LINEAR REGRESSION LINE, A COLOR BAR, AND REGRESSION STATISTICS
;
; CATEGORY:
;       PLT FAMILY
;
; CALLING SEQUENCE:
;       RESULT = PLT_HIST2D(X,Y)
;
; INPUTS:
;     	X:  X DATA ARRAY
;   		Y:  Y DATA ARRAY
;
; KEYWORD PARAMETERS: [### SEE ABOVE NOTES ADJACENT TO EACH KEYWORD]

; EXAMPLES:
;   X=RANDOMN(SEED,256L*256) & Y=RANDOMN(SEED,256L*256)+2*X & PLT_HIST2D,X,Y,DELAY = 7
;		X=RANDOMN(SEED,256L*256) & Y=RANDOMN(SEED,256L*256)+1.7*X & PLT_HIST2D,X,Y,PAL='PAL_SW3',/ONE_ADD,ONE_COLOR=255,DELAY = 6
;		ALSO SEE: PLT_HIST2D_DEMO.PRO
;
;
; RESTRICTIONS:
;		NOTE THAT HIST_2DJ  IS CALLED NOT IDL'S HIST_2D (SEE EXPLANATION IN HIST_2DJ)
;   SOME OF THE [OVER 90] KEYWORDS HAVE NOT BEEN TESTED
; OUTPUTS:
;       DISPLAYS A HIST2D PLOT IN THE GRAPHICS WINDOW,
;       OPTIONALL WRITES A PNG IMAGE FILE
;
;
; NOTES:
;		
;   TO CREATE A LOGLOG STYLE PLOT, ALL INPUTS (X,Y,BIN_X,MIN_X,MAX_X, ETC.) 
;   MUST BE IN LOGGED UNITS.  
;   THE XLOG AND YLOG KEYWORDS WILL CREATE LOG SCALE AXES
;
; MODIFICATION HISTORY:
;		WRITTEN FEB 6,2001 BY J.O'REILLY, 28 TARZWELL DRIVE, NMFS, NOAA 02882 (JAY.O'REILLY@NOAA.GOV)
;   PROGRAM LOGIC FOR SCALING IMAGES FOLLOWS IMG_CONT.PRO (RSI).
; 	AUG 6, 2004 JOR TD MAKE COLORBAR SMALLER,TAKE OUT MULTI LOGIC
;		NOV 2006 JOR NOW USING CONGRID INSTEAD OF REBIN WHEN SMOOTHING IS SPECIFIED
;		AUG 30,2012,JOR ADDED KEYWORD SAMPLE
;		
;		APR 24,2014,JOR COPIED PORTIONS FROM PLOT_HIST2D,RENAMED TO PLT_HIST2D,
;		            AND UPDATED TO USE NEW IDL FUNCTIONS 
;   APR 26,2014,JOR XSCALE & YSCALE MODIFIED FROM KIM HYDE'S PLOT_HIST2D_NG
;   MAY 1,2014,JOR  EXTENSIVE REVISIONS
;   MAY 2,2014,JOR ADDED MANY MORE KEYWORDS
;   MAY 3,2014,JOR FINALLY GOT IT TO WORK CORRECTLY USING IDL'S NEW GRAPHICS FUNCTIONS
;###################################################################################################
;-
;*************************
ROUTINE_NAME ='PLT_HIST2D'
;*************************

 ;#####   DEFAULTS   #####
IF NONE(PAL) THEN PAL='PAL_FREQ'  & RGB_TABLE = RGBS([0,255],PAL=PAL)
;===> DEFAULT PROD
IF NONE(PROD) THEN PROD = 'FREQ'

  XF = FLOAT(X)
  YF = FLOAT(Y)
 
;===> PLOT COLORS,BACKGROUND & TITLES DEFAULT
IF NONE(BACKGROUND_COLOR) THEN BACKGROUND_COLOR = 'WHITE'
;IF NONE(TITLE)  THEN TITLE = ROUTINE_NAME
IF NONE(TITLE)  THEN TITLE = ''
IF NONE(XTITLE) THEN XTITLE = 'X'
IF NONE(YTITLE) THEN YTITLE = 'Y'
;$ IF NONE(NOBAR) THEN NOBAR = 1
;|||||||||||||||||||||||||||||||||||||||||||

;===> AXES DEFAULTS
IF NONE(AXES_COLOR) THEN AXES_COLOR = 'BLACK'
IF NONE(AXES_FONT_SIZE) THEN AXES_FONT_SIZE = 16
IF NONE(AXES_THICK) THEN AXES_THICK = 1
IF NONE(ASPECT_RATIO) THEN ASPECT_RATIO = 0
;|||||||||||||||||||||||||||||||||||||||||||
;
;===> GRID DEFAULTS
IF NONE(GRID_ADD) THEN GRID_ADD= 0
IF NONE(GRID_COLOR) THEN GRID_COLOR= 'BLACK'
IF NONE(GRID_THICK) THEN GRID_THICK= 2
IF NONE(GRID_LINESTYLE) THEN GRID_LINESTYLE= 0
;|||||||||||||||||||||||||||||||||||||||||||
;
;===> COLORBAR DEFAULTS
IF NONE(CB_ADD)        THEN CB_ADD = 0
IF NONE(CB_FONT)       THEN CB_FONT = "HELVETICA"
IF NONE(CB_TITLE)      THEN CB_TITLE = "FREQ"
IF KEY(PERCENT)        THEN CB_TITLE = CB_TITLE+' %'
IF KEY(PERCENT)        THEN PROD = 'PERCENT'
IF NONE(CB_COLOR)      THEN CB_COLOR = 'BLACK'
IF NONE(CB_SIZE)       THEN CB_SIZE = 10  ;CB_SIZE
IF NONE(CB_POSITION)   THEN CB_POSITION = [0.30,0.865,0.70,0.875]
IF NONE(CB_COMMA)      THEN CB_COMMA = 1
IF NONE(CB_STYLE)      THEN CB_STYLE = 2
IF NONE(PAL)           THEN PAL='PAL_FREQ'  & RGB_TABLE = RGBS([0,255],PAL=PAL)
IF NONE(CB_POS) THEN CB_POS = 'T'; [=TOP] COLORBAR ABOVE IMAGE
;===> FORCE CB_POS TO BE EITHER 'T' OR 'B' [LEFT& RIGHT NOT WORKING YET]
IF CB_POS NE 'T' OR CB_POS NE 'B' THEN CB_POS = 'T'
;|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||

;===> FOR DISPLAY & PLT_WRITE
IF NONE(BUFFER) THEN BUFFER= 0
IF NONE(MARGIN) THEN MARGIN = [0,0.1,0,.15] ; FOR PLOT
IF NONE(BIT_DEPTH) THEN BIT_DEPTH= 0 ; TRUE COLOR
IF NONE(BORDER) THEN BORDER= 30
IF NONE(LAYOUT) THEN LAYOUT= 0
IF NONE(DELAY) THEN DELAY= 0
IF NONE(VERBOSE) THEN VERBOSE= 0
IF NONE(ISOTROPIC) THEN ISOTROPIC= 1 ; NOT WORKING IN NEW GRAPHICS
IF NONE(DATE_ADD) THEN DATE_ADD= 0
;|||||||||||||||||||||||||||||||||

;===> MEAN [X,Y] DEFAULTS
IF NONE(MEAN_ADD)       THEN MEAN_ADD= 0
IF NONE(MEAN_SYMBOL)     THEN MEAN_SYMBOL = '+'
IF NONE(MEAN_COLOR)      THEN MEAN_COLOR = 'GOLD'
IF NONE(MEAN_SIZE)       THEN MEAN_SIZE = 5
IF NONE(MEAN_THICK)      THEN MEAN_THICK = 5
;|||||||||||||||||||||||||||||||||||||||||||||||

;===> ONE2ONE LINE DEFAULTS
IF NONE(ONE_ADD) THEN ONE_ADD = 0
IF NONE(ONE_COLOR) THEN ONE_COLOR = 'BLACK'
IF NONE(ONE_LINESTYLE) THEN ONE_LINESTYLE = 0
IF NONE(ONE_THICK) THEN ONE_THICK = 3
;||||||||||||||||||||||||||||||||||||||||||||

;===> REGRESSION DEFAULTS [PLT_SLOPE]
IF NONE(REG_ADD) THEN REG_ADD = 0
IF NONE(MODEL) THEN MODEL = 'RMA'
IF NONE(DECIMALS) THEN DECIMALS= 3
IF NONE(PARAMS) THEN PARAMS=  [1,2,3,4,5,6,8,10,11]
IF NONE(REG_FONT_SIZE) THEN REG_FONT_SIZE = 21
IF NONE(REG_COLOR) THEN REG_COLOR = 'RED'
IF NONE(REG_THICK) THEN REG_THICK = 7
IF NONE(REG_LINESTYLE) THEN REG_LINESTYLE = 0
IF NONE(REG_MID_COLOR) THEN REG_MID_COLOR = 'WHITE'
IF NONE(REG_MID_THICK) THEN REG_MID_THICK = 3
IF NONE(REG_MID_LINESTYLE) THEN REG_MID_LINESTYLE = 0
;|||||||||||||||||||||||||||||||||||||||||||||||||||||

;===> STATISTICAL LEGEND DEFAULTS [FOR PLT_STRUCT]
IF NONE(STATS_ADD)       THEN STATS_ADD = 0
IF NONE(STATS_POS)       THEN STATS_POS = [0.05,0.80]
IF NONE(STATS_COLOR)     THEN STATS_COLOR = 'FOREST GREEN'
IF NONE(STATS_SIZE)      THEN STATS_SIZE = 16
IF NONE(DOUBLE_SPACE)    THEN DOUBLE_SPACE = 0
IF NONE(TXT_SIZE)        THEN TXT_SIZE = 16
IF NONE(TXT_STYLE)       THEN TXT_STYLE = 2
IF NONE(TXT_ALIGN)       THEN TXT_ALIGN = 0
;|||||||||||||||||||||||||||||||||||||||||||

;===> SUBSAMPLE INPUT DATA?
IF N_ELEMENTS(SAMPLE) EQ 1 THEN BEGIN
  XF = SUBSAMPLE(XF,SAMPLE)
  YF = SUBSAMPLE(YF,SAMPLE)
ENDIF;IF N_ELEMENTS(SAMPLE) GE 1 THEN BEGIN
;|||||||||||||||||||||||||||||||||||||||||||

;===>  DEFAULTS FOR SCALING,BINNING, AND SMOOTHING JOINT FREQUENCIES
;	===> GENERATE A NICE RANGE ENCOMPASSING X AND Y DATA INPUTS
  NICE_X = NICE_RANGE(XF)
  NICE_Y = NICE_RANGE(YF)

;	===> IF PROVIDED THEN USE MIN_X,MAX_X,MIN_Y,MAX_Y 
;	     INSTEAD THOSE FROM NICE_X,NICE_Y
  IF NONE(MIN_X) THEN MIN_X = NICE_X[0]
  IF NONE(MAX_X) THEN MAX_X = NICE_X[1]
  IF NONE(MIN_Y) THEN MIN_Y = NICE_Y[0]
  IF NONE(MAX_Y) THEN MAX_Y = NICE_Y[1]

;	===> DEFAULT IS TO PARTITION THE DATA INTO 50 BINS
  IF NONE(BIN_X) THEN BIN_X = ABS((MAX_X-MIN_X)/50.)
  IF NONE(BIN_Y) THEN BIN_Y = ABS((MAX_Y-MIN_Y)/50.)

;	===> DEFAULT IS NO ENLARGEMENT AND SMOOTHING OF THE ARRAY 
;	     GENERATED BY IDL'S HIST_2D
  IF NOT KEY(SMO) THEN BEGIN
  	_SMOOTH = 1
  ENDIF ELSE BEGIN
  	_SMOOTH = 1 > SMO
  ENDELSE
;||||||||||||||||||||||||||||||||||||||||||||

;	===> AXES COLOR, THICK
  IF NONE(X_COLOR)  THEN X_COLOR = 0
  IF NONE(Y_COLOR)  THEN Y_COLOR = 0
  IF NONE(X_THICK)  THEN X_THICK = 1
  IF NONE(Y_THICK)  THEN Y_THICK = 1
  ;||||||||||||||||||||||||||||||||||||||||||||

;	===> LABEL COLOR AND CHARACTER SIZE
	IF N_ELEMENTS(LAB_POS) NE 2 THEN LAB_POS = [0.77,0.05]
  IF NONE(LAB_COLOR) 		 THEN LAB_COLOR = 0
  IF NONE(LAB_CHARSIZE)  THEN LAB_CHARSIZE = 1.0
  ;||||||||||||||||||||||||||||||||||||||||||||

;	===> COLOR FOR ZERO FREQUENCIES, BACKGROUND, MAX AND MIN COLOR
;			 FOR THE BYTE IMAGE DISPLAYED TO THE GRAPHICS DEVICE
  IF NONE(ZERO_COLOR)  THEN ZERO_COLOR = 255
  IF NONE(BKG_COLOR)   THEN BKG_COLOR = 255
  IF NONE(MAX_COLOR) 	 THEN MAX_COLOR = 250
  IF NONE(MIN_COLOR) 	 THEN MIN_COLOR = 1

;	===> DEFAULT REGRESSION MODEL IS REDUCED MAJOR AXIS (TYPE II)
	IF NONE(MODEL) THEN MODEL = 'RMA' ELSE MODEL = MODEL
	N_MODEL = N_ELEMENTS(MODEL)

;	===> DEFAULT PARAMETER PASED TO STATS2 (ASSUMES LARGE X,Y
;			ARRAYS AND PREVENTS HIGHER-ORDER, TIME-CONSUMING STATISTICS
;			FROM BEING CALCULATED (SEE STATS2)
  IF NONE(FAST)  THEN FAST = 1

;	===> CODES FOR STATISTICAL PARAMETERS TO SHOW (SEE STATS2)
  IF NONE(STATS_PARAMS)  THEN BEGIN
  	STATS_PARAMS = [1,2,3,4,5,6,8,10,11]
  	IF FAST EQ 1 THEN STATS_PARAMS = [1,2,3,4,8,10]
	ENDIF

	;===>  DEFAULTS FOR THE ONE2ONE LINE
  IF NONE(ONE_COLOR)    THEN ONE_COLOR = 0
  IF NONE(ONE_THICK)    THEN ONE_THICK = 1
  IF NONE(ONE_LINESTYLE)  THEN ONE_LINESTYLE = 0
;||||||||||||||||||||||||||||||||||||||||||||||||


;	===> MEAN XY COLOR, THICK, PSYM AND SYMSIZE
	IF NONE(MEAN_COLOR)   THEN MEAN_COLOR =  0
  IF NONE(MEAN_THICK)   THEN MEAN_THICK =  2
  IF NONE(MEAN_PSYM) 			 THEN MEAN_PSYM = 1
  IF NONE(MEAN_SYMSIZE) 	 THEN MEAN_SYMSIZE = 1
  ;||||||||||||||||||||||||||||||||||||||||||||||||

;	===> FRAME AROUND THE PLOT AXES [NOT WORKING]
	IF NONE(FRAME_COLOR)    THEN FRAME_COLOR = 0
  IF NONE(FRAME_THICK)    THEN FRAME_THICK = 2

;	===> CROSS [NOT WORKING =REDUNDANT WITH MEAN_ADD ?]
	IF NONE(CROSS_COLOR)  THEN CROSS_COLOR = [0]
  IF NONE(CROSS_THICK) THEN CROSS_THICK = [2]
  IF NONE(CROSS_LINESTYLE) THEN CROSS_LINESTYLE = 1

; ===> X AND Y LABEL [NOT USED]
	IF NONE(XLABEL) THEN XLABEL =''
	IF NONE(YLABEL) THEN YLABEL =''

	XTITLE=XTITLE+'  '+ XLABEL
	YTITLE=YTITLE+'  '+ YLABEL


;	#######################################################################################
; ###   H I S T _ 2 D     CONSTRUCT A 2-D IMAGE OF THE JOINT OCCURANCES OF X,Y DATA 	###
; #######################################################################################
;	===> USE HIST_2DJ .
;			 THIS VERSION (JOR) OF IDL'S HIST_2D 
;			 DOES NOT ADD AN EXTRA ARRAY ELEMENT IF IT IS NOT NEEDED)
	IMAGE = HIST_2DJ(XF,YF,MIN1=MIN_X,MAX1=MAX_X,BIN1=BIN_X, MIN2=MIN_Y,MAX2=MAX_Y,BIN2=BIN_Y)
; ===> GET THE RESULTING IMAGE ARRAY SIZE IN PIXELS
  SZ_IMG = SIZEXYZ(IMAGE)
  PX = SZ_IMG.PX
  PY = SZ_IMG.PY

;	===> MAKE FIMAGE, A FLOATING-POINT IMAGE FROM IMAGE
;	===> IF /PERCENT THEN CALCULATE THE RELATIVE PERCENT FREQUENCY FOR EACH ELEMENT IN FIMAGE
	IF KEY(PERCENT) THEN FIMAGE = 100.0*IMAGE/TOTAL(IMAGE) ELSE FIMAGE = FLOAT(IMAGE) 


; #######################################################################################
;	###      E N L A R G E   A N D    S M O O T H    T H E   F I M A G E    
; #######################################################################################
;	===> ENLARGE FIMAGE USING CONGRID, NEAREST NEIGHBOR RESAMPLING (INTERP=0) 
;	     AND CENTER KEYWORD
 	FIMAGE 	= CONGRID(FIMAGE,	PX*_SMOOTH, PY*_SMOOTH,/CENTER,INTERP=0)

;	===> FIND THE NON-ZERO AND ZERO FREQUENCIES
	OK_FIMAGE		=	WHERE(FINITE(FIMAGE) AND FIMAGE GT 0, COUNT_FIMAGE,NCOMPLEMENT=N_ZERO_FREQUENCY,COMPLEMENT=OK_ZERO_FREQUENCY)

;	===> LOG10-TRANSFORM THE FREQUENCIES (OR PERCENT FREQUENCIES) IF /LOG_FREQ
	IF KEY(LOG_FREQ) THEN BEGIN
		IF COUNT_FIMAGE GE 1 THEN FIMAGE(OK_FIMAGE) = ALOG10(FIMAGE(OK_FIMAGE))
		XMINOR = 9
		YMINOR = 9
	ENDIF ELSE BEGIN
 		XMINOR=2
		YMINOR=2
	ENDELSE

;	===> COMPUTE THE MIN MAX OF FIMAGE
 	MIN_FIMAGE = MIN(FIMAGE(OK_FIMAGE))
	MAX_FIMAGE = MAX(FIMAGE(OK_FIMAGE))

;	===> SET ANY ZERO FREQUENCIES TO INFINITY
	IF N_ZERO_FREQUENCY GE 1 THEN FIMAGE(OK_ZERO_FREQUENCY) = MISSINGS(FIMAGE)

;	===> SMOOTH, IGNORING MISSING VALUE CODES (INFINITY)
  IF _SMOOTH NE 1 THEN FIMAGE = SMOOTH( FIMAGE, _SMOOTH,/EDGE_TRUNCATE, MISSING=MISSINGS(FIMAGE), /NAN )


; #################################################################################
;	###     S C A L E   P R O B A B I L I T Y    A R R A Y   T O    B Y T E       ###
; #################################################################################
;	===> INITIALIZE A BYTE IMG
  BIMAGE = BYTE(FIMAGE) & BIMAGE(*,*) =255B

;	===> USE SCALE TO CONSTRUCT A BINARY IMAGE OF THE PROBABILITY VALUES
;			 SCALING THE PROBABILITY VALUES BETWEEN MIN_FIMAGE AND MAX_FIMAGE
;			 TO THE COLOR RANGE ([MIN_COLOR,MAX_COLOR]
	BIMAGE(OK_FIMAGE) = SCALE(FIMAGE(OK_FIMAGE),[MIN_COLOR,MAX_COLOR],MIN=MIN_FIMAGE,MAX=MAX_FIMAGE )

;	===> REPLACE THE ZERO FREQUENCY PIXELS IN THE BIMAGE WITH THE ZERO_COLOR
  IF N_ZERO_FREQUENCY GE 1 THEN BIMAGE(OK_ZERO_FREQUENCY) = ZERO_COLOR




; ############################################
; ###  D I R E C T   G R A P H I C S       ###
; ############################################
;===> MUST DO THIS PART USING DIRECT GRAPHICS
SET_PLOT,'WIN'
ZWIN,[10000,10000]
  PLOT, XF,YF,/NODATA, XSTYLE=5, YSTYLE = 5,$
    XTICK_GET=XTICK_GET,YTICK_GET=YTICK_GET,$
    XRANGE=[MIN_X,MAX_X],YRANGE=[MIN_Y,MAX_Y],$
    TITLE=TITLE,XTITLE=XTITLE,YTITLE=YTITLE,$
    XTICKLEN= -0.02, YTICKLEN= -0.02,$
    XTICKFORMAT='(G0)',YTICKFORMAT='(G0)',$
    ISOTROPIC=ISOTROPIC,$
    BACKGROUND=BKG_COLOR,POSITION=POSITION
    
; ********************************************
; ****** SCALE HIST_2D IMAGE TO PLOT AREA  ***
; ********************************************

; ===> DIMENSIONS OF HIST2D IMAGE
  SZ_IMAGE = SIZE(BIMAGE,/STRUCT)
  IF SZ_IMAGE.N_DIMENSIONS  NE 2  THEN MESSAGE, 'IMAGE IS NOT 2D'
  PX = FLOAT(SZ_IMAGE.DIMENSIONS[0])
  PY = FLOAT(SZ_IMAGE.DIMENSIONS[1])

; ===> GET SIZE OF WINDOW IN DEVICE UNITS
  WINDOW_X = !X.WINDOW * !D.X_VSIZE
  WINDOW_Y = !Y.WINDOW * !D.Y_VSIZE

  PX_WINDOW = WINDOW_X[1]-WINDOW_X[0]   ;SIZE IN X IN DEVICE UNITS
  PY_WINDOW = WINDOW_Y[1]-WINDOW_Y[0]   ;SIZE IN Y IN DEVICE UNITS

  IMAGE_ASPECT        = PX / PY    ;IMAGE ASPECT RATIO
  WINDOW_ASPECT       = PX_WINDOW / PY_WINDOW    ;WINDOW ASPECT RATIO
  IMAGE_WINDOW_RATIO = IMAGE_ASPECT / WINDOW_ASPECT     ;RATIO OF ASPECT RATIOS

  IMAGE_OFFSET_X = 0
  IMAGE_OFFSET_Y = 0


;   ===> DISPLAY IMAGE TO DIRECT GRAPHICS DEVICE [ZWIN]
TV,POLY_2D(BIMAGE,$           ;HAVE TO RESAMPLE IMAGE
  [[-0.0,0],[PX/PX_WINDOW,0]], [[-0.0,PY/PY_WINDOW],[0,0]],$
  0,PX_WINDOW,PY_WINDOW), $   ; 0 = DO NOT WANT TO INTERPOLATE (USE NEAREST NEIGHBOR)
  WINDOW_X[0],WINDOW_Y[0]
 ZWIN ; CLOSE DIRECT GRAPHICS
 
 
;;===> CREATE  X,Y SCALED ARRAYS FOR THE IMAGE FUNCTION
XSCALE = (FINDGEN(PX)*BIN_X+MIN_X)/_SMOOTH
YSCALE = (FINDGEN(PY)*BIN_Y+MIN_Y)/_SMOOTH

SZ = SIZEXYZ(BIMAGE) & WIDTH = SZ.PX & HEIGHT = SZ.PY

;#####> PASS CB_POS & BIMAGE TO POSITIONS   #########
POS =POSITIONS(CB_POS,OBJ=BIMAGE,ASPECT=ASPECT,_EXTRA=_EXTRA)

 IF KEYWORD_SET(VERBOSE) THEN PRINT,PLT
;||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||

;###########################################################################
;############>       MAKE THE PLOT     #####################################
;###########################################################################  
PLT = PLOT(XSCALE,YSCALE,ASPECT_RATIO=ASPECT_RATIO,BUFFER=BUFFER,MARGIN = MARGIN,$
  TITLE=TITLE,FONT_SIZE = AXES_FONT_SIZE,LOCATION = [0,0],OVERPLOT=1,$
  SYMBOL=SYMBOL, SYM_FILLED=SYM_FILLED,SYM_COLOR =SYM_COLOR,$
  SYM_FILL_COLOR=SYM_FILL_COLOR,SYM_SIZE=SYM_SIZE,SYM_THICK=SYM_THICK, $
  LINESTYLE='NONE',CURRENT=1,$
  XTICKFORMAT='(G0)',YTICKFORMAT='(G0)',$
  XLOG=XLOG,YLOG=YLOG,XRANGE=XRANGE,YRANGE=YRANGE,XSTYLE=0,YSTYLE=0,XTITLE= XTITLE,$
  YTITLE= YTITLE,BACKGROUND_COLOR=BACKGROUND_COLOR,$
  XCOLOR=AXES_COLOR,YCOLOR=AXES_COLOR,XTHICK=AXES_THICK,YTHICK= AXES_THICK)
;|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||


;############################################################################
;############>       MAKE THE IMAGE     #####################################
;############################################################################
PLT = IMAGE(BIMAGE,XSCALE,YSCALE,$
    /CURRENT,/OVERPLOT,$
    BACKGROUND_COLOR = BACKGROUND_COLOR,$
    XLOG=XLOG,YLOG = YLOG,$
    XTICKFORMAT='(G0)',YTICKFORMAT='(G0)',$
    RGB_TABLE=RGB_TABLE)
;|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||

;;################################################################
;===> FIND ANY VALUES < =0 AND SET TO MISSINGS [AFTER LOGGING IF REQUIRED]
OK_X = WHERE(XF LE 0,COUNT_X)
OK_Y = WHERE(YF LE 0,COUNT_Y)

;###> SINCE THIS IS THE LAST TIME XF & YF ARE USED WE MAY ALTER THEM FOR STATS2
;===> LOG ?
IF KEY(XLOG)THEN XF = ALOG10(XF) & IF COUNT_X GE 1 THEN XF(OK_X) = MISSINGS(XF)
IF KEY(YLOG)THEN YF = ALOG10(YF) & IF COUNT_Y GE 1 THEN YF(OK_Y) = MISSINGS(YF)

S = STATS2(XF,YF,MODEL=MODEL,PARAMS=PARAMS,$
  DECIMALS=DECIMALS,SHOW=SHOW,FAST=FAST,DOUBLE_SPACE=DOUBLE_SPACE)
;||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||

;################################################################
IF KEY(REG_ADD) THEN BEGIN
  PLT_SLOPE,PLT,STRUCT = S,$
    REG_COLOR = REG_COLOR,$
    REG_THICK = REG_THICK,$
    REG_LINESTYLE = REG_LINESTYLE,$
    REG_MID_COLOR=REG_MID_COLOR,$
    REG_MID_THICK= REG_MID_THICK,$
    REG_MID_LINESTYLE=REG_MID_LINESTYLE
ENDIF;IF  KEY(REG_ADD) THEN BEGIN
;||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||

;##########################################
IF KEY(STATS_ADD) THEN BEGIN
  PLT_STRUCT,PLT,STRUCT = S,POS = STATS_POS,COLOR = STATS_COLOR,FONT_SIZE=STATS_SIZE,THICK = 3
ENDIF;IF NOT KEY(STATS_ADD) THEN BEGIN
;||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
;
;##########################################
IF KEY(ONE_ADD) THEN BEGIN
  PLT_ONE2ONE,PLT,COLOR = ONE_COLOR,LINESTYLE =ONE_LINESTYLE,THICK = ONE_THICK
ENDIF;IF NOT KEY(ONE_ADD) THEN BEGIN
;||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||


;;################################################################
IF KEY(GRID_ADD) THEN BEGIN
  PLT_GRIDS,PLT,COLOR=GRID_COLOR,THICK =GRID_THICK,LINESTYLE=GRID_LINESTYLE
ENDIF;IF KEY(GRID_ADD) THEN BEGIN
;||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||

;######### ADD THE MEAN X,Y ? ################
IF KEY(MEAN_ADD) THEN BEGIN
  PLT_MEAN,PLT,SYMBOL = MEAN_SYMBOL,SYM_SIZE = MEAN_SIZE,SYM_COLOR=MEAN_COLOR,$
          SYM_THICK = MEAN_THICK,XLOG=XLOG,YLOG=YLOG
ENDIF;IF KEY(MEAN_ADD) THEN BEGIN;
;||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
;
;######### ADD A COLORBAR ? #################


IF KEY(CB_ADD) THEN BEGIN
 PRODS_COLORBAR,PROD,IMG=PLT,PAL=PAL, ORIENTATION=0,$
  FONT_NAME = CB_FONT,COLOR = CB_COLOR,FONT_SIZE = CB_SIZE,TITLE = CB_TITLE,$
   POSITION = CB_POSITION,TEXTPOS = POS.TEXTPOS,TICKDIR =POS.TICKDIR,$
  COMMA = CB_COMMA
ENDIF;IF KEY(CB_ADD) THEN BEGIN
;||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||


;#########   ADD A TIMESTAMP ? #################
  IF  KEY(DATE_ADD) THEN BEGIN
    TXT= DATE_FORMAT(DATE_NOW(),UNITS='DAY',/MDY,/NAME,/COMMA)
    T = TEXT(0.99,0.0,TXT,ALIGNMENT = 1.0,VERTICAL_ALIGNMENT = 0.0,FONT_SIZE = 6)
  ENDIF
;||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
;===> DELAY CLOSING THE PLOT WINDOW ?
WAIT,DELAY
; ;===> WRITE THE IMAGE:
IF KEY(FILE) THEN BEGIN    
  PLT_WRITE,PLT,FILE=FILE,BORDER = BORDER,BIT_DEPTH=BIT_DEPTH
ENDIF ELSE BEGIN
  ;===> CLOSE THE PLOT  
  PLT.CLOSE    
ENDELSE; IF KEY(FILE) THEN BEGIN 
  
;
 DONE:




END; #####################  END OF ROUTINE ################################
