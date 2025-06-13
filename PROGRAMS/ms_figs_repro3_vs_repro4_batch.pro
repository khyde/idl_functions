; $ID:	MS_FIGS_REPRO3_VS_REPRO4_BATCH.PRO,	2020-06-30-17,	USER-KJWH	$
PRO MS_FIGS_REPRO3_VS_REPRO4_BATCH
UL='_'
DIR_IMAGES       		= 'D:\IDL\IMAGES\'
DIR_STATS 					= 'H:\SEAWIFS\STATS\'
DIR_STATS_BROWSE 		= 'H:\SEAWIFS\STATS_BROWSE\'
DIR_SAT_SHIP		 		= 'H:\SEAWIFS\SAT_SHIP\'
DIR_OUT 						= 'H:\METHODS\'

DIR_MS              = 'E:\_MANUSCRIPTS\SeaWiFS_PLVol22_repro4_vs_repro3\'

ASENSOR = 'SEAWIFS'
AMAP    = 'NEC'
APERIOD =	'ALL'

; ****************************************************************
; ****************************   SWITCHES  ***********************
; ****************************************************************
	DO_FIG_1							      =0
	DO_STATS_FREQ_COMBINE       =0
	DO_CHL_GREY  								=0
	DO_CHL_RATIO_GREY						=0
	DO_PNEG_GREY								=1
	DO_SAT_SHIP									=0

	DO_COPY_FILES								=1
	DO_FIG_2   								  = 0


  EPS = 1


  LANDMASK=READALL(DIR_IMAGES+'MASK_NEC.PNG')



; ********************************************
	IF DO_FIG_1 GE 1 THEN BEGIN
; ********************************************
   IMAGE=READ_PNG('D:\IDL\IMAGES\map_nec_fig1_20030126.png',R,G,B)
   image = CONGRID(IMAGE,1200,1200)
   ; REMOVE GREY COAST (COLOR 34)
   OK=WHERE(IMAGE EQ 34) & IMAGE[OK] = 255
   PNGFILE=DIR_OUT+'Figure1.png'
   WRITE_PNG,PNGFILE,IMAGE,R,G,B
   FILES=PNGFILE & COLOR=1 & PAL='PAL_36'
   ps_image, files=FILES, color=COLOR,xoffset=xoffset,yoffset=yoffset,scale=scale,$
                   landscape=LANDSCAPE ,center=center,FULL=full,OUT_DIR=out_dir,BW=bw,GREY=grey,PAL=PAL, FLIP=flip,EPS=EPS

	ENDIF





; ********************************************
	IF DO_STATS_FREQ_COMBINE GE 1 THEN BEGIN
; ********************************************

		; EDIT SD_ANALYSES_COMPARE AND SET SWITCH DO_STATS_FREQ_COMBINE  =1
   SD_ANALYSES_COMPARE


;   COREL DRAW TO IMPORT 7 PS FILES AS 2400PIXELS WIDE
		; SAVE AS PNG THEN CONVERT TO PS
		; THEN EDIT COLORS
   TARGETS=DIR_OUT + 'SD_STATS_FREQ_PLOT_COMBINE_SEAWIFS_REPRO3_REPRO4_NEC_ALL_*.png'
   FILES = FILELIST(TARGETS)
   FOR _FILE = 0,N_ELEMENTS(FILES)-1 DO BEGIN
    AFILE = FILES(_FILE)
    IMAGE = READALL(AFILE)
    FN=PARSE_IT(AFILE)
    PNGFILE = DIR_MS+FN.FIRST_NAME+UL+'BW.png'
    OK=WHERE(IMAGE EQ 3) & IMAGE[OK]=255 & OK=WHERE(IMAGE NE 255) & IMAGE[OK] = 0
		PAL_36,R,G,B
    WRITE_PNG,PNGFILE,IMAGE,R,G,B
    COLOR=0 & pal='PAL_36' & BW=1
   	ps_image, files=PNGFILE, color=COLOR,xoffset=xoffset,yoffset=yoffset,scale=scale,$
                   landscape=LANDSCAPE ,center=center,FULL=full,OUT_DIR=out_dir,BW=bw,GREY=grey,PAL=PAL, FLIP=flip,EPS=eps
   ENDFOR
	ENDIF

; ********************************************
	IF DO_CHL_GREY EQ 1 THEN BEGIN
