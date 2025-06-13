; $ID:	CHL_PROFILE_MOREL_BERTHON_FIG7B_DEMO.PRO,	2020-06-30-17,	USER-KJWH	$

PRO CHL_PROFILE_MOREL_BERTHON_FIG7B_DEMO,Cpd=Cpd,ze=ZE, px=PX,PNG=PNG
;+
; NAME:
;       CHL_PROFILE_MOREL_BERTHON_FIG7B_DEMO
;
; PURPOSE:
;       Generate vertical profiles of chlorophyll concentration using model of:
;      	A. Morel and J.F. Berthon (1989)
;		Surface pigments, aglal biomass profiles, and potential production of the euphotic layer:
;		Relationships reinvestigated in view of remote-sensing applications.
;		Limnol. Oceanogr., 34(8):1545-1562.
;
; CATEGORY:
;      Models
;
; CALLING SEQUENCE:
;       CHL_PROFILE_MOREL_BERTHON_FIG7B_DEMO
;		CHL_PROFILE_MOREL_BERTHON_FIG7B_DEMO, Cpd = 1.0
;  		CHL_PROFILE_MOREL_BERTHON_FIG7B_DEMO, Cpd = [ 0.015625, 0.03125, 0.0625, 0.125,0.25,0.5,1,2,4,8,16]
;		CHL_PROFILE_MOREL_BERTHON_FIG7B_DEMO, Cpd = [ 0.03125, 0.0625, 0.125,0.25,0.5,1,2,4,8,16]  , px = 1200, /PNG
;
; INPUTS:
;       None
;
; KEYWORD PARAMETERS:
;  		Cpd:    Mean  chl in the upper light penetration depth ( Cpd ~=~ sat chlorophyll, according to Morel and Berthon)
; 		Ze :    Euphotic Depth
;		PNG:    Set this keyword to generate a PNG file of the graph.
; 		_extra:	This allows the user to pass additional valid plot commands (e.g. color=128) to the program
;
; OUTPUTS:
;    	Plot on screen
;		PNG graphics file
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
; NOTES:
; ===================>
; Create chlorophyll concentration profile using:
; Morel and Berthon (1989) p.1557, equation 6
; To simulate profile shapes shown on page 1555, Fig. 7b.
; This equation is based on the Standard Gaussian. See:
; Doudy,S. and S. Wearden, 1983. Statistics for Research
; John Wiley and Sons, New York, 537p.
; p.144
; f(y) = (1/(sigma*(2!pi)^0.5)) * exp -( ((y-u)^2.0) / (2*sigma^2.0))
;
; Also note that symbolic terms of Platt et al. 1991 are  used when possible
; Normal form of Platt et al. 1991 equation:
; bz= b0+   h/  (SIGMA*((2*!PI)^0.5) ) * exp( (-(Z-ZM)^2) / (2.0*sigma^2) )
;
; Morel and Berthon 1989 formulation:
; B_Cze =  b0+    bm * exp( -(  ((Zze-Zm) /ht)^2.0)    )
; or :
; B_Cze =  b0+    bm * exp( -  (Zze-Zm)^2.0 /  ht^2.0    )
;
; B_Cze is  chl / avg. euphotic chl
; B0 is background chl
; Bm is the biomass maximum:		Bm ~= h/  (SIGMA*((2*!PI)^0.5) ) in Platt et al. equation
; Zze is depth below surface, scaled to euphotic depth.
; Zm  is the depth of the chl maximum
; ht is the bump thickness parameter:    	ht  ~=  (2.0*sigma^2) in Platt et al. equation
;
; MODIFICATION HISTORY:
;       Written by:  J.E.O'Reilly, July, 1995.
;		NOAA, NMFS, Narragansett Laboratory, 28 Tarzwell Drive, Narragansett, RI 02882-1199
;		oreilly@fish1.gso.uri.edu
;-

; ====================>
; Check  keywords  supplied by user and set default values

  IF KEYWORD_SET(Cpd) EQ 0 THEN Cpd = [0.040, 0.101, 0.211, 0.368, 0.791, 2.664, 9.058]
;   The default values for Cpd are those in Morel and Berthon (1989) p. 1553, table 3, Avg. Cpd
;   These Cpd values generate curves a-g in their figure 7a when using their statistical model
;   which computes background chl, max chl, depth of chl max and 'bump spread' using
;   only the value of Cpd and model coefficients.

  IF KEYWORD_SET(Ze) EQ 0 THEN Ze = 50   ; default euphotic depth = 50m
  IF KEYWORD_SET(px) EQ 0 THEN px = 600  ; default width (pixels) of graphics window.
; (px = 1200 is good size for PNG output)

; ====================>
; Create an integer  variable (Z) , tenths of meter resolution, twice the euphotic depth
  xmax=4.0          ; x-axis maximum
  ymax = 2.0        ; y-axis maximum (2 euphotic depths).
  increments = ymax*Ze*10+1
  Z=INDGEN(increments)/10.
  Zze = z / ze      ;  scale depths by euphotic depth

  Cpd = DOUBLE(Cpd) ; make double precision so following calculations will all be double precision

; ====================>
; Set some graphics defaults

