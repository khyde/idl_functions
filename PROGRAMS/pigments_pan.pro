; $ID:	PIGMENTS_PAN.PRO,	2020-07-08-15,	USER-KJWH	$
FUNCTION PIGMENTS_PAN, SENSOR=SENSOR, SST=SST, RRS488=R488, RRS490=R490, RRS547=R547, RRS555=R555, RRS667=R667, RRS670=R670, VERSION=VERSION

;+
; NAME:
;   PIGMENTS_PAN
;
; PURPOSE:;
;   This function uses Xiaoju Pan's model to produce regional phytoplankton pigments (CHLA,CHLB,CHLC,CARO,ALLO,FUCO,PERID,NEO,VIOLA,DIA,ZEA,LUT) using SeaWiFS, MODIS and OCCCI. 
;   
; CATEGORY:
;   Algorithms
;
; CALLING SEQUENCE:
;   PIGMENTS = PIGMENTS_PAN(SENSOR=SENSOR, RRS488=R488, RRS490=R490, RRS547=R547, RRS555=R555, RRS667=R667, RRS670=R670, VERSION=VERSION)
;
; REQUIRED INPUTS:
;   SENSOR..... Name of the input sensor (SEAWIFS, MODISA and OCCCI are all accepted).  Need to add VIIRS once we have coefficients for the VIIRS data
;   RRS488..... The "blue" Remote Sensing Reflectance data for MODISA
;   RRS490..... The "blue" Remote Sensing Reflectance data for SEAWIFS
;   RRS547..... The "green" Remote Sensing Reflectance data for MODISA
;   RRS555..... The "green" Remote Sensing Reflectance data for SEAWIFS
;   RRS667..... The "red" Remote Sensing Reflectance data for MODISA
;   RRS670..... The "red" Remote Sensing Reflectance data for SEAWIFS
;
; OPTIONAL INPUTS:
;   VERSION.... The VERSION will determine which set of cofficients are used
;
; KEYWORD PARAMETERS:
;   NONE
;
; OUTPUTS:
;   This function returns a structure with the results of the Pan pigment algorithms
;
; EXAMPLE:  
;   PIGMENTS_PAN(SENSOR='MODISA', RRS488=0.0077,RRS547=0.00187,RRS667=0.00186,SST=5.0)
;   PIGMENTS_PAN(SENSOR='SEAWIFS',RRS490=0.0077,RRS555=0.00187,RRS670=0.00186,SST=5.0)
;   PIGMENTS_PAN(SENSOR='MODISA', RRS488=[0.0028,0.0077,0.0379],RRS547=[0.000984,0.001855,0.028217],RRS667=[0.000110,0.000186,0.00151200],SST=[5.0,5.5,6.0])
;   PIGMENTS_PAN(SENSOR='SEAWIFS',RRS490=[0.0028,0.0077,0.0379],RRS555=[0.000984,0.001855,0.028217],RRS670=[0.000110,0.000186,0.00151200],SST=[5.0,5.5,6.0])
;   PIGMENTS_PAN(SENSOR='MODISA', RRS488=[0.0028,0.0077,0.0379],RRS547=[0.000984,0.001855,0.028217],RRS667=[0.000110,0.000186,0.00151200],SST=[5.0,5.5,6.0],VERSION='V1_0')
;   PIGMENTS_PAN(SENSOR='SEAWIFS',RRS490=[0.0028,0.0077,0.0379],RRS555=[0.000984,0.001855,0.028217],RRS670=[0.000110,0.000186,0.00151200],SST=[5.0,5.5,6.0],VERSION='V1_1')
;
;
; NOTES:
;  Algorithms are based on 3rd-order polynomial function
;    log[pigment]=A+B*X+C*X^2+D*X^3
;    X=log[Rrs(lambda1)/Rrs(lambda2)]
;    
;  Version 1 (V1_0) of the algorithm was provided by Xiaoju Pan (a former NASA post-doc with Antonio Mannino) and based on the coefficients in Pan et al., 2010
;    
;    
;  Version 1.1 (V1_1) uses the same coefficients as V1_0, but include a step to evaluate low values of RRS_670 (RRS_667) for the CHLA algorithm (from Pan et al, 2010)
;      IF RRS_670 IS LESS THAN 0.0001, THEN USE THE CHL DERIVED FROM THEN RRS_490/RRS_555 RATIO  
;    
; REFERENCES:
;   Pan X, Mannino A, Russ ME, Hooker SB, Harding Jr LW (2010) Remote sensing of phytoplankton pigment distribution in the United States
;       northeast coast. Remote Sensing of Environment 114: 2403-2416 doi doi: 10.1016/j.rse.2010.05.015
;
; COPYRIGHT:
; Copyright (C) 2018, Department of Commerce, National Oceanic and Atmospheric Administration, National Marine Fisheries Service,
;   Northeast Fisheries Science Center, Narragansett Laboratory.
;   This software may be used, copied, or redistributed as long as it is not sold and this copyright notice is reproduced on each copy made.
;   This routine is provided AS IS without any express or implied warranties whatsoever.
;
;   This program was written by Kimberly Hyde, DOC/NOAA/NMFS/NEFSC Narragansett, RI, kimberly.hyde@noaa.gov
;          
;
; MODIFICATION HISTORY:
;     Mar 22, 2010 - Written by K.J.W.Hyde, 28 Tarzwell Drive, NMFS, NOAA 02882 (kimberly.hyde@noaa.gov) 
;     Jan 16, 2015 - KJWH: Changed SAT to SENSOR
;     May 12, 2015 - KJWH: Changed MODIS RRS_555 to RRS_547
;     Nov 14, 2016 - KJWH: Added IF SENSOR EQ 'MODISA' THEN SENSOR = 'MODIS' 
;                          Replaced R555 with R547 in the MODIS section
;     Feb 17, 2017 - KJWH: Simplified the RRS data (i.e. make R490 = RRS448) & removed duplicate code   
;     AUG 27, 2018 - KJWH: Added a CASE block for the algorithm coefficients to allow for multiple versions
;                          Added VERSION keyword
;                          Removed the MISSING, ERROR and ERR_MSG keywords (legacy keywords)
;                          Updated the documentation and formatting
;                          Added the check for if the R670 vales are less than 0.001 - BUG FIX (V1_1)
;                            OK_R6 = WHERE(R670 < 0.0001, COUNT_R6)                       ; Find where R670(R667) is less than 0.0001
;                            IF COUNT_R6 GT 0 THEN OCHL(OK_R6) = C1(OK_R6)                ; If R670(R667) is less than 0.0001 then use the C1 chlorophyll
;     Feb 01, 2019 - KJWH: Fixed a BUG with the FUCO calculations.  The FUCO data had mistakenly been labled as CHLC   
;                          Changed the VERSION to V1_1                     
; 
;-
; ****************************************************************************************************
  ROUTINE_NAME = 'PIGMENTS_PAN'

