; $ID:	PHIST.PRO,	2020-07-01-12,	USER-KJWH	$
;#############################################################################################################
	PRO PHIST,DATA,NUM = NUM,PS = PS
	
;  PRO PHIST
;+
; NAME:
;		PHIST
;
; PURPOSE: THIS PROGRAM PRINTS A HISTOGRAM OF DATA [OR PLOTS AN IMAGE STRIPM OF DATA LOCATIONS]
;
; CATEGORY:
;		PROGRAMS
;		 
;
; CALLING SEQUENCE:PHIST
;
; INPUTS: 
;     DATA: DATA VALUES
;		
;		
; OPTIONAL INPUTS:
;		NONE:	
;		
; KEYWORD PARAMETERS:
; NUM: NUMBER OF NUM TO SPLIT UP THE DATA
; 
; OUTPUTS: PRINTS A HISTOGRAM TO THE SCREEN 
;		
;; EXAMPLES:
;  PHIST,INDGEN(99)

;	NOTES:

;
; MODIFICATION HISTORY:
;			WRITTEN DEC 5,2012  J.O'REILLY
;			FEB 11,2013,JOR IF DATA ARE FILES THEN USE IMAGE_INTERVALS TO MAKE AN IMAGE STRIP OF DATA LOCATIONS
;			OCT 2,2013,JOR IF SZ.TYPE EQ 1 AND SZ.N_DIMENSIONS EQ 2 THEN BEGIN
;     AUG 21,2014,JOR     TXT = STRTRIM((OK),2) + '   ' + STR_COMMA(H[OK])



;			
;#################################################################################
;-
;*************************
ROUTINE_NAME='PHIST'
;*************************
;HISTPLOT
SZ = SIZEXYZ(DATA)
IF SZ.N_DIMENSIONS EQ 2 THEN DO_IMAGE_INTERVALS = 1 ELSE DO_IMAGE_INTERVALS = 0
IF N_ELEMENTS (NUM) NE 1 THEN _NUM = 5 ELSE _NUM = NUM
;===> IF DATA IS A STRING THEN ASSUME A SD STRUCTURE
IF SZ.TYPE EQ 7 THEN   DATA = STRUCT_SD_READ(DATA,STRUCT=STRUCT)
IF SZ.TYPE LE 2 AND SZ.N_DIMENSIONS EQ 2 THEN BEGIN
  H=HISTOGRAM(DATA)
  OK = WHERE(H NE 0,COUNT)
  IF COUNT GE 1 THEN BEGIN
    T = ['COLOR  ,COUNT']
    TXT = STRTRIM((OK),2) + '   ' + STR_COMMA(H[OK])
    TXT = [T,TXT]
    PLIST,TXT,/NOSEQ
    GOTO,DONE
  ENDIF;IF COUNT GE 1 THEN BEGIN
  
ENDIF;IF SZ.TYPE EQ 1 AND SZ.N_DIMENSIONS EQ 2 THEN BEGIN

_MM = MINMAX(DATA,/FIN)
  ;===> GET THE SPAN OF THE DATA
  _SPAN=SPAN(_MM)  
  ;===> DIVIDE THE _SPAN INTO NUM
  _NUM = INTERVAL([_MM],_SPAN/_NUM)
  ;FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
  FOR NTH = 0,N_ELEMENTS(_NUM)-2 DO BEGIN
    LOWER = _NUM[NTH]
    UPPER = _NUM(0 > (NTH+1) < (N_ELEMENTS(_NUM)-1))
    OK = WHERE(DATA GE LOWER AND DATA LE UPPER AND DATA NE MISSINGS(DATA),COUNT)
    IF COUNT GE 1 THEN BEGIN
      TXT = 'RANGE:   '+STRTRIM(LOWER,2) + ' TO  '+STRTRIM(UPPER,2) + '    COUNT   ' + STRTRIM(COUNT,2)
      REPORT,TXT
      ;**************************
      IF DO_IMAGE_INTERVALS EQ 1 THEN BEGIN
      ;**************************
      IMAGE_INTERVALS,FILES
      IM = BYTE(DATA) & IM(*) = 255 & IM[OK] = 30;DARK GRAY
      ZWIN,IM & TV,IM
      FONT_TIMES
      XYOUTS,0.5,0.5,TXT,/NORMAL,CHARSIZE = _CHARSIZE,COLOR = 21,CHARTHICK = 3
      FRAME,COLOR = 0,/REGION,THICK = 3
      IM=TVRD()
      ZWIN
      IF N_ELEMENTS(PAGE) EQ 0 THEN PAGE = IM ELSE PAGE = IMAGE_WELD(PAGE,IM)        
      ENDIF;IF DO_IMAGE_INTERVALS_INTERVALS EQ 1 THEN BEGIN
      ;||||||||||||||||||||||||||||||||
    ENDIF;IF COUNT GE 1 THEN BEGIN 
    
  ENDFOR;FOR NTH = 0,N_ELEMENTS(_NUM)-1 DO BEGIN
  ;FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
  
 

IF KEYWORD_SET(PS) THEN BEGIN
  CD,CURRENT = DIR
  DIR = DIR + PATH_SEP()
  PSFILE = DIR +ROUTINE_NAME +'.PS'
  ;===> MAKE A POSTSCRIPT FILE
  PSPRINT,/COLOR,/FULL,FILENAME=PSFILE
  SET_PMULTI
  PAL_36,R,G,B
    BINSIZE=_SPAN/100
  HISTPLOT,DATA,TITLE = 'DATA',XMARGIN=[2,2],YMARGIN=[2,2],BAR_COLOR=21,STATS_CHARSIZE = 2, BINSIZE=BINSIZE,_EXTRA=_EXTRA
  PSPRINT
  PFILE,PSFILE,/W
ENDIF ELSE BEGIN
  PLINES
  H = HISTOGRAM(DATA,NBINS = 10)
  OK = WHERE(H NE 0,COUNT)
  FREQ = H[OK]
  
 
ENDELSE;IF KEYWORD_SET(PS) THEN BEGIN




DONE:          


	END; #####################  END OF ROUTINE ################################
