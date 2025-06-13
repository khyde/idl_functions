; $ID:	PRODS_COLORBAR.PRO,	2023-09-21-13,	USER-KJWH	$
;#############################################################################################################
	PRO PRODS_COLORBAR,PROD, IMG=IMG, TITLE=TITLE, STRUCT=STRUCT, PAL=PAL,$
	                   FILE=FILE, RES=RES, DELAY=DELAY, CLOSE=CLOSE, BUFFER=BUFFER,BIT_DEPTH=BIT_DEPTH,$
	                   CB_POS=CB_POS,CB_LO=CB_LO,CB_HI=CB_HI,LOG=LOG,$
	                   COLOR=COLOR, BACKGROUND_COLOR=BACKGROUND_COLOR, TEXT_COLOR=TEXT_COLOR,$
	                   FONT_NAME=FONT_NAME, FONT_SIZE=FONT_SIZE, FONT_STYLE=FONT_STYLE,$
	                   THCIK=THICK, MAJOR=MAJOR, MINOR=MINOR,$
	                   TICKNAMES=TICKNAMES, TICKVALUES=TICKVALUES, TICKDIR=TICKDIR,$
	                   ASPECT=ASPECT, POSITION=POSITION, ORIENTATION=ORIENTATION,$
	                   VSTAG=VSTAG, COMMA=COMMA,$
	                   EDIT=EDIT, VERBOSE=VERBOSE, _EXTRA=_EXTRA               