; ===> Defaults
  IF NONE(VERSION) THEN VERSION='V1_1'
  VER = STRMID(VERSION,0,2)

; ===> Check the SENSOR input
  IF N_ELEMENTS(SENSOR) NE 1 THEN RETURN, 'ERROR: No SENSOR provided'
  IF SENSOR EQ 'OCCCI' THEN SENSOR = 'SEAWIFS'  ; For the OCCCI data, use the SeaWiFS coefficients (KJWH 8/22/18)
  IF SENSOR NE 'SEAWIFS' AND SENSOR NE 'MODISA' THEN MESSAGE, 'ERROR: Unregonized SENSOR'

; ===> Sensor specific coefficients for the chlorophyll algorithm
  CASE STRUPCASE(SENSOR) OF
    'SEAWIFS': BEGIN
      CASE VER OF
        'V1': BEGIN
          CHLA_COEFF_1 = [  0.02534, -3.033,  2.096,  -1.607 ] ; 490/555
          CHLA_COEFF_2 = [  1.351,   -2.427,  0.9395, -0.2432] ; 490/670
          CHLB_COEFF   = [ -1.101,   -1.993,  0.9228, -7.980 ] ; 490/555
          CHLC_COEFF_1 = [ -0.7750,  -3.071,  0.7940, -1.559 ] ; 490/555
          CHLC_COEFF_2 = [  0.4424,  -2.291,  1.19,   -0.5307] ; 490/670
          CARO_COEFF_1 = [ -1.344,   -2.604,  3.050,  -3.351 ] ; 490/555
          CARO_COEFF_2 = [ -0.01909, -2.775,  1.703,  -0.5496] ; 490/670
          ALLO_COEFF_1 = [ -1.402,   -4.114, -0.9104,  0.9988] ; 490/555
          ALLO_COEFF_2 = [  0.04234, -2.747,  1.562,  -0.8771] ; 490/670
          FUCO_COEFF_1 = [ -0.6334,  -3.533,  1.317,   0.0   ] ; 490/555
          FUCO_COEFF_2 = [  0.6908,  -2.053,  0.2658,  0.0   ] ; 490/670
          PERID_COEFF_1= [ -1.416,   -2.363,  2.565,  -4.186 ] ; 490/555
          PERID_COEFF_2= [ -0.01038, -3.807,  3.612,  -1.489 ] ; 490/670
          NEO_COEFF    = [ -1.984,   -1.790,  1.610,  -11.31 ] ; 490/555
          VIOLA_COEFF  = [ -1.950,   -1.285,  2.595,  -14.65 ] ; 490/555
          DIA_COEFF    = [ -1.001,   -2.626,  1.501,  -3.736 ] ; 490/555
          ZEA_COEFF    = [-11.58,   -17.94, -11.02,   -2.323 ] ; 490/555
          LUT_COEFF    = [ -2.196,   -1.935,  2.042,  -3.601 ] ; 490/555
        END
        ELSE: MESSAGE, 'ERROR: Unrecognized version'
      ENDCASE
    END
    'MODISA': BEGIN
      CASE VER OF
        'V1': BEGIN
          CHLA_COEFF_1 = [ 0.03664,  -3.451,  2.276,   -1.096 ] ; 488/555
          CHLA_COEFF_2 = [ 1.351,    -2.427,  0.9395,  -0.2432] ; 488/667
          CHLB_COEFF   = [ -1.097,   -2.348,  0.9633,  -9.374 ] ; 488/555
          CHLC_COEFF_1 = [ -0.7584,  -3.511,  0.4116,  -0.4283] ; 488/555
          CHLC_COEFF_2 = [ 0.4424,   -2.291,  1.19,    -0.5307] ; 488/667
          CARO_COEFF_1 = [ -1.341,   -2.952,  3.802,   -4.256 ] ; 488/555
          CARO_COEFF_2 = [ -0.01909, -2.775,  1.703,   -0.5496] ; 488/667
          ALLO_COEFF_1 = [ -1.401,   -4.816,  -1.264,  5.838  ] ; 488/555
          ALLO_COEFF_2 = [ 0.04234,  -2.747,  1.562,   -0.8771] ; 488/667
          FUCO_COEFF_1 = [ -0.6208,  -3.928,  1.339,   0.0    ] ; 488/555
          FUCO_COEFF_2 = [ 0.6908,   -2.053,  0.2658,  0.0    ] ; 488/667
          PERID_COEFF_1= [ -1.401,   -2.817,  2.634,   -2.396 ] ; 488/555
          PERID_COEFF_2= [ -0.01038, -3.807,  3.612,   -1.489 ] ; 488/667
          NEO_COEFF    = [ -1.983,   -2.151,  2.134,   -12.67 ] ; 488/555
          VIOLA_COEFF  = [ -1.947,   -1.601,  3.258,   -17.31 ] ; 488/555
          DIA_COEFF    = [ -0.9963,  -3.113,  1.635,   -2.164 ] ; 488/555
          ZEA_COEFF    = [ -9.885,   -14.84,  -9.23,   -1.998 ] ; LOG(488/551)-1.5LOG(TW)
          LUT_COEFF    = [ -2.188,   -2.037,  2.179,   -10.16 ] ; 488/551
        END
        ELSE: MESSAGE, 'ERROR: Unrecognized version'
      ENDCASE
      R490 = R488 & GONE, R488                      ; Change the R488 variable name to R490 & remove from memory
      R555 = R547 & GONE, R547                      ; Change the R547 variable name to R555 & remove from memory
      R670 = R667 & GONE, R667                      ; Change the R667 variable name to R670 & remove from memory
    END
    'VIIRS': BEGIN
      RETURN, 'ERROR: VIIRS coefficients currently not available'
    END
    ELSE: RETURN, 'ERROR: Unrecognized SENSOR'
  ENDCASE

  ; ===> Set up blank output arrays
  TEMP = DOUBLE(R490) & TEMP(*)   = MISSINGS(TEMP)
  CHLA      = TEMP
  CHLB      = TEMP
  CHLC      = TEMP
  CARO      = TEMP
  ALLO      = TEMP
  FUCO      = TEMP
  PERID     = TEMP
  NEO       = TEMP
  VIOLA     = TEMP
  DIA       = TEMP
  ZEA       = TEMP
  LUT       = TEMP
  GONE, TEMP
  
