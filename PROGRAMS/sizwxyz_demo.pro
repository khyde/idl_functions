; $ID:	SIZWXYZ_DEMO.PRO,	2017-01-21,	USER-JEOR	$
; #########################################################################; 
PRO SIZWXYZ_DEMO
;+
; PURPOSE:  DEMO FOR SIZEXYZ
;
; CATEGORY: DEMO;
;
;
; INPUTS: NONE
;
;
; KEYWORDS:  NONE

; OUTPUTS: SCREEN
;

;
; MODIFICATION HISTORY:
;     JAN 21, 2017  WRITTEN BY: J.E. O"REILLY
;-
; #########################################################################

;************************
ROUTINE = "SIZWXYZ_DEMO"
;************************
                  
                  
PRINT,"SIZEXYZ([]); NULL "                     & PRINT & ST,SIZEXYZ([])                             & ENTER
PRINT,"SIZEXYZ(JUNK); JUNK NOT DEFINED "       & PRINT & ST,SIZEXYZ(JUNK)                           & ENTER
PRINT,"SIZEXYZ([256,512])  "                   & PRINT & ST,SIZEXYZ([256,512])                      & ENTER
PRINT,"SIZEXYZ(BYTARR(256,512))  "             & PRINT & ST,SIZEXYZ(BYTARR(256,512))                & ENTER
PRINT,"SIZEXYZ([3,256,512])  "                 & PRINT & ST,SIZEXYZ([3,256,512])                    & ENTER
PRINT,"SIZEXYZ(BYTARR(3,256,512))  "           & PRINT & ST,SIZEXYZ(BYTARR(3,256,512))              & ENTER
PRINT,"SIZEXYZ([256,128])  "                   & PRINT & ST,SIZEXYZ([256,128])                      & ENTER
PRINT,"SIZEXYZ([256,128,64]) "                 & PRINT & ST,SIZEXYZ([256,128,64])                   & ENTER
PRINT,"SIZEXYZ(['A'])  "                       & PRINT & ST,SIZEXYZ(["A"])                          & ENTER
PRINT,"SIZEXYZ(ALPHABET()) "                   & PRINT & ST,SIZEXYZ(ALPHABET())                     & ENTER
PRINT,"SIZEXYZ(['CAT'])  "                     & PRINT & ST,SIZEXYZ(["CAT"])                        & ENTER
PRINT,"SIZEXYZ(['A','B','C'])  "               & PRINT & ST,SIZEXYZ(["A","B","C"])                  & ENTER
PRINT,"SIZEXYZ([-1.0,0.0,1.0]) "               & PRINT & ST,SIZEXYZ([-1.0,0.0,1.0])                 & ENTER
PRINT,"SIZEXYZ(REFORM(ALPHABET(),2,13))  "     & PRINT & ST,SIZEXYZ(REFORM(ALPHABET(),2,13))        & ENTER
PRINT," SIZEXYZ(INTARR(5)) "                   & PRINT & ST, SIZEXYZ(INTARR(5))                     & ENTER
PRINT," SIZEXYZ([120L,120L]) "                 & PRINT & ST, SIZEXYZ([120L,120L])                   & ENTER
PRINT," SIZEXYZ([120UL,120UL]) "               & PRINT & ST, SIZEXYZ([120UL,120UL])                 & ENTER
PRINT," SIZEXYZ([ULONG64(120),ULONG64(120)]) " & PRINT & ST, SIZEXYZ([ULONG64(120),ULONG64(120)])   & ENTER
PRINT,"SIZEXYZ(['256','512'])  "               & PRINT & ST,SIZEXYZ(['256','512'])                  & ENTER
PRINT,"SIZEXYZ(FINDGEN([1024,1024])) "         & PRINT & ST,SIZEXYZ(FINDGEN([1024,1024]))           & ENTER
PRINT,"SIZEXYZ([1024L,1024L])  "               & PRINT & ST,SIZEXYZ([1024L,1024L])                  & ENTER
                  

END; #####################  END OF ROUTINE ################################
