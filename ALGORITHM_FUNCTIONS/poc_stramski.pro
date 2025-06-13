; $ID:	POC_STRAMSKI.PRO,	2023-09-21-13,	USER-KJWH	$

FUNCTION POC_STRAMSKI, Rrs490=Rrs490, Rrs555=Rrs555, WAVELENGTH=WAVELENGTH, VERSION=VERSION

; +
;	NAME:
;	  POC_STRAMSKI
;	
;	PURPOSE:
;	  This Function returns the Particulate Organic Carbon Estimate (POC) from Rrs555
; 
; CATEGORY:
;   ALGORITHM FUNCTIONS
;   
; REQUIRED INPUTS:
;   RRS490............ The data value at the RRS 490 wavelength
;   RRS555............ The data value at the RRS 555 wavelength
;   
; OPTIONAL INPUTS:
;   WAVELENGTH......... The wavelength of the Rrs "555" data (e.g. 550, 547, 560)
;   VERSION............ The VERSION of the code to use
;   
; KEYWORD PARAMETERS:
;  
;    
; OUTPUTS:
;    This function returns particulate organic carbon estimates in the same dimensions as the input data
; 
; OPTIONAL OUTPUTS:
; 
; COMMON BLOCKS:
;   None
;   
; SIDE EFFECTS:
;   None
;
; RESTRICTIONS:
;   None
;
; EXAMPLES:
;  PRINT, POC_STRAMSKI([0.001, 0.0011, 0.002, 0.007, -9.], MISSING= -9) 
;     0.000000      9.13649      72.7628      341.791     -9.00000
;
;
;
; NOTES:
;   Citation: Stramski,D., R.Reynolds, M.Kahru and B.Greg Mitchel, 1999. Estimation of particulate organic carbon in the ocean from satellite remote sensing. Science, 285:239-242.
;             Stramski, D., et al. (2008), Relationships between the surface concentration of particulate organic carbon and optical properties in the eastern South Pacific and eastern Atlantic Oceans, Biogeosciences, 5(1), 171-201. doi:10.5194/bg-5-171-2008
;             
;   POC empirical function is based on Antartic Polar Frontal Zone (APFZ) Data
;   ===> Power regression of POC versus Particulate Matter Backscattering (bbp510)
;           POC mg m-3) = 17069.0 * bbp510(m-1)^0.859       ; FIGURE 1, P240
;           With bbp510 from 0.0004 to 0.015 m-1 and  POC from 20 to 300 mg m-3
;   ===> Linear regression of Total Backscattering (bb510) versus Rrs555
;           bb510 (m-1)       = 1.756 * Rrs555 - 4.772e-4   ; FIGURE 2, P240
;           With Rrs555 (1/sr)  from 0.001 to 0.007
;   ===> Backscatter from water (bbw510) = 0.0013 m-1
;           bb510  = bbp510 + bbw510
;           bbp510 = bb510  - bbw510
;
;   Final Equation relating Rrs555 to POC
;   POC (mgm-3) = 17069.0 *  bbp510(m-1)^0.859
;   POC (mgm-3) = 17069.0 * (bb510  - bbw510) ^0.859
;   POC (mgm-3) = 17069.0 * ((1.756   * Rrs555 - 4.772e-4 )  - bbw510) ^0.859
;   POC (mgm-3) = 17069.0 * ((1.756   * Rrs555 - 4.772e-4 )  - 0.0013) ^0.859
;   POC (mgm-3) = 17069.0 * ( 1.756   * Rrs555 - 0.00177720          ) ^0.859
;
;   ===> Email update from M. Kahru April 20, 2003 to J.O'Reilly;
;   POC [mg/m^3] from Rrs(555)[1/sr] is:
;   POC = (10^4.2322072) * [1.7564525 * Rrs(555) - 1.7772217*10^(-3)]^0.8586392
;
;   ===> Update from M. Kahru with more precise coefficients than given in Science Report manuscript
;   POC = 17069.0 * ( 1.7564525 * Rrs555 - 0.0017772217     ) ^0.8586392
;
;   ===> Equation modified based on recommendations from Antonio Mannino (April, 2008)
;   POC = 232.145 * (Rrs490/Rrs555)^-1.4651
;
; COPYRIGHT:
; Copyright (C) 2003, Department of Commerce, National Oceanic and Atmospheric Administration, National Marine Fisheries Service,
;   Northeast Fisheries Science Center, Narragansett Laboratory.
;   This software may be used, copied, or redistributed as long as it is not sold and this copyright notice is reproduced on each copy made.
;   This routine is provided AS IS without any express or implied warranties whatsoever.
;
;   This program was written April 20, 2003 by John E. O'Reilly, Northeast Fisheries Science Center | NOAA Fisheries | U.S. Department of Commerce, 28 Tarzwell Dr, Narragansett, RI 02882
;
;
; MODIFICATION HISTORY:
;		Apr 20, 2003 - JEOR: Initial code written
;		Apr 04, 2008 - KJWH: Changed the equation according to recommendations from Antonio Mannino
;   Mar 16, 2010 - KJWH: Changed the equation according to the SeaDAS code at http://oceancolor.gsfc.nasa.gov/DOCS/OCSSW/get__poc_8c_source.html											
;   Oct 21, 2021 - KJWH: Updated documentation and formatting
;                        Removed ERROR and ERR_MSG output variables
;                        Added COMPILE_OPT IDL2
;                        Changed subscript () to []
;                        Removed the step to convert the LWN to RRS (obsolete)
;                        Added WAVELENGTH variable to be used to convert the RRS to 555
;-
; *************************************************************************
  ROUTINE_NAME='POC_STRAMSKI'
  COMPILE_OPT IDL2
  
