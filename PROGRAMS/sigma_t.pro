; $ID:	SIGMA_T.PRO,	2017-06-12-13,	USER-KJWH	$

  FUNCTION  SIGMA_T, T=T, S=S

;+
; NAME:
;   SIGMA_T
;
; PURPOSE:
;   This function Calculates in-situ sigma-t from Absolute Salinity and Conservative Temperature, using the computationally-efficient 48-term expression for
;   density in terms of SA, CT and p (IOC et al., 2010).
;
; CALLING SEQUENCE:
;
;   SIG = SIGMA_T(T=TEMPERATURE,S=SALINITY)
;
; INPUTS:
;   T: Temperature (degrees C)
;   S: Salinity (psu)
;
; KEYWORD PARAMETERS:
;   NONE
;
; OUTPUTS:
;   This function returns sigma-t
;
; OPTIONAL OUTPUTS:
;   NA
;
; EXAMPLE:
;   PRINT, SIGMA_T(T=15,S=33)
;   
; NOTES:
;   Note that the 48-term equation has been fitted in a restricted range of parameter space, and is most accurate inside the "oceanographic funnel"
;   described in IOC et al. (2010).  The GSW library function "gsw_infunnel(S,T,P)" is avaialble to be used if one wants to test if
;   some of one's data lies outside this "funnel".
;
;   Adapted from MATLAB code (gsw_rho.m) 
;   The original software is available from http://www.TEOS-10.org
;
; AUTHOR:
;   Paul Barker & Trevor McDougall - wrote the original MATLAB code 
;
; REFERENCES:
;   IOC, SCOR and IAPSO, 2010: The international thermodynamic equation of seawater - 2010: Calculation and use of thermodynamic properties.  
;   Intergovernmental Oceanographic Commission, Manuals and Guides No. 56,
;   UNESCO (English), 196 pp.  Available from http://www.TEOS-10.org
;   See appendix A.20 and appendix K of this TEOS-10 Manual. 
;   
;
; MODIFICATION HISTORY:
;			Written:  June 12, 2017 by K.J.W. Hyde, 28 Tarzwell Drive, NMFS, NOAA 02882 (kimberly.hyde@noaa.gov)
;			Modified:  
;			JUN 16, 2017 - KJWH: Changed the PRESSURE to be 0 so that it is fixed at 0 meters depth
;-
;	****************************************************************************************************
	ROUTINE_NAME = 'SIGMA_T'
	
	IF N_ELEMENTS(T) NE N_ELEMENTS(S) THEN MESSAGE, 'ERROR: Temperature and salinity must have the same number of elements'
	T = DOUBLE(T)
	S = DOUBLE(S)
	
	PRESSURE = REPLICATE(0,N_ELEMENTS(T))
		
	SQRT_S = SQRT(S);
	
	V01 = DOUBLE( 9.998420897506056E+2)
  V02 = DOUBLE( 2.839940833161907)
  V03 = DOUBLE(-3.147759265588511E-2)
  V04 = DOUBLE( 1.181805545074306E-3)
  V05 = DOUBLE(-6.698001071123802)
  V06 = DOUBLE(-2.986498947203215E-2)
  V07 = DOUBLE( 2.327859407479162E-4)
  V08 = DOUBLE(-3.988822378968490E-2)
  V09 = DOUBLE( 5.095422573880500E-4)
  V10 = DOUBLE(-1.426984671633621E-5)
  V11 = DOUBLE( 1.645039373682922E-7)
  V12 = DOUBLE(-2.233269627352527E-2)
  V13 = DOUBLE(-3.436090079851880E-4)
  V14 = DOUBLE( 3.726050720345733E-6)
  V15 = DOUBLE(-1.806789763745328E-4)
  V16 = DOUBLE( 6.876837219536232E-7)
  V17 = DOUBLE(-3.087032500374211E-7)
  V18 = DOUBLE(-1.988366587925593E-8)
  V19 = DOUBLE(-1.061519070296458E-11)
  V20 = DOUBLE( 1.550932729220080E-10)
  V21 = DOUBLE( 1.0)
  V22 = DOUBLE( 2.775927747785646E-3)
  V23 = DOUBLE(-2.349607444135925E-5)
  V24 = DOUBLE( 1.119513357486743E-6)
  V25 = DOUBLE( 6.743689325042773E-10)
  V26 = DOUBLE(-7.521448093615448E-3)
  V27 = DOUBLE(-2.764306979894411E-5)
  V28 = DOUBLE( 1.262937315098546E-7)
  V29 = DOUBLE( 9.527875081696435E-10)
  V30 = DOUBLE(-1.811147201949891E-11)
  V31 = DOUBLE(-3.303308871386421E-5)
  V32 = DOUBLE( 3.801564588876298E-7)
  V33 = DOUBLE(-7.672876869259043E-9)
  V34 = DOUBLE(-4.634182341116144E-11)
  V35 = DOUBLE( 2.681097235569143E-12)
  V36 = DOUBLE( 5.419326551148740E-6)
  V37 = DOUBLE(-2.742185394906099E-5)
  V38 = DOUBLE(-3.212746477974189E-7)
  V39 = DOUBLE( 3.191413910561627E-9)
  V40 = DOUBLE(-1.931012931541776E-12)
  V41 = DOUBLE(-1.105097577149576E-7)
  V42 = DOUBLE( 6.211426728363857E-10)
  V43 = DOUBLE(-1.119011592875110E-10)
  V44 = DOUBLE(-1.941660213148725E-11)
  V45 = DOUBLE(-1.864826425365600E-14)
  V46 = DOUBLE( 1.119522344879478E-14)
  V47 = DOUBLE(-1.200507748551599E-15)
  V48 = DOUBLE( 6.057902487546866E-17)

; V_HAT_DENOMINATOR
  DEN_D = V01 + T*(V02 + T*(V03 + V04*T)) + S*(V05 + T*(V06 + V07*T) + SQRT_S*(V08 + T*(V09 + T*(V10 + V11*T)))) + PRESSURE*(V12 + T*(V13 + V14*T) + S*(V15 + V16*T) + PRESSURE*(V17 + T*(V18 + V19*T) + V20*S))
  
; V_HAT_NUMERATOR 
  DEN_N = V21 + T*(V22 + T*(V23 + T*(V24 + V25*T))) + S*(V26 + T*(V27 + T*(V28 + T*(V29 + V30*T))) + V36*S + SQRT_S*(V31 + T*(V32 + T*(V33 + T*(V34 + V35*T))))) $
            + PRESSURE*(V37 + T*(V38 + T*(V39 + V40*T)) + S*(V41 + V42*T) + PRESSURE*(V43 + T*(V44 + V45*T + V46*S) + PRESSURE*(V47 + V48*T)))

  DENSITY = DEN_D/DEN_N
	
  RETURN, DENSITY - 1000.0D ; SIGMA_T

END; #####################  End of Routine ################################
