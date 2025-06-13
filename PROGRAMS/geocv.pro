; $ID:	GEOCV.PRO,	2020-06-26-15,	USER-KJWH	$

  FUNCTION GEOCV, ARRAY, TRANSFORM=TRANSFORM, MISSING=missing, ERROR=error, NAN=NAN

;+
; NAME:
;   TEMPLATE
;
; PURPOSE:
;   This function calculates the geometric coefficient of variaton from untransformed data
;
; CATEGORY:
;   CATEGORY
;
; CALLING SEQUENCE:
;
;   Result = GEOSTDEV(data)
;
; INPUTS:
;   Parm1:  Untransformed data
;
; OPTIONAL INPUTS:
;   Parm2:  Describe optional inputs here. If you don't have any, just delete this section.
;
; KEYWORD PARAMETERS:
;   Missing:   value for missing data (This value will be excluded from the statistics).
;
; OUTPUTS:
;   This function returns the geometric standard deviation of the input data
;
; OPTIONAL OUTPUTS:
;   ERROR:     Any Error messages are placed in ERROR, if no errors then ERROR = ''
;
; PROCEDURE:
;
; EXAMPLE:
;
; NOTES:
;     Based on information found at: http://onbiostatistics.blogspot.com/2008/07/geometric-statistics-geometric-cv-vs.html
;                                    http://en.wikipedia.org/wiki/Coefficient_of_variation
;
; MODIFICATION HISTORY:
;			Written:  May 18, 2015 by K.J.W. Hyde, 28 Tarzwell Drive, NMFS, NOAA 02882 (kimberly.hyde@noaa.gov)
;-
;	****************************************************************************************************
	ROUTINE_NAME = 'GEOSTDEV'
	
	IF N_ELEMENTS(ARRAY) EQ 0 THEN RETURN, []
	IF MIN(ARRAY) EQ MISSINGS(ARRAY) THEN RETURN, MISSINGS(0.0)
	
	; Check for TRANSFORM keyword
	IF NONE(TRANSFORM) THEN STAT_TRANSFORM = 'ALOG' ELSE STAT_TRANSFORM = TRANSFORM ; Default TRANSFORM is ALOG
	
	; Check keyword missing	
	IF N_ELEMENTS(MISSING) NE 1 THEN MISSING = MISSINGS(0.0D) ELSE MISSING = DOUBLE(MISSING)   ; If value for missing not provided make missing !VALUES.D_INFINITY
	
	; Copy array into data variable (This keeps original array unchanged)
	ARR = (DOUBLE(ARRAY))
	
	; ====================>
	; Remove data values equal to missing value, infinity or LE zero
	OK = WHERE(ARR NE MISSING AND FINITE(ARR) AND ARR GT 0.0 ,COUNT)  ; Check for missing input data
	IF COUNT GE 1 THEN ARR = TEMPORARY(ARR[OK]) ELSE ARR = MISSING
	
	IF STAT_TRANSFORM EQ 'ALOG' THEN RETURN, (EXP(STDDEV(ALOG(ARR),NAN=NAN)^2)-1)^.5 		
	IF STAT_TRANSFORM EQ 'ALOG10' THEN RETURN, (10^(STDDEV(ALOG10(ARR),NAN=NAN)^2)-1)^.5 
		
	PRINT, 'Incorrect transform input'
  RETURN, []

END; #####################  End of Routine ################################
