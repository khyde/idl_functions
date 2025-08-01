; $ID:	PLT_DEG.PRO,	2020-06-30-17,	USER-KJWH	$
; 
PRO PLT_DEG,MAPP,LEVELS,THICKS=THICKS,COLORS=COLORS,VERBOSE=VERBOSE,FACT=FACT,$
SMO=SMO,BYT=BYT,PNGFILE=PNGFILE,PAL=PAL,LABLE=LABEL
; #########################################################################; 
;+
; PURPOSE:  THIS PROGRAM READS TOPO 'DEG' FILES AND PLOTS LON,LAT DATA

; CATEGORY: PLT_ FAMILY;
;
; CALLING SEQUENCE: 
;
; INPUTS: MAPP ..... STANDARD MAP NAME
;         LEVELS.... ELEVATIONS [VALUES GE 0 ] OR DEPTHS [LT 0] [METERS, MAY BE MULTIPLE VALUES]
;
;
; KEYWORDS:
;     THICKS..... ARRAY OF LINE THICKNESS FOR LEVELS [DEPTHS]
;     COLORS..... ARRAY OF COLORS FOR LEVELS [DEPTHS]
;     VERBOSE.... PRINTS PROGRAM PROGRESS 
;     FACT........USED TO DETERMINE THE PXY SIZE:'PXY_8640_4320','PXY_34560_17280', OR 'PXY_43200_21600' 
;     SMO........ WIDTH TO USE TO SMOOTH CONTOUR CURVES [IF NONE THEN NO SMOOTHING DONE]
;     BYT........ BYTE ARRAY PASSED TO THIS PROGRAM [E.G. FROM TOPO_VIEW]
;     PAL........ PAL PROGRAM NAME
;     LABEL...... LABEL CONTOUR LINES USING XYOUTS

; OUTPUTS: PLOTS THE DEPTH CONTOURS AND MAKES A PNG
;
;; EXAMPLES:
;      PLT_DEG,'EC',-[10,20,50,100,200,1000,2000],FACT = 1,COLOR = 230
;      PLT_DEG,'EC',-[10,20,50,100,200,1000,2000],FACT = 4,COLOR = 230
;
; MODIFICATION HISTORY:
;     DEC 24, 2015  WRITTEN BY: J.E. O'REILLY
;     DEC 30,2015,JOR REFINEMENTS
;     JAN 06,2016,JOR ADDED KEY FACT, CHECKS IF BYT PROVIDED
;     JAN 10,2016,JOR ADDED KEY LABEL,FONT_HELVETICA,CHARSIZE
;-
; #########################################################################

;************************
ROUTINE_NAME  = 'PLT_DEG'
;************************
IF NONE(FACT) THEN FACT = 10
IF NONE(LABEL) THEN LABEL = 1
IF NONE(CHARSIZE) THEN CHARSIZE = 2.0
 SUB = 200 
FONT_HELVETICA
IF NONE(MIN_PTS) THEN MIN_PTS = 100 ; MIN NUM OF POINTS NEEDED TO LABEL A CONTOUR

;===> ALL THE DEG FILES WERE MADE USING THE SMI MAP AT VARIOUS RESOLUTIONS [PX & PY]
M = MAPS_SIZE('SMI') & PX = M.PX & PY = M.PY
;===> MAKE A PXY STRING TO USE WHEN FINDING THE DEG FILES
PXY = 'PXY_' + ROUNDS(PX*FACT) + '_' + ROUNDS(PY* FACT)

CLOSE,/ALL
FMT = '(2F16.5)'
NUM = 0.0
TT = TOPO_TAGS('SMI',LEVELS)
IF NONE(FILES) THEN FILES = FLS(!S.BATHY , '*'+PXY+ '*.DEG')
OK = WHERE_STRING(FILES,TT.TAG + '-',COUNT)
IF COUNT GE 1 THEN FILES = FILES[OK] ELSE GOTO,DONE;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
IF NONE(VERBOSE) THEN VERBOSE = 1
IF NONE(MAPP) OR NONE(LEVELS) THEN MESSAGE,'ERROR: MUST PROVIDE MAPP & LEVELS'
IF NONE(THICKS) THEN THICKS = REPLICATE(1,NOF(LEVELS))
IF NOF(THICKS) NE NOF(LEVELS) THEN THICKS = REPLICATE(THICKS[0],NOF(LEVELS))
IF NONE(COLORS) THEN COLORS = REPLICATE(1,NOF(LEVELS))
IF NOF(COLORS) NE NOF(LEVELS) THEN COLORS = REPLICATE(COLORS[0],NOF(LEVELS))
MAPS_SET,MAPP

