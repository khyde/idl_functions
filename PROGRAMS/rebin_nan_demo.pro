; $ID:	REBIN_NAN_DEMO.PRO,	2020-07-01-12,	USER-KJWH	$
; 
PRO REBIN_NAN_DEMO

; #########################################################################; 
;+
; PURPOSE:   A DEMO FOR COMPARING REBIN WITH REBIN_NAN


; MODIFICATION HISTORY:
;    SEP 29,2015  WRITTEN BY: K.J.W.HYDE [JUNK_REBIN_TEST]
;    OCT 23,2015,JOR REFORMATTED TO A DEMO PROGRAM
;-
; #########################################################################

;*********************************
ROUTINE_NAME  = 'REBIN_NAN_DEMO'
;*********************************
;===> SWITCHES
DO_DICK_JACKSON      = 'S'
DO_REBIN_VS_FREEBIN  = ''
DO_MISSINGS          = ''        
DO_32768_X_16384     = ''
;||||||||||||||||||||||||
;
;*********************************
IF KEY(DO_DICK_JACKSON) THEN BEGIN
;*********************************
  SWITCHES,DO_DICK_JACKSON,STOPP=STOPP,OVERWRITE=OVERWRITE,VERBOSE=VERBOSE,INIT=INIT,R_FILES=R_FILES,R_DATASETS=R_DATASETS
  IF STOPP THEN STOP
;REBIN_NAN

;FROM: Dick Jackson Software Consulting                 http://www.d-jackson.com
;Victoria, BC, Canada             +1-250-220-6117       di...@d-jackson.com
;
;I have regular arrayed data (1440*720). I'd like to change this data
;to 360*180 array.
;So I use 'Rebin' function.
;But these data have NaN value.
;If I use Rebin and there is a NaN value, new array becomes also NaN.
;For example, if there is only one NaN in the old array, the new-array
;becomes NaN. But I want to make a new array except NaN data. This
;situation makes residual data wasteful.
; A = [1.5,2.5,3.6,4,7,8.8,9.0,!values.f_nan]
;print, rebin(A, 1)
;;result is 'NAN'
;;That I expected value is mean(A, /nan)
;Is there any know-how to change array except NaN?
;
;
;
;
;Hi all,
;"Nick" <jungb...@hotmail.com> wrote in message 
;news:1184534401.344733.293590@i38g2000prf.googlegroups.com...
;- show quoted text –

;
;Just to clear up one possible confusion, IDL's Rebin() does handle each 
;resulting bin separately, so any bin with no NaNs comes up fine:
;IDL> A = [1.5,2.5,3.6,4,7,8.8,9.0,!values.f_nan]
;IDL> print,rebin(a,4)
;2.00000 3.80000 7.90000 NaN

;Rebin() gives a NaN result if any value in the bin is NaN. Now, what I think 
;Nick wants is for each bin to receive the mean of the finite values (the 
;non-NaNs, or NaNaNs! or perhaps Ns... :-) that are present. 
;A reasonable  request, in the spirit of Mean(array, /NaN). 
;I don't think there's a built-in way to do this NaN-tolerant Rebin, so here's my attempt.
;I take the first dimension (1440) and split it into two dimensions (4, 360). I 
;take the second dimension (720) and split it into two more dimensions (4, 180). 
;Then I use Total(/NaN) to squash out the extra dimensions, getting the total of 
;the desired values in each resulting array element. A similar Total-ing on the 
;count of Finite() values gives the count of values summed for each result. 
;Divide each total by each count and you get the mean of each bin's finite 
;values. If a bin had all NaNs, the result should be NaN as well.
;-----
;PRO RebinNaNTest
a = FIndGen(1440,720)                   ; Sample data
a[1] = !values.f_nan                    ; to make one element NaN
;a[*,0:2] = !values.f_nan                ; to make three rows NaN
;a[*,0:3] = !values.f_nan                ; to make four rows NaN
Print, 'Rebin method:'
rebinResult = Rebin(a,360,180)
Print, rebinResult[0:1, 0:1]
b = Reform(a, 4, 360, 4, 180)           ; Make separate 'b' array in
                                        ; case you want to see this:
print,total(a[0:3,0:3])
 ;         NaN
print,total(a[0:3,0:3],/NaN)
;      34583.0
print,total(b[*,0,*,0],/NaN)
;      34583.0
;;    But in practice, you could reform 'a' in place,
;;    which saves memory and is very fast:
   a = Reform(a, 4, 360, 4, 180, /Overwrite)
Print
Print, 'RebinNaN method:'
sumFinite = Total(Total(b, 3, /NaN), 1, /NaN)
nFinite = Total(Total(Finite(b), 3, /NaN), 1, /NaN)
result = sumFinite/nFinite
Print, result[0:1, 0:1]


