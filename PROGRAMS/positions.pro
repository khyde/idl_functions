; $ID:	POSITIONS.PRO,	2020-07-08-15,	USER-KJWH	$
;+
;;#############################################################################################################
	FUNCTION POSITIONS,CB_POS,$
	                   ASPECT=ASPECT,OBJ=OBJ,$
	                   WSCALE=WSCALE,GRACE=GRACE,VERBOSE=VERBOSE
;
;
;
;
; PURPOSE: THIS FUNCTION RETURNS A FOUR ELEMENT VALUE FOR THE 
;          POSITION FOR A GRAPHIC COLORBAR OBJECT
;          AND THE POSITION FOR AN IMAGE WITHIN AN IMAGE WINDOW
; 
; 
; 
; CATEGORY:	IMAGES;		 
;
; CALLING SEQUENCE: RESULT = POSITIONS('T')
;
; INPUTS: CB_POS POSITION FOR COLORBAR [L=LEFT,R=RIGHT,B=BOTTOM,T = TOP, I = INSIDE] 

; OPTIONAL INPUTS:
;		NONE:	
;		
; KEYWORD PARAMETERS:
;   
;   ASPECT: RATIO OF THE Y DIMENSION TO THE X DIMENSION IN DATA UNITS[.1=DEFAULT]
;   OBJ:     IMAGE OBJECT TO ANCHOR THE COLORBAR TO
;   VERBOSE: PRINT THE CONTENTS OF THE POSITIONS STRUCTURE USING STRUCT_PRINT


; OUTPUTS: 
;		
;; EXAMPLES:
;  ST, POSITIONS('T')
;	NOTES:  THIS ROUTINE IS USED FOR COLORBAR PLACEMENT
;
;
; MODIFICATION HISTORY:
;			WRITTEN JAN 30, 2014 J.O'REILLY
;			JAN 31, 2014 - KJWH & JEOR MODIFIED IM_POS
;			FEB 04, 2014 - JEOR: ADDED DIMENSION FOR WINDOW W_DIM
;			FEB 06, 2014 - JEOR: ADDED IMAGE_LOCATION
;			                     ADDED WSCALE [WINDOW SCALE]
;			                     ADDED GRACE [DEFAULT = 0.01]
;			FEB 08, 2014 - JEOR: SIMPLIFIED
;			FEB 09, 2014 - JEOR: IF N_ELEMENTS(IM) GT 4 THEN ASSUME IM IS AN OBJECT
;			APR 14, 2014 - JEOR: USING NONE TO STREAMLINE CODE 
;			APR 28, 2014 - JEOR: FIXED BUG: SZ = SIZEXYZ(IMAGE) & WIDTH = SZ.PX & HEIGHT = SZ.PY
;     MAY 06, 2014 - JEOR: FIXED HANDELING OF OBJECTS
;     AUG 03, 2017 - KJWH: Formatting
;                          Changed IMAGE to IMG
;#################################################################################
;-
;***************************
ROUTINE_NAME  = 'POSITIONS'
;***************************
;===> POSITION OF IMAGE IS AT 90% TO LEAVE ROOM FOR COLORBAR
  IF NONE(CB_POS) THEN CB_POS = 'T'
  IF NONE(GRACE)  THEN GRACE = 0.01 
  IF NONE(WSCALE) THEN WSCALE = 1.2
  IF NONE(ASPECT) THEN ASPECT = 0.1
  X = [0.25,0.75] & DIF = SPAN(X) & Y = X *ASPECT
  X_OFFSET = 0.5 & Y_OFFSET = 0.5
  TICKDIR = ''
  TEXTPOS = ''
  
  IF N_ELEMENTS(OBJ) EQ 1 THEN BEGIN
    IF IDLTYPE(OBJ) EQ 'OBJREF' THEN BEGIN
      IM_TYPE = 'OBJREF'
      OBJ.GETDATA,IMG
      SZ = SIZEXYZ(IMG) & WIDTH = SZ.PX & HEIGHT = SZ.PY
      DIMENSIONS=FIX([WIDTH/(WSCALE*4),(HEIGHT/(WSCALE*4)*(WSCALE))])
    ENDIF;IF IDLTYPE(OBJ) EQ 'OBJREF' THEN BEGIN
  ENDIF ELSE BEGIN
    IM_TYPE = ''
    DIMENSIONS=FIX([4320/(WSCALE*4),(2160/(WSCALE*4)*(WSCALE))])
  ENDELSE;IF N_ELEMENTS(OBJ) EQ 1 THEN BEGIN
  
  S = CREATE_STRUCT('ASPECT',ASPECT,'WSCALE',WSCALE,'GRACE',GRACE)
  S = CREATE_STRUCT(S,'DIMENSIONS',DIMENSIONS,'IMAGE_LOCATION',[0,0])
  S = CREATE_STRUCT(S,'IM_POS',[0.0,0.0,1.0,1.0])
  
; ===> ADJUST DEPENDING ON KEYWORDS L,R,T,B,I
  CASE STRUPCASE(CB_POS)  OF
      
    'T': BEGIN
      ORIENTATION = 0  
      TEXTPOS = 1
      TICKDIR = 0
      IF N_ELEMENTS(OBJ) GT 4 THEN  Y_OFFSET =0.85
      Y = Y + Y_OFFSET 
      S.IM_POS = [0.0,0.0,1.0,0.85]
      S.IMAGE_LOCATION = [0,0]
    END; 'T': BEGIN  
    
    'B': BEGIN  
      ORIENTATION = 0
      TEXTPOS = 0
      TICKDIR = 1  
      IF N_ELEMENTS(OBJ) GT 4 THEN  Y_OFFSET =0.1
      Y = Y + Y_OFFSET
      S.IM_POS = [0.0,0.15,1.0,1.0]
      S.IMAGE_LOCATION = [0,200]
    END; 'B': BEGIN 
      
    'L': BEGIN   
      ORIENTATION = 1
      TEXTPOS = 0
      TICKDIR = 1
      IF N_ELEMENTS(OBJ) GT 4 THEN  Y_OFFSET =0.05
      Y = Y + Y_OFFSET
      SWAP,X,Y
      S.IM_POS = [0.1,0.0,1.0,1.0]
    END; 'L': BEGIN
      
    'R': BEGIN
      TEXTPOS = 1
      TICKDIR = 0
      ORIENTATION = 1
      IF N_ELEMENTS(OBJ) GT 4 THEN  Y_OFFSET =0.90
      Y = Y + Y_OFFSET
      SWAP,X,Y
      S.IM_POS = [0.0,0.0,0.9,1.0]
    END; 'R': BEGIN
      
    ELSE: BEGIN
      Y = [0,0]
      X = [0,0]
      ORIENTATION=0
      TEXTPOS=0
      TICKDIR=0
    END
  ENDCASE
  
  S = CREATE_STRUCT(S,'CB_POS',[X[0],Y[0],X[1],Y[1]],'ORIENTATION',ORIENTATION,'TEXTPOS',TEXTPOS,'TICKDIR',TICKDIR)
  IF KEYWORD_SET(VERBOSE) THEN STRUCT_PRINT,S
    
  RETURN,S
  
  DONE:          
END; #####################  END OF ROUTINE ################################
