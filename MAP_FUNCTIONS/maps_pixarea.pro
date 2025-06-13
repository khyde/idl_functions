; $ID:	MAPS_PIXAREA.PRO,	2023-09-21-13,	USER-KJWH	$
;#########################################################################
 FUNCTION MAPS_PIXAREA, MAPP, LONS=LONS, LATS=LATS, SKIP_AREAS=SKIP_AREAS, OUTFILE=OUTFILE, DIR_OUT=DIR_OUT, OVERWRITE=OVERWRITE, WIDTHS=WIDTHS, HEIGHTS=HEIGHTS, AZIMUTH=AZIMUTH
;+
; NAME:
;   MAPS_PIXAREA 
;
; PURPOSE:
;   Generate an array with the area of each pixel in a standard map
;
; CATEGORY:
;   MAP_FUNCTIONS
;   
; REQUIRED INPUTS:
;   MP........... The name of a standard map
;     
;	OPTIONAL INPUTS:
;   LONS......... Longitude values for unmapped array 
;   LATS......... Latiitude values for unmapped array
;   OUTFILE...... The name of the output file
;   DIR_OUT...... The location of the output directory 
;
; KEYWORD PARAMETERS:
;   SKIP_AREAS... Keyword to skip creating the area file
;   OVERWRITE.... Overwrite saved pixel area map if exists
;   
; OUTPUTS:
;   Files that store the pixel areas for specified maps
; 
; OPTIONAL OUTPUTS:
;   WIDTHS....... An array with the width of each pixel
;   HEIGHTS...... An array with the height of each pixel
;   AZIMUTH...... An array with the azimuth angle of each pixel
;
; COMMON BLOCKS: 
;   MAPS_PIXAREA_.. Stores the map specific data to avoide needing to recreate it
;
; SIDE EFFECTS:  
;   The larger the map, the slower the program. However, the program should only need to be run once for a given map because the output is saved and can easily be read for future use.
;
; RESTRICTIONS:  
;   None
; 
; EXAMPLES: 
;   A = MAPS_PIXAREA('NEC') & PMM, A 
;   A = MAPS_PIXAREA('NWA') & PMM, A 
;   A = MAPS_PIXAREA('GS9') & PMM, A 
;
; NOTES:
;   
;
; COPYRIGHT:
; Copyright (C) 2014, Department of Commerce, National Oceanic and Atmospheric Administration, National Marine Fisheries Service,
;   Northeast Fisheries Science Center, Narragansett Laboratory.
;   This software may be used, copied, or redistributed as long as it is not sold and this copyright notice is reproduced on each copy made.
;   This routine is provided AS IS without any express or implied warranties whatsoever.
;
; AUTHOR:
;   This program was written on February 11, 2014 by Kimberly J. W. Hyde, Northeast Fisheries Science Center | NOAA Fisheries | U.S. Department of Commerce, 28 Tarzwell Dr, Narragansett, RI 02882
;
; MODIFICATION HISTORY:
;   Feb 11, 2014 - KJWH: Initial code written
;   Mar 05, 2014 - KJWH: Added GONE statements to clear up memory
;   Mar 06, 2014 - JEOR: MAPS_PIXAREA now works with GEQ map (was giving NaNs)
;                        Added XY= IMAGE_PXPY([PX,PY],CENTER=0,/DOUBLE)
;   Dec 05, 2014 - JEOR: Renamed from Kim's MAP_2PIXAREA and added some code from MAPS_PIXSIZE
;                        Now using IMG_XPYP, 
;                        Input MAP is now required
;                        Now using MAPS_SET instead of CALL_PROCEDURE 
;                        Read the MAPS_PIXAREA file if it already exists to save time  
;   Dec 9,  2014 - KJWH: Added OVERWRITE keyword in case you want to remake and existing map
;                        Added PX and PY info to the output save   
;                        Removed the PRODS_2PNG step - this should be done in the demo instead   
;                        Changed DIR_OUT to !S.MAPAREAS  
;                        Added OUTFILE as an optional input  
;   Mar 2,  2015 - KJWH: Changed .SAVE to .SAV   
;   Aug 25, 2015 - KJWH: Added "UNMAPPED" OPTION IF LONS AND LATS ARE PROVIDED  
;                        Added DIR_OUT OPTION                                           
;   Nov 12, 2015 - KJWH: Now using the POS keyword in IMG_XPYP to get the pixel locations for the mapped images     
;                        Using the "center" location from IMG_PXPY to get the center lons/lats for mapped images  
;   Nov 16, 2015 - KJWH: Added WIDTHS AND HEIGHTS KEYWORDS TO GET THE CENTER WIDTH AND HEIGHT OF EACH PIXEL 
;   Nov 17, 2015 - KJWH: Overhauled the determination of the coordinates for the lonlat map
;                          - Assume the value is the center of the pixel and take the mean distance between the center values to determine the corners
;                          - Special steps were taken to determine the pixel corners for the edges and corners of the image
;   Nov 18, 2015 - KJWH: Added SKIP_AREAS OPTION TO RETURN JUST THE WIDTHS AND HEIGHTS AND SKIP THE AREA CALCULATIONS (WHICH IS SLOW)          
;   Nov 20, 2015 - KJWH: Now able to save the lonlat outfiles if an outfile is provided                                              
;   Mar 31, 2015 - KJWH: Added steps to interpolate any missing lon/lat data.  
;                        *** At this time, it assumes the missing data is either isolated pixels or in a row.  
;                        *** This may not work if there is an entire column of data missing
;   Apr 04, 2016 - KJWH: Added "IF MAP NE 'LONLAT' THEN IF..." in the check to see if the outfile exists    
;   Jun 21, 2016 - KJWH: Removed PX and PY keywords     
;                        Added AZIMUTH KEYWORD AND MAPS_AZIMUTH TO CALCULATE THE AZIMUTH ANGLE
;                        Added A CHECK TO MAKE SURE THE IMAGE IS ORIENTATED CORRECTLY NORTH/SOUTH       
;   Jul 19, 2016 - KJWH: Changed !S.MAPAREAS to !S.MAPINFO        
;   Sep 07, 2017 - KJWH: Added steps to calculate the PIXAREA of the L3B files        
;   Sep 08, 2017 - KJWH: Tried to calculate PIXAREA by determining the LON/LATS at the 4 corners of the pixels, but it proved to be difficult due to the missing pixels on the edges at higher latitudes
;                        Now calculating the AREA simply as the average (center) width * the average (center) height.  
;                        Added IF HAS(STRUCT,'AZIMUTH') THEN AZIMUTH=STRUCT.AZIMUTH because the L3B SAV's do not have the AZIMUTH value          
;   May 20, 2019 - KJWH: Added step to see if the AREA calculation failed.  If so, just use the HEIGHTS and WIDTHS to calculate the areas 
;   Nov 18, 2022 - KJWH: Updated documentation
;                        Added COMPILE_OPT IDL2
;                        Changed input MP to MAPP for consistency with other programs
;   Nov 21, 2022 - KJWH: Change subscript () to []                                         
;-
; ****************************************************************************************************

  ROUTINE_NAME = 'MAPS_PIXAREA'
  COMPILE_OPT IDL2
  
  COMMON MAPS_PIXAREA_, STRUCT_AREAS
  IF ~N_ELEMENTS(STRUCT_AREAS) OR KEYWORD_SET(INIT) OR KEYWORD_SET(OVERWRITE) THEN STRUCT_AREAS=CREATE_STRUCT('_','')
  
  ; ===> Set up the LON/LAT constants
  LATMAX = 90.0
  LATMIN = -90.0
  LONMAX = 180.0
  LONMIN = -180.0

  ; ===> Check for the input map or coordinates
  IF ~N_ELEMENTS(MAPP) THEN MP = 'LONLAT'  ELSE  MP = STRUPCASE(MAPP)
  IF MP EQ 'LONLAT' AND ~N_ELEMENTS(LONS) THEN MESSAGE,'ERROR: If map is not specified, must provide lons'
  IF MP EQ 'LONLAT' AND ~N_ELEMENTS(LATS) THEN MESSAGE,'ERROR: If map is not specified, must provide lats'
  
  ; ===> Check the COMMON structure for the map specific data  
  OK_TAG = WHERE(TAG_NAMES(STRUCT_AREAS) EQ MP,COUNT)
  IF COUNT EQ 1 AND MP NE 'LONLAT' THEN BEGIN
    STR = STRUCT_AREAS.(OK_TAG)
    WIDTHS=STR.WIDTHS
    HEIGHTS=STR.HEIGHTS
    IF HAS(STR,'AZIMUTH') THEN AZIMUTH=STR.AZIMUTH
    RETURN, STR.DATA
  ENDIF

  ; ===> Get the MAP information  
  MS = MAPS_SIZE(MP,PX=PX,PY=PY) 
  IF MS.ERROR EQ 1 OR MS.MAP EQ 'LONLAT' THEN MS = SIZEXYZ(LONS,PX=PX,PY=PY)
  
  ; ===> Make the file label for the output file
  IF ~N_ELEMENTS(DIR_OUT) THEN DIR_OUT = !S.MAPINFO
  IF ~N_ELEMENTS(OUTFILE) AND MP NE 'LONLAT' THEN OUTFILE = DIR_OUT + STRUPCASE(MP) + '-PXY_' + ROUNDS(PX) + '_' + ROUNDS(PY) + '-PIXEL_AREAS.SAV'

  ;===> If MAPS_PIXAREA-MAP file already exists then read and return
  IF MP NE 'LONLAT' THEN IF FILE_TEST(OUTFILE) EQ 1 AND ~KEYWORD_SET(OVERWRITE) THEN BEGIN
    D = STRUCT_READ(OUTFILE,STRUCT=STRUCT)
    WIDTHS=STRUCT.WIDTHS
    HEIGHTS=STRUCT.HEIGHTS
    IF HAS(STRUCT,'AZIMUTH') THEN AZIMUTH=STRUCT.AZIMUTH
    STRUCT_AREAS=CREATE_STRUCT(TEMPORARY(STRUCT_AREAS),MP,STRUCT)
    RETURN, D
  ENDIF
  
  ; ===> Get L3B map specific information  
  IF IS_L3B(MP) THEN BEGIN
    BLL = MAPS_L3B_2LONLAT(MP)
    LATS = MAPS_L3BGS_SWAP(BLL.LATS) 
    LONS = MAPS_L3BGS_SWAP(BLL.LONS) 
    BINS = MAPS_L3BGS_SWAP(BLL.BINS)
    MS = SIZEXYZ(LONS,PX=PX,PY=PY) ; Rewrite the PX and PY values
    L3MASK = WHERE(LONS EQ MISSINGS(LONS))
    BINS[L3MASK] = 0
    FIRST_BINS = WHERE_MATCH(BINS,BLL.FIRST_BIN)
    LAST_BINS  = WHERE_MATCH(BINS,BLL.LAST_BIN)
    TOP_BINS   = WHERE(LATS[*,-1] NE MISSINGS(LATS))
    BOT_BINS   = WHERE(LATS[*, 0] NE MISSINGS(LATS))
  ENDIF
   
  ; ===> Check that lats are aligned north to south    
  IF MP EQ 'LONLAT' OR VALIDS('MAPS',MP) EQ '' THEN BEGIN
    LATS_TOP = LATS[*,-1]
    LATS_BOT = LATS[*,0]
    OK = WHERE(LATS_BOT GT LATS_TOP, COUNT_LATS)    
    
    ; ===> Check the input coordinates and fill in as missing values 
    OK = WHERE(LONS LT LONMIN OR LONS GT LONMAX, COUNT)
    IF COUNT GE 1 THEN BEGIN
      FOR L=0, PX-1 DO BEGIN
        OK = WHERE(LONS[L,*] GE LONMIN AND LONS[L,*] LE LONMAX, COUNT,COMPLEMENT=COMPLEMENT,NCOMPLEMENT=NCOMPLEMENT)
        IF NCOMPLEMENT GE 1 THEN BEGIN
          LON = REFORM(LONS[L,*])
          XX = FINDGEN(PY)
          _X = XX[OK]
          _Y = LON[OK]
          LONS[L,*] = INTERPOL(_Y,_X,XX)
         ENDIF
         OK = WHERE(LATS[L,*] GE LATMIN AND LATS[L,*] LE LATMAX, COUNT,COMPLEMENT=COMPLEMENT,NCOMPLEMENT=NCOMPLEMENT)
         IF NCOMPLEMENT GE 1 THEN BEGIN
           LAT = REFORM(LATS[L,*])
           XX = FINDGEN(PY)
           _X = XX[OK]
           _Y = LAT[OK]
           LATS[L,*] = INTERPOL(_Y,_X,XX)
         ENDIF
      ENDFOR
    ENDIF
  ENDIF ; IF MP EQ 'LONLAT' THEN BEGIN  
  
  ; ===> Establish blank arrays for the width and height arrays
  WIDTHS = DBLARR(PX,PY) & WIDTHS[*] = MISSINGS(WIDTHS) & HEIGHTS = WIDTHS 
  
  ; ===> Get the output information for the L3B maps
  IF IS_L3B(MP) THEN BEGIN
    AZIMUTH = MAPS_AZIMUTH(MP)
    AREAS = WIDTHS ; Blank array
    CN_LONS = LONS ; Assume that the LON/LAT values are the center of the pixel
    CN_LATS = LATS

    CL_EDGE = (LONS+SHIFT(LONS, 1))/2.0   ; The center left edge is the mean between the center LON and the center LON value of the pixel to the left
    CR_EDGE = (LONS+SHIFT(LONS,-1))/2.0   ; The center right edge is the mean between the center LON and the center LON value of the pixel to the right
    CB_EDGE = (LATS+SHIFT(LATS,0, 1))/2.0 ; The center bottom edge is the mean between the center LAT and the center LAT value of the pixel below
    CT_EDGE = (LATS+SHIFT(LATS,0,-1))/2.0 ; The center top edge is the mean between the center LAT and the center LAT of the pixel above
  
    CL_EDGE[FIRST_BINS] = -180.0 ; Need to correct the first valid pixel in each row to be -180
    CR_EDGE[LAST_BINS]  =  180.0 ; Need to correct the last valid pixel in each row to be 180

    CB_EDGE[BOT_BINS,0] = -90.0
    CT_EDGE[TOP_BINS,-1] = 90.0

    FOR W=0, N_ELEMENTS(WIDTHS) -1 DO IF FINITE(CL_EDGE[W]) AND FINITE(CR_EDGE[W]) THEN WIDTHS[W]  = MAP_2POINTS(CL_EDGE[W], CN_LATS[W], CR_EDGE[W], CN_LATS[W], /METERS)/1000.0 ; CALCULATE THE CENTER WIDTH OF THE PIXEL IN KM
    FOR H=0, N_ELEMENTS(HEIGHTS)-1 DO IF FINITE(CT_EDGE[H]) AND FINITE(CB_EDGE[H]) THEN HEIGHTS[H] = MAP_2POINTS(CN_LONS[H], CB_EDGE[H], CN_LONS[H], CT_EDGE[H], /METERS)/1000.0 ; CALCULATE THE CENTER HEIGHT OF THE PIXEL IN KM

    AREAS = WIDTHS * HEIGHTS ; For now, assuming the AREA is the average (center) width * the average (center) height.  It may be possible to determine the LON/LAT values of the corners, but it is a challenge because of the missing edge pixels and higher latitudes
    
    AREAS   = MAPS_L3BGS_SWAP(AREAS)
    WIDTHS  = MAPS_L3BGS_SWAP(WIDTHS)
    HEIGHTS = MAPS_L3BGS_SWAP(HEIGHTS)
    
    STRUCT_WRITE, AREAS, WIDTHS=WIDTHS, HEIGHTS=HEIGHTS, AZIMUTH=AZIMUTH, FILE=OUTFILE, PROD='PIXEL_AREA'
    D = STRUCT_READ(OUTFILE, STRUCT=STRUCT)
    STRUCT_AREAS=CREATE_STRUCT(TEMPORARY(STRUCT_AREAS),MP,STRUCT)
    RETURN, AREAS
  ENDIF
  
  ; ===> Calculate the areas for non-L3B maps
  IF MP NE 'LONLAT' AND VALIDS('MAPS',MP) NE '' AND IS_L3B(MP) EQ 0 THEN BEGIN   
    AZIMUTH = MAPS_AZIMUTH(MP)
     
    XY_BL = IMG_XPYP([PX,PY],POS='LL',/DOUBLE)  ; GET THE PIXEL VALUE FOR THE BOTTOM LEFT CORNER OF THE IMAGE
    XY_BR = IMG_XPYP([PX,PY],POS='LR',/DOUBLE)  ; GET THE PIXEL VALUE FOR THE BOTTOM RIGHT CORNER OF THE IMAGE
    XY_TL = IMG_XPYP([PX,PY],POS='UL',/DOUBLE)  ; GET THE PIXEL VALUE FOR THE TOP LEFT CORNER OF THE IMAGE
    XY_TR = IMG_XPYP([PX,PY],POS='UR',/DOUBLE)  ; GET THE PIXEL VALUE FOR THE TOP RIGHT CORNER OF THE IMAGE
    XY_CN = IMG_XPYP([PX,PY],POS='CEN',/DOUBLE) ; GET THE PIXEL VALUE FOR THE CENTER OF THE IMAGE
    MAPS_SET,MP
    BL=CONVERT_COORD(XY_BL.X,XY_BL.Y,/DEVICE,/TO_DATA) ; GET THE COORDINATES FOR THE LOWER LEFT CORNER OF THE PIXEL
    BL_LONS = REFORM(BL[0,*],PX,PY)
    BL_LATS = REFORM(BL[1,*],PX,PY)
    
    BR=CONVERT_COORD(XY_BR.X,XY_BR.Y,/DEVICE,/TO_DATA) ; GET THE COORDINATES FOR THE LOWER RIGHT CORNER OF THE PIXEL
    BR_LONS = REFORM(BR[0,*],PX,PY)
    BR_LATS = REFORM(BR[1,*],PX,PY)
    
    TL=CONVERT_COORD(XY_TL.X,XY_TL.Y,/DEVICE,/TO_DATA) ; GET THE COORDINATES FOR THE UPPER LEFT CORNER OF THE PIXEL
    TL_LONS = REFORM(TL[0,*],PX,PY)
    TL_LATS = REFORM(TL[1,*],PX,PY)
    
    TR=CONVERT_COORD(XY_TR.X,XY_TR.Y,/DEVICE,/TO_DATA) ; GET THE COORDINATES FOR THE UPPER RIGHT CORNER OF THE PIXEL
    TR_LONS = REFORM(TR[0,*],PX,PY)
    TR_LATS = REFORM(TR[1,*],PX,PY)
    
    CN=CONVERT_COORD(XY_CN.X,XY_CN.Y,/DEVICE,/TO_DATA) ; GET THE COORDINATES FOR THE CENTER OF THE PIXEL
    CN_LONS = REFORM(CN[0,*],PX,PY)
    CN_LATS = REFORM(CN[1,*],PX,PY)
    
    AVG_LLON = (BL_LONS+TL_LONS)/2.0 ; DETERMINE THE AVERAGE LONGITUDE OF THE LEFT SIDE OF THE PIXEL
    AVG_RLON = (BR_LONS+TR_LONS)/2.0 ; DETERMINE THE AVERAGE LONGITUDE OF THE RIGHT SIDE OF THE PIXEL
    
    AVG_BLAT = (BL_LATS+BR_LATS)/2.0 ; DETERMINE THE AVERAGE LATITUDE OF THE BOTTOM OF THE PIXEL
    AVG_TLAT = (TL_LATS+TR_LATS)/2.0 ; DETERMINE THE AVERAGE LATITUDE OF THE TOP OF THE PIXEL
    
    FOR W=0, N_ELEMENTS(WIDTHS) -1 DO WIDTHS[W]  = MAP_2POINTS(AVG_LLON[W],CN_LATS[W], AVG_RLON[W],CN_LATS[W], /METERS)/1000.0 ; CALCULATE THE CENTER WIDTH OF THE PIXEL IN KM
    FOR H=0, N_ELEMENTS(HEIGHTS)-1 DO HEIGHTS[H] = MAP_2POINTS(CN_LONS[H], AVG_BLAT[H],CN_LONS[H], AVG_TLAT[H],/METERS)/1000.0 ; CALCULATE THE CENTER HEIGHT OF THE PIXEL IN KM
    IF KEY(SKIP_AREAS) THEN RETURN, []
   
    ZWIN
    GONE, XY_BL
    GONE, XY_BR
    GONE, XY_TL
    GONE, XY_TR
    GONE, BL
    GONE, BR
    GONE, TL
    GONE, TR
  ENDIF ELSE BEGIN
    
    CN_LONS = LONS ; Assume that the LON/LAT values are the center of the pixel
    CN_LATS = LATS
  ;  AZIMUTH = MAPS_AZIMUTH(LONS=CN_LONS,LATS=CN_LATS)
  
    CN_LONS = LONS ; Rewrite CN_LONS and CN_LATS in case they changed during MAPS_AZIMUTH
    CN_LATS = LATS
    
    CL_EDGE = (LONS+SHIFT(LONS, 1))/2.0 ; Left edge is the mean between the center  LON and LON value of the pixel to the left 
    CR_EDGE = (LONS+SHIFT(LONS,-1))/2.0 ; Right edge is the mean between the center LON and LON value of the pixel to the right
    CL_EDGE[0, *] = LONS[0, *] - (CR_EDGE[0, *]-LONS[0, *]) ; Need to correct the 1st column of pixels by subtracting the distance between the center and right edge from the center to get the correct left edge
    CR_EDGE[-1,*] = LONS[-1,*] + (LONS[-1,*]-CL_EDGE[-1,*]) ; Need to correct the last column of pixels by adding the distance between the center and left edge to the center to get the correct right edge
    
    CB_EDGE = (LATS+SHIFT(LATS,0,-1))/2.0
    CT_EDGE = (LATS+SHIFT(LATS,0, 1))/2.0
    CB_EDGE[*,-1] = LATS[*,-1] - (CT_EDGE[*,-1]-LATS[*,-1])
    CT_EDGE[*, 0] = LATS[*, 0] - (CB_EDGE[*, 1]-LATS[*, 1]) 
              
    FOR W=0, N_ELEMENTS(WIDTHS) -1 DO IF FINITE(CL_EDGE[W]) AND FINITE(CR_EDGE[W]) THEN WIDTHS[W]  = MAP_2POINTS(CL_EDGE[W], CN_LATS[W], CR_EDGE[W], CN_LATS[W], /METERS)/1000.0 ; CALCULATE THE CENTER WIDTH OF THE PIXEL IN KM
    FOR H=0, N_ELEMENTS(HEIGHTS)-1 DO IF FINITE(CT_EDGE[H]) AND FINITE(CB_EDGE[H]) THEN HEIGHTS[H] = MAP_2POINTS(CN_LONS[H], CB_EDGE[H], CN_LONS[H], CT_EDGE[H], /METERS)/1000.0 ; CALCULATE THE CENTER HEIGHT OF THE PIXEL IN KM

    IF KEY(SKIP_AREAS) THEN RETURN, []
    
    LF = [ 1, 0]
    RT = [-1, 0]
    BT = [ 0,-1]
    TP = [ 0, 1]
    LL = [ 1,-1]
    LR = [-1,-1]
    UL = [ 1, 1]
    UR = [-1, 1]
    
