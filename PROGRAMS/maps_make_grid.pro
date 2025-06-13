pro maps_make_grid, MAPP, CHECK_STEP=CHECK_STEP

  IF NONE(MAPP) THEN MAPP = ['NESGRID2','NESGRID4','NWAGRID2','NWAGRID4','AMAPPSGRID2','AMAPPSGRID4']

  FOR M=0, N_ELEMENTS(MAPP)-1 DO BEGIN
    MP = STRUPCASE(MAPP[M])
    PROJ = 'CYLINDRICAL' 
    ROTATION = 0
    ISOTROPIC = 0
    MAPSCALE = ''
    STEP = []
    CASE MP OF 
      'NESGRID2': BEGIN
        LONGNAME = 'Northeast U.S. continental shelf 4 km equal-distance grid'
        LATMIN = 34.0D
        LATMAX = 46.0D
        LONMIN = -78.0D
        LONMAX = -62.0D
        STEP   = 0.0201938619
      END
      'NESGRID4': BEGIN
        LONGNAME = 'Northeast U.S. continental shelf 4 km equal-distance grid'
        LATMIN = 34.0D
        LATMAX = 46.0D
        LONMIN = -78.0D
        LONMAX = -62.0D
        STEP   = 0.04038993405
      END  
      'NWAGRID2': BEGIN
        LONGNAME = 'Northwest Atlantic/U.S. East Coast 2 km equal-distance grid'
        LATMIN = 24.0D
        LATMAX = 46.0D
        LONMIN = -82.0 
        LONMAX = -60.0D
        STEP   = 0.019678476
      END
      'NWAGRID4': BEGIN
        LONGNAME = 'Northwest Atlantic/U.S. East Coast 4 km equal-distance grid'
        LATMIN = 24.0D
        LATMAX = 46.0D
        LONMIN = -82.0 
        LONMAX = -60.0D
        STEP   = 0.0393588539
      END
      'AMAPPSGRID': BEGIN
        LONGNAME = 'East Coast grid for the AMAPPS model - 2 km equal-distance grid'
        LATMIN = 23.0D
        LATMAX = 52.0D
        LONMIN = -83.0D 
        LONMAX = -52.0
        STEP   = 0.019927979
      END  
      'AMAPPSGRID2': BEGIN
        LONGNAME = 'East Coast grid for the AMAPPS model - 2 km equal-distance grid'
        LATMIN = 23.0D
        LATMAX = 52.0D
        LONMIN = -83.0D
        LONMAX = -52.0
        STEP   = 0.019928164
      END
      'AMAPPSGRID4': BEGIN
        LONGNAME = 'East Coast grid for the AMAPPS model - 4 km equal-distance grid'
        LATMIN = 23.0D
        LATMAX = 52.0D
        LONMIN = -83.0D
        LONMAX = -52.0
        STEP   = 0.039858384
      END
    ENDCASE
    MLATMIN = LATMIN + (LATMAX-LATMIN)/2
    MLONMIN = LONMIN + (LONMAX-LONMIN)/2
    
    ; Determine the diamter of the pixel a^2 + b^2 = c^2 
    RES1KM = (1.0D^2 + 1.0D^2)^0.5 
    RES2KM = (2.0D^2 + 2.0D^2)^0.5
    RES4KM = (4.0D^2 + 4.0D^2)^0.5
    
        
    PLINES, 2
    print, '***** Use http://www.onlineconversion.com/map_greatcircle_distance.htm to determine the degrees difference that equals the desired resolution distance: '
    PLINES, 1
    PRINT, '  Mid-latitude = '  + NUM2STR(MLATMIN) + ' (represents the bottom latitude of the middle pixel)
    PRINT, '  Mid-longitude = ' + NUM2STR(MLONMIN) + ' (represents the left longitude of the middle pixel)
    PLINES, 1
    print, '  1 km = ' + NUM2STR(RES1KM)
    print, '  2 km = ' + NUM2STR(RES2KM)
    print, '  4 km = ' + NUM2STR(RES4KM)
    PLINES, 1
    print, '***** NOTE: the difference in degrees must be the same in both the lat and lon direction.'
    PLINES, 1
    
    IF STEP EQ [] THEN BEGIN       
      READ, MLATMAX, PROMPT = 'Enter the top latitude of the middle pixle in degrees: '   
      READ, MLONMAX, PROMPT = 'Enter the right longitude of the middle pixle in degrees: '   
      
      STEPLAT = ABS(FLOAT(MLATMIN)-FLOAT(MLATMAX))
      STEPLON = ABS(FLOAT(MLONMIN)-FLOAT(MLONMAX))
      
      IF ROUNDS(STEPLAT,5) NE ROUNDS(STEPLON,5) THEN MESSAGE, 'ERROR: the difference between the lons ' + ROUNDS(STEPLON,5) + ' and lats ' + ROUNDS(STEPLAT,5) + ' must be the same in order to create the gridded map.'
      STEP = STEPLAT
      PLINES, 1
      PRINT, 'Add ' + NUM2STR(STEP) + ' to the STEP variable in the ' + MP + ' CASE block'
      STOP
    ENDIF ELSE BEGIN
      PRINT, 'Double check STEP value: ' + NUM2STR(STEP)
      STOP
    ENDELSE
    
    LATS = LATMIN
    WHILE MAX(LATS) LT LATMAX DO LATS = [LATS,LATS(-1)+STEP]
    LONS = LONMIN
    WHILE MAX(LONS) LT LONMAX DO LONS = [LONS,LONS(-1)+STEP]
    PMM, LATS
    HELP, LATS
    PMM, LONS
    HELP, LONS
    
    PX = N_ELEMENTS(LATS)
    PY = N_ELEMENTS(LONS)
    
    RUN_MAPS_MAKE =STRUPCASE(DIALOG_MESSAGE('Run MAPS_MAKE for ' + MP +'  ENTER Y OR N',TITLE = 'Run MAPS_MAKE ',/QUESTION))

    IF RUN_MAPS_MAKE EQ 'YES' THEN BEGIN
      MAPS_MAKE, MP, PROJ=PROJ, LONGNAME=LONGNAME, P0LAT=0, P0LON=0, LATMIN=LATMIN, LATMAX=LATMAX, LONMIN=LONMIN, LONMAX=LONMAX, ROTATION=ROTATION, ISOTROPIC=ISOTROPIC, PX=PX, PY=PY, MAPSCALE=MAPSCALE
    ENDIF
      
  ENDFOR



END