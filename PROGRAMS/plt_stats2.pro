; $ID:	PLT_STATS2.PRO,	2014-03-26 16	$
;#########################################################################
 PRO PLT_STATS2, OBJ,STRUCT=STRUCT,_EXTRA=_EXTRA
;+
; NAME:
;       PLT_STATS2
;
; PURPOSE:
;       PLOT THE REGRESSION SLOPE FROM STATS2 ATOP AN EXISTING PLOT
;
; CATEGORY:
;      PLOT
;
; CALLING SEQUENCE:
;       PLT_STATS2,OBJ,STRUCT=STRUCT

;
; INPUTS:
;       OBJ: PLOT OBJECT
;
; KEYWORD PARAMETERS:
;        STRUCT      : OUTPUT FROM STATS2 REGRESSION
;       _EXTRA      : MAY CONTAIN ANY IDL KEYWORDS WHICH ARE VALID FOR THE PLOT FUNCTION
;
; OUTPUTS: OVERPLOTS THE REGRESSION SLOPE LINE ATOP EXISTING PLOT
;
; SIDE EFFECTS:
;       
;
; RESTRICTIONS:
;       ASSUMES YOU HAVE ALREADY ISSUED A PLOT COMMAND.

;
; MODIFICATION HISTORY:
;       WRITTEN BY:  J.E.O'REILLY, FEB 10, 1997.
;       MAR 13,2014,JOR: COPIED FROM ONE2ONE FORMATTING
;                        ADDED KEYWORD OBJ [FOR NEW GRAPHICS]
;       APR 19,2014,JOR  ADDED NEW LOGICAL FUNCTIONS
;-

; ############################################################################
;*************************** 
ROUTINE_NAME = 'PLT_STATS2'
;***************************
;
;##### IS PLOT OBJECT OBJECT PRESENT ? #####
IF NONE(OBJ) THEN MESSAGE,'ERROR: PLOT OBJECT IS REQUIRED'
IF IDLTYPE(OBJ) NE 'OBJREF' THEN MESSAGE,'ERROR: OBJ MUST BE A PLOT OBJECT'
;||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
  
;##### MAKE SURE THE INPUT STRUCT IS FROM STATS2 #####
NAMES = TAG_NAMES(STRUCT)
TARGETS = ['INT','SLOPE','RSQ'] 
OK = WHERE_IN(NAMES,TARGETS,COUNT) 
IF COUNT NE 3 THEN MESSAGE,'ERROR: STRUCT IS NOT FROM STATS2'
;|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
;
;##########################################################
;===> GET X AND Y DATA FOR SUBSEQUENT PLOTTING ONE2ONE LINE
OBJ.GETDATA, X, Y
S = SORT(X) & X=X(S) 
XX = [STRUCT.INT,X,MAX(Y)]
;XX = [MIN(Y),X,MAX(Y)]
YY = STRUCT.INT + STRUCT.SLOPE* XX




P=PLOT(XX,YY,/OVERPLOT,THICK = 9,COLOR = 'RED')
P=PLOT(XX,YY,/OVERPLOT,THICK = 7,COLOR = 'WHITE')
;||||||||||||||||||||||||||||||||||||||||||||||||

DONE:          
  END; #####################  END OF ROUTINE ################################

