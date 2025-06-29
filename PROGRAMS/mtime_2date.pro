; $ID:	MTIME_2DATE.PRO,	2020-06-30-17,	USER-KJWH	$
;+
;	This Function Uses IDL function SYSTIME() to convert SECONDS_SINCE_JAN_1_1970 (e.g. SEE idl FILE_INFO mtime) into DATE (YYYYMMDDHHMMSS)
; SYNTAX:
;	DT_FILEINFO_2DATE,
;	Result  = MTIME_2DATE(SECONDS_SINCE_JAN_1_1970)
; OUTPUT:	DATE
; ARGUMENTS:
; KEYWORDS:;
; EXAMPLE:
; CATEGORY:	DATE
; NOTES:	ON WINDOWS NT  THE TIME STAMPS ARE ACTUALLY IN GMT (EVEN THOUGH WHEN VIEWING THE FILE
;					PROPERTIES THE LOCAL CREATION,ACCESSED, MODIFIED, TIMES IS DISPLAYED)
; HISTORY:
;		Aug 9,2002	Written by:	J.E. O'Reilly, NOAA, 28 Tarzwell Drive, Narragansett, RI 02882
;-
; *************************************************************************

FUNCTION MTIME_2DATE,MTIME
  ROUTINE_NAME='MTIME_2DATE'

;	===> If seconds not provided then assume want current date
  IF N_ELEMENTS(MTIME) EQ 0 THEN RETURN,''

	DATE = STRARR(N_ELEMENTS(MTIME))

	FOR NTH=0L,N_ELEMENTS(MTIME)-1L DO DATE[NTH]  = JD_2DATE(SECONDS1970_2JD(SYSTIME(0, MTIME[NTH],/SECONDS)))
  IF N_ELEMENTS(DATE) EQ 1 THEN RETURN,DATE[0] ELSE RETURN,DATE

END; #####################  End of Routine ################################
