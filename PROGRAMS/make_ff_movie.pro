; $ID:	MAKE_FF_MOVIE.PRO,	2020-07-08-15,	USER-KJWH	$
; Makes a Movie from a series of images
; **************** Compressor  ***************************************
;
; Optional Keywords:
;   fps  := frames per second
;   kbps := bit rate in Kilo-Bits per Second (usual range is 1000-15000) higher is bigger/better, to a point.
;           (default = 5000 if not specified, coded in this routine.  IDLffVideoWrite default is unkown, but lower)
;   metadata arguments: specify a string for album, artist, comment, copyright, genre, mtitle
;   title arguments originally by TD; use at your discretion
;   getformats := print out the IDLffVideoWrite available formats for this platform
; 
; NOTES:
;   PAL = ['PAL_SW3','PAL_PETES24J']   IF THE INPUT FILES HAVE BOTH SEAWIFS AND AVHRR
;    If PAL is not specified, then the PNG file will be queried for a palette and that one will be used.
;    In many cases, the palette is already available in the PNG file.
;   MP4 and AVI file types are supported here, but there are MANY more types available.
;   IF format = (e.g. '.mp4' or '.avi') is not specified in IDLffVideoWrite object creation
;    then the filename extension is used to determine the file encoding type.
;    MP4 is recommended for high quality and small size.
;   Note on KPBS, if you use a higher frame rate, you will need a higher KBPS.  The converse is true as well.
;   mtitle is used in metadata because of an ambiguity problem
;   To use different formats, call this routine with the /getformats keyword.  Then use one of those
;   formats as the extension to the MOVIE_FILE filename, for example, 'my_movie.mpeg', or 'my_movie.mp4'
;   
; EXAMPLE:
;
; EXAMPLE FOR MAKING AN AVI FROM IMAGES THAT HAVE BOTH SEAWIFS AND AVHRR COMBINED INTO ONE PNG:
;   FILES = FILELIST('G:\METHODS\TS_IMAGES_SEAWIFS_AVHRR_REPRO3_CD_NEC_CHLOR_A_SST_ISERIES_1745_INTERP_DAY_*.PNG')  & $ 
;     MAKE_FF_MOVIE,FILES=FILES,MOVIE_FILE='G:\METHODS\TS_IMAGES_SEAWIFS_AVHRR_REPRO3_CD_NEC_CHLOR_A_SST_ISERIES_1745_INTERP_DAY.AVI'
;   FILES = FILELIST('G:\METHODS\TS_IMAGES_SEAWIFS_AVHRR_REPRO3_CD_NEC_CHLOR_A_SST_ISERIES_1745_INTERP_DAY_*.PNG') $ $
;     MAKE_FF_MOVIE,FILES=FILES(0:5),PAL=['PAL_SW3','PAL_PETES24J'],MOVIE_FILE='G:\METHODS\JUNK_BATCH.AVI
;     
;   make_ff_movie,files=f,dir_out='/tmp/',movie_file='xyz.mp4', fps=2, kbps=2000, $
;   album='myalbum',artist='DWM',comment='Productivity',copyright='(C) NMFS',genre='science',mtitle='NEC oceancolor'
;
;   make_ff_movie,files=f,dir_out='/tmp/',movie_file='xyz.avi', fps=10, kbps=8000, $
;     artist='DWM',copyright='(C) NMFS',genre='science',mtitle='NEC oceancolor'
;   
; HISTORY:
;   Jul 08, 2002 Written by: J.E. O'Reilly, NOAA, 28 Tarzwell Drive, Narragansett, RI 02882
;   Jul 22, 2002 - TD:   Work with sd_analyses_main.pro
;   Aug 15, 2003 - TD:   Add TITLE_SLIDE_FILE keyword
;   Feb 10, 2004 - TD:   Do not pass TITLE_SLIDE_FILE ,make it if TITLE_SLIDE is set
;   Jun 15, 2011 - DWM:  Changed name to MAKE_FF_MOVIE.  Convert to use IDLffVideoWrite
;                        Calculates 24 bit true-color image using palette and PNG file data.
;                        Read the palette from the PNG file and use that if available.
;   Jun 20, 2011 - DWM:  Modified movie file name and dir_out handling, doc sect., added kbps arg, fixed fps
;                        Removed useless code, added metadata args
;   Apr 03, 2104 - KJWH; Added END slides similar to TITLE slides
;   FEB 02, 2017 - KJWH: Updated default movie file name
;                        Removed making the calibration file (not necessary)
;
;-

