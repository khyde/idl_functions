; $ID:	TEMPLATE_MAIN.PRO,	2020-07-01-12,	USER-KJWH	$
;+
; ######################################################################### 
  PRO TEMPLATE_MAIN

;  PURPOSE:  THIS IS A TEMPLATE FOR A ROUTINE INVOLVING SEVERAL SEQUENTIAL PROCESSING STEPS

; CATEGORY: TEMPLATES
  
; 
; NOTES:
;   SWITCHES governs which processing steps to do and what to do in the step
;     '' (NULL STRING) = do not do the step
;        ANY ONE OR COMBINATION OF LETTERS WILL RUN THE STEP:
;     Y  = YES do the step
;     O  = OVERWRITE any output
;     V  = VERBOSE (allow PRINT statements)
;     RF = REVERSE the processing order of files in the step
;     S  = STOP at the beginning of the step and step through each command in the step
;     DATERANGE = Daterange for selecting files
;###################################################################################


; MODIFICATION HISTORY:
;     OCT 15, 2004 WRITTEN BY: J.E. O'REILLY
;     NOV 13,2014 JOR REVISED WITH NEW ALPHA SWITCHES
;                 WHICH ALLOW FOR MORE FLEXIBLE CONTROL OF THE PROCESSING
;                 AND FUTURE EXPANSION OF SWITCH CODES
;     NOV 20.2014,JOR IMPLEMENTED SWITCHES FUNCTION SUGGESTED BY K. HYDE
;     DEC 9,2014,JOR REPLACED SWITCHES WITH HAS
;     DEC 29, 2015 - KJWH: REPLACED HAS WITH SWITCHES
;-
; #########################################################################

;*****************************
ROUTINE_NAME  = 'TEMPLATE'
;*****************************


;===> #####   SWITCHES 
  DO_STEP_1				=	'YORFSV'
 
  
;|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||




;***************************
  IF KEY(DO_STEP_1) THEN BEGIN
;***************************
    SNAME = 'DO_STEP_1'
    SWITCHES,DO_STEP_1,STOPP=STOPP,OVERWRITE=OVERWRITE,VERBOSE=VERBOSE,INIT=INIT,R_FILES=R_FILES,R_DATASETS=R_DATASETS,R_MAPS=R_MAPS,DATERANGE=DATERANGE
    IF VERBOSE THEN PRINT, 'Running: ' + SNAME
    IF KEY(STOPP) THEN STOP
    
    FILES = FILE_SEARCH(' ',COUNT=COUNT_FILES); FILL IN THE BLANKS
    FILES = DATE_SELECT(FILES,DATERANGE)
    IF KEY(R_FILES) THEN FILES = REVERSE(FILES)
    
    
    ;FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
    FOR NTH = 0,N_ELEMENTS(FILES)-1 DO BEGIN
      FILE = FILES[NTH]
      IF VERBOSE THEN PFILE,FILE,/U
      IF VERBOSE THEN POF,NTH,FILES
    ENDFOR;FOR NTH = 0,N_ELEMENTS(FILES)-1 DO BEGIN
    ;FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF

    IF VERBOSE THEN , 'DO_STEP_1'
  ENDIF ; IF DO_STEP_1 GE 1 THEN BEGIN
  ; ||||||||||||||||||||||||||||||||||
; 



END; #####################  END OF ROUTINE ################################
