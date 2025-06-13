; $ID:	SCALE_DEMO.PRO,	2020-07-01-12,	USER-KJWH	$
;#############################################################################################################
	PRO SCALE_DEMO
	
;  PRO SCALE_DEMO
;+
; NAME:
;		SCALE_DEMO
;
; PURPOSE: THIS PROGRAM IS A DEMO FOR SCALE
;
; CATEGORY:
;		MATH
;		 
;
; CALLING SEQUENCE:SCALE_DEMO
;
; INPUTS: 
;		
;		
; OPTIONAL INPUTS:
;		NONE:	
;		
; KEYWORD PARAMETERS:
;		NONE:

; OUTPUTS: PRINTS TO SCREEN
;		
;; EXAMPLES:
;  SCALE_DEMO
;	NOTES:

;		
;
;
; MODIFICATION HISTORY:
;			WRITTEN JUL 7,2012  J.O'REILLY
;			FEB 5,2013,JOR ADDED STEP DO_GRAD_MAG_RATIO
;			MAR 7,2013,JOR NO LONGER ALOG10 OF RANGE SINCE SCALE_NEW DOES THE TRANSFORMATION OF RANGE 
;#################################################################################
;
;
;-
;	*******************************************
ROUTINE_NAME='SCALE_DEMO'
; *******************************************
; STOP PRINT N_ELEMENTS  ENDFOR SWITCHES  VAR    GAP
; 

;SSSSSSSSSSSSSSSSS  SWITCHES  SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS
DO_LNP_PRODS      = 0
DO_LNP_MAX_PEAK   = 0
DO_GAP_DAYS       = 0
DO_LNP_JMAX_CPY   = 0
DO_LNP_FAP        = 0
DO_GRAD_MAG_RATIO = 0
DO_ADG_443        = 1

;SSSSSSSSSSSSSSSSS  SWITCHES  SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS
PLINES
;******************************************
IF DO_GRAD_MAG_RATIO GE 1 THEN BEGIN
;******************************************
  ,'DO_GRAD_MAG_RATIO'
  PRINT,SCALE_NEW([1,250],[0.02,1.6],intercept=I,SLOPE= S,PROD='GRAD_MAG_RATIO',TRANSFORM='ALOG10',TEXT=TEXT)&PLINES &  PLIST,TEXT,/NOSEQ
  PLINES
  ,'DO_GRAD_MAG_RATIO'
  
ENDIF;IF DO_GRAD_MAG_RATIO GE 1 THEN BEGIN
;|||||||||||||||||||||||||||||||||||||||||



;******************************************
IF DO_LNP_JMAX_CPY GE 1 THEN BEGIN
;******************************************
,'DO_LNP_JMAX_CPY'
  S =SCALE_NEW([1,250],[0.05,5],intercept=I,SLOPE= S,PROD='LNP_JMAX_CPY',TRANSFORM='ALOG10',TEXT = TEXT)
  PRINT,'INT:  ',I,'   SLOPE:   ',S
  PLINES
  PLIST,TEXT,/NOSEQ
ENDIF;IF DO_LNP_JMAX_CPY GE 1 THEN BEGIN
;|||||||||||||||||||||||||||||||||||||||||


;******************************************
IF DO_GAP_DAYS GE 1 THEN BEGIN
;******************************************
,'DO_GAP_DAYS'
  S =SCALE_NEW([1,250],[01,1024],intercept=I,SLOPE= S,PROD='GAP_DAYS',TRANSFORM='ALOG10',TEXT = TEXT)
  PRINT,'INT:  ',I,'   SLOPE:   ',S
  PLINES
  PLIST,TEXT,/NOSEQ
ENDIF;IF DO_GAP_DAYS GE 1 THEN BEGIN
;|||||||||||||||||||||||||||||||||||||||||

;******************************************
IF DO_LNP_MAX_PEAK GE 1 THEN BEGIN
;******************************************
  PLINES
  S=SCALE_NEW([1,250],[1,1200],intercept=I,SLOPE= S,PROD='LNP_MAX_PEAK',TRANSFORM='ALOG10')& PRINT,'INT:  ',I,'   SLOPE:   ',S
  ;S= SCALE_NEW([1,250],ALOG10([1,1200]),intercept=I,SLOPE= S,PROD='LNP_DAN_PEAK',TRANSFORM='ALOG10')& PRINT,'INT:  ',I,'   SLOPE:   ',S
  PLINES
