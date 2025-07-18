; $ID:	PSPRINT.PRO,	2014-08-02-18	$  RES
  ;#########################################################################################  
  PRO PSPRINT, VECTOR=VECTOR,XSIZE=XSIZE,YSIZE=YSIZE, FULL=FULL,HALF=HALF, SPECIAL=SPECIAL,HELP=HELP, _EXTRA=_EXTRA

;+
; NAME:
;       PSPRINT
;
; PURPOSE:
;       DIRECTS GRAPHIC OUTPUT TO A POSTSCRIPT (OR ENCAPSULATED POSTSCRIPT) FILE AND
;       CHANGES SETTINGS FOR POSTSCRIPT DEVICE (PS) FOR SUBSEQUENT PLOTS.
;
; CATEGORY:
;       PRINTING
;
; CALLING SEQUENCE:
;       CALL PSPRINT TO INITIALIZE POSTSCRIPT DEVICE
;       ISSUE GRAPHICS COMMANDS
;       CALL PSPRINT (WITH NO OTHER KEYWORDS) TO CLOSE POSTSCRIPT FILE.
;  OR ...
;       CALL PSPRINT TO INITIALIZE POSTSCRIPT DEVICE
;       CALL PSPRINT WITH /HELP TO PRINT THE POSTSCRIPT DEVICE SETTINGS
;      .
;       CALL PSPRINT AGAIN WITH DEVICE KEYWORDS TO MAKE SOME MORE CHANGES TO THE POSTSCRIPT DEVICE
;       CALL PSPRINT WITH /HELP TO PRINT THE NEW POSTSCRIPT DEVICE SETTINGS
;       ISSUE GRAPHICS COMMANDS
;       CALL PSPRINT (WITH NO OTHER KEYWORDS) TO CLOSE POSTSCRIPT FILE.
;
;       THESE SETTINGS FOR THE PS DEVICE WILL REMAIN IN EFFECT
;       UNTIL YOU EXIT AND START A NEW IDL SESSION
;       OR YOU CALL PSPRINT WITH ADDITIONAL DEVICE COMMANDS
;
;
; EXAMPLES:
;       PSPRINT & PLOT,[1,2,3,4] & PSPRINT

;       PSPRINT,/COLOR,/EPS & PSPRINT,/HELP & PLOT,[1,2,3,4] & PSPRINT

; INPUTS:
;       NONE REQUIRED (DEFAULT POSTSCRIPT OUTPUT =IDL.PS)
;
; KEYWORD PARAMETERS:
;       KEYWORDS:

