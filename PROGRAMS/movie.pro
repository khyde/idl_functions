; $ID:	MOVIE.PRO,	2020-07-08-15,	USER-KJWH	$
; ;########################################################################################3
PRO MOVIE, FILES, MOVIE_FILE=MOVIE_FILE, DIR_OUT=DIR_OUT, N_REPEAT=N_REPEAT, FRAME_SEC=FRAME_SEC, FORMAT=FORMAT, WIDTH=WIDTH, HEIGHT=HEIGHT, $
           ADD_TITLE=ADD_TITLE, TITLE_FILE=TITLE_FILE, N_TITLE=N_TITLE, TITLE_TXT=TITLE_TXT, $
           ADD_END=ADD_END,     END_FILE=END_FILE,     N_END=N_END,     END_TXT=N_TXT, $
           METADATA=METADATA, ADD_AUDIO=ADD_AUDIO, _EXTRA=_EXTRA, VERBOSE=VERBOSE, OVERWRITE=OVERWRITE
 
; PURPOSE:  
;   Makes a movie from a series of image files [usually pngs]
;
; CATEGORY: 
;   VISUALIZATION FUNCTIONS
;
; CALLING SEQUENCE: 
;   MOVIE, FILES
;
; REQUIRED INPUTS: 
;   FILES......... An array of image file names (usually .png) to be made into an animation
;
; OPTIONAL INPUTS:
;   MOVIE_FILE.... The name of the output movie file name
;   DIR_OUT....... The ouput directory for the movie file
;   N_REPEAT...... The number of times to repeat an image (default =1)
;   FRAME_SEC..... The number of frames per second (default = 10)
;   FORMAT........ The extension of the movie file (default = mp4)
;   WIDTH......... The frame width in pixels (the default is based on the dimensions of the first image file)
;   HEIGHT........ The frame height in pixels (the default is based on the dimensions of the first image file)
;   TITLE_FILE.... The name of the file to use as the title slide
;   TITLE_TXT..... Text to be added to the TITLE slide if being made on the fly
;   N_TITLE....... The number of times the TITLE slide is repeated
;   END_FILE...... The name of the file to be used as the END slide 
;   END_TXT....... Text to be added to the END slide if being made on the fly
;   N_END......... The number of times the END slide is repeated
;   METADATA...... A structure containing the metadata for the file
;   ADD_AUDIO..... Add audio to the file (note, this has not been tested)
;   _EXTRA........ _EXTRA keywords (used when adding the TEXT to the title and end slides)
;
; KEYWORD PARAMETERS: 
;   ADD_TITLE..... To add a TITLE slide for the movie (not needed if TITLE_FILE is provided)
;   ADD_END....... To add the END slide for the movie (not needed if the END_FILE is provided)
;   VERBOSE....... Print out steps of the program
;   OVERWRITE..... Overwrite existing movie files
;
; OUTPUTS: 
;   A movie file in the desired format
;
; EXAMPLES: 
;   MOVIE, FILES
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
; NOTES:
;   NOV 10, 2020 - TODO: Add standard metadata to the movie files - COMPLETED
;   NOV 17, 2020 - TODO: Test the ADD_AUDIO block
;   
; COPYRIGHT:
; Copyright (C) 2014, Department of Commerce, National Oceanic and Atmospheric Administration, National Marine Fisheries Service,
;   Northeast Fisheries Science Center, Narragansett Laboratory.
;   This software may be used, copied, or redistributed as long as it is not sold and this copyright notice is reproduced on each copy made.
;   This routine is provided AS IS without any express or implied warranties whatsoever.
;
; AUTHOR:
;   This program was written on September 17, 2014 by John E. O'Reilly, Northeast Fisheries Science Center | NOAA Fisheries | U.S. Department of Commerce, 28 Tarzwell Dr, Narragansett, RI 02882
;   Inquires should be directed to kimberly.hyde@noaa.gov
;
;
; MODIFICATION HISTORY:
;   SEP 17, 2014 - JEOR: Copied sections from MAKE_FF_MOVIE, streamlined, modified extensively, added new functions, formatting
;   SEP 19, 2014 - JEOR: Streamlined keywords to just those needed 
;   SEP 20, 2014 - JEOR: Removed BIT_RATE - not needed [conclusion from a number of trials where various bit_rates were supplied]
;   DEC 15, 2014 - JEOR: Changed default to AVI
;   DEC 29, 2014 - JEOR: Replaced READALL with READIT
;   MAR 18, 2015 - JEOR: Added keyword DIR_OUT
;   FEB 02, 2017 - JEOR: Now using READ_IMAGE
;                        Added IMG = IMAGE_2TRUE(IMG,PAL = 'PAL_BR')
;   AUG 03, 2017 - KJWH: Formatting & documentation 
;                        Removed the METADATA block and put it directly in the section to add metatdata to the movie file
;                        Added TITLE_SLIDE and END_SLIDE related keywords
;                        Copied TITLE and END slide code from MAKE_FF_MOVIE and am now using MAKE_AVI_TITLE if needed
;                        Updated the determination of the WIDTH and HEIGHT
;                        Updated how REPEAT_FRAME is determined
;                        Added VERBOSE and OVERWRITE keywords
;                        Added FILE_MAKE(FILES,MOVIE_FILE,OVERWRITE=OVERWRITE) check
;   NOV 10, 2020 - KJWH: Updated documenation
;                        Added COMPILE_OPT IDL2
;                        Changed subscript () to []   
;                        Added ERROR if no files are provided    
;                        Changed default frames per second (FPS) to 10    
;   NOV 18, 2020 - KJWH: Updated documentation
;                        Changed TITLE and END keywords
;                        Changed TYPE keyword to FORMAT
;                        Added the WEBM format (may want to make this the default in the future)
;                        Added a step to derive the format from the file name or change the file name extension if the format types don't match
;                                                      
;
; -
; ****************************************************************************************************************************
  ROUTINE_NAME = 'MOVIE'
  COMPILE_OPT IDL2
  