; ===> Check for missing and bad data
  OK_GOOD = WHERE(R490 NE MISSINGS(R490) AND DOUBLE(R490) GT 0D AND FINITE(R490) AND $
                  R555 NE MISSINGS(R555) AND DOUBLE(R555) GT 0D AND FINITE(R555) AND $
                  R670 NE MISSINGS(R670) AND DOUBLE(R670) GT 0D AND FINITE(R670) AND $
                  SST  NE MISSINGS(SST)  AND DOUBLE(SST)  GT 0D AND FINITE(SST), COUNT_GOOD)              
  IF COUNT_GOOD LT 1 THEN BEGIN
    PRINT, 'No valid input data to calculate PIGMENTS-PAN.'
    RETURN, CREATE_STRUCT('CHLA',CHLA,'CHLB',CHLB,'CHLC',CHLC,'CARO',CARO,'ALLO',ALLO,'FUCO',FUCO,'PERID',PERID,'NEO',NEO,'VIOLA',VIOLA,'DIA',DIA,'ZEA',ZEA,'LUT',LUT)  ; If no valid input data, then return empty arrays
  ENDIF

; ===>   Calculate the band ratios
  X1   = ALOG10(DOUBLE(R490(OK_GOOD))/DOUBLE(R555(OK_GOOD)))
  X2   = ALOG10(DOUBLE(R490(OK_GOOD))/DOUBLE(R670(OK_GOOD)))
  XZEA = ALOG10(DOUBLE(R490(OK_GOOD))/DOUBLE(R555(OK_GOOD)))-1.5*ALOG10(DOUBLE(SST(OK_GOOD)))

