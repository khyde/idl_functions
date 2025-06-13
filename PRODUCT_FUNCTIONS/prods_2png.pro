; $ID:	PRODS_2PNG.PRO,	2023-09-21-13,	USER-KJWH	$
;#############################################################################################################
PRO PRODS_2PNG, $
  ;===> INPUT DATA
  FILES, STRUCT=STRUCT, DATA_IMAGE=DATA_IMAGE, BYT_IMAGE=BYT_IMAGE, TAG=TAG, _EXTRA=EXTRA, $

  ;===> INPUT DATA CHARACTERISTICS
  DISCRETE=DISCRETE, MAPP=MAPP,  MASK=MASK, $

  ;===> GRAPHICS PLOTTING KEYWORDS
  WINDOW=WINDOW, EDIT=EDIT, DELAY=DELAY, BUFFER=BUFFER, DEVICE=DEVICE, VERBOSE=VERBOSE, OVERWRITE=OVERWRITE, CURRENT=CURRENT, NO_SAVE=NO_SAVE, $

  ;===> OUTPUT PNG CHARACTERISTICS
  PNGFILE=PNGFILE, OUTFILE=OUTFILE, DIR_OUT=DIR_OUT, RESOLUTION=RESOLUTION, PAL=PAL, RGB_TABLE=RGB_TABLE, BIT_DEPTH=BIT_DEPTH, OBJ=OBJ, THUMBNAIL=THUMBNAIL, CROP=CROP, $

  ;===> PRODUCT CHARACTERISTICS
  PROD=PROD, SPROD=SPROD, LOG=LOG, MISS_COLOR=MISS_COLOR,$

  ;===> IMAGE POSITIONS
  IMG_DIMS=IMG_DIMS, IMG_POS=IMG_POS, IMG_LOCATION=IMG_LOCATION, MARGIN=MARGIN, LAYOUT=LAYOUT, $

  ;===> ADD FILE NAME TO BOTTOM OF IMAGE
  ADD_NAME=ADD_NAME, NAME_POS=NAME_POS, NAME_SIZE=NAME_SIZE, NAME_COLOR=NAME_COLOR,NAME_ALIGN=NAME_ALIGN,$

  ;===> ADD DATE TO BOTTOM OF IMAGE
  ADD_DATE=ADD_DATE, DATE_POS=DATE_POS, DATE_SIZE=DATE_SIZE, DATE_COLOR=DATE_COLOR,DATE_ALIGN=DATE_ALIGN,$

  ;===> ADD COLORBAR
  ADD_CB=ADD_CB, CB_POS=CB_POS, CB_TYPE=CB_TYPE, CB_SIZE=CB_SIZE, CB_STYLE=CB_STYLE, CB_TITLE=CB_TITLE, CB_RELATIVE=CB_RELATIVE, CB_TICKNAMES=CB_TICKNAMES, CB_TICKVALUES=CB_TICKVALUES, COMMA=COMMA, VSTAG=VSTAG,$

  ;===> ADD ADD_LONLAT TO EDGES OF MAP
  ADD_LONLAT=ADD_LONLAT,ADD_LL_LABELS=ADD_LL_LABELS,LL_COLOR=LL_COLOR,LL_THICK=LL_THICK,LL_SIZE=LL_SIZE,LONS=LONS,LATS=LATS,LONNAMES=LONNAMES,LATNAMES=LATNAMES,$

  ; ===> ADD BATHYMETRY LINES
  ADD_BATHY=ADD_BATHY, DEPTH=DEPTH, BATHY_COLOR=BATHY_COLOR, BATHY_THICK=BATHY_THICK,$

  ;===> ADD OUTLINES
  ADD_OUTLINE=ADD_OUTLINE, OUTLINE_IMG=OUTLINE_IMG, OUT_COLOR=OUT_COLOR, OUT_THICK=OUT_THICK, $

  ;===> ADD POINT SYMBOLS
  ADD_POINTS=ADD_POINTS, POINT_LONS=POINT_LONS, POINT_LATS=POINT_LATS, POINT_SYMBOL=POINT_SYMBOL, POINT_SIZE=POINT_SIZE, POINT_FILL_COLOR=POINT_FILL_COLOR, POINT_COLOR=POINT_COLOR, POINT_SYM_FILL=POINT_SYM_FILL, POINT_THICK=POINT_THICK, $
  
  ;===> ADD LANDMASK
  ADD_LAND=ADD_LAND, ADD_COAST=ADD_COAST, LAND_COLOR=LAND_COLOR, COAST_COLOR=COAST_COLOR, $

  ;===> DATE_BAR [USED PRIMARILY IN MOVIES]
  ADD_DB=ADD_DB, DB_POS=DB_POS, DB_SIZE=DB_SIZE, DB_COLOR=DB_COLOR, DB_THICK=DB_THICK, DB_BKG=DB_BKG, NO_YEAR=NO_YEAR ,NO_DAY=NO_DAY, DB_X=DB_X, DB_Y=DB_Y, DB_LONG=DB_LONG, DB_SHORT=DB_SHORT,$

  ;===> ADD CONTOURS
  C_LEVELS=C_LEVELS, C_COLORS=C_COLORS, C_ANNOTATION=C_ANNOTATION, C_CHARSIZE=C_CHARSIZE, C_CHARTHICK=C_CHARTHICK, C_THICK=C_THICK, $

  ;===> ADD TEXT
  ADD_TXT=ADD_TXT, TXT_POS=TXT_POS, TXT_TAGS=TXT_TAGS, TXT_SIZE=TXT_SIZE, TXT_STYLE=TXT_STYLE, TXT_ALIGN=TXT_ALIGN, TXT_COLOR=TXT_COLOR,$

  ;===> AUTHOR
  ADD_AUTH=ADD_AUTH,AUTH_TXT=AUTH_TXT,AUTH_POS=AUTH_POS,AUTH_SIZE=AUTH_SIZE, AUTH_COLOR=AUTH_COLOR,AUTH_ALIGN=AUTH_ALIGN
