; $ID:	TXT2IMG.PRO,	2020-07-08-15,	USER-KJWH	$

function TXT2IMG,image,x,y,text, _EXTRA=_extra
;+
; NAME:
;       TXT2IMG
;
; PURPOSE:
;
;
; CATEGORY:
;
;
; CALLING SEQUENCE:
;       Result = TXT2IMG(text)
;
; INPUTS:
;       a text string with any keywords which XYOUTS can process
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
;       Written by:  J.E.O'Reilly, August, 1, 1997
;-


; ================>
; Get the old graphics device
  old_device=!D.NAME

; ================>
; SIZE THE INPUT IMAGE ARRAY
  S = SIZE(image)
  px = s[1]
  py = s(2)

  IF N_PARAMS() NE 4 THEN MESSAGE,'ERROR: Must Input a 2d array, an x and y coordinate, and a text string'
  IF N_ELEMENTS(X) EQ 0 THEN X = 0
  IF N_ELEMENTS(Y) EQ 0 THEN Y = 0

  SET_PLOT,'Z'
  DEVICE,set_resolution=[PX,PY]
  ERASE,255b

  XYOUTS, X,Y,text,COLOR=0,_EXTRA=_extra

  txtimage = TVRD()
  ok = WHERE(txtimage EQ 0, COUNT)


  SET_PLOT, old_device

  IF count GE 1 THEN BEGIN
   RETURN, ok
  ENDIF ELSE BEGIN
   RETURN, -1
  ENDELSE


  END ; END OF PROGRAM
