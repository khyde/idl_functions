; $Id:	filter_median_igor.pro,	January 31 2007	$

 	FUNCTION FILTER_MEDIAN_IGOR, Data, WIDTH=width, FILTER=filter, MISSING=missing,ERROR=error

;+
; NAME:
;		FILTER_MEDIAN_IGOR
;
; PURPOSE:
;				Smooth a 1 or 2-d Data array using a MEDIAN_IGOR Filter
;
; CATEGORY:
;		MATH
;
; CALLING SEQUENCE:
;
;		Result = FILTER_MEDIAN_IGOR(Data,Width)
;
; INPUTS:
;		Data...	A 1 or 2-d array
;
; OPTIONAL INPUTS:
;		WIDTH.. The width for the filter (default = 5)
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
; EXAMPLE:
;
;	NOTES:
;
;
; MODIFICATION HISTORY:
;			Written Jan 29, 2007 by J.O'Reilly, 28 Tarzwell Drive, NMFS, NOAA 02882 (Jay.O'Reilly@NOAA.GOV)
;-
;	****************************************************************************************************
	ROUTINE_NAME = 'FILTER_MEDIAN_IGOR'
	ERROR = ''

;	===> Default Width
	IF N_ELEMENTS(WIDTH) NE 1 THEN WIDTH=5 ;

	IF N_ELEMENTS(MISSING) NE 1 THEN _missing = MISSINGS(Data) ELSE _missing = MISSING

;	===> Ensure width GE 3:
	WIDTH = WIDTH > 3




;		APPLY THE MEDIAN FILTER TO THE DATA










	; RETURN,THE RESULTS OF MED FILTER



END; #####################  End of Routine ################################
