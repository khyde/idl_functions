; $Id:	PAR_FROUIN.PRO,	2003 Oct 29 07:45	$

FUNCTION PAR_FROUIN, SOLZEN=SOLZEN, DIST_AU=dist_au, VIS_KM=vis_km, AEROSOL=aerosol, Uv=Uv,Uo=Uo,R=r, NM_RANGE=nm_range, SHOW=show

;+
; NAME:
;       PAR_FROUIN
;
; PURPOSE:
;       Compute Total Irradiance and PAR
;
; CATEGORY:
;       Light
;
; CALLING SEQUENCE:
;       Result = PAR_FROUIN(Solzen)
;
; INPUTS:
;
;	SOLZEN: 	Solar Zenith Angle (degrees)								Mandatory Input
;	DIST_AU:	Sun-Earth Distance in Astronomical Units,  	(Default is 1.0 AU)
;	VIS_KM:		Surface Visibility in km 										(default = 23 KM)
;
;	AEROSOL:	Type, 0 or 1							  								(default is 0)
;						0 = MARITIME
;						1 = CONTINENTAL
;
;	Uv:				Total Water Vapor amount	 									(Default is 1.4 g cm-2)
;	Uo:				Total Ozone Amount													(Default is 0.34 atm cm)
;
;	R:				Average Surface Reflectance									(Default is 0.05)
;
; NM_RANGE:	Specifies the Spectral_interval 						(default is 1)
;						0= 350-700nm
;						1= 400-700nm
;						2= 250-4000nm
;
;	SHOW: 		Prints Inputs, Intermediate Calculations, and PAR estimate.
;
;
; OUTPUTS:
;
;	 PAR in units of Watts per meter-square for the nm_range specified
;
;
; RESTRICTIONS:
;
;		SOLZEN  is in Degrees
;   DIST_AU is in Astronomical Units (Minimum Sun-Earth-Distance: 0.983291 AU, Jan 03,Maximum Sun-Earth-Distance: 1.01671 AU, Jul 04)
;		VIS_KM 	is in Kilometers
;
;	NOTES:
;		Calculation of PAR is based on:
;       Frouin, R., D.W. Lingner, C. Gautier, K.S. Baker, and R.C. Smith.  1989.
;           A simple analytical formula to compute clear sky total and photosynthetically availble
;           solar irradiance at the ocean surface.  J. Geophysical Research  94(C7):9731-9742.
;
;	## Equation 1 in Frouin et al. 1989 paper should be (d0/d)^2 not as it is in the paper (d/d0)^2  in their Equations 1 and 6
;  Email from R.Frouin to J.O'Reilly, Oct 28,2003:
;	"There is a typo in the equation, it's actually (do/d)^2. Obviously when the actual distance (d) is larger than the average distance
;	"(do), the correction factor should be smaller (less irradiance since the sun is farther away)."
;
;		McClatchey 1972 Standard Atmosphere, Frouin et al. 1989, page 9733
; 	Uv  = 1.4  ; (g cm-2)
; 	Uo  = 0.34 ; (atm cm) total ozone
;
;		V   = 23.0 ; (km)     Surface Visibility used by Frouin et al.
;
;
; MODIFICATION HISTORY:
;				From Equation 6 in Frouin et al. 1989.
;       Written by:  J.E.O'Reilly, July 6,1999
;				October 28, 2003,JOR, Fixed error based on Personal Communication from R.Frouin: Changed (d/d0)^2  to  (d0/d)^2

;-

	ROUTINE_NAME='PAR_FROUIN'

;	*************************************************************************************************
;	*********************   I N P U T S   AND  D E F A U L T S   ************************************
;	*************************************************************************************************
	IF N_ELEMENTS(SOLZEN) 	EQ 0 THEN STOP 		; SOLZEN is a MANDATORY input

	IF N_ELEMENTS(DIST_AU)  EQ 0 THEN D = 1.0		ELSE D = DIST_AU
	IF N_ELEMENTS(VIS_KM) 	NE 1 THEN V = 23 		ELSE V = VIS_KM ; Surface Visibility (KM)
	IF N_ELEMENTS(AEROSOL) 	NE 1 THEN AEROSOL 	= 0 						; MARITIME Aerosol model

