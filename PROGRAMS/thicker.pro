; $ID:	THICKER.PRO,	2020-07-08-15,	USER-KJWH	$

  PRO THICKER,thick
;+
; NAME:
;       THICKER
;
; PURPOSE:
;
;
; CATEGORY:
;
;
; CALLING SEQUENCE:
;       THICKER,thick
;
; INPUTS:
;
;
; KEYWORD PARAMETERS:
;
; OUTPUTS:
;
; SIDE EFFECTS:
;      Changes values in !X , !Y and !P system variables
;
; RESTRICTIONS:
;       None.
;
; PROCEDURE:
;       Straightforward.
;
; MODIFICATION HISTORY:
;       Written by:  J.E.O'Reilly, Setptember 12, 1997


IF N_ELEMENTS(THICK) EQ 0 THEN THICK = 1.0
IF N_ELEMENTS(THICK) EQ 1 THEN THICK = [thick[0],thick[0],thick[0]]
IF N_ELEMENTS(THICK) EQ 2 THEN THICK = [thick[0],thick[1],thick[1]]



!P.THICK=thick[0]
!X.THICK=thick[1]
!Y.THICK=thick(2)



END ; END OF PROGRAM
