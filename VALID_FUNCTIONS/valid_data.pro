; $ID:	VALID_DATA.PRO,	2017-03-15-11,	USER-KJWH	$

	FUNCTION VALID_DATA, ARRAY, PROD=PROD, SUBS=SUBS, OPERATORS=OPERATORS, RANGE=RANGE, CRITERIA_TXT=CRITERIA_TXT, COUNT=COUNT, COMPLEMENT=COMPLEMENT, NCOMPLEMENT=NCOMPLEMENT

;+
; NAME:
;		VALID_DATA
;
; PURPOSE:
;		This function applies the NARR standard set of criteria to determine the valid and invalid data.
;
; CATEGORY:
;		DATA
;
; CALLING SEQUENCE:
;		R = VALID_DATA([1.0,2.0,-1.0,3.0],PROD='CHLOR_A',SUBS=SUBS) 
;
; INPUTS:
;		ARRAY.....	Usually floating point data ARRAY
;		PROD......
;
;
; OUTPUTS:
;		Data ARRAY with the same data as the input array, except data that do not fall within the criteria range are changed to MISSINGS()
;		
; OPTIONAL OUTPUTS:
;		SUBS.......... Array of subscripts with VALID data
;		COUNT......... Number of VALID data
;		COMPLEMENT.... Subscripts of the INVALID data
;		NCOMPLEMENT... Number of INVALID data
;		
;	PROCEDURE:
;		The Standard NARR criteria range are passed to WHERE_CRITERIA to determine valid and invalid data
;		Invalid data are set to the NARR standard Missing Code for that data type.
;
; EXAMPLE:
;   PRINT, VALID_DATA([1.0,2.0,-1.0,3.0],PROD='CHLOR_A',SUBS=SUBS) & PRINT, SUBS
;   PRINT, VALID_DATA([1.0,2.0,-1.0,3.0],RANGE=[1.5,3.5],SUBS=SUBS) & PRINT, SUBS	
;   PRINT, VALID_DATA([1.0,2.0,-1.0,3.0],RANGE=[1.5,3.5],CRITERIA_TXT=CRITERIA_TXT) & PRINT, CRITERIA_TXT 
;   PRINT, VALID_DATA([1.0,2.0,-1.0,3.0],RANGE=[1.0,4.0],OPERATORS=['GE','LT'],SUBS=SUBS,NCOMPLMENENT=NCOMPLMENENT,COUNT=COUNT) & PRINT, SUBS, COUNT, NCOMPLEMENT
;   PRINT, VALID_DATA([1.0,2.0,-1.0,3.0],RANGE=[1.0,4.0],OPERATORS=['GT','LT'],SUBS=SUBS,COMPLEMENT=COMPLEMENT) & PRINT, SUBS, COMPLEMENT
;
;
; MODIFICATION HISTORY:
;			Written Nov 21, 2006 by J.O'Reilly, 28 Tarzwell Drive, NMFS, NOAA 02882 (Jay.O'Reilly@NOAA.GOV)
;			Modified:
;			  FEB 13, 2017 - KJWH: Overhauled and updated program to be consistent with new programs
;			                       Added several examples
;			  MAR 15, 2017 - KJWH: Changed 'CRITERIA' to 'PROD_CRITERIA' consistent with updates in VALIDS   
;			  MAR 16, 2017 - KJWH: Changed IF N_ELEMENTS(RANGE) NE 2 to IF NONE(RANGE) - WHERE_CRITERIA will sort out the RANGE input                  
;-
;	****************************************************************************************************
	ROUTINE_NAME = 'VALID_DATA'
	ERROR = ''
	
	IF NONE(RANGE) THEN VRANGE = VALIDS('PROD_CRITERIA',PROD) ELSE VRANGE = RANGE
	IF VRANGE EQ [] THEN MESSAGE,'ERROR: Invalid prod - range not found'
	
	SUBS = WHERE_CRITERIA(ARRAY,OPERATORS=OPERATORS,RANGE=VRANGE,NCOMPLEMENT=NCOMPLEMENT,COMPLEMENT=COMPLEMENT,CRITERIA_TXT=CRITERIA_TXT,COUNT)

	IF NCOMPLEMENT GE 1 THEN ARRAY[COMPLEMENT] = MISSINGS(ARRAY)
	  
	RETURN,ARRAY

END; #####################  End of Routine ################################
