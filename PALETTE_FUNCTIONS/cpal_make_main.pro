; $ID:	CPAL_MAKE_MAIN.PRO,	2021-04-15-10,	USER-KJWH	$
;#############################################################################################################
	PRO CPAL_MAKE_MAIN
	
;  PRO CPAL_MAKE_MAIN
;+
; NAME:
;		PALS_MAKE_MAIN
;
; PURPOSE: 
;   This is a "MAIN" program for making color palette programs
;
; CATEGORY:
;		Palette
;
; INPUTS: 
;   None
;		
; OPTIONAL INPUTS:
;		None	
;		
; KEYWORD PARAMETERS:
;		None

; OUTPUTS: 
;   A palette program
;	
; MODIFICATION HISTORY:
;			WRITTEN MAR 1,2013 J.O'REILLY
;			JUL 4,2014,JOR,ADDED SEVERAL STEPS
;			
;			JUL 8,2014,JOR ADDED STEP DO_SUBAREAS_PAL
;			AUG 4,2014,JOR ADDED STEP DO_UNEP_PAL
;     DEC 10,2015,JOR ADDED STEP DO_PAL_BATHY
;     JAN 04,2016,JOR ADDED STEP DO_PAL_TOPO
;     AUG 22, 2019 - KJWH: Added DO_PAL_RGB_FILE step to read in a .rgb file and create a new PAL
;			
;			
;#################################################################################
;
;
;-

SL = PATH_SEP()

;****************************
ROUTINE_NAME='CPAL_MAKE_MAIN'
;****************************

;SSSSS     SWITCHES     SSSSS
DO_PAL_BLUE_YELLOW_RED = ''
DO_PAL_RED_WHITE_BLUE = ''
DO_PAL_BATHY_RELIEF   = ''
DO_PAL_BYR            = ''
DO_PAL_CHL            = ''
DO_PAL_OCEAN          = ''
DO_PAL_NAVY_GOLD      = ''
DO_PAL_NAVY_GOLD_FULL = 'Y'
DO_SUBAREAS_PAL       = ''
DO_XPALETTE           = ''
DO_SW5                = ''
DO_WHITE_CENTERED_PAL = ''
DO_RWB_GREY_PAL       = ''
DO_ANOM_PAL           = ''
DO_GRAY_REVERSE_PAL   = ''
DO_UNEP_PAL           = ''
DO_PAL_INTERPOLATE    = ''
DO_PAL_RGB_FILE       = ''
DO_PAL_BATHY          = ''
DO_PAL_TOPO           = ''
DO_COLORTABLE_2PAL    = ''
DO_BLUE_RED           = ''
DO_NOAA               = ''

IF KEYWORD_SET(DO_PAL_BLUE_YELLOW_RED) THEN BEGIN
  PNAME = 'PAL_BLUE_YELLOW_RED'
  RGB = CPAL_READ('PAL_DEFAULT',R=PR,G=PG,B=PB)
  
  ; ===> Set up blank RGB arrays and add the grey at the end
  RR = INTARR(256) & RR(*)=-1 & GG = RR & BB = RR
  RR[0] = 0 & RR[251:255] = PR[251:255]
  GG[0] = 0 & GG[251:255] = PG[251:255]
  BB[0] = 0 & BB[251:255] = PB[251:255]

  ; ===> Add colors
  RR[1] = 36 & RR[62] = 157 & RR[125] = 254 & RR[187] = 241 & RR[250] = 157
  GG[1] = 34 & GG[62] = 203 & GG[125] = 255 & GG[187] = 112 & GG[250] = 21
  BB[1] = 96 & BB[62] = 225 & BB[125] = 193 & BB[187] = 74  & BB[250] = 41

  ; ===> Interpolate colors
  INTERVALS  = WHERE(RR NE -1)
  R = INTERPOL(RR[INTERVALS],INTERVALS,INDGEN(256))
  G = INTERPOL(GG[INTERVALS],INTERVALS,INDGEN(256))
  B = INTERPOL(BB[INTERVALS],INTERVALS,INDGEN(256))

  ; ===> View and save the new color palette
  TVLCT, R, G, B
  CPAL_COLORBOX,DELAY=5
  CPAL_WRITE,PNAME,R,G,B
  PFILE,PNAME
  PAL = CPAL_READ(PNAME)
  CPAL_VIEW,PNAME,DELAY=2

ENDIF

IF KEYWORD_SET(DO_PAL_RED_WHITE_BLUE) THEN BEGIN
  PNAME = 'PAL_RED_WHITE_BLUE'
  RGB = CPAL_READ('PAL_DEFAULT',R=PR,G=PG,B=PB)
  
  ; ===> Set up blank RGB arrays and add the grey at the end
  RR = INTARR(256) & RR(*)=-1 & GG = RR & BB = RR
  RR[0] = 0 & RR[251:255] = PR[251:255]
  GG[0] = 0 & GG[251:255] = PG[251:255]
  BB[0] = 0 & BB[251:255] = PB[251:255]

  ; ===> Add colors
  RR[1] = 96 & RR[31] = 185 & RR[62] = 227 & RR[94] = 250 & RR[125] = 246 & RR[156] = 194 & RR[187] = 113 & RR[219] = 51  & RR[250] = 13
  GG[1] = 8  & GG[31] = 50  & GG[62] = 133 & GG[94] = 206 & GG[125] = 246 & GG[156] = 219 & GG[187] = 171 & GG[219] = 110 & GG[250] = 44
  BB[1] = 30 & BB[31] = 55  & BB[62] = 107 & BB[94] = 183 & BB[125] = 246 & BB[156] = 234 & BB[187] = 207 & BB[219] = 175 & BB[250] = 92

  ; ===> Interpolate colors
  INTERVALS  = WHERE(RR NE -1)
  R = INTERPOL(RR[INTERVALS],INTERVALS,INDGEN(256))
  G = INTERPOL(GG[INTERVALS],INTERVALS,INDGEN(256))
  B = INTERPOL(BB[INTERVALS],INTERVALS,INDGEN(256))

  ; ===> View and save the new color palette
  TVLCT, R, G, B
  CPAL_COLORBOX,DELAY=5
  CPAL_WRITE,PNAME,R,G,B
  PFILE,PNAME
  PAL = CPAL_READ(PNAME)
  CPAL_VIEW,PNAME,DELAY=2

ENDIF

