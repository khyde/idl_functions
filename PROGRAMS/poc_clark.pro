; $ID:	POC_CLARK.PRO,	2020-07-08-15,	USER-KJWH	$
;+
;	This Function returns the Particulate Organic Carbon Estimate (POC)  Clark (unpublished) algorithm
; developed MODIS using field data from Chesapeake Bay
; Clark's algorithm is a 5th-order polynomial and includes three MODIS bands:
; X = [LWN(442) + LWN(487)]/LWN(547)
; log POC =   [-7.364709(log X)5 + 19.96593(log X)4 + -19.569603(log X)3 + 8.745837(log X)2 + -3.228108(log X) - 0.161397],

;
; HISTORY:
; Equation  from Sergio R. Signorini, May 19, 2004
;	May 20, 2004	Written by:	J.E. O'Reilly, NOAA, 28 Tarzwell Drive, Narragansett, RI 02882
; December 20, 2006,   No longer multiplying POC by 1000;RETURN, 1000.*POC
; March 16, 2010 Modified by: K. Hyde - Updated the coeffients and wavelengths according to the 2010 Ocean Color SeaDAS processing
;                                       http://oceancolor.gsfc.nasa.gov/DOCS/OCSSW/get__poc_8c_source.html
;
;-
; *************************************************************************

FUNCTION POC_CLARK,NLW443=NLW443, NLW490=NLW490, NLW_555=NLW555, RRS=RRS, DOY=DOY, MISSING=missing
  ROUTINE_NAME='POC_CLARK'

; POC CLARK COEFFICENTS
  COEFFS = [-0.12400,-2.63356,4.86451,-10.62753,11.60780,-4.63676]

; =====> Determine Missing data code. If not provided then use O'Reilly idl program MISSINGS.pro
  IF N_ELEMENTS(MISSING) EQ 1 THEN _MISSING = MISSING ELSE _MISSING = MISSINGS(NLW_555)

; =====> Make a POC array of same data type as NLW_547 and set all array elements to the missing code
;				 If any of the NLW_547 values are invalid (missing code) then the matching elements in POC array
;				 are returned as a missing code value
	POC = NLW_555 & POC(*) = _MISSING & LOGX = POC

; =====> Convert RRS values to NLW
  IF KEYWORD_SET(RRS) THEN BEGIN
    IF N_ELEMENTS(DOY) EQ 0 THEN _DOY = 183 ELSE _DOY = DOY
    NLW_443 = RRS_2LWN(NLW443,_DOY,443)
    NLW_490 = RRS_2LWN(NLW443,_DOY,490)
    NLW_555 = RRS_2LWN(NLW443,_DOY,555)
  ENDIF

; =====> Determine subscripts of non-missing NLW547 input data
  ok = WHERE(	NLW_443 NE _MISSING AND FINITE(NLW_443) AND NLW_443 GT 0.0 AND $
  						NLW_490 NE _MISSING AND FINITE(NLW_490) AND NLW_490 GT 0.0 AND $
  						NLW_555 NE _MISSING AND FINITE(NLW_555) AND NLW_555 GT 0.0 ,count)

; =====> If have at least one valid triplet data then calculate POC
 	IF COUNT GE 1 THEN BEGIN
 		LOGX[OK] = ALOG10((NLW_443[OK] + NLW_490[OK])/NLW_555[OK])
 		POC[OK]  = 10^(COEFFLS[0] + COEFFLS[1]*LOGX[OK] + COEFFLS(2)*LOGX[OK]^2 + COEFFLS(3)*LOGX[OK]^3 + COEFFLS(4)*LOGX[OK]^4 + COEFFLS(5)*LOGX[OK]^5) ; 2010 SeaDAS
;   POC[OK]  = 10^( -7.364709*(LOGX)^5 + 19.96593*(LOGX)^4  -19.569603*(LOGX)^3 + 8.745837*(LOGX)^2  -3.228108*(LOGX) - 0.161397  ) ; from 2006

; 	=====> Now set any Negative POC's to ZERO
  	POC[OK] =  POC[OK] > 0.0 ;;

  ENDIF

; ===> UNITS SO FAR ARE MG L-1 ... CONVERT TO MG M-3

 RETURN, 1000.0 * POC			;mg m^-3


END; #####################  End of Routine ################################
