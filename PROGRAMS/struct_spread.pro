; $ID:	STRUCT_SPREAD.PRO,	2020-07-08-15,	USER-KJWH	$
;+
; NAME:
;	STRUCT_SPREAD
;

; MODIFICATION HISTORY:
;	 From idls calendar drawing
;-
;

;  compile_opt hidden

 PRO STRUCT_SPREAD ,STRUCT, POSITION=POSITION, $
 										CHARSIZE_TAGS=CHARSIZE_TAGS, COLOR_TAGS=COLOR_TAGS,$
 										CHARSIZE_DATA=CHARSIZE_DATA, COLOR_DATA=COLOR_DATA,$
 										COLOR_LINES = COLOR_LINES,$
 										FORMAT=format,TRIM=TRIM,$
 										ORIENTATION = ORIENTATION,$
 										NO_TAGS=no_tags,$
 										NO_LINES = no_lines,$
 										BACKGROUND=BACKGROUND,$
 										_EXTRA=_extra

;; ON_ERROR, 2		; Return to caller if errors

IF N_ELEMENTS(POSITION) NE 4 THEN _POSITION = [.025,.025,0.975,0.975] ELSE _POSITION = POSITION
xr = _POSITION([0,2])
yr = _POSITION([1,3])

x_range = xr[1] - xr[0]
y_range = yr[1] - yr[0]

IF KEYWORD_SET(NO_TAGS) THEN y_div = N_ELEMENTS(STRUCT) ELSE y_div = N_ELEMENTS(STRUCT)+1


NTAGS=N_TAGS(STRUCT)
NUM  = N_ELEMENTS(STRUCT)
;IF KEYWORD_SET(NO_TAGS) THEN _NUM = NUM-1 ELSE _NUM = NUM
_NUM=NUM

x_delta = x_range /  N_TAGS(STRUCT)
y_delta = y_range / y_div

Y_ABOVE = 0.1

TSIZE = 2.5 * x_range
IF N_ELEMENTS(CHARSIZE_TAGS) NE 1 THEN _CHARSIZE_TAGS = TSIZE  ELSE _CHARSIZE_TAGS = CHARSIZE_TAGS
IF N_ELEMENTS(CHARSIZE_DATA) NE 1 THEN _CHARSIZE_DATA = TSIZE  ELSE _CHARSIZE_DATA = CHARSIZE_DATA

IF N_ELEMENTS(COLOR_TAGS) NE 1 THEN _COLOR_TAGS = TC[0]  ELSE _COLOR_TAGS = TC(COLOR_TAGS)
IF N_ELEMENTS(COLOR_DATA) NE 1 THEN _COLOR_DATA = TC[0]   ELSE _COLOR_DATA = TC(COLOR_DATA)

IF N_ELEMENTS(COLOR_LINES) NE 1 THEN _COLOR_LINES = TC[0]  ELSE _COLOR_LINES = TC(COLOR_LINES)

IF N_ELEMENTS(FORMAT) NE 1 THEN FMT = '' ELSE FMT = FORMAT

IF N_ELEMENTS(ORIENTATION) NE 1 THEN _ORIENTATION = 0 ELSE _ORIENTATION = ORIENTATION

; PLOT,[0,1],[0,1],/NORMAL,XMARGIN=[0,0],YMARGIN=[0,0] ,XSTYLE=1,YSTYLE=1,/NODATA,_EXTRA=_extra

; ===> Draw Frame
   plots,/norm,[xr[0],xr[1],xr[1],xr[0],xr[0]],[yr[0],yr[0],yr[1],yr[1],yr[0]]

  IF N_ELEMENTS(_ORIENTATION) EQ 1 THEN y = yr[1] - y_delta ELSE y = yr[1]


	IF N_ELEMENTS(BACKGROUND) EQ 1 THEN POLYFILL, /norm, [_POSITION[0],_POSITION(2),_POSITION(2),_POSITION[0]],[_POSITION[1],_POSITION[1],_POSITION(3),_POSITION(3)] ,color= BACKGROUND




	IF  KEYWORD_SET(NO_LINES) THEN GOTO, SKIP_LINES
;	LLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLL
; Draw The Vertical lines
  FOR i = 0,NTAGS do begin x=xr[0]+ i*x_delta & plots,[x,x],[yr[0],y],/norm,COLOR=_COLOR_LINES & ENDFOR
;	LLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLL
; Draw The Horizontal lines

	IF N_ELEMENTS(_ORIENTATION) EQ 1 THEN _Y_DIV = Y_DIV - 1 ELSE _Y_DIV = Y_DIV
  FOR i=0,_Y_DIV do begin y=yr[0]+i*y_delta & plots,[xr[0],xr[1]],[y,y], /norm,COLOR=_COLOR_LINES & ENDFOR

	SKIP_LINES:


  Y =YR[0] + _NUM*Y_DELTA + Y_DELTA*Y_ABOVE
	NTAGS=N_TAGS(STRUCT)
	TAGNAMES= TAG_NAMES(STRUCT)

	IF NOT KEYWORD_SET(NO_TAGS) THEN BEGIN
		IF _ORIENTATION NE 0 THEN BEGIN
			_ALIGN = 0.0
		ENDIF ELSE BEGIN
			_ALIGN =  0.5
		ENDELSE

;		LLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLL
		FOR I = 0, NTAGS-1 do xyouts,/norm, size= _CHARSIZE_TAGS, align=_ALIGN,xr[0] + (I + .5) * x_delta , Y, TAGNAMES[I],COLOR=_COLOR_TAGS,ORIENTATION=_ORIENTATION, _EXTRA=_extra
	ENDIF ELSE _ALIGN = 0

; ===> Calculate Horizontal and Vertical positions
	X = FLTARR(NTAGS)
	Y = FLTARR(N_ELEMENTS(STRUCT)+1)



	Y=REVERSE(FINDGEN(_NUM))
; LLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLL
	FOR i = 0, _NUM-1 DO Y[I] = yr[0] + Y[I] * y_delta + Y_DELTA*Y_ABOVE
; LLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLL
	FOR i = 0, NTAGS-1 DO X[I] = xr[0] + (I + .95) * x_delta
	NALIGN =1.0	;


;;	LLLLLLLLLLLLLLLLLLLLLLLLLLLL
;	FOR COL = 0,NTAGS-1 DO BEGIN
;;		LLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLL
;		FOR ROW = 0,N_ELEMENTS(STRUCT)-1L DO BEGIN
;		TXT = NUM2STR(STRUCT(ROW).(COL),FORMAT=FMT,TRIM=2)
;;		TXT = STRTRIM(STRING(STRUCT(ROW).(COL),FORMAT=FMT),2)
;		XYOUTS, /norm, size= _CHARSIZE_DATA, align = NALIGN, X[COL], Y[ROW], TXT,COLOR=_COLOR_DATA, _EXTRA=_extra
;	ENDFOR
;ENDFOR



;	LLLLLLLLLLLLLLLLLLLLLLLLLLLL
	FOR COL = 0,NTAGS-1 DO BEGIN
		IF COL EQ 0 THEN TXT = STRUCT.(COL) ELSE TXT =  NUM2STR(STRUCT.(COL),FORMAT=FMT,TRIM=TRIM)

		XYOUTS, /norm, size= _CHARSIZE_DATA, align = NALIGN, X[COL], Y, TXT,COLOR=_COLOR_DATA, _EXTRA=_extra
	ENDFOR




END; #####################  End of Routine ################################