; ********************************************
	  DIR_IN = DIR_STATS_BROWSE
		CHL_FILE=DIR_IN+'SD_STATS_SEAWIFS_REPRO4_NARR_NEC_ALL_CHLOR_A_MEAN_GMEAN_LEG.png'
		IMAGE = READALL(CHL_FILE)

		IMAGE(5:340,670:990) = 252
		IMAGE(5:580,900:1020) = 252
		IMAGE(5:300,670:950) = 252

		TXT =  UNITS('CHLOR_A',/NAME,/NOUNITS)+'(mean)'
		IMAGE=MAP_ADD_TXT(IMAGE,0.03,0.75,TXT,CHARSIZE=4,COLOR=0)

		FRAME,3,image=IMAGE
		PAL_GREY_CHLOR_A ,R,G,B
		FN=PARSE_IT(chl_file)
		PNG_FILE = DIR_OUT + fn.first_name+'_GREY.PNG'
		WRITE_PNG,PNG_FILE,IMAGE,R,G,B
		FILES=PNG_FILE & COLOR=1 & PAL='PAL_GREY_CHLOR_A'
		ps_image, files=FILES, color=COLOR,xoffset=xoffset,yoffset=yoffset,scale=scale,$
                   landscape=LANDSCAPE ,center=center,FULL=full,OUT_DIR=out_dir,BW=bw,GREY=grey,PAL=PAL, FLIP=flip,EPS=eps
    png_file =  DIR_OUT + fn.first_name+'_GREY_X2.PNG'
    WRITE_PNG,PNG_FILE,IMAGE,R,G,B
    FILES=PNG_FILE & COLOR=1 & PAL='PAL_GREY_CHLOR_A'
    scale=2
		ps_image, files=FILES, color=COLOR,xoffset=xoffset,yoffset=yoffset,scale=scale,$
                   landscape=LANDSCAPE ,center=center,FULL=full,OUT_DIR=out_dir,BW=bw,GREY=grey,PAL=PAL, FLIP=flip,EPS=eps

	ENDIF



; ********************************************
	IF DO_CHL_RATIO_GREY GE 1 THEN BEGIN
; ********************************************
		DIR_IN = 'H:\METHODS\'
		RAT_FILE=DIR_IN+'SD_STATS_SEAWIFS_REPRO3_REPRO4_NARR_NEC_ALL_CHLOR_A_MEAN_RATIO_PAGE_3_1_LEG.PNG'
; 	THESE THREE IMAGES WERE WELDED WITH 2 SPACES
		RATIO_FILE=DIR_IN+'SD_STATS_SEAWIFS_REPRO3_REPRO4_NARR_NEC_ALL_CHLOR_A_MEAN_RATIO_PAGE_3_1_LEG.PNG'
		image = READALL(ratio_file)
		image   = image(2052:*,*)
		IMAGE(5:340,670:990) = 252
		IMAGE(5:470,850:1020) = 252

;		Replace the color bar
    LEG=COLOR_BAR_SCALE(PROD='RATIO_LIN',XTITLE='Ratio',BACKGROUND=252,CHARSIZE=3)

    im = IMAGE(0:1023,0:1023)
    IMAGE = IMAGE_WELD(IM,LEG)

		TXT =  UNITS('CHLOR_A',/NAME,/NOUNITS)+' !Dfourth reprocessing /!N!X'+'!C'+UNITS('CHLOR_A',/NAME,/NOUNITS)+' !Dthird reprocessing!N!X'
		IMAGE=MAP_ADD_TXT(IMAGE,0.03,0.78,TXT,CHARSIZE=4,COLOR=0)
		FRAME,3,image=image,COLOR=0


		;; USED TO MAKE PALETTE PAL_GREY_RATIO_B ... SHIFTED TO STR_ADDLE NUMBERS LIKE 1.0
		;; ZWIN &   PAL_GREY_RATIO ,R,G,B     &   N= -10 & R=SHIFT(R,N) & G=SHIFT(G,N) & B=SHIFT(B,N)  & WRITEPAL,NAME='PAL_GREY_RATIO_B',R,G,B & ZWIN
		PNG_FILE_RATIO = DIR_OUT + 'SD_STATS_SEAWIFS_REPRO3_REPRO4_NARR_NEC_ALL_CHLOR_A_MEAN_RATIO_LEG_GREY.PNG'
		;;PAL_GREY_RATIO,R,G,B
		PAL_GREY_RATIO_C, R,G,B
		WRITE_PNG,PNG_FILE_RATIO,IMAGE,R,G,B
		FILES=PNG_FILE_RATIO & COLOR=1 & PAL='PAL_GREY_RATIO_C'
		ps_image, files=FILES, color=COLOR,xoffset=xoffset,yoffset=yoffset,scale=scale,$
                   landscape=LANDSCAPE ,center=center,FULL=full,OUT_DIR=out_dir,BW=bw,GREY=grey,PAL=PAL, FLIP=flip,EPS=eps

  ENDIF