IF NONE(BYT) THEN BEGIN
  ERASE,255
  MASK = READ_LANDMASK(MAP=MAPP)
  OK = WHERE(MASK EQ 0,COUNT)
  IF COUNT GE 1 THEN MASK[OK] = 255
  IF NONE(PAL) THEN PAL_LANDMASK,R,G,B  ELSE CALL_PROCEDURE,PAL,R,G,B
  TV,MASK
ENDIF ELSE BEGIN
  TV,BYT  
   IF NONE(PAL) THEN PAL_BATHY,R,G,B    ELSE CALL_PROCEDURE,PAL,R,G,B
ENDELSE;IF NONE(BYT) THEN BEGIN

;FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
FOR NTH = 0,NOF(LEVELS)-1 DO BEGIN
  LEVEL = LEVELS[NTH]
  THICK = THICKS[NTH]
  COLOR = COLORS[NTH]
  TT = TOPO_TAGS('SMI',LEVEL) 
  OK = WHERE_STRING(FILES,TT.TAG + '-',COUNT)
  IF COUNT NE 1 THEN CONTINUE;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  FILE = FILES[OK]
  IF KEY(VERBOSE) THEN PFILE,FILE,/R
  OPENR,LUN,FILE,/GET_LUN
  WHILE NOT EOF(LUN) DO BEGIN
    READF,LUN,NUM,LEVEL,FORMAT=FMT
    LONS = DBLARR(NUM) & LONS(*) = MISSINGS(LONS)
    LATS = DBLARR(NUM) & LATS(*) = MISSINGS(LATS)
    READF,LUN,LONS,LATS,FORMAT=FMT
    IF KEY(SMO) THEN BEGIN
      LONS = SMOOTH(LONS,SMO <NOF(LONS)-1)
      LATS = SMOOTH(LATS,SMO <NOF(LATS)-1)
    ENDIF;IF KEY(SMO) THEN BEGIN
    PLOTS,LONS,LATS,COLOR = COLOR,THICK = THICK
;    IF KEY(LABEL) AND NUM GE MIN_PTS THEN BEGIN
;        OK = WHERE(FINITE(LONS) AND FINITE(LATS),COUNT)
;        IF COUNT GE MIN_PTS THEN BEGIN
;          LONS = LONS[OK]
;          LATS = LATS[OK]
;          L = MAPS_LL_BOX()
;          OK = WHERE(LONS GT L.MINLON AND LONS LT L.MAXLON AND LATS GT L.MINLAT AND LATS LT L.MAXLAT,GOOD) & P,GOOD
;        ENDIF; IF COUNT GE 2 THEN BEGIN
        
;         SUB = SUB < (COUNT-1)                          
;        XYOUTS,LONS(SUB),LATS(SUB),ROUNDS(-LEVEL),/DATA,$
;        CHARSIZE=CHARSIZE,COLOR=COLOR,ALIGN = 0.5
;
;    ENDIF;IF KEY(LABEL) AND NUM GE MIN_PTS THEN BEGIN
  ENDWHILE;WHILE NOT EOF(LUN) DO BEGIN
    CLOSE,LUN    
ENDFOR;FOR NTH = 0,NOF(LEVELS)-1 DO BEGIN
;FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
IM = TVRD()
ZWIN
IF NONE(PNGFILE) THEN PNGFILE = !S.IDL_TEMP +MAPP + '.PNG'

IF VERBOSE THEN  PFILE,PNGFILE
WRITE_PNG,PNGFILE,IM,R,G,B

DONE:
END; #####################  END OF ROUTINE ################################
