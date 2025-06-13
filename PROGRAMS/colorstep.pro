; $ID:	COLORSTEP.PRO,	2020-06-30-17,	USER-KJWH	$
  PRO COLORSTEP,step,R,G,B, BIN_TOP=bin_top, BIN_BOT=bin_bot, UPPER=upper, MID=mid

;+
; NAME:
;       colorstep
;
; PURPOSE:
;       Program generates a grey scale palette which is stepped
;
; CATEGORY:
;       Graphics
;
; CALLING SEQUENCE:
;       colorstep
;   colorstep,16
;     colorstep,2    ; 2 grey steps
;
; INPUTS:
;   Step (default=16)
;
; KEYWORDS:
;    colors  256 Byte Array of STEP GREY VALUES
;
; OUTPUTS:
;      R,G,B inputs are modified to equal the outputs
;
; SIDE EFFECTS:
;       None.
;
; RESTRICTIONS:
;       None.
;
; PROCEDURE:
;       Straightforward.
;   e.g.
;       colorstep,16
;
;
; MODIFICATION HISTORY:
;       Written by:    J.O'Reilly, November 4, 1995.
;   NOAA, NMFS, Narragansett Laboratory, 28 Tarzwell Drive, Narragansett, RI 02882-1199
;   oreilly@fish1.gso.uri.edu

;   JUNE 22,1999   USED Z DEVICE TO SECURE ALL 256 COLORS
;
;-

; ====================>
; If resolution parameter (step)not provided then use default (16).
  IF N_PARAMS() EQ 0 THEN BEGIN
    step = 16
  ENDIF ELSE BEGIN
    IF step GT 256 THEN step = 16
  ENDELSE

	IF N_ELEMENTS(BIN_BOT) NE 1 THEN _BIN_BOT = 0   	ELSE _BIN_BOT = BIN_BOT
	IF N_ELEMENTS(BIN_TOP) NE 1 THEN _BIN_TOP = 250   ELSE _BIN_TOP = BIN_TOP


 	N= _BIN_TOP- _BIN_BOT +1
	I = ROUND(INTERPOL([_BIN_BOT,_BIN_TOP],STEP+1))
	IF KEYWORD_SET(UPPER) THEN BEGIN

	 I=I-1

	ENDIF
	PRINT,I
	RR=R
	GG=G
	BB=B


;	LLLLLLLLLLLLLLLLLLLLLLLLLLL
	FOR NTH = 0,STEP-1 DO BEGIN
		START = I[NTH]
		FIN   = I(NTH+1)
		PRINT, START,FIN
		VAL = START
		IF KEYWORD_SET(UPPER) THEN VAL = FIN
		IF KEYWORD_SET(MID) THEN VAL = MEAN([START,FIN])
		RR(START:FIN) = R(VAL)
		GG(START:FIN) = G(VAL)
		BB(START:FIN) = B(VAL)
	ENDFOR

	R=RR
	G=GG
	B=BB


; ====================>
; Load into IDL Common color
  TVLCT,RR,GG,BB

  END
; END OF PROGRAM
