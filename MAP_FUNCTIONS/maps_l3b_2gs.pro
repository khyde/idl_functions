; $ID:	MAPS_L3B_2GS.PRO,	2017-08-25-15,	USER-KJWH	$
; #########################################################################; 
FUNCTION MAPS_L3B_2GS, L3B, VERBOSE=VERBOSE, OVERWRITE=OVERWRITE
;+
; PURPOSE:  PROGRAM TO FIND THE POSITIONS OF THE L3B MAP BINS IN THE GS MAP AND WRITES TO A .SAV FILE
;
; CATEGORY: MAPS_L3B FAMILY
;
;
; INPUTS: 
;       LEB......... L3B MAP
;       
; KEYWORDS:  
;       VERBOSE..... KEYWORD TO PRINT ACTIONS
;       OVERWRITE... KEYWORD TO OVERWRITE PREVIOUS FILES
;       
; OUTPUTS:  
;       RESULT...... STRUCTURE SAVED IN THE FIILE
; EXAMPLES:
;          ST, MAPS_L3B_2GS('L3B9')
;          ST, MAPS_L3B_2GS('L3B4')
;
; MODIFICATION HISTORY:
;     MAR 04, 2017  WRITTEN BY: J.E. O'REILLY
;     AUG 25, 2017 - KJWH: Overhauled the program to now create an output SAV file that can be used in MAPS_L3BGS_SWAP
;     OCT 27, 2023 - KJWH: Added L3B25 map
;-
; #########################################################################

; ************************
  ROUTINE = 'MAPS_L3B_2GS'
; ************************

  IF IS_L3B(L3B) NE 1 THEN MESSAGE, 'ERROR: Must input a valid L3Bx map'
  
  CASE L3B OF
    'L3B1':  GS = 'GS1'
    'L3B2':  GS = 'GS2'
    'L3B3':  GS = 'GS3'
    'L3B4':  GS = 'GS4'
    'L3B5':  GS = 'GS5'
    'L3B6':  GS = 'GS6'
    'L3B9':  GS = 'GS9'
    'L3B10': GS = 'GS10'
    'L3B25': GS = 'GS25'
    ELSE: MESSAGE, 'ERROR: Must input a valid L3Bx map'
  ENDCASE

; ===> GET MAP SIZE INFO  
  MSL = MAPS_SIZE(L3B, PX=PXL, PY=PYL,  /STRING)
  MSG = MAPS_SIZE(GS,  PX=PXG, PY=PYG, /STRING)
  MP_TXT = L3B +'_'+ PXL + '_'  + PYL + '_' +  GS + '_'+ PXG + '_' + PYG
  
; ===> CHECK FOR FILE
  FILE = !S.MAPINFO + 'XPYP-' + MP_TXT + '.SAV'
  IF EXISTS(FILE) AND ~KEY(OVERWRITE) THEN BEGIN
    IF KEY(VERBOSE) THEN PRINT, 'Reading: ' + FILE 
    STR = IDL_RESTORE(FILE)
    RETURN, STR
  ENDIF
  
; ===> SET UP THE L3B BINS IN AN ARRAY  
  STR = MAPS_L3B_2LONLAT(L3B,/INIT)                                       ; GET L3B MAP INFO
  B = WHERE_SETS(STR.LATS)                                                ; FIND MATCHING LATITUDES
  B = SORTED(B,TAG='VALUE',/A)                                            ; SORT THE LATITUDES
  BINS_PER_ROW = B.N                                                      ; DETERMINE THE NUMBER OF BINS IN EACH ROW
  MAXBINS = MAX(BINS_PER_ROW)                                             ; GET THE MAXIMUM WIDTH OF THE ARRAY
  ARR = LONARR(MAXBINS,STR.NROWS) & XL = ARR                              ; CREATE 2 BLANK ARRAYS
  FOR I=0,N_ELEMENTS(B)-1 DO BEGIN                                        ; LOOP THROUGH LATITUDES
    SET = STR.BINS[WHERE_SETS_SUBS(B[I])]                                 ; SUBSET THE LATITUDES 
    ROWDIF = MAXBINS-BINS_PER_ROW[I]                                      ; DETERMINE THE NUMBER OF BLANK PIXELS OUTSIDE OF THE MAPPED AREA
    IF ODD(ROWDIF) THEN FIRSTBIN = (ROWDIF-1)/2 ELSE FIRSTBIN = ROWDIF/2  ; NOT ALL ROWS IN THE L3B MAPS HAVE AN EVEN NUMBER OF "EDGE" PIXELS (THIS MAY BE DIFFERENT FOR THE OTHER L3B MAPS)
    ARR[FIRSTBIN:FIRSTBIN+BINS_PER_ROW[I]-1,I] = SET                      ; SINCE THE BINBASE BIN REPRESENTS THE 180 DEGREE POSITION, ASSUME THERE IS ONE LESS "EDGE" PIXEL ON THE LEFT
  ENDFOR
  BLANK = WHERE(ARR EQ 0)                                                 ; FIND THE BLANK "EDGE" PIXELS
  YL = ARR-1                                                              ; CONVERT THE BINS, WHICH START AT 1, TO SUBSCRIPTS
  YL[BLANK] = -1                                                          ; MAKE THE "EDGE" PIXELS -1
  
  XG = 1
  YG = LONARR([1,STR.NBINS])
  YG[0,*] = WHERE(YL NE -1)
  
  GSTR = CREATE_STRUCT('MAP_TXT',MP_TXT,'L3B',L3B,'PX_L3',MSL.PX,'PY',MSL.PY,'GS',GS,'PX_GS',MSG.PX,'PY_GS',MSG.PY,'XP_L3_2GS',XL,'YP_L3_2GS',YL,'XP_GS_2L3',XG,'YP_GS_2L3',YG,'GS_EDGES',BLANK)
  IF KEY(VERBOSE) THEN PFILE, FILE
  SAVE, FILENAME=FILE, GSTR
  
  RETURN, GSTR

END; #####################  END OF ROUTINE ################################
