; $ID:	PLT_GSHHS.PRO,	2020-07-01-12,	USER-KJWH	$
;+
;#############################################################################################################
	PRO PLT_GSHHS,IMG

;
; PURPOSE: CONSTRUCT MAPS OF GSHHS COASTLINE SHAPEFILE
;
; CATEGORY:	MAPS
;
; CALLING SEQUENCE: PLT_GSHHS,STRUCT
;
; INPUTS: STRUCTURE
;		
; OPTIONAL INPUTS:
;		NONE:	
;		
; KEYWORD PARAMETERS:
;		NONE:

; OUTPUTS: 
;		
; EXAMPLES: 
;
; MODIFICATION HISTORY:
;			WRITTEN JAN 28,2014 J.O'REILLY
;			
;			
;			
;#################################################################################
;
;-
;********************************
ROUTINE_NAME  = 'PLT_GSHHS'
;********************************
;TAGNAMES = ID FROMNODE TONODE LEFTPOLYG RIGHTPOLY

DIR = !S.IDL+'SHAPEFILES\GSHHS\'
FILES = FILE_SEARCH(DIR,'*.SHP')
PL,FILES
FILES = "C:\IDL\SHAPEFILES\GSHHS\GSHHS_LAND.SHP"
FILES = "C:\IDL\SHAPEFILES\GSHHS\GSHHS_LAND.SHP"
;FILES = "C:\IDL\SHAPEFILES\GSSHHG\GSHHG-SHP-2.2.2\GSHHS_SHP\C\GSHHS_C_L1.SHP"
;FILES = "C:\IDL\SHAPEFILES\GSSHHG\GSHHG-SHP-2.2.2\GSHHS_SHP\F\GSHHS_F_L2.SHP"
;FILES = "C:\IDL\SHAPEFILES\GSSHHG\GSHHG-SHP-2.2.2\GSHHS_shp\f\GSHHS_f_L4.shp"
FILES = "C:\IDL\SHAPEFILES\GSSHHG\gshhg-shp-2.2.2\GSHHS_shp\c\GSHHS_c_L1.shp"
FILES = "C:\IDL\SHAPEFILES\GSSHHG\gshhg-shp-2.2.2\GSHHS_shp\f\GSHHS_f_L1.shp"
;FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
FOR _FILE = 0,N_ELEMENTS(FILES)-1 DO BEGIN
FILE = FILES(_FILE)
FN = FILE_PARSE(FILE)

MAPS = ['NEC']
  ;FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
  FOR NTH = 0,N_ELEMENTS(MAPS) -1 DO BEGIN
    AMAP = MAPS[NTH]
    IMG = READ_PNG("C:\IDL\LANDMASKS\MASK_LAND-NEC-PXY_1024_1024-SRTM.PNG")
    
    MAPS_SET,AMAP
    TV,IMG
    
    ;MAP_CONTINENTS,/HIRES,/FILL,COLOR = 2
    DO_ALL = 0
    AUTO = 1
    FILL = 0
    COLOR = 10
    TAGNAME = 'RIGHTPOLY'
    VERBOSE = 0
    PLOT_SHAPE, FILES,COLOR=COLOR,FILL=FILL,THICK=THICK,VERBOSE=VERBOSE,$
                GET_RANGE=GET_RANGE,TAGNAME=TAGNAME,VALUE=VALUE,$
                RANGE_X = RANGE_X, RANGE_Y = RANGE_Y,NORMAL=NORMAL,$
                DO_ALL = DO_ALL,AUTO=AUTO,_EXTRA=_EXTRA
    
    IM = TVRD()
    ZWIN
    pal36,R,G,B
    PNGFILE = !S.IDL_TEMP + FN.NAME +'-' + AMAP + '.PNG'
    WRITE_PNG,PNGFILE,IM,R,G,B
    PFILE,PNGFILE,/W
  ENDFOR;FOR NTH = 0,N_ELEMENTS(MAPS) -1 DO BEGIN
ENDFOR;FOR _FILE = 0,N_ELEMENTS(FILES)-1 DO BEGIN
;FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF


END; #####################  END OF ROUTINE ################################
