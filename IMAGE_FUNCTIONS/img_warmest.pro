  FUNCTION img_warmest, FILES=FILES,  $
                clouds = clouds,$
                land   = land,$
                TYPE=TYPE

;  April 14,1998 J.O'Reilly
;
;  composites warmest pixel avhrr;
;

; ====================>
; Get  files

  IF N_ELEMENTS(FILES) EQ 0 THEN BEGIN
    PRINT,'NO FILES FOUND'
    STOP
  ENDIF ELSE BEGIN
    files = FILELIST(files)
  ENDELSE

; ====================>

  IF N_ELEMENTS(clouds) NE 1 THEN READ,CLOUDS,PROMPT='ENTER CLOUD GREY SCALE VALUE'
  IF N_ELEMENTS(land)   NE 1 THEN READ,LAND,  PROMPT='ENTER LAND GREY SCALE VALUE'


  FOR NTH = 0, N_ELEMENTS(FILES)-1 DO BEGIN
    afile = files(nth)
    image = READALL(afile,type=type)

; Change clouds to zero when clouds are a high grey scale value
  OK_CLOUDS = WHERE(IMAGE EQ CLOUDS,COUNT)
  IF COUNT GE 1 THEN IMAGE(OK_CLOUDS) = 0
    OK_LAND   = WHERE(IMAGE EQ LAND,COUNT)
    IF COUNT GE 1 THEN IMAGE(OK_LAND) = 0

    IF NTH EQ 0 THEN BEGIN
      WARMEST =  IMAGE
    ENDIF

    IF NTH GE 1 THEN BEGIN
      WARMEST = WARMEST > IMAGE
    ENDIF

  ENDFOR
; ====================>

  RETURN, WARMEST
  END  ; End of Program

