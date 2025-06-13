; $Id:	MEDFILTER2D_5X5_DEMO.pro,	1 February 2007	$

	PRO MEDFILTER2D_5X5_DEMO

;+
; NAME:
; 	MEDFILTER2D_5X5_DEMO
;
; PURPOSE:
; 	This PROGRAM IS A DEMO FOR MEDFILTER2D_5X5
;
; CATEGORY:
;   Statistics.
;
; CALLING SEQUENCE:
;   Result = Moment(X)
;
; INPUTS:
;   X:
;	OPTIONAL INPUTS:
;
; KEYWORD PARAMETERS:
;   DOUBLE:
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
; PROCEDURE:
;
; RESTRICTIONS:
;
; NOTES:
;
; MODIFICATION HISTORY:
; Written Feb 1, 2007, Igor Belkin, URI
;-

	ROUTINE_NAME='MEDFILTER2D_5X5_DEMO'

;	*******************************
;	*** PROGRAM SWITCHES  ***
;	*********************************
	DO_TEST_RANDOM = 1
		IF DO_TEST_RANDOM GE 1 THEN BEGIN
			MAX_ITER = 10
		  Nrows=200 & Ncols=400 & A=RANDOMN(SEED,Nrows,Ncols)*100
		  NEW = MEDFILTER2D_5X5(A, NITER=NITER, MAX_ITER=MAX_ITER)
			PAL_SW3,R,G,B
		  SLIDEW, NEW
		  ALL = [A,NEW]
		  PNG_FILE = ROUTINE_NAME + '.PNG'
		  WRITE_PNG,PNG_FILE, ALL, R,G,B
;		  STOP
		ENDIF
	END; #####################  End of Routine ################################

