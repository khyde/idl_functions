; $ID:	FONT_CALIBRI.PRO,	2014-04-29	$
;##########################################################################################
  PRO FONT_CALIBRI
;+
; NAME:
;		FONT_ARIEL
;
; PURPOSE:
;		THIS PROCEDURE SETS THE IDL FONT TO A TRUE-TYPE ARIEL FONT 
;
; CATEGORY:
;		PLOT
;
; CALLING SEQUENCE:
;
;		FONT_ARIEL
;		
;		
;	EXAMPLE:
;	 PSPRINT & FONT_ARIEL & XYOUTS,.4,.5,'Calibri Font!Ca True-Type!CFont',/NORMAL,CHARSIZE = 5 & PSPRINT
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
	ROUTINE_NAME = 'FONT_CALIBRI'
;********************************************	

 	!P.FONT=1
  DEVICE, SET_FONT='Calibri', /TT_FONT
	END; #####################  END OF ROUTINE ################################
