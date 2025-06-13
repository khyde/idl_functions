; $ID:	GMEAN.PRO,	2018-03-25-14,	USER-JEOR	$
; #########################################################################; 
FUNCTION GMEAN,A,B,DIMENSION=DIMENSION
;+
; PURPOSE:  RETURN THE GEOMETRIC MEAN OF THE INPUT ARR
;
; CATEGORY: STATS;
;
;
; INPUTS: 
;        A..... ARRAY OF DATA
;;       B..... ARRAY OF DATA

;
; KEYWORDS:  NONE

; OUTPUTS:
;         GEOMETRIC MEAN OF FINITE DATA
;
;; EXAMPLES:
;     P,GMEAN(10)
;     P,GMEAN([1.,10.,100.])
;     P,GMEAN([1.,10.,100.,!VALUES.F_INFINITY]); SHOWS NON-FINATE ARE IGNORED
;     P,GMEAN([1.,10.,100.,!VALUES.F_NAN])
;     P,GMEAN([0.01,0.1,1.,10.,100.,1000.0,10000.0,!VALUES.F_NAN])
;
; MODIFICATION HISTORY:
;     SEP 30, 2016  WRITTEN BY: J.E. O'REILLY
;     MAR 25,2018 JEOR: REPLACED ARG_PRESENT(A) WITH ANY(A)
;-
; #########################################################################

;***********************
ROUTINE  = 'GMEAN'
;***********************
IF ANY(A) AND ANY(B) THEN BEGIN
 RETURN, MEAN([[A],[B]],DIMENSION = 2)  
ENDIF ELSE BEGIN
  RETURN,EXP(MEAN(ALOG(A),/NAN,/DOUBLE,DIMENSION=DIMENSION))
ENDELSE;IF ANY(A) AND ANY(B) THEN BEGIN



END; #####################  END OF ROUTINE ################################