;+
; NAME:
;		PRODS_COLORBAR 
;
; PURPOSE: 
;   Make a scaled colorbar based on an input product
;
; CATEGORY: 
;   Product functions
;
; CALLING SEQUENCE: 
;   PRODS_COLORBAR, PROD
;
; REQUIRED INPUTS: 
;   PROD........ The name of the standard prod [e.g. 'CHLOR_A' OR 'SST' OR 'PAR' ETC.] see VALID_PRODS
;		
; OPTIONAL INPUTS:
;   IMG......... Either an image or an image object to add the colorbar to
;   TITLE....... Title for the colorbar
;   STRUCT...... Use the info in struct to make a color bar [instead of PRODS_READ to get info]
;   PAL......... The name of a standard color palette
;   FILE........ The name of the output file to make a pngfile
;   RES......... The resolution to save the output image
;   DELAY....... The time in seconds to wait before closing the image
;   BIT_DEPTH...
;   CB_POS...... The position of the colorbar in the image 'T'=TOP, 'B'=BOTTOM, 'L'=LEFT, or 'R'=RIGHT
;   CB_LO....... Lowest color for the colorbar (default = 1)
;   CB_HI....... Highest color for the colorbar (default = 250)
;   ASPECT...... Y to X aspect ratio [default is 0.1]
;   _EXTRA...... Any other keywords to be passed to POSITIONS
;    
; KEYWORD PARAMETERS:
;		LOG......... To log the product when scaling
;		CLOSE....... Close the image after a set time
;		BUFFER...... To turn on (1) or off (0) the graphics buffer (1 will produce the grahic in the background)
;		EDIT........ Program stops after creating colorbar and appropriate colorbar commands may be used interactively to edit colorbar properties
;		COMMA....... Uses STR_COMMA to add commas to ticknames [when ge 1000]
;   VSTAG....... Vertically staggers of ticknames for greater legability  
;   VERBOSE..... Execute print commands
;   
;	OUTPUTS
;	  A scaled color bar
;	  
;	OPTIONAL OUTPUTS
;		A png file with the colorbar
;	
; COMMON BLOCKS:
;   None
;
; SIDE EFFECTS:
;   CBAR works better than PRODS_COLORBAR when adding colorbars to existing images
;
; RESTRICTIONS:
;   None
;		
;	EXAMPLES: 
;	  PRODS_COLORBAR,'CHLOR_A'
;   PRODS_COLORBAR,'PAR'
;   PRODS_COLORBAR,'PPD'
;   PRODS_COLORBAR,'SST'
;   PRODS_COLORBAR,'TEMP'
;   PRODS_COLORBAR,'LNP_FAP',FONT_SIZE = 15
;   PRODS_COLORBAR,'ZEU',FONT_SIZE = 21
;   PRODS_COLORBAR,'NLW_412',FONT_SIZE = 16  
;   PRODS_COLORBAR,'CNUM',DELAY = 3
;   PRODS_COLORBAR,'CNUM',FONT_SIZE = 10,DELAY = 2
;   PRODS_COLORBAR,'CNUM',FONT_SIZE = 16,/COMMA,DELAY = 2
;   PRODS_COLORBAR,'NUM_0_10',FONT_SIZE = 16,TITLE = 'NUMBER'
;   PRODS_COLORBAR,'NUM_0.1_1',CB_POS = 'T',TITLE = 'FRACTION'
;   PRODS_COLORBAR,'KM2',CB_POS = 'T',TITLE = 'KM2'
;   PRODS_COLORBAR,'PPY_3_3000',CB_POS = 'T',TITLE = 'PPY',/COMMA
;   PRODS_COLORBAR,'CHLOR_A',FONT_SIZE = 22,CB_POS = 'T',FILE='CHLOR_A-T'
;   PRODS_COLORBAR,'CHLOR_A',FONT_SIZE = 22,CB_POS = 'B',FILE='CHLOR_A-B'
;   PRODS_COLORBAR,'CHLOR_A',FONT_SIZE = 22,CB_POS = 'L',FILE='CHLOR_A-L'
;   PRODS_COLORBAR,'CHLOR_A',FONT_SIZE = 22,CB_POS = 'R',FILE='CHLOR_A-R'
;		
; COPYRIGHT:
; Copyright (C) 2013, Department of Commerce, National Oceanic and Atmospheric Administration, National Marine Fisheries Service,
;   Northeast Fisheries Science Center, Narragansett Laboratory.
;   This software may be used, copied, or redistributed as long as it is not sold and this copyright notice is reproduced on each copy made.
;   This routine is provided AS IS without any express or implied warranties whatsoever.
;
; AUTHOR:
;   This program was written on December 15, 2013 by Kimberly J. W. Hyde, Northeast Fisheries Science Center | NOAA Fisheries | U.S. Department of Commerce, 28 Tarzwell Dr, Narragansett, RI 02882
;
; MODIFICATION HISTORY:
;	  DEC 15, 2013 - JEOR: Initial code written
;  	DEC 22, 2013 - JEOR: Added kewyord CLOSE
;	  DEC 31, 2013 - JEOR: Added IF WHERE(TAG_NAMES(STRUCT) EQ 'PROD') NE -1 THEN PROD = STRUCT.PROD
;                              IF CHARSIZE PROVIDED IN _EXTRA THEN MAKE FONT_SIZE = CHARSIZE [ FOR BACKWARDS COMPATABILITY]
;   JAN 01, 2014 - JEOR: Added keywords DELAY & EDIT 
;   JAN 02, 2014 - JEOR: Added keyword TITLE
;   JAN 05, 2014 - JEOR: Added OK = WHERE(STRPOS(_TITLE,PROD)GE 0,COUNT)
;                              IF COUNT EQ 0 THEN _TITLE = PROD + ' ' + _TITLE
;   JAN 14, 2014 - JEOR: Removed null TICKNAMES from the TICKNAME ARRAY
;   JAN 17, 2014 - JEOR: Added keywords CB_LO & CB_HI
;   JAN 21, 2014 - JEOR: Changed CB_LOW to CB_LO and CB_HI to CB_HI
;   JAN 24, 2014 - JEOR: Added keyword COMMA to enhance legibility vertically stagger ticknames on two levels when STRLEN exceeds 5
;   FEB 03, 2014 - JEOR: Added keyword ASPECT
;                         ASPECT_DEFAULT = 0.1 ;[COLORBAR HEIGHT = 0.1 TIMES COLORBAR WIDTH]
;   FEB 06, 2014 - JEOR: Added keyword VERBOSE and CB_POS
;   FEB 08, 2014 - JEOR: PNG may be a file name
;   FEB 12, 2014 - JEOR: Now using RGBS.PRO to get the color table
;   APR 14, 2014 - JEOR: Added keyword RES
;   APR 29, 2014 - JEOR: Removed keyword INIT [NOT USEFUL]
;                        Added IF KEYWORD_SET(VERBOSE) THEN PRINT,CB
;   APR 30, 2014 - JEOR: Added keyword BUFFER
;   MAY 01, 2014 - JEOR: Now using IMG
;   MAY 03, 2014 - JEOR: Added more keywords
;   MAY 06, 2014 - JEOR: Fixed IMG object
;   MAY 26, 2014 - JEOR: Added keyword LOG ===> IF PROD HAS RANGE ENCODED THEN REMOVE THE RANGE FROM THE PROD NAME
;   JUL 09, 2014 - JEOR: Added RESOLVE_ROUTINE,'COLORBAR'
;   DEC 15, 2014 - JEOR: Added IF NONE(PAL) THEN PAL = 'PAL_BR'
;   JAN 07, 2015 - JEOR: Fixed problem with ticknames by making STRUCT_2ARR return a string instead of double 
;                         TICKNAME= STR_COMMA(STRING(TICKNAME,FORMAT = '(G0)'))
;   MAR 05, 2015 - JEOR: Changed keyword STAT to TAG
;   MAR 15, 2015 - JEOR: Removed MAX_STRLEN
;   AUG 25, 2015 - KJWH: We should be able to overwrite the default tickvalues and ticknames if provided - temporary fix when extracting ticknames 
;                        Changed RANGE TO BE DERIVED FROM S, NOT THE TICKNAMES
;   SEP 06, 2015 - JEOR: Added IF COUNT NE 0 THEN T = STRUCT_COPY(S, OK)
;   APR 06, 2016 - JEOR: Changed from TICKNAME= STR_COMMA(STRING(TICKNAME,FORMAT = '(G0)'))
;                                  to TICKNAME= STR_COMMA(STRING(TICKNAME,FORMAT = '(D0)'))
;   JUL 14, 2016 - JEOR: Replaced TICKNAME= STR_COMMA(STRING(TICKNAME,FORMAT = '(D0)')) 
;                            with TICKNAME = STR_COMMA(STRTRIM(TICKNAME,2))
;   JUL 15, 2016 - JEOR: Added IF MAX(FLOAT(TICKNAME)) GE 1000 THEN  TICKNAME= STR_COMMA(ROUNDS(STRING(TICKNAME,FORMAT = '(D0)'),2,/SIG))
;   AUG 12, 2016 - JEOR: Added FILE=FILE TO CALL TO PLT_WRITE [ FOR MAKING PNGS];
;                        Removed BORDER_ON = 1,$ FROM CALL TO PRODS_COLORBAR
;   SEP 13, 2016 - KJWH: Changed T = STRUCT_COPY(S,OK) To be T = STRUCT_COPY(S, TAGS=OK) because it was returning an error  
;   SEP 14, 2016 - JEOR: Changed T = STRUCT_COPY(S,OK) To be T = STRUCT_COPY(S, TAGS=OK) 
;                        Changed back to T = STRUCT_COPY(S, OK) [TAGS IS NOT A KEYWORD TO STRUCT_COPY]                  
;   SEP 20, 2016 - KJWH: Changed default window size to 800x400
;                        Changed default FONT_SIZE to 12
;   NOV 14, 2016 - JEOR: Added CASE to extract compound prod names like GRAD_SST from GRAD_SST_.001_15   
;   FEB 16, 2017 - KJWH: Removed ADD_NAMES and TAG keywords (not used)
;                        Added BACKGROUND_COLOR, FONT_STYLE and THICK keywords
;                        Formatting
;   JUL 11, 2019 - KJWH: Changed default LOG value to [] because it was overwriting products that should be log (e.g. CHLOR_A_.1_30)  
;   DEC 02, 2019 - KJWH: Changed default color palette to PAL_DEFAULT  
;   May 20, 2021 - KJWH: Updated documentation and formatting
;                        Added COMPILE_OPT IDL2
;                        Changed subscript () to []
;                        Removed the steps to remove the range from the product name (e.g. SST_0_10) because that is done by PRODS_READ                 
;                   
;-
;********************************************************************************************************************************
  ROUTINE_NAME  = 'PRODS_COLORBAR'
  COMPILE_OPT IDL2

