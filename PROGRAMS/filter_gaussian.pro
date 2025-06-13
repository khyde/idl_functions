; $ID:	FILTER_GAUSSIAN.PRO,	2020-07-08-15,	USER-KJWH	$

 	FUNCTION FILTER_GAUSSIAN, Data, WIDTH=width, SIGMA=sigma, FILTER=filter, MISSING=missing,ERROR=error

;+
; NAME:
;		FILTER_GAUSSIAN
;
; PURPOSE:
;				Smooth a 1 or 2-d Data array using a GAUSSIAN Filter
;
; CATEGORY:
;		MATH
;
; CALLING SEQUENCE: ;
;		Result = FILTER_GAUSSIAN(Data)
;
; INPUTS:
;		Data...	A 1 or 2-d array (should be floating-point or double-precision)
;
; OPTIONAL INPUTS:
;		WIDTH.. The width for the filter (default = 5)
;		SIGMA..	The value which controls the steepness of the Gaussian Weighting Function:
;						e.g. with a sigma = 0.5 the weighting function decreases rapidly away from the central pixel
;						and  with a sigma = 7.0 the weighting function decreases very slowly away from the central pixel.
;						The default Sigma is 0.6
;
;		MISSING.The data value which is INVALID and should be ignored as missing data
;						The default missing is based on the IDL data type and MISSINGS.PRO
;
;
; OUTPUTS:
;		A filtered 1 or 2-d array of the size of the input Data
;
; OPTIONAL OUTPUTS:
;		FILTER... Setting this keyword returns the filter kernel (Weights used in smoothing)
;		ERROR....	Any Error messages are placed in ERROR, if no errors then ERROR = ''

; RESTRICTIONS:
;		The filter WIDTH must be less than or equal to the dimension(s) of the input Data array
;
; EXAMPLE:
;		DATA=FINDGEN(10,10)&DATA(5,5)=!VALUES.F_NAN & PRINT, DATA & PRINT & F=FILTER_GAUSSIAN(DATA) & PRINT, F
;
; 	print, FILTER_GAUSSIAN(/filter)
; 	print, FILTER_GAUSSIAN(/filter,SIGMA=0.1)
;		print, FILTER_GAUSSIAN(/filter,SIGMA=3)
; 	print, FILTER_GAUSSIAN(/filter,SIGMA=7)
;
;	NOTES:
;
;
; MODIFICATION HISTORY:
;			Written Jan 29, 2007 by J.O'Reilly, 28 Tarzwell Drive, NMFS, NOAA 02882 (Jay.O'Reilly@NOAA.GOV)
;-
;	****************************************************************************************************
	ROUTINE_NAME = 'FILTER_GAUSSIAN'
	ERROR = ''

;	===> Default Width
	IF N_ELEMENTS(WIDTH) NE 1 THEN _WIDTH = FIX(5) ELSE _WIDTH = FIX(WIDTH)

	IF N_ELEMENTS(MISSING) NE 1 THEN _missing = MISSINGS(Data) ELSE _missing = MISSING

;	===> Ensure _WIDTH GE 3:
	_WIDTH = _WIDTH > 3

;	===> Center of filter
	center = _WIDTH/2

	X=FINDGEN(_WIDTH)

;	===> Get filter Weights
  IF N_ELEMENTS(sigma) NE 1 THEN _sigma = 0.6d ELSE _sigma = sigma

;	===> Following is from RSI: create X and Y indices
  x = (dindgen(_WIDTH)-_WIDTH/2) # replicate(1, _WIDTH)
  y = transpose(x)

;	===> create kernel
  kernel = EXP(-((x^2)+(y^2))/(2*DOUBLE(_sigma)^2)) / (SQRT(2.0*!pi) * DOUBLE(_sigma))

;	===> Size of input Data
	sz=SIZE(Data,/STRUCT)


;	===> If just want the filter
	IF KEYWORD_SET(FILTER) THEN RETURN,kernel


;	***************************************
;	*** Convolution of Data with kernel ***
;	***************************************

;	===> Ensure that _WIDTH of Kernel is less than _WIDTH of data array
	IF (SZ.N_DIMENSIONS EQ 1 AND _WIDTH GT sz.dimensions[0]) OR $
		 (SZ.N_DIMENSIONS EQ 2 AND (_WIDTH GT sz.dimensions[0] OR _WIDTH GT sz.dimensions[1])) THEN BEGIN
		ERROR='_WIDTH must be less than Data Dimensions'
		RETURN,''
	ENDIF


;	===> If Data are not floating or double-precision then convert to floating before Convolution Step
	IF sz.TYPE EQ 4 OR sz.TYPE EQ 5 THEN BEGIN
;		===> Convolve, ignore NAN
		F=CONVOL(Data,			 kernel,INVALID=_missing,MISSING=_MISSING,/NORMALIZE,/EDGE_TRUNCATE,/NAN)
	ENDIF ELSE BEGIN
		F=CONVOL(FLOAT(Data),kernel,INVALID=_missing,MISSING=_MISSING,/NORMALIZE,/EDGE_TRUNCATE,/NAN)
	ENDELSE

;	===> Ensure any input data which were missing or nan remain missing on output
	ok = WHERE(FINITE(DATA) EQ 0,COUNT)
	IF COUNT GE 1 THEN F[OK]= !VALUES.F_NAN

	RETURN,F

END; #####################  End of Routine ################################