PRO MAKE_FF_MOVIE,FILES=files, PAL=pal, $ ; REQUIRED INPUT
                DIR_OUT=dir_out, $
                MOVIE_FILE=MOVIE_FILE, $     ; don't specify a path with this name if you specify dir_out
                FPS=fps, $                   ; frames per second
                REPEAT_FRAME=repeat_frame, $ ; repeat the same frame x number of times to balance out the frame rate
                kbps=kbps, $                 ; bit rate in Kilo-bits per second (Kbps) e.g. 2000 - 15000
                MOVIE_TYPE=MOVIE_TYPE, $     ; Extension for the type of movie file to produce
                TITLE_SLIDE=title_slide, TITLE_FILE_PNG=TITLE_FILE_PNG, N_TITLE=N_TITLE,$
                END_SLIDE  =end_slide,   END_FILE_PNG  =END_FILE_PNG,   N_END  =N_END,$
                TYPE=TYPE, MAP=MAP,$ ; USUAL INPUT
                YOFFSET=YOFFSET,TITLE_COLOR=title_color,$
                AUTHORS=authors,ADDRESS=address,SENSORS=sensors, $
                album=album,artist=artist,comment=comment,copyright=copyright,genre=genre,mtitle=mtitle, $
                getformats=getformats, mformat=mformat
                

	ROUTINE_NAME = 'MAKE_FF_MOVIE'
	IF NONE(MOVIE_TYPE) THEN EXT = 'MP4' ELSE EXT = MOVIE_TYPE
	
  if N_ELEMENTS(GETFORMATS) THEN BEGIN
    ovid = IDLffVideoWrite('/tmp/tmpvid.avi')
    print,ovid.GetFormats()
    return
  endif
	UL='_'
	SLASH=DELIMITER(/SLASH)

	IF N_ELEMENTS(FILES) EQ 0 THEN FILES = DIALOG_PICKFILE()
	IF N_ELEMENTS(N_TITLE) EQ 0 THEN N_TITLE=10
  
  IF N_ELEMENTS(FPS) NE 1 THEN FPS = 30
  IF N_ELEMENTS(REPEAT_FRAME) NE 1 THEN REPEAT_FRAME = 1


; ===> Get Width and Height of Image from the first image file (assumes all files are dimensioned as the first file)
  IMG = READALL(FILES[0])
  SZ=SIZE(IMG,/STRUCT)
  IF SZ.N_DIMENSIONS EQ 3 THEN N = 1 ELSE N = 0
  WIDTH   = SZ.DIMENSIONS(N)
  HEIGHT  = SZ.DIMENSIONS(N+1)

	FN=FILE_PARSE(FILES)
	;DATE_START=FN.DATE_START & S=SORT(DATE_START) & _DATE_START=DATE_START(S)
	;DATE_START=STRMID(FIRST(_DATE_START),0,8)
	;DATE_END  =STRMID(LAST(_DATE_START),0,8)

  IF NONE(DIR_OUT) THEN DIR_OUT = FN[0].DIR & DIR_TEST, DIR_OUT
	IF N_ELEMENTS(MOVIE_FILE) NE 1 THEN BEGIN
  	MOVIE_FILE = DIR_OUT + REPLACE(FN[0].NAME,FN[0].PERIOD,FN[0].PERIOD_CODE+'_'+NUM2STR(DATE_START)+'-'+NUM2STR(DATE_END))+'-MOVIE-FPS_'+NUM2STR(FPS)+'.'+EXT
  	FN_AVI=PARSE_IT(MOVIE_FILE,/ALL)
	ENDIF ELSE MOVIE_FILE=DIR_OUT + SLASH + MOVIE_FILE
	FN_AVI=PARSE_IT(MOVIE_FILE,/ALL)
	

	
	
  
;	********************* Make Title Slide ******************
	TITLE_SLIDE_FILE = FN[0].DIR  +'TITLE_SLIDE-'+FN_AVI[0].PROD+'.PNG'
	IF KEYWORD_SET(TITLE_SLIDE) THEN BEGIN
 		IF FILE_TEST(TITLE_FILE_PNG) EQ 0 THEN BEGIN
 		  TITLE_FILE_PNG=FN[1].FULLNAME
 		  TITLE_SLIDE_FILE=MAKE_AVI_TITLE(IMAGE_FILE=TITLE_FILE_PNG,TYPE=TYPE,PAL=PAL,DIR_OUT=FN[0].DIR ,MAP=MAP,$
			                                DATE_START=DATE_START, DATE_END=DATE_END,YOFFSET=YOFFSET,TITLE_COLOR=title_color,$
		  	                              AUTHORS=authors,ADDRESS=address,SENSORS=sensors)
		ENDIF ELSE TITLE_SLIDE_FILE = TITLE_FILE_PNG 	                              
    _FILES=[REPLICATE(TITLE_SLIDE_FILE,N_TITLE),FILES]
  ENDIF ELSE _FILES=FILES
  