;    BL_LONS = (LONS+SHIFT(LONS, 1,-1))/2.0 & BL_LATS = (LATS+SHIFT(LATS, 1,-1))/2.0
;    TL_LONS = (LONS+SHIFT(LONS, 1, 1))/2.0 & TL_LATS = (LATS+SHIFT(LATS, 1, 1))/2.0
;    BR_LONS = (LONS+SHIFT(LONS,-1,-1))/2.0 & BR_LATS = (LATS+SHIFT(LATS,-1,-1))/2.0
;    TR_LONS = (LONS+SHIFT(LONS,-1, 1))/2.0 & TR_LATS = (LATS+SHIFT(LATS,-1, 1))/2.0
  
    BL_LONS = [LONS+SHIFT(LONS,LF)+SHIFT(LONS,LL)+SHIFT(LONS,BT)]/4.0 & BL_LATS = [LATS+SHIFT(LATS,LF)+SHIFT(LATS,LL)+SHIFT(LATS,BT)]/4.0
    BR_LONS = [LONS+SHIFT(LONS,RT)+SHIFT(LONS,LR)+SHIFT(LONS,BT)]/4.0 & BR_LATS = [LATS+SHIFT(LATS,RT)+SHIFT(LATS,LR)+SHIFT(LATS,BT)]/4.0
    TL_LONS = [LONS+SHIFT(LONS,LF)+SHIFT(LONS,UL)+SHIFT(LONS,TP)]/4.0 & TL_LATS = [LATS+SHIFT(LATS,LF)+SHIFT(LATS,UL)+SHIFT(LATS,TP)]/4.0
    TR_LONS = [LONS+SHIFT(LONS,RT)+SHIFT(LONS,UR)+SHIFT(LONS,TP)]/4.0 & TR_LATS = [LATS+SHIFT(LATS,RT)+SHIFT(LATS,UR)+SHIFT(LATS,TP)]/4.0  
    
