; $Id:	medfilter2d_3x3_demo.pro,	February 13 2007	$

	PRO MEDFILTER2D_3X3_DEMO



;+
; NAME:
;       MEDFILTER2D_3X3_DEMO
;
; PURPOSE:
;       This PROGRAM IS A DEMO FOR MEDFILTER2D_3X3
;
; CATEGORY:
;       Statistics.
;
; CALLING SEQUENCE:
;       Result = Moment(X)
;
; INPUTS:
;       X:
;	OPTIONAL INPUTS:
;
; KEYWORD PARAMETERS:
;       DOUBLE:
;
;	OUTPUTS:
;
;	OPTIONAL OUTPUTS:
;
;	COMMON BLOCKS:
;
;	SIDE EFFECTS:
;
; EXAMPLES:
;
;
;
; PROCEDURE:
;
; RESTRICTIONS:
;
; NOTES:
;
;
; MODIFICATION HISTORY:
;			Written Dec 1, 2006, Igor Belkin
;-

	ROUTINE_NAME='MEDFILTER2D_3X3_DEMO'



;	*******************************
;	*** PROGRAM SWITCHES  ***
;	*********************************

	DO_TEST_RANDOM    	= 0
	DO_FRONTS_DIRECTION = 1





	IF DO_TEST_RANDOM GE 1 THEN BEGIN
			MAX_ITER = 10
		  Nrows=200 & Ncols=400 & A=RANDOMN(SEED,Nrows,Ncols)*100
		  NEW = MEDFILTER2D_3X3(A, NITER=NITER, MAX_ITER=MAX_ITER)

			PAL_SW3,R,G,B
		  SLIDEW, RESULT
		  ALL = [A,NEW]
		  PNG_FILE = ROUTINE_NAME + '.PNG'
		  WRITE_PNG,PNG_FILE, ALL, R,G,B
		  STOP
	ENDIF



	IF DO_FRONTS_DIRECTION GE 1 THEN BEGIN
			FILE = 'D:\IDL\BELKIN\' + 'graddir_GS_34N44N_77W48W_winter.dat'


		dx=360/4096.
		dy=180/2048.
;   % GULF STREAM AREA:
    LatN=44. & LatS=34. & DLat=1. & LonW=-77. & LonE= -48. & DLon=1.;
;  % Data Aspect Ratio Setup: The central latitude is 39N:
	clat=MEAN([LatN,LatS]);
	DAR=1/cos(clat/360*2*!pi);

;seasons={'winter';'spring';'summer';'autumn'};
;seasonsmonths={' (JFM)';' (AMJ)';' (JAS)';' (OND)'};

;load graddir_colormap.mat;

;for s=1:4

;AREA=load(['graddir_GS_34N44N_77W48W_',char(seasons(s)),'.dat'],'AREA','-ASCII');

;% MAKE a MAP:
;% AXES LIMITS and TICKS:
Nrows=round((LatN-LatS)/dy);
Ncols=round((LonE-LonW)/dx);

X = FLTARR(NROWS,NCOLS)
Y = X


;	THE FOLLOWING IS NOT RIGHT
;x(0,*) =  0+dx/2
;X(1:NCOLS-2,*) = dx
;X(NCOLS-1,*) = 360-dx/2
;
;Y(*,0) =  0+dy/2
;Y(*,1:NROWS-2,*) = dy
;Y(NCOLS-1,*) = 360-dy/2
;
;& y= [ 0+dy/2  , dy,  180-dy/2];

;xx=1:Ncols & yy=1:Nrows;


;     EXPLORE DIMENSIONS IN FILE

			CLOSE,/ALL
			ARR = DBLARR(NROWS,NCOLS)
				OPENR, 1, FILE
				READU,1,ARR
			STOP



			MAX_ITER = 10
		  Nrows=200 & Ncols=400 & A=RANDOMN(SEED,Nrows,Ncols)*100
		  NEW = MEDFILTER2D_3X3(A, NITER=NITER, MAX_ITER=MAX_ITER)

			PAL_SW3,R,G,B
		  SLIDEW, RESULT
		  ALL = [A,NEW]
		  PNG_FILE = ROUTINE_NAME + '.PNG'
		  WRITE_PNG,PNG_FILE, ALL, R,G,B
		  STOP
		ENDIF

END; #####################  End of Routine ################################



