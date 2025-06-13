; $Id: TRICUBE.pro $  VERSION: March 26,2002
;+
;	This Function returns weights using the tricube function
; SYNTAX:
;
;	Result  = TRICUBE(Arr,Cen)
; OUTPUT:
; ARGUMENTS:
;		Arr: 	An array of usually x-axis distance values
;		Cen:	A scalar value at the location for which the tricube weighted value is desired
;
; NOTES:
; *****************************************************************************************
; Examples from NIST: Engineering Statistics Handbook, Example of Loess Computations
; http://www.itl.nist.gov/div898/handbook/pmd/section1/dep/dep144.htm
; cen = 0.5578196 ; Point of Estimation
; x          y     Distance  Distance   Weight
;	0.5578196  18.63654 0.000000 0.0000000 1.00000000
;	2.0217271 103.49646 1.463907 0.3217691 0.90334913
;	2.5773252 150.35391 2.019506 0.4438904 0.75988974
;	3.4140288 190.51031 2.856209 0.6277992 0.42621714
;	4.3014084 208.70115 3.743589 0.8228466 0.08686171
;	4.7448394 213.71135 4.187020 0.9203134 0.01072308
;	5.1073781 228.49353 4.549558 1.0000000 0.00000000
; cen = 0.5578196
; arr=[0.5578196,2.0217271,2.5773252,3.4140288,4.3014084,4.7448394,5.1073781]
;IDL> print, weight
;       1.0000000      0.90334912      0.75988974      0.42621708     0.086861716     0.010723108 -3.8857637e-021


; cen = 2.5773252 ; Point of Estimation
;	x          y     Distance  Distance   Weight
;0.5578196  18.63654 2.0195055 0.7982068 0.1186858
;2.0217271 103.49646 0.5555981 0.2195994 0.9685654
;2.5773252 150.35391 0.0000000 0.0000000 1.0000000
;3.4140288 190.51031 0.8367037 0.3307060 0.8953727
;4.3014084 208.70115 1.7240833 0.6814416 0.3194020
;4.7448394 213.71135 2.1675143 0.8567071 0.0511567
;5.1073781 228.49353 2.5300530 1.0000000 0.0000000
;arr=[0.5578196,2.0217271,2.5773252,3.4140288,4.3014084,4.7448394,5.1073781]
;cen = 2.5773252
; IDL> print, weight
; 0.11868579      0.96856545       1.0000000      0.89537262      0.31940198     0.051156749      0.00000000
; *****************************************************************************************


; HISTORY:
;		March 26,2002	Written by:	J.E. O'Reilly, NOAA, 28 Tarzwell Drive, Narragansett, RI 02882
;-
; *************************************************************************

FUNCTION TRICUBE,arr,cen
  ROUTINE_NAME='TRICUBE'

  max_dist =   MAX(ABS(cen  - DOUBLE(arr))) ; maximum distance from cen to either end

; ==================> dx is the
  RETURN, (1.0d -   (ABS( (cen-arr)/ max_dist ) )^3)^3

END; #####################  End of Routine ################################
