; $ID:	PLOTDEGL.PRO,	2020-07-08-15,	USER-KJWH	$

pro plotdegl,nosign=NOSIGN,nosymbol=NOSYMBOL,$
             noframe=noFRAME,frame_thick=FRAME_THICK,$
             frame_color=FRAME_COLOR,$
             font=FONT,X_OFFSET=X_OFFSET,Y_OFFSET=Y_OFFSET,$
             west=WEST,north=NORTH,deg=DEG,_extra=extra,$
             XMARGIN=xmargin,YMARGIN=ymargin,$
             XFUDGE=XFUDGE,YFUDGE=YFUDGE

;+
; NAME:
;       plotdegl
;
; PURPOSE:
;      Plot degree labels (lon,lat to whole degrees)
;      on top of a previously established map projection
;
; CATEGORY:
;      MAPPING,PLOTTING
;
; CALLING SEQUENCE:
;       plotdegl
;
; INPUTS:
;      None.
;
; KEYWORD PARAMETERS:
;
;      NOSIGN:     Prevents longitude signs from plotting.
;      NOSYMBOL:   Prevents plotting asuperscript degree symbol to lon,lat labels.
;      X_OFFSET:   Shifts longitude labels away from the map border (pixels).
;      Y_OFFSET:   Shifts latitude  labels away from the map border (pixels).
;      NOFRAME:    Prevents plotting a frame around the lon,lat labels
;      FRAME_THICK: Thickness of frame in pixels
;      FRAME_COLOR: Color of frame
;      _extra:     IDL convention for passing other keywords to this program.
;
; OUTPUTS:
;      Labels longitudes and latitudes.
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
;       Written by:  J.E.O'Reilly, March 17, 1995.
;       April 7,1995 Draws 'W' and 'N' symbols
;       July 2, 1997 updated references from !map.out to !map.ll_box for idl 5.0
;-

; ====================>
;	DEFAULTS
  !P.FONT = -1
  !P.charsize = 1.0
  charsize = !P.charsize
  color = !P.color

; ====================>
; Check if FONT # supplied by user.
  IF KEYWORD_SET(font) THEN _FONT = FONT ELSE _FONT = 'TIMES'
;	FONTS,_FONT

; ====================>
; Check if _extra keyword (charsize) was supplied by user.
   A = SIZE(EXTRA)
   IF A(2) EQ 8 THEN BEGIN ; e is a structure
     B=STRUPCASE(TAG_NAMES(EXTRA))
     I = -1
     I = MAX(STRPOS(B,'CHARSIZE',I))
     IF I GE 0 THEN CHARSIZE = EXTRA.CHARSIZE
     I = -1
     I = MAX(STRPOS(B,'COLOR',I))
     IF I GE 0 THEN _COLOR = EXTRA.COLOR
   ENDIF

; ====================>
; CHECK IF DEGREE PARAMETER SUPPLIED.
  IF KEYWORD_SET(DEG) EQ 0 THEN DEG = 1.0

; ====================>
; Check if keyword offset_x was supplied by user.
  IF KEYWORD_SET(X_OFFSET)EQ 0 THEN offsetx = 2 ELSE offsetx = X_OFFSET

; ====================>
; Check if keyword offset_y was supplied by user.
  IF KEYWORD_SET(Y_OFFSET)EQ 0 THEN offsety = 7*charsize ELSE offsety = Y_OFFSET

; ====================>
; Check that the map transform has been established.
  IF (!X.TYPE NE 3) THEN MESSAGE,'Map transform not established.'

; ====================>
  IF KEYWORD_SET(NOSIGN) THEN LON_SIGN = 0 ELSE LON_SIGN = 1
  IF KEYWORD_SET(NOSYMBOL) THEN SYMBOL = 0 ELSE SYMBOL = 1
  IF KEYWORD_SET(FRAME_COLOR) EQ 0 THEN FRAME_COLOR = !P.COLOR ELSE FRAME_COLOR = FRAME_COLOR
  IF KEYWORD_SET(FRAME_THICK) EQ 0 THEN FRAME_THICK = 1 ELSE FRAME_THICK = FRAME_THICK

