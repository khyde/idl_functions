; $Id: NICENUM.PRO ,version Jan 5,1999  J.E.O'Reilly Exp $

function NICENUM, DATA ,PLACES, BASE=base
;+
; NAME:
;       NICENUM
;
; PURPOSE:
;       Generate a nice number
;
; CATEGORY:
;       MATH
;
; CALLING SEQUENCE:
;       Result = NICENUM(a)
;
; INPUTS:
;       NUMBER
;
; KEYWORD PARAMETERS:
;
; OUTPUTS:
;       A NICE NUMBER
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
;       Written by:  J.E.O'Reilly, Jan 5,1999
;
;-

  IF N_ELEMENTS(PLACES) NE 1 THEN PLACES = 1
  IF N_ELEMENTS(BASE) NE 1 THEN BASE = 10.0

  txt = STRTRIM(STRING(LONG(DATA)),2)
  LEN = STRLEN(txt)
  NUM = LONG(STRMID(txt,0,places))

  N = LONG(DATA*(BASE^PLACES))
  N=ALOG10(DATA*(BASE^PLACES))

  N = CEIL(N)
  RETURN, BASE^N






  END ; END OF PROGRAM
