; $ID:	ISOGRID.PRO,	2020-07-08-15,	USER-KJWH	$
 ; Notes: Program assumes that x is km and y is depth (negative values below sea surface)
 ;        bottom is also assumed neg values


 pro ISOGRID,  XDATA,  YDATA,   ZDATA,  $
               NEW_Y=new_y,$
               GRID=grid, GS=gs, LIMITS=limits, $
               MIN_VALUE=min_value, MAX_VALUE=max_value, MISSING=missing, BOTTOM=bottom, $
               y_interp=y_interp,y_extend=y_extend,$
               SIZE_GRID=size_grid, _X=_x, _Y=_y,$
               TRIANGLES=triangles, $
               BLANK_ABOVE=blank_above,BLANK_BELOW=blank_below,$
               N_PROFILES=n_profiles, SHALLOWEST=shallowest, DEEPEST=deepest, $
               OUTLINE_X=outline_x, BOT_OUTLINE=bot_outline, TOP_OUTLINE=top_outline, $
               EXTRAPOLATE=extrapolate, QUINTIC=quintic, SPHERE=sphere


  IF N_PARAMS() LT 3 THEN MESSAGE, 'ERROR: MUST PROVIDE X,Y,Z'
  x = xdata & y = ydata & z = zdata
; ====================>
; If limits not provided then make limits the range of x and the range of -1.0*y
; Note that the minimum y is then the deepest sample(most negative y)
  IF KEYWORD_SET(LIMITS) THEN BEGIN
    IF N_ELEMENTS(limits) LT 4 THEN limits = [MIN(X),MIN(Y),MAX(X),MAX(Y)]
  ENDIF ELSE BEGIN
   limits = [MIN(X),MIN(Y),MAX(X),MAX(Y)]
  ENDELSE


; ====================>
; Sort the data by km from the start of the transect and by depth from surface
   a = sort(LONG(x*1000.0d) + (-1.0*y/1000000.0D))
   y = TEMPORARY(y(a))
   x = TEMPORARY(x(a))
   z = TEMPORARY(z(a))
   IF N_ELEMENTS(BOTTOM) EQ N_ELEMENTS(y) THEN BEGIN
     BOTTOM = TEMPORARY(bottom(a))
   ENDIF
; ====================>
; Find the indices of the deepest sample from each profile (each unique x or km value)
  deepest = uniq(x) ;

; ====================>
; Determine the number of profiles
  n_profiles = N_ELEMENTS(deepest)
  nth_profile = n_profiles -1

; ====================>
; Find the indices of the shallowest sample from each profile
  shallowest = [0 ,deepest(0:n_profiles-2)+1]

; ====================>
; Get horizontal positions of profiles along the transect
  transect_kms = x(shallowest)

; ====================>
; Get deepest and shallowest depths from each profile
  deepest_depths    = y(deepest)
  shallowest_depths = y(shallowest)

; ====================>
; Vertically interpolate data to 1 meter resolution for each profile
; Note: if first depth is not zero meters (e.g. -1 or -5 meters)
;       then the interpolated data above the first value will be the
;       same as the uppermost sampling depth.  Similarly,
;       interpolated values below the last depth in the original profile
;       will be the same as the lowermost depth in the original profile.

  IF KEYWORD_SET(y_interp) THEN BEGIN
    new_x = 0.0
    new_y = 0.0
    new_z = 0.0
    FOR _profile = 0, nth_profile DO BEGIN
      first = shallowest(_profile)    ; get array subscript for first depth on profile
      last  = deepest(_profile)       ; get array subscript for last  depth on profile

;     If want to vertically extend (not extrapolate) first and or last observataion
;

;     USE THE JHUAPL INTERPX FUNCTION
      IF N_ELEMENTS(Y_EXTEND) GE 1 THEN upper = y_extend[0] > y(first) $
                                   ELSE upper = y(first)  ; least negative is choosen
      IF N_ELEMENTS(Y_EXTEND) EQ 2 THEN lower = y_extend[1] < y(last) $
                                   ELSE lower = y(last)


      iy=interval([-1.0*upper,-1.0*lower],1) ; make a depth interval at 1m between first and last depthsELSE lower = -1.0*y(last)   ; most negative is choosen


      IZ = INTERPX(-1.0*y(first:last),z(first:last),iy)
      new_x=[new_x, REPLICATE(x(first),N_ELEMENTS(iz))] ; new_x has same km value as old x
      new_y=[new_y, -1.0*iy]                  ; new_y has depths beteen first and last at 1m resolution
      new_z=[new_z, iz]                       ; new_z are interpolated data values
    ENDFOR
     x = new_x(1:*) ; eliminate first dummy value
     y = new_y(1:*)
     z = new_z(1:*)
  ENDIF

