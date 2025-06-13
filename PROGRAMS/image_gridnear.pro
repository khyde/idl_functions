; $ID:	IMAGE_GRIDNEAR.PRO,	2020-06-26-15,	USER-KJWH	$

 pro  IMAGE_GRIDNEAR
;+
; NAME:
;       IMAGE_GRIDNEAR.PRO
;
; PURPOSE:
;
;
; CATEGORY:
;
;
; CALLING SEQUENCE:
;       Result = template(a)
;
; INPUTS:
;
;
; KEYWORD PARAMETERS:
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
;       Written by:  J.E.O'Reilly, Jan, 1995.
;-


;IMAGE = DIST(512)
;_MAX = MAX(IMAGE)
;IMAGE = BYTSCL(IMAGE)

  arr = readall('f:/sst_necw/MED1998JAN.ARR')
  N  = readall('f:/sst_necw/N1998JAN.ARR')
  DATAX = FINDGEN(1024)
  DATAY = DATAX
  DATAZ = ARR/100.0

  OK = WHERE(DATAZ NE 0)

  DATAX = DATAX[OK]
  DATAY = DATAY[OK]
  DATAZ = DATAZ[OK]


;   ====================>
;   Compute grid using distance-weighted means of nearest N neighbors
;   gs is the grid spacing and gx,gy are the returned grid matrix device coordinates
;
    g_size=[1024,1024]
    xrange=[0,1023]
    yrange=xrange
    limits = [0,0,1023,1023]
 ;   gs = [4.0,4.0] ; Grid spacing =5.12 pixels between grids
    gs = [4.0,4.0] ; Grid spacing =5.12 pixels between grids
 ;   search = 51.2 ; pixels
     search = 51.2 ; pixels
;    NEAR = 21
    NEAR = 21
    MIN_FIND = 2

;   ====================>
;   Do the gridding using GRIDNEAR.PRO
    grid=GRIDNEAR(dataX,dataY,dataZ,LIMITS=LIMITS,$
                      gs=gs,gx=gx,gy=gy,XRANGE=XRANGE,YRANGE=YRANGE,$
                      search=search,NEAR=NEAR,MIN_FIND=min_find ) ;,$
                      ;GRID_MASK=MASK_GRID)
STOP
;   ====================>
;   Enlarge the grid to 1024,1024
    LCHL = CONGRID(GRID,PX,PY)
    M = 21
    LCHL = MEDIAN(LCHL,M)

;   ====================>
;   Make a COPY (CHL) OF LCHL AND A grey_scale_chl image
    CHL = FLTARR(PX,PY)
    grey_chl = BYTARR(PX,PY)

END