IF KEYWORD_SET(DO_PAL_BATHY_RELIEF) THEN BEGIN
  PNAME = 'PAL_BATHY_RELIEF'
  RGB = CPAL_READ('PAL_DEFAULT',R=PR,G=PG,B=PB)
  GMT = CPAL_READ('PAL_GMT_RELIEF_OCEANONLY', R=RO, G=GO, B=BO)
  
  ; ===> Set up blank RGB arrays and add the grey at the end
  RR = INTARR(256) & RR(*)=-1 & GG = RR & BB = RR
  RR[0] = 0 & RR[251:255] = PR[251:255]
  GG[0] = 0 & GG[251:255] = PG[251:255]
  BB[0] = 0 & BB[251:255] = PB[251:255]

  ; ===> Add colors
  RR[1:112] = RO[1:112] & RR[125] = RO[120] & RR[150] = RO[130] & RR[175] = RO[145] & RR[200] = RO[160] & RR[225] = RO[175] & RR[250] = RO[190]
  GG[1:112] = GO[1:112] & GG[125] = GO[120] & GG[150] = GO[130] & GG[175] = GO[145] & GG[200] = GO[160] & GG[225] = GO[175] & GG[250] = GO[190]
  BB[1:112] = BO[1:112] & BB[125] = BO[120] & BB[150] = BO[130] & BB[175] = BO[145] & BB[200] = BO[160] & BB[225] = BO[175] & BB[250] = BO[190]

  ; ===> Interpolate colors
  INTERVALS  = WHERE(RR NE -1)
  R = INTERPOL(RR[INTERVALS],INTERVALS,INDGEN(256))
  G = INTERPOL(GG[INTERVALS],INTERVALS,INDGEN(256))
  B = INTERPOL(BB[INTERVALS],INTERVALS,INDGEN(256))
  
  ; ===> View and save the new color palette
  TVLCT, R, G, B
  CPAL_COLORBOX,DELAY=5
  CPAL_WRITE,PNAME,R,G,B
  PFILE,PNAME
  PAL = CPAL_READ(PNAME)
  CPAL_COLORBOX,PNAME,DELAY=3,/OVERWRITE
  
