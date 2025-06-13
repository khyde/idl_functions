; $ID:	BIN2LL.PRO,	2015-11-23	$
;+NAME/ONE LINE DESCRIPTION OF ROUTINE:
;    BIN2LL computes the latitude/longitude values for an array of bin numbers.
;


pro bin2ll, nrows,inbin,outlat,outlon,totbins=totbins

  if (n_params() eq 0) then begin
    print, 'bin2ll, nrows,bins,latitude,longitude'
    print, ' '
    print, 'where nrows is the number of records in the BinIndex Vdata'
    print, '      bins is the input array of bin numbers'
    print, '      latitude is the output array of latitude values'
    print, '      longitude is the output array of longitude values'
    return
  endif

  i=lindgen(nrows)
  latbin=float((i + 0.5) * (180.0d0 / nrows) - 90.0)
  numbin=long(cos(latbin *!dpi/180.0) * (2.0*nrows) +0.5)
  basebin=lindgen(nrows) & basebin[0]=1
  for i=1l,nrows-1 do basebin[i]=basebin[i-1] + numbin[i-1]

  totbins = basebin[nrows-1] + numbin[nrows-1] - 1
  basebin = [basebin, totbins+1]

  n_inbin = N_ELEMENTS(inbin)

  outlat = FLTARR(n_inbin)
  outlon = FLTARR(n_inbin)

  oldrow = 1
  for i=0,n_elements(inbin)-1 do begin
    bin=long64(inbin[i])

    if (bin GE basebin[oldrow-1] and bin LT basebin[oldrow]) then begin
      row = oldrow
    endif else begin
      ;print,'in bisect'
      rlow = 1
      rhi = nrows
      row = -1
      while (row NE rlow) DO BEGIN     
        rmid = (rlow + rhi - 1) / 2
        if (basebin[rmid] GT bin)  THEN rhi = rmid ELSE rlow = rmid + 1

        if (rlow EQ rhi) then  begin
          row = rlow
          oldrow = row
        endif

      endwhile

    endelse


    lat = LATBIN[row-1]
    lon = 360.0 * (bin - BASEBIN[row-1] + 0.5) / NUMBIN[row-1]

    lon = lon - 180
    ;  *lon = *lon + SEAM_LON;  /* note, *lon returned here may be in 0 to 360 */

    outlat[i] = lat
    outlon[i]  = lon


  ENDFOR

  RETURN
END; #####################  END OF ROUTINE ################################


