; $ID:	RMSE.PRO,	2020-06-26-15,	USER-KJWH	$

FUNCTION RMSE, X, Y, N=N, ERROR=ERROR, ERR_MSG=ERR_MSG

;+
; NAME:
;		RMSE
;
; PURPOSE:
;		This FUNCTION Computes the Root Mean Square Error between two variables, x & y
;
; CATEGORY:
;		STATISTICS
;
; CALLING SEQUENCE:
;		Result = rms(x,y)
;
; INPUTS:
;		X = Actual or "true" data (in situ)
;		Y = Modeled or "observed" data (satellite)
;
; KEYWORD PARAMETERS:
;
; OUTPUTS:
;		RMS: The root-mean-square difference between X and Y.
;		N: Number of valid X & Y data pairs
;		ERROR: 0=OK, 1=ERROR
;		ERR_MSG: Error Message
;
;	EXAMPLE:
;
;		X=1.0 & Y = 1.2 & PRINT, RMSE(x,y) 
;		X=[1.0,2.0,3.0] & Y = [1.1,1.9,3.1]  & PRINT, RMSE(x,y) 
;   X=[-9.0, 1.0,2.0,3.0] & Y = [0.1,1.1,1.9,3.1]  & PRINT, RMSE(x,y) 
;		X=[-9.0, 1.0, 2.0, 3.0] & Y = [0.1, 1.1, 1.9, 999D]  & PRINT, RMSE(x,y) 
;		X=[-9.0, 1.0, 2.0, 3.0] & Y = [0.1, 1.1, 1.9, 999D]  & PRINT, RMSE(x,y) 
;		X=[-9.0, 1.0, 2.0, 3.0] & Y = [0.1, 1.1, 1.9, !VALUES.F_INFINITY] & PRINT, RMSE(x,y,N=N) & PRINT, N 
;		X=[0, 1, 2, 3] & Y = [0, 1, 1, 32767]  & PRINT, RMSE(x,y) 
;
; MODIFICATION HISTORY:
;		Written Nov 13, 1994 by J.O'Reilly, 28 Tarzwell Drive, NMFS, NOAA 02882 (Jay.O'Reilly@NOAA.GOV)
; 	June 13,1995 JOR Returns a structure with RMS and N
;		Dec 10, 2006 JOR Added ERROR and ERR_MSG to structure
;   May 17, 2015 - KJWH: Removed the structure and now returning just the RMSE value
;                        Changed name to RMSE
;                        
;-
;	****************************************************************************************************
	ROUTINE_NAME = 'RMSE'
  RMSE = []
  ERROR = 0
  ERR_MSG = ''


;	===> Ensure that X,Y have the same number of elements
	IF N_ELEMENTS(X) NE N_ELEMENTS(Y) THEN BEGIN
    ERROR = 1 
	  ERR_MSG='X &Y must be the same size' 
	  RETURN, RMSE
	ENDIF
	
	XX = DOUBLE(X)
	YY = DOUBLE(Y)

;	===> Find the pairs of good (non-missing) and FINITE data
  OK = WHERE(XX NE MISSINGS(XX) AND YY NE MISSINGS(YY),N)

  IF N GE 1 THEN RMSE = FLOAT((TOTAL((XX[OK]-YY[OK])^2.0)/N)^0.5)
  RETURN, RMSE

	END; #####################  End of Routine ################################

