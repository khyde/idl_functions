; $ID:	TEMPLATE_KH.PRO,	2018-08-01-16,	USER-KJWH	$

  FUNCTION GET_IDL_COLOR, COLOR

;+
; NAME:
;   GET_IDL_COLOR
;
; PURPOSE:
;   This function gets the r,g,b values from the IDL !COLOR system value
;
; CATEGORY:
;   
;
; CALLING SEQUENCE:
;   Result = GET_IDL_COLOR(COLOR)
;
; INPUTS:
;   COLOR..... IDL system color 
;   
; OPTIONAL INPUTS:
;   
;   
; KEYWORD PARAMETERS:
;   
;   
; OUTPUTS:
;   This function returns the rgb array that represents IDL's colors
;
; OPTIONAL OUTPUTS:
;
; PROCEDURE:
;
; EXAMPLE:
;
; NOTES:
;
;   
; COPYRIGHT: 
; Copyright (C) 2018, Department of Commerce, National Oceanic and Atmospheric Administration, National Marine Fisheries Service,
;   Northeast Fisheries Science Center, Narragansett Laboratory.
;   This software may be used, copied, or redistributed as long as it is not sold and this copyright notice is reproduced on each copy made.
;   This routine is provided AS IS without any express or implied warranties whatsoever.
;
;   This program was written by Kimberly Hyde, DOC/NOAA/NMFS/NEFSC Narragansett, RI, kimberly.hyde@noaa.gov
;          with assistance from John E. O'Reilly, DOC/NOAA/NMFS/NEFSC Narragansett, RI
;   
;
; MODIFICATION HISTORY:
;			Written:  Nov 09, 2018 by K.J.W. Hyde, NOAA/NEFSC/Narragansett Laboratory, 28 Tarzwell Drive, 02882 (kimberly.hyde@noaa.gov)
;			Modified: 
;-
;	****************************************************************************************************
	ROUTINE_NAME = 'GET_IDL_COLOR'
	
	BLK = [0,0,0]
	IF N_ELEMENTS(COLOR) NE 1 THEN RETURN, BLK
	IF IDLTYPE(COLOR) NE 'STRING' THEN RETURN, BLK
	
	CLRS = TAG_NAMES(!COLOR)
	OK = WHERE(CLRS EQ STRUPCASE(COLOR),COUNT)
	IF COUNT EQ 0 THEN RETURN, [0,0,0]
	RETURN, !COLOR.(OK) 
	

END; #####################  End of Routine ################################
