; $ID:	FONT_CASTELLAR.PRO,	2014-04-29	$
;##########################################################################################
  PRO FONT_CASTELLAR
;+
; NAME:
;		FONT_CASTELLAR
;
; PURPOSE:
;		THIS PROCEDURE SETS THE IDL FONT TO A TRUE-TYPE CASTELLAR FONT 
;
; CATEGORY:
;		PLOT
;
; CALLING SEQUENCE:
;
;		FONT_CASTELLAR
;		
;		
;	EXAMPLE:
;	 PSPRINT & FONT_CASTELLAR & XYOUTS,.4,.5,'CASTELLAR FONT!CA TRUE-TYPE!CFONT',/NORMAL,CHARSIZE = 5 & PSPRINT
;
; INPUTS:
;		NONE:
;
; OUTPUTS:
;		THIS ROUTINE SETS THE !P.FONT TO 1 (TRUE-TYPE FONT)

; MODIFICATION HISTORY:
;			WRITTEN SEP 21, 2003 BY J.O'REILLY, 28 TARZWELL DRIVE, NMFS, NOAA 02882 (JAY.O'REILLY@NOAA.GOV)
;			FEB 21,2013,JOR: FORMATTING
;-
;##################################################################################################
;
;********************************************
	ROUTINE_NAME = 'FONT_CASTELLAR'
;********************************************	

 	!P.FONT=1
  DEVICE, SET_FONT='Castellar', /TT_FONT
	END; #####################  END OF ROUTINE ################################
