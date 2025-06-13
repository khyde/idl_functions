; $ID:	CHL_PROFILE_MOREL_BERTHON.PRO,	2004 08 03 09:41	$

  FUNCTION CHL_PROFILE_MOREL_BERTHON,CCpd, RES=res, ZMAX=zmax , ALLOW_ERRORS=ALLOW_ERRORS
;+
; NAME:
;       CHL_PROFILE_MOREL_BERTHON
;
; PURPOSE:
;       Generate vertical profiles of chlorophyll concentration using model of:
;      	A. Morel and J.F. Berthon (1989)
;		Surface pigments, aglal biomass profiles, and potential production of the euphotic layer:
;		Relationships reinvestigated in view of remote-sensing applications.
;		Limnol. Oceanogr., 34(8):1545-1562.
;
;
; CALLING SEQUENCE:
;
;				STRUCT = CHL_PROFILE_MOREL_BERTHON(0.101);
;
; INPUTS:
;       CCpd  Average Chlorophyll in the first photic depth ( cpd ~=~ sat chlorophyll, according to Morel and Berthon)
;
; KEYWORD PARAMETERS:
;  		RES:    Resolution in units of Zze (Z/Ze) for the optical depth (default = 0.01)
; 		ZMAX:   The maximum number of euphotic depths to construct the profile (usually 2 or 3)
;			ALLOW_ERRORS: Allows CCpd values to be below 0.02 or above 10.0 mg m-3
;										(to see functional responses outside the Cpd range for which Morel & Berthon parameterized these functions)
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
; Normal form of Platt et al. 1991 equation:
; bz= b0+   h/  (SIGMA*((2*!PI)^0.5) ) * exp( (-(Z-ZM)^2) / (2.0*sigma^2) )
;
; Morel and Berthon 1989 formulation:
; C_Cze =  b0+    Cm * exp( -(  ((Zze-Zm) /ht)^2.0)    )
; or :
; C_Cze =  b0+    bm * exp( -  (Zze-Zm)^2.0 /  ht^2.0    )
;
; C_Cze is  chl / avg. euphotic chl
; B0 is background chl
; Bm is the biomass maximum:		Bm ~= h/  (SIGMA*((2*!PI)^0.5) ) in Platt et al. equation
; Zze is depth below surface, scaled to euphotic depth.
; Zm  is the depth of the chl maximum
; ht is the bump thickness parameter:    	ht  ~=  (2.0*sigma^2) in Platt et al. equation

;	****************************************************************************************
; ! Morel and Berthon Page 1557-1558:
;	"It must be emphasized that use of the above parameterization must be restricted to the
;  range of Cpd values extending from about 0.02 to 10 mg m-3, namely the range envisaged
;  when fitting the analytical equations to the actual profiles"

;	CONSEQUENTLY, THIS PROGRAM SETS CPD VALUES BELOW 0.02 TO 0.02 AND VALUES ABOVE 10 TO 10
;	AND RETURNS AN ERROR CODE WITH THE STRUCTURE
;	****************************************************************************************
;
; MODIFICATION HISTORY:
;   Written by:  J.E.O'Reilly, July, 1995.
;		NOAA, NMFS, Narragansett Laboratory, 28 Tarzwell Drive, Narragansett, RI 02882-1199
;		oreilly@fish1.gso.uri.edu
;		August 2, 2004 J.O'R Added the computed chlorophyll profiles to output structure
;-

	ROUTINE_NAME = 'CHL_PROFILE_MOREL_BERTHON'

; =====> Check  keywords  supplied by user and set default values
  IF N_ELEMENTS(CCpd)  NE 1 THEN RETURN, -1  ; Because returning an array only input one Cpd at a time

  IF N_ELEMENTS(ZMAX) LT 1 THEN _Zmax = 2 		ELSE _ZMAX=ZMAX   ;
  IF N_ELEMENTS(RES)  LT 1 THEN _RES  = 0.01 	ELSE _RES = RES ; default vertical resolution in euphotic depth units

; =====> Create an integer  variable (Z) with resolution= RES
  Zze=INDGEN(_Zmax/_RES)*_RES

	Cpd = CCpd

	ERROR='0'
	IF NOT KEYWORD_SET(ALLOW_ERRORS) THEN BEGIN
		IF Cpd LT 0.02 THEN BEGIN
			CPD= 0.02
	 	ERROR = 'Cpd TOO LOW: CHANGED TO 0.02)
		ENDIF
		IF Cpd GT 10.0 THEN BEGIN
			Cpd = 10.0
			ERROR = 'Cpd TOO HIGH; CHANGED TO 10.0)
		ENDIF
	ENDIF


; ********************************************************************************************************
; Genereate profile of the ratio of chl/(mean euphotic chl) versus depth scaled to euphotic depth
; Morel and Berthon (1989) page 1557, Equation 6 (Note they used log base 10 in their equations).
  Cb      = 0.768 + ( 0.087 * ALOG10(Cpd) ) - ( 0.179 * (ALOG10(Cpd))^2.0 ) - ( 0.025 * (ALOG10(Cpd))^3.0 )
  Cmax    = 0.299 - ( 0.289 * ALOG10(Cpd) ) + ( 0.579 * (ALOG10(Cpd))^2.0 )
  Z_max   = 0.600 - ( 0.640 * ALOG10(Cpd) ) + ( 0.021 * (ALOG10(Cpd))^2.0 ) + ( 0.115 * (ALOG10(Cpd))^3.0 )
  delta_Z = 0.710 + ( 0.159 * ALOG10(Cpd) ) + ( 0.021 * (ALOG10(Cpd))^2.0 )

	C_Cze =  Cb+ Cmax * EXP( -( ( (Zze-Z_max) /  delta_Z)^2.0) ) ; C_Cze= chl/mean euphotic chl


; ********************************************************************************************************
;	Calculate 'Total Pigment Content' ~ CHLOR_EUPHOTIC (mg Chl m-2) from Cpd
;	Morel and Berthon (1989) page 1550, Table 2, Equations 2b, 2c
  C_TOT	=38.0*FLOAT(Cpd LT 1.)*(Cpd > 0.)^0.425 $
    	  +40.2*FLOAT(Cpd GE 1.)*(Cpd > 0.)^0.507;


; ********************************************************************************************************
; Calculate Depth of Euphotic Layer using Morel's Case I model,(m)
;	Morel and Berthon (1989) page 1547, Equations 1a, 1b
	Z_eu  =  (C_TOT GT 10.0)* 568.2*C_TOT^(-0.746) $
				+  (C_TOT LE 10.0)* 200.*C_TOT^(-0.293)

;PRINT, CPD
;PRINT, C_TOT
;PRINT, Z_EU


;	===> Calculate Depths: rescale ZZE to Z (meters) based on Z_eu
	Z 	= ZZE * Z_EU

;	=====> Calculate chlorophyll concentration profile
	CHL =	(C_TOT/Z_eu) * C_Cze

;;IF CCpd GT 10 THEN CHL(*) = CCpd

  RETURN, CREATE_STRUCT('Cb',Cb,'Cmax',cmax,'z_max',z_max,'delta_z',delta_z,'Z_ZE',ZZE,'C_CZE',C_CZE,'Z',Z,'C_TOT',C_TOT,'Zeu',Z_eu,'CHL',CHL, 'ERROR',error)


END  ; End of Program
