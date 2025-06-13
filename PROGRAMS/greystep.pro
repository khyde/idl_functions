; $ID:	GREYSTEP.PRO,	2020-06-30-17,	USER-KJWH	$
  PRO greystep,step,greys=greys, min_color=MIN_COLOR,MAX_COLOR=max_color, rev=rev

;+
; NAME:
;       greystep
;
; PURPOSE:
;       Program generates a grey scale palette which is stepped
;
; CATEGORY:
;       Graphics
;
; CALLING SEQUENCE:
;       greystep
;		greystep,16
;    	greystep,2    ; 2 grey steps
;
; INPUTS:
;		Step (default=16)
;
; KEYWORDS:
;    GREYS	256 Byte Array of STEP GREY VALUES
;
; OUTPUTS:
;       COMMON COLOR TABLE MODIFIED
;
; SIDE EFFECTS:
;       None.
;
; RESTRICTIONS:
;       None.
;
; PROCEDURE:
;       Straightforward.
;		e.g.
;       greystep,16
;
;
; MODIFICATION HISTORY:
;       Written by:    J.O'Reilly, November 4, 1995.
;		NOAA, NMFS, Narragansett Laboratory, 28 Tarzwell Drive, Narragansett, RI 02882-1199
;		oreilly@fish1.gso.uri.edu
;
;-

; ====================>
; If resolution parameter (step)not provided then use default (16).
  IF N_PARAMS() EQ 0 THEN BEGIN
    step = 16
  ENDIF ELSE BEGIN
    IF step GT 256 THEN step = 16
  ENDELSE

  STEP = 256./STEP

; ====================>
; Get IDL Common color
  COMMON COLORS, R_ORIG,G_ORIG,B_ORIG,R_CURR,G_CURR,B_CURR

; ====================>
; Generate array
  GREYS = ROUND(STEP) +((indgen(256)) / FIX(step))*step
  GREYS[0] = 0
  GREYS = BYTSCL(GREYS, MIN = 0, MAX=255)
;  PRINT, GREYS
  R_ORIG = GREYS
  G_ORIG = GREYS
  B_ORIG = GREYS
  R_CURR = GREYS
  G_CURR = GREYS
  B_CURR = GREYS

; ====================>
; Load into IDL Common color
  IF KEYWORD_SET(REV) THEN BEGIN
  	R_CURR=REVERSE(R_CURR)
  	G_CURR=REVERSE(G_CURR)
  	B_CURR=REVERSE(B_CURR)
  ENDIF
  TVLCT,R_CURR,G_CURR,B_CURR
  END
; END OF PROGRAM
