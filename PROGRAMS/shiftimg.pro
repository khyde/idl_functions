; $ID:	SHIFTIMG.PRO,	2020-07-08-15,	USER-KJWH	$
;+
; NAME:
;       shiftimg
;
; PURPOSE:
;       IMAGE NAVIGATION
;       Generate a text file with x and y shifts to be used to navigate images
;       (shifting-translating image) images
;
; CATEGORY:
;       IMAGES
;
; CALLING SEQUENCE:
;
; shiftimg,files='h:\czcs\seadas\t8888\*520.gif',coastimage='d:\idl\jay\images\nec_coast.gif',shift_file='d:\idl\jay\etc\shiftimg.txt'
; shiftimg,files='h:\czcs\seadas\t8888\*520.gif',coastimage='d:\idl\jay\images\nec_coast.gif',shift_file='d:\idl\jay\etc\shiftimg.txt'
;
; shiftimg,shift_file='d:\idl\jay\etc\shiftimg.txt', /dbf
; shiftimg,shift_file='d:\idl\jay\etc\shiftimg.txt', dbf='shiftimg.dbf'
;
; INPUTS:
;       Image files (See Readall.pro to see what file types can be read).
;
;
; KEYWORD PARAMETERS:
;       FILES:  The name(s) of the image file(s)
;       COASTIMAGE: The name of the gif coastline file where coast values are 1
;                   and where the dimensions and map projection matches
;                   all the images which you are navigating.
;       SHIFTFILE:  The name of the file which will contain the x,y shift values
;       XSIZE:      The X size in pixels for the image display scroll window
;       YSIZE:      The Y size in pixels for the image display scroll window
;       DBF:        The name of the DBF DBASE FILE TO WRITE SHIFTS
;                   (When DBF is used this program will find the most recent time stamp
;                    and write these shifts to the dbf binary file).
;
;  OTHER PROGRAMS CALLED:


;   FILELIST
;   PARSE_IT
;   READ_ALL  (AND RELATED READING PROGRAMS)
;   SETCOLOR
;   IDLTYPE
;   DATE_NOW
;   CW_ZOOMJ ;
;   READ_DB
;   WRITE_DB
;   MISSINGS
;   NUM2STR
;   STR_ADD
;   STRALONG
;   SLIDE_IMAGE
;   GRAY0,R,G,B     palette
;   CZVMIAMI,R,G,B  palette
;   BLKGRWH1,R,G,B  palette
;   PAL_36,R,G,B  palette
;   PAL_SW2,R,G,B  palette
;   PETES24,R,G,B  palette
;
; OUTPUTS:
;       shift_file: The name of the ascii file to write navigation shifts.
;       dbf: The name of the dbf file to write navigation shifts.
;
; SIDE EFFECTS:
;       None.
;
; RESTRICTIONS:
;       Input files must be same size and map projection as your coastline image file.
;       DO NOT put any commas in the comment box as commas are used by this program to parse the
;       data items.
;
; PROCEDURE:
;       Use shiftimg to navigate, saving x,y offsets along with image name and time
;       If no land is visible (clouds) then press the NO LAND button and the Write Butten
;       Then press NEXT
;       You can add comments about the image in the comment box
;
;       After you have navigated images then run shiftimg with /dbf
;       (this will make a dbf dbase file which can be used as a lookup table by
;       other programs which require the x,y shifts to navigate the image.
;
; NOTES:
;
;
; MODIFICATION HISTORY:
;       Written by:  J.E.O'Reilly, June 26, 1995.
;       March 4,1999 J.O'R  made more generic
;-

; ==================>
  PRO shiftimg_event,event
  COMMON data, coast,image,temp_image,base,next,xshift,yshift,zoom,$
             image_label,slidex,slidey,no_land,XYS,fname,$
             _file,comment,notes,pal,palval,paltable,RED,GREEN,BLUE

  WIDGET_CONTROL, event.id, GET_UVALUE=uvalue

  IF uvalue NE 'EXIT' AND _file GE N_ELEMENTS(FNAME) THEN BEGIN
   PRINT, 'NO MORE IMAGES TO PROCESS ... EXIT PROGRAM'
   done = WIDGET_MESSAGE('NO MORE IMAGES TO PROCESS ... EXIT PROGRAM'  )
   GOTO, NO_MORE_IMAGES
  ENDIF

  CASE uvalue of
    'ZOOM': BEGIN
     HELP,/STRUCT, event
     print, event.id
     WIDGET_CONTROL,zoom, SET_VALUE=temp_image
     END

  'NEXT_IMAGE':  BEGIN
     _file = _file + 1
     IF _file  GE N_ELEMENTS(FNAME) THEN GOTO, NO_MORE_IMAGES
     IMAGE = READALL(fname(_file).fullname);,TYPE='HDF',/binary)
     PRINT, FNAME(_file).FULLNAME
     temp_image = image
     temp_image(coast) = 0b
     notes = ''
     xshift = 0.0
     yshift = 0.0
     WIDGET_CONTROL,zoom, SET_VALUE=temp_image
     IF KEYWORD_SET(dosname) THEN BEGIN
       b = 'c' + fname(_file).name + fname(_file).ext
     ENDIF ELSE BEGIN
        b = fname(_file).name
     ENDELSE
     WIDGET_CONTROL,image_label,SET_VALUE=fname(_file).name+fname(_file).ext
     WIDGET_CONTROL,COMMENT, SET_VALUE=notes
     WIDGET_CONTROL,slidex,/SENSITIVE, SET_VALUE=xshift
     WIDGET_CONTROL,slidey,/SENSITIVE, SET_VALUE=yshift
     END

  'PAL':    BEGIN
     palval = palval + 1
     IF palval GE N_ELEMENTS(paltable) THEN palval = 0
     TVLCT,RED(*,PALVAL),GREEN(*,PALVAL),BLUE(*,PALVAL)
   END

  'SLIDEX':  BEGIN
     IF STRMID(notes[0],0,15) EQ 'NO VISIBLE LAND' THEN BEGIN
       WIDGET_CONTROL,slidex, SENSITIVE=0,SET_VALUE=0.0
       WIDGET_CONTROL,slidey, SENSITIVE=0,SET_VALUE=0.0
     ENDIF ELSE BEGIN
       WIDGET_CONTROL,slidex, GET_VALUE=xshift
       xshift = xshift
       WIDGET_CONTROL,slidex, SET_VALUE=xshift
       temp_image = shift(image,xshift,yshift)
       temp_image(coast) = 0b
       WIDGET_CONTROL,zoom, SET_VALUE=temp_image
     ENDELSE
     END

   'SLIDEY': BEGIN
      IF STRMID(notes[0],0,15) EQ 'NO VISIBLE LAND' THEN BEGIN
        WIDGET_CONTROL,slidex, SENSITIVE=0,SET_VALUE=0.0
        WIDGET_CONTROL,slidey, SENSITIVE=0,SET_VALUE=0.0
      ENDIF ELSE BEGIN
        WIDGET_CONTROL,slidey, GET_VALUE=yshift
        yshift = yshift
        WIDGET_CONTROL,slidey, SET_VALUE=yshift
        temp_image = shift(image,xshift,yshift)
        temp_image(coast) = 0b
        WIDGET_CONTROL,zoom, SET_VALUE=temp_image
      ENDELSE
      END

   'COMMENT': BEGIN
      WIDGET_CONTROL,COMMENT, GET_VALUE=notes
      IF STRMID(notes[0],0,15) NE 'NO VISIBLE LAND' THEN BEGIN
        WIDGET_CONTROL,slidex, SENSITIVE=1
        WIDGET_CONTROL,slidey, SENSITIVE=1
      ENDIF
      END

   'NO_LAND': BEGIN
      WIDGET_CONTROL,slidex, SENSITIVE=0,SET_VALUE=0.0
      WIDGET_CONTROL,slidey, SENSITIVE=0,SET_VALUE=0.0
      xshift = 0.0
      yshift = 0.0
      notes = 'NO VISIBLE LAND'
      WIDGET_CONTROL,comment, SET_VALUE=notes
      END

   'WRITE_SHIFTS': BEGIN
      IF STRMID(notes[0],0,15) EQ 'NO VISIBLE LAND' THEN BEGIN
        WIDGET_CONTROL,slidex, SET_VALUE=0.0
        WIDGET_CONTROL,slidey, SET_VALUE=0.0
        xshift = 0.0
        yshift = 0.0
      ENDIF
      fullname = FNAME(_file).FULLNAME
      iname = FNAME(_file).NAME
      CHRON=DATE_NOW()
      C = ","
      PRINT,    iname,C,xshift,C,yshift,C,chron,C,fullname,C,notes,FORMAT='(A,A,I4,A,I4,A,A14,A,A,A,A)'
      PRINTF,XYS,iname,C,xshift,C,yshift,C,chron,C,fullname,C,notes,FORMAT='(A,A,I4,A,I4,A,A14,A,A,A,A)'
      END

    'EXIT':  BEGIN
       CLOSE,XYS
       FREE_LUN,XYS
       WIDGET_CONTROL, event.top, /DESTROY
      END
   ENDCASE
   NO_MORE_IMAGES:
END

; ====================>
; shiftimg,files='h:\czcs\seadas\t8888\*520.gif',coastimage='d:\idl\jay\images\nec_coast.gif',shift_file='d:\idl\jay\images\shiftimg.txt'
  PRO SHIFTIMG,FILES=FILES,$
               COASTIMAGE=coastimage,$
               shift_file=shift_file,$
               XSIZE=xsize, YSIZE=ysize, $
               DBF=DBF

  COMMON data, coast,image,temp_image,base,next,xshift,yshift,zoom,$
             image_label,slidex,slidey,no_land,XYS,fname,$
             _file,comment,notes,pal,palval,paltable,RED,GREEN,BLUE

  IF N_ELEMENTS(DBF) EQ 1 THEN GOTO, MAKE_DBF_FILE

; ===================>
; Initialize some variables
  xshift = 0
  yshift = 0
  zoom_id = 0L
  _file = -1
  palval=0
  paltable=[1,2,3,4]
  IF N_ELEMENTS(XSIZE) NE 1 THEN XSIZE = 850
  IF N_ELEMENTS(ySIZE) NE 1 THEN ySIZE = 750

; ===================>
  SETCOLOR,0   ; program setcolor.pro makes background white and plotting color black (0).

; ====================>
; Read in custom palettes
  RED = BYTARR(256,6)
  GREEN = RED
  BLUE = GREEN

  GRAY0,R,G,B
  RED(*,0) =R(*)
  GREEN(*,0)=G(*)
  BLUE(*,0)=B(*)

  PAL_SW2,R,G,B
  RED(*,1) =R(*)
  GREEN(*,1)=G(*)
  BLUE(*,1)=B(*)

  blkgrwh1,R,G,B
  RED(*,2) =R(*)
  GREEN(*,2)=G(*)
  BLUE(*,2)=B(*)

  petes24,R,G,B
  RED(*,3) =R(*)
  GREEN(*,3)=G(*)
  BLUE(*,3)=B(*)

  pal36,R,G,B
  RED(*,4) =R(*)
  GREEN(*,4)=G(*)
  BLUE(*,4)=B(*)

; ====================>
; Read coast image file (GIF) file
  GETCOAST:
  coastfile=''
  IF KEYWORD_SET(coastimage)EQ 0 THEN BEGIN
    READ,COASTFILE,PROMPT="Enter Coast Image file"
  ENDIF ELSE BEGIN
    coastfile = coastimage
  ENDELSE