; ===> MAKE ALL OF THE EDGES MISSINGS BECAUSE THEY ARE INCORRECT
    BL_LONS[0, *] = MISSINGS(0.0) & BL_LONS[*,-1] = MISSINGS(0.0) 
    BR_LONS[-1,*] = MISSINGS(0.0) & BR_LONS[*,-1] = MISSINGS(0.0)
    TL_LONS[0, *] = MISSINGS(0.0) & TL_LONS[*, 0] = MISSINGS(0.0)
    TR_LONS[-1,*] = MISSINGS(0.0) & TR_LONS[*, 0] = MISSINGS(0.0)
    
    BL_LATS[0, *] = MISSINGS(0.0) & BL_LATS[*,-1] = MISSINGS(0.0)
    BR_LATS[-1,*] = MISSINGS(0.0) & BR_LATS[*,-1] = MISSINGS(0.0)
    TL_LATS[0, *] = MISSINGS(0.0) & TL_LATS[*, 0] = MISSINGS(0.0)
    TR_LATS[-1,*] = MISSINGS(0.0) & TR_LATS[*, 0] = MISSINGS(0.0)
    
; ===> CORRECT THE EDGES (EXCEPT FOR THE CORNERS)     
    BL_LONS[ 0,0:-2] = BL_LONS[ 1,0:-2] - (BR_LONS[ 1,0:-2] - BL_LONS[ 1,0:-2]) ; LEFT  LON EDGE 
    BR_LONS[-1,0:-2] = BR_LONS[-2,0:-2] + (BR_LONS[-2,0:-2] - BL_LONS[-2,0:-2]) ; RIGHT LON EDGE 
    TL_LONS[ 0,1: *] = TL_LONS[ 1,1: *] - (TR_LONS[ 1,1: *] - TL_LONS[ 1,1: *]) ; LEFT  LON EDGE 
    TR_LONS[-1,1: *] = TR_LONS[-2,1: *] + (TR_LONS[-2,1: *] - TL_LONS[-2,1: *]) ; RIGHT LON EDGE
   
    BL_LATS[ 0,0:-2] = BL_LATS[ 1,0:-2] - (BR_LATS[ 1,0:-2] - BL_LATS[ 1,0:-2]) ; LEFT  LAT EDGE 
    BR_LATS[-1,0:-2] = BR_LATS[-2,0:-2] + (BR_LATS[-2,0:-2] - BL_LATS[-2,0:-2]) ; RIGHT LAT EDGE 
    TL_LATS[ 0,1: *] = TL_LATS[ 1,1: *] - (TR_LATS[ 1,1: *] - TL_LATS[ 1,1: *]) ; LEFT  LAT EDGE 
    TR_LATS[-1,1: *] = TR_LATS[-2,1: *] + (TR_LATS[-2,1: *] - TL_LATS[-2,1: *]) ; RIGHT LAT EDGE 
    
    BL_LONS[1: *,-1] = BL_LONS[1: *,-2] - (TL_LONS[1: *,-2] - BL_LONS[1: *,-2]) ; BOTTOM LON EDGE
    BR_LONS[0:-2,-1] = BR_LONS[0:-2,-2] - (TR_LONS[0:-2,-2] - BR_LONS[0:-2,-2]) ; BOTTOM LON EDGE
    TL_LONS[1: *, 0] = TL_LONS[1: *, 1] + (TL_LONS[1: *, 1] - BL_LONS[1: *, 1]) ; TOP LON EDGE
    TR_LONS[0:-2, 0] = TR_LONS[0:-2, 1] + (TR_LONS[0:-2, 1] - BR_LONS[0:-2, 1]) ; TOP LON EDGE
    
    BL_LATS[1: *,-1] = BL_LATS[1:*, -2] - (TL_LATS[1:*, -2] - BL_LATS[1:*, -2]) ; BOTTOM LAT EDGE
    BR_LATS[0:-2,-1] = BR_LATS[0:-2,-2] - (TR_LATS[0:-2,-2] - BR_LATS[0:-2,-2]) ; BOTTOM LAT EDGE
    TL_LATS[1: *, 0] = TL_LATS[1:*,  1] + (TL_LATS[1:*,  1] - BL_LATS[1:*,  1]) ; TOP LAT EDGE
    TR_LATS[0:-2, 0] = TR_LATS[0:-2, 1] + (TR_LATS[0:-2, 1] - BR_LATS[0:-2, 1]) ; TOP LAT EDGE
    
