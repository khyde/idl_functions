; $ID:	POC_SON.PRO,	2020-06-26-15,	USER-KJWH	$

 FUNCTION POC_SON, Rrs412=Rrs412, Rrs443=Rrs443, Rrs490=Rrs490, Rrs555=Rrs555, LWN=LWN, MISSING=MISSING, ERROR=ERROR


; NAME:
; 	POC_SON

;		This Program computes POC concentration (uM) using the Son et al. (2009) algorithm
;
; CATEGORY:
;		ALGORITHM
;
; CALLING SEQUENCE:		 ;
;		Result = POC_SON(Rrs412=Rrs412, Rrs443=Rrs443, Rrs490=Rrs490, Rrs555=Rrs555)
;
; INPUTS:
;		SeaWiFS:
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
;		Result = A_CDOM_MANNINO(Rrs490=Rrs490,Rrs555=Rrs555)
;		Result = A_CDOM_MANNINO(Rrs490=Rrs490,Rrs555=Rrs555,/LWN)
;
;
;		Notes:
;   Algorithm by Young Baek Son, Wilford Gardner, Alexey Mishonov, Mary Jo Richardson
;   Texas A & M
;   Son YB, Gardner WD, Mishonov AV, Richardson MJ (2009) Multispectral remote-sensing algorithms for particulate organic carbon (POC): 
;       The Gulf of Mexico. Remote Sensing of Environment 113: 50-61
;		
;   MODIFICATION HISTORY:
;		Written:  March 16, 2010 by A. Mannino & K.J.W.Hyde (kimberly.hyde@noaa.gov) 
;-
	ROUTINE_NAME='POC_SON'

	ERROR = 0

	NLW_LOW = 0.1

; ===> initialize POC array to same size as Rrs412
    POC = DOUBLE(RRS412) & POC(*) = MISSINGS(POC) & MNDCI_RRS = POC

; ===> Check for missing data
  OK = WHERE(RRS412 NE MISSINGS(RRS412) AND $
             RRS443 NE MISSINGS(RRS443) AND $
             RRS490 NE MISSINGS(RRS490) AND $             
             RRS555 NE MISSINGS(RRS555) AND $
             RRS412 GT 0D               AND $
             RRS443 GT 0D               AND $
             RRS490 GT 0D               AND $             
             RRS555 GT 0D               AND $
             FINITE(RRS412)             AND $
             FINITE(RRS443)             AND $
             FINITE(RRS490)             AND $             
             FINITE(RRS555) , COUNT)
  	IF COUNT LT 1 THEN RETURN, FLOAT(POC)

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

;   ===> Calculate POC
    MNDCI_RRS[OK] = (RRS555[OK]-(RRS412[OK]>RRS443[OK]>RRS490[OK]))/(RRS555[OK]+(RRS412[OK]>RRS443[OK]>RRS490[OK]))
    POC[OK] = 10^(6.36*(MNDCI_RRS[OK])^5 + 3.26*(MNDCI_RRS[OK])^4 - 0.37*(MNDCI_RRS[OK])^3 - 0.40*(MNDCI_RRS[OK])^2 + 1.79*(MNDCI_RRS[OK]) + 2.42)

;		===> Find any ZERO OR Negative ACDOM values and make them missing values
		OK=WHERE(POC LE 0,COUNT)
		IF COUNT GE 1 THEN POC[OK] = MISSINGS(POC)
		RETURN, FLOAT(POC)
	





END; #####################  End of Routine ################################