; ********************************************
	IF DO_PNEG_GREY GE 1 THEN BEGIN
; ********************************************
	 	DIR_IN = DIR_STATS_BROWSE
	 	ASTAT = 'PNEG'
	 	AMEANTYPE ='AMEAN'
	 	PAL='PAL_SW3'
	 	BKG_COLOR=255
	 	abyte = 96

		TARGETS=DIR_IN+'SD*ALL*'+ASTAT+'*.PNG'
		FA = FILE_ALL(TARGETS)
		BANDS =['NLW_412','NLW_443','NLW_490','NLW_670']
		BANDS=BANDS([0,1 ])
		METHODS = ['REPRO3','REPRO4']
		N_METHODS=N_ELEMENTS(METHODS)
		N_BANDS = N_ELEMENTS(BANDS)
		ALL_FILES = ''
		FOR _BAND = 0,N_BANDS-1 DO BEGIN
		  ABAND = BANDS(_BAND)
		  PAGE =''
		  FOR _METHOD = 0,N_METHODS-1 DO BEGIN
		  	abyte = abyte + 1 ; for panel letters
		    AMETHOD = METHODS(_METHOD)
		    OK = WHERE(FA.SENSOR EQ ASENSOR AND FA.MAP EQ AMAP AND FA.METHOD EQ AMETHOD AND FA.PERIOD EQ APERIOD AND FA.PROD EQ ABAND AND FA.STAT EQ ASTAT AND FA.MEANTYPE EQ AMEANTYPE,COUNT)
		    IF COUNT NE 1 THEN STOP
		    FILE=FA[OK].FULLNAME
		    IMAGE=READALL(FILE)
;				=====> blank out for new label
				IMAGE(5:340,670:990) = 252
				IMAGE(5:580,900:1020) = 252
				IMAGE(5:300,670:950) = 252

		    IF AMETHOD EQ 'REPRO3' THEN _AMETHOD = 'third!Creprocessing'
		  	IF AMETHOD EQ 'REPRO4' THEN _AMETHOD = 'fourth!Creprocessing'

		    _prod = ASTAT+STRMID(ABAND,4,3)
				txt = UNITS(_prod,/name,/nounits) + '!C'+ _AMETHOD
				IMAGE=MAP_ADD_TXT(IMAGE,0.025,0.70,TXT,CHARSIZE=5,COLOR=0)
;				=====> Add letter to identify panel
				aletter = STRING(BYTE(abyte))
		    IMAGE=map_add_txt(IMAGE, 0.03,0.78,aletter, charsize=6,color=0)

;				=====> ZERO PNEGS ARE BLACK SO CHANGE THEIR COLOR TO 255
				OK = WHERE(LANDMASK EQ 255 AND IMAGE EQ 0,COUNT)
				IF COUNT GE 1 THEN IMAGE[OK] = 255

				FRAME,3,image=IMAGE,COLOR=0