ENDIF  

  
  
  IF KEYWORD_SET(DO_PAL_BYR) THEN BEGIN
    PNAME = 'PAL_BLUEYELLOWRED_DARK'
    RGB = CPAL_READ('PAL_DEFAULT',R=PR,G=PG,B=PB)

    
    ; ===> Set up blank RGB arrays and add the grey at the end
    RR = INTARR(256) & RR(*)=-1 & GG = RR & BB = RR
    RR[0] = 0 & RR[251:255] = PR[251:255]
    GG[0] = 0 & GG[251:255] = PG[251:255]
    BB[0] = 0 & BB[251:255] = PB[251:255]

    ; ===> Add colors
    RR[1] = 21  & RR[62] = 59  & RR[125] = 252 & RR[188] = 230 & RR[250] = 65
    GG[1] = 23  & GG[62] = 82  & GG[125] = 202 & GG[188] = 86 & GG[250] = 9
    BB[1] = 66  & BB[62] = 166 & BB[125] = 122 & BB[188] = 58 & BB[250] = 28
    
    ; ===> Interpolate colors
    INTERVALS  = WHERE(RR NE -1)
    R = INTERPOL(RR[INTERVALS],INTERVALS,INDGEN(256))
    G = INTERPOL(GG[INTERVALS],INTERVALS,INDGEN(256))
    B = INTERPOL(BB[INTERVALS],INTERVALS,INDGEN(256))
    
    ; ===> View and save the new color palette
    TVLCT, R, G, B
    CPAL_COLORBOX,DELAY=5
    CPAL_WRITE,PNAME,R,G,B
    PFILE,PNAME
    PAL = CPAL_READ(PNAME)
    
    
    
    PNAME = 'PAL_BLUEYELLOWRED'

    ; ===> Set up blank RGB arrays
    RR = INTARR(256) & RR(*)=-1 & GG = RR & BB = RR
    RR[0] = 0 & RR[251:255] = PR[251:255]
    GG[0] = 0 & GG[251:255] = PG[251:255]
    BB[0] = 0 & BB[251:255] = PB[251:255]

    ; ===> Add colors
    RR[1] = 50  & RR[62] = 59  & RR[125] = 252 & RR[188] = 230 & RR[250] = 162
    GG[1] = 46  & GG[62] = 82  & GG[125] = 202 & GG[188] = 86 & GG[250] = 36
    BB[1] = 139 & BB[62] = 166 & BB[125] = 122 & BB[188] = 58 & BB[250] = 29

    ; ===> Interpolate colors
    INTERVALS  = WHERE(RR NE -1)
    R = INTERPOL(RR[INTERVALS],INTERVALS,INDGEN(256))
    G = INTERPOL(GG[INTERVALS],INTERVALS,INDGEN(256))
    B = INTERPOL(BB[INTERVALS],INTERVALS,INDGEN(256))

    ; ===> View the new color palette
    TVLCT, R, G, B
    CPAL_COLORBOX,DELAY=5

    ; ===> Save the new color palette
    CPAL_WRITE,PNAME,R,G,B
    PFILE,PNAME
    PAL = CPAL_READ(PNAME)
    
    
    PNAME = 'PAL_BLUEYELLOWRED_LIGHT'

    ; ===> Set up blank RGB arrays
    RR = INTARR(256) & RR(*)=-1 & GG = RR & BB = RR
    RR[0] = 0 & RR[251:255] = PR[251:255]
    GG[0] = 0 & GG[251:255] = PG[251:255]
    BB[0] = 0 & BB[251:255] = PB[251:255]

    ; ===> Add colors
    RR[1] = 78  & RR[62] = 185  & RR[125] = 244 & RR[188] = 248 & RR[250] = 210
    GG[1] = 123 & GG[62] = 222  & GG[125] = 255 & GG[188] = 155 & GG[250] = 55
    BB[1] = 179 & BB[62] = 235  & BB[125] = 161 & BB[188] = 88  & BB[250] = 44

    ; ===> Interpolate colors
    INTERVALS  = WHERE(RR NE -1)
    R = INTERPOL(RR[INTERVALS],INTERVALS,INDGEN(256))
    G = INTERPOL(GG[INTERVALS],INTERVALS,INDGEN(256))
    B = INTERPOL(BB[INTERVALS],INTERVALS,INDGEN(256))

    ; ===> View the new color palette
    TVLCT, R, G, B
    CPAL_COLORBOX,DELAY=5

    ; ===> Save the new color palette
    CPAL_WRITE,PNAME,R,G,B
    PFILE,PNAME
    PAL = CPAL_READ(PNAME)
    
    
  ENDIF

  IF KEYWORD_SET(DO_NOAA) THEN BEGIN
    PNAME = 'PAL_NOAA'
    R = BYTARR(256) & R[*] = 255 & G = R & B = R
    CSV = CSV_READ(!S.IDL_PALETTES + 'CSV' + SL + 'NOAA_FISHERIES_BRAND_COLORS.csv')
    N = N_ELEMENTS(CSV)-1
    R[0:N] = CSV.R
    G[0:N] = CSV.G
    B[0:N] = CSV.B
    
    CPAL_WRITE,PNAME,R,G,B
    CPAL_VIEW,PNAME
    PFILE,PNAME
    PAL = CPAL_READ(PNAME)
  ENDIF

  IF KEY(DO_PAL_CHL) THEN BEGIN
    RGB = CPAL_READ('PAL_DEFAULT',R=R,G=G,B=B)

    ; ===> Set up blank RGB arrays
    RR = INTARR(256) & RR(*)=-1 & GG = RR & BB = RR
    
    RR[0] = 0 & RR[251:255] = R[251:255]
    GG[0] = 0 & GG[251:255] = G[251:255]
    BB[0] = 0 & BB[251:255] = B[251:255]
    
    RR[1] = 22  & RR[62] = 102 & RR[125] = 255 & RR[188] = 74 & RR[250] = 6
    GG[1] = 56  & GG[62] = 126 & GG[125] = 255 & GG[188] = 143 & GG[250] = 58 
    BB[1] = 141 & BB[62] = 172 & BB[125] = 255 & BB[188] = 79 & BB[250] = 18
    
    INTERVALS  = WHERE(RR NE -1)
    R = INTERPOL(RR[INTERVALS],INTERVALS,INDGEN(256))
    G = INTERPOL(GG[INTERVALS],INTERVALS,INDGEN(256))
    B = INTERPOL(BB[INTERVALS],INTERVALS,INDGEN(256))
    
    ; ===> View the new color palette
    TVLCT, R, G, B
    CPAL_COLORBOX,DELAY=1
    
    ; ===> Save the new color palette
    CPAL_WRITE,'pal_chlor',R,G,B

  ENDIF
  
  IF KEY(DO_PAL_OCEAN) THEN BEGIN
    RGB = CPAL_READ('PAL_OCEAN_RELIEF',R=R,G=G,B=B)

    ; ===> Set up blank RGB arrays
    RR = INTARR(256) & RR(*)=-1
    GG = RR
    BB = RR

    SCLR = 63
    ECLR = 191
    
    C=1
    FOR N=0, ECLR-SCLR-1 DO BEGIN
      RR[C] = R[SCLR+N]
      GG[C] = G[SCLR+N]
      BB[C] = B[SCLR+N]
      C = C+2
    ENDFOR
    RR[250] = R[ECLR]
    GG[250] = G[ECLR]
    BB[250] = B[ECLR]  
    
    RR[0] = 0 & RR[251:255] = R[251:255]
    GG[0] = 0 & GG[251:255] = G[251:255]
    BB[0] = 0 & BB[251:255] = B[251:255]

    INTERVALS  = WHERE(RR NE -1)
    R = INTERPOL(RR[INTERVALS],INTERVALS,INDGEN(256))
    G = INTERPOL(GG[INTERVALS],INTERVALS,INDGEN(256))
    B = INTERPOL(BB[INTERVALS],INTERVALS,INDGEN(256))

    ; ===> View the new color palette
    TVLCT, R, G, B
    CPAL_COLORBOX,DELAY=1

    ; ===> Save the new color palette
    CPAL_WRITE,'pal_ocean_dark',R,G,B
    CPAL_REVERSE, 'pal_ocean_dark'

  ENDIF
  
  IF KEY(DO_PAL_NAVY_GOLD) THEN BEGIN
    RGB = CPAL_READ('PAL_PARULA',R=R,G=G,B=B)

    ; ===> Set up blank RGB arrays
    RR = INTARR(256) & RR(*)=-1
    GG = RR
    BB = RR

    CLRS = INDGEN(15)*17
    SUBS = INDGEN(15)*18

    FOR N=1, N_ELEMENTS(CLRS)-1 DO BEGIN
      RR[SUBS[N]] = R[CLRS[N]]
      GG[SUBS[N]] = G[CLRS[N]]
      BB[SUBS[N]] = B[CLRS[N]]
    ENDFOR
    
    RR[0] = -1 & RR[1] = 4   & RR[248:250] = R[248:250]; & RR[251:255] = R[251:255]
    GG[0] = -1 & GG[1] = 47  & GG[248:250] = G[248:250]; & GG[251:255] = G[251:255]
    BB[0] = -1 & BB[1] = 102 & BB[248:250] = B[248:250]; & BB[251:255] = B[251:255]

    INTERVALS = WHERE(RR NE -1)
    R[1:250] = INTERPOL(RR[INTERVALS],INTERVALS,INDGEN(250))
    G[1:250] = INTERPOL(GG[INTERVALS],INTERVALS,INDGEN(250))
    B[1:250] = INTERPOL(BB[INTERVALS],INTERVALS,INDGEN(250))

    RR[0] = 0
    GG[0] = 0
    BB[0] = 0
    
    ; ===> View the new color palette
    TVLCT, R, G, B
    CPAL_COLORBOX,DELAY=3

    ; ===> Save the new color palette
    CPAL_WRITE,'pal_navy_gold',R,G,B
    CPAL_REVERSE, 'pal_navy_gold', outname='pal_gold_navy'
    
  ENDIF  
  
  IF KEY(DO_PAL_NAVY_GOLD_FULL) THEN BEGIN
    
    RGB = CPAL_READ('PAL_PARULA',R=R,G=G,B=B)

    ; ===> Set up blank RGB arrays
    RR = INTARR(256) & RR(*)=-1
    GG = RR
    BB = RR

    CLRS = INDGEN(15)*17
    SUBS = INDGEN(15)*18

    FOR N=1, N_ELEMENTS(CLRS)-1 DO BEGIN
      RR[SUBS[N]] = R[CLRS[N]]
      GG[SUBS[N]] = G[CLRS[N]]
      BB[SUBS[N]] = B[CLRS[N]]
    ENDFOR

    RR[0] = 4   & RR[255] = R[250]; & RR[251:255] = R[251:255]
    GG[0] = 47  & GG[255] = G[250]; & GG[251:255] = G[251:255]
    BB[0] = 102 & BB[255] = B[250]; & BB[251:255] = B[251:255]

    INTERVALS = WHERE(RR NE -1)
    R[0:255] = INTERPOL(RR[INTERVALS],INTERVALS,INDGEN(256))
    G[0:255] = INTERPOL(GG[INTERVALS],INTERVALS,INDGEN(256))
    B[0:255] = INTERPOL(BB[INTERVALS],INTERVALS,INDGEN(256))


    ; ===> View the new color palette
    TVLCT, R, G, B
    CPAL_COLORBOX,DELAY=3

    ; ===> Save the new color palette
    CPAL_WRITE,'pal_navy_gold_full',R,G,B
    CPAL_REVERSE, 'pal_navy_gold_full', outname='pal_gold_navy_full'
    

  ENDIF
  
  
