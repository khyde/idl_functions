; $Id: IMAGE_MEDIAN_FILL.PRO  Jan 5, 2000  J.E.O'Reilly Exp $

  PRO IMAGE_MEDIAN_FILL, FILES = FILES,DIR_OUT=DIR_OUT



;+
; NAME:
;       IMAGE_MEDIAN_FILL
;
; PURPOSE:
;       EDIT, CLEAN UP MISSING DATA AND DATA WITH FEW OBSERVATIONS PER PIXEL
;             BY REPLACEMENT WITH THE MEDIAN USING SPECIAL PROGRAM MEDIAN_FILL.PRO
;

; MODIFICATION HISTORY:
;       Written by:  J.E.O'Reilly, Jan, 5,2000
;-


; =================>
   ; ====================>
; Get the NEC land mask and thicken coastline
  LAND_MASK=READALL('D:\IDL\IMAGES\MASK_NEC_NO_LAKES.PNG')
  OK_LAND = WHERE(LAND_MASK EQ 0 OR LAND_MASK EQ 1)
  MASK=LAND_MASK & MASK(*) = 0 & MASK(OK_LAND) = 1

  FILES = FILELIST(files)

; ====================>
; For each file
  FOR _file = 0, N_ELEMENTS(FILES)-1L DO BEGIN
    IMAGE_FILE = FILES(_file)
    IF N_ELEMENTS(DIR_OUT) NE 1 THEN BEGIN
      FN=PARSE_IT(IMAGE_FILE)
      DIR_OUT = FN.DIR
    ENDIF

    fn=parse_it(IMAGE_FILE)
    name=fn.name

;   =============>
;   Read the image file
    IMAGE = READALL(IMAGE_FILE, RED=red,green=green,blue=blue)


;   ====================>
;   Median smooth entire scene (not just missing)
    image = MEDIAN_FILL(IMAGE,missing=0,BOX=[5,5],MIN_F=1./25,MASK=LAND_MASK,/ignore_missing)




;   ==================>
;   WRITE PNG
    PNG_FILE = DIR_OUT + FN.NAME + '_MF.PNG'
    PRINT, 'WRITING EDITED PNG FILE: ', PNG_FILE

    WRITE_PNG,PNG_FILE,image,RED,GREEN,BLUE


  ENDFOR
  END; END OF PROGRAM