ENDIF;IF KEY(DICK_JACKSON) THEN BEGIN
;|||||||||||||||||||||||||||||||||||||||||||||||||||
;***************************
IF KEY(DO_REBIN_VS_FREEBIN) THEN BEGIN
;***************************
  SWITCHES,DO_REBIN_VS_FREEBIN,STOPP=STOPP,OVERWRITE=OVERWRITE,VERBOSE=VERBOSE,INIT=INIT,R_FILES=R_FILES,R_DATASETS=R_DATASETS,R_MAPS=R_MAPS,R_PRODS=R_PRODS,DATERANGE=DATERANGE
  CLEAR
  IF VERBOSE THEN , 'DO_REBIN_VS_FREEBIN'
  ARR = FINDGEN(8,8)
  P,'ARR:FINDGEN(8,8)'
  P, ARR
  P
  P, 'REBIN 4,4'
  P, REBIN(ARR,4,4)
  P
  P, 'FREBIN 4X4'
  P, FREBIN(ARR,4,4)
  P
  P, 'FREBIN 3X3'
  P, FREBIN(ARR,3,3)
  IF STOPP THEN STOP

  IF VERBOSE THEN , 'DO_REBIN_VS_FREEBIN'
ENDIF ; IF DO_REBIN_VS_FREEBIN GE 1 THEN BEGIN
; ||||||||||||||||||||||||||||||||||||||||||||
; 
;*****************************
IF KEY(DO_MISSINGS) THEN BEGIN
;*****************************
  SWITCHES,DO_MISSINGS,STOPP=STOPP,OVERWRITE=OVERWRITE,VERBOSE=VERBOSE,INIT=INIT,R_FILES=R_FILES,R_DATASETS=R_DATASETS
  CLEAR
  IF VERBOSE THEN , 'DO_MISSINGS'

  P, 'ARRAY WITH MISSINGS'
  A = FINDGEN(6,6)                   ; SAMPLE DATA
  SUBS = [1,4,8,16,24]
  A(SUBS) = MISSINGS(A)
  P, A
  P
  P, 'REBIN RETURNS MISSINGS:'
  P,REBIN(A,3,3)
  P
  P, 'REBIN_NAN RETURNS MEANS WITHOUT THE MISSING DATA:'
  B = REFORM(A, 2, 3, 2, 3)           ; MAKE SEPARATE 'B' ARRAY  - TO SAVE MEMORY, COULD REWRITE A AS:  A = REFORM(A, 2, 3, 2, 3, /OVERWRITE)
  SUMFINITE = TOTAL(TOTAL(B, 3, /NAN), 1, /NAN)
  NFINITE = TOTAL(TOTAL(FINITE(B), 3, /NAN), 1, /NAN)
  RESULT = SUMFINITE/NFINITE
  P, RESULT
  P
  IF STOPP THEN STOP
  IF VERBOSE THEN , 'DO_MISSINGS'

ENDIF;IF KEY(DO_MISSINGS) THEN BEGIN
;||||||||||||||||||||||||||||

;**********************************
IF KEY(DO_32768_X_16384) THEN BEGIN
;**********************************
  SWITCHES,DO_32768_X_16384,STOPP=STOPP,OVERWRITE=OVERWRITE,VERBOSE=VERBOSE,INIT=INIT,R_FILES=R_FILES,R_DATASETS=R_DATASETS
  CLEAR
  IF VERBOSE THEN , 'DO_32768_X_16384'

  P
  A = FINDGEN(32768,16384)                   ; SAMPLE DATA
  SUBS = FIX(10000000*RANDOMU(SEED,100000))
  A(SUBS) = MISSINGS(A)
  P, 'START WITH 32768 X 16384 ARRAY WITH ' + NUM2STR(N_ELEMENTS(SUBS)) + ' MISSING VALUES'
  P
 
  P, 'ORIGINAL REBIN'
  TIC
  R = REBIN(A,4096,2048)
  TOC
  OK = WHERE(R EQ MISSINGS(R),COUNT)
  P, 'REBIN RETURNS 4096 X 2048 ARRAY WITH ' + NUM2STR(COUNT) + ' MISSING VALUES'

  P
  P, 'REBIN_NAN'
  TIC
  A = REFORM(A, 8, 4096, 8, 2048,/OVERWRITE)
  SUMFINITE = TOTAL(TOTAL(A, 3, /NAN), 1, /NAN)
  NFINITE = TOTAL(TOTAL(FINITE(A), 3, /NAN), 1, /NAN)
  RESULT = SUMFINITE/NFINITE
  TOC
  OK = WHERE(RESULT EQ MISSINGS(RESULT),COUNT)
  P, 'REBIN_NAN RETURNS 4096 X 2048 ARRAY WITH ' + NUM2STR(COUNT) + ' MISSING VALUES'
  P


  IF STOPP THEN STOP
  IF VERBOSE THEN , 'DO_32768_X_16384'

ENDIF;IF KEY(DO_32768_X_16384) THEN BEGIN
;||||||||||||||||||||||||||||


 IF VERBOSE THEN 


END; #####################  END OF ROUTINE ################################
