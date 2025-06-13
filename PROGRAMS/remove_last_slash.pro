; $Id: REMOVE_LAST_SLASH.pro $  VERSION: March 26,2002
;+
;	This Function Removes the last path slash if present

; HISTORY:
;		Jul 30,2002	Written by:	J.E. O'Reilly, NOAA, 28 Tarzwell Drive, Narragansett, RI 02882
;		Dec 23, 2020 - KJWH: Now looping on the TEXT array because of a bug when using an array for the last variable of the STRMID
;-
; *************************************************************************

FUNCTION REMOVE_LAST_SLASH,TEXT
  ROUTINE_NAME='REMOVE_LAST_SLASH'

  TXT = TEXT
  FOR T=0, N_ELEMENTS(TXT)-1 DO BEGIN
    TX = TXT[T]  
    DELIM='/';
  	TX = STRMID(TX, 0, STRLEN(TX)-(STRPOS(TX,DELIM,/REVERSE_OFFSET)+1 EQ STRLEN(TX)))
  
  	DELIM='\';
  	TX = STRMID(TX, 0, STRLEN(TX)-(STRPOS(TX,DELIM,/REVERSE_OFFSET)+1 EQ STRLEN(TX)))
    TXT[T] = TX
  ENDFOR  

  RETURN, TXT

END; #####################  End of Routine ################################