; ====================>
; Establish  min,max of graphics window in normal coordinates
; If xmargin or ymargin is present then !x.window and !y.window
; will be >0 and < 1.0 in normal units
  X_MIN = !X.WINDOW[0]
  X_MAX = !X.WINDOW[1]
  Y_MIN = !Y.WINDOW[0]
  Y_MAX = !Y.WINDOW[1]


; ====================>
; Determine if margins exist
  IF N_ELEMENTS(XMARGIN) EQ 0 AND  N_ELEMENTS(YMARGIN) THEN MARGINS   = !X.WINDOW[0] - !X.REGION[0] ELSE MARGINS = 0.01
  IF N_ELEMENTS(XMARGIN) EQ 0 THEN XMARGINS  = !X.WINDOW    - !X.REGION ELSE XMARGINS=XMARGIN
  IF N_ELEMENTS(YMARGIN) EQ 0 THEN YMARGINS  = !Y.WINDOW    - !Y.REGION ELSE YMARGINS=YMARGIN

  XY_MARGINS = CONVERT_COORD(XMARGINS(*),YMARGINS(*),/NORMAL,/TO_DEVICE)
  IF MARGINS GE 0.01 THEN YN_MARGINS = 1 ELSE YN_MARGINS = 0

; ====================>
; Create align_x,align_y variables used to align lat,lon labels
; First subscript of align_x refers to margins (T,F = 1,0)
; If no margins present then degree labels will be drawn inside
; map box instead of outside map box.
; Second subscript refers to lon_sign (T,F = 1,0)
; Third  subscript refers to left,right,bottom,top sides of map

  ALIGN_X = FLTARR(2,2,4)
  ALIGN_Y = FLTARR(2,2,4)

;                    L    R    B     T
  ALIGN_X(0,0,*) = [-0.0, 1.0, 0.4,  0.4]
  ALIGN_X(1,0,*) = [ 1.0,-0.0, 0.4,  0.4]
  ALIGN_X(0,1,*) = [-0.0, 1.0, 0.60, 0.60]
  ALIGN_X(1,1,*) = [ 1.0,-0.0, 0.60, 0.60]

;                   L    R    B     T
  ALIGN_Y(0,0,*) = [-0.4,-0.4, 0.0, -1.0]
  ALIGN_Y(1,0,*) = [-0.4,-0.4,-1.0,  0.0]
  ALIGN_Y(0,1,*) = [-0.4,-0.4, 0.0, -1.0]
  ALIGN_Y(1,1,*) = [-0.4,-0.4,-1.0,  0.0]

; ====================>
; Compute the pixel width of map width
  XYZ = CONVERT_COORD([X_MIN,X_MAX],[Y_MIN,Y_MAX],/NORMAL,/TO_DEVICE)

  PX = ABS(XYZ(0,0)-XYZ(0,1))

; ====================>
; A fudge factor (constant) is required to obtain the reverse map
; transformation from the normal coordinates of the graphics window
; to the respective longitudes and latitudes
; If attempt to use convert_coord with exact corners of map in normal units
; you generate garbage output (limitation of map_set etc.)
; Thus, the lower_left,lower_right,upper_left,upper_right coordinates are
; in Longitude,Latitude and are very close to the actual corners

  IF N_ELEMENTS(XFUDGE) NE 1 THEN X_FUDGE = 0.0 ELSE X_FUDGE = XFUDGE
  IF N_ELEMENTS(YFUDGE) NE 1 THEN Y_FUDGE = 0.0 ELSE Y_FUDGE = YFUDGE

  LOWER_LEFT  = CONVERT_COORD(X_MIN+X_FUDGE,Y_MIN+Y_FUDGE,/NORMAL,/TO_DATA)
  LOWER_RIGHT = CONVERT_COORD(X_MAX-X_FUDGE,Y_MIN+Y_FUDGE,/NORMAL,/TO_DATA)

  UPPER_LEFT  = CONVERT_COORD(X_MIN+X_FUDGE,Y_MAX-Y_FUDGE,/NORMAL,/TO_DATA)
  UPPER_RIGHT = CONVERT_COORD(X_MAX-X_FUDGE,Y_MAX-Y_FUDGE,/NORMAL,/TO_DATA)

