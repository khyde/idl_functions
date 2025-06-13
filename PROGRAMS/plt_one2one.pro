; $ID:	PLT_ONE2ONE.PRO,	2020-07-08-15,	USER-KJWH	$
;#########################################################################
 PRO PLT_ONE2ONE, OBJ,_EXTRA=_EXTRA
;+
; NAME:
;       PLT_ONE2ONE
;
; PURPOSE:
;       OVERPLOT A ONE 2 ONE LINE (X=Y) ATOP AN EXISTING PLOT
;
; CATEGORY:
;      PLOT
;
; CALLING SEQUENCE:
;       PLT_ONE2ONE
;       PLT_ONE2ONE, COLOR=126,LINESTYLE=2
;       PLT_ONE2ONE, RATIO=5
;
; INPUTS:
;       NONE REQUIRED.
;
; KEYWORD PARAMETERS:
;        RATIO      : RATIO OF Y TO X (USED TO DRAW A 2:1 , 3:1 , 1:5 CURVE ETC.)
;       _EXTRA      : MAY CONTAIN ANY IDL KEYWORDS WHICH ARE VALID FOR THE PLOT FUNCTION.
;
; OUTPUTS:
;
; SIDE EFFECTS:
;       OVERPLOTS A LINE ATOP AN EXISTING PLOT
;
; RESTRICTIONS:
;       ASSUMES YOU HAVE ALREADY ISSUED A PLOT COMMAND.

;
; MODIFICATION HISTORY:
;       WRITTEN BY:  J.E.O'REILLY, FEB 10, 1997.
;       MAR 13,2014,JOR: COPIED FROM ONE2ONE FORMATTING
;                        ADDED KEYWORD OBJ [FOR NEW GRAPHICS]
;       APR 19,2014,JOR ADDED NEW LOGICAL FUNCTIONS
;       APR 27,2014,JOR:NAME = STRUPCASE(OBJ.NAME)
;                       IF NAME EQ 'IMAGE' THEN OBJ.GETDATA, IMAGE,X, Y
;                       IF NAME EQ 'PLOT' THEN OBJ.GETDATA,X, Y;
;       MAY 1,2014,JOR: IF WHERE_STRING(NAME,'IMAGE') NE -1  THEN OBJ.GETDATA, IMAGE,X, Y


; ############################################################################
;***************************
ROUTINE_NAME = 'PLT_ONE2ONE'
;***************************
;##### IS PLOT OBJECT OBJECT PRESENT ? #####
IF NONE(OBJ) THEN MESSAGE,'ERROR: PLOT OBJECT IS REQUIRED'
IF IDLTYPE(OBJ) NE 'OBJREF' THEN MESSAGE,'ERROR: OBJ MUST BE A PLOT OBJECT'
;||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
;
;#################################################################
;===> GET X AND Y RANGE FOR THE ONE2ONE LINE
NAME = STRUPCASE(OBJ.NAME)
IF WHERE_STRING(NAME,'IMAGE') NE -1  THEN OBJ.GETDATA, IMAGE,X, Y
IF WHERE_STRING(NAME,'PLOT') NE -1  THEN OBJ.GETDATA,X, Y
XRANGE = OBJ.XRANGE
XX = [X,XRANGE[1]]
YY = XX
;XX = OBJ.XRANGE
;YY = OBJ.YRANGE

P=PLOT(XX,YY,/OVERPLOT,THICK = 3,_EXTRA=_EXTRA)

;|||||||||||||||||||||||||||||||||||||||||||||| 
 
DONE:          
  END; #####################  END OF ROUTINE ################################

