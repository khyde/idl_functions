; $ID:	STRUCT_COUNT.PRO,	2020-06-30-17,	USER-KJWH	$

FUNCTION STRUCT_COUNT,STRUCT ,NAME=NAME, FIN=fin
;+
; NAME:
;       STRUCT_COUNT
;
; PURPOSE:
;       Characterize the number of non-missing values in each tag of a structure
;
; MODIFICATION HISTORY:
;       Written by:  J.E.O'Reilly, Jan 10, 2006
;-

; ====================>
 	NTAGS=N_TAGS(STRUCT)
	DB=STRUCT_RETYPE(STRUCT[0],0L)

; LLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLL
  FOR _tag = 0L, NTAGS -1 DO BEGIN
  	OK = WHERE(struct.(_tag) NE MISSINGS(struct.(_tag)),COUNT)
    DB.(_tag) = count
   ENDFOR
RETURN,DB

END ; END OF PROGRAM