;############ CONSTANTS & DEFAULTS  ###############
  IF NONE(BACKGROUND_COLOR) THEN BACKGROUND_COLOR = RGBS(255)
  IF NONE(BIT_DEPTH)        THEN BIT_DEPTH = 1
  IF NONE(PAL)              THEN PAL = 'PAL_DEFAULT'
  IF NONE(ASPECT)           THEN ASPECT = 0.1;[COLORBAR HEIGHT = 0.1 TIMES COLORBAR WIDTH] 
  IF NONE(RES)              THEN RES = 600
  IF NONE(CB_POS)           THEN CB_POS = 'T'
  IF NONE(CB_LO)            THEN CB_LO = 1
  IF NONE(CB_HI)            THEN CB_HI = 250
  IF NONE(LOG)              THEN LOG = []
  IF NONE(COLOR)            THEN COLOR = 'BLACK'
  IF NONE(TEXT_COLOR)       THEN TEXT_COLOR = 'BLACK'
  IF NONE(FONT_NAME)        THEN FONT_NAME = 'HELVETCA'
  IF NONE(FONT_STYLE)       THEN FONT_STYLE = 0
  IF NONE(THICK)            THEN THICK = 2
  IF NONE(FONT_SIZE)        THEN FONT_SIZE = 12
  IF NONE(MAJOR)            THEN MAJOR = 1
  IF NONE(MINOR)            THEN MINOR = 0
  IF NONE(CB_COLOR)         THEN CB_COLOR = 0
  IF NONE(DELAY) THEN DELAY = 1
  IF NONE(CLOSE) THEN CLOSE = 0
  DO_IMAGE = 0 & HIDE = 0
  RGB_TABLE = RGBS([CB_LO,CB_HI],PAL=PAL)
  