; ====================>
; Estimate the distance (pixels) covered by one degree
; approximately perpendicular to the left,right,bottom,top sides
; This is used to adjust the labels below or above the axes.

  deg_l =convert_coord([lower_left[0], lower_left[0]+1.0], [lower_left[1], lower_left[1]],    /data ,/to_device)
  deg_r =convert_coord([lower_right[0],lower_right[0]+1.0],[lower_right[1],lower_right[1]],   /data ,/to_device)
  deg_b =convert_coord([lower_left[0], lower_left[0]],     [lower_left[1], lower_left[1]+1.0],/data ,/to_device)
  deg_t =convert_coord([upper_left[0],upper_left[0]],      [upper_left[1], upper_left[1]+1.0],/data ,/to_device)

  deg_l = ABS(deg_l(0,0) - deg_l(0,1)) ; pixels per degree at left side
  deg_r = ABS(deg_r(0,0) - deg_r(0,1))
  deg_b = ABS(deg_b(1,0) - deg_b(1,1))
  deg_t = ABS(deg_t(1,0) - deg_t(1,1)) ; pixels per degree at top side

  off_b = (-offsety)/deg_b
  off_t = ( offsety)/deg_t
  off_l = (-offsetx)/deg_l
  off_r = ( offsetx)/deg_r

  IF yn_margins EQ 0 THEN BEGIN
    off_b = -1*off_b
    off_t = -1*off_t
    off_l = -1*off_l
    off_r = -1*off_r
  ENDIF

  deg_b = (charsize * 10  )/deg_b
  deg_t = (charsize * 10  )/deg_t
  deg_l = (charsize * 10  )/deg_l
  deg_r = (charsize * 10  )/deg_r


  IF NOT KEYWORD_SET(noframe) THEN BEGIN
    IF symbol GE 1 THEN lat_chars = 3.0 ELSE lat_chars = 2.5    ; only ~5 pixels for lower case degree sign.

    grace = lat_chars*10*charsize + (2*offsetx)  ; pixels
    l_l  = convert_coord(x_min,y_min,/normal,/to_device)
    l_r  = convert_coord(x_max,y_min,/normal,/to_device)
    u_l  = convert_coord(x_min,y_max,/normal,/to_device)
    u_r  = convert_coord(x_max,y_max,/normal,/to_device)

    x_frame = ([l_l[0]-grace, u_l[0]-grace, u_r[0]+grace,l_r[0]+grace, l_l[0]-grace])
    y_frame = ([l_l[1]-grace, u_l[1]+grace, u_r[1]+grace,l_r[1]-grace, l_l[1]-grace])

    IF MIN(x_frame) LT 0 OR MIN(y_frame) LT 0 THEN BEGIN
      x_frame = ([0.001,0.001,0.999,0.999,0.001])
      y_frame = ([0.001,0.999,0.999,0.001,0.001])
      PLOTS,x_frame,y_frame,/NORMAL,color=frame_color,thick=frame_thick
    ENDIF ELSE PLOTS,x_frame,y_frame,/DEVICE
  ENDIF

; ====================>
; Lable Lower x-axis every whole degree
  side = 2
  lon = FIX(lower_left[0]-1.5*deg)
  WHILE lon LT FLOOR(lower_right[0]) DO BEGIN
    found = 0
    lon  = lon + deg
    lat  = !map.ll_box[0] + deg
    WHILE found EQ 0 DO BEGIN
      lat = lat - 0.01*deg
      xyz = convert_coord(lon,lat,/to_normal)
      IF  xyz[1] LE y_min THEN BEGIN
        found = 1
        IF lon_sign GE 1 THEN atext = STRMID(STRTRIM(FIX(lon),2),0,4) ELSE atext = STRMID(STRTRIM(FIX(lon),2),1,4)
        IF symbol EQ 1 THEN atext = atext + '!uo' + '!N' ELSE atext = atext + '!N'
        newlat = lat + align_y(yn_margins,lon_sign,side)*deg_b +off_b
      	XYOUTS,lon,newlat, atext,ALIGN=align_x(yn_margins,lon_sign,side), _extra=extra
      ENDIF
    ENDWHILE
  ENDWHILE