;+
; NAME:
;   PRODS_2PNG
;
; PURPOSE:
;   Create an image from geophysical data
;
; CATEGORY:
;   Graphics
;
; CALLING SEQUENCE:
;   PRODS_2PNG, FILE
;
; REQUIRED INPUTS (one of the following is required):
;   FILE............ Fullname of file with the name of a prod being part of the name
;   STRUCT.......... Full structure with the desired product to be mapped
;   DATA_IMAGE...... Mapped data image of the desired product
;   BYT_IMAGE....... Mapped image that has already been converted to byte scale
;
; OPTIONAL INPUTS:
;  * INPUT DATA/FILE CHARACTERISTICS
;     MAPP.......... Name of the output map (default is derived from the input file/structure)
;     MASK.......... An array of subscripts to be used as a "mask" to blank out data in the image
;     TAG........... The tag to use in STRUCT_READ to extract the data
; * GRAPHICS PLOTTING KEYWORDS
;     WINDOW........ Window object to insert the image into
;     EDIT.......... Stop the program to allow for mannual editing of the image using the window's annotation graphic features
;     DELAY......... Seconds to delay prior to closing the graphics window
;     BUFFER........ To buffer the graphics window (default = 0)
;     DEVICE........ Set this keyword if values are specified in device coordinates (pixels) for the MARGIN and POSITION keywords
;     VERBOSE....... Execute print commands
;     OVERWRITE..... Overwrite the file if it already exists
;     CURRENT....... Use the current graphics window
; * OUTPUT INFORMATION
;     PNGFILE....... The name of the output pngfile (default is derived from the file name)
;     DIR_OUT....... Output directory
;     PAL........... Palette for displaying the data
;     RGB_TABLE..... A color palette table if not using a defined "PAL"
;     BIT_DEPTH..... See IMAGE/WINDOW save method for details [default = 0, true color]
;     OBJ........... Parameter to hold the output image object
;     THUMBNAIL..... Create a smalelr "thumbnail" image instead of at full resolution
;     CROP.......... Subscripts to crop an image before the IMAGE function
; * PRODUCT CHARACTERISTICS
;     PROD.......... Standard product name (default is derived from the file name
;     SPROD......... Product name to use for scaling if different from PROD
;     LOG........... For the data to be log-transformed for display
;     MISS_COLOR.... Color for the missing data
; * IMAGE POSITIONS
;     IMG_DIMS...... Dimensions for the image
;     IMG_POS....... Position of the image in the graphics window
;     IMG_LOCATION.. Two-element vector to specify the location of the lower-left pixel in data units (passed to IMAGE)
;     MARGIN........ Set to establish a margin around the image (passed to IMAGE)
;     LAYOUT........ Set to arrange the graphics in a grid on the graphics window (passed to IMAGE)
; * ADD FILE
;     ADD_NAME..... Add the file name to the image
;     NAME_POS..... Postion of the name text
;     NAME_SIZE.... Size of the name text
;     NAME_COLOR... Color of the name text
;     NAME_ALIGN... Alignment of the name text
; * ADD DATE
;     ADD_DATE...... Keyword to add the date to the image
;     DATE_POS...... Position for the date text
;     DATE_SIZE..... Font size for the date text
;     DATE_COLOR.... Color for the date text
;     DATE_ALIGN.... Alignment for the date text
; * ADD COLORBAR
;     ADD_CB........ Add the product specific colorbar
;     CB_POS........ Normal-coordinate position [x,y,x2,y2] for the colorbar
;     CB_TYPE....... Code for the style of colorbar [1-7]
;     CB_SIZE....... Font size for the colorbar
;     CB_STYLE...... Font style for the colorbar
;     CB_TITLE...... Title for the colorbar
;     CB_RELATIVE... Set this keyword to indicate that the input arguments are specified in normalized [0,1] coordinates, relative to the axis range of the TARGET's dataspace [default=1]
;     CB_TICKNAMES.. Names for the colorbar ticks
;     CB_TICKVALUES. Values for the colorbar ticks
;     COMMA......... Passed to cbar to add a comma to numbers >= 1000
;     VSTAG......... Vertically stagger the colorbar ticknames for greater legibility
; * ADD ADD_LONLAT
;     ADD_LONLAT.... Will add latitude and longitude lines and labels and ticks to the edges of the image
;     ADD_LL_LABELS. Add the lon/lat labels
;     LL_COLOR...... The color of the lon/lat text
;     LL_THICK...... The thickness of the lon/lat lines
;     LL_SIZE....... The size of the lon/lat text
;     LONS.......... The lonitude values to add to the image
;     LATS.......... The latitude values to add to the image
;     LONNAMES...... The names for the longitude labels
;     LATNAMES...... The names for the latitude labels
; * ADD BATHYMETRY LINES
;     ADD_BATHY..... Keyword to add bathymetry lines to the image
;     DEPTH......... Depth for the contour lines
;     BATHY_COLOR... Color of the bahymetry lines
;     BATHY_THICK... Thickness of the bathymetry lines
; * ADD OUTLINES
;     ADD_OUTLINE... Keyword to add outlines to the mapped image (e.g. subarea outlines)
;     OUTLINE_IMG... The image containing the outlines
;     OUT_COLOR..... Color for the outlines
;     OUT_THICK..... Thickness of the outlines
; * ADD LANDMASK
;     ADD_LAND...... Add the land from the landmask file
;     ADD_COAST..... Add the coastline from the landmask file
;     LAND_COLOR.... The color for the land mask
;     COAST_COLOR... The color for the coastline mask
; * ADD DATE_BAR [USED PRIMARILY IN MOVIES]
;     ADD_DB........ Add the datebar to the image
;     DB_POS........ Datebar position
;     DB_SIZE....... Font size of the datebar text
;     DB_COLOR...... Color of the datebar text
;     DB_THICK...... Thickness of the datebar
;     DB_BKG........ Background color of the datebar
;     NO_YEAR....... Exclude the year from the datebar
;     NO_DAY........ Exclude the day from the datebar
;     DB_X.......... X normal-coordinate for the central datebar db_pos [easier to estimate than db_pos]
;     DB_Y.......... Y normal-coordinate for the central datebar db_pos [easier to estimate than db_pos]
;     DB_LONG....... Long dimension [normal coords] for the datebar [use with db_x,db_y]
;     DB_SHORT...... Short dimension [normal coords] for the datebar [use with db_x,db_y]
; * ADD CONTOURS
;    C_LEVELS....... The values of the contour lines
;    C_COLORS....... The color of the contour lines
;    C_ANNOTATION... The labels for the contour lines
;    C_CHARSIZE..... The fontsize of the contour labels
;    C_CHARTHICK.... The thickness of the contour label text
;    C_THICK........ The thickness of the contour lines
; * TEXT ANNOTATION
;     ADD_TXT....... Add text to the image - if text is provided, then that text will be added, otherwise, the information from TXT_TAGS will be added
;     TXT_POS....... Position of the text
;     TXT_TAGS...... Tags derived from the input file name or structure [default=['sensor','method','map','prod','alg']]
;     TXT_SIZE...... Font size of the text
;     TXT_STYLE..... Font style of the text
;     TXT_ALIGN..... Text alignment
;     TXT_COLOR..... Font color of the text
; * AUTHOR
;     ADD_AUTH...... Add author information
;     AUTH_TXT...... Author text
;     AUTH_POS...... Author text position
;     AUTH_SIZE..... Author text size
;     AUTH_COLOR.... Author text color
;     AUTH_ALIGN.... Author text alignment
;
; OUTPUTS:
;   AN IMAGE OF THE DATA IN THE FILE EITHER SAVED AS A PNG OR PLACED IN A DISPLAY WINDOW
;
; OPTIONAL OUTPUTS:
;   OUTFILE..... Name of the output pngfile
;
; EXAMPLES:
;       PRODS_2PNG,!S.OC + 'OCCCI/L3B4/STATS/CHLOR_A-CCI/M_199810-SA-R2015-L3B2-CHLOR_A-PAN-STATS.SAV",DIR_OUT = !S.IDL_TEMP,/OVERWRITE

; MODIFICATION HISTORY:
;			JAN 16, 2014 - JEOR: Initial code written
;			JAN 17, 2014 - JEOR: Added keywords
;			                     Added TARGET:  CBAR,PROD,TARGET=IM
;			JAN 29, 2014 - JEOR: Added KEYWORD NO_CB [FOR POSTERS]
;			                     NOW USING POSITIONS FUNCTION
;			FEB 09, 2014 - JEOR: Added keyword BUFFER [passed to WINDOW to create the image window in buffer background]                 ;
;     FEB 02, 2014 - JEOR: Now using RGBS.PRO to get the color table
;     FEB 15, 2014 - JEOR: IF N_ELEMENTS(DIR_OUT) EQ 1 THEN _DIR_OUT = DIR_OUT ELSE _DIR_OUT = FN.DIR
;     MAR 05, 2014 - JEOR: Now using FILE_ALL
;     MAR 07, 2014 - JEOR: Added keywords MAP_OUT and ADD_NAME
;     APR 10, 2014 - JEOR: Added keyword BIT_DEPTH
;     APR 13, 2014 - JEOR: Add BYT = PRODS_2BYTE(D,PROD=PROD)
;                          Simplified by using the new NONE & ANY functions
;                          Added & TESTED MAKE FUNCTION
;                          Added CB_POSITION variable [to conserve CB_POS for TEXT function]
;     APR 23, 2014 - JEOR: Now using PLT_WRITE
;     MAY 01, 2014 - JEOR: Now using OWIN
;     MAY 06, 2014 - JEOR: Added keyword PROD [in case prod is not in the file name]
;                          POS =POSITIONS(CB_POS,OBJ=BYT,ASPECT=ASPECT,_EXTRA=_EXTRA)
;     MAY 07, 2014 - JEOR: Added STAT tp pngfile only if not already in the name of the input savefile
;                          [SINCE INPUT SAVEFILE FROM STATS_ARRAYS MAY HAVE NUM,MEAN,SUM,ETC.]
;                          IF NONE(STAT) THEN STAT = 'MEAN'
;     AUG 21, 2014 - JEOR: Fixed 2 problems:
;                          1)Discovered RGB values in output pngfile are different than those in PAL_SW3 [DEFAULT PAL]
;                          2)Output pngs are now the correct size for the map
;     AUG 29, 2014 - JEOR: Added IF KEY(ADD_LONLAT) THEN BYT = MAPS_ADD_ADD_LONLAT(BYT,MAPP=MAP_OUT,LON_COLOR=0)
;                          Added IF KEY(ADD_LMES) THEN BYT =MAPS_ADD_LMES(BYT,MAPP=MAP_OUT,COLOR=0)
;                          Added keyword CB_FONT_SIZE
;     SEP 06, 2014 - JEOR: Added IF NONE(PROD) THEN PRODUCT = VALIDS('PRODS',FA.NAME) ELSE PRODUCT = PROD
;     SEP 13, 2014 - JEOR: Added keyword NO_LAND
;                          Added STAT to COLORBAR
;     DEC 29, 2014 - JEOR: Now using FILE_MAKE
;     FEB 25, 2015 - JEOR: Added IF NONE(DB_SIZE) THEN DB_SIZE = 16
;     MAR 06, 2015 - KJWH: Added TAG, PAL and PNGFILE keywords
;     MAR 06, 2015 - JEOR: Changed keyword STAT to TAG
;     MAR 08, 2015 - JEOR: Rearranged steps in correct order [REAMAP,ADD_LAND,ADD_LONLAT,ADD_LMES,DATE_BAR.]
;     MAR 13, 2015 - JEOR: Fixed bug when MAP_OUT not provided MAP_OUT = []
;                          Replaced keyword NOSTAG with VSTAG
;     SEP 04, 2015 - JEOR: MAPS_ADD_LONLAT CHANGED TO MAPS_ADD_ADD_LONLAT
;     OCT 30, 2015 - JEOR: CHANGED PRODUCT TO PROD,NOW USING VALIDS
;     JAN 27, 2016 - JEOR: IF KEY(ADD_NAME) AND KEY(NO_CB) THEN ADD_NAME = 0
;     JAN 31, 2017 - KJWH: Added MAPP keyword so that you can remap L3Bx files
;                          Fixed READ_LANDMASK error
;                          Added error message if MAP_OUT has 'L3B'
;     FEB 02, 2017 - KJWH: Changed the default IF NONE(TAG) THEN TAG = 'MEAN' to TAG='' because it assumed the file was a stat file if tag was not provided and returned blank images
;                          Commented out the ADD_LONLAT block because it was causing compilation errors (I'm missing MAPS_ADD_ADD_LONLAT)
;                          Changed MAP_REMAP to MAPS_REMAP
;     AUG 17, 2017 - JEOR: Added keyword OBJ [OUTPUT]
;     AUG 18, 2017 - JEOR: Added keywords:IMG_POS,CB_POS,DB_POS,TXT_POS
;     AUG 20, 2017 - JEOR: Added keyword TXT_TAGS & IF NONE(TXT_TAGS) THEN TXT_TAGS=['SENSOR','METHOD','MAP','PROD','ALG']
;                          No longer using POSITIONS for IMAGE, COLOR BAR BECAUSE POSITIONS ARE NOW IN MAP_MASTER
;     AUG 21, 2017 - JEOR: Added IF NONE(VALS) THEN VALS = TAG+ ': ' + VAL ELSE VALS = [VALS,TAG+ ': ' + VAL]
;     AUG 22, 2017 - JEOR: Added OBJECT GRAPHICS DATE_BAR
;     AUG 23, 2017 - JEOR: Rearranged keywords by group for clarity
;                          IF M.LONMAX EQ '180' THEN SPACES = 0 ELSE SPACES = 1
;                          IF N_ELEMENTS(MAP_OUT) EQ 1 AND MAP_OUT NE AMAP THEN BEGIN
;     AUG 25, 2017 - JEOR: Now using new CBAR instead of PRODS_COLORBAR
;                          Added keywords AUTH, AUTH_POS
;     AUG 27, 2017 - JEOR: Added CB_TYPE TO CALL TO  CBAR
;     AUG 28, 2017 - JEOR: Added keywords CB_X,CB_Y,CB_LONG,CB_SHORT,DB_X,DB_Y,DB_LONG,DB_SHORT
;     SEP 01, 2017 - JEOR: Rearranged keywords for clarity
;                          Set defaults for ADD_CB,ADD_DB,ADD_TXT,ADD_NAME
;                          Removed keyword aspect [COLORBAR ASPECT IS NOW CONTROLLED BY CB_POS]
;                          Added keyword TXT_SPACES, SET DEFAULT TXT_SPACES = 0 ,CHANGED NO_LAND TO ADD_LAND
;                          Changed TAG to DATA_TAG [MORE MEANINGFUL]
;     SEP 16, 2017 - KJWH: Removed MAP_OUT keyword (redundant with MAPP)
;                          Added ADD_COAST keyword - by default it will add the coast, but if ADD_COAST=0, no coastline will be drawn
;                          Added ADD_OUTLINE keyword and OUTLINE_COLOR - ADD_OUTLINE should contain the oultine subscripts
;                          Updated formatting
;                          Made default ADD_CB = 0
;                          Removed MAP_4LANDMASK, just need to use AMAP
;                          Removed the REMAPPING step and instead added MAP_OUT=AMAP to the STRUCT_READ step
;                          Added IMG_DIMS keyword to set the IMAGE_DIMENSIONS called in WINDOW
;     NOV 22, 2017 - KJWH: Added STOP in the ADD_LMES block because MAPS_LMES is out of date
;     DEC 07, 2017 - KJWH: Added keyword CB_TITLE and included CB_TITLE in the call to CBAR
;                          Added DIR_TEST, _DIR_OUT to make sure the output directory exists
;                          Added TXT_TAGS as a keyword
;                          Updated the IF statement and defaults for ADD_TXT - Now if just 'TXT_TAGS' is in the call to PRODS_2PNGS (and ADD_TXT is omitted) it will still add the txt string
;                          Added NAME_SIZE keyword
;                          Changed ADD_COAT to ADD_COAST
;                          Reorganized keywords
;                          Removed TEST, TXT_SPACES, CB_X, CB_Y, CB_LONG, and CB_SHORT keywords because they are not used in the program
;                          Changed CB_FONT_SIZE to CB_SIZE to be consisted with the DB keywords
;                          Added check to make sure the value returned by STRUCT_GET is valid before adding it to the TXT_ADD text string - IF VAL NE [] THEN VALS = [VALS, TAG + ': ' + VAL]
;                          Removed redundant ADD_AUTHOR line of code
;                          Updated formatting and in code documentation
;                          Added SKIP_SAVE keyword to skip saving the PNG file
;                          Added WINDOW keyword to input a WINDOW object to insert the image into
;     DEC 14, 2017 - KJWH: Added ability to read NC files - NOTE: May need some updates to account for the NC_PRODUCTS
;                          IF STRUPCASE(FA.EXT) EQ 'SAV' THEN D = STRUCT_READ(FILE,TAG=DATA_TAG,BINS=BINS,MAP_OUT=AMAP) $
;                                                         ELSE D = READ_NC(FILE,PROD=PROD,BINS=BINS,/DATA))
;                          Added CB_TYPE default
;                             IF NONE(CB_TYPE) THEN CB_TYPE   = 2
;     DEC 15, 2017 - KWJH: Added 'DATE_CREATED': VAL = DATE_FORMAT(GET_MTIME(FILE,/DATE),/DAY) as an optional TXT_TAG
;                          Added PAL=PAL to CBAR call
;     DEC 18, 2017 - KJWH: Removed ADD_LMES keyword and block of code.  LME outlines can be done using the ADD_OUTLINE option
;     DEC 19, 2017 - KJWH: Added steps to plot a user provided OUTLINE to the BYT image prior to the call to IMAGE.  Since the outline is map specific, I am not sure it can be added once the graphics image has been created
;     MAR 21, 2018 - KJHW: Changed DATA_TAG keyword to TAG to be consistent with other programs (JEOR)
;                          In the ADD_TXT block, changed the parameter name TAG to TT to avoid conflicts with TAG keyword
;     MAY 14, 2018 - KJWH: Changed DIMENIONS=DIMS to IMAGE_DIMENSIONS=IMG_DIMS in the IMAGE call
;                          Added THUMBNAIL keyword to create a small image (< 300 maximum dimension)
;                            If set, then change the HEIGHT and WIDTH to a scaled down version (the max dimension would be between 200 and 300 pixels)
;     JUL 03, 2018 - KJWH: Added CB_TICKNAMES keyword to add specific TICKNAMES to the colorbar
;     AUG 07, 2018 - KJWH: Changed IF NONE(SPROD) THEN SPROD = PR.IN_PROD to IF NONE(SPROD) THEN SPROD = (PRODS_READ(PROD)).IN_PROD
;     OCT 19, 2018 - KJWH: Changed it so that if the PNGFILE name is provided, that it will not be changed
;     NOV 08, 2018 - KJWH: Added MASK keyword and options to use a data mask in STRUCT_READ and READ_NC steps
;                          Added MISS_COLOR keyword
;     FEB 19, 2019 - KJWH: Added ADD_BATHY keywords and steps to add bathymetry lines using PLT_TOPO
;     FEB 20, 2019 - KJWH: Updated the default DIR_OUT location & added a specific location for THUMBNAILS
;     FEB 21, 2019 - KJWH: Changed FILE to FILES and added FOR NTH=0, N_ELEMENTS(FILES)-1 DO BEGIN loop
;     MAR 06, 2019 - KJWH: Added READ_BATHY(AMAP) if the PROD contains "BATHY"
;     MAR 13, 2019 - KJWH: Added CB_STYLE keyword and FONT_STYLE=CB_STYLE
;     APR 01, 2019 - KJWH: Now looking for values LE 0 (instead of EQ 0) for default font and thickness sizes (e.g. IF NONE(CB_SIZE)   OR CB_SIZE   LE 0 THEN CB_SIZE   = 12)
;     APR 03, 2019 - KJWH: Added DELAY kewyord to show the image for a short duration and then close without saving
;     SEP 23, 2019 - KJWH: Changed the default color palette from PAL_BR to PAL_DEFAULT (a rainbow palette with no green)
;     FEB 11, 2020 - KJWH: Added the ability to create images from structures and not just files
;                          Added CB_TICKVALUES
;     JUN 10, 2020 - KJWH: Changed ADD_OUTLINES keyword to ADD_OUTLINE (bug fix)
;     SEP 08, 2020 - KJWH: Updated documentation
;                          Added COMPILE_OPT IDL2
;                          Changed subscript () to []
;     JUL 19, 2021 - KJWH: Added BYT_IMAGE as an optional input.  When the byte scaled image is input, it skips the PRODS_2BYTE step               
;     DEC 03, 2021 - KJWH: Added IF KEYWORD_SET(ADD_DB) AND CB_TYPE EQ 2 THEN CB_TYPE = 3 to change the default CB_TYPE if a DATEBAR is included
;     MAR 07, 2022 - KJWH: Added the optional parameter CROP - Subscripts to crop an image before the IMAGE function
;                          Added the optional parameter RGB_TABLE - A user supplied color palette to be used instead of the PAL 
;                            NOTE - If adding the colorbar, will still need to supply the PAL (assumes the changes were to colors 0 and 251-255)
;                            TODO - Update the colorbar code to work with the RGB_TABLE instead of the PAL
;                          Updated the default PNGFILE to include the TAG name if provided (e.g. STD for a stats image)  
;     AUG 31, 2022 - KJWH: Added LAND_COLOR and COAST_COLOR keywords                     
;###################################################################################################################
;-
  ROUTINE_NAME  = 'PRODS_2PNG'
  COMPILE_OPT IDL2

  ; ####### FILE INFORMATION #######
  IF NONE(FILES) THEN BEGIN
    IF NONE(STRUCT) THEN BEGIN
      IF NONE(DATA_IMAGE) THEN BEGIN
        IF NONE(BYT_IMAGE) THEN MESSAGE,'ERROR: File, data image, byte image, or structure is required'
          SZ = SIZEXYZ(BYT_IMAGE)
        ENDIF ELSE SZ = SIZEXYZ(DATA_IMAGE)
      IF SZ.N_DIMENSIONS NE 2 THEN MESSAGE, 'ERROR: Input data image must be a 2D array'
      IF NONE(MAPP) OR NONE(PROD) THEN MESSAGE, 'ERROR: Must provide MAP and PROD when using the DATA_IMAGE option.'
      IF NONE(PNGFILE) AND ~KEY(CURRENT) THEN IF ~KEY(NO_SAVE) THEN MESSAGE, 'ERROR: Must provide the output file name when using the DATA_IMAGE option.' 
      FILES = ''
    ENDIF ELSE BEGIN
      IF IDLTYPE(STRUCT) NE 'STRUCT' THEN MESSAGE, 'ERROR: Input STRUCT not a structure'
      IF HAS(STRUCT,'FILE') THEN FILES = STRUCT.FILE ELSE MESSAGE, 'ERROR: Structure must have a file name'
    ENDELSE
  ENDIF ELSE BEGIN
    STRUCT = []
    DATA_IMAGE = []
    BYT_IMAGE = []
  ENDELSE


  FOR NTH=0, N_ELEMENTS(FILES)-1 DO BEGIN
    FILE = FILES[NTH]
    IF FILE NE '' THEN BEGIN
      FA = PARSE_IT(FILE,/ALL)
      IF NONE(DATE)       THEN _DATE  = FA.DATE_START ELSE _DATE  = DATE
      IF NONE(TAG)        THEN ATAG  = '' ELSE ATAG = TAG ; [FOR STRUCT_READ]
      IF NONE(MAPP)       THEN AMAP = VALIDS('MAPS',FA.NAME) ELSE AMAP = STRUPCASE(MAPP)
      IF WHERE_MATCH(WORDS(FA.NAME),ATAG) EQ !NULL THEN _TAG = '' ELSE _TAG=ATAG
      _PNGFILE = REPLACE(FA.NAME +'-'+ _TAG +'.PNG','-.','.')
      _PNGFILE = REPLACE(_PNGFILE,FA.MAP,AMAP)
      IF NONE(DIR_OUT) AND KEY(THUMBNAIL) THEN DIR_OUT = REPLACE(FA.DIR,[FA.MAP,'SAVE','NC'],[AMAP,'THUMBNAILS','THUMBNAILS'])
      IF NONE(DIR_OUT) THEN DIR_OUT = REPLACE(FA.DIR,[FA.MAP,'SAVE','NC'],[AMAP,'PNGS','PNGS'])
      IF ~KEY(CURRENT) THEN DIR_TEST, DIR_OUT
      _PNGFILE = DIR_OUT + _PNGFILE
    ENDIF

    IF ANY(PNGFILE) THEN _PNGFILE = PNGFILE
    IF (FILE_PARSE(_PNGFILE)).EXT EQ '' THEN _PNGFILE = _PNGFILE + '.PNG' ;===> MAKE SURE FILE HAS AN EXTENSION, IF NOT THEN MAKE IT PNG
    IF ANY(ATAG) AND NONE(PNGFILE) THEN _PNGFILE = REPLACE(_PNGFILE,'.PNG','-'+ATAG+'.PNG')
    _PNGFILE = REPLACE(_PNGFILE,'.-','.')
    OUTFILE = _PNGFILE ; OPTIONAL OUTPUT
    IF FILE_MAKE(FILE,_PNGFILE,OVERWRITE=OVERWRITE,VERBOSE=VERBOSE) EQ 0 AND ~KEY(CURRENT) THEN GOTO, DONE ; >>>>>>>>>>>>>>
    IF FILE_MAKE(FILE,_PNGFILE,OVERWRITE=OVERWRITE,VERBOSE=VERBOSE) EQ 0 AND ~KEY(NO_SAVE) THEN GOTO, DONE ; >>>>>>>>>>>>>>


    IF NONE(MAPP)       THEN AMAP = VALIDS('MAPS',FA.NAME) ELSE AMAP = STRUPCASE(MAPP)
    IF NONE(AMAP) OR AMAP EQ '' THEN MESSAGE,'ERROR: MAP CAN NOT BE FOUND IN THE FILENAME'
    IF IS_L3B(AMAP)             THEN MESSAGE,'ERROR: NEED TO REMAP L3B FILES'

    IF NONE(PROD)       THEN PROD = VALIDS('PRODS',FA.NAME)
    IF NONE(PROD) OR PROD EQ '' THEN MESSAGE,'ERROR: PROD CAN NOT BE FOUND IN THE FILENAME'

    IF NONE(SPROD) THEN SPROD = (PRODS_READ(PROD)).IN_PROD ; PRODUCT NAME TO USE FOR SCALING


    ; ####### CONSTANTS AND DEFAULTS #######
    ; IMAGE OUTPUTS
    IF NONE(BIT_DEPTH)  THEN BIT_DEPTH = 0 ; [24-BIT TRUE-COLOR IMAGE ARRAY]
    IF NONE(RESOLUTION) THEN RESOLUTION = 600 ; [FOR SAVING THE .PNG FILE]

    ; ===> IMAGE ADD ONS
    IF NONE(ADD_LAND)  THEN ADD_LAND  = 1
    IF NONE(ADD_COAST) THEN ADD_COAST = 1
    IF NONE(ADD_CB)    THEN ADD_CB    = 0
    IF NONE(ADD_NAME)  THEN ADD_NAME  = 0
    IF NONE(ADD_DATE)  THEN ADD_DATE  = 0 
    IF NONE(ADD_DB)    THEN ADD_DB    = 0
    IF NONE(ADD_AUTH)  THEN ADD_AUTH  = 0
    IF NONE(ADD_TXT)   THEN ADD_TXT   = 0
    IF NONE(ADD_BATHY) AND NONE(DEPTH) THEN ADD_BATHY = 0
    
    IF KEYWORD_SET(ADD_DATE) THEN BEGIN
      IF N_ELEMENTS(FA) EQ 0 THEN IF STRLEN(ADD_DATE) EQ 1 THEN MESSAGE, 'ERROR: Must either provide the input date or use a file for the input data'
      IF STRLEN(ADD_DATE) GT 1 THEN BEGIN
        IF IS_DATE(ADD_DATE) THEN ADDDATE = DATE_FORMAT(ADD_DATE,/DAY) ELSE ADDDATE = ADD_DATE 
      ENDIF ELSE BEGIN
        IF FA.PERIOD_CODE EQ 'D' OR FA.PERIOD_CODE EQ 'S' THEN ADDDATE = DATE_FORMAT(FA.DATE_START,/DAY) ELSE $
        ADDDATE = DATE_FORMAT(FA.DATE_START,/DAY) + ' - ' + DATE_FORMAT(FA.DATE_END,/DAY)
      ENDELSE
    ENDIF

    ; ===> IMAGE COLORS
    IF NONE(BORDER)           THEN BORDER = 0 ; [AROUND IMAGE]
    IF NONE(BACKGROUND_COLOR) THEN BACKGROUND_COLOR = 254
    IF NONE(LAND_COLOR)       THEN LAND_COLOR  = 253
    IF NONE(COAST_COLOR)      THEN COAST_COLOR = 0
    IF NONE(MISS_COLOR)       THEN MISS_COLOR  = 254
    IF NONE(DB_COLOR)         THEN DB_COLOR = 200
    IF NONE(OUT_COLOR)        THEN OUT_COLOR = 255
    IF NONE(OUT_THICK)        THEN OUT_THICK = 2
    IF NONE(LL_COLOR)         THEN LL_COLOR = 0
    IF NONE(LL_THICK)         THEN LL_THICK = 2
    IF NONE(LL_SIZE)          THEN LL_SIZE = 2
    IF NONE(BATHY_COLOR)      THEN BATHY_COLOR = 0
    IF NONE(BATHY_THICK)      THEN BATHY_THICK = 2
    IF NONE(C_COLORS)         THEN C_COLORS = 0
    IF NONE(C_THICK)          THEN C_THICK = 3
    IF NONE(DATE_COLOR)       THEN DATE_COLOR = 'BLACK'
    IF NONE(NAME_COLOR)       THEN NAME_COLOR = 'BLACK'
    IF NONE(AUTH_COLOR)       THEN AUTH_COLOR = 'BLACK'
    IF NONE(DB_BKG)           THEN DB_BKG = BACKGROUND_COLOR
    IF NONE(TXT_COLOR)        THEN TXT_COLOR = 'BLACK'
    IF N_ELEMENTS(RBG_TABLE) GT 1 AND ~N_ELEMENTS(PAL) AND KEYWORD_SET(ADD_CB) THEN MESSAGE, 'ERROR: Must also provide a color palette for the colorbar when providing the RGB table.'
    IF ~N_ELEMENTS(PAL)       THEN PAL='PAL_DEFAULT'
    IF ~N_ELEMENTS(RGB_TABLE) THEN RGB_TABLE = RGBS([0,255],PAL=PAL)    ;COLOR PALETTE
    
    IF BYT_IMAGE NE [] AND KEYWORD_SET(DISCRETE) THEN BEGIN
      IF MAX(BYT_IMAGE[WHERE(BYT_IMAGE NE MISSINGS(BYT_IMAGE))]) GT 255 THEN MESSAGE, 'ERROR: The data value range exceeds the 250 color limit'
      WIDTH = ROUND(250/FLOAT(DISCRETE))
      RGB = RGB_TABLE[*,WIDTH + WIDTH*INDGEN(DISCRETE)]
      RGB_TABLE[*,1:DISCRETE] = RGB
      TICKVALUES = [] ; Remove the value to make a discrete colorbar
    ENDIF
    

    ; ===> OTHER DEFAULTS
    IF NONE(TXT_TAGS) AND KEY(ADD_TXT) THEN TXT_TAGS=['SENSOR', 'METHOD','MAP','PROD','ALG'] ; CREATE NULL TXT_TAGS IF NONE ARE PROVIDED AND KEY(ADD_TXT) IS 0
    IF NONE(VSTAG)      THEN VSTAG    = 0            ; [DO NOT STAGGER THE COLORBAR TICKNAMES]
    IF NONE(AUTH_TXT)   THEN AUTH_TXT = !S.USER      ; [AUTHOR NAME]
    IF KEY(ADD_BATHY) AND NONE(DEPTH) THEN DEPTH = -200

    ; ######### MAP SPECIFIC INFORMATION #########
    ; ===> GET LANDMASK
    LD = READ_LANDMASK(AMAP,/STRUCT) & LAND = LD.LAND & OCEAN = LD.OCEAN & COAST = LD.COAST

    ; ===> LOOK FOR POSITION AND TEXT SIZE DEFAULTS IN MAPS_MASTER
    M = MAPS_READ(AMAP)
    IF NONE(IMG_DIMS)  THEN IMG_DIMS  = FLOAT(STRSPLIT(M.IMG_DIMS,';',/EXTRACT))
    IF NONE(IMG_POS)   THEN IMG_POS   = FLOAT(STRSPLIT(M.IMG_POS, ';',/EXTRACT))
    IF NONE(CB_POS)    THEN CB_POS    = FLOAT(STRSPLIT(M.CB_POS,  ';',/EXTRACT))
    IF NONE(DB_POS)    THEN DB_POS    = FLOAT(STRSPLIT(M.DB_POS,  ';',/EXTRACT))
    IF NONE(TXT_POS)   THEN TXT_POS   = FLOAT(STRSPLIT(M.TXT_POS, ';',/EXTRACT))
    IF NONE(AUTH_POS)  THEN AUTH_POS  = FLOAT(STRSPLIT(M.AUTH_POS,';',/EXTRACT))
    IF NONE(NAME_POS)  THEN NAME_POS  = FLOAT(STRSPLIT(M.NAME_POS,';',/EXTRACT))
    IF NONE(DATE_POS)  THEN DATE_POS  = FLOAT(STRSPLIT(M.DATE_POS,';',/EXTRACT))
    IF NONE(MARGIN)    THEN MARGIN    = FIX(M.MARGIN)
    IF NONE(CB_TYPE)   THEN CB_TYPE   = FIX(M.CB_TYPE)
    IF NONE(CB_SIZE)   THEN CB_SIZE   = FIX(M.CB_SIZE)
    IF NONE(DB_SIZE)   THEN DB_SIZE   = FIX(M.DB_SIZE)
    IF NONE(DB_THICK)  THEN DB_THICK  = FIX(M.DB_THICK)
    IF NONE(TXT_STYLE) THEN TXT_STYLE = 'BOLD'
    IF NONE(TXT_SIZE)  THEN TXT_SIZE  = FIX(M.TXT_SIZE)
    IF NONE(AUTH_SIZE) THEN AUTH_SIZE = FIX(M.AUTH_SIZE)
    IF NONE(NAME_SIZE) THEN NAME_SIZE = FIX(M.NAME_SIZE)
    IF NONE(DATE_SIZE) THEN DATE_SIZE = FIX(M.DATE_SIZE)

    ; ===> IF NO DEFAULTS IN MAPS_MASTER THEN DEFAULT TO THE FOLLOWING POSITIONS AND SIZES
    IF MARGIN EQ ''              THEN MARGIN    = 0
    IF N_ELEMENTS(IMG_DIMS) NE 2 THEN IMG_DIMS  = FIX([M.PX,M.PY])
    IF N_ELEMENTS(IMG_POS)  NE 4 THEN IMG_POS   = [0,0,1.0,1.0]
    IF N_ELEMENTS(CB_POS)   NE 4 THEN CB_POS    = [0.05,0.84,0.44,0.855]
    IF N_ELEMENTS(DB_POS)   NE 4 THEN DB_POS    = [0.10,0.95, 0.55,0.99]
    IF N_ELEMENTS(TXT_POS)  NE 2 THEN BEGIN & TXT_POS   = [0.10,0.55] & TXT_ALIGN=0.0 & ENDIF ELSE IF N_ELEMENTS(TXT_ALIGN)  EQ 0 THEN TXT_ALIGN  = 0
    IF N_ELEMENTS(NAME_POS) NE 2 THEN BEGIN & NAME_POS = [0.5,0.01]  & NAME_ALIGN=0.5 & ENDIF ELSE IF N_ELEMENTS(NAME_ALIGN) EQ 0 THEN NAME_ALIGN = 0
    IF N_ELEMENTS(DATE_POS) NE 2 THEN BEGIN & DATE_POS = [0.5,0.03]  & DATE_ALIGN=0.5 & ENDIF ELSE IF N_ELEMENTS(DATE_ALIGN) EQ 0 THEN DATE_ALIGN = 0
    IF N_ELEMENTS(AUTH_POS) NE 2 THEN BEGIN & AUTH_POS = [0.98,0.01] & AUTH_ALIGN=1.0 & ENDIF ELSE IF N_ELEMENTS(AUTH_ALIGN) EQ 0 THEN AUTH_ALIGN = 0

    IF NONE(CB_RELATIVE)                 THEN CB_RELATIVE = 1
    IF NONE(CB_TYPE)   OR CB_TYPE   LE 0 THEN CB_TYPE   = 2 & IF KEYWORD_SET(ADD_DB) AND CB_TYPE EQ 2 THEN CB_TYPE = 3
    IF NONE(CB_SIZE)   OR CB_SIZE   LE 0 THEN CB_SIZE   = 12
    IF NONE(DB_SIZE)   OR DB_SIZE   LE 0 THEN DB_SIZE   = 12
    IF NONE(DB_THICK)  OR DB_THICK  LE 0 THEN DB_THICK  = 4
    IF NONE(AUTH_SIZE) OR AUTH_SIZE LE 0 THEN AUTH_SIZE = 8
    IF NONE(NAME_SIZE) OR NAME_SIZE LE 0 THEN NAME_SIZE = 8
    IF NONE(DATE_SIZE) OR DATE_SIZE LE 0 THEN DATE_SIZE = 10
    IF NONE(TXT_SIZE)  OR TXT_SIZE  LE 0 THEN TXT_SIZE  = 12


    ;|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||

    ; ########### CREATE THE BYTE ARRAY ###############
    ; ===> READ THE FILE
    IF STRUCT EQ [] AND DATA_IMAGE EQ [] AND BYT_IMAGE EQ [] THEN BEGIN
      IF STRUPCASE(FA.EXT) EQ 'SAV' THEN BEGIN
        IF HAS(PROD,'BATHY') THEN D = READ_BATHY(AMAP) ELSE D = STRUCT_READ(FILE,TAG=ATAG,MAP_OUT=AMAP,MASK=MASK)
      ENDIF ELSE BEGIN
        SI = SENSOR_INFO(FILE)
        PR = PRODS_READ(PROD)
        NPROD = PR.PROD                         ; PRODUCT NAME TO USE FOR READING THE FILE
        DD = READ_NC(FILE,/NAMES)
        OK = WHERE_MATCH(STRUPCASE(DD),STRUPCASE(NPROD),COUNT)
        IF COUNT EQ 0 THEN BEGIN
          OK = WHERE_MATCH(STRUPCASE(DD),STRUPCASE(NPROD)+'_MEAN',COUNT)
          IF COUNT EQ 1 THEN NPROD = NPROD+'_MEAN' ELSE MESSAGE, 'ERROR: ' + NPROD + ' not found in file'
        ENDIF
        D = READ_NC(FILE,PROD=NPROD,BINS=BINS,/DATA) ; NOTE: May need some updates to account for the NC_PRODUCTS
        IF SI.MAP EQ 'LONLAT' THEN BEGIN
          CONTROL_LONS = READ_NC(FILE,PROD='LONGITUDE',/DATA)
          CONTROL_LATS = READ_NC(FILE,PROD='LATITUDE',/DATA)
        ENDIF
        D = MAPS_REMAP(D, MAP_IN=SI.MAP, MAP_OUT=AMAP, BINS=BINS, CONTROL_LONS=CONTROL_LONS, CONTROL_LATS=CONTROL_LATS)
        IF KEY(MASK) THEN D[MASK] = MISSINGS(D)
      ENDELSE
    ENDIF ELSE BEGIN
      IF STRUCT NE [] THEN BEGIN
        D = STRUCT_GET(STRUCT,ATAG)
        IF HAS(STRUCT,'BINS') THEN BINS = STRUCT.BINS
        IF STRUCT.MAP NE AMAP THEN D = MAPS_REMAP(D,MAP_IN=STRUCT.MAP,MAP_OUT=AMAP, BINS=BINS)
      ENDIF ELSE BEGIN
        IF DATA_IMAGE NE [] THEN D = DATA_IMAGE ELSE D = BYT_IMAGE
      ENDELSE
    ENDELSE

    IF IDLTYPE(D) EQ 'STRING' THEN BEGIN
      PRINT,'ERROR: '+ D
      GOTO,DONE
    ENDIF;IF IDLTYPE(D) EQ 'STRING' THEN BEGIN

    ; ===> FIND MISSING DATA BEFORE CONVERTING TO BYTES
    MISS = WHERE(D EQ MISSINGS(D),COUNT_MISS)

    ; ===> CONVERT DATA TO BYTES
    IF BYT_IMAGE EQ [] THEN BYT = PRODS_2BYTE(D,PROD=SPROD,LOG=LOG) ELSE BYT = BYTE(BYT_IMAGE)
    SZ = SIZEXYZ(BYT, PX=WIDTH, PY=HEIGHT)

    IF KEY(THUMBNAIL) THEN BEGIN
      FOR TSCALE=1, 100 DO BEGIN
        TDIMS = FIX([IMG_DIMS[0]/TSCALE,IMG_DIMS[1]/TSCALE])
        IF MAX(TDIMS) LE 200 THEN GOTO, FINISH_DIMS
      ENDFOR
      FINISH_DIMS:
      WIDTH = TDIMS[0] & HEIGHT = TDIMS[1]
    ENDIF ELSE TSCALE = 1


    ; ===> CHANGE COLORS IN BYT TO MISS_COLOR
    IF COUNT_MISS GE 1 THEN BYT[MISS] = MISS_COLOR

    ; ===> ADD CONTOURS
    IF KEY(C_LEVELS) THEN BEGIN
      CBYT = MAPS_CONTOUR(D, C_LEVELS=C_LEVELS, C_COLORS=C_COLORS, C_ANNOTATION=C_ANNOTATION, C_CHARSIZE=C_CHARSIZE, C_CHARTHICK= C_CHARTHICK, C_THICK=C_THICK)
      OK = WHERE(CBYT EQ 1, COUNT)
      IF COUNT GT 0 THEN BYT[OK] = C_COLORS[0]