;
;
;*****************************
IF KEY(DO_SUBAREAS_PAL) THEN BEGIN
  ;*****************************
  ;===>MAKE A SET OF VERY DISTINCT CONTRASTING COLORS
  COLORS = ['LIME','AQUA','GOLD','VIOLET']
 ; COLORS = ['RED','AQUA','SIENNA','VIOLET'];,'CHARTREUSE','GOLD','BLUE','GREEN','RED']
  I = ROUND(INTERVAL([0,255],N_ELEMENTS(COLORS)) + 1)
  RED   = BYTARR(256)
  GREEN = BYTARR(256)
  BLUE  = BYTARR(256)
  FOR NTH = 0,N_ELEMENTS(COLORS)-1 DO BEGIN
    COLOR = COLORS[NTH]
    RGB = RGBS(COLOR)
    PRINT,'COLOR:  ' ,COLOR,'    RGBS: ',RGB
    RED(I)  = RGB[0]
    GREEN(I) = RGB[1]
    BLUE(I) = RGB[2]
    I = I + 1
  ENDFOR;FOR NTH = 0,N_ELEMENTS(COLORS)-1 DO BEGIN
  ;FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF\
  ;===> REPLACE 250:255 WITH COLORS FROM PAL_SW3
  PAL_SW3,RR,GG,BB
  RED(250:*)= RR(250:*)
  GREEN(250:*)= GG(250:*)
  BLUE(250:*)= BB(250:*)
  NAME = 'SUBAREAS'
  CPAL_WRITE,NAME,RED,GREEN,BLUE
  FILE = 'PAL_' + NAME+ '.PRO'
  PFILE,FILE
  CPAL_VIEW,PAL=FILE
ENDIF;IF KEY(DO_SUBAREAS_PAL) THEN BEGIN
;|||||||||||||||||||||||||||||||||||



;*******************************
IF KEY(DO_XPALETTE) THEN BEGIN
;*******************************
PRINT,'EXAMPLE OF MAKING A BLOCK OF WHITE IN THE MIDDLE OF A PALETTE' 
;===> LOAD PAL_SW3
PAL_SW3,R,G,B
TVLCT,R,G,B
XPALETTE
STOP
ENDIF;IF KEY(DO_XPALETTE) THEN BEGIN
;|||||||||||||||||||||||||||||||||||


;*************************
IF KEY(DO_SW5) THEN BEGIN
;*************************
PRINT,'MAKE A NEW PAL PROGRAM BY MODIFYING  PAL_SW3' 
PAL_SW3,R,G,B
R(240:250) = 255
G(240:250) = 192
B(240:250) = 255
NAME = 'PAL_SW5'
CPAL_WRITE,NAME,R,G,B

ENDIF;IF KEY(DO_SW5) THEN BEGIN
;||||||||||||||||||||||||||||||
;
;
;
;
;
;
;
;
;
;************************************
IF KEY(DO_WHITE_CENTERED_PAL) THEN BEGIN
;************************************

INTERVALS  = [0,1,  20, 80, 100,105,145,170,195,250,251,252,253,254,255]
R = INTERPOL([0,0,  0,  51, 230,255,255,255,255,255,128,160,192,224,255],INTERVALS,INDGEN(256))
G = INTERPOL([0,255,191,0,  230,255,255,0,  153,255,128,160,192,224,255],INTERVALS,INDGEN(256))
B = INTERPOL([0,255,255,255,250,255,255,0,  18, 0,  128,160,192,224,255],INTERVALS,INDGEN(256))

PAL = BYTARR(3,N_ELEMENTS(R))
PAL(0,*) = R
PAL(1,*) = G
PAL(2,*) = B

PALLIST = LIST()
FOR I = 0, N_ELEMENTS(R)-1 DO PALLIST.ADD,REFORM(PAL[*,I])

W = WINDOW(DIMENSIONS=[800,800],LAYOUT=[2,1,1])
ARR    = FLTARR(200,200)
FOR I = 0, 199 DO ARR(*,I) = (0+(100/199.)*FINDGEN(200))            ; scale the array to 200 intervals ranging from 0 to 100 (adapted from the jhuapl routine maken)
X = [MIN(ARR),MAX(ARR)]
IM = IMAGE(ARR,/CURRENT,RGB_TABLE=PAL,LAYOUT=[2,1,1],TITLE='LINEAR')

CPAL_WRITE,'PAL_ANOMCY',R,G,B


ENDIF;IF KEY(DO_WHITE_CENTERED_PAL) THEN BEGIN
;||||||||||||||||||||||||||||||||||||||||||



;*********************************
IF KEY(DO_RWB_GREY_PAL) THEN BEGIN
;*********************************

  INTERVALS  = [0, 1,  110,140,250,251,252,253,254,255]
  R = INTERPOL([0, 0,  240,240,245,128,160,192,224,255],INTERVALS,INDGEN(256))
  G = INTERPOL([0, 0,  240,240,0,  128,160,192,224,255],INTERVALS,INDGEN(256))
  B = INTERPOL([0, 245,240,240,0,  128,160,192,224,255],INTERVALS,INDGEN(256))
  
  PAL = BYTARR(3,N_ELEMENTS(R))
  PAL(0,*) = R
  PAL(1,*) = G
  PAL(2,*) = B
  
  PALLIST = LIST()
  FOR I = 0, N_ELEMENTS(R)-1 DO PALLIST.ADD,REFORM(PAL[*,I])
  
  W = WINDOW(DIMENSIONS=[800,800],LAYOUT=[2,1,1])
  ARR    = FLTARR(200,200)
  FOR I = 0, 199 DO ARR(*,I) = (0+(100/199.)*FINDGEN(200))            ; scale the array to 200 intervals ranging from 0 to 100 (adapted from the jhuapl routine maken)
  X = [MIN(ARR),MAX(ARR)]
  IM = IMAGE(ARR,/CURRENT,RGB_TABLE=PAL,LAYOUT=[2,1,1],TITLE='LINEAR')
  
  CPAL_WRITE,'pal_anom_rgb',R,G,B
  
  
ENDIF;IF KEY(DO_RWB_GREY_PAL) THEN BEGIN
;||||||||||||||||||||||||||||||||||||
;
;*****************************
IF KEY(DO_ANOM_PAL) THEN BEGIN
;*****************************

INTERVALS  = [0, 1,   25, 50, 75,100,110,115,135,140,150,160,175,200,225,250,251,252,253,254,255]
R = INTERPOL([0, 132, 75, 12,  0,  0,  0,236,236,233,255,255,255,255,255,255,128,160,192,224,255],INTERVALS,INDGEN(256))
G = INTERPOL([0, 0,    0,  0,125,239,255,236,236,255,234,202,150, 70,  0,  0,128,160,192,224,255],INTERVALS,INDGEN(256))
B = INTERPOL([0, 124,181,244,255,255,221,236,236,  0,  0,  0,  0,  0, 23,255,128,160,192,224,255],INTERVALS,INDGEN(256))

