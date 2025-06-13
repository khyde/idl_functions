; $Id: HISTOGRAM_SUBS.pro, December 27,1999  J.E.O'Reilly Exp $

function HISTOGRAM_SUBS,data,_EXTRA=_extra
;+
; NAME:
;       HISTOGRAM_SUBS
;
; PURPOSE:
;       Return an array of subscripts
;
; CATEGORY:
;
;
; CALLING SEQUENCE:
;       Result = histogram_sub(a)
; example:
; X = [1,1,2,3,4,10,11,12,1,12] & H=HISTOGRAM(X,REVERSE_INDICES=R)  & FOR I = 0,N_ELEMENTS(H)-1L DO BEGIN &  If R[i]  NE R(I+1) THEN PRINT, R(R[i] : R(i+1)-1) & ENDFOR
; INPUTS:
;
;
; KEYWORD PARAMETERS:
;
; OUTPUTS:
;
; SIDE EFFECTS:
;       None.
;
; RESTRICTIONS:
;       None.
;
; PROCEDURE:
;       Straightforward.
;
; MODIFICATION HISTORY:
;       Written by:  J.E.O'Reilly, Jan, 1995.
;-



; ====================>
; Determine if binsize other than 1 was supplied
  IF KEYWORD_SET(_EXTRA) THEN BEGIN
     tags = TAG_NAMES(_EXTRA)
;   BINSIZE ?
    ok = WHERE(STRMID(tags,0,3) EQ 'BIN',count)
    IF count GE 1 THEN BEGIN
      BINSIZE = _EXTRA.BINSIZE
    ENDIF ELSE BEGIN
      BINSIZE = 1
    ENDELSE
  ENDIF ELSE BEGIN
    BINSIZE = 1
  ENDELSE


  H=HISTOGRAM(DATA,REVERSE_INDICES=R, OMIN=OMIN,OMAX=OMAX,_EXTRA=_extra)


  POS = OMIN - BINSIZE
  FOR I = 0,N_ELEMENTS(H)-1L DO BEGIN
    POS = POS + BINSIZE
    IF R[i] NE R(I+1) THEN BEGIN
       NAME = '_'+NUM2STR(POS)+'_'+NUM2STR(POS+BINSIZE)
       name = replace(name,'.','D')
       SUB =  R(R[i] : R(i+1)-1)
       IF N_ELEMENTS(ARR) EQ 0 THEN BEGIN
          ARR=CREATE_STRUCT(NAME,sub)
        ENDIF ELSE BEGIN
          ARR=CREATE_STRUCT(ARR,NAME,sub)
       ENDELSE
     ENDIF
  ENDFOR

  RETURN,ARR
  END; END OF PROGRAM
