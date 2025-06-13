; $ID:	DUPS.PRO,	2020-06-30-17,	USER-KJWH	$

  FUNCTION DUPS,DATA
;+
; NAME:
;       DUPS
;
; PURPOSE:
;       IDENTIFY DUPLICATES IN AN ARRAY
;
; CATEGORY:
;
;
; CALLING SEQUENCE:
;       Result = DUPS(DATA)
;
; INPUTS:
;       DATA (ARRAY)
;
; KEYWORD PARAMETERS:
;       NONE
; OUTPUTS:
;       STRUCTURE WITH SET AND NUMBER PER SET
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
;       Written by:  J.E.O'Reilly, November 27,1999
;-


; =================>
; Sort data and determin unique elements
  S=SORT(DATA)
  U = UNIQ(DATA(S))
  db = CREATE_STRUCT('SET',DATA[0],'N',0L)
  DB = REPLICATE(DB,N_ELEMENTS(U))

; ====================>
  FOR NTH = 0L, N_ELEMENTS(U)-1L DO BEGIN
    DATUM = DATA(S(U[NTH]))
    OK = WHERE(DATA EQ DATUM,COUNT)
    DB[NTH].SET = DATUM
    DB[NTH].N   = COUNT

  ENDFOR
  RETURN, DB
  END ; END OF PROGRAM
