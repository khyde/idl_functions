; $Id:	zwin.pro,	May 17 2011	$

 PRO ZWIN,IMG
;+
; NAME:
;       ZWIN
;
; PURPOSE:
;
;       Directs Graphic Output to a Z Window and,
;       with a follow-up call, restores graphic device
;
; CATEGORY:
;       Graphics
;
; CALLING SEQUENCE:
;       ZWIN,IMAGE
;       ZWIN  ; WHEN DONE
;
; INPUTS:
;       IMAGE:  A 2D IMAGE ARRAY
;            :  OR THE WINDOW DESTINATION SIZE  [1024,1024]
;
; KEYWORD PARAMETERS:
;       NONE
; OUTPUTS:
;
; SIDE EFFECTS:
;       CREATES A Z BUFFER GRAPHICS WINDOW
;       TEMPORARILY CHANGES THE IDL PROMPT (!PROMPT).
;
; RESTRICTIONS:
;       None.
;
; PROCEDURE:
;       Straightforward.
;
; MODIFICATION HISTORY:
;       Written by:  J.E.O'Reilly, November 8,2000
;-

 CATCH,ERROR_STATUS
 IF ERROR_STATUS NE 0 THEN BEGIN
    ERROR = 1 & ERROR_STATUS=0 
    STOP
  ENDIF

 IF !D.NAME NE 'Z' OR N_ELEMENTS(IMG) GE 1 THEN BEGIN
    DEFSYSV, '!PREV_DEVICE',!D.NAME
    DEFSYSV, '!TEMP_X',!X
    DEFSYSV, '!TEMP_Y',!Y
    DEFSYSV, '!TEMP_Z',!Z
    DEFSYSV, '!TEMP_P',!P
    SET_PLOT,'Z'
  ENDIF ELSE BEGIN
;   Close the Z DEVICE only if ZWIN is given with no qualifiers
    DEVICE,/CLOSE
    SET_PLOT, !PREV_DEVICE
    !X = !TEMP_X
    !Y = !TEMP_Y
    !Z = !TEMP_Z
    !P = !TEMP_P
    RETURN
  ENDELSE



; ====================>
; Get size of image or intended graphics z window
  s=SIZE(IMG)
  IF s(0) EQ 2 THEN BEGIN ; Image is 2-dimensions
    px = s(1) & py=s(2)
  ENDIF
  IF s(0) EQ 1 THEN BEGIN ; Image is array with 2 elements
    IF s(1) EQ 2 THEN BEGIN
      px = IMG(0) & py = IMG(1)
    ENDIF
  ENDIF
  IF s(0) EQ 0 THEN BEGIN ; Image is not provided
    px = 1024 & py = 1024
  ENDIF

; ====================>
; Set the graphics device to the 'Z' device
  DEVICE,SET_RESOLUTION=[PX,PY],  SET_COLORS=256

  END; #####################  End of Routine ################################