; ===> Group A Pigments     
; ***** CHLA *****
	C1=10.^(CHLA_COEFF_1[0] + (CHLA_COEFF_1[1]*X1) + (CHLA_COEFF_1(2)*X1^2) + (CHLA_COEFF_1(3)*X1^3))  ; Chlorophyll based on the 490/555 ratio
	C2=10.^(CHLA_COEFF_2[0] + (CHLA_COEFF_2[1]*X2) + (CHLA_COEFF_2(2)*X2^2) + (CHLA_COEFF_2(3)*X2^3))	 ; Chlorophyll based on the 490/670 ratio
  MCHL = C1 & OCHL = MCHL                               ; MCHL is the array to hold the "Maximum" chl & OCHL is the array to hold the "output" chl  
  OK_C2 = WHERE(C2 GT C1,COUNT_C2)                      ; Find where C2 is greater than C1    
  IF COUNT_C2 GE 1 THEN MCHL(OK_C2) = C2(OK_C2)         ; Fill in MCHL with the "maximum" chl from C1 & C2  
  OK_X1 = WHERE(X1 LE 0.15,COUNT_X1)                    ; Find where the R1 waveband ratio is less than 0.15
  IF COUNT_X1 GT 0 THEN OCHL(OK_X1) = MCHL(OK_X1)       ; If X1 is less than 0.15, then use the "maximum" chl from C1 & C2 (MCHL), otherwise use the chl from C1
  IF VERSION NE 'V1_0' THEN BEGIN                       ; BUG found on 8/27/2018 by KJWH.  Addition of the search for R670 < 0.0001 is valid for V1_1 and higher
    OK_R6 = WHERE(R670 LT 0.0001, COUNT_R6)             ; Find where R670(R667) is less than 0.0001
    IF COUNT_R6 GT 0 THEN OCHL(OK_R6) = C1(OK_R6)       ; If R670(R667) is less than 0.0001 then use the C1 chlorophyll
  ENDIF
  CHLA(OK_GOOD) = OCHL                                  ; Input the "output" chl data into the full chl array  
  BAD = WHERE(CHLA LE 0.0 OR CHLA GT 200.0,COUNT_BAD)   ; Find any negative or very high values 
  IF COUNT_BAD GE 1 THEN CHLA(BAD) = MISSINGS(0.0)      ; Replace any negative or very high values with missing code
	GONE, MCHL
	GONE, OCHL
	GONE, C1
	GONE, C2
				
