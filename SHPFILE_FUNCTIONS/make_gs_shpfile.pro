; $ID:	MAKE_GS_SHPFILE.PRO,	2024-01-25-10,	USER-KJWH	$
  PRO MAKE_GS_SHPFILE

;+
; NAME:
;   MAKE_GS_SHPFILE
;
; PURPOSE:
;   $PURPOSE$
;
; CATEGORY:
;   SHPFILE_FUNCTIONS
;
; CALLING SEQUENCE:
;   MAKE_GS_SHPFILE,$Parameter1$, $Parameter2$, $Keyword=Keyword$, ....
;
; REQUIRED INPUTS:
;   Parm1.......... Describe the positional input parameters here. 
;
; OPTIONAL INPUTS:
;   Parm2.......... Describe optional inputs here. If none, delete this section.
;
; KEYWORD PARAMETERS:
;   KEY1........... Document keyword parameters like this. Note that the keyword is shown in ALL CAPS!
;
; OUTPUTS:
;   OUTPUT.......... Describe the output of this program or function
;
; OPTIONAL OUTPUTS:
;   None
;
; COMMON BLOCKS: 
;   None
;
; SIDE EFFECTS:  
;   None
;
; RESTRICTIONS:  
;   None
;
; EXAMPLE:
; 
;
; NOTES:
;   $Citations or any other useful notes$
;   
; COPYRIGHT: 
; Copyright (C) 2024, Department of Commerce, National Oceanic and Atmospheric Administration, National Marine Fisheries Service,
;   Northeast Fisheries Science Center, Narragansett Laboratory.
;   This software may be used, copied, or redistributed as long as it is not sold and this copyright notice is reproduced on each copy made.
;   This routine is provided AS IS without any express or implied warranties whatsoever.
;
; AUTHOR:
;   This program was written on January 25, 2024 by Kimberly J. W. Hyde, Northeast Fisheries Science Center | NOAA Fisheries | U.S. Department of Commerce, 28 Tarzwell Dr, Narragansett, RI 02882
;    
; MODIFICATION HISTORY:
;   Jan 25, 2024 - KJWH: Initial code written
;-
; ****************************************************************************************************
  ROUTINE_NAME = 'MAKE_GS_SHPFILE'
  COMPILE_OPT IDL3
  SL = PATH_SEP()
  
  MP = 'NWA'
  SUBFILE = !S.IDL_DATA + 'MASK_SUBAREA-' + MP +'-GULF_STREAM_MEAN_POSITION.SAV'
  GSFILE = !S.IDL_DATA + 'GSmeanpath.csv'
  OVERWRITE = 1
  
  PAL_DEFAULT,R,G,B 
  BUFFER = 1
  IF ~FILE_TEST(SUBFILE) OR KEYWORD_SET(OVERWRITE) THEN BEGIN
    GSDAT = CSV_READ(GSFILE)    
    GLON = GSDAT.LON & GLAT = GSDAT.LAT
    
    BLK = MAPS_BLANK(MP,FILL=0)
    LM = READ_LANDMASK(MP)
    MS = MAPS_SIZE(MP, PX=MPX, PY=MPY)
    MLL = MAPS_2LONLAT(MP, LONS=LON, LATS=LAT)
        
    ZWIN, BLK
    MAPS_SET, MP
    LL = MAP_DEG2IMAGE(BLK,GLON,GLAT,X=PX,Y=PY,SUBS=GSUBS)
    ZWIN
    
    OK = WHERE(PX GE 0 AND PY GE 0)
    LPX = PX[OK] & LPY = PY[OK]
    
;    OK = WHERE_ARE(LON, MIN(ROUND(GLON-1)),COUNT_LONMIN) & SUB_LONMIN = OK[0]
;    OK = WHERE_ARE(LON, MAX(ROUND(GLON+1)),COUNT_LONMAX) & SUB_LONMAX = OK[0]
;    OK = WHERE_ARE(LAT, MIN(ROUND(GLAT-1)),COUNT_LATMIN) & SUB_LATMIN = OK[0]
;    OK = WHERE_ARE(LAT, MAX(ROUND(GLAT+1)),COUNT_LATMAX) & SUB_LATMAX = OK[0]
;    ARR = LM[SUB_LONMIN:SUB_LONMAX,SUB_LATMIN:SUB_LATMAX]

    W = WINDOW(DIMENSIONS=[MPX,MPY],BUFFER=BUFFER)
    IM = IMAGE(BLK,DIMENSIONS=[MPX,MPY],MARGIN=0,BACKGROUND_COLOR=[0,0,0],BUFFER=BUFFER,/CURRENT)
    PLT = PLOT(LPX,LPY,/OVERPLOT,LINESTYLE=0,THICK=10,COLOR=[255,255,255],BUFFER=BUFFER)
    IMG = IM.COPYWINDOW()
    W.CLOSE
    IM = REFORM(IMG[1,*,*])
    
    
    SUBS = WHERE(IM GT 0)
    BLK[SUBS] = 1
    ;IMG = IMG_DILATE(BLK, TARGET=22, BOX=15, SUBS=DSUBS)
    ;BLK[DSUBS] = 22
;    IMD = IMG_DILATE(IM, TARGET=255, BOX=3, SUBS=DSUBS)
    