; ====================>
; See if the coastimage file exists  ... if not try again
  OPENR, temp,coastfile, /GET_LUN, ERROR=i
  IF  i NE 0 THEN BEGIN
   PRINT,' YOU MUST ENTER THE FULL (include directory) NAME OF AN EXISTING COASTLINE FILE '
     coastfile = ''
     READ,coastfile,PROMPT= ' Enter Full Name of Existing Coastline File Used to Navigate (shift) images '
  ENDIF ELSE BEGIN
    CLOSE,temp
    FREE_LUN,temp
  ENDELSE
  ERROR = 0

; ==============>
; Read the coastline file and get its dimensions
  READ_GIF,coastfile,coastline,R,G,B
  s = size(coastline)
  px = s[1] & py = s(2)
  coast = WHERE(coastline eq 1) ; Assumes coastline pixels have value of 1
  temp_image = coastline

; ====================>
; Check if  name of shift_file  was supplied by user
  IF N_ELEMENTS(shift_file) NE 1 THEN xysfile='shiftimg.txt' ELSE xysfile=shift_file
  PRINT,'shift_file: ', XYSFILE

; ====================>
; Check if user supplied a file name or file names with wildcard (*)
  IF KEYWORD_SET(FILES) NE 0 THEN BEGIN
   files = filelist(files,/sort)
  ENDIF ELSE BEGIN
   files = Dialog_PICKFILE(/READ,TITLE='SELECT AN IMAGE FILE TO NAVIGATE')
  ENDELSE

; ====================>
; Parse file names into an array structure (fname)
  fname = parse_it(files)

; ====================>
; make an array files_done
  files_done = BYTARR(N_ELEMENTS(FILES))

; ====================>
; See if the xysfile exists
  OPENR, xys, xysfile, /GET_LUN, ERROR=i
  IF  i NE 0 THEN BEGIN   ;(FILE DOES NOT EXIST YET, SO CREATE IT AND CLOSE IT)
    OPENW,XYS,XYSFILE,/GET_LUN,/APPEND
    CLOSE,xys
    free_lun,xys
  ENDIF ELSE BEGIN
;   Open,Read the image names from the xys file, and close file
    OPENR,XYS,XYSFILE,/GET_LUN
    TXT = ''
    WHILE NOT EOF(xys) DO BEGIN
      READF,xys,TXT, FORMAT='(A)'
      STXT = STR_SEP(TXT,',')
      NAME = STXT[0]
      OK = WHERE(fname.name EQ name,COUNT)
      IF count GE 1 THEN BEGIN
         files_done(ok) = 1b
      ENDIF
    ENDWHILE
    CLOSE,XYS
    FREE_LUN,XYS
  ENDELSE

; =================>
; ELIMINATE FILES ALREADY NAVIGATED
  OK = WHERE(FILES_DONE EQ 0,COUNT)
  IF COUNT GE 1 THEN BEGIN
   FILES=FILES[OK]
   FNAME = FNAME[OK]
  ENDIF
  txt = STRTRIM(STRING(N_ELEMENTS(fname)),2) + ' Remaining Files To Navigate'
  PRINT,  txt

; ====================>
; Open the xys file for writing x,y offsets
; File pointer is at end of file (append keyword)
  OPENW,XYS,XYSFILE,/GET_LUN,/APPEND

