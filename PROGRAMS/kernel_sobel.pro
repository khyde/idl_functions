; $Id:	kernel_sobel.pro,	July 26 2007	$

	FUNCTION KERNEL_SOBEL

;+
; NAME:
;		KERNEL_SOBEL
;
; PURPOSE:
;		This function returns the SOBEL 3x3 Kernel
;
;
; CATEGORY:
;		FILTER
;
; CALLING SEQUENCE:
;
;		Result = KERNEL_SOBEL()
;
; INPUTS:
;		NONE
;
; OUTPUTS:
;		A floating point SOBEL Kernel
;
; OPTIONAL OUTPUTS:
;		ERROR:     Any Error messages are placed in ERROR, if no errors then ERROR = ''

; EXAMPLE:
;
;		Result = KERNEL_SOBEL()
;
;	NOTES:
;		This routine will display better if you set your tab to 2 spaces:
;	  (Preferences, Editor, The TAB Number of spaces to indent for each Tab: 2)


; MODIFICATION HISTORY:
;			Written July 25, 2007 by J.O'Reilly, 28 Tarzwell Drive, NMFS, NOAA 02882 (Jay.O'Reilly@NOAA.GOV)
;-
;	****************************************************************************************************
	ROUTINE_NAME = 'KERNEL_SOBEL'

; %%%  KERNEL SOBEL  %%%
  KERNEL = FLTARR(3,3)
  KERNEL[0,[0,2]] = -1.;
  KERNEL[2,[0,2]] =  1.;
  KERNEL[0,1] = -2.;
  KERNEL[2,1] =  2.;
; //////////////////////////

	RETURN,KERNEL


	END; #####################  End of Routine ################################