; ********************* Make End Slide ******************
  END_SLIDE_FILE   = FN[0].DIR  +'END_SLIDE-'  +FN_AVI[0].PROD+'.PNG'
  IF KEYWORD_SET(END_SLIDE) THEN BEGIN
    IF FILE_TEST(END_FILE_PNG) EQ 0 THEN BEGIN
      END_FILE_PNG=FN[1].FULLNAME
      END_SLIDE_FILE=MAKE_AVI_TITLE(IMAGE_FILE=END_FILE_PNG,TYPE=TYPE,PAL=PAL,DIR_OUT=FN[0].DIR ,MAP=MAP,$
                                    DATE_START=DATE_START, DATE_END=DATE_END,YOFFSET=YOFFSET,TITLE_COLOR=title_color,$
                                    AUTHORS=authors,ADDRESS=address,SENSORS=sensors)
    ENDIF ELSE END_SLIDE_FILE = END_FILE_PNG
    _FILES=[_FILES,REPLICATE(END_SLIDE_FILE,N_END)]
  ENDIF 

 

; artificially populate PAL variable for IDLffVideoWrite
; ------ you may use the palette from the PNG file ----

; example of parsing a PNG file and getting it's palette; adapted from IDL help by DWM
; only done if PAL is not specified
   png_had_palette = 0
   if N_ELEMENTS(PAL) EQ 0 THEN BEGIN
     i = 0
     ok = QUERY_PNG(files[i],s)
     IF (ok) THEN BEGIN
       IF (s.HAS_PALETTE) THEN BEGIN
        img = READ_PNG(files[i],r,g,b)
        png_had_palette = 1
        IMAGE_TRUE = BYTARR(3,WIDTH,HEIGHT)
       ENDIF ELSE BEGIN
        img = READ_PNG(files[i])
       ENDELSE
     END
   ENDIF


  ; ****************************************************************
  ; *** Make a first frame to properly initialize the  colors ******
  ; ****************************************************************
  IF PNG_HAD_PALETTE EQ 0 THEN BEGIN ; palette not found in PNG file
    IF N_ELEMENTS(PAL) GE 1 THEN BEGIN
      N=N_ELEMENTS(PAL)
      RR = BYTARR(N,256)
      GG = BYTARR(N,256)
      BB = BYTARR(N,256)
      FOR _PAL =0,N_ELEMENTS(PAL)-1 DO BEGIN
        CALL_PROCEDURE,PAL(_PAL),R,G,B
        RR(_PAL,*)=R & GG(_PAL,*)=G & BB(_PAL,*)=B
      ENDFOR

      RR = CONGRID(RR,WIDTH,HEIGHT)
      GG = CONGRID(GG,WIDTH,HEIGHT)
      BB = CONGRID(BB,WIDTH,HEIGHT)
  
      IMAGE_TRUE = BYTARR(3,WIDTH,HEIGHT)
      IMAGE_TRUE(0,*,*) = RR
      IMAGE_TRUE(1,*,*) = GG
      IMAGE_TRUE(2,*,*) = BB
     ; WRITE_PNG,IMAGE_TRUE_FILE,IMAGE_TRUE
    ENDIF ELSE BEGIN
      MESSAGE, 'ERROR: Must provide pal or array of pal '
      RETURN
    ENDELSE
  ENDIF ; Palette not found

  ; choose an encoder type
  ;ovid = IDLffVideoWrite(MOVIE_FILE,format='avi')
  ;ovid = IDLffVideoWrite(MOVIE_FILE,format='mp4')
  ovid = IDLffVideoWrite(MOVIE_FILE)
  ; Set Metadata if desired
  if n_elements(album) eq 1 then $
    ovid.SetMetadata,'album',album
  if n_elements(artist) eq 1 then $
    ovid.SetMetadata,'artist',artist
  if n_elements(comment) eq 1 then $
    ovid.SetMetadata,'comment',comment
  if n_elements(copyright) eq 1 then $
    ovid.SetMetadata,'copyright',copyright
  if n_elements(genre) eq 1 then $
    ovid.SetMetadata,'genre',genre
  if n_elements(title) eq 1 then $
    ovid.SetMetadata,'title',mtitle

  ; use bit_rate to increase or decrease the quality; higher bitrate = higher quality and size
  if n_elements(bit_rate) ne 0 then begin
    bps = kbps * 1000L ; (must multiply user's kbps to get bps), allows user to specify smaller numbers at command
    vidStream = ovid.AddVideoStream(width, height, fps, BIT_RATE=bps)
  endif else begin
    ; use default bit_rate (unkown)
    vidStream = ovid.AddVideoStream(width, height, fps, BIT_RATE=5000000L) ;5000 kpbs is a standard decent quality
  endelse

  ; Audio if desired goes in here
  ;audStream = ovid.AddAudioStream(samplerate)
  ;time = oVid.Put(audStream, audio)

  ; Generate video frames
  tmpi = image_true
  FOR i = 0, n_elements(_files) -1 DO BEGIN
    img = readall(_FILES(i))
    POF,i,_files,TXT=_files(i),/NOPRO
   ; print, 'Adding file: ' + _files(i)
;    tmpi(0,*,*) = r(img)
;    tmpi(1,*,*) = g(img)
;    tmpi(2,*,*) = b(img)
    FOR RP=0, REPEAT_FRAME-1 DO time = oVid.Put(vidStream, IMG)
  ENDFOR

  ; Close the file
  oVid.Cleanup

END