; ***** CHLC *****
  C1=10.^(CHLC_COEFF_1[0]+CHLC_COEFF_1[1]*X1+CHLC_COEFF_1(2)*X1^2+CHLC_COEFF_1(3)*X1^3)
	C2=10.^(CHLC_COEFF_2[0]+CHLC_COEFF_2[1]*X2+CHLC_COEFF_2(2)*X2^2+CHLC_COEFF_2(3)*X2^3)
	MCHL = C1 & OCHL = MCHL                               ; MCHL is the array to hold the "Maximum" chl & OCHL is the array to hold the "output" chl  
  OK_C2 = WHERE(C2 GT C1,COUNT_C2)                      ; Find where C2 is greater than C1    
  IF COUNT_C2 GE 1 THEN MCHL(OK_C2) = C2(OK_C2)         ; Fill in MCHL with the "maximum" chl from C1 & C2  
  OK_X1 = WHERE(X1 LE 0.15,COUNT_X1)                    ; Find where the R1 waveband ratio is less than 0.15
  IF COUNT_X1 GT 0 THEN OCHL(OK_X1) = MCHL(OK_X1)       ; If X1 is less than 0.15, then use the "maximum" chl from C1 & C2 (MCHL), otherwise use the chl from C1
  IF VERSION NE 'V1_0' THEN BEGIN                       ; BUG found on 8/27/2018 by KJWH.  Addition of the search for R670 < 0.0001 is valid for V1_1 and higher
    OK_R6 = WHERE(R670 LT 0.0001, COUNT_R6)             ; Find where R670(R667) is less than 0.0001
    IF COUNT_R6 GT 0 THEN OCHL(OK_R6) = C1(OK_R6)       ; If R670(R667) is less than 0.0001 then use the C1 chlorophyll
  ENDIF
  CHLC(OK_GOOD) = OCHL                                  ; Input the "output" chl data into the full chl array  
  BAD = WHERE(CHLC LE 0.0 OR CHLC GT 200.0,COUNT_BAD)   ; Find any negative or very high values 
  IF COUNT_BAD GE 1 THEN CHLC(BAD) = MISSINGS(0.0)      ; Replace any negative or very high values with missing code
  GONE, MCHL
  GONE, OCHL
  GONE, C1
  GONE, C2
  