; ====================>
; Construct Delaunay Triangles to be used in TRIGRID below
  TRIANGULATE, x,y,triangles,b,CONNECTIVITY=connected

; ====================>
; Construct Grid Array using x,y,z, TRIGRID, and triangles from TRIANGULATE

; Determine Grid Spacing to be used in TRIGRID
  IF N_ELEMENTS(GS) EQ 0 OR N_ELEMENTS(GS) GT 2 THEN GS=[1.,1.]

; If min_value and max_value not provided then make these the extremes of Z
  IF N_ELEMENTS(MIN_VALUE) EQ 0 THEN min_value = MIN(Z)
  IF N_ELEMENTS(MAX_VALUE) EQ 0 THEN max_value = MAX(Z)

; Check if user supplied a missing code (See TRIGRID)
  IF N_ELEMENTS(MISSING) NE 1 THEN MISSING = 0.0

; Check if user wants a QUINTIC smooth interpolation performed
  IF N_ELEMENTS(QUINTIC) GE 1 THEN QUINTIC = 1 ELSE QUINTIC = 0

; Check if user wants spherical triangles to be used in TRIGRID
  IF N_ELEMENTS(SPHERE)  GE 1 THEN SPHERE  = 1 ELSE SHPERE  = 0

  IF N_ELEMENTS(EXTRAPOLATE) EQ 0 THEN BEGIN

   grid=TRIGRID(x,y,z,triangles,min_value=min_value,$
               GS,limits, missing=missing,QUINTIC=quintic)
  ENDIF ELSE BEGIN
   grid=TRIGRID(x,y,z,triangles,min_value=min_value,$
               GS,limits, missing=missing,QUINTIC=quintic,extrapolate=b)

  ENDELSE

; ====================>
; Determine size of resulting grid array
  SZ= SIZE(grid)
  size_grid=[sz[1],sz(2)]

; ====================>
; Blank grid elements below and or above the deepest and shallowest samples on the profiles
  IF KEYWORD_SET(BLANK_BELOW) OR  KEYWORD_SET(BLANK_ABOVE) THEN BEGIN

;    ====================>
;    Create x coordinates for a blanking outline vector
     outline_x = [limits[0],limits[0],transect_kms(*),limits(2),limits(2),limits[0]]

;    ====================>
;    Create y (upper) coordinates for a blanking outline vector
     top_outline =  [limits(3),shallowest_depths[0],shallowest_depths(*),$
                    shallowest_depths(nth_profile),$
                    limits(3),limits(3)]
;    ====================>
;    Create y (lower) coordinates for a blanking outline vector
    IF blank_below GT 1 THEN  _deepest_depths = -1.0*blank_below < deepest_depths $
                        ELSE  _deepest_depths = deepest_depths

     bot_outline =  [limits[1],_deepest_depths[0],_deepest_depths(*),$
                    _deepest_depths(nth_profile),$
                    limits[1],limits[1]]


;    ====================>
;    Do the blanking (Set array values to the missing code provided by the user)
     BLANK_X   = (outline_x-limits[0])  /(limits(2)-limits[0])*size_grid[0]
     BLANK_BOT = (BOT_OUTLINE-limits[1])/(limits(3)-limits[1])*size_grid[1]
     BLANK_TOP = (TOP_OUTLINE-limits[1])/(limits(3)-limits[1])*size_grid[1]
     IF BLANK_BELOW GE 1  THEN BEGIN
      ok = POLYFILLV(BLANK_X,BLANK_BOT,size_grid[0],size_grid[1])
      IF ok[0] NE -1 THEN GRID[OK] = missing
     ENDIF

     IF KEYWORD_SET(BLANK_ABOVE) THEN BEGIN
       ok = POLYFILLV(BLANK_X,BLANK_TOP,size_grid[0],size_grid[1])
       IF ok[0] NE -1 THEN GRID[OK] = missing
     ENDIF
  ENDIF
;   ===================>
;   Compute coordinates for contouring (See IDL CONTOUR, X,Y
    _x = limits[0]+ DINDGEN(size_grid[0])*GS[0]
    _y = limits[1]+ DINDGEN(size_grid[1])*GS[1]
  END ; END OF PROGRAM