; ===> FILL IN THE CORNERS BY USING THE CLOSEST VALUE IN THE RESPECTIVE COLUMN (LONS) OR ROW (LATS)    
    BL_LONS[0, -1] = BL_LONS[ 1,-1] + (BL_LONS[ 1,-1] - BL_LONS[ 2,-1])
    BR_LONS[-1,-1] = BR_LONS[-2,-1] - (BR_LONS[-3,-1] - BR_LONS[-2,-1])
    TL_LONS[0,  0] = TL_LONS[ 1, 0] + (TL_LONS[ 1, 0] - TL_LONS[ 2, 0]) 
    TR_LONS[-1, 0] = TR_LONS[-2, 0] - (TR_LONS[-3, 0] - TR_LONS[-2, 0])
    
    BL_LATS[0, -1] = BL_LATS[ 0,-2] - (BL_LATS[ 0,-3] - BL_LATS[ 0,-2])
    BR_LATS[-1,-1] = BR_LATS[-1,-2] + (BL_LATS[-1,-2] - BL_LATS[-1,-3])
    TL_LATS[0,  0] = TL_LATS[ 1, 0] - (TL_LATS[ 2, 0] - TL_LATS[ 1, 0]) 
    TR_LATS[-1, 0] = TR_LATS[-1, 1] + (TR_LATS[-1, 1] - TR_LATS[-1, 2])

