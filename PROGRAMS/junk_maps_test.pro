pro junk_maps_test

; maps_make, 'NESGRID', PROJ='CYLINDRICAL',LONGNAME='Northeast shelf equal-distance grid', LATMIN=34, LATMAX=46, LONMIN=-78, LONMAX=-62, ROTATION=0, ISOTROPIC=0, PX=1364, PY=1335, MAPSCALE=''

MP = 'ECGRID' ; 
PROJ = 'CYLINDRICAL'
LONGNAME = 'U.S. East Coast 1 km equal-distance grid'
ROTATION = 0
ISOTROPIC = 0
MAPSCALE = ''

lat0 = 24.5D; 34.0D
lat1 = 46.0D; 46.0D
lon0 = -84.0D ;-78.0D
lon1 = -55.0D;-62.0D

latm = lat0 + (lat1-lat0)/2
lonm = lon0 + (lon1-lon0)/2

res1km = 2.0d^0.5
res2km = 8.0d^0.5

PLINES
print, 'Use http://www.onlineconversion.com/map_greatcircle_distance.htm to determine the degrees difference that equals the desired resxkm distance'
PLINES, 1
print, 'NOTE: the difference in degrees must be the same in both the lat and lon direction.'
PLINES
 
stop

READ, STEP, PROMPT = 'Enter the distance in degrees between the coordinates: '   ; step = 0.0197029; 0.01009

lats = lat0
WHILE MAX(LATS) LT LAT1 DO LATS = [LATS,LATS(-1)+STEP]
lons = lon0
WHILE MAX(LONS) LT LON1 DO LONS = [LONS,LONS(-1)+STEP]
PMM, LATS
HELP, LATS
PMM, LONS
HELP, LONS

PX = N_ELEMENTS(LONS)
PY = N_ELEMENTS(LATS)

STOP

MAPS_MAKE, MP, PROJ=PROJ, LONGNAME=LONGNAME, P0LAT=P0LAT, P0LON=P0LON, LATMIN=LATMIN, LATMAX=LATMAX, LONMIN=LONMIN, LONMAX=LONMAX, ROTATION=ROTATION, ISOTROPIC=ISOTROPIC, PX=PX, PY=PY, MAPSCALE=MAPSCALE


STOP


map_set, /cylndrical, limits=[lat0,lon0,lat1,lon1], isotropic=0, p0_lat=40,p0_lon=-70
XYZ=CONVERT_COORD(IXY.X,IXY.Y,/DEVICE,/TO_DATA)
LONS = REFORM(XYZ(0,*),PX,PY)
LATS = REFORM(XYZ(1,*),PX,PY)


map_set, /cylndrical, limits=[lat0,lon0,lat1,lon1], isotropic=0, p0_lat=0,p0_lon=0




end