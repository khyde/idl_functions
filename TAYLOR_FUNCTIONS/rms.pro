; $Id:	rms.pro,	March 05 2006, 14:39	$

FUNCTION RMS, X,Y, MISSING=MISSING

;+
; NAME:
;		RMS
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
;		X and Y
;
; KEYWORD PARAMETERS:
;		MISSING:
;			Value to be used to for missing data which will be excluded from the rms statistic.
;			If MISSING is a single element then it will be used to exclude the missing value from
;			both X and Y data.
;
;			If Missing is an array of 2 elements then this routine assumes that MISSING(0) applies to X
;			and MISSING(1) applies to Y.
;
; OUTPUTS:
;		A structure with the following tags:
;			N: The number of non-missing pairs of X,Y
;			RMS: The root-mean-square difference between X and Y.
;			ERROR: 0=OK, 1=ERROR
;			ERR_MSG: Error Message
;
;	EXAMPLE:
;
;		X=1.0 & Y = 1.2 & Result = RMS(x,y) & HELP,/STRUCT, Result
;		X=[1.0,2.0,3.0] & Y = [1.1,1.9,3.1] & Result = RMS(x,y) & HELP,/STRUCT, Result
;   X=[-9.0, 1.0,2.0,3.0] & Y = [0.1,1.1,1.9,3.1] & Result = RMS(x,y, MISSING= -9) & HELP,/STRUCT, Result
;		X=[-9.0, 1.0, 2.0, 3.0] & Y = [0.1, 1.1, 1.9, 999D] & Result = RMS(x,y, MISSING= [-9,999]) & HELP,/STRUCT, Result
;		X=[-9.0, 1.0, 2.0, 3.0] & Y = [0.1, 1.1, 1.9, 999D] & Result = RMS(x,y, MISSING= [-9,999]) & HELP,/STRUCT, Result
;		X=[-9.0, 1.0, 2.0, 3.0] & Y = [0.1, 1.1, 1.9, !VALUES.F_INFINITY] & Result = RMS(x,y) & HELP,/STRUCT, Result
;		X=[0, 1, 2, 3] & Y = [0, 1, 1, 32767] & Result = RMS(x,y) & HELP,/STRUCT, Result
;
; MODIFICATION HISTORY:
;		Written Nov 13, 1994 by J.O'Reilly, 28 Tarzwell Drive, NMFS, NOAA 02882 (Jay.O'Reilly@NOAA.GOV)
; 	June 13,1995 JOR Returns a structure with RMS and N
;		Dec 10, 2006 JOR Added ERROR and ERR_MSG to structure
;
;-
;	****************************************************************************************************
	ROUTINE_NAME = 'RMS'

;	===> Construct a STRUCTURE to hold statistical results
  struct = {n:0L,rms:MISSINGS(0.0D),error:0,err_msg:''}


;	===> Ensure that X,Y have the same number of elements
	IF N_ELEMENTS(X) NE N_ELEMENTS(Y) THEN BEGIN & struct.error = 1 & struct.err_msg='X &Y must be the same size' & RETURN,struct & ENDIF

; ===> Check keyword missing (MISSING may have only 1 or 2 elements)
	IF N_ELEMENTS(MISSING) GT 2 THEN BEGIN & struct.error = 1 & struct.err_msg='MISSING must have 2 or less elements' & RETURN,struct & ENDIF

;	===> If the value for missing is not provided then get the standard missing value
;			 based on the data type and the result from MISSINGS.PRO FUNCTION
  IF N_ELEMENTS(missing) EQ 0 THEN BEGIN
    _missing = [MISSINGS(X),MISSINGS(Y)]
  ENDIF ELSE BEGIN
    _missing = FLOAT(missing)
  ENDELSE

;	===> If missing has just one elements then duplicate it for use with both X and Y variables
	IF N_ELEMENTS(_MISSING) EQ 1 THEN _MISSING = [MISSING,MISSING]

;	===> Find the pairs of good (non-missing) and FINITE data
  ok = WHERE(FINITE(X) AND X NE _missing(0) AND FINITE(Y) AND Y NE _missing(1),count)

;	===> Fill the structure with N and the computed RMS
  struct.n =count
  IF COUNT GE 1 THEN struct.rms = (TOTAL( (ABS(X(ok)-Y(ok)))^2.0)^0.50)  /(count ^0.5)
  RETURN, struct

	END; #####################  End of Routine ################################