; ===> FIX ANY LONS OR LATS THAT ARE SLIGHTLY LESS THAN OR GREATER THAN THE MINS AND MAX (E.G. LAT = 90.000015 CRASHES MAP_2POINTS)
    BL_LONS[WHERE(FINITE(BL_LONS) EQ 1 AND DOUBLE(BL_LONS) LT -180.0)] = -180.0 & BL_LONS[WHERE(FINITE(BL_LONS) EQ 1 AND DOUBLE(BL_LONS) LT 180.0)] = 180.0
    BR_LONS[WHERE(FINITE(BR_LONS) EQ 1 AND DOUBLE(BR_LONS) LT -180.0)] = -180.0 & BR_LONS[WHERE(FINITE(BR_LONS) EQ 1 AND DOUBLE(BR_LONS) LT 180.0)] = 180.0
    TL_LONS[WHERE(FINITE(TL_LONS) EQ 1 AND DOUBLE(TL_LONS) LT -180.0)] = -180.0 & TL_LONS[WHERE(FINITE(TL_LONS) EQ 1 AND DOUBLE(TL_LONS) LT 180.0)] = 180.0
    TR_LONS[WHERE(FINITE(TR_LONS) EQ 1 AND DOUBLE(TR_LONS) LT -180.0)] = -180.0 & TR_LONS[WHERE(FINITE(TR_LONS) EQ 1 AND DOUBLE(TR_LONS) LT 180.0)] = 180.0
    
    BL_LATS[WHERE(FINITE(BL_LATS) EQ 1 AND DOUBLE(BL_LATS) LT -90.0)] = -90.0 & BL_LATS[WHERE(FINITE(BL_LATS) EQ 1 AND DOUBLE(BL_LATS) GT 90.0)] = 90.0
    BR_LATS[WHERE(FINITE(BR_LATS) EQ 1 AND DOUBLE(BR_LATS) LT -90.0)] = -90.0 & BR_LATS[WHERE(FINITE(BR_LATS) EQ 1 AND DOUBLE(BR_LATS) GT 90.0)] = 90.0
    TL_LATS[WHERE(FINITE(TL_LATS) EQ 1 AND DOUBLE(TL_LATS) LT -90.0)] = -90.0 & TL_LATS[WHERE(FINITE(TL_LATS) EQ 1 AND DOUBLE(TL_LATS) GT 90.0)] = 90.0
    TR_LATS[WHERE(FINITE(TR_LATS) EQ 1 AND DOUBLE(TR_LATS) LT -90.0)] = -90.0 & TR_LATS[WHERE(FINITE(TR_LATS) EQ 1 AND DOUBLE(TR_LATS) GT 90.0)] = 90.0
    
    GONE, LONS
    GONE, LATS
   
  ENDELSE
  
  BDIS = BL_LONS & BDIS[*] = MISSINGS(BDIS) & TDIS = BDIS & LDIS = BDIS & RDIS = BDIS & AREAS = BDIS ; SET UP BLANK ARRAYS
  BLX = BDIS & BRX = BDIS & TLX = BDIS & TRX = BDIS
  BLY = BDIS & BRY = BDIS & TLY = BDIS & TRY = BDIS
  
;FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF  
      
  FOR B=0, N_ELEMENTS(BDIS)-1 DO IF MIN(FINITE([BL_LONS[B],BL_LATS[B],BR_LONS[B],BR_LATS[B]])) EQ 1 THEN BDIS[B] = MAP_2POINTS(BL_LONS[B],BL_LATS[B],BR_LONS[B],BR_LATS[B],/METERS)/1000.0 ; CALCULATE THE BOTTOM DISTANCE OF THE PIXEL IN KM
  FOR T=0, N_ELEMENTS(TDIS)-1 DO IF MIN(FINITE([TL_LONS[T],TL_LATS[T],TR_LONS[T],TR_LATS[T]])) EQ 1 THEN TDIS[T] = MAP_2POINTS(TL_LONS[T],TL_LATS[T],TR_LONS[T],TR_LATS[T],/METERS)/1000.0 ; CALCULATE THE TOP DISTANCE OF THE PIXEL IN KM
  FOR L=0, N_ELEMENTS(LDIS)-1 DO IF MIN(FINITE([BL_LONS[L],BL_LATS[L],TL_LONS[L],TL_LATS[L]])) EQ 1 THEN LDIS[L] = MAP_2POINTS(BL_LONS[L],BL_LATS[L],TL_LONS[L],TL_LATS[L],/METERS)/1000.0 ; CALCULATE THE LEFT SIDE DISTANCE OF THE PIXEL IN KM
  FOR R=0, N_ELEMENTS(RDIS)-1 DO IF MIN(FINITE([BR_LONS[R],BR_LATS[R],TR_LONS[R],TR_LATS[R]])) EQ 1 THEN RDIS[R] = MAP_2POINTS(BR_LONS[R],BR_LATS[R],TR_LONS[R],TR_LATS[R],/METERS)/1000.0 ; CALCULATE THE RIGHT SIDE DISTANCE OF THE PIXEL IN KM
  GONE, BL_LONS
  GONE, BL_LATS
  GONE, BR_LONS
  GONE, BR_LATS
  GONE, TL_LONS
  GONE, TL_LATS
  GONE, TR_LONS
  GONE, TR_LATS
    
  BLX[0,*] = 0.0       & BRX[0,*] = BDIS[0,*] ; INITIALIZE THE FIRST COLUMN OF THE BOTTOM LEFT AND RIGHT X PIXELS
  TLX[0,*] = 0.0       & TRX[0,*] = TDIS[0,*] ; INITIALIZE THE FIRST COLUMN OF THE TOP LEFT AND RIGHT X PIXELS
  BLY[*,0] = LDIS[*,0] & BRY[*,0] = LDIS[*,0] ; INITIALIZE THE FIRST ROW OF THE BOTTOM LEFT AND RIGHT Y PIXELS
  TLY[*,0] = 0.0       & TRY[*,0] = 0.0       ; INITIALIZE THE FIRST ROW OF THE BOTTOM LEFT AND RIGHT Y PIXELS
  
  FOR X=1, PX-1 DO BLX[X,*] = BLX[X-1,*]+BDIS[X-1,*] ; CALCULATE THE X DISTANCE OF EACH BOTTOM LEFT PIXEL FROM THE FIRST COLUMN
  FOR X=1, PX-1 DO BRX[X,*] = BRX[X-1,*]+BDIS[X,*]   ; CALCULATE THE X DISTANCE OF EACH BOTTOM RIGHT PIXEL FROM THE FIRST COLUMN
  FOR Y=1, PY-1 DO BLY[*,Y] = BLY[*,Y-1]+LDIS[*,Y-1] ; CALCULATE THE Y DISTANCE OF EACH BOTTOM RIGHT PIXEL FROM THE FIRST ROW
  FOR Y=1, PY-1 DO BRY[*,Y] = BRY[*,Y-1]+RDIS[*,Y]   ; CALCULATE THE Y DISTANCE OF EACH BOTTOM RIGHT PIXEL FROM THE FIRST ROW
  
  FOR X=1, PX-1 DO TLX[X,*] = TLX[X-1,*]+TDIS[X-1,*] ; CALCULATE THE X DISTANCE OF EACH TOP LEFT PIXEL FROM THE FIRST COLUMN
  FOR Y=1, PY-1 DO TLY[*,Y] = TLY[*,Y-1]+LDIS[*,Y-1] ; CALCULATE THE Y DISTANCE OF EACH TOP RIGHT PIXEL FROM THE FIRST ROW
  FOR X=1, PX-1 DO TRX[X,*] = TRX[X-1,*]+TDIS[X,*]   ; CALCULATE THE X DISTANCE OF EACH TOP RIGHT PIXEL FROM THE FIRST COLUMN
  FOR Y=1, PY-1 DO TRY[*,Y] = TRY[*,Y-1]+RDIS[*,Y]   ; CALCULATE THE Y DISTANCE OF EACH TOP RIGHT PIXEL FROM THE FIRST ROW
    
  FOR A=0, N_ELEMENTS(AREAS)-1 DO AREAS[A] = POLY_AREA([TLX[A],TRX[A],BRX[A],BLX[A],TLX[A]],[TLY[A],TRY[A],BRY[A],BLY[A],TLY[A]]) ; USE THE X,Y COORDINATES OF EACH PIXEL TO CALCULATE THE AREA OF THE PIXEL
  
  OK = WHERE(FINITE(AREAS) EQ 1, COUNT) ; If unable to calculate the AREA using POLY_AREA, then just use the WIDTHS and HEIGHTS
  IF COUNT EQ 0 THEN BEGIN
    AREAS = WIDTHS * HEIGHTS 
  ENDIF
  
  GONE, PX
  GONE, PY
  GONE, TLX
  GONE, TRX
  GONE, BRX
  GONE, BLX
  GONE, TLY
  GONE, TRY
  GONE, BRY
  GONE, BLY
  
  IF IS_L3B(MP) THEN BEGIN
    
    stop
  ENDIF
    
  IF MP EQ 'LONLAT' AND NONE(OUTFILE) THEN RETURN, AREAS 
  
  STRUCT_WRITE, AREAS, WIDTHS=WIDTHS, HEIGHTS=HEIGHTS, AZIMUTH=AZIMUTH, FILE=OUTFILE
  D = STRUCT_READ(OUTFILE, STRUCT=STRUCT)
  STRUCT_AREAS=CREATE_STRUCT(TEMPORARY(STRUCT_AREAS),MP,STRUCT)
  RETURN, AREAS
    

END; #####################  END OF ROUTINE ################################

