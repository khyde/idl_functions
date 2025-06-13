; $ID:	REBIN_NAN.PRO,	2015-10-27	$
; 
FUNCTION REBIN_NAN,ARR,X,Y
; #########################################################################; 
;+
; THIS PROGRAM REBINS AND RETURNS MEANS WITHOUT THE MISSING DATA

; CATEGORY: UTILITY;
;
; CALLING SEQUENCE: RESULT = REBIN_NAN(ARR)
;
; INPUTS: ARR ARRAY

; OPTIONAL INPUTS:
;
; KEYWORD PARAMETERS:
;         SHRINK....... FACTOR TO SHRINK ARR BY [2,4,ETC]

; OUTPUTS:
;

; REFERENCE:
; 
; NOTES: APPROACH FROM: https://groups.google.com/forum/#!searchin/comp.lang.idl-pvwave/REBIN/comp.lang.idl-pvwave/bm_YF-DrNxQ/J61RjxbiWWYJ
;                       DICK JACKSON SOFTWARE CONSULTING                 HTTP://WWW.D-JACKSON.COM
;                       VICTORIA, BC, CANADA             +1-250-220-6117       DI...@D-JACKSON.COM

;        NOT SURE IF BOTH PX,PY ARE BEING TREATED CORRECTLY WHEN PX NOT EQUAL PY?
; 
; 
; EXAMPLES:
;          ARR = FINDGEN(6,6) & ARR([1,4,8,16,24])=MISSINGS(ARR)& P,REBIN_NAN(ARR,3,3)
;          
;          ;DICK_JACKSON'S EXAMPLE
;          ARR = FINDGEN(1440,720) 
;          ARR[1] = !VALUES.F_NAN 
;          B= REBIN(ARR,360,180)& HELP,B &  PRINT, B[0:1, 0:1];NOTE ONE ELEMENT OF B IS NAN
;          B= REBIN_NAN(ARR,360,180)& HELP,B & PRINT, B[0:1, 0:1]
;        
                

; 
; 
; MODIFICATION HISTORY:
;     SOURCE CODE   FROM  DICK JACKSON HTTP://WWW.D-JACKSON.COM
;     OCT 15, 2004  WRITTEN BY: KJW.HYDE & J.E.O'REILLY
;     OCT 27,2015,  JOR ADDED SOURCE CODE,EXAMPLES, X,Y, AND CHECK ON MODULUS OF PX,PY
;-
; #########################################################################

;**************************
ROUTINE_NAME  = 'REBIN_NAN'
;**************************
IF NONE(ARR) OR NONE(X) OR NONE(Y) THEN MESSAGE,'ERROR: MUST PROVIDE ARR,X,Y'
S = SIZEXYZ(ARR)
PX=S.PX & PY = S.PY
IF PX MOD X NE 0  THEN MESSAGE,'ERROR: PX  NOT DIVISIBLE BY ' + STRTRIM(X,2)
IF PY MOD Y NE 0  THEN MESSAGE,'ERROR: PY  NOT DIVISIBLE BY ' + STRTRIM(Y,2)
XF = PX/X
YF = PY/Y
ARR = REFORM(ARR, XF, PX/XF, YF, PY/YF, /OVERWRITE)     
SUMFINITE = TOTAL(TOTAL(ARR, 3, /NAN), 1, /NAN)
NFINITE   = TOTAL(TOTAL(FINITE(ARR), 3, /NAN), 1, /NAN)
RETURN,SUMFINITE/NFINITE

END; #####################  END OF ROUTINE ################################
