; $ID:	CPAL_VIEW.PRO,	2023-09-21-13,	USER-KJWH	$
;#############################################################################################################
	PRO CPAL_VIEW, PALS, PNG=PNG, TXT=TXT, NAMES=NAMES, TABLE=TABLE, DELAY=DELAY, WILDCARD=WILDCARD, BUFFER=BUFFER
	
;  PRO CPAL_VIEW
;+
; NAME:
;		CPAL_VIEW
;
; PURPOSE: 
;   This function displays a 256 color palette with color numbers
;   
; CATEGORY:  
;   PALLETTE_FUNCTIONS
;   UTILITY
;		 
; CALLING SEQUENCE: 
;   CPAL_VIEW, PAL
;
; REQUIRED INUTS: 
;   None
; 
; OPTIONAL INPUTS:
;		PAL.......... The name of the color palette .pro to display.  (Default is 'PAL_DEFAULT')
;		DELAY........ The amount of time (in seconds) to keep the image open
;   WILDCARD..... A wildcard text string to use when searching for color palettes
;		
; KEYWORD PARAMETERS:
;   PNG..... Make a PNG file of the palette display
;   TXT..... Make a window display of the !COLOR as text using IDL_COLORS
;   NAMES... Get all of the names of the palette programs or list of colors in !COLOR is the input PAL is IDL
;   TABLE... Creates a csv file with the R,G,B values for each color
;   BUFFER.. Turn on or off the image window buffer
;
; OUTPUTS: 
;   A display of the palette 
;   
; OPTIONAL OUTPUTS:
;   A png file saved to !S.IDL_PALETTES/PNGS
;   A csv table saved to !S.IDL_PALETTES/CSV
;   A rgb file saved to !S.IDL_PALETTES
;   A image showing the colors and names found in !COLOR saved in !S.IDL_TEMP   
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
; EXAMPLES:  
;   CPAL_VIEW
;   CPAL_VIEW,'PAL_36'
;   CPAL_VIEW,/TXT,/PNG
;   CPAL_VIEW,'PAL_LANDMASK' 
;   CPAL_VIEW,'IDL'
;   CPAL_VIEW,'PAL_LME',/PNG
;   CPAL_VIEW,/NAMES
;   CPAL_VIEW,'IDL',/NAMES'
;   CPAL_VIEW,/TABLE
;
; COPYRIGHT:
; Copyright (C) 2020, Department of Commerce, National Oceanic and Atmospheric Administration, National Marine Fisheries Service,
;   Northeast Fisheries Science Center, Narragansett Laboratory.
;   This software may be used, copied, or redistributed as long as it is not sold and this copyright notice is reproduced on each copy made.
;   This routine is provided AS IS without any express or implied warranties whatsoever.
;
;   This program was written by John E. O'Reilly, DOC/NOAA/NMFS/NEFSC Narragansett, RI
;          with assistance from Kimberly Hyde, DOC/NOAA/NMFS/NEFSC Narragansett, RI, kimberly.hyde@noaa.gov
;
;   All inquires should be directed to kimberly.hyde@noaa.gov
;
;
; MODIFICATION HISTORY:
;			 Apr 18, 2013 - JEOR: Wrote the program
;			 May 28, 2014 - JEOR: Made the default pal PAL_SW3
;			                      Added PNG keyword
;			                      Added IF PAL EQ 'IDL' THEN READ THE IDL !COLOR PALETTE IMAGE
;			 Jun 30, 2014 - JEOR: Added IF PAL NE 'IDL' THEN CALL_PROCEDURE,PAL,R,G,B
;			 Jul 05, 2014 - JEOR: Added NAMES and TABLE keywords
;			 Jul 06, 2014 - JEOR: Added TXT keyword 
;			 Jul 09, 2014 - JEOR: Added IF PAL NE 'IDL' THEN RESOLVE_ROUTINE,PAL
;      May 01, 2020 - KJWH: Updated documentation
;                           Changed default palette to PAL_DEFAULT
;      Apr 30, 2021 - KJWH: Removed the SLIDEW call if the image is not saved as a png
;                           Added COMPILE_OPT IDL2 
;                           Updated documentation  
;      Aug 10, 2023 - KJWH: Changed the default palette from PAL_DEFAULT to searching for all available pal_*.pro files
;                           Added the ability to loop through multiple palettes
;                           Added the WILDCARD keyword to use when searching for PAL files
;                           Added the BUFFER keyword to use when creating images
;                           Now also creating an example colorbar and exporting the palette as a csv
;                                              
;                       			
;-
;#################################################################################
;

  ROUTINE_NAME  = 'CPAL_VIEW'
  COMPILE_OPT IDL2

