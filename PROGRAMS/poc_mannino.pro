; $ID:	POC_MANNINO.PRO,	2020-06-26-15,	USER-KJWH	$

 FUNCTION POC_MANNINO, Rrs490=Rrs490, Rrs555=Rrs555, LWN=LWN, MISSING=MISSING, ERROR=ERROR, ERR_MSG=ERR_MSG


; NAME:
; 	POC_MANNINO

;		This Program computes POC concentration (uM) using the Mannino algorithm
;
; CATEGORY:
;		ALGORITHM
;
; CALLING SEQUENCE:		 ;
;		Result = POC_MANNINO(Rrs490=Rrs490,Rrs555=Rrs555)
;
; INPUTS:		
;			Rrs490:	Remote Sensing Reflectance at 490nm
;			Rrs555:	Remote Sensing Reflectance at 490nm
;
; KEYWORD PARAMETERS:
;		LWN:	Indicates that the input Rrs is actually LWN and the program will then convert these LWNs into Rrs
;
; OUTPUTS:
;		This function returns POC
;
; OPTIONAL OUTPUTS:
;		ERROR:     Any Error messages are placed in ERROR, if no errors then ERROR = ''
;
; EXAMPLE:
;		Result = POC_MANNINO(Rrs490=Rrs490,Rrs555=Rrs555)
;		Result = POC_MANNINO(Rrs490=Rrs490,Rrs555=Rrs555,/LWN)
;
; 	MODIFICATION HISTORY:
;		Algorithm by A. Mannino, NASA, GSFC
;
;		Notes:
;
;		Written:  April 4, 2008 by A. Mannino & K.J.W.Hyde (kimberly.hyde@noaa.gov)
;		Modified: March 16, 2010 by A. Mannino & K.J.W.Hyde (kimberly.hyde@noaa.gov) - updated the coefficients, which works better at higher POC values on the inner shelf 
;-
	ROUTINE_NAME='POC_MANNINO'

	ERROR = []
	ERR_MSG = []

	NLW_LOW = 0.1

	IF N_ELEMENTS(RRS490) GE 1 AND N_ELEMENTS(RRS555) GE 1 AND N_ELEMENTS(RRS490) EQ N_ELEMENTS(RRS555) THEN BEGIN
; ===> initialize POC array to same size as Rrs490
  	POC	= DOUBLE(RRS490) & POC(*)	= MISSINGS(POC)

;		===> F0 Factors for converting Rrs to Lwn
		F0_490 = 193.38D  ;SeaWiFS Nominal Band Solar Irradiances
		F0_555 = 183.76D  ;SeaWiFS Nominal Band Solar Irradiances

;		===> Convert LWN to Rrs if inputs are LWN and keyword LWN is provided
		IF KEYWORD_SET(LWN) THEN BEGIN ;			===> Input Radiance is LWN

;			===> Find Valid data
			OK = WHERE(RRS490 NE MISSINGS(RRS490) AND FINITE(RRS490) AND RRS490 GE NLW_LOW AND $
  							 RRS555 NE MISSINGS(RRS555) AND FINITE(RRS555) AND RRS555 GE NLW_LOW,COUNT)
			IF COUNT EQ 0 THEN RETURN, FLOAT(POC) ; >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
      RRS490[OK] = DOUBLE(RRS490[OK])/F0_490 ; SEAWIFS
      RRS555[OK] = DOUBLE(RRS555[OK])/F0_555 ; SEAWIFS
		ENDIF ELSE BEGIN ;			===> Input radiance is Rrs

;			===> Find Valid data (also check that the LWN (Rrs*F0) exceeds the NLW_LOW value
			OK = WHERE(	RRS490 NE MISSINGS(RRS490) AND FINITE(RRS490) AND (RRS490*F0_490) GE NLW_LOW AND $
  								RRS555 NE MISSINGS(RRS555) AND FINITE(RRS555) AND (RRS555*F0_555) GE NLW_LOW,COUNT)
  		IF COUNT EQ 0 THEN RETURN, FLOAT(POC) ; >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
		ENDELSE

;		===> POC
; 	POC[OK] = ALOG((DOUBLE(RRS490[OK])/DOUBLE(RRS555[OK])-0.574407)/1.8423)/(-0.00566515)		;mg m^-3  2008 Mannino algorithm
		POC[OK] = ALOG((DOUBLE(RRS490[OK])/DOUBLE(RRS555[OK])-0.5461)/1.5564)/(-0.0039354)   ;mg m^-3  2010 Mannino algorithm


;		===> Find any ZERO OR Negative ACDOM values and make them missing values
		OK=WHERE(POC LE 0,COUNT)
		IF COUNT GE 1 THEN POC[OK] = MISSINGS(POC)
		RETURN, FLOAT(POC)
	ENDIF





END; #####################  End of Routine ################################