; ===> Check input data
  IF N_ELEMENTS(RRS555) NE N_ELEMENTS(RRS490) THEN MESSAGE, 'ERROR: The Rrs 490 and Rrs 555 data arrays must have the same number of elements'
  IF N_ELEMENTS(RRS555) EQ 0 THEN MESSAGE, 'ERROR: Missing input data.'
  IF N_ELEMENTS(WAVELENGTH) GT 1 THEN MESSAGE, 'ERROR: WAVELENGTH must be a single value'
  IF N_ELEMENTS(WAVELENGTH) EQ 0 THEN WAVE = 555 ELSE WAVE = FIX(STRMID(WAVELENGTH,2,/REVERSE_OFFSET))  ; Assume the input wavelength is 555 if not provided 
  IF N_ELEMENTS(VERSION) NE 1 THEN VERSION = 'VER2'

; ===> Create a POC array the same size as the input data array and make the values "missing"
	POC = RRS555 & POC[*] = MISSINGS(POC)

	RRS_LOW = 0.001

	OK = WHERE(RRS490 NE MISSINGS(RRS490) AND FINITE(RRS490) AND RRS490 GE RRS_LOW AND $       ; Find valid data
             RRS555 NE MISSINGS(RRS555) AND FINITE(RRS555) AND RRS555 GE RRS_LOW,COUNT)
  IF COUNT EQ 0 THEN RETURN, FLOAT(POC) ; No valid data found so return missing values
    
  IF WAVE NE 555 THEN RRS555[OK] = CONVERT_RRS_555(RRS555[OK], WAVE)

 	CASE VERSION OF
 	  'VER1': POC[OK] = 232.145 * ((DOUBLE(RRS490[OK])/DOUBLE(RRS555[OK]))^(-1.4651))     ; mg m^-3  2008 Modification from Antonio
 	  'VER2': POC[OK] = 308.3   * ((DOUBLE(RRS490[OK])/DOUBLE(RRS555[OK]))^(-1.639))      ; mg m^-3  2010 Modifcation based on SeaDAS
 	ENDCASE

; ==> Set any negative values to zero
  OK = WHERE(POC LE 0,COUNT)
  IF COUNT GE 1 THEN POC[OK] = MISSINGS(POC)

  RETURN, POC

END; #####################  End of Routine ################################