; ====================>
; Check if want a 'W' west symbol
  IF KEYWORD_SET(west) AND KEYWORD_SET(nosign) THEN BEGIN
    atext =  'W' + '!N'
    xyouts,lon,newlat,atext,align=-1.6,_extra=extra
  ENDIF

; ====================>
; Lable Upper x-axis every whole degree
  side = 3
  lon = FIX(upper_left[0]-1.5*deg)
  WHILE lon LT FLOOR(upper_right[0]) DO BEGIN
    found = 0
    lon  = lon + deg
    lat  = !map.ll_box(2) - deg
    WHILE found EQ 0 DO BEGIN
      lat = lat + 0.01*deg
      xyz = convert_coord(lon,lat,/to_normal)
      IF  xyz[1] GE y_max THEN BEGIN
        found = 1
        IF lon_sign GE 1 THEN atext = STRMID(STRTRIM(FIX(lon),2),0,4) ELSE atext = STRMID(STRTRIM(FIX(lon),2),1,4)
        IF symbol EQ 1 THEN atext = atext + '!uo' + '!N' ELSE atext = atext + '!N'
        newlat = lat + align_y(yn_margins,lon_sign,side)*deg_t + off_t
      	XYOUTS,lon,newlat, atext,ALIGN=align_x(yn_margins,lon_sign,side), _extra=extra
      ENDIF
    ENDWHILE
  ENDWHILE


; ====================>
; Lable Left y-axis every whole degree
  side = 0
  lat = CEIL(lower_left[1]) -deg
  WHILE lat LT FLOOR(upper_left[1]) DO BEGIN
    found = 0
    lat  = lat + deg
    lon  = (!map.ll_box[1]+!map.ll_box(3))/2.0
    WHILE found EQ 0 DO BEGIN
      lon = lon - 0.01*deg
      xyz = convert_coord(lon,lat,/to_normal)
      IF  xyz[0] LE x_min THEN BEGIN
        found = 1
        atext = STRMID(STRTRIM(FIX(lat),2),0,4)
        IF symbol EQ 1 THEN atext = atext + '!uo' + '!N' ELSE atext = atext + '!N'
        newlon = lon + off_l
        newlat = lat + align_y(yn_margins,lon_sign,side)*deg_l
      	XYOUTS,newlon,newlat,atext,ALIGN=align_x(yn_margins,lon_sign,side), _extra=extra
      ENDIF
    ENDWHILE
  ENDWHILE

; ====================>
; Lable Right y-axis every whole degree
  side = 1
  lat = CEIL(lower_right[1]) -deg
  WHILE lat LT FLOOR(upper_right[1]) DO BEGIN
    found = 0
    lat  = lat + deg
    lon  = (!map.ll_box[1]+!map.ll_box(3))/2.0
    WHILE found EQ 0 DO BEGIN
      lon = lon + 0.01*deg
      xyz = convert_coord(lon,lat,/to_normal)
      IF  xyz[0] GE x_max THEN BEGIN
        found = 1
        atext = STRMID(STRTRIM(FIX(lat),2),0,4)
        IF symbol EQ 1 THEN atext = atext + '!uo' + '!N' ELSE atext = atext + '!N'
        newlon = lon - off_l
        newlat = lat + align_y(yn_margins,lon_sign,side)*deg_l
      	XYOUTS,newlon,newlat, atext,ALIGN=align_x(yn_margins,lon_sign,side), _extra=extra
      ENDIF
    ENDWHILE
  ENDWHILE

; ====================>
; Check if want a 'N' North symbol
  IF KEYWORD_SET(north) THEN BEGIN
    atext =  'N' + '!N'
    xyouts,newlon,(newlat -3*(align_y(yn_margins,lon_sign,side)*deg_l) ),atext,align=-.5,/data,_extra=extra
  ENDIF

   !P.FONT = -1
; ====================>
  END  ; END OF PROGRAM
