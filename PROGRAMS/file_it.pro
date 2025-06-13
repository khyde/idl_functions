; $ID:	FILE_IT.PRO,	2017-01-20,	USER-KJWH	$
;+
; ######################################################################### 
  PRO FILE_IT, FILE, VERBOSE=VERBOSE

;  PURPOSE:   THIS PROGRAM CREATES A NEW SYSTEM VARIABLE,!F WHICH STORES A KEY FILE NAME SO THAT SUBSEQUENT PROGRAMS MAY REFERENCE IT
;
; CATEGORY: FILES
;  
; KEYWORDS:  NONE
;
; OPTIONAL KEYWORDS: 
;   VERBOSE..... Prints '!F = '+ FILE
;
; EXAMPLE: 
;          FILE_IT,'JUNK.DAT' & P,!F
;
;                    
; MODIFICATION HISTORY:
;     MAR 30, 2015 WRITTEN BY: J.E. O'REILLY
;     JAN 20, 2017 - KWJH: Added a VERBOSE keyword
; #########################################################################
;-
;*************************
  ROUTINE_NAME  = 'FILE_IT'
;*************************
  
  IF NONE(FILE) THEN FILE = ''
  DEFSYSV, '!F',FILE 
  IF KEY(VERBOSE) THEN PRINT,'!F = '+ FILE

DONE:
END; #####################  END OF ROUTINE ################################