PAL = BYTARR(3,N_ELEMENTS(R))
PAL(0,*) = R
PAL(1,*) = G
PAL(2,*) = B

PALLIST = LIST()
FOR I = 0, N_ELEMENTS(R)-1 DO PALLIST.ADD,REFORM(PAL[*,I])

W = WINDOW(DIMENSIONS=[800,800],LAYOUT=[2,1,1])
ARR    = FLTARR(200,200)
FOR I = 0, 199 DO ARR(*,I) = (0+(100/199.)*FINDGEN(200))            ; scale the array to 200 intervals ranging from 0 to 100 (adapted from the jhuapl routine maken)
X = [MIN(ARR),MAX(ARR)]
IM = IMAGE(ARR,/CURRENT,RGB_TABLE=PAL,LAYOUT=[2,1,1],TITLE='LINEAR')

CPAL_WRITE,'pal_anomg',R,G,B
FILE_DOC,'pal_anomg'

IM.CLOSE
ENDIF;IF KEY(DO_ANOM_PAL) THEN BEGIN
;||||||||||||||||||||||||||||||||
;
;*************************************
IF KEY(DO_GRAY_REVERSE_PAL) THEN BEGIN
;*************************************
; PAL_GRAY_IDL,R,G,B
PAL_GRAY,R,G,B
RR = REVERSE(R)
GG = REVERSE(G)
BB = REVERSE(B)

I = [0,251,252,253,254,255]
C = [0,128,160,192,224,255]

FOR N=0, N_ELEMENTS(I)-1 DO BEGIN
  RR[I[N]] = C(N)
  GG[I[N]] = C(N)
  BB[I[N]] = C(N)
ENDFOR

PAL = BYTARR(3,N_ELEMENTS(RR))
PAL(0,*) = RR
PAL(1,*) = GG
PAL(2,*) = BB

W = WINDOW(DIMENSIONS=[800,800],LAYOUT=[2,1,1])
ARR    = FLTARR(200,200)
FOR I = 0, 199 DO ARR(*,I) = (0+(100/199.)*FINDGEN(200))            ; scale the array to 200 intervals ranging from 0 to 100 (adapted from the jhuapl routine maken)
X = [MIN(ARR),MAX(ARR)]
IM = IMAGE(ARR,/CURRENT,RGB_TABLE=PAL,LAYOUT=[2,1,1],TITLE='LINEAR')

CPAL_WRITE,'pal_gray_reverse',RR,GG,BB
FILE_DOC,'pal_gray_reverse'
IM.CLOSE
ENDIF;IF KEY(DO_GRAY_REVERSE_PAL) THEN BEGIN
;|||||||||||||||||||||||||||||||||||||||||||
;
;
;*******************************
IF KEY(DO_UNEP_PAL) THEN BEGIN
;*******************************
;
  R = REPLICATE(255B,256) & G=R & B=R
  
  ;Highest risk: level 5
  ;RGB 216 35 42
  R(5) = 216 & G(5) = 35 & B(5) = 42
  ;Moderately high risk: level 4
  ;RGB 238 159 66
  R(4) = 238 & G(4) = 159 & B(4) = 66
  ;Medium risk: level 3
  ;RGB 228 227 68
  R(3) = 228 & G(3) = 227 & B(3) = 68
  ;Moderately low risk: level 2
  ;RGB 120 187 75
  R(2) = 120 & G(2) = 187 & B(2) = 75
  ;Lowest risk: level 1
  ;RGB 95 186 221
  R[1] = 95 & G[1] = 186 & B[1] = 221
  ;Insufficient data: no data
  ;CMJK 0 0 0 20
  R[0] = 0 & G[0] = 0 & B[0] = 0 
  
  CPAL_WRITE,'UNEP',R,G,B
  CPAL_VIEW,PAL='PAL_UNEP'
ENDIF;IF KEY(DO_UNEP_PAL) THEN BEGIN
;|||||||||||||||||||||||||||||||||||
;
;***************************
  IF KEY(DO_PAL_INTERPOLATE) THEN BEGIN
