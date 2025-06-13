; $Id:	circle.pro,	October 29 2009	$
  PRO circle,res,rotate=rotate,_extra=_extra

;+
; NAME:
;       circle
;
; PURPOSE:
;       Program uses IDL program USERSYM to
;	    create a CIRCLE (USER SYMBOL #8)
;       for use in plotting.
;
; CATEGORY:
;       Graphics
;
; CALLING SEQUENCE:
;   circle
;		circle,color=128
;  	circle,32,color=128            ; Circle defined by 32 vertices
;   circle,16,color=128, thick=3   ; Thick edge
;		circle,color=128,fill=0        ; Empty circle
;		circle,thick=3,fill=0		       ; Thick empty circle
;		circle,1,fill=0	               ; point
;		circle,2,fill=0                ; short line
;		circle,3,fill=0                ; triangle
;		circle,4,fill=0                ; diamond
;		circle,5,fill=0                ; pentagon
;		circle,6,fill=0                ; hexagon
;
; INPUTS:
;       None Required
;
; KEYWORDS:
;    rotate:   rotates the symbol (use res=2,/rotate to get vertical line symbols)
;    _extra:   Extra parameters to be passed to Routine USERSYM
;
; OUTPUTS:
;       A user symbol (#8) used by plot commands
;
; SIDE EFFECTS:
;       None.
;
; RESTRICTIONS:
;       None.
;
; PROCEDURE:
;       Straightforward.
;		e.g.
;       circle,color=128 & plot,[0,1,2,3,4],[0,1,2,3,4],psym=8,symsize=3
;
;
; MODIFICATION HISTORY:
;       Written by:    J.O'Reilly, April 9, 1994.	NOAA, NMFS, Narragansett Laboratory, 28 Tarzwell Drive, Narragansett, RI 02882-1199
;       Modified by:   K. Hyde, October 29, 2009 - Removed the color option so that the color is controlled in the PLOT command
;
;-

; ====================>
; If resolution parameter (res)not provided then use default (16).
  IF N_PARAMS() EQ 0 THEN BEGIN
    res = 16
  ENDIF ELSE BEGIN
    IF res GT 48 THEN res = 48
    res = res
  ENDELSE

; ====================>
; Generate array
  a = FINDGEN(res) * (!PI*2/res)

; ====================>
; Duplicate the first vertex and place at end of array
  a = [a,a(0)]


; ====================>
; Call IDL USERSYM
  IF KEYWORD_SET(ROTATE) EQ 0 THEN USERSYM,COS(a),SIN(a),/FILL,THICK=1,_extra=_extra $ 
                              ELSE USERSYM,SIN(a),COS(a),/FILL,THICK=1,_extra=_extra
  
  END
; END OF PROGRAM
