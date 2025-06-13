; $ID:	GET_DATERANGE.PRO,	2020-07-08-15,	USER-KJWH	$

  FUNCTION GET_DATERANGE, DATE1, DATE2

;+
; NAME:
;   GET_DATERANGE
;
; PURPOSE:
;   This function will convert a single (or two) dates into a "daterange"
;
; CATEGORY:
;   CATEGORY
;
; CALLING SEQUENCE:
;
; INPUTS:
;   DATE1.....
;   DATE2.....
;
; OUTPUTS:
;   This function returns the "DATERANGE" in the proper format
;
;
; PROCEDURE:
;
; EXAMPLE:
;
; NOTES:
;   
; COPYRIGHT: 
; Copyright (C) 2018, Department of Commerce, National Oceanic and Atmospheric Administration, National Marine Fisheries Service,
;   Northeast Fisheries Science Center, Narragansett Laboratory.
;   This software may be used, copied, or redistributed as long as it is not sold and this copyright notice is reproduced on each copy made.
;   This routine is provided AS IS without any express or implied warranties whatsoever.
;
;   This program was written by Kimberly Hyde, DOC/NOAA/NMFS/NEFSC Narragansett, RI, kimberly.hyde@noaa.gov  
;
; MODIFICATION HISTORY:
;			Written:  Sep 17, 2018 by K.J.W. Hyde, NOAA/NEFSC/Narragansett Laboratory, 28 Tarzwell Drive, 02882 (kimberly.hyde@noaa.gov)
;			Modified: Sep 17, 2018 - KJWH: Added SWITCHES information to get the default DATERANGE
;			          
;-
;	****************************************************************************************************
	ROUTINE_NAME = 'GET_DATERANGE'
	
	SWITCHES,'Y',DATERANGE=DATERANGE
	
	IF NONE(DATE1) THEN RETURN, DATERANGE
	
	IF ANY(DATE1) THEN D1 = NUM2STR(DATE1)
	IF ANY(DATE2) THEN D2 = NUM2STR(DATE2) 
	
	IF N_ELEMENTS(D1) EQ 2 THEN BEGIN
	  D2 = D1[1]
	  D1 = D1[0]
	ENDIF
	
	IF NUMBER(D1) EQ 0 THEN BEGIN
	 DELIMS = [',',' ','_','-']
   DM = REPLICATE(0,N_ELEMENTS(DELIMS))
   FOR D=0, N_ELEMENTS(DELIMS)-1 DO IF HAS(D1,DELIMS(D)) THEN DM(D) = 1
   IF TOTAL(DM) NE 1 THEN RETURN, DATERANGE ; Unable to determine the delimiter or multiple delimiters found
   DELIM = DELIMS[WHERE(DM EQ 1)]
   DTS = STR_BREAK(D1,DELIM)
   IF N_ELEMENTS(DTS) GT 2 THEN RETURN, DATERANGE ; More than 1 "date" found
   D1 = DTS[0]
   D2 = DTS[1]
	ENDIF
	
	IF NONE(D2) THEN D2 = STRMID(D1,0,4)
	
	IF STRLEN(D1) EQ 4 THEN D1 = D1 + '0101'
	IF STRLEN(D2) EQ 4 THEN D2 = D2 + '1231'
	IF STRLEN(D1) EQ 6 THEN D1 = D1 + '01'
	IF STRLEN(D2) EQ 6 THEN D2 = D2 + DAYS_MONTH(STRMID(D2,4,2),/STRING)
	DATERANGE = [D1,D2]
	DATERANGE = [MIN(DATERANGE),MAX(DATERANGE)] ; Make sure the earlier date is first
	RETURN, DATERANGE
	
	
	
	


END; #####################  End of Routine ################################
