; $Id:	CHAR_CENTER.pro,	January 08 2007	$

	FUNCTION CHAR_CENTER, FONT, ERROR = error

;+
; NAME:
;		CHAR_CENTER
;
; PURPOSE:
;		This function empirically determines the horizontal and vertical alignments used by XYOUTS2_CHAR to plot the character at its center
;
;	CATEGORY:
;		PLOT
;
; CALLING SEQUENCE:;
;
;		Result = CHAR_CENTER(Font='Times')
;
; INPUTS:
;		FONT:	The font to use (See FONTS.PRO)
;

; OUTPUTS:
;		A structure with the printable characters and their x,y alignments
;
; OPTIONAL OUTPUTS:
;		ERROR:     Any Error messages are placed in ERROR, if no errors then ERROR = ''
;
;
; RESTRICTIONS:
;		TrueType Fonts
;
;	PROCEDURE:
;		Letter alignments are determined relative to the plotting of a single pixel (psym=3)
;
; EXAMPLE:
;
;	NOTES:
;		This routine will display better if you set your tab to 2 spaces:
;	  (Preferences, Editor, The TAB Number of spaces to indent for each Tab: 2)


;
; MODIFICATION HISTORY:
;			Written Feb 21, 2007 by J.O'Reilly, 28 Tarzwell Drive, NMFS, NOAA 02882 (Jay.O'Reilly@NOAA.GOV)
;-
;	****************************************************************************************************
	ROUTINE_NAME = 'CHAR_CENTER'


;	===> Default Font is TIMES
	IF N_ELEMENTS(FONT) NE 1 THEN _FONT = 'TIMES' ELSE _FONT = FONT


;	===> Current Graphics Settings
	SYS_P = !P
	SYS_X = !X
	SYS_Y = !Y
	SYS_Z = !Z


	CHARSIZE = 5

;	===> Open a Z buffer
	ZWIN,[100*CHARSIZE,100*CHARSIZE]

	PLOT,[0,1],[0,1],/NORMAL


	FONTS, _FONT

;	===> Printable characters
	I = INDGEN(94) + 33 ;

;	===> Make a structure to hold output
	STRUCT= REPLICATE(CREATE_STRUCT('N',-1, 'CHAR','', 'X',0.0,'Y',0.0),N_ELEMENTS(I))

;	LLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLL
	FOR nth = 0,N_ELEMENTS(I)-1 DO BEGIN
		ERASE,0
		STR = STRING(BYTE(I(NTH)))

		XYOUTS, 0.5,0.5,/NORMAL,STR , CHARSIZE=CHARSIZE,COLOR=255
		LETTER=TVRD()
		OK=WHERE(LETTER EQ 255,COUNT)
		IF COUNT EQ 0 THEN CONTINUE ; >>>>>>>>>>
		XY=ARRAY_INDICES(LETTER,OK)
		CX = MIN(XY(0,*)) + SPAN(XY(0,*))/2.0
		CY = MIN(XY(1,*)) + SPAN(XY(1,*))/2.0

		ERASE,0
		PLOTS,  0.5,0.5,/NORMAL, PSYM=3, COLOR=255
		SYMBOL = TVRD()
		OK=WHERE(SYMBOL EQ 255,COUNT)
		XY=ARRAY_INDICES(SYMBOL,OK)
		SX =  XY(0)
		SY =  XY(1)
		STRUCT(nth).n = I(nth)
		STRUCT(nth).char = str
		STRUCT(nth).X =  (CX - SX)/(!D.X_CH_SIZE*CHARSIZE)
		STRUCT(nth).Y =  (CY - SY)/(!D.Y_CH_SIZE*CHARSIZE)
	ENDFOR

;	===> Close the Z-buffer
	ZWIN


;	===> Restore graphics
	!P = 	SYS_P
	!X = 	SYS_X
	!Y =	SYS_Y
	!Z = 	SYS_Z

	RETURN,STRUCT


	END; #####################  End of Routine ################################
