; $ID:	IMG_XPYP.PRO,	2014-12-01	$
;###########################################################################################
FUNCTION IMG_XPYP, IMG, POS=POS, CENTER=CENTER, DOUBLE=DOUBLE
;+
; NAME:
;       IMG_XPYP
;
; PURPOSE: GENERATE A 2-D ARRAY OF PIXEL POSITIONS FOR AN IMG
;; CATEGORY:
;   IMG FAMILY
;   
;   
;	KEYWORDS:
;	    POS: POSITION OF CORNER [LL,LR,UL,UR,OR CEN]
;	    POS VALUES:
;     LL: GENERATES VALS FOR THE LOWER_LEFT CORNER OF EACH PIXEL (0,0)
;     LR: GENERATES VALS FOR THE LOWER_RIGHT CORNER OF EACH PIXEL (1,0)
;     UL: GENERATES VALS FOR THE UPPER LEFT CORNER OF EACH PIXEL (0,1)
;     UR: GENERATES VALS FOR THE UPPER_RIGHT CORNER OF EACH PIXEL (1,1);			
;     CEN: GENERATES VALS FOR THE CENTER OF EACH PIXEL (0.5,0.5)
;
; PROBLEMS: NOT YET WORKING FOR 3D ARRAY
; CALLING SEQUENCE:
;				IMG = BYTARR(1024,1024)
;       RESULT = IMG_XPYP(IMG)       ; PROVIDE AN IMG ARRAY
;				OR
;				I = IMG_XPYP([1024,1024]) ; YOU MAY JUST PROVIDE DIMENSIONS OF IMG [SIZEXYZ DETERMINS PX,PY FROM THE DIMENSIONS]
;
; EXAMPLES:
;      I = IMG_XPYP([1024,1024])& X = I.X & Y = I.Y  & P,X(0,0) & P,Y(0,0) & P
;      I = IMG_XPYP([1024,1024],POS = 'LL')& X = I.X & Y = I.Y  & P,X(0,0) & P,Y(0,0)& P
;      I = IMG_XPYP([1024,1024],POS = 'LR')& X = I.X & Y = I.Y  & P,X(0,0) & P,Y(0,0)& P
;      I = IMG_XPYP([1024,1024],POS = 'UL')& X = I.X & Y = I.Y  & P,X(0,0) & P,Y(0,0)& P
;      I = IMG_XPYP([1024,1024],POS = 'UR')& X = I.X & Y = I.Y  & P,X(0,0) & P,Y(0,0)& P 
; MODIFICATION HISTORY:
;        MAY 8,  2015 WRITTEN BY:  J.E.O'REILLY - COPIED FROM IMAGE_PXPY AND UPDATED WITH KEYWORDS
;        DEC 1,  2015 MODIFIED BY: KJWH - CLEANED UP PROGRAM (ADDED TABS ETC.) AND REMOVED ELSE CASE SINCE THE DEFAULT POS = 'CEN'
;                                         ADDED IF POS EQ 'CENTER' THEN POS EQ 'CEN'
;                                         
;###########################################################################################
;-
;*************************
  ROUTINE_NAME = 'IMG_XPYP'
;*************************

  IF KEY(DOUBLE) THEN VAL = 1.0D ELSE VAL = 1
  IF NONE(POS)   THEN POS = 'CEN'      ; DEFAULT POS IS CENTER,CEN 
  IF POS EQ 'CENTER' THEN POS = 'CEN'  ; IN CASE POSITION IS ENTERED AS CENTER INSTEAD OF CEN 
  IF KEY(CENTER) THEN POS = 'CEN'
  
  CASE POS OF
    'LL': BEGIN
      XP = 0.
      YP = 0.
    END;LL
    
    'LR': BEGIN
      XP = 1.
      YP = 0.
    END;LR  
    
    'UL': BEGIN
      XP = 0.
      YP = 1.
    END;UL
    
    'UR': BEGIN
      XP = 1.
      YP = 1.
    END;UR
    'CEN': BEGIN
        XP = 0.5
        YP = 0.5
    END;CEN
  ENDCASE

  IF KEY(DOUBLE) THEN BEGIN
    XP = DOUBLE(XP)
    YP = DOUBLE(YP)  
  ENDIF;IF KEY(DOUBLE THEN BEGIN


  SZ=SIZEXYZ(IMG) ; ===> DETERMINE SIZE OF IMG
  PX = SZ.PX
  PY = SZ.PY

  RETURN, CREATE_STRUCT('X',(LINDGEN(PX) # REPLICATE(VAL,PY))  + XP, 'Y', (REPLICATE(VAL,PX)  # LINDGEN(PY))  + YP)
  

END; #####################  END OF ROUTINE ################################
