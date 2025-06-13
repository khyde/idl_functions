; $ID:	REBIN_DEMO.PRO,	2015-09-26	$
;+
; ######################################################################### 
  PRO REBIN_DEMO

;  PURPOSE:  THIS IS A DEMO FOR REBIN SHOWING RESAMPLING WHEN MINIFYING AN ARRAY,
;            AND COMPARING WITH CONGRID RESULTS

; CATEGORY: DEMO
; 

;###################################################################################


; MODIFICATION HISTORY:
;      WRITTEN BY J.O'REILLY AND K.J.W. HYDE SEP 24,2015
;-
; #########################################################################

;***************************
ROUTINE_NAME  = 'REBIN_DEMO'
;***************************
;===> #####   SWITCHES 
  DO_SHRINK_1D				=	'' 
  DO_SHRINK_2D        = '' 
  DO_CENTER           = 'S' 
;||||||||||||||||||||||||||

;******************************
IF KEY(DO_SHRINK_1D) THEN BEGIN
;******************************
  SWITCHES,DO_SHRINK_1D,STOPP=STOPP,OVERWRITE=OVERWRITE,VERBOSE=VERBOSE,INIT=INIT,R_FILES=R_FILES,R_DATASETS=R_DATASETS,R_MAPS=R_MAPS
  A = FINDGEN(4) ;&A(3) = MISSINGS(A)
  B = REBIN(A,2)
  PRINT,A
  PRINT
  PRINT,B
  PRINT, MEAN(A([0,1])), MEAN(A([2,3]))
  PRINT
ENDIF ; IF DO_SHRINK_1D GE 1 THEN BEGIN
; |||||||||||||||||||||||||||||||||||||
; 
;******************************
IF KEY(DO_SHRINK_2D) THEN BEGIN
;******************************
  SWITCHES,DO_SHRINK_2D,STOPP=STOPP,OVERWRITE=OVERWRITE,VERBOSE=VERBOSE,INIT=INIT,R_FILES=R_FILES,R_DATASETS=R_DATASETS,R_MAPS=R_MAPS,SWITCH_NAME=SWITCH_NAME
  A = FINDGEN([4,4])
  B = REBIN(A,2,2)
  PRINT,A
  PRINT
  PRINT,B
  PRINT
  PRINT, MEAN(A([0,1,4,5]))  , MEAN(A([2,3,6,7]))
  PRINT, MEAN(A([8,9,12,13])), MEAN(A([10,11,14,15]))

ENDIF ; IF DO_SHRINK_2D GE 1 THEN BEGIN
; |||||||||||||||||||||||||||||||||||||
;******************************
IF KEY(DO_CENTER) THEN BEGIN
  ;******************************
  SWITCHES,DO_CENTER,STOPP=STOPP,OVERWRITE=OVERWRITE,VERBOSE=VERBOSE,INIT=INIT,R_FILES=R_FILES,R_DATASETS=R_DATASETS,R_MAPS=R_MAPS
  A =  & B = REBIN(INDGEN([2,2]),4,4)
  C = REBIN(A,4,4,/SAMPLE)

  PRINT,A
  PRINT
  PRINT,B
  PRINT
  PRINT,C
  PRINT, MEAN(A([0,1,4,5]))  , MEAN(A([2,3,6,7]))
  PRINT, MEAN(A([8,9,12,13])), MEAN(A([10,11,14,15]))

ENDIF ; IF DO_CENTER GE 1 THEN BEGIN
; |||||||||||||||||||||||||||||||||||||



END; #####################  END OF ROUTINE ################################