;===> DEFAULTS & CONSTANTS
  FORMATS = ['MP4','AVI', 'GIF',  'MOV', 'WEBM']
  UL='_'
  IF NONE(FPS) THEN FPS = 10 
  IF NONE(N_TITLE) THEN N_TITLE = 10
  IF NONE(N_END) THEN N_END = 10
  IF NONE(N_REPEAT) THEN N_REPEAT = 2
  IF !S.INITIALS EQ 'JEOR' THEN DEFAULT_FORMAT = 'AVI' ELSE DEFAULT_FORMAT = 'MP4'
  IF NONE(METADATA) THEN METADATA = CREATE_STRUCT('Author', !S.AUTHOR, 'Affiliation', !S.AFFILIATION)
  IF IDLTYPE(METADATA) NE 'STRUCT' THEN MESSAGE, 'ERROR: Metadata must be entered as a structure.'
  
; ===> Get info from parsed file name and determine the date range
  IF NONE(FILES)  THEN MESSAGE, 'ERROR: Must provide input image files.'
  FN=FILE_PARSE(FILES)
  IF NONE(DIR_OUT) THEN DIR_OUT = FN[0].DIR
;  IF NONE(PROD)  THEN PROD = FIRST(FN.PROD)
;  DATE_START=FN.DATE_START & _DATE_START=DATE_START[SORT(DATE_START)]
;  DATE_START=STRMID(_DATE_START[0], 0,8)
;  DATE_END  =STRMID(_DATE_START[-1],0,8)
;  PER = VALID_PERIODS('DD_' + DATE_START + UL + DATE_END)
;  DATE_TXT = STRJOIN([DATE_START,DATE_END],' - ') & IF DATE_TXT EQ ' - ' THEN 
  
  DATE_TXT = ''
  
; ===> Set up the output movie file name and determine the file format  
  IF NONE(MOVIE_FILE) THEN BEGIN
    IF NONE(FORMAT) THEN FORMAT = DEFAULT_FORMAT
    MOVIE_FILE = DIR_OUT +  PER +'-'+ ROUTINE_NAME + '-'+ PROD  +'.'+ FORMAT 
    FM = FILE_PARSE(MOVIE_FILE)
  ENDIF ELSE BEGIN
    FM = FILE_PARSE(MOVIE_FILE)
    IF NONE(FORMAT) AND FM.EXT NE '' THEN FORMAT = FM.EXT
    IF NONE(FORMAT) AND FM.EXT EQ '' THEN FORMAT = DEFAULT_FORMAT
    IF STRUPCASE(FM.EXT) NE STRUPCASE(FORMAT) THEN MOVIE_FILE = REPLACE(MOVIE_FILE,'.'+FM.EXT,'.'+STRLOWCASE(TYPE))
  ENDELSE  
  IF WHERE(FORMATS EQ STRUPCASE(FORMAT)) LT 0 THEN MESSAGE, 'ERROR: Unrecognized movie file format - correct output formats are: '+ STRJOIN(FORMATS + ', ')    ; ===> CHECK MOVIE FORMAT
  
  IF FILE_MAKE(FILES,MOVIE_FILE,OVERWRITE=OVERWRITE) EQ 0 THEN GOTO, DONE

; ===> Get width and height of image from the first image file (assumes all files are dimensioned as the first file)
  IMG = READ_IMAGE(FILES[0])
  SZ=SIZE(IMG,/STRUCT)
  IF SZ.N_DIMENSIONS EQ 3 THEN N = 1 ELSE N = 0
  IF NONE(WIDTH)  THEN WIDTH  = SZ.DIMENSIONS[N]
  IF NONE(HEIGHT) THEN HEIGHT = SZ.DIMENSIONS[N+1]
  
