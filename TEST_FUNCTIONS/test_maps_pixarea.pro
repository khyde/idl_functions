pro test_maps_pixarea

  f = file_search('/Users/kimberly.hyde/Documents/nadata/DATASETS_SOURCE/OCCCI/V6.0/SOURCE_DATA/MAPPED_4KM_DAILY/CHL/*.nc')
  d = read_nc(f[0])
  
  lon = d.sd.lon.image
  lat = d.sd.lat.image
  
  d = arr_xy(lon[100:199],lat[100:199])
  lats = d.y
  lons = d.x
  
  mpa = maps_pixarea('LONLAT',lons=lons,lats=lats)
  stop


end