; ***** FUCO *****
  C1=10.^(FUCO_COEFF_1[0]+FUCO_COEFF_1[1]*X1+FUCO_COEFF_1(2)*X1^2+FUCO_COEFF_1(3)*X1^3)
  C2=10.^(FUCO_COEFF_2[0]+FUCO_COEFF_2[1]*X2+FUCO_COEFF_2(2)*X2^2+FUCO_COEFF_2(3)*X2^3)
  MFUCO = C1 & OFUCO = MFUCO                            ; MFUCO is the array to hold the "Maximum" fuco & OFUCO is the array to hold the "output" fuco  
  OK_C2 = WHERE(C2 GT C1,COUNT_C2)                      ; Find where C2 is greater than C1    
  IF COUNT_C2 GE 1 THEN MFUCO(OK_C2) = C2(OK_C2)        ; Fill in MFUCO with the "maximum" fuco from C1 & C2  
  OK_X1 = WHERE(X1 LE 0.15,COUNT_X1)                    ; Find where the R1 waveband ratio is less than 0.15
  IF COUNT_X1 GT 0 THEN OFUCO(OK_X1) = MFUCO(OK_X1)     ; If X1 is less than 0.15, then use the "maximum" fuco from C1 & C2 (MFUCO), otherwise use the fuco from C1
  IF VERSION NE 'V1_0' THEN BEGIN                       ; BUG found on 8/27/2018 by KJWH.  Addition of the search for R670 < 0.0001 is valid for V1_1 and higher
    OK_R6 = WHERE(R670 LT 0.0001, COUNT_R6)             ; Find where R670(R667) is less than 0.0001
    IF COUNT_R6 GT 0 THEN OFUCO(OK_R6) = C1(OK_R6)      ; If R670(R667) is less than 0.0001 then use the C1 fuco
  ENDIF
  FUCO(OK_GOOD) = OFUCO                                 ; Input the "output" fuco data into the full fuco array  
  BAD = WHERE(FUCO LE 0.0 OR FUCO GT 200.0,COUNT_BAD)   ; Find any negative or very high values 
  IF COUNT_BAD GE 1 THEN FUCO(BAD) = MISSINGS(0.0)      ; Replace any negative or very high values with missing code
  GONE, MFUCO
  GONE, OFUCO
  GONE, C1
  GONE, C2  

; ***** CARO *****
  C1=10.^(CARO_COEFF_1[0]+CARO_COEFF_1[1]*X1+CARO_COEFF_1(2)*X1^2+CARO_COEFF_1(3)*X1^3)
	C2=10.^(CARO_COEFF_2[0]+CARO_COEFF_2[1]*X2+CARO_COEFF_2(2)*X2^2+CARO_COEFF_2(3)*X2^3)
	MCARO = C1 & OCARO = MCARO                            ; MCARO is the array to hold the "Maximum" caro & OCARO is the array to hold the "output" caro  
  OK_C2 = WHERE(C2 GT C1,COUNT_C2)                      ; Find where C2 is greater than C1    
  IF COUNT_C2 GE 1 THEN MCARO(OK_C2) = C2(OK_C2)        ; Fill in MCARO with the "maximum" caro from C1 & C2  
  OK_X1 = WHERE(X1 LE 0.15,COUNT_X1)                    ; Find where the R1 waveband ratio is less than 0.15
  IF COUNT_X1 GT 0 THEN OCARO(OK_X1) = MCARO(OK_X1)     ; If X1 is less than 0.15, then use the "maximum" caro from C1 & C2 (MCARO), otherwise use the caro from C1
  IF VERSION NE 'V1_0' THEN BEGIN                       ; BUG found on 8/27/2018 by KJWH.  Addition of the search for R670 < 0.0001 is valid for V1_1 and higher
    OK_R6 = WHERE(R670 LT 0.0001, COUNT_R6)             ; Find where R670(R667) is less than 0.0001
    IF COUNT_R6 GT 0 THEN OCARO(OK_R6) = C1(OK_R6)      ; If R670(R667) is less than 0.0001 then use C1 
  ENDIF
  CARO(OK_GOOD) = OCARO                                 ; Input the "output" caro data into the full caro array  
  BAD = WHERE(CARO LE 0.0 OR CARO GT 200.0,COUNT_BAD)   ; Find any negative or very high values 
  IF COUNT_BAD GE 1 THEN CARO(BAD) = MISSINGS(0.0)      ; Replace any negative or very high values with missing code
  GONE, MCARO
  GONE, OCARO
  GONE, C1
  GONE, C2
		
