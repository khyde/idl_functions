; $Id: chlprof2.pro, v 1.0 1995/07/01 12:00:00 J.E.O'Reilly Exp $

PRO CHLPROF2, ZE = Ze, Zm=Zm, b0=b0, h=h, sigma=sigma, xmax=XMAX  ,ymax=YMAX,cpd=CPD,_extra=e
;+
; NAME:
;       chlprof2
;
; PURPOSE:
;       Generate vertical profiles of chlorophyll concentration using model of
; 		 Morel, A. and J.F. Berthon (1989)
;		Surface pigments, aglal biomass profiles, and potential production of the euphotic layer:
;		Relationships reinvestigated in view of remote-sensing applications.
;		Limnol. Oceanogr., 34(8):1545-1562.
;
; CATEGORY:
;      Models
;
; CALLING SEQUENCE:
;       chlprof2
;		chlprof2,  Zm=15
;		chlprof2,  zm=15,  b0=1
;		chlprof2, zm = 16, b0=.6, xmax = 15, ymax=50
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

;  		cpd			avg chl in upper penetration depth    (sat chlorophyll)

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
;       Written by:  J.E.O'Reilly, July, 1995.
;-

; ====================>
; Check which keywords were supplied by user and
; supply default values to program if user did not provide them
IF KEYWORD_SET(xmax) EQ 0 THEN xmax=2.5
IF KEYWORD_SET(ymax) EQ 0 THEN ymax=0
IF KEYWORD_SET(Zm) EQ 0 THEN Zm=20
IF KEYWORD_SET(b0) EQ 0 THEN b0=0.5
IF KEYWORD_SET(Ze) EQ 0 THEN  ze   = 25 ; euphotic depth (meters)


IF KEYWORD_SET(cpd) EQ 0 THEN cpd = 1

; ====================>
; Create an integer  variable (Z) , tenths of meter resolution, twice the euphotic depth
 Z=INDGEN(2*Ze*10+1)/10.

 ; ====================>
 ; Make background plot color black and plotted data white
  !P.BACKGROUND = 0
  !P.COLOR      = 255

; ===================>
; Create chlorophyll concentration profile using:
; Morel and Berthon (1989) p.1557, equation 6
; To simulate profile shapes shown on page 1555, Fig. 7b.

; NOTE: This equation is based on the Standard Gaussian
; See:
; Doudy,S. and S. Wearden, 1983. Statistics for Research
; John Wiley and Sons, New York, 537p.
; p.144
; f(y) = (1/(sigma*(2!pi)^0.5)) * exp -( ((y-u)^2.0) / (2*sigma^2.0))
;

; Also note that symbolic terms of Platt et al. 1991 are  used when possible
; Normal form of Platt et al. 1991 equation:
; bz= b0+   h/  (SIGMA*((2*!PI)^0.5) ) * exp( (-(Z-ZM)^2) / (2.0*sigma^2) )

; Morel and Berthon 1989 formulation:
; Bze_Cze =  b0+    bm * exp( -(  ((Zze-Zm) /ht)^2.0)    )
; or :
; Bze_Cze =  b0+    bm * exp( -  (Zze-Zm)^2.0 /  ht^2.0    )

; Bze_Cze is  chl / avg. euphotic chl
; B0 is background chl
; Bm is the biomass maximum:  					Bm ~= h/  (SIGMA*((2*!PI)^0.5) ) in Platt et al. equation
; Zze is depth below surface, scaled to euphotic depth.
; Zm  is the depth of the chl maximum
; ht is the bump thickness parameter:    	ht  ~=  (2.0*sigma) in Platt et al. equation

; ====================>
;  Morel and Berthon (1989) page 1557, equation 6 :

  cpd = DOUBLE(cpd)
  B0 =  0.768 + (  0.087 * ALOG10(Cpd)  )  - (  0.179 * (ALOG10(Cpd))^2.0  )  -  (  0.025 * (ALOG10(Cpd))^3.0 )
  Bm = 0.299 - (  0.289 * ALOG10(Cpd)  ) + (  0.579 * (ALOG10(Cpd))^2.0  )
  Zm = 0.600 - (  0.640 * ALOG10(Cpd)  ) + (  0.021 * (ALOG10(Cpd))^2.0  ) +  (  0.115 * (ALOG10(Cpd))^3.0 )

  ht   = 0.710 + (  0.159 * ALOG10(Cpd)  ) + (  0.021 * (ALOG10(Cpd))^2.0  )

  Zze = z / ze    ;  scale depths by euphotic depth

  Bze_Cze =  b0+    bm * exp( -(  ( (Zze-Zm) /  ht)^2.0)    )      ; chl / avg. euphotic chl = ...

; bzz = Bze_Cze * Cze  ; biomass at depths scaled by euphotic depth

; ====================>
; Plot the chl-biomass profile (bz) vs depth(z)
  PLOT, Bze_Cze,-1.0*Zze,$
  title='Morel and Berthon 1989',charsize=.75,color=!p.color,$
  xticklen=1,xgridstyle=1 ,$
  yticklen=1,ygridstyle=1 ,$
  yticks=FLOOR(ymax/10.0), xticks=FLOOR(xmax/10.0),$
  xminor=5,yminor=5,$
  xrange = [0,xmax],$
  yrange=[-1.0*max(Zze),0],$
  xstyle = 1, ystyle = 1, $
  xtitle = 'C / Cpd',ytitle='Z / Ze', $
  _extra = e

; ====================>
; Compute the 'SSR'
;  Subsurface chl maximum to surface (background) chlorophyll ratio:
; Platt, Caverhill and Sathyendranath (1991) EQUATION 2, p. 15,148

;  NOTE: possibly an error in the Plat et al. 1991 paper in following equation:
;  p = h/(b0*sigma*(2*!PI)^0.5) ???
; ??? Should be p = 1 + h/(b0*sigma*(2*!PI)^0.5)
; Divide the amplitude (b0+ h/(SIGMA*((2*!PI)^0.5) )
; by b0 yields:

;  p = 1 + h/(b0*sigma*(2*!PI)^0.5)
;  xyouts,max(bz),-1*zm,'SSR='+STRTRIM(STRING(p),2)

; ====================>
; Compute the water column integrated Pigment (ug/m2)

; The program int_tabulated is in IDL version 4.0 (do not know if
; it is in earlier versions of idl

 ; Cw = INT_TABULATED(Z,BZ)
;  xyouts,.25,(-1*max(z)+0.05*max(z)),'Cw='+STRTRIM(STRING(Cw),2)



END  ; End of Program