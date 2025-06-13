; $Id: str_format.pro,  Oct 28,2000 J.E.O'Reilly Exp $

function str_format,data,FORMAT=format
;+
; NAME:
;       str_format
;
; PURPOSE:
;       Work around limitation of idl to format string arrays larger than 1024 :
;       '% STRING: Explicitly formatted output truncated at limit of 1024 lines.'
;
; CATEGORY:
;
;
; CALLING SEQUENCE:
;       Result = str_format(data)
;
; INPUTS:
;       data
;       FORMAT (IDL FORMAT)
;
; KEYWORD PARAMETERS:
;
; OUTPUTS:
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
;       Written by:  J.E.O'Reilly, Oct 28,2000.
;-


; ****************************
; Process in chunks of 1024 lines
; Because IDL can only handle 1024 lines or we get the idl error:
;  '% STRING: Explicitly formatted output truncated at limit of 1024 lines.'

  IF N_ELEMENTS(FORMAT) NE 1 THEN FORMAT=''

; Force block between 1 and 1024
  block = 512
  NRECS = N_ELEMENTS(DATA)
  TEXT  = STRARR(NRECS)
  GROUPS = NRECS / BLOCK
  IF  NRECS MOD BLOCK GT 0L THEN GROUPS = GROUPS + 1L
    START = 0L - BLOCK
    FOR _GROUP=0L,GROUPS -1L DO BEGIN
      START = START + BLOCK
      IF _GROUP EQ GROUPS-1L THEN FINISH = START + (0 > (NRECS MOD BLOCK -1L) ) ELSE FINISH = START + BLOCK -1L
      TEXT(START:FINISH)= STRING(DATA(START:FINISH),FORMAT=FORMAT)
    ENDFOR
    RETURN, TEXT
  END
