; $ID:	FILTER_TRICUBE.PRO,	2020-07-08-15,	USER-KJWH	$
 	
 	FUNCTION FILTER_TRICUBE, ARRAY, WIDTH=WIDTH, MISSING=MISSING
;+
; NAME:
;		FILTER_TRICUBE
;
;
; PURPOSE:
;	  Smooth a 1 or 2-d data array using a TRICUBE weighted kernel
;
;
; CATEGORY:
;		Math
;
;
; CALLING SEQUENCE:
;		RESULT = FILTER_TRICUBE(ARR,WIDTH)
;
;
; INPUTS:
;		ARRAY..... A 1 or 2-d array
;
;
; OPTIONAL INPUTS:
;		WIDTH..... The width for the filter (default = 5)
;		MISSING... The data value which is INVALID and should be ignored as missing data
;						   The default missing is based on the IDL data type and MISSINGS.PRO
;
;
; OUTPUTS:
;		A Double-Precision filtered 1 or 2-d array of the size of the input Data
;
;
; OPTIONAL OUTPUTS:
;		NONE
;
;
; RESTRICTIONS:
;		The filter WIDTH must be greater than 3 and less than or equal to the dimension(s) of the input Data array
;
;  
; PROGRAM NOTES:
;   The following examples of the TRI-CUBE weighting function are from the NIST: Engineering Statistics Handbook, Example of Loess Computations
;     http://www.itl.nist.gov/div898/handbook/pmd/section1/dep/dep144.htm
;       
;         CEN = 0.5578196 ; Point of Estimation
;         X          Y          DISTANCE  DISTANCE   WEIGHT
;         0.5578196   18.63654  0.000000  0.0000000  1.00000000
;         2.0217271  103.49646  1.463907  0.3217691  0.90334913
;         2.5773252  150.35391  2.019506  0.4438904  0.75988974
;         3.4140288  190.51031  2.856209  0.6277992  0.42621714
;         4.3014084  208.70115  3.743589  0.8228466  0.08686171
;         4.7448394  213.71135  4.187020  0.9203134  0.01072308
;         5.1073781  228.49353  4.549558  1.0000000  0.00000000
;         cEN = 0.5578196
;         ARR=[0.5578196, 2.0217271, 2.5773252, 3.4140288, 4.3014084, 4.7448394, 5.1073781]
;         IDL> PRINT, WEIGHT
;               1.0000000      0.90334912      0.75988974      0.42621708     0.086861716     0.010723108 -3.8857637e-021
;
;
;         cen = 2.5773252 ; Point of Estimation
;         X          Y          DISTANCE   DISTANCE   WEIGHT
;         0.5578196   18.63654  2.0195055  0.7982068  0.1186858
;         2.0217271  103.49646  0.5555981  0.2195994  0.9685654
;         2.5773252  150.35391  0.0000000  0.0000000  1.0000000
;         3.4140288  190.51031  0.8367037  0.3307060  0.8953727
;         4.3014084  208.70115  1.7240833  0.6814416  0.3194020
;         4.7448394  213.71135  2.1675143  0.8567071  0.0511567
;         5.1073781  228.49353  2.5300530  1.0000000  0.0000000
;         ARR=[0.5578196, 2.0217271, 2.5773252 ,3.4140288,4.3014084,4.7448394,5.1073781]
;         CEN = 2.5773252
;         IDL> PRINT, WEIGHT
;           0.11868579      0.96856545       1.0000000      0.89537262      0.31940198     0.051156749      0.00000000
; *****************************************************************************************
;
;
;	NOTES:
;	Copyright (C) 2018, Department of Commerce, National Oceanic and Atmospheric Administration, National Marine Fisheries Service,
;   Northeast Fisheries Science Center, Narragansett Laboratory.
;   This software may be used, copied, or redistributed as long as it is not sold and this copyright notice is reproduced on each copy made.
;   This routine is provided AS IS without any express or implied warranties whatsoever.
;
;   This program was written by John E. O'Reilly, DOC/NOAA/NMFS/NEFSC Narragansett, RI
;          with assistance from Kimberly Hyde, DOC/NOAA/NMFS/NEFSC Narragansett, RI, kimberly.hyde@noaa.gov.
;   For questions about the code, contact kimberly.hyde@noaa.gov       
;
;
; MODIFICATION HISTORY:
;			Written:  Jan 29, 2007 by J.O'Reilly, NOAA/NEFSC/Narragansett Laboratory, 28 Tarzwell Drive, 02882 
;			Modified: Aug 01, 2018 - KJWH: Updated the formatting
;			                               Updated the documentation 
;			                               Removed the FILTER keyword
;			                               Removed the ERROR keyword and replaced with the MESSAGE to report the error
;			                               Changed the DATA keyword to ARR to avoid conflicts with IDL's DATA 
;			                               Removed the call to the external fuction WEIGHT_TRICUBE and now calculating the weights within the program
;-
;	****************************************************************************************************
	ROUTINE_NAME = 'FILTER_TRICUBE'

;	===> Defaults Width
	IF N_ELEMENTS(WIDTH) NE 1 THEN WIDTH = 5  ; Default WIDTH
	IF N_ELEMENTS(NAN)   NE 1 THEN NAN = 1    ; NON-FINITE values (NAN, INFINITY) are considered invalid when using CONVOL

	IF N_ELEMENTS(MISSING) NE 1 THEN _MISSING = MISSINGS(ARRAY) ELSE _MISSING = MISSING

;	===> Ensure width GE 3 and less than the width of the data array:
	IF WIDTH LT 3 THEN MESSAGE, 'ERROR: WIDTH must be greater than 3'
	SZ=SIZE(ARR,/STRUCT) ;  ===> Get the size of input data
	IF (SZ.N_DIMENSIONS EQ 1 AND WIDTH GT SZ.DIMENSIONS[0]) OR $
	   (SZ.N_DIMENSIONS EQ 2 AND (WIDTH GT SZ.DIMENSIONS[0] OR WIDTH GT SZ.DIMENSIONS[1])) THEN MESSAGE,'ERROR: WIDTH must be less than the input data array dimensions'
	  	
;	===> Center of filter
	CENTER = WIDTH/2

; ===> Create a floating point array
	X=FINDGEN(WIDTH)

;	===> Get the filter weights
  MAX_DIST = MAX(ABS(CENTER - DOUBLE(X))) ; maximum distance from cen to either end
  WT = (1.0d - (ABS((CENTER-X)/MAX_DIST))^3)^3
	KERNEL = WT
	IF SZ.N_DIMENSIONS EQ 2 THEN KERNEL = WT # TRANSPOSE(WT)


;	===> Convolution of Data with kernel 
	RETURN, CONVOL(ARRAY,KERNEL,TOTAL(KERNEL), INVALID=_MISSING, MISSING=_MISSING, /NORMALIZE, /EDGE_TRUNCATE)


END; #####################  End of Routine ################################
