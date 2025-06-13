; $ID:	PRODS_2BYTE.PRO,	2023-09-21-13,	USER-KJWH	$
;#########################################################################################################
FUNCTION PRODS_2BYTE, VALUES, PROD=PROD, LOG=LOG, MAPP=MAPP, TRUE_COLOR=TRUE_COLOR, PAL=PAL, CB_RANGE=CB_RANGE, BACKGROUND=BACKGROUND, $
                      ADD_LAND        = ADD_LAND,        LAND_COLOR        = LAND_COLOR,$
                      ADD_COAST       = ADD_COAST,       COAST_COLOR       = COAST_COLOR,$
                      ADD_THICK_COAST = ADD_THICK_COAST, COAST_THICK_COLOR = COAST_THICK_COLOR,$
                      ADD_LAKE        = ADD_LAKE,        LAKE_COLOR        = LAKE_COLOR,$
                      ADD_LAKESIDE    = ADD_LAKESIDE,    LAKESIDE_COLOR    = LAKESIDE_COLOR,$
                      ADD_SMALL_LAKE  = ADD_SMALL_LAKE,  SMALL_LAKE_COLOR  = SMALL_LAKE_COLOR, $
                      ADD_BATHY       = ADD_BATHY,       BATHY_COLOR       = BATHY_COLOR,  BATHY_THICK=BATHY_THICK, DEPTH=DEPTH
                                                         
