; $Id:	subsample.pro,	January 05 2007	$

	FUNCTION SUBSAMPLE,ARRAY,NTH

;+
; NAME:
;		SUBSAMPLE
;
; PURPOSE:;
;		This function Subsamples an array by returning every Nth value in the array

;
; CATEGORY:
;		ARRAY
;
; CALLING SEQUENCE:
;		Result = SUBSAMPLE(Array,Nth)
;
; INPUTS:
;		Array: An array
;   Nth:	 Select every nth value for the output
;
; OUTPUTS:
;		This function returns every Nth value in the Array
;
; EXAMPLE:
;		Result=SUBSAMPLE(INDGEN(100),10) & PRINT, A;
;        0      10      20      30      40      50      60      70      80      90
;
; MODIFICATION HISTORY:
;			Written Nov 29, 1998 by J.O'Reilly, 28 Tarzwell Drive, NMFS, NOAA 02882 (Jay.O'Reilly@NOAA.GOV)
;-
;	****************************************************************************************************
	ROUTINE_NAME = 'SUBSAMPLE'

 	IF N_ELEMENTS(ARRAY) LT 1 THEN RETURN, -1
 	IF N_ELEMENTS(NTH) NE 1 THEN NTH = 1
 	subscripts = LINDGEN(N_ELEMENTS(ARRAY))
 	OK = WHERE(SUBSCRIPTS MOD NTH EQ 0)
 	RETURN,ARRAY(OK)
END; #####################  End of Routine ################################
