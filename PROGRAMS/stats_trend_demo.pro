; $ID:	STATS_TREND_DEMO.PRO,	2020-07-01-12,	USER-KJWH	$
; 
PRO STATS_TREND_DEMO

; #########################################################################; 
;+
; THIS PROGRAM IS A  DEMO ROUTINE FOR STATS_TRENDS


; HISTORY:
;     SEPT 3, 2014  WRITTEN BY: J.E. O'REILLY
;-
; #########################################################################

;*****************************
ROUTINE_NAME  = 'STATS_TREND_DEMO'
;*****************************

; SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS
; SSSSS       S W I T C H E S      CONTROLLING WHICH PROCESSING STEPS TO DO SSSSS
;SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS;	
; 0 (DO NOT DO THE STEP)
;	1 (DO THE STEP)
; 2 (DO THE STEP AND OVERWRITE ANY OUTPUT IF IT ALREAD EXISTS)
; 3 (STOP IN THE STEP)
; ================>
; SWITCHES CONTROLLING WHICH PROCESSING STEPS TO DO:
  DO_DOUBLE				= 1
  DO_STEP_2 			= 0
  DO_STEP_3  			= 0
  DO_STEP_4 		  = 0

;SSSSS     END OF SWITCHES     SSSSS

; ****************************
 	IF DO_DOUBLE GE 1 THEN BEGIN
; ****************************
    , 'DO_DOUBLE'
    OVERWRITE = DO_DOUBLE EQ 2   & IF DO_DOUBLE EQ 3 THEN STOP 
    DATE_RANGE = ['19980101','20131231']
    JD = DATE_2JD(DATE_GEN(DATE_RANGE,UNITS = 'DAY'))
    INC = 1./(N_ELEMENTS(JD)-1)
    DATA = INTERVAL([1,2],INC) & PN,DATA
    S = STATS_TREND(JD,DATA,DATE_RANGE = DATE_RANGE,MAP = 'TEST',JUNK = 'JUNKY',JAY = 'JAY',YYYY = 'YYYY') 
    ST,S
    P
    , 'DO_DOUBLE'
  ENDIF ; IF DO_DOUBLE GE 1 THEN BEGIN
; ||||||||||||||||||||||||||||||||||||


; ****************************
  IF DO_STEP_2 GE 1 THEN BEGIN
; ****************************
    , 'DO_STEP_2'
    OVERWRITE = DO_STEP_2 EQ 2   & IF DO_STEP_2 EQ 3 THEN STOP     
    
     
    , 'DO_STEP_2'
  ENDIF ; IF DO_STEP_2 GE 1 THEN BEGIN
; ||||||||||||||||||||||||||||||||||||

; ****************************
IF DO_STEP_3 GE 1 THEN BEGIN
  ; ****************************
  , 'DO_STEP_3'
  OVERWRITE = DO_STEP_3 EQ 2   & IF DO_STEP_3 EQ 3 THEN STOP



  , 'DO_STEP_3'
ENDIF ; IF DO_STEP_3 GE 1 THEN BEGIN
; ||||||||||||||||||||||||||||||||||||

; ****************************
IF DO_STEP_4 GE 1 THEN BEGIN
  ; ****************************
  , 'DO_STEP_4'
  OVERWRITE = DO_STEP_4 EQ 2   & IF DO_STEP_4 EQ 3 THEN STOP



  , 'DO_STEP_4'
ENDIF ; IF DO_STEP_4 GE 1 THEN BEGIN
; ||||||||||||||||||||||||||||||||||||



END; #####################  END OF ROUTINE ################################
