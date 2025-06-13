; $Id:	font_times.pro,	January 24 2007	$
  PRO FONT_TIMES
;+
; NAME:
;		FONT_TIMES
;
; PURPOSE:
;		This procedure sets the IDL Font to a TRUE TYPE FONT for the Times Roman Regular
;
; CATEGORY:
;		PLOT
;
; CALLING SEQUENCE:
;
;		FONT_TIMES
;
; INPUTS:
;		NONE:
;
; OUTPUTS:
;		This Routine sets the !P.FONT to 1 (True Type Font)

; MODIFICATION HISTORY:
;			Written Sep 21, 2003 by J.O'Reilly, 28 Tarzwell Drive, NMFS, NOAA 02882 (Jay.O'Reilly@NOAA.GOV)
;-
;	****************************************************************************************************
	ROUTINE_NAME = 'FONT_TIMES'

 	!P.FONT=1
  DEVICE, SET_FONT='Times', /TT_FONT


	END; #####################  End of Routine ################################
