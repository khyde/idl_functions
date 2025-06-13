; $ID:	FILTER_TRAPEZOID.PRO,	2020-07-08-15,	USER-KJWH	$

 	FUNCTION FILTER_TRAPEZOID, DATA, WIDTH=WIDTH, FILTER=FILTER, MISSING=MISSING,ERROR=ERROR

;+
; NAME:
;		FILTER_TRAPEZOID
;
; PURPOSE:
;				Smooth a 1 or 2-d Data array using a TRAPEZOID Filter
;
; CATEGORY:
;		MATH
;
; CALLING SEQUENCE:
;		Result = FILTER_TRAPEZOID(Data,Width)
;
; INPUTS:
;		Data...	A 1 or 2-d array
;
; OPTIONAL INPUTS:
;		WIDTH.. The width for the filter (default = 3)
;		MISSING.The data value which is INVALID and should be ignored as missing data
;						The default missing is based on the IDL data type and MISSINGS.PRO
;
; OUTPUTS:
;		A Double-Precision filtered 1 or 2-d array of the size of the input Data
;
; OPTIONAL OUTPUTS:
;		FILTER... Setting this keyword returns the filter kernel
;		ERROR....	Any Error messages are placed in ERROR, if no errors then ERROR = ''

; RESTRICTIONS:
;		The filter WIDTH must be less than or equal to the dimension(s) of the input Data array
;
;	PROCEDURE:
; EXAMPLES:
; PRINT,FILTER_TRAPEZOID(/FILTER)
; PRINT,FILTER_TRAPEZOID(/FILTER,WIDTH=5)
; PRINT,FILTER_TRAPEZOID(/FILTER,WIDTH=7)
; PRINT,FILTER_TRAPEZOID(/FILTER,WIDTH=9)
; PRINT,FILTER_TRAPEZOID([0,1,2,3.4,5,4,3,2,1,0],WIDTH=3)
;
;	NOTES:
;
;		A Trapezoidal filter of Width=7 is similar to Bloomfield's Modified Daniell Filter width=6
;		where the central 4 are summed and the points to left and right of central 4 are averaged

;		For Example, Bloomfield's simple moving average of length 6
;		S6(f) = 1/6 *(  1/2*I(f-f3) + TOTAL(I(f-fj)(j=-2,2) + 1/2*I(f+f3)  )
;		YIELDS IDENTICAL RESULTS TO THIS PROGRAM WHEN WIDTH = 7

;   Bloomfield, Peter. 2000.
;		Fourier Analysis of Time Series, An Introduction.
;		Second Edition. John Wiley & Sons, INC. (Page 157).
;
; MODIFICATION HISTORY:
;       Written by:  J.E.O'Reilly, Feb 7, 2004
;       JAN.8,2010,JOR EDITER AN ADDED EXAMPLES
;-
;	****************************************************************************************************
	ROUTINE_NAME = 'FILTER_TRAPEZOID'
	;RETURN
	ERROR = ''
; ===> If just want the filter
;	===> Default Width

	IF N_ELEMENTS(WIDTH) NE 1 THEN WIDTH_=3  ELSE WIDTH_= WIDTH
	;  ===> Ensure width GE 3:
  WIDTH_ = WIDTH_ > 3
W = REPLICATE(1./(WIDTH_-1),WIDTH_)
  W([0,WIDTH_-1]) = 0.5*W([0,WIDTH_-1])
    kernel = W
  
    IF KEYWORD_SET(FILTER) AND N_ELEMENTS(DATA) EQ 0 THEN RETURN,kernel
  
	IF N_ELEMENTS(MISSING) NE 1 THEN _missing = MISSINGS(Data) ELSE _missing = MISSING



;	===> Center of filter
	center = WIDTH/2


	W = REPLICATE(1./(WIDTH_-1),WIDTH_)
	W([0,WIDTH_-1]) = 0.5*W([0,WIDTH_-1])


;	===> Size of input Data
	sz=SIZE(Data,/STRUCT)

	IF SZ.N_DIMENSIONS EQ 2 THEN kernel = W # TRANSPOSE(W)

;	===> If just want the filter
	IF KEYWORD_SET(FILTER) THEN RETURN,kernel

;	***************************************
;	*** Convolution of Data with kernel ***
;	***************************************

;	===> Ensure that Width of Kernel is less than width of data array
	IF (SZ.N_DIMENSIONS EQ 1 AND WIDTH_ GT sz.dimensions[0]) OR $
		 (SZ.N_DIMENSIONS EQ 2 AND (WIDTH_ GT sz.dimensions[0] OR WIDTH_ GT sz.dimensions[1])) THEN BEGIN
		ERROR='WIDTH must be less than Data Dimensions'
		RETURN,''
	ENDIF

;	RETURN, CONVOL(Data,kernel,TOTAL(kernel),/EDGE_TRUNCATE,/NAN)

	RETURN, CONVOL(DATA,KERNEL,TOTAL(KERNEL),INVALID=_MISSING,MISSING=_MISSING,/NORMALIZE,/EDGE_TRUNCATE)


END; #####################  End of Routine ################################
