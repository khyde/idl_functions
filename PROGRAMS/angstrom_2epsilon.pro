; $ID:	ANGSTROM_2EPSILON.PRO,	2020-07-08-15,	USER-KJWH	$
;+
;	This Function Converts Angstrom exponents to Epsilons
; SYNTAX:
;	Result = ANGSTROM_2EPSILON(Nm, Angstrom)
; OUTPUT:
; ARGUMENTS:
; 	Nm:	wavelengths in nanometers for numerator/denominator e.g. [443,670]
; 	Angstrom:	Angstrom exponent for the nm wavelength
; KEYWORDS:
;
; EXAMPLE:
;	Result = ANGSTROM_2EPSILON([520,670],-0.449611) & print, Result ; 1.1207
; CATEGORY:
;	LIGHT
; NOTES:
;  McClain and Yeh , equation 11, page 9, SeaWiFS Tech. Rept 13
;  and page 2 of seapak manual

;  E(nm) = (nm/670.)^ang(nm)
;  alog10(E(nm)) = alog10(nm/670.)*ang(nm))
;  alog10(E(nm))/alog10(nm/670.) = ang(nm)
;
; NOTE GLOBAL PROCESSING USED AN EPSILON OF 0.95,1,1
; WHICH TRANSLATES TO Angstrom exponent of 0.123, 0,0
; See page 12 in:
; McClain, C.R. and E-N Yeh.
; SeaWiFS Ozone Data Analysis Study.
; In Case Studies for SeaWiFS Calibration and Validation, Part 1,
; edited by S.B. Hooker and E.R. Firestone, pp. 3-8,
; NASA Tech. Memo. 104566, Vol. 13,
; NASA Goddard Space Flight Center, Greenbelt, Maryland, 1994.
;
; VERSION:
;	Feb 15,2001
; HISTORY:
;	June 25, 1998	Written by:	J.E. O'Reilly, NOAA, 28 Tarzwell Drive, Narragansett, RI 02882
;-
; *************************************************************************

FUNCTION ANGSTROM_2EPSILON, Nm,  Angstrom
  ROUTINE_NAME='ANGSTROM_2EPSILON'
  IF N_PARAMS() NE 2 THEN STOP
  IF N_ELEMENTS(Nm) NE 2 THEN STOP

  RETURN,  EXP(Angstrom* ALOG(FLOAT(Nm[0])/Nm[1]))

  END; #####################  End of Routine ################################
