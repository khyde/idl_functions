; $ID:	PIX2VEC.PRO,	2020-07-08-15,	USER-KJWH	$

function PIX2VEC, IMAGE,COLOR,MAX_DIST=max_dist,CONNECT=connect, THIN=THIN,SMOOTH=smooth,SPARSE=sparse,SHOW=show
;+
; NAME:
;       PIX2VEC
;
; PURPOSE:
;       FINDS ADJACENT (AND NEAREST) PIXELS OF A TARGET COLOR IN AN IMAGE
;       AND CONSTRUCTS AN VECTOR ARRAY CONTAINING THE PIXEL X AND Y COORDINATES
;
; CATEGORY:
;
;
; CALLING SEQUENCE:
;       Result = PIX2VEC(a)
;
; INPUTS:
;
;
; KEYWORD PARAMETERS:
;    	MAX:  Maximum Number of Pixels (distance from last pixel)
;
; OUTPUTS:
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
;       Subroutine Ordinate from Program PCXLINE.FOR (O'Reilly; 1991)
;       is used as basis of program
;       Written by:  J.E.O'Reilly, December 12,1997
;       Dec 12,2000; MADE OUTPUT FLOAT
;                    Color may be scaler or vector
;                    Added keyword MAX (Maximum distance (in Pixels) before rejecting the connection to other points)
;-

  IF N_ELEMENTS(MAX_DIST) NE 1 THEN MAX_DIST = 10; PIXELS
  IF N_ELEMENTS(IMAGE) EQ 0 OR N_ELEMENTS(COLOR) EQ 0 THEN MESSAGE,'ERROR: MUST PROVIDE AN IMAGE ARRAY AND A TARGET COLOR'


  IF KEYWORD_SET(SHOW) THEN SLIDEW,IMAGE,XVISIBLE=600,YVISIBLE=500
  pal36
; LLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLL
  FOR _COLOR = 0,N_ELEMENTS(COLOR)-1L DO BEGIN
    SEQ =0
    TARGET = COLOR(_COLOR)
    OK_COLOR = WHERE(IMAGE EQ TARGET,COUNT)
    IF COUNT EQ 0 THEN BEGIN
      PRINT, 'NO PIXELS OF COLOR: '+NUM2STR(TARGET)+' FOUND'
      CONTINUE
    ENDIF

    COPY = BYTE(IMAGE) & COPY(*,*) = 0B & COPY(OK_COLOR)=1

    IF KEYWORD_SET(THIN) THEN BEGIN
       box_of_ones = REPLICATE(1,21,21)
       D = DILATE(COPY,box_of_ones,10,10)
       T = THIN(D)
       OK_COLOR = WHERE(T EQ 2)
    ENDIF
      SEG=0L
;     Convert indices to 2 dimensional indices using JHUAPL ONE2TWO
      ONE2TWO,OK_COLOR,IMAGE,PXS,PYS

;     ================>
;     Start an array of pixel x and y positions in image
      CONNECTED_X = 0.0
      CONNECTED_Y = 0.0

      AGAIN:

      PX = DOUBLE(PXS[0])
      PY = DOUBLE(PYS[0])
      PXS = PXS(1:*)
      PYS = PYS(1:*)

;     =================>
;     Find the closest point EXCLUDING the reference point
      DIST    = (PX - PXS)^2 + (PY - PYS)^2
      SORTED  = SORT(DIST)
      DIST    = DIST(SORTED)

      PXS     = PXS(SORTED)
      PYS     = PYS(SORTED)

      IF DIST[0] LE MAX_DIST THEN BEGIN
        CONNECTED_X = [CONNECTED_X, PXS( 0)]
        CONNECTED_Y = [CONNECTED_Y, PYS[0]]
        IF N_ELEMENTS(PXS) GE 2 THEN GOTO, AGAIN
      ENDIF ELSE BEGIN
         GOTO,FINISH_SEGEMENT
      ENDELSE

      IF KEYWORD_SET(SHOW) THEN BEGIN
        PLOTS,PXS[0],PYS[0],/DEVICE,PSYM=1,COLOR=21
        PRINT,NUM2STR(TARGET)+' '+NUM2STR(SEQ)+' '+NUM2STR(PXS[0])+' '+NUM2STR(PYS[0])
        STOP
      ENDIF
      N = N_ELEMENTS(PXS)

      IF N GE 2 THEN GOTO, AGAIN
      FINISH_SEGEMENT:

      IF N_ELEMENTS(CONNECTED_X) GE 2 THEN BEGIN
;     ==========================>
;     Elimininate first (dummy) value
      CONNECTED_X =  CONNECTED_X(1:*)
      CONNECTED_Y =  CONNECTED_Y(1:*)

      IF KEYWORD_SET(CONNECT) THEN BEGIN
        CONNECTED_X = [CONNECTED_X, CONNECTED_X[0]]
        CONNECTED_Y = [CONNECTED_Y, CONNECTED_Y[0]]
      ENDIF

      IF N_ELEMENTS(SMOOTH) GE 1 THEN BEGIN
        IF SMOOTH LE 11 THEN _SMOOTH = 11 ELSE _SMOOTH = SMOOTH
          CONNECTED_X = SMOOTH(CONNECTED_X, _SMOOTH)
          CONNECTED_Y = SMOOTH(CONNECTED_Y, _SMOOTH)
      ENDIF



      IF KEYWORD_SET(SPARSE) THEN BEGIN
        NUMBER=N_ELEMENTS(CONNECTED_X)-1L
        COUNT=0
        X = CONNECTED_X(COUNT)
        Y = CONNECTED_Y(COUNT)
        IF CONNECTED_X[1] NE CONNECTED_X[0] THEN BEGIN
          DY = CONNECTED_Y[1] - CONNECTED_Y[0]
          DX = CONNECTED_X[1] - CONNECTED_X[0]
          SLOPE1 = DY/DX
        ENDIF ELSE BEGIN
          SLOPE1=9999.
        ENDELSE

        FOR N=2L,N_ELEMENTS(CONNECTED_X)-1L DO BEGIN

          IF CONNECTED_X(N) NE CONNECTED_X(N-1L) THEN BEGIN
            DY = CONNECTED_Y(N) - CONNECTED_Y(N-1L)
            DX = CONNECTED_X(N) - CONNECTED_X(N-1L)
            SLOPE2 = DY/DX
          ENDIF ELSE BEGIN
             SLOPE2=9999.
          ENDELSE
          IF SLOPE2 NE SLOPE1 THEN BEGIN
            COUNT = COUNT + 1
            X = [X, CONNECTED_X(N-1)]
            Y = [Y, CONNECTED_Y(N-1)]
            SLOPE1 = SLOPE2
          ENDIF
        ENDFOR
        X = [X, CONNECTED_X(NUMBER)]
        Y = [Y, CONNECTED_Y(NUMBER)]
        connected_x=x
        connected_y=y
      ENDIF





      XY = FLTARR(2,N_ELEMENTS(CONNECTED_X))
      XY(0,*) = (CONNECTED_X)
      XY(1,*) = (CONNECTED_Y)


      LABEL = 'COLOR_'+NUM2STR(TARGET)+'_'+NUM2STR(SEG)

;     ====================>
;     Place into structure
      IF N_ELEMENTS(ARR) EQ 0 THEN BEGIN
        ARR=CREATE_STRUCT(LABEL,XY)
      ENDIF ELSE BEGIN
        ARR=CREATE_STRUCT(ARR,LABEL,XY)
      ENDELSE
 ;
      SEG=SEG+1
      CONNECTED_X = 0
      CONNECTED_Y = 0
      ENDIF
      IF N_ELEMENTS(PXS) GE 2 THEN GOTO, AGAIN

    ENDFOR; FOR _COLOR

  RETURN,ARR
  END

