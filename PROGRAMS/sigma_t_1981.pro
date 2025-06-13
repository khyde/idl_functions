; $ID:	SIGMA_T_1981.PRO,	2017-06-12-12,	USER-KJWH	$

  FUNCTION  SIGMA_T_1981, T=T, S=S, DENSITY=DENSITY

;+
; NAME:
;   SIGMA_T
;
; PURPOSE:
;   This function calculates Sigma-t using UNESCO 1983 (EOS 1980) polynomial
;
; CALLING SEQUENCE:
;
;   SIG = SIGMA_T(T=TEMPERATURE,S=SALINITY,DENSITY=DENSITY)
;
; INPUTS:
;   T: Temperature (degrees C)
;   S: Salinity (psu)
;
; OPTIONAL INPUTS:
;   NONE
;
; KEYWORD PARAMETERS:
;   NONE
;
; OUTPUTS:
;   This function returns the density of sea water at atmospheric pressure
;
; OPTIONAL OUTPUTS:
;   DENSITY: The Density of Sea Water at atmospheric pressure
;
; EXAMPLE:
;   PRINT, SIGMA_T_1981(T=15,S=33)
;   
; NOTES:
;   
; REFERENCES:
;   Unesco 1983. Algorithms for computation of fundamental properties of seawater, 1983. _Unesco Tech. Pap. in Mar. Sci._, No. 44, 53 pp.
;
;   Millero, F.J. and  Poisson, A. International one-atmosphere equation of state of seawater. Deep-Sea Res. 1981. Vol28A(6) pp625-629.  
;   
;
; MODIFICATION HISTORY:
;			Written:  June 12, 2017 by K.J.W. Hyde, 28 Tarzwell Drive, NMFS, NOAA 02882 (kimberly.hyde@noaa.gov)
;			Modified:  
;-
;	****************************************************************************************************
	ROUTINE_NAME = 'SIGMA_T'
	
	IF N_ELEMENTS(T) NE N_ELEMENTS(S) THEN MESSAGE, 'ERROR: Temperature and salinity must have the same number of elements'
	T = DOUBLE(T)
	S = DOUBLE(S)
	
	T68 = T * 1.00024D

	A0 =   999.842594D
	A1 =   0.06793952D
	A2 =  -0.009095290D
	A3 =   0.0001001685D
	A4 =  DOUBLE(-1.120083E-6)
	A5 =  DOUBLE(6.536332E-9)

	B0 =  0.824493D
	B1 = -0.0040899D
	B2 =  DOUBLE(7.6438E-5)
	B3 =  DOUBLE(-8.2467E-7)
	B4 =  DOUBLE(5.3875E-9)

	C0 = -0.00572466D
	C1 =  0.00010227D
	C2 = DOUBLE(-1.6546E-6)

	D0 =  0.00048314D
	
	DEN0 = (A0 + (A1 + (A2 + (A3 + (A4 + A5 * T68) * T68) * T68) * T68) * T68)
	
	DENSITY = DEN0 + (B0 + (B1 + (B2 + (B3 + B4 * T68) * T68) * T68) * T68) * S	+ (C0 + (C1 + C2 * T68) * T68) * S * SQRT(S) + D0*S^2
	
	RETURN, DENSITY - 1000.0D
	
 

END; #####################  End of Routine ################################
