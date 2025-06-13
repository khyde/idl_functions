; $Id: PLOT_STRUCT.pro,  March 23,2000 J.E.O'Reilly Exp $

PRO PLOT_STRUCT,array, XVAR=XVAR,PMULTI=pmulti, TITLE_PAGE=TITLE_PAGE, COLOR_SYM=color_sym, _EXTRA=_extra
;+
; NAME:
;       PLOT_STRUCT
;
; PURPOSE:
;       Characterize data in a structure
;
; CATEGORY:
;
;
; CALLING SEQUENCE:
;       uniqlist
;
; INPUTS:
;        array
;
; KEYWORD PARAMETERS:
;        quiet :    Prevents printing text results to sceen
;        pmulti:	Plots all structure variables on one page.
;
; OUTPUTS:
;        ARRAY OF elements

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
;       Written by:  J.E.O'Reilly, Dec 6, 1995.
;-

; ====================>

IF N_ELEMENTS(TITLE_PAGE) NE 1 THEN TITLE_PAGE = ' '
SETCOLOR,255
;circle,color=21,thick=1,fill=1

!Y.OMARGIN = [0,2]

tags = TAG_NAMES(array)

IF n_elements(pmulti) EQ 1 THEN BEGIN
  ;!P.MULTI=[0,CEIL(N_ELEMENTS(tags)^.5), CEIL(N_ELEMENTS(tags)^.5)]
  SET_PMULTI,N_ELEMENTS(TAGS)
ENDIF
IF N_ELEMENTS(PMULTI) GE 3 THEN BEGIN
  !P.MULTI = PMULTI
ENDIF


  FOR _tags = 0, (N_ELEMENTS(tags) -1) DO BEGIN
; get one tag and sort in ascending order
  data = array.(_tags)
  OK = WHERE(DATA EQ MISSINGS(DATA),COUNT)
  IF COUNT GE 1 THEN PRINT, TAGS(_TAGS) ,COUNT,' MISSING'


  IF KEYWORD_SET(pmulti) EQ 0 THEN BEGIN
    YN = WIDGET_MESSAGE(' PLOT  TAG  '+TAGS(_TAGS),/QUESTION)
    IF YN EQ 'Yes' THEN BEGIN
      OK = WHERE(FINITE(DATA),COUNT)
      IF N_ELEMENTS(XVAR) EQ N_ELEMENTS(DATA) THEN BEGIN
        IF COUNT GE 2 THEN PLOT,XVAR, data, TITLE=TAGS(_TAGS),  XSTYLE=1,YSTYLE=1, _EXTRA=_extra ELSE SKIPPLOT
      ENDIF ELSE BEGIN
        OK = WHERE(FINITE(DATA),COUNT)
        IF COUNT GE 2 THEN PLOT, data, TITLE=TAGS(_TAGS),  XSTYLE=1,YSTYLE=1, _EXTRA=_extra ELSE SKIPPLOT
      ENDELSE
      WSET,0
     ENDIF
   ENDIF

  IF KEYWORD_SET(pmulti) NE 0 THEN BEGIN
      OK = WHERE(FINITE(DATA),COUNT)
      IF N_ELEMENTS(XVAR) EQ N_ELEMENTS(DATA) THEN BEGIN
        IF COUNT GE 2 THEN PLOT,XVAR, data, TITLE=TAGS(_TAGS),  XSTYLE=1,YSTYLE=1, _EXTRA=_extra ELSE SKIPPLOT
      ENDIF ELSE BEGIN
        IF COUNT GE 2 THEN PLOT, data, TITLE=TAGS(_TAGS),  XSTYLE=1,YSTYLE=1, _EXTRA=_extra ELSE SKIPPLOT
      ENDELSE
   ENDIF


   XYOUTS,.5,.99, TITLE_PAGE,/normal,ALIGN=0.5

   CAPTION


   ENDFOR


!Y.OMARGIN = [0,0]

END ; END OF PROGRAM
