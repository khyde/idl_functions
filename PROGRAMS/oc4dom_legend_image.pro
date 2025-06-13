; $ID:	OC4DOM_LEGEND_IMAGE.PRO,	2020-07-08-15,	USER-KJWH	$
  FUNCTION oc4dom_legend_image ,xtitle=xtitle,GIF=gif,PX=px,PY=py,GRACE=grace ,$
           WHOLE=whole,GREY=grey,$
           NOTES=noteS,NOTE_COLOR=note_color,note_char=note_char,note_pos=note_pos,$
           SHORT=short,BACKGROUND=background,$
           _EXTRA=_extra

;LEG = oc4dom_legend_IMAGE(px=612,py=150,gif='d:\idl\jay\images\oc4dom_legend_image.gif',charsize=2,BACKGROUND=255,pos=[.04,.1,.96,.23]) & SLIDEW,LEG
 DIR_WORK='C:\IDL\JAY\images\'


; Program makes a legend for CZCS DSP images (grey scale)
; GRACE defines the amount of whitespace around the legend
  IF N_ELEMENTS(GRACE) NE 4 THEN grace = [20,20,10,10]


  IF NOT KEYWORD_SET(PX) THEN BEGIN
    PX = 512
  ENDIF
  IF NOT KEYWORD_SET(PY) THEN BEGIN
    PY = 512
  ENDIF



; Note, The Z device is used to obtain the full 0-255 color range for the temp scale
  old_device = !D.NAME
; Get old !x.margin and !y.margin
  old_xmargin=!x.margin
  old_ymargin=!y.margin

  SET_PLOT,'Z'
  DEVICE,SET_RESOLUTION=[PX,PY],Z_BUFFERING=0

  IF NOT KEYWORD_SET(BACKGROUND) THEN BACKGROUND=0B

  SETCOLOR, BACKGROUND

  ERASE
 ;  defont,17
 ; DEFONT,-1
  pal_seawifs
  FONT_TIMES
; ====================>
; JHUAPL program to draw horizontal color bar at bottom of page.
; levels=interval([-6,6],base=2)
; levels spans from 0 to 255 pigment units

   min_color=1
   max_color=4

   min_val  = 1
   max_val  = 4


  COLORS=INDGEN(max_color+1)





  IF KEYWORD_SET(XTITLE) EQ 0 THEN xtitle='Dominant SeaWiFS Band'

  xtickv    = [1,2,3]

;  xtickname = ndecimal(xtickv,trim=3)
  xtickname=['443','490','510']
  Xticks=n_elements(xtickv)-1

  !x.margin=[0,0]
  !y.margin=[0,0]


  cbar,vmin= (min_val),vmax= (max_val) ,$
    cmin=min_color,cmax=max_color,$
  xtickv=xtickv,xtickname=xtickname,xticks=xticks,$
  pos=[.04,.2,.96,.23],$
    xtitle=xtitle,$
  charsize=3,xmargin=[1,1],ymargin=[3,4],$
  color=!P.COLOR,xticklen=-0.35,/top ,xthick=2,charthick=1,$
  _EXTRA=_extra



SKIP:

; ==================>
; Add any notes
  IF KEYWORD_SET(NOTES) THEN BEGIN
    IF NOT KEYWORD_SET(NOTE_POS) THEN NOTE_POS=[.5,.02]
    IF NOT KEYWORD_SET(NOTE_CHAR) THEN NOTE_CHAR = 1.0
    XYOUTS,NOTE_POS[0],NOTE_POS[1],NOTES,CHARSIZE=NOTE_CHAR, ALIGN=.5,/NORMAL
  ENDIF


; ==================>
; Read the graphics device
  IMAGE=TVRD()

; ==================>
; Cut out the box surrounding non-background data
  IF NOT KEYWORD_SET(WHOLE) THEN image=CUTOUT(image,background,grace)

; ==================>
; Make a GIF file if keyword provided

  IF KEYWORD_SET(GIF) THEN BEGIN

   PAL_SW2,R,G,B
    IF STRLEN(STRTRIM(STRING(GIF),2)) GE 5 THEN giffile=gif ELSE giffile = DIR_WORK+'TEMP.gif'
    write_gif,giffile,image,r,g,b
  ENDIF


; ==================>
   SET_PLOT,old_device
  !x.margin=old_xmargin
  !Y.MARGIN=old_ymargin

  RETURN, IMAGE

  END  ; <==================== END OF PROGRAM  ====================>
