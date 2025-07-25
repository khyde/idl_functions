; $ID:	PLT_COLORS.PRO,	2020-06-30-17,	USER-KJWH	$
;+
;#############################################################################################################
	PRO PLT_COLORS,X,Y

;
; PURPOSE:  PLOTS DATA AS DISTINCT COLORS
;
; CATEGORY:	PLT
;
; CALLING SEQUENCE: PLT_COLORS
;
; INPUTS: NONE
;         
;		
; OPTIONAL INPUTS:
;		NONE:	
;		
; KEYWORD PARAMETERS:  NONE
;		

; OUTPUTS: PNG FILE FOR EACH LME
;		
; EXAMPLES: 
; 
;
; MODIFICATION HISTORY:
;			OCT 25,2014,  WRITTEN BY J.O'REILLY 
;			
;			
;			
;#################################################################################
;-
;********************************
ROUTINE_NAME  = 'PLT_COLORS'
;********************************
PROD = 'CHLOR_A'
BUFFER = 0
RGB_TABLE = CPAL_READ('PAL_SW3')
;===> GET AVG CHL AND SORT LOW TO HIGH
M = GET_LME_MEAN(PROD = 'CHLOR_A',PER = 'Y',/ALL)
S=(SORT(M.MEAN))
M = M(S)

MAPS = M.MAP
W = WINDOW(BUFFER=BUFFER)
SEQ = 0
;FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
FOR MAP_ = 0,N_ELEMENTS(MAPS)-1 DO BEGIN
  LME = MAPS(MAP_) & PF,LME,/U
  SEQ = SEQ + 1
  LAYOUT = [1,N_ELEMENTS(MAPS),SEQ]
  TS = GET_LME_TS(LME,PROD = PROD,PER = 'M')
  DATA = TS.MEAN
  YRANGE = [1.,67.]
  ;===> MAKE XRANGE TO 2014 FOR COMPLETE AXIS LABELING
  X = DATE_2DYEAR(PERIOD_2DATE(TS.PERIOD))
  Y = REPLICATE(SEQ,N_ELEMENTS(X))
  ;===> SCALE DATA
  BDATA = PRODS_2BYTE(PROD=PROD,DATA)
  ;===> GET COLOR SETS
  SETS = WHERE_SETS(BDATA)
 
  ;FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
  FOR NTH = 0,N_ELEMENTS(SETS)-1 DO BEGIN
    SET = SETS[NTH]
    SUBS = WHERE_SETS_SUBS(SET)
    XX = X(SUBS) & YY = Y(SUBS)  
    IF N_ELEMENTS(SUBS) EQ 1 THEN BEGIN
      XX = [XX,XX]
      YY = [YY,YY]
    ENDIF;IF N_ELEMENTS(SUBS) EQ 1 THEN BEGIN
 
    P=PLOT(XX,YY,/YSTYLE,YRANGE=YRANGE,SYMBOL = '*',COLOR = RGBS(SET.VALUE),THICK = 15,/CURRENT,MARGIN = 0,/OVERPLOT,RGB_TABLE=RGB_TABLE)    
  ENDFOR;FOR NTH = 0,N_ELEMENTS(DB)-1 DO BEGIN
  ;FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
P
ENDFOR;ENDFOR;FOR MAP_ = 0,N_ELEMENTS(MAPS)-1 DO BEGIN
;FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
FILE = !S.IDL_TEMP + ROUTINE_NAME + '.PNG'
W.SAVE,FILE
W.CLOSE
PF,FILE
END; #####################  END OF ROUTINE ################################
