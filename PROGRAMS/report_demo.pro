; $ID:	REPORT_DEMO.PRO,	2020-07-01-12,	USER-KJWH	$
; 
PRO REPORT_DEMO

; #########################################################################; 
;+
; THIS PROGRAM IS A DEMO FOR REPORT


; HISTORY:
;     JUL 5, 2014  WRITTEN BY: J.E. O'REILLY
;-
; #########################################################################

;*****************************
ROUTINE_NAME  = 'REPORT_DEMO'
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
  DO_REPORT_PROGRESS				=	1
  DO_STEP_2 			= 0
  DO_STEP_3  			= 0
  DO_STEP_4 		  = 0

;SSSSS     END OF SWITCHES     SSSSS

; ****************************
 	IF DO_REPORT_PROGRESS GE 1 THEN BEGIN
; ****************************
    , 'DO_REPORT_PROGRESS'
    OVERWRITE = DO_REPORT_PROGRESS EQ 2   & IF DO_REPORT_PROGRESS EQ 3 THEN STOP 
    ;FFFFFFFFFFFFFFFFFFFFFF
    FOR NTH = 0,10 DO BEGIN      
      TXT = 'ITERATION = ' +STRTRIM(NTH,2)
      IF NTH EQ 0 THEN REPORT,TXT,/START,/QUIET ELSE REPORT,TXT,/STOP,/QUIET
      WAIT,2      
    ENDFOR;FOR NTH = 0,10 DO BEGIN
    ;FFFFFFFFFFFFFFFFFFFFFFFFFFFFF
    
     
    , 'DO_REPORT_PROGRESS'
  ENDIF ; IF DO_REPORT_PROGRESS GE 1 THEN BEGIN
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