;+
; NAME: 
;   PRODS_2BYTE
;       
; PURPOSE:  
;   This function generates byte-scaled values from geophysical values for standard prods
;				 
; CATEGORY: 
;   Product functions
;
; CALLING SEQUENCE:
;   RESULT = PRODS_2BYTE(VALUES,PROD=PROD)
;
; REQUIRED INPUTS:
;   VALUES.............. Geophysical data 
;   PROD................ A standard product name (e.g. 'SST', 'NUM', 'NUM_0_10')
;
; OPTIONAL INPUTS
;   MAPP................ The name of a standard map (e.g. 'NES', 'NWA', 'GEQ') to extract the landmask information 
;   PAL................. The name of a standard color palette (e.g. 'PAL_DEFAULT')
;   BACKGROUND.......... The byte value for the background color (default = 255)
;   CB_RANGE............ The range for the colorbar scaling (default = 1-250)
;   LAND_COLOR.......... Color for the land pixels
;   COAST_COLOR......... Coastline color
;   THICK_COAST_COLOR... "Thick" coastline color
;   LAKE_COLOR.......... Lake color
;   SMALL_LAKE_COLOR.... Small lake color
;
; KEYWORD PARAMETERS:	
;   LOG................. To force the data to be log scaled
;   TRUE_COLOR.......... To return a true_color (3d - r,g,b) image
;   ADD_LAND............ Add the landmask if the MAPP is provided
;   ADD_COAST........... Add the coastline if the MAPP is provided
;   ADD_THICK_COAST..... Add the "thick" coastline if the MAPP is provided
;   ADD_LAKE............ Add the big lakes if the MAPP is provided
;   ADD_LAKESIDE........ Add the lake coastline if the MAPP is provided
;   LAKESIDE_COLOR...... Lake coastlinen color
;   ADD_SMALL_LAKE...... Add the small lakes if the MAPP is provided
;    
; OUTPUTS:  
;   Byte-scaled values based on the input product 
;
; OPTIONAL OUTPUTS:
;   A 3-dimensional R,G,B array  
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
;   S = PRODS_READ('CHLOR_A') & B = PRODS_2BYTE([S.LOWER,S.UPPER],PROD = S.PROD) & P,B
;   S = PRODS_READ('SST') & B = PRODS_2BYTE([S.LOWER,S.UPPER],PROD = S.PROD) & P,B
;   PRINT, PRODS_2BYTE([0.0001,0.0001,0.01,1,10,100,1000], PROD='CHLOR_A')
;   PRINT, PRODS_2BYTE([1,10,100,1000,9000,10000],PROD='CNUM')
;   PRINT, PRODS_2BYTE([1,10,100,1000,9000,10000],PROD='CNUM',/TRUE_COLOR) ; Will not generate a true color image because it is not 2D
;
; NOTES:
;   Replaced SD_SCALES - Compares well, but not exactly probably because SD_SCALES did not always use the [1-250] byte scale range 
;     VALUES = DOUBLE([0.010,0.011,1,3,10,100,1000])
;     PRINT, PRODS_2BYTE(VALUES, PROD='CHLOR_A')
;     PRINT, SD_SCALES(VALUES, PROD='CHLOR_A', /DATA2BIN,BIN_BOT=1,BIN_TOP = 250)
;
; COPYRIGHT:
; Copyright (C) 2013, Department of Commerce, National Oceanic and Atmospheric Administration, National Marine Fisheries Service,
;   Northeast Fisheries Science Center, Narragansett Laboratory.
;   This software may be used, copied, or redistributed as long as it is not sold and this copyright notice is reproduced on each copy made.
;   This routine is provided AS IS without any express or implied warranties whatsoever.
;
; AUTHOR:
;   This program was written on December 17, 2013 by John E. O'Reilly, Northeast Fisheries Science Center | NOAA Fisheries | U.S. Department of Commerce, 28 Tarzwell Dr, Narragansett, RI 02882
;     Inquires regarding this program should be directed to Kimberly.hyde@noaa.gov
;    
; MODIFICATION HISTORY:
;   DEC 17, 2013 - JEOR: Initial code written
;   JAN 10, 2014 - JEOR: Refined
;   JAN 16, 2014 - JEOR: Fixed scaling but in PRODS_WRITE 
;   APR 10, 2014 - JEOR: Made PROD a keyword
;                        Added function NONE
;   MAY 26, 2014 - JEOR: Added keyword LOG
;   DEC 07, 2014 - JEOR: Now using HAS to check for compound prods
;   DEC 08, 2014 - JEOR: Compound prods may have more than one underscore in the prod name so always extract the range from the last two items in the prod
;                        Added RANGE = FLOAT(GET(T,NUM = 2,/LAST))
;   AUG 25, 2015 - KJWH: In CASE block, changed "DATA" to "_DATA"     
;   NOV 13, 2015 - KJWH: Fixed bug when looking for range values in the prod name: 
;                          IF N_ELEMENTS(T) GE 3 THEN N = TOTAL(NUMBER(T(-2:-1))) 
;                          ELSE N = 0 
;                          IF N EQ 2 THEN BEGIN  
;   DEC 21, 2015 - JEOR: Fixed bug when looking for range values in a compound prod name:
;                          IF N_ELEMENTS(T) GE 3 THEN N = TOTAL(NUMBER(T)) ELSE N = 0
;   MAR 30, 2015 - KJWH: Added special case for depth prod to make any land pixels 0
;                        Updated documentation and formatting
;   SEP 19, 2016 - KJWH: Added SZ = SIZEXYZ(_DATA,PX=PX,PY=PY) AND CHANGED BYTE(_DATA) TO BYTARR(PX,PY) IN ORDER TO AVOID "% PROGRAM CAUSED ARITHMETIC ERROR: FLOATING ILLEGAL OPERAND"
;   NOV 02, 2016 - KJWH: Added T = STRJOIN(T(0:N_ELEMENTS(T)-3),'_') PRIOR TO CALLING PRODS_TICKS TO ISOLATE THE PROD AND REMOVE THE RANGE NUMBERS   
;                        Removed the block with the call to PRODS_TICKS since the correct info can now be derived from PRODS_READ   
;   NOV 13, 2016 - JEOR: Removed keyword RANGE [not used]
;                        Added PY = 1> PY [TO WORK WITH VECTOR DATA]
;                        Added B_VALUES = BYTE(_DATA)),[TO CONSERVE DATA DIMENSIONS TOWORK WITH VECTOR OR IMAGE DATA]
;   NOV 23, 2016 - KJWH: Added SZ = SIZEXYZ(_DATA, PX=PX, PY=PY) to avoid "% Program caused arithmetic error: Floating illegal operand" errors.
;   FEB 16, 2017 - KJWH: There are problems with PRODS_READ getting stuck in an infinite loop if the prod is not valid (e.g. if a PROD-ALG is passed into the program)
;                        Formatting
;   MAR 09, 2017 - KJWH: Added an option to add the land mask to the image.  If a MAPP is provided, then the landmask will be added by default.  All other masking options are 0 by default                     
;   MAR 15, 2017 - KJWH: Added AND IDLTYPE(MASK) EQ 'STRUCT' before trying to add the landmask to the image
;   AUG 18, 2017 - KJWH: Changed default land color to 252
;   MAY 09, 2018 - KJWH: Added the option to return a TRUE_COLOR image array using IMAGE_2TRUE (added keywords and examples)
;                          IF KEY(TRUE_COLOR) THEN B_VALUES = IMAGE_2TRUE(B_VALUES,PAL=PAL)
;                        Updated the keyword documentation
;                        Replaced: SZ = SIZEXYZ(_DATA, PX=PX, PY=PY) & B_VALUES = BYTARR(PX,PY) with B_VALUES = BYTE(_DATA) because not all input arrays are 2D
;   NOV 27, 2019 - KJWH: Changed default pal from PAL_BR to PAL_DEFAULT
;   MAY 18, 2021 - KJWH: Updated documentation and formatting
;                        Added COMPILE_OPT IDL2
;                        Changed subscript () to []
;                            
;-
; ******************************************************************************************************************************************
  ROUTINE_NAME = 'PRODS_2BYTE'
  COMPILE_OPT IDL2

