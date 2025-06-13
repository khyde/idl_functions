; $ID:	DRAW_BOXES.PRO,	2020-06-30-17,	USER-KJWH	$

FUNCTION DRAW_BOXES,IMAGE=IMAGE,WIDTH=WIDTH, COLOR=COLOR,XP=XP,YP=YP, ERROR = error

;
;  PRINT
  ;  THICK
  ;+
  ; NAME:
  ;		DRAW_BOXES
  ;
  ; PURPOSE:
  ;
  ; CATEGORY:
  ;		CATEGORY
  ;
  ; CALLING SEQUENCE:
  ;
  ; INPUTS:
  ;		Parm1:	Describe the positional input parameters here. Note again that positional parameters are shown with Initial Caps.
  ;
  ; OPTIONAL INPUTS:
  ;		Parm2:	Describe optional inputs here. If you don't have any, just delete this section.
  ;
  ; KEYWORD PARAMETERS:
  ;		KEY1:	Document keyword parameters like this. Note that the keyword is shown in ALL CAPS!
  ;
  ; OUTPUTS:
  ;		This function returns the
  ;
  ; OPTIONAL OUTPUTS:
  ;		ERROR:     Any Error messages are placed in ERROR, if no errors then ERROR = ''
  ;
  ; COMMON BLOCKS: If no common blocks then delete this line
  ; SIDE EFFECTS:	 If no side effects then delete this line
  ; RESTRICTIONS:  If no restrictions then delete this line
  ;
  ;	PROCEDURE:
  ;			This is usually a description of the method, or any data manipulations
  ;
  ; EXAMPLE:
  ;
  ;	NOTES:
  ;		This routine will display better if you set your tab to 2 spaces:
  ;	  (Preferences, Editor, The TAB Number of spaces to indent for each Tab: 2)

  ;		Citations or any other useful notes
  ;
  ;
  ; MODIFICATION HISTORY:
  ;			Written DEC. 7,2009 J.O'Reilly, 28 Tarzwell Drive, NMFS, NOAA 02882 (jay.oreilly@noaa.gov)
  ;			DEC.23,2009 JOR, TD CHANGED DIAM DIAM=(WIDTH/2)-1
  ;			DEC.23,2009 JOR, TD NOW WIDTH MAY VARY WITH EACH POINT (BOX)
  ;			MARCH 7,2010,JOR,FIXED ERROR OCCURING WHEN BOXL GT BOXR
  ;-
  ;	****************************************************************************************************
  ROUTINE_NAME = 'DRAW_BOXES'
;  STOP
  
  
  _IMAGE=IMAGE
  XY =PXY(IMAGE)
  IF XY.ERROR NE '' THEN BEGIN
    PRINT,  'ERROR!!!IMAGE MUST BE A 2-DIMENSIONAL ARRAY'
    ERROR = 'IMAGE MUST BE A 2-DIMENSIONAL ARRAY'
;    RETURN,_IMAGE
  ENDIF ELSE BEGIN
    IMAGE_=IMAGE
    xy=pxy(image)
    
    PX=XY.PX
    PY=XY.PY
    
    PX_=PX-1
    PY_=PY-1
;      PRINT
  ENDELSE
  IF N_ELEMENTS(XP) EQ 0 THEN BEGIN
    PRINT,  '!!!XP MUST BE PROVIDED'
    ERROR = '!!!XP MUST BE PROVIDED'
;    RETURN,_IMAGE
  ENDIF  ELSE BEGIN
    NPOINTS=N_ELEMENTS(XP)
    XP_=XP
  ENDELSE
  IF N_ELEMENTS(YP) EQ 0 THEN BEGIN
    PRINT,  '!!!YP MUST BE PROVIDED'
    ERROR = '!!!YP MUST BE PROVIDED'
;    RETURN,_IMAGE
  ENDIF  ELSE BEGIN
    YP_=YP
  ENDELSE
  
;  IF N_ELEMENTS(WIDTH) EQ 0 THEN BEGIN
;    PRINT,  '!!!WIDTH MUST BE PROVIDED'
;    ERROR = '!!!WIDTH MUST BE PROVIDED'
;    RETURN,_IMAGE
;  ENDIF  ELSE BEGIN
;    DIAM=(WIDTH/2)  
;    
;;    DIAM=(WIDTH/2)  < 55
;  ENDELSE


  
 
  IF N_ELEMENTS(COLOR) NE NPOINTS THEN BEGIN
    PRINT,  '!!!COLOR MUST BE PROVIDED'
    ERROR = '!!!COLOR MUST BE PROVIDED' 
     COLOR_ =REPLICATE(0,NPOINTS)
  ENDIF  ELSE BEGIN 
  COLOR_ =COLOR 
  ENDELSE
  
  ;FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
  FOR NTH = 0,NPOINTS-1 DO BEGIN
    X=XP[NTH]
    Y=YP[NTH]
    ACOLOR=COLOR[NTH]
      ADIAM=(WIDTH[NTH]/2)-1  
    
    BOXL=  0 > (X-ADIAM) <  PX_
    BOXR=  0 > (X+ADIAM) <  PX_
    BOXB=  0 > (Y-ADIAM) <  PY_
    BOXT=  0 > (Y+ADIAM) <  PY_
    IF BOXL GT BOXR THEN BEGIN
      XXX=BOXL
      BOXR=BOXL
      BOXL=XXX
    ENDIF
    IF BOXB GT BOXT THEN BEGIN
      YYY=BOXB
      BOXB=BOXT
      BOXT=YYY
    ENDIF
    ; >>>  USE SUBSCRIPTING METHOD
    IMAGE_(BOXL:BOXR,BOXB:BOXT)= ACOLOR
 ENDFOR
    RETURN,IMAGE_
    
  
  
  
  
END  ; #####################  End of Routine ##############################;
