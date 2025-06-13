; $ID:	PREP.PRO,	2020-06-30-17,	USER-KJWH	$
;+
; ######################################################################### 
  PRO PREP,TXT,NUM,WAIT=WAIT

;  PURPOSE:  THIS PROGRAM PRINTS TXT REPLICATE [MULTIPLE] TIMES

; CATEGORY: PRINT
  
; INPUTS:
;    TXT: TEXT TO PRINT
;    NUM: NUMBER OF TIMES TO PRINT
;
; KEYWORDS:
;    WAIT: TIME IN SECONDS TO WAIT BETWEEN PRINTS

; EXAMPLES:
;   PREP,'HELLO'
;   PREP,'HELLO',9
;   PREP,'HELLO',9,WAIT = .1
;   PREP,'HELLO',9,WAIT = 1

;###################################################################################


; MODIFICATION HISTORY:
;     JAN 4,2015 WRITTEN BY: J.E. O'REILLY

;-
; #########################################################################

;**********************
ROUTINE_NAME  = 'PREP'
;**********************
IF NONE(TXT) THEN GOTO,DONE
IF NONE(NUM) THEN NUM = 1
IF NONE(WAIT) THEN WAIT = 0
TXT = REPLICATE(TXT,NUM)
;FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
FOR NTH = 0, NOF(TXT)-1 DO BEGIN
  PRINT,TXT[NTH]
  WAIT,WAIT 
ENDFOR;FOR NTH = 0 NOF(TXT)-1 DO BEGIN
;FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF


DONE:
END; #####################  END OF ROUTINE ################################
