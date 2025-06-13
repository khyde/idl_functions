; $Id:	pbmax_mb.pro,	June 15 2007	$

   FUNCTION PBOPT_MB, SST=sst, CHL=chl
;+
; NAME:
;       PBOPT_MB
;
; PURPOSE:
;       Return the mean Massachusetts Bay Pbmax (see Chapter 2, Hyde dissertation, 2006)
;
;       Written by:			K.J.W. Hyde		December 14, 2006 - return the median Pbmax value (2.508)
;				Modified by:		K.J.W. Hyde		June 15, 2007 - changed the median Pbmax value to a temperature and chlorophyll
;                                                     dependent model by Kameda & Ishizaka (2005)


	pbopt = 2.2567244
	pbopt = 2.68482			; Jan 27, 2008

  RETURN, PBOPT

END ; END OF PROGRAM