;TODO Update the contouring functions      
    ENDIF

    ; ===> ADD LANDMASK FEATURES
    IF KEY(ADD_LAND)  THEN IF ANY(LAND)  AND FIRST(LAND)  NE -1 THEN BYT[LAND]  = LAND_COLOR
    IF KEY(ADD_COAST) THEN IF ANY(COAST) AND FIRST(COAST) NE -1 THEN BYT[COAST] = COAST_COLOR

    
    ; ===> ADD_LONLAT
    IF KEY(ADD_LONLAT) OR ANY(LONS) OR ANY(LONNAMES) OR KEY(ADD_LONLAT_LABELS) THEN BEGIN
      IF NONE(LATS)  THEN _LATS = [-90,-60,-30,0,30,60,90]     ELSE _LATS=LATS
      IF NONE(LONS)  THEN _LONS = [-180,-120,-60,0,60,120,180] ELSE _LONS=LONS
      IF NONE(LATNAMES)  THEN _LATNAMES = STRTRIM(_LATS, 2) ELSE _LATNAMES = LATNAMES
      IF NONE(LONNAMES)  THEN _LONNAMES = STRTRIM(_LONS, 2) ELSE _LONNAMES = LONNAMES


      IF ~KEY(ADD_LL_LABELS) THEN _LATNAMES = ''
      IF ~KEY(ADD_LL_LABELS) THEN _LONNAMES = ''

      LL = MAPS_2LONLAT(AMAP)
      IF N_ELEMENTS(_LATS) GE 1 THEN BEGIN
        FIN = WHERE(FINITE(LL.LATS) EQ 0,COUNT_FIN) & IF COUNT_FIN GE 1 THEN LL.LATS[FIN] = MISSINGS(0.0)
        ZWIN, LL.LATS
        CONTOUR,LL.LATS,LEVELS=_LATS,MIN_VALUE=-90,MAX_VALUE=90,C_CHARSIZE=LL_SIZE,C_LABELS=_LATNAMES,C_THICK=LL_THICK, $
          XSTYLE=5,YSTYLE=5,XMARGIN=[0,0],YMARGIN=[0,0],POSITION=[0,0,1,1], CLOSED=0,/NOERASE,_EXTRA=_extra
        LL_LATS = TVRD()
        ZWIN
        SUBS_LAT = WHERE(LL_LATS EQ 255)
        BYT[SUBS_LAT] = LL_COLOR
      ENDIF

      IF N_ELEMENTS(_LONS) GE 1 THEN BEGIN
        FIN = WHERE(FINITE(LL.LONS) EQ 0,COUNT_FIN) & IF COUNT_FIN GE 1 THEN LL.LONS[FIN] = MISSINGS(0.0)
        ZWIN, LL.LONS
        CONTOUR,LL.LONS,LEVELS=_LONS,MIN_VALUE=-180,MAX_VALUE=180,C_CHARSIZE=LL_SIZE,C_LABELS=_LONNAMES,C_THICK=LL_THICK, $$
          XSTYLE=5,YSTYLE=5,XMARGIN=[0,0],YMARGIN=[0,0],POSITION=[0,0,1,1], CLOSED=0,/NOERASE,_EXTRA=_extra
        LL_LONS = TVRD()
        ZWIN
        SUBS_LON = WHERE(LL_LONS EQ 255)
        BYT[SUBS_LON] = LL_COLOR
      ENDIF
    ENDIF ; ADD_LONLAT

    ; ===> ADD BATHY
    IF KEY(ADD_BATHY) OR ANY(DEPTH) THEN BEGIN
      TOPO = PLT_TOPO(AMAP, DEPTH, THICKS=BATHY_THICK, COLORS=BATHY_COLOR)
      TPSZ = SIZEXYZ(TOPO,PX=TPX,PY=TPY)
      IF TPX NE WIDTH OR TPY NE HEIGHT THEN MESSAGE, 'ERROR: TOPO size dimensions do not match with the input image'
      TSUBS = [] & FOR C=0, N_ELEMENTS(BATHY_COLOR)-1 DO TSUBS = [TSUBS,WHERE(TOPO EQ BATHY_COLOR[C],COUNT_TOPO,/NULL)]
      IF COUNT_TOPO GT 0 THEN BYT[TSUBS] = TOPO[TSUBS]
    ENDIF


    ;######### ADD OUTLINE #####################
    IF KEY(ADD_OUTLINE) OR ANY(OUTLINE_IMG) THEN BEGIN
      IF NONE(OUTLINE_IMG) THEN GOTO, SKIP_OUTLINE
      IF N_ELEMENTS(OUTLINE_IMG) LT 2 THEN GOTO, SKIP_OUTLINE
      OUTLINE = OUTLINE_IMG ; Need to make a copy of the OUTLINE so that the modified outline is not returned
      OBLK = MAPS_BLANK(AMAP,FILL=0)
      OBLK[OUTLINE] = 10
      IF KEY(OUT_THICK) THEN BEGIN
        CLOUDIER, IMAGE=OBLK,CLOUDS=10B,MASK=CMASK,BOX=OUT_THICK,/QUIET
        OUTLINE = WHERE(CMASK EQ 1,COUNT_OUTLINE)
      ENDIF
      BYT[OUTLINE] = OUT_COLOR
    ENDIF;IF KEY(ADD_LMES) THEN BEGIN
    SKIP_OUTLINE:
    ;||||||||||||||||||||||||||||||||||||||||||

    ; ####### CROP THE IMAGE #######
    IF KEYWORD_SET(CROP) THEN BEGIN
      IF N_ELEMENTS(CROP) NE 4 THEN MESSAGE, 'ERROR: Must provide 4 subscripts to crop the image'
      BYT = BYT[CROP[0]:CROP[1],CROP[2]:CROP[3]]
      SZ = SIZEXYZ(BYT,PX=SPX,PY=SPY)
      IMG_DIMS = [SPX,SPY]
    ENDIF


    ; ####### CREATE THE IMAGE #######
    ; ===> OPEN IMAGE WINDOW
    IMG = IMAGE(BYT, RGB_TABLE=RGB_TABLE, BACKGROUND_COLOR=RGBS(BACKGROUND_COLOR),DIMENSIONS=IMG_DIMS, IMAGE_DIMENSIONS=IMG_DIMS, POSITION=IMG_POS, IMAGE_LOCATION=IMG_LOCATION, MARGIN=MARGIN, CURRENT=CURRENT, LAYOUT=LAYOUT, DEVICE=DEVICE, BUFFER=BUFFER)

    ; ===> ADD COLORBAR
    IF KEY(ADD_CB) THEN CBAR, SPROD, IMG=IMG, COMMA=COMMA, FONT_SIZE=CB_SIZE/TSCALE, FONT_STYLE=CB_STYLE, CB_TYPE=CB_TYPE, CB_POS=CB_POS, CB_TITLE=CB_TITLE, VSTAG=VSTAG, CB_OBJ=CB_OBJ, CB_TICKNAMES=CB_TICKNAMES, CB_TICKVALUES=CB_TICKVALUES, PAL=PAL, RELATIVE=CB_RELATIVE

    ; ===> ADD DATEBAR
    IF KEY(ADD_DB) THEN DB = DATE_BAR(_DATE,BKG=BKG,DB_FONT_SIZE= DB_SIZE,DB_COLOR=DB_COLOR,DB_THICK=DB_THICK,NO_YEAR=NO_YEAR,NO_DAY=NO_DAY,$
      PAL=PAL,PX=PX,PY=PY,DB_POS =DB_POS,DB_X=DB_X,DB_Y=DB_Y,DB_LONG=DB_LONG,DB_SHORT=DB_SHORT,_EXTRA=_EXTRA)

    ; === ADD AUTHOR TAG
    IF KEY(ADD_AUTH)  THEN T = TEXT(AUTH_POS[0], AUTH_POS[1], /RELATIVE, AUTH_TXT, FONT_SIZE=AUTH_SIZE, ALIGNMENT=AUTH_ALIGN, FONT_COLOR=AUTH_COLOR, TARGET=IMG)

    ; ===> ADD FILENAME
    IF KEY(ADD_NAME)  THEN T = TEXT(NAME_POS[0], NAME_POS[1], /RELATIVE, FA.NAME, FONT_SIZE=NAME_SIZE,  ALIGNMENT=NAME_ALIGN, FONT_COLOR=NAME_COLOR, TARGET=IMG)

    ; ===> ADD DATE
    IF KEY(ADD_DATE)  THEN T = TEXT(DATE_POS[0], DATE_POS[1], /RELATIVE, ADDDATE, FONT_SIZE=DATE_SIZE,  ALIGNMENT=DATE_ALIGN, FONT_COLOR=DATE_COLOR, TARGET=IMG)

    ; ===> ADD TEXT TAGS FROM THE STRUCTURE
    IF KEY(ADD_TXT) OR KEY(TXT_TAGS) THEN BEGIN ; NOW IF JUST 'TXT_TAGS' IS IN THE CALL TO PRODS_2PNGS (AND ADD_TXT IS OMITTED) IT WILL STILL ADD THE TXT STRING
      IF IDLTYPE(ADD_TXT) EQ 'STRING' THEN VALS = ADD_TXT ELSE BEGIN
        VALS = []
        FOR T=0, NOF(TXT_TAGS)-1 DO BEGIN
          TT = TXT_TAGS[T]
          CASE TT OF
            'DATE_CREATED': VAL = DATE_FORMAT(GET_MTIME(FILE,/DATE),/DAY)
            ELSE: VAL = STRUCT_GET(FA,TT)
          ENDCASE
          IF VAL NE [] THEN VALS = [VALS, TT + ': ' + VAL] ELSE VALS = [VALS, TT]
        ENDFOR;FOR T = 0,NOF(TXT_TAGS) -1 DO BEGIN
      ENDELSE ; ADD_TXT NE 'STRING'
      IF VALS NE [] THEN T = TEXT(TXT_POS[0], TXT_POS[1], /RELATIVE, VALS, FONT_SIZE=TXT_SIZE, FONT_STYLE=TXT_STYLE, FONT_COLOR=TXT_COLOR, TARGET=IMG, ALIGNMENT=TXT_ALIGN)
    ENDIF;IF N_ELEMENTS(ADD_TXT) GE 1 THEN BEGIN

    ;######### ADD POINTS #####################
    IF KEYWORD_SET(ADD_POINTS) THEN BEGIN
      IF IDLTYPE(ADD_POINTS) EQ 'STRUCT' THEN BEGIN
        FOR SY=0, N_TAGS(ADD_POINTS)-1 DO BEGIN
          STR = ADD_POINTS.(SY)
          MAPS_SET, AMAP, PX=IMG_DIMS[0], PY=IMG_DIMS[1]
          LL = MAP_DEG2IMAGE(MAPS_BLANK(AMAP,PX=IMG_DIMS[0],PY=IMG_DIMS[1]),STR.LONS,STR.LATS,X=PX,Y=PY)
          ZWIN
          PSY = SYMBOL(PX,PY,SYMBOL=STR.SYMBOL,/DEVICE, SYM_FILLED=STR.SYM_FILLED, SYM_COLOR=STR.SYM_COLOR, SYM_FILL_COLOR=STR.SYM_FILL_COLOR, SYM_SIZE=STR.SYM_SIZE, SYM_THICK=0.05, TARGET=IMG)
        ENDFOR
      ENDIF ELSE BEGIN
        MAPS_SET, AMAP
        LL = MAP_DEG2IMAGE(MAPS_BLANK(AMAP),POINT_LONS,POINT_LATS,X=PX,Y=PY)
        ZWIN
        PSY = SYMBOL(PX,PY,SYMBOL=POINT_SYMBOL,/DEVICE, SYM_FILLED=POINT_SYM_FILL, SYM_COLOR=POINT_COLOR, SYM_SIZE=POINT_SIZE, TARGET=IMG)
      ENDELSE
    ENDIF

    ; ##### FINISH THE IMAGE #####
    IF KEY(EDIT) THEN STOP
    OBJ = IMG

    IF KEY(DELAY) THEN BEGIN
      IF DELAY EQ 1 THEN DELAY = 10
      WAIT, DELAY
      IMG.CLOSE
      GOTO, DONE
    ENDIF

    IF KEYWORD_SET(CURRENT) OR KEYWORD_SET(NO_SAVE) THEN GOTO, DONE
    
    ; ===> WRITE THE PNGFILE
    IMG.SAVE, _PNGFILE, APPEND=APPEND, RESOLUTION=RESOLUTION, HEIGHT=HEIGHT, WIDTH=WIDTH, BORDER=BORDER, /BITMAP, BIT_DEPTH=BIT_DEPTH, OUTFILE=PNGFILE
    PFILE, _PNGFILE
    IMG.CLOSE ; ===> CLOSE THE IMAGE WINDOW
    
    DONE:
  ENDFOR ; FILES
  ;IF KEY(VERBOSE) THEN PDONE
END; #####################  END OF ROUTINE ################################