;===> DEFAULTS
  SL = PATH_SEP()
  DIR_PNG = !S.IDL_PALETTES + 'PNG' + SL 
  DIR_CSV = !S.IDL_PALETTES + 'CSV' + SL 
  DIR_CB  = !S.IDL_PALETTES + 'COLORBARS' + SL
  DIR_TEST, [DIR_PNG, DIR_CSV, DIR_CB]
    
  IF ~N_ELEMENTS(BUFFER) THEN BUFFER = 0
  IF ~N_ELEMENTS(DELAY) THEN DELAY = 5
  IF ~N_ELEMENTS(PALS) THEN PALS=CPAL_GET(WILDCARD)
  
  FOR N=0, N_ELEMENTS(PALS)-1 DO BEGIN
    PAL = PALS[N]
    PAL = STRLOWCASE(PAL)
    PAL = REPLACE(PAL,'.pro','')                          ; Remove the .pro before resolving
    PALFILE = !S.PALETTE_FUNCTIONS + PAL + '.pro'
  ;  IF PAL NE 'idl' THEN RESOLVE_ROUTINE, PAL             ; Compiles the .pro routine
    
    R=[] & G=[] & B=[]                                    ; Make sure the R, G and B variables are null
  
    IF KEYWORD_SET(TXT) THEN BEGIN                        ; Make a window display of the !COLOR as text using IDL_COLORS
      COLORS = TAG_NAMES(!COLOR)
      COLORS = COLORS[SORT(COLORS)]
      W = WINDOW(DIMENSIONS=[1024,1024],BACKGROUND_COLOR = 'GREY',WINDOW_TITLE = 'IDL !COLORS')
      XPOS = 0.02
      YPOS = 0.97
      XCOUNT = 0
      FOR C = 0, N_ELEMENTS(COLORS)-1 DO BEGIN
        T = TEXT(XPOS,YPOS-(XCOUNT*0.025),COLORS[C],COLOR=!COLOR.(C),FONT_SIZE=15,FONT_STYLE='BOLD',/NORMAL,/CURRENT)
        XCOUNT = XCOUNT+1
        IF C EQ 37  THEN BEGIN & XPOS = 0.27 & XCOUNT = 0 & ENDIF
        IF C EQ 75  THEN BEGIN & XPOS = 0.52 & XCOUNT = 0 & ENDIF
        IF C EQ 112 THEN BEGIN & XPOS = 0.78 & XCOUNT = 0 & ENDIF
      ENDFOR;FOR C = 0, N_ELEMENTS(COLORS)-1 DO BEGIN
      PNGFILE = DIR_PNG + 'IDL_COLORS-TEXT_LIST' + '.PNG'
      IF KEY(PNG) THEN W.SAVE ,PNGFILE
      WAIT, DELAY
      W.CLOSE
      PFILE,PNGFILE
      CONTINUE
    ENDIF ; IDL TEXT DISPLAY
  
  ;|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
  
    IF KEYWORD_SET(NAMES) THEN BEGIN
      IF PAL NE 'idl' THEN BEGIN
        DIRS = GET_PROGRAM_DIRS()
        FILES = []
        FOR D=0, N_ELEMENTS(DIRS)-1 DO FILES =[FILES,FILE_SEARCH(DIRS[D]+['PAL_*.PRO','pal_*.pro','PAL_*.pro','pal_*.PRO'])]  ; Look for pal*.pro files 
        FILES = FILES[WHERE(FILES NE '',/NULL)]
        FN = FILE_PARSE(FILES)
        PALS = STRUPCASE(FN.FIRST_NAME)  
      ENDIF ELSE BEGIN
        PALS = TAG_NAMES(!COLOR)
        PALS = PALS(SORT(PALS))  
      ENDELSE;IF PAL NE 'IDL' THEN BEGIN
      PN,PALS,'PALETTES'
      PRINT,PALS,FORMAT = "(5(A,'; '))" 
      CONTINUE   
    ENDIF;IF KEY(NAMES) THEN BEGIN
  
  
  ;###################################################################
    IF KEYWORD_SET(TABLE) THEN BEGIN
      CSVFILE = DIR_CSV + 'IDL_COLOR_RGBS.csv'
      NAMES = TAG_NAMES(!COLOR)
      ;FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FOR NTH = 0,N_ELEMENTS(NAMES)-1 DO BEGIN
        NAME = NAMES[NTH]
        RGB = !COLOR.(NTH)
        R = FIX(RGB[0]) & G = FIX(RGB[1]) & B = FIX(RGB[2])
        D = CREATE_STRUCT('NAME',NAME,'R',R,'G',G,'B',B)
        IF N_ELEMENTS(DB) EQ 0 THEN DB = D ELSE DB = [DB,D]
      ENDFOR;FOR NTH = 0,N_ELEMENTS(NAMES)-1 DO BEGIN
      ;FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
    
      STRUCT_2CSV,CSVFILE,DB
      PFILE,CSVFILE,/W
      
     CONTINUE 
    ENDIF;IF KEY(TABLE) THEN BEGIN
  ;|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||  
    
    
    IF PAL EQ 'idl' THEN BEGIN
     FILE = !S.IDL_TEMP  + "IDLCOLORS.PNG"
     IF FILE_TEST(FILE) THEN IMG = READ_PNG(FILE) 
     IDL_NAMES=TAG_NAMES(!COLOR)
    ENDIF;IF PAL EQ 'IDL' THEN BEGIN
  
    CPAL_COLORBOX, PAL, DELAY=DELAY, BUFFER=BUFFER
    
    CBFILE = !S.IDL_PALETTES + 'COLORBARS' + SL + PAL + '.png'
    IF FILE_MAKE(PALFILE,CBFILE,OVERWRITE=OVERWRITE) EQ 1 THEN BEGIN
      W = WINDOW(DIMENSIONS=[500,150],BUFFER=BUFFER)
      CBAR, 'NUM_0_10', PAL=PAL, CB_TITLE=PAL, OBJ=W, FONT_SIZE=10, CB_POS=[.1,.25,.9,.65], TICKLENGTH=0.15
      W.SAVE, CBFILE
      W.CLOSE
    ENDIF
    
    CPAL_2CSV, PAL
    
    IF PAL NE 'idl' THEN CALL_PROCEDURE,PAL,R,G,B
  
    IF KEYWORD_SET(PNG) THEN BEGIN  
      IF PAL NE 'idl' THEN CALL_PROCEDURE,PAL,R,G,B
      PNGFILE = !S.IDL_PALETTES + 'PNG' + SL + PAL + '.png'
      WRITE_PNG,PNGFILE,IMG,R,G,B
      PFILE,PNGFILE  
    ENDIF 
  ENDFOR  

DONE:


END; #####################  END OF ROUTINE ################################
