; $ID:	STR_WELD.PRO,	2017-02-15,	USER-JEOR	$
; #########################################################################; 
FUNCTION STR_WELD,AA,BB,CC,DD
;+
; PURPOSE:  WELD TOGETHER UP TO 4 STRING ARRAYS OF UNEQUAL N ELEMENTS
;
; CATEGORY: 
;
;
; INPUTS: UP TO 4 STRING ARRAYS
;
;
; KEYWORDS:  NONE

; OUTPUTS: A WELDED STRING ARRAY
;
;; EXAMPLES:  
;   A = ['ONE','TWO','THREE']& B = ['CAT','DOG'] & C = ['HOUSE','BARN'] & PLIST,STR_WELD(A,B,C)
;   A = ['ONE','TWO','THREE']& B = ['CAT','DOG'] & C = ['HOUSE','BARN']& D = ['1','2'] & PLIST,STR_WELD(A,B,C,D)
; MODIFICATION HISTORY:
;     FEB 22, 2017  WRITTEN BY: J.E. O'REILLY
;-
; #########################################################################

;********************
ROUTINE = 'STR_WELD'
;********************

IF NONE(CC) THEN BEGIN
  CC = ' '
  DD = ' '
ENDIF;IF NONE(CC) THEN BEGIN
  
IF NONE(DD) THEN BEGIN 
  DD = ' '
ENDIF;IF NONE(DD) THEN BEGIN  
  

;[MUST LOOP BECAUSE UNEQUAL N_ELEMENTS]
;FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
FOR A_ = 0,NOF(AA) -1 DO BEGIN
  A = AA(A_)
  ;FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
  FOR B_ = 0,NOF(BB) -1 DO BEGIN
    B = BB(B_)
    ;FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
    FOR C_ = 0,NOF(CC) -1 DO BEGIN
      C = CC(C_)
        ;FFFFFFFFFFFFFFFFFFFFFFFFFFFFF
        FOR D_ = 0,NOF(DD) -1 DO BEGIN
          D = DD(D_) 
          T = STR_JOIN(A,B,C,D,DELIM = ';')
          IF NONE(TXT) THEN TXT = T ELSE TXT = [TXT,T]
        ENDFOR;FOR D_ = 0,NOF(DD) -1 DO BEGIN 
    ENDFOR; FOR C_ = 0,NOF(CC) -1 DO BEGIN
  ENDFOR;FOR B_ = 0,NOF(BB) -1 DO BEGIN
ENDFOR;FOR A_ = 0,NOF(AA) -1 DO BEGIN
TXT =STRCOMPRESS(TXT)
;===> REPLACE ';;' WITH ';'
TXT = REPLACE(TXT,';;',';')
RETURN,TXT
END; #####################  END OF ROUTINE ################################
