; $ID:	GET_ROUTINE.PRO,	2020-07-08-15,	USER-KJWH	$
;+
;	This Function returns the name of the Routine that Calls this program
; HISTORY:
;		Jan 16, 2003	Written by:	J.E. O'Reilly, NOAA, 28 Tarzwell Drive, Narragansett, RI 02882
;-
; *************************************************************************

FUNCTION GET_ROUTINE
  ROUTINE_NAME='GET_ROUTINE'
  HELP,CALLS=CALLS & FN=PARSE_IT(CALLS[1]) & CALLING_ROUTINE = FN.FIRST_NAME
  RETURN, CALLING_ROUTINE
END; #####################  End of Routine ################################
