; $ID:	PPLT.PRO,	2020-06-03-17,	USER-KJWH	$
; #########################################################################; 
PRO PPLT,X,Y,PNG=PNG,_EXTRA=_EXTRA
;+
; PURPOSE:  EASIER SHORTCUT WRAPPER FOR THE PLOT FUNCTION
;
; CATEGORY: PLT
;
;
; INPUTS:
;         X ......... X DATA 
;         Y ......... Y DATA [NOT REQUIRED]
;
; KEYWORDS:  
;          PNG ............. WRITE THE PLOT TO A PNG FILE IN !S.IDL_TEMP
;          _EXTRA .......... PASSED TO PLOT [COLOR,THICK,LINESTYLE,XTITLE,YTITLE,TITLE,ETC.
;        
;         
; OUTPUTS: 
;
;; EXAMPLES: 
;           PPLT,INDGEN(9)
;           PPLT,INDGEN(9),INDGEN(9)
;           PPLT,INDGEN(9),INDGEN(9),XTITLE = 'JUNK',YTITLE = 'MORE JUNK',TITLE = 'JUNK PLOT'
;           PPLT,INDGEN(9),INDGEN(9),XTITLE = 'JUNK',YTITLE = 'MORE JUNK',TITLE = 'JUNK PLOT',/PNG
; MODIFICATION HISTORY:
;     APR 23, 2019  WRITTEN BY: J.E. O'REILLY
; #########################################################################
;-
;***************
ROUTINE = 'PPLT'
;***************

CASE (N_PARAMS()) OF
  1: BEGIN
    PLT = PLOT(X,COLOR = 'DODGER_BLUE',THICK = 3,YTITLE = 'X',XTITLE = 'SEQUENCE',_EXTRA=_EXTRA)
  END;1
  2: BEGIN
    PLT = PLOT(X,Y,COLOR = 'DODGER_BLUE',THICK = 3,XTITLE = 'X',YTITLE = 'Y',_EXTRA=_EXTRA)
  END;2
  ELSE: BEGIN
  END
ENDCASE
PLT_GRIDS,PLT
IF KEY(PNG) THEN BEGIN
  PNGFILE = !S.IDL_TEMP + ROUTINE + '.PNG'
  PLT.SAVE,PNGFILE
  PFILE,PNGFILE
  PLT.CLOSE
ENDIF;IF KEY(PNG) THEN BEGIN


END; #####################  END OF ROUTINE ################################
