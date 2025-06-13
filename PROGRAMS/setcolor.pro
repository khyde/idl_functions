; $ID:	SETCOLOR.PRO,	OCTOBER 03,2013 	$
;##########################################################################
 PRO SETCOLOR,BACK,COLOR

;+
; NAME:
;       SETCOLOR
;
; PURPOSE:
;       SETS UP BACKGROUND AND DEFAULT COLOR INDEX
; CATEGORY:
;       GRAPHICS.
;
; CALLING SEQUENCE:
;       SETCOLOR)
;       SETCOLOR,0
;       SETCOLOR,0,255
;       SETCOLOR,255,0
; INPUTS:
;       INTEGERS FROM 0 TO 255 REPRESENTING THE DESIRED BACKGROUND COLOR
; OUTPUTS:
;       SETS !P.BACKGROUND AND !P.COLOR
;
; MODIFICATION HISTORY:
;       WRITTEN BY:    J.E.O'REILLY, MARCH 23,1995
;				JAN 2004, JOR,  TRUE COLOR
;       SEPT.15,2010,JOR REMOVED FAULTY IF LOGIC REGSARDING N_PARAMS()  AT BOTTOM OF PROGRAM
;       OCT 3,2013,JOR, FORMATTING
;##########################################################################

;************************
ROUTINE_NAME = 'SETCOLOR'
;************************

  IF N_PARAMS() EQ 0 THEN BEGIN
    !P.BACKGROUND = 0
    !P.COLOR      = !D.N_COLORS -1
  ENDIF

  IF N_PARAMS() EQ 1 THEN BEGIN
    IF BACK GE 0 AND BACK LE 255 THEN BEGIN
     !P.BACKGROUND = TC(BACK)
     !P.COLOR = TC((ABS(BACK -255 )))
    ENDIF
  ENDIF
  IF N_PARAMS() EQ 2 THEN BEGIN
    IF BACK GE 0 AND BACK LE 255 AND COLOR GE 0 AND COLOR LE 255 THEN BEGIN
      !P.BACKGROUND = TC(BACK)
      !P.COLOR = TC(COLOR)
    ENDIF 
  ENDIF

END; #####################  END OF ROUTINE ################################

