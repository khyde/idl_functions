; $ID:	MPEG_MAKE.PRO,	2020-07-08-15,	USER-KJWH	$

   PRO MPEG_MAKE, FILES     = files, $
                  TYPE      = type,$
                  SCALE     = scale,$
                  ORDER     = order,$
                  MPEG_NAME = mpeg_name,$
                  PAL       = pal,$
                  QUIET     = quiet
;+
; NAME:
;       MPEG_MAKE
;
; PURPOSE:
;       Make a MPEG movie loop from input 8-bit image files
;
; CATEGORY:
;       Image Display
;
; CALLING SEQUENCE:
;       mpeg_make,files='    *.gif'
;
; INPUTS:
;       Any 8bit 2 dimensional image file which READALL.PRO can read
;       (GIF, BMP, PCX, DSP, BINARY IDL IMAGES, ETC)
;
; KEYWORD PARAMETERS:
;       FILES:  The names of input image file
;
;       TYPE:   The type of input image files (see READALL.PRO)
;
;       SCALE:  The scaling factor to shrink (SCALE=0.5) or enlarge (SCALE=2)
;               the size of the input image files
;
;       ORDER:  Reverses display order (see MPEG)
;
;       MPEG_NAME: The name of the outpu mpeg file (default name is 'idl.mpg'
;
;       PAL:       The idl palette number (e.g. 1, 2, etc.) to use or
;                  The name of a palette program (e.g. 'petes24', 'pal_sw2',etc.)

;       QUIET:  Prevents the display of each image to the graphics device
;
; OUTPUTS:
;       An MPEG movie loop
;
; SIDE EFFECTS:
;       None.
;
; RESTRICTIONS:
;       ALL IMAGE FILES MUST BE SAME DIMENSION (AS FIRST IMAGE)
;       SCALE FACTOR MUST BE BETWEEN 1/64 AND 64/1 .
;
; PROCEDURE:
;       Straightforward.
;
; MODIFICATION HISTORY:
;       Written by:  J.E.O'Reilly and S.Baker
;                    NOAA, Narragansett Laboraory, RI
;                    August 27,1998
;       Sept. 4,1998 added palette (Pal) keyword
;       If reading dsp assume petes24 palette
;       Sept 23,1998 used congrid instead of rebin
;-


; ==============>
; Make sure names of images are provided
  IF N_ELEMENTS(FILES) LT 1 THEN BEGIN
     FILES = DIALOG_PICKFILE(/multiple_files)
  ENDIF

; ===============>
; Get the dimensions from the first image file
  IMAGE = READALL(FILES[0],RED=R,GREEN=G,BLUE=B,PX=PX,PY=PY, TYPE=type)
  IF N_ELEMENTS(PX)  NE 1 THEN BEGIN
    s=SIZE(IMAGE,/STRUCT)
    PX = S.DIMENSIONS[0]
  ENDIF
  IF N_ELEMENTS(PY)  NE 1 THEN BEGIN
    s=SIZE(IMAGE,/STRUCT)
    PY = S.DIMENSIONS[1]
  ENDIF
  IF N_ELEMENTS(SCALE) NE 1 THEN SCALE = 1


  _px = px
  _py = py
; Make sure scale factore is within range accepted by this program
  IF SCALE LT 1./64. OR SCALE GT 64./1. THEN SCALE = 1

; ================>
; Scale if required
  MPEG_PX = PX*SCALE
  MPEG_PY = PY*SCALE

; =================>
  IF NOT KEYWORD_SET(ORDER) THEN ORDER = 1

; ==============>
; Make a True Color array
  I = BYTARR(3,MPEG_PX,MPEG_PY)

; ====================>
; Get the mpegID and dimension the mpeg
  mpegID = MPEG_OPEN([MPEG_PX,MPEG_PY],MOTION_VEC_LENGTH=1)


; =====================>
; For each of the image files
  FOR NTH = 0,N_ELEMENTS(FILES)-1L DO BEGIN
    AFILE = FILES[NTH]
    PRINT, AFILE
;   Get an image
    IMAGE = READALL(AFILE,TYPE=type,red=r,green=g,blue=b,px=_px,py=_py)

;   ====================>
;   Make sure that all image dimensions are same as first image
    IF _px NE PX or _py NE PY THEN BEGIN
      PRINT,'ERROR: IMAGE SIZE NOT IDENTICAL TO SIZE OF FIRST IMAGE"
      RETUN
    ENDIF

; =================>
  IF N_ELEMENTS(PAL) EQ 1 THEN BEGIN
   IF IDLTYPE(pal,/CODE) EQ 7 THEN BEGIN
     CALL_PROCEDURE,PAL,R,G,B
   ENDIF
   IF IDLTYPE(pal,/CODE) NE 7 THEN BEGIN
     LOADCT,PAL
     TVLCT,R,G,B,/GET
   ENDIF

  ENDIF

  IF N_ELEMENTS(PAL) EQ 0 THEN BEGIN
    IF TYPE EQ 'DSP' THEN   CALL_PROCEDURE,PAL,R,G,B
  ENDIF


;   Fill the array wih the appropriate color for
;   each pixel

    IF SCALE NE 1 THEN IMAGE = CONGRID(IMAGE,MPEG_PX,MPEG_PY,/CUBIC)




    I(0,*,*) = R(IMAGE)
    I(1,*,*) = G(IMAGE)
    I(2,*,*) = B(IMAGE)

    MPEG_PUT, mpegID,FRAME=NTH,IMAGE=I,ORDER=ORDER


;   ====================>
    IF NOT KEYWORD_SET(QUIET) THEN BEGIN
;     load the rgb values into display
      TVLCT,R,G,B
      TV,I,TRUE=1,ORDER= (1- ORDER)
    ENDIF

 ENDFOR

; ====================>
; Save and Close the mpeg
  IF N_ELEMENTS(MPEG_NAME) EQ 0 THEN MPEG_NAME ='idl.mpg'
  MPEG_SAVE, mpegID, FILENAME=mpeg_name
  MPEG_CLOSE, mpegID

END ; End of Program
