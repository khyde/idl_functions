; $ID:	SET_DRAW.PRO,	2020-07-08-15,	USER-KJWH	$

 PRO SET_DRAW,    SLIDE=slide, FIGURE=figure,_EXTRA=_extra
;+
; NAME:
;       SET_DRAW
;
; PURPOSE:
;       SET UP DEFAULT PLOTTING CHARACTERISTICS
;
; CATEGORY:
;       PLOT
;
; CALLING SEQUENCE:
;       SET_DRAW
;
; INPUTS:
;       USUAL IDL GRAPHIC KEYWORDS
;
; KEYWORD PARAMETERS:
;
; OUTPUTS:
;
; SIDE EFFECTS:
;       Changes IDL System variables !P, !X, !Y
;
; RESTRICTIONS:
;       None.
;
; PROCEDURE:
;       Straightforward.
;
; MODIFICATION HISTORY:
;       Written by:  J.E.O'Reilly, September 9,1999
;-


  IF NOT KEYWORD_SET(FIGURE) OR KEYWORD_SET(SLIDE) THEN BEGIN
    COLS = !P.MULTI[1] > 1
    ROWS = !P.MULTI(2) > 1
    N    = COLS
    F    = N^(0.5)
    !P.CHARSIZE = 1.0*F
    IF N EQ 1 THEN !P.CHARSIZE=1.25
    !P.CHARTHICK= 2 > 1.0*F
    !P.THICK    = 2 > CEIL(F)
    !X.THICK    = 2 > CEIL(F)
    !Y.THICK    = 2 > CEIL(F)
    !X.TICKV    = 0
    !Y.TICKV    =0
    !X.TICKNAME = ''
    !Y.TICKNAME = ''



  ENDIF






  END
