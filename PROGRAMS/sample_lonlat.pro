; $ID:	SAMPLE_LONLAT.PRO,	2020-07-08-15,	USER-KJWH	$
;+NAME/ONE LINE DESCRIPTION OF ROUTINE:
;    SAMPLE_LONLAT generates a resampling index from one lon/lat array to another
function sample_lonlat,lon1,lat1,lon2,lat2,ds,dl

    if ((n_elements(lon2) ne n_elements(lat2)) or $
        (n_elements(lon1) ne n_elements(lat1))) then begin
        print,'longitude and latitude arrays must be equal in size'
        return,-1
    endif

    if (n_elements(ds) eq 0) then ds=1
    if (n_elements(dl) eq 0) then dl=360.0

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

            dlon = lon2(i1:i2,j1:j2) - lon1(ip,is)
            dlat = lat2(i1:i2,j1:j2) - lat1(ip,is)
            dist = dlon^2 + dlat^2
            min_dist = min(dist)
            s = where(dist eq min_dist)
            upkwhere,dist,s,i,j & i = i[0]+i1 & j = j[0]+j1
            index(0,ip,is) = i
            index(1,ip,is) = j

        endif else begin

            dlon = lon2 - lon1(ip,is)
            dlat = lat2 - lat1(ip,is)
            dist = dlon^2 + dlat^2
            min_dist = min(dist)
            s = where(dist eq min_dist)
            upkwhere,dist,s,i,j & i=i[0] & j=j[0]
            index(0,ip,is) = i
            index(1,ip,is) = j

       endelse

       if (min_dist gt dl) then return,-1

       li = i
       lj = j

;        if ( i[0] eq 0 or i[0] eq np2-1 or $
;             j[0] eq 0 or j[0] eq ns2-1 ) then begin
;             print,'Hitting matching scene boundaries at ',is,ip
;             print,i[0],j[0],min_dist
;        endif

      endfor

    endfor

    return,index
end