; ===> Defaults 
  IF N_ELEMENTS(CB_RANGE) NE 2 THEN CB_RANGE = [1,250] 
  IF NONE(MAPP) THEN MP = [] ELSE MP = MAPP
  IF MP NE [] THEN MASK = READ_LANDMASK(MP,/STRUCT) ELSE MASK = []
  IF NONE(PAL) THEN PAL = 'PAL_DEFAULT'
  IF NONE(BACKGROUND)        THEN BACKGROUND        = 255
  IF NONE(ADD_LAND)          THEN ADD_LAND          = 1 ; Default is to add land if the MP is present
  IF NONE(LAND_COLOR)        THEN LAND_COLOR        = 252
  IF NONE(COAST_COLOR)       THEN COAST_COLOR       = 0
  IF NONE(COAST_THICK_COLOR) THEN COAST_THICK_COLOR = 0
  IF NONE(LAKE_COLOR)        THEN LAKE_COLOR        = 252
  IF NONE(LAKESIDE_COLOR)    THEN LAKESIDE_COLOR    = 251
  IF NONE(SMALL_LAKE_COLOR)  THEN SMALL_LAKE_COLOR  = 252
  IF NONE(BATHY_COLOR)       THEN BATHY_COLOR       = 0
  IF NONE(BATHY_THICK)       THEN BATHY_THICK       = 2
  IF NONE(ADD_BATHY) AND NONE(DEPTH) THEN ADD_BATHY = 0
  IF KEYWORD_SET(ADD_BATHY)  AND NONE(DEPTH) THEN DEPTH     = -200
  
; ===> Check values & prod
  IF NONE(VALUES) THEN MESSAGE,'ERROR: MUST PROVIDE VALUES'
  IF NONE(PROD) THEN MESSAGE,'ERROR: MUST PROVIDE PROD'
  IF IDLTYPE(VALUES) EQ 'STRING' THEN _DATA = FLOAT(VALUES) ELSE _DATA = VALUES  
    
  S = PRODS_READ(PROD,LOG=LOG)
  
