; $Id: gausprof.pro, v 1.0 1995/05/01 12:00:00 J.E.O'Reilly Exp $

Function gausprof,$
    b0=b0,h=h,sigma=sigma,Zm=Zm,rho=rho,$
    waterdepth=waterdepth,vresolution=vresolution
;+
; NAME:
;       gausprof
;
; PURPOSE:
;       Generate vertical profile of chlorophyll concentration
;      	Using model of  Platt, Caverhill and Sathyendranath, 1991
;
; CATEGORY:
;      Models
;
; CALLING SEQUENCE:
;       result = gausprof()
;		result = gausprof(Zm=15)
;
; INPUTS:
;       None
;
; KEYWORD PARAMETERS:
;      	Zm:		Depth of chlorophyll maximum
;		b0: 	Baseline (background; surface) chlorophyll concentration
;     	h:		Statistical parameter
;		sigma:	Statistical parameter related to the width (spread) of the subsurface
;				chlorophyll maximum
;		ymax:	Depth of water column (max value for the y axis)
;		xmax: 	Maximum value for the x axis
; OUTPUTS:
;    	Plot on screen
;
; SIDE EFFECTS:
;       None.
;
; RESTRICTIONS:
;       None.
;
; PROCEDURE:
;       Straightforward.
;
; MODIFICATION HISTORY:
;       Written by:  J.E.O'Reilly, May, 1995.
;		NOAA, NMFS, Narragansett Laboratory, 28 Tarzwell Drive, Narragansett, RI 02882-1199
;		oreilly@fish1.gso.uri.edu
;-

; ====================>
; Check which keywords were supplied by user and
; supply default values to program if user did not provide them

IF KEYWORD_SET(waterdepth) EQ 0 THEN waterdepth=100
IF KEYWORD_SET(Zm) EQ 0 THEN Zm=20
IF KEYWORD_SET(b0) EQ 0 THEN b0=0.5
IF KEYWORD_SET(h) EQ 0 THEN h=10
IF KEYWORD_SET(sigma) EQ 0 THEN sigma = 2
IF KEYWORD_SET(rho) EQ 0 THEN rho = 30
IF KEYWORD_SET(vresolution) EQ 0 THEN vresolution = 0.1   ; meters
vresolution = DOUBLE(vresolution)

; ====================>
; Create an integer  variable (Z)
  Z=INDGEN(FIX(waterdepth)*(1/vresolution)+1)/(1/vresolution)

; ===================>
; Create chlorophyll concentration profile using:
; Platt, Caverhill and Sathyendranath (1991) EQUATION 1, p. 15,148

; NOTE: This equation is bases on the Standard Gaussian
; See:
; Doudy,S. and S. Wearden, 1983. Statistics for Research
; John Wiley and Sons, New York, 537p.
; p.144
; f(y) = (1/(sigma*(2!pi)^0.5)) * exp -( ((y-u)^2.0) / (2*sigma^2.0))
;

  IF KEYWORD_SET(SIGMA) AND KEYWORD_SET(h) THEN BEGIN
    bz= b0+ $
        h/(SIGMA*((2*!PI)^0.5) )*$
              exp( (-(Z-Zm)^2) / (2.0*sigma^2) )
  ENDIF

  IF KEYWORD_SET(RHO)AND KEYWORD_SET(SIGMA) THEN BEGIN
    Bz = (1+RHO* EXP(-((Z-Zm)^2/(2*SIGMA^2))))
  ENDIF


  RETURN,Bz
  END  ; End of Program