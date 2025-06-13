; $Id:	span.pro,	June 14 2006, 09:11	$

 FUNCTION SPAN, DATA, FIN=FIN
;+
; NAME:
; 	SPAN

;		This Function Computes the SPAN for 2 or more data values as the ABS(MAX(DATA)-MIN(DATA)
;
; SYNTAX:
;		Result = SPAN(Data)
;
; OUTPUT:
;	 The Absolute Difference between the Maximum and Minimum of the input Data Values
;
; ARGUMENTS:
;		Data: 	Numeric
;
; KEYWORDS:
;
; EXAMPLE:
;		Data = [-4,2,5,9,12.5] & PRINT, SPAN(DATA)
;
;	NOTES:
;
; MODIFICATION HISTORY:
;		Written Jan 23, 2005 by J.O'Reilly, 28 Tarzwell Drive, NMFS, NOAA 02882 (Jay.O'Reilly@NOAA.GOV)
;-

ROUTINE_NAME='SPAN'

	IF N_ELEMENTS(DATA) EQ 0 THEN RETURN, -1

	MINMAX_=MINMAX(DOUBLE(DATA),FIN=FIN)
	RETURN, ABS(MINMAX_(1)-MINMAX_(0))


END; #####################  End of Routine ################################



