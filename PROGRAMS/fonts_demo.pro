; $ID:	FONTS_DEMO.PRO,	2020-06-30-17,	USER-KJWH	$

	PRO FONTS_DEMO

;+
; NAME:
;		FONTS_DEMO
;
; PURPOSE:
;		This procedure is a DEMO for FONTS.PRO and makes a Postscript File illustrating available fonts
;
; CATEGORY:
;		GRAPHICS
;
; CALLING SEQUENCE:
;		FONTS_DEMO
;
; INPUTS:
;		NONE
;
; OUTPUTS:
;		This Procedure writes a PostScript File
;

;	NOTES:
;	 		DEVICE,GET_FONTNAMES=names, SET_FONT='*' provides the names of available True Type Fonts on your
;			system, however not all of these are actually available
;
;
; MODIFICATION HISTORY:
;			Written Jan 28, 2007 by J.O'Reilly, 28 Tarzwell Drive, NMFS, NOAA 02882 (Jay.O'Reilly@NOAA.GOV)
;-
;	****************************************************************************************************
	ROUTINE_NAME = 'FONTS_DEMO'

	PSPRINT,/COLOR,/FULL
	!P.MULTI=0

;	===> Call FONTS to get a list of the True Type fonts available
	FONTS,'TIMES',NAMES=NAMES
	LIST, NAMES


;	LLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLL
	FOR NTH=0,N_ELEMENTS(NAMES)-1 DO BEGIN
		FONTS, NAMES[NTH], ERROR=error
		PRINT, NAMES[NTH],ERROR

		IF ERROR EQ '' THEN BEGIN
			txt = [ALPHABET(), ALPHABET(/LOWER),'','','']
			txt = REFORM(TXT, 5,11)
			txt(4,*)= txt(4,*) +'!C'
	  	TXT= STRJOIN(STRJOIN(TXT))
	  	FONTS,'HELVETICA'
			PLOT,[0,1.],[0,1.0],XSTYLE=5,YSTYLE=5,title=NAMES[NTH],/NODATA,CHARSIZE=3
			FONTS, NAMES[NTH], ERROR=error
			XYOUTS, 0.05,0.8,/NORMAL,TXT,CHARSIZE=5

		ENDIF ELSE BEGIN
			FONTS,'HELVETICA'
			PLOT,[0,1],[0,1],XSTYLE=5,YSTYLE=5,title=NAMES[NTH],/NODATA,CHARSIZE=3
			FONTS, NAMES[NTH], ERROR=error
			XYOUTS, 0.05,0.8,/NORMAL,ERROR, CHARSIZE=2
		ENDELSE
	ENDFOR

	PSPRINT


	END; #####################  End of Routine ################################
