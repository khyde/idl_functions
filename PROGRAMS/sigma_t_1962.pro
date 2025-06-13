; $ID:	SIGMA_T_1962.PRO,	2020-06-26-15,	USER-KJWH	$

FUNCTION SIGMA_T_1962 ,TEMP=TEMP,SAL=SAL, ERROR=error
;+
; NAME:
;       SIGMA_T
; INPUTS:
;       TEMP: Temperature Degrees C
;				SAL:	Salinity (PPT, PSU)
;	OUTPUT: SIGMA-T density
;
; MODIFICATION HISTORY:
;				AUGUST 10,1993 JOR SIGMAT1.PRG DBASE PROGRAM
;       Converted to IDL by:  J.E.O'Reilly, Dec 23,2005
;       Modified by KJWH: JUN 12, 2017 - Changed name to SIGMA_T_1962 so that an updated equation can be used in the program SIGMA_T

;	*************
;	*** NOTES ***
;	*************
;      SIGMA-T CALCULATIONS
;      FORMULA FROM:
;      HYDROGRAPHICAL TABLES
;      MARTIN KNUDSEN (EDITOR)
;      "A REPRINT OF HYDROGRAPHICAL TABLES"
;      REPRINTED:JAN.1962 BY G.M. MFG.& INSTRUMENT CORP. BRONX,N.Y.
;      IF SALINITY WAS MEASURED BY CONDUCTIVITY THEN
;      IT IS NECESSARY TO USE KNUDSEN'S DEFINITION OF
;      OF CHLORINITY/SALINITY RELATIONSHIP TO SIMULATE BETTER
;      THE SALINITY/SIGMA-T RELATIONSHIPS IN KNUDSEN'S TABLES
;      AND NOT THE NEWEST DEFINITION OF CHLORINITY/SALINITY
;      (CL = S /1.80655) AS GIVEN IN WOOSTER,LEE,DIETRICH(1969)
;      "REDEFINITION OF SALINITY",DEEP-SEA RESEARCH,16:321:322
;      August 10,1993 checked calculations against :
;      Table of Sigma-t with Intervals of 0.1 for Temperature and Salinity
;      Betty Ann L. Keala, 1965
;      US Fish and Wildlife Service, Special Scientific Report--Fisheries
;      No. 506
;      Data were in agreement to 0.001 sigmat units !!
;      CL = (SAL - 0.030)/1.8050
;      SIGO=-.069+1.4708*CL-0.00157*CL**2+0.0000398*CL**3
;      At=TEMP*(4.7867-.098185*TEMP+.0010843*TEMP**2)*1E-3
;      Bt=TEMP*(18.03-0.8164*TEMP+0.01667*TEMP**2)*1E-6
;      Et=((TEMP-3.98)**2*(TEMP+283))/(503.57*(TEMP+67.26))*(-1)
;      SIGT=Et+(SIGO+0.1324)*(1-At+Bt*(SIGO-0.1324))
;; 		 SIGT= SGT(TEMP,SAL,Et)

;-

	ERROR = 0
	N_TEMP=N_ELEMENTS(TEMP)
	N_SAL =N_ELEMENTS(SAL)

	IF N_TEMP EQ 0 OR N_TEMP NE N_SAL THEN BEGIN
		PRINT,'ERROR: Number of elements in temperature must match number of elements in salinity'
		ERROR = 1
		RETURN, -1
	ENDIF

  CL = (SAL - 0.030)/1.8050 ;
  SIGO= -.069+1.4708*CL-0.00157*CL^2+0.0000398*CL^3 ;
  At=TEMP*(4.7867-.098185*TEMP+.0010843*TEMP^2)*1E-3;
  Bt=TEMP*(18.03-0.8164*TEMP+0.01667*TEMP^2)*1E-6;
  Et=((TEMP-3.98)^2*(TEMP+283))/(503.57*(TEMP+67.26))*(-1);
  SIGT=Et+(SIGO+0.1324)*(1-At+Bt*(SIGO-0.1324));

	OK=WHERE(TEMP EQ MISSINGS(TEMP) OR SAL EQ MISSINGS(SAL),COUNT)
 	IF COUNT GE 1 THEN SIGT[OK]=MISSINGS(SIGT)

	RETURN,SIGT

END; #####################  End of Routine ################################

