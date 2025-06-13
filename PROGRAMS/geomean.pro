; $ID:	GEOMEAN.PRO,	2020-06-26-15,	USER-KJWH	$

  FUNCTION GEOMEAN, ARRAY, TRANSFORM=transform, MISSING=missing, ERROR=error, NAN=NAN

;+
; NAME:
;   TEMPLATE
;
; PURPOSE:
;   This function calculates the geometric mean from untransformed data
;
; CATEGORY:
;   CATEGORY
;
; CALLING SEQUENCE:
;
;   Result = GEOMEAN(data)
;   Result = GEOMEAN(data,transform='alog')
;   Result = GEOMEAN(data,transform='alog10')
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
;   This function returns the geometric mean of the input data
;
; OPTIONAL OUTPUTS:
;   ERROR:     Any Error messages are placed in ERROR, if no errors then ERROR = ''
;
; PROCEDURE:
;
; EXAMPLE:
;
; NOTES:
;
;
; MODIFICATION HISTORY:
;			Written:  June 03, 2013 by K.J.W. Hyde, 28 Tarzwell Drive, NMFS, NOAA 02882 (kimberly.hyde@noaa.gov)
;			Modified: June 04, 2014 by K.J.W. Hyde - Added NAN keyword and check for NULL array
;     Modified: May  18, 2015 by K.J.W. Hyde - Changed GMEAN equation (results are still the same) and removed TRANSFORM and NAN keywords
;     Modified: May  26, 2015 by K.J.W. Hyde - Reverted back to the original equation because previous version could not handle large amounts of data (returned a 0.0 value)
;     Modified: Dec  11, 2015 by K.J.W. Hyde - If all input data are MISSING then RETURN, MISSING
;-
;	****************************************************************************************************
	ROUTINE_NAME = 'GEOMEAN'
	
	IF N_ELEMENTS(ARRAY) EQ 0 THEN RETURN, []

	; Check for TRANSFORM keyword
	IF NOT KEYWORD_SET(TRANSFORM) THEN STAT_TRANSFORM = 'ALOG' ELSE STAT_TRANSFORM = TRANSFORM ; Default TRANSFORM is ALOG
		
	; Check keyword missing	
	IF N_ELEMENTS(MISSING) NE 1 THEN MISSING = MISSINGS(0.0D) ELSE MISSING = DOUBLE(MISSING)   ; If value for missing not provided make missing !VALUES.D_INFINITY
	
	; Copy array into data variable (This keeps original array unchanged)
	ARR = (DOUBLE(ARRAY))
	
	; ====================>
	; Remove data values equal to missing value, infinity or LE zero
	OK = WHERE(ARR NE MISSING AND FINITE(ARR) AND ARR GT 0.0 ,COUNT)  ; Check for missing input data
	IF COUNT GE 1 THEN ARR = TEMPORARY(ARR[OK]) ELSE RETURN, MISSING
	
;	RETURN, (PRODUCT(ARR))^(1.0/N_ELEMENTS(ARR))
		
	IF STAT_TRANSFORM EQ 'ALOG' THEN RETURN, EXP(MEAN(ALOG(ARR),NAN=NAN)) 		
	IF STAT_TRANSFORM EQ 'ALOG10' THEN RETURN, 10^(MEAN(ALOG10(ARR),NAN=NAN)) 
		
;	PRINT, 'Incorrect transform input'
  

END; #####################  End of Routine ################################