;***************************
  PALNAME = 'PAL_DEFAULT'
  
  ; ===> Set up blank RGB arrays
  RR = INTARR(256) & RR(*)=-1
  GG = RR
  BB = RR
  
  BR = CPAL_READ('pal_br')
  GM = CPAL_READ('pal_gmt_no_green')
  
  BSUBS = LIST(BR(*,1),BR(*,10),BR(*,20),BR(*,30),BR(*,40),GM(*,1),GM(*,10),GM(*,25),GM(*,40),GM(*,55),GM(*,70),GM(*,85),GM(*,100))
  I = ROUND(INTERVAL([1,100],ROUND(100./N_ELEMENTS(BSUBS))))
  FOR N=0, N_ELEMENTS(I)-1 DO BEGIN
    SUBS = BSUBS(N)
    RR[I[N]] = SUBS[0]
    GG[I[N]] = SUBS[1]
    BB[I[N]] = SUBS[2]  
  ENDFOR
  
  RR(101:200) = GM(0,101:200)
  GG(101:200) = GM(1,101:200)
  BB(101:200) = GM(2,101:200)
  
  RSUBS = LIST(GM(*,205),GM(*,220),GM(*,235),GM(*,250),BR(*,220),BR(*,230),BR(*,240),BR(*,250))
  I = ROUND(INTERVAL([201,250],ROUND(52./N_ELEMENTS(RSUBS))))
  FOR N=0, N_ELEMENTS(I)-1 DO BEGIN
    SUBS = RSUBS(N)
    RR[I[N]] = SUBS[0]
    GG[I[N]] = SUBS[1]
    BB[I[N]] = SUBS[2]
  ENDFOR
  
  SUBS = [0,251,252,253,254,255]
  CLRS = [0,128,160,192,224,255]
  FOR S=0, N_ELEMENTS(SUBS)-1 DO BEGIN
    RR[SUBS[S]] = CLRS[S]
    GG[SUBS[S]] = CLRS[S]
    BB[SUBS[S]] = CLRS[S]
  ENDFOR
  MAXCLR = 250
  STRCLR = 1  
  
  INTERVALS  = WHERE(RR NE -1)
  R = INTERPOL(RR(INTERVALS),INTERVALS,INDGEN(256))
  G = INTERPOL(GG(INTERVALS),INTERVALS,INDGEN(256))
  B = INTERPOL(BB(INTERVALS),INTERVALS,INDGEN(256))
  
  PAL = BYTARR(3,N_ELEMENTS(R))
  PAL(0,*) = R
  PAL(1,*) = G
  PAL(2,*) = B
  
  PALLIST = LIST()
  FOR I = 0, N_ELEMENTS(R)-1 DO PALLIST.ADD,REFORM(PAL[*,I])
  
  W = WINDOW(DIMENSIONS=[800,800],LAYOUT=[2,1,1])
  ARR    = FLTARR(200,200)
  FOR I = 0, 199 DO ARR(*,I) = (0+(100/199.)*FINDGEN(200))            ; scale the array to 200 intervals ranging from 0 to 100 (adapted from the jhuapl routine maken)
  X = [MIN(ARR),MAX(ARR)]
  IM = IMAGE(ARR,/CURRENT,RGB_TABLE=PAL,LAYOUT=[2,1,1],TITLE='LINEAR')
  
  CPAL_WRITE, PALNAME, R,G,B
  CPAL_VIEW, PALNAME
  FILE_DOC, PALNAME
    
  IM.CLOSE


  ENDIF;IF KEY(DO_PAL_BR) THEN BEGIN



  ;*************************************
  IF KEY(DO_PAL_RGB_FILE) THEN BEGIN
  ;*************************************
    SWITCHES,DO_PAL_RGB_FILE,STOPP=STOPP,OVERWRITE=OVERWRITE,VERBOSE=VERBOSE,INIT=INIT,R_FILES=R_FILES,R_DATASETS=R_DATASETS,R_MAPS=R_MAPS,R_PRODS=R_PRODS,DATERANGE=DATERANGE
    IF STOPP THEN STOP
    
    PAL_FILES = FLS(!S.IDL_PALETTES + '*.rgb') & help, PAL_FILES
  
    FOR I=0, N_ELEMENTS(PAL_FILES)-1 DO BEGIN
      GRAY_FILL = 1 ; DEFAULT
      SKIP = 0
      PNAME = ''
      FP = FILE_PARSE(PAL_FILES(I))
      CASE FP.NAME OF
        'RGB_gray':     BEGIN & PNAME = 'PAL_GRAY2'    & GRAY_FILL=0 & END
        'GMT_gray':     BEGIN & PNAME = 'PAL_GMT_GRAY' & GRAY_FILL=0 & END
        'BlueDarkOrange18': PNAME = 'PAL_BLUE_ORANGE'
        'GMT_no_green':     PNAME = 'PAL_GMT_NO_GREEN'
        'NCV_blu_red': BEGIN & PNAME = 'PAL_BLUERED' & END
        ELSE: SKIP = 1
      ENDCASE
      
      IF FILE_MAKE(FP.FULLNAME, !S.PALETTE_FUNCTIONS + STRLOWCASE(PNAME) + '.pro',OVERWRITE=OVERWRITE) EQ 0 OR KEY(SKIP) THEN CONTINUE

      ; ===> Set up blank RGB arrays
      RR = INTARR(256) & RR(*)=-1
      GG = RR
      BB = RR
      
      ; ===> Fill in the beginning (0=black) and end (250-255=shades of gray) of the new palette
      IF KEY(GRAY_FILL) THEN BEGIN
        SUBS = [0,251,252,253,254,255]
        CLRS = [0,128,160,192,224,255]
        FOR S=0, N_ELEMENTS(SUBS)-1 DO BEGIN
          RR[SUBS[S]] = CLRS[S]
          GG[SUBS[S]] = CLRS[S]
          BB[SUBS[S]] = CLRS[S]
        ENDFOR
        MAXCLR = 250
        STRCLR = 1
      ENDIF ELSE BEGIN
        MAXCLR = 255
        STRCLR = 0
      ENDELSE
    
    ; ===> Read the rgb palette
    PAL = READ_DELIMITED(FP.FULLNAME, DELIM = ' ')
    
    ; ===> If the palette is not a full 256 array, interpolate between colors
    IF N_ELEMENTS(PAL) LT 256 THEN BEGIN
      STEP = FLOAT(MAXCLR)/N_ELEMENTS(PAL)
      CT = STRCLR
      FOR N=0, N_ELEMENTS(PAL.R)-2 DO BEGIN
        C = ROUND(CT)
        CT = CT + STEP
        IF CT GT MAXCLR THEN CONTINUE
        IF PAL(N).R LE 1.0 THEN RR(C) = ROUND(PAL(N).R*255.) ELSE RR(C) = PAL(N).R & IF RR(C) GT 255 THEN RR(C) = 255
        IF PAL(N).G LE 1.0 THEN GG(C) = ROUND(PAL(N).G*255.) ELSE GG(C) = PAL(N).G & IF GG(C) GT 255 THEN GG(C) = 255
        IF PAL(N).B LE 1.0 THEN BB(C) = ROUND(PAL(N).B*255.) ELSE BB(C) = PAL(N).B & IF BB(C) GT 255 THEN BB(C) = 255  
      ENDFOR
      IF PAL(N).R LE 1.0 THEN RR(MAXCLR) = ROUND(PAL(N).R*255.) ELSE RR(MAXCLR) = PAL(N).R 
      IF PAL(N).G LE 1.0 THEN GG(MAXCLR) = ROUND(PAL(N).G*255.) ELSE GG(MAXCLR) = PAL(N).G 
      IF PAL(N).B LE 1.0 THEN BB(MAXCLR) = ROUND(PAL(N).B*255.) ELSE BB(MAXCLR) = PAL(N).B 

      INTERVALS  = WHERE(RR NE -1)
      R = INTERPOL(RR(INTERVALS),INTERVALS,INDGEN(256))
      G = INTERPOL(GG(INTERVALS),INTERVALS,INDGEN(256))
      B = INTERPOL(BB(INTERVALS),INTERVALS,INDGEN(256))
      CPAL_WRITE,PNAME,R,G,B

    ENDIF ELSE BEGIN  
      RR(STRCLR:MAXCLR) = PAL(STRCLR:MAXCLR).R
      GG(STRCLR:MAXCLR) = PAL(STRCLR:MAXCLR).G
      BB(STRCLR:MAXCLR) = PAL(STRCLR:MAXCLR).B
      CPAL_WRITE,PNAME,RR,GG,BB

    ENDELSE
      
    CPAL_VIEW,PNAME
    PFILE,PNAME
    PAL = CPAL_READ(PNAME)
  stop  
    ENDFOR
    
    
    
  
  ENDIF ; DO_PAL_RGB_FILE