;         _EXTRA: (ANY VALID DEVICE COMMANDS FOR POSTSCRIPT DEVICE MAY BE PROVIDED
;                  SEE IDL HELP FOR THE POSTSCRIPT DEVICE)
;
;         VECTOR:  MAKE THE DEFAULT FONT THE IDL VECTOR FONT INSTEAD OF THIS PROGRAM'S
;                  DEFAULT (/TIMES).
;
;
;
; ===============>
; EXAMPLES OF SOME OF THE ADDITIONAL KEYWORD COMMANDS FOR POSTSCRIPT FILES
; (YOU CAN PASS ANY OF THESE COMMANDS TO THIS PROGRAM).
;
;TYPE OF OUTPUT POSTSCRIPT FILE
; POSTSCRIPT       IS THE DEFAULT UNLESS ENCAPSULATED IS USED.
; ENCAPSULATED
;                  SET THIS KEYWORD TO CREATE AN ENCAPSULATED POSTSCRIPT FILE,
;                  SUITABLE FOR IMPORTING INTO ANOTHER DOCUMENT.
;
;NAME OF OUTPUT POSTSCRIPT FILE:
; FILENAME:      NORMALLY, ALL GENERATED OUTPUT IS SENT TO A FILE NAMED IDL.PS
;                UNLESS A FILE NAME IS PROVIDED.
;                IF NO FILENAME PROVIDED AND /ENCAPSULATED THEN OUTPUT IS IDL.EPS
;
;PAGE ORIENTATION:
; PORTRAIT       IS THE DEFAULT UNLESS LANDSCAPE IS USED
; LANDSCAPE:     ORIENTATION (ABSCISSA ALONG THE LONG DIMENSION OF THE PAGE) IS USED.
;
;SIZE AND POSITION OF PLOT ON PAGE
; XSIZE:         SPECIFIES THE  WIDTH OF OUTPUT GENERATED BY IDL.IN CENTIMETERS,
; YSIZE:         SPECIFIES THE HEIGHT OF OUTPUT GENERATED BY IDL IN CENTIMETERS,
; XOFFSET:       SPECIFIES THE X POSITION, ON THE PAGE
; YOFFSET:       SPECIFIES THE Y POSITION, ON THE PAGE
;
;UNITS
; INCHES:        NORMALLY, THE XOFFSET, XSIZE, YOFFSET, AND YSIZE KEYWORDS ARE SPECIFIED IN CENTIMETERS.
;                HOWEVER, IF INCHES IS PRESENT AND NON-ZERO, THEY ARE TAKEN TO BE IN INCHES INSTEAD.
;
;COLOR OF PLOT:
; COLOR: ENABLES COLOR AND ENABLES THE COLOR TABLES.
;
; BITS_PER_PIXEL:IDL IS CAPABLE OF PRODUCING POSTSCRIPT IMAGES WITH 1, 2, 4, OR 8 BITS PER PIXEL.
;                (USE 1 FOR BLACK&WHITE; 5 FOR 32 GRAY SHADES; 8 FOR 256 COLOR PAGES.
;                (CAN USE BITS=1 FOR BLACK AND WHITE, BITS=5, ETC)

;FONT THICKNESS
; LIGHT:         SET THIS KEYWORD TO SPECIFY THAT THE LIGHT VERSION OF THE CURRENT POSTSCRIPT FONT SHOULD BE USED.
; MEDIUM:        SET THIS KEYWORD TO SPECIFY THAT THE MEDIUM VERSION OF THE CURRENT POSTSCRIPT FONT SHOULD BE USED.
; BOLD:          SET THIS KEYWORD TO SPECIFY THAT THE BOLD VERSION OF THE CURRENT POSTSCRIPT FONT SHOULD BE USED.
; NARROW;        SET THIS KEYWORD TO SPECIFY THAT THE NARROW VERSION OF THE CURRENT POSTSCRIPT FONT SHOULD BE USED.
; OBLIQUE;       SET THIS KEYWORD TO SPECIFY THAT THE OBLIQUE VERSION OF THE CURRENT POSTSCRIPT FONT SHOULD BE USED.

;FONT STYLES     (SEE IDL HELP FOR ALL AVAILABLE POSTSCRIPT FONTS)
; AVANTGARDE:    SET THIS KEYWORD TO SELECT THE ITC AVANT GARDE POSTSCRIPT FONT.
; COURIER:       SET THIS KEYWORD TO SELECT THE COURIER POSTSCRIPT FONT.
; HELVETICA:     SET THIS KEYWORD TO SELECT THE HELVETICA POSTSCRIPT FONT.
; SYMBOL:        SET THIS KEYWORD TO SELECT THE SYMBOL POSTSCRIPT FONT.
; TIMES:         SET THIS KEYWORD TO SELECT THE TIMES-ROMAN POSTSCRIPT FONT.

;OTHER
; PREVIEW:SET THIS KEYWORD TO ADD A "DEVICE INDEPENDENT SCREEN PREVIEW" TO THE POSTSCRIPT OUTPUT FILE,

;
; OUTPUTS:
;      THE RESULTS FROM YOUR GRAPHICS COMMANDS ARE SENT TO THE POSTSCRIPT FILE
;
; SIDE EFFECTS:
;
;      CHANGES THE IDL !PROMPT TO 'PS' THE FIRST CALL THEN TO PREVIOUS !PROMPT
;      WHEN PSPRINT IS CALLED WITHOUT ANY OTHER INSTRUCTIONS OR KEYWORDS.
;
;      SETS !P.FONT TO 0, MAKING HARDWARE FONTS THE DEFAULT.
;      YOU CAN MAKE THE IDL VECTOR THE DEFAULT FONT BY USING THE KEYWORD /VECTOR
;
;      THESE SETTINGS YOU CHOOSE FOR THE PS DEVICE WILL REMAIN IN EFFECT UNTIL YOU RESTART A NEW IDL SESSION
;
; NOTES:
;         DEFAULT IS 1 BIT COLOR (BLACK&WHITE), TIMES ROMAN FONT
;
; RESTRICTIONS:
;
;
; MODIFICATION HISTORY:
;       J.O'REILLY , AUGUST 11,1997
;       AUG 2,2014,JOR :IF NONE(XSIZE) THEN XSIZE=8.1 & XSIZE = XSIZE -XOFFSET

  ;#########################################################################################  
;-
;-------------------------------------------------------------


; ====================>
; SET OUTPUT DEVICE TO POSTSCRIPT
;
; IF CURRENT GRAPHICS DEVICE IS NOT POSTSCRIPT THEN SET_PLOT='PS'.
; IF IT IS ALREADY POSTSCRIPT THEN CLOSE AND RESTORE THE !PROMPT
; (BUT IF HELP THEN LEAVE OPEN AND DISPLAY SETTINGS)
  IF !D.NAME NE 'PS' THEN BEGIN
    !PROMPT = !D.NAME + '>PS'
    SET_PLOT,'PS'
  ENDIF ELSE BEGIN
    POS = RSTRPOS(!PROMPT,">PS")
    IF POS THEN BEGIN
;     CLOSE THE POSTSCRIPT FILE ONLY IF PSPRINT IS GIVEN WITH NO QUALIFIERS
;     CHECK IF ANY COMMANDS TO DEVICE WERE GIVEN OR IF HELP IS USED
      DONE = N_ELEMENTS(VECTOR) + N_ELEMENTS(PAGE) + N_ELEMENTS(HELP) + N_ELEMENTS(_EXTRA) EQ 0
      IF DONE THEN BEGIN ;IF DONE IS 1 (TRUE) THEN CLOSE THE POSTSCRIPT FILE
        DEVICE,/CLOSE
        SET_PLOT,STRMID(!PROMPT,0,POS)
        !PROMPT = 'IDL>'
        RETURN
      ENDIF
    ENDIF
  ENDELSE


  FILENAME='IDL.PS'

; ====================>
; SET THE DEFAULT FONT FOR THIS PROGRAM (/TIMES)
; OR THE IDL VECTOR FONT ?
  IF NOT KEYWORD_SET(VECTOR) THEN BEGIN
    !P.FONT = 0
  ENDIF ELSE BEGIN
    !P.FONT = -1
  ENDELSE

; =================>
; DEFAULT PAGE SIZES FOR POSTSCRIPT
; SET UP FOR PUBLICATION PAGE
;  DEVICE,XOFFSET= 0.75,/INCH
;  DEVICE,YOFFSET= 1.5, /INCH
;  DEVICE,XSIZE  = 7.0, /INCH
;  DEVICE,YSIZE  = 8.75,/INCH

; ==============>
; ENABLE A FULL PAGE


  IF KEYWORD_SET(FULL) THEN BEGIN
    _PAGE =1
    XOFFSET= .5
    YOFFSET= .75
    IF NONE(XSIZE) THEN XSIZE=8.1 & XSIZE = XSIZE -XOFFSET
    IF NONE(YSIZE) THEN YSIZE=10.6 & YSIZE = YSIZE -YOFFSET
     
    DEVICE,XOFFSET= XOFFSET,/INCH
    DEVICE,YOFFSET= YOFFSET,/INCH  ; CENTIMETERS

    DEVICE,XSIZE=XSIZE ,/INCH
    DEVICE,YSIZE=YSIZE ,/INCH
  ENDIF

 IF KEYWORD_SET(HALF) THEN BEGIN
    _PAGE =1
  DEVICE,XOFFSET= 0.75,/INCH
  DEVICE,YOFFSET= 1.5,/INCH
  DEVICE,XSIZE  = 6.0 ,/INCH
  DEVICE,YSIZE  = 5.0,/INCH
  ENDIF

  IF KEYWORD_SET(SPECIAL) THEN BEGIN
    IF SPECIAL EQ 'TM' THEN DEVICE, XSIZE=6.0*2.54,YSIZE=7.776*2.54
  ENDIF

; ====================>
; DEFAULT BITS_PER_PIXEL = 1 (BLACK & WHITE)
;  CHECK _EXTRA TO SEE OF COLOR WAS PROVIDED
  IF KEYWORD_SET(_EXTRA) THEN BEGIN
    TAGS = TAG_NAMES(_EXTRA)

;   COLOR ?
    OK = WHERE(STRMID(TAGS,0,3) EQ 'COL',COUNT)
    IF COUNT GE 1 THEN BEGIN
      DEVICE, BITS_PER_PIXEL=8,/COLOR
    ENDIF

;   ENCAPSULATED POSTSCRIPT ?
    OK = WHERE(STRMID(TAGS,0,3) EQ 'ENC' OR STRMID(TAGS,0,3) EQ 'EPS',COUNT)
    IF COUNT GE 1 THEN BEGIN
     DEVICE, /ENCAPSULATED,BITS_PER_PIXEL=8,/COLOR,PREVIEW=2,FILENAME='IDL.EPS'
    ENDIF

;   POSTSCRIPT ?
    OK = WHERE(STRMID(TAGS,0,3) EQ 'PS',COUNT)
    IF COUNT GE 1 THEN BEGIN
     DEVICE, ENC=0,FILENAME='IDL.PS'
    ENDIF

;   ENCAPSULATED POSTSCRIPT ?
    OK = WHERE(STRMID(TAGS,0,3) EQ 'FIL',COUNT)
    IF COUNT GE 1 THEN BEGIN
     DEVICE,FILENAME=FILENAME
    ENDIF

;   PORTRAIT ?
    OK = WHERE(STRMID(TAGS,0,3) EQ 'POR',COUNT)
    IF COUNT GE 1 THEN BEGIN
     DEVICE,PORTRAIT=1
    ENDIF

;   LANDSCAPE ?
    OK = WHERE(STRMID(TAGS,0,3) EQ 'LAN',COUNT)
    IF COUNT GE 1 THEN BEGIN
     DEVICE,LANDSCAPE=1
    ENDIF

  ENDIF ;  IF KEYWORD_SET(_EXTRA) THEN BEGIN




; ===================>
; CHECK _EXTRA AND SUPPLY ANY EXTRA INSTRUCTIONS TO
; THE POSTSCRIPT DEVICE
  IF KEYWORD_SET(_EXTRA) THEN DEVICE, _EXTRA=_EXTRA

; =================>
; DISPLAY CURRENT GRAPHICS SETINGS
  PRINT_HELP:
  IF KEYWORD_SET(HELP) THEN HELP,/DEVICE

;############################################################################
  END; #####################  END OF ROUTINE ################################
