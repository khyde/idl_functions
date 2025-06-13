; $ID:	LAYOUT_DEMO.PRO,	2020-07-01-12,	USER-KJWH	$
; 
PRO LAYOUT_DEMO

; #########################################################################; 
;+
; THIS PROGRAM IS A  A DEMO FOR USING LAYOUT


; HISTORY:
;     OCT 23, 2014  WRITTEN BY: J.E. O'REILLY
;-
; #########################################################################

;*****************************
ROUTINE_NAME  = 'LAYOUT_DEMO'
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
  DO_PORTRAIT_4	  =	1
  DO_STEP_2 			= 0
  DO_STEP_3  			= 0
  DO_STEP_4 		  = 0

;SSSSS     END OF SWITCHES     SSSSS

; ****************************
 	IF DO_PORTRAIT_4 GE 1 THEN BEGIN
; ****************************
    , 'DO_PORTRAIT_4'
    OVERWRITE = DO_PORTRAIT_4 EQ 2   & IF DO_PORTRAIT_4 EQ 3 THEN STOP
    NUM = 0 
    X = FINDGEN(99)
    Y = X
    W = WINDOW()
    ;FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
    FOR N = 1,4 DO BEGIN
      NUM = NUM+ 1
      LAYOUT = [1,4,NUM]
      XY=BIVARIATE(100)
      PLT_XY,XY.X,XY.Y,$
        LAYOUT=LAYOUT,/CURRENT, OBJ=OBJ,AXES_FONT_SIZE = 16,TITLE = 'DO_PORTRAIT_4',$
        MARGIN = [0.25,0.25,0.25,0.25],/JAY
      
      
;      PLT_XY,X,Y,LAYOUT=LAYOUT,/CURRENT ,$
;      TITLE = 'DO_PORTRAIT_4',OBJ = OBJ ,MARGIN = [0.25,0.25,.25,0.25]
      ;  TITLE = 'DO_PORTRAIT_4',OBJ = OBJ 
   
    ENDFOR;FOR N = 1,4 DO BEGIN
    ;FFFFFFFFFFFFFFFFFFFFFFFFFF
    FILE = !S.IDL_TEMP + ROUTINE_NAME + '.PNG' & PF,FILE
    OBJ.SAVE ,FILE
    OBJ.CLOSE
    , 'DO_PORTRAIT_4'
  ENDIF ; IF DO_PORTRAIT_4 GE 1 THEN BEGIN
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
