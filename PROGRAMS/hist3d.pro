; $ID:	HIST3D.PRO,	2020-07-08-15,	USER-KJWH	$
;-------------------------------------------------------------
;+
; NAME:
;       HIST3D
; PURPOSE:
;       Compute a 3-d histogram for an array of points.
; CATEGORY:
; CALLING SEQUENCE:
;       result = hist3d( x, y, z)
; INPUTS:
;       x, y , z = 2-d point coordinates.                 in
; KEYWORD PARAMETERS:
;       Keywords:
;         MIN=mn set lower left corner of region to
;           histogram in (x,y) space.  If x and y are
;           of type byte the default is 0.  If MIN is not
;           given and type is not byte then the arrays are
;           searched for their min values.  If MIN is a scalar
;           or 1 element array then that value is applied to both
;           x and y.  To set both x and y minimums separately
;           send MIN as the 2 element array [xmin, ymin].
;         MAX=mx set upper right corner of region to
;           histogram in (x,y) space.  If MAX is not given then
;           the arrays are searched for their max values. If MAX
;           is a scalar or 1 element array then that value is applied to
;           both x and y.  To set both x and y maximums separately
;           send MAX as the 2 element array [xmax, ymax].
;         BIN=bn sets the histogram bin widths.  If BIN is a
;           scalar or a single element array then it is applied
;           to both x and y.  To set both x and y bins separately
;           send BIN as the 2 element array [xbin, ybin].
;           If BIN is not given then a value is chosen to give
;           roughly 200 bins in both x and y.
;         /LIST lists the x and y ranges and bin sizes used
;           to compute the 3-d histogram.
; OUTPUTS:
;       result = The computed 2-d histogram of x and y.  out
; COMMON BLOCKS:
;       array_map_com
;       array_map_com
; NOTES:
; MODIFICATION HISTORY:
;	R. Sterner, 24 May, 1991.
;   J. O'Reilly, Modified R.Sterner to deal with 3-d  November 22,1995
;
; Copyright (C) 1991, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------

	function hist3d, x, y, z, min=mn, max=mx, bin=bn, help=hlp, $
	  list=list

	common array_map_com, amxmn, amxstep, amymn, amystep ,amzmn, amzstep

	if (n_params[0] eq 0) or keyword_set(hlp) then begin
	  print,' Compute a 2-d histogram for an array of points.'
	  print,' h3d = hist3d( x, y, z)'
	  print,'   x, y, z = 2-d point coordinates.                 in'
	  print,'   h3d = The computed 3-d histogram of x and y.  out'
	  print,' Keywords:'
	  print,'   MIN=mn set lower left corner of region to'
	  print,'     histogram in (x,y,z) space.  If x and y and z are'
	  print,'     of type byte the default is 0.  If MIN is not'
	  print,'     given and type is not byte then the arrays are'
	  print,'     searched for their min values.  If MIN is a scalar'
	  print,'     or 1 element array then that value is applied to '
	  print,'     x,y,and z.  To set x and y and z minimums separately'
	  print,'     send MIN as the 3 element array [xmin, ymin, zmin].'
	  print,'   MAX=mx set upper right corner of region to'
	  print,'     histogram in (x,y,z) space.  If MAX is not given then'
	  print,'     the arrays are searched for their max values. If MAX'
	  print,'     is scalar or 1 element array that value is applied to'
	  print,'     x,y and z.  To set x,and y and z maximums separately'
	  print,'     send MAX as the 3 element array [xmax, ymax, zmax].'
	  print,'   BIN=bn sets the histogram bin widths.  If BIN is a'
	  print,'     scalar or a single element array then it is applied'
	  print,'     to x,y and z.  To set x, y and z bins separately'
	  print,'     send BIN as the 3 element array [xbin, ybin, zbin].'
	  print,'     If BIN is not given then a value is chosen to give'
	  print,'     roughly 256 bins in both x and y and z.'
	  print,'   /LIST lists the x and y and z ranges and bin sizes used'
	  print,'     to compute the 3-d histogram.'
	  return, -1
	endif

	;======  Process keywords  =======
	;------  MIN  -------
	if n_elements(mn) eq 0 then begin	; No MIN.
	  xmn = 0.				; Assume data type = byte.
	  ymn = 0.
	  zmn = 0.
	  sz = size(x)				; Check assumption.
	  if sz(sz[0]+1) ne 1 then begin	; Type byte?
	    xmn = min(x)			; No, search for mins.
	    ymn = min(y)
	    zmn = min(z)
	  endif
	endif else begin
	  xmn = mn[0]				; Use given MIN.
	  ymn = mn((1<(n_elements(mn)-1)))
	  zmn = mn((1<(n_elements(mn)-1)))
	endelse