; ====================>
; Define Widgets
  base = WIDGET_BASE(ROW=2,TITLE="IDL PROGRAM SHIFTIMG.PRO")

  zoom        = CW_ZOOMj(BASE, XSIZE=PX,YSIZE=PY,$
                X_ZSIZE=(256),Y_ZSIZE=(256),$
                X_SCROLL_SIZE=XSIZE,Y_SCROLL_SIZE=YSIZE,$
                SAMPLE=1,UVALUE='ZOOM',MIN=2,MAX=16,RETAIN=2)

  right  = WIDGET_BASE(base, ROW=1, /BASE_ALIGN_CENTER )

  image_label= WIDGET_LABEL(RIGHT,VALUE=txt,UVALUE='IMAGE_LABEL',SCR_XSIZE=350)

  slidex=WIDGET_SLIDER(right,UVALUE='SLIDEX',TITLE='X SHIFT',$
             VALUE=0,MINIMUM=-30,MAXIMUM=30)

  slidey=WIDGET_SLIDER(right,UVALUE='SLIDEY',TITLE='Y SHIFT',$
                VALUE=0,MINIMUM=-30,MAXIMUM=30)
  pal=WIDGET_BUTTON(right,VALUE='Pal',UVALUE='PAL')

  next=WIDGET_BUTTON(right,VALUE='Next',UVALUE='NEXT_IMAGE')

  write_shifts=WIDGET_BUTTON(right,VALUE='Write',UVALUE='WRITE_SHIFTS')

  comment= CW_FIELD(right,VALUE='',UVALUE='COMMENT',TITLE='COMMENT',/column,/ALL_EVENTS)

  no_land=WIDGET_BUTTON(right,VALUE='No Land',UVALUE='NO_LAND')

  exit=WIDGET_BUTTON(right,VALUE='EXIT',UVALUE='EXIT')


; ====================>
; Realize widgets, load default values, and register widgets with xmanager
  WIDGET_CONTROL,base,   /REALIZE
  WIDGET_CONTROL,zoom,   SET_VALUE=temp_image  ;(load coastline image)
  WIDGET_CONTROL,slidex, SET_VALUE=0
  WIDGET_CONTROL,slidey, SET_VALUE=0
  XMANAGER, 'shiftimg',  base

  PRINT,'Navigation Shifts Were Written to File =', XYSFILE

; ====================>
; Now sort navigation shifts (most recent will be used) and write a DBF file
; which may subsequently be used to look up the x and y shifts based on
; image name
  MAKE_DBF_FILE:
  If N_ELEMENTS(DBF) EQ 1 THEN BEGIN
    TYPE = IDLTYPE(DBF,/CODE)
    IF TYPE NE 7 THEN  DBF = 'shiftimg.dbf' ; default name

;   ====================>
;   Check if  name of shift_file file was supplied by user
    IF N_ELEMENTS(shift_file) NE 1 THEN xysfile='shiftimg.txt' ELSE xysfile=shift_file

;   ====================>
;   Initialize variables
    iname = '' & xshift = 0 & yshift = 0 & chron = '' &  txt = ''

;   ====================>
;   Open navigation file (previously written).
    OPENR,XYS,XYSFILE,/GET_LUN

    datum = {INAME:' ',XSHIFT:0,YSHIFT:0,TIME:' ',FULLNAME:' ',txt:''}
    all = datum
    TXT =''
    WHILE NOT EOF(xys) DO BEGIN
      READF,xys,TXT
      STXT = STR_SEP(TXT,",")
      datum.iname = STXT[0]
      datum.xshift = STXT[1]
      datum.yshift = STXT(2)
      datum.time=STXT(3)
      datum.fullname = STXT(4)
      datum.txt = STXT(5)
      all= [all,datum]
    ENDWHILE
    all = all(1:*)

;   ====================>
;   Now sort navigation shifts with the most recent (chron) shifts
;   ahead of the older shifts for the same image
    ok = WHERE(STRTRIM(all.iname,2) NE '        ')  ; find non blank records
    all = all(ok)  ; get rid of blank records
    ok = REVERSE(sort(all.iname+all.time))  ; reverse sort (latest first)
    all = all(ok)
    ok = UNIQ(all.iname)  ; get indices of latest navigation shifts for each image in data array
    all = all(ok)
    s = sort(all.iname) ; sort data earliest to latest
    all = all(s)
    CLOSE,XYS
    FREE_LUN,XYS
    WRITE_DB,DBF,all

    PRINT,N_ELEMENTS(all),'  Navigation Shift Values Written to DBF File: ', DBF
  ENDIF ;; If N_ELEMENTS(DBF) EQ 1 THEN BEGIN

END  ; <==================== END OF PROGRAM  ====================>
