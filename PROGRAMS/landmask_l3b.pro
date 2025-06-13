; $ID:	LANDMASK_L3B.PRO,	2020-07-08-15,	USER-KJWH	$
;+
; This Program Makes a LANDMASK for L3b  (and a mask that maskes out areas that are not sampled enough)
; SYNTAX:
; NOTES:
; HISTORY:
; Aug 17, 2003  td, read l3b stats NUM, write out MAP_OUT projection png, land is 252B, water is 255B
; Aug 18, 2003  jor, Min-num = 4: Must have atleast 4 samples for water
;               Make mask with 0=ocean, land=1, land color is grey, but byte value for land is 1
;               Write out an inspection png for the NUM
;-
; *************************************************************************

PRO LANDMASK_L3B,STATS_FILE=STATS_FILE,DIR_OUT=dir_out,DIR_DATA=DIR_DATA,MAP_OUT=MAP_OUT,PROD=PROD
  ROUTINE_NAME='LANDMASK_L3B.PRO'
  DIR_IDL='D:\IDL\PROGRAMS\'
  MAP_OUT=['ROBINSON']
  DIR_OUT='D:\IDL\IMAGES\'
  DIR_DATA='D:\IDL\DATA\'
  STATS_FILE='G:\seawifs\stats\!ALL-SEAWIFS-REPRO4-L3B-CHLOR_A-STATS.save'
  FN=PARSE_IT(STATS_FILE)
  PROD='CHLOR_A'
  BACKGROUND= 253B
  LANDCOLOR = 252B
  DASH=DELIMITER(/DASH)
  DO_NUM_CHECK = 0

  MIN_NUM = 2 ; MUST HAVE 2 OR MORE samples over the study to be considered water
  MIN_NUM = 1 ; MUST HAVE 2 OR MORE samples over the study to be considered water
  IF N_ELEMENTS(DIR_OUT) EQ 0 OR N_ELEMENTS(STATS_FILE) EQ 0 OR N_ELEMENTS(MAP_OUT) EQ 0 OR $
                                 N_ELEMENTS(DIR_DATA) EQ 0 THEN STOP
  IF N_ELEMENTS(PROD) EQ 0 THEN PROD='CHLOR_A'

  struct_sd_stats=readall(STATS_FILE)
  IF IDLTYPE(STRUCT_SD_STATS )  NE 'STRUCT' THEN GOTO,DONE
  NAMES = TAG_NAMES(STRUCT_SD_STATS)
  OK_PROD=WHERE(NAMES EQ PROD,COUNT_PROD)
  IF COUNT_PROD NE 1 THEN GOTO,DONE
  NUM=STRUCT_SD_STATS.(OK_PROD).NUM.IMAGE

  PX=1L & PY = 5940423L
  _PX=4096  & _PY=2048

  FOR N=0,N_ELEMENTS(MAP_OUT)-1L DO BEGIN
    AMAP=MAP_OUT(N)

;   ===> Get the Global Equidistant Array (4096 x 2048) of L3B bin assignments)
    MAP_BINS = READALL(DIR_DATA+'MAP_'+AMAP+'_BINS-'+'PXY_'+NUM2STR(_PX)+'_'+NUM2STR(_PY)+'.SAVE')
    OUT_MAP  = WHERE(MAP_BINS EQ 0,COUNT_OUT_MAP)

    IMAGE = NUM(MAP_BINS)

    OK_LAND=WHERE(IMAGE LE MIN_NUM AND MAP_BINS NE 0 ,COUNT_LAND)
STOP
    BIMAGE=BYTE(IMAGE) & BIMAGE(*,*) = 0b ; set all to not masked code initially
    IF COUNT_LAND GE 1 THEN BEGIN
      BIMAGE(OK_LAND)=1B
    ENDIF

;   ===> Write out a MASK FILE for this MAP
    PAL_36,R,G,B
;   ===> Keep binary data value 1 equal to 1 but make the r,g,b settings for 1b equal to a grey color
;       And r,g,b settings for 0b (not masked) equal to white
    R[0]=255 & G[0]=255 &B[0]=255
    R[1]=160 & G[1]=160 &B[1]=160
;    R(2)=132 & G(2)=132 &B(2)=132
    MASK_FILE = DIR_OUT+'MASK_LAND'+DASH+MAP_OUT+DASH+'PXY_'+NUM2STR(_PX)+'_'+NUM2STR(_PY)+'.PNG'
    WRITE_PNG,MASK_FILE,BIMAGE,R,G,B


    IF DO_NUM_CHECK EQ 0 THEN CONTINUE ; >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
    STEPS = INDGEN(6)*2
    FOR NTH = 0,N_ELEMENTS(STEPS)-1 DO BEGIN
      MIN_NUM = STEPS[NTH]
;   ===> Write out an image showing bytscaled num
    OK_LAND=WHERE(IMAGE LE MIN_NUM AND MAP_BINS NE 0 ,COUNT_LAND)
    PAL_SW3,R,G,B
    BIMAGE=SD_SCALES(IMAGE,PROD='NUM',/DATA2BIN)
    IF COUNT_LAND GE 1 THEN BEGIN
      BIMAGE(OK_LAND)=LANDCOLOR
    ENDIF
    IF COUNT_OUT_MAP GE 1 THEN BEGIN
      BIMAGE(OUT_MAP)=BACKGROUND
    ENDIF
    LEG   =COLOR_BAR_SCALE(PROD='NUM',XTITLE='Number',PX=1024,PY=140,CHARSIZE=4,GRACE=20,BACKGROUND=LANDCOLOR)
    BIMAGE(2000,0) = LEG
    PNGFILE =  DIR_IDL+FN.NAME+DASH+MAP_OUT+'-NUM-'+NUM2STR(MIN_NUM)+'.PNG'
    WRITE_PNG,PNGFILE,BIMAGE,R,G,B
    ENDFOR

  ENDFOR

  DONE:
END; #####################  End of Routine ################################