; ===> Make the title slide 
  IF KEYWORD_SET(ADD_TITLE) OR N_ELEMENTS(TITLE_FILE) EQ 1 THEN BEGIN
    IF NONE(TITLE_FILE) THEN BEGIN
      TITLE_FILE = REPLACE(MOVIE_FILE,'.'+FM.EXT,'-TITLE_FILE.png')
      IF NONE(TITLE_TXT) THEN BEGIN
        IF DATE_TXT NE '' THEN TITLE_TXT = [DATE_TXT, 'Created by ' + !S.AUTHOR, REPLACE(!S.AFFILIATION,' | U.S. Department of Commerce','')] $
                          ELSE TITLE_TXT = ['Created by ' + !S.AUTHOR, REPLACE(!S.AFFILIATION,' | U.S. Department of Commerce','')]
        
      ENDIF
      TITLE_TXT = STRJOIN(TITLE_TXT,'!C!C')
      I = READ_IMAGE(FN[0].FULLNAME)
      IM = IMAGE(I,DIMENSIONS=[WIDTH,HEIGHT],/BUFFER)
      TX = TEXT(0.5,0.5,TITLE_TXT,ALIGNMENT=0.5,VERTICAL_ALIGNMENT=0.5,_EXTRA=_EXTRA);FONT_COLOR=FONT_COLOR,FONT_SIZE=FONT_SIZE,FONT_STYLE=FONT_STYLE)
      IM.SAVE, TITLE_FILE
      IM.CLOSE
    ENDIF 
    FILES=[TITLE_FILE,FILES]
    ADD_TITLE = 1 ; Make sure the ADD_TITLE keyword is set
  ENDIF 
  
  ; ===> Make the end slide
  IF KEYWORD_SET(ADD_END) OR N_ELEMENTS(END_FILE) EQ 1 THEN BEGIN
    IF NONE(END_FILE) THEN BEGIN
      END_FILE = REPLACE(MOVIE_FILE,'.'+FM.EXT,'-END_FILE.png')
      IF NONE(END_TXT) THEN END_TXT = ''
        
      END_TXT = STRJOIN(END_TXT,'!C!C')
      I = READ_IMAGE(FN[-1].FULLNAME)
      IM = IMAGE(I,DIMENSIONS=[WIDTH,HEIGHT],/BUFFER)
      IF END_TXT NE '' THEN TX = TEXT(0.5,0.5,END_TXT,ALIGNMENT=0.5,VERTICAL_ALIGNMENT=0.5,_EXTRA=_EXTRA);FONT_COLOR=FONT_COLOR,FONT_SIZE=FONT_SIZE,FONT_STYLE=FONT_STYLE)
      IM.SAVE, END_FILE
      IM.CLOSE
    ENDIF
    FILES=[FILES,END_FILE]
    ADD_END = 1 ; Make sure the ADD_END keyword is set
  ENDIF  

; ===> Open the movie file  
  OVID = IDLFFVIDEOWRITE(MOVIE_FILE,FORMAT=FORMAT)

; ===> Add metadata to movie file
  MTAGS = TAG_NAMES(METADATA)
  FOR MTH=0, N_TAGS(METADATA)-1 DO BEGIN
    OVID.SETMETADATA,MTAGS[MTH],METADATA.(MTH)
  ENDFOR
  
; ===> Set up the movie details
  VIDSTREAM = OVID.ADDVIDEOSTREAM(WIDTH, HEIGHT, FPS, BIT_RATE=5000000L) ; 5000 kpbs is a standard decent quality
  
; ===> Add audio to the movie
  IF KEYWORD_SET(ADD_AUDIO) THEN BEGIN
    MESSAGE, 'CAUTION: This section has not been test...'    
    AUDSTREAM = OVID.ADDAUDIOSTREAM(SAMPLERATE)
    TIME = OVID.PUT(AUDSTREAM, AUDIO)
  ENDIF
 

; ===> Add the images to the video
  FRAMES = N_ELEMENTS(FILES)
  FOR NTH = 0L, FRAMES-1 DO BEGIN
    REPEAT_FRAME = N_REPEAT
    IF NTH EQ 0 AND KEYWORD_SET(ADD_TITLE) THEN REPEAT_FRAME = N_TITLE
    IF NTH EQ FRAMES-1 AND KEYWORD_SET(ADD_END) THEN REPEAT_FRAME = N_END  
    IMG = READ_IMAGE(FILES[NTH])
    IF KEY(VERBOSE) THEN PFILE, FILES[NTH],/A
    FOR RP=0, REPEAT_FRAME-1 DO TIME = OVID.PUT(VIDSTREAM, IMG)
  ENDFOR;FOR NTH = 0L, FRAMES-1 DO BEGIN
;FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF

;===>CLOSE THE FILE
  OVID.CLEANUP
  IF KEY(VERBOSE) THEN PFILE, MOVIE_FILE

  DONE:

END; #####################  END OF ROUTINE ################################
