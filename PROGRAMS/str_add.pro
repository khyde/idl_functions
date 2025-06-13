; $ID:	STR_ADD.PRO,	2020-06-30-17,	USER-KJWH	$

FUNCTION STR_ADD,DATA,ADD, NO_LAST=NO_LAST
;+
; NAME:
;       STR_ADD
;
; PURPOSE:
;       Add a STRING to the end of a string or string array
;
; CATEGORY:
;       STRING
;
; CALLING SEQUENCE:
;       S = STR_ADD(DATA)
;
; INPUTS:
;       String or string ARRAY
;
; KEYWORD PARAMETERS:
;
;       NONE

; OUTPUTS:
;       A STRING with (Default is a SPACE)
;
; SIDE EFFECTS:
;       None.
;
; RESTRICTIONS:
;       None.
;
; PROCEDURE:
;       Straightforward.
;
; MODIFICATION HISTORY:
;       Written by:  J.E.O'Reilly, April 9, 1997.
;       Modified     J.O'R         April 14,1997 Remove last delimiter from string
;-


; ===>
	ROUTINE_NAME='STR_ADD'

  IF N_ELEMENTS(ADD) NE 1 THEN ADD = ' '
  TXT = ''
  N = N_ELEMENTS(DATA)
  NTH = N-1
  FOR _nth = 0, NTH DO BEGIN
    IF _nth NE NTH THEN BEGIN
    	TXT_ =  DATA(_nth) + ADD
    ENDIF ELSE BEGIN
    	IF KEYWORD_SET(NO_LAST) THEN TXT_ = DATA(_nth) ELSE TXT_ = DATA(_nth) + ADD
    ENDELSE
    TXT  = [TXT , TXT_]
  ENDFOR

  TXT = TXT(1:*)
  IF N_ELEMENTS(TXT) EQ 1 THEN TXT  = TXT[0]


    RETURN, TXT

  END ; END OF PROGRAM