; Make background plot color white and plotted data black
  !P.BACKGROUND =255       ; white background
  !P.COLOR      = 0	       ; black lines
  !P.THICK      = px/400.0
  !P.CHARTHICK  = px/600.0
  !P.CHARSIZE   = px/600.0 ;  default character size for plot
  !X.THICK      = px/600.0
  !Y.THICK      = px/600.0
  _FONT = '!3'     ; idl default font (Simplex Roman);  !5 = Duplex Roman;  !17 =Triplex Roman

; ====================>
; Open a graphics window (sliding window)
  image = bytarr(px,px)
;  SLIDE_IMAGE,image,xvisible=600,yvisible=600,SHOW_FULL=0,title='Morel and Berthon (1989)'
  ERASE,255b

; Morel and Berthon (1989) page 1557, equation 6 :
; Note they used log base 10 in their equations.
  B0 = 0.768 + ( 0.087 * ALOG10(Cpd) ) - ( 0.179 * (ALOG10(Cpd))^2.0 ) - ( 0.025 * (ALOG10(Cpd))^3.0 )
  Bm = 0.299 - ( 0.289 * ALOG10(Cpd) ) + ( 0.579 * (ALOG10(Cpd))^2.0 )
  Zm = 0.600 - ( 0.640 * ALOG10(Cpd) ) + ( 0.021 * (ALOG10(Cpd))^2.0 ) + ( 0.115 * (ALOG10(Cpd))^3.0 )
  ht = 0.710 + ( 0.159 * ALOG10(Cpd) ) + ( 0.021 * (ALOG10(Cpd))^2.0 )

  B_Cze = DBLARR(N_ELEMENTS(B0),N_ELEMENTS(Zze))   ; Dimension array B_Cze

; ====================>
; Now for each of the values in the Cpd array, plot the modeled profile of the ratio of
; chl / mean euphotic chl versus depth scaled to euphotic depth
  FOR i = 0, N_ELEMENTS(Cpd)-1 DO BEGIN
    B_Cze(i,*) =  b0(i)+ bm(i) * exp( -( ( (Zze-Zm(i)) /  ht(i))^2.0) ) ; chl / mean euphotic chl  profile

;   After the first curve  is drawn overplot subsequent curves without erasing previous ones
    IF i EQ 0 THEN BEGIN

      PLOT, B_Cze(I,*),-1.0*Zze,$
      charsize=1.4*!P.charsize,$
      xrange =[0,xmax], xstyle = 1,xticklen=1,  xgridstyle=1 , $
      xticks=FLOOR(xmax/10.0),     xminor=5,    xtitle = 'B / B!Dpd' , $
      yrange= [-1.0*max(Zze),0],   ystyle = 1,  yticklen=1,  ygridstyle=1 , $
      yticks=FLOOR(ymax/10.0),     yminor=5,    ytitle='Z / Z!De'

    ENDIF ELSE BEGIN   ; if i > 0 overlay remaining curves
      OPLOT,  B_Cze(I,*),-1.0*Zze , $
      linestyle=0
;     linestyle = i MOD 2  ; alternate line style solid dash solid dash...
    ENDELSE
  ENDFOR

; ====================>
; Now Add Table of Profile Parameters
   xoffset= 0.98*xmax
   yoffset= -0.11*ymax
   XYOUTS,/DATA,xoffset,yoffset,_FONT+'Morel and Berthon (1989)' ,$
                   charsize=!P.CHARSIZE, ALIGN=1.0 ,color=128
   yoffset = yoffset - 0.1
   XYOUTS,/DATA,xoffset,yoffset,_FONT+'B!Dpd!N  Z!DMax!N   SSR' ,$
                  charsize=!P.CHARSIZE, ALIGN=1.0 ,color=128

  FOR i = 0, N_ELEMENTS(Cpd)-1 DO BEGIN
     letter = STRING(BYTE(65+i))
     str_Cpd = STRING(Cpd(i),FORMAT='(F6.3)')      ; Cpd (Sat chl)
     str_ssr   =  STRING(   (MAX(B_Cze(i,*)) / B_Cze(i,0)),  FORMAT='(F5.2)')  ;Subsurface/surface chl ratio
     zmax    = WHERE(B_Cze(i,*) EQ MAX(B_Cze(i,*))  )
     zmax    = zmax[0]
     zmax    = Zze(zmax)
     str_zmax = STRING(zmax, FORMAT='(F4.2)'  )
     XYOUTS, /DATA, B_Cze(i,0), 0.03,_FONT+ letter, align=0.5 , charsize=!P.CHARSIZE ; label top of profile
     yoffset = yoffset - 0.1
     txt = _FONT+letter +' '+ str_Cpd +' '+ str_zmax + ' ' + str_ssr ;an entry  for the table
     XYOUTS,/DATA,xoffset,yoffset,txt,charsize=!P.CHARSIZE, ALIGN=1.0 ,color=128
  ENDFOR

; ====================>
; Write PNG file
  IF KEYWORD_SET(PNG) THEN BEGIN
    LOADCT, 1
    TVLCT,R,G,B,/GET
    WRITE_PNG,'CHL_PROFILE_MOREL_BERTHON_FIG7B_DEMO.PNG', tvrd(), r,g,b
 ENDIF


END  ; End of Program
