; $ID:	ZW.PRO,	2020-07-08-15,	USER-KJWH	$
  PRO  ZW, IMAGE

; ====================>
; Open a z window and size it to image

  s=SIZE(IMAGE)
  IF s[0] EQ 2 THEN BEGIN ; Image is 2-dimensions
    px = s[1] & py=s(2)
  ENDIF
  IF s[0] EQ 1 THEN BEGIN ; Image is array with 2 elements
    IF s[1] EQ 2 THEN BEGIN
      px = IMAGE[0] & py = image[1]
    ENDIF
  ENDIF
  IF s[0] EQ 0 THEN BEGIN ; Image is not provided
    px = 800 & py = 600
  ENDIF


  IF !D.NAME NE 'Z' THEN BEGIN
   !PROMPT = !D.NAME + '>Z'
    SET_PLOT,'Z'
    DEVICE,SET_RESOLUTION=[PX,PY],Z_BUFFERING=0
  ENDIF ELSE BEGIN
    POS = RSTRPOS(!PROMPT,">Z")
    IF POS THEN BEGIN
;     Close the Z Device only if zw is given with no qualifiers
;     Check if any commands to device were given or if HELP is used
      done = N_ELEMENTS(image) EQ 0
      IF done THEN BEGIN ;If done is 1 (true) then close the postscript file
        DEVICE,/CLOSE
        SET_PLOT,STRMID(!PROMPT,0,pos)
        !PROMPT = 'IDL>'
        RETURN
      ENDIF
    ENDIF
  ENDELSE



; ==============>
 IF s[0] EQ 2 THEN TV,image


END