;############ ############ ############ ############ ############ 

; ===> Look for an image object
  IF N_ELEMENTS(IMG) EQ 1 THEN IF IDLTYPE(IMG) EQ 'OBJREF' THEN DO_IMAGE = 1

; ===> Get the product information
  IF N_ELEMENTS(STRUCT) GE 1 THEN IF WHERE(TAG_NAMES(STRUCT) EQ 'PROD') NE -1 THEN PROD = STRUCT.PROD
  IF N_ELEMENTS(PROD) NE 1 THEN MESSAGE,'ERROR: PROD IS REQUIRED'
  IF N_ELEMENTS(STRUCT) NE 1 THEN  S = PRODS_READ(PROD,LOG=LOG,INIT=INIT) ELSE  S = STRUCT  
  IF S EQ [] THEN BEGIN
    PRINT, 'ERROR: ' + PROD + ' not found in PRODS_MAIN.csv' 
    GOTO,DONE  
  ENDIF
  _PROD = S.PROD ; Reset the PRODUCT name in case the input product has the range encoded in it (e.g. SST_0_10)


  IF N_ELEMENTS(TITLE) NE 1 THEN TITLE = UNITS(_PROD,/NO_NAME)
  
; ===> Set up the ticknames
  OK = WHERE(STRMID(TAG_NAMES(S),0,1) EQ 'T' AND STRLEN(TAG_NAMES(S)) LE 3 ,COUNT) 
  IF COUNT NE 0 THEN T = STRUCT_COPY(S, OK)
  IF N_ELEMENTS(TICKNAMES) EQ 0 THEN TICKNAME = STRTRIM(STRUCT_2ARR(T),2) ELSE TICKNAME = TICKNAMES ; Overwrite default ticknames if provided
  OK = WHERE(TICKNAME EQ '' OR TICKNAME EQ MISSINGS(0.0) OR TICKNAME EQ MISSINGS(0.0D) OR TICKNAME EQ MISSINGS(0L) OR TICKNAME EQ MISSINGS(0),COUNT)
  IF COUNT GE 1 THEN TICKNAME = REMOVE(TICKNAME,OK) ; Remove blank ticknames
  
