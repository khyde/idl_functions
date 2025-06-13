; $ID:	FILL_IMAGE.PRO,	2020-07-08-15,	USER-KJWH	$
pro fill_image,a,ii,extrapolate=extrapolate
;+
; ROUTINE:          fill_image
;
; USEAGE:           fill_image,a,ii
;
; PURPOSE:          fill in undefined regions of a 2-d array by interpolation
;
; INPUT:
;       a           image array with some undefined points
;       ii          index array of bad image points,
;                   E.G., ii=where(aa eq 999)
;
; keyword input
;   extrapolate     if set extrapolation is used to fill in bad values outside
;                   of region covered by convex hull of good points.
; OUTPUT:
;       a           image array with initially undefined points replaced
;                   with values that vary smoothly in both the horizontal and
;                   vertical directions.  Initially defined points are
;                   unchanged.
;
; PROCEDURE:        Use TRIANGULATE and TRIGRID to establish a linear
;                   interpolation function which is used to fill in
;                   the undefined regions.  The points used to
;                   generate the triangulation are immediately
;                   adjacent to the undefined regions. "Good data" regions
;                   are unchanged.  Execution time is increased if a
;                   large fraction of the image is undefined.
;
; EXAMPLE:
;
;   a=fltarr(16,16)
;   x=[4,11,4,11]
;   y=[4,4,11,11]
;   a(x,y)=[1,2,4,3.]
;   fill_image,a,where(a eq 0.),/extra
;   tvim,a,/scale
;   print,a(x,y)
;
;; create a test pattern, splatter on some "no data"
;; and fix it back up with FILL_IMAGE
;; compare original data with fixed up data
;
;   w8x11
;   !p.multi=[0,2,2]
;   loadct,5
;   a=randata(256,256,s=3) & a=a-min(a) & aa=a
;   tvim,a>0,/scale,title='Original Data',clev=clev
;   contour,a>0,/overplot,levels=clev
;   a(where(smooth(randomu(iseed,256,256),21) gt .51))=-999.; bad values
;   tvim,a>0,/scale,title='Missing Data'
;   fill_image,a,where(a eq -999)
;   tvim,a>0,/scale,title='Restored data'
;   contour,a>0,/overplot,levels=clev
;   confill,aa-a,levels=[-1,-.1,-.01,.01,.1,1],title='Difference',/asp,c_thic=0
;
; AUTHOR            Paul Ricchiazzi                          29oct92
;                   Institute for Computational Earth System Science
;                   University of California, Santa Barbara
;-

sz=size(a)
nx=sz[1]
ny=sz(2)

bad=bytarr(nx,ny)
bad(ii)=1
good=(dilate(bad,[[0,1,0],[1,1,1],[0,1,0]])-bad)>0<1

good([0,nx-1,0,nx-1],[0,0,ny-1,ny-1])=1b-bad([0,nx-1,0,nx-1],[0,0,ny-1,ny-1])

iedg=where(good eq 1)
xedg=iedg mod nx
yedg=iedg / nx

triangulate,xedg,yedg,tri,b
if keyword_set(extrapolate) then begin
  a(ii)=(trigrid(xedg,yedg,a(iedg),tri,[1,1],[0,0,nx-1,ny-1],extra=b))(ii)
endif else begin
  a(ii)=(trigrid(xedg,yedg,a(iedg),tri,[1,1],[0,0,nx-1,ny-1]))(ii)
endelse
end


