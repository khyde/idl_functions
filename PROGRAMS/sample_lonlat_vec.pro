; $ID:	SAMPLE_LONLAT_VEC.PRO,	2020-07-08-15,	USER-KJWH	$
;+NAME/ONE LINE DESCRIPTION OF ROUTINE:
;    SAMPLE_LONLAT generates a resampling index from one lon/lat array to another
; Returns an index, equal in size to the first (input) lon/lat pair, providing the location of the nearest element in the second (target) lon/lat pair.
;
; ds = delta-sampling, used for optimization of the search.
; dk = delta-kilometers, causes search to fail if nearest pixel in target
;      array is more than dk kilometers from input array.

function sample_lonlat_vec,lon1,lat1,lon2,lat2,ds=ds,dk=dk

    if ((n_elements(lon2) ne n_elements(lat2)) or $
        (n_elements(lon1) ne n_elements(lat1))) then begin
        print,'longitude and latitude arrays must be equal in size'
        return,-1
    endif

    if (n_elements(ds) eq 0) then ds=10  ; +/- 10 rows & columns
    if (n_elements(dk) eq 0) then dk=2   ; 2-km

    sz = size(lon1)
    if (sz[0] eq 1) then begin
       np1 = 1
       ns1 = sz[1]
    endif else begin
       np1 = sz[1]
       ns1 = sz(2)
    endelse

    sz = size(lon2)
    if (sz[0] eq 1) then begin
       np2 = 1
       ns2 = sz[1]
    endif else begin
       np2 = sz[1]
       ns2 = sz(2)
    endelse

    vec1  = lonlat2geovec(lon1,lat1)
    vec2  = lonlat2geovec(lon2,lat2)

    index = lonarr(2,np1,ns1)

    for is=0,ns1-1 do begin

      if (is mod 50 eq 0) then print,is

      li = 0
      lj = 0

      for ip=0,np1-1 do begin

        if (ip ne 0 and ip ne (np1-1)) then begin

            i1 = (li-ds) > 0
            i2 = (li+ds) < (np2-1)
            j1 = (lj-ds) > 0
            j2 = (lj+ds) < (ns2-1)

            dx = reform(vec2(0,i1:i2,j1:j2)) - vec1(0,ip,is)
            dy = reform(vec2(1,i1:i2,j1:j2)) - vec1(1,ip,is)
            dz = reform(vec2(2,i1:i2,j1:j2)) - vec1(2,ip,is)
            dist = sqrt(dx^2 + dy^2 + dz^2)
            min_dist = min(dist)
            s = where(dist eq min_dist)
            upkwhere,dist,s,i,j & i = i[0]+i1 & j = j[0]+j1
            index(0,ip,is) = i
            index(1,ip,is) = j

        endif else begin

            dx = reform(vec2(0,*,*)) - vec1(0,ip,is)
            dy = reform(vec2(1,*,*)) - vec1(1,ip,is)
            dz = reform(vec2(2,*,*)) - vec1(2,ip,is)
            dist = sqrt(dx^2 + dy^2 + dz^2)
            min_dist = min(dist)
            s = where(dist eq min_dist)
            upkwhere,dist,s,i,j & i=i[0] & j=j[0]
            index(0,ip,is) = i
            index(1,ip,is) = j

       endelse

       if (min_dist gt dk) then begin
           index(0,ip,is) = -1
           index(1,ip,is) = -1
       endif

       li = i
       lj = j

      endfor

    endfor

    return,index
end