ENDIF;IF DO_LNP_MAX_PEAK GE 1 THEN BEGIN
;|||||||||||||||||||||||||||||||||||||||||

;******************************************
IF DO_LNP_FAP GE 1 THEN BEGIN
;******************************************
  P,SCALE_NEW([1,250],[1E-9,1.0D],intercept=I,SLOPE= S,PROD='LNP_FAP',TRANSFORM='ALOG10')& PRINT,'INT:  ',I,'   SLOPE:   ',S
ENDIF;IF DO_LNP_JMAX_CPY GE 1 THEN BEGIN
;|||||||||||||||||||||||||||||||||||||||||


;  P,SCALE([1,250],ALOG10([0.25,5.]),intercept=I,SLOPE= S,PROD='LNP_JMAX_CPY')& PRINT,'INT:  ',I,'   SLOPE:   ',S
;  P,SCALE([0.25,5.],[1,250],/DATA2BIN,intercept=I,SLOPE= S,PROD='LNP_JMAX_CPY',TRANSFORM='ALOG10')& PRINT,'INT:  ',I,'   SLOPE:   ',S
;'LNP_JMAX_CPY': BEGIN
  ;S.PROD= 'LNP_JMAX_CPY'
  ;S.B_SCALING= 'LOGARITHMIC'
  ;S.INTERCEPT= 0.0
  ;S.SLOPE= 1.0
  ;S.UNITS= ' ' 
  ;S.B_INTERCEPT= -1.3097
  ;S.B_SLOPE=  0.0087
  ;END;LNP_JMAX_CPY
  ;
;******************************
IF DO_LNP_PRODS GE 1 THEN BEGIN
;******************************
  ,'DO_LNP_PRODS'
  PRODS = ['LNP_1CPY','LNP_2CPY','LNP_3CPY','LNP_4CPY','LNP_5CPY']
  PRODS = ['LNP_MAX_PEAK']
  ;FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF  
  FOR NTH = 0,N_ELEMENTS(PRODS)-1 DO BEGIN
    PROD = PRODS[NTH]
    STOP
    FILE = 'F:\SMI\LNP\!STUDY-OCTS_SEAWIFS_TERRA_AQUA_MERIS-SMI-2010_12-9KM-CHLOR_A-' + PROD +'.SAVE'
    PFILE,FILE,/X
    DATA= STRUCT_SD_READ(FILE)
    IF PROD EQ 'VAR' THEN PROD = 'LNP_VAR'
 ;===> FIND NOT MAX BUT PRACTICAL MAX
     _MAX =MAX(DATA,/NAN)
     _MAX =CEIL(_MAX)
     R=NICE_RANGE(_MAX) & _MAX = LAST(R);=20
     PRINT,'_MAX   ',_MAX
    STOP
    S= SCALE([1,250], alog10([1,_MAX]),intercept=intercept,slope=slope) & print, intercept,slope
  STOP
    P,SD_SCALES([1,_MAX/2,_MAX],PROD = 'LNP_VAR',/DATA2BIN)
    SLIDEW,COLOR_BAR_SCALE(PROD = PROD)
    STOP
  ENDFOR;FOR NTH = 0,N_ELEMENTS(PRODS)-1 DO BEGIN
ENDIF;IF DO_LNP_PRODS GE 1 THEN BEGIN
;||||||||||||||||||||||||||||||||||||


;******************************************
IF DO_ADG_443 GE 1 THEN BEGIN
;******************************************
  PLINES
  S=SCALE_NEW([1,250],[0.001,10],intercept=I,SLOPE= S,PROD='ADG_443',TRANSFORM='ALOG10')& PRINT,'INT:  ',I,'   SLOPE:   ',S
  ;S= SCALE_NEW([1,250],ALOG10([1,1200]),intercept=I,SLOPE= S,PROD='LNP_DAN_PEAK',TRANSFORM='ALOG10')& PRINT,'INT:  ',I,'   SLOPE:   ',S
  PLINES
ENDIF;IF DO_ADG_443 GE 1 THEN BEGIN
;|||||||||||||||||||||||||||||||||||||||||




DONE:          
	END; #####################  END OF ROUTINE ################################
