; $ID:	PLT_CAPTION.PRO,	2020-07-08-15,	USER-KJWH	$
;+
;#############################################################################################################
	PRO PLT_CAPTION,FILE,TXT=TXT,WPL=WPL,XPOS=XPOS,YPOS = YPOS,FONT_SIZE =FONT_SIZE

;
; PURPOSE: ADDS TEXT TO A PNG FILE
;
; CATEGORY:	PNGS
;
; CALLING SEQUENCE: PLT_CAPTION,FILE,TXT=TXT
;
; INPUTS: PROMPTED TO PICK A PNG FILE
;         PROMPTED TO ENTER THE CAPTION
;		
;		
; OPTIONAL INPUTS:
;		NONE:	
;		
; KEYWORD PARAMETERS:
;		TXT: THE FIGURE CAPTION TO ADD BELOW THE PNG
;   FONT_SIZE: FONT SIZE FOR FIGURE CAPTION
;   XPOS: X POSITION OF THE TXT INNORMAL UNITS
;   YPOS: Y POSITION OF THE TXT IN NORMAL UNITS
;   WPL:  WORDS PER LINE IN FIG CAPTION MADE FROM TXT [PASSED TO STR_2LINES]
; OUTPUTS: A PNG WITH TXT ADDED BELOW THE IMAGE
;		
; EXAMPLES: 
;
; MODIFICATION HISTORY:
;			MAR 19,2014 WRITTEN BY J.O'REILLY
;			MAY 27,2014,JOR MADE INTERACTIVE:ADDED DIALOG_PICKFILE,READ
;			
;			
;			
;#################################################################################
;
;
;-
;*****************************
ROUTINE_NAME  = 'PLT_CAPTION'
;*****************************

RGB_TABLE = CPAL_READ('PAL_SW2')
BACKGROUND_COLOR= RGBS(255)
POS = POSITIONS('B')
FONT_HELVETICA
RES = 600
BORDER = 1
IF NONE(XPOS) THEN XPOS = 0.9
IF NONE(YPOS) THEN YPOS = 0.02
IF NONE(FONT_SIZE) THEN FONT_SIZE = 8
 
IF NONE(FILE) THEN FILE = DIALOG_PICKFILE(FILTER = '*.PNG')
IF NONE(TXT) THEN BEGIN
  TXT = ''
  READ, TXT, PROMPT='ENTER CAPTION [WITHOUT QUOTES]: '
ENDIF;IF NONE(TXT) THEN BEGIN


FN = FILE_PARSE(FILE)
TITLE = FN.NAME
IMG = READ_PNG(FILE,R,G,B)

;###> CANGE BKG FROM MAX IN IMG TO 255 [GSVIEW ALTERS BKG]
;;OK = WHERE(IMG EQ MAX(IMG),COUNT)& IMG[OK] = 255

SZ = SIZEXYZ(IMG) & PX = SZ.PX & PY = SZ.PY
POS.DIMENSIONS = [PX,PY]
IF NONE(YPOS) THEN YPOS = 0.5*(POS.IM_POS[1])
DIMS = POS.DIMENSIONS * 1.25
W  = WINDOW(DIMENSIONS=DIMS,WINDOW_TITLE=TITLE,BUFFER=BUFFER)
IM = IMAGE(IMG,RGB_TABLE=RGB_TABLE,BACKGROUND_COLOR= BACKGROUND_COLOR,$
POSITION = POS.IM_POS,$
DIMENSIONS=POS.DIMENSIONS,$
IMAGE_LOCATION=POS.IMAGE_LOCATION,MARGIN=0,/CURRENT)

;##################################
;#####> ADD FIGURE CAPTION ?  #####
;##################################
IF N_ELEMENTS(TXT) GE 1 THEN BEGIN
  ;===> CONVERT TXT TO MULTIPLE LINES FOR OUTPUT AS A FIG CAPTION
  TXT = STR_2LINES(TXT,WPL=WPL)

T = TEXT(XPOS,YPOS,TXT,ALIGNMENT = 0.5,FONT_SIZE = FONT_SIZE)
ENDIF;IF N_ELEMENTS(TXT) GE 1 THEN BEGIN
  
PNGFILE = REPLACE(FILE,'.PNG','-EDIT.PNG')
W.SAVE, PNGFILE,RESOLUTION=RES,WIDTH = PX,HEIGHT = PY ,BORDER =BORDER,/BITMAP
PF,PNGFILE
W.CLOSE



END; #####################  END OF ROUTINE ################################
