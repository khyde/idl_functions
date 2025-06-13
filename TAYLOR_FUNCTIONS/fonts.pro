; $Id:	fonts.pro,	January 31 2007	$
  PRO FONTS, FONT,  NAMES =names,  ERROR=error
;+
; NAME:
;		FONTS
;
; PURPOSE:
;		This procedure changes the Font for Direct Graphics Devices (WIN,X,Z,Postscript, etc.)
;
; CATEGORY:
;		PLOT
;
; CALLING SEQUENCE:
;		FONTS
;
;	INPUTS:
;		Font...... Value of -1 or from 3 to 20 yields IDL Vector Fonts
;							 If no Font number is provided or no Keywords are provided
;							 then this routine sets the font to IDL default (Hershey 3 vector font Font Simplex Roman)
;							 If TrueType font names are provided then the first match with those available is used,
;							 giving preference to IDL's TrueType fonts over the system's TrueType fonts
;
;	KEYWORD PARAMETERS:
;		NAMES..... The names of the available fonts
;		ERROR:     Any Error messages are placed in ERROR, if no errors then ERROR = ''
;
; OUTPUTS:
;		This Routine sets the !P.FONT to -1 (Vector Fonts),0 (Device Fonts),or 1 (True Type Fonts)
;
;
; EXAMPLE:
;		PLOT,[1,2,3] & fonts,'Times'& xyouts,0.5,0.5,/normal,'Times', align=0.5,charsize=5,color=!P.COLOR
;
;		FONTS
;		FONTS,'TIMES'
;
;	NOTES:
;	If the specified True Type font is not found, This routine follows IDL's convention and substitutes Helvetica.
;
;	This routine gives priority to the IDL supplied TrueType Fonts (version 6.3) over the TrueType fonts on your system
;	The IDL True Type fonts supplied are:
;	Helvetica,	Helvetica Bold,	Helvetica Italic,	Helvetica Bold Italic,$
;	Courier,  	Courier Bold,	 	Courier Italic,	 	Courier Bold Italic, $
;	Times,			Times Bold,			Times Italic,		 Times Bold Italic,$
;	Symbol,		Monospace Symbol,	and ENVI Symbols


;	This routine uses STRPOS to pick the first TrueType Font name matching your input FONT
;


; MODIFICATION HISTORY:
;			Written Jan 22, 2007 by J.O'Reilly, 28 Tarzwell Drive, NMFS, NOAA 02882 (Jay.O'Reilly@NOAA.GOV)
;-
;	****************************************************************************************************
	ROUTINE_NAME = 'FONTS'
	ERROR = ''

;	===> Default font is IDL's Default:Simplex Roman Vector Font 3
	IF N_ELEMENTS(FONT) NE 1 THEN TYPE = -1 ELSE TYPE = FONT


;	===> See if FONT is a number or string
	IF NUMERIC(TYPE) THEN BEGIN
;		===> Hershey vector fonts (see IDL Help for the meaning of fonts 3 to 20)
		IF type EQ -1 OR (type GE 3 AND type LE 20) THEN BEGIN
			!P.FONT = -1
	    IF type EQ -1 THEN TYPE = 3   ; Default Vector Font (Simplex Roman)
;			===> Implement this font by a call to XYOUTS (with improbable normal coordinates)
	    vfont = '!'+ STRTRIM(TYPE,2)
	    XYOUTS,-10,-10,vfont,/normal
	 		RETURN
		ENDIF

;		===> Default Device Font
		IF font EQ 0 THEN BEGIN
	  	!P.FONT = 0
	  	RETURN
	  ENDIF

	ENDIF ELSE BEGIN



;		**********************************************************************
;		*** Information about the True Type Fonts available on your system ***
;		**********************************************************************
;		===> Remember the current graphics device name
		device_name = !D.name
		SYS_P   = !P

;		===> Set device to system graphics device (win or x) to see what true type fonts are availble
  	IF !VERSION.OS EQ 'Win32' THEN SET_PLOT,'WIN' ELSE SET_PLOT,'X'
		DEVICE,GET_FONTNAMES=names, SET_FONT='*'

;		===> Give priority to the IDL supplied TrueType Fonts (version 6.3)
		IDL_TRUE_TYPE_FONTS =['Helvetica','Helvetica Bold','Helvetica Italic','Helvetica Bold Italic',$
													'Courier',  'Courier Bold',	 'Courier Italic',	 'Courier Bold Italic', $
													'Times',	'Times Bold',				'Times Italic',		 'Times Bold Italic',$
													'Symbol',	'Monospace Symbol',	'ENVI Symbols']

		names = [IDL_TRUE_TYPE_FONTS,names]


;		===> Set Device back to starting device and restore info in system variable !P
		SET_PLOT,device_name
		!P = SYS_P


;		===> Find the True Type font
		OK=WHERE(STRPOS(STRUPCASE(names),STRUPCASE(TYPE)) GE 0,COUNT)


;		===> True Type Fonts (see IDL Help)
		IF COUNT GE 1 THEN TTYPE = NAMES(OK(0))  ELSE 	TTYPE = IDL_TRUE_TYPE_FONTS(0); 'Helvetica'
	 	!P.FONT=1


;		===> Set up an error catching block because not all TrueType Fonts
;				 found on your system with the above statement
;				 (DEVICE,GET_FONTNAMES=names, SET_FONT='*') are really availble
		CATCH, Error_Status
   	IF Error_Status NE 0 THEN BEGIN
    	ERROR = !ERROR_STATE.MSG
    	PRINT,ERROR
   		CATCH, /CANCEL
;				===> Default font if encounter an error is Helvetica
    	TTYPE = IDL_TRUE_TYPE_FONTS(0); 'Helvetica'
   	ENDIF
  	DEVICE, SET_FONT= TTYPE, /TT_FONT
  	RETURN

	ENDELSE ; 	IF NUMERIC(FONT) THEN BEGIN

	END; #####################  End of Routine ################################