print, xmn,ymn,zmn
	;------  MAX  -------
	if n_elements(mx) eq 0 then begin	; No MAX.
	  xmx = max(x)				; Search for max.
	  ymx = max(y)
	  zmx = max(z)
	endif else begin
	  xmx = mx[0]				; Use given MAX.
	  ymx = mx((1<(n_elements(mx)-1)))
	  zmx = mx((1<(n_elements(mx)-1)))
	endelse

print, xmx,ymx,zmx
	;------  BIN  -------
	if n_elements(bn) eq 0 then begin	; No BIN.
	  xbin = nicenumber((xmx-xmn)/256.)	; Pick bins to make 2-d
	  ybin = nicenumber((ymx-ymn)/256.)	; hist be about 256 x 256.
	  zbin = nicenumber((zmx-zmn)/256.)
	endif else begin
	  xbin = bn[0]				; Use given BIN.
	  ybin = bn((1<(n_elements(bn)-1)))
	  zbin = bn((1<(n_elements(bn)-1)))
	endelse

print, xbin,ybin,zbin

	;========  Process data  ==========
	;-----  Size of 2-d histogram  --------
	nx = long((xmx - xmn)/xbin)
	ny = long((ymx - ymn)/ybin)
	nz = long((zmx - zmn)/zbin)
	n = nx*ny*nz

print, nx,ny,nz
	;-----  Find data that is in range  ---------
	w = where((x ge xmn) and (x le xmx) and $
	          (y ge ymn) and (y le ymx) and $
	          (z ge zmn) and (z le zmx), count)
	if count le 0 then begin
	  print,' Error in hist3d: no data in selected range,'
	  print,'   check MIN and MAX keywords.'
	  return, -1
	endif

	;-----  Convert data to 2-d histogram indices  -------
	ix = long((x(w)-xmn)/xbin)
	iy = long((y(w)-ymn)/ybin)
	iz = long((z(w)-zmn)/zbin)

	; pro two2one, inx, iny, arr, in, help=hlp
;	in = long(.5+iny)*s[1] + long(.5+inx)
;	arr = [nx,ny,nz]
;two2one, ix, iy, [nx,ny], in	; Convert from 2-d indices to 1-d.

	in = long(iz)*ny+ long(iy)*nx + long(+ix)

print, in
   stop
	h = histogram(in,min=0,max=n-1) ; Count occurrances of 1-d indices.

	;-----  /LIST  ---------
	if keyword_set(list) then begin
	  print,' Values used to compute the 3-d histogram:'
	  print,'   xmin, xmax, xbin = ',xmn, xmx, xbin
	  print,'   ymin, ymax, ybin = ',ymn, ymx, ybin
	endif

	;-----  Set values in common  ---------
	amxmn = xmn		; This values may be used to
	amxstep = xbin  ; convert array coordinates to
	amymn = ymn		; some linear mapping.
	amystep = ybin
	amzmn = zmn		; some linear mapping.
	amzstep = zbin

	return, reform(h, [nx, ny, nz])

	end