;*************************************
IF KEY(DO_PAL_BATHY) THEN BEGIN
;*************************************
  SWITCHES,DO_PAL_BATHY,STOPP=STOPP,OVERWRITE=OVERWRITE,VERBOSE=VERBOSE,INIT=INIT,R_FILES=R_FILES,R_DATASETS=R_DATASETS,R_MAPS=R_MAPS,R_PRODS=R_PRODS,DATERANGE=DATERANGE
  IF STOPP THEN STOP 
  
  PAL_BR,R,G,B
  RR = INTARR(256) & RR(*)=-1
  GG = RR
  BB = RR
  RR[0] = 0
  GG[0] = 0
  BB[0] = 0
  RR[1] = 255
  GG[1] = 255
  BB[1] = 255
  RR(251:255) = R(251:255)
  GG(251:255) = G(251:255)
  BB(251:255) = B(251:255)
  PAL = READ_DELIMITED(!S.IDL + 'PALETTES/cmocean_deep.txt', DELIM = ' ')
  RR(1:250) = PAL(1:250).R
  GG(1:250) = PAL(1:250).G
  BB(1:250) = PAL(1:250).B
  CPAL_WRITE,'PAL_OCEAN',RR,GG,BB
  CPAL_VIEW,'PAL_OCEAN'
  PFILE,'PAL_OCEAN'
  
  
  PAL_BR,R,G,B
  RR = INTARR(256) & RR(*)=-1
  GG = RR
  BB = RR
  RR[0] = 0
  GG[0] = 0
  BB[0] = 0
  RR[1] = 255
  GG[1] = 255
  BB[1] = 255
  RR(251:255) = R(251:255)
  GG(251:255) = G(251:255)
  BB(251:255) = B(251:255)
  
  GMT = READ_DELIMITED(!S.IDL + 'PALETTES/GMT_relief_oceanonly.txt',DELIM=' ')
  R = REVERSE(GMT.R)
  G = REVERSE(GMT.G)
  B = REVERSE(GMT.B)
  
  CT = 2
  FOR N=0, N_ELEMENTS(GMT)-5 DO BEGIN
    C = ROUND(CT)
    RR(C) = ROUND(R(N)*256.) & IF RR(C) GT 255 THEN RR(C) = 255
    GG(C) = ROUND(G(N)*256.) & IF GG(C) GT 255 THEN GG(C) = 255
    BB(C) = ROUND(B(N)*256.) & IF BB(C) GT 255 THEN BB(C) = 255
    CT = CT + 3.25
    IF CT GT 250 THEN STOP
  ENDFOR
  
  INTERVALS  = WHERE(RR NE -1)
  R = INTERPOL(RR(INTERVALS),INTERVALS,INDGEN(256))
  G = INTERPOL(GG(INTERVALS),INTERVALS,INDGEN(256))
  B = INTERPOL(BB(INTERVALS),INTERVALS,INDGEN(256))

  CPAL_WRITE,'PAL_GMT_RELIEF_OCEANONLY',R,G,B
  CPAL_VIEW,'PAL_GMT_RELIEF_OCEANONLY'
  PFILE,'PAL_GMT_RELIEF_OCEANONLY'



  PAL_BR,R,G,B
  RR = REVERSE(R)
  GG = REVERSE(G)
  BB = REVERSE(B)
  RR[0] = 0
  GG[0] = 0
  BB[0] = 0
  RR(251:255) = R(251:255)
  GG(251:255) = G(251:255)
  BB(251:255) = B(251:255)
  RR(1:4) = REVERSE(R(247:250))
  GG(1:4) = REVERSE(G(247:250))
  BB(1:4) = REVERSE(B(247:250))

  CPAL_WRITE,'PAL_BATHY',RR,GG,BB
  PFILE,'PAL_BATHY'
  
  
  
ENDIF;IF KEY(DO_PAL_BATHY) THEN BEGIN
;|||||||||||||||||||||||||||||||||||||||||||
;

;*************************************
IF KEY(DO_PAL_TOPO) THEN BEGIN
  ;*************************************
  SWITCHES,DO_PAL_TOPO,STOPP=STOPP,OVERWRITE=OVERWRITE,VERBOSE=VERBOSE,INIT=INIT,R_FILES=R_FILES,R_DATASETS=R_DATASETS,R_MAPS=R_MAPS,R_PRODS=R_PRODS,DATERANGE=DATERANGE
  IF STOPP THEN STOP
  
  ;===> GET PAL_BATHY
  PAL_BATHY,R,G,B
  ;===> REVERSE
  R=REVERSE(R)
  G=REVERSE(G)
  B=REVERSE(B)
  ;===> SUBSAMPLE
 
  H,R,G,B
  RR = R & BB = B & GG = G
  IF STOPP THEN STOP

  ;===> GET THE R,G,B FROM ELEVATION.PNG
;  FILE = !S.IMAGES +"ELEVATION.PNG"
;  IMG = READ_IMAGE(FILE,R,G,B)
;  H,IMG
;  H,R,G,B
  ;===> GET R,G,B FROM EDITED PAL_ELEVATION
  PAL_ELEVATION,R,G,B
  ;===> SUBSAMPLE
 
  H,R,G,B
  PRINT
  ;===> CONCATENATE
  RR = [RR,R]
  GG = [GG,G]
  BB = [BB,B];INTERPX, X,Y,XX
  RR = REBIN(RR,256)
  GG = REBIN(GG,256)
  BB = REBIN(BB,256)
  H,RR,GG,BB
  IF STOPP THEN STOP
  ;===> WRITE THE TOPO PAL
  CPAL_WRITE,'TOPO',RR,GG,BB
  ;===> VIEW THE PAL_TOPO
  CPAL_VIEW,'PAL_TOPO'
  PRODS_COLORBAR,'TOPO',PAL='PAL_TOPO', FONT_SIZE=8
  ;===> US_ECO
  MAPP = 'SMI'
  TOPO_VIEW,MAPP,PROD = 'TOPO',PAL = 'PAL_TOPO',BUFFER = 0
  IF STOPP THEN STOP
  
  
  
  
  
  
  
  IMG_TRUE_2_8BIT,FILE,FILE_OUT=FILE_OUT
  IMG = READ_IMAGE(FILE_OUT,R,G,B) & H,R,G,B

  CPAL_WRITE,'PAL_TOPO',R,G,B
  PFILE,'PAL_TOPO'
  CPAL_VIEW,'PAL_TOPO',/PNG
ENDIF;IF KEY(DO_PAL_TOPO) THEN BEGIN


IF DO_COLORTABLE_2PAL GE 1 THEN BEGIN

  LOADCT, 3,  RGB_TABLE=RGB
  R = RGB[*,0]
  G = RGB[*,1]
  B = RGB[*,2]
  CPAL_WRITE, 'RED_TEMP', R,G,B

ENDIF