;	===> McClatchey 1972 Standard Atmosphere
 	IF N_ELEMENTS(Uv) 			NE 1 THEN Uv  			= 1.4  					; (g cm-2)
 	IF N_ELEMENTS(Uo)				NE 1 THEN Uo  			= 0.34 					; (atm cm) total ozone
 	IF N_ELEMENTS(R) 				NE 1 THEN R 				= 0.05  				; Average Surface Reflectance (R.Frouin)

 	IF N_ELEMENTS(NM_RANGE) NE 1 THEN NM_RANGE 	= 1 ; 400-700nm ; The Usual PAR Wavelength Range
;	--------------------------------------------------------------------------------------------


;	*************************************************************************************************
;	************************** C O N S T A N T S  ***************************************************
;	*************************************************************************************************
;	===> Mean sun-earth distance (by defination is 1 AU)
  D0 = 1.0D ; AU

; ====================>
; Table 1. Top-of-atmosphere solar irradiance in the spectral intervals considered (Frouin et al. 1989)
; Spectral_interval = ['350-700','400-700','250-4000'] ; nm
  Solar_irradiance  = [ 584.9,      531.2,     1358.2] ; Wm-2

;	Table 2. Regression Coefficients for Analytical Formulas (Frouin et al. 1989)
  Spectral_interval = [ '350-700',     '350-700',  '400-700',     '400-700', '250-4000',    '250-4000'] ; nm
  aerosol_type      = ['maritime', 'continental', 'maritime', 'continental', 'maritime', 'continental']
  a                 = [     0.079,         0.089,      0.068,         0.078,      0.059,         0.066]
  b                 = [     0.378,         0.906,      0.379,         0.882,      0.359,         0.704]
  ap                = [     0.132,         0.138,      0.117,         0.123,      0.089,         0.088]
  bp                = [     0.470,         0.576,      0.493,         0.594,      0.503,         0.456]
  av                = [     0.002,         0.002,      0.002,         0.002,      0.102,         0.102]
  bv                = [     0.87 ,         0.87 ,      0.87 ,         0.87 ,      0.29 ,         0.29 ]
  ao                = [     0.047,         0.047,      0.052,         0.052,      0.041,         0.041]
  bo                = [     0.99 ,         0.99 ,      0.99 ,         0.99 ,      0.57 ,         0.57 ]
;	------------------------------------------------------------------------------------------------------

;	===> Get the Solar_irradiance
	I0 = Solar_irradiance(nm_range)

;	===> Get the index for the column # in Table 2 (beginning with 0th column)
 	index = nm_range*2 + aerosol

; ===> Get the parameters from Table 2
 	Spectral_interval=Spectral_interval(index)
 	aerosol_type = aerosol_type(index)
 	a    = DOUBLE(a(index))
 	b    = DOUBLE(b(index))
 	ap   = DOUBLE(ap(index))
 	bp   = DOUBLE(bp(index))
 	av   = DOUBLE(av(index))
 	bv   = DOUBLE(bv(index))
 	ao   = DOUBLE(ao(index))
 	bo   = DOUBLE(bo(index))


;	===> Convert solar zeneith degrees to radians for trig functions to work below
 	rsol_zen =!dtor*SOLZEN

	I = (I0 * (D0/D)^2) $
  * ( COS(rsol_zen) *   EXP(- (a+b/V)/COS(rsol_zen)) / ( 1- R*(ap + bp/V)) )  $
  * ( EXP(-av*(Uv/COS(rsol_zen))^bv)  )   $
  * ( EXP(-ao*(Uo/COS(rsol_zen))^bo)  )

;	===> Ensure I is at least zero and not NAN
  I = I > 0.0

 IF KEYWORD_SET(SHOW) THEN BEGIN
 	print,'nm_range aerosol   interval  Solar_irr    alpha      beta       ap        bp          av        bv        ao        bo      SolZen  PAR (WM-2)'
 	FOR NTH=0,N_ELEMENTS(I)-1 DO  print, nm_range,aerosol_type,Spectral_interval,I0,A,B,ap,bp,av,bv,ao,bo,SOLZEN(nth),I(nth),format='(I10,2A10,11F9.3)'
 ENDIF

 RETURN,I

END; #####################  End of Routine ################################