; ===> Adjust the RANGE and TICKNAMES if logged
  IF LOG EQ [] THEN LOG = S.LOG  
  IF LOG EQ 1 THEN BEGIN
    TICKVALUES=ALOG10(FLOAT(TICKNAME))
    RNGE = ALOG10([S.LOWER,S.UPPER])  
  ENDIF ELSE BEGIN  
    RNGE = [S.LOWER,S.UPPER]
    TICKVALUES=(FLOAT(TICKNAME))  
  ENDELSE;IF S.LOG EQ 1 THEN BEGIN

; Finalize TICKNAME set-up
  IF KEYWORD_SET(COMMA) THEN IF MAX(FLOAT(TICKNAME)) GE 1000 THEN  TICKNAME= STR_COMMA(ROUNDS(STRING(TICKNAME,FORMAT = '(D0)'),2,/SIG))
  IF KEYWORD_SET(VSTAG) AND CB_POS NE 'L' AND CB_POS NE 'R' THEN TICKNAME= STAGGER(TICKNAME,/VERT)

; ===> Create the image if not present
  IF DO_IMAGE EQ 0 THEN BEGIN
    IMG = (REPLICATE(255B,2,2))
    HIDE=1
    IMG = IMAGE(IMG,DIMENSIONS=[800,400],RGB_TABLE=RGB_TABLE,HIDE=HIDE,BACKGROUND_COLOR= BACKGROUND_COLOR,POSITION = [0,0,1,1],BUFFER=BUFFER)
  ENDIF
    
; ===> Set up the colorbar defaults
  POS = POSITIONS(CB_POS,ASPECT=ASPECT,OBJ=IMG)
  IF N_ELEMENTS(POSITION) NE 4 THEN POSITION = POS.CB_POS
  IF N_ELEMENTS(TICKDIR) NE 1 THEN TICKDIR = POS.TICKDIR
  IF N_ELEMENTS(TEXTPOS) NE 1 THEN TEXTPOS = POS.TEXTPOS
  IF N_ELEMENTS(ORIENTATION) NE 1 THEN ORIENTATION = POS.ORIENTATION

; ===> Make the colorbar
  OBJ = COLORBAR(TARGET=IMG, RGB_TABLE=RGB_TABLE, RANGE=RNGE,$
    POSITION    = POSITION,$
    COLOR       = CB_COLOR,$
    FONT_NAME   = FONT_NAME,$
    FONT_SIZE   = FONT_SIZE,$
    MAJOR       = MAJOR,$
    MINOR       = MINOR,$
    TEXT_COLOR  = TEXT_COLOR,$
    TICKDIR     = TICKDIR,$
    TEXTPOS     = TEXTPOS,$
    ORIENTATION = ORIENTATION,$
    TICKNAME    = TICKNAME,$
    THICK       = THICK,$
    FONT_STYLE  = FONT_STYLE,$
    TICKVALUES  = TICKVALUES,$
    TITLE       = TITLE,$
    _EXTRA      = _EXTRA)

  IF KEYWORD_SET(EDIT)  THEN STOP                                                           ; Opportunity to manually edit the colorbar
  IF KEYWORD_SET(FILE)  THEN PLT_WRITE,IMG,FILE=FILE,BORDER = BORDER,BIT_DEPTH=BIT_DEPTH    ; Write the colorbar to the provided file
  IF KEYWORD_SET(DELAY) THEN WAIT, DELAY                                                    ; Pause before continuing
  IF KEYWORD_SET(CLOSE) THEN BEGIN
    IF ISA(IMG) THEN BEGIN
        IF IDLTYPE(IMG) EQ 'OBJREF' THEN IMG.CLOSE                                          ; Close graphics objects
    ENDIF
  ENDIF
  
  DONE:
END; #####################  END OF ROUTINE ################################