; ===> Set up byte array, [conserving the dimensions of _data]  
  B_VALUES = BYTE(_DATA)
  B_VALUES[*] = BACKGROUND
  
; ===> Scale the values 
  BIN_BOT = FLOAT(CB_RANGE[0])
  BIN_TOP = FLOAT(CB_RANGE[1])
  CASE STRTRIM(STRUPCASE(S.LOG),2) OF
    STRUPCASE('1') : BEGIN  ; Logged data
      OK = WHERE(_DATA GT 0 AND _DATA NE MISSINGS(_DATA), COUNT) ; Find non zero values in the input values values
      IF COUNT GE 1 THEN  B_VALUES[OK] =   BIN_BOT > ((ALOG10(_DATA[OK])-FLOAT(S.INTERCEPT))/FLOAT(S.SLOPE)) < BIN_TOP 
    END ; 'LOG'      

    STRUPCASE('0') : BEGIN
      OK = WHERE(_DATA NE MISSINGS(_DATA), COUNT)
      IF COUNT GE 1 THEN  B_VALUES[OK] =   BIN_BOT > ((_DATA[OK]-FLOAT(S.INTERCEPT))/FLOAT(S.SLOPE)) < BIN_TOP  
    END ; 'LINEAR'
  ENDCASE
  
; ===>  Special cases
  IF PROD EQ 'DEPTH' THEN BEGIN
    OK = WHERE(_DATA LE 0.0 OR _DATA EQ MISSINGS(_DATA), COUNT) ; FIND LAND VALUES (LE 0) AND MAKE THEM ZERO
    IF COUNT GE 1 THEN B_VALUES[OK] = 0
  ENDIF;IF PROD EQ 'DEPTH' THEN BEGIN
    
; ===> Add land mask etc      
  IF MP NE [] AND IDLTYPE(MASK) EQ 'STRUCT' THEN BEGIN
    IF KEYWORD_SET(ADD_LAND)        THEN B_VALUES[MASK.LAND]        = LAND_COLOR
    IF KEYWORD_SET(ADD_COAST)       THEN B_VALUES[MASK.COAST]       = COAST_COLOR
    IF KEYWORD_SET(ADD_THICK_COAST) THEN B_VALUES[MASK.COAST_THICK] = COAST_THICK_COLOR
    IF KEYWORD_SET(ADD_LAKE)        THEN B_VALUES[MASK.LAKE]        = LAKE_COLOR
    IF KEYWORD_SET(ADD_LAKESIDE)    THEN B_VALUES[MASK.LAKESIDE]    = LAKESIDE_COLOR
    IF KEYWORD_SET(ADD_SMALL_LAKE)  THEN B_VALUES[MASK.SMALL_LAKE]  = SMALL_LAKE_COLOR
  ENDIF
  
; ===> Add bathymetry lines
  IF KEYWORD_SET(ADD_BATHY) OR ANY(DEPTH) THEN BEGIN
    IF NONE(MP) THEN MESSAGE, 'ERROR: Must provide input map'
    MS = MAPS_SIZE(MP, PX=WIDTH, PY=HEIGHT)
    TOPO = PLT_TOPO(MP, DEPTH, THICKS=BATHY_THICK, COLORS=BATHY_COLOR)
    TPSZ = SIZEXYZ(TOPO,PX=TPX,PY=TPY)
    IF TPX NE WIDTH OR TPY NE HEIGHT THEN MESSAGE, 'ERROR: TOPO size dimensions do not match with the input image'
    TSUBS = WHERE(TOPO NE 255,COUNT_TOPO)
    IF COUNT_TOPO GT 0 THEN B_VALUES[TSUBS] = TOPO[TSUBS]
  ENDIF
  
  IF KEYWORD_SET(TRUE_COLOR) THEN B_VALUES = IMAGE_2TRUE(B_VALUES, PAL=PAL)
         
  RETURN,B_VALUES
END; #####################  END OF ROUTINE ################################
