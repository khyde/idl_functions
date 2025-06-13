; $Id:	template.pro,	April 18 2011	$

  PRO MAKE_INTERPOLATED_PAL, IMAGE, ERROR = error

;+
; NAME:
;   TEMPLATE
;
; PURPOSE:
;   This procedure/function
;
; CATEGORY:
;   CATEGORY
;
; CALLING SEQUENCE:
;
;   TEMPLATE, Parameter1, Parameter2, Foobar
;
;   Result = TEMPLATE(Parameter1, Parameter2, Foobar)
;
; INPUTS:
;   Parm1:  Describe the positional input parameters here. Note again that positional parameters are shown with Initial Caps.
;
; OPTIONAL INPUTS:
;   Parm2:  Describe optional inputs here. If you don't have any, just delete this section.
;
; KEYWORD PARAMETERS:
;   KEY1: Document keyword parameters like this. Note that the keyword is shown in ALL CAPS!
;
; OUTPUTS:
;   This function returns the
;
; OPTIONAL OUTPUTS:
;   ERROR:     Any Error messages are placed in ERROR, if no errors then ERROR = ''
;
; COMMON BLOCKS: If no common blocks then delete this line
; SIDE EFFECTS:  If no side effects then delete this line
; RESTRICTIONS:  If no restrictions then delete this line
;
; PROCEDURE:
;
; EXAMPLE:
;
; NOTES:
;   This routine will display better if you set your tab to 2 spaces:
;   (Preferences, Editor, The TAB Number of spaces to indent for each Tab: 2)
;
;   Citations or any other useful notes
;
;
; MODIFICATION HISTORY:
;			Written:  April 18, 2011 by K.J.W. Hyde, 28 Tarzwell Drive, NMFS, NOAA 02882 (kimberly.hyde@noaa.gov)
;			Modified:  
;-
;	****************************************************************************************************
	ROUTINE_NAME = 'MAKE_INTERPOLATED_PAL'
	
	IF N_ELEMENTS(PALNAME) NE 1 THEN PAL_NAME = 'pal_temp' ELSE PAL_NAME = PALNAME 
		
	IF KEYWORD_SET(END_GREY) THEN BEGIN
  	INTERVALS  = [0,INERVALS,250,251,252,253,254,255]
    R = INTERPOL([0,RED,  255,128,160,192,224,255],INTERVALS,INDGEN(256)) 
    G = INTERPOL([0,GREEN,255,128,160,192,224,255],INTERVALS,INDGEN(256)) 
    B = INTERPOL([0,BLUE, 0,  128,160,192,224,255],INTERVALS,INDGEN(256))
  ENDIF ELSE BEGIN
    INTERVALS  = [0,INERVALS,255]
    R = INTERPOL([0,RED,     255],INTERVALS,INDGEN(256)) 
    G = INTERPOL([0,GREEN,   255],INTERVALS,INDGEN(256)) 
    B = INTERPOL([0,BLUE,    255],INTERVALS,INDGEN(256))  
  ENDELSE   

  PAL = BYTARR(3,N_ELEMENTS(R))
  PAL(0,*) = R
  PAL(1,*) = G
  PAL(2,*) = B
    
  PALLIST = LIST()
  FOR I = 0, N_ELEMENTS(R)-1 DO PALLIST.ADD,REFORM(PAL[*,I])
        
  W = WINDOW(DIMENSIONS=[800,800],LAYOUT=[2,1,1])
  ARR    = FLTARR(200,200) 
  FOR I = 0, 199 DO ARR(*,I) = (0+(100/199.)*FINDGEN(200))            ; scale the array to 200 intervals ranging from 0 to 100 (adapted from the jhuapl routine maken)     
  X = [MIN(ARR),MAX(ARR)]
  IF KEYWORD_SET(SHOW) THEN IM = IMAGE(ARR,/CURRENT,RGB_TABLE=PAL,LAYOUT=[2,1,1],TITLE=PAL_NAME)
  WRITEPAL,PAL_NAME,R,G,B
   
	


END; #####################  End of Routine ################################