; ===> Group B Pigments  		
; ***** CHLB *****
  C1=10.^(CHLB_COEFF[0]+CHLB_COEFF[1]*X1+CHLB_COEFF(2)*X1^2+CHLB_COEFF(3)*X1^3)
  CHLB(OK_GOOD) = C1                                    ; Input data into the chl array
  BAD = WHERE(CHLB LE 0.0 OR CHLB GT 200.0,COUNT_BAD)   ; Find any negative or very high values
  IF COUNT_BAD GE 1 THEN CHLB(BAD) = MISSINGS(0.0)      ; Replace any negative or very high values with missing code
  GONE, C1		
		
; ***** NEO *****
  C1=10.^(NEO_COEFF[0]+NEO_COEFF[1]*X1+NEO_COEFF(2)*X1^2+NEO_COEFF(3)*X1^3)
  NEO(OK_GOOD) = C1                                     ; Input data into the neo array
  BAD = WHERE(NEO LE 0.0 OR NEO GT 200.0,COUNT_BAD)     ; Find any negative or very high values
  IF COUNT_BAD GE 1 THEN NEO(BAD) = MISSINGS(0.0)       ; Replace any negative or very high values with missing code
  GONE, C1

; ***** VIOLA *****
  C1=10.^(VIOLA_COEFF[0]+VIOLA_COEFF[1]*X1+VIOLA_COEFF(2)*X1^2+VIOLA_COEFF(3)*X1^3)
  VIOLA(OK_GOOD) = C1                                   ; Input data into the viola array
  BAD = WHERE(VIOLA LE 0.0 OR VIOLA GT 200.0,COUNT_BAD) ; Find any negative or very high values
  IF COUNT_BAD GE 1 THEN VIOLA(BAD) = MISSINGS(0.0)     ; Replace any negative or very high values with missing code
  GONE, C1

; ***** DIA *****
  C1=10.^(DIA_COEFF[0]+DIA_COEFF[1]*X1+DIA_COEFF(2)*X1^2+DIA_COEFF(3)*X1^3)
  DIA(OK_GOOD) = C1                                     ; Input data into the dia array
  BAD = WHERE(DIA LE 0.0 OR DIA GT 200.0,COUNT_BAD)     ; Find any negative or very high values
  IF COUNT_BAD GE 1 THEN DIA(BAD) = MISSINGS(0.0)       ; Replace any negative or very high values with missing code
  GONE, C1

; ***** LUT *****
  C1=10.^(LUT_COEFF[0]+LUT_COEFF[1]*X1+LUT_COEFF(2)*X1^2+LUT_COEFF(3)*X1^3)
  LUT(OK_GOOD) = C1                                     ; Input data into the lut array
  BAD = WHERE(LUT LE 0.0 OR LUT GT 200.0,COUNT_BAD)     ; Find any negative or very high values
  IF COUNT_BAD GE 1 THEN LUT(BAD) = MISSINGS(0.0)       ; Replace any negative or very high values with missing code
  GONE, C1		
				
