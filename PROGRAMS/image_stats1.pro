; $Id: IMAGE_STATS1.PRO ,v 1.1 1998/02/03 12:00:00 J.E.O'Reilly Exp $

 PRO IMAGE_STATS1, FILES=FILES, TYPE=type,$
                MASK_FILE = mask_file, COLORS=colors, TYPE_MASK = type_mask,$
                OUTPUT = output,$
                START=start,$
                QUIET= quiet
;+
; NAME:
;       IMAGE_STATS1
;
; PURPOSE:
;
;
; CATEGORY:
;
;
; CALLING SEQUENCE:

;       IMAGE_STATS1, FILES='c:\idl\*.gif'
;       IMAGE_STATS1, FILES='c:\idl\*.gif',mask_file='c:\idl\necmask.gif'
;       IMAGE_STATS1, FILES='c:\idl\*.gif',mask_file='c:\idl\necmask.gif',colors=[1,4,7]
;       IMAGE_STATS1, FILES='c:\idl\*.gif',mask_file='c:\idl\necmask.gif',colors=[1,4,7],type_mask='GIF'
;       IMAGE_STATS1, FILES='c:\idl\*.gif',mask_file='c:\idl\necmask.gif',colors=[1,4,7],OUTPUT='C:\IDL\TEST.LON'
;
; INPUTS:
;       FILES : Satellite Image Files (DSP, GIF, etc.)
;
; KEYWORD PARAMETERS:
;       TYPE		The type of image file e.g. TYPE = 'DSP' ; TYPE ='GIF'
;       MASK_FILE  	The name of the mask file which defines statistical subareas
;       COLORS		The colors (1-255) (subareas) in the mask to use (zero is reserved for image background)
;       TYPE_MASK	The type of image file (dsp,gif,etc.)
;       OUTPUT		The name of an output file (default is IMAGE_STATSs1.lon
;       START       The sequential number of the file to start (used if program is interrupted)
;       QUIET		Prevents printing of program progress
;
;
; OUTPUTS:
;      A file containing the image name, and histogram frequency statistics for each image
;      and for each subarea (color) if a mask_file is provided.
;
; SIDE EFFECTS:
;       None.
;
; RESTRICTIONS:
;       None.
;
; PROCEDURE:
;       Straightforward.
;
; MODIFICATION HISTORY:
;       Written by:  J.E.O'Reilly, September 12, 1997
;       Modified                   February   3, 1998
;-


; **********************************************************
; Define Constants
; Blanks is a string of blanks 28 characters long
; It is used to pad the right side of the image file name so that
; all image names written to output file are 28 characters long

; =====================>
; Maximum length of image name
  name_length = 80 ;
  blanks = BYTARR(name_length)
  blanks(*) = 32b
  blanks = STRING(blanks)


; ====================>
; Define counters for the number of valid images processed
; and total number of output records (valid images * valid subarea colors in mask)
  images_processed = 0L
  output_records   = 0L

; ====================>
; Get the Target Image Files
; and Sort the file names in ascending order


  IF N_ELEMENTS(FILES) EQ 0 THEN BEGIN
    files = PICKFILE(TITLE='Pick an Image File')
  ENDIF ELSE BEGIN
    files = FILELIST(files,/sort)
    IF KEYWORD_SET(START) THEN files = files(start:*)
  ENDELSE



; =====================>
; If mask image file name is not provided
; then assume statistics are for the whole image and not for
; a series of image subareas defined by the mask image


  IF N_ELEMENTS(mask_file) EQ 1 THEN BEGIN
    WHOLE = 0  ; Statistics for each target subarea in Overlay
;   Program assumes mask mask is GIF type unless TYPE is specified
    IF N_ELEMENTS(type_mask) EQ 0 THEN type_mask = 'GIF'

    mask = READALL(mask_file,TYPE=type_mask,/quiet)

;   IF target colors are not provided then assume
;   the user wants statistics for all colors (subareas) in the mask mask
    IF N_ELEMENTS(COLORS) LT 1 THEN BEGIN
      h  = HISTOGRAM(mask,MIN=1,MAX=255)
      ok = WHERE(H NE 0,COUNT)
      colors = ok  ; -1 if no non-zero colors in mask
    ENDIF ELSE BEGIN
      colors = colors(WHERE(colors GE 1 AND colors LE 255))
    ENDELSE

;   ==================>
;   Ensure that user supplied target mask_colors are within correct range

  ENDIF ELSE BEGIN  ; IF N_ELEMENTS(mask) EQ 1 THEN BEGIN
;   If no mask and no target colors provided then
;   histogram statistics will be based on the entire image
    WHOLE = 1
  ENDELSE ; IF N_ELEMENTS(mask) EQ 1 THEN BEGIN



; ====================>
; If no output file name provided then output ='IMAGE_STATS1.lon'
  IF N_ELEMENTS(OUTPUT) LT 1 THEN output ='image_stats1.lon'


; ====================>
; Open file for writing statistical output
  OPENW,lun,output,/GET_LUN


; **********************************************************
; M A I N           P R O G R A M        L O O P
; E X T R A C T     H I S T O G R A M    S T A T I S T I C S   F O R   E A C H   I M A G E
; **********************************************************

  FOR nth = 0, N_ELEMENTS(files) -1 DO BEGIN
    afile = files(nth)
;   Parse file name to extract image name
    fname = PARSE_IT(afile,/with_period)
    iname = fname.name + fname.ext
    length= STRLEN(iname)


;   ================>
;   Make sure image name length is always name_length
;   pad if necessary
    IF length GE name_length THEN BEGIN
      iname = STRMID(iname,0,name_length)
    ENDIF ELSE BEGIN
      pad   = STRMID(BLANKS,length,name_length)
      iname = iname + pad
    ENDELSE

    IF NOT KEYWORD_SET(QUIET) THEN PRINT, iname

    image = READALL(afile,/quiet,TYPE=type)
;
;   ====================>
;   If READALL CAN NOT READ THE FILE THEN SKIP IT
    IF image(0,0) EQ -1 THEN GOTO, SKIP

    images_processed = images_processed +1L

    IF WHOLE EQ 1 THEN BEGIN
      h = HISTOGRAM(image,MIN=0,MAX=255)
      WRITEU,LUN,iname,-1L,h
      output_records = output_records +1L
    ENDIF ELSE BEGIN
      FOR _color = 0, N_ELEMENTS(colors) -1 DO BEGIN
        subarea_color = colors(_color)
        subarea = WHERE(MASK EQ subarea_color,subarea_count)
        IF subarea_count GE 1 THEN BEGIN
          h  = HISTOGRAM(image(subarea),MIN=0,MAX=255)
          WRITEU,LUN,iname,LONG(subarea_color),h
          output_records = output_records +1L
        ENDIF
      ENDFOR
    ENDELSE  ; IF WHOLE EQ 1 THEN BEGIN

    SKIP:
  ENDFOR ; FOR nth = 0, N_ELEMENTS(files) -1 DO BEGIN

; ====================>
; Close output file
  CLOSE, lun

; ====================>
; Print program statistics
  IF NOT KEYWORD_SET(QUIET) THEN BEGIN
    PRINT, ''
    PRINT, ' IMAGE_STATS1 IS DONE >>>>>>>>>>>>>>>>>>>>'
    PRINT, ' IMAGES PROCESSED: ', images_processed
    PRINT, ' OUTPUT RECORDS: ',   output_records
    PRINT, ' WRITTEN TO FILE : ',  output
  ENDIF

; ************************************************************
  END  ; END OF PROGRAAM
; ************************************************************






