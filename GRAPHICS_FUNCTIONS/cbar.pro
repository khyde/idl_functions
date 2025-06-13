; $ID:	CBAR.PRO,	2020-08-07-13,	USER-KJWH	$
; #########################################################################; 
PRO CBAR, PROD, IMG=IMG, OBJ=OBJ,PAL=PAL,$
          CB_TITLE=CB_TITLE, NAME=NAME, DISCRETE=DISCRETE, $
          CB_TYPE=CB_TYPE,CB_POS=CB_POS,CB_X=CB_X,CB_Y=CB_Y,CB_LONG=CB_LONG,CB_SHORT=CB_SHORT, $
          CB_TICKSN=CB_TICKSN, CB_TICKVALUES=CB_TICKVALUES, CB_TICKNAMES=CB_TICKNAMES, TICKLENGTH=TICKLENGTH, $
          BACKGROUND_COLOR=BACKGROUND_COLOR,TXT_COLOR=TXT_COLOR,COMMA=COMMA,VSTAG=VSTAG,CB_OBJ=CB_OBJ,FONT_SIZE=FONT_SIZE,FONT_STYLE=FONT_STYLE,TXT=TXT,_EXTRA=_EXTRA
;+
; PURPOSE:  
;   Draw seven types of color bars using IDL'S colorbar function
;
; CATEGORY: 
;   Graphics
;
;
; REQUIRED INPUTS: 
;   PROD............ Product name
;   
; OPTIONAL INPUTS  
;   IMG ............ Either an image or an image object
;   OBJ............. Window object
;   PAL............. PALETTE TO USE FOR THE COLORBAR [DEFAULT = 'PAL_DEFAULT']
;   CB_TITLE........ Color bar title [default is made from prods_master]
;   NAME............ An alternate name for the colorbar title  [not the default from prods_read]
;   CB_TYPE......... Code for the style of colorbar [1-7, see case block below for codes]
;   CB_POS.......... Normal-coordinate position [x,y,x2,y2]for the colorbar
;   CB_X............ X normal-coordinate for the central colorbar position [easier to estimate than CB_POS]
;   CB_Y............ Y normal-coordinate for the central colorbar position [easier to estimate than CB_POS]
;   CB_LONG......... Long dimension [normal coords] for the colorbar [use with cb_x,cb_y]
;   CB_SHORT........ Short dimension [normal coords] for the colorbar [use with cb_x,cb_y]
;   CB_TICKSN....... The number of ticks (note, currently only works with non-valid products e.g. NUM_0_9)
;   CB_TICKNAMES.... User specified ticknames
;   CB_TICKVALUES... User specified tickvalues
;   TICKLENGTH...... User specified tick length
;   BACKGROUND_COLOR Background color if the image is created on the fly (default = 'WHITE')
;   TXT_COLOR....... Color for the text
;   COMMA........... Uses str_comma to add commas to ticknames [when ge 1000]
;   VSTAG........... Vertically staggers ticknames for horizontal colorbars for greater legability [useful when prod has several decimal places]
;   FONT_SIZE....... Size of cb title and labels [default = 16]
;   TXT............. Any additional text to plot at 0.5,0.75 using text function
;   _EXTRA.......... Additional valid parameters colorbar [e.g.taper,minor]
;
; KEYWORDS
;
;  OUTPUTS:  
;    Draws a colorbar onto the current graphics object or object graphics window
;
; OPTIONAL OUTPUT  
;   CB_OBJ.......... Colorbar object
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
; NOTES: 
;   Additional CB_TYPES may be added in the future by adding to the CB_TYPE case block
; 
;   When determing the placement of the colorbar on an image or a map, it may be easier to iteratively use a single pair of normal coordinates [e.g. CB_X= & CB_Y=]
;     along with [optionally] CB_LONG & CB_SHORT, than to provide the 4 normal position coordinates in cb_pos
;
; EXAMPLES:
;   CBAR,'CHLOR_A' ; [DEFAULT = CB_TYPE = 2-KIM'S PREFERENCE]
;   CBAR,'CHLOR_A',NAME = 'Chlorophyll' 
;   CBAR,'CHLOR_A_0.01_10.0',NAME = 'Chlorophyll' 
;   CBAR,'CHLOR_A',CB_TYPE = 1
;   CBAR,'CHLOR_A',CB_TYPE = 1,/VSTAG
;   CBAR,'CHLOR_A',FONT_SIZE = 12,/TAPER,/MINOR,TEXT_ORIENTATION=90
;   CBAR,'CHLOR_A',FONT_SIZE = 12,/TAPER,/MINOR,TEXT_ORIENTATION=45
;   CBAR,'SST'
;   CBAR,'TEMPERATURE_-32_212'
;   CBAR,'TEMPERATURE_-32_212',NAME = 'Degrees Fahrenheit'
;   CBAR,'ADG_443',/VSTAG
;   CBAR,'CHLOR_A',CB_X = 0.5,CB_Y = 0.5 
;   CBAR,'CHLOR_A',CB_X = 0.50,CB_Y = 0.5,CB_LONG = 0.95
;   The following demonstrates the 7 types of colorbars [cb_type] possible with this program:
;     FOR I = 1,7 DO CBAR,'CHLOR_A',CB_TYPE = I,TXT = 'CB_TYPE= ' +ROUNDS(I)
;   The following demonstrates the 7 types of colorbars [cb_type] with cb_x,cb_y provided:
;     FOR I = 1,7 DO CBAR,'CHLOR_A',CB_TYPE = I,TXT = 'CB_TYPE= ' +ROUNDS(I),CB_X = 0.5,CB_Y = 0.5 
;          
; COPYRIGHT:
; Copyright (C) 2017, Department of Commerce, National Oceanic and Atmospheric Administration, National Marine Fisheries Service,
;   Northeast Fisheries Science Center, Narragansett Laboratory.
;   This software may be used, copied, or redistributed as long as it is not sold and this copyright notice is reproduced on each copy made.
;   This routine is provided AS IS without any express or implied warranties whatsoever.
;
; AUTHOR:
;   This program was written on August 24, 2017 by John E. O'Reilly Northeast Fisheries Science Center | NOAA Fisheries | U.S. Department of Commerce, 28 Tarzwell Dr, Narragansett, RI 02882
;     
; CONTACT INFORMATION:
;   All inquiries regarding this program should be directed to kimberly.hyde@noaa.gov    
;
; MODIFICATION HISTORY:
;     AUG 24, 2017 - JEOR: Adapted program from PRODS_COLORBAR and STRUCT_SD_2IMAGE_NG
;     AUG 25, 2017 - JEOR: Added keyword CB_TYPE
;     AUG 27, 2017 - JEOR: Fixed stagger for CB_TYPES 2 and 3
;     AUG 28, 2017 - JEOR: Added keywords CB_X,CB_Y,CB_LONG,CB_SHORT
;     AUG 30, 2017 - JEOR: Added CASE BLOCK for valid vs non-valid, compound prods [with implied range]
;     AUG 31, 2017 - JEOR: Added CASE BLOCK for CASE (CB_TYPE) OF
;     SEP 01, 2017 - JEOR: Changed STAG to VSTAG
;     SEP 16, 2017 - KJWH: Changed RANGE to RNG to avoid conflicts with the RANGE function
;     DEC 08, 2017 - KJWH: Added a space ' ' between the PROD and PROD_UNITS in the title
;     DEC 21, 2017 - KJWH: Changed TICKNAME = STRTRIM(STRUCT_2ARR(T),2) to STR_ZERO_TRIM(ROUNDS(STRUCT_2ARR(T),3,/SIG),TRIM=3) in order to remove leading zero's from the ticknames
;     JAN 23, 2018 - KJWH: Added "OR TICKNAME EQ MISSINGS(TICKNAME)" to OK = WHERE(FLOAT(TICKNAME) LT FLOAT(RNG[0]) OR FLOAT(TICKNAME) GT FLOAT(RNG[1]) OR TICKNAME EQ MISSINGS(TICKNAME),COUNT)
;                          Need to remove the '' values from the TICKNAME array - T = STRUCT_2ARR(T) & T = T[WHERE(T NE MISSINGS(T)]
;                          Added TICKNAME = STRTRIM(TICKNAME,2) to remove any blank spaces in the ticknames
;     JUL 03, 2018 - KJWH: Added CB_TICKNAMES keyword to add specific TICKNAMES to the colorbar.  Will need to be updated to work with TEXT ticknames (e.g. 'J', 'F', 'M')                 
;     AUG 16, 2019 - KJWH: Added TXT_COLOR keyword to specify the text color
;     AUG 26, 2019 - KJWH: Updated the title position for CB_TYPE = 2 (Title above, labels below) so that the position is proportionate to the height of the colorbar
;                             Y = POSITION(3) + (POSITION(3)-POSITION[1])*.5 ; ADJUST UP SO AVOVE THE CBAR
;     MAR 04, 2020 - KJWH: Updated the TICKVAL to use the CB_TICKNAMES if provided, but CB_TICKVALUES were not     
;     AUG 07, 2020 - KJWH: Updated documentation and formatting
;                          Added COMPILE_OPT IDL2
;                          Removed CB_BKG keyword because it is not used
;                          Added OBJ parameter input as an option to use the WINDOW graphics as the target location 
;                          Added functionality to add colorbars to WINDOW graphics with just the PROD and OBJ inputs    
;                          Changed default pal to PAL_DEFAULT   
;     AUG 10, 2023 - KJWH: Added TICKLENGTH as a user specified option for the tick length            
;-
; #######################################################################################################

  ROUTINE_NAME = 'CBAR'

; ===> Set up defaults
  IF NONE(PAL)              THEN PAL = 'PAL_DEFAULT' & RGB_TABLE = RGBS([1,250],PAL=PAL)
  IF NONE(CB_TYPE)          THEN CB_TYPE = 2
  IF NONE(CB_LONG)          THEN CB_LONG = 0.50
  IF NONE(CB_SHORT)         THEN CB_SHORT = 0.03
  IF NONE(BACKGROUND_COLOR) THEN BACKGROUND_COLOR = 'WHITE'
  IF NONE(TXT_COLOR)        THEN TXT_COLOR = 'BLACK'

; === Check for a product
  IF NONE(PROD) THEN MESSAGE,'ERROR: PROD is required'
  VALID_PROD = VALIDS('PRODS',PROD,/VALID)
  CASE (VALID_PROD) OF
    1: BEGIN
      S = PRODS_READ(PROD)
      IF STRUCT_GET(S,'PLOT_UNITS') EQ [] THEN PLOT_UNITS = (PRODS_READ(_PROD)).PLOT_UNITS ELSE PLOT_UNITS = S.PLOT_UNITS
      RNG = [S.LOWER,S.UPPER]
      IF NONE(CB_TITLE) THEN BEGIN
        IF NONE(NAME) THEN CB_TITLE = PROD + ' ' + PLOT_UNITS ELSE CB_TITLE = NAME  + ' ' + PLOT_UNITS
      ENDIF
    END
    
   0: BEGIN
     S = PRODS_TICKS(PROD,NUM_TICKS=CB_TICKSN)
     RNG = [S.LOWER,S.UPPER]
     IF VALIDS('PRODS',PROD,/VALID) EQ 1 THEN PLOT_UNITS = (PRODS_READ(S.PROD)).PLOT_UNITS ELSE PLOT_UNITS = ''  
     IF NONE(CB_TITLE) THEN BEGIN
       IF NONE(NAME) THEN CB_TITLE = S.PROD + ' ' + PLOT_UNITS ELSE CB_TITLE = NAME  + ' ' + PLOT_UNITS
     ENDIF
    END
  ENDCASE;CASE (VALID_PROD) OF

; ===> Set up colorbar types
  CASE (CB_TYPE) OF
    1: BEGIN ; ; HORIZONTAL: TITLE ABOVE BAR,AXIS ABOVE BAR
       IF NONE(CB_POS)  THEN CB_POS = [0.25,0.50,(0.25 + CB_LONG),(0.50+ CB_SHORT)]
       TITLE = CB_TITLE
       MINOR            = 0
       ANTIALIAS        = 1
       ORIENTATION      = 0
       TEXT_ORIENTATION = 0.0
       TEXTPOS          = 1
       TICKDIR          = 0
       TICKLEN          = 0.25
       TICKLAYOUT       = 0;  
       IF NONE(FONT_SIZE) THEN FONT_SIZE = 12
       BORDER           = 1
    END;1 -------------------------------------------------------------------------------
  
    2: BEGIN ; HORIZONTAL: TITLE ABOVE BAR,AXIS BELOW BAR
      IF NONE(CB_POS)  THEN CB_POS = [0.25,0.50,(0.25 + CB_LONG),(0.50+ CB_SHORT)]
      TITLE            = ''
      MINOR            = 0
      ANTIALIAS        = 1
      ORIENTATION      = 0
      TEXT_ORIENTATION = 0.0
      TEXTPOS          = 0
      TICKDIR          = 0
      TICKLEN          = 0.5
      TICKLAYOUT       = 0;  
      IF NONE(FONT_SIZE) THEN FONT_SIZE = 12
      BORDER           = 1
    END;2 --------------------------------------------------------------------------------
  
    3: BEGIN ; ; HORIZONTAL:,AXIS BELOW BAR, TITLE BELOW AXIS
      IF NONE(CB_POS)  THEN CB_POS = [0.25,0.50,(0.25 + CB_LONG),(0.50+ CB_SHORT)]
      TITLE            = CB_TITLE
      MINOR            = 0
      ANTIALIAS        = 1
      ORIENTATION      = 0
      TEXT_ORIENTATION = 0.0
      TEXTPOS          = 0
      TICKDIR          = 0
      TICKLEN          = 0.5
      TICKLAYOUT       = 0
      IF NONE(FONT_SIZE) THEN FONT_SIZE = 12
      BORDER           = 1
    END;3 --------------------------------------------------------------------------------
    
    4: BEGIN ; ; VERTICAL: AXIS AND TITLE TO LEFT OF BAR
      IF NONE(CB_POS)  THEN CB_POS = [0.50,0.25,(0.50+CB_SHORT),(0.25+ CB_LONG)]
      TITLE = CB_TITLE
      MINOR            = 0
      ANTIALIAS        = 1
      ORIENTATION      = 1
      TEXT_ORIENTATION = 0.0
      TEXTPOS          = 0
      TICKDIR          = 0
      TICKLEN          = 0.25
      TICKLAYOUT       = 0;  
      IF NONE(FONT_SIZE) THEN FONT_SIZE = 12
      BORDER           = 1
    END;4 -------------------------------------------------------------------------------
  
    5: BEGIN ; ; VERTICAL: AXIS AND TITLE TO RIGHT OF BAR
      IF NONE(CB_POS)  THEN CB_POS = [0.50,0.25,(0.50+CB_SHORT),(0.25+ CB_LONG)]
      TITLE = CB_TITLE
      MINOR            = 0
      ANTIALIAS        = 1
      ORIENTATION      = 1
      TEXT_ORIENTATION = 0.0
      TEXTPOS          = 1
      TICKDIR          = 0
      TICKLEN          = 0.25
      TICKLAYOUT       = 0;  
      IF NONE(FONT_SIZE) THEN FONT_SIZE = 12
      BORDER           = 1
    END;5 -------------------------------------------------------------------------------
    
    6: BEGIN ; ; VERTICAL: AXIS TO RIGHT OF BAR,TITLE ABOVE OF BAR
      IF NONE(CB_POS)  THEN CB_POS = [0.50,0.25,(0.50+CB_SHORT),(0.25+ CB_LONG)]
      TITLE            = ''
      MINOR            = 0
      ANTIALIAS        = 1
      ORIENTATION      = 1
      TEXT_ORIENTATION = 0.0
      TEXTPOS          = 1
      TICKDIR          = 0
      TICKLEN          = 0.25
      TICKLAYOUT       = 0;  
      IF NONE(FONT_SIZE) THEN FONT_SIZE = 12
      BORDER           = 1
    END;6 -------------------------------------------------------------------------------
    
    7: BEGIN ; ; VERTICAL: AXIS TO RIGHT OF BAR,TITLE BELOW BAR
      IF NONE(CB_POS)  THEN CB_POS =  [0.50,0.25,(0.50+CB_SHORT),(0.25+ CB_LONG)]
      TITLE            = ''
      MINOR            = 0
      ANTIALIAS        = 1
      ORIENTATION      = 1
      TEXT_ORIENTATION = 0.0
      TEXTPOS          = 1
      TICKDIR          = 0
      TICKLEN          = 0.25
      TICKLAYOUT       = 0;  
      IF NONE(FONT_SIZE) THEN FONT_SIZE = 12
      BORDER           = 1
    END;7 -------------------------------------------------------------------------------
    
    8: BEGIN ; ; VERTICAL: AXIS TO RIGHT OF BAR, TITLE TO THE LEFT
      IF NONE(CB_POS)  THEN CB_POS =  [0.50,0.25,(0.50+CB_SHORT),(0.25+ CB_LONG)]
      TITLE            = ''
      MINOR            = 0
      ANTIALIAS        = 1
      ORIENTATION      = 1
      TEXT_ORIENTATION = 0.0
      TEXTPOS          = 1
      TICKDIR          = 0
      TICKLEN          = 0.25
      TICKLAYOUT       = 0;
      IF NONE(FONT_SIZE) THEN FONT_SIZE = 12
      BORDER           = 1
    END;8 -------------------------------------------------------------------------------
   
    ELSE: BEGIN
      MESSAGE,'ERROR: CB_TYPE ' + NUM2STR(CB_TYPE) + ' not found.'
    END
  ENDCASE

; ===> Set up the colorbar position 
  IF NOF(CB_X) EQ 1 AND NOF(CB_Y) EQ 1 THEN BEGIN
    IF ORIENTATION EQ 1 THEN SWAP,CB_LONG,CB_SHORT ; If the bar is verticle, swap the variables
    CB_POS = [(CB_X-CB_LONG/2.0),(CB_Y-CB_SHORT/2.0),(CB_X+CB_LONG/2.0),(CB_Y+CB_SHORT/2.0)]
  ENDIF

; ===> Get the ticknames 
  OK = WHERE(STRMID(TAG_NAMES(S),0,1) EQ 'T' AND STRLEN(TAG_NAMES(S)) LE 3 ,COUNT)
  IF COUNT NE 0 THEN T = STRUCT_COPY(S, OK)
  T = STRUCT_2ARR(T) & T = T[WHERE(T NE MISSINGS(T))] 
  IF NONE(CB_TICKVALUES) AND NONE(CB_TICKNAMES) THEN TICKVAL = T 
  IF NONE(CB_TICKVALUES) AND ANY(CB_TICKNAMES)  THEN TICKVAL = FLOAT(CB_TICKNAMES)
  IF ANY(CB_TICKVALUES)                         THEN TICKVAL = CB_TICKVALUES
  IF NONE(CB_TICKNAMES)                         THEN TICKNAME = STR_ZERO_TRIM(ROUNDS(TICKVAL,3,/SIG),TRIM=3) ELSE TICKNAME = CB_TICKNAMES ; Overwrite default ticknames if provided
  TICKNAME = STRTRIM(TICKNAME,2)
  IF N_ELEMENTS(TICKVAL) NE N_ELEMENTS(TICKNAME) THEN MESSAGE, 'ERROR: Must have the same number of TICKNAMES and TICKVALUES'

;===> Remove ticknames outside of ascending range
  RNG = [MIN(RNG), MAX(RNG)]
  OK = WHERE(FLOAT(TICKVAL) LT FLOAT(RNG[0]) OR FLOAT(TICKVAL) GT FLOAT(RNG[1]) OR TICKVAL EQ MISSINGS(TICKVAL),COUNT)
  IF COUNT GE 1 THEN TICKVAL = REMOVE(TICKVAL,OK)
  MAJOR = NOF(TICKVAL)
  
; ===> Check if the product has a log scale
  IF S.LOG EQ 1 THEN BEGIN
    TICKVALUES=ALOG10(FLOAT(TICKVAL))
    RNG = ALOG10([S.LOWER,S.UPPER])
  ENDIF ELSE BEGIN
    RNG = MM([S.LOWER,S.UPPER])
    TICKVALUES=(FLOAT(TICKVAL))
  ENDELSE

; ===> Add comma's to the ticknames
  IF KEYWORD_SET(COMMA) THEN BEGIN
    IF MAX(FLOAT(TICKNAME)) GE 1000 THEN  TICKNAME= STR_COMMA(ROUNDS(STRING(TICKNAME,FORMAT = '(D0)'),2,/SIG))
  ENDIF;IF KEY(COMMA) THEN BEGIN

; ===> Vertically stagger the ticknames
  IF KEYWORD_SET(VSTAG) AND ORIENTATION EQ 0 THEN BEGIN
    STAG_TXT = '!C'
    SUBS=SUBSAMPLE(LINDGEN(N_ELEMENTS(TICKNAME)),2)
    IF CB_TYPE EQ 1 THEN TICKNAME(SUBS) = TICKNAME(SUBS)+ STAG_TXT ELSE TICKNAME(SUBS) = STAG_TXT + VSTAG_TXT + TICKNAME(SUBS)
  ENDIF

; ===> Set up a discrete colorbar
  IF KEYWORD_SET(DISCRETE) THEN BEGIN
    WIDTH = ROUND(250/FLOAT(N_ELEMENTS(TICKNAME)))
    RGB_TABLE = RGB_TABLE[*,WIDTH + WIDTH*INDGEN(N_ELEMENTS(TICKNAME))]
    TICKVALUES = [] ; Remove the value to make a discrete colorbar
  ENDIF

  IF N_ELEMENTS(TICKLENGTH) EQ 1 THEN TICKLEN = TICKLENGTH

; ===> Look for an IMAGE Object then make the COLORBAR
  IF IDLTYPE(IMG) EQ 'OBJREF' THEN BEGIN
    CB_OBJ = COLORBAR(TARGET=IMG, RGB_TABLE=RGB_TABLE, RANGE=RNG,$
    POSITION    = CB_POS,$
    FONT_SIZE   = FONT_SIZE,$
    TICKLEN     = TICKLEN ,$    ; THE LENGTH OF THE TICKMARKS. OUR DEFAULT IS 0.5.
    MAJOR       = MAJOR,$
    MINOR       = MINOR,$
    BORDER      = BORDER,$      ; 1 = DISPLAY A BORDER AROUND THE IMAGE PORTION OF THE COLORBAR.
    TICKDIR     = TICKDIR,$     ; 1 = DRAW THE TICKMARKS FACING OUTWARDS. THE DEFAULT IS 0, FACING INWARDS.
    TEXTPOS     = TEXTPOS,$     ; 1 = TICK LABELS AND AXIS TITLE ABOVE THE AXIS. THE DEFAULT IS 0, BELOW THE AXIS.
    TEXT_COLOR  = TXT_COLOR,$
    ORIENTATION = ORIENTATION,$ ; 0 = HORIZONTAL 1 = VERTICAL
    TICKNAME    = TICKNAME,$
    THICK       = THICK,$
    TICKVALUES  = TICKVALUES,$
    TITLE       = TITLE,$
    TICKLAYOUT  = TICKLAYOUT,$
    _EXTRA=_EXTRA)
  ENDIF ELSE BEGIN  
    IF IDLTYPE(OBJ) EQ 'UNDEFINED' THEN BEGIN ; Create a blank image
      IMG = (REPLICATE(255B,2,2))
      OBJ = IMAGE(IMG,DIMENSIONS=[800,400],RGB_TABLE=RGB_TABLE,/HIDE,BACKGROUND_COLOR= BACKGROUND_COLOR,POSITION = [0,0,1,1],BUFFER=BUFFER)
    ENDIF  
    
    CB_OBJ = COLORBAR(RGB_TABLE=RGB_TABLE, RANGE=RNG,WINDOW=OBJ,$
      POSITION    = CB_POS,$
      FONT_SIZE   = FONT_SIZE,$
      TICKLEN     = TICKLEN ,$    ; THE LENGTH OF THE TICKMARKS. OUR DEFAULT IS 0.5.
      MAJOR       = MAJOR,$
      MINOR       = MINOR,$
      BORDER      = BORDER,$      ; 1 = DISPLAY A BORDER AROUND THE IMAGE PORTION OF THE COLORBAR.
      TICKDIR     = TICKDIR,$     ; 1 = DRAW THE TICKMARKS FACING OUTWARDS. THE DEFAULT IS 0, FACING INWARDS.
      TEXTPOS     = TEXTPOS,$     ; 1 = TICK LABELS AND AXIS TITLE ABOVE THE AXIS. THE DEFAULT IS 0, BELOW THE AXIS.
      TEXT_COLOR  = TXT_COLOR,$
      ORIENTATION = ORIENTATION,$ ; 0 = HORIZONTAL 1 = VERTICAL
      TICKNAME    = TICKNAME,$
      THICK       = THICK,$
      TICKVALUES  = TICKVALUES,$
      TITLE       = TITLE,$
      TICKLAYOUT  = TICKLAYOUT,$
      _EXTRA=_EXTRA) 
  ENDELSE  
    
; ===> Add titles for specific CB_TYPES
  CASE (CB_TYPE) OF
    2: BEGIN
     POSITION = CB_OBJ.POSITION
     X = MEAN([POSITION[0],POSITION(2)])
     Y = POSITION(3) + (POSITION(3)-POSITION[1])*.5 ; Adjust up so avove the cbar
     T = TEXT(X,Y,CB_TITLE,/OVERPLOT,/CURRENT,TARGET = CB_OBJ,FONT_SIZE=FONT_SIZE,FONT_COLOR=TXT_COLOR,ALIGN = 0.5)
    END;2
   6: BEGIN
     POSITION = CB_OBJ.POSITION
     X = MEAN([POSITION[0],POSITION(2)])
     Y = POSITION(3) + 0.03 ; Adjust up so above the cbar
     T = TEXT(X,Y,CB_TITLE,/OVERPLOT,/CURRENT,TARGET = CB_OBJ,FONT_SIZE=FONT_SIZE,FONT_COLOR=TXT_COLOR,ALIGN = 0.5)
    END;6
   7: BEGIN
     POSITION = CB_OBJ.POSITION
     X = MEAN([POSITION[0],POSITION(2)])
     Y = POSITION[1] - 0.07 ; Adjust down so below the cbar
     T = TEXT(X,Y,CB_TITLE,/OVERPLOT,/CURRENT,TARGET = CB_OBJ,FONT_SIZE=FONT_SIZE,FONT_COLOR=TXT_COLOR,ALIGN = 0.5)
    END;7 
   8: BEGIN
     POSITION = CB_OBJ.POSITION
     Y = MEAN([POSITION[1],POSITION(3)])
     X = POSITION[0] - 0.01 ; Adjust left so below the cbar
     T = TEXT(X,Y,CB_TITLE,/OVERPLOT,/CURRENT,TARGET = CB_OBJ,FONT_SIZE=FONT_SIZE,FONT_COLOR=TXT_COLOR,ALIGN = 0.5,ORIENTATION=90)
    END;7
    ELSE: BEGIN
  END 
     
  ENDCASE

; ===> Add text if provided
  IF KEY(TXT) THEN T = TEXT(0.15,0.15,TXT,/OVERPLOT,/CURRENT,TARGET = CB_OBJ,FONT_SIZE=FONT_SIZE,FONT_STYLE=FONT_STYLE,FONT_COLOR=TEXT_COLOR,ALIGN = 0.5)
  
END; #####################  END OF ROUTINE ################################
