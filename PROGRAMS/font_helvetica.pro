; $ID:	FONT_HELVETICA.PRO,	FEBRUARY 26,2013 	$
;##########################################################################################
  PRO FONT_HELVETICA
;+
; NAME:
;		FONT_HELVETICA
;
; PURPOSE:
;		THIS PROCEDURE SETS THE IDL FONT TO A TRUE-TYPE HELVETICA FONT 
;
; CATEGORY:
;		PLOT
;
; CALLING SEQUENCE:
;
;		FONT_HELVETICA
;		
;		
;	EXAMPLE:
;  PSPRINT,FILENAME = 'HELVETICA.PS' & FONT_HELVETICA & XYOUTS,.4,.5,'HELVETICA FONT!Ca True-Type!CFont',/NORMAL,CHARSIZE = 5,ALIGN = 0.5 & PSPRINT
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
	ROUTINE_NAME = 'FONT_HELVETICA'
;********************************************	

 	!P.FONT=1
  DEVICE, SET_FONT='HELVETICA', /TT_FONT
	END; #####################  END OF ROUTINE ################################