;				=====> Write out a junk file and provide name to all_files
        PNGFILE = DIR_OUT + 'JUNK_' + ALETTER+'.PNG'
        PAL_SW3,R,G,B
        WRITE_PNG,PNGFILE,IMAGE,R,G,B
		    ALL_FILES=[ALL_FILES,PNGFILE]
    ENDFOR ; METHODS

    PAL_GREY_RATIO_B, R,G,B

    ENDFOR ; BANDS
    ALL_FILES=ALL_FILES(1:*)

		PNGFILE=DIR_OUT+'JUNK.PNG'

    IMAGE_WELD_PAGE, FILES=ALL_FILES,COLS=N_METHODS,ROWS=N_BANDS,space=4,background=BKG_COLOR, PAL=PAL,PNGFILE=pngfile

		; NOW ADD LEGEND
    IMAGE = READALL(PNGFILE)
    LEG = COLOR_BAR_SCALE(PROD='PNEG',PAL=PAL,BACKGROUND= BKG_COLOR,METHOD=Amethod,/NAME,XTITLE=' % Negative Water-Leaving Radiance',TRIM=2,PX=1024,PY=110,CHARSIZE=2.5)
    IMAGE = IMAGE_WELD(IMAGE,LEG,	space=0,background=BKG_COLOR )

    PNG_FILE = DIR_OUT + 'SD_STATS_SEAWIFS_REPRO3_REPRO4_NARR_NEC_ALL_PRODS_PNEG_AMEAN_PAGE_'+NUM2STR(N_METHODS)+UL+NUM2STR(N_BANDS)+'.PNG'
		PAL_SW3,R,G,B
		FRAME,3,image=ratio
    WRITE_PNG,PNG_FILE,IMAGE,R,G,B

;   ======> Now make a postscript
   	 pal='PAL_GREY_PERCENT' & COLOR=1
		ps_image, files=PNG_FILE, color=COLOR,xoffset=xoffset,yoffset=yoffset,scale=scale,$
                   landscape=LANDSCAPE ,center=center,FULL=full,OUT_DIR=out_dir,BW=bw,GREY=grey,PAL=PAL, FLIP=flip,EPS=eps
  ENDIF


; ********************************************
; ********************************************
	IF DO_SAT_SHIP GE 1 THEN BEGIN
; ********************************************
; ********************************************
	 	DIR_IN = DIR_SAT_SHIP
	 	sat_product='Median SeaWiFS '

STOP ; CHANGE MAX_DATE IF REQUIRED

	 	MAX_DATE ='200211112359' ; TO FORCE REPRO4 TO SAME AS REPRO3
	 	MAX_JULIAN = DT_DATE2JULIAN(MAX_DATE) & MAX_JULIAN=MAX_JULIAN[0]

	 	PAL='PAL_SW3'
	 	BKG_COLOR=255
	 	abyte = 96
		FONT_TIMES
	 	;  TARGETS E.G. :  SD_SAT_SHIP_SEAWIFS_REPRO4_NARR_NEC.save
		TARGETS=DIR_IN+'SD_SAT_SHIP_SEAWIFS_REPRO'+'*'+'_NARR_NEC.save'
		FA = FILE_ALL(TARGETS)
		HELP, FA
		METHODS = ['REPRO3','REPRO4']
		N_METHODS=N_ELEMENTS(METHODS)

		IF KEYWORD_SET(EPS) THEN _EXT = '.eps' ELSE _ext = '.ps'
		PSFILE=DIR_OUT+'SD_SAT_SHIP_SEAWIFS_REPRO3_REPRO4_NARR_NEC_PAGE_2_1'+_ext

		PSPRINT,FILE=PSFILE,COLOR=0,/HALF,EPS=eps
		FONT_TIMES
		!P.MULTI=[0,N_METHODS,1]
		!X.THICK = 2
  	!Y.THICK = 2
  	!P.CHARTHICK=2
  	!X.MARGIN = [5,2]
  	!Y.OMARGIN=[6,7]
	  FONT_TIMES

