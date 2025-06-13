; $Id: chlprof1.pro, v 1.0 1995/05/01 12:00:00 J.E.O'Reilly Exp $

PRO CHLPROF1, Zm=Zm, b0=b0, h=h, sigma=sigma, xmax=XMAX, ymax=YMAX
;+
; NAME:
;       chlprof1
;
; PURPOSE:
;       Generate vertical profile of chlorophyll concentration
;      	Using model of  Platt, Caverhill and Sathyendranath, 1991
;
;
; CATEGORY:
;      Models
;
; CALLING SEQUENCE:
;       chlprof1
;		chlprof1,  Zm=15
;		chlprof1,  zm=15,  b0=1
;		chlprof1, zm = 16, b0=.6, xmax = 15, ymax=50
;
; INPUTS:
;       None
;
; KEYWORD PARAMETERS:
;      	Zm:		Depth of chlorophyll maximum
;		b0: 	 Baseline (background; surface) chlorophyll concentration
;     	h:		 Statistical parameter
;		sigma:	Statistical parameter related to the width (spread) of the subsurface
;						chlorophyll maximum
;		ymax:		   Depth of water column (max value for the y axis)
;		xmax:    Maximum value for the x axis
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
;-

; ====================>
; Check which keywords were supplied by user and
; supply default values to program if user did not provide them
IF KEYWORD_SET(xmax) EQ 0 THEN xmax=10
IF KEYWORD_SET(ymax) EQ 0 THEN ymax=80
IF KEYWORD_SET(Zm) EQ 0 THEN Zm=20
IF KEYWORD_SET(b0) EQ 0 THEN b0=0.5
IF KEYWORD_SET(h) EQ 0 THEN h=10
IF KEYWORD_SET(sigma) EQ 0 THEN sigma = 2

; ====================>
; Create an integer  variable (Z)
 Z=INDGEN(ymax*10+1)/10.

 ; ====================>
 ; Make background plot color black and plotted data white
  !P.BACKGROUND = 0
  !P.COLOR      = 255

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

; Normal form of Platt et al. equation
; bz= b0+ $
;        h/(SIGMA*((2*!PI)^0.5) )*$
 ;      exp( (-(Z-ZM)^2) / (2.0*sigma^2) )

 ; Background chl decreases with increasing distance from surface
 ;   bz= b0*exp(-(z/zm))+ $
  ;         h/(SIGMA*((2*!PI)^0.5) )*$
   ;       exp( (-(Z-ZM)^2) / (2.0*sigma^2) )

 ;  bz= b0+ b0*exp(-(z-zm)^0.5/zm)+ $
 ;          h/(SIGMA*((2*!PI)^0.5) )*$
 ;         exp( (-(Z-ZM)^2) / (2.0*sigma^2) )

  bz=b0*exp(-(z-zm)/zm)
; ====================>
; Plot the chl-biomass profile (bz) vs depth(z)
  PLOT,bz,-1.0*z,$
  title='Platt, Caverhill and Sathyendranath, 1991',charsize=.75,color=!p.color,$
  xticklen=1,xgridstyle=1 ,$
  yticklen=1,ygridstyle=1 ,$
  yticks=FLOOR(ymax/10.0), xticks=xmax,$
  xminor=1,yminor=1,$
  xrange = [0,xmax],$
  yrange=[-1.0*max(z),0],ystyle=17,$
  xtitle = 'Pigment',ytitle='Depth'

; ====================>
; Compute the 'SSR'
;  Subsurface chl maximum to surface (background) chlorophyll ratio:
; Platt, Caverhill and Sathyendranath (1991) EQUATION 2, p. 15,148

;  NOTE: possibly an error in the Plat et al. 1991 paper in following equation:
;  p = h/(b0*sigma*(2*!PI)^0.5) ???
; ??? Should be p = 1 + h/(b0*sigma*(2*!PI)^0.5)
; Divide the amplitude (b0+ h/(SIGMA*((2*!PI)^0.5) )
; by b0 yields:

  p = 1 + h/(b0*sigma*(2*!PI)^0.5)
  xyouts,max(bz),-1*zm,'SSR='+STRTRIM(STRING(p),2)

; ====================>
; Compute the water column integrated Pigment (ug/m2)

; The program int_tabulated is in IDL version 4.0 (do not know if
; it is in earlier versions of idl

  Cw = INT_TABULATED(Z,BZ)
  xyouts,.25,(-1*max(z)+0.05*max(z)),'Cw='+STRTRIM(STRING(Cw),2)


                    stop
END  ; End of Program