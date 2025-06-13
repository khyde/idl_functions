; $ID:	IMAGE_WELD_PAGE.PRO,	AUGUST 19 2005, 07:04	$
;+
;	This Program WELDS (COMPOSITES) a number of similar sized images onto a single image page.

;	INPUT:
;		FILES: The image (png) files to read (in the order for compositing)
;		ROWS:  The number of rows
;		COLS:  The number of columns
;		PAL:	 The name of the palette to use for the output (e.g. PAL='PAL_SW3'
;		PNGFILE: The name for the output png
;		BACKGROUND: The background color for the new composite page
;		SPACE:	Space in pixels (gap) between images
;		PX:			Width in pixels of the images
;						(if you do not have a complete number of images to fill the ROWS * COLS px and py are used to make a blank image)
;		PY:			Height in pixels of the images
;		ISHIFT:	Used to shift the images
;		NOTRIM:	Prevents the trimming of input images to the px,py size (the default is to trim each image to px,py if they are not already px,py)

; OUTPUT:	A png image file

; NOTES:
;

; VERSION:
;	Apr 11, 2002
; HISTORY:
;		March 16, 2002	Written by:	J.E. O'Reilly, NOAA, 28 Tarzwell Drive, Narragansett, RI 02882
;   Apr 11,2002 Added NOTRIM keyword
;-
; *************************************************************************

PRO IMAGE_WELD_PAGE,FILES=FILES,ROWS=ROWS,COLS=COLS,PAL=PAL,PNGFILE=pngfile,BACKGROUND=background,$
										SPACE=space,PX=px,py=py,ISHIFT=ishift,_EXTRA=_extra,NOTRIM=notrim,MAKE_TRUE=make_true

  ROUTINE_NAME='IMAGE_WELD_PAGE'
  CMD = PAL + ',R,G,B'
  CALL_PROCEDURE,PAL ,R,G,B
  
  IF N_ELEMENTS(FILES) EQ 0 THEN STOP
  IF N_ELEMENTS(COLS) NE 1 THEN COLS = 3
  IF N_ELEMENTS(ROWS) NE 1 THEN ROWS = 4
  IF N_ELEMENTS(PAL) NE 1 THEN PAL = 'PAL_SW3'
  IF N_ELEMENTS(BACKGROUND) NE 1 THEN BACKGROUN=255

  IF N_ELEMENTS(PNGFILE) NE 1 THEN _PNGFILE = ROUTINE_NAME+'_'+STRTRIM(COLS,2)+'_'+STRTRIM(ROWS,2)+'.PNG' ELSE _PNGFILE = PNGFILE

  _FILES = FILES

  IF N_ELEMENTS(PX) NE 1 THEN PX = 1024
  IF N_ELEMENTS(PY) NE 1 THEN PY = 1024

  blank = BYTARR(PX,PY) & BLANK(*,*) = BACKGROUND

  IF N_ELEMENTS(FILES) LT ROWS*COLS THEN BEGIN
    DUMMY_FILES = REPLICATE('',ROWS*COLS-N_ELEMENTS(FILES))
    _FILES = [_FILES,DUMMY_FILES]
  ENDIF

	IF N_ELEMENTS(ISHIFT) NE 0 THEN 	_FILES = SHIFT(_FILES,ISHIFT)

  NTH = -1

;	LLLLLLLLLLLLLLLLLLLLLLLLLLLLLL
  FOR _ROW = 0, ROWS-1 DO BEGIN
;		LLLLLLLLLLLLLLLLLLLLLLLLLLLL
 	 	FOR _COL = 0,COLS-1 DO BEGIN
 	 	  NTH = NTH+1
 	 	  AFILE = _FILES(nth)
 	 	  PRINT, 'WORKING ON :'+AFILE
 	 	  IF AFILE EQ '' THEN BEGIN
 	 	  	IMG = BLANK 	 	  	
 	 	  	IF N_ELEMENTS(IMAGE_ROW) GE 1 THEN BEGIN
 	 	  	  SZ=SIZE(IMAGE_ROW,/STRUCT)
          IF SZ.N_DIMENSIONS EQ 3 THEN IMG = IMAGE_2TRUE(IMG,R,B,G)  
        ENDIF   	  	 	  	
 	 	  ENDIF ELSE BEGIN
 	 	  	IMG = READ_PNG(AFILE,R,G,B)
 	 	  	IF NOT KEYWORD_SET(notrim) THEN IMG = IMG(0:PX-1L,0:PY-1L)
 	 	  	IF KEYWORD_SET(MAKE_TRUE)  THEN IMG = IMAGE_2TRUE(IMG,R,G,B) 	 	  	
 	 	  ENDELSE
      IF _COL EQ 0 THEN IMAGE_ROW 	= IMG 		ELSE IMAGE_ROW 	= IMAGE_WELD(IMAGE_ROW,IMG,/LANDSCAPE,BACKGROUND=background,SPACE=space,_EXTRA=_extra)
    ENDFOR
      IF _ROW EQ 0 THEN IMAGE_PAGE 	= IMAGE_ROW ELSE IMAGE_PAGE = IMAGE_WELD(IMAGE_PAGE,IMAGE_ROW,/PORTRAIT,BACKGROUND=background,SPACE=space,/REVERSE,_EXTRA=_extra)
  ENDFOR
;	||||||

  
   WRITE_PNG,_PNGFILE,IMAGE_PAGE,R,G,B

END; #####################  End of Routine ################################
