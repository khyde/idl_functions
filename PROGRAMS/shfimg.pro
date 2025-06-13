; $ID:	SHFIMG.PRO,	2020-07-08-15,	USER-KJWH	$

; ====================>
pro shfimg_event,event
   common data, coast,image,new,xshift,yshift,zoom_id,slidex_id,slidey_id,first,FNAME
   WIDGET_CONTROL, event.id, GET_UVALUE=uvalue
   AGAIN:
   CASE uvalue of
     'ZOOM':      BEGIN
            HELP,/STRUCT, event
            print, event.id
            zoom_id = event.id
          WIDGET_CONTROL,zoom_id, SET_VALUE=new
                  END

     'NEXT_IMAGE':  BEGIN
                    IF FIRST EQ 1 THEN BEGIN
                      FIRST = 0
          ENDIF ELSE BEGIN
             PRINT, FNAME.FULLNAME,xshift,yshift,FORMAT='(A,2I3)'
                     WIDGET_CONTROL,slidex_id, SET_VALUE=0
           WIDGET_CONTROL,slidey_id, SET_VALUE=0
                     xshift=0
                     yshift=0
                    ENDELSE

            read_dsp,FILE=FILE,image=image,/rotate,/quiet
            FNAME=PARSE_IT(FILE)
            PRINT, FNAME.FULLNAME

                  new = image
                  new(coast) = 0
          WIDGET_CONTROL,zoom_id, SET_VALUE=new

                  END

       'SLIDEX':  BEGIN
                  slidex_id = event.id
                  WIDGET_CONTROL,slidex_id, GET_VALUE=xshift
                  new = shift(image,xshift,yshift)
                  new(coast) = 0
                  WIDGET_CONTROL,zoom_ID, SET_VALUE=new
                END

         'SLIDEY':  BEGIN
              slidey_id = event.id
                  WIDGET_CONTROL,slidey_id, GET_VALUE=yshift
                  new = shift(image,xshift,yshift)
                  new(coast) = 0
                    WIDGET_CONTROL,zoom_ID, SET_VALUE=new
                  END

         'EXIT':  BEGIN
              PRINT, FNAME.FULLNAME,xshift,yshift,FORMAT='(A,2I3)'
                  WIDGET_CONTROL, event.top, /DESTROY
                  END
   ENDCASE
END

; ====================>
PRO SHFIMG
common data, coast,image,new,xshift,yshift,zoom_id,slidex_id,slidey_id,first,FNAME
  xshift = 0
  yshift = 0
  first=1
  zoom_id = 0L
   NEC=READALL('D:\IDL\JAY\IMAGES\MASK_NEC.GIF',/QUIET)
   S=SIZE(NEC)
   PX=S[1]
   PY=S(2)

   coast = where(NEC eq 1)
   new = NEC

  base = WIDGET_BASE(ROW=2,TITLE='Shift Image')

  zoom=CW_ZOOM(base, XSIZE=PX,YSIZE=PY,$
                 X_ZSIZE=(PX/2.0),Y_ZSIZE=(PY/2.0),$
                 SAMPLE=1,UVALUE='ZOOM')
  next=WIDGET_BUTTON(base,VALUE='Next_image',UVALUE='NEXT_IMAGE')

  slidex=WIDGET_SLIDER(base,UVALUE='SLIDEX',TITLE='X SHIFT',$
          VALUE=0,MINIMUM=-15,MAXIMUM=15,SCROLL=1)
  slidey=WIDGET_SLIDER(base,UVALUE='SLIDEY',TITLE='Y SHIFT',$
            VALUE=0,MINIMUM=-15,MAXIMUM=15,SCROLL=1)

  write_shifts=WIDGET_BUTTON(base,VALUE='WRITE SHIFTS',UVALUE='WRITE_SHIFTS')
  exit=WIDGET_BUTTON(base,VALUE='EXIT',UVALUE='EXIT')



  WIDGET_CONTROL,base,/REALIZE
  WIDGET_CONTROL,zoom, SET_VALUE=new

  WIDGET_CONTROL,slidex, SET_VALUE=0
  WIDGET_CONTROL,slidey, SET_VALUE=0
  XMANAGER, 'shfimg',base

end