;*****************************
IF DO_BLUE_RED GE 1 THEN BEGIN
  ;*****************************

  RGB = CPAL_READ('PAL_BLUE_RED')
  
  RR = RGB[0,*]
  GG = RGB[1,*]
  BB = RGB[2,*]

  R = [RR[0:84],INTERPOL([RGB[0,85],236,RGB[0,165]],[0,40,80],INDGEN(81)),RR[166:255]]


  R = [RR[0:120],INTERPOL([RGB[0,121],RGB[0,125],RGB[0,130]],[0,5,10],INDGEN(10)),RR[130:255]]
  G = [GG[0:120],INTERPOL([RGB[1,121],RGB[1,125],RGB[1,130]],[0,5,10],INDGEN(10)),GG[130:255]]
  B = [BB[0:120],INTERPOL([RGB[2,121],RGB[2,125],RGB[2,130]],[0,5,10],INDGEN(10)),BB[130:255]]

  CPAL_WRITE,'pal_bluered',R,G,B
  FILE_DOC,'pal_bluered'
  CPAL_VIEW,'pal_bluered'
  
  
  STOP
  
  RGB = READ_DELIMITED(!S.IDL + 'PALETTES/NCV_blu_red.rgb',DELIM=',',/NOHEADING)

  I = [0, 1, 16, 30, 45, 59, 74, 89, 103, 118, 132, 147, 162, 176, 191, 205, 220, 235, 250, 251, 252, 253, 254, 255]
  R = [0, FIX(RGB.(0)), 96, 128, 160, 192, 255]
  G = [0, FIX(RGB.(1)), 96, 128, 160, 192, 255]
  B = [0, FIX(RGB.(2)), 96, 128, 160, 192, 255]

  RR = INTERPOL(R,I,INDGEN(256))
  GG = INTERPOL(G,I,INDGEN(256))
  BB = INTERPOL(B,I,INDGEN(256))

  PAL = BYTARR(3,256)
  PAL(0,*) = RR
  PAL(1,*) = GG
  PAL(2,*) = BB

  ARR    = FLTARR(200,200)
  FOR I = 0, 199 DO ARR(*,I) = (0+(100/199.)*FINDGEN(200))            ; scale the array to 200 intervals ranging from 0 to 100 (adapted from the jhuapl routine maken)
  X = [MIN(ARR),MAX(ARR)]
  IM = IMAGE(ARR,/CURRENT,RGB_TABLE=PAL,TITLE='LINEAR')
  CPAL_WRITE,'pal_blue_red',RR,GG,BB
  FILE_DOC,'pal_blue_red'

  IM.CLOSE

  STOP
  
  
  RGB = CPAL_READ('PAL_BR')
  IF EXISTS(!S.PROGRAMS + 'pal_anom_bgr.pro') THEN FILE_DELETE, !S.PROGRAMS + 'pal_anom_bgr.pro'

  RR = RGB[0,*]
  GG = RGB[1,*]
  BB = RGB[2,*]

  R = [RR[0:84],INTERPOL([RGB[0,85],236,RGB[0,165]],[0,40,80],INDGEN(81)),RR[166:255]]
  G = [GG[0:84],INTERPOL([RGB[1,85],236,RGB[1,165]],[0,40,80],INDGEN(81)),GG[166:255]]
  B = [BB[0:84],INTERPOL([RGB[2,85],236,RGB[2,165]],[0,40,80],INDGEN(81)),BB[166:255]]

  CPAL_WRITE,'pal_anom_bgr',R,G,B
  FILE_DOC,'pal_anom_bgr'
  CPAL_VIEW,'pal_anom_bgr'


  STOP



  RGB = READ_DELIMITED(!S.IDL + 'PALETTES/BlueDarkRed18.txt',DELIM=',',/NOHEADING)

  I = [0, 1, 16, 30, 45, 59, 74, 89, 103, 118, 132, 147, 162, 176, 191, 205, 220, 235, 250, 251, 252, 253, 254, 255]
  R = [0, FIX(RGB.(0)), 96, 128, 160, 192, 255]
  G = [0, FIX(RGB.(1)), 96, 128, 160, 192, 255]
  B = [0, FIX(RGB.(2)), 96, 128, 160, 192, 255]

  RR = INTERPOL(R,I,INDGEN(256))
  GG = INTERPOL(G,I,INDGEN(256))
  BB = INTERPOL(B,I,INDGEN(256))

  PAL = BYTARR(3,256)
  PAL(0,*) = RR
  PAL(1,*) = GG
  PAL(2,*) = BB

  ARR    = FLTARR(200,200)
  FOR I = 0, 199 DO ARR(*,I) = (0+(100/199.)*FINDGEN(200))            ; scale the array to 200 intervals ranging from 0 to 100 (adapted from the jhuapl routine maken)
  X = [MIN(ARR),MAX(ARR)]
  IM = IMAGE(ARR,/CURRENT,RGB_TABLE=PAL,TITLE='LINEAR')
  CPAL_WRITE,'pal_blue_red',RR,GG,BB
  FILE_DOC,'pal_blue_red'

  IM.CLOSE

  STOP

  RGB = READ_DELIMITED(!S.IDL + 'PALETTES/panoply_default.csv',DELIM=',',/NOHEADING)
  RGB = STRUCT_2FIX(RGB)

  B = [0, 1, 20]
  E = [240, 250, 251, 252, 253, 255]
  I = [0,   1,  20, 240, 250, 251, 252, 253, 254, 255]
  R = [0,   0,  14, 218, 120,  96, 128, 160, 192, 255]
  G = [0,   0,   3,  50,   0,  96, 128, 160, 192, 255]
  B = [0, 150, 253,  50,   0,  96, 128, 160, 192, 255]

  RR = [INTERPOL(R[0:2],I[0:2],INDGEN(21)),RGB[21:239].(1),INTERPOL(R[3:4],I[3:4],INDGEN(11)+240), R[5:9]];]
  GG = [INTERPOL(G[0:2],I[0:2],INDGEN(21)),RGB[21:239].(2),INTERPOL(G[3:4],I[3:4],INDGEN(11)+240), G[5:9]];,INTERPOL(G(3:9),I(3:9),INDGEN(16))]
  BB = [INTERPOL(B[0:2],I[0:2],INDGEN(21)),RGB[21:239].(3),INTERPOL(B[3:4],I[3:4],INDGEN(11)+240), B[5:9]];,INTERPOL(B(3:9),I(3:9),INDGEN(16))]

  PAL = BYTARR(3,256)
  PAL(0,*) = RR
  PAL(1,*) = GG
  PAL(2,*) = BB

  ;  PALLIST = LIST()
  ;  FOR I = 0, N_ELEMENTS(R)-1 DO PALLIST.ADD,REFORM(PAL[*,I])

  ARR    = FLTARR(200,200)
  FOR I = 0, 199 DO ARR(*,I) = (0+(100/199.)*FINDGEN(200))            ; scale the array to 200 intervals ranging from 0 to 100 (adapted from the jhuapl routine maken)
  X = [MIN(ARR),MAX(ARR)]
  IM = IMAGE(ARR,/CURRENT,RGB_TABLE=PAL,TITLE='LINEAR')

  CPAL_WRITE,'pal_panoply',RR,GG,BB
  FILE_DOC,'pal_panoply'

  IM.CLOSE
ENDIF;IF DO_ANOM_PAL GE 1 THEN BEGIN



DONE:          
	END; #####################  END OF ROUTINE ################################
