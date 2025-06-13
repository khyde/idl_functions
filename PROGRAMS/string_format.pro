; $Id: STRING_FORMAT.pro $
;+
;   Work around limitation of idl to format string arrays larger than 1024 :
;       '% STRING: Explicitly formatted output truncated at limit of 1024 lines.'
;	This Function Program
; SYNTAX:
;	Result = STRING_FORMAT(Data)
; OUTPUT:
;	STRING
; ARGUMENTS:
; 	Data:	IDL data to format into a string
; KEYWORDS:
;	FORMAT:	IDL FORMAT
; EXAMPLE:
; CATEGORY:
;	DT
; NOTES:
; VERSION:
;	Jan 22,2001
; HISTORY:
;	Oct 28, 2000	Written by:	J.E. O'Reilly, NOAA, 28 Tarzwell Drive, Narragansett, RI 02882
;-
; *************************************************************************

FUNCTION STRING_FORMAT, Data, FORMAT=format
  ROUTINE_NAME='STRING_FORMAT'

; ****************************
; Process in chunks of 1024 lines
; Because IDL can only handle 1024 lines or we get the idl error:
;  '% STRING: Explicitly formatted output truncated at limit of 1024 lines.'

  IF N_ELEMENTS(FORMAT) NE 1 THEN FORMAT=''
  block = 512
  nrecs = N_ELEMENTS(Data)
  text  = STRARR(nrecs)
  groups = nrecs / block
  IF  nrecs MOD block GT 0L THEN groups = groups + 1L
    start = 0L - block
    FOR _group=0L,groups -1L DO BEGIN
      start = start + block
      IF _group EQ groups-1L THEN finish = start + (0 > (NRECS MOD BLOCK -1L) ) ELSE finish = start + BLOCK -1L
      TEXT(start:finish)= STRING(Data(start:finish),FORMAT=FORMAT)
    ENDFOR
    RETURN, TEXT
END; #####################  End of Routine ################################