;    KERNEL = GAUSSIAN_FUNCTION([1,1], WIDTH=5, MAXIMUM=255)
;    kernel = [ [0,1,0],[-1,0,1],[0,-1,0] ]
; ;   IMS = SMOOTH(IMD,9) 
;    RESULT = CONVOL(IM, KERNEL, INVALID=0, MISSING=0, /EDGE_TRUNCATE, /NORMALIZE)
;    OK = WHERE(RESULT NE 0)
;    RESULT[OK] = 22
   ; IMGR, RESULT, DELAY=3
    
    ;IMGR, IMS, DELAY=3
    SUBAREA_NAME = 'GULF_STREAM_MEAN_PATH'
    SUBAREA_CODE = 1
    STRUCT_WRITE, BLK, SUBAREA_NAME=SUBAREA_NAME, SUBAREA_CODE=SUBAREA_CODE, MAP=MP, PX=MPX, PY=MPY, FILE=SUBFILE
    
    SUBAREAS_IMAGE_2SHP, SUBFILE
    
    MP = 'MAB'
    MS = MAPS_SIZE(MP, PX=MPX, PY=MPY)
    SHP = READ_SHPFILE('GULF_STREAM_MEAN_POSITION', MAPP=MP)
    BATHY = READ_BATHY(MP) & BATHY = PRODS_2BYTE(BATHY,PROD='BATHY')
    IM = IMAGE(BATHY,DIMENSIONS=[MPX,MPY],RGB_TABLE=CPAL_READ('PAL_BATHY'),MARGIN=0)
    PLY = POLYGON([SHP.(0).OUTLINE_PX,SHP.(0).OUTLINE_PX[0]],[SHP.(0).OUTLINE_PY,SHP.(0).OUTLINE_PY[0]],FILL_COLOR='BLACK',/DEVICE)
    
    
    
    
STOP
;    ;===> Contour the level
;    CONTOUR,SMOOTH(FACTTOPO,SWIDTH),LEVELS=LEVEL,C_COLORS=CON_COLOR,/DEVICE,XMARGIN=[0,0],YMARGIN=[0,0],C_THICK=1,XSTYLE=5,YSTYLE=5
;    IM = TVRD()
;    SUBS     = WHERE(IM EQ CON_COLOR,COUNT_LEVEL)
;    SUBS_TXT = STRCOMPRESS(STRJOIN(STRTRIM(SUBS,2),';'))
;
;    ;===>Contour the coast_code to get PATH_INFO & PATH_XY
;    CONTOUR,SMOOTH(FACTTOPO,SWIDTH),LEVELS=LEVEL,C_COLORS=CON_COLOR,/DEVICE,XMARGIN=[0,0],YMARGIN=[0,0],C_THICK=THICK,XSTYLE=5,YSTYLE=5,PATH_INFO=PATH_INFO,PATH_XY=PATH_XY
;    ZWIN
;
;    
;      LEVEL = LEVELS[NTH]
;      THICK = THICKS[NTH]
;      COLOR = COLORS[NTH]
;      TT = TOPO_TAGS(MAPP,LEVEL)
;      OK = WHERE_STRING(FILES,TT.TAG + '-',COUNT)
;      IF COUNT NE 1 THEN CONTINUE;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
;      FILE = FILES[OK]
;      IF KEY(VERBOSE) THEN PFILE,FILE,/R
;      OPENR,LUN,FILE,/GET_LUN
;      WHILE NOT EOF(LUN) DO BEGIN
;        READF,LUN,NUM,LEVEL,FORMAT=FMT
;        LONS = DBLARR(NUM) & LONS[*] = MISSINGS(LONS)
;        LATS = DBLARR(NUM) & LATS[*] = MISSINGS(LATS)
;        READF,LUN,LONS,LATS,FORMAT=FMT
;        IF KEY(SMO) THEN BEGIN
;          LONS = SMOOTH(LONS,SMO <NOF(LONS)-1)
;          LATS = SMOOTH(LATS,SMO <NOF(LATS)-1)
;        ENDIF;IF KEY(SMO) THEN BEGIN
;        PLOTS,LONS,LATS,COLOR = COLOR,THICK = THICK
;      ENDWHILE;WHILE NOT EOF(LUN) DO BEGIN
;      CLOSE,LUN
;    ENDFOR;FOR NTH = 0,NOF(LEVELS)-1 DO BEGIN
;    ;FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
;    IM = TVRD()
;    ZWIN
;
;    OK = WHERE(IM NE 255)
;    MASK[OK] = IM[OK]
;
;    IF KEY(VIEW) THEN IMGR, MASK, PROD='DEPTH'
;    
;    
;    TOPO = PLT_TOPO(MP, -1*DEPS, COLORS=INDGEN(N_ELEMENTS(DEPS))+1);, THICKS=THICKS, COLORS=COLORS, VERBOSE=VERBOSE, VIEW=VIEW, FACT=FACT, SMO=SMO, PNGFILE=PNGFILE, PAL=PAL, LABEL=LABEL
;    SUBAREA_NAME = 'BATHY_' + NUM2STR(DEPS)
;    SUBAREA_CODE = INDGEN(N_ELEMENTS(DEPS))+1
;    STRUCT_WRITE, TOPO, SUBAREA_NAME=SUBAREA_NAME, SUBAREA_CODE=SUBAREA_CODE, MAP=MP, PX=PX, PY=PY, FILE=SUBFILE
  ENDIF
stop
  SUBAREAS_IMAGE_2SHP, SUBFILE, /LINE


END ; ***************** End of MAKE_GS_SHPFILE *****************
