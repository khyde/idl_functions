; $ID:	MEDFILTER2D_5X5.PRO,	2020-07-08-15,	USER-KJWH	$

	FUNCTION MEDFILTER2D_5X5, ARRAY, WIDTH=WIDTH, DIFF= diff, NITER=NITER, MAX_ITER = MAX_ITER, ERROR=error, ERR_MSG=err_msg

;+
; NAME:
;       MEDFILTER2D_5X5
;
; PURPOSE:
;       This FUNCTION returns a median of the input array
;
; CATEGORY:
;       Statistics.
;
; CALLING SEQUENCE:
;       Result = MEDFILTER2D_5X5(array)
;
; INPUTS:
;       ARRAY:	2-D ARRAY
;	OPTIONAL INPUTS:
;
; KEYWORD PARAMETERS:
;       DIFF:   The desired difference between the initial and final median array
;
;	OUTPUTS:
;
;	OPTIONAL OUTPUTS:
;		NITER:		The number of NITERations
;		ERROR=error
;		ERR_MSG
;
;	COMMON BLOCKS:
;		NONE
;
;	SIDE EFFECTS:
;
; EXAMPLES:
;
;  Nrows=200 & Ncols=400 & A=RANDOMN(SEED,Nrows,Ncols)*100 & Result = MEDFILTER2D_3X3(A, NITER=NITER)
;
; PROCEDURE:
;
; RESTRICTIONS:
;
; NOTES:
;
; MODIFICATION HISTORY:
;			Written Feb 1, 2007 by Igor Belkin, URI.
;-

	ROUTINE_NAME='MEDFILTER2D_5X5'

;	===> Initialize
	ERROR = 0
	NITER  = 0

;	===> Default difference between input array and output array after median filter
	IF N_ELEMENTS(DIFF) NE 1 THEN DIFF = 5

;	===> Default window is 5x5
	IF N_ELEMENTS(WIDTH) NE 1 THEN WIDTH = 5

;	===> MAXIMUM NUMBER OF ITERATIONS ALLOWED
	IF N_ELEMENTS(MAX_ITER) NE 1 THEN MAX_ITER = 100

;	===> CHECK ON INPUTS
	SZ = SIZE(ARRAY,/STRUCT)

	IF SZ.N_ELEMENTS LT 2 THEN BEGIN
		ERROR = 1
		ERR_MSG = 'Array not provided'
		RETURN, -1
	ENDIF

	NCOLS = SZ.DIMENSIONS[0]
	NROWS = SZ.DIMENSIONS[1]

;	===> Convergence criteria = MACHINE EPS TIMES NROWS * NCOLS
	_MACHAR = MACHAR()
	EPS = _MACHAR.EPS * NCOLS * NROWS

;	===> Make a copy of the input array to avoid changing it
	_ARRAY = ARRAY

;	===> MAKE A COPY OF THE INPUT _ARRAY
  COPY = _ARRAY

	W = FLTARR(WIDTH,WIDTH)

	DIFF = 1E32

;	===> OPEN A GRAPHICS WINDOW SIZED TO THE INPUT ARRAY
	WINDOW, XSIZE= NCOLS, YSIZE=NROWS

;	WWWWWWWWWWWWWWWWWWWWWWWW
	WHILE  DIFF GT EPS  AND NITER LE MAX_ITER DO BEGIN
    NITER=NITER+1;

;		LLLLLLLLLLLLLLLLLLLLLLLL
    FOR i=2,Nrows-3 DO BEGIN
;			LLLLLLLLLLLLLLLLLLLLLLLL
			FOR j=2,Ncols-3 DO BEGIN
				W =  _ARRAY(J-2:J+2 , I-2:I+2)
        COPY(J,I)=MEDIAN(W)
      ENDFOR ; j-loop
   	ENDFOR ; i-loop

		PAL_SW3

    diff =  TOTAL(ABS(_ARRAY-COPY))
    PRINT, DIFF
    _ARRAY = COPY
    TV, COPY

		WAIT, 1

	ENDWHILE ; WHILE loop

	RETURN, COPY

END; #####################  End of Routine ################################
