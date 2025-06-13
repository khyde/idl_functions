; $ID:	GRIDNEAR.PRO,	2020-07-08-15,	USER-KJWH	$
  FUNCTION GRIDNEAR, $
;              === Mandatory Inputs ===:
               XDATA,  YDATA,   ZDATA  ,$
;              === Other Input Keywords ===:
               LIMITS=limits ,$
               G_SIZE = G_size, GS=gs ,$
               XRANGE = xrange, YRANGE = yrange, ZRANGE = zrange , $
               MISSING = missing ,$
               NEAR=near , SEARCH=search, MIN_FIND=min_find,$
               QUIET=quiet,$
;              === Output Keywords ===:
               GX = gx, GY = gy
;+
; NAME:
;       GRIDNEAR
;
; PURPOSE:
;       Generate a 2-d grid array
;       of distance-weighted means of nearest (n) neighboring data values
;
; CATEGORY:
;       Gridding
;
; CALLING SEQUENCE:
;
;       grid=GRIDNEAR(xdata,ydata,zdata)
;       grid=GRIDNEAR(xdata,ydata,zdata,LIMITS=[-20.17,-16.78,20.17,26.87])
;       grid=GRIDNEAR(xdata,ydata,zdata,near=8)
;       grid=GRIDNEAR(xdata,ydata,zdata,gx=gx,gy=gy)
;       grid=GRIDNEAR(xdata,ydata,zdata,missing=-9)
;       grid=GRIDNEAR(xdata,ydata,zdata,xrange=[-10,10],yrange=[-10,10])
;       grid=GRIDNEAR(xdata,ydata,zdata,zrange=[0.0001,16.0])
;
; INPUT PARAMETERS:
;
;       xdata: vector of x coordinates
;       ydata: vector of y coordinates
;       zdata: vector of z (data) values
;
; KEYWORD PARAMETERS:
;
; INPUT KEYWORDS:
;
;       limits: vector containing the desired [minimum x, minimum y, maximum x, maximum y] coordinates
;               Note that these are not limited to the ranges of x and y, ... may be smaller or larger
;
;       g_size: Vector defining the size of the output grid array, e.g. g_size = [101,102]
;
;           gs: Vector defining the desired grid spacing in units
;               of your input x and y coordinates e.g. gs  = [.4,.45]
;               Note that if you provide both g_size and gs, then g_size will
;               prevail over gs in defining the size of the grid array and the grid spacing.
;
;       xrange: The allowable range of the x coordinates to be used in gridding
;       yrange: The allowable range of the y coordinates to be used in gridding
;       zrange: The allowable range of the z data values to be used in gridding
;
;       missing: The data value to be used for missing data.
;                zdata data values identified as missing will not be used in gridding.
;
;       near:    The number of nearest neighbors which will be used to estimate the
;                distance-weighted mean value for each grid node.
;                The default is 8.
;
;       Search:  [Maximum Distance to Nearest Point from a Grid Node,
;                 Maximum Search Distance From a Grid Node]
;                 Default values are twice the distance needed to find NEAR points,
;                 and five times this distance.
;
;
; OUTPUT:
;       The function returns an array of distance-weighted means of input data values
;
; OTHER OUTPUT KEYWORDS:
;
;       GX:    An output vector of x coordinates for each grid node
;       GY:    An output vector of y coordinates for each grid node
;
;
; SIDE EFFECTS:
;       None.
;
; RESTRICTIONS:
;       Must have at least 1 data value which is within xrange,yrange,zrange,
;       and not missing, and not infinite.
;
; PROCEDURE:
;       Straightforward.
;
; MODIFICATION HISTORY:
;       Written by:  J.E.O'Reilly, April 5, 1996.
;       July 16,1996 Added Keyword SEARCH (search elipse)
;       September 4,1996 Ensure that Search values are positive
;-


; ====================>
; Check that mandatory input parameters xdata,ydata,zdata were provided
  IF N_PARAMS() LT 3 THEN MESSAGE, 'ERROR: YOU MUST PROVIDE xdata,ydata,zdata'

