; $ID:	RMS.PRO,	2020-06-26-15,	USER-KJWH	$

FUNCTION RMS, X, Y, N=N, ERROR=ERROR, ERR_MSG=ERR_MSG

;+
; NAME:
;		RMS
;
; PURPOSE:
;		This FUNCTION Computes the Root Mean Square on a set of variables.  RMS is the statistical measure of the magnitude of a varying quantity (also known as the quadratic mean)
;
; CATEGORY:
;		STATISTICS
;
; CALLING SEQUENCE:
;		Result = rms(x)
;
; INPUTS:
;		X = input data
;
; KEYWORD PARAMETERS:
;
; OUTPUTS:
;		RMS: The root-mean-square of X.
;		N: Number of valid data
;	  ERROR: 0=OK, 1=ERROR
;		ERR_MSG: Error Message
;
;	EXAMPLE:
;
;		X=[1.0,2.0,3.0] & PRINT, RMS(X) 
;   X=[1.0,-2.0,3.0,-4.0] & PRINT, RMS(X)
;   X=[1.0,-2.0,3.0,-4.0,!VALUES.F_INFINITY] & PRINT, RMS(X) 
;
; MODIFICATION HISTORY:
;		Written Nov 13, 1994 by J.O'Reilly, 28 Tarzwell Drive, NMFS, NOAA 02882 (Jay.O'Reilly@NOAA.GOV)
; 	June 13,1995 JOR Returns a structure with RMS and N
;		Dec 10, 2006 JOR Added ERROR and ERR_MSG to structure
;   May 17, 2015 - KJWH: Removed the structure and now returning just the RMSE value
;-
;	****************************************************************************************************
	ROUTINE_NAME = 'RMS'
  RMS = []
  ERROR = 0
  ERR_MSG = ''

	IF NONE(X) THEN BEGIN
    ERROR = 1 
	  ERR_MSG='Must provide X variable' 
	  RETURN, RMS
	ENDIF ELSE XX = FLOAT(X)

;	===> Find the pairs of good (non-missing) and FINITE data
  OK = WHERE(XX NE MISSINGS(XX),N)

  IF N GE 1 THEN RMS = (TOTAL(XX[OK]^2.0)/N)^0.5
  RETURN, RMS

	END; #####################  End of Routine ################################

