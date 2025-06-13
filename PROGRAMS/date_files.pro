; $ID:	DATE_FILES.PRO,	2020-07-08-15,	USER-KJWH	$

  FUNCTION DATE_FILES, FILES, DAYS=days,  $
  		  							 DATE_RANGE=date_range,   QUIET=quiet
;+
; NAME:
;       DATE_FILES
;
; PURPOSE:
;       Return a subset of Files based on MTIME and a criterion supplied as a keyword.
; CATEGORY:
;       FILE

; INPUTS:
;       FILE NAMES OR WILDCARD
;				DEFAULT: Returns files made today
;				DAYS:    Decimal Days before the present time
;				DATE:    May be one or two dates representing the target date window
;
;
;	NOTES: PC: WINDOWS stores the maketime (mtime) as GMT which is calculated from
;  					 local time using the offset (from GMT in hours) selected by the user
;						 in the Windows Control Panel (Date/Time).
;						 Therefore, to find files based on their MTIME, GMT time is used.
;
; MODIFICATION HISTORY:
;       Written by:  J.E.O'Reilly, 1998
;				Sept 20, 2003, JOR, UPDATED USING FILE_INFO instead of call to dos (dir)
;				OCT 23, 2017 - KJWH: Changed RETURN, '' to RETURN, [] to be consistent with other programs
;-

	ROUTINE_NAME = 'DATE_FILES'


  IF N_ELEMENTS(FILES) LT 1 THEN RETURN, []
  IF N_ELEMENTS(DAYS) EQ 0 AND N_ELEMENTS(DATE_RANGE) EQ 0 THEN DAYS = 1

	SEC_PER_DAY		=	SECONDS_DAY()

	OK_ASTER = WHERE_STRING(FILES,'*',COUNT)
	IF COUNT GE 1 THEN _FILES = FILE_SEARCH(FILES) ELSE _FILES = FILES
	FI = FILE_INFO(_FILES)

;	===> Default is today
	IF N_ELEMENTS(DAYS) EQ 1 THEN BEGIN
		JD_GMT		= SYSTIME(/JULIAN,/UTC)

 		DATE_END 		= JD_2DATE(JD_GMT)
 		MTIME_END  	= JD_2SECONDS1970(JD_GMT)
		DATE_START 	= STRMID(DATE_END,0,8) + '000000'
		JD_START 		= DATE_2JD(DATE_START)
		JD_START 		= JD_START - LONG((1>DAYS) -1)
		DATE_START	=	JD_2DATE(JD_START)
	  MTIME_START  = JD_2SECONDS1970(JD_START)

  	IF NOT KEYWORD_SET(QUIET) THEN $
  		PRINT,'Finding Files Since: ' + DATE_FORMAT(DATE_START) + ' (GMT)'

 		OK=WHERE(FI.MTIME GE MTIME_START[0],COUNT)
  	IF COUNT GE 1 THEN BEGIN
  		RETURN, _FILES[OK]
  	ENDIF ELSE BEGIN
  		RETURN, ''
  	ENDELSE
	ENDIF


	IF N_ELEMENTS(DATE_RANGE) EQ 2 THEN BEGIN
		DATE_START		= JD_2DATE(DATE_2JD(DATE_RANGE[0]))
		DATE_END	 		= JD_2DATE(DATE_2JD(DATE_RANGE[1]))

 		MTIME_START		= JD_2SECONDS1970(DATE_2JD(DATE_START)) ; DATE COULD BE 8,10,12,14 CHARS
 		MTIME_END  		= JD_2SECONDS1970(DATE_2JD(DATE_END))

  	IF NOT KEYWORD_SET(QUIET) THEN $
  		PRINT,'Finding Files From: ' + DATE_FORMAT(DATE_START) +' to ' + DATE_FORMAT(DATE_END) + ' (GMT)'

 		OK=WHERE(FI.MTIME GE MTIME_START[0] AND FI.MTIME LE MTIME_END[0],COUNT)
  	IF COUNT GE 1 THEN BEGIN
  		RETURN, _FILES[OK]
  	ENDIF ELSE BEGIN
  		RETURN, []
  	ENDELSE
	ENDIF

  DONE:

  END; #####################  End of Routine ################################