; ====================>
; Check if user supplied a missing code. IF not, make missing code equal to infinity
  IF N_ELEMENTS(MISSING) NE 1 THEN  MISSING = MISSINGS(zdata)

; ====================>
; Find subscripts having non-missing data (in the original input data type)
  ok = WHERE(FINITE(xdata) AND FINITE(ydata) AND FINITE(zdata) AND $
             zdata NE missing, count)

  IF count GE 1  THEN BEGIN
    x = DOUBLE(xdata(ok)) & y = DOUBLE(ydata(ok)) & z = DOUBLE(zdata(ok))
  ENDIF ELSE BEGIN
    MESSAGE, 'ERROR:  MUST HAVE AT LEAST 1  GOOD VALUE (Not Equal to Missing Code and Not Infinite)'
  ENDELSE


; ====================>
; If ranges for xdata,ydata,zdata not provided then
; make these the extremes of x,y,z
  IF N_ELEMENTS(xrange) NE 2 THEN xrange = [MIN(x), MAX(x)]
  IF N_ELEMENTS(yrange) NE 2 THEN yrange = [MIN(y), MAX(y)]
  IF N_ELEMENTS(zrange) NE 2 THEN zrange = [MIN(z), MAX(z)]

; ====================>
; Find z values within the allowable ranges for x,y,z
  ok_xyz = WHERE(x GE xrange[0] AND x LE xrange[1] AND $
                 y GE yrange[0] AND y LE yrange[1] AND $
                 z GE zrange[0] AND z LE zrange[1], count_xyz)

  IF count_xyz GE 1 THEN BEGIN
    x = x(ok_xyz) & y = y(ok_xyz) & z = z(ok_xyz)
  ENDIF ELSE BEGIN
    MESSAGE, 'ERROR:  MUST HAVE AT LEAST 1 VALUE BETWEEN min_value and max_value'
  ENDELSE

; ====================>
; If limits were not provided then make limits the range of x and the range of y
  IF N_ELEMENTS(limits) LT 4 THEN limits = [xrange[0],yrange[0],xrange[1],yrange[1]]

; ====================>
; If user did not specify the size of the grid array (g_size)
; OR the grid spacing (gs) then make the grid 50x50
; If both g_size and gs are provided then g_size will prevail over gs
  IF N_ELEMENTS(g_size) NE 2 THEN BEGIN
    IF N_ELEMENTS(gs) NE 2 THEN BEGIN
      g_size = [50,50]
    ENDIF ELSE BEGIN
      g_size=[LONG(ROUND((limits(2)-limits[0])/GS[0])),LONG(ROUND((limits(3)-limits[1])/GS[1]))]
    ENDELSE
  ENDIF

; Actual map units per grid after above rounding:
  gs_ =       (limits(2)-limits[0])/g_size[0]
  gs_ = [gs_, (limits(3)-limits[1])/g_size[1]  ]

; ====================>
; Make the grid array and set all grid values to infinity (missing)
  GRID = DBLARR(g_size[0],g_size[1]) & grid(*,*) = MISSINGS(grid)

; ====================>
; Check whether near was provided,
; If not, then use the nearest 8 neighbors to calculate
; the distance-weighted mean for each grid node
  IF N_ELEMENTS(near) NE 1 THEN near = 8
  IF near LT 1 THEN near = 8

; ====================>
; calculate x and y coordinates for each grid node
  gx = DOUBLE(limits[0]+LINDGEN(g_size[0])*(limits(2)-limits[0])/(g_size[0]-1))
  gy = DOUBLE(limits[1]+LINDGEN(g_size[1])*(limits(3)-limits[1])/(g_size[1]-1))

  IF N_ELEMENTS(MIN_FIND) NE 1 THEN MIN_FIND = 2


; ====================>
; Check Keyword SEARCH  (SEARCH ELIPSE)
  IF N_ELEMENTS(SEARCH) EQ 0 THEN BEGIN