; ***** ALLO *****			
	C1=10.^(ALLO_COEFF_1[0]+ALLO_COEFF_1[1]*X1+ALLO_COEFF_1(2)*X1^2+ALLO_COEFF_1(3)*X1^3)
	C2=10.^(ALLO_COEFF_2[0]+ALLO_COEFF_2[1]*X2+ALLO_COEFF_2(2)*X2^2+ALLO_COEFF_2(3)*X2^3)	                     
  IF VERSION EQ 'V1_0' THEN OK_C2 = WHERE(X1 LE 0.15,COUNT_C1) $                   ; Find where X1 is less than 0.15 
                       ELSE OK_C2 = WHERE(X1 LE 0.15 AND R670 GE 0.0001,COUNT_C1)  ; BUG found on 8/27/2018 by KJWH.  Addition of the search for R670 > 0.0001 is valid for V1_1 and higher
  IF COUNT_C1 GE 1 THEN C1(OK_C2) = C2(OK_C2)                                      ; Use C2 when X1 is less than 0.15 (and R670 GE 0.0001)  
  ALLO(OK_GOOD) = C1                                                               ; Input data into the pigment array  
  BAD = WHERE(ALLO LE 0.0 OR ALLO GT 200.0,COUNT_BAD)                              ; Replace any negative or very high values with missing code
  IF COUNT_BAD GE 1 THEN ALLO(BAD) = MISSINGS(0.0)
  GONE, C1
  GONE, C2	
  
; ***** PERID *****
  C1=10.^(PERID_COEFF_1[0]+PERID_COEFF_1[1]*X1+PERID_COEFF_1(2)*X1^2+PERID_COEFF_1(3)*X1^3)
  C2=10.^(PERID_COEFF_2[0]+PERID_COEFF_2[1]*X2+PERID_COEFF_2(2)*X2^2+PERID_COEFF_2(3)*X2^3)
  IF VERSION EQ 'V1_0' THEN OK_C2 = WHERE(X1 LE 0.15,COUNT_C1) $                   ; Find where X1 is less than 0.15 
                       ELSE OK_C2 = WHERE(X1 LE 0.15 AND R670 GE 0.0001,COUNT_C1)  ; BUG found on 8/27/2018 by KJWH.  Addition of the search for R670 > 0.0001 is valid for V1_1 and higher
  IF COUNT_C1 GE 1 THEN C1(OK_C2) = C2(OK_C2)                                      ; Use C2 when X1 is less than 0.15 (and R670 GE 0.0001)  
  PERID(OK_GOOD) = C1                                                              ; Input data into the pigment array  
  BAD = WHERE(PERID LE 0.0 OR PERID GT 200.0,COUNT_BAD)                            ; Replace any negative or very high values with missing code
  IF COUNT_BAD GE 1 THEN PERID(BAD) = MISSINGS(0.0)
  GONE, C1
  GONE, C2	
			
; ===> Group C Pigments								
; ***** ZEA *****		
  C1=10.^(ZEA_COEFF[0]+ZEA_COEFF[1]*XZEA+ZEA_COEFF(2)*XZEA^2+ZEA_COEFF(3)*XZEA^3)
  ZEA(OK_GOOD) = C1                                     ; Input data into the zea array  
  BAD = WHERE(ZEA LE 0.0 OR ZEA GT 200.0,COUNT_BAD)     ; Find any negative or very high values 
  IF COUNT_BAD GE 1 THEN ZEA(BAD) = MISSINGS(0.0)       ; Replace negative or very high values with missing code
  GONE, C1
  
  GONE, R490
  GONE, R555
  GONE, R670
  GONE, DSST

; ===> Return the pigment data as a structure
  RETURN, CREATE_STRUCT('CHLA',CHLA,'CHLB',CHLB,'CHLC',CHLC,'CARO',CARO,'ALLO',ALLO,'FUCO',FUCO,'PERID',PERID,'NEO',NEO,'VIOLA',VIOLA,'DIA',DIA,'ZEA',ZEA,'LUT',LUT)
  

END
