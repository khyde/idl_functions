; $ID:	ZWIN.PRO,	2015-05-08	$
;############################################################################################
 PRO ZWIN,IMG
;+
; NAME:  ZWIN
;     
;
; PURPOSE: DIRECTS GRAPHIC OUTPUT TO A Z-BUFFER WINDOW AND,
;          WITH A FOLLOW-UP CALL, RESTORES GRAPHIC DEVICE
;
; CATEGORY:
;       GRAPHICS
;
; CALLING SEQUENCE:
;       ZWIN,IMG
;       ZWIN  ; WHEN DONE
;
; INPUTS:
;       IMG:  A 2D IMAGE ARRAY
;            :  OR THE WINDOW DESTINATION SIZE  [1024,1024]
;
; KEYWORD PARAMETERS:  NONE
; 
; OUTPUTS: DIMENSIONS THE Z-BUFFER TO HOLD THE IMG
;
; SIDE EFFECTS:
;       CREATES A Z BUFFER GRAPHICS WINDOW
;       TEMPORARILY CHANGES THE IDL PROMPT (!PROMPT).
;
; RESTRICTIONS:
;       NONE.
;
; PROCEDURE:
;       STRAIGHTFORWARD.
;
; MODIFICATION HISTORY:
;       WRITTEN BY:  J.E.O'REILLY, NOVEMBER 8,2000
;       JUL 29,2011,JOR, NOW USING SIZEXYZ
;       FEB 23,2011, JOR, 
;                   IF IMG IS PROVIDED THEN DISPLAY IT TO THE Z-BUFFER
            ;       IF  JUST DIMENSIONS ARE PROVIDED THEN MAKE A BINARY IMG OF ZEROS AND DISPLAY IT TO THE Z-BUFFER
;       JAN 2,2013,JOR:IF S.N_DIMENSIONS EQ 3 THEN TRUE = 1 ELSE TRUE = 0
;                      TV,IMG,TRUE = TRUE
;       DEC 10,2013,KWH CHANGED IMAGE TO IMG 
;       DEC 10,2013,JOR: IF S.N_DIMENSIONS EQ 0 THEN BEGIN ; IMAGE IS NOT PROVIDED
;       APR 17,2015,JOR: IF !D.NAME EQ  'Z' AND NONE(IMG) THEN BEGIN
;                        FIXED PROMPT
;       MAY 08,2015,JOR, REARRANGED NESTING OF LOGIC

;########################################################################################             
;-

;********************
ROUTINE_NAME = 'ZWIN'
;********************
;
;******************************************
IF !D.NAME EQ 'Z' AND NONE(IMG) THEN BEGIN
;******************************************
  ; CLOSE THE Z DEVICE IF Z BUT NO IMG
  DEVICE,/CLOSE
  SET_PLOT, !PREV_DEVICE
  !X = !TEMP_X
  !Y = !TEMP_Y
  !Z = !TEMP_Z
  !P = !TEMP_P
  !PROMPT = 'IDL>'
  RETURN
ENDIF;IF !D.NAME EQ  'Z' AND NONE(IMG) THEN BEGIN
;||||||||||||||||||||||||||||||||||||||||||||||||


;****************************************************
IF !D.NAME NE 'Z' AND N_ELEMENTS(IMG) GE 2 THEN BEGIN
;****************************************************
  DEFSYSV, '!PREV_DEVICE',!D.NAME
  DEFSYSV, '!TEMP_X',!X
  DEFSYSV, '!TEMP_Y',!Y
  DEFSYSV, '!TEMP_Z',!Z
  DEFSYSV, '!TEMP_P',!P
  SET_PLOT,'Z'
  ; ====================>
  ; GET SIZE OF IMG OR INTENDED GRAPHICS Z WINDOW
  S=SIZEXYZ(IMG)
  PX = S.PX
  PY = S.PY
  IF S.N_DIMENSIONS EQ 3 THEN TRUE = 1 ELSE TRUE = 0
  ; ===> SET THE GRAPHICS DEVICE TO THE 'Z' DEVICE
  DEVICE,SET_RESOLUTION=[PX,PY],  SET_COLORS=256
  IF N_ELEMENTS(IMG) GE 2 THEN BEGIN
    TV,IMG,TRUE = TRUE
  ENDIF ELSE BEGIN
    TV,BYTARR(PX,PY),TRUE = TRUE
  ENDELSE;IF N_ELEMENTS(IMG) GE 2 THEN BEGIN

  !PROMPT = !D.NAME + ' >>>>'
ENDIF;IF !D.NAME NE 'Z' OR N_ELEMENTS(IMG) GE 1 THEN BEGIN
;|||||||||||||||||||||||||||||||||||||||||||||||||||||||||
;
; CLOSE THE Z DEVICE ONLY IF ZWIN IS GIVEN WITH NO QUALIFIERS
IF !D.NAME EQ 'Z' AND N_ELEMENTS(IMG) EQ 0 THEN BEGIN
  DEVICE,/CLOSE
  SET_PLOT, !PREV_DEVICE
  !PROMPT = 'IDL>'
  !X = !TEMP_X
  !Y = !TEMP_Y
  !Z = !TEMP_Z
  !P = !TEMP_P
  RETURN
ENDIF;IF !D.NAME EQ 'Z' AND N_ELEMENTS(IMG) EQ 0 THEN BEGIN

;|||||||||||||||||||||||||||||||||




END; #####################  END OF ROUTINE ################################
