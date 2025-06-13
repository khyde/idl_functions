; $ID:	D3_INTERP_BLANK.PRO,	2020-06-30-17,	USER-KJWH	$
;############################################################################################
 FUNCTION D3_INTERP_BLANK, JDS=JDS, INTERP_DATA=INTERP_DATA, INTERP_JD=INTERP_JD, SPAN=SPAN
;+
; NAME:
;       D3_INTERP_BLANK
;
; PURPOSE:
;				BLANK (MAKE MISSING) INTERPOLATED OBSERVATIONS WHERE ORIGINAL DATES EXCEED THE INPUT DATE SPAN
;				
; KEYWORDS:
;   JDS............ ARRAY OF JULIAN DAYS FOR THE ORIGINAL NON-MISSING DATA
;   INTERP_DATA.... ARRAY OF INPUT INTERPOLATED DATA
;   INTERP_JD...... ARRAY OF JULIAN DAYS FOR THE INTERPOLATED DATA
;   SPAN........... THE WIDTH OF THE ALLOWED INTERPOLATION WINDOW.  IF THE JD RANGE EXCEEDS THIS SPAN, THEN BLANK THE DATA.
;
; COPYRIGHT:
; Copyright (C) 2018, Department of Commerce, National Oceanic and Atmospheric Administration, National Marine Fisheries Service,
;   Northeast Fisheries Science Center, Narragansett Laboratory.
;   This software may be used, copied, or redistributed as long as it is not sold and this copyright notice is reproduced on each copy made.
;   This routine is provided AS IS without any express or implied warranties whatsoever.
;
;   This program was written by John E. O'Reilly, DOC/NOAA/NMFS/NEFSC Narragansett, RI
;          with assistance from Kimberly Hyde, DOC/NOAA/NMFS/NEFSC Narragansett, RI, kimberly.hyde@noaa.gov.  Inquiries should be directed to kimberly.hyde@noaa.gov.
;
; MODIFICATION HISTORY:
;     Written:  April 30, 2004 by John E. O'Reilly, NOAA/NEFSC/Narragansett Laboratory, 28 Tarzwell Drive, 02882
;     Modified:
;       NOV 21, 2011 - JEOR: REMOVED UNUSED KEYWORDS DATA, AND MISS (BECAUSE MISSINGS.PRO FUNCTION IS ALWAYS USED)
;       JAN 09, 2013 - JEOR: FORMATTING
;       JAN 20, 2017 - KJWH: CHANGED FROM A PROGRAM TO A FUNCTION 
;                            CHANGED NAME FROM TS_INTERP_BLANK TO D3_INTERP_BLANK
;                            FORMATTING
;       FEB 22, 2019 - KJWH: Changed default SPAN from 45 to 15 days 
;                            Fixed bug that was skipping the JD loop.   
;                              Changed: FOR _JD = 0L,N_ELEMENTS(JD)-2L DO BEGIN        
;                              to:      FOR _JD = 0L,N_ELEMENTS(JDS)-2L DO BEGIN   
;                            Added steps to check the span before the first JD and after the last JD to blank out the ends if they exceed the span.             
;                            
;############################################################################################
;-
;**************************************
  ROUTINE_NAME='D3_INTERP_BLANK'
;**************************************
     
; ===> DEFAULT SPAN:
  IF NONE(SPAN) THEN SPAN = 15 ; DAYS
  SPAN = DOUBLE(SPAN)
  N_INTERP=N_ELEMENTS(INTERP_DATA)

; ===> CHECK INPUT DATA
  IF N_ELEMENTS(INTERP_JD) NE N_INTERP THEN MESSAGE, 'ERROR: JDS AND DATA MUST HAVE THE SAME SIZE ARRAYS.' 

;	===> BLANK OUT INTERPOLATED DATA THAT EXCEED THE TIME SPAN (IN DAYS)
	IN_START = 0UL

; ===> CHECK THE SPAN BETWEEN THE FIRST/LAST INPUT JD AND FIRST/LAST INTERPOLATED JD
  OK = WHERE(INTERP_JD LT JDS[0]-SPAN,COUNT) & IF COUNT GT 1 THEN INTERP_DATA[OK] = MISSINGS(INTERP_DATA)
  OK = WHERE(INTERP_JD GT JDS(-1)+SPAN,COUNT) & IF COUNT GT 1 THEN INTERP_DATA[OK] = MISSINGS(INTERP_DATA)
    
;	FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
	FOR _JD = 0L,N_ELEMENTS(JDS)-2L DO BEGIN
		JD_THIS = JDS(_JD)
		JD_NEXT   = JDS(_JD+1)
;		===> FIND THE INTERP_JD ENCOMPASSING THE JD RANGE
		IF JD_NEXT-JD_THIS GT SPAN THEN BEGIN

;			FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
			FOR IN = IN_START, N_INTERP-1L DO BEGIN
				IF INTERP_JD(IN) GT JD_THIS THEN BEGIN
					BSTART=IN
;					FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
					FOR BOUT = BSTART,N_INTERP-1L DO BEGIN
						IF INTERP_JD(BOUT) LT JD_NEXT THEN BEGIN
							INTERP_DATA(BOUT) = MISSINGS(INTERP_DATA(BOUT))
						ENDIF ELSE BEGIN
							IN_START = BOUT +1L
							GOTO, NEXT
						ENDELSE ; IF INTERP_JD(BOUT) LT JD_NEXT THEN BEGIN
					ENDFOR ; FOR BOUT = BSTART,N_INTERP-1L DO BEGIN
					;FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
				ENDIF ; IF INTERP_JD(IN) GT JD_THIS THEN BEGIN
			ENDFOR ; FOR IN = IN_START, N_INTERP-1L DO BEGIN
			;FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
		ENDIF
    NEXT:
	ENDFOR ; FOR _JD = 0L,N_ELEMENTS(JD)-2L DO BEGIN
  ;FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF

  RETURN, INTERP_DATA
END; #####################  END OF ROUTINE ################################
