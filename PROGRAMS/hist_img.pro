PRO hist_img, files=files

   CLOSE,/ALL  ; close all logical units
   the_time = STRTRIM(SYSTIME(),2)

; ====================>
;  ### CHECK KEYWORDS

; ====================>
;  Location of Files Used by This Program:
;    program_files = 'd:\czcs_cal\'
   globlandfile = 'd:\czcs_cal\dsp\globland.img'
   output = 'd:\czcs_cal\hist_img.txt'

; ====================>
;  Open files for writing statistical data
   openw,lun,output,/GET_LUN
;  ____________________________________________________________________
;  Read GLOBLAND.IMG image file (Globec Domain, Land = 0, Water = 255)
;  Generated from DSP and with program GLOBLAND.PRO
;  AND locate LAND pixels

   READ_DSP,FILE=globlandfile, IMAGE=globland,PX=PX,PY=PY
   land = WHERE(globland EQ 0)
   water_pixels = LONG(px * py) - N_ELEMENTS(land)
   print, water_pixels
   image_size = INTARR(2)
   WINDOW,0,XSIZE=px,YSIZE=py
   IF !D.X_SIZE NE px or !D.Y_SIZE NE py THEN BEGIN
     MESSAGE, 'ERROR: Size of Graphics Window does not match image size'
     RETURN
   ENDIF

;  ______________________________________________________________________
;  Establish a data coordinate system (longitude/latitude versus pixel locations)
;  Using IDL program MAPSETJ.PRO (modification of MAPSET.PRO)
;  Which generates a Mercator Projection of the GLOBEC Domain

; (Coordinates from A. Barnard)
; area -map of image:45.429  39.013
;                   -72.164 -63.487
; Image center:     -67.834  42.309
; Dimensions (w,h): 8.660   0.00    512,512

  MAP_SETJ,0,0,0,$
  /MERCATOR,$
  limit=[39.013,-72.164,45.429,-63.487],$
  xmargin=[0,0],ymargin=[0,0],$
  /whole_map,$
  /noborder

; Test Coordinate Transformation:
  pxy = convert_coord(-72.164,39.013,/DATA,/TO_DEVICE) & PRINT, pxy(0:1)
  pxy = convert_coord(-72.164,45.429,/DATA,/TO_DEVICE) & PRINT, pxy(0:1)
  pxy = convert_coord(-63.487,45.429,/DATA,/TO_DEVICE) & PRINT, pxy(0:1)
  pxy = convert_coord(-63.487,39.013,/DATA,/TO_DEVICE) & PRINT, pxy(0:1)
  pxy = convert_coord(-67.834,42.309,/DATA,/TO_DEVICE) & PRINT, pxy(0:1)

  PRINT, 'Limits of Map Are:'
  PRINT, !map.out(2),!map.out(3),!map.out(4),!map.out(5)
  PRINT,'Device  x,y = ', !D.X_SIZE, !D.Y_SIZE


; ====================>
; Get files
  files = FILELIST(files,/sort)

; ====================>
;  LOOP FOR EACH OF THE IMAGE FILES
  FOR _file = 0,(N_ELEMENTS(files)-1) DO BEGIN
    afile = STRLOWCASE(files(_file))
    READ_DSP,FILE=afile,IMAGE=IMAGE,/QUIET
    fname = parse_it(files(_file))
    iname = 'c'+fname.name+fname.ext  ;  when image name is a dos equivalent name
    PRINT, iname

    ok_pixels = WHERE( IMAGE NE 255 AND  IMAGE NE 0 AND GLOBLAND NE 0, count)

      percent_ok =  100.* count/ water_pixels
      IF count GE 1 THEN BEGIN
        h = HISTOGRAM(IMAGE(ok_pixels),MIN=0,MAX=255)
      ENDIF ELSE BEGIN
        h = intarr(256)
      ENDELSE

      PRINTF,LUN,fname.fullname,percent_ok, h, FORMAT = '(A80,F10.6, 256i5)'

  ENDFOR
CLOSE,LUN
FREE_LUN,LUN
END

