; $Id:	axis_demo.pro,	February 13 2007	$

	PRO AXIS_DEMO

;+
; NAME:
;		AXIS_DEMO.PRO
;
; PURPOSE:;
;		This procedure is a DEMO for IDL'S AXIS procedure
;
; CATEGORY:
;		PLOT
;
; CALLING SEQUENCE:
;
;		AXIS_DEMO
;

; INPUTS:
;		NONE
;

; OUTPUTS:
;		PLOT

; EXAMPLE:
;
;	NOTES:
;
;
;
; MODIFICATION HISTORY:
;			Written Nov 21, 2006 by J.O'Reilly, 28 Tarzwell Drive, NMFS, NOAA 02882 (Jay.O'Reilly@NOAA.GOV)
;-
;	****************************************************************************************************
	ROUTINE_NAME = 'AXIS_DEMO.PRO'

;	===> Initialize ERROR to a null string. If errors are encountered ERROR will be set to a message.
;			 The calling routine can check error (e.g.IF ERROR NE 0 then there was a problem and do this or that)
	ERROR = ''

	WIN
	ERASE
	X = [0,1,2,3]
	Y= X

	PLOT,X,Y, XTICK_GET=xtick_get ,YMARGIN=[2,5],XSTYLE=1,YSTYLE=1
	XTICKNAME= STRTRIM(STRING(10^FLOAT(XTICK_GET),FORMAT='(G0)'),2)
	XTICKS = N_ELEMENTS(XTICK_GET)-1
	PRINT,XTICKNAME
	AXIS, XAXIS = 1,XSTYLE=1,XTICKS=XTICKS,XTICKV= FLOAT(XTICK_GET), XTICKLEN= -0.02,XTICKNAME=XTICKNAME

		STOP
;; FUNCTION YTICKS, axis, index, value
;;   fixvalue = 389.0d
;;   pvalue = (value/fixvalue) * 100.0d
;;   RETURN, STRING(pvalue, FORMAT='(D5.2,"%")')
;;END

	END; #####################  End of Routine ################################