;		LLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLL
		FOR _METHOD = 0,N_METHODS-1 DO BEGIN
		  AMETHOD = METHODS(_METHOD)
		  IF AMETHOD EQ 'REPRO3' THEN _AMETHOD = 'third reprocessing'
		  IF AMETHOD EQ 'REPRO4' THEN _AMETHOD = 'fourth reprocessing'

		  OK = WHERE(FA.SENSOR EQ ASENSOR AND FA.MAP EQ AMAP AND FA.METHOD EQ AMETHOD,COUNT)
		  IF COUNT NE 1 THEN STOP
		  FA_IN=FA[OK]

 ; 		=======> Get Ship Seawifs stat file
  		PRINT,'READING SAVE FILE: ' + FA_IN.FULLNAME
  		DB=READALL(FA_IN.FULLNAME)
  		DB.source = STRTRIM(DB.SOURCE,2)

 ; 		sat_product = DB(0).SAT_PRODUCT
  		JULIAN_SAT  = DT_SAT2JULIAN(DB.INAME)
  		JULIAN_SHIP = DT_DATE2JULIAN(DB.DATE_SHIP)

  		XTICKNAME=['0.1','1','10','64']
  		XTICKV   =['0.1','1','10','64']
  		YTICKNAME=['0.1','1','10','64']
  		YTICKV   =['0.1','1','10','64']

  		MAX_N = MAX(DB.N)   ; SHOULD BE 7X7 OR 49

  		PRINT, 'MAXIMUM NUMBER OF GOOD PIXELS: ' + NUM2STR(MAX_N)

  		inames=DB.iname & srt=SORT(inames) & inames=inames(srt)
			first_iname = first(inames) & last_iname = LAST(inames)
			first_date = DT_FMT(DT_SAT2JULIAN(first_iname),/MDY,/DAY)
			last_date = DT_FMT(DT_SAT2JULIAN(last_iname),/MDY,/DAY)

  		HEADING_1 =  aSENSOR + '(LAC)  Versus  in situ '
 		 	HEADING_2 = '!C' + _AMETHOD + '  -  ' + aMAP + '  -  ' + SAT_PRODUCT
			HEADING_3 = '!C'+'( '+first_date+' - '+last_date+' )'

;			****************************
; 		Plot NMFS .5 DAYS 11/49 GOOD
  		ASOURCE='NMFS'
  		DDAYS = [0.5]
  		GOOD  = [11]

; 		LLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLL
  		FOR I = 0,N_ELEMENTS(DDAYS)-1L DO BEGIN
    		COINCIDENCE = DDAYS(I)
;   		LLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLL
    		FOR J = 0,N_ELEMENTS(GOOD)-1L DO BEGIN
      		NGOOD = GOOD(J)
      		_coincidence= NUM2STR(coincidence,FORMAT='(F4.2)')+' Days, '
      		_fraction= NUM2STR(NGOOD) + '/' + NUM2STR(MAX_N) +' cloud-free pixels '

      		OK = WHERE(DB.SOURCE EQ ASOURCE AND $
                 ABS(JULIAN_SAT-jULIAN_SHIP) LE COINCIDENCE AND $
                 DB.N GE Ngood AND $
                 DB.MED_SAT_CHL/DB.SHIP_CHL LE 10 AND  DB.MED_SAT_CHL/DB.SHIP_CHL GE 1./10.0 AND $
                 JULIAN_SAT LE MAX_JULIAN,COUNT)
      		IF COUNT LT 2 THEN CONTINUE
      		;TITLE =  '(+- ' + _coincidence+ _fraction+')'
      		TITLE= _AMETHOD
      		TITLE=''

      		XTITLE= UNITS('in_situ',/NOPAREN) + ' '+ UNITS('CHLOR_A',/NAME)
      		YTITLE = SAT_PRODUCT + UNITS('CHLM3',/NAME)

      		PLOTXY, DB[OK].SHIP_CHL, DB[OK].MED_SAT_CHL, /LOGLOG,PARAMS=[1,2,3,4,8],DECIMALS=3,TITLE = TITLE,$
           PSYM=1,SYMSIZE=0.6,thick=2,XTITLE=xtitle , YTITLE=YTITLE,$
           xrange=[0.1,64],/xstyle, yrange=[0.1,64],/ystyle ,$
           /ONE2ONE,ONE_LINESTYLE=1,/MEAN_NONE,REG_THICK=5,REG_LINESTYLE=31,STATS_CHARSIZE=0.8, /ISOTROPIC

;					Add label
					abyte = abyte + 1 ; for panel letters
					aletter = STRING(BYTE(abyte))
					XYOUTS,0.07,80,/DATA,aletter,charsize=1.25


    		ENDFOR ;FOR J = 0,N_ELEMENTS(GOOD)-1L DO BEGIN
  		ENDFOR ;FOR I = 0,N_ELEMENTS(DDAYS)-1L DO BEGIN
    ENDFOR ; METHODS
    	HEADING_1 = 'SeaWiFS (LAC) Versus in situ (NMFS)'
  		HEADING = HEADING_1+HEADING_2+HEADING_3
  		;XYOUTS,0.5,0.99,/NORMAL,CHARSIZE=1.0,HEADING,align=0.5
  		;TXT="J.O'Reilly (NOAA), J.Yoder (URI), "
  		;Caption, txt
      PSPRINT
  ENDIF