; Notes: Assuming points evenly distributed throughout area then the radius
;        from a grid node needed to find 4,8,24,80 points is 1,1.4,2.8,4.2,5.6 units
;
;        IDL> plotxy,alog2([4,8,24,48,80]), alog2([1.0,1.4,1.41*2,1.41*3,1.41*4])
;        REDUCED MAJOR AXIS  5 -1.2172540 0.58830408 0.056550938 0.0099628707 0.99865571
;        near = [4,8,24,48,80] & print, 2.0^(-1.217)*near^0.588
;                0.971981      1.46104      2.78747      4.19002      5.65801
    radius = 2.0^(-1.217)*near^0.588
    search    = 2.0*radius ; Maximum distance allowed for nearest point to grid node
    search =[search, 5.0*radius] ; Maximum search radius to find NEAR points


; ====================>
; Determine average spacing between points (in units of x,y) assuming uniform distribution
    area = (limits(2)-limits[0])*(limits(3)-limits[1])
    side = area^0.5
    n_side= count_xyz^0.5 -1
    unit = side/n_side
    search = search*unit
  ENDIF

  search = ABS(search)     ; Search (distances) must be positive
  IF N_ELEMENTS(SEARCH) EQ 1 THEN SEARCH = [SEARCH,2.5*SEARCH]
  IF N_ELEMENTS(SEARCH) EQ 2 AND SEARCH[1] LT SEARCH[0] THEN SEARCH[1]=2.5*SEARCH[0]

  IF NOT KEYWORD_SET(QUIET) THEN BEGIN
    PRINT, 'Parameters for GRIDNEAR.PRO',SYSTIME()
    PRINT, 'Number of Points: ',count_xyz
    PRINT, 'Missing Code: ',missing
    PRINT, 'Xrange: ',xrange
    PRINT, 'Yrange: ',Yrange
    PRINT, 'Zrange: ',Zrange
    PRINT, 'Map Limits: ',limits
    PRINT, 'Grid Dimensions: ',g_size
    PRINT, 'Map Units Per Grid (x,y): ', gs_
    PRINT, 'Near (n of points to find): ',near
    PRINT, 'Search Radii: ', search
  ENDIF


; ===============>
; Now square search to eliminate some calculations below
  search = search^2.0

; ====================>
; Compute the distance-weighted z-value for each grid node
  FOR _gy = 0, g_size[1]-1 DO BEGIN
    IF _GY MOD 10 EQ 0 THEN PRINT, _GY,' OF ' , G_SIZE[1]
    FOR _gx  = 0, g_size[0]-1 DO BEGIN

;     Compute the distances between x and the grid x value:
;     Compute the distances between y and the grid y value:
;      distx = ABS(x-gx(_gx))
;      disty = ABS(y-gy(_gy))
;     Compute distances of data(x,y) to the grid node:
;      distance = (distx^2.0 + disty^2.0)^0.5
      distance = ((x-gx(_gx))^2.0 + (y-gy(_gy))^2.0)

;     See if any points are close to the grid node
      ok_close = WHERE(distance LE search[0], count_close)
;     Find subscripts of points within allowable search radius of grid node
      ok_search= WHERE(distance LE search[1], count_search)

;     (IF count_one is 0 or count_near is 0 then the
;     grid array element (_gx,_gy) is unchanged =missing value)
      IF count_close GE MIN_FIND AND count_search GE NEAR THEN BEGIN
;       Subset the points within the search radius of the grid node
        distance = distance(ok_search)^0.5
        nearz = z(ok_search)

;       Get sort index (increasing distances to grid node):
        order = SORT(distance)
;       Get the highest subscript, but not higher than near -1
        upper = (count_search-1) < (near-1)

;       Get the nearest distances (neard) to the grid node:
        neard = distance(order(0:upper))
;       Get the nearest z values:
        nearz = nearz(order(0:upper))

        dmax11 = 1.1d*MAX(neard)
;       Determine weighting function
        w = ((1-(neard/(dmax11)))^2d ) / ((neard/ (dmax11))^2d)
;       (w/TOTAL(w)) is the normalized weights whose sum equals 1.0
;       Replace the grid node with the normalized distance-weighted estimated z
        grid(_gx,_gy) = TOTAL((w/TOTAL(w))*nearz)

      ENDIF ; IF count GE 1 THEN BEGIN
    ENDFOR
  ENDFOR
  RETURN, grid

; ===================>
  END ; END OF PROGRAM
