; $ID:	MOVIE_DEMO.PRO,	2021-04-15-17,	USER-KJWH	$
PRO MOVIE_DEMO

  ;+
  ; NAME:
  ;   GRAPHICS_DEMO
  ;
  ; PURPOSE:;
  ;   This procedure is to test the new plotting and image routines in IDL 8.0
  ;
  ; NOTES:
  ;
  ; MODIFICATION HISTORY:
  ;     Written May 16, 2011 by K.J.W.Hyde, 28 Tarzwell Drive, NMFS, NOAA 02882 (kimberly.hyde@noaa.gov)
  ;-
  ; ****************************************************************************************************
  ROUTINE_NAME = 'MOVIE_DEMO'
  
    
  SL = DELIMITER(/PATH)
  
  
  
  
  RGB_TABLE = CPAL_READ('PAL_SW3',PALLIST=PALLIST)
  FAO = IDL_RESTORE(FIX_PATH(!S.IDL + 'DEMO/MOVIES_DEMO/ORIG_FIG_55.SAVE'))
  FP = FILE_PARSE(FIX_PATH(!S.IDL + 'DEMO/MOVIES_DEMO/ORIG_FIG_55.SAVE'))
        
  
  COLORS = SD_SCALES(FINDGEN(N_ELEMENTS(FAO)),PROD='NUM',SPECIAL_SCALE=NUM2STR(N_ELEMENTS(FAO)),/DATA2BIN)
  B = WHERE_SETS(COLORS)
  P = PLOT(FLOAT(FAO.POINT_X),FLOAT(FAO.POINT_Y),LINESTYLE=0,COLOR='BLACK',THICK=1,XRANGE=[-90,-36],XTITLE='Longitude',YTITLE='Latitude',TITLE='LAT/LON PLOT')
  P.SAVE,FIX_PATH(FP.DIR + '\FRAMES\LME_FAO_PLOT_TITLE.png'),resolution=200
  CB = COLORBAR(RGB_TABLE=RGB_TABLE(*,1:250),POSITION=[0.18,0.22,0.7,0.24],RANGE=[0,N_ELEMENTS(B)],TITLE='Vertex #')
  FOR N=0, N_ELEMENTS(B)-1 DO BEGIN
    SAVEFILE = FIX_PATH(FP.DIR + '\FRAMES\LME_FAO_PLOT_FRAME_'+STR_PAD(NUM2STR(N),3)+'.png')
    IF FILE_TEST(SAVEFILE) EQ 1 AND NOT KEYWORD_SET(OVERWRITE) THEN CONTINUE
    SUBS = WHERE_SETS_SUBS(B(N))
    S = SYMBOL(FLOAT(FAO(SUBS).POINT_X),FLOAT(FAO(SUBS).POINT_Y),SYM_COLOR=PALLIST(B(N).VALUE),/SYM_FILLED,SYMBOL='CIRCLE',SYM_SIZE=0.5,/DATA)
    P.SAVE,SAVEFILE,resolution=200
  ENDFOR
  PNGFILES = FILE_SEARCH(FIX_PATH(FP.DIR + '\FRAMES\LME_FAO_PLOT_FRAME_*.png'))
  MOVIE_FILE = 'LME_FAO_PLOT_ANIMATION'+['.MP4','.AVI']
  DIR_MOVIES = FP.DIR
  FOR M=0, N_ELEMENTS(MOVIE_FILE)-1 DO MAKE_FF_MOVIE,FILES=PNGFILES,DIR_OUT=DIR_MOVIES,PAL='PAL_SW3',KBPS=KBPS,FPS=15,YOFFSET=YOFFSET,$
    TITLE_FILE_PNG=FIX_PATH(FP.DIR + '\FRAMES\LME_FAO_PLOT_TITLE.png'),N_TITLE=15,TITLE_SLIDE=1,MOVIE_FILE=MOVIE_FILE(M)    
  STOP
  
END