; ********************************************
; ********************************************
	IF DO_COPY_FILES GE 1 THEN BEGIN
; ********************************************
; ********************************************


  LABEL = 'PLVol22_JOR_'
  IF KEYWORD_SET(EPS) THEN _EXT = '.eps' ELSE _ext = '.ps'
  FILES = [$
'H:\METHODS\Figure1',$
'H:\METHODS\SD_STATS_FREQ_PLOT_COMBINE_SEAWIFS_REPRO3_REPRO4_NEC_ALL_CHLOR_A',$

'H:\METHODS\SD_STATS_FREQ_PLOT_COMBINE_SEAWIFS_REPRO3_REPRO4_NEC_ALL_NLW_412',$
'H:\METHODS\SD_STATS_FREQ_PLOT_COMBINE_SEAWIFS_REPRO3_REPRO4_NEC_ALL_NLW_443',$
'H:\METHODS\SD_STATS_FREQ_PLOT_COMBINE_SEAWIFS_REPRO3_REPRO4_NEC_ALL_NLW_490',$
'H:\METHODS\SD_STATS_FREQ_PLOT_COMBINE_SEAWIFS_REPRO3_REPRO4_NEC_ALL_NLW_510',$
'H:\METHODS\SD_STATS_FREQ_PLOT_COMBINE_SEAWIFS_REPRO3_REPRO4_NEC_ALL_NLW_555',$
'H:\METHODS\SD_STATS_FREQ_PLOT_COMBINE_SEAWIFS_REPRO3_REPRO4_NEC_ALL_NLW_670',$

'H:\METHODS\SD_STATS_SEAWIFS_REPRO3_REPRO4_NARR_NEC_ALL_CHLOR_A_MEAN_RATIO_LEG_GREY',$
'H:\METHODS\SD_STATS_SEAWIFS_REPRO4_NARR_NEC_ALL_CHLOR_A_MEAN_GMEAN_LEG_GREY',$
'H:\METHODS\SD_STATS_SEAWIFS_REPRO3_REPRO4_NARR_NEC_ALL_PRODS_PNEG_AMEAN_PAGE_2_2',$
'H:\METHODS\SD_SAT_SHIP_SEAWIFS_REPRO3_REPRO4_NARR_NEC_PAGE_2_1' ]
FILES = FILES + _EXT
  FIG = 1 & sub=0
  FOR _file=0,N_ELEMENTS(FILES)-1 DO BEGIN

  	AFILE = FILES(_FILE)
  	fn=parse_it(afile)
  	IF STRPOS(AFILE,'SD_STATS_FREQ_PLOT') GE 0 THEN BEGIN
  	  sub = sub + 1
  		outfile = DIR_MS + LABEL + 'Fig_2_'+NUM2STR(sub)+'.'+FN.EXT
  		IF SUB EQ 6 THEN FIG=3
  	ENDIF ELSE BEGIN
  		outfile = DIR_MS + LABEL + 'Fig_' + NUM2STR(FIG)+'.'+FN.EXT
  		 FIG = FIG+ 1
    ENDELSE
  	print, outfile
   	FILE_COPY, AFILE,outfile,/OVERWRITE
  ENDFOR
ENDIF


 IF DO_FIG_2 EQ 1 THEN BEGIN
	TARGETS=DIR_MS + '*FIG_2*bit.png'

 	FILES = FILELIST(TARGETS)
   FOR _FILE = 0,N_ELEMENTS(FILES)-1 DO BEGIN
    AFILE = FILES(_FILE)
    IMAGE = READALL(AFILE)
    FN=PARSE_IT(AFILE)
    PNGFILE = DIR_MS+FN.FIRST_NAME+UL+'BW.png'
    OK=WHERE(IMAGE EQ 3) & IMAGE[OK]=255 & OK=WHERE(IMAGE NE 255) & IMAGE[OK] = 0
		PAL_36,R,G,B
    WRITE_PNG,PNGFILE,IMAGE,R,G,B
    COLOR=0 & pal='PAL_36' & BW=1
   	ps_image, files=PNGFILE, color=COLOR,xoffset=xoffset,yoffset=yoffset,scale=scale,$
                   landscape=LANDSCAPE ,center=center,FULL=full,OUT_DIR=out_dir,BW=bw,GREY=grey,PAL=PAL, FLIP=flip,EPS=eps
   ENDFOR
	ENDIF


















END
